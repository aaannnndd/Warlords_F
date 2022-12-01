#include "..\warlords_constants.hpp"

params ["_customDropzone"];

["RequestMenu_close"] call WL2_fnc_setupUI;

if (_customDropzone) then {
	WL2_targetSector = player;
	[player, -WL2_dropCost_far] call WL2_fnc_fundsControl;
} else {
	[player, -WL2_dropCost] call WL2_fnc_fundsControl;
	"Dropzone" call WL2_fnc_announcer;
	[toUpper localize "STR_A3_WL_popup_airdrop_selection"] spawn WL2_fnc_smoothText;
	if !(visibleMap) then {
		processDiaryLink createDiaryLink ["Map", player, ""];
		WL_CONTROL_MAP ctrlMapAnimAdd [0, 1, [WL2_mapSize / 2, WL2_mapSize / 2]];
		ctrlMapAnimCommit WL_CONTROL_MAP;
	};
	WL2_targetSector = objNull;
	WL2_currentSelection = WL_ID_SELECTION_ORDERING_AIRDROP;
	WL2_orderedAssetRequirements = [];
	sleep 0.25;

	"dropping" spawn WL2_fnc_sectorSelectionHandle;

	waitUntil {sleep WL_TIMEOUT_MIN; !isNull WL2_targetSector || !visibleMap || WL2_currentSelection == WL_ID_SELECTION_VOTING};

	["dropping", "end"] call WL2_fnc_sectorSelectionHandle;

	if (WL2_currentSelection == WL_ID_SELECTION_ORDERING_AIRDROP) then {
		WL2_currentSelection = WL_ID_SELECTION_NONE;
	};
};

if (isNull WL2_targetSector) exitWith {
	"Canceled" call WL2_fnc_announcer;
	[toUpper localize "STR_A3_WL_airdrop_canceled"] spawn WL2_fnc_smoothText;
	[player, WL2_dropCost] call WL2_fnc_fundsControl;
};

if (WL2_targetSector distance2D player <= 300) then {
	playSound3D ["A3\Data_F_Warlords\sfx\flyby.wss", objNull, FALSE, [(position WL2_targetSector) # 0, (position WL2_targetSector) # 1, 100]];
};

_dropInfo = [];
{
	_dropInfo pushBack (_x # 3);
	_dropInfo pushBack (_x # 4);
} forEach WL2_dropPool;

WL2_dropPool = [];
WL2_vehsInBasket = 0;
WL2_matesInBasket = 0;

"Airdrop" call WL2_fnc_announcer;
[toUpper localize "STR_A3_WL_airdrop_underway"] spawn WL2_fnc_smoothText;

_assets = ["requestAssetArray", [_dropInfo, WL2_targetSector]] call WL2_fnc_sendClientRequest;

{
	[player, _x] call WL2_fnc_newAssetHandle;
} forEach _assets;

[] spawn WL2_fnc_refreshOSD;