function drawSimpleArrow(_from, _to, _width) {
    var _dirVector = _to.subtract(_from).normalize();
    var _scaledDir = _dirVector.multiplyByScalar(_width);
    var _topOffset = _scaledDir.rotate90(1);
    var _bottomOffset = _scaledDir.rotate90(-1);
    
    var _topVertex = _from.add(_topOffset);
    var _bottomVertex = _from.add(_bottomOffset);
    
    draw_primitive_begin(pr_trianglelist);
    
    draw_vertex(_bottomVertex.x, _bottomVertex.y);
    draw_vertex(_topVertex.x, _topVertex.y);
    draw_vertex(_to.x, _to.y);
    
    draw_primitive_end();
}

/**
 * Function drawBar
 * @param {Struct.Vector} _position
 * @param {Struct.Vector} _size
 * @param {Constant.Color} _color
 * @param {Real} _ratio 
 * @param {Constant.HAlign} [_halign]=fa_center
 * @param {Constant.VAlign} [_valign]=fa_middle
 */
function drawBar(_position, _size, _color, _ratio, _halign = fa_center, _valign = fa_middle) {
    var _x1, _y1, _x2, _y2, _xBar;
    var _borderSize = 2;
        
    switch(_halign) {
        case fa_left:
            _x1 = _position.x;
            _x2 = _position.x + _size.x;
            break;
        case fa_center:
            _x1 = _position.x - _size.x / 2;
            _x2 = _position.x + _size.x / 2;
            break;
        case fa_right:
            _x1 = _position.x - _size.x;
            _x2 = _position.x;
            break;
    }
    
    switch(_valign) {
        case fa_top:
            _y1 = _position.y;
            _y2 = _position.y + _size.y;
            break;
        case fa_middle:
            _y1 = _position.y - _size.y / 2;
            _y2 = _position.y + _size.y / 2;
            break;
        case fa_bottom:
            _y1 = _position.y - _size.y;
            _y2 = _position.y;
            break;
    }
    
    _xBar = _x1 + _size.x * _ratio;
    
    draw_set_alpha(0.7);
    draw_set_color(c_dkgray);
    draw_rectangle(_xBar, _y1, _x2, _y2, false);
    
    draw_set_color(_color);
    draw_rectangle(_x1, _y1, _xBar, _y2, false);
    
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(_x1, _y1, _x1 + _borderSize, _y2, false);
    draw_rectangle(_x1, _y1, _x2, _y1 + _borderSize, false);
    draw_rectangle(_x2 - _borderSize, _y1, _x2, _y2, false);
    draw_rectangle(_x1, _y2 - _borderSize, _x2, _y2, false);
}
