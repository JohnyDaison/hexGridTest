tileSize = new Vector(160, 150); // tuned to our sprites
startPosition = new Vector(room_width/2, room_height/2);
debugText = "TEST";

hexMap = new HexMap(layout_flat, tileSize, startPosition);
hexMap.stackHeight = 60;

selectedHex = undefined;
selectedUnit = pointer_null;
moveTargetTile = undefined;

createTestTiles = function() {
    var _swordSkeleton = hexMap.addTile(-1, 0, TerrainType.Snow);
    hexMap.addUnit(_swordSkeleton, UnitType.SkeletonSwordBasic);

    var _bowSkeleton = hexMap.addTile(-1, 1, TerrainType.Snow, 3);
    hexMap.addUnit(_bowSkeleton, UnitType.SkeletonBowBasic);
    
    var _water = hexMap.addTile(0, -1, TerrainType.Water, 2);
    
    var _center = hexMap.addTile(0, 0, TerrainType.Rock, 3);
    hexMap.addUnit(_center, UnitType.KnightUnarmedBasic);
    
    var _swordKnight = hexMap.addTile(0, 1, TerrainType.Sand, 2);
    hexMap.addUnit(_swordKnight, UnitType.KnightSwordBasic);

    var _bowKnight = hexMap.addTile(1, -1, TerrainType.Grass);
    hexMap.addUnit(_bowKnight, UnitType.KnightBowBasic);
    
    var _dummy = hexMap.addTile(1, 0, TerrainType.Grass);
    hexMap.addUnit(_dummy, UnitType.TrainingDummy);
    
    var _bat = hexMap.addTile(2, -1, TerrainType.Sand, 3);
    hexMap.addUnit(_bat, UnitType.BatBasic);
    
    var _spider = hexMap.addTile(2, 0, TerrainType.Rock, 2);
    hexMap.addUnit(_spider, UnitType.SpiderBasic);
}

createTestTiles();