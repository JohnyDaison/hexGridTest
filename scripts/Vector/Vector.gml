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
    
    static length = function () {
        return point_distance(0, 0, x, y);
    }
    
    static distance = function (_otherVector) {
        return point_distance(x, y, _otherVector.x, _otherVector.y);
    }
}