/*
    SPDX-FileCopyrightText: 2026 Pranshul Pandey

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

KCM.SimpleKCM {
    id: root

    property string cfg_labelMode: "none"
    property string cfg_indexPrefix: ""
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

    property string chosenStyle: ""

    readonly property int presetSize: cfg_inactiveShapeHeight
    readonly property int presetRoundness: {
        const cap = Math.min(cfg_inactiveShapeWidth, cfg_inactiveShapeHeight) / 2
        if (cap <= 0)
            return 100
        return Math.max(0, Math.min(100, Math.round(cfg_inactiveShapeRadius / cap * 100)))
    }
    readonly property string styleId: chosenStyle.length > 0 ? chosenStyle : detectStyle()
    readonly property bool customStyle: styleId === "custom"
    readonly property color previewActiveColor: {
        const themeColor = Kirigami.Theme.highlightColor
        if (!cfg_useSystemColors)
            return cfg_activeColor
        return themeColor.a > 0.05 ? themeColor : "#3daee9"
    }
    readonly property color previewInactiveColor: {
        const themeColor = Kirigami.Theme.textColor
        if (!cfg_useSystemColors)
            return cfg_inactiveColor
        return themeColor.a > 0.05 ? themeColor : "#fcfcfc"
    }
    function contrastOn(color) {
        const luma = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
        return luma > 0.62 ? "#1a1a1a" : "#fcfcfc"
    }
    readonly property color previewLabelOnActive: cfg_useSystemColors ? Kirigami.Theme.highlightedTextColor : contrastOn(previewActiveColor)
    readonly property font previewFont: Qt.font({
        family: Kirigami.Theme.defaultFont.family,
        pixelSize: Math.max(8, Math.round(Math.min(
            Math.max(cfg_inactiveShapeWidth, cfg_activeShapeWidth),
            Math.max(cfg_inactiveShapeHeight, cfg_activeShapeHeight)
        ) * 0.7)),
        weight: Font.Medium
    })

    function cappedRadius(w, h, raw) {
        const cap = Math.min(w, h) / 2
        return Math.max(0, Math.min(cap, raw))
    }

    function radiusFor(w, h, roundness) {
        return Math.round(Math.max(0, Math.min(100, roundness)) / 100 * Math.min(w, h) / 2)
    }

    function presetGeometry(style, size, roundness) {
        const s = Math.max(4, Math.round(size))
        if (style === "dots") {
            const iw = s
            const ih = s
            const aw = Math.max(iw, Math.round(s * 2.6))
            const ah = ih
            return { labelMode: "none", iw: iw, ih: ih, aw: aw, ah: ah, ir: radiusFor(iw, ih, roundness), ar: radiusFor(aw, ah, roundness) }
        }
        if (style === "pills") {
            const ih = s
            const iw = Math.round(s * 2)
            const aw = Math.round(s * 3.2)
            const ah = ih
            return { labelMode: "none", iw: iw, ih: ih, aw: aw, ah: ah, ir: radiusFor(iw, ih, roundness), ar: radiusFor(aw, ah, roundness) }
        }
        if (style === "numbers" || style === "names") {
            const ih = Math.max(16, s)
            const iw = Math.round(ih * 1.8)
            const aw = Math.round(ih * 2.6)
            const ah = ih
            return {
                labelMode: style === "numbers" ? "index" : "name",
                iw: iw, ih: ih, aw: aw, ah: ah,
                ir: radiusFor(iw, ih, roundness),
                ar: radiusFor(aw, ah, roundness)
            }
        }
        return null
    }

    function stylesMatch(style, size, roundness) {
        const g = presetGeometry(style, size, roundness)
        if (!g)
            return false
        return g.labelMode === cfg_labelMode
            && g.iw === cfg_inactiveShapeWidth
            && g.ih === cfg_inactiveShapeHeight
            && g.aw === cfg_activeShapeWidth
            && g.ah === cfg_activeShapeHeight
            && g.ir === cfg_inactiveShapeRadius
            && g.ar === cfg_activeShapeRadius
    }

    function detectStyle() {
        const size = presetSize
        const roundness = presetRoundness
        const order = ["dots", "pills", "numbers", "names"]
        for (let i = 0; i < order.length; ++i) {
            if (stylesMatch(order[i], size, roundness))
                return order[i]
        }
        return "custom"
    }

    function applyPreset(style, size, roundness) {
        const g = presetGeometry(style, size, roundness)
        if (!g)
            return
        cfg_labelMode = g.labelMode
        cfg_inactiveShapeWidth = g.iw
        cfg_inactiveShapeHeight = g.ih
        cfg_activeShapeWidth = g.aw
        cfg_activeShapeHeight = g.ah
        cfg_inactiveShapeRadius = g.ir
        cfg_activeShapeRadius = g.ar
    }

    function previewChip(active, text) {
        const fontSize = previewFont.pixelSize
        let w = active ? cfg_activeShapeWidth : cfg_inactiveShapeWidth
        let h = active ? cfg_activeShapeHeight : cfg_inactiveShapeHeight
        if (text && String(text).length > 0) {
            const pad = Math.max(6, Math.round(Math.min(cfg_inactiveShapeHeight, cfg_activeShapeHeight) * 0.35))
            const cap = Math.max(w, Kirigami.Units.gridUnit * 7)
            w = Math.max(w, Math.min(cap, Math.ceil(previewMetrics.advanceWidth(String(text))) + pad * 2))
            h = Math.max(h, Math.ceil(previewMetrics.height), fontSize)
        }
        return { width: Math.max(4, w), height: Math.max(4, h) }
    }

    function previewSample(index) {
        if (cfg_labelMode === "name")
            return [i18n("Home"), i18n("Work"), i18n("Mail"), i18n("Media")][index]
        if (cfg_labelMode === "index")
            return (cfg_indexPrefix || "") + (index + cfg_indexStart)
        return ""
    }

    FontMetrics {
        id: previewMetrics
        font: root.previewFont
    }

    Kirigami.FormLayout {
        wideMode: true

        Item {
            Kirigami.FormData.label: i18n("Preview")
            implicitWidth: Math.max(previewRow.implicitWidth + root.cfg_margin * 2, Kirigami.Units.gridUnit * 8)
            implicitHeight: previewRow.implicitHeight + root.cfg_margin * 2 + Kirigami.Units.smallSpacing

            Row {
                id: previewRow
                x: root.cfg_margin
                y: root.cfg_margin + Kirigami.Units.smallSpacing / 2
                spacing: root.cfg_gap

                Repeater {
                    model: 4
                    delegate: Item {
                        id: sample
                        required property int index
                        readonly property bool active: index === 1
                        readonly property bool occupied: index === 2
                        readonly property string sampleText: root.previewSample(index)
                        readonly property var inactiveChip: root.previewChip(false, sampleText)
                        readonly property var activeChip: root.previewChip(true, sampleText)
                        readonly property bool showLabel: sampleText.length > 0
                        readonly property bool showCount: !showLabel && root.cfg_showWindowCount && occupied
                        implicitWidth: Math.max(inactiveChip.width, activeChip.width)
                        implicitHeight: Math.max(inactiveChip.height, activeChip.height)

                        Rectangle {
                            visible: !sample.active
                            anchors.centerIn: parent
                            width: sample.inactiveChip.width
                            height: sample.inactiveChip.height
                            radius: root.cappedRadius(root.cfg_inactiveShapeWidth, root.cfg_inactiveShapeHeight, root.cfg_inactiveShapeRadius)
                            color: root.previewInactiveColor
                            opacity: root.cfg_inactiveOpacity
                            border.width: root.cfg_inactiveBorderWidth
                            border.color: sample.occupied && root.cfg_occupancyStyle === "outline"
                                ? root.previewActiveColor
                                : root.cfg_inactiveBorderColor
                        }

                        Rectangle {
                            visible: sample.active
                            anchors.centerIn: parent
                            width: sample.activeChip.width
                            height: sample.activeChip.height
                            radius: root.cappedRadius(root.cfg_activeShapeWidth, root.cfg_activeShapeHeight, root.cfg_activeShapeRadius)
                            color: root.previewActiveColor
                            opacity: root.cfg_activeOpacity
                            border.width: root.cfg_activeBorderWidth
                            border.color: root.cfg_activeBorderColor
                        }

                        Text {
                            visible: sample.showLabel
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: sample.sampleText
                            elide: Text.ElideRight
                            font: root.previewFont
                            color: sample.active ? root.previewLabelOnActive : root.previewInactiveColor
                        }

                        Text {
                            visible: sample.showCount
                            anchors.centerIn: parent
                            text: "2"
                            font.pixelSize: Math.max(8, Math.round(Math.min(sample.width, sample.height) * 0.55))
                            font.weight: Font.DemiBold
                            color: sample.active ? root.previewLabelOnActive : root.previewInactiveColor
                        }

                        Rectangle {
                            visible: !sample.showLabel && !sample.showCount && root.cfg_occupancyStyle === "dot" && sample.occupied
                            width: Math.max(3, Math.round(Math.min(root.cfg_inactiveShapeWidth, root.cfg_inactiveShapeHeight) * 0.28))
                            height: width
                            radius: width / 2
                            color: root.previewActiveColor
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: Math.max(1, Math.min(root.cfg_inactiveShapeWidth, root.cfg_inactiveShapeHeight) * 0.12)
                        }

                        Rectangle {
                            visible: root.cfg_occupancyStyle === "underline" && sample.occupied
                            color: root.previewActiveColor
                            radius: 1
                            width: parent.width * 0.64
                            height: 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 1
                        }
                    }
                }
            }
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Style")
            model: [i18n("Dots"), i18n("Pills"), i18n("Numbers"), i18n("Names"), i18n("Custom")]
            property var ids: ["dots", "pills", "numbers", "names", "custom"]
            currentIndex: Math.max(0, ids.indexOf(root.styleId))
            onActivated: (i) => {
                const style = ids[i]
                root.chosenStyle = style
                if (style !== "custom")
                    root.applyPreset(style, root.presetSize, root.presetRoundness)
            }
        }

        QQC2.SpinBox {
            visible: !root.customStyle
            Kirigami.FormData.label: i18n("Size")
            from: 4
            to: 128
            stepSize: 1
            editable: true
            value: root.presetSize
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.applyPreset(root.styleId, value, root.presetRoundness)
        }

        QQC2.SpinBox {
            visible: !root.customStyle
            Kirigami.FormData.label: i18n("Roundness")
            from: 0
            to: 100
            stepSize: 5
            editable: true
            value: root.presetRoundness
            textFromValue: (value) => i18n("%1%", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: root.applyPreset(root.styleId, root.presetSize, value)
        }

        QQC2.ComboBox {
            visible: root.customStyle
            Kirigami.FormData.label: i18n("Label")
            model: [i18n("None"), i18n("Numbers"), i18n("Desktop names")]
            property var ids: ["none", "index", "name"]
            currentIndex: Math.max(0, ids.indexOf(root.cfg_labelMode))
            onActivated: (i) => {
                root.chosenStyle = "custom"
                root.cfg_labelMode = ids[i]
            }
        }

        QQC2.TextField {
            visible: root.cfg_labelMode === "index"
            Kirigami.FormData.label: i18n("Number prefix")
            text: root.cfg_indexPrefix
            placeholderText: i18n("None")
            onTextEdited: root.cfg_indexPrefix = text
        }

        QQC2.SpinBox {
            visible: root.cfg_labelMode === "index"
            Kirigami.FormData.label: i18n("First number")
            from: 0
            to: 99
            value: root.cfg_indexStart
            onValueModified: root.cfg_indexStart = value
        }

        Item {
            visible: root.customStyle
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Inactive desktop")
        }

        QQC2.SpinBox {
            visible: root.customStyle
            Kirigami.FormData.label: i18n("Width")
            from: 4
            to: 128
            stepSize: 1
            editable: true
            value: root.cfg_inactiveShapeWidth
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: {
                root.chosenStyle = "custom"
                root.cfg_inactiveShapeWidth = value
            }
        }

        QQC2.SpinBox {
            visible: root.customStyle
            Kirigami.FormData.label: i18n("Height")
            from: 4
            to: 128
            stepSize: 1
            editable: true
            value: root.cfg_inactiveShapeHeight
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: {
                root.chosenStyle = "custom"
                root.cfg_inactiveShapeHeight = value
            }
        }

        QQC2.SpinBox {
            visible: root.customStyle
            Kirigami.FormData.label: i18n("Radius")
            from: 0
            to: 64
            stepSize: 1
            editable: true
            value: root.cfg_inactiveShapeRadius
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: {
                root.chosenStyle = "custom"
                root.cfg_inactiveShapeRadius = value
            }
        }

        QQC2.SpinBox {
            visible: root.customStyle
            Kirigami.FormData.label: i18n("Border")
            from: 0
            to: 8
            stepSize: 1
            editable: true
            value: root.cfg_inactiveBorderWidth
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: {
                root.chosenStyle = "custom"
                root.cfg_inactiveBorderWidth = value
            }
        }

        KQuickControls.ColorButton {
            visible: root.customStyle && root.cfg_inactiveBorderWidth > 0
            Kirigami.FormData.label: i18n("Border color")
            showAlphaChannel: false
            color: root.cfg_inactiveBorderColor
            onAccepted: (chosen) => {
                root.chosenStyle = "custom"
                root.cfg_inactiveBorderColor = chosen.toString()
            }
        }

        Item {
            visible: root.customStyle
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Active desktop")
        }

        QQC2.SpinBox {
            visible: root.customStyle
            Kirigami.FormData.label: i18n("Width")
            from: 4
            to: 128
            stepSize: 1
            editable: true
            value: root.cfg_activeShapeWidth
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: {
                root.chosenStyle = "custom"
                root.cfg_activeShapeWidth = value
            }
        }

        QQC2.SpinBox {
            visible: root.customStyle
            Kirigami.FormData.label: i18n("Height")
            from: 4
            to: 128
            stepSize: 1
            editable: true
            value: root.cfg_activeShapeHeight
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: {
                root.chosenStyle = "custom"
                root.cfg_activeShapeHeight = value
            }
        }

        QQC2.SpinBox {
            visible: root.customStyle
            Kirigami.FormData.label: i18n("Radius")
            from: 0
            to: 64
            stepSize: 1
            editable: true
            value: root.cfg_activeShapeRadius
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: {
                root.chosenStyle = "custom"
                root.cfg_activeShapeRadius = value
            }
        }

        QQC2.SpinBox {
            visible: root.customStyle
            Kirigami.FormData.label: i18n("Border")
            from: 0
            to: 8
            stepSize: 1
            editable: true
            value: root.cfg_activeBorderWidth
            textFromValue: (value) => i18n("%1 px", value)
            valueFromText: (text) => parseInt(text)
            onValueModified: {
                root.chosenStyle = "custom"
                root.cfg_activeBorderWidth = value
            }
        }

        KQuickControls.ColorButton {
            visible: root.customStyle && root.cfg_activeBorderWidth > 0
            Kirigami.FormData.label: i18n("Border color")
            showAlphaChannel: false
            color: root.cfg_activeBorderColor
            onAccepted: (chosen) => {
                root.chosenStyle = "custom"
                root.cfg_activeBorderColor = chosen.toString()
            }
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
            enabled: root.cfg_labelMode === "none"
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

        KQuickControls.ColorButton {
            Kirigami.FormData.label: i18n("Inactive background")
            enabled: !root.cfg_useSystemColors
            showAlphaChannel: false
            color: root.cfg_inactiveColor
            onAccepted: (chosen) => { root.cfg_inactiveColor = chosen.toString() }
        }

        QQC2.Slider {
            Kirigami.FormData.label: i18n("Inactive opacity")
            from: 0.15
            to: 1
            stepSize: 0.05
            value: root.cfg_inactiveOpacity
            onMoved: root.cfg_inactiveOpacity = value
        }

        KQuickControls.ColorButton {
            Kirigami.FormData.label: i18n("Active background")
            enabled: !root.cfg_useSystemColors
            showAlphaChannel: false
            color: root.cfg_activeColor
            onAccepted: (chosen) => { root.cfg_activeColor = chosen.toString() }
        }

        QQC2.Slider {
            Kirigami.FormData.label: i18n("Active opacity")
            from: 0.15
            to: 1
            stepSize: 0.05
            value: root.cfg_activeOpacity
            onMoved: root.cfg_activeOpacity = value
        }
    }
}
