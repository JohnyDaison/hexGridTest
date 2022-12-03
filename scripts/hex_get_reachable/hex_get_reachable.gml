// Feather ignore all

///@function hex_reachable(start, movement);
///@param start_hex
///@param movement
function hex_get_reachable(argument0, argument1) {
	var start_hex = argument0;
	var visited = [];
	if (!hex_exists(start_hex)) {
		return visited;
	}
	var ap = argument1;
	var frontier = ds_priority_create();
	ds_priority_add(frontier,start_hex,0);
	var cost_so_far = ds_map_create();
	var key = hex_get_key(start_hex);
	cost_so_far[? key] = 0;
	visited = [start_hex];
	var v = 1;
	var fm = combat_master.field_map;


	while (ds_priority_size(frontier) > 0) {
		var current = ds_priority_delete_min(frontier);
		var current_key = hex_get_key(current);
		for (var dir=0;dir<6;dir++) {
			var neighbour = hex_neighbour(current,dir);
			var neighbour_key = hex_get_key(neighbour);
			if (hex_exists(neighbour)) {
				var passable = hex_passable(neighbour);
				var unit_cost = -1;
				if (passable != true) {
					if (passable < -1) {
						continue;
					}
					else if (is_ally(neighbour,unit.side)) {
						continue;
					}
					else {
						unit_cost = basic_attack_cost;
					}
				}
				var map = fm[? neighbour_key];
				var new_cost;
				if (unit_cost == -1) {
					new_cost = cost_so_far[? current_key]+map[? "cost"];
				}
				else {
					new_cost = cost_so_far[? current_key]+basic_attack_cost;
				}
				if (new_cost <= ap) {
					if (!ds_map_exists(cost_so_far,neighbour_key) || new_cost < cost_so_far[? neighbour_key]) {
						cost_so_far[? neighbour_key] = new_cost;
						var priority = new_cost;
						ds_priority_add(frontier,neighbour,priority);
						visited[v] = neighbour;
						v++;
					}
				}
			}
		}
	}

	ds_map_destroy(cost_so_far);
	ds_priority_destroy(frontier);

	for (var current_pos=0;current_pos<array_length_1d(visited);current_pos++) {
		for (var i=current_pos;i<array_length_1d(visited);i++) {
			if (i != current_pos) {
				if (array_equals(visited[i],visited[current_pos])) {
					show_debug_message("Pos "+string(current_pos)+" and "+string(i)+" are duplicates!");
				}
			}
		}
	}

	return visited;


}
