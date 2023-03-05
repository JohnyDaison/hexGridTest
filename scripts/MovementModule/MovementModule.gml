function MovementModule(_unit, _stats) constructor {
    myUnit = _unit;
    stats = _stats.copy();
    
    static canMove = function () {
        return stats.mobile;
    }
    
    static planMovementToHex = function (_hex) {
        if (!canMove()) {
            return false;
        }
        
        var _actionArray = myUnit.hexMap.findUnitPath(myUnit, myUnit.plannedFinalPosition, _hex);
        
        array_foreach(_actionArray, function(_action, _index) {
            myUnit.enqueueAction(_action);
        });
        
        return true;
    }
    
    static moveToHex = function (_hex) {
        var _endTile = myUnit.hexMap.getTile(_hex);
        var _movementAnimation = new BasicMovementAnimation(myUnit.gameController, myUnit, _endTile);
        myUnit.hexMap.displaceUnit(myUnit);
    
        _movementAnimation.onAnimEnd = method(self, function (_animation) {
            myUnit.hexMap.placeUnit(_animation.endTile, myUnit);
            myUnit.endCurrentAction();
        });
    }
}