
_pos = [];
_validBuildings = [];
{
	_thisAOLoc = _x;
	if (count ((_thisAOLoc select 2) select 7) > 0) then {
		{_validBuildings pushBack _x} forEach ((_thisAOLoc select 2) select 7);
	};	
} forEach AOLocations;
_validPositions = [];
if (count _validBuildings == 0) then {
	{
		_thisAOLoc = _x;
		if (count ((_thisAOLoc select 2) select 2) > 0) then {{_validPositions pushBack _x} forEach ((_thisAOLoc select 2) select 2)};	
		if (count ((_thisAOLoc select 2) select 3) > 0) then {{_validPositions pushBack _x} forEach ((_thisAOLoc select 2) select 3)};	
		if (count ((_thisAOLoc select 2) select 6) > 0) then {{_validPositions pushBack _x} forEach ((_thisAOLoc select 2) select 6)};	
	} forEach AOLocations;
	if (count _validPositions > 0) then {
		_pos = selectRandom _validPositions;
	};
} else {
	_pos = getPos (selectRandom _validBuildings);
};

if (count _pos > 0) then {
	_civType = selectRandom civClasses;
	_group = createGroup civilian;
	_contactCiv = _group createUnit [_civType, _pos, [], 0, "NONE"];	

	_taskName = format ["civContactTask%1", (round(random 100000))];
	_taskDesc = format ["We have a local informant in the area who is willing to supply us with information. Meet with %1 and question him.", name _contactCiv];
	_taskTitle = "Optional: Contact Informant";
	_task = [_taskName, true, [_taskDesc, _taskTitle, ""], [_contactCiv, true], "CREATED", 0.5, false, true, "talk", true] call BIS_fnc_setTask;

	_contactCiv allowFleeing 0;
	_contactCiv setVariable ["taskName", _taskName, true];

	[
		_contactCiv,
		"Question",
		"\A3\ui_f\data\igui\cfg\simpleTasks\types\talk_ca.paa",
		"\A3\ui_f\data\igui\cfg\simpleTasks\types\talk_ca.paa",
		"(alive _target) && ((_this distance _target) < 3)",
		"(alive _target) && ((_this distance _target) < 3)",
		{
			[(_this select 0), true] remoteExec ["stop", (_this select 0)];		
			_dir = [(_this select 0), (_this select 1)] call BIS_fnc_dirTo;
			[(_this select 0), _dir] remoteExec ["setFormDir", (_this select 0)];
			[(_this select 0), _dir] remoteExec ["setDir", (_this select 0)];
			[(_this select 0), true] remoteExec ["setRandomLip", 0];		
		},
		{
			[(_this select 0), false] remoteExec ["setRandomLip", (_this select 0)];
		},
		{
			[5, true, (_this select 1)] execVM "sunday_system\intel\revealIntel.sqf";
			//[5, true, (_this select 1), (_this select 0)] call dro_revealMapIntel;
			[(_this select 0) getVariable "taskName", "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
			[(_this select 0), false] remoteExec ["stop", (_this select 0)];
			[(_this select 0), false] remoteExec ["setRandomLip", 0];
			[(_this select 0), (_this select 2)] remoteExec ["bis_fnc_holdActionRemove", 0, true];
			[(_this select 0), 0.5] remoteExec ["allowFleeing", (_this select 0)];		
		},
		{
			[(_this select 0), false] remoteExec ["stop", (_this select 0)];
			[(_this select 0), false] remoteExec ["setRandomLip", 0];		
		},
		[],
		10,
		10,
		true,
		false
	] remoteExec ["bis_fnc_holdActionAdd", 0, true];

	_index = _contactCiv addMPEventHandler ["mpkilled", {
		if (![((_this select 0) getVariable "taskName")] call BIS_fnc_taskCompleted) then {
			[((_this select 0) getVariable "taskName"), "FAILED", true] spawn BIS_fnc_taskSetState;
		};
	}];

	[_contactCiv, _taskName, _taskDesc, _taskTitle] spawn {
		params ["_contactCiv", "_taskName", "_taskDesc", "_taskTitle"];
		// Reassign task after loadout phase
		waitUntil {(missionNameSpace getVariable ["playersReady", 0]) == 1};
		_task = [_taskName, true, [_taskDesc, _taskTitle, ""], [_contactCiv, true], "CREATED", 0.5, false, true, "talk", true] call BIS_fnc_setTask;			
	};
};