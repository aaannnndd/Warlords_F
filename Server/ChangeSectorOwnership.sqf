#include "..\warlords_constants.inc"

params ["_sector", "_owner"];

_sector setVariable ["WL2_owner", _owner, TRUE];

private _previousOwners = _sector getVariable "WL2_previousOwners";

if !(_owner in _previousOwners) then {
	_previousOwners pushBack _owner;
	if (time > 0 && count _previousOwners == 1) then {
		{
			[_x, (_sector getVariable "WL2_value") * WL_SECTOR_CAPTURE_REWARD_MULTIPLIER] call WL2_fnc_fundsControl;
		} forEach (WL2_allWarlords select {side group _x == _owner});
	};
};

_previousOwners pushBackUnique _owner;
_sector setVariable ["WL2_previousOwners", _previousOwners, TRUE];

_zoneRestrictionTrgs = _sector getVariable "WL2_zoneRestrictionTrgs";
_detectionTrgs = (if (WL2_fogOfWar != 0) then {_sector getVariable "WL2_detectionTrgs"} else {[]});

{
	if ((_x getVariable "WL2_handledSide") == _owner) then {
		deleteVehicle _x;
	};
} forEach (_zoneRestrictionTrgs + _detectionTrgs);

if (_zoneRestrictionTrgs findIf {!isNull _x} == -1) then {_zoneRestrictionTrgs = []};
if (_detectionTrgs findIf {!isNull _x} == -1) then {_detectionTrgs = []};

if (_sector == (missionNamespace getVariable format ["WL2_currentTarget_%1", _owner])) then {[_owner, objNull] call WL2_fnc_selectTarget};

["server"] call WL2_fnc_updateSectorArrays;

private _enemySide = (WL2_competingSides - [_owner]) # 0;
if (isNull (missionNamespace getVariable format ["WL2_currentTarget_%1", _enemySide])) then {
	missionNamespace setVariable [format ["WL2_resetTargetSelection_server_%1", _enemySide], TRUE];
	WL2_resetTargetSelection_client = TRUE;
	{
		(owner _x) publicVariableClient "WL2_resetTargetSelection_client";
	} forEach (WL2_allWarlords select {side group _x == _enemySide});
	if !(isDedicated) then {
		if (WL2_playerSide != _enemySide) then {
			WL2_resetTargetSelection_client = FALSE;
		};
	};
};