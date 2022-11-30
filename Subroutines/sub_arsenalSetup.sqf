#include "..\warlords_constants.inc"

["Preload"] call BIS_fnc_arsenal;

WL2_factionAppropriateUniforms = "getNumber (_x >> 'scope') == 2" configClasses (configFile >> "CfgWeapons");
WL2_factionAppropriateUniforms = (WL2_factionAppropriateUniforms select {player isUniformAllowed configName _x}) apply {configName _x};

BIS_fnc_arsenal_data set [3, WL2_factionAppropriateUniforms];
BIS_fnc_arsenal_data set [5, (BIS_fnc_arsenal_data # 5) - WL2_blacklistedBackpacks];
BIS_fnc_arsenal_data set [23, (BIS_fnc_arsenal_data # 23) - ["APERSMineDispenser_Mag"]];