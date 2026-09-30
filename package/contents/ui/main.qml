/*
    SPDX-FileCopyrightText: 2026 Pranshul Pandey

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    fullRepresentation: CompactPager {}
    preferredRepresentation: fullRepresentation
    activationTogglesExpanded: false

    function syncStatus() {
        const item = root.fullRepresentationItem
        const hide = Plasmoid.configuration.hideWhenSingle && item && item.desktopCount < 2
        Plasmoid.status = hide ? PlasmaCore.Types.HiddenStatus : PlasmaCore.Types.ActiveStatus
    }

    onFullRepresentationItemChanged: syncStatus()
    Connections {
        target: root.fullRepresentationItem
        function onDesktopCountChanged() { root.syncStatus() }
    }
    Connections {
        target: Plasmoid.configuration
        function onHideWhenSingleChanged() { root.syncStatus() }
    }
}
