params ["_object"];

if (_object in ER32_persistency_createdObjects) then {
	private _index = ER32_persistency_createdObjects find _object;
	ER32_persistency_createdObjects deleteAt _index;
};

publicVariable "ER32_persistency_createdObjects";
