hexMap.unitsAnimUpdate();

cursorHex = hexMap.cursorToHex(mouse_x, mouse_y);
cursorPos = hexMap.pixelToHex(mouse_x, mouse_y);
cursorTile = undefined;

if (!is_undefined(cursorHex)) {
    cursorTile = hexMap.grid.getTile(cursorHex);
    
    if (mouse_check_button_pressed(mb_left)) {
        if (selectedUnit == pointer_null) {
            selectedUnit = cursorTile.unit;
        } else if (cursorTile.unit == pointer_null) {
            moveTargetTile = cursorTile;
        } else if (cursorTile.unit == selectedUnit) {
            selectedUnit = pointer_null;
        }
    }
}

if (selectedUnit != pointer_null && moveTargetTile != pointer_null) {
    hexMap.displaceUnit(selectedUnit);
    hexMap.placeUnit(moveTargetTile, selectedUnit);
    
    selectedUnit = pointer_null;
    moveTargetTile = pointer_null;
}
