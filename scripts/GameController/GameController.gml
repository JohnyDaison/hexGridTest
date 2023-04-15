function GameController() constructor {
    units = ds_list_create();
    gameAnimations = ds_list_create();
    hexMap = pointer_null;
    selectedUnit = pointer_null;
    unitTargetTile = pointer_null;
    endTurnButtonPressed = false;
    
    unitQueue = new UnitQueue(self);
    useUnitQueue = true;
    
    initiativeThreshold = 60;
    roundCounter = 1;
    
    static destroy = function() {
        destroyMap();
        unitQueue.destroy();

        ds_list_destroy(gameAnimations);
        ds_list_destroy(units);
    }
    
    static init = function() {
        unitsRoundStart();
        unitQueue.init();
        
        if (useUnitQueue) {
            selectedUnit = unitQueue.activeUnit;
        }
    }
    
    static createMap = function (_orientation, _size, _origin) {
        if (hexMap != pointer_null) {
            return pointer_null;
        }
        
        hexMap = new HexMap(_orientation, _size, _origin);
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
    
    static addUnit = function(_hexTile, _unitType) {
        var _unit = new Unit(_unitType);
        ds_list_add(units, _unit);
        _unit.gameController = self;
        _unit.hexMap = hexMap;
        
        hexMap.placeUnit(_hexTile, _unit);
        
        if (useUnitQueue) {
            unitQueue.addUnit(_unit);
        }
        
        return true;
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
        
        unitQueue.deleteUnit(_unit);
        
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
        
        for (var i = 0; i < _gameAnimationCount; i++) {
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
        
        var _unitCount = ds_list_size(units);
        
        for (var i = _unitCount - 1; i >= 0; i--) {
            var _unit = units[| i];
            
            if (_unit.dying) {
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
    
    static handleTileClicked = function(_cursorTile) {
        var _cursorUnit = _cursorTile.getTopUnit();
        
        if (useUnitQueue) {
            if (_cursorUnit != selectedUnit) {
                unitTargetTile = _cursorTile;
            }
        } else {
            if (selectedUnit == pointer_null) {
                if (_cursorUnit != pointer_null && !_cursorUnit.dying) {
                    selectedUnit = _cursorUnit;
                }
            } else if (_cursorUnit == selectedUnit) {
                selectedUnit = pointer_null;
                unitTargetTile = pointer_null;
            } else {
                unitTargetTile = _cursorTile;
            }
        }
        
        if (selectedUnit != pointer_null && unitTargetTile != pointer_null) {
            var _planned = false;
    
            if (_cursorUnit != pointer_null && selectedUnit.combat.canAttack()) {
                _planned = selectedUnit.combat.planAttackOnHex(unitTargetTile.position);
            } else if (selectedUnit.movement.canMove()) {
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
        
        return true;
    }
    
    static endUnitTurn = function () {
        show_debug_message("endUnitTurn called");
        
        if (selectedUnit != pointer_null) {
            selectedUnit.initiativeAccumulated -= initiativeThreshold;
            selectedUnit.turnCounter++;
        }
        
        selectedUnit = pointer_null;
        unitTargetTile = pointer_null;
        
        if (useUnitQueue) {
            unitQueue.update();
            selectedUnit = unitQueue.activeUnit;
        }
        
        if (selectedUnit == pointer_null) {
            endRound();
        }
    }
    
    static endRound = function () {
        show_debug_message("endRound called");
        
        roundCounter++;
        
        unitsRoundStart();
        endUnitTurn();
    }

    static drawUnitQueue = function () {
        if (useUnitQueue) {
            unitQueue.draw();
        }
    }
}