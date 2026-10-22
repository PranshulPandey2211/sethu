/*
    SPDX-FileCopyrightText: 2026 Pranshul Pandey

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

Item {
    id: slot

    required property int index
    required property Item pagerItem
    required property var desktops
    property bool overlay: false

    readonly property bool active: pagerItem.modelReady && desktops.currentIndex === index
    readonly property var entry: desktops.infoFor(index)
    readonly property bool occupied: entry !== null && entry.count > 0
    readonly property bool urgent: entry !== null && entry.urgent
    readonly property int windowCount: entry !== null ? entry.count : 0
    readonly property string label: pagerItem.labelFor(index)
    readonly property int listedWindows: entry && entry.windows ? entry.windows.length : 0
    readonly property point origin: pagerItem.slotOrigin(index)
    readonly property var slotSize: pagerItem.slotSizeAt(index)
    readonly property var inactiveChip: pagerItem.chipSize(index, false)
    readonly property bool hot: !active && pagerItem.hoveredIndex === index
    property real attention: 1

    x: origin.x
    y: origin.y
    width: slotSize.width
    height: slotSize.height
    z: overlay ? 2 : 0

    Rectangle {
        visible: !slot.overlay && !slot.active
        anchors.centerIn: parent
        width: slot.inactiveChip.width
        height: slot.inactiveChip.height
        radius: slot.pagerItem.inactiveRadius
        color: slot.hot ? Qt.lighter(slot.pagerItem.inactiveColor, 1.3) : slot.pagerItem.inactiveColor
        opacity: Math.min(1, slot.pagerItem.inactiveOpacity
            * (slot.hot ? 1.7 : 1)
            * (slot.urgent && slot.pagerItem.occupancyStyle === "outline" ? slot.attention : 1))
        border.width: slot.pagerItem.inactiveBorderWidth
        border.color: slot.occupied && slot.pagerItem.occupancyStyle === "outline"
            ? (slot.urgent ? slot.pagerItem.urgentColor : slot.pagerItem.activeColor)
            : slot.pagerItem.inactiveBorderColor
    }

    Text {
        visible: slot.overlay && slot.label.length > 0
        anchors.fill: contentBox
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        text: slot.label
        color: slot.active ? slot.pagerItem.labelOnActive : slot.pagerItem.inactiveColor
        font: slot.pagerItem.labelFont
    }

    Item {
        id: contentBox
        anchors.fill: parent
    }

    Rectangle {
        visible: slot.overlay && slot.label.length === 0 && !slot.pagerItem.showWindowCount && slot.pagerItem.occupancyStyle === "dot" && slot.occupied
        width: Math.max(3, Math.round(Math.min(slot.pagerItem.inactiveW, slot.pagerItem.inactiveH) * 0.28))
        height: width
        radius: width / 2
        opacity: slot.urgent ? slot.attention : 1
        color: slot.urgent ? slot.pagerItem.urgentColor : slot.pagerItem.activeColor
        x: contentBox.x + (slot.pagerItem.vertical
            ? contentBox.width - width - Math.max(1, Math.min(slot.pagerItem.inactiveW, slot.pagerItem.inactiveH) * 0.12)
            : (contentBox.width - width) / 2)
        y: contentBox.y + (slot.pagerItem.vertical
            ? (contentBox.height - height) / 2
            : contentBox.height - height - Math.max(1, Math.min(slot.pagerItem.inactiveW, slot.pagerItem.inactiveH) * 0.12))
    }

    Rectangle {
        visible: slot.overlay && slot.pagerItem.occupancyStyle === "underline" && slot.occupied
        opacity: slot.urgent ? slot.attention : 1
        color: slot.urgent ? slot.pagerItem.urgentColor : slot.pagerItem.activeColor
        radius: 1
        x: contentBox.x + (slot.pagerItem.vertical ? contentBox.width - 2 : contentBox.width * 0.18)
        y: contentBox.y + (slot.pagerItem.vertical ? contentBox.height * 0.18 : contentBox.height - height - 1)
        width: slot.pagerItem.vertical ? 2 : contentBox.width * 0.64
        height: slot.pagerItem.vertical ? contentBox.height * 0.64 : 2
    }

    Text {
        visible: slot.overlay && slot.label.length === 0 && slot.pagerItem.showWindowCount && slot.windowCount > 0
        text: slot.windowCount > 99 ? "99" : String(slot.windowCount)
        color: slot.active
            ? slot.pagerItem.labelOnActive
            : (slot.urgent ? slot.pagerItem.urgentColor : slot.pagerItem.inactiveColor)
        font.pixelSize: Math.max(8, Math.round(Math.min(slot.pagerItem.cellW, slot.pagerItem.cellH) * 0.55))
        opacity: slot.urgent ? slot.attention : 1
        font.weight: Font.DemiBold
        x: contentBox.x
        y: contentBox.y
        width: contentBox.width
        height: contentBox.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        visible: slot.overlay
        enabled: slot.overlay && slot.pagerItem.tooltips && slot.listedWindows === 0
        mainText: slot.desktops.desktopName(slot.index)
        subText: slot.desktops.tooltipBody(slot.index)
        location: Plasmoid.location
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            Accessible.name: slot.desktops.desktopName(slot.index)
            Accessible.role: Accessible.Button
            hoverEnabled: true
            property bool dragged: false
            property real pressMain: 0
            onContainsMouseChanged: slot.pagerItem.hoverSlot(slot.index, slot, containsMouse)
            onPressed: (mouse) => {
                dragged = false
                const p = mapToItem(slot.pagerItem, mouse.x, mouse.y)
                pressMain = slot.pagerItem.vertical ? p.y : p.x
            }
            onPositionChanged: (mouse) => {
                if (!slot.pagerItem.dragToSwitch || !(mouse.buttons & Qt.LeftButton))
                    return
                const p = mapToItem(slot.pagerItem, mouse.x, mouse.y)
                const main = slot.pagerItem.vertical ? p.y : p.x
                if (!dragged && Math.abs(main - pressMain) < 6)
                    return
                dragged = true
                slot.pagerItem.closeWindowPopup()
                slot.pagerItem.scrubAt(p.x, p.y)
            }
            onClicked: (mouse) => {
                slot.pagerItem.closeWindowPopup()
                if (dragged && mouse.button === Qt.LeftButton)
                    return
                if (mouse.button === Qt.LeftButton)
                    slot.desktops.leftClick(slot.index)
                else if (mouse.button === Qt.MiddleButton)
                    slot.desktops.middleClick(slot.index)
                else if (mouse.button === Qt.RightButton)
                    slot.pagerItem.openDesktopMenu(slot.index, slot, mouse)
            }
            onWheel: (wheel) => {
                slot.desktops.acceptWheel(wheel)
                wheel.accepted = true
            }
        }
    }

    SequentialAnimation {
        running: slot.urgent && slot.pagerItem.animations
        loops: Animation.Infinite
        NumberAnimation { target: slot; property: "attention"; to: 0.35; duration: 700; easing.type: Easing.InOutSine }
        NumberAnimation { target: slot; property: "attention"; to: 1; duration: 700; easing.type: Easing.InOutSine }
        onRunningChanged: if (!running) slot.attention = 1
    }
}
