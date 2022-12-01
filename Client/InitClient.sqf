#include "..\warlords_constants.hpp"

["client_init"] call BIS_fnc_startLoadingScreen;

waitUntil {!isNull player && isPlayer player};

"client" call WL2_fnc_varsInit;

private _teamCheckOKVarID = format ["WL2_teamCheckOK_%1", getPlayerUID player];

waitUntil {!isNil {missionNamespace getVariable _teamCheckOKVarID}};

if !(missionNamespace getVariable _teamCheckOKVarID) exitWith {
	addMissionEventHandler ["EachFrame", {
		clearRadio;
		{
			deleteMarkerLocal _x;
		} forEach allMapMarkers;
	}];
	sleep 0.1;
	["client_init"] call BIS_fnc_endLoadingScreen;
	player removeItem "ItemMap";
	player removeItem "ItemRadio";
	[player] joinSilent WL2_wrongTeamGroup;
	enableRadio FALSE;
	enableSentences FALSE;
	0 fadeSpeech 0;
	0 fadeRadio 0;
	{_x enableChannel [FALSE, FALSE]} forEach [0,1,2,3,4,5];
	showCinemaBorder FALSE;
	private _camera = "Camera" camCreate position player;
	_camera camSetPos [0, 0, 10];
	_camera camSetTarget [-1000, -1000, 10];
	_camera camCommit 0;
	_camera cameraEffect ["Internal", "Back"];
	waitUntil {!isNull WL_DISPLAY_MAIN};
	WL_DISPLAY_MAIN ctrlCreate ["RscStructuredText", 994001];
	(WL_DISPLAY_MAIN displayCtrl 994001) ctrlSetPosition [safeZoneX, safeZoneY, safeZoneW, safeZoneH];
	(WL_DISPLAY_MAIN displayCtrl 994001) ctrlSetBackgroundColor [0, 0, 0, 0.75];
	(WL_DISPLAY_MAIN displayCtrl 994001) ctrlCommit 0;
	WL_DISPLAY_MAIN ctrlCreate ["RscStructuredText", 994000];
	(WL_DISPLAY_MAIN displayCtrl 994000) ctrlSetPosition [safeZoneX + 0.1, safeZoneY + (safeZoneH * 0.5), safeZoneW, safeZoneH];
	(WL_DISPLAY_MAIN displayCtrl 994000) ctrlCommit 0;
	(WL_DISPLAY_MAIN displayCtrl 994000) ctrlSetStructuredText parseText format [
		"<t shadow = '0'><t size = '%1' color = '#ff4b4b'>%2</t><br/><t size = '%3'>%4</t></t>",
		(2.5 call WL2_fnc_sub_purchaseMenuGetUIScale),
		localize "STR_WL2_switch_teams",
		(1.5 call WL2_fnc_sub_purchaseMenuGetUIScale),
		localize "STR_WL2_switch_teams_info"
	];
};

[] spawn {
	_varFormat = format ["WL2_%1_repositionDone", getPlayerUID player];
	missionNamespace setVariable [_varFormat, FALSE];
	publicVariableServer _varFormat;
	
	_pos = position player;
	_confirmReposition = FALSE;
	while {!_confirmReposition} do {
		waitUntil {player distance _pos > 5};
		uiSleep 1;
		if (player distance _pos > 5) then {
			_confirmReposition = TRUE;
		};
	};

	missionNamespace setVariable [_varFormat, TRUE];
	publicVariableServer _varFormat;
};

if !((side group player) in WL2_competingSides) exitWith {
	["client_init"] call BIS_fnc_endLoadingScreen;
	["Warlords error: Your unit is not a Warlords competitor"] call BIS_fnc_error;
};

uiNamespace setVariable ["WL2_purchaseMenuLastSelection", [0,0,0]];

if !(isServer) then {
	"setup" call WL2_fnc_handleRespawnMarkers;
};
call WL2_fnc_sectorsInitClient;
["client", TRUE] call WL2_fnc_updateSectorArrays;
private _specialStateArray = (WL2_sectorsArray # 6) + (WL2_sectorsArray # 7);
{
	[_x, _x getVariable "WL2_owner", _specialStateArray] call WL2_fnc_sectorMarkerUpdate;
} forEach WL2_allSectors;
if !(isServer) then {
	WL2_playerSide call WL2_fnc_parsePurchaseList;
};
[] spawn WL2_fnc_zoneRestrictionHandleClient;
[] spawn WL2_fnc_sectorCaptureStatus;
[] spawn WL2_fnc_teammatesAvailability;
[] spawn WL2_fnc_forceGroupIconsFunctionality;
[] spawn WL2_fnc_mapControlHandle;

WL2_groupIconClickHandler = addMissionEventHandler ["GroupIconClick", WL2_fnc_groupIconClickHandle];
WL2_groupIconEnterHandler = addMissionEventHandler ["GroupIconOverEnter", WL2_fnc_groupIconEnterHandle];
WL2_groupIconLeaveHandler = addMissionEventHandler ["GroupIconOverLeave", WL2_fnc_groupIconLeaveHandle];

_mapBorderMrkr1 = createMarkerLocal ["WL2_mapBorder1", [(WL2_mapSize / 2) + (WL2_mapSize / 2), -(WL2_mapSize / 2)]];
_mapBorderMrkr2 = createMarkerLocal ["WL2_mapBorder2", [WL2_mapSize + (WL2_mapSize / 2), WL2_mapSize + (WL2_mapSize / 2)]];
_mapBorderMrkr3 = createMarkerLocal ["WL2_mapBorder3", [-(WL2_mapSize / 2), WL2_mapSize + (WL2_mapSize / 2)]];
_mapBorderMrkr4 = createMarkerLocal ["WL2_mapBorder4", [-(WL2_mapSize / 2), WL2_mapSize - (WL2_mapSize / 2)]];

{
	_x setMarkerShapeLocal "RECTANGLE";
	_x setMarkerBrushLocal "SolidFull";
	_x setMarkerColorLocal "ColorBlack";
} forEach [_mapBorderMrkr1, _mapBorderMrkr2, _mapBorderMrkr3, _mapBorderMrkr4];

_mapBorderMrkr1 setMarkerSizeLocal [WL2_mapSize + (WL2_mapSize / 2), (WL2_mapSize / 2)];
_mapBorderMrkr2 setMarkerSizeLocal [(WL2_mapSize / 2), WL2_mapSize + (WL2_mapSize / 2)];
_mapBorderMrkr3 setMarkerSizeLocal [WL2_mapSize + (WL2_mapSize / 2), (WL2_mapSize / 2)];
_mapBorderMrkr4 setMarkerSizeLocal [(WL2_mapSize / 2), WL2_mapSize + (WL2_mapSize / 2)];

_mrkrTargetEnemy = createMarkerLocal ["WL2_targetEnemy", position WL2_enemyBase];
_mrkrTargetEnemy setMarkerColorLocal WL2_colorMarkerEnemy;
_mrkrTargetFriendly = createMarkerLocal ["WL2_targetFriendly", position WL2_playerBase];
_mrkrTargetFriendly setMarkerColorLocal WL2_colorMarkerFriendly;

{
	_x setMarkerAlphaLocal 0;
	_x setMarkerSizeLocal [2, 2];
	_x setMarkerTypeLocal "selector_selectedMission";
} forEach [_mrkrTargetEnemy, _mrkrTargetFriendly];

WL2_enemiesCheckTrigger = createTrigger ["EmptyDetector", position player, FALSE];
WL2_enemiesCheckTrigger attachTo [player, [0, 0, 0]];
WL2_enemiesCheckTrigger setTriggerArea [200, 200, 0, FALSE];
WL2_enemiesCheckTrigger setTriggerActivation ["ANY", "PRESENT", TRUE];
WL2_enemiesCheckTrigger setTriggerStatements [
	"{(side group _x) getFriend WL2_playerSide == 0} count thislist > 0",
	"",
	""
];
player addEventHandler ["GetInMan", {detach WL2_enemiesCheckTrigger; WL2_enemiesCheckTrigger attachTo [vehicle player, [0, 0, 0]]}];
player addEventHandler ["GetOutMan", {detach WL2_enemiesCheckTrigger; WL2_enemiesCheckTrigger attachTo [player, [0, 0, 0]]}];

player addEventHandler ["Fired", WL2_fnc_sub_restrictMines];
player addEventHandler ["Killed", {
	WL2_loadoutApplied = FALSE;
	["RequestMenu_close"] call WL2_fnc_setupUI;
	
	WL2_lastLoadout = +getUnitLoadout player;
	private _varName = format ["WL2_purchasable_%1", WL2_playerSide];
	private _gearArr = (missionNamespace getVariable _varName) # 5;
	private _lastLoadoutArr = _gearArr # 0;
	private _text = _savedLoadoutArr # 5;
	private _text = localize "STR_A3_WL_last_loadout_info";
	_text = _text + "<br/><br/>";
	{
		switch (_forEachIndex) do {
			case 0;
			case 1;
			case 2;
			case 3;
			case 4: {
				if (count _x > 0) then {
					_text = _text + (getText (configFile >> "CfgWeapons" >> _x # 0 >> "displayName")) + "<br/>";
				};
			};
			case 5: {
				if (count _x > 0) then {
					_text = _text + (getText (configFile >> "CfgVehicles" >> _x # 0 >> "displayName")) + "<br/>";
				};
			};
		};
	} forEach WL2_lastLoadout;
	_lastLoadoutArr set [5, _text];
	_gearArr set [0, _lastLoadoutArr];
	(missionNamespace getVariable _varName) set [5, _gearArr];
}];

if (WL2_arsenalEnabled) then {
	call WL2_fnc_sub_arsenalSetup;
};

[] spawn {
	waitUntil {uiSleep WL_TIMEOUT_SHORT; !isNull WL_CONTROL_MAP};
	WL_CONTROL_MAP ctrlMapAnimAdd [0, 0.35, WL2_playerBase];
	ctrlMapAnimCommit WL_CONTROL_MAP;
};

["client_init"] call BIS_fnc_endLoadingScreen;

sleep 0.01;

{_x setMarkerAlphaLocal 0} forEach WL2_sectorLinks;

call WL2_fnc_refreshCurrentTargetData;
call WL2_fnc_sceneDrawHandle;
call WL2_fnc_targetResetHandle;
player call WL2_fnc_sub_assetAssemblyHandle;
"init" spawn WL2_fnc_hintHandle;
[] spawn WL2_fnc_music;

(format ["WL2_%1_friendlyKillPenaltyEnd", getPlayerUID player]) addPublicVariableEventHandler WL2_fnc_friendlyFireHandleClient;

waitUntil {WL_PLAYER_FUNDS != -1};

["OSD"] spawn WL2_fnc_setupUI;

[] spawn {
	waitUntil {sleep 1; isNull WL_TARGET_FRIENDLY};
	_t = WL_SYNCED_TIME + 10;
	waitUntil {sleep WL_TIMEOUT_SHORT; WL_SYNCED_TIME > _t || visibleMap};
	if !(visibleMap) then {
		[toUpper localize "STR_A3_WL_tip_voting", 5] spawn WL2_fnc_smoothText;
	};
};

[] spawn {
	_t = WL_SYNCED_TIME + 10;
	waitUntil {sleep WL_TIMEOUT_STANDARD; WL_SYNCED_TIME > _t && !isNull WL_TARGET_FRIENDLY};
	sleep 5;
	while {!WL2_purchaseMenuDiscovered} do {
		[format [toUpper localize "STR_A3_WL_tip_menu", (actionKeysNamesArray "Gear") # 0], 5] spawn WL2_fnc_smoothText;
		sleep 30;
	};
};

sleep 1;

"Initialized" call WL2_fnc_announcer;
[toUpper localize "STR_A3_WL_popup_init"] spawn WL2_fnc_smoothText;
["maintenance", {(player nearObjects ["All", WL_MAINTENANCE_RADIUS]) findIf {(_x getVariable ["WL2_canRepair", FALSE]) || (_x getVariable ["WL2_canRearm", FALSE])} != -1}] call WL2_fnc_hintHandle;

sleep 1;

[] spawn WL2_fnc_selectedTargetsHandle;
[] spawn WL2_fnc_targetSelectionHandleClient;
[] spawn WL2_fnc_purchaseMenuOpeningHandle;
[] spawn WL2_fnc_assetMapControl;