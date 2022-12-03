// Feather ignore all

///@function hex_diagonal_neighbor(hex, dir)
///@param hex
///@param dir
function hex_diagonal_neighbour(argument0, argument1) {

#macro hex_diagonals return_diagonals()

	var hex = argument0;
	var dir = argument1;

	var hex_diag = hex_diagonals;

	return hex_add(hex, hex_diag[dir]);


}
