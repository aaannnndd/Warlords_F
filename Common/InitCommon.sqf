#include "..\warlords_constants.inc"

WL2_allSectors = (entities "Logic") select {count synchronizedObjects _x > 0};

call compile preprocessFileLineNumbers "TEMP.sqf";

if (isMultiplayer) then {
	_initModuleVars = allVariables WL2_initModule;
	
	{
		_param = configName _x;
		
		if ((toLower _param) in _initModuleVars) then {
			_value = paramsArray # _forEachIndex;
			_convertToBool = getNumber (_x >> "isBool") == 1;
			
			if (_convertToBool) then {
				_value = [FALSE, TRUE] # _value;
			};
			
			WL2_initModule setVariable [_param, _value];
		};
	} forEach ("TRUE" configClasses (missionConfigFile >> "Params"));
};

"common" call WL2_fnc_varsInit;

if (!WL2_savingEnabled && isMultiplayer) then {
	enableSaving [FALSE, FALSE];
};

setViewDistance 4000;

call WL2_fnc_playersListHandle;

addMissionEventHandler ["EntityKilled", {
	_this call WL2_fnc_killRewardHandle;
	if (isServer) then {
		_this call WL2_fnc_friendlyFireHandleServer;
	};
}];

addMissionEventHandler ["EntityRespawned", {
	_this call WL2_fnc_respawnHandle;
}];

{
	private _sector = _x;
	_sector setVariable ["WL2_connectedSectors", (synchronizedObjects _sector) select {typeOf _x == "Logic"}];
	_sector setVariable ["objectAreaComplete", [position _sector] + (_sector getVariable "objectArea")];
	_sector spawn WL2_fnc_sectorScanHandle;
	private _otherSectors = WL2_allSectors - [_sector];
	_otherSectors = _otherSectors apply {[_x distance2D _sector, _x]};
	_otherSectors sort TRUE;
	_sector setVariable ["WL2_distanceToNearestSector", _sector distance2D ((_otherSectors # 0) # 1)];
	private _axisA = (_sector getVariable "objectArea") # 0;
	private _axisB = (_sector getVariable "objectArea") # 1;
	_sector setVariable ["WL2_maxAxis", if ((_sector getVariable "objectArea") # 3) then {sqrt ((_axisA ^ 2) + (_axisB ^ 2))} else {_axisA max _axisB}];
} forEach WL2_allSectors;

call WL2_fnc_processRunways;

if (isServer) then {
	call WL2_fnc_initServer;
} else {
	waitUntil {{isNil _x} count [
		"WL2_base1",
		"WL2_base2",
		format ["WL2_currentTarget_%1", WL2_competingSides # 0],
		format ["WL2_currentTarget_%1", WL2_competingSides # 1],
		"WL2_missionStart",
		"WL2_wrongTeamGroup"
	] == 0};
	
	waitUntil {{isNil {_x getVariable "WL2_originalOwner"}} count WL_BASES == 0};

	{
		_sector = _x;
		waitUntil {{isNil {_sector getVariable _x}} count [
			"WL2_owner",
			"WL2_previousOwners",
			"WL2_agentGrp",
			"WL2_revealedBy"
		] == 0};
	} forEach WL2_allSectors;
};

if (!isDedicated && hasInterface) then {call WL2_fnc_initClient};

[] spawn WL2_fnc_missionEndHandle;