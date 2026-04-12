import qs.modules.common

import QtQuick
import M3Shapes

MaterialShape {
    id: root

    property bool animate: true
    property int interval: 1500

    shape: MaterialShape.Circle
    animationDuration: 500
    color: Appearance.player.myBackground

    function changeRandomShape() {
        shape = getRandomShape();
    }
    property int lastIndex: 0
    function getRandomShape() {
        let index = lastIndex;
        while (index === lastIndex)
            index = Math.floor(Math.random() * shapes.length);
        lastIndex = index;
        return shapes[index];
    }
    readonly property var shapes: [MaterialShape.Circle, MaterialShape.Square, MaterialShape.Slanted, MaterialShape.Arch, MaterialShape.Fan, MaterialShape.Arrow, MaterialShape.SemiCircle, MaterialShape.Oval, MaterialShape.Pill, MaterialShape.Triangle, MaterialShape.Diamond, MaterialShape.ClamShell, MaterialShape.Pentagon, MaterialShape.Gem, MaterialShape.Sunny, MaterialShape.VerySunny, MaterialShape.Cookie4Sided, MaterialShape.Cookie6Sided, MaterialShape.Cookie7Sided, MaterialShape.Cookie9Sided, MaterialShape.Cookie12Sided, MaterialShape.Ghostish, MaterialShape.Clover4Leaf, MaterialShape.Clover8Leaf, MaterialShape.Burst, MaterialShape.SoftBurst, MaterialShape.Boom, MaterialShape.SoftBoom, MaterialShape.Flower, MaterialShape.Puffy, MaterialShape.PuffyDiamond, MaterialShape.PixelCircle, MaterialShape.PixelTriangle, MaterialShape.Bun, MaterialShape.Heart,]

    Timer {
        interval: root.interval
        running: root.animate
        repeat: true
        onTriggered: root.changeRandomShape()
    }
}
