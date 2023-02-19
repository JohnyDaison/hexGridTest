function AttackUnitAction(_unit) : GameAction() constructor {
    type = ActionType.AttackUnit;
    unit = _unit;
    
    static toString = function() {
        return string("ATTACK UNIT: {0}", string(unit));
    }
}