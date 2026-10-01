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
    readonly property string style: Plasmoid.configuration.style || "mixed"
    readonly property bool labelsAllowed: style !== "mixed" && style !== "dots"
    readonly property string labelMode: labelsAllowed ? (Plasmoid.configuration.labelMode || "none") : "none"
    readonly property bool labeled: labelMode !== "none"
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
    readonly property real inactiveOpacity: Math.max(0.35, Number(Plasmoid.configuration.inactiveOpacity) || 0.45)
    readonly property bool animations: Plasmoid.configuration.animations
    readonly property string occupancyStyle: Plasmoid.configuration.occupancyStyle || "dot"
    readonly property bool showWindowCount: Plasmoid.configuration.showWindowCount
    readonly property bool tooltips: Plasmoid.configuration.tooltips
    readonly property int shown: Math.max(desktopCount, 1)

    readonly property real dot: {
        const value = Number(Plasmoid.configuration.dotSize)
        return Math.max(4, Number.isFinite(value) && value > 0 ? value : 10)
    }
    readonly property real pillLength: Math.round(dot * 2.6)
    readonly property real gap: {
        const value = Number(Plasmoid.configuration.gap)
        return Number.isFinite(value) ? Math.max(0, value) : 4
    }
    readonly property real pad: Math.round(Kirigami.Units.smallSpacing / 2)
    readonly property real contentCross: labeled ? Math.max(dot, Math.ceil(fontMetrics.height + 4)) : dot
    readonly property real slotCross: contentCross
    readonly property real contentW: vertical ? contentCross : slotMain
    readonly property real contentH: vertical ? slotMain : contentCross
    readonly property font labelFont: Qt.font({
        family: Kirigami.Theme.defaultFont.family,
        pixelSize: Math.max(10, Math.round(dot * 0.95)),
        weight: Font.Medium
    })
    readonly property real slotMain: {
        const base = style === "dots" ? dot : pillLength
        if (!labeled && style !== "buttons")
            return base
        return Math.max(base, Math.ceil(labelWidth + Math.max(8, dot * 0.8)))
    }
    readonly property real slotW: vertical ? slotCross : slotMain
    readonly property real slotH: vertical ? slotMain : slotCross
    readonly property real stripLength: shown * slotMain + Math.max(0, shown - 1) * gap
    readonly property real labelWidth: {
        let w = 0
        const count = desktopCount
        for (let i = 0; i < count; ++i)
            w = Math.max(w, fontMetrics.boundingRect(labelFor(i)).width)
        return w
    }

    function labelFor(index) {
        if (labelMode === "name")
            return desktopModel.desktopName(index)
        if (labelMode === "index")
            return (Plasmoid.configuration.indexPrefix || "") + (index + Plasmoid.configuration.indexStart)
        return ""
    }

    function slotOrigin(index) {
        const main = index * (slotMain + gap)
        const visual = rtl ? (shown - 1 - index) * (slotMain + gap) : main
        const extraX = Math.max(0, (width - (vertical ? slotW : stripLength) - pad * 2) / 2)
        const extraY = Math.max(0, (height - (vertical ? stripLength : slotH) - pad * 2) / 2)
        if (vertical)
            return Qt.point(pad + extraX, pad + extraY + visual)
        return Qt.point(pad + extraX + visual, pad + extraY)
    }

    implicitWidth: (vertical ? slotW : stripLength) + pad * 2
    implicitHeight: (vertical ? stripLength : slotH) + pad * 2

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
        visible: pager.style !== "buttons" && pager.desktopCount > 0
        radius: Math.min(width, height) / 2
        color: pager.activeColor
        property bool ready: false
        width: pager.style === "dots" ? pager.dot : pager.contentW
        height: pager.style === "dots" ? pager.dot : pager.contentH
        x: {
            const item = shapes.itemAt(desktopModel.currentIndex)
            if (!item)
                return pager.pad
            return item.x + (item.width - width) / 2
        }
        y: {
            const item = shapes.itemAt(desktopModel.currentIndex)
            if (!item)
                return pager.pad
            return item.y + (item.height - height) / 2
        }
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
        Component.onCompleted: Qt.callLater(function() { indicator.ready = true })
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

    function openDesktopMenu(index, item, mouse) {
        desktopMenu.desktopIndex = index
        desktopMenu.visualParent = item
        desktopMenu.open(mouse.x, mouse.y)
    }
}
