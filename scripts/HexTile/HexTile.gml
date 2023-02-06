function HexTile(_position, _terrainType = TerrainType.Base) constructor {
    position = _position;
    terrainType = _terrainType;
    terrainTypeInfo = global.terrainTypeMap[? _terrainType];
    height = 1;
    neighbors = ds_list_create();
    unit = pointer_null;
    animations = ds_list_create();
    
    static toString = function() {
        var _typeName = terrainTypeInfo.name;
        return string("{0}", _typeName);
    }
    
    static destroy = function() {
        ds_list_destroy(neighbors);
        ds_list_destroy(animations);
    }
    
    static setTerrainType = function(_terrainType) {
        terrainType = _terrainType;
        terrainTypeInfo = global.terrainTypeMap[? _terrainType];
    }
}
