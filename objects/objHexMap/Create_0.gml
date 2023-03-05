tileSize = new Vector(160, 150); // tuned to our sprites
endTurnButtonMargin = 30;

var _halfRoomWidth = room_width / 2;
var _halfRoomHeight = room_height / 2;
startPosition = new Vector(_halfRoomWidth, _halfRoomHeight);
debugText = "TEST";

gameController = new GameController();
hexMap = gameController.createMap(layout_flat, tileSize, startPosition);

endTurnButton = noone;

cursorHex = undefined;
cursorPos = undefined;
cursorTile = pointer_null;

activeTerrainBrush = new TerrainBrush(TerrainBrushShape.Hexagon, 2, 1);
terrainGeneratorOptions = { height: true };
lastPaintedPos = undefined;

handleTap = function() {
    if (is_undefined(cursorHex)) {
        exit;
    }

    gameController.handleTileClicked(cursorTile);
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

createTestTiles();

gameController.init();

testInitiativeSystem = function () {
    var _testCount = 1000;
    for(var i = 0; i < _testCount; i++) {
        gameController.endUnitTurn();
    }
}

// testInitiativeSystem();