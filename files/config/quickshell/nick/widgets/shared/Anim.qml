import "../config"
import QtQuick

// Animation helper that uses Material Design inspired curves
NumberAnimation {
    duration: Appearance.anim.normal
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Appearance.anim.standard
}
