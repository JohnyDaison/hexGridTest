// Feather ignore all

///@function Hex(q, r, s);
///@param q
///@param r
///@param s
function Hex(argument0, argument1, argument2) {

	enum h {
		q,
		r,
		s
	}

	var q = argument0;
	var r = argument1;
	var s = argument2;
	var sum = q+r+s;
	if (round(sum) != 0) {
		show_debug_message("q + r + s must be 0");
	}
	else {
	    return [q,r,s];
	}


}
