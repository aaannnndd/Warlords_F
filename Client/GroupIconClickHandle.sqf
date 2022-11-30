#include "..\warlords_constants.inc"

if !(WL2_currentSelection in [WL_ID_SELECTION_VOTING, WL_ID_SELECTION_VOTED, WL_ID_SELECTION_ORDERING_AIRCRAFT, WL_ID_SELECTION_ORDERING_AIRCRAFT, WL_ID_SELECTION_ORDERING_AIRDROP, WL_ID_SELECTION_FAST_TRAVEL, WL_ID_SELECTION_FAST_TRAVEL_CONTESTED, WL_ID_SELECTION_SCAN]) exitWith {WL2_highlightedSector = objNull};

private _sector = (_this # 1) getVariable ["WL2_sector", objNull];

if (isNull _sector) exitWith {};

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
	switch (WL2_currentSelection) do {
		case WL_ID_SELECTION_VOTING;
		case WL_ID_SELECTION_VOTED: {
			WL2_targetVote = _sector;
			_variableFormat = format ["WL2_targetVote_%1", getPlayerUID player];
			missionNamespace setVariable [_variableFormat, _sector];
			publicVariableServer _variableFormat;
			if (WL2_currentSelection == WL_ID_SELECTION_VOTING) then {
				WL2_currentSelection = WL_ID_SELECTION_VOTED;
			};
			playSound "AddItemOK";
		};
		case WL_ID_SELECTION_ORDERING_AIRCRAFT;
		case WL_ID_SELECTION_FAST_TRAVEL;
		case WL_ID_SELECTION_FAST_TRAVEL_CONTESTED;
		case WL_ID_SELECTION_ORDERING_AIRDROP: {
			WL2_targetSector = _sector;
			playSound "AddItemOK";
		};
		case WL_ID_SELECTION_SCAN: {
			if ((_sector getVariable [format ["WL2_lastScanEnd_%1", side group player], -9999]) < (WL_SYNCED_TIME) - WL2_scanCooldown) then {
				WL2_targetSector = _sector;
				playSound "AddItemOK";
			} else {
				playSound "AddItemFailed";
			};
		};
	};
} else {
	playSound "AddItemFailed";
};