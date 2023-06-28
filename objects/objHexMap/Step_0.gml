cursorLastTile = cursorTile;

cursorHex = hexMap.cursorToHex(mouse_x, mouse_y);
cursorPos = hexMap.pixelToHex(mouse_x, mouse_y);
cursorTile = pointer_null;
var _paintPos = cursorPos;

if (!is_undefined(cursorHex)) {
    cursorTile = hexMap.getTile(cursorHex);
    _paintPos = cursorHex;
}

if (cursorTile != cursorLastTile) {
    if (cursorLastTile) {
        gameController.handleTileHoverEnd(cursorLastTile);
    }

    if (cursorTile) {
        gameController.handleTileHoverStart(cursorTile);
    }
}

if (mouse_check_button(mb_right)) {
    if (is_undefined(lastPaintedPos) || !_paintPos.equals(lastPaintedPos)) {
        hexMap.paintTerrain(_paintPos, activeTerrainBrush, mainTerrainGenerator, terrainGeneratorOptions);
        lastPaintedPos = _paintPos;
    }
} else {
    lastPaintedPos = undefined;
}

cursorPulseCurrent = clamp(cursorPulseCurrent + cursorPulseDirection * cursorPulseSpeed, cursorPulseMin, cursorPulseMax);

if (cursorPulseDirection == 1 && cursorPulseCurrent == cursorPulseMax) {
    cursorPulseDirection = -1;
}

if (cursorPulseDirection == -1 && cursorPulseCurrent == cursorPulseMin) {
    cursorPulseDirection = 1;
}
