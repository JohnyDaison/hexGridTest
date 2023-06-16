function Colors() constructor {
    static friendlyGreen = merge_color(c_white, merge_color(c_lime, c_green, 0.5), 0.8);
    static enemyRed = c_red;
    
    static trixagonRed = merge_color(c_white, merge_color(c_red, c_black, 0.5), 0.8);
    static trixagonBlue = merge_color(c_white, merge_color(c_blue, c_black, 0.25), 0.7);
    static trixagonHover = c_ltgray;
    static trixagonSelection = c_white;
    static trixagonCursor = c_yellow;
    static trixagonMeleeTarget = c_yellow;
    static trixagonRangedTarget = merge_color(c_yellow, c_white, 0.5);
    
    static trixagonTrunc = c_ltgray;
    static trixagonTruncRanged = merge_color(trixagonTrunc, c_black, 0.2);
    static trixagonTruncMovementBlocked = c_black;
}

var _colors = new Colors();