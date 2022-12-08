function HexGrid() constructor {
    tileList = ds_list_create();
    tileGrid = ds_map_create();
    minQ = undefined;
    maxQ = undefined;
    minR = undefined;
    maxR = undefined;
    
    static addTile = function(_position) {
        if (!is_undefined(getTile(_position))) {
            return false;
        }

        var _tile = new HexTile(_position);
        
        ds_list_add(tileList, _tile);
        
        var _column = tileGrid[? _position.q];
        if (is_undefined(_column)) {
            _column = ds_map_create();
            tileGrid[? _position.q] = _column;
        }
        
        _column[? _position.r] = _tile;
        
        if (is_undefined(minQ) || _position.q < minQ) {
            minQ = _position.q;   
        }
        
        if (is_undefined(maxQ) || _position.q > maxQ) {
            maxQ = _position.q;   
        }
        
        if (is_undefined(minR) || _position.r < minR) {
            minR = _position.r;
        }
        
        if (is_undefined(maxR) || _position.r > maxR) {
            maxR = _position.r;   
        }
        
        return _tile;
    }
    
    static getTile = function(_position) {
        var _column = tileGrid[? _position.q];
        if (is_undefined(_column)) {
            return undefined;   
        }
        
        var _tile = _column[? _position.r];
        
        return _tile;
    }
    
    static destroy = function() {
        var _tileCount = ds_list_size(tileList);
        
        for(var i = 0; i < _tileCount; i++) {
            var _tile = tileList[| i];
            _tile.destroy();
        }
        
        ds_list_destroy(tileList);
        
        for(var _q = minQ; _q <= maxQ; _q++) {
            var _column = tileGrid[? _q];
            
            if (!is_undefined(_column)) {
                ds_map_destroy(_column);
            }
        }
        
        ds_map_destroy(tileGrid);
    }
}
