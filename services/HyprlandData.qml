pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../common"

/**
 * Provides access to some Hyprland data not available in Quickshell.Hyprland.
 */
Singleton {
    id: root
    property var windowList: []
    property var addresses: []
    property var windowByAddress: ({})
//<<<<<<< HEAD
//=======
    property var workspaces: []
    property var allWorkspaces: []
    property var workspaceIds: []
    property var workspaceById: ({})
//>>>>>>> main
    property var activeWorkspace: null
    property var monitors: []
    property var monitorGeometries: []
    property var layers: ({})
//<<<<<<< HEAD
    
    property var _rawHyprkoolData: null
    property var _rawClientsData: null
//=======
    property bool pendingWindowsUpdate: false
    property bool pendingMonitorsUpdate: false
    property bool pendingLayersUpdate: false
    property bool pendingWorkspacesUpdate: false
    property bool pendingActiveWorkspaceUpdate: false
//>>>>>>> main

    function updateHyprkoolData() {
        getHyprkoolData.running = true;
    }

    function updateClients() {
        getClients.running = true;
    }

    function updateMonitorGeometries() {
        getMonitorGeometries.running = true;
    }

    function updateLayers() {
        getLayers.running = true;
    }

    function updateAll() {
//<<<<<<< HEAD
        updateHyprkoolData();
        updateClients();
        updateMonitorGeometries();
        updateLayers();
//=======
        scheduleUpdates(true, true, true, true, true);
    }

    function scheduleUpdates(windows, monitors, layers, workspaces, activeWorkspace) {
        pendingWindowsUpdate = pendingWindowsUpdate || !!windows;
        pendingMonitorsUpdate = pendingMonitorsUpdate || !!monitors;
        pendingLayersUpdate = pendingLayersUpdate || !!layers;
        pendingWorkspacesUpdate = pendingWorkspacesUpdate || !!workspaces;
        pendingActiveWorkspaceUpdate = pendingActiveWorkspaceUpdate || !!activeWorkspace;

        const debounceMs = Math.max(0, Config.options.hacks.hyprlandEventDebounceMs);
        if (debounceMs === 0) {
            flushPendingUpdates();
        } else {
            eventDebounceTimer.interval = debounceMs;
            eventDebounceTimer.restart();
        }
    }

    function flushPendingUpdates() {
        if (pendingWindowsUpdate) {
            pendingWindowsUpdate = false;
            updateWindowList();
        }
        if (pendingMonitorsUpdate) {
            pendingMonitorsUpdate = false;
            updateMonitors();
        }
        if (pendingLayersUpdate) {
            pendingLayersUpdate = false;
            updateLayers();
        }
        if (pendingWorkspacesUpdate) {
            pendingWorkspacesUpdate = false;
            getWorkspaces.running = true;
        }
        if (pendingActiveWorkspaceUpdate) {
            pendingActiveWorkspaceUpdate = false;
            getActiveWorkspace.running = true;
        }
//>>>>>>> main
    }

    function rebuildData() {
        if (!_rawHyprkoolData || !_rawClientsData) return;
        
        // Create a map of clients for fast lookup
        var clientsMap = {};
        _rawClientsData.forEach(c => {
            clientsMap[c.address] = c;
        });

        var data = _rawHyprkoolData;
        root.monitors = data;
        
        var wins = [];
        var winByAddr = {};
        var addrs = [];
        var activeWs = null;
        
        data.forEach(monitor => {
            monitor.activities.forEach(activity => {
                activity.workspaces.forEach(row => {
                    row.forEach(workspace => {
                        if (monitor.focused && activity.focused && workspace.focused) {
                            activeWs = workspace;
                        }
                        workspace.windows.forEach(win => {
                            // Merge with client data
                            var clientData = clientsMap[win.address];
                            if (clientData) {
                                win.at = clientData.at;
                                win.size = clientData.size;
                                win.xwayland = clientData.xwayland;
                                win.pinned = clientData.pinned;
                                win.floating = clientData.floating;
                                // win.monitor is set below from the structure
                            }
                            
                            win.workspace = workspace;
                            win.monitor = monitor.id;
                            wins.push(win);
                            winByAddr[win.address] = win;
                            addrs.push(win.address);
                        });
                    });
                });
            });
        });
        
        root.windowList = wins;
        root.windowByAddress = winByAddr;
        root.addresses = addrs;
        root.activeWorkspace = activeWs;
    }


    Component.onCompleted: {
        scheduleUpdates(true, true, true, true, true);
        flushPendingUpdates();
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            const eventName = `${event?.name ?? event?.event ?? event?.type ?? ""}`;
            if (["openlayer", "closelayer", "screencast"].includes(eventName))
                return;

            if (eventName === "openwindow" || eventName === "closewindow" || eventName === "movewindow" || eventName === "movewindowv2" || eventName === "windowtitle") {
                scheduleUpdates(true, false, false, true, false);
                return;
            }

            if (eventName === "workspace" || eventName === "workspacev2" || eventName === "focusedmon" || eventName === "focusedmonv2" || eventName === "activewindow" || eventName === "activewindowv2") {
                scheduleUpdates(false, false, false, true, true);
                return;
            }

            if (eventName.startsWith("monitor") || eventName === "configreloaded") {
                scheduleUpdates(true, true, false, true, true);
                return;
            }

            scheduleUpdates(true, true, true, true, true);
        }
    }

    Timer {
        id: eventDebounceTimer
        interval: Math.max(0, Config.options.hacks.hyprlandEventDebounceMs)
        repeat: false
        onTriggered: root.flushPendingUpdates()
    }

    Process {
        id: getHyprkoolData
        command: ["hyprkool", "info", "monitors-all-info"]
        stdout: StdioCollector {
            id: hyprkoolCollector
            onStreamFinished: {
                root._rawHyprkoolData = JSON.parse(hyprkoolCollector.text);
                root.rebuildData();
            }
        }
    }

    Process {
        id: getClients
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            id: clientsCollector
            onStreamFinished: {
                root._rawClientsData = JSON.parse(clientsCollector.text);
                root.rebuildData();
            }
        }
    }

    Process {
        id: getLayers
        command: ["hyprctl", "layers", "-j"]
        stdout: StdioCollector {
            id: layersCollector
            onStreamFinished: {
                root.layers = JSON.parse(layersCollector.text);
            }
        }
    }

    Process {
        id: getMonitorGeometries
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            id: monitorGeometriesCollector
            onStreamFinished: {
//<<<<<<< HEAD
                root.monitorGeometries = JSON.parse(monitorGeometriesCollector.text);
//=======
                const rawWorkspaces = JSON.parse(workspacesCollector.text);
                root.allWorkspaces = rawWorkspaces;
                root.workspaces = rawWorkspaces.filter(ws => ws.id >= 1 && ws.id <= 100);
                let tempWorkspaceById = {};
                for (var i = 0; i < root.workspaces.length; ++i) {
                    var ws = root.workspaces[i];
                    tempWorkspaceById[ws.id] = ws;
                }
                root.workspaceById = tempWorkspaceById;
                root.workspaceIds = root.workspaces.map(ws => ws.id);
//>>>>>>> main
            }
        }
    }


}
