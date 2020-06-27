scopeName "objSelection";

params ["_AOIndex", ["_ignorePrefs", false]];
_center = ((AOLocations select _AOIndex) select 0);
_size = ((AOLocations select _AOIndex) select 1);
//_roadPosClose = (((AOLocations select _AOIndex) select 2) select 0);
//_roadPosFar = (((AOLocations select _AOIndex) select 2) select 1);
//_groundPosClose = (((AOLocations select _AOIndex) select 2) select 2);
//_groundPosFar = (((AOLocations select _AOIndex) select 2) select 3);
//_flatPositionsClose = (((AOLocations select _AOIndex) select 2) select 4);
//_flatPositionsFar = (((AOLocations select _AOIndex) select 2) select 5);
//_forestPositions = (((AOLocations select _AOIndex) select 2) select 6);
//_buildingPositions = (((AOLocations select _AOIndex) select 2) select 7);		
//_helipads = (((AOLocations select _AOIndex) select 2) select 8);

diag_log "DRO: Attempting to create new task";

_thisTask = nil;
_objectivePos = [0,0,0];

_thisObj = nil;
_heliTransports = [];
_pVehicleWreckClasses = pCarClasses + pTankClasses + pHeliClasses;

_AOStyles = [];
_AODestroyStyles = [];
_AOHVTStyles = [];
_AOPOWStyles = [];
_AOReconStyles = [];
_AODisarmStyles = [];
_AOFortifyStyles = [];
_AOPreferredStyles = [];
_AOPreferredDestroyStyles = [];
_AOPreferredFortifyStyles = [];
_AOPreferredDisarmStyles = [];

{
	_AOStyles pushBack [];	
	_AODestroyStyles pushBack [];
	_AOHVTStyles pushBack [];
	_AOPOWStyles pushBack [];
	_AOReconStyles pushBack [];
	_AODisarmStyles pushBack [];
	_AOFortifyStyles pushBack [];
	_AOPreferredStyles pushBack [];
	_AOPreferredDestroyStyles pushBack [];	
	_AOPreferredFortifyStyles pushBack [];	
	_AOPreferredDisarmStyles pushBack [];	
} forEach AOLocations;

{
	/*
	diag_log (_x select 0);
	diag_log (_x select 1);
	diag_log (_x select 2);
	diag_log (_x select 3);
	diag_log (_x select 4);
	diag_log (_x select 5);
	*/
	if ((_x select 4) == 1) then {
		
		// *****
		// Neutral AO
		// *****
		
		//_roadPosClose
		if (count ((_x select 2) select 0) > 0) then {					
			//(_AOStyles select _forEachIndex) pushBackUnique "FOOTPATROL";	
			(_AOStyles select _forEachIndex) pushBackUnique "DISARM";
			(_AODisarmStyles select _forEachIndex) pushBackUnique "IED";
			(_AODisarmStyles select _forEachIndex) pushBackUnique "UXO";			
			(_AOStyles select _forEachIndex) pushBackUnique "FORTIFY";
			(_AOFortifyStyles select _forEachIndex) pushBackUnique "BLOCKADE";
			
		};
		//_groundPosClose
		if (count ((_x select 2) select 2) > 0) then {
			//(_AOStyles select _forEachIndex) pushBackUnique "AID";
			(_AOStyles select _forEachIndex) pushBackUnique "DISARM";
			(_AODisarmStyles select _forEachIndex) pushBackUnique "UXO";
		};
		//_flatPositionsClose
		if (count ((_x select 2) select 4) > 0) then {
			(_AOStyles select _forEachIndex) pushBackUnique "FORTIFY";
			(_AOFortifyStyles select _forEachIndex) pushBackUnique "OP";			
		};
		//_buildingPositions
		if (count ((_x select 2) select 7) > 0) then {
			(_AOStyles select _forEachIndex) pushBackUnique "PROTECTCIV";
			if (count ((_x select 2) select 7) > 2) then {
				//(_AOStyles select _forEachIndex) pushBackUnique "SEARCHHOUSES";		
			};
		};
		
	} else {

		// *****
		// Hostile AO
		// *****

		//_roadPosClose
		if (count ((_x select 2) select 0) > 0) then {
			if (count eCarClasses > 0) then {
				(_AOStyles select _forEachIndex) pushBackUnique "VEHICLE";			
				(_AOStyles select _forEachIndex) pushBackUnique "VEHICLESTEAL";			
			};		
			if (count _pVehicleWreckClasses > 0) then { 
				(_AODestroyStyles select _forEachIndex) pushBackUnique "WRECK";
			};
			(_AOHVTStyles select _forEachIndex) pushBackUnique "OUTSIDETRAVEL";
		};
		//_groundPosClose
		if (count ((_x select 2) select 2) > 0) then {
			(_AOHVTStyles select _forEachIndex) pushBackUnique "OUTSIDETRAVEL";
			(_AOStyles select _forEachIndex) pushBackUnique "CLEARLZ";
			if (count _pVehicleWreckClasses > 0) then { 
				(_AODestroyStyles select _forEachIndex) pushBackUnique "WRECK";
			};
		};
		//_groundPosFar
		if (count ((_x select 2) select 3) > 0) then {
			(_AOHVTStyles select _forEachIndex) pushBackUnique "OUTSIDETRAVEL";
		};
		//_flatPositionsClose
		if (count ((_x select 2) select 4) > 0) then {
			if (count eArtyClasses > 0) then {
				(_AOStyles select _forEachIndex) pushBackUnique "ARTY";
			};
			if (count eAAClasses > 0) then {
				(_AOStyles select _forEachIndex) pushBackUnique "ARTY";
			};
			if (count eMortarClasses > 0) then {				
				(_AODestroyStyles select _forEachIndex) pushBackUnique "MORTAR";
			};
			if (count eHeliClasses > 0) then {	
				(_AOStyles select _forEachIndex) pushBackUnique "HELI";
			};
			if (count _pVehicleWreckClasses > 0) then { 
				(_AODestroyStyles select _forEachIndex) pushBackUnique "WRECK";
			};
			(_AOStyles select _forEachIndex) pushBackUnique "CLEARLZ";
			(_AOHVTStyles select _forEachIndex) pushBackUnique "OUTSIDETRAVEL";		
			(_AOHVTStyles select _forEachIndex) pushBackUnique "OUTSIDE";
			//(_AODestroyStyles select _forEachIndex) pushBackUnique "POWER";	
		};
		//_forestPositions
		if (count ((_x select 2) select 6) > 0) then {
			(_AOPOWStyles select _forEachIndex) pushBackUnique "OUTSIDE";
			(_AOStyles select _forEachIndex) pushBackUnique "CLEARLZ";
			(_AODestroyStyles select _forEachIndex) pushBackUnique "CACHE";
		};
		//_buildingPositions
		if (count ((_x select 2) select 7) > 0) then {
			(_AOStyles select _forEachIndex) pushBackUnique "CACHEBUILDING";
			(_AOStyles select _forEachIndex) pushBackUnique "INTEL";
			(_AOHVTStyles select _forEachIndex) pushBackUnique "INSIDE";
			(_AOPOWStyles select _forEachIndex) pushBackUnique "INSIDE";
		};
		//_helipads
		if (count ((_x select 2) select 8) > 0) then {	
			if (count eHeliClasses > 0) then {	
				(_AOStyles select _forEachIndex) pushBackUnique "HELI";
			};	
		};
		if (count (_AOHVTStyles select _forEachIndex) > 0) then {
			(_AOStyles select _forEachIndex) pushBackUnique "HVT";
		};
		if (count (_AODestroyStyles select _forEachIndex) > 0) then {
			(_AOStyles select _forEachIndex) pushBackUnique "DESTROY";
		};
		if (count (_AOPOWStyles select _forEachIndex) > 0) then {
			(_AOStyles select _forEachIndex) pushBackUnique "POW";
		};
	};
	
	//(_AOStyles select _forEachIndex) pushBack "RECON";	
	(_AOReconStyles select _forEachIndex) pushBack "RECONFOOT";
	
} forEach AOLocations;

diag_log format ["DRO: _ignorePrefs = %1", _ignorePrefs];
diag_log format ["DRO: preferredObjectives = %1", preferredObjectives];
// Find preferred styles
if (!_ignorePrefs) then {
	if (count preferredObjectives > 0) then {
		{
			_thisPref = _x;
			{
				if (_thisPref in _x) then {
					(_AOPreferredStyles select _forEachIndex) pushBackUnique _thisPref;
				} 				
			} forEach _AOStyles;
			{				
				if (_thisPref in _x) then {
					(_AOPreferredStyles select _forEachIndex) pushBackUnique "DESTROY";
					(_AOPreferredDestroyStyles select _forEachIndex) pushBackUnique _thisPref;
				};
			} forEach _AODestroyStyles;
			{				
				if (_thisPref in _x) then {
					(_AOPreferredStyles select _forEachIndex) pushBackUnique "FORTIFY";
					(_AOPreferredFortifyStyles select _forEachIndex) pushBackUnique _thisPref;
				};
			} forEach _AOFortifyStyles;
			{				
				if (_thisPref in _x) then {
					(_AOPreferredStyles select _forEachIndex) pushBackUnique "DISARM";
					(_AOPreferredDisarmStyles select _forEachIndex) pushBackUnique _thisPref;
				};
			} forEach _AODisarmStyles;				
		} forEach preferredObjectives;
	};
};
diag_log format ["DRO: _AOStyles = %1", _AOStyles];
diag_log format ["DRO: _AOPreferredStyles = %1", _AOPreferredStyles];

_select = [];
// Check for preferred styles within the requested AO
if (count (_AOPreferredStyles select _AOIndex) > 0) then {
	_select = [_AOIndex, selectRandom (_AOPreferredStyles select _AOIndex)];
} else {
	// Expand the search for preferred styles within all other AOs
	for "_i" from 0 to (count _AOPreferredStyles - 1) step 1 do {
		if (count (_AOPreferredStyles select _i) > 0) exitWith {
			_select = [_i, selectRandom (_AOPreferredStyles select _i)];
		};
	};
	// If no preference is found start looking for any styles in the requested AO
	if (count _select == 0) then {
		if (count (_AOStyles select _AOIndex) > 0) then {
			_select = [_AOIndex, selectRandom (_AOStyles select _AOIndex)];
		} else {		
			// Expand the search for any styles within all other AOs
			for "_i" from 0 to (count _AOStyles - 1) step 1 do {
				if (count (_AOStyles select _i) > 0) exitWith {
					_select = [_i, selectRandom (_AOStyles select _i)];
				};
			};			
		};	
	};
};

// Failsafe
if (count _select == 0) then {
	_select = [0, "RECON"];
};

diag_log format ["DRO: New task will be %1", _select];
_scriptHandle = nil;

switch (_select select 1) do {
	case "HVT": {
		_hvtInterrogate = "HVTREGULAR";
		if (missionPreset == 2) then {"HVTREGULAR"} else {
			if (random 1 > 999) then {_hvtInterrogate = "HVTINTERROGATE"} else {_hvtInterrogate = "HVTREGULAR"};
			_AOHVTStyles = _AOHVTStyles - ["OUTSIDETRAVEL"];
		};		
		switch (_hvtInterrogate) do {		
			case "HVTREGULAR": {_scriptHandle = [(_select select 0), (_AOHVTStyles select (_select select 0))] execVM "sunday_system\objectives\hvt.sqf";};
			case "HVTINTERROGATE": {_scriptHandle = [(_select select 0), (_AOHVTStyles select (_select select 0))] execVM "sunday_system\objectives\hvtInterrogate.sqf";};
		};				
	};
	case "DESTROY": {
		_destroySelect = if (count (_AOPreferredDestroyStyles select (_select select 0)) > 0) then {
			selectRandom (_AOPreferredDestroyStyles select (_select select 0))
		} else {
			selectRandom (_AODestroyStyles select (_select select 0))
		};
		switch (_destroySelect) do {
			case "MORTAR": {
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\destroyMortar.sqf";	
			};
			case "WRECK": {				
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\destroyWreck.sqf";					
			};
			case "CACHE": {
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\cache.sqf";					
			};
			case "POWER": {
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\destroyPower.sqf";				
			};
		};
	};	
	case "POW": {
		_scriptHandle = [(_select select 0), (_AOPOWStyles select (_select select 0))] execVM "sunday_system\objectives\pow.sqf";			
	};
	case "VEHICLE": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\vehicle.sqf";			
	};
	case "VEHICLESTEAL": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\vehicleSteal.sqf";			
	};
	case "ARTY": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\artillery.sqf";		
	};
	case "CACHEBUILDING": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\cacheBuilding.sqf";				
	};
	case "HELI": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\heli.sqf";	
	};
	case "CLEARLZ": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\clearArea.sqf";		
	};
	case "CLEARBASE": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\clearBase.sqf";				
	};
	case "INTEL": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\intel.sqf";		
	};
	case "RECON": {
		_reconSelect = selectRandom (_AOReconStyles select (_select select 0));
		switch (_reconSelect) do {
			case "RECONRANGE": {
				[(_select select 0)] execVM "sunday_system\objectives\reconRange.sqf";
				_scriptHandle = 0 spawn {};
			};
			case "RECONFOOT": {
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives\reconFoot.sqf";		
			};
		};
	};
	case "FOOTPATROL": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives_neutral\footPatrol.sqf";	
	};	
	case "DISARM": {
		_disarmSelect = selectRandom (_AODisarmStyles select (_select select 0));		
		switch (_disarmSelect) do {
			case "IED": {
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives_neutral\disarmIED.sqf";	
			};
			case "UXO": {				
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives_neutral\disarmUXO.sqf";					
			};			
		};		
	};
	case "FORTIFY": {
		_fortifySelect = selectRandom (_AOFortifyStyles select (_select select 0));		
		switch (_fortifySelect) do {
			case "OP": {
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives_neutral\fortify.sqf";	
			};
			case "BLOCKADE": {				
				_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives_neutral\blockade.sqf";					
			};			
		};		
	};	
	case "PROTECTCIV": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives_neutral\protectCiv.sqf";	
	};
	case "SEARCHHOUSES": {
		_scriptHandle = [(_select select 0)] execVM "sunday_system\objectives_neutral\searchHouses.sqf";	
	};
};
sleep 1;

//waitUntil {scriptDone _scriptHandle};