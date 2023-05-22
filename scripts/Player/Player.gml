function Player(_number, _name, _color) constructor {
    number = _number;
    name = _name;
    color = _color;
    units = array_create(0);
    
    static addUnit = function(_unit) {
        if (_unit.player == self) {
            return;
        }
        
        if (_unit.player) {
            _unit.player.removeUnit(_unit);
        }
        
        _unit.player = self;
        
        array_push(units, _unit);
    }
    
    static removeUnit = function(_unit) {
        var _index = array_get_index(units, _unit);
        array_delete(units, _index, 1);
        
        _unit.player = pointer_null;
    }
}