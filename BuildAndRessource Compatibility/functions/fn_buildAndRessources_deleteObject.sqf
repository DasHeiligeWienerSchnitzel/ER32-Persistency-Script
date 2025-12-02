params ["_object","_time","_name","_sortedCrates","_cost","_crates"];

_ER32_buildAndRessources_objectDelete = [
	"ER32_buildAndRessources_objectDelete",
	"Remove",
	"",
	{														
		//On activation
		
		params ["_target","_player","_params"];
		_params params ["_time","_name","_sortedCrates","_cost"];
		
		//Play animation
		
		_player playMove "Acts_carFixingWheel";
		
		//Progress bar
		
		[															
			_time/2, //Time needed
			[_target,_player,_sortedCrates,_cost,_crates],
			{														
				//On completion
				
				params ["_params"];
				_params params ["_target","_player","_sortedCrates","_cost","_crates"];
				
				//Deletes the object again and removes animation.
				
				deleteVehicle _target;
				hint "Deconstruction completed.";
				_player switchMove "Stand";
				_addOrRemove = "add";
				[_sortedCrates,_cost,_addOrRemove,_crates] remoteExecCall ["ER32_fnc_buildAndRessources_updateRessources",2];
				[_target] remoteExecCall ["ER32_fnc_persistency_removeObject",2];
			},
			{														
				//On failure
				params ["_params"];
				
				_player = _params select 1;
				hint "Deconstruction cancelled.";
				_player switchMove "Stand";
			},
			_name + " is being destructed."
		] call ace_common_fnc_progressBar;
	},
	{true},
	{},
	[_time,_name,_sortedCrates,_cost]	//Arguments
	] call ace_interact_menu_fnc_createAction;
[_object, 0, ["ACE_MainActions"], _ER32_buildAndRessources_objectDelete] call ace_interact_menu_fnc_addActionToObject;
