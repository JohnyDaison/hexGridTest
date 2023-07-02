/// @description ANIMATIONS, DEBUG TEXT

if (clearPlanButton == noone && !gameController.trixagon.active) {
    var _xPos = objGameCamera.baseViewportWidth - clearPlanButtonMargin;
    var _yPos = objGameCamera.baseViewportHeight - endTurnButtonMargin;
    
    clearPlanButton = instance_create_layer(_xPos, _yPos, "GUI", objBasicSpriteButton);
    clearPlanButton.sprite_index = sprClearPlanButton;
    
    clearPlanButton.onClick = method(self, function () {
        gameController.clearUnitPlan();
    });
}

if (endTurnButton == noone) {
    var _xPos = objGameCamera.baseViewportWidth - endTurnButtonMargin;
    var _yPos = objGameCamera.baseViewportHeight - endTurnButtonMargin;
    
    endTurnButton = instance_create_layer(_xPos, _yPos, "GUI", objEndTurnButton);
    
    endTurnButton.onClick = method(self, function () {
        gameController.endTurnButtonPressed = true;
    });
}

// ANIMATIONS
gameController.gameUpdate();
gameController.animationUpdate();

if (!gameController.trixagon.active) {
    clearPlanButton.enabled = gameController.canPlanBeCleared();
}
endTurnButton.enabled = gameController.canTurnBeEnded();

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
debugText += "\n";

debugText += string("Round: {0}\n", gameController.roundCounter);

debugText += string("Phase: {0}\n", gameController.currentTurnPhase);

var _selectedUnit = gameController.selectedUnit;
var _unitTargetTile = gameController.unitTargetTile;

debugText += "\n";
debugText += string("{0}\n", string(_selectedUnit));

if (_selectedUnit != pointer_null) {
    debugText += string("Action points: {0}/{1}", string(_selectedUnit.actionPoints - _selectedUnit.actionPointsUsed), string(_selectedUnit.actionPoints));
    debugText += "\n";
    debugText += string("Target tile: {0} {1}", _unitTargetTile ? string(_unitTargetTile.position) : "", string(_unitTargetTile));
    debugText += "\n";
    
    debugText += "Actions:\n";
    if (_selectedUnit.currentAction != pointer_null) {
        debugText += string(_selectedUnit.currentAction) + "\n";
        debugText += "----------" + "\n";
    }
    
    var _actionCount = ds_list_size(_selectedUnit.actionQueue);
    for (var i = 0; i < _actionCount; i++) {
        var _action = _selectedUnit.actionQueue[| i];
        debugText += string(_action) + "\n";
    }

    debugText += "\n";
}