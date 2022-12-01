#include "..\warlords_constants.hpp"

_uniform = uniform player;

["RequestMenu_close"] call WL2_fnc_setupUI;
[player, -WL2_arsenalCost] call WL2_fnc_fundsControl;
["Open", TRUE] spawn BIS_fnc_arsenal;

_uniform spawn {
	waitUntil {!isNull (uiNamespace getVariable ["BIS_fnc_arsenal_cam", objNull])};
	while {!isNull (uiNamespace getVariable ["BIS_fnc_arsenal_cam", objNull])} do {
		if ((backpack player) in WL2_blacklistedBackpacks) then {
			removeBackpack player;
		};
		if !(uniform player in WL2_factionAppropriateUniforms) then {
			player forceAddUniform _this;
		};
		sleep WL_TIMEOUT_MIN;
	};
};