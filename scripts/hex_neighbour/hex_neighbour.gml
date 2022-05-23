///@function hex_neighbor(hex, dir)
///@param hex
///@param dir
function hex_neighbour(argument0, argument1) {
	var hex = argument0;
	var dir = argument1;

	return hex_add(hex, hex_direction(dir));


}
