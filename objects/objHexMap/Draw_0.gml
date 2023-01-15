// test drawHexBg
//draw_set_color(c_red);
//draw_set_alpha(0.5);
//hexMap.drawHexBg();

var _highlightHex = hexMap.pixelToHex(mouse_x, mouse_y);
debugText = string("{0},{1}",_highlightHex.q, _highlightHex.r);

var _hexTile = hexMap.grid.getTile(_highlightHex);
if (!is_undefined(_hexTile)) {
    debugText += string(": {0}", ds_list_size(_hexTile.neighbors));
}

hexMap.drawHexes(_highlightHex);

// show tileSize as rectangle
/*
draw_set_alpha(0.8);
draw_set_color(c_red);
draw_rectangle(startPosition.x - tileSize.x, startPosition.y - tileSize.y, startPosition.x + tileSize.x, startPosition.y + tileSize.y, true);
*/