#include "..\warlords_constants.hpp"

while {TRUE} do {
	sleep WL_SECTOR_PAYOFF_PERIOD;
	{
		_side = _x;
		_income = _side call WL2_fnc_income;
		{
			[_x, _income] call WL2_fnc_fundsControl;
		} forEach (WL2_allWarlords select {side group _x == _side});
	} forEach WL2_competingSides;
};