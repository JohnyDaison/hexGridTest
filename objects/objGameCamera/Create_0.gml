view_visible[0] = true;
view_enabled = true;

camera = view_get_camera(0);
baseViewportWidth = 1920;
baseViewportHeight = 1080;
zoomLevel = 1;
minZoomLevel = 1;
maxZoomLevel = 8;
zoomInCoef = 0.8;
zoomOutCoef = 1.2;

view_set_wport(0, baseViewportWidth);
view_set_hport(0, baseViewportHeight);
window_set_size(baseViewportWidth, baseViewportHeight);

updateZoomLevel = function(_newLevel) {
	var _prevZoomLevel = zoomLevel;
	zoomLevel = clamp(_newLevel, minZoomLevel, maxZoomLevel);
	
	if (zoomLevel != _prevZoomLevel) {
		updateCamera();
	}
}

updateCamera = function() {
	camera_set_view_size(camera,
		zoomLevel * baseViewportWidth,
		zoomLevel * baseViewportHeight);
	camera_set_view_pos(camera, 
		objHexMap.startPosition.x - zoomLevel * baseViewportWidth / 2,
		objHexMap.startPosition.y - zoomLevel * baseViewportHeight / 2);
}

updateCamera();
