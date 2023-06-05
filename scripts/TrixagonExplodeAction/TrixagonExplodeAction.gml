function TrixagonExplodeAction() : GameAction() constructor {
    static type = ActionType.TrixagonExplode;
    static planColor = c_red;
    
    static toString = function() {
        return "TRIXAGON EXPLODE";
    }
    
    static drawPlanned = function(_unit, _fromHex) {
        var _hexMap = _unit.hexMap;
        var _fromPosition = _hexMap.getTileXY(_hexMap.getTile(_fromHex));
        var _radius = 200;
        
        draw_set_color(self.planColor);
        draw_circle(_fromPosition.x - 1, _fromPosition.y - 1, _radius, false);
    }
}