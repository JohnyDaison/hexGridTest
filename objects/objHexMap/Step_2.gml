/// @description ANIMATIONS, DEBUG TEXT

// ANIMATIONS
gameController.gameUpdate();
gameController.animationUpdate();

// DEBUG TEXT
debugText = "";
debugText += string("FPS {0} | {1}\n", fps, string_format(fps_real, 3, 0));

debugText += string("Zoom: {0}\n", objGameCamera.zoomLevel);

if (!is_undefined(cursorHex)) {
    debugText += string("Hex {0}", cursorHex);
    debugText += string(": {0}", cursorTile);
} else {
    debugText += string("Pos {0}", cursorPos);
}

var _selectedUnit = gameController.selectedUnit;
var _unitTargetTile = gameController.unitTargetTile;

debugText += "\n\n";
debugText += string("{0}\n", string(_selectedUnit));

if (_selectedUnit != pointer_null) {
    debugText += string("Target tile: {0} {1}", _unitTargetTile ? string(_unitTargetTile.position) : "", string(_unitTargetTile));
    debugText += "\n";
    
    debugText += "Actions:\n";
    if (_selectedUnit.currentAction != pointer_null) {
        debugText += string(_selectedUnit.currentAction) + "\n";
        debugText += "----------" + "\n";
    }
    
    var _actionCount = ds_list_size(_selectedUnit.actionQueue);
    for(var i = 0; i < _actionCount; i++) {
        var _action = _selectedUnit.actionQueue[| i];
        debugText += string(_action) + "\n";
    }

    debugText += "\n";
}