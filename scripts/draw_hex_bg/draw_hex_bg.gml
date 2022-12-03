// Feather ignore all

function draw_hex_bg() {
	for (var r=0;r<=map_height;r++) {
		var r_offset = floor(r/2);
		for (var q=-r_offset;q<=map_width-r_offset;q++) {
			var hex = Hex(q,r,-q-r);
			if (!hex_exists(hex)) {
				continue;
			}
			var map_key = hex_get_key(hex);
			var map = global.combat_map[? map_key];
			var corners = polygon_corners(hex,layout);
			draw_set_alpha(0.15);
			draw_primitive_begin(pr_trianglefan);
			for (var k=0;k<6;k++) {
				var corner = corners[k]
				var x1 = corner[X];
				var y1 = corner[Y];
				draw_vertex(x1,y1);
			}
			draw_primitive_end();
			draw_set_alpha(1);
		}
	}

	// Reachable Hexes
	/*var reachable = false;
	draw_set_color(c_aqua);
	draw_set_alpha(0.5);
	if (is_array(reachable_list)) {
		for (var i=0;i<array_length_1d(reachable_list);i++) {
			var hex = reachable_list[i];
			var corners = polygon_corners(hex,layout);
			draw_primitive_begin(pr_trianglefan);
			for (var k=0;k<6;k++) {
				var corner = corners[k]
				var x1 = corner[X];
				var y1 = corner[Y];
				draw_vertex(x1,y1);
			}
			draw_primitive_end();
			if (array_equals(hex,selected_hex)) {
				reachable = true;
			}
		}
	}
	draw_set_alpha(1);*/


}
