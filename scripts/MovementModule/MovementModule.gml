function MovementModule(_unit, _stats) constructor {
    myUnit = _unit;
    stats = _stats.copy();
    
    static destroy = function () {
        stats.destroy();
    }
    
    static canMove = function () {
        if (!stats.mobile)
            return false;
            
        if (myUnit.gameController.trixagon.active) {
            var _hex = myUnit.nextPosition;
            var _trunc = _hex.getTrixagonTrunc();
            
            var _meleeHexes = _trunc.melee;
            var _count = 3;
            
            for (var i = 0; i < _count; i++) {
                var _meleeHex = _hex.add(_meleeHexes[i]);
                var _meleeTile = myUnit.hexMap.getTile(_meleeHex);
                
                if (!_meleeTile)
                    continue;
                    
                var _unit = _meleeTile.getTopUnit();
                
                if (!_unit)
                    continue;
                    
                if (_unit.player && _unit.player != myUnit.player && _unit.getUnitInFrontOfMe() == myUnit)
                    return false;
            }
        }
        
        return true;
    }
    
    static canMoveToTile = function(_hexTile) {
        if (_hexTile == myUnit.currentTile)
            return true;
        
        if (!canMove())
            return false;
            
        if (myUnit.gameController.trixagon.active) {
            var _unitOnTile = _hexTile.getTopUnit();
            if (_unitOnTile) {
                return false;
            }
        }
        
        return true;
    }
    
    static planFacingHex = function (_hex) {
        var _lastAction = myUnit.getQueueEndAction();
        
        if (_lastAction && _lastAction.type == ActionType.FaceHex) {
            _lastAction.hex = _hex;
        } else {
            myUnit.enqueueAction(new FaceHexAction(_hex));
        }
        
        return true;
    }
    
    static planMovementToHex = function (_hex) {
        var _hexTile = myUnit.hexMap.getTile(_hex);
        
        if (!_hexTile || !canMoveToTile(_hexTile) || _hexTile == myUnit.currentTile) {
            return false;
        }
        
        var _path = myUnit.hexMap.findUnitPath(myUnit, myUnit.plannedFinalPosition, _hex);
        
        if (myUnit.gameController.trixagon.active && myUnit.currentTile && !myUnit.currentAction && !myUnit.getNextAction()) {
            var _actionCount = array_length(_path.actionArray);
            var _skipCount = 0;
            var _index = 0;
            var _done = false;
            var _currentHex = myUnit.currentTile.position;
            
            do {
                _done = true;
                var _nextAction = _path.actionArray[_index];
                
                if (_nextAction.type == ActionType.MoveToHex) {
                    var _distance = _nextAction.hex.subtract(_currentHex).length();
                    
                    if (_distance <= 2) {
                        _skipCount = _index;
                        _done = false;
                        
                        if (_index > 0) {
                            _path.totalCost -= _path.actionArray[_index - 1].computedCost;
                        }
                    }
                }
                
                _index++;
            } until (_done || _index >= _actionCount);
            
            array_delete(_path.actionArray, 0, _skipCount);
        }
        
        if (!myUnit.gameController.rules.planForFutureTurns && _path.totalCost > myUnit.getRemainingActionPoints()) {
            return;
        }
        
        array_foreach(_path.actionArray, function(_action, _index) {
            myUnit.enqueueAction(_action);
        });
        
        return true;
    }
    
    // this method assumes the two hexes are neighbors
    static getMovementCost = function(_fromTile, _action) {
        var _toTile = myUnit.hexMap.getTile(_action.hex);
        
        if (_fromTile == pointer_null || _toTile == pointer_null) {
            return undefined;
        }
        
        var _fromRelations = stats.terrainRelations[? _fromTile.terrainType];
        var _toRelations = stats.terrainRelations[? _toTile.terrainType];
        
        if (!_toRelations.possible) {
            return undefined;
        }
        
        var _fromModifier = _fromRelations.pointCostModifier;
        var _fromMultiplier = _fromRelations.pointCostMultiplier;
        var _toModifier = _toRelations.pointCostModifier;
        var _toMultiplier = _toRelations.pointCostMultiplier;
        
        return _action.pointCost * _fromMultiplier * _toMultiplier + _fromModifier + _toModifier;
    }
    
    static getFacingToHex = function (_hex) {
        return _hex.subtract(myUnit.currentTile.position).toFacing();
    }
    
    static faceHex = function (_hex) {
        var _newFacing = getFacingToHex(_hex);
        myUnit.updateFacing(_newFacing);
    }
    
    static moveToHex = function (_hex) {
        if (myUnit.gameController.rules.otherActionsChangeFacing) {
            faceHex(_hex);
        }
        
        if (myUnit.gameController.trixagon.active) {
            myUnit.facingUncertain = true;
        }
        
        var _endTile = myUnit.hexMap.getTile(_hex);
        var _movementAnimation = new BasicMovementAnimation(myUnit.gameController, myUnit, _endTile);
        myUnit.hexMap.displaceUnit(myUnit);
    
        _movementAnimation.onAnimEnd = method(self, function (_animation) {
            myUnit.hexMap.placeUnit(_animation.endTile, myUnit);
            myUnit.endCurrentAction();
        });
    }
}