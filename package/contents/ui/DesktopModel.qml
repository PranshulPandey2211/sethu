/*
    SPDX-FileCopyrightText: 2026 Pranshul Pandey

    SPDX-License-Identifier: GPL-3.0-or-later
*/

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.workspace.dbus as DBus
import org.kde.taskmanager as TaskManager

Item {
    id: model

    visible: false
    width: 0
    height: 0

    property rect screenGeometry
    property int desktopCount: info.numberOfDesktops
    property var ids: info.desktopIds
    property var names: info.desktopNames
    property bool wraps: info.navigationWrappingAround !== 0
    property var occupancy: ({})
    property real wheelBuffer: 0

    function screenDesktop() {
        const fallback = info.currentDesktop
        if (screenGeometry.width <= 0 || screenGeometry.height <= 0)
            return fallback
        try {
            const byScreen = info.currentDesktopByScreenGeometry(screenGeometry)
            if (byScreen !== undefined && byScreen !== null && String(byScreen).length > 0)
                return byScreen
        } catch (error) {
            return fallback
        }
        return fallback
    }

    readonly property var currentId: screenDesktop()

    readonly property int currentIndex: {
        const key = String(currentId)
        const list = ids ? ids : []
        for (let i = 0; i < list.length; ++i) {
            if (String(list[i]) === key)
                return i
        }
        return 0
    }

    TaskManager.ActivityInfo { id: activityInfo }
    TaskManager.VirtualDesktopInfo { id: info }
    TaskManager.TasksModel {
        id: tasks
        sortMode: TaskManager.TasksModel.SortDisabled
        groupMode: TaskManager.TasksModel.GroupDisabled
        separateLaunchers: false
        filterByVirtualDesktop: false
        filterByCurrentVirtualDesktop: false
        filterByScreen: Plasmoid.configuration.filterByScreen
        filterByActivity: Plasmoid.configuration.filterByActivity
        filterMinimized: !Plasmoid.configuration.includeMinimized
        filterHidden: true
        activity: activityInfo.currentActivity
        screenGeometry: model.screenGeometry
    }

    Timer {
        id: occupancyTimer
        interval: 40
        repeat: false
        onTriggered: model.rebuildOccupancy()
    }

    function scheduleOccupancy() {
        occupancyTimer.restart()
    }

    function desktopId(index) {
        const list = ids ? ids : []
        if (index < 0 || index >= list.length)
            return ""
        return list[index]
    }

    function desktopName(index) {
        const list = names ? names : []
        if (index >= 0 && index < list.length) {
            const name = list[index]
            if (name && String(name).length > 0)
                return String(name)
        }
        return i18n("Desktop %1", index + 1)
    }

    function infoFor(index) {
        const map = occupancy
        const key = String(desktopId(index))
        return map[key] ? map[key] : null
    }

    function dbus(service, path, iface, member, args) {
        DBus.SessionBus.asyncCall({
            service: service,
            path: path,
            iface: iface,
            member: member,
            arguments: args
        }, function() {}, function() {})
    }

    function kwin(member, args) {
        dbus("org.kde.KWin", "/VirtualDesktopManager", "org.kde.KWin.VirtualDesktopManager", member, args)
    }

    function activate(index) {
        const id = String(desktopId(index))
        if (id.length === 0)
            return
        dbus("org.kde.KWin", "/VirtualDesktopManager", "org.freedesktop.DBus.Properties", "Set", [
            "org.kde.KWin.VirtualDesktopManager",
            "current",
            new DBus.variant(id)
        ])
    }

    function addDesktop() {
        kwin("createDesktop", [new DBus.uint32(desktopCount + 1), i18n("Desktop %1", desktopCount + 1)])
    }

    function removeAt(index) {
        if (desktopCount < 2)
            return
        const id = desktopId(index)
        if (String(id).length === 0)
            return
        kwin("removeDesktop", [String(id)])
    }

    function rename(index, name) {
        const id = desktopId(index)
        if (String(id).length === 0)
            return
        kwin("setDesktopName", [String(id), name])
    }

    function toggleOverview() {
        dbus("org.kde.kglobalaccel", "/component/kwin", "org.kde.kglobalaccel.Component", "invokeShortcut", ["Overview"])
    }

    function wrapping() {
        const mode = Plasmoid.configuration.scrollWrap
        if (mode === "always")
            return true
        if (mode === "never")
            return false
        return wraps
    }

    function step(direction) {
        if (desktopCount < 1)
            return
        let next = currentIndex + direction
        if (wrapping())
            next = (next % desktopCount + desktopCount) % desktopCount
        else
            next = Math.max(0, Math.min(desktopCount - 1, next))
        if (next !== currentIndex)
            activate(next)
    }

    function acceptWheel(wheel) {
        if (!Plasmoid.configuration.scrollToSwitch)
            return
        const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x
        if (delta === 0)
            return
        if (wheelBuffer !== 0 && (wheelBuffer > 0) !== (delta > 0))
            wheelBuffer = 0
        wheelBuffer += delta
        if (Math.abs(wheelBuffer) < 60)
            return
        const direction = wheelBuffer > 0 ? -1 : 1
        wheelBuffer = 0
        step(direction)
    }

    function leftClick(index) {
        if (index === currentIndex && Plasmoid.configuration.clickCurrent === "overview")
            toggleOverview()
        else
            activate(index)
    }

    function middleClick(index) {
        const action = Plasmoid.configuration.middleClick
        if (action === "add")
            addDesktop()
        else if (action === "remove")
            removeAt(index)
        else if (action === "overview")
            toggleOverview()
    }

    function tooltipBody(index) {
        const entry = infoFor(index)
        if (!entry || entry.count < 1)
            return index === currentIndex ? i18n("Current desktop") : ""
        const lines = entry.titles.slice()
        if (entry.urgent)
            lines.unshift(i18n("Needs attention"))
        if (entry.count > entry.titles.length)
            lines.push(i18n("+%1 more", entry.count - entry.titles.length))
        return lines.join("\n")
    }

    function rebuildOccupancy() {
        const roleWindow = TaskManager.AbstractTasksModel.IsWindow
        const roleDesktops = TaskManager.AbstractTasksModel.VirtualDesktops
        const roleAll = TaskManager.AbstractTasksModel.IsOnAllVirtualDesktops
        const roleUrgent = TaskManager.AbstractTasksModel.IsDemandingAttention
        const roleSkip = TaskManager.AbstractTasksModel.SkipPager
        const roleApp = TaskManager.AbstractTasksModel.AppName
        const next = {}
        const allIds = ids ? ids : []
        const includeAll = Plasmoid.configuration.includeAllDesktopsWindows
        const showUrgent = Plasmoid.configuration.showUrgent
        const rows = tasks.count
        for (let i = 0; i < rows; ++i) {
            const idx = tasks.index(i, 0)
            if (!tasks.data(idx, roleWindow))
                continue
            if (tasks.data(idx, roleSkip))
                continue
            const title = String(tasks.data(idx, 0) || tasks.data(idx, roleApp) || "")
            const urgent = showUrgent && !!tasks.data(idx, roleUrgent)
            const onAll = includeAll && !!tasks.data(idx, roleAll)
            let desks = tasks.data(idx, roleDesktops)
            if (onAll || !desks || desks.length === 0)
                desks = allIds
            for (let d = 0; d < desks.length; ++d) {
                const key = String(desks[d])
                if (key.length === 0)
                    continue
                let slot = next[key]
                if (!slot) {
                    slot = { count: 0, urgent: false, titles: [] }
                    next[key] = slot
                }
                slot.count += 1
                if (urgent)
                    slot.urgent = true
                if (slot.titles.length < 8 && title.length > 0)
                    slot.titles.push(title)
            }
        }
        occupancy = next
    }

    Component.onCompleted: scheduleOccupancy()

    Connections {
        target: model.info
        function onDesktopIdsChanged() { model.scheduleOccupancy() }
        function onNumberOfDesktopsChanged() { model.scheduleOccupancy() }
    }

    Connections {
        target: model.tasks
        function onCountChanged() { model.scheduleOccupancy() }
        function onModelReset() { model.scheduleOccupancy() }
        function onDataChanged(topLeft, bottomRight, roles) {
            if (roles && roles.length > 0) {
                const roleWindow = TaskManager.AbstractTasksModel.IsWindow
                const roleDesktops = TaskManager.AbstractTasksModel.VirtualDesktops
                const roleAll = TaskManager.AbstractTasksModel.IsOnAllVirtualDesktops
                const roleUrgent = TaskManager.AbstractTasksModel.IsDemandingAttention
                const roleSkip = TaskManager.AbstractTasksModel.SkipPager
                let relevant = false
                for (let i = 0; i < roles.length; ++i) {
                    const role = roles[i]
                    if (role === 0 || role === roleWindow || role === roleDesktops || role === roleAll || role === roleUrgent || role === roleSkip) {
                        relevant = true
                        break
                    }
                }
                if (!relevant)
                    return
            }
            model.scheduleOccupancy()
        }
    }
}
