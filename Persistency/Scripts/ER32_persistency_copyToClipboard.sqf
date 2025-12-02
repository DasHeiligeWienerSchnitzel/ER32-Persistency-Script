private _code = "";
{
    private _type = typeOf _x;
    private _pos = getPosATL _x;
    private _yaw = getDir _x;
    private _pitchBank = _x call BIS_fnc_getPitchBank;
	private _pitch = _pitchBank select 0;
	private _roll = _pitchBank select 1;

    private _line = format [
        "_obj = create3DENEntity ['Object', '%1', %2];" + 
		"_obj set3DENAttribute ['rotation', [%4,%5,%3]];", 
        _type,
        str _pos,
        _yaw,
        _pitch,
		_roll
    ];

    _code = _code + _line + toString [10];
} forEach ER32_persistency_createdObjects;

// Export to clipboard
copyToClipboard _code;
systemChat "Object export copied to clipboard!";
