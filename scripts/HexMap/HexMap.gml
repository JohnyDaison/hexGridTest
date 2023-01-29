function HexMap(_orientation, _size, _origin) constructor {
    layout = Layout(_orientation, _size, _origin);
    grid = new HexGrid();
    stackHeight = 1;
    highlightColor = c_white;
    highlightAlpha = 0.5;
    units = ds_list_create();
    
    static destroy = function() {
        grid.destroy();
        
        var _unitCount = ds_list_size(units);
        for (var i = 0; i < _unitCount; i++) {
            var _unit = units[| i];
            _unit.destroy();
        }
        
        ds_list_destroy(units);
    }
    
    static getTileYOffset = function(_hexTile) {
        return (_hexTile.height - 1) * -stackHeight;
    }
    
    static pixelToHex = function(_x, _y, _yOffset = 0) {
        var _ori = layout[lay.orient];
        var _size = layout[lay.size];
        var _origin = layout[lay.origin];
        
        var _tempX = (_x - _origin.x) / _size.x;
        var _tempY = (_y - _origin.y - _yOffset) / _size.y;

        var _q = _ori[ori.b0] * _tempX + _ori[ori.b1] * _tempY;
        var _r = _ori[ori.b2] * _tempX + _ori[ori.b3] * _tempY;

        var _result = new HexVector(_q, _r);
        _result.makeRound();
        return _result;
    }
    
    static isCursorOverHex = function(_x, _y, _hex) {
        var _hexTile = grid.getTile(_hex);
        
        if (!is_undefined(_hexTile)) {
            var _cursorHex = pixelToHex(_x, _y, getTileYOffset(_hexTile));
            if (_cursorHex.equals(_hex)) {
                return true;
            }
        }
        
        return false;
    }
    
    static cursorToHex = function(_x, _y) {
        var _baseHex = pixelToHex(_x, _y);
        var _highlightHex = undefined;
        
        if (isCursorOverHex(_x, _y, _baseHex)) {
            _highlightHex = _baseHex;
        }
        
        for(var _dirIndex = 0; _dirIndex < 3; _dirIndex++) {
            var _otherHex = _baseHex.add(global.hexDirectionsDown[_dirIndex]);
            
            if (isCursorOverHex(_x, _y, _otherHex)) {
                _highlightHex = _otherHex;
            }
        }
        
        return _highlightHex;
    }
    
    static hexToPixel = function(_hex) {
        var _ori = layout[lay.orient];
        var _size = layout[lay.size];
        var _origin = layout[lay.origin];
        var _xx = (_ori[ori.f0] * _hex.q + _ori[ori.f1] * _hex.r) * _size.x;
        var _yy = (_ori[ori.f2] * _hex.q + _ori[ori.f3] * _hex.r) * _size.y;
        return new Vector(_xx + _origin.x, _yy + _origin.y);
    }
    
    static hexCornerOffset = function(_corner) {
        var _ori = layout[lay.orient];
        var _size = layout[lay.size];
        var _angle = 2.0 * pi * (_ori[ori.start_angle] - _corner) / 6.0;

        return new Vector(_size.x * cos(_angle), _size.y * sin(_angle));
    }
    
    static polygonCorners = function(_hex) {
        var _corners = [];
        var _center = hexToPixel(_hex);
        for (var i = 0; i < 6; i++) {
            var _offset = hexCornerOffset(i);
            _corners[i] = _center.add(_offset);
        }

        return _corners;
    }
    
    static drawFlatHex = function(_hex, _yOffset = 0) {
        var _corners = polygonCorners(_hex);
        draw_primitive_begin(pr_trianglefan);
        for (var _k = 0; _k < 6; _k++) {
            var _corner = _corners[_k];
            var _x1 = _corner.x;
            var _y1 = _corner.y;
            draw_vertex(_x1, _y1 + _yOffset);
        }
        draw_primitive_end();
    }
    
    static drawHexBg = function() {
        for (var _r = grid.minR; _r <= grid.maxR; _r++) {
            var _rOffset = floor(_r / 2);
            for (var _q = grid.minQ; _q <= grid.maxQ; _q++) {
                var _hex = new HexVector(_q,_r);
                if (is_undefined(grid.getTile(_hex))) {
                    continue;
                }
                
                drawFlatHex(_hex);
            }
        }
    }
    
    static drawHexTile = function(_hexTile) {
        var _vector = hexToPixel(_hexTile.position);
        for(var i = 0; i < _hexTile.height; i++) {
            if (i == _hexTile.height - 1) {
                draw_sprite(_hexTile.terrainTypeInfo.sprBasic, 0, _vector.x, _vector.y - i * stackHeight);
            } else {
                draw_sprite(_hexTile.terrainTypeInfo.sprStack, 0, _vector.x, _vector.y - i * stackHeight);
            }
        }
    }
    
    static drawHexUnit = function(_hexTile) {
        if (_hexTile.unit == pointer_null) {
            return;
        }
        
        var _vector = hexToPixel(_hexTile.position);
        var _unit = _hexTile.unit;
        var _unitScale = _unit.type.scale;
        var _yOffset = _unit.type.yOffset;
        
        draw_sprite_ext(_unit.animSprite, _unit.animProgress,
            _vector.x, _vector.y + _unitScale*_yOffset - (_hexTile.height - 1) * stackHeight,
            _unitScale * _unit.facing, _unitScale, 0, c_white, 1);
    }
    
    static drawHexes = function(_highlightHex) {
        for (var _r = grid.minR; _r <= grid.maxR; _r++) {
            for (var _q = grid.minQ; _q <= grid.maxQ; _q++) {
                var _hex = new HexVector(_q,_r);
                var _hexTile = grid.getTile(_hex)
                
                if (is_undefined(_hexTile) || _hexTile.terrainType == TerrainType.Base) {
                    continue;
                }
                
                draw_set_alpha(1);
                
                drawHexTile(_hexTile);
                
                var _drawHighlight = !is_undefined(_highlightHex) && _hex.equals(_highlightHex);
                
                if (_drawHighlight) {
                    draw_set_alpha(highlightAlpha);
                    draw_set_color(highlightColor);
                
                    drawFlatHex(_hex, getTileYOffset(_hexTile));
                }
                
                drawHexUnit(_hexTile);
            }
        }
    }
    
    static addTile = function (_q, _r, _terrainType, _height = 1) {
        var _tile = grid.addTile(new HexVector(_q, _r));
        _tile.setTerrainType(_terrainType);
        _tile.height = _height;
        
        return _tile;
    }
    
    static addUnit = function(_hexTile, _unitType) {
        if (_hexTile.unit != pointer_null) {
            return false;
        }
        
        _hexTile.unit = new Unit(_unitType);
        ds_list_add(units, _hexTile.unit);
        
        return true;
    }
    
    static unitsAnimUpdate = function () {
        var _unitCount = ds_list_size(units);
        
        for (var i = 0; i < _unitCount; i++) {
            var _unit = units[| i];
            
            _unit.animUpdate();
        }
    }
}
