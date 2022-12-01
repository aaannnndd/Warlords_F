#include "..\warlords_constants.hpp"

["RequestMenu_close"] call WL2_fnc_setupUI;
[player, -WL2_lastLoadoutCost] call WL2_fnc_fundsControl;

player setUnitLoadout WL2_lastLoadout;
WL2_loadoutApplied = TRUE;
[toUpper localize "STR_A3_WL_loadout_applied"] spawn WL2_fnc_smoothText;