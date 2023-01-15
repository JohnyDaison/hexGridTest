/// @description DRAGGING

if (draggingView) {
    objHexMap.startPosition.x = origStartPosition.x + mouse_x - mouseDragStart.x;
    objHexMap.startPosition.y = origStartPosition.y + mouse_y - mouseDragStart.y;
}