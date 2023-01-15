global.hexDirections = [new HexVector(1, 0), new HexVector(1, -1), new HexVector(0, -1), new HexVector(-1, 0), new HexVector(-1, 1), new HexVector(0, 1)];

function HexVector(_q, _r) constructor {
    q = _q;
    r = _r;
    s = -(_q+_r);
    
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
    
    static length = function () {
        return (abs(q) + abs(r) + abs(s)) / 2;
    }
    
    static distance = function (_otherVector) {
        return subtract(_otherVector).length();
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
}
