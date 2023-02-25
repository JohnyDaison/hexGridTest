function HexMap(_orientation, _size, _origin) constructor {
    layout = Layout(_orientation, _size, _origin);
    grid = new HexGrid();
    stackHeight = 1;
    highlightColor = c_white;
    highlightMoveColor = merge_color(c_white, c_yellow, 0.8);
    highlightAlpha = 0.5;
    terrainPainter = new TerrainPainter(self);
    drawTileCoords = true;
    
    static destroy = function() {
        grid.destroy();
    }
    
    static getTileYOffset = function(_hexTile) {
        return (_hexTile.height - 1) * -stackHeight;
    }
    
    static getTileXY = function(_hexTile) {
        var _vector = hexToPixel(_hexTile.position);
        
        return new Vector(_vector.x, _vector.y + getTileYOffset(_hexTile));
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
        
        if (_hexTile == pointer_null) {
            return false;
        }
        
        var _cursorHex = pixelToHex(_x, _y, getTileYOffset(_hexTile));
        if (_cursorHex.equals(_hex)) {
            return true;
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
                if (grid.getTile(_hex) == pointer_null) {
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
    
    static drawHexUnits = function(_hexTile) {
        var _count = _hexTile.getUnitCount();
        var _vector = getTileXY(_hexTile);
        
        for(var i = 0; i < _count; i++) {
            var _unit = _hexTile.getUnit(i);
            
            _unit.draw(_vector.x, _vector.y);
        }
    }
    
    static drawHexAnimations = function(_hexTile) {
        var _count = ds_list_size(_hexTile.animations);
        
        for(var i = 0; i < _count; i++) {
            var _animation = _hexTile.animations[| i];
            
            if (_animation.started && !_animation.ended) {
                _animation.draw(_hexTile);
            }
        }
    }
    
    static drawHexes = function(_highlightHex, _movementTile) {
        for (var _r = grid.minR; _r <= grid.maxR; _r++) {
            for (var _q = grid.minQ; _q <= grid.maxQ; _q++) {
                var _hex = new HexVector(_q,_r);
                var _hexTile = grid.getTile(_hex)
                
                if (_hexTile == pointer_null || _hexTile.terrainType == TerrainType.Base) {
                    continue;
                }
                
                draw_set_alpha(1);
                
                drawHexTile(_hexTile);
                
                var _drawHighlight = !is_undefined(_highlightHex) && _hex.equals(_highlightHex);
                var _highlightColor = highlightColor;
                
                if (_movementTile != pointer_null && _hexTile == _movementTile) {
                    _drawHighlight = true;
                    _highlightColor = highlightMoveColor;
                }
                
                if (_drawHighlight) {
                    draw_set_alpha(highlightAlpha);
                    draw_set_color(_highlightColor);
                
                    drawFlatHex(_hex, getTileYOffset(_hexTile));
                }
                
                if (drawTileCoords) {
                    draw_set_alpha(1);
                    draw_set_color(c_black);
                    draw_set_font(fontDebug);
                    draw_set_halign(fa_center);
                
                    var _center = getTileXY(_hexTile);
                    var _coordsOffset = 35;
                    draw_text(_center.x, _center.y + _coordsOffset, string("[{0}, {1}]", _q, _r));
                }
                
                drawHexUnits(_hexTile);
                drawHexAnimations(_hexTile);
            }
        }
    }
    
    static addTile = function (_q, _r, _terrainType, _height = 1) {
        var _hexTile = grid.addTile(new HexVector(_q, _r));
        
        if (_hexTile == pointer_null) {
            return pointer_null;
        }
        
        _hexTile.setTerrainType(_terrainType);
        _hexTile.height = _height;
        
        return _hexTile;
    }
    
    static getTile = function (_hex) {
        return grid.getTile(_hex);
    }
    
    static paintTerrain = function (_centerHex, _brush, _generatorFunction, _options = undefined) {
        terrainPainter.paintTerrain(_centerHex, _brush, _generatorFunction, _options);
    }
    
    static placeUnit = function(_hexTile, _unit) {
        return _hexTile.placeUnit(_unit);
    }
    
    static displaceUnit = function(_unit) {
        var _hexTile = _unit.currentTile;
        if (_hexTile == pointer_null) {
            return false;
        }
        
        _hexTile.displaceUnit(_unit);
        
        return true;
    }

    static findUnitPath = function (_unit, _fromHex, _toHex, _maxPathLength = 100) {
        var _actionArray = [];
        
        var _startTile = getTile(_fromHex);
        if (_startTile == pointer_null) {
            return _actionArray;
        }
        
        var _frontier = [];
        var _currentTile = _startTile;
        var _previousTile = pointer_null;
        var _counter = 0;
        
        while(!_currentTile.position.equals(_toHex) && _counter < _maxPathLength) {
            _frontier = _currentTile.neighbors;
        
            var _nextTileIndex = _toHex.findClosestTile(_frontier);
            var _nextTile = _frontier[_nextTileIndex];
        
            // prevent looping between two tiles
            if (_previousTile == _nextTile) {
                break;
            }
        
            array_push(_actionArray, new MoveToHexAction(_nextTile.position));
            
            _previousTile = _currentTile;
            _currentTile = _nextTile;
            _counter++;
        }
        
        return _actionArray;
    }
}
