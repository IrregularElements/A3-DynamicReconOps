params ["_AOIndex"];

if (count (((AOLocations select _AOIndex) select 2) select 1) > 0) then {
	_roadPosition = [(((AOLocations select _AOIndex) select 2) select 1)] call sun_selectRemove; 
	
	// Get road direction
	_roadList = _roadPosition nearRoads 50;
	_thisRoad = _roadList select 0;
	_roadConnectedTo = roadsConnectedTo _thisRoad;
	if (count _roadConnectedTo == 0) exitWith {_bunker = "Land_BagBunker_Small_F" createVehicle _roadPosition;};
	_connectedRoad = _roadConnectedTo select 0;
	_direction = [_thisRoad, _connectedRoad] call BIS_fnc_DirTo;
			
	_objects = (selectRandom compositionsRoadblocks);	
	_spawnedObjects = [_roadPosition, _direction, _objects] call BIS_fnc_ObjectsMapper;
	
	// Collect guard positions
	_guardPositions = [];		
	{
		if (typeOf _x == "Sign_Arrow_Blue_F") then {
			_spawnPos = getPos _x;
			_dir = getDir _x;				
			_guardPositions pushBack [_spawnPos, _dir];				
			deleteVehicle _x;			
		};
	} forEach _spawnedObjects;
	
	// Spawn guards at guard positions
	_leader = nil;
	_leaderChosen = 0;		
	_totalRoadInf = round (4 * aiMultiplier);
	_roadInfCount = 0;
	{
		_spawnPos = (_x select 0) findEmptyPosition [0,10];
		if (count _spawnPos > 0) then {
			if (_roadInfCount < _totalRoadInf) then {
				_guardGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
				waitUntil {!isNil "_guardGroup"};
				_guardUnit = ((units _guardGroup) select 0);					
				_guardUnit setFormDir (_x select 1);
				_guardUnit setDir (_x select 1);				
				if (_leaderChosen == 0) then {
					_leader = _guardUnit;
					_leaderChosen = 1;
				} else {
					[_guardUnit] joinSilent _leader;
					doStop _guardUnit;
				};
				if (random 1 > 0.5) then {
					[_guardUnit, (selectRandom ["STAND", "STAND_IA", "KNEEL", "WATCH", "WATCH1", "WATCH2"]), "ASIS"] call BIS_fnc_ambientAnimCombat;
				};
				_roadInfCount = _roadInfCount + 1;				
			};
		};
	} forEach _guardPositions;	
	
	if (count eStaticClasses > 0) then {
		if ((random 1) > 0.6) then {
			_turretClass = selectRandom eStaticClasses;
			_turretPos = _roadPosition findEmptyPosition [0, 16, _turretClass];
			if (count _turretPos > 0) then {
				_turret = _turretClass createVehicle _turretPos;
				[_turret] call sun_createVehicleCrew;
				//createVehicleCrew _turret;
			};
		};
	};
	
	// Create Marker
	_markerName = format["roadblockMkr%1", floor(random 10000)];
	_markerRoadblock = createMarker [_markerName, _roadPosition];			
	_markerRoadblock setMarkerShape "ICON";
	_markerRoadblock setMarkerType "hd_warning";
	_markerRoadblock setMarkerText "Checkpoint";		
	_markerRoadblock setMarkerColor markerColorEnemy;
	_markerRoadblock setMarkerAlpha 0;
	enemyIntelMarkers pushBack _markerRoadblock;
	
	travelPosPOIMil pushBack _roadPosition;
};