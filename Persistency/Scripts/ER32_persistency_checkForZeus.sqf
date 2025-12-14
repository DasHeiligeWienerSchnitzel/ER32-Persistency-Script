waitUntil { !isNull player };

private _actionID = "";
private _actionAdded = false;

while { true } do {
	private _isAdmin = player getVariable ["#adminLogged", false];
	private _isZeus  = !isNull (getAssignedCuratorLogic player);

	if ((_isAdmin || _isZeus) && !_actionAdded) then {
		// --- Create ACE action ---
		_actionID = [
			"ER32_persistency_saveAction",
			"Save Builds to Clipboard",
			"",
			{
				[] execVM "Scripts\ER32_persistency_copyToClipboard.sqf";
			},
			{ true }
		] call ace_interact_menu_fnc_createAction;

		// Add
		[player, 1, ["ACE_SelfActions"], _actionID] call ace_interact_menu_fnc_addActionToObject;

		_actionAdded = true;
	};

	if (!(_isAdmin || _isZeus) && _actionAdded) then {
		// Remove the action again
		[player, 1, ["ACE_SelfActions"], "ER32_persistency_saveAction"] call ace_interact_menu_fnc_removeActionFromObject;

		_actionAdded = false;
	};

	sleep 1;
};