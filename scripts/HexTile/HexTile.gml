function HexTile(_position, _terrainType = TerrainType.Base) constructor {
    self.position = _position;
    self.TerrainType = _terrainType;
    self.TerrainTypeInfo = global.TerrainTypeMap[? _terrainType];
    //neighbors = ds_list_create();
    
    static destroy = function() {
        //ds_list_destroy(neighbors);
    }
    
    static setTerrainType = function(_terrainType) {
        self.TerrainType = _terrainType;
        self.TerrainTypeInfo = global.TerrainTypeMap[? _terrainType];
    }
}