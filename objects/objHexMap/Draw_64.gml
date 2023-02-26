gameController.drawUnitQueue();

if (debugText != "") {
    var _xPos = 10
    var _yPos = 10;
    draw_set_font(fontDebug);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_text(_xPos - 1, _yPos - 1, debugText);
    draw_text(_xPos - 1, _yPos + 1, debugText);
    draw_text(_xPos + 1, _yPos - 1, debugText);
    draw_text(_xPos + 1, _yPos + 1, debugText);
    draw_set_color(c_red);
    draw_text(_xPos, _yPos, debugText);
}