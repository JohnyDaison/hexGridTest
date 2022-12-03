// Feather ignore all

///@function hex_to_pixel(hex,layout)
///@param hex
///@param layout
function hex_to_pixel(argument0, argument1) {

	var hex = argument0;
	var layout = argument1;

	var M = layout[lay.orient];
	var size = layout[lay.size];
	var origin = layout[lay.origin];
	var xx = (M[ori.f0] * hex[h.q] + M[ori.f1] * hex[h.r]) * size[X];
	var yy = (M[ori.f2] * hex[h.q] + M[ori.f3] * hex[h.r]) * size[Y];
	return Point(xx + origin[X], yy + origin[Y]);


}
