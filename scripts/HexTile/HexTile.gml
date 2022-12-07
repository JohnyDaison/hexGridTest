function HexTile(_position, _TerrainType = TerrainType.Base) constructor {
    self.position = _position;
    self.TerrainType = _TerrainType;
    self.TerrainTypeInfo = global.TerrainTypeMap[? _TerrainType];
    //neighbors = ds_list_create();
    
    static destroy = function() {
        //ds_list_destroy(neighbors);
    }
    
    static setTerrainType = function(_TerrainType) {
        self.TerrainType = _TerrainType;
        self.TerrainTypeInfo = global.TerrainTypeMap[? _TerrainType];
    }
}