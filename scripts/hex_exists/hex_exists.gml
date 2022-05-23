///@function hex_exists(hex);
///@param hex
function hex_exists(argument0) {

	var hex = argument0;
	var map_key = hex_get_key(hex);
	if (!ds_map_exists(field_map,map_key)) {
		return false;
	}
	else {
		return true;
	}


}
