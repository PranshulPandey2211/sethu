/*
    SPDX-FileCopyrightText: 2026 Pranshul Pandey

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: root

    property string cfg_preset: "dots"
    property string cfg_style: "mixed"
    property string cfg_labelMode: "none"
    property string cfg_indexPrefix: "d"
    property int cfg_indexStart: 1
    property int cfg_dotSize: 10
    property int cfg_gap: 4

    readonly property bool labelsAllowed: cfg_style !== "mixed" && cfg_style !== "dots"
    property string cfg_occupancyStyle: "dot"
    property bool cfg_showUrgent: true
    property bool cfg_showWindowCount: false
    property bool cfg_useSystemColors: true
    property string cfg_activeColor: "#3daee9"
    property string cfg_inactiveColor: "#fcfcfc"
    property double cfg_inactiveOpacity: 0.45
    property bool cfg_animations: true

    property bool applyingPreset: false

    function applyPreset(id) {
        applyingPreset = true
        cfg_preset = id
        if (id === "dots") {
            cfg_style = "mixed"
            cfg_labelMode = "none"
        } else if (id === "numbers") {
            cfg_style = "buttons"
            cfg_labelMode = "index"
            cfg_indexPrefix = "d"
            cfg_indexStart = 1
        } else if (id === "names") {
            cfg_style = "buttons"
            cfg_labelMode = "name"
        } else if (id === "pills") {
            cfg_style = "pills"
            cfg_labelMode = "none"
        }
        applyingPreset = false
    }

    function touch() {
        if (!applyingPreset)
            cfg_preset = "custom"
    }

    readonly property string presetHint: {
        if (cfg_preset === "numbers")
            return i18n("Desktops are labeled d1, d2, d3. Change the prefix below after choosing Custom.")
        if (cfg_preset === "names")
            return i18n("Each desktop shows its name.")
        if (cfg_preset === "pills")
            return i18n("Every desktop is a pill. The current one is filled.")
        if (cfg_preset === "custom")
            return i18n("Style and labels are yours. Size, marks, and colors stay available on every preset.")
        return i18n("Other desktops are dots. The current one is a pill.")
    }

    Kirigami.FormLayout {
        wideMode: true

        QQC2.ComboBox {
            id: presetBox
            Kirigami.FormData.label: i18n("Preset")
            model: [i18n("Dots"), i18n("Numbers"), i18n("Names"), i18n("Pills"), i18n("Custom")]
            property var ids: ["dots", "numbers", "names", "pills", "custom"]
            currentIndex: Math.max(0, ids.indexOf(root.cfg_preset))
            onActivated: (i) => root.applyPreset(ids[i])
        }

        QQC2.Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 18
            wrapMode: Text.WordWrap
            text: root.presetHint
            color: Kirigami.Theme.disabledTextColor
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Style")
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Shape")
            model: [i18n("Dots, active pill"), i18n("Dots"), i18n("Pills"), i18n("Buttons")]
            property var ids: ["mixed", "dots", "pills", "buttons"]
            currentIndex: Math.max(0, ids.indexOf(root.cfg_style))
            onActivated: (i) => {
                root.cfg_style = ids[i]
                if (ids[i] === "mixed" || ids[i] === "dots")
                    root.cfg_labelMode = "none"
                root.touch()
            }
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Label")
            enabled: root.labelsAllowed
            model: [i18n("None"), i18n("Numbers"), i18n("Desktop names")]
            property var ids: ["none", "index", "name"]
            currentIndex: root.labelsAllowed ? Math.max(0, ids.indexOf(root.cfg_labelMode)) : 0
            onActivated: (i) => {
                root.cfg_labelMode = ids[i]
                root.touch()
            }
        }

        QQC2.TextField {
            Kirigami.FormData.label: i18n("Number prefix")
            enabled: root.labelsAllowed && root.cfg_labelMode === "index"
            text: root.cfg_indexPrefix
            placeholderText: i18n("d")
            onTextEdited: {
                root.cfg_indexPrefix = text
                root.touch()
            }
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("First number")
            enabled: root.labelsAllowed && root.cfg_labelMode === "index"
            from: 0
            to: 99
            value: root.cfg_indexStart
            onValueModified: {
                root.cfg_indexStart = value
                root.touch()
            }
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Layout")
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Size")
            from: 4
            to: 48
            stepSize: 1
            editable: true
            value: root.cfg_dotSize
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.cfg_dotSize = value
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

        QQC2.Button {
            Kirigami.FormData.label: i18n("Active color")
            enabled: !root.cfg_useSystemColors
            text: root.cfg_activeColor
            onClicked: activeDialog.open()
        }

        QQC2.Button {
            Kirigami.FormData.label: i18n("Inactive color")
            enabled: !root.cfg_useSystemColors
            text: root.cfg_inactiveColor
            onClicked: inactiveDialog.open()
        }

        QQC2.Slider {
            Kirigami.FormData.label: i18n("Inactive strength")
            enabled: !root.cfg_useSystemColors
            from: 0.15
            to: 1
            stepSize: 0.05
            value: root.cfg_inactiveOpacity
            onMoved: root.cfg_inactiveOpacity = value
        }
    }

    ColorDialog {
        id: activeDialog
        selectedColor: root.cfg_activeColor
        onAccepted: root.cfg_activeColor = selectedColor.toString()
    }

    ColorDialog {
        id: inactiveDialog
        selectedColor: root.cfg_inactiveColor
        onAccepted: root.cfg_inactiveColor = selectedColor.toString()
    }
}
