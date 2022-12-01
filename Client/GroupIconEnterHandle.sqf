#include "..\warlords_constants.hpp"

private _sector = (_this # 1) getVariable ["WL2_sector", objNull];

if (isNull _sector) exitWith {WL2_highlightedSector = objNull; ((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlShow FALSE; ((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlEnable FALSE};

private _selectionActive = WL2_currentSelection in [WL_ID_SELECTION_VOTING, WL_ID_SELECTION_VOTED, WL_ID_SELECTION_ORDERING_AIRCRAFT, WL_ID_SELECTION_ORDERING_AIRDROP, WL_ID_SELECTION_FAST_TRAVEL, WL_ID_SELECTION_FAST_TRAVEL_CONTESTED, WL_ID_SELECTION_SCAN];
private _services = (_sector getVariable "WL2_services");
private _airstrip = "A" in _services;
private _helipad = "H" in _services;
private _harbor = "W" in _services;
_scanCD = if (WL2_scanEnabled) then {((_sector getVariable [format ["WL2_lastScanEnd_%1", side group player], -9999]) + WL2_scanCooldown - WL_SYNCED_TIME) max 0} else {-1};
if (_scanCD == 0) then {_scanCD = -1};

((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlSetPosition [(getMousePosition # 0) + safeZoneW / 100, (getMousePosition # 1) + safeZoneH / 50, safeZoneW, safeZoneH];
((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlCommit 0;
((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlSetStructuredText parseText format [
	if (_scanCD == -1) then {
		"<t shadow = '2' size = '%1'>%2<br/>+%3 %4/%5%6%7%8%9%10%11</t>"
	} else {
		"<t shadow = '2' size = '%1'>%2<br/>+%3 %4/%5%6%7%8%9%10%11<br/>%12: <t color = '#ff4b4b'>%13</t></t>"
	},
	(1 call WL2_fnc_sub_purchaseMenuGetUIScale),
	_sector getVariable "WL2_name",
	_sector getVariable "WL2_value",
	localize "STR_A3_WL_unit_cp",
	localize "STR_A3_rscmpprogress_min",
	if (_airstrip || _helipad || _harbor) then {"<br/>"} else {""},
	if (_airstrip) then {localize "STR_A3_WL_param32_title"} else {""},
	if (_airstrip && (_helipad || _harbor)) then {", "} else {""},
	if (_helipad) then {localize "STR_A3_WL_module_service_helipad"} else {""},
	if ((_airstrip || _helipad) && _harbor) then {", "} else {""},
	if (_harbor) then {localize "STR_A3_WL_param30_title"} else {""},
	localize "STR_A3_WL_param_scan_timeout",
	ceil _scanCD
];

((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlShow TRUE;
((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlEnable TRUE;

if (!_selectionActive) exitWith {
	if ((_sector getVariable "WL2_owner") == WL2_playerSide) then {
		WL_CONTROL_MAP ctrlMapCursor ["Track", "HC_overFriendly"];
	} else {
		WL_CONTROL_MAP ctrlMapCursor ["Track", "HC_overEnemy"];
	};
	WL2_highlightedSector = objNull
};

private _availableSectors = (switch (WL2_currentSelection) do {
	case WL_ID_SELECTION_VOTING;
	case WL_ID_SELECTION_VOTED: {WL2_sectorsArray # 1};
	case WL_ID_SELECTION_ORDERING_AIRCRAFT: {(WL2_sectorsArray # 0) select {WL2_orderedAssetRequirements isEqualTo (WL2_orderedAssetRequirements arrayIntersect (_x getVariable "WL2_services"))}};
	case WL_ID_SELECTION_ORDERING_AIRDROP: {WL2_sectorsArray # 0};
	case WL_ID_SELECTION_FAST_TRAVEL: {(WL2_sectorsArray # 2) select {_x getVariable "WL2_fastTravelEnabled"}};
	case WL_ID_SELECTION_FAST_TRAVEL_CONTESTED: {[WL_TARGET_FRIENDLY]};
	case WL_ID_SELECTION_SCAN: {WL2_sectorsArray # 3};
});

if (_sector in _availableSectors) then {
	WL_CONTROL_MAP ctrlMapCursor ["Track", "HC_overMission"]; 
	WL2_highlightedSector = _sector;
	if !(WL2_hoverSamplePlayed) then {
		playSound "clickSoft";
		WL2_hoverSamplePlayed = TRUE;
	};
} else {
	WL_CONTROL_MAP ctrlMapCursor ["Track", "HC_unsel"]; 
	WL2_highlightedSector = objNull;
};