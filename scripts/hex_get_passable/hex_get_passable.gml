// Feather ignore all

///@function hex_get_passable(hex);
///@description Returns whether a hex is passable or not
///@param hex
function hex_get_passable(argument0) {

	var hex = argument0;
	if (!hex_exists(hex)) {
		return -1;
	}
	var hex_key = hex_get_key(hex);
	var hex_map = field_map[? hex_key];
	if (hex_map[? "passable"] == false) {
		return -2;
	}
	else if (hex_map[? "status"] == e_hex_status.WALL) {
		return -3;
	}
	else {
		var inst = hex_map[? "instance"];
		if (instance_exists(inst)) {
			return inst;
		}
		else {
			return 1;
		}
	}


}
