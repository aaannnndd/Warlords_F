#include "..\warlords_constants.hpp"

["RequestMenu_close"] call WL2_fnc_setupUI;
[player, -WL2_targetResetCost] call WL2_fnc_fundsControl;

missionNamespace setVariable [format ["WL2_targetResetVotingSince_%1", WL2_playerSide], WL_SYNCED_TIME, TRUE];
missionNamespace setVariable [format ["WL2_targetResetOrderedBy_%1", WL2_playerSide], name player, TRUE];

player setVariable ["WL2_targetResetVote", 1, TRUE];