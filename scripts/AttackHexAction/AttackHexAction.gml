function AttackHexAction(_hex) : GameAction() constructor {
    static type = ActionType.AttackHex;
    static planColor = c_red;
    hex = _hex;
    
    static toString = function() {
        return string("ATTACK HEX: {0}", string(hex));
    }
    
    static drawPlanned = function(_unit, _fromHex) {
        var _hexMap = _unit.hexMap;
        var _fromPosition = _hexMap.getTileXY(_hexMap.getTile(_fromHex));
        var _toPosition = _hexMap.getTileXY(_hexMap.getTile(self.hex));
        
        draw_set_color(self.planColor);
        drawSimpleArrow(_fromPosition, _toPosition, 20);
    }
}