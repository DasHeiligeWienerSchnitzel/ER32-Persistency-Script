/*
The code below will create the called object and place it infront of the player.
The player now has 4 possibilities to interact with the object.
1.	Place the object as it is shown with 'Left Mouse Button'.
2.	Change the height of the shown object with 'Mouse Wheel Up/Down'.
3.	Change the rotation of the shown object with 'CTRL and Mouse Wheel 'Up/Down'.
4.	Cancel the construction by pressing 'ESC' or 'Right Mouse Button'. 
*/

params ["_class","_cost","_name","_time","_caller","_crates","_names","_maxHeight","_minHeight"];

/*
First Checks for all eligible crates nearby.
And collects the collective ressources, stored inside.
Then these ressources will be compared with the needed cost of the wanted structure.
If enough the building will be build, otherwise the construction will not happen.
If successfull the ressources needed to build will be removed from the crates. 
*/

private _cratesNearby = _caller nearEntities [_crates,50]; //checks all crates nearby and puts them in an array.
private _sortedCrates = [_cratesNearby, [_caller], {_input0 distance _x}, "ASCEND"] call BIS_fnc_sortBy;
private _numberOfCratesNearby = count _cratesNearby; //counts the objects in the array.

/*
If atleast one crate exists, collects all the ressources and combines them in one array.
*/

private _ressources = [0,0,0,0];
private _enoughRessources = false;

if (_numberOfCratesNearby > 0) then {
	
	//Collects the ressources of all crates nearby.
	
	{
		private _ressourcesToAdd = _x getVariable ["ER32_buildAndRessources_ressources", [0,0,0,0]];
		for "_i" from 0 to ((count _ressources) - 1) do {
			_ressources set [_i, (_ressources select _i) + (_ressourcesToAdd select _i)];
		};
	}forEach _cratesNearby;
	
	//Now checks if the ressources are enough to cover the cost of the building.
	
	_enoughRessources = true;
	for "_i" from 0 to ((count _ressources) - 1) do {
		if ((_ressources select _i) < (_cost select _i)) then {
			_enoughRessources = false;
		};
	};
};

//If not enough ressources are found the below block will trigger.

if (_enoughRessources == false) exitWith {
	
	//If no ressource crates are nearby then there are no ressources nearby.
	
	if (_numberOfCratesNearby == 0) then {
		_ressources = [0,0,0,0];
	};
	
	//Tells the player how many ressources are nearby and how many are needed for the building cost.
	
	hint format [
		"Not enough ressources!\nRessources needed:\n"+(_names select 0)+": (%1/%2)\n"+(_names select 1)+": (%3/%4)\n"+(_names select 2)+": (%5/%6)\n"+(_names select 3)+": (%7/%8)",
		_ressources select 0,_cost select 0,
		_ressources select 1,_cost select 1,
		_ressources select 2,_cost select 2,
		_ressources select 3,_cost select 3
	];
};

//Gets the relative position of the soon to be created object to the player.

_tempObject = createVehicle [_class, [0,0,-1000], [], 0, "CAN_COLLIDE"];

_sizeOfObject = sizeOf _class;
_distance = (_sizeOfObject) - 5;
_distance = _distance max 3;
_distance = _distance min 20;

deleteVehicle _tempObject;

_pos = [position _caller, _distance, getDir _caller] call BIS_fnc_relPos; 

//Creates the object at the relativ position from the player.

_selectedObject = _caller getVariable ["ER32_buildAndRessources_selectedObject",objNull];
if (!isNull _selectedObject) then {
	deleteVehicle _selectedObject
};

_object = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];
_caller setVariable ["ER32_buildAndRessources_selectedObject",_object];

_object enableSimulationGlobal false;

_eventHandler = _caller addEventHandler ["AnimChanged", {
    params ["_unit", "_anim"];
    if (_anim find "ladder" > -1) then {
        _unit switchMove ""; // instantly cancel climbing
    };
}];


//Sets the direction of the object to the same direction the player is facing.

_object setDir getDir _caller; 

_posAdd = 0.0; 
_dirAdd = 0;
_placed = false;
_canceled = false;

/*
This loop will constantly update the position and rotation of the created object.
And check if any of the 4 combination, explained above, are fullfilled.
*/
private _loopTimeStart = diag_tickTime;
while {(_placed == false) and (_canceled == false)} do {
	//Get a relative position infront of the caller.
	
	_pos = [position _caller, _distance, getDir _caller] call BIS_fnc_relPos;
	
	/*
	Depending on the key input the preview object height or rotation will be changed.
	- prevAction shows if the mousewheel has been scrolled up.
	- nextAction shows if the mousewheel has been scrolled down.
	- curatorGroupMod shows if the Left Ctrl Button has been pressed.
	*/
	
	//Increases the height if scroll wheel goes up.
	if ((inputAction "prevAction" > 0) and (inputAction "curatorGroupMod" == 0)) then {
		_posAdd = _posAdd + 0.05;
		_posAdd = _posAdd min _maxHeight;
	};
	
	//Decreases the height if scroll wheel goes down.
	if ((inputAction "nextAction" > 0) and (inputAction "curatorGroupMod" == 0)) then {
		_posAdd = _posAdd -0.05;
		_posAdd = _posAdd max _minHeight;
	};
	
	//Rotates clockwise if mousewheel scrolled up and Left Ctrl has been pressed.
	if ((inputAction "curatorGroupMod" > 0) and (inputAction "prevAction" > 0)) then {
		_dirAdd = _dirAdd + 1;
	};
	
	//Rotates counterclockwise if mousewheel scrolled down and Left Ctrl has been pressed.
	if ((inputAction "curatorGroupMod" > 0) and (inputAction "nextAction" > 0)) then {
		_dirAdd = _dirAdd - 1;
	};
	
	//Changes the position of the object accordingly.
	
	_pos set [2,(_pos select 2) + _posAdd];
	_object setPos _pos;
	_object setDir ((getDir _caller) + _dirAdd);
	sleep 0.001;
	/*
	Checks if the left/right mouse button has been pressed.
	On left mouse button press the object will be placed.
	On right mouse button press the placement will be canceled.
	*/
	
	if (inputMouse 0 == 1) then {
		_placed = true;
		_object hideObjectGlobal true;
	}else{
		if (inputMouse 1 == 1) then {
			_canceled = true;
			deleteVehicle _object;
			_caller setVariable ["ER32_buildAndRessources_selectedObject",objNull];
			_caller removeEventHandler ["AnimChanged",_eventHandler];
		};
	};
};
/*
After 'placing' the object. It will first vanish/hide and a progress bar will be shown.
Showing the duration till the object will be sucessfully build. 
*/

if (_canceled == true) exitWith {
	hint "Placement canceled.";
};

_caller playMove "Acts_carFixingWheel";
if (_placed == true) then {
	[																				
		_time, //Time needed for the progress bar to complete
		[_object,_caller,_name,_time,_ressources,_cost,_sortedCrates,_eventHandler,_crates], 	//Arguments
		{																			
			//Code that runs on completion
			
			params ["_params"];
			_params params ["_object","_caller","_name","_time","_ressources","_cost","_sortedCrates","_eventHandler","_crates"];
			
			//Shows the object again and stops the animation.
			
			_object hideObjectGlobal false;
			_object enableSimulationGlobal true;
			_caller switchMove "Stand";
			_addOrRemove = "remove";
			[_sortedCrates,_cost,_addOrRemove,_crates] remoteExecCall ["ER32_fnc_buildAndRessources_updateRessources",2];
			_caller setVariable ["ER32_buildAndRessources_selectedObject",objNull];
			[_object] remoteExecCall ["ER32_fnc_persistency_saveObject",2];
			[_object,_time,_name,_sortedCrates,_cost,_crates] remoteExecCall ["ER32_fnc_buildAndRessources_deleteObject",0,true];
			
			_caller removeEventHandler ["AnimChanged",_eventHandler];
			
		}, 												
		{
			//Code on Failure
			params ["_params"];
			_params params ["_object","_caller","_name","_time","_ressources","_cost","_sortedCrates","_eventHandler"];
			
			_caller switchMove "Stand";
			deleteVehicle _object;
			_caller setVariable ["ER32_buildAndRessources_selectedObject",objNull];
			_caller removeEventHandler ["AnimChanged",_eventHandler];
		}, 												
		_name + " is being build."	//Shown Text on progress bar
	] call ace_common_fnc_progressBar;
};
