params ["_AOIndex"];

_reconChance = 0;
_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_subTaskName = format ["subtask%1", floor(random 100000)];
_subTaskName2 = format ["subtask%1", floor(random 100000)];
_thisPos = [];
_thisHouse = [(((AOLocations select _AOIndex) select 2) select 7)] call sun_selectRemove;	
_buildingPositions = [_thisHouse] call BIS_fnc_buildingPositions;
_thisCiv = objNull;
if (count _buildingPositions > 0) then {
	_thisPos = selectRandom _buildingPositions;
	_civType = selectRandom civClasses;
	_group = createGroup playersSide;
	_thisCiv = _group createUnit [_civType, _thisPos, [], 0, "NONE"];	
	[_thisCiv] call dro_civDeathHandler;
	_thisCiv setVariable ["NOHOSTILE", true, true];
	_thisCiv setCaptive true;
	_thisCiv disableAI "PATH";
};

if (isNull _thisCiv) exitWith {[(AOLocations call BIS_fnc_randomIndex), false] call fnc_selectObjective};

// Marker
_markerName = format["protectMkr%1", floor(random 10000)];
_markerProtect = createMarker [_markerName, _thisPos];			
_markerProtect setMarkerShape "ICON";
_markerProtect setMarkerType "mil_end";
_markerProtect setMarkerColor "ColorCivilian";		
_markerProtect setMarkerAlpha 0;

// Create task
_taskTitle = "Protect Civilian";
_taskDesc = selectRandom [
	(format ["%3 is a journalist in the %2 region who has been under house arrest for the last year. Based on intelligence gathered in a previous operation we believe that there is now a credible threat on his life from %1. Move to %3's location and protect him.", enemyFactionName, aoLocationName, name _thisCiv]),
	(format ["We've received a communication that a local civilian is willing to give us detailed information on %1 troop movements but that his life is currently threatened. Find him and protect him from harm.", enemyFactionName, aoLocationName, name _thisCiv]),
	(format ["%1 has begun cracking down on protestors in the %2 region. A vocal campaigner named %3 has called for aid after receiving credible threats on his life. Get to him and protect him from harm.", enemyFactionName, aoLocationName, name _thisCiv])
];

_taskType = "defend";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

// Create subtasks	
_subTaskDesc = format ["Make contact with %1.", name _thisCiv];
_subTaskTitle = "Contact";
_subTasks pushBack [_subTaskName, _subTaskDesc, _subTaskTitle, "help"];
missionNamespace setVariable [(format ["%1_taskType", _subTaskName]), "help", true];

_subTaskDesc2 = format ["Protect %1 from harm.", name _thisCiv];
_subTaskTitle2 = "Protect";
_subTasks pushBack [_subTaskName2, _subTaskDesc2, _subTaskTitle2, "defend"];
missionNamespace setVariable [(format ["%1_taskType", _subTaskName2]), "defend", true];

_thisCiv setVariable ["taskName", _taskName, true];
_thisCiv setVariable ["subTasks", _subTasks, true];

// Completion trigger
[_thisCiv, _taskName, _subTasks] spawn {
	_thisCiv = (_this select 0);
	_taskName = (_this select 1);
	_subTasks = (_this select 2);
	if (_taskName call BIS_fnc_taskCompleted) exitWith {};
	
	waitUntil {
		sleep 3;
		if (_taskName call BIS_fnc_taskCompleted) exitWith {true};		
		(((leader (grpNetId call BIS_fnc_groupFromNetId)) distance _thisCiv) < 6)
	};
	if (_taskName call BIS_fnc_taskCompleted) exitWith {};
	["PROTECT_CIV_MEET", (name (leader (grpNetId call BIS_fnc_groupFromNetId))), [name _thisCiv], false] spawn dro_sendProgressMessage;
	
	_thisCiv setUnitPos "DOWN";	
	_thisCiv setCaptive false;
	
	[((_subTasks select 0) select 0), 'SUCCEEDED', true] spawn BIS_fnc_taskSetState;
	missionNamespace setVariable [format ['%1Completed', ((_subTasks select 0) select 0)], 1, true];
	[((_subTasks select 0) select 1), "ASSIGNED", true] call BIS_fnc_taskSetState;
	_allGroups = [];
	_messageSent = false;
	for "_i" from 0 to ([1, 3] call BIS_fnc_randomInt) step 1 do {		
		_spawnGroup = [(getPos _thisCiv)] call dro_triggerAmbushSpawn;		
		if (!isNull _spawnGroup) then {
			_allGroups pushBack _spawnGroup;
			//_spawnGroup deleteGroupWhenEmpty false;
		};		
		if (!_messageSent && !isNull _spawnGroup) then {
			_messageSent = true;
			if (_taskName call BIS_fnc_taskCompleted) exitWith {};
			["AMBUSHCIV", "Command", [name _thisCiv]] spawn dro_sendProgressMessage;			
		};
		sleep 40;		
	};
	
	if (count _allGroups > 0) then {
		waitUntil {
			sleep 5;
			if (_taskName call BIS_fnc_taskCompleted) exitWith {true};
			[_allGroups] call sun_checkAllDeadFleeing
		};
	};
	
	if (_taskName call BIS_fnc_taskCompleted) exitWith {};
	["PROTECT_CIV_CLEAR", (name (leader (grpNetId call BIS_fnc_groupFromNetId))), [name _thisCiv], false] spawn dro_sendProgressMessage;
	[((_subTasks select 0) select 1), "SUCCEEDED", true] call BIS_fnc_taskSetState;
	missionNamespace setVariable [format ['%1Completed', ((_subTasks select 0) select 1)], 1, true];
	[_taskName, "SUCCEEDED", true] call BIS_fnc_taskSetState;
	missionNamespace setVariable [format ['%1Completed', _taskName], 1, true];
	
	sleep 30;
	_thisCiv enableAI "PATH";
	_thisCiv setUnitPos "UP";
};

// Create triggers
_thisCiv addEventHandler ["Killed", {
	_unit = (_this select 0);
	[(_unit getVariable "taskName"), 'FAILED', true] spawn BIS_fnc_taskSetState;
}]; 

allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_thisPos,
	0,
	_subTasks,
	_thisCiv,
	0	
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];