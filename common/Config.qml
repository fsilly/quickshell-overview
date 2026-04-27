pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root
    
    property QtObject options: QtObject {
        property QtObject overview: QtObject {
            property int rows: 2
            property int columns: 5
            property real scale: 0.16
            property bool enable: true
            property bool shadow: false
            property real opacity: 0.5
            property int blur_strength: 1
            property string scheme_path: "/home/shinkuan/.local/state/caelestia/scheme.json"
        }
        
        property QtObject hacks: QtObject {
            property int arbitraryRaceConditionDelay: 150
        }
    }
}
