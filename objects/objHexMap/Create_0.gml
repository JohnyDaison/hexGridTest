randomize();
tileSize = new Vector(160, 150); // tuned to our sprites
clearPlanButtonMargin = 190;
endTurnButtonMargin = 30;

var _halfRoomWidth = room_width / 2;
var _halfRoomHeight = room_height / 2;
startPosition = new Vector(_halfRoomWidth, _halfRoomHeight);
debugText = "TEST";

gameController = new GameController();
var _layout = gameController.trixagon ? layout_pointy : layout_flat;
if (gameController.trixagon) {
    var _tempY = tileSize.y;
    tileSize.y = tileSize.x;
    tileSize.x = _tempY;
}
hexMap = gameController.createMap(_layout, tileSize, startPosition);

clearPlanButton = noone;
endTurnButton = noone;

cursorHex = undefined;
cursorPos = undefined;
cursorTile = pointer_null;

activeTerrainBrush = new TerrainBrush(TerrainBrushShape.Hexagon, 2, 1);
mainTerrainGenerator = randomTerrainGenerator;
terrainGeneratorOptions = { height: true };
lastPaintedPos = undefined;

if (gameController.trixagon) {
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
    var _swordSkeleton = hexMap.addTile(-1, 0, TerrainType.Snow);
    gameController.addUnit(_swordSkeleton, UnitType.SkeletonSwordBasic);

    var _bowSkeleton = hexMap.addTile(-1, 1, TerrainType.Snow, 3);
    gameController.addUnit(_bowSkeleton, UnitType.SkeletonBowBasic);
    
    var _water = hexMap.addTile(0, -1, TerrainType.Water, 2);
    
    var _center = hexMap.addTile(0, 0, TerrainType.Rock, 3);
    gameController.addUnit(_center, UnitType.KnightUnarmedBasic);
    
    var _swordKnight = hexMap.addTile(0, 1, TerrainType.Sand, 2);
    gameController.addUnit(_swordKnight, UnitType.KnightSwordBasic);

    var _bowKnight = hexMap.addTile(1, -1, TerrainType.Grass);
    gameController.addUnit(_bowKnight, UnitType.KnightBowBasic);
    
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
    var _sidesSeparation = 2; // if _sidesSeparation is 0 and _randomRange is 0, you will only get red units
    var _randomRange = 2; // if _randomRange is 0, you will only get 2/3 of _unitsPerSide
    
    // red units
    var _q = -_sidesSeparation;
    var _rStart = -floor((_unitsPerSide - (_sidesSeparation - 2)) / 3);
    var _rDist = _unitsPerSide;
    var _player = gameController.players[? 1];
    
    for (var _r = _rStart; _r < _rStart + _rDist; _r++) {
        placeUnitNearPosition(_q, _r, _randomRange, UnitType.TrixagonRed, 1, _player);
    }
    
    // blue units
    _q = _q + 2 * _sidesSeparation;
    _rStart = _rStart - _sidesSeparation;
    _player = gameController.players[? 2];
    
    for (var _r = _rStart; _r < _rStart + _rDist; _r++) {
        placeUnitNearPosition(_q, _r, _randomRange, UnitType.TrixagonBlue, 4, _player);
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

placeUnitNearPosition = function (_q, _r, _range, _unitType, _facing, _player) {
    for(var _tries = 10; _tries > 0; _tries--) {
        var _tile = hexMap.getTileQR(_q + irandom_range(-_range, _range), _r + irandom_range(-_range, _range));
    
        if (_tile && ds_list_size(_tile.units) == 0) {
            var _unit = gameController.addUnit(_tile, _unitType);
            _unit.updateFacing(_facing);
            _player.addUnit(_unit);
            
            return _unit;
        } 
    }
    
    return pointer_null;
}

if (gameController.trixagon) {
    createTrixagonPlayers();
    createTrixagonTestTiles();
} else {
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
    while (gameController.roundCounter <= gameController.initiativeThreshold) {
        gameController.endUnitTurn();
    }
}

// testInitiativeSystem();