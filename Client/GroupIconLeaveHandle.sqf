#include "..\warlords_constants.inc"

WL2_highlightedSector = objNull;
WL2_hoverSamplePlayed = FALSE;

WL_CONTROL_MAP ctrlMapCursor ["Track", "Track"]; 

((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlShow FALSE;
((ctrlParent WL_CONTROL_MAP) getVariable "WL2_sectorInfoBox") ctrlEnable FALSE;