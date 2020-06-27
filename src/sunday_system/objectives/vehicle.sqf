params ["_AOIndex"];

_break = false;
_reconChance = (random 1);
_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];
_locateSubTaskName = format ["subtask%1", floor(random 100000)];

// Get vehicles with a preference for those without turrets
_vehicleList = if (count eCarNoTurretClasses > 0) then {
	if (count eCarNoTurretClasses < 3) then {
		eCarClasses + eCarNoTurretClasses
	} else {
		eCarNoTurretClasses
	};	
} else {
	eCarClasses
};

// Get transport slot bounds
_cargoRange = [100, 0];
{
	_transportSlots = ([_x] call sun_getTrueCargo);
	if (_forEachIndex == 0) then {
		_cargoRange set [0, _transportSlots];
		_cargoRange set [1, _transportSlots];
	};	
	if (_transportSlots < (_cargoRange select 0)) then {
		_cargoRange set [0, _transportSlots];
	};
	if (_transportSlots > (_cargoRange select 1)) then {
		_cargoRange set [1, _transportSlots];
	};
} forEach _vehicleList;

// Get vehicle slot weights
_cargoWeights = [];
{
	_transportSlots = ([_x] call sun_getTrueCargo);
	_thisWeight = linearConversion [(_cargoRange select 0)-1, (_cargoRange select 1)+1, _transportSlots, 0, 1, true]; 
	_cargoWeights pushBack _thisWeight;
} forEach _vehicleList;

// If possible remove vehicles with too few slots
if (({_x < 0.2} count _cargoWeights) < (count _cargoWeights - 1)) then {
	_deletePositions = [];
	{
		if (_x < 0.2) then {
			_deletePositions pushBack _forEachIndex;
		};
	} forEach _cargoWeights;
	{
		_vehicleList deleteAt _x;
		_cargoWeights deleteAt _x;
	} forEach _deletePositions;	
};

diag_log _vehicleList;
diag_log _cargoWeights;

_vehicleType = [_vehicleList, _cargoWeights] call BIS_fnc_selectRandomWeighted;
//_vehicleType = selectRandom _vehicleList;		
_thisPos = [(((AOLocations select _AOIndex) select 2) select 0)] call sun_selectRemove;

_thisVeh = _vehicleType createVehicle _thisPos;
_thisVeh = [_thisVeh] call sun_checkVehicleSpawn;
if (isNull _thisVeh) exitWith {[(AOLocations call BIS_fnc_randomIndex), false] call fnc_selectObjective};

_roads = _thisVeh nearRoads 50;
_dir = 0;
if (count _roads > 0) then {
	_firstRoad = _roads select 0;
	if (count (roadsConnectedTo _firstRoad) > 0) then {			
		_connectedRoad = ((roadsConnectedTo _firstRoad) select 0);
		_dir = [_firstRoad, _connectedRoad] call BIS_fnc_dirTo;
		_thisVeh setDir _dir;
	} else {
		_thisVeh setDir (random 360);
	};
};

// Get a selection of possible new travel locations if chance allows
_travelPositions = [];			
_possibleLocsMaxIndex = (count AOLocations)-1;
if (_possibleLocsMaxIndex > 0) then {
	for "_i" from 0 to ([0, _possibleLocsMaxIndex] call BIS_fnc_randomInt) step 1 do {		
		_possibleLocTypes = [];
		if (_i == _AOIndex) then {
			if (count (((AOLocations select _i) select 2) select 0) > 0) then {_possibleLocTypes pushBack 0};
			if (count (((AOLocations select _i) select 2) select 1) > 0) then {_possibleLocTypes pushBack 1};			
		} else {
			if (((AOLocations select _i) select 3) isEqualTo "ROUTE") then {
				diag_log "Location route found";
				if (count (((AOLocations select _i) select 2) select 0) > 0) then {_possibleLocTypes pushBack 0};
				if (count (((AOLocations select _i) select 2) select 1) > 0) then {_possibleLocTypes pushBack 1};
			};
		};
		diag_log format ["_possibleLocTypes = %1", _possibleLocTypes];		
		if (count _possibleLocTypes > 0) then {
			if (_i == 0) then {
				_selectedPosArray = ((((AOLocations select _i) select 2) select (selectRandom _possibleLocTypes)));					
				_selectedPos = [_selectedPosArray] call sun_selectRemove;					
				_travelPositions pushBack _selectedPos;
			} else {
				if (random 1 > 0.5) then {
					_selectedPosArray = ((((AOLocations select _i) select 2) select (selectRandom _possibleLocTypes)));					
					_selectedPos = [_selectedPosArray] call sun_selectRemove;					
					_travelPositions pushBack _selectedPos;
				};
			};
		};		
	};
};



_vehStyle = if (count _travelPositions > 0) then {
	selectRandom ["LOADING", "WAITING", "DRIVING"]
} else {
	selectRandom ["LOADING", "WAITING"]
}; 

switch (_vehStyle) do {
	case "LOADING": {
		// Choose between repair situation or loading situation
		if (random 1> 0.5) then {
				// Find any doors to animate
			{ 
				if ( ((configFile >> "CfgVehicles" >> _vehicleType >> "AnimationSources" >> (configName _x) >> "source") call BIS_fnc_GetCfgData) == "door") then {
					_thisVeh animateDoor [(configName _x), 1, true];
				};
			} forEach ("true" configClasses (configFile >> "CfgVehicles" >> _vehicleType >> "AnimationSources"));

			// Create fluff objects			
			_itemsArray = [		
				"CargoNet_01_barrels_F",
				"CargoNet_01_box_F",			
				"Land_PaperBox_closed_F",
				"Land_PaperBox_open_empty_F",
				"Land_PaperBox_open_full_F",
				"Land_Pallet_MilBoxes_F",
				"Land_Pallets_F",
				"Land_Pallet_F"					
			];
			_item1Pos = [getPos _thisVeh, 5, (_dir - 155)] call dro_extendPos;
			_item2Pos = [_item1Pos, 1.5, (_dir - 180)] call dro_extendPos;
			_item1 = selectRandom _itemsArray;
			_item2 = selectRandom _itemsArray;
			[_item1, _item1Pos, _dir] call dro_createSimpleObject;
			[_item2, _item2Pos, _dir] call dro_createSimpleObject;	

			_guardPos = [getPos _thisVeh, 3, (_dir - 180)] call dro_extendPos;		
			_group = [_guardPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
		
		} else {
			_wheels = [];
			{ 
				if (["wheel", ((_x >> "name") call BIS_fnc_getCfgData), false] call BIS_fnc_inString) then {
					_wheels pushBack ((_x >> "name") call BIS_fnc_getCfgData);
				};
			} forEach ("true" configClasses (configFile >> "CfgVehicles" >> _vehicleType >> "HitPoints"));
			if (count _wheels > 0) then {
				_thisVeh sethit [(selectRandom _wheels), 1];				
			};
			
			// Create fluff objects			
			_itemsArray = [		
				"Land_Tyre_F",
				"Oil_Spill_F",
				"Land_CanisterFuel_F",
				"Land_Wrench_F"								
			];
			_item1Pos = [getPos _thisVeh, 2.5, (_dir - 85)] call dro_extendPos;
			_item2Pos = [_item1Pos, 1, _dir] call dro_extendPos;			
			_item1 = selectRandom _itemsArray;
			_item2 = selectRandom _itemsArray;
			[_item1, _item1Pos, (random 360)] call dro_createSimpleObject;
			[_item2, _item2Pos, (random 360)] call dro_createSimpleObject;
			_toolkit = "Item_ToolKit" createVehicle ([getPos _thisVeh, 2.5, (_dir - 140)] call dro_extendPos);
			
			_guardPos = [getPos _thisVeh, 3, (_dir - 90)] call dro_extendPos;		
			_group = [_guardPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
			_unit = ((units _group) select 0);
			_unit setUnitPos "MIDDLE";
			_unit setFormDir (_dir + 90);
			_unit setDir (_dir + 90);
		};		
		
		_spawnPos = [_thisPos, 6, (random 360)] call dro_extendPos;
		_minAI = round (3 * aiMultiplier);
		_maxAI = round (5 * aiMultiplier);
		_spawnedSquad = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;			
		if (!isNil "_spawnedSquad") then {
			[_spawnedSquad, _thisPos, [10, 30], "limited"] execVM "sunday_system\orders\patrolArea.sqf";	
		};		
	};
	case "WAITING": {
		[_thisVeh] call sun_createVehicleCrew;
		//createVehicleCrew _thisVeh;
		_thisVeh engineOn true;
		
		_spawnPos = [_thisPos, 6, (random 360)] call dro_extendPos;
		_minAI = round (3 * aiMultiplier);
		_maxAI = round (5 * aiMultiplier);
		_spawnedSquad = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;			
		if (!isNil "_spawnedSquad") then {
			[_spawnedSquad, _thisPos, [10, 30], "limited"] execVM "sunday_system\orders\patrolArea.sqf";	
		};	
		
	};
	case "DRIVING": {
		//createVehicleCrew _thisVeh;
		[_thisVeh] call sun_createVehicleCrew;
		waitUntil {!isNull (driver _thisVeh)};
		_vehGroup = group (driver _thisVeh);
		// Initialise route waypoints
		_wpFirst = _vehGroup addWaypoint [_thisPos, 0];
		_wpFirst setWaypointType "MOVE";
		_wpFirst setWaypointBehaviour "AWARE";
		_wpFirst setWaypointSpeed "LIMITED";			
		{
			_pos = if (typeName _x == "OBJECT") then {getPos _x} else {_x};
			_wp = _vehGroup addWaypoint [_pos, 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointCompletionRadius 20;
			_wp setWaypointTimeout [60, 90, 60];
			if (_reconChance < baseReconChance) then {
				taskIntel pushBack [_taskName, _pos, _intelSubTaskName, "WAYPOINT"];
			};
		} forEach _travelPositions;
		_wpLast = _vehGroup addWaypoint [_thisPos, 0];
		_wpLast setWaypointType "CYCLE";		
		_wpLast setWaypointCompletionRadius 20;
		_wpLast setWaypointTimeout [60, 90, 60];
		if (_reconChance < baseReconChance) then {
			taskIntel pushBack [_taskName, _thisPos, _intelSubTaskName, "WAYPOINT"];
		};
	};	
};

// Create Task		
_vehicleName = ((configFile >> "CfgVehicles" >> _vehicleType >> "displayName") call BIS_fnc_GetCfgData);

_taskTitle = "Destroy Vehicle";
_taskType = "destroy";
_taskDesc = selectRandom [
	(format ["Today's tasking will see you sabotaging enemy assets in the region. We have reports that a %2 %1 can be found somewhere in the area and command would like to see it taken out of action.", _vehicleName, enemyFactionName, aoLocationName]),
	(format ["Late last night %2 started moving assets into the %3 area, presenting us with a prime opportunity for a small force to damage their operations. The target is a %1 which will need to be located and destroyed.", _vehicleName, enemyFactionName, aoLocationName]),
	(format ["A guerilla element has provided us with information that a %2 %1 carrying important cargo has been sighted in the %3 region. Destroying the %1 along with its cargo will hamper %2 resupply efforts and assist the general %4 offensive.", _vehicleName, enemyFactionName, aoLocationName, playersFactionName])	
];
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];
_thisVeh setVariable ["thisTask", _taskName, true];

[_thisVeh] call dro_addSabotageAction;
_thisVeh setVehicleLock "LOCKED";

// Add destruction event handler
if (isMultiplayer) then {
	_thisVeh addMPEventHandler ["MPKilled", {
		[((_this select 0) getVariable ("thisTask")), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
		missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
		
	}]; 
} else {
	_thisVeh addEventHandler ["Killed", {	
		[((_this select 0) getVariable ("thisTask")), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
		missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];
		
	}];
};	

// Marker
_markerName = format["vehMkr%1", floor(random 10000)];
[_thisVeh, _taskName, _markerName, _intelSubTaskName, markerColorEnemy, 400] execVM "sunday_system\objectives\followingMarker.sqf";

// Create intel subtasks	
_subTaskDesc = format ["Collect all intelligence on the target to narrow down your search. Intel may reduce the size of your search radius and locate any positions they're moving through. Check the bodies of %1 team leaders, search marked intel locations and complete any intel tasks.", enemyFactionName];
_subTaskTitle = "Optional: Collect Intel";
_subTasks pushBack [_intelSubTaskName, _subTaskDesc, _subTaskTitle, "documents"];
missionNamespace setVariable [(format ["%1_taskType", _intelSubTaskName]), "documents", true];

allObjectives pushBack _taskName;

objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_thisPos,
	_reconChance,
	_subTasks,
	_thisVeh
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];