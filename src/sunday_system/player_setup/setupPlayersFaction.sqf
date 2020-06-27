// *****
// SETUP PLAYER START
// *****

newUnitsReady = false;
private _center = getPos trgAOC;
_playerGroup = (units(grpNetId call BIS_fnc_groupFromNetId));
_playersPos = [];
_groundStyleSelect = "";

// Has the player edited in Zeus?
_zeus = getAssignedCuratorLogic (leader(grpNetId call BIS_fnc_groupFromNetId));
diag_log format ["Zeus = %1",_zeus];

// Delete all tasks
/*
{
	diag_log format ["DRO: Deleting old task %1", _x];
	[_x] call BIS_fnc_deleteTask;
} forEach ([leader (grpNetId call BIS_fnc_groupFromNetId)] call BIS_fnc_tasksUnit);
*/

{	
	if (isObjectHidden _x) then {		
		deleteVehicle _x;
		diag_log format ["DRO: Deleting unit %1", _x];
	};
} forEach _playerGroup;
diag_log _playerGroup;

if (insertType == 0) then {
	insertType = [1,3] call BIS_fnc_randomInt;		
};

_customStart = false;
_randomStartingLocation = [];
_forceSeaStart = 0;
if (count customPos == 0) then {
	diag_log "DRO: No custom start position found, will generate random.";
	_randomStartingLocation = [];
} else {
	diag_log "DRO: Custom start position found.";
	_randomStartingLocation = customPos;
	if (surfaceIsWater _randomStartingLocation) then {
		_forceSeaStart = 1;
	};
	_customStart = true;
};

_seaSpawnReal = [];
_airStartPos = [];

// Random resupply
_resupplyValid = true;
if (count pHeliClasses > 0) then {
	if (random 1 > 0.5) then {
		customSupports pushBackUnique ["SUPPLY"];
		_resupplyValid = false;
	};
};
if (_resupplyValid) then {
	_validIndexes = [];
	{
		if (count ((_x select 2) select 6) > 0) then {
			_validIndexes pushBack _forEachIndex;
		};
	} forEach AOLocations;
	_resupplyPos = if (count _validIndexes > 0) then {
		[(((AOLocations select (selectRandom _validIndexes)) select 2) select 6)] call sun_selectRemove
	} else {
		[_center, 0, 500, 2, 0, 0.4, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos
	};
	if (!isNil "_resupplyPos") then {
		if (_resupplyPos isEqualTo [0,0,0]) then {
			_resupplyValid = false;
		};
	} else {
		_resupplyValid = false;
	};
	if (_resupplyValid) then {
		_resupply = "B_supplyCrate_F" createVehicle _resupplyPos;
		clearWeaponCargoGlobal _resupply;
		clearMagazineCargoGlobal _resupply;
		clearItemCargoGlobal _resupply;
		_resupply addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 2];
		_resupply addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 4];
		_resupply addItemCargoGlobal ["Medikit", 1];
		_resupply addItemCargoGlobal ["FirstAidKit", 10];
		{		
			_magazines = magazinesAmmoFull _x;			
			{
				_resupply addMagazineCargoGlobal [(_x select 0), 2];
			} forEach _magazines;	
		} forEach units (grpNetId call BIS_fnc_groupFromNetId);		
		[_resupply] spawn {
			waitUntil {sleep 5; (missionNameSpace getVariable ["playersReady", 0]) == 1};
			[(_this select 0)] call sun_supplyBox;
		};		
		markerResupply = createMarker ["resupplyMkr", _resupplyPos];
		markerResupply setMarkerShape "ICON";
		markerResupply setMarkerColor markerColorPlayers;
		markerResupply setMarkerType "mil_flag";
		markerResupply setMarkerText "Resupply";
		markerResupply setMarkerSize [0.6, 0.6];
	};
};
_carClasses = [];
_carWeights = [];
_slots = [];

if (count pCarNoTurretClasses > 0) then {
	{
		_vehicleClass = (configFile >> "CfgVehicles" >> _x >> "vehicleClass") call BIS_fnc_GetCfgData;		
		_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));
		
		if (_vehicleClass != "Support") then {		
			_carClasses pushBack _x;						
			_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));						
			_slots pushBack _vehRoles;
			_weight = (1-((_vehRoles * 3)/100)) max 0;		
			_carWeights pushBack _weight;		
			
		};
	} forEach pCarNoTurretClasses;
};

{
	_vehicleClass = (configFile >> "CfgVehicles" >> _x >> "vehicleClass") call BIS_fnc_GetCfgData;
	_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));
	
	if (_vehicleClass != "Support") then {		
		if (_x in _carClasses) then {} else {
			_carClasses pushBack _x;				
			_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));
			_slots pushBack _vehRoles;		
			_weight = (1-((_vehRoles * 7)/100)) max 0;		
			_carWeights pushBack _weight;
		};		
	};		
} forEach pCarClasses;

_heliClasses = [];
_cargoRange = [100, 0];
{	
	_trueCargo = [_x] call sun_getTrueCargo;		
	if (_trueCargo >= count (units (grpNetId call BIS_fnc_groupFromNetId))) then {
		if (_forEachIndex == 0) then {
			_cargoRange set [0, _trueCargo];
			_cargoRange set [1, _trueCargo];
		};
		_heliClasses pushBack _x;
		if (_trueCargo < (_cargoRange select 0)) then {
			_cargoRange set [0, _trueCargo];
		};
		if (_trueCargo > (_cargoRange select 1)) then {
			_cargoRange set [1, _trueCargo];
		};
	};	
} forEach pHeliClasses;

_shipClasses = pShipClasses;
if (count _shipClasses == 0) then {
	_shipClasses pushBack "B_Boat_Transport_01_F";
};

if ((count _carClasses) == 0) then {
	_carClasses pushBack "B_G_Offroad_01_F";
	_carWeights pushBack 1;
};

if ((count _heliClasses) == 0) then {
	switch (playersSide) do {
		case west: {_heliClasses pushBack "B_Heli_Transport_01_F"};
		case east: {_heliClasses pushBack "O_Heli_Light_02_F"};
		case resistance: {_heliClasses pushBack "I_Heli_Transport_02_F"};
	};
};

diag_log format ["DRO: Insert will be %1", insertType];

switch (insertType) do {

	case 1: {
		// GROUND INSERTION		
		_groundStylesAvailable = [];		
		_seaSpawn = nil;
		
		if (_forceSeaStart == 1) then {
			_groundStylesAvailable = ["SEA"];
		} else {
		
			// Check for sea start possibility
			_seaPositions = [];	
			if (!_customStart) then {
				_seaPlaces = selectBestPlaces [_center, aoSize, "(1 + sea)", 50, 5];							
				{
					_thisPos = (_x select 0);
					_zValue = getTerrainHeightASL _thisPos;					
					if (_zValue < -10) then {
						_seaPositions pushBack [((_x select 0)select 0), ((_x select 0)select 1), _zValue];	
					};					
				} forEach _seaPlaces;				
				_seaPositions = [_seaPositions, [_center], {_input0 distance _x}, "DESCEND"] call BIS_fnc_sortBy;
				diag_log format ["DRO: Potential sea positions: %1", _seaPositions];
			};

			// Generate random ground start position for player group
			if (count _randomStartingLocation == 0) then {
				_randomStartingLocation = [_center, (aoSize+500), (aoSize+1500), 8, 0, 0.25, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			};
			if (_randomStartingLocation isEqualTo [0,0,0]) then {
				_randomStartingLocation = [_center, (aoSize+500), (aoSize+3000), 2, 0, 0.6, 0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;				
			};			
			if (_forceSeaStart == 1) then {
				_groundStylesAvailable = ["SEA"];
			} else {
				if (!(_randomStartingLocation isEqualTo [0,0,0])) then {								
					_groundStylesAvailable pushBack "FOB";					
				};
			};					
			
			if (count _groundStylesAvailable == 0) then {			
				if ((count _seaPositions > 0) && (count _shipClasses > 0)) then {
					_seaSpawn = _seaPositions select 0;
					_groundStylesAvailable pushBackUnique "SEA";
				};		
			} else {
				_seaRand = (random 100);
				if (_seaRand > 85) then {
					if ((count _seaPositions > 0) && (count _shipClasses > 0)) then {
						_seaSpawn = _seaPositions select 0;
						_groundStylesAvailable pushBackUnique "SEA";
					};
				};
			};		
		};
		_groundStyleSelect = selectRandom _groundStylesAvailable;
		diag_log format ["DRO: Ground insert style will be %1", _groundStyleSelect];
				
		switch (_groundStyleSelect) do {
			case "FOB": {					
				// Spawn FOB				
				insertType = "GROUND";
				// Get smallest distance to an AO
				_closestDistance = 1000000;
				{
					_dist = (_x select 0) distance _randomStartingLocation;
					if (_dist < _closestDistance) then {
						_closestDistance = _dist;
					};
				} forEach AOLocations;
				
				_boundaries = [0, 1000, 2000, 1000000];
				_chosenBoundary = 0;
				{
					if (_closestDistance > _x) then {
						if (_forEachIndex + 1 < count _boundaries) then {
							if (_closestDistance <= (_boundaries select (_forEachIndex + 1))) then {
								_chosenBoundary = _forEachIndex;
							};
						};
					};
				} forEach _boundaries;
				
				switch (_chosenBoundary) do {
					case 0: {
						// Camp
						[_randomStartingLocation] call fnc_generateCampsite;
					};
					case 1: {
						// Small FOB
						_objects = selectRandom compositionsFOBs;
						_ambGrp = createGroup playersSide;		
						_spawnDir = (random 360);
						{
							_x hideObjectGlobal true;
						} forEach (nearestTerrainObjects [_randomStartingLocation, [], 40]);
						_spawnedObjects = [_randomStartingLocation, _spawnDir, _objects] call BIS_fnc_ObjectsMapper;
						{
							if (typeOf _x == "Sign_Arrow_Blue_F") then {
								_guardGroup = [getPos _x, playersSide, pInfClassesForWeights, pInfClassWeights, [1,1]] call dro_spawnGroupWeighted;
								_guardUnit = ((units _guardGroup) select 0);
								[_guardUnit, (selectRandom ["GUARD", "STAND1", "STAND2", "STAND_U1", "STAND_U2", "STAND_U3"]), "ASIS"] remoteExec ["BIS_fnc_ambientAnim", 0, true];										
								_guardUnit setFormDir (getDir _x);
								_guardUnit setDir (getDir _x);
								//_guardUnit disableAI "TARGET";
								//_guardUnit disableAI "MOVE";
								deleteVehicle _x;
							};
						} forEach _spawnedObjects;
						
						_addonPlaces = [_randomStartingLocation, 3, 3, 14] call sun_defineGrid;						
						_addonPlaces deleteAt 4;
							
						for "_i" from 3 to ([4, 7] call BIS_fnc_randomInt) step 1 do {
							_thisPos = [_addonPlaces] call sun_selectRemove;
							_objects = selectRandom compositionsFOBAddons;
							_spawnedObjects = [_thisPos, (selectRandom [_spawnDir, _spawnDir + 90]), _objects] call BIS_fnc_ObjectsMapper;
							if (random 1 > 0.6) then {
								_ambGuard = (units (([_thisPos, playersSide, pInfClassesForWeights, pInfClassWeights, [1, 1]] call dro_spawnGroupWeighted)) select 0);
								[_ambGuard, (selectRandom ["GUARD", "STAND1", "STAND2", "STAND_U1", "STAND_U2", "STAND_U3"]), (selectRandom ["ASIS", "MEDIUM"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];										
								_dir = (selectRandom [(_ambGuard getDir _thisPos), (_thisPos getDir _ambGuard)]);																
								_ambGuard setDir _dir;
								if (random 1 > 0.3) then {
									_safePos = (getPos _ambGuard) findEmptyPosition [1.5, 2.5];
									if (count _safePos > 0) then {
										_ambGuard2 = (units (([_safePos, playersSide, pInfClassesForWeights, pInfClassWeights, [1, 1]] call dro_spawnGroupWeighted)) select 0);
										//_ambGuard2 setPos (_thisPos getPos [(random [1.5, 2.5, 2]), _dir - 25]);
										[_ambGuard2, (selectRandom ["GUARD", "STAND1", "STAND2", "STAND_U1", "STAND_U2", "STAND_U3"]), (selectRandom ["ASIS", "MEDIUM"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];										
										_ambGuard2 setDir ((_ambGuard2 getDir _ambGuard) - 20);
									};
								};
							};
						};
						
						_spawnPos1 = _randomStartingLocation findEmptyPosition [10, 30];
						_spawnedSquad1 = [_spawnPos1, playersSide, pInfClassesForWeights, pInfClassWeights, [2, 4]] call dro_spawnGroupWeighted;						
						waitUntil {!isNil "_spawnedSquad1"};
						{							
							_x disableAI "TARGET";
							_x disableAI "AUTOTARGET";
							_x disableAI "FSM";
							_x disableAI "WEAPONAIM";
							_x disableAI "AUTOCOMBAT";
						} forEach (units _spawnedSquad1);						
						[_spawnedSquad1, _randomStartingLocation, 30] call BIS_fnc_taskPatrol;						
					
					};
					case 2: {
						// Big FOB
						_ambGrp = createGroup playersSide;
						_objects = selectRandom compositionsFOBLarge;								
						//_spawnDir = (random 360);
						{
							_x hideObjectGlobal true;
						} forEach (nearestTerrainObjects [_randomStartingLocation, [], 80]);
						_spawnedObjects = [_randomStartingLocation, 0, _objects] call BIS_fnc_ObjectsMapper;
						{
							if (["patrol", (typeOf _x)] call BIS_fnc_inString) then {
								if (random 1 > 0.25) then {
									_ambGuard = (units (([_randomStartingLocation, playersSide, pInfClassesForWeights, pInfClassWeights, [1, 1]] call dro_spawnGroupWeighted)) select 0);
									[_ambGuard, (selectRandom ["WATCH", "WATCH2"]), "ASIS"] remoteExec ["BIS_fnc_ambientAnim", 0, true];										
									_dirOut = ((getDir _x) + 180);
									_ambGuard setDir _dirOut;
									[_x, _ambGuard, [(selectRandom [-1.5, 1.5]),-1.5,4.3], _dirOut] call BIS_fnc_relPosObject;
								};					
							};
							
							if (typeOf _x == "Sign_Arrow_Direction_Green_F") then {
								_objVehWork = createVehicle [(selectRandom pCarClasses), (getPos _x), [], 0, "CAN_COLLIDE"];
								_objVehWork setDir (getDir _x);
								deleteVehicle _x;
								_objVehWork setVehicleLock "LOCKED";
								_objVehWork setDamage 0.8;
								_class = (selectRandom pInfClasses);
								{
									if (["engineer", _x, false] call BIS_fnc_inString) then {
										_class = _x;
									};
								} forEach pInfClasses;							
								_ambWorker = _ambGrp createUnit [_class, _randomStartingLocation, [], 0, "NONE"];
								
								[_ambWorker, (selectRandom ["REPAIR_VEH_KNEEL", "REPAIR_VEH_STAND"]), (selectRandom ["LIGHT", "NONE"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];
								[_objVehWork, _ambWorker, [-2,(selectRandom [-1.5, 1.5]), 0], (getDir _objVehWork)] call BIS_fnc_relPosObject;
								_dirTo = ((getDir _objVehWork) + 90);
								_ambWorker setDir _dirTo;
								//[_ambWorker, "InBaseMoves_repairVehicleKnl"] remoteExec ["switchMove", 0, true];
								
							};					
						} forEach _spawnedObjects;
						
						_base = createVehicle ["Land_CanvasCover_01_F", _randomStartingLocation, [], 0, "CAN_COLLIDE"];					
						_obj1 = objNull;
						_obj3 = createVehicle ["Land_CampingTable_white_F", [0,0,100], [], 0, "CAN_COLLIDE"];
						[_base, _obj3, [1.1,0.7,0], 90] call BIS_fnc_relPosObject;		
						if (playersFaction in ["BLU_CTRG_F", "BLU_F", "BLU_GEN_F", "BLU_T_F", "IND_F", "OPF_F", "OPF_T_F", "OPF_V_F"]) then {
							_obj1 = createVehicle ["Land_TripodScreen_01_large_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_base, _obj1, [0.3,3.1,0], 230] call BIS_fnc_relPosObject;
												
							_obj4 = createVehicle ["Land_Laptop_unfolded_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_obj3, _obj4, [-0.35,0.15,0.82], 160] call BIS_fnc_relPosObject;
							_obj5 = createVehicle ["Land_SatellitePhone_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_obj3, _obj5, [0.5,0,0.82], 20] call BIS_fnc_relPosObject;
							_box1 = createVehicle ["Land_PaperBox_open_full_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_base, _box1, [2.3,0.4,0], 5] call BIS_fnc_relPosObject;
							_box2 = createVehicle ["Land_Pallet_MilBoxes_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_base, _box2, [2.5,1.7,0], 350] call BIS_fnc_relPosObject;
							// Setup actions post player spawn
							/*
							[_obj1] spawn {
								params ["_obj1"];
								waitUntil {(missionNamespace getVariable ["playersReady", 0]) == 1};				
								
								// Set screen render
								if (typeOf _obj1 == "Land_TripodScreen_01_large_F") then {
									_obj1 setObjectTextureGlobal [0, "#(argb,512,512,1)r2t(basescreen,1.333)"];
									//_camPos = [(_startPos select 0), (_startPos select 1), ((_startPos select 2) + 300)];						
									_camPos = [(((AOLocations select 0) select 0) select 0), (((AOLocations select 0) select 0) select 1), ((((AOLocations select 0) select 0) select 2) + 500)];		
									camScreen = "camera" camCreate _camPos;
									camScreen cameraEffect ["Internal", "Back", "basescreen"];			
									camScreen camSetDir [0,0,-0.5]; 
									camScreen camCommit 0;
									"basescreen" setPiPEffect [3,1,1,0.2,0,[0,0,0,0],[1,1,1,0],[1,1,1,1]];
								};
								// Create sound effects
								[_obj1, "BASE_RADIO"] spawn sun_loopSounds;
														
							};
							*/
						} else {
							_obj1 = createVehicle ["Land_MapBoard_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							
							[_base, _obj1, [0.3,3.1,0], 50] call BIS_fnc_relPosObject;
							
							_map = switch (worldName) do {
								case "Altis": {"Land_Map_altis_F"};
								case "Stratis": {"Land_Map_stratis_F"};
								case "Tanoa": {"Land_Map_Tanoa_F"};
								case "Malden": {"Land_Map_Malden_F"};
								case "Enoch": {"Land_Map_Enoch_F"};
								default {"Land_Map_blank_F"};
							};	
							_intelClasses = ["Land_File1_F", "Land_FilePhotos_F", "Land_File2_F", "Land_File_research_F", "Land_MobilePhone_old_F", "Land_PortableLongRangeRadio_F", "Land_Laptop_02_unfolded_F"];
							
							_obj4 = createVehicle [_map, [0,0,100], [], 0, "CAN_COLLIDE"];
							[_obj3, _obj4, [-0.35,0.12,0.82], 70] call BIS_fnc_relPosObject;
							if (_map == "Land_Map_blank_F") then {
								_mapPic = ((configFile >> "CfgWorlds" >> worldName >> "pictureMap") call BIS_fnc_GetCfgData);
								if (!isNil "_mapPic") then {
									_obj4 setObjectTextureGlobal [0, _mapPic];
								};
							};
							_obj5 = createVehicle [(selectRandom _intelClasses), [0,0,100], [], 0, "CAN_COLLIDE"];
							[_obj3, _obj5, [0.5,0,0.82], 20] call BIS_fnc_relPosObject;
							
							_box1 = createVehicle ["Land_Pallet_MilBoxes_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_base, _box1, [2.3,0.4,0], 5] call BIS_fnc_relPosObject;
							_box2 = createVehicle ["Land_PaperBox_open_full_F", [0,0,100], [], 0, "CAN_COLLIDE"];
							[_base, _box2, [2.5,2,0], 350] call BIS_fnc_relPosObject;
						};
						_mapBoard = switch (worldName) do {
							case "Altis": {"MapBoard_altis_F"};
							case "Stratis": {"MapBoard_stratis_F"};
							case "Tanoa": {"MapBoard_Tanoa_F"};
							case "Malden": {"MapBoard_Malden_F"};
							case "Enoch": {"MapBoard_Enoch_F"};
							default {"Land_MapBoard_F"};
						};	
						_obj2 = createVehicle [_mapBoard, [0,0,100], [], 0, "CAN_COLLIDE"];
						[_base, _obj2, [-3.6,3.4,0], 320] call BIS_fnc_relPosObject;
						
						if (typeOf _obj2 == "Land_MapBoard_F") then {
							_mapPic = ((configFile >> "CfgWorlds" >> worldName >> "pictureMap") call BIS_fnc_GetCfgData);
							if (!isNil "_mapPic") then {
								_obj2 setObjectTextureGlobal [0, _mapPic];
							};
						};
						
						// Create officers
						if (count pOfficerClasses > 0) then {
							if (random 1 > 0.3) then {
								_dir = if (typeOf _obj1 == "Land_MapBoard_F") then {((getDir _obj1) + 220)} else {((getDir _obj1) + 40)};
								_officer = _ambGrp createUnit [(selectRandom pOfficerClasses), (_obj1 getPos [2, _dir]), [], 0, "CAN_COLLIDE"];
								_officer setDir (_officer getDir _obj1);
								[_officer, "BRIEFING", (selectRandom ["LIGHT", "ASIS", "NONE"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];
							};
							if (random 1 > 0.3) then {
								_officer2 = _ambGrp createUnit [(selectRandom pOfficerClasses), (_obj3 getPos [0.7, ((getDir _obj3) - 150)]), [], 0, "CAN_COLLIDE"];
								[_officer2, "LEAN_ON_TABLE", (selectRandom ["LIGHT", "ASIS", "NONE"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];
								_officer2 setDir (getDir _obj3);
								_officer2 setPos [((getPos _officer2) select 0), ((getPos _officer2) select 1), 0.8];
							};
						};
						
						for "_i" from 0 to ([2, 4] call BIS_fnc_randomInt) do {
							_thisPos = [_randomStartingLocation, 10, 18, 1, 0, 1, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
							if !(_thisPos isEqualTo [0,0,0]) then {
								//_ambGuard = _ambGrp createUnit [(selectRandom pInfClasses), _thisPos, [], 0, "NONE"];
								_ambGuard = (units (([_thisPos, playersSide, pInfClassesForWeights, pInfClassWeights, [1, 1]] call dro_spawnGroupWeighted)) select 0);
								[_ambGuard, (selectRandom ["GUARD", "STAND1", "STAND2", "STAND_U1", "STAND_U2", "STAND_U3"]), (selectRandom ["ASIS", "MEDIUM"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];										
								_dir = (selectRandom [(_ambGuard getDir _thisPos), (_thisPos getDir _ambGuard)]);								
								_ambGuard setDir _dir;
								if (random 1 > 0.3) then {
									_safePos = (getPos _ambGuard) findEmptyPosition [1.5, 2.5];
									if (count _safePos > 0) then {
										_ambGuard2 = (units (([_safePos, playersSide, pInfClassesForWeights, pInfClassWeights, [1, 1]] call dro_spawnGroupWeighted)) select 0);
										//_ambGuard2 setPos (_thisPos getPos [(random [1.5, 2.5, 2]), _dir - 25]);
										[_ambGuard2, (selectRandom ["GUARD", "STAND1", "STAND2", "STAND_U1", "STAND_U2", "STAND_U3"]), (selectRandom ["ASIS", "MEDIUM"])] remoteExec ["BIS_fnc_ambientAnim", 0, true];										
										_ambGuard2 setDir ((_ambGuard2 getDir _ambGuard) - 20);
									};
								};
							};
						}; 						
						_spawnPos1 = _randomStartingLocation findEmptyPosition [10, 50];
						if (count _spawnPos1 > 0) then {
							_spawnedSquad1 = [_spawnPos1, playersSide, pInfClassesForWeights, pInfClassWeights, [2, 4]] call dro_spawnGroupWeighted;						
							waitUntil {!isNil "_spawnedSquad1"};
							{							
								_x disableAI "TARGET";
								_x disableAI "AUTOTARGET";
								_x disableAI "FSM";
								_x disableAI "WEAPONAIM";
								_x disableAI "AUTOCOMBAT";
							} forEach (units _spawnedSquad1);						
							[_spawnedSquad1, _randomStartingLocation, 30] call BIS_fnc_taskPatrol;
						};						
					};					
				};
								
				// Create 'real' player units at the spawn position and switch players
				_playersPos = [_randomStartingLocation, 20, (random 360)] call dro_extendPos;				
				//[_playersPos] remoteExec ["sun_newUnits", s1];
				[_playersPos] call sun_setPlayerGroup;
				waitUntil {newUnitsReady};				
				_rolesFilled = 0;
				_whileAttempts = 0;
				_select = 0;
				_vehLocation = [];
				if (count startVehicles > 0) then {
					{
						_vehRoles = (count([_x] call BIS_fnc_vehicleRoles));
						_vehLocation = _randomStartingLocation findEmptyPosition [10, 60, _x];
						diag_log format ["DRO: spawning insert vehicle %1 at %2 with %3 roles", _x, _vehLocation, _vehRoles];
						if (!isNil "_vehLocation" && count _vehLocation > 0) then {
							_veh = createVehicle [_x, _vehLocation, [], 0, "NONE"];
							_veh respawnVehicle	[30];							
							_rolesFilled = _rolesFilled + _vehRoles;
						};
					} forEach startVehicles;
				};
				while {(_rolesFilled < (count(units (grpNetId call BIS_fnc_groupFromNetId))))} do {
					_vehClass = "";
					diag_log format ["DRO: startVehicles = %1", startVehicles];
					if ((count startVehicles > 0) && _whileAttempts == 0) then {
						_vehClass = (startVehicles select _select);
						if (_select < ((count startVehicles)-1)) then {
							_select = _select + 1;
						} else {
							_select = 0;
						}; 
					} else {
						_vehClass = _carClasses selectRandomWeighted _carWeights;
					};					
					_vehRoles = (count([_vehClass] call BIS_fnc_vehicleRoles));
					_vehLocation = _randomStartingLocation findEmptyPosition [10, 60, _vehClass];
					diag_log format ["DRO: spawning insert vehicle %1 at %2 with %3 roles", _vehClass, _vehLocation, _vehRoles];
						if (!isNil "_vehLocation" && count _vehLocation > 0) then {
							if (_vehClass isKindOf "Helicopter") then {
								_padTypes = ["Land_HelipadCircle_F", "Land_HelipadCivil_F", "Land_HelipadSquare_F"];
								_veh = createVehicle [(selectRandom _padTypes), _vehLocation, [], 0, "NONE"];
							};
							_veh = createVehicle [_vehClass, _vehLocation, [], 0, "NONE"];
							_veh respawnVehicle	[30];														
							_rolesFilled = _rolesFilled + _vehRoles;
						};
					_whileAttempts = _whileAttempts + 1;
					if (_whileAttempts >= 8) exitWith {
						diag_log "DRO: spawning insert vehicle while attempts exceeded";
					};
				};
				
				_mkrName = switch (playersSide) do {
					case west: {"respawn_vehicle_west"};
					case east: {"respawn_vehicle_east"};
					case resistance: {"respawn_vehicle_guerilla"};
				};
				_vehicleRespawnMkr = createMarker [_mkrName, _vehLocation];
				_vehicleRespawnMkr setMarkerShape "ICON";
				_vehicleRespawnMkr setMarkerType "EmptyIcon";
				
				_boxLocation = _randomStartingLocation findEmptyPosition [0, 20, "B_supplyCrate_F"];
				if (count _boxLocation > 0) then {				
					_box = createVehicle ["B_supplyCrate_F", _boxLocation, [], 0, "NONE"];
					_box = [_box] call sun_checkVehicleSpawn;
					clearWeaponCargoGlobal _box;
					clearMagazineCargoGlobal _box;
					clearItemCargoGlobal _box;

					_box addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 2];
					_box addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 4];
					_box addItemCargoGlobal ["Medikit", 1];
					_box addItemCargoGlobal ["FirstAidKit", 10];
					_box addItemCargoGlobal ["Toolkit", 1];
					_box addItemCargoGlobal ["MineDetector", 1];

					{						
						_magazines = magazinesAmmoFull _x;						
						{
							_box addMagazineCargoGlobal [(_x select 0), 2];
						} forEach _magazines;	
					} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
					
					["AmmoboxInit", [_box, true]] spawn BIS_fnc_arsenal;
					[_box] spawn {
						waitUntil {(missionNameSpace getVariable ["playersReady", 0]) == 1};
						[(_this select 0)] call sun_supplyBox;
					};
					
				
				};
				// FOB marker
				deleteMarker "campMkr";				
				_campName = format ["FOB %1", ([FOBNames] call sun_selectRemove)];
				missionNameSpace setVariable ["publicCampName", _campName];
				publicVariable "publicCampName";
				markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
				markerPlayerStart setMarkerShape "ICON";
				markerPlayerStart setMarkerColor markerColorPlayers;
				markerPlayerStart setMarkerType "loc_Bunker";
				markerPlayerStart setMarkerSize [3, 3];
				markerPlayerStart setMarkerText _campName;
				if ((paramsArray select 0) < 3 && (paramsArray select 1) < 2) then {	
					respawnFOB = [missionNamespace, "campMkr", _campName] call BIS_fnc_addRespawnPosition;
				};
				
			};		
			
			case "SEA": {				
				insertType = "SEA";
				_shipClass = selectRandom _shipClasses;
				
				if (getMarkerColor "campMkr" == "") then {
					_randomStartingLocation = [(_seaSpawn select 0), (_seaSpawn select 1), 0];
				} else {
					_randomStartingLocation = getMarkerPos "campMkr";					
				};
				[_randomStartingLocation] call sun_setPlayerGroup;
				//[_randomStartingLocation] remoteExec ["sun_newUnits", s1];
				waitUntil {newUnitsReady};				
				sleep 2;
				// Spawn vehicles until there are enough slots for players
				_vehiclePool = [];
				_rolesFilled = 0;
				while {(_rolesFilled < (count(units(grpNetId call BIS_fnc_groupFromNetId))))} do {
				
					_shipClass = selectRandom _shipClasses;
					_vehRoles = (count([_shipClass] call BIS_fnc_vehicleRoles));
					
					_boatLoc = _randomStartingLocation findEmptyPosition [0, 10, _shipClass];
					
					_boat = createVehicle [_shipClass, _boatLoc, [], 0, "NONE"];
					
					[
						_boat,
						[
							"Nudge",  
							{  
								_dir = [(_this select 1), (_this select 0)] call BIS_fnc_dirTo;  
								_nudgePos = [(getPos (_this select 0)), 2, _dir] call dro_extendPos;  
								(_this select 0) setVelocity [(sin _dir)*3, (cos _dir)*3, 0.5];	
							},  
							nil,  
							6,  
							false,  
							false,  
							"",  
							"(_this distance _target < 8) && (vehicle _this == _this)"
						]
					] remoteExec ["addAction", 0, true];
					
					_rolesFilled = _rolesFilled + _vehRoles;
					
					_vehiclePool pushBack _boat;
					
				};	
				
				if (count _vehiclePool > 0) then {
					
					_playersLeft = (units(grpNetId call BIS_fnc_groupFromNetId));
					diag_log format ["_playersLeft = %1", _playersLeft];
					{
						if ((count _playersLeft) > 0) then {
							_thisBoat = _x;
							diag_log format ["_thisBoat = %1", _thisBoat];
							_vehRoles = (count([_thisBoat] call BIS_fnc_vehicleRoles));
							diag_log format ["_vehRoles = %1", _vehRoles];
							_playersToAssign = [];
							if (_vehRoles > (count _playersLeft)) then {_vehRoles = (count _playersLeft)};
							for "_i" from 0 to (_vehRoles - 1) do {	
								diag_log format ["_i = %1", _i];
								diag_log format ["(_playersLeft select _i) = %1", (_playersLeft select _i)];
								_thisUnit = (_playersLeft select _i);
								_playersToAssign pushBack _thisUnit;							
							};
							_playersLeft = _playersLeft - _playersToAssign;
							diag_log format ["_playersLeft = %1", _playersLeft];
							diag_log format ["_playersToAssign = %1", _playersToAssign];
							if ((count _playersToAssign) > 0) then {
								[_playersToAssign, _thisBoat] spawn sun_groupToVehicle;
							};
						};						
					} forEach _vehiclePool;
					diag_log format ["(units(group s1)) = %1", (units(grpNetId call BIS_fnc_groupFromNetId))];					
					deleteMarker "campMkr";
					missionNameSpace setVariable ["publicCampName", "Altis Ocean Territory"];
					publicVariable "publicCampName";
					markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
					markerPlayerStart setMarkerShape "ICON";
					markerPlayerStart setMarkerColor markerColorPlayers;
					markerPlayerStart setMarkerType "mil_start";
					markerPlayerStart setMarkerText "Sea Insert";
					
					{
						_x addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 2];
						_x addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 4];
						_x addItemCargoGlobal ["Medikit", 1];
						_x addItemCargoGlobal ["FirstAidKit", 10];
					} forEach _vehiclePool;
										
					
				};				
			};
		};		
				
		// Blacklist marker
		_markerBL = createMarker ["blacklistMkr", _randomStartingLocation];
		_markerBL setMarkerShape "ELLIPSE";
		_markerBL setMarkerSize [500, 500];
		_markerBL setMarkerAlpha 0;
		blackList = blackList + [_markerBL];
			
	};
	case 2: {
		// HALO INSERTION		
		// Generate drop position
		insertType = "HALO";
		// If no insert position selected then generate a random one
		if (count _randomStartingLocation == 0) then {		
			_randomStartingLocation = [_center,(aoSize/1.8),(aoSize/1.6),0,1,1,0, [trgAOC], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if (_randomStartingLocation isEqualTo [0,0,0]) then {
				_randomStartingLocation = [_center,(aoSize/1.8),(aoSize/1.6),0,0,1,0] call BIS_fnc_findSafePos;
			};			
		};
				
		_randomStartingLocation set [2, 0];
		_startHeight = (getTerrainHeightASL _randomStartingLocation) + 2000;
		_planeStartPos = [(_randomStartingLocation select 0), (_randomStartingLocation select 1), 2100];
		_airStartPos = [(_randomStartingLocation select 0), (_randomStartingLocation select 1), 2000];
		
		// Draw drop marker
		deleteMarker "campMkr";
		markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
		markerPlayerStart setMarkerShape "ICON";
		markerPlayerStart setMarkerColor markerColorPlayers;
		markerPlayerStart setMarkerType "mil_end";
		markerPlayerStart setMarkerText "Drop point";		
						
		//[_airStartPos] remoteExec ["sun_newUnits", s1];
		[_airStartPos] call sun_setPlayerGroup;
		waitUntil {newUnitsReady};
		sleep 2;
		//[_airStartPos] call sun_newUnits;
		/*
		waitUntil {count (units (grpNetId call BIS_fnc_groupFromNetId)) == 0};
		grpNetId = _newGroup call BIS_fnc_netId;
		diag_log format ["DRO: New group with netID %1 containing %2", grpNetId, units (grpNetId call BIS_fnc_groupFromNetId)];	
		publicVariable "grpNetId";
		*/
		//[_airStartPos] remoteExec ["sun_newUnits", s1];
		//waitUntil {newUnitsReady};
		
		_lastPos = _airStartPos;
		{
			_thisPos = [_lastPos, 20, ([_airStartPos, _center] call BIS_fnc_dirTo)] call dro_extendPos;
			_x setPos [(_thisPos select 0) + (random 10), (_thisPos select 1) + (random 10), (3000 + (random 20))];			
			_lastPos = _thisPos;
		} forEach units (grpNetId call BIS_fnc_groupFromNetId);
				
		[units (grpNetId call BIS_fnc_groupFromNetId)] execVM 'sunday_system\player_setup\callParadrop.sqf';
		
		// Set wind
		0 setGusts 0;
		setWind [0, 0, true];		
		diag_log "DRO: Air insert called";
		sleep 2;		
		// Blacklist marker
		_markerBL = createMarker ["blacklistMkr", _randomStartingLocation];
		_markerBL setMarkerShape "ELLIPSE";
		_markerBL setMarkerSize [500, 500];
		_markerBL setMarkerAlpha 0;
		blackList = blackList + [_markerBL];			
		missionNameSpace setVariable ["publicCampName", format ["%1 Airspace", ((configfile >> "CfgWorlds" >> worldName >> "description") call BIS_fnc_getCfgData)]];
		publicVariable "publicCampName";
	};
	
	case 3: {
		// HELI INSERTION		
		insertType = "HELI";
		// Generate drop position				
		// If no insert position selected then generate a random one
		if (count _randomStartingLocation == 0) then {		
			_randomStartingLocation = [_center,(aoSize-150),(aoSize+500),0,0,0.25,0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
			if (_randomStartingLocation isEqualTo [0,0,0]) then {
				_randomStartingLocation = [_center,aoSize,(aoSize+1500),0,0,1,0] call BIS_fnc_findSafePos;
			};			
		};				
		_randomStartingLocation set [2, 0];
		
		_dir = [_center, _randomStartingLocation] call BIS_fnc_dirTo;
		_heliPos = [_randomStartingLocation, 2000, _dir] call BIS_fnc_relPos;
		_heliPos set [2,100];
		_cargoWeights = [];
		{
			_thisWeight = linearConversion [(_cargoRange select 0)-1, (_cargoRange select 1)+1, [_x] call sun_getTrueCargo, 1, 0, true] max 0; 
			_cargoWeights pushBack _thisWeight;
		} forEach _heliClasses;		
		diag_log format ["DRO: _heliClasses = %1", _heliClasses];
		diag_log format ["DRO: _cargoWeights = %1", _cargoWeights];
		_heliClass = _heliClasses selectRandomWeighted _cargoWeights;
		
		_insertHeli = createVehicle [_heliClass, _heliPos, [], 0, "FLY"];
		_insertHeli allowDamage false;
		[_insertHeli, playersSide, false] call sun_createVehicleCrew;		
		_insertHeli setPos _heliPos;
		_insertHeli setDir (_dir + 180);		
		waitUntil {!isNull (driver _insertHeli)};		
		_insertHeli flyInHeight 40;
		_insertHeli setBehaviour "CARELESS";
		_insertHeli setCaptive true;
		(driver _insertHeli) disableAI "TARGET";		
		(driver _insertHeli) disableAI "AUTOTARGET";		
		
		_heliGroup = group (driver _insertHeli);
		while {(count (waypoints (_insertHeli) )) > 0} do {
		   deleteWaypoint ((waypoints (_insertHeli) ) select 0);
		};
		[_heliGroup, _randomStartingLocation, _insertHeli, _heliPos] spawn {
			_heliGroup = (_this select 0);
			_randomStartingLocation = (_this select 1);
			_insertHeli = (_this select 2);
			_heliPos = (_this select 3);
			
			private _wp0 = _heliGroup addWaypoint [(getPos _insertHeli), 0];	
			_wp0 setWaypointBehaviour "CARELESS";			
			_wp0 setWaypointSpeed "NORMAL";
			_wp0 setWaypointType "MOVE";	
			
			private _wpLand = _heliGroup addWaypoint [_randomStartingLocation, 0];
			_wpLand setWaypointType "MOVE";
			_wpLand setWaypointStatements ["TRUE", "vehicle this land 'GET OUT'"];
			diag_log format ["DRO: Insert heli waypoints: %1, %2", waypointPosition _wp0, waypointPosition _wpLand];
			waitUntil {
				sleep 2;
				((getPos _insertHeli) select 2) <= 3
			};			
			_insertHeli disableAI "MOVE";
			diag_log "DRO: Insert heli AI disabled";
			waitUntil {
				sleep 1;
				_insertHeli setVelocity [0, 0, 0];
				({_x in _insertHeli} count (units (grpNetId call BIS_fnc_groupFromNetId))) == 0;				
			};
			_insertHeli enableAI "MOVE";
			diag_log "DRO: Insert heli AI enabled";
			private _wpEnd = _heliGroup addWaypoint [_heliPos, 0];
			_wpEnd setWaypointType "MOVE";
			_wpEnd setWaypointStatements ["TRUE", "_heli = vehicle this; {_heli deleteVehicleCrew _x} forEach crew _heli; deleteVehicle _heli;"];			
		};
				
		// Draw drop marker
		deleteMarker "campMkr";
		markerPlayerStart = createMarker ["campMkr", _randomStartingLocation];
		markerPlayerStart setMarkerShape "ICON";
		markerPlayerStart setMarkerColor markerColorPlayers;
		markerPlayerStart setMarkerType "mil_end";
		markerPlayerStart setMarkerText "Drop point";
		
		//[getPos logicStartPos] remoteExec ["sun_newUnits", s1];
		[getPos logicStartPos] call sun_setPlayerGroup;
		waitUntil {newUnitsReady};
		sleep 3;
		[(units(grpNetId call BIS_fnc_groupFromNetId)), _insertHeli] spawn sun_groupToVehicle;
	};	
};

// Set leader to higher rank to avoid demotion
(leader (grpNetId call BIS_fnc_groupFromNetId)) setRank "COLONEL";

// Check for UAV terminals and spawn random UAV if possible
_uavSpawned = 0;
_spawnUAVPatrol = false;
if (count pUAVClasses > 0) then {
	{
		_itemsPresent = assignedItems _x;
		{
			if ((["UavTerminal", _x] call BIS_fnc_inString) && (_uavSpawned == 0)) then {
				_availableUAVs = [];
				{
					if (_x isKindOf "Car" || _x isKindOf "Helicopter") then {
						_availableUAVs pushBack _x;
					};
					
				} forEach pUAVClasses;
				if (count _availableUAVs > 0) then {					
					if (insertType == "GROUND") then {
						_uavClass = selectRandom _availableUAVs;
						_uavLocation = _randomStartingLocation findEmptyPosition [10, 30, _uavClass];
						if (count _uavLocation > 0) then {
							_uav = createVehicle [_uavClass, _uavLocation, [], 0, "NONE"];
							_uavSpawned = 1;
						};
					};					
				};								
			};
		} forEach _itemsPresent;
	} forEach (units (grpNetId call BIS_fnc_groupFromNetId));	
};

// Create transport boat if any routes are blocked by water
diag_log "DRO: Searching for water";
_waterReturn = [_randomStartingLocation, _center, true] call sun_checkRouteWater;
_waterPositions = [];
if (typeName _waterReturn == "ARRAY") then {
	_waterPositions pushBack _waterReturn;
} else {
	{
		if (typeName (_x select 3) == "ARRAY") then {
			_waterPositions pushBack (_x select 3);
		};
	} forEach AOLocations;
};
if (count _waterPositions > 0) then {
	diag_log "DRO: Found water for extra boat spawn";
	_closestWaterPositions = [_waterPositions, [_randomStartingLocation], {_input0 distance _x}, "ASCEND"] call BIS_fnc_sortBy;
	_checkPos = (_closestWaterPositions select 0);					
	_waterPlaces = selectBestPlaces [_checkPos, 200, "sea - waterDepth + (waterDepth factor [0.25, 0.5])", 20, 5];					
	diag_log format ["DRO: _waterPlaces = %1", _waterPlaces];
	_deepestPos = ((_waterPlaces select 0) select 0);
	_deepestHeight = getTerrainHeightASL ((_waterPlaces select 0) select 0);					
	{
		_height = getTerrainHeightASL (_x select 0);
		if (_height < _deepestHeight) then {
			_deepestHeight = _height;
			_deepestPos = (_x select 0);
		};
	} forEach _waterPlaces;					
	
	_boatPos = [(_deepestPos select 0), (_deepestPos select 1), 0];
	diag_log format ["DRO: _boatPos = %1", _boatPos];
	// Spawn boats until there are enough slots for players
	_rolesFilled = 0;
	while {_rolesFilled < (count(units(grpNetId call BIS_fnc_groupFromNetId)))} do {
	
		_shipClass = selectRandom _shipClasses;
		_vehRoles = (count([_shipClass] call BIS_fnc_vehicleRoles));
		_dir = [_checkPos, _boatPos] call BIS_fnc_dirTo;
		_boat = createVehicle [_shipClass, _boatPos, [], 0, "NONE"];
		_boat setDir _dir;
		
		[
			_boat,
			[
				"Nudge",  
				{  
				   _dir = [(_this select 1), (_this select 0)] call BIS_fnc_dirTo;  
				   _nudgePos = [(getPos (_this select 0)), 2, _dir] call dro_extendPos;  
					(_this select 0) setVelocity [(sin _dir)*3, (cos _dir)*3, 0.5];	
				},  
				nil,  
				6,  
				false,  
				false,  
				"",  
				"(_this distance _target < 8) && (vehicle _this == _this)"
			]
		] remoteExec ["addAction", 0, true];						
		_rolesFilled = _rolesFilled + _vehRoles;						
	};						
	_markerName = format["boatMkr%1", floor(random 10000)];
	_markerBoat = createMarker [_markerName, _boatPos];			
	_markerBoat setMarkerShape "ICON";
	_markerBoat setMarkerType "mil_pickup";							
	_markerBoat setMarkerColor markerColorPlayers;						
	_markerBoat setMarkerText "Sea transport";	
};		


missionNameSpace setVariable ["startPos", _randomStartingLocation, true];
/*
// Recreate tasks
if (count objData > 0) then {
	{	
		if ((_x select 6) < baseReconChance) then {
			// Create task for task data
			[_x] call sun_assignTask;		
		} else {		
			// Create recon addition
			diag_log "DRO: Creating a recon task";
			[_x, true, true] execVM "sunday_system\objectives\reconTask.sqf";	
		};		
	} forEach objData;
};
publicVariable "taskIDs";
*/
[[musicMain, 0 ,1],"bis_fnc_playmusic", true] call BIS_fnc_MP;

sleep 1;

// Add supports
[_randomStartingLocation] execVM "sunday_system\player_setup\addSupports.sqf";

(leader (grpNetId call BIS_fnc_groupFromNetId)) createDiarySubject ["reset", "Reset AI units"];
(leader (grpNetId call BIS_fnc_groupFromNetId)) createDiaryRecord ["reset", ["Reset AI units", "<br /><font size='20' face='PuristaBold'>Reset AI Units</font><br /><br />Reset AI functions have moved! They can now be found by selecting the stuck unit using F1-10 and opening command menu 6."]];

playerGroup = _playerGroup;

if (isMultiplayer) then {
	// If respawn is enabled add the dynamic team respawn position
	if ((paramsArray select 0) < 3) then {
		if ((paramsArray select 1) == 0 OR (paramsArray select 1) == 2) then {
			[] execVM 'sunday_system\player_setup\teamRespawnPos.sqf';			
		};		
		diag_log format ["DRO: Respawn time = %1", respawnTime];
		{		
			respawnTime remoteExec ["setPlayerRespawnTime", _x];				
		} forEach allPlayers;
	};		
	{
		if (!isPlayer _x) then {		
			// Add eventhandlers to govern respawning in MP games				
			if ((paramsArray select 0) == 3) then {
				// Respawn disabled
				[_x, ["respawn", {
					_unit = (_this select 0);				
					deleteVehicle _unit
				}]] remoteExec ["addEventHandler", _x, true];
			} else {
				// Respawn enabled
				[_x, ["killed", {[(_this select 0)] execVM "sunday_system\player_setup\fakeRespawn.sqf"}]] remoteExec ["addEventHandler", _x];
				[_x, ["respawn", {
					_unit = (_this select 0);				
					deleteVehicle _unit
				}]] remoteExec ["addEventHandler", _x];				
			};			
		};		
		// Add player's side to spectator whitelist
		_x setVariable ["WhitelistedSides", [playersSideCfgGroups], true];		
		_x setVariable ["AllowFreeCamera", true, true];
		_x setVariable ["AllowAi", true, true];
		_x setVariable ["Allow3PPCamera", true, true];
		_x setVariable ["ShowFocusInfo", true, true];
		_x setVariable ["ShowCameraButtons", true, true];
		// Add respawn weapon loss failsafes		
		_x setVariable ["respawnLoadout", (getUnitLoadout _x), true];
		_x setVariable ["respawnPWeapon", [(primaryWeapon  _x), primaryWeaponItems _x], true];
	} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
};

// Lights, backpacks, reset action, unit traits, force allowDamage to account for any setup issues
{
	_thisUnit = _x;
	diag_log format ["DRO: Setting allowDamage for %1 to true", _thisUnit];
	[_thisUnit, true] remoteExec ["allowDamage", _thisUnit];	
	
	_thisUnit enableGunLights "forceon";
	
	if (!isPlayer _thisUnit) then {
		[_thisUnit] call sun_addResetAction;
	};	
	
	[] remoteExec ["sun_backpackFix", _thisUnit];
	
	[_thisUnit, ["Medic", true]] remoteExec ["setUnitTrait", _thisUnit];	
	[_thisUnit, ["engineer", true]] remoteExec ["setUnitTrait", _thisUnit];	
	[_thisUnit, ["explosiveSpecialist", true]] remoteExec ["setUnitTrait", _thisUnit];	
	[_thisUnit, ["UAVHacker", true]] remoteExec ["setUnitTrait", _thisUnit];	
	
	
} forEach (units (grpNetId call BIS_fnc_groupFromNetId));

// Add friendly unit trigger to leader
if (missionPreset == 3) then {
	[(leader (grpNetId call BIS_fnc_groupFromNetId)), "DRO_Friendly_Engage"] remoteExec ["BIS_fnc_addCommMenuItem", (leader (grpNetId call BIS_fnc_groupFromNetId))];
};

// Set player callsign and icon
_iconSide = switch (playersSide) do {
	case west: {"b_inf"};
	case east: {"o_inf"};
	case resistance: {"n_inf"};
	default {"b_inf"};
};	
(grpNetId call BIS_fnc_groupFromNetId) addGroupIcon [_iconSide, [0, 0]];
(grpNetId call BIS_fnc_groupFromNetId) setGroupIconParams [colorPlayers, playerCallsign, 1, true, true, colorPlayers];
(grpNetId call BIS_fnc_groupFromNetId) setGroupIdGlobal [playerCallsign];

// Remove arsenal backdrop objects
sleep 2;
_backdropList = (getPos logicStartPos) nearObjects 20;
_backdropList = _backdropList - (units(grpNetId call BIS_fnc_groupFromNetId));
{
	if !(_x isKindOf "Module_F") then {
		deleteVehicle _x;
	};		
} forEach _backdropList;

if (reviveDisabled < 3) then {
	diag_log "DRO: Revive enabled";
	_reviveHandle = [(grpNetId call BIS_fnc_groupFromNetId)] execVM "sunday_revive\initRevive.sqf";
	waitUntil {scriptDone _reviveHandle};
};

if (stealthEnabled == 1) then {
	[] execVM "sunday_system\stealth.sqf";	
}; 
/*
// If MCC4 is present re-initialise it for new players
if (isClass (configFile >> "CfgPatches" >> "mcc_sandbox")) then {
	[] execVM "\mcc_sandbox_mod\init.sqf";
};

// If Zeus is present re-initialise it for new players
if (!isNull _zeus) then {
	(leader(grpNetId call BIS_fnc_groupFromNetId)) assignCurator _zeus;
};
*/
// Chance to reveal some intel at start
if (random 1 > 0.35) then {
	[([1,3] call BIS_fnc_randomInt), false] execVM "sunday_system\intel\revealIntel.sqf";	
};

missionNameSpace setVariable ["playersReady", 1, true];

