/*
    SPDX-FileCopyrightText: 2026 Pranshul Pandey

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: root

    property bool cfg_hideWhenSingle: false
    property bool cfg_scrollToSwitch: true
    property string cfg_scrollWrap: "system"
    property string cfg_middleClick: "add"
    property string cfg_clickCurrent: "overview"
    property bool cfg_manageDesktops: true
    property bool cfg_tooltips: true
    property bool cfg_filterByScreen: false
    property bool cfg_filterByActivity: true
    property bool cfg_includeAllDesktopsWindows: true
    property bool cfg_includeMinimized: true

    Kirigami.FormLayout {
        wideMode: true

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Scroll")
            text: i18n("Switch desktops with the wheel")
            checked: root.cfg_scrollToSwitch
            onToggled: root.cfg_scrollToSwitch = checked
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Wrapping")
            enabled: root.cfg_scrollToSwitch
            model: [i18n("Follow KWin"), i18n("Always"), i18n("Never")]
            property var ids: ["system", "always", "never"]
            currentIndex: Math.max(0, ids.indexOf(root.cfg_scrollWrap))
            onActivated: (i) => { root.cfg_scrollWrap = ids[i] }
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Click current desktop")
            model: [i18n("Open Overview"), i18n("Do nothing")]
            property var ids: ["overview", "none"]
            currentIndex: Math.max(0, ids.indexOf(root.cfg_clickCurrent))
            onActivated: (i) => { root.cfg_clickCurrent = ids[i] }
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Middle click")
            model: [i18n("Add a desktop"), i18n("Remove the desktop"), i18n("Open Overview"), i18n("Do nothing")]
            property var ids: ["add", "remove", "overview", "none"]
            currentIndex: Math.max(0, ids.indexOf(root.cfg_middleClick))
            onActivated: (i) => { root.cfg_middleClick = ids[i] }
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Right click")
            text: i18n("Rename, add, and remove desktops")
            checked: root.cfg_manageDesktops
            onToggled: root.cfg_manageDesktops = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Tooltips")
            text: i18n("Show the desktop name and window titles")
            checked: root.cfg_tooltips
            onToggled: root.cfg_tooltips = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Single desktop")
            text: i18n("Hide this widget when only one desktop exists")
            checked: root.cfg_hideWhenSingle
            onToggled: root.cfg_hideWhenSingle = checked
        }

        Item {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Which windows count")
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Activity")
            text: i18n("Only windows on the current activity")
            checked: root.cfg_filterByActivity
            onToggled: root.cfg_filterByActivity = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Screen")
            text: i18n("Only windows on this screen")
            checked: root.cfg_filterByScreen
            onToggled: root.cfg_filterByScreen = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("All desktops")
            text: i18n("Count windows that are on every desktop")
            checked: root.cfg_includeAllDesktopsWindows
            onToggled: root.cfg_includeAllDesktopsWindows = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Minimized")
            text: i18n("Count minimized windows")
            checked: root.cfg_includeMinimized
            onToggled: root.cfg_includeMinimized = checked
        }
    }
}
