#include "..\warlords_constants.inc"

if (WL2_musicEnabled) then {
	_musicPool = "getText (_x >> 'name') != '' && getNumber (_x >> 'duration') > 20" configClasses (configFile >> "CfgMusic");
	_poolSize = count _musicPool;
	sleep 5;
	0 fadeMusic WL_MUSIC_VOLUME;
	WL2_musicStopped = FALSE;
	addMusicEventHandler ["MusicStop", {WL2_musicStopped = TRUE}];
	while {!WL2_missionEnd} do {
		_trackClass = _musicPool # floor random _poolSize;
		playMusic configName _trackClass;
		waitUntil {sleep WL_TIMEOUT_STANDARD; WL2_musicStopped};
		WL2_musicStopped = FALSE;
		sleep WL_TIMEOUT_STANDARD;
	};
};