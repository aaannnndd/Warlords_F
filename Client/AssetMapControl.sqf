#include "..\warlords_constants.hpp"

WL2_assetMapClickHandler = addMissionEventHandler ["MapSingleClick", {
	params ["_units", "_pos", "_alt", "_shift"];
	if (_alt && _shift) then {
		if !(isNull WL2_mapAssetTarget) then {
			if ((WL2_mapAssetTarget in WL_PLAYER_VEHS) && count crew WL2_mapAssetTarget > 0) then {
				playSound "AddItemFailed";
				[toUpper localize "STR_WL2_popup_asset_not_empty"] spawn WL2_fnc_smoothText;
			} else {
				playSound "AddItemOK";
				[format [toUpper localize "STR_WL2_popup_asset_deleted", toUpper (WL2_mapAssetTarget getVariable "WL2_iconText")], 2] spawn WL2_fnc_smoothText;
				_ownedVehiclesVarName = format ["WL2_%1_ownedVehicles", getPlayerUID player];
				missionNamespace setVariable [_ownedVehiclesVarName, WL_PLAYER_VEHS - [WL2_mapAssetTarget]];
				publicVariableServer _ownedVehiclesVarName;
				WL2_mapAssetTarget call WL2_fnc_sub_deleteAsset;
				((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlShow FALSE;
				((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlEnable FALSE;
			};
		};
	};
}];

WL2_assetInfoActive = FALSE;

WL2_assetMapHandler = addMissionEventHandler ["EachFrame", {
	_shown = FALSE;
	
	if (visibleMap) then {
		_nearbyAssets = ((WL_CONTROL_MAP ctrlMapScreenToWorld getMousePosition) nearObjects ["All", (((ctrlMapScale WL_CONTROL_MAP) * 500) min 50) max 2]) select {!isNull (_x getVariable ["WL2_ownerGrp", grpNull])};
		
		if (count _nearbyAssets > 0) then {
			WL2_mapAssetTarget = _nearbyAssets # 0;
			WL2_assetInfoActive = TRUE;
			_shown = TRUE;
			((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlSetPosition [(getMousePosition # 0) + safeZoneW / 100, (getMousePosition # 1) + safeZoneH / 50, safeZoneW, safeZoneH];
			((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlCommit 0;
			((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlSetStructuredText parseText format [
				"<t shadow = '2' size = '%1'>%2</t>",
				(1 call WL2_fnc_sub_purchaseMenuGetUIScale),
				format [
					localize "STR_WL2_info_asset_map_deletion",
					"<t color = '#ff4b4b'>",
					"</t>",
					"<br/>",
					WL2_mapAssetTarget getVariable "WL2_iconText"
				]
			];
			((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlShow TRUE;
			((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlEnable TRUE;
		};
	};
	
	if (!_shown && WL2_assetInfoActive) then {
		WL2_mapAssetTarget = objNull;
		WL2_assetInfoActive = FALSE;
		((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlShow FALSE;
		((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlEnable FALSE;
	};
}];