/// @description SELECT, MOVE UNIT

if (!is_undefined(cursorHex)) {
    if (selectedUnit == pointer_null) {
        selectedUnit = cursorTile.unit;
    } else if (cursorTile.unit == pointer_null) {
        moveTargetTile = cursorTile;
    } else if (cursorTile.unit == selectedUnit) {
        selectedUnit = pointer_null;
    }
}