/*
    SPDX-FileCopyrightText: 2026 Pranshul Pandey

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

Item {
    id: pager

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool rtl: !vertical && effectiveLayoutDirection === Qt.RightToLeft
    readonly property int desktopCount: desktopModel.desktopCount
    readonly property string labelMode: Plasmoid.configuration.labelMode || "none"
    readonly property bool useSystemColors: Plasmoid.configuration.useSystemColors
    readonly property color activeColor: {
        const themeColor = Kirigami.Theme.highlightColor
        if (!useSystemColors)
            return Plasmoid.configuration.activeColor
        return themeColor.a > 0.05 ? themeColor : "#3daee9"
    }
    readonly property color inactiveColor: {
        const themeColor = Kirigami.Theme.textColor
        if (!useSystemColors)
            return Plasmoid.configuration.inactiveColor
        return themeColor.a > 0.05 ? themeColor : "#fcfcfc"
    }
    readonly property color urgentColor: Kirigami.Theme.negativeTextColor
    readonly property color labelOnActive: Kirigami.Theme.highlightedTextColor
    readonly property real inactiveOpacity: {
        const value = Number(Plasmoid.configuration.inactiveOpacity)
        return Number.isFinite(value) ? Math.max(0.15, Math.min(1, value)) : 0.45
    }
    readonly property real activeOpacity: {
        const value = Number(Plasmoid.configuration.activeOpacity)
        return Number.isFinite(value) ? Math.max(0.15, Math.min(1, value)) : 1
    }
    readonly property bool animations: Plasmoid.configuration.animations
    readonly property real inactiveBorderWidth: Math.max(0, Number(Plasmoid.configuration.inactiveBorderWidth) || 0)
    readonly property color inactiveBorderColor: Plasmoid.configuration.inactiveBorderColor || inactiveColor
    readonly property real activeBorderWidth: Math.max(0, Number(Plasmoid.configuration.activeBorderWidth) || 0)
    readonly property color activeBorderColor: Plasmoid.configuration.activeBorderColor || activeColor
    readonly property string occupancyStyle: Plasmoid.configuration.occupancyStyle || "dot"
    readonly property bool showWindowCount: Plasmoid.configuration.showWindowCount
    readonly property bool tooltips: Plasmoid.configuration.tooltips
    readonly property bool dragToSwitch: Plasmoid.configuration.dragToSwitch
    readonly property int shown: Math.max(desktopCount, 1)
    property int hoveredIndex: -1
    property Item hoverItem: null
    property bool popupContainsMouse: false

    function cappedRadius(w, h, raw) {
        const cap = Math.min(w, h) / 2
        const value = Number(raw)
        return Math.max(0, Math.min(cap, Number.isFinite(value) ? value : cap))
    }

    readonly property real inactiveW: Math.max(4, Number(Plasmoid.configuration.inactiveShapeWidth) || 10)
    readonly property real inactiveH: Math.max(4, Number(Plasmoid.configuration.inactiveShapeHeight) || 10)
    readonly property real inactiveRadius: cappedRadius(inactiveW, inactiveH, Plasmoid.configuration.inactiveShapeRadius)
    readonly property real activeW: Math.max(4, Number(Plasmoid.configuration.activeShapeWidth) || inactiveW)
    readonly property real activeH: Math.max(4, Number(Plasmoid.configuration.activeShapeHeight) || inactiveH)
    readonly property real activeRadius: cappedRadius(activeW, activeH, Plasmoid.configuration.activeShapeRadius)
    readonly property real cellW: Math.max(inactiveW, activeW)
    readonly property real cellH: Math.max(inactiveH, activeH)
    readonly property real gap: {
        const value = Number(Plasmoid.configuration.gap)
        return Number.isFinite(value) ? Math.max(0, value) : 4
    }
    readonly property real pad: {
        const value = Number(Plasmoid.configuration.margin)
        return Number.isFinite(value) ? Math.max(0, value) : 2
    }
    readonly property font labelFont: Qt.font({
        family: Kirigami.Theme.defaultFont.family,
        pixelSize: Math.max(8, Math.round(Math.min(cellW, cellH) * 0.7)),
        weight: Font.Medium
    })

    function chipSize(index, active) {
        const fontSize = labelFont.pixelSize
        let w = active ? activeW : inactiveW
        let h = active ? activeH : inactiveH
        const text = labelFor(index)
        if (text.length > 0) {
            const pad = Math.max(6, Math.round(Math.min(inactiveH, activeH) * 0.35))
            w = Math.max(w, Math.ceil(fontMetrics.advanceWidth(text)) + pad * 2)
            h = Math.max(h, Math.ceil(fontMetrics.height), fontSize)
        }
        return { width: w, height: h }
    }

    function slotSizeAt(index) {
        const inactive = chipSize(index, false)
        const active = chipSize(index, true)
        return {
            width: Math.max(inactive.width, active.width),
            height: Math.max(inactive.height, active.height)
        }
    }

    function mainExtent(index) {
        const sz = slotSizeAt(index)
        return vertical ? sz.height : sz.width
    }

    readonly property real stripLength: {
        const n = shown
        let length = 0
        for (let i = 0; i < n; ++i)
            length += mainExtent(i)
        if (n > 1)
            length += (n - 1) * gap
        return length
    }
    readonly property real stripCross: {
        const n = shown
        let cross = 0
        for (let i = 0; i < n; ++i) {
            const sz = slotSizeAt(i)
            cross = Math.max(cross, vertical ? sz.width : sz.height)
        }
        return Math.max(cross, 4)
    }

    function labelFor(index) {
        if (labelMode === "name")
            return desktopModel.desktopName(index)
        if (labelMode === "index")
            return (Plasmoid.configuration.indexPrefix || "") + (index + Plasmoid.configuration.indexStart)
        return ""
    }

    readonly property real stripOffsetX: {
        const slack = width - (vertical ? stripCross : stripLength) - pad * 2
        return pad + Math.max(0, slack) / 2
    }
    readonly property real stripOffsetY: {
        const slack = height - (vertical ? stripLength : stripCross) - pad * 2
        return pad + Math.max(0, slack) / 2
    }

    function extentBefore(index) {
        let total = 0
        if (rtl) {
            for (let i = shown - 1; i > index; --i)
                total += mainExtent(i) + gap
        } else {
            for (let i = 0; i < index; ++i)
                total += mainExtent(i) + gap
        }
        return total
    }

    function slotOrigin(index) {
        const sz = slotSizeAt(index)
        const before = extentBefore(index)
        const cross = vertical ? (stripCross - sz.width) / 2 : (stripCross - sz.height) / 2
        if (vertical)
            return Qt.point(Math.round(stripOffsetX + cross), Math.round(stripOffsetY + before))
        return Qt.point(Math.round(stripOffsetX + before), Math.round(stripOffsetY + cross))
    }

    readonly property bool modelReady: {
        const n = desktopModel.desktopCount
        const list = desktopModel.ids
        const current = desktopModel.currentId !== undefined && desktopModel.currentId !== null ? String(desktopModel.currentId) : ""
        if (n < 1 || !list || list.length !== n || current.length === 0)
            return false
        for (let i = 0; i < list.length; ++i) {
            if (String(list[i]) === current)
                return true
        }
        return false
    }
    readonly property var indicatorGeo: {
        const index = desktopModel.currentIndex
        const pill = chipSize(index, true)
        const origin = slotOrigin(index)
        const sz = slotSizeAt(index)
        return {
            x: Math.round(origin.x + (sz.width - pill.width) / 2),
            y: Math.round(origin.y + (sz.height - pill.height) / 2),
            width: pill.width,
            height: pill.height
        }
    }
    property bool settled: false
    implicitWidth: (vertical ? stripCross : stripLength) + pad * 2
    implicitHeight: (vertical ? stripLength : stripCross) + pad * 2
    Behavior on implicitWidth {
        enabled: settled && animations
        NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.OutCubic }
    }
    Behavior on implicitHeight {
        enabled: settled && animations
        NumberAnimation { duration: Kirigami.Units.shortDuration; easing.type: Easing.OutCubic }
    }

    Layout.minimumWidth: implicitWidth
    Layout.maximumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.maximumHeight: implicitHeight
    Layout.preferredHeight: implicitHeight

    FontMetrics {
        id: fontMetrics
        font: pager.labelFont
    }

    DesktopModel {
        id: desktopModel
        screenGeometry: {
            const geo = Plasmoid.containment ? Plasmoid.containment.screenGeometry : Qt.rect(0, 0, 0, 0)
            return Qt.rect(geo.x, geo.y, geo.width, geo.height)
        }
    }

    Repeater {
        id: shapes
        model: pager.desktopCount
        delegate: DesktopSlot {
            overlay: false
            pagerItem: pager
            desktops: desktopModel
        }
    }

    Rectangle {
        id: indicator
        z: 1
        visible: pager.modelReady
        radius: pager.activeRadius
        color: pager.activeColor
        opacity: pager.activeOpacity
        border.width: pager.activeBorderWidth
        border.color: pager.activeBorderColor
        property bool ready: false
        x: pager.indicatorGeo.x
        y: pager.indicatorGeo.y
        width: pager.indicatorGeo.width
        height: pager.indicatorGeo.height
        Behavior on x {
            enabled: indicator.ready && pager.animations
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on y {
            enabled: indicator.ready && pager.animations
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on width {
            enabled: indicator.ready && pager.animations
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            enabled: indicator.ready && pager.animations
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.OutCubic
            }
        }
        function arm() {
            if (pager.width <= 0 || pager.height <= 0 || !pager.modelReady) {
                ready = false
                return
            }
            ready = false
            Qt.callLater(function() {
                if (pager.width <= 0 || pager.height <= 0 || !pager.modelReady)
                    return
                ready = true
                pager.settled = true
            })
        }
        Component.onCompleted: arm()
    }

    onModelReadyChanged: indicator.arm()
    onWidthChanged: indicator.arm()
    onHeightChanged: indicator.arm()
    Connections {
        target: desktopModel
        function onDesktopCountChanged() { indicator.arm() }
        function onCurrentIndexChanged() {
            if (!indicator.ready)
                indicator.arm()
        }
    }

    Repeater {
        id: hits
        model: pager.desktopCount
        delegate: DesktopSlot {
            z: 2
            overlay: true
            pagerItem: pager
            desktops: desktopModel
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 0
        acceptedButtons: Qt.NoButton
        onWheel: (wheel) => {
            desktopModel.acceptWheel(wheel)
            wheel.accepted = true
        }
    }

    PlasmaExtras.Menu {
        id: desktopMenu
        property int desktopIndex: 0
        PlasmaExtras.MenuItem {
            text: i18n("Rename")
            enabled: Plasmoid.configuration.manageDesktops
            onClicked: renamePopup.openFor(desktopMenu.desktopIndex)
        }
        PlasmaExtras.MenuItem {
            text: i18n("Add Desktop")
            enabled: Plasmoid.configuration.manageDesktops
            onClicked: desktopModel.addDesktop()
        }
        PlasmaExtras.MenuItem {
            text: i18n("Remove Desktop")
            enabled: Plasmoid.configuration.manageDesktops && desktopModel.desktopCount > 1
            onClicked: desktopModel.removeAt(desktopMenu.desktopIndex)
        }
        PlasmaExtras.MenuItem {
            separator: true
        }
        PlasmaExtras.MenuItem {
            text: i18n("Configure Sethu…")
            onClicked: {
                const action = Plasmoid.internalAction("configure")
                if (action)
                    action.trigger()
            }
        }
    }

    QQC2.Popup {
        id: renamePopup
        popupType: QQC2.Popup.Window
        modal: true
        focus: true
        padding: Kirigami.Units.largeSpacing
        width: Math.max(implicitWidth, Kirigami.Units.gridUnit * 14)
        property int desktopIndex: -1

        ColumnLayout {
            QQC2.Label {
                text: i18n("Rename desktop")
            }
            QQC2.TextField {
                id: nameField
                Layout.fillWidth: true
                selectByMouse: true
                onAccepted: renamePopup.apply()
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                QQC2.Button {
                    text: i18n("Cancel")
                    onClicked: renamePopup.close()
                }
                QQC2.Button {
                    text: i18n("Rename")
                    onClicked: renamePopup.apply()
                }
            }
        }

        function apply() {
            if (desktopIndex >= 0)
                desktopModel.rename(desktopIndex, nameField.text)
            close()
        }

        function openFor(index) {
            desktopIndex = index
            nameField.text = desktopModel.desktopName(index)
            open()
            nameField.selectAll()
            nameField.forceActiveFocus()
        }
    }

    function desktopAt(px, py) {
        const n = desktopCount
        if (n < 1)
            return 0
        let pos = (vertical ? py : px) - (vertical ? stripOffsetY : stripOffsetX)
        if (rtl)
            pos = stripLength - pos
        if (pos <= 0)
            return 0
        let cursor = 0
        for (let i = 0; i < n; ++i) {
            const ext = mainExtent(i)
            if (pos < cursor + ext + gap / 2)
                return i
            cursor += ext + gap
        }
        return n - 1
    }

    function hoverSlot(index, item, inside) {
        if (inside) {
            hoveredIndex = index
            hoverItem = item
            windowPopupCloseTimer.stop()
            const entry = desktopModel.infoFor(index)
            if (entry && entry.windows && entry.windows.length > 0) {
                windowPopupTimer.desktopIndex = index
                windowPopupTimer.restart()
            } else {
                windowPopupTimer.stop()
                windowPopup.close()
            }
        } else if (hoveredIndex === index) {
            hoveredIndex = -1
            hoverItem = null
            windowPopupTimer.stop()
            windowPopupCloseTimer.restart()
        }
    }

    function showWindowPopup(index) {
        const item = hoverItem
        const entry = desktopModel.infoFor(index)
        if (!item || item.index !== index || !entry || !entry.windows || entry.windows.length < 1) {
            windowPopup.close()
            return
        }
        windowPopup.desktopIndex = index
        Qt.callLater(function() {
            if (windowPopup.desktopIndex !== index || hoverItem !== item)
                return
            positionWindowPopup(item)
            if (!windowPopup.opened)
                windowPopup.open()
            Qt.callLater(function() {
                if (windowPopup.desktopIndex === index && hoverItem === item)
                    positionWindowPopup(item)
            })
        })
    }

    function positionWindowPopup(item) {
        const gap = 8
        const w = windowPopup.implicitWidth
        const h = Math.max(windowPopup.implicitHeight, 1)
        const anchor = item.mapToItem(pager, 0, 0)
        let px = anchor.x + (item.width - w) / 2
        let py = anchor.y - h - gap
        const loc = Plasmoid.location
        if (loc === PlasmaCore.Types.TopEdge)
            py = anchor.y + item.height + gap
        else if (loc === PlasmaCore.Types.LeftEdge) {
            px = anchor.x + item.width + gap
            py = anchor.y + (item.height - h) / 2
        } else if (loc === PlasmaCore.Types.RightEdge) {
            px = anchor.x - w - gap
            py = anchor.y + (item.height - h) / 2
        }
        const origin = pager.mapToGlobal(0, 0)
        const geo = desktopModel.screenGeometry
        if (geo.width > 0) {
            const minX = geo.x + 8 - origin.x
            const maxX = geo.x + geo.width - w - 8 - origin.x
            px = Math.min(Math.max(px, minX), Math.max(minX, maxX))
        }
        if (geo.height > 0) {
            const minY = geo.y + 8 - origin.y
            const maxY = geo.y + geo.height - h - 8 - origin.y
            py = Math.min(Math.max(py, minY), Math.max(minY, maxY))
        }
        const slotLeft = anchor.x
        const slotRight = anchor.x + item.width
        const slotTop = anchor.y
        const slotBottom = anchor.y + item.height
        if (px < slotRight && px + w > slotLeft && py < slotBottom && py + h > slotTop) {
            if (loc === PlasmaCore.Types.TopEdge)
                py = slotBottom + gap
            else if (loc !== PlasmaCore.Types.LeftEdge && loc !== PlasmaCore.Types.RightEdge)
                py = slotTop - h - gap
        }
        windowPopup.x = Math.round(px)
        windowPopup.y = Math.round(py)
    }

    function closeWindowPopup() {
        windowPopupTimer.stop()
        windowPopupCloseTimer.stop()
        windowPopup.close()
    }

    Timer {
        id: windowPopupTimer
        interval: 400
        property int desktopIndex: -1
        onTriggered: pager.showWindowPopup(desktopIndex)
    }

    Timer {
        id: windowPopupCloseTimer
        interval: 400
        onTriggered: {
            if (!pager.popupContainsMouse)
                windowPopup.close()
        }
    }

    QQC2.Popup {
        id: windowPopup
        z: 10
        modal: false
        focus: false
        padding: Kirigami.Units.smallSpacing
        popupType: QQC2.Popup.Window
        closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnPressOutside
        property int desktopIndex: -1
        readonly property var entry: desktopIndex >= 0 ? desktopModel.infoFor(desktopIndex) : null
        readonly property var windows: entry && entry.windows ? entry.windows : []
        implicitWidth: Kirigami.Units.gridUnit * 12
        implicitHeight: windowPopupBody.implicitHeight + padding * 2

        Column {
            id: windowPopupBody
            width: windowPopup.implicitWidth - windowPopup.padding * 2
            spacing: Kirigami.Units.smallSpacing

            HoverHandler {
                onHoveredChanged: {
                    pager.popupContainsMouse = hovered
                    if (hovered)
                        windowPopupCloseTimer.stop()
                    else
                        windowPopupCloseTimer.restart()
                }
            }

            QQC2.Label {
                width: parent.width
                elide: Text.ElideRight
                font.weight: Font.DemiBold
                text: windowPopup.desktopIndex >= 0 ? desktopModel.desktopName(windowPopup.desktopIndex) : ""
            }

            Repeater {
                model: windowPopup.windows
                delegate: QQC2.ItemDelegate {
                    id: row
                    required property var modelData
                    width: windowPopupBody.width
                    onClicked: {
                        desktopModel.activateWindow(modelData.winId)
                        pager.closeWindowPopup()
                    }
                    contentItem: Row {
                        spacing: Kirigami.Units.smallSpacing
                        Kirigami.Icon {
                            width: Kirigami.Units.iconSizes.smallMedium
                            height: Kirigami.Units.iconSizes.smallMedium
                            anchors.verticalCenter: parent.verticalCenter
                            source: desktopModel.decorationFor(row.modelData.winId)
                            fallback: "application-x-executable"
                        }
                        QQC2.Label {
                            width: parent.width - Kirigami.Units.iconSizes.smallMedium - Kirigami.Units.smallSpacing
                            anchors.verticalCenter: parent.verticalCenter
                            text: row.modelData.title
                            elide: Text.ElideRight
                            color: row.highlighted || row.down ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        }
                    }
                }
            }

            QQC2.Label {
                width: parent.width
                visible: windowPopup.entry && windowPopup.entry.count > windowPopup.windows.length
                text: windowPopup.entry ? i18n("+%1 more", Math.max(0, windowPopup.entry.count - windowPopup.windows.length)) : ""
            }
        }
    }

    function scrubAt(px, py) {
        const index = desktopAt(px, py)
        if (index !== desktopModel.currentIndex)
            desktopModel.activate(index)
    }

    function openDesktopMenu(index, item, mouse) {
        desktopMenu.desktopIndex = index
        desktopMenu.visualParent = item
        desktopMenu.open(mouse.x, mouse.y)
    }
}
