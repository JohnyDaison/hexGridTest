// Feather ignore all

///@function hex_passable(hex);
///@description Returns whether the provided hex is passable or not (returns 1 if marked passable, -1 if it contains an instance and -2 if marked impassable)
///@param {array} hex
function hex_passable(argument0) {

	var hex = argument0;
	var hex_key = hex_get_key(hex);
	var field_map = combat_master.field_map;
	var map = field_map[? hex_key];
	if (map[? "passable"] == false) {
		return -2;
	}
	else if (instance_exists(map[? "instance"])) {
		return -1;
	}
	else if (map[? "status"] == e_hex_status.WALL) {
		return -3;
	}
	else {
		return true;
	}


}
