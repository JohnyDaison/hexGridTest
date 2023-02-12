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
    selectedUnit.planMovementToHex(moveTargetTile.position);
    selectedUnit.startNextAction();
    selectedUnit.onPlanEnd = method(self, function () {
        selectedUnit = pointer_null;
        moveTargetTile = pointer_null;
    });
}
