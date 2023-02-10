// test drawHexBg
//draw_set_color(c_red);
//draw_set_alpha(0.5);
//hexMap.drawHexBg();

var _highlightHex = cursorHex;
var _movementTile = pointer_null;
if (selectedUnit != pointer_null && selectedUnit.currentAction == pointer_null) {
    _movementTile = selectedUnit.currentTile;
}

hexMap.drawHexes(_highlightHex, _movementTile);

draw_sprite(sprCrosshair, 0, mouse_x, mouse_y);

// show tileSize as rectangle
/*
draw_set_alpha(0.8);
draw_set_color(c_red);
draw_rectangle(startPosition.x - tileSize.x, startPosition.y - tileSize.y, startPosition.x + tileSize.x, startPosition.y + tileSize.y, true);
*/