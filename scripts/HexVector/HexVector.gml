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
    
    static length = function () {
        return (abs(q) + abs(r) + abs(s)) / 2;
    }
    
    static distance = function (_otherVector) {
        return subtract(_otherVector).length();
    }
}