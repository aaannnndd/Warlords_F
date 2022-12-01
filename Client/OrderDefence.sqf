#include "..\warlords_constants.hpp"

params ["_class", "_cost", "_offset"];

//[player, -_cost] call WL2_fnc_fundsControl;

if (count _offset != 3) then {
	_offset = [0, 1.5, 0];
};

WL2_currentSelection = WL_ID_SELECTION_DEPLOYING_DEFENCE;

if (visibleMap) then {
	openMap [FALSE, FALSE];
	titleCut ["", "BLACK IN", 0.5];
};

_asset = ["requestAsset", [_class, player modelToWorld _offset, TRUE, TRUE]] call WL2_fnc_sendClientRequest;

_ownedVehiclesVarID = format ["WL2_%1_ownedVehicles", getPlayerUID player];
missionNamespace setVariable [_ownedVehiclesVarID, WL_PLAYER_VEHS + [_asset]];
publicVariableServer _ownedVehiclesVarID;

_asset lock TRUE;
_asset enableWeaponDisassembly FALSE;
_asset disableCollisionWith player;
_asset hideObject FALSE;

player reveal [_asset, 4];
_asset attachTo [player, _offset];
_h = (position _asset) # 2;
detach _asset;
_offset_tweaked = [_offset select 0, _offset select 1, (_offset select 2) - _h];
_asset attachTo [player, _offset_tweaked];

"assembly" call WL2_fnc_hintHandle;

WL2_spacePressed = FALSE;
WL2_backspacePressed = FALSE;

_deployKeyHandle = WL_DISPLAY_MAIN displayAddEventHandler ["KeyDown", {
	if (_this # 1 == 57) then {
		if !(WL2_backspacePressed) then {
			WL2_spacePressed = TRUE;
		};
	};
	if (_this # 1 == 14) then {
		if !(WL2_spacePressed) then {
			WL2_backspacePressed = TRUE;
		};
	};
}];

uiNamespace setVariable ["WL2_deployKeyHandle", _deployKeyHandle];

[] spawn {
	waitUntil {
		sleep WL_TIMEOUT_STANDARD;
		WL2_spacePressed ||
		WL2_backspacePressed ||
		vehicle player != player ||
		!alive player ||
		lifeState player == "INCAPACITATED" ||
		triggerActivated WL2_enemiesCheckTrigger ||
		(WL2_sectorsArray # 0) findIf {player inArea (_x getVariable "objectAreaComplete")} == -1
	};
	if !(WL2_spacePressed) then {
		WL2_backspacePressed = TRUE;
	};
};

waitUntil {sleep WL_TIMEOUT_MIN; WL2_spacePressed || WL2_backspacePressed};

WL_DISPLAY_MAIN displayRemoveEventHandler ["KeyDown", uiNamespace getVariable "WL2_deployKeyHandle"];
uiNamespace setVariable ['WL2_deployKeyHandle', nil];
_offset set [1, _asset distance player];
detach _asset;
missionNamespace setVariable [_ownedVehiclesVarID, WL_PLAYER_VEHS - [_asset]];
publicVariable _ownedVehiclesVarID;
_asset call WL2_fnc_sub_deleteAsset;

["assembly", FALSE] call WL2_fnc_hintHandle;

if (WL2_spacePressed) then {
	playSound "assemble_target";
	waitUntil {isNull _asset};
	_asset = ["requestAsset", [_class, player modelToWorld _offset, TRUE]] call WL2_fnc_sendClientRequest;
	[player, _asset] call WL2_fnc_newAssetHandle;
	_asset enableWeaponDisassembly FALSE;
	_asset setDir direction player;
	player reveal [_asset, 4];
} else {
	[player, _cost] call WL2_fnc_fundsControl;
	"Canceled" call WL2_fnc_announcer;
	[toUpper localize "STR_A3_WL_deploy_canceled"] spawn WL2_fnc_smoothText;
};

if (WL2_currentSelection == WL_ID_SELECTION_DEPLOYING_DEFENCE) then {
	WL2_currentSelection = WL_ID_SELECTION_NONE;
};

sleep 0.1;

showCommandingMenu "";