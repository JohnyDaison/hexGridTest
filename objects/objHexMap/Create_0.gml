tileSize = new Vector(160, 150); // tuned to our sprites
startPosition = new Vector(room_width/2, room_height/2);
debugText = "TEST";

gameController = new GameController();
hexMap = gameController.createMap(layout_flat, tileSize, startPosition);

cursorHex = undefined;
cursorPos = undefined;
cursorTile = pointer_null;
selectedUnit = pointer_null;
unitTargetTile = pointer_null;

activeTerrainBrush = new TerrainBrush(TerrainBrushShape.Hexagon, 2, 1);
terrainGeneratorOptions = { height: true };
lastPaintedPos = undefined;

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