///@function hex_get_cost(hex);
///@description Returns the move cost for the provided hex
///@param {array} hex
function hex_get_cost(argument0) {

	var hex = argument0;
	if (!hex_exists(hex)) {
		return 1000;
	}
	var hex_key = hex_get_key(hex);
	var field_map = combat_master.field_map;
	var hex_map = field_map[? hex_key];
	return hex_map[? "cost"];


}
