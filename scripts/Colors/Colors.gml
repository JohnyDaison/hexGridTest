function Colors() constructor {
    static friendlyGreen = merge_color(c_white, merge_color(c_lime, c_green, 0.5), 0.8);
    static enemyRed = c_red;
    
    static trixagonRed = merge_color(c_white, merge_color(c_red, c_black, 0.5), 0.8);
    static trixagonBlue = merge_color(c_white, merge_color(c_blue, c_black, 0.25), 0.7);
    static trixagonHover = c_gray;
    static trixagonSelection = c_white;
    static trixagonTarget = c_black;
    
    static trixagonTrunc = c_gray;
    static trixagonTruncRanged = c_dkgray;
}

var _colors = new Colors();