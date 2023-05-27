function MoveToHexAction(_hex) : GameAction() constructor {
    static type = ActionType.MoveToHex;
    static planColor = c_green;
    hex = _hex;
    computedCost = 0;
    
    static toString = function() {
        return string("MOVE TO HEX: {0}", string(hex));
    }
    
    static drawPlanned = function(_unit, _fromHex) {
        var _hexMap = _unit.hexMap;
        var _fromPosition = _hexMap.getTileXY(_hexMap.getTile(_fromHex));
        var _toPosition = _hexMap.getTileXY(_hexMap.getTile(self.hex));
        
        draw_set_color(self.planColor);
        drawSimpleArrow(_fromPosition, _toPosition, 20);
    }
    
    static getEndPosition = function(_unit, _fromHex) {
        return hex;
    }
}