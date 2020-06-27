// *****
// SETUP ENEMIES
// *****

params ["_AOIndex", "_AOSize"];

private _debug = 0;
_patrolGroups = [];
_numPlayers = count allPlayers;
enemyAlertableGroups = [];
enemySemiAlertableGroups = [];
_sizeMod = switch (_AOSize) do {
	case "REGULAR": {1};
	case "SMALL": {0.4};
	default {1};
};
enemyPosCollection = [];

// If this is the first AO location then garrison all the previously located military buildings in the entire AO area
if (_AOIndex == 0) then {
	// Generate building garrisons for locations near tasks
	[round (8*_sizeMod)] call dro_localBuildingPatrol;
	{
		_chance = (random 1);
		if (_chance > 0.3) then {
			[_x] call dro_spawnEnemyGarrison;
		};
	} forEach milBuildings;
};

diag_log format ["DRO: AO %1, aiMultiplier = %2, _sizeMod = %3", _AOIndex, aiMultiplier, _sizeMod];

// Generate extra building garrisons
//_tempBuildings = [];
_tempBuildings = (((AOLocations select _AOIndex) select 2) select 7);
_numGarrisons = (round ((([4, 6] call BIS_fnc_randomInt) * aiMultiplier) * _sizeMod) min (count (((AOLocations select _AOIndex) select 2) select 7)));
diag_log format ["DRO: AO %1, Generate enemies - garrisons = %2", _AOIndex, _numGarrisons];
if (_numGarrisons > 0) then {
	for "_g" from 1 to _numGarrisons step 1 do {		
		[([_tempBuildings] call sun_selectRemove)] call dro_spawnEnemyGarrison;
		//[(selectRandom (((AOLocations select _AOIndex) select 2) select 7))] call dro_spawnEnemyGarrison;
	};
};
/*
_numCompounds = (round ((([2, 4] call BIS_fnc_randomInt) * aiMultiplier) * _sizeMod) min (count (((AOLocations select _AOIndex) select 2) select 9)));
diag_log format ["DRO: AO %1, Generate enemies - compounds = %2", _AOIndex, _numCompounds];
if (_numCompounds > 0) then {
	for "_c" from 1 to _numCompounds step 1 do {	
		[(selectRandom (((AOLocations select _AOIndex) select 2) select 9))] call fnc_spawnEnemyCompound;
	};
};
*/
// Infantry patrols
_numInf = round ((([1,3] call BIS_fnc_randomInt) * aiMultiplier) * _sizeMod);	
_numInf = _numInf + (floor(_numPlayers/2));
diag_log format ["DRO: AO %1, Generate enemies - infantry patrols = %2", _AOIndex, _numInf];
if (missionPreset == 3) then {_numInf = _numInf min 1};
if (_numInf > 0) then {
	for "_infIndex" from 1 to _numInf step 1 do {
		_infPosition = [];
		if (_infIndex <= 1) then {
			_infPosition = selectRandom (((AOLocations select _AOIndex) select 2) select 2)
		} else {
			_infPosition = selectRandom (((AOLocations select _AOIndex) select 2) select 3)
		};
		if (count _infPosition > 0) then {
			_spawnedSquad = nil;	
			_minAI = (round ((4 * aiMultiplier) / (0.4 * _numInf)) min 6);
			_maxAI = (round ((6 * aiMultiplier) / (0.4 * _numInf)) min 8);
			_spawnedSquad = [_infPosition, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;					
			waitUntil {!isNil "_spawnedSquad"};	
			_patrolGroups pushBack _spawnedSquad;				
			enemyAlertableGroups pushBack _spawnedSquad;	
		};
	};
};

if (missionPreset == 3) then {
	// Combined Arms tanks
	// Vehicle patrol
	if (count eAPCClasses > 0) then {
		_numVeh = round ([2,3] call BIS_fnc_randomInt);
		for "_x" from 1 to _numVeh do {
			_indexes = [[0, 1]] call dro_checkAOIndexes;
			if (count _indexes > 0) then {			
				_vehPos = [(((AOLocations select _AOIndex) select 2) select (selectRandom _indexes))] call sun_selectRemove;			
				_vehType = selectRandom eAPCClasses;
				_veh = createVehicle [_vehType, _vehPos, [], 0, "NONE"];		
				[_veh] call sun_createVehicleCrew;
				//createVehicleCrew _veh;
				waitUntil {!isNull (driver _veh)};				
				_vehSlots = [_vehType] call sun_getTrueCargo;
				if (_vehSlots > 2) then {					
					_minAI = (_vehSlots/2) * aiMultiplier;							
					_reinfGroup = [_vehPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _vehSlots]] call dro_spawnGroupWeighted;				
					waitUntil {!isNil "_reinfGroup"};
					[_reinfGroup, _veh, true] spawn sun_groupToVehicle;					
				};				
				_patrolGroups pushBack (group (driver _veh));
				//[(group(driver _veh)), _vehPos, 800] call BIS_fnc_taskPatrol;		
				_vehPos = selectRandom (((AOLocations select _AOIndex) select 2) select 0);
			};			
		};
	};
	if (count eTankClasses > 0) then {
		_numVeh = ([1,3] call BIS_fnc_randomInt);
		for "_x" from 1 to _numVeh do {
			_indexes = [[0, 1]] call dro_checkAOIndexes;
			if (count _indexes > 0) then {			
				_vehPos = [(((AOLocations select _AOIndex) select 2) select (selectRandom _indexes))] call sun_selectRemove;			
				_vehType = selectRandom eTankClasses;
				_veh = createVehicle [_vehType, _vehPos, [], 0, "NONE"];		
				[_veh] call sun_createVehicleCrew;
				//createVehicleCrew _veh;
				waitUntil {!isNull (driver _veh)};				
				_vehSlots = [_vehType] call sun_getTrueCargo;
				if (_vehSlots > 2) then {					
					_minAI = (_vehSlots/2) * aiMultiplier;							
					_reinfGroup = [_vehPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _vehSlots]] call dro_spawnGroupWeighted;				
					waitUntil {!isNil "_reinfGroup"};
					[_reinfGroup, _veh, true] spawn sun_groupToVehicle;					
				};				
				_patrolGroups pushBack (group (driver _veh));
				//[(group(driver _veh)), _vehPos, 800] call BIS_fnc_taskPatrol;		
				_vehPos = selectRandom (((AOLocations select _AOIndex) select 2) select 0);
				[[(group (driver _veh)), "TANK"]] call dro_unitTaskObjective;
			};			
		};
	};	
};

// Vehicle patrol
if (count eCarClasses > 0) then {
	if (random 1 > 0.4) then {
		_numVeh = round (([1,2] call BIS_fnc_randomInt) * _sizeMod);
		for "_x" from 1 to _numVeh do {
			_indexes = [[0, 1]] call dro_checkAOIndexes;
			if (count _indexes > 0) then {			
				_vehPos = [(((AOLocations select _AOIndex) select 2) select (selectRandom _indexes))] call sun_selectRemove;			
				_vehType = selectRandom eCarClasses;
				_veh = createVehicle [_vehType, _vehPos, [], 0, "NONE"];		
				[_veh] call sun_createVehicleCrew;
				//createVehicleCrew _veh;
				waitUntil {!isNull (driver _veh)};				
				_vehSlots = [_vehType] call sun_getTrueCargo;
				if (_vehSlots > 2) then {					
					_minAI = (_vehSlots/2) * aiMultiplier;							
					_reinfGroup = [_vehPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _vehSlots]] call dro_spawnGroupWeighted;				
					waitUntil {!isNil "_reinfGroup"};
					[_reinfGroup, _veh, true] spawn sun_groupToVehicle;					
				};				
				_patrolGroups pushBack (group (driver _veh));
				//[(group(driver _veh)), _vehPos, 800] call BIS_fnc_taskPatrol;		
				_vehPos = selectRandom (((AOLocations select _AOIndex) select 2) select 0);
			};			
		};
	};
};

// Generate military POIs
{
	switch (_x) do {
		case "ROADBLOCK": {						
			_numRoadblocks = round ((([2,3] call BIS_fnc_randomInt) * aiMultiplier) * _sizeMod);
			diag_log format ["DRO: AO %1, Generate enemies - _numRoadblocks = %2", _AOIndex, _numRoadblocks];
			if (_numRoadblocks > 0) then {
				for "_x" from 1 to _numRoadblocks step 1 do {
					[_AOIndex] call fnc_generateRoadblock;
				};
			};		
		};
		case "BUNKER": {			
			_numBunkers = round ((([1,2] call BIS_fnc_randomInt) * aiMultiplier) * _sizeMod);
			diag_log format ["DRO: AO %1, Generate enemies - _numBunkers = %2", _AOIndex, _numBunkers];
			if (_numBunkers > 0) then {
				for "_x" from 1 to _numBunkers step 1 do {	
					[_AOIndex] call fnc_generateBunker;
				};
			};
		};		
		case "CAMP": {			
			_numCamps = round ((([2,4] call BIS_fnc_randomInt) * aiMultiplier) * _sizeMod);
			diag_log format ["DRO: AO %1, Generate enemies - _numCamps = %2", _AOIndex, _numCamps];
			if (_numCamps > 0) then {
				for "_x" from 1 to _numCamps step 1 do {
					_campPositions = [];
					if (count (((AOLocations select _AOIndex) select 2) select 6) > 0) then {_campPositions pushBack 6};
					if (count (((AOLocations select _AOIndex) select 2) select 9) > 0) then {_campPositions pushBack 9};
					_campPos = [(((AOLocations select _AOIndex) select 2) select (selectRandom _campPositions))] call sun_selectRemove;
					[_campPos] execVM "sunday_system\generate_ao\generateCampsite.sqf";
					_minAI = (round ((2 * aiMultiplier) / (0.4 * _numCamps)) min 3);
					_maxAI = (round ((3 * aiMultiplier) / (0.4 * _numCamps)) min 5);		
					_spawnedSquad = nil;
					_spawnedSquad = [_campPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI,_maxAI]] call dro_spawnGroupWeighted;			
					waitUntil {!isNil "_spawnedSquad"};
					[_spawnedSquad, _campPos] call bis_fnc_taskDefend;	
					enemyAlertableGroups pushBack _spawnedSquad;
					_markerName = format["campMkr%1", floor(random 10000)];
					_markerCamp = createMarker [_markerName, _campPos];			
					_markerCamp setMarkerShape "ICON";
					_markerCamp setMarkerType "hd_warning";
					_markerCamp setMarkerText "Camp";			
					_markerCamp setMarkerColor markerColorEnemy;
					_markerCamp setMarkerAlpha 0;				
					travelPosPOIMil pushBack _campPos;	
				};
			};
		};		
		case "EMPLACEMENT": {
			_numEmplacements = round ((([1,2] call BIS_fnc_randomInt) * aiMultiplier) * _sizeMod);
			diag_log format ["DRO: AO %1, Generate enemies - _numEmplacements = %2", _AOIndex, _numEmplacements];
			if (_numEmplacements > 0) then {
				for "_x" from 1 to _numEmplacements step 1 do {	
					[_AOIndex] call fnc_generateEmplacement;
				};
			};			
		};
		case "BARRIER": {
			if (_sizeMod > 0.5) then {
				[_AOIndex] call fnc_generateBarrier;
			};
		};
	};
} forEach AO_POIs;


// Get a selection of possible new travel locations if chance allows
if (count _patrolGroups > 0) then {
	diag_log format ["DRO: _patrolGroups = %1", _patrolGroups];
	_availableTravelPositions = [];			
	{
		if (_forEachIndex != 0) then {			
			if ((_x select 3) isEqualTo "ROUTE") then {
				if (count ((_x select 2) select 0) > 0) then {_availableTravelPositions = _availableTravelPositions + ((_x select 2) select 0)};
				if (count ((_x select 2) select 1) > 0) then {_availableTravelPositions = _availableTravelPositions + ((_x select 2) select 1)};
				if (count ((_x select 2) select 2) > 0) then {_availableTravelPositions = _availableTravelPositions + ((_x select 2) select 2)};
			};
		} else {
			if (count ((_x select 2) select 0) > 0) then {_availableTravelPositions = _availableTravelPositions + ((_x select 2) select 0)};
			if (count ((_x select 2) select 1) > 0) then {_availableTravelPositions = _availableTravelPositions + ((_x select 2) select 1)};
			if (count ((_x select 2) select 2) > 0) then {_availableTravelPositions = _availableTravelPositions + ((_x select 2) select 2)};
		};
	} forEach AOLocations;
	_availableTravelPositions = _availableTravelPositions + travelPosPOIMil;
	{
		_thisGroup = _x;
		_startPos = (getPos (leader _thisGroup));
		if (count _availableTravelPositions > 0) then {
			_thesePositions = _availableTravelPositions;
			diag_log format ["DRO: Enemy patrol _thesePositions = %1", _thesePositions];					
			// Initialise route waypoints
			_wpFirst = _thisGroup addWaypoint [_startPos, 0];
			_wpFirst setWaypointType "MOVE";
			_wpFirst setWaypointBehaviour "SAFE";
			_wpFirst setWaypointSpeed "LIMITED";
			for "_w" from 1 to (([3, 6] call BIS_fnc_randomInt) min (count _thesePositions)) step 1 do {				
				_pos = [_thesePositions] call sun_selectRemove;
				_pos = if (typeName _pos == "OBJECT") then {getPos _pos} else {_pos};
				_wp = _thisGroup addWaypoint [_pos, 0];
				_wp setWaypointType "MOVE";
				_wp setWaypointCompletionRadius 20;
				_wp setWaypointTimeout [45, 60, 90];					
			};
			_wpLast = _thisGroup addWaypoint [_startPos, 0];
			_wpLast setWaypointType "CYCLE";		
			_wpLast setWaypointCompletionRadius 20;
			_wpLast setWaypointTimeout [20, 30, 45];								
		} else {		
			if (vehicle (leader _thisGroup) == (leader _thisGroup)) then {
				[_thisGroup, _startPos, 200] call BIS_fnc_taskPatrol;	
			} else {
				[_thisGroup, _startPos, 800] call BIS_fnc_taskPatrol;	
			};
		};
		if (_debug == 1) then {
			_garMarker = createMarker [format["garMkr%1", random 10000], _startPos];
			_garMarker setMarkerShape "ICON";
			_garMarker setMarkerColor "ColorOrange";
			_garMarker setMarkerType "mil_dot";
			_garMarker setMarkerText format ["Patrol %2: %1", _thisGroup, _forEachIndex];
			_garMarker setMarkerSize [0.7, 0.7];
			diag_log format ["Patrol %1: %2", _forEachIndex, (waypoints _thisGroup)];
		};
	} forEach _patrolGroups;		
	
};

publicVariable "enemyIntelMarkers";