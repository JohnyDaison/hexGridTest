function UnitQueueCard(_unitQueue, _unit) constructor {
    unitQueue = _unitQueue;
    unit = _unit;
    sprite = unit.type.getAnim(UnitAnimState.Idle);
    startPosition = new Vector(0, 0);
    currentPosition = new Vector(0, 0);
    targetPosition = new Vector(0, 0);
    moveAnimationProgress = 0;
    spriteWidth = sprite_get_width(sprite);
    spriteHeight = sprite_get_height(sprite);

    static initPosition = function (_x, _y) {
        currentPosition.x = _x;
        currentPosition.y = _y;

        setTargetPosition(_x, _y);
    }
    
    static setTargetPosition = function (_x, _y) {
        startPosition.x = currentPosition.x;
        startPosition.y = currentPosition.y;
        targetPosition.x = _x;
        targetPosition.y = _y;
        moveAnimationProgress = 0;
    }
    
    static updateCurrentPosition = function (_timePassed) {
        var _currentDiffX = targetPosition.x - currentPosition.x;
        var _totalDiffX = targetPosition.x - startPosition.x;
        var _currentDistance = abs(_currentDiffX);
        var _totalDistance = abs(_totalDiffX);
        
        if (_currentDistance == 0 || _totalDistance == 0) {
            return;
        }
        
        moveAnimationProgress += _timePassed;
        
        var _progressRatio = moveAnimationProgress / unitQueue.moveAnimationDuration;
        
        if (_progressRatio >= 1) {
            currentPosition.x = targetPosition.x;
        } else {
            currentPosition.x = lerp(startPosition.x, targetPosition.x, _progressRatio);
        }
    }
    
    static draw = function (_isActive, _isInRound) {
        var _yOffset = unit.type.yOffset;
        var _scale = unitQueue.scale * unit.scale;
        
        var _centerX = currentPosition.x;
        var _spriteCenterY = currentPosition.y + _scale * _yOffset;
        var _bottomY = currentPosition.y;
        var _padding = unitQueue.cardPadding;
        var _drawCard = _isActive || _isInRound;
        
        
        var _firstLabelY = _bottomY + unitQueue.labelMargin;
        var _secondLabelY = _firstLabelY + unitQueue.labelHeight + unitQueue.labelMargin;
        var _thirdLabelY = _secondLabelY + unitQueue.labelHeight + unitQueue.labelMargin;
        
        if (_isActive) {
            draw_set_color(c_white);
            draw_set_alpha(0.7);
        } else if (_isInRound) {
            draw_set_color(c_ltgray);
            draw_set_alpha(0.4);
        }
        
        if (_drawCard) {
            var _cardTop = _spriteCenterY - spriteHeight * _scale - _padding;
            var _cardBottom = _bottomY;
            var _cardLeft = _centerX - (spriteWidth / 2) * _scale - _padding;
            var _cardRight = _centerX + (spriteWidth / 2) * _scale + _padding;
            
            draw_roundrect(_cardLeft, _cardTop, _cardRight, _cardBottom, true);
            draw_roundrect(_cardLeft, _cardTop, _cardRight, _cardBottom, false);
            draw_roundrect(_cardLeft, _cardTop, _cardRight, _cardBottom, true);
        }
        
        draw_sprite_ext(sprite, 0, _centerX, _spriteCenterY, _scale, _scale, 0, c_white, 1);
        
        if (_drawCard) {
            draw_set_color(c_white);
        } else {
            draw_set_color(c_yellow);
        }
        
        draw_set_alpha(1);
        draw_set_font(fontDebug);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        
        draw_text(_centerX, _firstLabelY, string("{0}", unitQueue.roundsUntilActive(self)));
        draw_text(_centerX, _secondLabelY, string("{0} +{1}", unit.initiativeAccumulated, unit.initiative));
        draw_text(_centerX, _thirdLabelY, string("{0}", unit.turnCounter));
    }
}