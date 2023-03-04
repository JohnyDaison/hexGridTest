function AttackUnitAction(_unit) : GameAction() constructor {
    static type = ActionType.AttackUnit;
    static planColor = c_red;
    unit = _unit;
    
    static toString = function() {
        return string("ATTACK UNIT: {0}", string(unit));
    }
}