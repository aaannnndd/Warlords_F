#include "..\warlords_constants.hpp"

params ["_sector", "_owner", ["_specialStateArray", []]];

private _ownerIndex = WL2_sidesArray find _owner;
private _area = _sector getVariable "objectArea";
private _previousOwners = _sector getVariable "WL2_previousOwners";
private _mrkrMain = (_sector getVariable "WL2_markers") # 0;
private _mrkrArea = (_sector getVariable "WL2_markers") # 1;
private _mrkrAreaBig = (_sector getVariable "WL2_markers") # 2;

if (_owner == WL2_playerSide || (WL2_playerSide) in _previousOwners) then {
	_mrkrAreaBig setMarkerSizeLocal [0, 0];
	_mrkrArea setMarkerBrushLocal "Border";
};

if (WL2_playerSide in (_sector getVariable "WL2_revealedBy")) then {
	if (_sector in WL_BASES) then {
		_mrkrMain setMarkerSizeLocal [WL_BASE_ICON_SIZE, WL_BASE_ICON_SIZE];
	};
	if (_sector in _specialStateArray) then {
		_mrkrMain setMarkerColorLocal "ColorGrey";
	} else {
		_mrkrMain setMarkerColorLocal (["colorBLUFOR", "colorOPFOR", "colorIndependent"] select _ownerIndex);
	};
	_mrkrArea setMarkerColorLocal (["colorBLUFOR", "colorOPFOR", "colorIndependent"] select _ownerIndex);
	if (_sector in WL_BASES) then {
		_mrkrMain setMarkerTypeLocal (["b_hq", "o_hq", "n_hq"] select _ownerIndex);
	} else {
		_mrkrMain setMarkerTypeLocal (["b_installation", "o_installation", "n_installation"] select _ownerIndex);
	};
};

if (_sector == WL_TARGET_FRIENDLY) then {
	call WL2_fnc_refreshCurrentTargetData;
};