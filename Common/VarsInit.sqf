#include "..\warlords_constants.inc"

params ["_locality"];

switch (_locality) do {
	case "common": {
		WL2_sidesArray = [WEST, EAST, RESISTANCE];
		WL2_competingSides = [[WEST, EAST], [WEST, RESISTANCE], [EAST, RESISTANCE]] # (WL2_initModule getVariable ["WL2_combatantsPreset", 0]);
		WL2_targetVotingDuration = WL2_initModule getVariable ["WL2_targetVotingDuration", 15];
		WL2_startCP = WL2_initModule getVariable ["WL2_startCP", 500];
		WL2_fogOfWar = WL2_initModule getVariable ["WL2_fogOfWar", 1];
		WL2_localSide = (WL2_sidesArray - WL2_competingSides) # 0;
		WL2_missionEnd = FALSE;
		WL2_sectorUpdateInProgress = FALSE;
		WL2_mapSize = getNumber (configFile >> "cfgWorlds" >> worldName >> "mapSize");
		if (WL2_mapSize == 0) then {WL2_mapSize = getNumber (configFile >> "cfgWorlds" >> worldName >> "Grid" >> "OffsetY")};
		WL2_mapAreaArray = [[WL2_mapSize / 2, WL2_mapSize / 2], WL2_mapSize / 2, WL2_mapSize / 2, 0, TRUE];
		WL2_purchaseListTeplateArr = call compile (WL2_initModule getVariable ["WL2_requisitionPreset", "['A3DefaultAll']"]);
		WL2_scanCost = WL2_initModule getVariable ["WL2_scanCost", 350];
		WL2_fastTravelCostOwned = WL2_initModule getVariable ["WL2_fastTravelCostOwned", 0];
		WL2_fastTravelCostContested = WL2_initModule getVariable ["WL2_fastTravelCostContested", 50];
		WL2_fundsTransferCost = WL2_initModule getVariable ["WL2_fundsTransferCost", 500];
		WL2_targetResetCost = WL2_initModule getVariable ["WL2_targetResetCost", 2000];
		WL2_scanEnabled = WL2_initModule getVariable ["WL2_scanEnabled", TRUE];
		WL2_fastTravelEnabled = WL2_initModule getVariable ["WL2_fastTravelEnabled", 1];
		WL2_maxCP = WL2_initModule getVariable ["WL2_maxCP", 50000];
		WL2_dropCost = WL2_initModule getVariable ["WL2_dropCost", 25];
		WL2_dropCost_far = WL2_initModule getVariable ["WL2_dropCost_far", 1000];
		WL2_arsenalEnabled = WL2_initModule getVariable ["WL2_arsenalEnabled", TRUE];
		WL2_arsenalCost = WL2_initModule getVariable ["WL2_arsenalCost", 1000];
		WL2_assetLimit = WL2_initModule getVariable ["WL2_assetLimit", 10];
		WL2_maxSubordinates = WL2_initModule getVariable ["WL2_maxSubordinates", 3];
		WL2_targetResetTimeout = WL2_initModule getVariable ["WL2_targetResetTimeout", 300];
		WL2_baseValue = WL2_initModule getVariable ["WL2_baseValue", 10];
		WL2_scanCooldown = (WL2_initModule getVariable ["WL2_scanCooldown", 90]) max WL_SCAN_DURATION;
		WL2_lastLoadoutCost = WL2_initModule getVariable ["WL2_lastLoadoutCost", 100];
		WL2_savedLoadoutCost = WL2_initModule getVariable ["WL2_savedLoadoutCost", 500];
		WL2_zoneRestrictionSetting = WL2_initModule getVariable ["WL2_zoneRestrictionSetting", 0];
		WL2_savingEnabled = WL2_initModule getVariable ["WL2_savingEnabled", FALSE];
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
		WL2_allowAIVoting = WL2_initModule getVariable ["WL2_allowAIVoting", FALSE];
		WL2_initialProgress = WL2_initModule getVariable ["WL2_initialProgress", FALSE];
		WL2_baseDistanceMin = WL2_initModule getVariable ["WL2_baseDistanceMin", 1];
		WL2_baseDistanceMax = WL2_initModule getVariable ["WL2_baseDistanceMax", -1];
		WL2_wreckRemovalTimeout = WL2_initModule getVariable ["WL2_wreckRemovalTimeout", 30];
		WL2_corpseRemovalTimeout = WL2_initModule getVariable ["WL2_corpseRemovalTimeout", 600];
		if (WL2_baseDistanceMax < 0) then {WL2_baseDistanceMax = 999};
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
		WL2_faction_WEST = WL2_initModule getVariable ["WL2_faction_WEST", "BLU_F"];
		WL2_faction_EAST = WL2_initModule getVariable ["WL2_faction_EAST", "OPF_F"];
		WL2_faction_GUER = WL2_initModule getVariable ["WL2_faction_GUER", "IND_F"];
		{
			missionNamespace setVariable [format ["WL2_boundTo%1", _x], []];
		} forEach WL2_competingSides;
		WL2_timeMultiplier = WL2_initModule getVariable ["WL2_timeMultiplier", 12];
	};
	case "client": {
		WL2_playerSide = side group player;
		WL2_enemySide = (WL2_competingSides - [WL2_playerSide]) # 0;
		WL2_playersAlpha = (WL2_initModule getVariable ["WL2_playersAlpha", 50]) / 100;
		WL2_markersAlpha = (WL2_initModule getVariable ["WL2_markersAlpha", 50]) / 100;
		WL2_autonomous_limit = WL2_initModule getVariable ["WL2_autonomous_limit", 2];
		WL2_playerBase = WL2_playerSide call WL2_fnc_getSideBase;
		WL2_enemyBase = WL2_enemySide call WL2_fnc_getSideBase;
		WL2_mapSizeIndex = WL2_mapSize / 8192;
		WL2_colorMarkerFriendly = ["colorBLUFOR", "colorOPFOR", "colorIndependent"] # (WL2_sidesArray find WL2_playerSide);
		WL2_colorMarkerEnemy = ["colorBLUFOR", "colorOPFOR", "colorIndependent"] # (WL2_sidesArray find WL2_enemySide);
		WL2_targetVote = objNull;
		WL2_announcerEnabled = WL2_initModule getVariable ["WL2_announcerEnabled", TRUE];
		WL2_musicEnabled = WL2_initModule getVariable ["WL2_musicEnabled", TRUE];
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