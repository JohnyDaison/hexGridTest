var _guiX = device_mouse_x_to_gui(0);
var _guiY = device_mouse_y_to_gui(0);

var _tapEvent = new TapGUIEvent(_guiX, _guiY);

with(objBasicSpriteButton) {
    handleTapEvent(_tapEvent);
}

if (_tapEvent.tappedElement != pointer_null) {
    _tapEvent.tappedElement.click();
} else {
    objHexMap.handleTap();
}