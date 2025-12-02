//In this script the whole interaction with the crates and the flatbed is done.

params ["_object","_crates","_loadDistance"];

/*
Get nearest Flatbed that has the needed classname.
The positions for the crates are dependent on the used flatbed. 
If you want to use another vehicle, you first need to find suitable positions points for your crates.
*/

_nearestFlatbed_green = nearestObject [_object,"UK3CB_BAF_MAN_HX58_Cargo_Green_A"]; 
_nearestFlatbed_sand = nearestObject [_object,"UK3CB_BAF_MAN_HX58_Cargo_Sand_A"]; 

_distance_green = _object distance _nearestFlatbed_green;
_distance_sand = _object distance _nearestFlatbed_sand;

_nearestFlatbed = objNull;
if (_distance_green > _distance_sand) then {
	_nearestFlatbed = _nearestFlatbed_sand
}else{
	_nearestFlatbed = _nearestFlatbed_green
};

/*
Gets the array of all the objects that are already loaded onto the flatbed.
Normally its [], but later on there will be objects stored inside.
*/

_objectsLoaded = _nearestFlatbed getVariable ["ER32_buildAndRessources_objectsLoaded",[]]; 

/*
Script will only fire if the distance between crate and flatbed is less then 15 meters.
*/

if (_object distance _nearestFlatbed < _loadDistance) then {
	
	/*
	Counts how many objects are on the flatbed and depending on how many there are,
	it will either put the crate in the first place, second place or will tell the player that
	there is no more space onto the flatbed.
	*/
	
	switch (count _objectsLoaded) do {
		case 0: {
			
			//Object will be stored in the list, containing all the objects on the flatbed.
			
			_objectsLoaded pushBack _object; 
			_nearestFlatbed setVariable ["ER32_buildAndRessources_objectsLoaded",_objectsLoaded, true];
			
			//Object will be attached to the first position on the flatbed.
			
			_object attachTo [_nearestFlatbed, [0,3.8,0.15]];
			_object setDir ((_nearestFlatbed getRelDir _object) - 90);
			
			/*
			The interaction on the object to store it onto a flatbed will be removed, because it is already on an flatbed.
			Will be later added if the object is removed again from the flatbed.
			*/
			[_object, 0, ["ACE_MainActions","ER32_buildAndRessources_loadOnFlatbed"]] remoteExecCall ["ace_interact_menu_fnc_removeActionFromObject",-2,true];
			
			[_nearestFlatbed,_crates,_loadDistance] remoteExecCall ["ER32_fnc_buildAndRessources_unloadFromFlatbed",0,true];
			
		};
		case 1: {
			_objectsLoaded pushBack _object;
			_nearestFlatbed setVariable ["ER32_buildAndRessources_objectsLoaded",_objectsLoaded, true];
			_object attachTo [_nearestFlatbed, [0,0.6,0.15]];
			_object setDir ((_nearestFlatbed getRelDir _object) - 90);
			[_object, 0, ["ACE_MainActions","ER32_buildAndRessources_loadOnFlatbed"]] remoteExecCall ["ace_interact_menu_fnc_removeActionFromObject",-2,true];
		};
		default {hint "Flatbed already full!"};
	};
}else{hint "No viable vehicle nearby!"};


/*
save script welches solange truck sich bewegt velocity checkt. Falls velocity auf null ist kann das script auch aufhören periodisch nachzuschauen.
*/
