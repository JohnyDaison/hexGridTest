///@function polygon_corners(hex,layout);
///@param hex
///@param layout
function polygon_corners(argument0, argument1) {

	var hex = argument0;
	var layout = argument1;

	var corners = [];
	var center = hex_to_pixel(hex,layout);
	for (var i = 0; i < 6; i++) {
	    var offset = hex_corner_offset(i,layout);
	    corners[i] = Point(center[X] + offset[X], center[Y] + offset[Y]);
	}

	return corners;



}
