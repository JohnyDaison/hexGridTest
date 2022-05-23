///@function hex_get_los(hex,range);
///@description Returns an array of hexes visible within the range
///@param {array} hex
///@param {real} range
function hex_get_los(argument0, argument1) {

	var center = argument0;
	var range = argument1;
	var visible_arr = [];
	var c = 0;
	var p = 0;
	var invalid_dir = [];

	if (!hex_exists(center)) {
		return visible_arr;
	}

	for (var r=0;r<range;r++) {
		var ring_arr = hex_get_ring(center,r);
		for (var i=0;i<array_length_1d(ring_arr);i++) {
			for (var k=0;k<array_length_1d(invalid_dir);k++) {
				if (i == invalid_dir[k]) {
					continue;
				}
			}
			var line = hex_get_line(center,ring_arr[i]);
			var line_valid = true;
			for (var k=0;k<array_length_1d(line);k++) {
				if (!hex_exists(line[k])) {
					line_valid = false;
					break;
				}
				var inst = hex_get_passable(line[k]);
				if (inst < 0) {
					line_valid = false;
					break;
				}
				else {
					if (inst.id != unit.id) {
						if (inst.object_index == unit.object_index) {
							line_valid = false;
							break;
						}
					}
				}
			}
			if (line_valid) {
				var len = array_length_1d(line);
				for (var k=0;k<len;k++) {
					visible_arr[c] = line[k];
					c++;
				}
			}
			else {
				invalid_dir[p] = i;
				p++;
			}
		}
	}

	return visible_arr;


}
