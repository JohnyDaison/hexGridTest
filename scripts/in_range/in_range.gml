// Feather ignore all

///@function in_range(xx,yy,r);
///@description [boolean] Returns true if xx and yy are inside the circle
///@param {real} x X position to check
///@param {real} y Y position to check
///@param {real} r Radius of the circle
function in_range(argument0, argument1, argument2) {

	var xx = argument0;
	var yy = argument1;
	var r = argument2;
	var r_squared = r*r;
	var dist_squared = (xx*xx)+(yy*yy);
	if (dist_squared <= r_squared) {
		return true;
	}
	else {
		return false;
	}


}
