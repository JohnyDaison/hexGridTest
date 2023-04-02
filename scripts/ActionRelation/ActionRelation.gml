function ActionRelation() constructor {
	possible = true;
	pointCostModifier = 0;
	pointCostMultiplier = 1;
	
	static copyFrom = function (_otherRelation) {
		possible = _otherRelation.possible;
		pointCostModifier = _otherRelation.pointCostModifier;
		pointCostMultiplier = _otherRelation.pointCostMultiplier;
	}
}