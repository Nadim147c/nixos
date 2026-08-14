import QtQuick
import QtQuick.Shapes

Shape {
    id: shadow
    required property Rectangle target
    property color color: "black"
    property real angle: -45
    property real size: 10
    property bool inner: false

    property real radAngle: -angle * (Math.PI / 180)
    property real xOffset: size * Math.cos(radAngle)
    property real yOffset: size * Math.sin(radAngle)

    property int quadrant: {
        let normalized = ((angle % 360) + 360) % 360;
        let quadrant = Math.floor(normalized / 90) + 1;
        return quadrant;
    }

    ShapePath {
        id: p1
        fillColor: (!shadow.inner && [1, 3].includes(shadow.quadrant)) ? shadow.color : "transparent"
        strokeWidth: 0

        property real tw: shadow.target.width
        property real th: shadow.target.height
        property real dx: shadow.xOffset
        property real dy: shadow.yOffset
        property int q1: shadow.quadrant === 1
        property int q3: shadow.quadrant === 3

        startX: 0
        startY: 0
        PathLine {
            x: p1.dx
            y: p1.dy
        }
        PathLine {
            x: p1.q1 * p1.tw + p1.dx
            y: p1.q3 * p1.th + p1.dy
        }
        PathLine {
            x: p1.tw + p1.dx
            y: p1.th + p1.dy
        }
        PathLine {
            x: p1.tw
            y: p1.th
        }
        PathLine {
            x: p1.q1 * p1.tw
            y: p1.q3 * p1.th
        }
    }

    ShapePath {
        id: p2
        fillColor: (!shadow.inner && [2, 4].includes(shadow.quadrant)) ? shadow.color : "transparent"
        strokeWidth: 0

        property real tw: shadow.target.width
        property real th: shadow.target.height
        property real dx: shadow.xOffset
        property real dy: shadow.yOffset
        property int q2: shadow.quadrant === 2
        property int q4: shadow.quadrant === 4

        startX: 0
        startY: th
        PathLine {
            x: p2.dx
            y: p2.th + p2.dy
        }
        PathLine {
            x: p2.q4 * p2.tw + p2.dx
            y: p2.q4 * p2.th + p2.dy
        }
        PathLine {
            x: p2.tw + p2.dx
            y: p2.dy
        }
        PathLine {
            x: p2.tw
            y: 0
        }
        PathLine {
            x: p2.q4 * p2.tw
            y: p2.q4 * p2.th
        }
    }

    ShapePath {
        id: p1_inner
        fillColor: (shadow.inner && [1, 3].includes(shadow.quadrant)) ? shadow.color : "transparent"
        strokeWidth: 0

        property real tw: shadow.target.width
        property real th: shadow.target.height
        property real dx: Math.abs(shadow.xOffset)
        property real dy: Math.abs(shadow.yOffset)
        property int q1: shadow.quadrant === 1
        property int q3: shadow.quadrant === 3

        startX: 0
        startY: 0

        PathLine {
            x: p1_inner.dx
            y: p1_inner.dy
        }
        PathLine {
            x: p1_inner.q3 ? p1_inner.dx : p1_inner.tw - p1_inner.dx
            y: p1_inner.q3 ? p1_inner.th - p1_inner.dy : p1_inner.dy
        }
        PathLine {
            x: p1_inner.tw - p1_inner.dx
            y: p1_inner.th - p1_inner.dy
        }
        PathLine {
            x: p1_inner.tw
            y: p1_inner.th
        }
        PathLine {
            x: p1_inner.q1 * p1_inner.tw
            y: p1_inner.q3 * p1_inner.th
        }
    }

    ShapePath {
        id: p2_inner
        fillColor: (shadow.inner && [2, 4].includes(shadow.quadrant)) ? shadow.color : "transparent"
        strokeWidth: 0

        property real tw: shadow.target.width
        property real th: shadow.target.height
        property real dx: Math.abs(shadow.xOffset)
        property real dy: Math.abs(shadow.yOffset)
        property int q2: shadow.quadrant === 2
        property int q4: shadow.quadrant === 4

        startX: 0
        startY: p2_inner.th

        PathLine {
            x: p2_inner.dx
            y: p2_inner.th - p2_inner.dy
        }
        PathLine {
            x: p2_inner.q2 ? p2_inner.tw - p2_inner.dx : p2_inner.dx
            y: p2_inner.q2 ? p2_inner.th - p2_inner.dy : p2_inner.dy
        }
        PathLine {
            x: p2_inner.tw - p2_inner.dx
            y: p2_inner.dy
        }
        PathLine {
            x: p2_inner.tw
            y: 0
        }
        PathLine {
            x: p2_inner.q2 * p2_inner.tw
            y: p2_inner.q2 * p2_inner.th
        }
    }
}
