/// @description SELECT, MOVE UNIT
if (is_undefined(cursorHex)) {
    exit;
}

var _cursorUnit = cursorTile.getTopUnit();

if (selectedUnit == pointer_null) {
    selectedUnit = _cursorUnit;
} else if (_cursorUnit == selectedUnit) {
    selectedUnit = pointer_null;
    unitTargetTile = pointer_null;
} else {
    unitTargetTile = cursorTile;
}

if (selectedUnit != pointer_null && unitTargetTile != pointer_null) {
    var _planned = false;
    
    if (_cursorUnit != pointer_null && selectedUnit.combat.canAttack()) {
        _planned = selectedUnit.combat.planAttackOnHex(unitTargetTile.position);
    } else if (selectedUnit.mobile) {
        _planned = selectedUnit.planMovementToHex(unitTargetTile.position);
    }
    
    if (_planned) {
        selectedUnit.startNextAction();
        selectedUnit.onPlanEnd = method(self, function () {
            selectedUnit = pointer_null;
            unitTargetTile = pointer_null;
            unitTargetTile = pointer_null;
        });
    }
}