hexMap.unitsAnimUpdate();

cursorHex = hexMap.cursorToHex(mouse_x, mouse_y);
cursorPos = hexMap.pixelToHex(mouse_x, mouse_y);
cursorTile = undefined;
var _paintPos = cursorPos;

if (!is_undefined(cursorHex)) {
    cursorTile = hexMap.grid.getTile(cursorHex);
    _paintPos = cursorHex;
}

if (mouse_check_button(mb_right)) {
    if (is_undefined(lastPaintedPos) || !_paintPos.equals(lastPaintedPos)) {
        hexMap.paintTerrain(_paintPos, activeTerrainBrush, randomTerrainGenerator, terrainGeneratorOptions);
        lastPaintedPos = _paintPos;
    }
} else {
    lastPaintedPos = undefined;
}

if (selectedUnit != pointer_null && moveTargetTile != pointer_null) {
    hexMap.displaceUnit(selectedUnit);
    hexMap.placeUnit(moveTargetTile, selectedUnit);
    
    selectedUnit = pointer_null;
    moveTargetTile = pointer_null;
}
