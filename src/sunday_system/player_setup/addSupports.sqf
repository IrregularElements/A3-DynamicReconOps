params ["_basePos"];
diag_log "DRO: Initiating supports";


_supplyChance = 0.7;

// Check whether supports are random or custom
_dropChance = random 1;
_artyChance = random 1;
_casChance = random 1;
_uavChance = random 1;
if (randomSupports == 1) then {
	if ("SUPPLY" in customSupports) then {_dropChance = 1;} else {_dropChance = 0;};
	if ("ARTY" in customSupports) then {_artyChance = 1;} else {_artyChance = 0;};
	if ("CAS" in customSupports) then {_casChance = 1;} else {_casChance = 0;};
	if ("UAV" in customSupports) then {_uavChance = 1;} else {_uavChance = 0;};	
};




// Supply drop
if (_dropChance > _supplyChance) then {
	diag_log "DRO: Support selected: Supply drop";
	_availableDropClasses = [];
	{
		_availableSupportTypes = (configfile >> "CfgVehicles" >> _x >> "availableForSupportTypes") call BIS_fnc_GetCfgData;	
		if ("Drop" in _availableSupportTypes) then {
			_availableDropClasses pushBack _x;				
		};	
	} forEach pHeliClasses;
	
	if (count _availableDropClasses > 0) then {
		// Add support comms
		{
			[_x, "DRO_Support_Request_Drop"] remoteExec ["BIS_fnc_addCommMenuItem", _x, true];	
		} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
	} else {
		[] spawn {
			sleep 10;
			dro_messageStack pushBack [
				[
					["Command", "We don't have any supply drop resources available.", 0]		
				],
				true
			];	
		};
	};
};

// Artillery
if (_artyChance > _supplyChance) then {
	diag_log "DRO: Support selected: Artillery";
	_artyList = pMortarClasses + pArtyClasses;
	if (count _artyList > 0) then {
		_availableArty = [];
		{
			_artyClass = (selectRandom _artyList);						
			_artyRanges = [_artyClass] call dro_getArtilleryRanges;
			_minRange = (_artyRanges select 0);
			_maxRange = (_artyRanges select 1);			
			_trgArea = triggerArea trgAOC;
			_largestSize = if ((_trgArea select 0) > (_trgArea select 1)) then {
				(_trgArea select 0)
			} else {
				(_trgArea select 1)
			};			
			_minPlacementDistance = (_largestSize + 500);			
			if (_minRange > 0) then {
				_minPlacementDistance = (_largestSize + _minRange);			
			};				
			_artyPos = [getPos trgAOC, _minPlacementDistance, _minPlacementDistance + 500, 5, 0, 0.25, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if (!(_artyPos isEqualTo [0,0,0])) then {
				_availableArty pushBack [_artyClass, _artyPos];
			};
		} forEach _artyList;
		
		if (count _availableArty > 0) then {			
			_artySelection = selectRandom _availableArty;
			_artyClass = _artySelection select 0;
			_artyPos = _artySelection select 1;
			_markerSupports = createMarker ["mkrSupports", _artyPos];
			_markerSupports setMarkerShape "ICON";
			_markerSupports setMarkerColor markerColorPlayers;
			_markerSupports setMarkerType "mil_marker";
			_markerSupports setMarkerText "Artillery Position";
			_markerSupports setMarkerSize [0.6, 0.6];				
			_artyVeh = createVehicle [_artyClass, _artyPos, [], 0, "NONE"];
			_artyVeh setDir ([_artyPos, trgAOC] call BIS_fnc_dirTo);			
			diag_log format ["DRO: _artyVeh = %1", _artyVeh];			
			[_artyVeh, playersSide, false] call sun_createVehicleCrew;
			_artyVeh disableAI "PATH";
			
			dro_messageStack pushBack [
				[
					[str group ((crew _artyVeh) select 0), "Artillery ready to receive strike coordinates.", 0]		
				],
				true
			];	
			// Add support comms
			{
				[_x, "DRO_Support_Request_Artillery"] remoteExec ["BIS_fnc_addCommMenuItem", _x, true];
				_x setVariable ["DRO_SUPP_artyVeh", _artyVeh];
			} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
						
		} else {
			diag_log "DRO: Valid artillery support position not found";			 
			[] spawn {
				sleep 10;
				dro_messageStack pushBack [
					[
						["Command", "We don't have any artillery positions available.", 0]		
					],
					true
				];	
			};
		};
	} else {
		[] spawn {
			sleep 10;
			dro_messageStack pushBack [
				[
					["Command", "We don't have any artillery positions available.", 0]		
				],
				true
			];	
		};
	};
};


// CAS
if (_casChance > _supplyChance) then {
	diag_log "DRO: Support selected: CAS";
	if (count availableCASClasses > 0) then {		
		_availableCASClassesHeli = [];
		_availableCASClassesBomb = [];
		{
			_availableSupportTypes = (configfile >> "CfgVehicles" >> _x >> "availableForSupportTypes") call BIS_fnc_GetCfgData;	
			if ("CAS_Bombing" in _availableSupportTypes) then {
				_availableCASClassesBomb pushBack _x;				
			};
			if ("CAS_Heli" in _availableSupportTypes) then {
				_availableCASClassesHeli pushBack _x;				
			};
		} forEach availableCASClasses;		
		
		_chosenCASClasses = [];
		// Choose a random CAS type based on vehicles available
		_casType = "";		
		if ((count _availableCASClassesHeli > 0) && (count _availableCASClassesBomb > 0)) then {			
			_casTypeChance = [0,1] call BIS_fnc_randomInt;
			if (_casTypeChance == 0) then {				
				_chosenCASClasses = _availableCASClassesHeli;
				_casType = "CAS_Heli";
			} else {				
				_chosenCASClasses = _availableCASClassesBomb;
				_casType = "CAS_Bombing";
			};
		} else {
			if (count _availableCASClassesHeli > 0) then {				
				_chosenCASClasses = _availableCASClassesHeli;
				_casType = "CAS_Heli";
			} else {				
				_chosenCASClasses = _availableCASClassesBomb;
				_casType = "CAS_Bombing";
			};
		};
		_CASClass = selectRandom _chosenCASClasses;
			
		// Add support comms
		{			
			[_x, format ["DRO_Support_Request_%1", _casType]] remoteExec ["BIS_fnc_addCommMenuItem", _x, true];
			_x setVariable ["DRO_SUPP_CASType", _casType];
			_x setVariable ["DRO_SUPP_CASClass", _CASClass];
			DRO_SUPP_CASUsed = false;
			publicVariable "DRO_SUPP_CASUsed";
		} forEach (units (grpNetId call BIS_fnc_groupFromNetId));	
			
	};
};

if (_uavChance >_supplyChance) then {
	[] execVM "sunday_system\player_setup\uavPatrol.sqf";
};	
