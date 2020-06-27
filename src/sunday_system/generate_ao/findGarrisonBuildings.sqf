private ["_whileAttempts"];

_milCargoPosts = ["Land_Cargo_Patrol_V1_F", "Land_Cargo_Patrol_V2_F", "Land_Cargo_Patrol_V3_F"];

_taskLocations = [];
{
	_pushValue = nil;
	switch (typeName _x) do {
		case "OBJECT": {_pushValue = getPos _x};
		case "ARRAY": {_pushValue = _x};
		default {_pushValue = _x};
	};
	if (!isNil "_pushValue") then {
		_taskLocations pushBack ([_pushValue] call BIS_fnc_taskDestination);
	};
} forEach taskIDs;

{
	_taskLocations pushBack (_x select 0);
} forEach AOLocations;

taskBuildings = [];
milBuildings = [];
{
	_maxBuildings = 3;
	_searchRadius = 130;
	if (_forEachIndex == (count _taskLocations)-1) then {		
		_searchRadius = 300;
	};
	
	diag_log format ["findGarrisonBuildings location: %1", _x];
	_nearHouses = nearestObjects [_x, ["House"], _searchRadius];
		
	if (_forEachIndex == (count _taskLocations)-1) then {
		if (count _nearHouses < 30) then {
			_nearHouses = nearestObjects [_x, ["House"], (_searchRadius+175)];
		};
		_buildingsPresent = (count _nearHouses);		
		if (_buildingsPresent <= 40) then {
			_maxBuildings = ceil(_buildingsPresent * 0.11);
			_maxBuildings = _maxBuildings - ((count _taskLocations)-1);
		} else {
			if (_buildingsPresent <= 60) then {
				_maxBuildings = ceil(_buildingsPresent * 0.17);
				_maxBuildings = _maxBuildings - ((count _taskLocations)-1);
			} else {
				_maxBuildings = 13;
				_maxBuildings = _maxBuildings - ((count _taskLocations)-1);
			};		
		};		
	};
	
	_maxBuildings = round (_maxBuildings * aiMultiplier);	
	/*
	_markerFlat = createMarker [format ["mkrLand%1",(random 10000)], _x];
	_markerFlat setMarkerShape "ICON";
	_markerFlat setMarkerType "mil_dot";
	_markerFlat setMarkerColor "ColorOrange";	
	_markerFlat setMarkerSize [2,2];
	*/
	_buildings = [];	
		
	{
		_thisBuilding = _x;
		if ((count([_thisBuilding] call BIS_fnc_buildingPositions)) >= 2 || (typeOf _thisBuilding in _milCargoPosts)) then {						
			if (count taskBuildings > 0) then {
				{					
					if (!(_thisBuilding in _x)) then {
						if (typeOf _thisBuilding in _milCargoPosts) then {
							milBuildings pushBack _thisBuilding;
						} else {
							_buildings pushBack _thisBuilding;
						};
					};					
				} forEach taskBuildings;
			} else {
				if (typeOf _thisBuilding in _milCargoPosts) then {
					milBuildings pushBack _thisBuilding;
				} else {
					_buildings pushBack _thisBuilding;
				};
			};					
		};		
	} forEach _nearHouses;
	
	_selectedBuildings = [];
	_whileAttempts = 0;
	while {(count _selectedBuildings < _maxBuildings) && (_whileAttempts < (count _buildings))} do {
		_index = [0,((count _buildings) - 1)] call BIS_fnc_randomInt;
		_selectedBuildings pushBack (_buildings select _index);
		_arr = [_buildings, _index] call BIS_fnc_removeIndex;
		_buildings = _arr;
		_whileAttempts = _whileAttempts + 1;
	};			
	taskBuildings pushBack _selectedBuildings;		
} forEach _taskLocations;
/*
{
	_theseBuildings = _x;
	_taskBuildingsCount = _forEachIndex;
	
	{
		_markerFlat = createMarker [format ["mkrLand%1",(random 10000)], _x];
		_markerFlat setMarkerShape "ICON";
		_markerFlat setMarkerType "mil_dot";
		_markerFlat setMarkerColor "ColorOrange";		
		_markerFlat setMarkerText (format ["%1", _taskBuildingsCount]);
	} forEach _theseBuildings;	
} forEach taskBuildings;
*/