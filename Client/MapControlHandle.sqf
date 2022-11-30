#include "..\warlords_constants.inc"

WL2_highlightedSector = objNull;

addMissionEventHandler ["Map", {
	WL2_highlightedSector = objNull;
	WL2_hoverSamplePlayed = FALSE;
	if (_this # 0) then {
		if (isNull WL_TARGET_FRIENDLY && WL2_currentSelection == WL_ID_SELECTION_VOTING) then {
			WL_CONTROL_MAP ctrlMapAnimAdd [0, 1, [WL2_mapSize / 2, WL2_mapSize / 2]];
			ctrlMapAnimCommit WL_CONTROL_MAP;
		};
	};
}];

while {!WL2_missionEnd} do {
	if (time == 0) then {
		if (isMultiplayer) then {
			if (isServer) then {
				waitUntil {!isNull (findDisplay 52)};
				uiNamespace setVariable ["WL2_mapControl", (findDisplay 52) displayCtrl 51];
			} else {
				waitUntil {!isNull (findDisplay 53)};
				uiNamespace setVariable ["WL2_mapControl", (findDisplay 53) displayCtrl 51];
			};
		} else {
			waitUntil {!isNull (findDisplay 37) || time > 0};
			if (time > 0) exitWith {uiNamespace setVariable ["WL2_mapControl", (findDisplay 52) displayCtrl 54]};
			uiNamespace setVariable ["WL2_mapControl", (findDisplay 37) displayCtrl 51];
		};
	} else {
		waitUntil {!isNull (findDisplay 12) || !isNull (findDisplay 160)};
		if !(isNull (findDisplay 12)) then {
			uiNamespace setVariable ["WL2_mapControl", (findDisplay 12) displayCtrl 51];
		} else {
			uiNamespace setVariable ["WL2_mapControl", (findDisplay 160) displayCtrl 51];
		};
	};
	
	if (isNull ((ctrlParent WL_CONTROL_MAP) getVariable ["WL2_sectorInfoBox", controlNull])) then {
		(ctrlParent WL_CONTROL_MAP) setVariable ["WL2_sectorInfoBox", (ctrlParent WL_CONTROL_MAP) ctrlCreate ["RscStructuredText", 9999000]];
		((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlSetBackgroundColor [0, 0, 0, 0];
		((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlSetTextColor [1,1,1,1];
		((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlEnable FALSE;
		
		[] spawn WL2_fnc_mapDrawHandle;
	};
	
	uiSleep WL_TIMEOUT_STANDARD;
};