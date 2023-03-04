function Vector(_x, _y) constructor {
    x = _x;
    y = _y;
    
    static equals = function (_otherVector) {
        return x == _otherVector.x && y == _otherVector.y;
    }
    
    static add = function (_otherVector) {
        return new Vector(x + _otherVector.x, y + _otherVector.y);
    }
    
    static subtract = function (_otherVector) {
        return new Vector(x - _otherVector.x, y - _otherVector.y);
    }
    
    static multiplyByScalar = function (_factor) {
        return new Vector(x * _factor, y * _factor);
    }
    
    static divideByScalar = function (_factor) {
        return new Vector(x / _factor, y / _factor);
    }
    
    static length = function () {
        return point_distance(0, 0, x, y);
    }
    
    static getDirection = function () {
        return point_direction(0, 0, x, y);
    }
    
    static distance = function (_otherVector) {
        return point_distance(x, y, _otherVector.x, _otherVector.y);
    }
    
    static copy = function () {
        return new Vector(x, y);
    }
    
    static normalize = function() {
        if (length() == 0) {
            return copy();
        }
        
        return divideByScalar(length());
    }
    
    static rotate90 = function(_dir) {
        if (_dir < 0) {
            return new Vector(y, -x);
        } else {
            return new Vector(-y, x);
        }
    }
    
    static rotate180 = function(_dir) {
        return new Vector(-x, -y);
    }
}