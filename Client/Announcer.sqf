#include "..\warlords_constants.inc"

if (isNil "WL2_soundMsgBuffer" && WL2_announcerEnabled) then {
	WL2_soundMsgBuffer = [];
	[] spawn {
		while {TRUE} do {
			waitUntil {sleep WL_TIMEOUT_SHORT; count WL2_soundMsgBuffer > 0};
			_msg = WL2_soundMsgBuffer # 0;
			_length = getNumber (configFile >> "CfgSounds" >> _msg >> "duration");
			if (_length == 0) then {_length = 2};
			playSound (WL2_soundMsgBuffer # 0);
			WL2_soundMsgBuffer deleteAt 0;
			sleep (_length + WL_ANNOUNCER_PAUSE);
		};
	};
};

if (WL2_announcerEnabled) then {
	WL2_soundMsgBuffer pushBack format ["BIS_WL_%1_%2", _this, WL2_sidesArray # ((WL2_sidesArray find WL2_playerSide) min 1)];
};