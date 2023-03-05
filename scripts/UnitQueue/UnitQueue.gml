function UnitQueue(_gameController) constructor {
    gameController = _gameController;
    activeUnit = pointer_null;
    unitCards = [];
    
    queuePadding = 6;
    cardPadding = 6;
    labelMargin = 2;
    labelHeight = 20;
    
    cardSpacing = 180;
    height = 200;
    scale = 0.5;
    
    position = new Vector(320, scale * height);
    
    moveAnimationDuration = 1; // in seconds
    
    static destroy = function () {}
    
    static init = function () {
        update();
        initCards();
    }
    
    static addUnit = function(_unit) {
        var _unitCard = new UnitQueueCard(self, _unit);
        
        array_push(unitCards, _unitCard);
    }
    
    static deleteUnit = function(_unit) {
        var _unitCardCount = array_length(unitCards);
        var _unitQueueIndex = -1;
        
        for (var i = 0; i < _unitCardCount && _unitQueueIndex == -1; i++) {
            var _unitCard = unitCards[i];
            
            if (_unitCard.unit == _unit) {
                _unitQueueIndex = i;
                break;
            }
        };
        
        if (_unitQueueIndex == -1) {
            return false;
        }
        
        if (activeUnit == _unit) {
            activeUnit = pointer_null;
        }
        
        var _unitCard = unitCards[_unitQueueIndex];
        array_delete(unitCards, _unitQueueIndex, 1);
        delete _unitCard;
        
        update();
        
        return true;
    }
    
    static isInThisRound = function(_unitCard) {
        return _unitCard.unit.initiativeAccumulated >= gameController.initiativeThreshold;
    }
    
    static updateActiveUnit = function () {
        show_debug_message("updateActiveUnit called");
        
        var _unitCardCount = array_length(unitCards);
        if (_unitCardCount == 0) {
            activeUnit = pointer_null;
            return;
        }
        
        var _firstCard = array_first(unitCards)
        
        if (isInThisRound(_firstCard)) {
            activeUnit = _firstCard.unit;
        } else {
            activeUnit = pointer_null;
        }
    }
    
    static update = function () {
        var _unitCardCount = array_length(unitCards);
        if (_unitCardCount == 0) {
            return;
        }
        
        var _firstCard = array_first(unitCards);
        if (_firstCard.unit.initiativeAccumulated == 0) {
            array_delete(unitCards, 0, 1);
            array_push(unitCards, _firstCard);
        }
        
        insertionSort(unitCards, method(self, function(_card1, _card2) {
            if(isInThisRound(_card1) && isInThisRound(_card2)) {
                return _card2.unit.initiative - _card1.unit.initiative;
            }
            
            return _card2.unit.initiativeAccumulated - _card1.unit.initiativeAccumulated;
        }));
        
        updateCardTargets();
        updateActiveUnit();
    }
    
    static initCards = function () {
        var _unitCardCount = array_length(unitCards);
        var _scaledCardSpacing = scale * cardSpacing;
        
        for (var i = _unitCardCount - 1; i >= 0; i--) {
            var _unitCard = unitCards[i];
            _unitCard.initPosition(position.x + _scaledCardSpacing * i, position.y);
        }
    }
    
    static updateCardTargets = function () {
        var _unitCardCount = array_length(unitCards);
        var _scaledCardSpacing = scale * cardSpacing;
        
        for (var i = _unitCardCount - 1; i >= 0; i--) {
            var _unitCard = unitCards[i];
            _unitCard.setTargetPosition(position.x + _scaledCardSpacing * i, position.y);
        }
    }
    
    static updateCards = function () {
        var _timePassed = delta_time / 1000000;
        var _unitCardCount = array_length(unitCards);
        
        for (var i = 0; i < _unitCardCount; i++) {
            var _unitCard = unitCards[i];
            _unitCard.updateCurrentPosition(_timePassed);
        }
    }
    
    static draw = function () {
        var _unitCardCount = array_length(unitCards);
        var _padding = queuePadding;
        var _cardWidth = cardSpacing * scale;
        var _width = _unitCardCount * _cardWidth;
        var _leftEdge = position.x - _cardWidth / 2;
        
        var _bgTop = position.y - height * scale - _padding;
        var _bgBottom = position.y + 2 * labelHeight + labelMargin + _padding;
        var _bgLeft = _leftEdge - _padding;
        var _bgRight = _leftEdge + _width + _padding;
        
        draw_set_color(c_black);
        draw_set_alpha(0.7);
        draw_roundrect(_bgLeft, _bgTop, _bgRight, _bgBottom, false);
        
        for (var i = _unitCardCount - 1; i >= 0; i--) {
            var _unitCard = unitCards[i];
            var _isActive = _unitCard.unit == activeUnit;
            var _isInRound = isInThisRound(_unitCard);
            _unitCard.draw(_isActive, _isInRound);
        }
    }
}