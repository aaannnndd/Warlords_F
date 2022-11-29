startLoadingScreen [""];
BIS_fnc_WL2_welcome = compile preprocessFileLineNumbers "welcome.sqf";
endLoadingScreen;

[] remoteExecCall ["BIS_fnc_WL2_mineLimit", 2];
if(isServer) then
{
	moneyDatabase = createHashmap;
};
[] call BIS_fnc_WL2_initCommon;

/*
## Old mission conversion code
all3DENEntities params ["_objects", "_groups", "_triggers", "_systems", "_waypoints", "_markers", "_layers", "_comments"];   
_output = [];   
{   
 _obj = _x; 
 if (typeOf _obj in ["ModuleWLBase_F", "ModuleWLSector_F"]) then {  
  _trigger = create3DENEntity ["Trigger", "EmptyDetector", getPosATL _obj];  
  _logic = create3DENEntity ["Logic", "Logic", getPosATL _obj];
  _isBase = typeOf _obj == "ModuleWLBase_F";
  _svcs = [];
  _svcVarName = if (_isBase) then {"ModuleWLBase_F_Service_%1"} else {"ModuleWLSector_F_Service_%1"};
  if (((_obj get3DENAttribute (format [_svcVarName, "Runway"])) # 0) == true) then {
	_svcs pushBack "A";
  };
  if (((_obj get3DENAttribute (format [_svcVarName, "Helipad"])) # 0) == true) then {
	_svcs pushBack "H";
  };
  if (((_obj get3DENAttribute (format [_svcVarName, "Harbour"])) # 0) == true) then {
	_svcs pushBack "W";
  };
  _attrString = format ["this setVariable ['BIS_WL_services', %1]; this setVariable ['BIS_WL_canBeBase', %2];", _svcs, _isBase];
  {   
   _var = _x;   
   _val = _obj getVariable _var;   
   if (typeName _val == typeName "") then {
	_val = format ["'%1'", _val];
   };
   _attrString = _attrString + format ["this setVariable ['%1', %2];", _var, _val];  
  } forEach allVariables _obj;
  _size = _obj getVariable "Size";
  _size = _size * 0.5;  
  _logic set3DENAttribute ["init", _attrString];  
  _trigger set3DENAttribute ["size3", [_size, _size, -1]];  
  _trigger set3DENAttribute ["isRectangle", true]; 
 }; 
} forEach _systems;   
_output;*/