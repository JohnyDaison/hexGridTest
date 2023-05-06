tileSize = new Vector(160, 150); // tuned to our sprites
clearPlanButtonMargin = 190;
endTurnButtonMargin = 30;

var _halfRoomWidth = room_width / 2;
var _halfRoomHeight = room_height / 2;
startPosition = new Vector(_halfRoomWidth, _halfRoomHeight);
debugText = "TEST";

gameController = new GameController();
hexMap = gameController.createMap(layout_flat, tileSize, startPosition);

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

createTrixagonTestTiles = function() {
    hexMap.paintTerrain(new HexVector(0, 0), new TerrainBrush(TerrainBrushShape.Hexagon, 6, 3, 1), trixagonTerrainGenerator);
    var _q = -2;
    var _rStart = -2;
    var _rDist = 6;
    var _tile;
    
    for (var _r = _rStart; _r < _rStart + _rDist; _r++) {
        _tile = hexMap.getTileQR(_q, _r);
    
        if (_tile) {
            var _unit = gameController.addUnit(_tile, UnitType.TrixagonRed);
            _unit.updateFacing(1);
        }
    }
    
    _q = _q + 4;
    _rStart = _rStart -2;
    for (var _r = _rStart; _r < _rStart + _rDist; _r++) {
        _tile = hexMap.getTileQR(_q, _r);
    
        if (_tile) {
            var _unit = gameController.addUnit(_tile, UnitType.TrixagonBlue);
            _unit.updateFacing(4);
        }
    }
}

if (gameController.trixagon) {
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