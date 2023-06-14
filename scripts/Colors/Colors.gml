function Colors() constructor {
    static friendlyGreen = merge_color(c_white, merge_color(c_lime, c_green, 0.5), 0.8);
    static enemyRed = c_red;
    
    static trixagonRed = merge_color(c_white, merge_color(c_red, c_black, 0.5), 0.8);
    static trixagonBlue = merge_color(c_white, merge_color(c_blue, c_black, 0.25), 0.7);
    static trixagonHover = c_ltgray;
    static trixagonSelection = c_white;
    
    static trixagonTruncMelee = c_ltgray;
    static trixagonTrunc = c_gray;
    static trixagonTruncRanged = c_dkgray;
    static trixagonTruncMovementBlocked = c_black;
}

var _colors = new Colors();