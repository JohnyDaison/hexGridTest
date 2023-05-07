function MovementModule(_unit, _stats) constructor {
    myUnit = _unit;
    stats = _stats.copy();
    
    static destroy = function () {
        stats.destroy();
    }
    
    static canMove = function () {
        return stats.mobile;
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
        if (!canMove()) {
            return false;
        }
        
        var _actionArray = myUnit.hexMap.findUnitPath(myUnit, myUnit.plannedFinalPosition, _hex);
        
        if (myUnit.gameController.trixagon && myUnit.currentTile && !myUnit.currentAction && !myUnit.getNextAction()) {
            var _actionCount = array_length(_actionArray);
            var _skipCount = 0;
            var _index = 0;
            var _done = false;
            var _currentHex = myUnit.currentTile.position;
            
            do {
                _done = true;
                var _nextAction = _actionArray[_index];
                
                if (_nextAction.type == ActionType.MoveToHex) {
                    var _distance = _nextAction.hex.subtract(_currentHex).length();
                    
                    if (_distance <= 2) {
                        _skipCount = _index;
                        _done = false;
                    }
                }
                
                _index++;
            } until (_done || _index >= _actionCount);
            
            array_delete(_actionArray, 0, _skipCount);
        }
        
        array_foreach(_actionArray, function(_action, _index) {
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
        faceHex(_hex);
        
        var _endTile = myUnit.hexMap.getTile(_hex);
        var _movementAnimation = new BasicMovementAnimation(myUnit.gameController, myUnit, _endTile);
        myUnit.hexMap.displaceUnit(myUnit);
    
        _movementAnimation.onAnimEnd = method(self, function (_animation) {
            myUnit.hexMap.placeUnit(_animation.endTile, myUnit);
            myUnit.endCurrentAction();
        });
    }
}