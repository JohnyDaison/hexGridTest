function MovementStats() constructor {
    self.mobile = true;
    self.terrainRelations = ds_map_create();
    
    for (var i = 0; i < TerrainType.Length; i++) {
        self.terrainRelations[? i] = new ActionRelation();
    }
    
    static destroy = function () {
        ds_map_destroy(self.terrainRelations);
    }
    
    static copy = function () {
        var _newStats = new MovementStats();
        
        _newStats.mobile = self.mobile;
        
        for (var i = 0; i < TerrainType.Length; i++) {
            _newStats.terrainRelations[? i].copyFrom(self.terrainRelations[? i]);
        }
        
        return _newStats;
    };
    
}