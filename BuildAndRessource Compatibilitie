//This code spawns the four different kinds of ressource crates.

params ["_classname_list","_spawner","_spawnpoints","_names","_ressources","_crates","_loadDistance","_maxHeight","_minHeight"];

for "_i" from 0 to ((count _spawner) - 1) do {
	for "_j" from 0 to 3 do {
		(_spawner select _i) addAction
		[
			"Spawn Crate (" + (_names select _j) + ")" , // Title
			{
				// Script
				params ["_target", "_caller", "_actionID", "_arguments"];
				_arguments params ["_spawnpoints","_crates","_i","_j","_ressources","_names","_loadDistance"];
				
				//Checks if a box is already inside the spawn area, otherwise will spawn the crate
				
				private _nearbyCrates = (_spawnpoints select _i) nearEntities 2.5;
				
				if (count _nearbyCrates == 0) then {
					private _ressource = +_ressources;
					for "_k" from 0 to 3 do {
						if (_k != _j) then {
							_ressource set [_k, 0];
						};
					};
					
					//Spawn the crate and add it's ressource.
					
					private _crate = createVehicle [_crates select _j, getPos (_spawnpoints select _i), [], 0, "CAN_COLLIDE"]; 
					_crate setDir getDir (_spawnpoints select _i);
					_crate setVariable ["ER32_buildAndRessources_ressources", _ressource, true];
					
					[_crate] remoteExecCall ["ER32_fnc_persistency_saveObject",2];
					
					//Removes and adds ace interactions.
					
					[_crate, -1] remoteExecCall ["ace_cargo_fnc_setSize",0,true];
					[_crate, -1] remoteExecCall ["ace_cargo_fnc_setSpace",0,true];
					[_crate,_names] remoteExecCall ["ER32_fnc_buildAndRessources_checkForRessources",0,true];
					[_crate,_crates,_loadDistance] remoteExecCall ["ER32_fnc_buildAndRessources_loadOnFlatbed",0,true];
					
				}else{
					hint "Space occupied!";
				};
			},
			[_spawnpoints,_crates,_i,_j,_ressources,_names,_loadDistance],		// arguments
			1.5,		// priority
			true,		// showWindow
			true,		// hideOnUse
			"",			// shortcut
			"true",		// condition
			10,			// radius
			false,		// unconscious
			"",			// selection
			""			// memoryPoint
		];
	};
};

[_classname_list,_crates,_names,_maxHeight,_minHeight] execVM "Scripts\ER32_buildAndRessources_addActions.sqf";
