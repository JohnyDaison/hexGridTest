randomize();
tileSize = new Vector(160, 150); // tuned to our sprites
clearPlanButtonMargin = 190;
endTurnButtonMargin = 30;

var _halfRoomWidth = room_width / 2;
var _halfRoomHeight = room_height / 2;
startPosition = new Vector(_halfRoomWidth, _halfRoomHeight);
debugText = "TEST";

gameController = new GameController();

var _layout = layout_flat;
if (gameController.trixagon.active) {
    _layout = layout_pointy;

    var _tempY = tileSize.y;
    tileSize.y = tileSize.x;
    tileSize.x = _tempY;
}

hexMap = gameController.createMap(_layout, tileSize, startPosition);

if (gameController.trixagon.active) {
    hexMap.highlightColor = c_yellow;
    hexMap.highlightAlpha = 0.8;
}

clearPlanButton = noone;
endTurnButton = noone;

cursorHex = undefined;
cursorPos = undefined;
cursorTile = pointer_null;

cursorPulseMin = 0.6;
cursorPulseMax = 1;
cursorPulseCurrent = cursorPulseMax;
cursorPulseSpeed = 0.0045;
cursorPulseDirection = 1;

activeTerrainBrush = new TerrainBrush(TerrainBrushShape.Hexagon, 2, 1);
mainTerrainGenerator = randomTerrainGenerator;
terrainGeneratorOptions = { height: true };
lastPaintedPos = undefined;

if (gameController.trixagon.active) {
    mainTerrainGenerator = trixagonTerrainGenerator;
}

handleTap = function() {
    if (is_undefined(cursorHex)) {
        exit;
    }

    gameController.handleTileClicked(cursorTile);
}

handleDrag = function(_startTile, _endHex) {
    gameController.handleTileDragged(_startTile, _endHex);
}

drawFacingDragArrow = function() {
    if (!gameController.selectedUnit) {
        return;
    }
    
    var _input = objInputController;
    if (!_input.facingDragValid) {
        return;
    }
        
    var _fromPosition = hexMap.getTileXY(_input.dragStartTile);
    var _toPosition = hexMap.getTileXY(_input.facingDragTile);
        
    draw_set_color(c_orange);
    drawSimpleArrow(_fromPosition, _toPosition, 20);
}

createTestTiles = function() {
    var _player1 = gameController.players[? 1];
    var _player2 = gameController.players[? 2];
    var _unit;
    
    var _swordSkeleton = hexMap.addTile(-1, 0, TerrainType.Snow);
    _unit = gameController.addUnit(_swordSkeleton, UnitType.SkeletonSwordBasic);
    _player2.addUnit(_unit);

    var _bowSkeleton = hexMap.addTile(-1, 1, TerrainType.Snow, 3);
    _unit = gameController.addUnit(_bowSkeleton, UnitType.SkeletonBowBasic);
    _player2.addUnit(_unit);
    
    var _water = hexMap.addTile(0, -1, TerrainType.Water, 2);
    
    var _center = hexMap.addTile(0, 0, TerrainType.Rock, 3);
    _unit = gameController.addUnit(_center, UnitType.KnightUnarmedBasic);
    _player1.addUnit(_unit);
    
    var _swordKnight = hexMap.addTile(0, 1, TerrainType.Sand, 2);
    _unit = gameController.addUnit(_swordKnight, UnitType.KnightSwordBasic);
    _player1.addUnit(_unit);

    var _bowKnight = hexMap.addTile(1, -1, TerrainType.Grass);
    _unit = gameController.addUnit(_bowKnight, UnitType.KnightBowBasic);
    _player1.addUnit(_unit);
    
    var _dummy = hexMap.addTile(1, 0, TerrainType.Grass);
    gameController.addUnit(_dummy, UnitType.TrainingDummy);
    
    var _bat = hexMap.addTile(2, -1, TerrainType.Sand, 3);
    gameController.addUnit(_bat, UnitType.BatBasic);
    
    var _spider = hexMap.addTile(2, 0, TerrainType.Rock, 2);
    gameController.addUnit(_spider, UnitType.SpiderBasic);
    
    hexMap.paintTerrain(new HexVector(0, 0), new TerrainBrush(TerrainBrushShape.Hexagon, 4, 3, 1), randomTerrainGenerator);
}

createTrixagonPlayers = function() {
    gameController.addPlayer("Red", Colors.trixagonRed);
    gameController.addPlayer("Blue", Colors.trixagonBlue);
}

createTrixagonTestTiles = function() {
    hexMap.paintTerrain(new HexVector(0, 0), new TerrainBrush(TerrainBrushShape.Hexagon, 6, 1), trixagonTerrainGenerator);
    
    var _unitsPerSide = 6;
    var _sidesSeparation = 2; // if _sidesSeparation is 0 and _unitRandomRange is 0, you will only get red units
    var _unitRandomRange = 2; // if _unitRandomRange is 0, you will only get 2/3 of _unitsPerSide
    
    var _rockCount = 5;
    var _rocksRandomRange = 3;
    
    var _bombCount = 2;
    var _bombsRandomRange = 2;
    
    // red units
    var _q = -_sidesSeparation;
    var _rStart = -floor((_unitsPerSide - (_sidesSeparation - 2)) / 3);
    var _rDist = _unitsPerSide;
    var _player = gameController.players[? 1];
    
    for (var _r = _rStart; _r < _rStart + _rDist; _r++) {
        placeUnitNearPosition(_q, _r, _unitRandomRange, UnitType.TrixagonRed, 1, _player);
    }
    
    // blue units
    _q = _q + 2 * _sidesSeparation;
    _rStart = _rStart - _sidesSeparation;
    _player = gameController.players[? 2];
    
    for (var _r = _rStart; _r < _rStart + _rDist; _r++) {
        placeUnitNearPosition(_q, _r, _unitRandomRange, UnitType.TrixagonBlue, 4, _player);
    }
    
    // rocks
    for (var i = 0; i < _rockCount; i++) {
        placeUnitNearPosition(0, 0, _rocksRandomRange, UnitType.TrixagonRock);
    }
    
    // bombs
    for (var i = 0; i < _bombCount; i++) {
        placeUnitNearPosition(0, 0, _bombsRandomRange, UnitType.TrixagonBomb, 0, pointer_null, 2);
    }
    
    // rotate units to not face friends if possible
    var _unitCount = ds_list_size(gameController.units);
    
    for (var _index = 0; _index < _unitCount; _index++) {
        var _unit = gameController.units[| _index];
        var _facingFriend = true;
        
        for (var _tries = 3; _tries > 0; _tries--) {
            var _facingUnit = _unit.getUnitInFrontOfMe();
            
            if (!_facingUnit) {
                break;
            }
            
            _facingFriend = _unit.type.typeId == _facingUnit.type.typeId;
            
            if (_facingFriend) {
                _unit.rotateFacing(-2);
            } else {
                break;
            }
        }
    }
}

placeUnitNearPosition = function (_q, _r, _range, _unitType, _facing = 0, _player = pointer_null, _spread = 0) {
    for(var _tries = 32; _tries > 0; _tries--) {
        var _tile = hexMap.getTileQR(_q + irandom_range(-_range, _range), _r + irandom_range(-_range, _range));
        var _valid = false;
    
        if (_tile && ds_list_size(_tile.units) == 0) {
            _valid = !hexMap.findNearestUnitOfTypeInRange(_tile.position, _unitType, _spread, false);
        }
        
        if (_valid) {
            var _unit = gameController.addUnit(_tile, _unitType);
            _unit.updateFacing(_facing);
            
            if (_player) {
                _player.addUnit(_unit);
            }
            
            return _unit;
        } 
    }
    
    return pointer_null;
}

if (gameController.trixagon.active) {
    createTrixagonPlayers();
    createTrixagonTestTiles();
} else {
    createTrixagonPlayers();
    createTestTiles();
}

createDirectionTestTiles = function() {
    var _dirs = global.hexDirections;

    hexMap.addTile(_dirs[0].q, _dirs[0].r, TerrainType.Snow, 1);
    hexMap.addTile(_dirs[1].q, _dirs[1].r, TerrainType.Water, 2);
    hexMap.addTile(_dirs[2].q, _dirs[2].r, TerrainType.Rock, 3);
    hexMap.addTile(_dirs[3].q, _dirs[3].r, TerrainType.Sand, 1);
    hexMap.addTile(_dirs[4].q, _dirs[4].r, TerrainType.Rock, 2);
    hexMap.addTile(_dirs[5].q, _dirs[5].r, TerrainType.Grass, 3);
}

// createDirectionTestTiles();

gameController.init();

testInitiativeSystem = function () {
    while (gameController.roundCounter <= gameController.rules.initiativeThreshold) {
        gameController.endUnitTurn();
    }
}

// testInitiativeSystem();