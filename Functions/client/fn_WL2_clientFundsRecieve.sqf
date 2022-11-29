#include "..\warlords_constants.inc"

params [ "_playerPriorCP", "_event"];

switch (_event) do {
	case "succes": { 
		[player, -1000] call BIS_fnc_WL2_fundsControl;
		[player, _playerPriorCP] call BIS_fnc_WL2_fundsControl;
		[toUpper localize "STR_A3_WL_cp_recieved"] spawn BIS_fnc_WL2_smoothText;
	};
	case "fail": { 
		[toUpper localize "STR_A3_WL_cp_failed"] spawn BIS_fnc_WL2_smoothText;
	};
};