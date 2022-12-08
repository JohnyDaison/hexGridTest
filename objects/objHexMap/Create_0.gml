tileSize = new Vector(160, 150); // tuned to our sprites
startPosition = new Vector(room_width/2, room_height/2);

hexMap = new HexMap(layout_flat, tileSize, startPosition);
hexMap.stackHeight = 60;

// test tiles
var center = hexMap.grid.addTile(new HexVector(0, 0));
center.setTerrainType(TerrainType.Rock);
center.height = 3;

var a = hexMap.grid.addTile(new HexVector(1, 0));
a.setTerrainType(TerrainType.Grass);

var b = hexMap.grid.addTile(new HexVector(0, 1));
b.setTerrainType(TerrainType.Sand);
b.height = 2;

var c = hexMap.grid.addTile(new HexVector(-1, 0));
c.setTerrainType(TerrainType.Snow);

var d = hexMap.grid.addTile(new HexVector(0, -1));
d.setTerrainType(TerrainType.Water);
d.height = 3;

var e = hexMap.grid.addTile(new HexVector(-1, 1));
e.setTerrainType(TerrainType.Snow);
e.height = 3;

hexMap.grid.addTile(new HexVector(1, -1));