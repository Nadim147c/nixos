import qs.modules.common
import QtQuick
import QtQuick.Controls

/**
 * Does not include visual layout, but includes the easily neglected colors.
 */
TextArea {
    renderType: Text.NativeRendering
    selectedTextColor: Appearance.material.myOnSecondaryContainer
    selectionColor: Appearance.material.mySecondaryContainer
    placeholderTextColor: Appearance.material.myOnSurfaceVariant
    color: Appearance.material.myOnSurface
    background: null
    font {
        family: Appearance.font.family.main
        pixelSize: Appearance?.font.pixelSize.small ?? 15
        hintingPreference: Font.PreferFullHinting
        variableAxes: Appearance.font.variableAxes.main
    }
}
