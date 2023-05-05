cursorHex = hexMap.cursorToHex(mouse_x, mouse_y);
cursorPos = hexMap.pixelToHex(mouse_x, mouse_y);
cursorTile = pointer_null;
var _paintPos = cursorPos;

if (!is_undefined(cursorHex)) {
    cursorTile = hexMap.getTile(cursorHex);
    _paintPos = cursorHex;
}

if (mouse_check_button(mb_right)) {
    if (is_undefined(lastPaintedPos) || !_paintPos.equals(lastPaintedPos)) {
        hexMap.paintTerrain(_paintPos, activeTerrainBrush, mainTerrainGenerator, terrainGeneratorOptions);
        lastPaintedPos = _paintPos;
    }
} else {
    lastPaintedPos = undefined;
}
