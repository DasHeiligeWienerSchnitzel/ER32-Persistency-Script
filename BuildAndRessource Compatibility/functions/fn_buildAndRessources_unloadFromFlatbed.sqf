params ["_nearestFlatbed","_crates","_loadDistance"];

/*
Only if the first object is loaded onto the flatbed the interaction to unload crates will be added onto the flatbed.
Will be later removed if no more crates are on the flatbed.
*/
		
_ER32_buildAndRessources_flatbedUnload = [
	"ER32_buildAndRessources_flatbedUnload",
	"Unload Crate",
	"",
	{
		params ["_target","_player","_params"];
		_nearestFlatbed = _params select 0;
		_crates = _params select 1;
		_loadDistance = _params select 2;
		
		//Gets all the objects loaded onto the flatbed.
		
		_objectsLoaded = _nearestFlatbed getVariable ["ER32_buildAndRessources_objectsLoaded",[]];
		
		if (count _objectsLoaded > 0) then {
			
			private _pos = [position _nearestFlatbed, 4, (getDir _nearestFlatbed) - 180] call BIS_fnc_relPos;
			
			
			private _nearbyCrates = _pos nearEntities 2.5;
			if (count _nearbyCrates == 0) then {
			
				//Gets the last added object and detaches it from the flatbed.
				
				_lastObject = _objectsLoaded select -1;
				_lastObject enableSimulationGlobal false;
				detach _lastObject;
				
				//Now teleports it behind the flatbed.
				
				
				_lastObject setPos [_pos select 0,_pos select 1,_pos select 2];
				
				//Adds back the interaction to load it back onto the flatbed.
				
				[_lastObject,_crates,_loadDistance] remoteExecCall ["ER32_fnc_buildAndRessources_loadOnFlatbed",0,true];
				
				//Deletes the now unloaded object from the object list.
				
				_objectsLoaded deleteAt [-1]; 
				_nearestFlatbed setVariable ["ER32_buildAndRessources_objectsLoaded", _objectsLoaded, true];
				
				_lastObject enableSimulationGlobal true;
				
				[_lastObject] remoteExecCall ["ER32_fnc_persistency_saveObject",2];
				
				//If now no longer any crates are on the flatbed the interaction to unload crates will be removed.
				
				if (count _objectsLoaded == 0) then {
					[_nearestFlatbed, 0, ["ACE_MainActions","ER32_buildAndRessources_flatbedUnload"]] remoteExecCall ["ace_interact_menu_fnc_removeActionFromObject",-2,true];
				};
			}else{
				hint "Unloading obstructed";
			};
		};
	},
	{true},
	{},
	[_nearestFlatbed,_crates,_loadDistance]
	] call ace_interact_menu_fnc_createAction;
[_nearestFlatbed, 0, ["ACE_MainActions"], _ER32_buildAndRessources_flatbedUnload] call ace_interact_menu_fnc_addActionToObject;
