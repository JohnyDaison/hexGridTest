function TrixagonRangedAttackAction() : GameAction() constructor {
    static type = ActionType.TrixagonRangedAttack;
    static planColor = c_red;
    
    static toString = function() {
        return "TRIXAGON RANGED ATTACK";
    }
    
    static drawPlanned = function(_unit, _fromHex) {
        var _hexMap = _unit.hexMap;
        var _fromPosition = _hexMap.getTileXY(_hexMap.getTile(_fromHex));
        var _targetHex = _fromHex.add(global.hexDirections[_unit.facing]);
        var _toPosition = _hexMap.getTileXY(_hexMap.getTile(_targetHex));
        
        draw_set_color(self.planColor);
        drawSimpleArrow(_fromPosition, _toPosition, 40);
    }
}