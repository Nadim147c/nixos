pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    readonly property AnimationElementMove elementMove: AnimationElementMove {}
    readonly property AnimationElementMoveEnter elementMoveEnter: AnimationElementMoveEnter {}
    readonly property AnimationElementMoveExit elementMoveExit: AnimationElementMoveExit {}
    readonly property AnimationElementMoveFast elementMoveFast: AnimationElementMoveFast {}
    readonly property AnimationElementResize elementResize: AnimationElementResize {}
    readonly property AnimationClickBounce clickBounce: AnimationClickBounce {}
    readonly property AnimationScroll scroll: AnimationScroll {}
    readonly property AnimationMenuDecel menuDecel: AnimationMenuDecel {}
}
