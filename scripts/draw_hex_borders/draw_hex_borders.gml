function draw_hex_borders() {
	draw_set_color(c_white);
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
			if (array_equals(mhex,hex)) {
				array_copy(selected_hex,0,hex,0,array_length_1d(hex));
			}
			for (var i=0;i<6;i++) {
				if (i < 5) {
					var corner = corners[i]
					var corner2 = corners[i+1];
					var x1 = corner[X];
					var y1 = corner[Y];
					var x2 = corner2[X];
					var y2 = corner2[Y];
					draw_line_width(x1,y1,x2,y2,2);
				}
				else {
					var corner = corners[i]
					var corner2 = corners[0];
					var x1 = corner[X];
					var y1 = corner[Y];
					var x2 = corner2[X];
					var y2 = corner2[Y];
					draw_line_width(x1,y1,x2,y2,2);
				}
			}
		}
	}
	for (var r=0;r<=map_height;r++) {
		var r_offset = floor(r/2);
		for (var q=-r_offset;q<=map_width-r_offset;q++) {
			var hex = Hex(q,r,-q-r);
			if (!hex_exists(hex)) {
				continue;
			}
			if (q < -r_offset+5) {
				draw_set_color(c_green);
			}
			else if (q > map_width-r_offset-5) {
				draw_set_color(c_red);
			}
			else {
				continue;
			}
			var map_key = hex_get_key(hex);
			var map = global.combat_map[? map_key];
			var corners = polygon_corners(hex,layout);
			if (array_equals(mhex,hex)) {
				array_copy(selected_hex,0,hex,0,array_length_1d(hex));
			}
			for (var i=0;i<6;i++) {
				if (i < 5) {
					var corner = corners[i]
					var corner2 = corners[i+1];
					var x1 = corner[X];
					var y1 = corner[Y];
					var x2 = corner2[X];
					var y2 = corner2[Y];
					draw_line_width(x1,y1,x2,y2,2);
				}
				else {
					var corner = corners[i]
					var corner2 = corners[0];
					var x1 = corner[X];
					var y1 = corner[Y];
					var x2 = corner2[X];
					var y2 = corner2[Y];
					draw_line_width(x1,y1,x2,y2,2);
				}
			}
		}
	}


}
