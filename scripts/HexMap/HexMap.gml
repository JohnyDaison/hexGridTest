function HexMap(_orientation, _size, _origin) constructor {
    layout = Layout(_orientation, _size, _origin);
    grid = new HexGrid();
    
    static destroy = function() {
        grid.destroy();
    }
    
    static hexToPixel = function(_hex) {
        var _ori = layout[lay.orient];
        var _size = layout[lay.size];
        var _origin = layout[lay.origin];
        var _xx = (_ori[ori.f0] * _hex.q + _ori[ori.f1] * _hex.r) * _size.x;
        var _yy = (_ori[ori.f2] * _hex.q + _ori[ori.f3] * _hex.r) * _size.y;
        return new Vector(_xx + _origin.x, _yy + _origin.y);
    }
    
    static hexCornerOffset = function(_corner) {
        var _ori = layout[lay.orient];
        var _size = layout[lay.size];
        var _angle = 2.0 * pi * (_ori[ori.start_angle] - _corner) / 6.0;

        return new Vector(_size.x * cos(_angle), _size.y * sin(_angle));
    }
    
    static polygonCorners = function(_hex) {
        var _corners = [];
        var _center = hexToPixel(_hex);
        for (var i = 0; i < 6; i++) {
            var _offset = hexCornerOffset(i);
            _corners[i] = _center.add(_offset);
        }

        return _corners;
    }
    
    static drawHexBg = function() {
        for (var _r = grid.minR; _r <= grid.maxR; _r++) {
            var _rOffset = floor(_r / 2);
            for (var _q = grid.minQ; _q <= grid.maxQ; _q++) {
                var _hex = new HexVector(_q,_r);
                if (is_undefined(grid.getTile(_hex))) {
                    continue;
                }
                
                var _corners = polygonCorners(_hex);
                draw_primitive_begin(pr_trianglefan);
                for (var _k = 0; _k < 6; _k++) {
                    var _corner = _corners[_k];
                    var _x1 = _corner.x;
                    var _y1 = _corner.y;
                    draw_vertex(_x1, _y1);
                }
                draw_primitive_end();
            }
        }
    }
}