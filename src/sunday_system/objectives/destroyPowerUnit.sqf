params ["_thisBuilding"];
_powerObjects = [["Land_PowerGenerator_F", 270], ["Land_DieselGroundPowerUnit_01_F", 270], ["Land_dp_transformer_F", 180], ["Land_DPP_01_transformer_F", 180]];

_wallPositions = [_thisBuilding] call sun_findWallPositions;
_objects = [];
{
	_wallPos = (_x select 0);
	_wallDir = (_x select 1);
	_powerType = selectRandom _powerObjects;
	_spawnPos = _wallPos findEmptyPosition [0, 2.5, (_powerType select 0)];
	if (count _spawnPos > 0) then {
		_object = createVehicle [(_powerType select 0), _spawnPos, [], 0, "NONE"];
		_object setDir (_wallDir + (_powerType select 1));
		_objects pushBack _object;
	};	
} forEach _wallPositions;

if (count _objects == 0) exitWith {};

_powerUnit = [_objects] call sun_selectRemove;
{
	deleteVehicle _x;
} forEach _objects;

// Create marker
_markerName = format["powerMkr%1", floor(random 10000)];
_markerPower = createMarker [_markerName, (getPos _powerUnit)];
_markerPower setMarkerShape "ICON";
_markerPower setMarkerType  "mil_triangle_noShadow";
_markerPower setMarkerSize [0.65, 0.65];
_markerPower setMarkerColor "ColorBlack";
_markerPower setMarkerText "Power";
_markerPower setMarkerAlpha 1;

waitUntil {(missionNameSpace getVariable ["playersReady", 0]) == 1};

// Create Task
_taskName = format ["task%1", floor(random 100000)];
_powerName = ((configFile >> "CfgVehicles" >> (typeOf _powerUnit) >> "displayName") call BIS_fnc_GetCfgData);
if (["powerTask"] call BIS_fnc_taskExists) then {
	// Create this subtask	
	_taskTitle = format ["Sabotage %1", _powerName];
	_taskDesc = format ["Destroy or sabotage the %1 to disrupt power in the immediate area.", _powerName];
	_task = [[_taskName, "powerTask"], true, [_taskDesc, _taskTitle, _markerName], _powerUnit, "CREATED", 0, false, true, "danger", true] call BIS_fnc_setTask;
} else {
	// Create parent task
	_taskTitle = "Optional: Sabotage Power Grid";
	_taskDesc = format ["Take out the %1 power grid in the %2 region. Each power unit you destroy will help reduce the enemy's ability to locate your team. Consider taking a toolkit to sabotage the power units silently.", enemyFactionName, aoLocationName];
	_task = ["powerTask", true, [_taskDesc, _taskTitle, ""], objNull, "CREATED", 0, true, true, "danger", true] call BIS_fnc_setTask;	
	// Create this subtask		
	_taskTitle = format ["Sabotage %1", _powerName];
	_taskDesc = format ["Destroy or sabotage the %1 to disrupt power in the immediate area.", _powerName];
	_task = [[_taskName, "powerTask"], true, [_taskDesc, _taskTitle, _markerName], _powerUnit, "CREATED", 0, false, true, "danger", true] call BIS_fnc_setTask;
	// Listen for all subtasks to be completed
	[] spawn {
		waitUntil {
			sleep 3;
			_completed = 0;
			{
				if ([_x] call BIS_fnc_taskCompleted) then {
					_completed = _completed + 1;
				};
			} forEach (["powerTask"] call BIS_fnc_taskChildren);
			(_completed == count (["powerTask"] call BIS_fnc_taskChildren))
		};		
		["powerTask", "SUCCEEDED", true] spawn BIS_fnc_taskSetState;		
	};
};

_powerUnit setVariable ["thisTask", _taskName, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), "danger", true];

[_powerUnit] call dro_addSabotageAction;
// Add destruction event handler
_powerUnit addEventHandler ["Explosion", {
	if ((_this select 1) > 0.2) then {
		(_this select 0) setdamage 1;		
		_taskState = [((_this select 0) getVariable 'thisTask')] call BIS_fnc_taskState;		
		if !(_taskState isEqualTo "SUCCEEDED") then {
			[((_this select 0) getVariable 'thisTask'), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
			missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
		};
		(_this select 0) removeAllEventHandlers "Explosion";
		(_this select 0) removeAllEventHandlers "Killed";
	};
}];

_powerUnit addEventHandler ["Killed", {				
	_taskState = [((_this select 0) getVariable 'thisTask')] call BIS_fnc_taskState;	
	if !(_taskState isEqualTo "SUCCEEDED") then {
		[((_this select 0) getVariable 'thisTask'), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
		missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
	};
	(_this select 0) removeAllEventHandlers "Explosion";
	(_this select 0) removeAllEventHandlers "Killed";
}];				

[_powerUnit] spawn {
	waitUntil {
		sleep 3;
		_taskState = [((_this select 0) getVariable 'thisTask')] call BIS_fnc_taskState;	
		(_taskState == "SUCCEEDED")
	};
	{
		//_x switchLight "OFF";
		for "_i" from 0 to count getAllHitPointsDamage _x - 1 do {
			[_x, [_i, 0.97]] remoteExec ["setHitIndex", 2];
			//_x setHitIndex [_i, 0.97];
		};
		/*
		_x setHit ["light_1_hitpoint", 0.97];
		_x setHit ["light_2_hitpoint", 0.97];
		_x setHit ["light_3_hitpoint", 0.97];
		_x setHit ["light_4_hitpoint", 0.97];
		*/
	} forEach nearestObjects [
		(_this select 0), 
		[		
			"Lamps_base_F",
			"PowerLines_base_F",
			"PowerLines_Small_base_F"
		],
		300
	];
};
