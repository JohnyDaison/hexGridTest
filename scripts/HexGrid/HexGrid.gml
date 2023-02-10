function HexGrid() constructor {
    tileList = ds_list_create();
    tileGrid = ds_map_create();
    minQ = undefined;
    maxQ = undefined;
    minR = undefined;
    maxR = undefined;
    
    static addTile = function(_position) {
        if (getTile(_position) != pointer_null) {
            return pointer_null;
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
        
        for(var _dirIndex = 0; _dirIndex < 6; _dirIndex++) {
            var _dir = global.hexDirections[_dirIndex];
            var _otherTile = getTile(_position.add(_dir));
            
            if (_otherTile != pointer_null) {
                ds_list_add(_tile.neighbors, _otherTile);
                ds_list_add(_otherTile.neighbors, _tile);
            }
        }
        
        return _tile;
    }
    
    static getTile = function(_position) {
        var _column = tileGrid[? _position.q];
        if (is_undefined(_column)) {
            return pointer_null;
        }
        
        var _tile = _column[? _position.r];
        if (is_undefined(_tile)) {
            return pointer_null;
        }
        
        return _tile;
    }
    
    static getTileQR = function(_q, _r) {
        var _column = tileGrid[? _q];
        if (is_undefined(_column)) {
            return undefined;
        }
        
        var _tile = _column[? _r];
        
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
