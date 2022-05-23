///@function check_circle_all(gx,gy,r,grid);
///@description [array] Returns an array of all the points inside a circle
///@param {real} gx X position of the circle center on grid
///@param {real} gy Y position of the circle center on grid
///@param {real} r Radius of the circle
///@param {real} grid Grid index
function check_circle_all(argument0, argument1, argument2, argument3) {

	var gx = argument0;
	var gy = argument1;
	var r = argument2;
	var grid = argument3;
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
				array[array_pos] = [xx,yy];
				array_pos++;
			}
		}
	}

	return array;


}
