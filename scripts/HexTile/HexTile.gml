function HexTile(_position, _terrainType = TerrainType.Base) constructor {
    position = _position;
    terrainType = _terrainType;
    terrainTypeInfo = global.terrainTypeMap[? _terrainType];
    height = 1;
    neighbors = [];
    units = ds_list_create();
    animations = ds_list_create();
    overlaysArray = [];
    overlaysCount = 0;
    overlays = {};
    
    static createOverlay = function(_depth) {
        return {
            display: new SpriteDisplay(),
            depth: _depth
        }
    }
    
    static updateOverlaysArray = function () {
        var _keys = variable_struct_get_names(overlays);
        var _keyCount = array_length(_keys);
        
        array_foreach(_keys, function (_key) {
            var _overlay = variable_struct_get(overlays, _key)
            var _index = array_get_index(overlaysArray, _overlay);
            
            if (_index == -1) {
                array_push(overlaysArray, _overlay);
                overlaysCount = array_length(overlaysArray);
            }
        });
        
        array_sort(overlaysArray, function (_overlayA, _overlayB) {
            return sign(_overlayB.depth - _overlayA.depth);
        });
    }
    
    static drawOverlays = function (_center) {
        for (var i = 0; i < overlaysCount; i++) {
            var _overlay = overlaysArray[i];
            _overlay.display.draw(_center);
        }
    }
    
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
            
        _unit.updateFacing();
        
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
    
    static getRelativeTile = function(_hexOffset) {
        var _hex = position.add(_hexOffset);
        return hexMap.getTile(_hex);
    }
}
