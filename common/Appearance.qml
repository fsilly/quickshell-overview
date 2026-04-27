pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "functions"

Singleton {
    id: root
    property QtObject m3colors
    property QtObject animation
    property QtObject animationCurves
    property QtObject colors
    property QtObject rounding
    property QtObject font
    property QtObject sizes

    property var loadedColors: null

    m3colors: QtObject {
        property bool darkmode: root.loadedColors ? (root.loadedColors.mode === "dark") : true
        property color m3primary: root.loadedColors ? "#" + root.loadedColors.colours.primary : "#E5B6F2"
        property color m3onPrimary: root.loadedColors ? "#" + root.loadedColors.colours.onPrimary : "#452152"
        property color m3primaryContainer: root.loadedColors ? "#" + root.loadedColors.colours.primaryContainer : "#5D386A"
        property color m3onPrimaryContainer: root.loadedColors ? "#" + root.loadedColors.colours.onPrimaryContainer : "#F9D8FF"
        property color m3secondary: root.loadedColors ? "#" + root.loadedColors.colours.secondary : "#D5C0D7"
        property color m3onSecondary: root.loadedColors ? "#" + root.loadedColors.colours.onSecondary : "#392C3D"
        property color m3secondaryContainer: root.loadedColors ? "#" + root.loadedColors.colours.secondaryContainer : "#534457"
        property color m3onSecondaryContainer: root.loadedColors ? "#" + root.loadedColors.colours.onSecondaryContainer : "#F2DCF3"
        property color m3background: root.loadedColors ? "#" + root.loadedColors.colours.background : "#161217"
        property color m3onBackground: root.loadedColors ? "#" + root.loadedColors.colours.onBackground : "#EAE0E7"
        property color m3surface: root.loadedColors ? "#" + root.loadedColors.colours.surface : "#161217"
        property color m3surfaceContainerLow: root.loadedColors ? "#" + root.loadedColors.colours.surfaceContainerLow : "#1F1A1F"
        property color m3surfaceContainer: root.loadedColors ? "#" + root.loadedColors.colours.surfaceContainer : "#231E23"
        property color m3surfaceContainerHigh: root.loadedColors ? "#" + root.loadedColors.colours.surfaceContainerHigh : "#2D282E"
        property color m3surfaceContainerHighest: root.loadedColors ? "#" + root.loadedColors.colours.surfaceContainerHighest : "#383339"
        property color m3onSurface: root.loadedColors ? "#" + root.loadedColors.colours.onSurface : "#EAE0E7"
        property color m3surfaceVariant: root.loadedColors ? "#" + root.loadedColors.colours.surfaceVariant : "#4C444D"
        property color m3onSurfaceVariant: root.loadedColors ? "#" + root.loadedColors.colours.onSurfaceVariant : "#CFC3CD"
        property color m3inverseSurface: root.loadedColors ? "#" + root.loadedColors.colours.inverseSurface : "#EAE0E7"
        property color m3inverseOnSurface: root.loadedColors ? "#" + root.loadedColors.colours.inverseOnSurface : "#342F34"
        property color m3outline: root.loadedColors ? "#" + root.loadedColors.colours.outline : "#988E97"
        property color m3outlineVariant: root.loadedColors ? "#" + root.loadedColors.colours.outlineVariant : "#4C444D"
        property color m3shadow: root.loadedColors ? "#" + root.loadedColors.colours.shadow : "#000000"
    }

    colors: QtObject {
        property color colSubtext: m3colors.m3outline
        property color colLayer0: m3colors.m3background
        property color colOnLayer0: m3colors.m3onBackground
        property color colLayer0Border: ColorUtils.mix(root.m3colors.m3outlineVariant, colLayer0, 0.4)
        property color colLayer1: m3colors.m3surfaceContainerLow
        property color colOnLayer1: m3colors.m3onSurfaceVariant
        property color colOnLayer1Inactive: ColorUtils.mix(colOnLayer1, colLayer1, 0.45)
        property color colLayer1Hover: ColorUtils.mix(colLayer1, colOnLayer1, 0.92)
        property color colLayer1Active: ColorUtils.mix(colLayer1, colOnLayer1, 0.85)
        property color colLayer2: m3colors.m3surfaceContainer
        property color colOnLayer2: m3colors.m3onSurface
        property color colLayer2Hover: ColorUtils.mix(colLayer2, colOnLayer2, 0.90)
        property color colLayer2Active: ColorUtils.mix(colLayer2, colOnLayer2, 0.80)
        property color colPrimary: m3colors.m3primary
        property color colOnPrimary: m3colors.m3onPrimary
        property color colSecondary: m3colors.m3secondary
        property color colSecondaryContainer: m3colors.m3secondaryContainer
        property color colOnSecondaryContainer: m3colors.m3onSecondaryContainer
        property color colTooltip: m3colors.m3inverseSurface
        property color colOnTooltip: m3colors.m3inverseOnSurface
        property color colShadow: ColorUtils.transparentize(m3colors.m3shadow, 0.7)
        property color colOutline: m3colors.m3outline
    }

    rounding: QtObject {
        property int unsharpen: 2
        property int verysmall: 8
        property int small: 12
        property int normal: 17
        property int large: 23
        property int full: 9999
        property int screenRounding: large
        property int windowRounding: 18
    }

    font: QtObject {
        property QtObject family: QtObject {
            property string main: "sans-serif"
            property string title: "sans-serif"
            property string expressive: "sans-serif"
        }
        property QtObject pixelSize: QtObject {
            property int smaller: 12
            property int small: 15
            property int normal: 16
            property int larger: 19
            property int huge: 22
        }
    }

    animationCurves: QtObject {
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1]
        readonly property list<real> expressiveEffects: [0.34, 0.80, 0.34, 1.00, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property real expressiveDefaultSpatialDuration: 500
        readonly property real expressiveEffectsDuration: 200
    }

    animation: QtObject {
        property QtObject elementMove: QtObject {
            property int duration: animationCurves.expressiveDefaultSpatialDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveDefaultSpatial
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
        }

        property QtObject elementMoveEnter: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedDecel
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveEnter.duration
                    easing.type: root.animation.elementMoveEnter.type
                    easing.bezierCurve: root.animation.elementMoveEnter.bezierCurve
                }
            }
        }

        property QtObject elementMoveFast: QtObject {
            property int duration: animationCurves.expressiveEffectsDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveEffects
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveFast.duration
                    easing.type: root.animation.elementMoveFast.type
                    easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
                }
            }
        }
    }

    sizes: QtObject {
        property real elevationMargin: 10
    }

    FileView {
        id: schemeFile
        path: Config.options.overview.scheme_path
        watchChanges: true
        onLoaded: {
            try {
                root.loadedColors = JSON.parse(text())
            } catch (e) {
                console.error("Failed to parse scheme json:", e)
            }
        }
        onFileChanged: reload()
    }
}
