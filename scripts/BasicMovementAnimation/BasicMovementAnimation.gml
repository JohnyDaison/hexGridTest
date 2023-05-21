function BasicMovementAnimation(_gameController, _unit, _endTile) : UnitAnimation(_gameController, _unit) constructor {
    startTile = unit.currentTile;
    endTile = _endTile;
    drawingTile = pointer_null;
    originAtEnd = false;
    movementSpeed = unit.type.animMovementSpeed;
    
    static setDrawingTile = function(_hexTile) {
        if (drawingTile != pointer_null) {
            var _index = ds_list_find_index(drawingTile.animations, self);
            ds_list_delete(drawingTile.animations, _index);
        }
        
        drawingTile = _hexTile;
        
        if (drawingTile != pointer_null) {
            ds_list_add(drawingTile.animations, self);
        }
    }
    
    static animationStart = function() {
        var _startHex = startTile.position;
        var _endHex = endTile.position;
        var _unitStartPosition = hexMap.getTileXY(startTile);
        var _unitEndPosition = hexMap.getTileXY(endTile);
        
        duration = _unitStartPosition.distance(_unitEndPosition) / movementSpeed;
        
        if (_startHex.r < _endHex.r || (_startHex.r == _endHex.r && _startHex.q < _endHex.q)) {
            originAtEnd = true;
        }
        
        if (!originAtEnd) {
            unitTravelDistance = _unitEndPosition.subtract(_unitStartPosition);
            unitRelativePosition = new Vector(0, 0);
            unitTravelDirection = 1;
            setDrawingTile(startTile);
        } else {
            unitTravelDistance = _unitStartPosition.subtract(_unitEndPosition);
            unitRelativePosition = unitTravelDistance.copy();
            unitTravelDirection = -1;
            setDrawingTile(endTile);
        }
        
        unit.setNextAnimState(UnitAnimState.Moving, true);
    }
    
    static animationStep = function() {
        var _ratio = progress / duration;
        
        if (unitTravelDirection == -1) {
           _ratio = 1 - _ratio;
        }
        
        unitRelativePosition.x = _ratio * unitTravelDistance.x;
        unitRelativePosition.y = _ratio * unitTravelDistance.y;
    }
    
    static animationEnd = function() {
        setDrawingTile(pointer_null);
        
        unit.setNextAnimState(UnitAnimState.Moving, false);
        
        setUnit(pointer_null);
    }
    
    static draw = function() {
        if (!started || ended) {
            return;
        }
        
        var _basePos = hexMap.getTileXY(drawingTile);
        var _finalPos = _basePos.add(unitRelativePosition);
        
        unit.draw(_finalPos.x, _finalPos.y);
        unit.drawOverlay(_finalPos);
    }
}
