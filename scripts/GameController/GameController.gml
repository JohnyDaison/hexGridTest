function GameController() constructor {
    players = ds_map_create();
    playerCount = 0;
    units = ds_list_create();
    gameAnimations = ds_list_create();
    hexMap = pointer_null;
    selectedUnit = pointer_null;
    hoveredUnit = pointer_null;
    unitTargetTile = pointer_null;
    endTurnButtonPressed = false;
    roundCounter = 1;
    activePlayer = pointer_null;
    unitQueue = new UnitQueue(self);
    winner = pointer_null;
    gameEnding = false;
    gameEnded = false;
    gameEndCounter = 0;
    inited = false;
    
    turnPhases = [];
    turnPhaseCount = 0;
    currentTurnPhaseIndex = -1;
    currentTurnPhase = pointer_null;
    
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
        randomizeStartingPlayer: false,
        useUnitQueue: true,
        otherActionsChangeFacing: true,
        planForFutureTurns: true,
        
        initiativeThreshold: 60,
        gameEndDelay: 60
    }
    
    trixagon = {
        active: true,
        highAttackChance: 0.7,
        lowAttackChance: 0.4,
        stripeBlockedTiles: true,
        hideBlockedTiles: false,
        meleeTargetAlpha: 0.9,
        rangedTargetAlpha: 0.75,
    }
    
    if (trixagon.active) {
        rules.alternatePlayerTurns = true;
        rules.randomizeStartingPlayer = true;
        rules.useUnitQueue = false;
        rules.otherActionsChangeFacing = false;
        rules.planForFutureTurns = false;
        
        self.addTurnPhase(PhaseType.TrixagonMovement);
        self.addTurnPhase(PhaseType.TrixagonMelee);
        self.addTurnPhase(PhaseType.TrixagonRanged);
        
        objGameCamera.updateZoomLevel(objGameCamera.maxZoomLevel);
    } else {
        self.addTurnPhase(PhaseType.HexagonGeneral);
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
        startNextTurnPhase();
        
        if (rules.alternatePlayerTurns && !activePlayer) {
            var _startingPlayerNumber = 1;
            
            if (rules.randomizeStartingPlayer) {
                _startingPlayerNumber = irandom_range(1, playerCount);
            }
            
            selectPlayerByNumber(_startingPlayerNumber);
        }
        
        if (rules.useUnitQueue) {
            selectUnit(unitQueue.activeUnit);
        }
    }
    
    static createMap = function (_orientation, _size, _origin) {
        if (hexMap != pointer_null) {
            return pointer_null;
        }
        
        hexMap = new HexMap(_orientation, _size, _origin);
        hexMap.gameController = self;
        hexMap.stackHeight = 60;
        
        if (trixagon.active) {
            hexMap.addTileOverlay("tint", 0);
            hexMap.addTileOverlay("stripes", -1);
            hexMap.addTileOverlay("meleeTarget", -2);
            hexMap.addTileOverlay("rangedTarget", -3);
            
            hexMap.addTileOverlayGroup("movement");
            hexMap.addTileOverlayGroup("combat");
            hexMap.addTileOverlayGroup("bomb");
        }
        
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
    
    static addTurnPhase = function(_phaseType) {
        var _phaseConstructor = global.phaseTypeMap[? _phaseType];
        var _phase = new _phaseConstructor(self);
        
        _phase.onEnd = method(self, self.phaseEnded);
        
        array_push(turnPhases, _phase);
        turnPhaseCount++;
        
        return _phase;
    }
    
    static phaseEnded = function (_phase) {
        if (_phase == currentTurnPhase) {
            startNextTurnPhase();
        }
    }
    
    static startNextTurnPhase = function () {
        currentTurnPhaseIndex++;
        if (currentTurnPhaseIndex >= turnPhaseCount) {
            currentTurnPhaseIndex = 0;
            
            array_foreach(turnPhases, function (_phase) {
                _phase.reset();
            });
            
            endTurn();
        }
        
        currentTurnPhase = turnPhases[currentTurnPhaseIndex];
        currentTurnPhase.startPhase();
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
    
    static getPlayer = function(_number) {
        return players[? _number];
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
    
    static getUnitsByType = function (_unitType) {
        var _result = [];
        var _unitCount = ds_list_size(units);
        
        for (var i = 0; i < _unitCount; i++) {
            var _unit = units[| i];
            if (_unit.type.typeId == _unitType) {
                array_push(_result, _unit);
            }
        }
        
        return _result;
    }
    
    static selectUnit = function (_unit) {
        if (!_unit) {
            selectedUnit = pointer_null;
            setActivePlayer(pointer_null);
            
            return;
        }
        
        selectedUnit = _unit;
        setActivePlayer(_unit.player);
    }
    
    static deselectUnit = function () {
        selectedUnit = pointer_null;
        unitTargetTile = pointer_null;
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
        if (!inited) {
            init();
            inited = true;
        }
        
        if (endTurnButtonPressed) {
            if (selectedUnit != pointer_null && selectedUnit.currentAction == pointer_null) {
                selectedUnit.startNextAction();
            }
            
            if (selectedUnit == pointer_null || selectedUnit.currentAction == pointer_null) {
                endTurnButtonPressed = false;
                currentTurnPhase.endPhase();
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
        
        if (gameEnded) {
            return;
        }
        
        if (gameEnding) {
            gameEndCounter++;
            
            if (gameEndCounter >= rules.gameEndDelay) {
                gameEnded = true;
            }
        }
        
        unitQueue.updateCards();
        updatePlayersWinLossState();
        
        if (trixagon.active) {
            hexMap.updateTileOverlays();
        }
        
        if (!gameEnding) {
            currentTurnPhase.update();
        }
    }
    
    static canUnitBeSelected = function (_unit) {
        if (gameEnding || gameEnded) {
            return false;
        }
        
        if (!currentTurnPhase.interactive) {
            return false;
        }
        
        if (!_unit || _unit.dying) {
            return false;
        }
        
        if (_unit != selectedUnit && !canUnitSelectionChange()) {
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
    
    static canUnitSelectionChange = function () {
        return selectedUnit == pointer_null || canUnitBeDeselected(selectedUnit);
    }
    
    static handleTileHoverStart = function (_cursorTile) {
        hoveredUnit = _cursorTile.getTopUnit();
    }
    
    static handleTileHoverEnd = function (_cursorTile) {
        hoveredUnit = pointer_null;
    }
    
    static handleTileClicked = function (_cursorTile) {
        var _cursorUnit = _cursorTile.getTopUnit();
        
        if (rules.useUnitQueue) {
            unitTargetTile = pointer_null;
            if (_cursorUnit != selectedUnit) {
                unitTargetTile = _cursorTile;
            }
        } else {
            if (_cursorUnit && _cursorUnit != selectedUnit) {
                if (canUnitBeSelected(_cursorUnit)) {
                    selectedUnit = _cursorUnit;
                    unitTargetTile = pointer_null;
                }
            } else if (_cursorUnit && _cursorUnit == selectedUnit) {
                if (canUnitBeDeselected(_cursorUnit)) {
                    deselectUnit();
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
        
        if (!currentTurnPhase.interactive) {
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
        
        if (!currentTurnPhase.interactive) {
            return false;
        }
        
        if (trixagon.active && selectedUnit != pointer_null && selectedUnit.facingUncertain) {
            return false;
        }
        
        return true;
    }
    
    static endTurn = function () {
        if (rules.alternatePlayerTurns) {
            startNextPlayerTurn();
        } else if (rules.useUnitQueue) {
            endUnitTurn();
        }
    }
    
    // for use with rules.useUnitQueue
    static endUnitTurn = function () {
        show_debug_message("endUnitTurn called");
        
        if (selectedUnit != pointer_null) {
            selectedUnit.initiativeAccumulated -= rules.initiativeThreshold;
            selectedUnit.turnCounter++;
        }
        
        deselectUnit();
        
        unitQueue.update();
        selectUnit(unitQueue.activeUnit);
            
        if (selectedUnit == pointer_null) {
            endRound();
        }
    }
    
    static endRound = function () {
        show_debug_message("endRound called");
        
        updatePlayersWinLossState();
        
        if (gameEnding) {
            return;
        }
        
        roundCounter++;
        
        unitsRoundStart();
        if (rules.useUnitQueue) {
            endUnitTurn();
        }
    }
    
    static startNextPlayerTurn = function () {
        endRound();
        
        if (gameEnding) {
            return;
        }
        
        selectNextPlayer();
    }
    
    static selectNextPlayer = function () {
        if (activePlayer) {
            var _number = activePlayer.number;
            _number = _number == playerCount ? 1 : _number + 1;
            
            setActivePlayer(players[? _number]);
        }
        
        if (playerCount > 0 && !activePlayer) {
            setActivePlayer(players[? 1]);
        }
    }
    
    static selectPlayerByNumber = function (_number) {
        if (playerCount >= _number) {
            setActivePlayer(players[? _number]);
        }
    }
    
    static setActivePlayer = function (_player) {
        if (activePlayer == _player) {
            return;
        }
        
        activePlayer = _player;
        
        if (activePlayer && trixagon.active && instance_exists(objEndTurnButton)) {
            if (activePlayer.name == "Red") {
                objEndTurnButton.sprite_index = sprEndTurnButton;
            } else if (activePlayer.name == "Blue") {
                objEndTurnButton.sprite_index = sprEndTurnButtonBlue;
            }
        }
    }
    
    static updatePlayersWinLossState = function () {
        var _allLost = true;
        var _someoneWon = false;
        
        for (var i = 1; i <= playerCount; i++) {
            var _player = getPlayer(i);
            _player.checkLossCondition();
            
            _allLost = _allLost && _player.hasLost;
        }
        
        for (var i = 1; i <= playerCount; i++) {
            var _player = getPlayer(i);
            _player.checkWinCondition()
            
            _someoneWon = _someoneWon || _player.hasWon;
            
            if (!winner && _player.hasWon) {
                winner = _player;
            }
        }
        
        if (_someoneWon) {
            gameEndCounter++;
            gameEnding = true;
            
            if (gameEndCounter >= rules.gameEndDelay) {
                gameEnded = true;
            }
        }
        
        if (_allLost) {
            gameEnding = true;
            winner = pointer_null;
        }
        
        gameEnding = _allLost || _someoneWon;
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
                draw_set_color(_color);

                drawLazilyOutlinedText(_x, _y, c_white, playerListDisplay.outlineWidth, _name);
            } else {
                draw_set_color(_color);
            
                draw_text(_x, _y, _name);
            }
            
            _y += playerListDisplay.lineHeight;
        }
    }

    static drawUnitQueue = function () {
        if (rules.useUnitQueue) {
            unitQueue.draw();
        }
    }
    
    static drawGameEndMessage = function () {
        if (!gameEnded)
            return;
            
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fontPlayerList);
        draw_set_color(c_black);
        draw_set_alpha(1);
        var _center = objGameCamera.viewCenter;
        
        if (winner) {
            var _winMessage = string("{0} has Won!", winner.name);
            draw_set_color(winner.color);
            drawLazilyOutlinedText(_center.x, _center.y, c_white, playerListDisplay.outlineWidth, _winMessage);
        } else {
            var _drawMessage = "It's a Draw!";
            drawLazilyOutlinedText(_center.x, _center.y, c_white, playerListDisplay.outlineWidth, _drawMessage);
        }
    }
}