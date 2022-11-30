WL2_initModule setVariable ["WL2_combatantsPreset", 0];
WL2_initModule setVariable ["WL2_faction_WEST", "BLU_F"];
WL2_initModule setVariable ["WL2_faction_EAST", "OPF_F"];
WL2_initModule setVariable ["WL2_faction_GUER", "IND_F"];
WL2_initModule setVariable ["WL2_startCP", 500];
WL2_initModule setVariable ["WL2_targetVotingDuration", 15];
WL2_initModule setVariable ["WL2_allowAIVoting", FALSE];
WL2_initModule setVariable ["WL2_announcerEnabled", TRUE];
WL2_initModule setVariable ["WL2_musicEnabled", TRUE];
WL2_initModule setVariable ["WL2_initialProgress", 0];
WL2_initModule setVariable ["WL2_fogOfWar", 1];
WL2_initModule setVariable ["WL2_playersAlpha", 50];
WL2_initModule setVariable ["WL2_markersAlpha", 50];
WL2_initModule setVariable ["WL2_requisitionPreset", "['A3ReduxAll']"];
WL2_initModule setVariable ["WL2_scanCost", 350];
WL2_initModule setVariable ["WL2_fastTravelCostOwned", 25];
WL2_initModule setVariable ["WL2_fastTravelCostContested", 50];
WL2_initModule setVariable ["WL2_fundsTransferCost", 500];
WL2_initModule setVariable ["WL2_targetResetCost", 2000];
WL2_initModule setVariable ["WL2_scanEnabled", TRUE];
WL2_initModule setVariable ["WL2_fastTravelEnabled", 1];
WL2_initModule setVariable ["WL2_maxCP", 50000];
WL2_initModule setVariable ["WL2_dropCost", 25];
WL2_initModule setVariable ["WL2_dropCost_far", 1000];
WL2_initModule setVariable ["WL2_autonomous_limit", 2];
WL2_initModule setVariable ["WL2_arsenalEnabled", TRUE];
WL2_initModule setVariable ["WL2_arsenalCost", 1000];
WL2_initModule setVariable ["WL2_maxSubordinates", 3];
WL2_initModule setVariable ["WL2_assetLimit", 10];
WL2_initModule setVariable ["WL2_targetResetTimeout", 300];
WL2_initModule setVariable ["WL2_baseValue", 10];
WL2_initModule setVariable ["WL2_baseDistanceMin", 5];
WL2_initModule setVariable ["WL2_baseDistanceMax", -1];
WL2_initModule setVariable ["WL2_scanCooldown", 90];
WL2_initModule setVariable ["WL2_lastLoadoutCost", 100];
WL2_initModule setVariable ["WL2_wreckRemovalTimeout", 30];
WL2_initModule setVariable ["WL2_corpseRemovalTimeout", 600];
WL2_initModule setVariable ["WL2_savedLoadoutCost", 500];
WL2_initModule setVariable ["WL2_timeMultiplier", 6];
WL2_initModule setVariable ["WL2_zoneRestrictionSetting", 0];
WL2_initModule setVariable ["WL2_savingEnabled", FALSE];

{
	_x setVariable ["objectArea", triggerArea ((_x nearObjects ["EmptyDetector", 100]) # 0)];
	if (isNil {_x getVariable "WL2_services"}) then {
		_x setVariable ["WL2_services", []];
	};
	if (isNil {_x getVariable "WL2_canBeBase"}) then {
		_x setVariable ["WL2_canBeBase", TRUE];
	};
	_x setVariable ["WL2_fastTravelEnabled", TRUE];
} forEach WL2_allSectors;

{_x enableSimulation FALSE} forEach allMissionObjects "EmptyDetector";