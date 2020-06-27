// intel object to be picked up
// marks locations of enemy roadblocks, bunkers - handwriting]

params ["_AOIndex"];
		
_building = [(((AOLocations select _AOIndex) select 2) select 7)] call sun_selectRemove;
_buildingClass = typeOf _building;	
_buildingPos = getPos _building;
_buildingPositions = [_building] call BIS_fnc_buildingPositions;

// Populate building				
_intelClasses = ["Land_MetalCase_01_medium_F", "Land_MetalCase_01_small_F", "Land_Suitcase_F"];
_intelClass = selectRandom _intelClasses;

_validIntel = [];
_allIntel = [];

{	
	_thisIntel = _intelClass createVehicle _x;
	_bbr = boundingBoxReal _thisIntel;
	_p1 = _bbr select 0;
	_p2 = _bbr select 1;
	_maxHeight = abs ((_p2 select 2) - (_p1 select 2));
	_thisIntel setPos [(_x select 0), (_x select 1), ((_x select 2)+(_maxHeight/2))];
	_thisIntel setVelocity [0, 0, 0];
	_allIntel pushBack _thisIntel;	
	lineIntersectsSurfaces [ 
		getPosWorld _thisIntel,  
		getPosWorld _thisIntel vectorAdd [0, 0, 50],  
		_thisIntel, objNull, true, 1, 'GEOM', 'NONE' 
	] select 0 params ['','','','_building']; 
	if (_building isKindOf 'House') then {		
		_validIntel pushBack [_thisIntel, _x];
	};			
} forEach _buildingPositions;
	
_selectedIntel = (selectRandom _validIntel);
_thisIntel = (_selectedIntel select 0);
{
	if (_x != _thisIntel) then {
		deleteVehicle _x;
	};
} forEach _allIntel;

_buildingPositions = _buildingPositions - [(_selectedIntel select 1)];

_infCount = 0;
_totalInf = round (5 * aiMultiplier);
{
	_chance = random 100;
	if ((_chance > 50) && (_infCount < _totalInf)) then {
		_group = [_x, enemySide, eInfClassesForWeights, eInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
		_unit = ((units _group) select 0);
		if (!isNil "_unit") then {	
			_unit setUnitPos "UP";
			_infCount = _infCount + 1;
		};				
	};				
} forEach _buildingPositions;

// Spawn enemies to guard the building
_minAI = round (2 * aiMultiplier);
_maxAI = round (5 * aiMultiplier);
_spawnedSquad2 = [getPos _building, enemySide, eInfClassesForWeights, eInfClassWeights, [_minAI, _maxAI]] call dro_spawnGroupWeighted;			
if (!isNil "_spawnedSquad2") then {	
	[_spawnedSquad2, getPos _building, 100] call bis_fnc_taskPatrol;
};
// Marker
_markerName = format["intelMkr%1", floor(random 10000)];
_markerBuilding = createMarker [_markerName, _buildingPos];			
_markerBuilding setMarkerShape "ICON";
_markerBuilding setMarkerType "mil_pickup";
_markerBuilding setMarkerColor markerColorEnemy;		
_markerBuilding setMarkerAlpha 0;

// Create task
_buildingName = ((configFile >> "CfgVehicles" >> _buildingClass >> "displayName") call BIS_fnc_GetCfgData);
_intelName = ((configFile >> "CfgVehicles" >> _intelClass >> "displayName") call BIS_fnc_GetCfgData);			
			
_taskName = format ["task%1", floor(random 100000)];
_taskTitle = "Retrieve Intel";
_taskDesc = format ["Retrieve the %1 intelligence from a %2 located at the marked <marker name='%4'>%3</marker>. As well as containing important information desired by high command this intel package may contain useful information about troop placement in the AO.",enemyFactionName, _intelName,_buildingName, _markerName];
_taskType = "documents";
missionNamespace setVariable [format ["%1Completed", _taskName], 0, true];
missionNamespace setVariable [(format ["%1_taskType", _taskName]), _taskType, true];

[_thisIntel, _taskName] remoteExec ["sun_addIntel", 0, true];
	
allObjectives pushBack _taskName;
objData pushBack [
	_taskName,
	_taskDesc,
	_taskTitle,
	_markerName,
	_taskType,
	_buildingPos,
	0
];
diag_log format ["DRO: Task created: %1, %2", _taskTitle, _taskName];
diag_log format ["DRO: objData: %1", objData];
diag_log format ["DRO: allObjectives is now %1", allObjectives];