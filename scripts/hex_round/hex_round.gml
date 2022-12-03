// Feather ignore all

///@function hex_round(hex)
///@param hex
function hex_round(argument0) {

	var hex = argument0;
	var qi = round(hex[h.q]);
	var ri = round(hex[h.r]);
	var si = round(hex[h.s]);
	var q_diff = abs(qi - hex[h.q]);
	var r_diff = abs(ri - hex[h.r]);
	var s_diff = abs(si - hex[h.s]);
	if (q_diff > r_diff && q_diff > s_diff) {
		qi = -ri - si;
	}
	else {
		if (r_diff > s_diff) {
	        ri = -qi - si;
	    }
	    else {
	        si = -qi - ri;
	    }
	}

	return Hex(qi, ri, si);


}
