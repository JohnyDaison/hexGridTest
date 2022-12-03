// Feather ignore all

///@function hex_get_path(start_hex,end_hex)
///@param start_hex
///@param end_hex
function hex_get_path(argument0, argument1) {

	var start_hex = argument0;
	var end_hex = argument1;
	var path_array = [];
	if (array_equals(start_hex,end_hex)) {
		return path_array;
	}
	if (!hex_exists(end_hex)) {
		return path_array;
	}

	var frontier = ds_priority_create();
	ds_priority_add(frontier,start_hex,0);
	var cost_so_far = ds_map_create();
	var key = hex_get_key(start_hex);
	var came_from = ds_map_create();
	came_from[? key] = noone;
	cost_so_far[? key] = 0;
	var visited;
	visited = [start_hex];
	var v = 1;
	var fm = combat_master.field_map;

	while (ds_priority_size(frontier) > 0) {
		var current = ds_priority_delete_min(frontier);
		if (!hex_exists(current)) {
			continue;
		}
		var current_key = hex_get_key(current);
		if (array_equals(end_hex,current)) {
			break;
		}
		for (var dir=0;dir<6;dir++) {
			var neighbour = hex_neighbour(current,dir);
			var neighbour_key = hex_get_key(neighbour);
			if (hex_exists(neighbour)) {
				var passable = hex_passable(neighbour);
				var new_cost;
				var map = fm[? neighbour_key];
				new_cost = cost_so_far[? current_key]+map[? "cost"];
				if (passable < 0) {
					new_cost = 10000;
				}
				if (!ds_map_exists(cost_so_far,neighbour_key) || new_cost < cost_so_far[? neighbour_key]) {
					cost_so_far[? neighbour_key] = new_cost;
					var priority = new_cost;
					ds_priority_add(frontier,neighbour,priority);
					visited[v] = neighbour;
					if (array_equals(current,start_hex)) {
						came_from[? neighbour_key] = noone;
					}
					else {
						came_from[? neighbour_key] = current;
					}
					v++;
				}
			}
		}
	}

	ds_map_destroy(cost_so_far);
	ds_priority_destroy(frontier);
	var i = 1;
	var val;
	path_array[0] = end_hex;
	val = came_from[? hex_get_key(path_array[0])];
	while (true) {
		if (val != noone) {
			path_array[i] = val;
			val = came_from[? hex_get_key(val)];
			i++;
		}
		else {
			break;
		}
	}
	var temp_path = path_array;
	var arr_len = array_length_1d(path_array)-1;
	for (var i=0;i<=arr_len;i++) {
		temp_path[i] = path_array[arr_len-i];
	}
	path_array = temp_path;
	ds_map_destroy(came_from);
	return path_array;


}
