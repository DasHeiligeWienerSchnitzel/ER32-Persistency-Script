[] spawn {
    uiSleep 0.1;

    private _lb = toString [10];
    private _data = [];
	private _crates = ER32_buildAndRessources_crates;
	private _names = ER32_buildAndRessources_names;

    {
        private _type = typeOf _x;
        private _pos  = getPosATL _x;

        private _pb = _x call BIS_fnc_getPitchBank;
        private _pitch = _pb select 0;
        private _roll  = _pb select 1;
        private _yaw   = getDir _x;
		
		private _ressources = _x getVariable ["ER32_buildAndRessources_ressources", [0,0,0,0]];

        _data pushBack [
            _type,
            _pos,
            [_pitch, _roll, _yaw],
			_ressources
        ];
    } forEach ER32_persistency_createdObjects;
	
	private _initTemplate = 
		"this setVariable [''ER32_buildAndRessources_ressources'',%1,true];" + _lb +
		"[this, -1] remoteExecCall [''ace_cargo_fnc_setSize'',0,true];" + _lb +
		"[this, -1] remoteExecCall [''ace_cargo_fnc_setSpace'',0,true];" + _lb +
		"[this] remoteExecCall [''ER32_fnc_buildAndRessources_checkForRessources'',0,true];" + _lb +
		"[this] remoteExecCall [''ER32_fnc_buildAndRessources_loadOnFlatbed'',0,true];";
	
    private _code =
    "private _objects = " + str _data + ";" + _lb + _lb +
    "{" + _lb +
    "_x params ['_type','_pos','_rot','_ressources'];" + _lb +
    "_obj = create3DENEntity ['Object', _type, _pos];" + _lb +
    "_obj set3DENAttribute ['Rotation', _rot];" + _lb +
    "if (_type in ['Land_Cargo10_white_F','Land_Cargo10_orange_F','Land_Cargo10_sand_F','Land_Cargo10_grey_F']) then {" + _lb +
	"private _init = format ['" + _initTemplate + "', str _ressources];" + _lb +
    "_obj set3DENAttribute ['Init', _init];" + _lb +
    "};" + _lb +
    "} forEach _objects;";

	
	uiNamespace setVariable ["display3DENCopy_data", ["ER32 Persistency Clipboard", _code]];
    (call BIS_fnc_displayMission) createDisplay "display3denCopy";
};