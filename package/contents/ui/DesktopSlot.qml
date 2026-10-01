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

    readonly property bool active: desktops.currentIndex === index
    readonly property var entry: desktops.infoFor(index)
    readonly property bool occupied: entry !== null && entry.count > 0
    readonly property bool urgent: entry !== null && entry.urgent
    readonly property int windowCount: entry !== null ? entry.count : 0
    readonly property string label: pagerItem.labelFor(index)
    readonly property point origin: pagerItem.slotOrigin(index)
    readonly property bool capsule: pagerItem.style === "pills"
    readonly property real idleDot: pagerItem.style === "dots" ? pagerItem.dot * 0.62 : pagerItem.dot
    readonly property real shapeW: capsule ? pagerItem.contentW : idleDot
    readonly property real shapeH: capsule ? pagerItem.contentH : idleDot

    x: origin.x
    y: origin.y
    width: pagerItem.slotW
    height: pagerItem.slotH
    z: overlay ? 2 : 0

    Rectangle {
        visible: !slot.overlay && slot.pagerItem.style === "buttons"
        x: contentBox.x
        y: contentBox.y
        width: slot.pagerItem.contentW
        height: slot.pagerItem.contentH
        radius: Math.min(6, Math.min(width, height) / 3)
        color: slot.active
            ? slot.pagerItem.activeColor
            : Qt.rgba(slot.pagerItem.inactiveColor.r, slot.pagerItem.inactiveColor.g, slot.pagerItem.inactiveColor.b, slot.pagerItem.inactiveOpacity * 0.55)
        border.width: slot.active ? 0 : 1
        border.color: slot.occupied && slot.pagerItem.occupancyStyle === "outline"
            ? (slot.urgent ? slot.pagerItem.urgentColor : slot.pagerItem.activeColor)
            : Qt.rgba(slot.pagerItem.inactiveColor.r, slot.pagerItem.inactiveColor.g, slot.pagerItem.inactiveColor.b, 0.35)
    }

    Rectangle {
        visible: !slot.overlay && slot.pagerItem.style !== "buttons" && !slot.active
        x: contentBox.x + (contentBox.width - width) / 2
        y: contentBox.y + (contentBox.height - height) / 2
        width: slot.shapeW
        height: slot.shapeH
        radius: height / 2
        color: slot.capsule ? "transparent" : slot.pagerItem.inactiveColor
        opacity: slot.capsule ? 1 : slot.pagerItem.inactiveOpacity
        border.width: slot.capsule || (slot.occupied && slot.pagerItem.occupancyStyle === "outline") ? 1 : 0
        border.color: slot.occupied && slot.pagerItem.occupancyStyle === "outline"
            ? (slot.urgent ? slot.pagerItem.urgentColor : slot.pagerItem.activeColor)
            : Qt.rgba(slot.pagerItem.inactiveColor.r, slot.pagerItem.inactiveColor.g, slot.pagerItem.inactiveColor.b, slot.pagerItem.inactiveOpacity)
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
        x: (slot.width - width) / 2
        y: (slot.height - height) / 2
        width: slot.pagerItem.contentW
        height: slot.pagerItem.contentH
    }

    Rectangle {
        visible: slot.overlay && slot.pagerItem.occupancyStyle === "dot" && slot.occupied && !slot.pagerItem.showWindowCount
        width: Math.max(3, Math.round(slot.pagerItem.dot * 0.28))
        height: width
        radius: width / 2
        color: slot.urgent ? slot.pagerItem.urgentColor : slot.pagerItem.activeColor
        x: contentBox.x + (slot.pagerItem.vertical
            ? contentBox.width - width - Math.max(1, slot.pagerItem.dot * 0.12)
            : (contentBox.width - width) / 2)
        y: contentBox.y + (slot.pagerItem.vertical
            ? (contentBox.height - height) / 2
            : contentBox.height - height - Math.max(1, slot.pagerItem.dot * 0.12))
    }

    Rectangle {
        visible: slot.overlay && slot.pagerItem.occupancyStyle === "underline" && slot.occupied
        color: slot.urgent ? slot.pagerItem.urgentColor : slot.pagerItem.activeColor
        radius: 1
        x: contentBox.x + (slot.pagerItem.vertical ? contentBox.width - 2 : contentBox.width * 0.18)
        y: contentBox.y + (slot.pagerItem.vertical ? contentBox.height * 0.18 : contentBox.height - height - 1)
        width: slot.pagerItem.vertical ? 2 : contentBox.width * 0.64
        height: slot.pagerItem.vertical ? contentBox.height * 0.64 : 2
    }

    Text {
        visible: slot.overlay && slot.pagerItem.showWindowCount && slot.windowCount > 0
        text: slot.windowCount > 99 ? "99" : String(slot.windowCount)
        color: slot.active
            ? slot.pagerItem.labelOnActive
            : (slot.urgent ? slot.pagerItem.urgentColor : slot.pagerItem.inactiveColor)
        font.pixelSize: Math.max(8, Math.round(slot.pagerItem.dot * 0.55))
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
        enabled: slot.overlay && slot.pagerItem.tooltips
        mainText: slot.desktops.desktopName(slot.index)
        subText: slot.desktops.tooltipBody(slot.index)
        location: Plasmoid.location
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            Accessible.name: slot.desktops.desktopName(slot.index)
            Accessible.role: Accessible.Button
            onClicked: (mouse) => {
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
}
