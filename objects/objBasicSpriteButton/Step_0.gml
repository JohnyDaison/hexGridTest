if (!enabled) {
    hovered = false;
    pressed = false;
    exit;
}

var _mouseX = device_mouse_x_to_gui(0);
var _mouseY = device_mouse_y_to_gui(0);

if (collision_point(_mouseX, _mouseY, id, false, false)) {
    hovered = true;
    
    if (mouse_check_button_pressed(mb_left)) {
        pressed = true;
    }
    
    if (pressed && mouse_check_button_released(mb_left)) {
        pressed = false;
    }
} else {
    hovered = false;
    pressed = false;
}