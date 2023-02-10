/// @description SELECT, MOVE UNIT
if (is_undefined(cursorHex)) {
    exit;
}

var _cursorUnit = cursorTile.getUnit(0);

if (selectedUnit == pointer_null) {
    selectedUnit = _cursorUnit;
} else if (_cursorUnit == selectedUnit) {
    selectedUnit = pointer_null;
} else {
    moveTargetTile = cursorTile;
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
