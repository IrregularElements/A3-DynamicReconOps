diag_log "DRO: Starting AO generation";

// *****
// SETUP AO
// *****

fnc_generateMarket = compile preprocessFile "sunday_system\generate_ao\generateMarket.sqf";

_debug = 0;

_blackList = [];
aoSize = 1200;

_randomLoc = [];

if (getMarkerColor "aoSelectMkr" == "") then {
	diag_log "DRO: No custom AO position found, will generate random.";
	{
		deleteMarker _x;
	} forEach locMarkerArray;
	// Get a random location
	_size = worldSize;
	_worldCenter = (_size/2);
	_firstLocList = nearestLocations [[_worldCenter, _worldCenter], ["NameLocal","NameVillage","NameCity","NameCityCapital"], _size];
	_randomLoc = [_firstLocList] call sun_selectRemove;
		
	while {		
		(((getPos _randomLoc) select 0) < aoSize) ||
		(((getPos _randomLoc) select 1) < aoSize) ||
		(((getPos _randomLoc) select 0) > (_size-aoSize)) ||
		(((getPos _randomLoc) select 1) > (_size-aoSize)) ||
		(((getPos _randomLoc) distance logicStartPos) < 700)
		
	} do {
		_randomLoc = [_firstLocList] call sun_selectRemove;
	};
	aoName = text _randomLoc;
	publicVariable "aoName";
} else {
	diag_log "DRO: Custom AO position found.";
	_randomLoc = nearestLocation [getMarkerPos "aoSelectMkr", ""];
	"aoSelectMkr" setMarkerAlpha 0;
	{
		deleteMarker _x;
	} forEach locMarkerArray;
};

// Add the primary location to the pool
AOLocations = [];
AOLocations pushBack [(getPos _randomLoc), aoSize];
_cityCenter = (getPos _randomLoc);

// If secondary locations are enabled then find them
if (aoOptionSelect == 0) then {
	_secondaryLocList = nearestLocations [[_cityCenter select 0, _cityCenter select 1], ["NameLocal","NameVillage","NameCity","NameCityCapital"], 2000];	
	_secondaryLocList = _secondaryLocList select {((getPos _x) distance _cityCenter > (aoSize * 0.4))};
	// Add 1 to 3 secondary locations to the pool
	if (count _secondaryLocList > 0) then {
		for "_i" from 1 to (([1, count _secondaryLocList] call BIS_fnc_randomInt) min 3) step 1 do {
			_thisLoc = [_secondaryLocList] call sun_selectRemove;
			if (((getPos _thisLoc) distance logicStartPos) < 700) then {
				_secondaryLocList pushBack _thisLoc;
			} else {				
				AOLocations pushBack [(getPos _thisLoc), 800];
			};
		};
	};
};

// Primary location/mission data
AOLocType = type _randomLoc;
missionNameSpace setVariable ["aoLocation", _randomLoc, true];
missionNameSpace setVariable ["aoLocationName", aoName, true];

_AREAMARKER_WIDTH = 200;
AOBriefingLocType = switch (AOLocType) do  {
	case "NameLocal": {""};
	case "NameVillage": {"village"};
	case "NameCity": {"city"};
	case "NameCityCapital": {"capital"};
	case default {"countryside"};
};

missionNameSpace setVariable ["aoCamPos", _cityCenter];
publicVariable "aoCamPos";

// Create center marker
_markerCenter = createMarker ["centerMkr", _cityCenter];
_markerCenter setMarkerShape "ICON";
_markerCenter setMarkerType "EmptyIcon";

// Generate position data for all locations
AO_POITypes = [];
_aoDataAll = [];
{
	_aoData = [(_x select 0), "ALL", (_x select 1)] call fnc_generateAOLoc;	
	_aoDataAll pushBack _aoData;
} forEach AOLocations;
{
	(AOLocations select _forEachIndex) pushBack _x;
} forEach _aoDataAll;

// Select special type for primary location

travelPosPOICiv = [];
travelPosPOIMil = [];

if (count AO_POITypes > 0) then {
	AO_POIs = [];
	for "_p" from 1 to (([2,4] call BIS_fnc_randomInt) min (count AO_POITypes)) step 1 do {
		AO_POIs pushBack ([AO_POITypes] call sun_selectRemove);
	};	
	{
		switch (_x) do {
			case "MARKET": {
				// Find AO locations with valid market indexes
				marketPositions = [];
				_totalGroundPositions = 0;
				{
					if (count ((_x select 2) select 0) > 0) then {_totalGroundPositions = _totalGroundPositions + (count ((_x select 2) select 0))};
				} forEach AOLocations;
				if (_totalGroundPositions > 0) then {					
					_numMarkets = (([1, (count AOLocations)] call BIS_fnc_randomInt) min _totalGroundPositions);							
					{
						if (_numMarkets > 0) then {
							if (count ((_x select 2) select 0) > 0) then {
								_marketPos = [((_x select 2) select 0)] call sun_selectRemove;
								_thisMarketPositions = ([_marketPos] call fnc_generateMarket);
								if (count _thisMarketPositions > 0) then {				
									_markerName = format["marketMkr%1", floor(random 10000)];
									_markerMarket = createMarker [_markerName,  selectRandom _thisMarketPositions];			
									_markerMarket setMarkerShape "ICON";
									_markerMarket setMarkerType "mil_flag_noShadow";
									_markerMarket setMarkerText "Market";			
									_markerMarket setMarkerColor "ColorBlack";
									_markerMarket setMarkerAlpha 1;				
									_markerMarket setMarkerSize [0.65, 0.65];				
									{
										travelPosPOIMil pushBack _x;
										travelPosPOICiv pushBack _x;
									} forEach _thisMarketPositions;
									marketPositions pushBack _thisMarketPositions;
								};
								_numMarkets = _numMarkets - 1;
							};
						};
					} forEach AOLocations;
				};				
			};			
			case "HOUSE": {
				// Find AO locations with valid house indexes				
				_validAOIndexes = [];							
				{								
					if ((count ((_x select 2) select 7)) > 0) then {	
						_validAOIndexes pushBack _forEachIndex;
					};					
				} forEach AOLocations;
				_numHouses = [3, 6] call BIS_fnc_randomInt;
				for "_i" from 1 to _numHouses step 1 do {
					if ((count _validAOIndexes) > 0) then {
						_thisIndex = ([0, ((count _validAOIndexes) - 1)] call BIS_fnc_randomInt);
						_thisIndex = _validAOIndexes select _thisIndex;
						if ((count (((AOLocations select _thisIndex) select 2) select 7)) > 0) then {
							travelPosPOICiv pushBack ([(((AOLocations select _thisIndex) select 2) select 7)] call sun_selectRemove);
						} else {
							_validAOIndexes deleteAt _thisIndex;
							_i = _i + 1;
						};
					};
				};
			};
		};
	} forEach AO_POIs;
};

_aoPoints = [];
{
	_pos = (_x select 0);
	_dist = (_x select 1);
	_dir = 45;
	for "_i" from 0 to 3 step 1 do {
		_aoPoints pushBack ([_pos, _dist, _dir] call BIS_fnc_relPos);
		_dir = _dir + 90;
	};
} forEach AOLocations;

_leftmostPoints = [_aoPoints, [], {_x select 0}, "ASCEND"] call BIS_fnc_sortBy;
_leftmostPoint = _leftmostPoints select 0;
_rightmostPoint = _leftmostPoints select ((count _leftmostPoints)-1);
_topmostPoints = [_aoPoints, [], {_x select 1}, "DESCEND"] call BIS_fnc_sortBy;
_topmostPoint = _topmostPoints select 0;
_bottommostPoint = _topmostPoints select ((count _topmostPoints)-1);
_xDist =  (_rightmostPoint select 0) - (_leftmostPoint select 0);
_yDist = (_topmostPoint select 1) - (_bottommostPoint select 1);
_centerTrue = [(_rightmostPoint select 0)- (_xDist/2), (_topmostPoint select 1) - (_yDist/2)];

_markerAOC = createMarker ["mkrAOC", _centerTrue];
_markerAOC setMarkerShape "RECTANGLE";
_markerAOC setMarkerSize [_xDist/1.5, _yDist/1.5];
_markerAOC setMarkerBrush "Border";		
_markerAOC setMarkerColor "ColorRed";
_markerAOC setMarkerAlpha 0;

// Visual markers
_markerFlag = createMarker ["mkrFlag", [(_centerTrue select 0),((_centerTrue select 1)+150)]];
_markerFlag setMarkerShape "ICON";
_markerFlag setMarkerType "flag_AAF";
_markerFlag setMarkerSize [2,2];

trgAOC = createTrigger ["EmptyDetector", _centerTrue];
trgAOC setTriggerArea [_xDist/1.5, _yDist/1.5, 0, true];
if (isMultiplayer) then {	
	trgAOC setTriggerActivation ["ANY", "PRESENT", false];
	trgAOC setTriggerStatements ["(vehicle player in thisList)", "if (count hostileCivilians > 0) then {['HOSTILECIVS'] spawn dro_sendProgressMessage}", ""];	
} else {
	trgAOC setTriggerActivation ["ANY", "PRESENT", false];
	trgAOC setTriggerStatements ["(vehicle player in thisList)", "saveGame; if (count hostileCivilians > 0) then {['HOSTILECIVS'] spawn dro_sendProgressMessage}", ""];	
};

AOTrigs = [];
AOMarkers = [];
_neutralChance = if (neutralTasksChosen) then {
	1
} else {
	if (noNeutralTasksChosen) then {
		0
	} else {
		(count AOLocations) * 0.08
	};
};
	
//_neutralChance = 0;
//_neutralChance = 1;
{
	// Check for water between each location
	_thisAOPos = _x select 0;
	_otherAOLocations = AOLocations - [_x];
	_returns = [];
	{		
		_return = [_thisAOPos, _x select 0, true] call sun_checkRouteWater;
		diag_log format ["DRO: Water on route? Checked %2 against %1: %3", _thisAOPos,  _x select 0, _return];
		_returns pushBack _return;
	} forEach _otherAOLocations;
	if (false in _returns || (count _returns == 0)) then {
		(AOLocations select _forEachIndex) pushBack "ROUTE";
	} else {		
		(AOLocations select _forEachIndex) pushBack (_returns select _forEachIndex);
	};	
	if (count (AOLocations select _forEachIndex) != 4) then {
		(AOLocations select _forEachIndex) pushBack (_returns select 0);
	};
		
	_trgAO = createTrigger ["EmptyDetector", _thisAOPos];
	_trgAO setTriggerArea [((_x select 1)/4), ((_x select 1)/4), 0, false];
	AOTrigs pushBack _trgAO;
	
	// Randomly assign as neutral
	_thisNeutralChance = random 1;
	diag_log format ["DRO: AO %1 comparing neutral chance %2 against base of %3.", _forEachIndex, _thisNeutralChance, _neutralChance];
	if (_thisNeutralChance < _neutralChance) then {
		(AOLocations select _forEachIndex) pushBack 1;		
		_neutralChance = 0;
		diag_log format ["DRO: AO %1 has become neutral, _neutralChance is now %2", _forEachIndex, _neutralChance];
		// Create marker			
		_mkrName = format ["mkrSecondaryLoc%1", _forEachIndex];
		_markerWarning = createMarker [_mkrName, (_x select 0)];
		_markerWarning setMarkerShape "ICON";
		_markerWarning setMarkerType "c_unknown";
		_markerWarning setMarkerColor "ColorCivilian";
		_markerWarning setMarkerSize [2, 2];
		_markerWarning setMarkerAlpha 0.6;
		//AOMarkers pushBack _mkrName;
	} else {
		(AOLocations select _forEachIndex) pushBack 0;		
		// Create marker		
		//if (_forEachIndex > 0) then {
			_mkrName = format ["mkrSecondaryLoc%1", _forEachIndex];
			_markerWarning = createMarker [_mkrName, (_x select 0)];
			_markerWarning setMarkerShape "ICON";
			_markerWarning setMarkerType "mil_warning_noShadow";
			_markerWarning setMarkerColor "ColorRed";
			_markerWarning setMarkerSize [1.5, 1.5];
			_markerWarning setMarkerAlpha 0.6;			
			AOMarkers pushBack _mkrName;	
		//};		
	};
	(AOLocations select _forEachIndex) pushBack (nearestLocation [(_x select 0), ""]);
	(AOLocations select _forEachIndex) pushBack _trgAO;
} forEach AOLocations;

_destroyChance = random 1;
if (_destroyChance > 0.85) then {
	_destroyAOTrg = (selectRandom AOTrigs);
	[getPos _destroyAOTrg, ((triggerArea _destroyAOTrg) select 0)] call BIS_fnc_destroyCity;
	/*
	for "_i" from 0 to 5 do {
		_randomPos = [[_destroyAOTrg], ["water"]] call BIS_fnc_randomPos;
		_source = "#particlesource" createVehicle _randomPos;
		_source setParticleClass "HouseDestrSmokeLong";
	};
	*/
	for "_i" from 0 to 5 do {
		_randomPos = [[_destroyAOTrg], ["water"]] call BIS_fnc_randomPos;
		_source = "#particlesource" createVehicle _randomPos;
		_source setParticleClass "BigDestructionSmoke";	
		_obj = [(selectRandom ["Crater", "CraterLong", "CraterLong_small"]), _randomPos, (random 360)] call dro_createSimpleObject;
		_obj setDir (random 360);
		if (random 1 > 0.4) then {
			_obj = [(selectRandom ["Land_Wreck_HMMWV_F", "Land_Wreck_Skodovka_F", "Land_Wreck_Truck_F", "Land_Wreck_Car_F", "Land_Wreck_Car2_F", "Land_Wreck_Hunter_F", "Land_Wreck_Offroad_F", "Land_Wreck_UAZ_F", "Land_Wreck_Ural_F", "Land_Wreck_BMP2_F", "Land_Wreck_BRDM2_F", "Land_Wreck_Heli_Attack_02_F", "Land_Wreck_T72_hull_F", "Land_Wreck_Slammer_F"]), _randomPos, (random 360)] call dro_createSimpleObject;
			//_obj = createSimpleObject [(selectRandom ["Land_Wreck_HMMWV_F", "Land_Wreck_Skodovka_F", "Land_Wreck_Truck_F", "Land_Wreck_Car_F", "Land_Wreck_Car2_F", "Land_Wreck_Hunter_F", "Land_Wreck_Offroad_F", "Land_Wreck_UAZ_F", "Land_Wreck_Ural_F", "Land_Wreck_BMP2_F", "Land_Wreck_BRDM2_F", "Land_Wreck_Heli_Attack_02_F", "Land_Wreck_T72_hull_F", "Land_Wreck_Slammer_F"]), (AGLToASL _randomPos)];
			//_obj setDir (random 360);
			(nearestBuilding _randomPos) setDamage 1;
		};
		//_crater = (selectRandom ["Crater", "CraterLong", "CraterLong_small"]) createVehicle _randomPos;
	};

	for "_i" from 0 to 9 do {
		_randomPos = [[_destroyAOTrg], ["water"]] call BIS_fnc_randomPos;	
		_obj = [(selectRandom ["Crater", "CraterLong", "CraterLong_small"]), _randomPos, (random 360)] call dro_createSimpleObject;
		//_obj = createSimpleObject [(selectRandom ["Crater", "CraterLong", "CraterLong_small"]), (AGLToASL _randomPos)];
		//_obj setDir (random 360);
	};	
}; 

//[(AOVisTrigs select 0)] call BIS_fnc_drawAO;
{
	diag_log format ["DRO: AOLocation %1 position: %2", _forEachIndex, _x select 0];
	diag_log format ["DRO: AOLocation %1 size: %2", _forEachIndex, _x select 1];
	diag_log format ["DRO: AOLocation %1 data: %2", _forEachIndex, _x select 2];
	
	{
		_str = switch (_forEachIndex) do {
			case 0: {"Roads close"};
			case 1: {"Roads far"};
			case 2: {"Ground pos close"};
			case 3: {"Ground pos far"};
			case 4: {"Flat pos close"};
			case 5: {"Flat pos far"};
			case 6: {"Forest"};
			case 7: {"Buildings"};
			case 8: {"Helipads"};
		};
		diag_log format ["DRO: 		%1 count: %2", _str, (count _x)];		
	} forEach (_x select 2);	
	diag_log format ["DRO: AOLocation %1 route: %2", _forEachIndex, _x select 3];
	diag_log format ["DRO: AOLocation %1 neutral: %2", _forEachIndex, _x select 4];
	diag_log format ["DRO: AOLocation %1 location: %2", _forEachIndex, _x select 5];
	diag_log format ["DRO: AOLocation %1 trigger: %2", _forEachIndex, _x select 6];
} forEach AOLocations;

centerPos = _cityCenter;
publicVariable "centerPos";
diag_log "DRO: Completed AO generation";
