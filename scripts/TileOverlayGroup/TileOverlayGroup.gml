function TileOverlayGroup(_hexMap) constructor {
    hexMap = _hexMap;
    tiles = [];
    data = ds_map_create();
    
    static destroy = function() {
        ds_map_destroy(data);
    }
    
    static clearData = function() {
        array_resize(tiles, 0);
        ds_map_clear(data);
    }
    
    static clearOverlays = function () {
        array_foreach(tiles, function(_tile) {
            var _tileData = data[? _tile];
            
            for(var i = 0; i < hexMap.tileOverlayCount; i++) {
                var _id = hexMap.tileOverlayIDs[i];
            
                if (!is_undefined(_tileData[$ _id])) {
                    _tile.overlays[$ _id].display.setState(false);
                }
            }
        });
    }
    
    static setData = function (_tile, _data) {
        if (!_tile || !_data) {
            return;
        }
        
        if (!array_contains(tiles, _tile)) {
            array_push(tiles, _tile);
            data[? _tile] = {};
        }
        
        var _tileData = data[? _tile];
        
        for(var i = 0; i < hexMap.tileOverlayCount; i++) {
            var _id = hexMap.tileOverlayIDs[i];
            
            if (!is_undefined(_data[$ _id])) {
                _tileData[$ _id] = _data[$ _id];
            }
        }
    }
    
    static applyData = function() {
        array_foreach(tiles, function (_tile) {
            hexMap.updateTileOverlay(_tile, data[? _tile]);
        });
    }
}