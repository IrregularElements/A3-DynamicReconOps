// *****
// Civilians
// *****

private _AOIndex = _this select 0;
private _debug = 0;
patrolGroups = [];

_createCivUnit = {
	params ["_pos", "_module", ["_customClasses", civClasses]];
	_civType = selectRandom _customClasses;	
	_group = createGroup civilian;
	_unit = createAgent [_civType, _pos, [], 0, "NONE"];
	//_unit = _group createUnit [_civType, _pos, [], 0, "NONE"];		
	_unit setVariable ["#core", _module];
	_unit setBehaviour "CARELESS";
	_unit execFSM "A3\Modules_F_Tacops\Ambient\CivilianPresence\FSM\behavior.fsm";
	_module setVariable ["#units", ((_module getVariable ["#units", []]) + [_unit])];
	[_unit] call dro_civDeathHandler;	
	// Currently civilians don't always exit dynamic simulation correctly
	//_group enableDynamicSimulation true;	
	_group
};

_createHostileCivUnit = {
	params ["_pos", ["_patrol", false], ["_customWaypoints", []], ["_allowGroup", false]];
	_civType = selectRandom _customClasses;
	_group = createGroup civilian;
	_unit = _group createUnit [_civType, _pos, [], 0, "NONE"];	
	[_unit, _customClasses] execVM "sunday_system\civilians\hostileCivilians.sqf";
	
	if (_patrol) then {patrolGroups pushBack _group} else {
		if (count _customWaypoints > 0) then {
			{
				_wp = _group addWaypoint [_x, 15];
				if ((count _customWaypoints) > 1) then {
					if (_forEachIndex == ((count _customWaypoints)-1)) then {
						_wp setWaypointType "CYCLE";
					} else {
						_wp setWaypointType "MOVE";
					};
				} else {
					_wp setWaypointType "MOVE";
				};
				_wp setWaypointBehaviour "SAFE";
				_wp setWaypointSpeed "LIMITED";
				_wp setWaypointCompletionRadius 1.5;
				_wp setWaypointTimeout [15, 30, 40];
			} forEach _customWaypoints;
		};
	};
	
	// Currently civilians don't always exit dynamic simulation correctly
	//_group enableDynamicSimulation true;	
	_group
};

_createSafeSpot = {
	params ["_pos", ["_useBuilding", true], ["_type", 1], ["_capacity", 3]];
	_modCivsSafeSpot = (createGroup centerSide) createUnit ["ModuleCivilianPresenceSafeSpot_F", _pos, [], 0, "FORM"];	
	{
		_modCivsSafeSpot setVariable [(_x select 0),(_x select 1),true];
	} forEach [
		["#useBuilding", true],		
		["#type", 1],		
		["#terminal", false],	
		["#capacity", 3],		
		["objectarea", [0.1,0.1,0,false,-1]]		
	];
};

private _AOPos = ((AOLocations select _AOIndex) select 0);
private _AOSize = ((AOLocations select _AOIndex) select 1);
centerSide = createCenter sideLogic;

(createGroup centerSide) createUnit ["ModuleCivilianPresenceUnit_F", _AOPos, [], 0, "FORM"];

private _customClasses = civClasses;
if (civFaction == "CIV_F") then {
	_locText = text ((AOLocations select _AOIndex) select 5);	
	switch (_locText) do {
		case "dump": {_customClasses = ["C_man_w_worker_F", "C_Man_UtilityWorker_01_F"]};
		case "quarry": {_customClasses = ["C_man_w_worker_F", "C_Man_UtilityWorker_01_F"]};
		case "factory": {_customClasses = ["C_man_w_worker_F", "C_Man_UtilityWorker_01_F"]};
		case "military": {_customClasses = ["C_man_w_worker_F", "C_Man_ConstructionWorker_01_Black_F", "C_Man_ConstructionWorker_01_Blue_F", "C_Man_ConstructionWorker_01_Red_F", "C_Man_ConstructionWorker_01_Vrana_F"]};
		case "training base": {_customClasses = ["C_man_w_worker_F", "C_Man_ConstructionWorker_01_Black_F", "C_Man_ConstructionWorker_01_Blue_F", "C_Man_ConstructionWorker_01_Red_F", "C_Man_ConstructionWorker_01_Vrana_F"]};
		case "power plant": {_customClasses = ["C_man_w_worker_F", "C_Man_UtilityWorker_01_F", "C_Man_ConstructionWorker_01_Black_F", "C_Man_ConstructionWorker_01_Blue_F", "C_Man_ConstructionWorker_01_Red_F", "C_Man_ConstructionWorker_01_Vrana_F"]};
		case "storage": {_customClasses = ["C_man_w_worker_F", "C_Man_UtilityWorker_01_F"]};
		case "farm": {_customClasses = ["C_man_w_worker_F", "C_Farmer_01_enoch_F", "C_man_hunter_1_F", "C_Man_Fisherman_01_F"]};
		case "ind.": {_customClasses = ["C_man_w_worker_F", "C_Man_ConstructionWorker_01_Black_F", "C_Man_ConstructionWorker_01_Blue_F", "C_Man_ConstructionWorker_01_Red_F", "C_Man_ConstructionWorker_01_Vrana_F"]};
		case "lumberyard": {_customClasses = ["C_man_w_worker_F", "C_man_hunter_1_F"]};		
		case "sawmill": {_customClasses = ["C_man_w_worker_F", "C_man_hunter_1_F"]};
		default {_customClasses = civClasses};
	};
};
diag_log format ["DRO: %2 Civilian custom classes = %1", _customClasses, text ((AOLocations select _AOIndex) select 5)];

// Extract civ identities and wearables
private _keyClass = (_customClasses select 0);
// Identities

private _identities = [_keyClass, civilian] call sun_extractIdentities;
_C_firstNames = (_identities select 0);
_C_lastNames = (_identities select 1);
_C_speakers = (_identities select 2);
_C_faces = (_identities select 3);
// Uniform
_C_uniformList = [];
{
	_C_uniformList pushBackUnique ([(configFile >> "CfgVehicles" >> _x >> "uniformClass")] call BIS_fnc_getCfgData);
} forEach _customClasses;
// Headgear
_C_headgearList = ([(configFile >> "CfgVehicles" >> _keyClass >> "headgearList")] call BIS_fnc_getCfgData);
_C_headgearList = if (isNil "_headgearList") then {[]} else {DRO_C_headgearList};
// Vest
_C_vestList = [];
private _thisLinked = ([(configFile >> "CfgVehicles" >> _keyClass >> "linkedItems")] call BIS_fnc_getCfgData); //{"H_Cap_press","V_Press_F","ItemMap","ItemCompass","ItemWatch"};
if (!isNil "_thisLinked") then {
	{			
		if (_x isKindOf ["Vest_Camo_Base", configFile >> "CfgWeapons"]) then {DRO_C_vestList pushBack _x};
		if (_x isKindOf ["Vest_NoCamo_Base", configFile >> "CfgWeapons"]) then {DRO_C_vestList pushBack _x};
	} forEach _thisLinked;
};


hostileCivsEnabled = if (civiliansEnabled == 2) then {true} else {
	if (civiliansEnabled == 1) then {
		if (random 1 > 0.5) then {
			true
		} else {false};
	};
};
DRO_C_HWearables = [];
if (hostileCivsEnabled) then {
	private _wearables = [
		//["H_Shemag_olive", "H_ShemagOpen_tan", "H_ShemagOpen_khk"],
		["H_Bandanna_gry", "H_Bandanna_blu", "H_Bandanna_cbr", "H_Bandanna_khk", "H_Bandanna_sgg", "H_Bandanna_sand", "H_Bandanna_camo", "H_Bandanna_mcamo"],
		["V_BandollierB_khk", "V_BandollierB_cbr", "V_BandollierB_rgr", "V_BandollierB_blk", "V_BandollierB_oli"],
		["V_Pocketed_black_F", "V_Pocketed_coyote_F", "V_Pocketed_olive_F"]
	];	
	DRO_C_HWearables = selectRandom _wearables;
	hostileCivIntel = "Some of the civilian militia may be wearing similar clothing. Check and ID your targets visually.";	
	publicVariable "hostileCivIntel";
};

private _filteredHouses = (((AOLocations select _AOIndex) select 2) select 7);
private _numHouses = count _filteredHouses;
private _percentToFill = 0.3;
if (_numHouses < 9) then {_percentToFill = 0.5};
_numHousesToFill = _numHouses * _percentToFill;
if (_numHousesToFill > 10) then {_numHousesToFill = 10};
for "_i" from 1 to _numHousesToFill do {
	private _thisHouse = [_filteredHouses] call sun_selectRemove;
	(createGroup centerSide) createUnit ["ModuleCivilianPresenceUnit_F", (getPos _thisHouse), [], 0, "FORM"];
	private _buildingPositions = [_thisHouse] call BIS_fnc_buildingPositions;	
	{ 
		_chance = 0.5;
		for "_bp" from 1 to ((count _buildingPositions) min 3) step 1 do {
			if (random 1 > _chance) then {			
				[_x, false, [], false] call _createHostileCivUnit;	
				_chance = _chance + 0.2;
			};
		};
	} forEach _buildingPositions;
	[(getPos _thisHouse), true, ((count _buildingPositions) - 1)] call _createSafeSpot;
	if (_debug == 1) then {
		_garMarker = createMarker [format["garMkr%1", random 10000], getPos _thisHouse];
		_garMarker setMarkerShape "ICON";
		_garMarker setMarkerColor "ColorGreen";
		_garMarker setMarkerType "mil_dot";
		_garMarker setMarkerText format ["Civ %1", (typeOf  _thisHouse)];
	};
};

_civPositions = (((AOLocations select _AOIndex) select 2) select 0) + (((AOLocations select _AOIndex) select 2) select 2) + (((AOLocations select _AOIndex) select 2) select 4);

_minAI = 3;
_maxAI = 6;

if (((AOLocations select _AOIndex) select 4) == 1) then {
	_minAI = round (_minAI * 1.5);
	_maxAI = round (_minAI * 1.5);
};

diag_log format ["DRO: Generating civilian positions at AO %1", (name ((AOLocations select _AOIndex) select 5))];
private _modUnitCount = 15;
switch (type ((AOLocations select _AOIndex) select 5)) do {
	case "NameVillage": {
		private _numCivs = [_minAI, _maxAI] call BIS_fnc_randomInt;
		diag_log format ["DRO: Civilian _minAI: %1", _minAI];
		diag_log format ["DRO: Civilian _maxAI: %1", _maxAI];
		_modUnitCount = 20;
		for "_x" from 1 to _numCivs do {			
			private _civPosition = selectRandom _civPositions;
			(createGroup centerSide) createUnit ["ModuleCivilianPresenceUnit_F", _civPosition, [], 0, "FORM"];
			[_civPosition, true, 2] call _createSafeSpot;
			if (hostileCivsEnabled) then {
				if (_x < (_numCivs * 0.4)) then {
					[_civPosition, true, [], true] call _createHostileCivUnit;					
				};
			};
		};		
	};
	case "NameCity": {
		private _numCivs = [_minAI + 2, _maxAI + 2] call BIS_fnc_randomInt;
		diag_log format ["DRO: Civilian _minAI: %1", _minAI];
		diag_log format ["DRO: Civilian _maxAI: %1", _maxAI];
		_modUnitCount = 25;
		for "_x" from 1 to _numCivs do {			
			private _civPosition = selectRandom _civPositions;
			(createGroup centerSide) createUnit ["ModuleCivilianPresenceUnit_F", _civPosition, [], 0, "FORM"];
			[_civPosition, true, 2] call _createSafeSpot;
			if (hostileCivsEnabled) then {
				if (_x < (_numCivs * 0.4)) then {
					[_civPosition, true, [], true] call _createHostileCivUnit;	
				};
			};
		};
	};
	case "NameCityCapital": {
		diag_log format ["DRO: Civilian _minAI: %1", _minAI];
		diag_log format ["DRO: Civilian _maxAI: %1", _maxAI];
		_modUnitCount = 30;
		private _numCivs = [_minAI + 3, _maxAI + 3] call BIS_fnc_randomInt;
		for "_x" from 1 to _numCivs do {			
			private _civPosition = selectRandom _civPositions;
			(createGroup centerSide) createUnit ["ModuleCivilianPresenceUnit_F", _civPosition, [], 0, "FORM"];
			[_civPosition, true, 2] call _createSafeSpot;
			if (hostileCivsEnabled) then {
				if (_x < (_numCivs * 0.4)) then {
					[_civPosition, true, [], true] call _createHostileCivUnit;
				};
			};
		};
	};
	case "NameLocal": {
		diag_log format ["DRO: Civilian _minAI: %1", _minAI];
		diag_log format ["DRO: Civilian _maxAI: %1", _maxAI];
		_modUnitCount = 15;
		private _numCivs = [_minAI, _maxAI] call BIS_fnc_randomInt;
		for "_x" from 1 to _numCivs do {			
			private _civPosition = selectRandom _civPositions;
			(createGroup centerSide) createUnit ["ModuleCivilianPresenceUnit_F", _civPosition, [], 0, "FORM"];
			[_civPosition, true, 2] call _createSafeSpot;
			if (hostileCivsEnabled) then {
				if (_x < (_numCivs * 0.4)) then {
					[_civPosition, true, [], true] call _createHostileCivUnit;
				};
			};
		};
	};
};

// Create market bustle
private _continue = if (isNil "marketPositionsUsed") then {true} else {if (marketPositionsUsed) then {false}};
if (_continue && !isNil "marketPositions") then {
	marketPositionsUsed = true;
	if (count marketPositions > 0) then {
		{			
			private _thisMarketPositions = _x;
			
			diag_log (format ["DRO: _thisMarketPositions = %1", _thisMarketPositions]);
			_count = 0;
			{	
				if (hostileCivsEnabled) then {
					if (_count < 3) then {
						[_x, true, _thisMarketPositions, true] call _createHostileCivUnit;
						_count = _count + 1;
					};
				};
				if (_forEachIndex % 2 == 0) then {
					(createGroup centerSide) createUnit ["ModuleCivilianPresenceUnit_F", _x, [], 0, "FORM"];
					[_x, true, 2] call _createSafeSpot;				
				};		
			} forEach _thisMarketPositions;
		} forEach marketPositions;
	};
};	

// Spawn civilian vehicles
if (count civCarClasses > 0) then {
	if (random 1 > 0.5 || (((AOLocations select _AOIndex) select 4) == 1)) then {
		_numCivVehicles = [1,3] call BIS_fnc_randomInt;
		for "_i" from 1 to _numCivVehicles do {							
			if (count (((AOLocations select _AOIndex) select 2) select 0) > 0) then {
				_pos = [(((AOLocations select _AOIndex) select 2) select 0)] call sun_selectRemove;
				_class = (selectRandom civCarClasses);
				_pos = _pos findEmptyPosition [0, 20, _class];
				if (count _pos > 0) then {				
					_veh = createVehicle [_class, _pos, [], 0, "NONE"];
					//_veh = _class createVehicle _pos;			
					_roadList = _pos nearRoads 10;
					if (count _roadList > 0) then {
						_thisRoad = _roadList select 0;
						_direction = [_thisRoad] call sun_getRoadDir;
						_veh setDir _direction;
						_newPos = [_pos, 4, (_direction + 90)] call BIS_fnc_relPos;
						if (!(_newPos isFlatEmpty [5, -1, -1, -1, 0, false] isEqualTo [])) then {
							_veh setPos _newPos;
						};
					};
					if (random 1 > 0.75) then {
						createVehicleCrew _veh;
						waitUntil {!isNull (driver _veh)};
						if (random 1 > 0.5) then {
							patrolGroups pushBack (group driver _veh);
						};
						{
							[_x] call dro_civDeathHandler;
						} forEach units (group driver _veh);
						
					};
				};
			};			
		};		
	};
};

private _modCivs = (createGroup centerSide) createUnit ["ModuleCivilianPresence_F", _AOPos, [], 0, "FORM"];
_modCivs setVariable ["#unitCount", 0, true];
_modCivs setVariable ["objectarea", [(_AOSize / 2), (_AOSize / 2), 0, false, -1], true];
_modCivs setVariable ["#onCreated", {[_this] call dro_civDeathHandler}, true];
_modCivs setVariable ["#useAgents", true, true];
_modCivs setVariable ["#usePanicMode", true, true];
_modCivs setVariable ["DRO_uniformList", _C_uniformList];
_modCivs setVariable ["DRO_firstNames", _C_firstNames];
_modCivs setVariable ["DRO_lastNames", _C_lastNames];
_modCivs setVariable ["DRO_speakers", _C_speakers];
_modCivs setVariable ["DRO_faces", _C_faces];
_modCivs setVariable ["DRO_headgearList", _C_headgearList];
_modCivs setVariable ["DRO_vestList", _C_vestList];
_modCivs setVariable ["#onCreated", {
	removeAllItems _this;	
	removeVest _this;
	removeHeadgear _this;
	removeUniform _this;
	_module = (_this getVariable "#core");
	[_this, (selectRandom (_module getVariable "DRO_firstNames")), (selectRandom (_module getVariable "DRO_lastNames")), (selectRandom (_module getVariable "DRO_speakers")), (selectRandom (_module getVariable "DRO_faces"))] remoteExec ["sun_setNameMP", 0, true];		
	_this addUniform (selectRandom (_module getVariable "DRO_uniformList"));
	if (random 1 > 0.6) then {_this addHeadgear (selectRandom (_module getVariable "DRO_headgearList"))};
	if (random 1 > 0.3) then {_this addVest (selectRandom (_module getVariable "DRO_vestList"))};
	[_this] call dro_civDeathHandler;
}, true];
["init", [_modCivs]] call bis_fnc_moduleCivilianPresence;

// Initialise waypoints
if (count patrolGroups > 0) then {
	private _travelPositions = (((AOLocations select _AOIndex) select 2) select 0) + (((AOLocations select _AOIndex) select 2) select 2) + (((AOLocations select _AOIndex) select 2) select 4);		
	if (count _travelPositions > 0) then {		
		{				
			_thisGroup = _x;
			_availableTravelPositions = [];
			_randI = ([0, (count _travelPositions)-1] call BIS_fnc_randomInt);			
			for "_i" from _randI to ((_randI + ([2,3] call BIS_fnc_randomInt)) min (count _travelPositions)) step 1 do {
				_availableTravelPositions pushBack (_travelPositions select _i);
			};
			
			_startPos = (getPos (leader _thisGroup));						
			// Initialise route waypoints
			_wpFirst = _thisGroup addWaypoint [_startPos, 20];
			_wpFirst setWaypointType "MOVE";
			_wpFirst setWaypointBehaviour "SAFE";
			_wpFirst setWaypointSpeed "LIMITED";			
			{
				_pos = if (typeName _x == "OBJECT") then {getPos _x} else {_x};
				_wp = _thisGroup addWaypoint [_pos, 20];
				_wp setWaypointType "MOVE";
				_wp setWaypointCompletionRadius 20;
				_wp setWaypointTimeout [60, 90, 120];					
			} forEach _availableTravelPositions;
			_wpLast = _thisGroup addWaypoint [_startPos, 20];
			_wpLast setWaypointType "CYCLE";		
			_wpLast setWaypointCompletionRadius 20;
			_wpLast setWaypointTimeout [60, 90, 120];			
		} forEach patrolGroups;
	};	
};
/*
{
	if (!((teamType _x) in civClasses)) then {
		deleteTeam _x;
	};
} forEach agents;


