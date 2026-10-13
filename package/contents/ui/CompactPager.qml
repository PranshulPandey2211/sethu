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
    readonly property string customIcon: String(Plasmoid.configuration.customIcon || "")
    readonly property bool hasIcon: customIcon.length > 0
    readonly property bool iconIsFile: customIcon.indexOf("/") !== -1 || customIcon.indexOf("file:") === 0
    readonly property real inactiveBorderWidth: Math.max(0, Number(Plasmoid.configuration.inactiveBorderWidth) || 0)
    readonly property color inactiveBorderColor: Plasmoid.configuration.inactiveBorderColor || inactiveColor
    readonly property real activeBorderWidth: Math.max(0, Number(Plasmoid.configuration.activeBorderWidth) || 0)
    readonly property color activeBorderColor: Plasmoid.configuration.activeBorderColor || activeColor
    readonly property string occupancyStyle: Plasmoid.configuration.occupancyStyle || "dot"
    readonly property bool showWindowCount: Plasmoid.configuration.showWindowCount
    readonly property bool tooltips: Plasmoid.configuration.tooltips
    readonly property int shown: Math.max(desktopCount, 1)

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
    readonly property real contentW: cellW
    readonly property real contentH: cellH
    readonly property font labelFont: Qt.font({
        family: Kirigami.Theme.defaultFont.family,
        pixelSize: Math.max(8, Math.round(Math.min(cellW, cellH) * 0.7)),
        weight: Font.Medium
    })
    readonly property real slotMain: vertical ? cellH : cellW
    readonly property real slotCross: vertical ? cellW : cellH
    readonly property real slotW: cellW
    readonly property real slotH: cellH
    readonly property real stripLength: shown * slotMain + Math.max(0, shown - 1) * gap

    function labelFor(index) {
        if (labelMode === "name")
            return desktopModel.desktopName(index)
        if (labelMode === "index")
            return (Plasmoid.configuration.indexPrefix || "") + (index + Plasmoid.configuration.indexStart)
        return ""
    }

    readonly property real stripOffsetX: {
        const slack = width - (vertical ? slotW : stripLength) - pad * 2
        return pad + Math.max(0, slack) / 2
    }
    readonly property real stripOffsetY: {
        const slack = height - (vertical ? stripLength : slotH) - pad * 2
        return pad + Math.max(0, slack) / 2
    }

    function slotOrigin(index) {
        const main = index * (slotMain + gap)
        const visual = rtl ? (shown - 1 - index) * (slotMain + gap) : main
        if (vertical)
            return Qt.point(Math.round(stripOffsetX), Math.round(stripOffsetY + visual))
        return Qt.point(Math.round(stripOffsetX + visual), Math.round(stripOffsetY))
    }

    property bool settled: false
    implicitWidth: (vertical ? slotCross : stripLength) + pad * 2
    implicitHeight: (vertical ? stripLength : slotCross) + pad * 2
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

    readonly property Item activeSlot: shapes.itemAt(desktopModel.currentIndex)

    Rectangle {
        id: indicator
        z: 1
        visible: pager.activeSlot !== null
        radius: pager.activeRadius
        color: pager.activeColor
        opacity: pager.activeOpacity
        border.width: pager.activeBorderWidth
        border.color: pager.activeBorderColor
        property bool canAnimate: false
        property bool layoutReady: false
        width: pager.activeW
        height: pager.activeH
        x: pager.activeSlot ? Math.round(pager.activeSlot.x + (pager.activeSlot.width - width) / 2) : 0
        y: pager.activeSlot ? Math.round(pager.activeSlot.y + (pager.activeSlot.height - height) / 2) : 0
        Behavior on x {
            enabled: indicator.canAnimate && pager.animations
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on y {
            enabled: indicator.canAnimate && pager.animations
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.OutCubic
            }
        }
        function snapLayout() {
            canAnimate = false
            Qt.callLater(function() {
                if (!pager.activeSlot)
                    return
                canAnimate = pager.animations
                pager.settled = true
            })
        }
        Component.onCompleted: snapLayout()
    }

    onWidthChanged: indicator.snapLayout()
    onHeightChanged: indicator.snapLayout()
    Connections {
        target: pager
        function onActiveSlotChanged() {
            if (pager.activeSlot && !indicator.layoutReady) {
                indicator.layoutReady = true
                indicator.snapLayout()
            }
        }
    }
    Connections {
        target: desktopModel
        function onDesktopCountChanged() { indicator.snapLayout() }
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
        let pos = (vertical ? py : px) - (vertical ? stripOffsetY : stripOffsetX)
        if (rtl)
            pos = stripLength - pos
        const stride = slotMain + gap
        if (stride <= 0 || desktopCount < 1)
            return 0
        return Math.max(0, Math.min(desktopCount - 1, Math.floor(pos / stride)))
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
