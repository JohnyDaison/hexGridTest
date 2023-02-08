/// @description ANIMATIONS, DEBUG TEXT

// ANIMATIONS
hexMap.gameUpdate();
hexMap.animationUpdate();

// DEBUG TEXT
debugText = "";
debugText += string("{0} | {1}\n", fps, string_format(fps_real, 4, 0));

debugText += string("{0} ", objGameCamera.zoomLevel);

if (!is_undefined(cursorHex)) {
    debugText += string("Hex {0},{1}", cursorHex.q, cursorHex.r);
    debugText += string(": {0}", ds_list_size(cursorTile.neighbors));
} else {
    debugText += string("Pos {0},{1}", cursorPos.q, cursorPos.r);
}

debugText += "\n";
debugText += string("{0} {1}", string(selectedUnit), string(moveTargetTile));
debugText += "\n";

if (selectedUnit != pointer_null) {
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