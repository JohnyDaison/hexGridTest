hovered = false;
pressed = false;
enabled = true;
onClick = undefined;
image_speed = 0;

handleTapEvent = function(_event) {
    if (_event.tappedElement == pointer_null && collision_point(_event.x, _event.y, id, false, false)) {
        _event.tappedElement = self;
    }
}

click = function() {
    if (enabled && !is_undefined(onClick)) {
        onClick();
    }
}