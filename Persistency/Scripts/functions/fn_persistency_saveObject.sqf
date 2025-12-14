params ["_objects"];

{
	if (_x in ER32_persistency_createdObjects) then {
		private _index = ER32_persistency_createdObjects find _x;
		ER32_persistency_createdObjects deleteAt _index;
	};

	ER32_persistency_createdObjects pushBack _x;
	publicVariable "ER32_persistency_createdObjects";
}forEach _objects;