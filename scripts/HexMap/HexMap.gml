function HexMap(_orientation, _size, _origin) constructor {
    layout = Layout(_orientation, _size, _origin);
    grid = new HexGrid();
    stackHeight = 1;
    highlightColor = c_white;
    highlightAlpha = 0.5;
    terrainPainter = new TerrainPainter(self);
    drawTileCoords = false;
    
    truncForHex = pointer_null;
    truncForUnit = pointer_null;
    truncForFacing = -1;
    
    bombForHex = pointer_null;
    bombForUnit = pointer_null;

    truncAlpha = 0.6;
    stripesAlpha = 0.1;
    topOverlaysTiles = array_create(0);
    
    tileOverlayIDs = [];
    tileOverlayCount = 0;
    tileOverlayData = ds_map_create();
    
    tileOverlayGroupIDs = [];
    tileOverlayGroupCount = 0;
    tileOverlayGroupData = ds_map_create();
    
    static destroy = function() {
        grid.destroy();
        
        for (var i = 0; i < tileOverlayGroupCount; i++) {
            var _id = tileOverlayGroupIDs[ i];
            var _group = tileOverlayGroupData[? _id];
            _group.destroy();
        }
        
        ds_map_destroy(tileOverlayGroupData);
        
        ds_map_destroy(tileOverlayData);
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
    
    static drawTrixagonUnitHighlight = function(_hex, _bandColor, _unitColor, _yOffset = 0, _tintBand = false, _radius = 80) {
        var _lineThickness = 4;
        var _bandThickness = 24;
        
        var _outerRadius = _radius;
        var _outerBandRadius = _outerRadius - _lineThickness;
        var _innerBandRadius = _outerBandRadius - _bandThickness;
        var _innerRadius = _innerBandRadius - _lineThickness;
        
        var _center = hexToPixel(_hex);
        var _x = _center.x - 1;
        var _yWithOffset = _center.y + _yOffset - 1;
        
        
        draw_set_alpha(0.8);
        
        draw_set_color(c_black);
        draw_circle(_x, _yWithOffset, _outerRadius, false);
        
        if (_tintBand) {
            _bandColor = merge_color(_bandColor, _unitColor, 0.4)
        }
        
        draw_set_color(_bandColor);
        draw_circle(_x, _yWithOffset, _outerBandRadius, false);
        
        draw_set_color(c_black);
        draw_circle(_x, _yWithOffset, _innerBandRadius, false);
        
        draw_set_color(_unitColor);
        draw_circle(_x, _yWithOffset, _innerRadius, false);
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
            
            if (_unit.type.drawOverlay && _unit.type.hasFace  && !_unit.facingUncertain) {
                _unit.drawFacingArrow(_vector.x, _vector.y, Unit.facingArrowAlpha);
            }
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
        array_resize(topOverlaysTiles, 0);
        
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
                _hexTile.drawBottomOverlays(_center);
                
                if (_hexTile.overlaysTopCount > 0) {
                    array_push(topOverlaysTiles, _hexTile);
                }
                
                var _drawHighlight = !is_undefined(_highlightHex) && _hex.equals(_highlightHex);
                var _highlightColor = highlightColor;
                
                if (_drawHighlight) {
                    draw_set_alpha(highlightAlpha * objHexMap.cursorPulseCurrent);
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
    
    static drawTrixagonUnits = function(_units, _highlightHex, _selectedTile) {
        if (!gameController.trixagon.active) {
            return;
        }
        
        var _count = ds_list_size(_units);
        
        for (var i = 0; i < _count; i++) {
            var _unit = _units[| i];
            
            drawAnimations(_unit.animations);
            
            if (!_unit.currentTile) {
                continue;
            }

            var _hexTile = _unit.currentTile;
            var _hex = _hexTile.position;
            var _drawHighlight = !is_undefined(_highlightHex) && _hex.equals(_highlightHex);
                
            if (_selectedTile != pointer_null && _hexTile == _selectedTile) {
                var _tintBand = gameController.hoveredUnit && gameController.selectedUnit && gameController.hoveredUnit != gameController.selectedUnit;
                drawTrixagonUnitHighlight(_hex, Colors.trixagonSelection, _unit.type.tint, getTileYOffset(_hexTile), _tintBand);
            } else if (_drawHighlight) {
                if (gameController.canUnitBeSelected(_unit)) {
                    drawTrixagonUnitHighlight(_hex, Colors.trixagonHover, _unit.type.tint, getTileYOffset(_hexTile));
                }
            }
        }
    }
    
    static drawTopTileOverlays = function () {
        var _count = array_length(topOverlaysTiles);
        
        for (var i = 0; i < _count; i++) {
            var _hexTile = topOverlaysTiles[i];
            var _center = getTileXY(_hexTile);
            _hexTile.drawTopOverlays(_center);
        }
    }
    
    static drawUnitsOverlay = function(_units) {
        var _count = ds_list_size(_units);
        
        for (var i = 0; i < _count; i++) {
            var _unit = _units[| i];
            
            if (!_unit.currentTile) {
                continue;
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
        _hexTile.hexMap = self;
        
        for(var i = 0; i < tileOverlayCount; i++) {
            var _id = tileOverlayIDs[i];
            var _data = tileOverlayData[? _id];
            
            _hexTile.overlays[$ _id] = _hexTile.createOverlay(_data.depth);
        }
        
        _hexTile.updateOverlaysArrays();
        
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
    
    static getUnitOfTypeAtPosition = function (_unitType, _hex) {
        var _hexTile = getTile(_hex);
        if (!_hexTile) {
            return pointer_null;
        }
        
        var _topUnit = _hexTile.getTopUnit();
        if (!_topUnit) {
            return pointer_null;
        }
        
        if (_topUnit.type.typeId == _unitType) {
            return _topUnit;
        }
        
        return pointer_null;
    }
    
    static findNearestUnitOfTypeInRange = function (_hex, _unitType, _range = 1, _includeCenter = true) {
        var _unit = pointer_null;
        
        if (_includeCenter) {
            var _centerUnit = getUnitOfTypeAtPosition(_unitType, _hex);
            
            if (_centerUnit) {
                return _centerUnit;
            }
        }
        
        for (var _radius = 1; _radius <= _range; _radius++) {
            var _ring = _hex.getRing(_radius);
            var _hexCount = array_length(_ring);
                
            for (var i = 0; i < _hexCount; i++) {
                var _ringHex = _ring[i];
                var _nearUnit = getUnitOfTypeAtPosition(_unitType, _ringHex);
                
                if (_nearUnit) {
                    _unit = _nearUnit;
                    break;
                }
            }
            
            if (_unit) {
                break;
            }
        }
        
        return _unit;
    }
    
    static addTileOverlay = function (_id, _depth) {
        if (array_contains(tileOverlayIDs, _id)) {
            return;
        }
        
        array_push(tileOverlayIDs, _id);
        tileOverlayCount++;
        
        tileOverlayData[? _id] = {
            depth: _depth,
        }
    }
    
    static addTileOverlayGroup = function (_id) {
        if (array_contains(tileOverlayGroupIDs, _id)) {
            return;
        }
        
        array_push(tileOverlayGroupIDs, _id);
        tileOverlayGroupCount++;
        
        tileOverlayGroupData[? _id] = new TileOverlayGroup(self);
    }
    
    static updateTileOverlays = function () {
        updateTruncOverlay();
        updateBombOverlay();
    }
    
    static updateTruncOverlay = function () {
        var _desiredTruncHex = pointer_null;
        var _desiredTruncUnit = pointer_null;
        var _desiredTruncFacing = -1;
        
        if (gameController.selectedUnit && gameController.selectedUnit.currentTile) {
            _desiredTruncHex = gameController.selectedUnit.currentTile.position;
            _desiredTruncUnit = gameController.selectedUnit;
            _desiredTruncFacing = gameController.selectedUnit.facing;
        }
        
        if (_desiredTruncHex != truncForHex || _desiredTruncUnit != truncForUnit || _desiredTruncFacing != truncForFacing) {
            var _movementGroup = tileOverlayGroupData[? "movement"];
            var _combatGroup = tileOverlayGroupData[? "combat"];
                
            _movementGroup.clearOverlays();
            _movementGroup.clearData();
            
            _combatGroup.clearOverlays();
            _combatGroup.clearData();
            
            truncForHex = _desiredTruncHex;
            truncForUnit = _desiredTruncUnit;
            truncForFacing = _desiredTruncFacing;
            
            if (truncForHex && truncForUnit) {
                var _unitTile = truncForUnit.currentTile;
                var _canMove = truncForUnit.movement.canMove();
                var _trunc = truncForHex.getTrixagonTrunc();
                var _truncMeleeValid = truncForUnit.combat.trixagonMeleeAttackValid();
                
                var _tile = _unitTile.getRelativeTile(HexVector.zero);
                
                self.setTrixagonMovementTileOverlaysData(_tile, true, Colors.trixagonTrunc);
                self.setTrixagonCombatTileOverlaysData(_tile, truncForUnit, false, false);
                
                for (var i = 0; i < 3; i++) {
                    var _hexOffset = _trunc.melee[i];
                    _tile = _unitTile.getRelativeTile(_hexOffset);
                    
                    self.setTrixagonMovementTileOverlaysData(_tile, _canMove, Colors.trixagonTrunc);
                    self.setTrixagonCombatTileOverlaysData(_tile, truncForUnit, _truncMeleeValid, false);
                }
                
                for (var i = 0; i < 6; i++) {
                    var _hexOffset = _trunc.movement[i];
                    _tile = _unitTile.getRelativeTile(_hexOffset);
                    
                    self.setTrixagonMovementTileOverlaysData(_tile, _canMove, Colors.trixagonTrunc);
                    self.setTrixagonCombatTileOverlaysData(_tile, truncForUnit, false, false);
                }
                
                for (var i = 0; i < 3; i++) {
                    var _hexOffset = _trunc.ranged[i];
                    _tile = _unitTile.getRelativeTile(_hexOffset);
                    
                    self.setTrixagonMovementTileOverlaysData(_tile, _canMove, Colors.trixagonTruncRanged);
                    self.setTrixagonCombatTileOverlaysData(_tile, truncForUnit, false, true);
                }
                
                _movementGroup.applyData();
                _combatGroup.applyData();
            }
        }
    }
    
    static updateBombOverlay = function () {
        var _desiredBombHex = pointer_null;
        var _desiredBombUnit = pointer_null;
        
        if (gameController.hoveredUnit && gameController.hoveredUnit.currentTile && gameController.hoveredUnit.type.typeId == UnitType.TrixagonBomb) {
            _desiredBombHex = gameController.hoveredUnit.currentTile.position;
            _desiredBombUnit = gameController.hoveredUnit;
        }
        
        if (_desiredBombHex != bombForHex || _desiredBombUnit != bombForUnit) {
            var _movementGroup = tileOverlayGroupData[? "movement"];
            var _combatGroup = tileOverlayGroupData[? "combat"];
            var _bombGroup = tileOverlayGroupData[? "bomb"];
            
                
            _bombGroup.clearOverlays();
            _bombGroup.clearData();
            
            bombForHex = _desiredBombHex;
            bombForUnit = _desiredBombUnit;
            
            if (bombForHex && bombForUnit) {
                var _unitTile = bombForUnit.currentTile;
                var _trunc = bombForHex.getTrixagonTrunc();
                var _tile;
                
                for (var i = 0; i < 3; i++) {
                    var _hexOffset = _trunc.melee[i];
                    _tile = _unitTile.getRelativeTile(_hexOffset);
                    
                    self.setTrixagonBombTileOverlaysData(_tile, bombForUnit, true, false);
                }
                
                for (var i = 0; i < 6; i++) {
                    var _hexOffset = _trunc.movement[i];
                    _tile = _unitTile.getRelativeTile(_hexOffset);
                    
                    self.setTrixagonBombTileOverlaysData(_tile, bombForUnit, false, true);
                }
                
                _movementGroup.clearOverlays();
                _combatGroup.clearOverlays();
                _bombGroup.applyData();
            } else {
                _movementGroup.applyData();
                _combatGroup.applyData();
            }
        }
    }
    
    static setTrixagonMovementTileOverlaysData = function (_tile, _canMove, _tint) {
        if (!_tile)
            return;
        
        var _overlayGroup = tileOverlayGroupData[? "movement"];
        var _blocked = false;
        var _unit = _tile.getTopUnit();
        var _tileBlocked = _unit && _unit.type.indestructible;
        
        _blocked = !_canMove || _tileBlocked;
        
        if (!(gameController.trixagon.hideBlockedTiles && _blocked)) {
            _overlayGroup.setData(_tile, {
                tint: _tint,
                stripes: gameController.trixagon.stripeBlockedTiles && _blocked
            });
        }
    }
    
    static setTrixagonCombatTileOverlaysData = function (_tile, _forUnit, _melee, _ranged) {
        if (!_tile)
            return;
        
        var _overlayGroup = tileOverlayGroupData[? "combat"];
        var _unit = _tile.getTopUnit();
        
        
        if (_melee) {
            var _meleeTarget = false;
            var _unitInFront = _forUnit.getUnitInFrontOfMe();
            _meleeTarget = _unitInFront && _unit == _unitInFront;
            
            _overlayGroup.setData(_tile, {
                meleeTarget: _meleeTarget,
            });
        }
        
        
        if (_ranged) {
            var _rangedTarget = pointer_null;
            var _validRangedTarget = _forUnit.combat.trixagonRangedAttackValid(_unit);
            _rangedTarget = _validRangedTarget ? sprTrixagonRangedTargetValid : sprTrixagonRangedTargetInvalid;
             
            _overlayGroup.setData(_tile, {
                rangedTarget: _rangedTarget,
            });
        }
    }
    
    static setTrixagonBombTileOverlaysData = function (_tile, _forUnit, _melee, _ranged) {
        if (!_tile)
            return;
        
        var _overlayGroup = tileOverlayGroupData[? "bomb"];
        var _unit = _tile.getTopUnit();
        
        if (_melee) {
            _overlayGroup.setData(_tile, {
                meleeTarget: true,
            });
        }
        
        if (_ranged) {
            var _rangedTarget = pointer_null;
            var _validRangedTarget = _forUnit.combat.trixagonRangedAttackValid(_unit);
            _rangedTarget = _validRangedTarget ? sprTrixagonRangedTargetValid : sprTrixagonRangedTargetInvalid;
             
            _overlayGroup.setData(_tile, {
                rangedTarget: _rangedTarget,
            });
        }
    }

    static updateTileOverlay = function (_tile, _data) {
        if (gameController.trixagon.active) {
            updateTrixagonTileOverlay(_tile, _data);
        }
    }
    
    static updateTrixagonTileOverlay = function (_tile, _data) {
        if (!_tile || !_data) {
            return;
        }
        
        var _isRight = _tile.position.isTrixagonRight();
        
        if (!is_undefined(_data[$ "tint"])) {
            var _truncSprite = _isRight ? sprTrixagonTileRight : sprTrixagonTileLeft;
            _tile.overlays.tint.display.setState(_data.tint != pointer_null, _truncSprite, _data.tint, truncAlpha);
        }
        
        if (!is_undefined(_data[$ "stripes"])) {
            var _stripesSprite = _isRight ? sprTrixagonTileRightStripes : sprTrixagonTileLeftStripes;
            _tile.overlays.stripes.display.setState(_data.stripes, _stripesSprite, Colors.trixagonTruncMovementBlocked, stripesAlpha);
        }
        
        if (!is_undefined(_data[$ "meleeTarget"])) {
            _tile.overlays.meleeTarget.display.setState(_data.meleeTarget, sprTrixagonMeleeTarget, Colors.trixagonMeleeTarget, gameController.trixagon.meleeTargetAlpha);
            _tile.overlays.meleeTarget.display.cursorPulse = true;
        }
        
        if (!is_undefined(_data[$ "rangedTarget"])) {
            _tile.overlays.rangedTarget.display.setState(_data.rangedTarget != pointer_null, _data.rangedTarget, Colors.trixagonRangedTarget, gameController.trixagon.rangedTargetAlpha);
            _tile.overlays.rangedTarget.display.cursorPulse = true;
        }
    }
}
