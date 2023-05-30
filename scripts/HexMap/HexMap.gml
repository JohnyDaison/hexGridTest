function HexMap(_orientation, _size, _origin) constructor {
    layout = Layout(_orientation, _size, _origin);
    grid = new HexGrid();
    stackHeight = 1;
    highlightColor = c_white;
    highlightAlpha = 0.5;
    terrainPainter = new TerrainPainter(self);
    drawTileCoords = false;
    truncForHex = pointer_null;
    truncTiles = array_create(0);
    truncTint = c_white;
    
    static destroy = function() {
        grid.destroy();
    }
    
    static isValidPosition = function(_hex) {
        if (gameController.trixagon.active) {
            return modulo(_hex.q, 3) != modulo(_hex.r, 3);
        }
        
        return true;
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
        
        for (var _dirIndex = 0; _dirIndex < 3; _dirIndex++) {
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
    
    static polygonCorners = function(_hex, _scale = 1) {
        var _corners = [];
        var _center = hexToPixel(_hex);
        for (var i = 0; i < 6; i++) {
            var _offset = hexCornerOffset(i);
            if (_scale != 1) {
               _offset = _offset.multiplyByScalar(_scale);
            }
            
            _corners[i] = _center.add(_offset);
        }

        return _corners;
    }
    
    static drawFlatHex = function(_hex, _yOffset = 0, _scale = 1) {
        var _corners = polygonCorners(_hex, _scale);
        draw_primitive_begin(pr_trianglefan);
        for (var _k = 0; _k < 6; _k++) {
            var _corner = _corners[_k];
            var _x1 = _corner.x;
            var _y1 = _corner.y;
            draw_vertex(_x1, _y1 + _yOffset);
        }
        draw_primitive_end();
    }
    
    static drawUnitHighlight = function(_hex, _color, _yOffset = 0, _scale = 1) {
        var _innerCorners = polygonCorners(_hex, _scale);
        var _outerCorners = polygonCorners(_hex, _scale + 0.1);
        var _innerCornersOutline = polygonCorners(_hex, _scale - 0.025);
        var _outerCornersOutline = polygonCorners(_hex, _scale + 0.125);
        
        draw_set_alpha(0.65);
        drawHexagonOutline(_innerCorners, _outerCorners, _yOffset, _color);
        drawHexagonOutline(_innerCorners, _innerCornersOutline, _yOffset, c_black);
        drawHexagonOutline(_outerCorners, _outerCornersOutline, _yOffset, c_black);
    }
    
    static drawHexagonOutline = function(_innerCorners, _outerCorners, _yOffset, _color) {
        draw_set_color(_color);
        draw_primitive_begin(pr_trianglestrip);
        for (var _k = 0,  _shouldBreak = false; !_shouldBreak; _k++) {
            if (_k == 6) {
                _k = 0;
                _shouldBreak = true;
            }
            
            var _corner = _innerCorners[_k];
            var _x1 = _corner.x;
            var _y1 = _corner.y;
            
            draw_vertex(_x1, _y1 + _yOffset);
            
            _corner = _outerCorners[_k];
            _x1 = _corner.x;
            _y1 = _corner.y;
            
            draw_vertex(_x1, _y1 + _yOffset);
        }
        draw_primitive_end();
    }
    
    static drawTrixagonUnitHighlight = function(_hex, _bandColor, _unitColor, _yOffset = 0, _radius = 80) {
        var _lineThickness = 4;
        var _bandThickness = 24;
        
        var _outerRadius = _radius;
        var _outerBandRadius = _outerRadius - _lineThickness;
        var _innerBandRadius = _outerBandRadius - _bandThickness;
        var _innerRadius = _innerBandRadius - _lineThickness;
        
        var _center = hexToPixel(_hex);
        var _yWithOffset = _center.y + _yOffset;
        
        draw_set_alpha(0.8);
        
        draw_set_color(c_black);
        draw_circle(_center.x, _yWithOffset, _outerRadius, false);
        
        draw_set_color(_bandColor);
        draw_circle(_center.x, _yWithOffset, _outerBandRadius, false);
        
        draw_set_color(c_black);
        draw_circle(_center.x, _yWithOffset, _innerBandRadius, false);
        
        draw_set_color(_unitColor);
        draw_circle(_center.x, _yWithOffset, _innerRadius, false);
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
        for (var i = 0; i < _hexTile.height; i++) {
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
        
        for (var i = 0; i < _count; i++) {
            var _unit = _hexTile.getUnit(i);
            
            _unit.drawFacingArrow(_vector.x, _vector.y, Unit.facingArrowAlpha);
            _unit.draw(_vector.x, _vector.y);
        }
    }
    
    static drawAnimations = function(_animations) {
        var _count = ds_list_size(_animations);
        
        for (var i = 0; i < _count; i++) {
            var _animation = _animations[| i];
            
            _animation.draw();
        }
    }
    
    static drawHexes = function(_highlightHex, _selectedTile) {
        for (var _r = grid.minR; _r <= grid.maxR; _r++) {
            for (var _q = grid.minQ; _q <= grid.maxQ; _q++) {
                var _hex = new HexVector(_q,_r);
                var _hexTile = grid.getTile(_hex)
                
                if (_hexTile == pointer_null || _hexTile.terrainType == TerrainType.Base) {
                    continue;
                }
                
                draw_set_alpha(1);
                
                drawHexTile(_hexTile);
                
                var _center = getTileXY(_hexTile);
                _hexTile.overlay.draw(_center);
                
                var _drawHighlight = !is_undefined(_highlightHex) && _hex.equals(_highlightHex);
                var _highlightColor = highlightColor;
                
                if (_drawHighlight) {
                    draw_set_alpha(highlightAlpha);
                    draw_set_color(_highlightColor);
                
                    drawFlatHex(_hex, getTileYOffset(_hexTile));
                }
                
                if (_selectedTile != pointer_null && _hexTile == _selectedTile) {
                    drawUnitHighlight(_hex, Colors.friendlyGreen, getTileYOffset(_hexTile), 0.5);
                } else if (_drawHighlight) {
                    var _unit = _hexTile.getTopUnit();
                    if (_unit) {
                        drawUnitHighlight(_hex, Colors.enemyRed, getTileYOffset(_hexTile), 0.5);
                    }
                }
                
                if (drawTileCoords) {
                    draw_set_alpha(1);
                    draw_set_color(c_black);
                    draw_set_font(fontDebug);
                    draw_set_halign(fa_center);
                    
                    var _coordsOffset = 35;
                    draw_text(_center.x, _center.y + _coordsOffset, string("[{0}, {1}]", _q, _r));
                }
                
                drawHexUnits(_hexTile);
                drawAnimations(_hexTile.animations);
            }
        }
    }
    
    static drawUnitsOverlay = function(_units, _highlightHex, _selectedTile) {
        var _count = ds_list_size(_units);
        
        for (var i = 0; i < _count; i++) {
            var _unit = _units[| i];
            
            if (gameController.trixagon.active) {
                drawAnimations(_unit.animations);
            }
            
            if (!_unit.currentTile) {
                continue;
            }
            
            if (gameController.trixagon.active) {
                var _hexTile = _unit.currentTile;
                var _hex = _hexTile.position;
                var _drawHighlight = !is_undefined(_highlightHex) && _hex.equals(_highlightHex);
                
                if (_selectedTile != pointer_null && _hexTile == _selectedTile) {
                    drawTrixagonUnitHighlight(_hex, Colors.trixagonSelection, _unit.type.tint, getTileYOffset(_hexTile));
                } else if (_drawHighlight) {
                    var _highlightColor = gameController.selectedUnit ? Colors.trixagonTarget : Colors.trixagonHover;
                    
                    if (!gameController.selectedUnit && gameController.canUnitBeSelected(_unit)) {
                        drawTrixagonUnitHighlight(_hex, _highlightColor, _unit.type.tint, getTileYOffset(_hexTile));
                    }
                }
            }
            
            var _tileCenter = getTileXY(_unit.currentTile);
            _unit.drawOverlay(_tileCenter);
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
    
    static getTileQR = function(_q, _r) {
        return grid.getTileQR(_q, _r);
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
        var _totalCost = 0;
        
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
        
            var _action = new MoveToHexAction(_nextTile.position);
            _action.computedCost = _unit.getActionCost(_currentTile, _action);
            _totalCost += _action.computedCost;
            
            array_push(_actionArray, _action);
            
            _previousTile = _currentTile;
            _currentTile = _nextTile;
            _counter++;
        }
        
        return {actionArray: _actionArray, totalCost: _totalCost};
    }
    
    static updateTruncOverlay = function () {
        var _desiredTruncHex = pointer_null;
        
        if (gameController.selectedUnit && gameController.selectedUnit.currentTile) {
            _desiredTruncHex = gameController.selectedUnit.currentTile.position;
        }
        
        if (_desiredTruncHex != truncForHex) {
            array_foreach(truncTiles, function(_tile, _index) {
                _tile.overlay.enabled = false;
            });
            
            array_resize(truncTiles, 0);
            
            truncForHex = _desiredTruncHex;
            
            if (truncForHex) {
                var _isRight = truncForHex.isTrixagonRight();
                var _trunc = _isRight ? global.truncRight : global.truncLeft;
                
                truncTint = Colors.trixagonTruncMelee;
                self.setTruncTileOverlay(HexVector.zero);
                array_foreach(_trunc.melee, self.setTruncTileOverlay);
                
                truncTint = Colors.trixagonTrunc;
                array_foreach(_trunc.movement, self.setTruncTileOverlay);
                
                truncTint = Colors.trixagonTruncRanged;
                array_foreach(_trunc.ranged, self.setTruncTileOverlay);
            }
        }
    }
    
    static setTruncTileOverlay = function (_hexOffset) {
        var _hex = truncForHex.add(_hexOffset);
        var _isRight = _hex.isTrixagonRight();
        var _tile = getTile(_hex);
        
        if (!_tile) {
            return;
        }
        
        _tile.overlay.enabled = true;
        _tile.overlay.sprite = _isRight ? sprTrixagonTileRight : sprTrixagonTileLeft;
        _tile.overlay.tint = truncTint;
        _tile.overlay.alpha = 0.7;
        
        array_push(truncTiles, _tile);
    }
}
