#include "..\warlords_constants.inc"

params ["_warlord"];

private _startingPos = position _warlord;
private _markers = (side group _warlord) call WL2_fnc_getRespawnMarkers;
private _varFormat = "";

_warlord setVariable ["WL2_detectedByServerSince", WL_SYNCED_TIME];
_warlord setVariable ["WL2_friendlyKillTimestamps", []];
[_warlord, if (WL_SYNCED_TIME < (WL2_missionStart + 30)) then {WL2_startCP} else {WL2_fastTravelCostContested min WL2_startCP}] call WL2_fnc_fundsControl;
_boundToAnotherTeam = FALSE;

if (isPlayer _warlord) then {
	_playerVarID = format ["WL2_teamCheckOK_%1", getPlayerUID _warlord];
	_boundToAnotherTeam = (getPlayerUID _warlord) in (missionNamespace getVariable format ["WL2_boundTo%1", (WL2_competingSides - [side group _warlord]) # 0]);
	missionNamespace setVariable [_playerVarID, !_boundToAnotherTeam];
	(owner _warlord) publicVariableClient _playerVarID;
	
	if !(_boundToAnotherTeam) then {
		(missionNamespace getVariable format ["WL2_boundTo%1", side group _warlord]) pushBackUnique getPlayerUID _warlord;
		_playerSideArr = WL2_playerIDArr # (WL2_competingSides find side group _warlord);
		_playerSideArr pushBackUnique getPlayerUID _warlord;
		_var = format ["WL2_%1", getPlayerUID _warlord];
		
		if (isMultiplayer) then {
			_var addPublicVariableEventHandler WL2_fnc_processClientRequest;
		} else {
			missionNamespace setVariable [_var, ""];
			_var spawn {
				waitUntil {(missionNamespace getVariable _this) != ""};
				[_this, missionNamespace getVariable _this] call WL2_fnc_processClientRequest;
				waitUntil {(missionNamespace getVariable _this) == ""};
			};
		};
		
		_varFormat = format ["WL2_%1_repositionDone", getPlayerUID _warlord];
		waitUntil {!(missionNamespace getVariable [_varFormat, TRUE])};
	} else {
		_warlord setVariable ["WL2_ignore", TRUE, TRUE];
		_warlord enableSimulationGlobal FALSE;
		_warlord hideObjectGlobal TRUE;
		WL2_allWarlords = WL2_allWarlords - [_warlord];
	};
};

if !(_boundToAnotherTeam) then {
	_respawnPos = markerPos selectRandom _markers;

	while {if (isPlayer _warlord) then {!(missionNamespace getVariable [_varFormat, FALSE])} else {_warlord distance2D _respawnPos > 100}} do {
		[_warlord, [_respawnPos, [], 2, "NONE"]] remoteExec ["setVehiclePosition", _warlord];
		uiSleep WL_TIMEOUT_STANDARD;
	};
	
	if (_varFormat != "") then {
		missionNamespace setVariable [_varFormat, FALSE];
	};
	
	_friendlyFireVarName = format ["WL2_%1_friendlyKillPenaltyEnd", getPlayerUID _warlord];
	if ((missionNamespace getVariable _friendlyFireVarName) > WL_SYNCED_TIME) then {
		(owner _warlord) publicVariableClient _friendlyFireVarName;
	};

	[_warlord] call WL2_fnc_respawnHandle;
};