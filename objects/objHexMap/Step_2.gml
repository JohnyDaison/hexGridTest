/// @description ANIMATIONS, DEBUG TEXT

// ANIMATIONS
hexMap.gameUpdate();
hexMap.animationUpdate();

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

debugText += "\n\n";
debugText += string("{0}\n", string(selectedUnit));

if (selectedUnit != pointer_null) {
    debugText += string("Target tile: {0} {1}", unitTargetTile ? string(unitTargetTile.position) : "", string(unitTargetTile));
    debugText += "\n";
    
    debugText += "Actions:\n";
    if (selectedUnit.currentAction != pointer_null) {
        debugText += string(selectedUnit.currentAction) + "\n";
        debugText += "----------" + "\n";
    }
    
    var _actionCount = ds_list_size(selectedUnit.actionQueue);
    for(var i = 0; i < _actionCount; i++) {
        var _action = selectedUnit.actionQueue[| i];
        debugText += string(_action) + "\n";
    }

    debugText += "\n";
}