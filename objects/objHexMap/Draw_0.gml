// test drawHexBg
//draw_set_color(c_red);
//draw_set_alpha(0.5);
//hexMap.drawHexBg();

debugText = string("{0} ", objGameCamera.zoomLevel);

var _highlightHex = selectedHex;
if (!is_undefined(_highlightHex)) {
    debugText += string("Hex {0},{1}",_highlightHex.q, _highlightHex.r);

    var _hexTile = hexMap.grid.getTile(_highlightHex);
    if (!is_undefined(_hexTile)) {
        debugText += string(": {0}", ds_list_size(_hexTile.neighbors));
    }
} else {
    var _hexPos = hexMap.pixelToHex(mouse_x, mouse_y);
    debugText += string("Pos {0},{1}",_hexPos.q, _hexPos.r);
}

debugText += "\n";
debugText += string("{0} {1}", string(selectedUnit), string(moveTargetTile));

var _movementTile = undefined;
if (selectedUnit != pointer_null) {
    _movementTile = selectedUnit.myTile;
}

hexMap.drawHexes(_highlightHex, _movementTile);

draw_sprite(sprCrosshair, 0, mouse_x, mouse_y);

// show tileSize as rectangle
/*
draw_set_alpha(0.8);
draw_set_color(c_red);
draw_rectangle(startPosition.x - tileSize.x, startPosition.y - tileSize.y, startPosition.x + tileSize.x, startPosition.y + tileSize.y, true);
*/