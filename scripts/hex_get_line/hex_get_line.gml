// Feather ignore all

///@function hex_get_line(hex_a, hex_b)
///@param hex_a
///@param hex_b
function hex_get_line(argument0, argument1) {

	var a = argument0;
	var b = argument1;
	var N = hex_distance(a, b);
	var a_nudge = Hex(a[h.q] + 0.000001, a[h.r] + 0.000001, a[h.s] - 0.000002);
	var b_nudge = Hex(b[h.q] + 0.000001, b[h.r] + 0.000001, b[h.s] - 0.000002);
	var results = [];
	var step = 1.0 / max(N, 1);

	for (var i = 0; i <= N; i++) {
	    results[i] = hex_round(hex_lerp(a_nudge, b_nudge, step * i));
	}

	return results;



}
