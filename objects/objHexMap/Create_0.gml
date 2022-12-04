tileSize = new Vector(160, 150); // tuned to our sprites
startPosition = new Vector(room_width/2, room_height/2);

hexMap = new HexMap(layout_flat, tileSize, startPosition);

// test tiles
hexMap.grid.addTile(new HexVector(0, 0));

hexMap.grid.addTile(new HexVector(2, 0));
hexMap.grid.addTile(new HexVector(0, 2));

hexMap.grid.addTile(new HexVector(-2, 0));
hexMap.grid.addTile(new HexVector(0, -2));

hexMap.grid.addTile(new HexVector(-2, 2));
hexMap.grid.addTile(new HexVector(2, -2));