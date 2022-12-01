#include "..\warlords_constants.hpp"

params ["_locality"];

switch (_locality) do {
	case "common": {
		WL2_sidesArray = [WEST, EAST, RESISTANCE];
		WL2_competingSides = [[WEST, EAST], [WEST, RESISTANCE], [EAST, RESISTANCE]] # (["CombatantsPreset", 0] call BIS_fnc_getParamValue);
		WL2_targetVotingDuration = (["TargetVotingDuration", 15] call BIS_fnc_getParamValue);
		WL2_startCP = ["StartCP", 500] call BIS_fnc_getParamValue;
		WL2_fogOfWar = (["FogOfWar", 1] call BIS_fnc_getParamValue);
		WL2_localSide = (WL2_sidesArray - WL2_competingSides) # 0;
		WL2_missionEnd = FALSE;
		WL2_sectorUpdateInProgress = FALSE;
		WL2_mapSize = getNumber (configFile >> "cfgWorlds" >> worldName >> "mapSize");
		if (WL2_mapSize == 0) then {WL2_mapSize = getNumber (configFile >> "cfgWorlds" >> worldName >> "Grid" >> "OffsetY")};
		WL2_mapAreaArray = [[WL2_mapSize / 2, WL2_mapSize / 2], WL2_mapSize / 2, WL2_mapSize / 2, 0, TRUE];
		WL2_purchaseListTeplateArr = ['A3ReduxAll'];
		WL2_scanCost = (["ScanCost", 350] call BIS_fnc_getParamValue);
		WL2_fastTravelCostOwned = (["FastTravelCostOwned", 25] call BIS_fnc_getParamValue);
		WL2_fastTravelCostContested = (["FastTravelCostContested", 50] call BIS_fnc_getParamValue);
		WL2_fundsTransferCost = (["FundsTransferCost", 500] call BIS_fnc_getParamValue);
		WL2_targetResetCost = (["TargetResetCost", 2000] call BIS_fnc_getParamValue);
		WL2_scanEnabled = ([false,true] select (["ScanEnabled", 1] call BIS_fnc_getParamValue));
		WL2_fastTravelEnabled = (["FastTravelEnabled", 1] call BIS_fnc_getParamValue);
		WL2_maxCP = (["MaxCP", 50000] call BIS_fnc_getParamValue);
		WL2_dropCost = (["DropCost", 25] call BIS_fnc_getParamValue);
		WL2_dropCost_far = (["DropCost_far", 1000] call BIS_fnc_getParamValue);
		WL2_arsenalEnabled = ([false,true] select (["ArsenalEnabled", 1] call BIS_fnc_getParamValue));
		WL2_arsenalCost = (["ArsenalCost", 1000] call BIS_fnc_getParamValue);
		WL2_assetLimit = (["AssetLimit", 10] call BIS_fnc_getParamValue);
		WL2_maxSubordinates = (["MaxSubordinates", 3] call BIS_fnc_getParamValue);
		WL2_targetResetTimeout = (["TargetResetTimeout", 300] call BIS_fnc_getParamValue);
		WL2_baseValue = (["BaseValue", 10] call BIS_fnc_getParamValue);
		WL2_scanCooldown = (["ScanCooldown", 90] call BIS_fnc_getParamValue) max WL_SCAN_DURATION;
		WL2_lastLoadoutCost = (["LastLoadoutCost", 100] call BIS_fnc_getParamValue);
		WL2_savedLoadoutCost = (["SavedLoadoutCost", 500] call BIS_fnc_getParamValue);
		WL2_zoneRestrictionSetting = (["ZoneRestrictionSetting", 2] call BIS_fnc_getParamValue);
		WL2_savingEnabled = ([false,true] select (["SavingEnabled", 0] call BIS_fnc_getParamValue));
		WL2_blacklistedBackpacks = [];
		{
			private _class = _x;
			private _bases = getArray (_class >> "assembleInfo" >> "base");
			if (count _bases > 0 || (toLower configName _class) find "respawn" != -1) then {
				WL2_blacklistedBackpacks pushBackUnique configName _class;
				{
					WL2_blacklistedBackpacks pushBackUnique _x;
				} forEach _bases;
			};
		} forEach ("getNumber (_x >> 'scope') == 2 && (configName _x) isKindOf 'Bag_Base'" configClasses (configFile >> "CfgVehicles"));

		WL2_blacklistedBackpacks = WL2_blacklistedBackpacks - [""];

		WL2_blacklistedBackpacks append [
			"C_IDAP_UGV_02_Demining_backpack_F",
			"I_UGV_02_Demining_backpack_F",
			"O_UGV_02_Demining_backpack_F",
			"I_E_UGV_02_Demining_backpack_F",
			"B_UGV_02_Demining_backpack_F",
			"I_UGV_02_Science_backpack_F",
			"O_UGV_02_Science_backpack_F",
			"I_E_UGV_02_Science_backpack_F",
			"B_UGV_02_Science_backpack_F"
		];
	};
	case "server": {
		WL2_allowAIVoting = ([false,true] select (["AllowAIVoting", 0] call BIS_fnc_getParamValue));
		WL2_initialProgress = (["InitialProgress", 0] call BIS_fnc_getParamValue);
		WL2_wreckRemovalTimeout = (["WreckRemovalTimeout", 30] call BIS_fnc_getParamValue);
		WL2_corpseRemovalTimeout = (["CorpseRemovalTimeout", 600] call BIS_fnc_getParamValue);
		WL2_initialProgress = switch (WL2_initialProgress) do {
			case 0: 	{[0, 0]};
			case 2525: 	{[0.25, 0.25]};
			case 5050: 	{[0.5, 0.5]};
			case 250: 	{[0.25, 0]};
			case 500: 	{[0.5, 0]};
			case 750: 	{[0.75, 0]};
			case 25: 	{[0, 0.25]};
			case 50: 	{[0, 0.5]};
			case 75: 	{[0, 0.75]};
			case 5025: 	{[0.5, 0.25]};
			case 7525: 	{[0.75, 0.25]};
			case 2550: 	{[0.25, 0.5]};
			case 2575: 	{[0.25, 0.75]};
		};
		WL2_playerIDArr = [[], []];
		{
			missionNamespace setVariable [format ["WL2_boundTo%1", _x], []];
		} forEach WL2_competingSides;
		WL2_timeMultiplier = (["TimeMultiplier", 6] call BIS_fnc_getParamValue);
	};
	case "client": {
		WL2_playerSide = side group player;
		WL2_enemySide = (WL2_competingSides - [WL2_playerSide]) # 0;
		WL2_playersAlpha = 50 / 100;
		WL2_markersAlpha = 50 / 100;
		WL2_autonomous_limit = (["Autonomous_limit", 2] call BIS_fnc_getParamValue);
		WL2_playerBase = WL2_playerSide call WL2_fnc_getSideBase;
		WL2_enemyBase = WL2_enemySide call WL2_fnc_getSideBase;
		WL2_mapSizeIndex = WL2_mapSize / 8192;
		WL2_colorMarkerFriendly = ["colorBLUFOR", "colorOPFOR", "colorIndependent"] # (WL2_sidesArray find WL2_playerSide);
		WL2_colorMarkerEnemy = ["colorBLUFOR", "colorOPFOR", "colorIndependent"] # (WL2_sidesArray find WL2_enemySide);
		WL2_targetVote = objNull;
		WL2_announcerEnabled = ([false,true] select (["AnnouncerEnabled", 1] call BIS_fnc_getParamValue));
		WL2_musicEnabled = ([false,true] select (["MusicEnabled", 1] call BIS_fnc_getParamValue));
		WL2_terminateOSDEvent_voting = FALSE;
		WL2_terminateOSDEvent_seizing = FALSE;
		WL2_terminateOSDEvent_trespassing = FALSE;
		WL2_terminateOSDEvent_seizingDisabled = FALSE;
		WL2_resetTargetSelection_client = FALSE;
		WL2_localized_m = localize "STR_A3_rscdisplayarcademap_meters";
		WL2_localized_km = localize "STR_A3_WL_unit_km";
		WL2_purchaseMenuVisible = FALSE;
		WL2_purchaseMenuDiscovered = FALSE;
		WL2_gearKeyPressed = FALSE;
		WL2_currentSelection = WL_ID_SELECTION_NONE;
		WL2_matesAvailable = floor (WL2_maxSubordinates / 2);
		WL2_matesInBasket = 0;
		WL2_vehsInBasket = 0;
		WL2_dropPool = [];
		WL2_lastLoadout = [];
		WL2_savedLoadout = [];
		WL2_loadoutApplied = FALSE;
		WL2_selectionMapManager = -1;
		WL2_currentlyScannedSectors = [];
		WL2_currentTargetData = [
			"\A3\ui_f\data\map\markers\nato\b_hq.paa",
			[0, 0, 0, 0],
			[0, 0, 0]
		];
		WL2_colorsArray = [
			[profileNamespace getVariable ["Map_BLUFOR_R", 0], profileNamespace getVariable ["Map_BLUFOR_G", 1], profileNamespace getVariable ["Map_BLUFOR_B", 1], profileNamespace getVariable ["Map_BLUFOR_A", 0.8]],
			[profileNamespace getVariable ["Map_OPFOR_R", 0], profileNamespace getVariable ["Map_OPFOR_G", 1], profileNamespace getVariable ["Map_OPFOR_B", 1], profileNamespace getVariable ["Map_OPFOR_A", 0.8]],
			[profileNamespace getVariable ["Map_Independent_R", 0], profileNamespace getVariable ["Map_Independent_G", 1], profileNamespace getVariable ["Map_Independent_B", 1], profileNamespace getVariable ["Map_Independent_A", 0.8]],
			[profileNamespace getVariable ["Map_Unknown_R", 0], profileNamespace getVariable ["Map_Unknown_G", 1], profileNamespace getVariable ["Map_Unknown_B", 1], profileNamespace getVariable ["Map_Unknown_A", 0.8]]
		];
		WL2_sectorIconsArray = [
			"\A3\ui_f\data\map\markers\nato\b_installation.paa",
			"\A3\ui_f\data\map\markers\nato\o_installation.paa",
			"\A3\ui_f\data\map\markers\nato\n_installation.paa"
		];
		WL2_colorFriendly = WL2_colorsArray # (WL2_sidesArray find WL2_playerSide);
		WL2_recentlyPurchasedAssets = [];
		WL2_penalized = FALSE;
		WL2_mapAssetTarget = objNull;
	};
};