function HexTile(_position, _terrainType = TerrainType.Base) constructor {
    position = _position;
    terrainType = _terrainType;
    terrainTypeInfo = global.terrainTypeMap[? _terrainType];
    height = 1;
    neighbors = [];
    units = ds_list_create();
    animations = ds_list_create();
    overlaysTopArray = [];
    overlaysTopCount = 0;
    overlaysBottomArray = [];
    overlaysBottomCount = 0;
    overlays = {};
    
    static createOverlay = function(_depth) {
        return {
            display: new SpriteDisplay(),
            depth: _depth
        }
    }
    
    static updateOverlaysArrays = function () {
        var _keys = variable_struct_get_names(overlays);
        var _keyCount = array_length(_keys);
        
        array_foreach(_keys, function (_key) {
            var _overlay = overlays[$ _key];
            var _overlaysArray = _overlay.depth < 0 ? overlaysTopArray : overlaysBottomArray;
            var _index = array_get_index(_overlaysArray, _overlay);
            
            if (_index == -1) {
                array_push(_overlaysArray, _overlay);
                if (_overlay.depth < 0) {
                    overlaysTopCount = array_length(_overlaysArray);
                } else {
                    overlaysBottomCount = array_length(_overlaysArray);
                }
            }
        });
        
        array_sort(overlaysTopArray, function (_overlayA, _overlayB) {
            return sign(_overlayB.depth - _overlayA.depth);
        });
        
        array_sort(overlaysBottomArray, function (_overlayA, _overlayB) {
            return sign(_overlayB.depth - _overlayA.depth);
        });
    }
    
    static drawTopOverlays = function (_center) {
        for (var i = 0; i < overlaysTopCount; i++) {
            var _overlay = overlaysTopArray[i];
            _overlay.display.draw(_center);
        }
    }
    
    static drawBottomOverlays = function (_center) {
        for (var i = 0; i < overlaysBottomCount; i++) {
            var _overlay = overlaysBottomArray[i];
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
