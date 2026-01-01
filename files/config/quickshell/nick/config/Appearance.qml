pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    // Rounding values
    readonly property QtObject rounding: QtObject {
        property int small: 12
        property int normal: 17
        property int large: 25
        property int full: 1000
    }

    // Spacing values
    readonly property QtObject spacing: QtObject {
        property int small: 7
        property int smaller: 10
        property int normal: 12
        property int larger: 15
        property int large: 20
    }

    // Padding values
    readonly property QtObject padding: QtObject {
        property int small: 5
        property int smaller: 7
        property int normal: 10
        property int larger: 12
        property int large: 15
    }

    // Font settings
    readonly property QtObject font: QtObject {
        property string sans: "Rubik"
        property string mono: "CaskaydiaCove NF"
        property string material: "Material Symbols Rounded"

        property int small: 11
        property int smaller: 12
        property int normal: 13
        property int larger: 18
        property int large: 22
    }

    // Animation settings - Material Design inspired curves
    readonly property QtObject anim: QtObject {
        // Durations in ms
        property int small: 200
        property int normal: 400
        property int large: 600

        // Bezier curves (Material Design expressive)
        property var standard: [0.2, 0, 0, 1, 1, 1]
        property var emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        property var expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
    }
}
