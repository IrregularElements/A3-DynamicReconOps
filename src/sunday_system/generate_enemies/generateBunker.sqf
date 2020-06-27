params ["_AOIndex"];

if (count (((AOLocations select _AOIndex) select 2) select 5) > 0) then {		
	_thisPos = [(((AOLocations select _AOIndex) select 2) select 5)] call sun_selectRemove;
	_bunkerTypes = ["Land_BagBunker_Large_F", "Land_BagBunker_Tower_F"];
	_bunkerPos = [_thisPos, 0, 100, 15, 0, 1, 0, [], [[0,0,0], [0,0,0]]] call BIS_fnc_findSafePos;
	if !(_bunkerPos isEqualTo [0,0,0]) then {
		_startDir = random 360;
		_bunkerType = selectRandom _bunkerTypes;
		_bunker = [_bunkerType, _bunkerPos, _startDir] call dro_createSimpleObject;
		_dir = _startDir;
		_rotation = _startDir;		
		_bunkerGroup = createGroup enemySide;
		
		_numBunkerGuards = round (([2,4] call BIS_fnc_randomInt) * aiMultiplier);	
		
		_guardPositions = [];
		for "_i" from 1 to 4 do {
			_cornerPos = [_bunkerPos, 10, _dir] call dro_extendPos;
			_objList = (selectRandom compositionsBunkerCorners);								
			_spawnedObjects = [_cornerPos, _dir, _objList] call BIS_fnc_ObjectsMapper;
			// Collect guard positions					
			{
				if (typeOf _x == "Sign_Arrow_Blue_F") then {
					_spawnPos = getPos _x;
					_dir = getDir _x;				
					_guardPositions pushBack [_spawnPos, _dir];				
					deleteVehicle _x;			
				};
			} forEach _spawnedObjects;
			_dir = _dir + 90;
			_rotation = _rotation + 90;
		};		
		{
			_guardGroup = [(_x select 0), enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
			waitUntil {!isNil "_guardGroup"};
			_guardUnit = ((units _guardGroup) select 0);					
			_guardUnit setFormDir (_x select 1);
			_guardUnit setDir (_x select 1);				
			[_guardUnit] joinSilent _bunkerGroup;
			if (random 1 > 0.6) then {
				[_guardUnit, (selectRandom ["STAND", "STAND_IA", "KNEEL", "WATCH", "WATCH1", "WATCH2"]), "ASIS"] call BIS_fnc_ambientAnimCombat;
			};
		} forEach _guardPositions;
		
		_numBunkerGuards = (_numBunkerGuards - (count units _bunkerGroup)) max 0;
		
		switch (_bunkerType) do {
			case "Land_BagBunker_Large_F": {
				_leader = nil;
				_leaderChosen = 0;
				for "_n" from 1 to _numBunkerGuards do {
					_dir = random 360;
					_spawnPos = [_bunkerPos, 4, _dir] call dro_extendPos;
					_bunkerGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;												
					if (!isNil "_bunkerGroup") then {
						_unit = ((units _bunkerGroup) select 0);
						_unit setFormDir _dir;
						_unit setDir _dir;							
						if (_leaderChosen == 0) then {
							_leader = _unit;
							_leaderChosen = 1;
						} else {
							[_unit] joinSilent _leader;
							doStop _unit;
						};
						if (random 1 > 0.6) then {
							[_unit, (selectRandom ["STAND", "STAND_IA", "KNEEL", "WATCH", "WATCH1", "WATCH2"]), "ASIS"] call BIS_fnc_ambientAnimCombat;
						};
					};
					
				};
			};
			case "Land_BagBunker_Tower_F": {				
				_leader = nil;
				_leaderChosen = 0;
				for "_n" from 1 to _numBunkerGuards do {
					_dir = random 360;						
					_spawnPos = _bunkerPos findEmptyPosition [0,20];
					_bunkerGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;						
					if (!isNil "_bunkerGroup") then {
						_unit = ((units _bunkerGroup) select 0);
						_unit setFormDir _dir;
						_unit setDir _dir;
						if (_leaderChosen == 0) then {
							_leader = _unit;
							_leaderChosen = 1;
						} else {
							[_unit] joinSilent _leader;
							doStop _unit;
						};
						if (random 1 > 0.6) then {
							[_unit, (selectRandom ["STAND", "STAND_IA", "KNEEL", "WATCH", "WATCH1", "WATCH2"]), "ASIS"] call BIS_fnc_ambientAnimCombat;
						};
					};
				};					
				_spawnPos = [(getPos _bunker select 0), (getPos _bunker select 1), (getPos _bunker select 2)];
				_bunkerGroup = [_spawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;					
				if (!isNil "_bunkerGroup") then {
					_unit = ((units _bunkerGroup) select 0);
					_unit setPosATL [(getPos _bunker select 0), (getPos _bunker select 1), (getPos _bunker select 2)+3.5];
					_dir = random 360;
					_unit setFormDir _dir;
					_unit setDir _dir;
				};					
			};
		};
		
		if (count eStaticClasses > 0) then {
			if ((random 1) > 0.6) then {
				_turretClass = selectRandom eStaticClasses;
				_turretPos = _bunkerPos findEmptyPosition [5, 20, _turretClass];
				if (count _turretPos > 0) then {
					_turret = _turretClass createVehicle _turretPos;
					[_turret] call sun_createVehicleCrew;
					//createVehicleCrew _turret;
				};
			};
		};
			
		
		/*
		_garMarker = createMarker [format["garMkr%1", random 10000], getPos _bunker];
		_garMarker setMarkerShape "ICON";
		_garMarker setMarkerColor "ColorOrange";
		_garMarker setMarkerType "mil_objective";
		*/
		
		// Create Marker
		_markerName = format["bunkerMkr%1", floor(random 10000)];
		_markerBunker = createMarker [_markerName, _bunkerPos];			
		_markerBunker setMarkerShape "ICON";
		_markerBunker setMarkerType "hd_warning";
		_markerBunker setMarkerText "Bunker";			
		_markerBunker setMarkerColor markerColorEnemy;
		_markerBunker setMarkerAlpha 0;
		enemyIntelMarkers pushBack _markerBunker;			
		
		travelPosPOIMil pushBack _bunkerPos;
	};
	
};