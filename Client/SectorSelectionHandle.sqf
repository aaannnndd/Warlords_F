#include "..\warlords_constants.inc"

params ["_event", ["_state", "start"]];

if (_state == "start") then {
	switch (_event) do {
		case "voting": {
			WL2_selection_availableSectors = WL2_sectorsArray # 1;
			WL2_selection_showLinks = TRUE;
		};
		case "dropping": {
			WL2_selection_availableSectors = (WL2_sectorsArray # 0) select {WL2_orderedAssetRequirements isEqualTo (WL2_orderedAssetRequirements arrayIntersect (_x getVariable "WL2_services"))};
			WL2_selection_showLinks = FALSE;
		};
		case "travelling": {
			WL2_selection_availableSectors = (WL2_sectorsArray # 2) select {_x getVariable "WL2_fastTravelEnabled"};
			WL2_selection_showLinks = FALSE;
		};
		case "travelling_contested": {
			WL2_selection_availableSectors = [WL_TARGET_FRIENDLY];
			WL2_selection_showLinks = FALSE;
		};
		case "scan": {
			WL2_selection_availableSectors = WL2_sectorsArray # 3;
			WL2_selection_showLinks = FALSE;
		};
	};
	
	waitUntil {WL2_selectionMapManager == -1};
	
	{
		((_x getVariable "WL2_markers") # 0) setMarkerAlphaLocal WL_CONNECTING_LINE_ALPHA_MIN;
		((_x getVariable "WL2_markers") # 1) setMarkerAlphaLocal WL_CONNECTING_LINE_ALPHA_MIN;
	} forEach (WL2_allSectors - WL2_selection_availableSectors);
	
	if (WL2_selection_showLinks) then {
		{_x setMarkerAlphaLocal WL_CONNECTING_LINE_ALPHA_MAX} forEach WL2_sectorLinks;
	};

	WL2_selectionMapManager = addMissionEventHandler ["EachFrame", {
		if (visibleMap && isNull (findDisplay 160 displayCtrl 51)) then {
			_mapScale = ctrlMapScale WL_CONTROL_MAP;
			_timer = (time % WL_MAP_PULSE_FREQ);
			_timer = if (_timer <= (WL_MAP_PULSE_FREQ / 2)) then {_timer} else {WL_MAP_PULSE_FREQ - _timer};
			_markerSize = linearConversion [0, WL_MAP_PULSE_FREQ / 2, _timer, 1, WL_MAP_PULSE_ICON_SIZE];
			_markerSizeArr = [_markerSize, _markerSize];
			if (WL2_selection_showLinks) then {
				{
					_x setMarkerSizeLocal [WL_CONNECTING_LINE_AXIS * _mapScale * WL2_mapSizeIndex, (markerSize _x) # 1];
				} forEach WL2_sectorLinks;
			};
			{
				if (_x == WL2_targetVote) then {
					((_x getVariable "WL2_markers") # 0) setMarkerSizeLocal [WL_MAP_PULSE_ICON_SIZE, WL_MAP_PULSE_ICON_SIZE];
				} else {
					((_x getVariable "WL2_markers") # 0) setMarkerSizeLocal _markerSizeArr;
				};
			} forEach WL2_selection_availableSectors;
		};
	}];
} else {
	removeMissionEventHandler ["EachFrame", WL2_selectionMapManager];
		
	{
		_mrkrMain = (_x getVariable "WL2_markers") # 0;
		_mrkrMain setMarkerAlphaLocal 1;
		_mrkrMain setMarkerSizeLocal (if !(_x in WL_BASES && WL2_playerSide in (_x getVariable "WL2_revealedBy")) then {[1, 1]} else {[WL_BASE_ICON_SIZE, WL_BASE_ICON_SIZE]});
		((_x getVariable "WL2_markers") # 1) setMarkerAlphaLocal 1;
	} forEach WL2_allSectors;
	
	if (WL2_selection_showLinks) then {
		{_x setMarkerAlphaLocal 0} forEach WL2_sectorLinks;
	};
	WL2_selectionMapManager = -1;
};