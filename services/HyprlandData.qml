pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

/**
 * Provides access to some Hyprland data not available in Quickshell.Hyprland.
 */
Singleton {
    id: root
    property var windowList: []
    property var addresses: []
    property var windowByAddress: ({})
    property var activeWorkspace: null
    property var monitors: []
    property var monitorGeometries: []
    property var layers: ({})
    
    property var _rawHyprkoolData: null
    property var _rawClientsData: null

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
        updateHyprkoolData();
        updateClients();
        updateMonitorGeometries();
        updateLayers();
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
        updateAll();
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            updateAll()
        }
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
                root.monitorGeometries = JSON.parse(monitorGeometriesCollector.text);
            }
        }
    }


}
