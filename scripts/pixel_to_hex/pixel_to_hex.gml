// Feather ignore all

///@function pixel_to_hex(layout, point);
///@param point[x,y]
///@param layout
function pixel_to_hex(argument0, argument1) {

	var p = argument0;
	var layout = argument1;
	var M = layout[lay.orient];
	var size = layout[lay.size];
	var origin = layout[lay.origin];

	var pt = Point((p[X] - origin[X]) / size[X], (p[Y] - origin[Y]) / size[Y]);
	var q = M[ori.b0] * pt[X] + M[ori.b1] * pt[Y];
	var r = M[ori.b2] * pt[X] + M[ori.b3] * pt[Y];

	return Hex(q, r, -q - r);


}
