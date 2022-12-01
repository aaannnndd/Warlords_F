#include "..\warlords_constants.hpp"

params ["_sector"];

waitUntil {sleep WL_TIMEOUT_STANDARD; WL2_playerSide in (_sector getVariable "WL2_revealedBy")};

private _specialStateArray = (WL2_sectorsArray # 6) + (WL2_sectorsArray # 7);
[_sector, _sector getVariable "WL2_owner", _specialStateArray] call WL2_fnc_sectorMarkerUpdate;