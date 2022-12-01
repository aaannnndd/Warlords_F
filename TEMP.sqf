
{
	_x setVariable ["objectArea", triggerArea ((_x nearObjects ["EmptyDetector", 100]) # 0)];
	if (isNil {_x getVariable "WL2_services"}) then {
		_x setVariable ["WL2_services", []];
	};
	if (isNil {_x getVariable "WL2_canBeBase"}) then {
		_x setVariable ["WL2_canBeBase", TRUE];
	};
	_x setVariable ["WL2_fastTravelEnabled", TRUE];
} forEach WL2_allSectors;

{_x enableSimulation FALSE} forEach allMissionObjects "EmptyDetector";