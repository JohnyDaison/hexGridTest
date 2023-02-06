function BasicMovementAnimation(_hexMap, _unit, _endTile) : GameAnimation(_hexMap) constructor {
    unit = _unit;
    endTile = _endTile;
    drawingTile = pointer_null;
    
    var _unitStartPosition = hexMap.getTileXY(unit.currentTile);
    var _unitEndPosition = hexMap.getTileXY(endTile);
    unitTravelDistance = _unitEndPosition.subtract(_unitStartPosition);
    unitRelativePosition = new Vector(0, 0);
    
    static setDrawingTile = function(_hexTile) {
        if (drawingTile != pointer_null) {
            var _index = ds_list_find_index(drawingTile.animations, self);
            ds_list_delete(drawingTile.animations, _index);
        }
        
        drawingTile = unit.currentTile;
        
        if (drawingTile != pointer_null) {
            ds_list_add(drawingTile.animations, self);
        }
    }
    
    static animationStart = function() {
        started = true;
        setDrawingTile(unit.currentTile);
        hexMap.displaceUnit(unit);
        
        if(!is_undefined(onAnimStart))
            onAnimStart();
    }
    
    static animationStep = function() {
        var _ratio = progress / duration;
        
        unitRelativePosition.x = _ratio * unitTravelDistance.x;
        unitRelativePosition.y = _ratio * unitTravelDistance.y;
    }
    
    static animationEnd = function() {
        ended = true;
        hexMap.placeUnit(endTile, unit);
        setDrawingTile(pointer_null);
        
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
