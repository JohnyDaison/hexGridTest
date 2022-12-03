// Feather ignore all

///@function hex_distance(hex_a, hex_b)
///@param hex_a
///@param hex_b
function hex_distance(argument0, argument1) {

	var a = argument0;
	var b = argument1;

	return hex_length(hex_subtract(a, b));


}
