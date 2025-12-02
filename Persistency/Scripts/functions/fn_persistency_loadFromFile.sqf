params ["_file"];

private _objectsFromFile = ["read", ["Objects", "Data", []]] call _file;

{
	private _type = _x select 0;
	private _pos = _x select 1;
	private _dir = _x select 2;
	private _vectorUp = _x select 3;
	
	private _object = createVehicle [_type,_pos,[],0,"CAN_COLLIDE"];
	_object setDir _dir;
	_object setVectorUp _vectorUp;
	
	ER32_persistency_createdObjects pushBack _object;
}forEach _objectsFromFile;

publicVariable "ER32_persistency_createdObjects";