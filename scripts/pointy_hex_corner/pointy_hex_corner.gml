// Feather ignore all

///@function pointy_hex_corner(center,size,i);
///@param center
///@param size
///@param i
function pointy_hex_corner(argument0, argument1, argument2) {

	var center = argument0;
	var size = argument1;
	var i = argument2;
	var angle_deg = 60*i-30;
	var angle_rad = pi/180*angle_deg;

	return [center[X]+size*cos(angle_rad),center[Y]+size*sin(angle_rad)];


}
