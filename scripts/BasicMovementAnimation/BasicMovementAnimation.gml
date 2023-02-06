function BasicMovementAnimation(_hexMap, _unit, _endTile) : GameAnimation(_hexMap) constructor {
    unit = _unit;
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
        
        var _xDiff = _unitEndPosition.x - _unitStartPosition.x;
        if (_xDiff != 0) {
            unit.facing = sign(_xDiff);
        }
        
        started = true;
        hexMap.displaceUnit(unit);
        unit.setAnimState(UnitAnimState.Moving, true);
        
        if(!is_undefined(onAnimStart))
            onAnimStart();
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
        ended = true;
        hexMap.placeUnit(endTile, unit);
        setDrawingTile(pointer_null);
        
        unit.setAnimState(UnitAnimState.Idle);
        
        if(!is_undefined(onAnimEnd))
            onAnimEnd();
    }
    
    static draw = function(_tile) {
        var _basePos = hexMap.getTileXY(drawingTile);
        var _finalX = _basePos.x + unitRelativePosition.x;
        var _finalY = _basePos.y + unitRelativePosition.y;
        
        unit.draw(_finalX, _finalY);
    }
}
