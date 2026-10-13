/*
    SPDX-FileCopyrightText: 2026 Pranshul Pandey

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.iconthemes as KIconThemes
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

KCM.SimpleKCM {
    id: root

    property string cfg_labelMode: "none"
    property string cfg_indexPrefix: "d"
    property int cfg_indexStart: 1
    property int cfg_inactiveShapeWidth: 10
    property int cfg_inactiveShapeHeight: 10
    property int cfg_inactiveShapeRadius: 5
    property int cfg_inactiveBorderWidth: 0
    property string cfg_inactiveBorderColor: "#888888"
    property int cfg_activeShapeWidth: 26
    property int cfg_activeShapeHeight: 10
    property int cfg_activeShapeRadius: 5
    property int cfg_activeBorderWidth: 0
    property string cfg_activeBorderColor: "#3daee9"
    property string cfg_customIcon: ""
    property int cfg_gap: 4
    property int cfg_margin: 2
    property double cfg_activeOpacity: 1
    property string cfg_occupancyStyle: "dot"
    property bool cfg_showUrgent: true
    property bool cfg_showWindowCount: false
    property bool cfg_useSystemColors: true
    property string cfg_activeColor: "#3daee9"
    property string cfg_inactiveColor: "#fcfcfc"
    property double cfg_inactiveOpacity: 0.45
    property bool cfg_animations: true

    Kirigami.FormLayout {
        wideMode: true

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Label")
            model: [i18n("None"), i18n("Numbers"), i18n("Desktop names")]
            property var ids: ["none", "index", "name"]
            currentIndex: Math.max(0, ids.indexOf(root.cfg_labelMode))
            onActivated: (i) => { root.cfg_labelMode = ids[i] }
        }

        QQC2.TextField {
            Kirigami.FormData.label: i18n("Number prefix")
            enabled: root.cfg_labelMode === "index"
            text: root.cfg_indexPrefix
            placeholderText: i18n("d")
            onTextEdited: root.cfg_indexPrefix = text
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("First number")
            enabled: root.cfg_labelMode === "index"
            from: 0
            to: 99
            value: root.cfg_indexStart
            onValueModified: root.cfg_indexStart = value
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Inactive desktop")
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Width")
            from: 4
            to: 128
            stepSize: 1
            editable: true
            value: root.cfg_inactiveShapeWidth
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.cfg_inactiveShapeWidth = value
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Height")
            from: 4
            to: 128
            stepSize: 1
            editable: true
            value: root.cfg_inactiveShapeHeight
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.cfg_inactiveShapeHeight = value
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Radius")
            from: 0
            to: 64
            stepSize: 1
            editable: true
            value: root.cfg_inactiveShapeRadius
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.cfg_inactiveShapeRadius = value
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Border")
            from: 0
            to: 8
            stepSize: 1
            editable: true
            value: root.cfg_inactiveBorderWidth
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.cfg_inactiveBorderWidth = value
        }

        KQuickControls.ColorButton {
            Kirigami.FormData.label: i18n("Border color")
            showAlphaChannel: false
            color: root.cfg_inactiveBorderColor
            onAccepted: (chosen) => { root.cfg_inactiveBorderColor = chosen.toString() }
        }

        KQuickControls.ColorButton {
            Kirigami.FormData.label: i18n("Background")
            enabled: !root.cfg_useSystemColors
            showAlphaChannel: false
            color: root.cfg_inactiveColor
            onAccepted: (chosen) => { root.cfg_inactiveColor = chosen.toString() }
        }

        QQC2.Slider {
            Kirigami.FormData.label: i18n("Opacity")
            from: 0.15
            to: 1
            stepSize: 0.05
            value: root.cfg_inactiveOpacity
            onMoved: root.cfg_inactiveOpacity = value
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Active desktop")
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Width")
            from: 4
            to: 128
            stepSize: 1
            editable: true
            value: root.cfg_activeShapeWidth
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.cfg_activeShapeWidth = value
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Height")
            from: 4
            to: 128
            stepSize: 1
            editable: true
            value: root.cfg_activeShapeHeight
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.cfg_activeShapeHeight = value
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Radius")
            from: 0
            to: 64
            stepSize: 1
            editable: true
            value: root.cfg_activeShapeRadius
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.cfg_activeShapeRadius = value
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Border")
            from: 0
            to: 8
            stepSize: 1
            editable: true
            value: root.cfg_activeBorderWidth
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.cfg_activeBorderWidth = value
        }

        KQuickControls.ColorButton {
            Kirigami.FormData.label: i18n("Border color")
            showAlphaChannel: false
            color: root.cfg_activeBorderColor
            onAccepted: (chosen) => { root.cfg_activeBorderColor = chosen.toString() }
        }

        KQuickControls.ColorButton {
            Kirigami.FormData.label: i18n("Background")
            enabled: !root.cfg_useSystemColors
            showAlphaChannel: false
            color: root.cfg_activeColor
            onAccepted: (chosen) => { root.cfg_activeColor = chosen.toString() }
        }

        QQC2.Slider {
            Kirigami.FormData.label: i18n("Opacity")
            from: 0.15
            to: 1
            stepSize: 0.05
            value: root.cfg_activeOpacity
            onMoved: root.cfg_activeOpacity = value
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Layout")
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Spacing")
            from: 0
            to: 32
            stepSize: 1
            editable: true
            value: root.cfg_gap
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.cfg_gap = value
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Margin")
            from: 0
            to: 32
            stepSize: 1
            editable: true
            value: root.cfg_margin
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.cfg_margin = value
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Animation")
            text: i18n("Slide the active desktop")
            checked: root.cfg_animations
            onToggled: root.cfg_animations = checked
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Marks")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Desktops with windows")
            model: [i18n("Hidden"), i18n("Dot"), i18n("Underline"), i18n("Outline")]
            property var ids: ["hidden", "dot", "underline", "outline"]
            currentIndex: Math.max(0, ids.indexOf(root.cfg_occupancyStyle))
            onActivated: (i) => { root.cfg_occupancyStyle = ids[i] }
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Urgent windows")
            text: i18n("Highlight desktops that need attention")
            checked: root.cfg_showUrgent
            onToggled: root.cfg_showUrgent = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Window count")
            text: i18n("Show how many windows are on each desktop")
            checked: root.cfg_showWindowCount
            onToggled: root.cfg_showWindowCount = checked
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Colors")
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Theme")
            text: i18n("Use system colors")
            checked: root.cfg_useSystemColors
            onToggled: root.cfg_useSystemColors = checked
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Background image")
            Kirigami.Icon {
                visible: root.cfg_customIcon.length > 0
                source: root.cfg_customIcon
                implicitWidth: Kirigami.Units.iconSizes.small
                implicitHeight: Kirigami.Units.iconSizes.small
            }
            QQC2.Button {
                text: i18n("Choose")
                onClicked: iconDialog.open()
            }
            QQC2.Button {
                text: i18n("From file")
                onClicked: fileDialog.open()
            }
            QQC2.Button {
                text: i18n("Clear")
                enabled: root.cfg_customIcon.length > 0
                onClicked: root.cfg_customIcon = ""
            }
        }

    }

    KIconThemes.IconDialog {
        id: iconDialog
        title: i18n("Desktop icon")
        onAccepted: {
            if (iconName.length > 0)
                root.cfg_customIcon = iconName
        }
    }

    FileDialog {
        id: fileDialog
        title: i18n("Desktop icon")
        fileMode: FileDialog.OpenFile
        nameFilters: [i18n("Images (*.png *.svg *.svgz *.jpg *.jpeg *.webp *.ico)")]
        onAccepted: root.cfg_customIcon = selectedFile.toString()
    }
}
