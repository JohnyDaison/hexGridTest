function UnitAnimation(_gameController, _unit) : GameAnimation(_gameController) constructor {
    unit = pointer_null;
    
    static setUnit = function(_unit) {
        if (unit != pointer_null) {
            var _index = ds_list_find_index(unit.animations, self);
            ds_list_delete(unit.animations, _index);
        }
        
        unit = _unit;
        
        if (unit != pointer_null) {
            ds_list_add(unit.animations, self);
        }
    }
    
    setUnit(_unit);
}