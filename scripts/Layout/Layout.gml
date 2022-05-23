///@function Layout(orientation, size[x,y], origin[x,y]) {
///@param orientation
///@param size[x,y]
///@param origin[x,y]
function Layout(argument0, argument1, argument2) {

#macro layout_pointy Orientation(sqrt(3.0),sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0, sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0, 0.5)
#macro layout_flat Orientation(3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0), 2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0, 0.0)

	enum lay {
		orient,
		size,
		origin
	}

	var orientation = argument0;
	var size = argument1;
	var origin = argument2;

	return [orientation, size, origin];


}
