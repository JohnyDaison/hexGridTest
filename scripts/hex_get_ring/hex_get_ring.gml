// Feather ignore all

///@function cube_ring(center_hex, radius)
///@param center_hex
///@param radius;
function hex_get_ring(argument0, argument1) {
	var center = argument0;
	var radius = argument1;
	var results = [];
	var c = 0;

	var hex = hex_add(center, hex_scale(hex_direction(4), radius));
	for (var i=0;i<6;i++) {
		for (var j=0;j<radius;j++) {
			results[c] = hex;
			hex = hex_neighbour(hex,i);
			c++;
		}
	}

	return results;


}
