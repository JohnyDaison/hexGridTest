///@function Orientation(f0, f1, f2, f3, b0, b1, b2, b3, start_angle)
///@param f0
///@param f1
///@param f2
///@param f3
///@param b0
///@param b1
///@param b2
///@param b3
///@param start_angle
function Orientation(argument0, argument1, argument2, argument3, argument4, argument5, argument6, argument7, argument8) {

	enum ori {
		f0,
		f1,
		f2,
		f3,
		b0,
		b1,
		b2,
		b3,
		start_angle
	}

	var f0 = argument0;
	var f1 = argument1;
	var f2 = argument2;
	var f3 = argument3;
	var b0 = argument4;
	var b1 = argument5;
	var b2 = argument6;
	var b3 = argument7;
	var start_angle = argument8;

	return [f0,f1,f2,f3,b0,b1,b2,b3,start_angle];



}
