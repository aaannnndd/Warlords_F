#include "..\warlords_constants.hpp"

while {TRUE} do {
	waitUntil {(player getVariable ["WL2_zoneRestrictionKillTime", -1]) != -1};
	_killTime = player getVariable "WL2_zoneRestrictionKillTime";
	["trespassing", [WL_SYNCED_TIME, _killTime]] spawn WL2_fnc_setOSDEvent;
	[toUpper localize "STR_A3_WL_zone_warn"] spawn WL2_fnc_smoothText;
	playSound "air_raid";

	waitUntil {(player getVariable "WL2_zoneRestrictionKillTime") == -1 || !alive player};

	player setVariable ["WL2_zoneRestrictionKillTime", -1];
	["trespassing", []] spawn WL2_fnc_setOSDEvent;
};