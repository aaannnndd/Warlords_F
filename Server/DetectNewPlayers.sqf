#include "..\warlords_constants.hpp"

while {!WL2_missionEnd} do {
	_newPlayers = WL2_allWarlords select {!isNull _x && ((_x getVariable ["WL2_detectedByServerSince", -1]) == -1) || (isPlayer _x && isNil {missionNamespace getVariable format ["WL2_teamCheckOK_%1", getPlayerUID _x]})};
	{
		_x spawn WL2_fnc_setupNewWarlord;
	} forEach _newPlayers;
	
	uiSleep WL_TIMEOUT_STANDARD;
};