function HexTile(_position, _terrainType = TerrainType.Base) constructor {
    position = _position;
    terrainType = _terrainType;
    terrainTypeInfo = global.terrainTypeMap[? _terrainType];
    height = 1;
    neighbors = [];
    units = ds_list_create();
    animations = ds_list_create();
    
    static toString = function() {
        var _typeName = terrainTypeInfo.name;
        return string("{0}", _typeName);
    }
    
    static destroy = function() {
        ds_list_destroy(units);
        ds_list_destroy(animations);
    }
    
    static setTerrainType = function(_terrainType) {
        terrainType = _terrainType;
        terrainTypeInfo = global.terrainTypeMap[? _terrainType];
    }
    
    static placeUnit = function(_unit) {
        if (ds_list_find_index(units, _unit) != -1) {
            return false;
        }
        
        ds_list_add(units, _unit);
        _unit.currentTile = self;
        
        if (_unit.nextPosition == pointer_null)
            _unit.nextPosition = position;
        
        if (_unit.plannedFinalPosition == pointer_null)
            _unit.plannedFinalPosition = position;
        
        return true;
    }
    
    static getUnit = function(_index) {
        return units[| _index] ?? pointer_null;
    }
    
    static getTopUnit = function() {
        return units[| getUnitCount() - 1] ?? pointer_null;
    }
    
    static getUnitCount = function() {
        return ds_list_size(units);
    }
    
    static displaceUnit = function(_unit) {
        var _index = ds_list_find_index(units, _unit);
        if (_index == -1) {
            return false;
        }
        
        ds_list_delete(units, _index);
        _unit.currentTile = pointer_null;
        
        return true;
    }
}
