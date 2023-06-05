function GameController() constructor {
    players = ds_map_create();
    playerCount = 0;
    units = ds_list_create();
    gameAnimations = ds_list_create();
    hexMap = pointer_null;
    selectedUnit = pointer_null;
    unitTargetTile = pointer_null;
    endTurnButtonPressed = false;
    roundCounter = 1;
    activePlayer = pointer_null;
    playerTurnIsEnding = false;
    unitQueue = new UnitQueue(self);
    
    playerListDisplay = {
        margin: 12,
        lineHeight: 60,
        outlineWidth: 4,
        position: new Vector(0,0),
        size: new Vector(0,0),
        font: fontPlayerList,
    }
    
    rules = {
        alternatePlayerTurns: false,
        useUnitQueue: true,
        otherActionsChangeFacing: true,
        planForFutureTurns: true,
        
        initiativeThreshold: 60,
    }
    
    trixagon = {
        active: true,
        highAttackChance: 0.7,
        lowAttackChance: 0.4
    }
    
    if (trixagon.active) {
        rules.alternatePlayerTurns = true;
        rules.useUnitQueue = false;
        rules.otherActionsChangeFacing = false;
        rules.planForFutureTurns = false;
        
        objGameCamera.updateZoomLevel(objGameCamera.maxZoomLevel);
    }
    
    static destroy = function() {
        destroyMap();
        unitQueue.destroy();

        ds_list_destroy(gameAnimations);
        ds_list_destroy(units);
        ds_map_destroy(players);
    }
    
    static init = function() {
        unitsRoundStart();
        unitQueue.init();
        
        if (rules.alternatePlayerTurns && !activePlayer) {
            selectNextPlayer();
        }
        
        if (rules.useUnitQueue) {
            selectedUnit = unitQueue.activeUnit;
        }
    }
    
    static createMap = function (_orientation, _size, _origin) {
        if (hexMap != pointer_null) {
            return pointer_null;
        }
        
        hexMap = new HexMap(_orientation, _size, _origin);
        hexMap.gameController = self;
        hexMap.stackHeight = 60;
        
        return hexMap;
    }
    
    static destroyMap = function() {
        hexMap.destroy();
        hexMap = pointer_null;
        
        var _gameAnimationCount = ds_list_size(gameAnimations);
        for (var i = _gameAnimationCount - 1; i >= 0; i--) {
            var _gameAnimation = gameAnimations[| i];
            _gameAnimation.destroy();
            delete _gameAnimation;
        }
        
        ds_list_clear(gameAnimations);
        
        var _unitCount = ds_list_size(units);
        for (var i = 0; i < _unitCount; i++) {
            var _unit = units[| i];
            _unit.destroy();
            delete _unit;
        }
        
        ds_list_clear(units);
    }
    
    static addPlayer = function(_name, _color) {
        var _number = playerCount + 1;
        var _player = new Player(_number, _name, _color);
        
        _player.gameController = self;
        _player.hexMap = hexMap;
        
        players[? _number] = _player;
        playerCount++;
        
        updatePlayerListDisplay();
        
        return _player;
    }
    
    static addUnit = function(_hexTile, _unitType) {
        var _unit = new Unit(_unitType);
        ds_list_add(units, _unit);
        _unit.gameController = self;
        _unit.hexMap = hexMap;
        
        hexMap.placeUnit(_hexTile, _unit);
        
        if (rules.useUnitQueue) {
            unitQueue.addUnit(_unit);
        }
        
        return _unit;
    }
    
    /**
     * Remove unit from the game permanently
     * @param {Struct.Unit} _unit
     * @returns {bool} success
     */
    static deleteUnit = function(_unit) {
        if (selectedUnit == _unit) {
            endUnitTurn();
        }
        
        hexMap.displaceUnit(_unit);
        
        _unit.destroy();
        
        ds_list_delete(units, ds_list_find_index(units, _unit));
        
        return true;
    }
    
    static animationUpdate = function () {
        gameAnimationsUpdate();
        unitsAnimUpdate();
    }
    
    static unitsAnimUpdate = function () {
        var _unitCount = ds_list_size(units);
        
        for (var i = 0; i < _unitCount; i++) {
            var _unit = units[| i];
            
            _unit.animUpdate();
        }
    }
    
    static gameAnimationsUpdate = function () {
        var _gameAnimationCount = ds_list_size(gameAnimations);
        
        for (var i = _gameAnimationCount - 1; i >= 0; i--) {
            var _gameAnimation = gameAnimations[| i];
            
            _gameAnimation.update();
        }
    }
    
    static gameUpdate = function () {
        if (endTurnButtonPressed) {
            if (selectedUnit != pointer_null && selectedUnit.currentAction == pointer_null) {
                selectedUnit.startNextAction();
            }
            
            if (selectedUnit == pointer_null || selectedUnit.currentAction == pointer_null) {
                endTurnButtonPressed = false;
                endUnitTurn();
            }
        }
        
        if (playerTurnIsEnding) {
            if (trixagon.active) {
                var _state = {totalActive: 0};
                
                array_foreach(activePlayer.units, method(_state, function (_unit) {
                    if (_unit.currentAction != pointer_null) {
                        totalActive++;
                    }
                }));
                
                if (_state.totalActive == 0) {
                    startPlayerTurn();
                }
            }
        }
        
        var _unitCount = ds_list_size(units);
        
        for (var i = _unitCount - 1; i >= 0; i--) {
            var _unit = units[| i];
            
            if (_unit.dead) {
                deleteUnit(_unit);
            }
        }
        
        _unitCount = ds_list_size(units);
        
        for (var i = 0; i < _unitCount; i++) {
            var _unit = units[| i];
            
            _unit.handleCurrentAction();
        }
        
        unitQueue.updateCards();
    }
    
    static canUnitBeSelected = function (_unit) {
        if (!_unit || _unit.dying) {
            return false;
        }
        
        if (activePlayer && _unit.player != activePlayer) {
            return false;
        }
        
        return true;
    }
    
    static canUnitBeDeselected = function (_unit) {
        if (rules.alternatePlayerTurns && _unit.tookActionThisRound) {
            return false;
        }
        
        return true;
    }
    
    static handleTileClicked = function (_cursorTile) {
        var _cursorUnit = _cursorTile.getTopUnit();
        
        if (rules.useUnitQueue) {
            unitTargetTile = pointer_null;
            if (_cursorUnit != selectedUnit) {
                unitTargetTile = _cursorTile;
            }
        } else {
            if (selectedUnit == pointer_null) {
                if (canUnitBeSelected(_cursorUnit)) {
                    selectedUnit = _cursorUnit;
                    unitTargetTile = pointer_null;
                }
            } else if (_cursorUnit == selectedUnit) {
                if (canUnitBeDeselected(selectedUnit)) {
                    selectedUnit = pointer_null;
                    unitTargetTile = pointer_null;
                }
            } else {
                unitTargetTile = _cursorTile;
            }
        }
        
        if (selectedUnit != pointer_null && unitTargetTile != pointer_null) {
            var _planned = false;
    
            if (_cursorUnit != pointer_null && selectedUnit.combat.canAttack()) {
                if (!trixagon.active) {
                    _planned = selectedUnit.combat.planAttackOnHex(unitTargetTile.position);
                }
            } else {
                _planned = selectedUnit.movement.planMovementToHex(unitTargetTile.position);
            }
    
            if (_planned) {
                selectedUnit.startNextAction();
                selectedUnit.onPlanEnd = method(self, function () {
                    unitTargetTile = pointer_null;
                });
            }
        }
    }
    
    static handleTileDragged = function (_startTile, _endHex) {
        if (selectedUnit == pointer_null) {
            return;
        }
        
        if (!_startTile.position.equals(selectedUnit.nextPosition)) {
            handleTileClicked(_startTile);
        }
        
        if (selectedUnit.plannedFinalPosition.equals(_startTile.position)) {
            selectedUnit.movement.planFacingHex(_endHex);
            
            if (selectedUnit.currentAction == pointer_null) {
                selectedUnit.startNextAction();
            }
        }
    }
    
    static getActiveUnit = function () {
        return unitQueue.activeUnit;
    }
    
    static unitsRoundStart = function () {
        var _unitCount = ds_list_size(units);
        
        for (var i = 0; i < _unitCount; i++) {
            var _unit = units[| i];
            _unit.onRoundStart();
        }
    }
    
    static canPlanBeCleared = function () {
        if (endTurnButtonPressed) {
            return false;
        }
        
        if (selectedUnit != pointer_null && ds_list_size(selectedUnit.actionQueue) > 0) {
            return true;
        }
        
        return false;
    }
    
    static clearUnitPlan = function () {
        if (selectedUnit == pointer_null) {
            return;
        }
        
        selectedUnit.clearActionQueue();
    }
    
    static canTurnBeEnded = function () {
        if (selectedUnit != pointer_null && selectedUnit.currentAction != pointer_null) {
            return false;
        }
        
        if (playerTurnIsEnding) {
            return false;
        }
        
        return true;
    }
    
    static endUnitTurn = function () {
        show_debug_message("endUnitTurn called");
        
        if (selectedUnit != pointer_null) {
            selectedUnit.initiativeAccumulated -= rules.initiativeThreshold;
            selectedUnit.turnCounter++;
        }
        
        selectedUnit = pointer_null;
        unitTargetTile = pointer_null;
        
        if (rules.useUnitQueue) {
            unitQueue.update();
            selectedUnit = unitQueue.activeUnit;
        }
        
        if (rules.alternatePlayerTurns) {
            endPlayerTurn();
        }
        
        if (selectedUnit == pointer_null && !rules.alternatePlayerTurns) {
            endRound();
        }
    }
    
    static endRound = function () {
        show_debug_message("endRound called");
        
        roundCounter++;
        
        unitsRoundStart();
        if (rules.useUnitQueue) {
            endUnitTurn();
        }
    }
    
    static endPlayerTurn = function () {
        show_debug_message("endPlayerTurn called");
        
        if (trixagon.active && roundCounter > 1) {
            array_foreach(activePlayer.units, function (_unit) {
                _unit.combat.planTrixagonAttack();
                
                if (_unit.currentAction == pointer_null) {
                    _unit.startNextAction();
                }
            });
        }
        
        playerTurnIsEnding = true;
    }
    
    static startPlayerTurn = function () {
        endRound();
        playerTurnIsEnding = false;
        selectNextPlayer();
    }
    
    static selectNextPlayer = function () {
        if (activePlayer) {
            var _number = activePlayer.number;
            _number = _number == playerCount ? 1 : _number + 1;
            
            activePlayer = players[? _number];
        }
        
        if (playerCount > 0 && !activePlayer) {
            activePlayer = players[? 1];
        }
    }
    
    static updatePlayerListDisplay = function () {
        var _maxNameWidth = 0;
        draw_set_font(playerListDisplay.font);
        
        for (var i = 1; i <= playerCount; i++) {
            var _name = players[? i].name;
            var _width = string_width(_name);
            
            if (_width > _maxNameWidth) {
                _maxNameWidth = _width;
            }
        }
        
        playerListDisplay.size.x = _maxNameWidth;
        playerListDisplay.size.y = playerListDisplay.lineHeight * playerCount;
        
        playerListDisplay.position.x = objGameCamera.baseViewportWidth - playerListDisplay.margin - playerListDisplay.size.x;
        playerListDisplay.position.y = playerListDisplay.margin;
    }
    
    static drawPlayerListDisplay = function () {
        var _x = playerListDisplay.position.x;
        var _y = playerListDisplay.position.y;
        
        draw_set_alpha(1);
        
        for (var i = 1; i <= playerCount; i++) {
            var _player = players[? i];
            var _name = _player.name;
            var _color = _player.color;
            var _font = playerListDisplay.font;
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_font(_font);
            
            if (_player == activePlayer) {
                _color = merge_color(_color, c_white, 0.2);

                var _offset = playerListDisplay.outlineWidth;
                draw_set_color(c_white);
                
                draw_text(_x - _offset, _y, _name);
                draw_text(_x + _offset, _y, _name);
                draw_text(_x, _y + _offset, _name);
                draw_text(_x, _y - _offset, _name);
            }
            
            draw_set_color(_color);
            
            draw_text(_x, _y, _name);
            
            _y += playerListDisplay.lineHeight;
        }
    }

    static drawUnitQueue = function () {
        if (rules.useUnitQueue) {
            unitQueue.draw();
        }
    }
}