///@function cube_spiral(center, radius);
///@param center_hex
///@param radius
function hex_get_spiral(argument0, argument1) {
	var center = argument0;
	var radius = argument1;
	var results = [center]
	var c = 0;
	for (var k=0;k<=radius;k++) {
		var ring_arr = hex_get_ring(center, k);
		for (var i=0;i<array_length_1d(ring_arr);i++) {
			results[c] = ring_arr[i];
			c++;
		}
	}
	return results;


}
