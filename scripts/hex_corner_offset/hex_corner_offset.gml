// Feather ignore all

///@function hex_corner_offset(corner,layout);
///@param corner
///@param layout
function hex_corner_offset(argument0, argument1) {

	var corner = argument0;
	var layout = argument1;
	var M = layout[lay.orient];
	var size = layout[lay.size];
	var angle = 2.0 * pi * (M[ori.start_angle] - corner) / 6.0;

	return Point(size[X] * cos(angle), size[Y] * sin(angle));


}
