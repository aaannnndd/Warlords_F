#include "..\warlords_constants.hpp"

params ["_class", "_cost"];

"Dropzone" call WL2_fnc_announcer;
[toUpper localize "STR_A3_WL_popup_airdrop_selection_water"] spawn WL2_fnc_smoothText;
if !(visibleMap) then {
	processDiaryLink createDiaryLink ["Map", player, ""];
	WL_CONTROL_MAP ctrlMapAnimAdd [0, 1, [WL2_mapSize / 2, WL2_mapSize / 2]];
	ctrlMapAnimCommit WL_CONTROL_MAP;
};
WL2_waterDropPos = [];
WL2_currentSelection = WL_ID_SELECTION_ORDERING_NAVAL;
sleep 0.25;

_mapClickEH = addMissionEventHandler ["MapSingleClick", {
	params ["_units", "_pos", "_alt", "_shift"];
	if (surfaceIsWater _pos) then {
		WL2_waterDropPos = _pos;
	} else {
		playSound "AddItemFailed";
	};
}];

waitUntil {sleep WL_TIMEOUT_MIN; count WL2_waterDropPos > 0 || !visibleMap || WL2_currentSelection == WL_ID_SELECTION_VOTING};

if (WL2_currentSelection == WL_ID_SELECTION_ORDERING_NAVAL) then {
	WL2_currentSelection = WL_ID_SELECTION_NONE;
};

removeMissionEventHandler ["MapSingleClick", _mapClickEH];

if (count WL2_waterDropPos == 0) exitWith {
	[player, _cost] call WL2_fnc_fundsControl;
	"Canceled" call WL2_fnc_announcer;
	[toUpper localize "STR_A3_WL_airdrop_canceled"] spawn WL2_fnc_smoothText;
};

if (WL2_waterDropPos distance2D player <= 300) then {
	playSound3D ["A3\Data_F_Warlords\sfx\flyby.wss", objNull, FALSE, [WL2_waterDropPos # 0, WL2_waterDropPos # 1, 100]];
};

WL2_waterDropPos set [2, 0];
"Airdrop" call WL2_fnc_announcer;
[toUpper localize "STR_A3_WL_airdrop_underway"] spawn WL2_fnc_smoothText;
playSound "AddItemOK";

_asset = ["requestAsset", [_class, WL2_waterDropPos]] call WL2_fnc_sendClientRequest;

[player, _asset] call WL2_fnc_newAssetHandle;