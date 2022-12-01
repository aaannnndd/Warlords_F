#include "..\warlords_constants.hpp"

["server_init"] call BIS_fnc_startLoadingScreen;

{createCenter _x} forEach [WEST, EAST, RESISTANCE, CIVILIAN];

WEST setFriend [EAST, 0];
EAST setFriend [WEST, 0];
RESISTANCE setFriend [WEST, 0];
WEST setFriend [RESISTANCE, 0];
RESISTANCE setFriend [EAST, 0];
EAST setFriend [RESISTANCE, 0];
CIVILIAN setFriend [WEST, 1];
CIVILIAN setFriend [EAST, 1];
CIVILIAN setFriend [RESISTANCE, 1];
WEST setFriend [CIVILIAN, 1];
EAST setFriend [CIVILIAN, 1];
RESISTANCE setFriend [CIVILIAN, 1];

[] spawn {
	while {TRUE} do {
		_overcastPreset = random 1;
		(7200 * timeMultiplier) setOvercast _overcastPreset;
		waitUntil {sleep 600; 0 setFog 0; 10e10 setFog 0; 0 setRain 0; 10e10 setRain 0; simulWeatherSync; abs (overcast - _overcastPreset) < 0.2};
	};
};

"server" call WL2_fnc_varsInit;

addMissionEventHandler ["HandleDisconnect", {
	params ["_unit", "_id", "_uid", "_name"];
	
	WL2_allWarlords = WL2_allWarlords - [_unit];
	_sideID = WL2_competingSides find (side group _unit);
	if (_sideID != -1) then {
		_playerSideArr = WL2_playerIDArr # _sideID;
		_playerSideArr = _playerSideArr - [_uid];
		WL2_playerIDArr set [_sideID, _playerSideArr];
	};

	{
		_x call WL2_fnc_sub_deleteAsset;
	} forEach (missionNamespace getVariable format ["WL2_%1_ownedVehicles", _uid]);
	
	{
		if !(isPlayer _x) then {_x setDamage 1};
	} forEach ((units group _unit) - [_unit]);
	
	missionNamespace setVariable [format ["WL2_%1", _uid], nil];
	missionNamespace setVariable [format ["WL2_%1_ownedVehicles", _uid], nil];
}];

missionNamespace setVariable ["WL2_missionStart", WL_SYNCED_TIME, TRUE];
missionNamespace setVariable ["WL2_wrongTeamGroup", createGroup CIVILIAN, TRUE];
WL2_wrongTeamGroup deleteGroupWhenEmpty FALSE;

if !(isDedicated) then {waitUntil {!isNull player && isPlayer player}};

call WL2_fnc_loadFactionClasses;
call WL2_fnc_sectorsInitServer;
"setup" call WL2_fnc_handleRespawnMarkers;
{_x call WL2_fnc_parsePurchaseList} forEach WL2_competingSides;
[] spawn WL2_fnc_detectNewPlayers;
["server", TRUE] call WL2_fnc_updateSectorArrays;
[] spawn WL2_fnc_targetSelectionHandleServer;
[] spawn WL2_fnc_zoneRestrictionHandleServer;
[] spawn WL2_fnc_incomePayoff;
[] spawn WL2_fnc_garbageCollector;
[] spawn WL2_fnc_targetResetHandleServer;

setTimeMultiplier WL2_timeMultiplier;

[] spawn {
	while {TRUE} do {
		waitUntil {sleep WL_TIMEOUT_LONG; daytime > 20 || daytime < 5};
		setTimeMultiplier ((WL2_timeMultiplier * 4) min 24);
		waitUntil {sleep WL_TIMEOUT_LONG; daytime < 20 && daytime > 5};
		setTimeMultiplier WL2_timeMultiplier;
	};
};

{
	_x spawn {
		_side = _this;
		while {!WL2_missionEnd} do {
			waitUntil {sleep WL_TIMEOUT_LONG; ((missionNamespace getVariable format ["WL2_currentTarget_%1", _side]) getVariable ["WL2_owner", sideUnknown]) == _side};
			sleep WL_TIMEOUT_LONG;
			if (((missionNamespace getVariable format ["WL2_currentTarget_%1", _side]) getVariable ["WL2_owner", sideUnknown]) == _side) then {
				[_side, objNull] call WL2_fnc_selectTarget;
			};
		};
	};
} forEach WL2_competingSides;

["server_init"] call BIS_fnc_endLoadingScreen;