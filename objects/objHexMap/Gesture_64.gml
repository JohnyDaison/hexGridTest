/// @description SELECT, MOVE UNIT

if (!is_undefined(cursorHex)) {
    if (selectedUnit == pointer_null) {
        selectedUnit = cursorTile.unit;
    } else if (moveTargetTile == pointer_null && cursorTile.unit == pointer_null) {
        moveTargetTile = cursorTile;
    } else if (cursorTile.unit == selectedUnit) {
        selectedUnit = pointer_null;
    }
}

if (selectedUnit != pointer_null && moveTargetTile != pointer_null && movementAnimation == pointer_null) {
    movementAnimation = new BasicMovementAnimation(hexMap, selectedUnit, moveTargetTile);
    
    movementAnimation.onAnimEnd = method(self, function () {
        selectedUnit = pointer_null;
        moveTargetTile = pointer_null;
        movementAnimation = pointer_null
    });
}
