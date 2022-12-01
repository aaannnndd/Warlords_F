#include "..\warlords_constants.hpp"

_previousSeizingInfo = [];
_visitedSector = objNull;

while {!WL2_missionEnd} do {
	
	sleep (if (count _previousSeizingInfo == 0) then {WL_TIMEOUT_STANDARD} else {WL_TIMEOUT_SHORT});
	
	_sectorsToCheck = +(WL2_sectorsArray # 3);
	_visitedSectorID = _sectorsToCheck findIf {player inArea (_x getVariable "objectAreaComplete")};
	
	if (_visitedSectorID != -1) then {
		_visitedSector = _sectorsToCheck # _visitedSectorID;
		_info = _visitedSector getVariable ["WL2_seizingInfo", []];
		if !(_previousSeizingInfo isEqualTo _info) then {
			if (count _info > 1) then {
				["seizing", [_visitedSector, _info # 0, _info # 1, _info # 2]] spawn WL2_fnc_setOSDEvent;
			} else {
				["seizing", []] spawn WL2_fnc_setOSDEvent;
			};
			_previousSeizingInfo = _info;
		} else {
			if ((_visitedSector getVariable "WL2_owner") != WL2_playerSide && count _info == 0 && (_visitedSector in (WL2_sectorsArray # 7)) && _visitedSector != WL_TARGET_FRIENDLY) then {
				["seizingDisabled", [_visitedSector getVariable "WL2_owner"]] spawn WL2_fnc_setOSDEvent;
				_visitedSector setVariable ["WL2_seizingInfo", ["seizingDisabled"]];
				_previousSeizingInfo = ["seizingDisabled"];
			};
		};
	} else {
		if (count _previousSeizingInfo > 0) then {
			["seizing", []] spawn WL2_fnc_setOSDEvent;
			["seizingDisabled", []] spawn WL2_fnc_setOSDEvent;
			_previousSeizingInfo = [];
			_visitedSector setVariable ["WL2_seizingInfo", []];
		};
	};
};