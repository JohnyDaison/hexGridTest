tileSize = new Vector(160, 150); // tuned to our sprites
startPosition = new Vector(room_width/2, room_height/2);

hexMap = new HexMap(layout_flat, tileSize, startPosition);

// test tiles
var center = hexMap.grid.addTile(new HexVector(0, 0));
center.setTerrainType(TerrainType.Rock);
var a = hexMap.grid.addTile(new HexVector(1, 0));
a.setTerrainType(TerrainType.Grass);
var b = hexMap.grid.addTile(new HexVector(0, 1));
b.setTerrainType(TerrainType.Sand);
var c = hexMap.grid.addTile(new HexVector(-1, 0));
c.setTerrainType(TerrainType.Snow);
var d = hexMap.grid.addTile(new HexVector(0, -1));
d.setTerrainType(TerrainType.Water);
var e = hexMap.grid.addTile(new HexVector(-1, 1));
e.setTerrainType(TerrainType.Snow);
hexMap.grid.addTile(new HexVector(1, -1));