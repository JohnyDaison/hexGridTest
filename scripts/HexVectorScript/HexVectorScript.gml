global.hexDirections = [new HexVector(1, 0), new HexVector(1, -1), new HexVector(0, -1), new HexVector(-1, 0), new HexVector(-1, 1), new HexVector(0, 1)];
global.hexDirectionsDown = [global.hexDirections[0], global.hexDirections[4], global.hexDirections[5]];

global.truncRight = {
    melee: [new HexVector(-1, 0), new HexVector(1, -1), new HexVector(0, 1)],
    movement: [new HexVector(-1, -1), new HexVector(1, -2), new HexVector(-2, 1), new HexVector(2, -1), new HexVector(-1, 2), new HexVector(1, 1)],
    ranged: [new HexVector(0, -2), new HexVector(-2, 2), new HexVector(2, 0)]
}

global.truncLeft = {
    melee: [new HexVector(0, -1), new HexVector(-1, 1), new HexVector(1, 0)],
    movement: [new HexVector(-1, -1), new HexVector(1, -2), new HexVector(-2, 1), new HexVector(2, -1), new HexVector(-1, 2), new HexVector(1, 1)],
    ranged: [new HexVector(-2, 0), new HexVector(2, -2), new HexVector(0, 2)]
}

/// @function HexVector(_q, _r)
/// @param {Real} _q
/// @param {Real} _r
function HexVector(_q, _r) constructor {
    q = _q;
    r = _r;
    s = -(_q+_r);
    
    static zero = pointer_null;
    
    static toString = function() {
        return string("[{0}, {1}]", q, r);
    }
    
    static equals = function (_otherVector) {
        return q == _otherVector.q && r == _otherVector.r && s == _otherVector.s;
    }
    
    static add = function (_otherVector) {
        return new HexVector(q + _otherVector.q, r + _otherVector.r);
    }
    
    static subtract = function (_otherVector) {
        return new HexVector(q - _otherVector.q, r - _otherVector.r);
    }
    
    static multiply = function (_otherVector) {
        return new HexVector(q * _otherVector.q, r * _otherVector.r);
    }
    
    static divide = function (_otherVector) {
        return new HexVector(q / _otherVector.q, r / _otherVector.r);
    }
    
    static scale = function (_factor) {
        return new HexVector(q * _factor, r * _factor);
    }
    
    static neighbor = function (_directionIndex) {
        return add(global.hexDirections[_directionIndex]);
    }
    
    static length = function () {
        return (abs(q) + abs(r) + abs(s)) / 2;
    }
    
    static distance = function (_otherVector) {
        return subtract(_otherVector).length();
    }
    
    static normalize = function () {
        var _normalized = self.scale(1 / self.length());
        _normalized.makeRound();
        
        return _normalized;
    }
    
    static toFacing = function () {
        var _normalized = self;
        var _origLength = self.length();
        
        if (_origLength == 0) {
            return -1;
        }
        
        if (_origLength != 1) {
            _normalized = self.normalize();
        }
        
        for (var i = 0; i < 6; i++) {
            if (_normalized.equals(global.hexDirections[i])) {
                return i;
            }
        }
        
        return -1;
    }
    
    static getRing = function (_radius) {
        var _results = [];
        var _c = 0;

        var _hex = self.add(global.hexDirections[4].scale(_radius));
        for (var _side = 0; _side < 6; _side++) {
            for (var _hexIndex = 0; _hexIndex < _radius; _hexIndex++) {
                _results[_c] = _hex;
                _hex = _hex.neighbor(_side);
                _c++;
            }
        }

        return _results;
    }
    
    static getSpiral = function (_radius) {
        var _results = [self];
        
        for (var _currentRadius = 0; _currentRadius <= _radius; _currentRadius++) {
            var _ringArray = self.getRing(_currentRadius);
            _results = array_concat(_results, _ringArray);
        }
        
        return _results;
    }
    
    static findClosestTile = function (_array) {
        var _count = array_length(_array);
        var _minDistance = 0;
        var _closestIndex = -1;
        
        for (var i = 0; i < _count; i++) {
            var _tile = _array[i];
            var _distance = self.distance(_tile.position);
            
            if (_closestIndex == -1 || _distance < _minDistance) {
                _minDistance = _distance;
                _closestIndex = i;
            }
        }
        
        return _closestIndex;
    }
    
    static makeRound = function () {
        var _q = round(q);
        var _r = round(r);
        var _s = round(s);

        var _qDiff = abs(_q - q);
        var _rDiff = abs(_r - r);
        var _sDiff = abs(_s - s);

        if (_qDiff > _rDiff && _qDiff > _sDiff) {
            _q = -_r-_s;
        } else if (_rDiff > _sDiff) {
            _r = -_q-_s;
        } else {
            _s = -_q-_r;
        }

        q = _q;
        r = _r;
        s = _s;
        
        if (q == -0) {
            q = 0;
        }
        
        if (r == -0) {
            r = 0;
        }
        
        if (s == -0) {
            s = 0;
        }
    }
    
    static isTrixagonRight = function () {
        var _result = modulo(self.s, 2) == 0;
        var _diffMod = modulo(self.q - self.r, 6);
    
        if (_diffMod == 0 || _diffMod >= 3) {
            _result = !_result;
        }
        
        return _result;
    }
    
    static getTrixagonTrunc = function () {
        return isTrixagonRight() ? global.truncRight : global.truncLeft;
    }
}

HexVector.zero = new HexVector(0, 0);