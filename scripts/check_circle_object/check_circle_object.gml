// Feather ignore all

///@function check_circle(gx,gy,r,grid);
///@description [array] Returns an array of all the points inside a circle
///@param {real} gx X position of the circle center on grid
///@param {real} gy Y position of the circle center on grid
///@param {real} r Radius of the circle
///@param {real} grid Grid index
///@param {real} object Object index to check for
function check_circle_object(argument0, argument1, argument2, argument3, argument4) {

	var gx = argument0;
	var gy = argument1;
	var r = argument2;
	var grid = argument3;
	var object = argument4;
	var gw = ds_grid_width(grid);
	var gh = ds_grid_height(grid);
	var array = [];
	var array_pos = 0;

	for (var xx=gx-r;xx<gx+r;xx++) {
		for (var yy=gy-r;yy<gy+r;yy++) {
			if (xx < 0 || xx >= gw || yy < 0 || yy >= gh) {
				continue;
			}
			if (in_range(xx,yy,r)) {
				if (grid[# xx,yy].object_index == object) {
					array[array_pos] = grid[# xx,yy];
					array_pos++;
				}
			}
		}
	}

	return array;


}
