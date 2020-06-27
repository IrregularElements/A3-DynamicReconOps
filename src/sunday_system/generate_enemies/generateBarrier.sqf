params ["_center"];

_guardTowers = [];

_startDir = (random 360);
_thisDir = _startDir;
_startPos = [_center, (aoSize/4.5), _startDir] call BIS_fnc_relPos;		
// Create hexagon of barriers
_clearedRoadArray = 0;		
_barrierClasses = [
	"Land_HBarrier_5_F",
	"Land_HBarrier_Big_F",
	"Land_HBarrierWall6_F",
	"Land_Razorwire_F",
	"Land_BagFence_Long_F"			
];		
_barrierClass1 = selectRandom _barrierClasses;
_barrierClass2 = selectRandom _barrierClasses;		
for "_i" from 1 to 6 do {
	if (random 1 > 0.4) then {
		_thisDir = (_thisDir + 60);
		_thisPos = [_center, (aoSize/4.5), _thisDir] call BIS_fnc_relPos;			
		if (!surfaceIsWater _thisPos) then {
			_markerName = format["barrierMkr%1", _i];
			_markerBarrier = createMarker [_markerName, _thisPos];			
			_markerBarrier setMarkerShape "ICON";
			_markerBarrier setMarkerType "mil_ambush";			
			_markerBarrier setMarkerSize [1, 2];			
			_markerBarrier setMarkerDir (_thisDir-90);	
		};
		_barrierSidePosArray = [];
		_lastPos = _thisPos;
		for "_n" from 1 to 5 do {
			_pos = [_lastPos, 30, (_thisDir-90)] call BIS_fnc_relPos;
			_barrierSidePosArray pushBack _pos;
			_lastPos = _pos;
		};
		_lastPos = _thisPos;
		for "_n" from 1 to 5 do {
			_pos = [_lastPos, 30, (_thisDir+90)] call BIS_fnc_relPos;
			_barrierSidePosArray pushBack _pos;
			_lastPos = _pos;
		};			
		{
			if (!surfaceIsWater _x) then {
				_nRoads = _x nearRoads 22;
				if (count _nRoads > 0) then {
					if (_clearedRoadArray == 0) then {
						_clearedRoadArray = 1;
						roadblockPosArray = [];
					};
					roadblockPosArray pushBack (getPos (_nRoads select 0));
					
				} else {
					_nBuilding = nearestBuilding _x;
					if ((_x distance _nBuilding) > 10) then {
						_checkPos = (_x isFlatEmpty [-1, -1, 1, 10, 0, false]);
						if (count _checkPos > 0) then {
							[_barrierClass1, _checkPos, _thisDir] call dro_createSimpleObject;																
							_barrier2Pos = [_x, 8, (_thisDir-90)] call BIS_fnc_relPos;	
							_checkPos = (_barrier2Pos isFlatEmpty [0.5, -1, -1, 1, -1, false]);
							if (count _checkPos > 0) then {																
								[_barrierClass2, _checkPos, _thisDir] call dro_createSimpleObject;									
							};
							_barrier3Pos = [_x, 8, (_thisDir+90)] call BIS_fnc_relPos;
							_checkPos = (_barrier3Pos isFlatEmpty [0.5, -1, -1, 1, -1, false]);
							if (count _checkPos > 0) then {	
								[_barrierClass2, _checkPos, _thisDir] call dro_createSimpleObject;									
							};
						};						
					};			
				};				
			};
		} forEach _barrierSidePosArray;
	};			
};	

// Populate hexagon corners with guard towers
_lastAngle = (_startDir + 30);
for "_i" from 1 to 6 do {
	_thisDir = (_lastAngle + 60);
	_thisPos = [_center, ((aoSize/4.5)+40), _thisDir] call BIS_fnc_relPos;			
	_checkPos = _thisPos findEmptyPosition [0, 50, "Land_Cargo_Patrol_V3_F"];
	if (count _checkPos > 0) then {
		if (!surfaceIsWater _checkPos) then {
			_guardTower = "Land_Cargo_Patrol_V3_F" createVehicle _checkPos;
			_guardTower setDir (_thisDir+180);				
			_dirVector = vectorDir _guardTower;
			_guardTower setVectorDirAndUp [_dirVector,[0,0,1]];				
			_guardTowers pushBack _guardTower;
		};		
	};
	_lastAngle = _thisDir;
};		

for "_k" from 1 to 6 step 1 do {
	_markerName = format["barrierMkr%1", _k];
	_markerName setMarkerColor markerColorEnemy;
};

// Populate guardposts
{
	_buildingPosition = (_x buildingPos 1);
	_group = [_buildingPosition, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
	if (!isNil "_group") then {
		_unit = ((units _group) select 0);
		_unit setFormDir ((getDir _x)+180);
		_unit setDir ((getDir _x)+180);	
	};
} forEach _guardTowers;

// Barrier patrols
_numBarrierInf = round (([2,3] call BIS_fnc_randomInt) * aiMultiplier);	
_numBarrierInf = _numBarrierInf + (ceil(_numPlayers/2));	
for "_infIndex" from 1 to _numBarrierInf step 1 do {			
	_maxIndex = 0;	
	if ((count _guardTowers) == 1) then {
		if (!isNil "_spawnedSquad") then {
			_infBarrierSpawnPos = getPos(_guardTowers select _select);	
			_spawnedSquad = nil;
			_minAI = round (2 * aiMultiplier);
			_maxAI = round (3 * aiMultiplier);				
			_spawnedSquad = [_infBarrierSpawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;				
			if (!isNil "_spawnedSquad") then {
				[_spawnedSquad, _infBarrierSpawnPos, 50] call BIS_fnc_taskPatrol;
				enemyAlertableGroups pushBack _spawnedSquad;
			};
		};
	} else {
		_maxIndex = ((count _guardTowers)-1);
		_select = 0;
		
		_select = (floor(random(count _guardTowers)));
		if (_select == _maxIndex) then {_select = _maxIndex - 1};
			
		_infBarrierSpawnPos = getPos(_guardTowers select _select);	
		_spawnedSquad = nil;
		_minAI = round (2 * aiMultiplier);
		_maxAI = round (4 * aiMultiplier);
		_spawnedSquad = [_infBarrierSpawnPos, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;	
		if (!isNil "_spawnedSquad") then {				
			_wp0 = _spawnedSquad addWaypoint[_infBarrierSpawnPos, 10];
			_wp0 setWaypointBehaviour "SAFE";
			_wp0 setWaypointSpeed "LIMITED";
			_wp0 setWaypointType "MOVE";
			_wp0 setWaypointTimeout [5, 10, 6];
			
			_select2 = _select + 1;
			_nextPos = getPos(_guardTowers select _select2);	
			_wp1 = _spawnedSquad addWaypoint[_nextPos, 10];
			_wp1 setWaypointTimeout [5, 10, 6];
			_wp1 setWaypointType "MOVE";
			
			_wp2 = _spawnedSquad addWaypoint[_nextPos, 10];				
			_wp2 setWaypointType "CYCLE";		

			enemyAlertableGroups pushBack _spawnedSquad;		
		};		
	};		
};


