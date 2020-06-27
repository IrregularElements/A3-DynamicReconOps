params ["_AOIndex"];

_reconChance = (random 1);
_subTasks = [];
_taskName = format ["task%1", floor(random 100000)];
_intelSubTaskName = format ["subtask%1", floor(random 100000)];

_vehicleList = eHeliClasses;
_vehicleType = selectRandom _vehicleList;

_helipadUsed = 0;
_thisPos = [];		
if (count (((AOLocations select _AOIndex) select 2) select 8) > 0) then {			
	_thisPos = getPos ([(((AOLocations select _AOIndex) select 2) select 8)] call sun_selectRemove);
	_helipadUsed = 1;
} else {
	_thisPos = [(((AOLocations select _AOIndex) select 2) select 4)] call sun_selectRemove;	
	_tempPos = [(_thisPos select 0), (_thisPos select 1), 0];
	_thisPos = _tempPos;			
};		
	
// Create Task		
_heliName = ((configFile >> "CfgVehicles" >> _vehicleType >> "displayName") call BIS_fnc_GetCfgData);
_taskTitle = "Destroy Helicopter";
_taskDesc = "";
_taskType = "destroy";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];

_thisVeh = _vehicleType createVehicle _thisPos;
_thisVeh = [_thisVeh] call sun_checkVehicleSpawn;
if (isNull _thisVeh) exitWith {[(AOLocations call BIS_fnc_randomIndex), false] call fnc_selectObjective};			
_thisVeh setVariable ["thisTask", _taskName, true];			
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

[_thisVeh] call dro_addSabotageAction;

// Add destruction event handler
_thisVeh addEventHandler ["Killed", {
	[((_this select 0) getVariable ("thisTask")), "SUCCEEDED", true] spawn BIS_fnc_taskSetState;
	missionNamespace setVariable [format ["%1Completed", ((_this select 0) getVariable ("thisTask"))], 1, true];	
} ];

// Create helipad and emplacements
if (_helipadUsed == 0) then {
	_startDir = random 360;
	_helipad = createVehicle  ["Land_HelipadSquare_F", _thisPos, [], 0, "CAN_COLLIDE"];
	_helipad setDir (_startDir+45);	
	_dir = _startDir;
	_rotation = (_startDir - 45);
	for "_i" from 1 to 4 do {
		_cornerPos = [_thisPos, 16, _dir] call BIS_fnc_relPos;
		_corner = ["Land_HBarrierWall_corner_F", _cornerPos, _rotation] call dro_createSimpleObject;		
		_lightPos = [_thisPos, 10, _dir] call BIS_fnc_relPos;
		_light = ["PortableHelipadLight_01_red_F", _lightPos, _rotation] call dro_createSimpleObject;		
		_dir = _dir + 90;
		_rotation = _rotation + 90;
	};
	
	_towerPos = [_thisPos, 20, random 360] call BIS_fnc_relPos;
	["Land_HBarrierTower_F", _towerPos, (_startDir+45)] call dro_createSimpleObject;	
} else {
	_thisPad = nearestObject [_thisPos, "HeliH"];
	_dir = (getDir _thisPad);
	for "_i" from 1 to 4 do {				
		_lightPos = [_thisPos, 10, _dir] call BIS_fnc_relPos;
		_light = ["PortableHelipadLight_01_red_F", _lightPos, _dir] call dro_createSimpleObject;		
		_dir = _dir + 90;				
	};
};

_randItems = floor (random 4);
_itemsArray = ["Land_AirIntakePlug_05_F", "Land_DieselGroundPowerUnit_01_F", "Land_HelicopterWheels_01_assembled_F", "Land_HelicopterWheels_01_disassembled_F", "Land_RotorCoversBag_01_F", "Windsock_01_F"];
for "_i" from 1 to _randItems do {
	_itemPos = [_thisPos, 8, 20, 1, 0, 1, 0] call BIS_fnc_findSafePos;
	_thisItem = selectRandom _itemsArray;
	[_thisItem, _itemPos, (random 360)] call dro_createSimpleObject;	
};

// Guards
_minAI = round (2 * aiMultiplier);
_maxAI = round (4 * aiMultiplier);
_spawnedSquad = [_thisPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;						
if (!isNil "_spawnedSquad") then {
	[_spawnedSquad, _thisPos] call bis_fnc_taskDefend;
};

// Get a selection of possible new travel locations if chance allows
_travelPositions = [];			
_possibleLocsMaxIndex = (count AOLocations)-1;
if (_possibleLocsMaxIndex > 0) then {
	for "_i" from 0 to ([0, _possibleLocsMaxIndex] call BIS_fnc_randomInt) step 1 do {
		if (_i != _AOIndex) then {
			_possibleLocTypes = [];
			if (count (((AOLocations select _i) select 2) select 4) > 0) then {_possibleLocTypes pushBack 4};
			if (count (((AOLocations select _i) select 2) select 5) > 0) then {_possibleLocTypes pushBack 5};
			if (count (((AOLocations select _i) select 2) select 8) > 0) then {_possibleLocTypes pushBack 8};
			diag_log format ["_possibleLocTypes = %1", _possibleLocTypes];		
			if (count _possibleLocTypes > 0) then {
				_selectedPosArray = if (8 in _possibleLocTypes) then {
					((((AOLocations select _i) select 2) select 8))
				} else {
					((((AOLocations select _i) select 2) select (selectRandom _possibleLocTypes)))
				};				
				_selectedPos = [_selectedPosArray] call sun_selectRemove;					
				_travelPositions pushBack _selectedPos;
			};
		};		
	};
};

if (count _travelPositions > 0) then {
	[_thisVeh] call sun_createVehicleCrew;
	//createVehicleCrew _thisVeh;
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
		_wp setWaypointStatements ["TRUE", "vehicle this land 'LAND'"];
		_wp setWaypointTimeout [150, 300, 200];
		if (_reconChance < baseReconChance) then {
			taskIntel pushBack [_taskName, _pos, _intelSubTaskName, "WAYPOINT"];
		};
	} forEach _travelPositions;
	_wpLast = _vehGroup addWaypoint [_thisPos, 0];
	_wpLast setWaypointType "CYCLE";		
	_wpLast setWaypointStatements ["TRUE", "vehicle this land 'LAND'"];
	_wpLast setWaypointTimeout [150, 300, 200];
	if (_reconChance < baseReconChance) then {
		taskIntel pushBack [_taskName, _thisPos, _intelSubTaskName, "WAYPOINT"];
	};
	_taskDesc = selectRandom [
		(format ["%2 air assets are stationed in the %3 region. We have intelligence that a %1 is present for drills and destroying it would be a significantly reduce %2 offensive capabilities.", _heliName, enemyFactionName, aoLocationName]),		
		(format ["%2 have been attacking %4 forces from hidden airbases at a number of locations. Intelligence has identified one of these locations are your team is tasked with destroying the %2 air asset.", _heliName, enemyFactionName, aoLocationName, playersFactionName]),
		(format ["Allied local militias have requested %4 help to destroy a %2 %1 that has been impeding their progress in the region. Locate and destroy the helicopter to give the militias further security from air attack.", _heliName, enemyFactionName, aoLocationName, playersFactionName])	
	];
} else {
	_taskDesc = selectRandom [
		(format ["Intelligence reports a target of opportunity in the %3 region: a %1 may have been forced down for repairs. Search the area, locate and destroy the %1.", _heliName, enemyFactionName, aoLocationName]),
		(format ["%3 is hosting a %2 %1 that we believe will be within reach of a small recon team. Enter the %3 region and destroy the helicopter.", _heliName, enemyFactionName, aoLocationName])		
	];
};

// Marker
_markerName = format["heliMkr%1", floor(random 10000)];
[_thisVeh, _taskName, _markerName, _intelSubTaskName, markerColorEnemy, 800] execVM "sunday_system\objectives\followingMarker.sqf";

// Create intel subtasks	
_subTaskDesc = format ["Collect all intelligence on the target to narrow down your search. Intel may reduce the size of your search radius and locate any positions they're moving through. Check the bodies of %1 team leaders, search marked intel locations and complete any intel tasks.", enemyFactionName];
_subTaskTitle = "Optional: Collect Intel";
_subTasks pushBack [_intelSubTaskName, _subTaskDesc, _subTaskTitle, "documents"];

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