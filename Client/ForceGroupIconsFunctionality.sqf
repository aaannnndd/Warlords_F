#include "..\warlords_constants.hpp"

while {!WL2_missionEnd} do {
	setGroupIconsSelectable TRUE;
	setGroupIconsVisible [TRUE, FALSE];
	waitUntil {sleep WL_TIMEOUT_LONG; !(groupIconsVisible isEqualTo [TRUE, FALSE] && groupIconSelectable)}
};