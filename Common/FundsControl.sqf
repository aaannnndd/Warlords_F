#include "..\warlords_constants.inc"

params ["_warlord", "_amount"];

_warlord setVariable ["WL2_funds", ((_warlord getVariable ["WL2_funds", 0]) + _amount) min WL2_maxCP, TRUE];