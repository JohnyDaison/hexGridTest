function HexTile(_position, _terrainType = TerrainType.Base) constructor {
    position = _position;
    terrainType = _terrainType;
    terrainTypeInfo = global.terrainTypeMap[? _terrainType];
    height = 1;
    neighbors = ds_list_create();
    unit = pointer_null;
    
    static destroy = function() {
        ds_list_destroy(neighbors);
    }
    
    static setTerrainType = function(_terrainType) {
        terrainType = _terrainType;
        terrainTypeInfo = global.terrainTypeMap[? _terrainType];
    }
}
