hexMap.unitsAnimUpdate();

selectedHex = hexMap.cursorToHex(mouse_x, mouse_y);

if (!is_undefined(selectedHex)) {
    if (mouse_check_button_pressed(mb_left)) {
        var _hexTile = hexMap.grid.getTile(selectedHex);
        
        if (selectedUnit == pointer_null) {
            selectedUnit = _hexTile.unit;
        } else if (_hexTile.unit == pointer_null) {
            moveTargetTile = _hexTile;
        } else if (_hexTile.unit == selectedUnit) {
            selectedUnit = pointer_null;
        }
    }
}

if (selectedUnit != pointer_null && !is_undefined(moveTargetTile)) {
    var _originTile = selectedUnit.myTile;
    
    hexMap.displaceUnit(selectedUnit);
    hexMap.placeUnit(moveTargetTile, selectedUnit);
    
    selectedUnit = pointer_null;
    moveTargetTile = undefined;
}