#include "..\warlords_constants.hpp"

params ["_unit", ["_mode", "init"]];

switch (_mode) do {
	case "init": {
		_scriptHandle = scriptNull;
		if !(isPlayer _unit) then {
			_scriptHandle = [_unit, "main"] spawn WL2_fnc_mainAIHandle;
		};
		_unit setVariable ["WL2_AIControlScript", _scriptHandle];
		_unit spawn {
			params ["_unit"];
			waitUntil {sleep WL_TIMEOUT_STANDARD; isPlayer _unit || !alive _unit};
			terminate (_unit getVariable "WL2_AIControlScript");
			waitUntil {sleep WL_TIMEOUT_STANDARD; !isPlayer _unit || !alive _unit};
			if (alive _unit) then {
				_unit setDamage 1;
			};
		};
	};
	case "main": {
		while {!WL2_missionEnd} do {
			sleep 3;
		};
	};
};