#include "..\warlords_constants.inc"

params ["_newUnit", ["_corpse", objNull]];

WL2_allWarlords = WL2_allWarlords - [_corpse];

if (_newUnit getVariable ["WL2_ignore", FALSE]) exitWith {};

[_newUnit] spawn {
	params ["_newUnit"];
	waitUntil {!isNull group _newUnit};
	
	if ((side group _newUnit) in WL2_competingSides) then {
		WL2_allWarlords pushBackUnique _newUnit;
		
		if !(isDedicated) then {
			if ((side group _newUnit) == WL2_playerSide) then {
				call WL2_fnc_refreshIconsToDraw;
			};
		};
		
		if (isServer) then {
			_newUnit call WL2_fnc_mainAIHandle;
			_base = WL_BASES # (WL_BASES findIf {(_x getVariable "WL2_owner") == side group _newUnit});
			if (time == 0 || _newUnit inArea (_base getVariable "objectAreaComplete")) then {
				[_newUnit, FALSE] remoteExec ["allowDamage", _newUnit];
				_protectionEnd = WL_SYNCED_TIME + WL_RESPAWN_PROTECTION_DURATION;
				waitUntil {sleep WL_TIMEOUT_STANDARD; !alive _newUnit || WL_SYNCED_TIME >= _protectionEnd || !(_newUnit inArea (_base getVariable "objectAreaComplete"))};
				[_newUnit, TRUE] remoteExec ["allowDamage", _newUnit];
			};
		};
	};
};

if (local _newUnit) then {
	[group _newUnit, 0] setWaypointPosition [getPosASL _newUnit, -1];

	if (_newUnit == player) then {
		detach WL2_enemiesCheckTrigger;
		WL2_enemiesCheckTrigger attachTo [player, [0, 0, 0]];
	};
};