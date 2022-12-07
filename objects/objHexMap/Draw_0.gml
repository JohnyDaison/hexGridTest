// test tile
//draw_set_color(c_white);
//draw_set_alpha(1);

//draw_sprite(sprGrassStack, 0, startPosition.x, startPosition.y);

// test drawHexBg
draw_set_color(c_red);

draw_set_alpha(1);
hexMap.drawHex();

//draw_set_alpha(0.5);
//hexMap.drawHexBg();

// show tileSize as rectangle
draw_set_alpha(0.8);
draw_rectangle(startPosition.x - tileSize.x, startPosition.y - tileSize.y, startPosition.x + tileSize.x, startPosition.y + tileSize.y, true);