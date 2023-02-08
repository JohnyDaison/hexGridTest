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

if (selectedUnit != pointer_null && moveTargetTile != pointer_null) {
    selectedUnit.enqueueAction(new MoveToHexAction(moveTargetTile.position));
    selectedUnit.startNextAction();
    selectedUnit.onActionEnd = method(self, function () {
        selectedUnit.startNextAction();
        if (selectedUnit.currentAction == pointer_null) {
            selectedUnit = pointer_null;
            moveTargetTile = pointer_null;
        }
    });
}
