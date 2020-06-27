_playerFactions = [playersFaction] + (playersFactionAdv select {count _x > 0});
_enemyFactions = [enemyFaction] + (enemyFactionAdv select {count _x > 0});
_playerFactions = _playerFactions apply {toUpper _x};
_enemyFactions = _enemyFactions apply {toUpper _x};

pInfClasses = [];
pOfficerClasses = [];
pCarClasses = [];
pCarNoTurretClasses = [];
pTankClasses = [];
pArtyClasses = [];
pMortarClasses = [];
pHeliClasses = [];
pPlaneClasses = [];
pShipClasses = [];
pAmmoClasses = [];
pGenericNames = [];
pIdentityTypes = [];
pUAVClasses = [];
pInfClassesForWeights = [];
pInfClassWeights = [];
pCarTurretClasses = [];
pStaticClasses = [];
pAAClasses = [];
pAPCClasses = [];

eInfClasses = [];
eOfficerClasses = [];
eCarClasses = [];
eCarNoTurretClasses = [];
eTankClasses = [];
eArtyClasses = [];
eMortarClasses = [];
eHeliClasses = [];
ePlaneClasses = [];
eShipClasses = [];
eAmmoClasses = [];
eGenericNames = [];
eIdentityTypes = [];
eUAVClasses = [];
eInfClassesForWeights = [];
eInfClassWeights = [];
eCarTurretClasses = [];
eStaticClasses = [];
eAAClasses = [];
eAPCClasses = [];

civClasses = [];
civCarClasses = [];

_pInfClassesUnarmed = [];
_pInfClassesUnarmedForWeights = [];
_pInfClassUnarmedWeights = [];
_pInfEditorSubcats = [];

{
	pInfClassesForWeights pushBack [];
	pInfClassWeights pushBack [];
	_pInfClassesUnarmedForWeights pushBack [];
	_pInfClassUnarmedWeights pushBack [];
	_pInfEditorSubcats pushBack [];
} forEach _playerFactions;

_eInfClassesUnarmed = [];
_eInfClassesUnarmedForWeights = [];
_eInfClassUnarmedWeights = [];
_eInfEditorSubcats = [];

{
	eInfClassesForWeights pushBack [];
	eInfClassWeights pushBack [];
	_eInfClassesUnarmedForWeights pushBack [];
	_eInfClassUnarmedWeights pushBack [];
	_eInfEditorSubcats pushBack [];
} forEach _enemyFactions;

diag_log _playerFactions;
diag_log _enemyFactions;

_cfgVeh = configFile >> "CfgVehicles";
{
	_cfgName = (configName _x);
	_cfgVehName = configFile >> "CfgVehicles" >> _cfgName;
	_thisFac = ((_cfgVeh >> _cfgName >> "faction") call BIS_fnc_GetCfgData);
	_isCivFaction = if (toUpper _thisFac == civFaction)	then {true} else {false};
	_isPlayerFaction = if ((toUpper _thisFac) in _playerFactions) then {true} else {false};
	_isEnemyFaction = if ((toUpper _thisFac) in _enemyFactions) then {true} else {false};	
	if (_isPlayerFaction OR _isEnemyFaction OR _isCivFaction) then {				
		if (_cfgName isKindOf 'Man') then {	
			if (_isPlayerFaction) then {	
				if (count pGenericNames == 0) then {
					pGenericNames = ((_cfgVehName >> "genericNames") call BIS_fnc_GetCfgData);
					pIdentityTypes = ((_cfgVehName >> "identityTypes") call BIS_fnc_GetCfgData);					
				};
			} else {
				if (_isEnemyFaction) then {
					if (count eGenericNames == 0) then {
						eGenericNames = ((_cfgVehName >> "genericNames") call BIS_fnc_GetCfgData);
						eIdentityTypes = ((_cfgVehName >> "identityTypes") call BIS_fnc_GetCfgData);
					};
				};
			};	
			if ((["officer", _cfgName, false] call BIS_fnc_inString) || (["commander", _cfgName, false] call BIS_fnc_inString)) then {
				if (_isPlayerFaction) then {
					pOfficerClasses pushBack _cfgName;
				};
				if (_isEnemyFaction) then {
					eOfficerClasses pushBack _cfgName;
				};
			} else {					
				if (						
					(["driver", _cfgName, false] call BIS_fnc_inString) ||
					(["diver", _cfgName, false] call BIS_fnc_inString) ||
					(["story", _cfgName, false] call BIS_fnc_inString) ||
					(["competitor", _cfgName, false] call BIS_fnc_inString) ||
					(["survivor", _cfgName, false] call BIS_fnc_inString) ||
					(["unarmed", _cfgName, false] call BIS_fnc_inString) ||
					(["protagonist", _cfgName, false] call BIS_fnc_inString) ||						
					(["_vr_", _cfgName, false] call BIS_fnc_inString) ||
					(["story", ((_cfgVehName >> "editorSubcategory") call BIS_fnc_GetCfgData), false] call BIS_fnc_inString)						
				) then {
				
				} else {
					if (_isCivFaction) exitWith {
						//diag_log (count ((_cfgVehName >> "weapons") call BIS_fnc_GetCfgData));
						if ((count ((_cfgVehName >> "weapons") call BIS_fnc_GetCfgData)) <= 2) then {							
							civClasses pushBack _cfgName;
						};
					};
					_pFactionIndex = if (_isPlayerFaction) then {							
						(_playerFactions find (toUpper ((_cfgVehName >> "faction") call BIS_fnc_GetCfgData)))
					};
					_eFactionIndex = if (_isEnemyFaction) then {
						(_enemyFactions find (toUpper ((_cfgVehName >> "faction") call BIS_fnc_GetCfgData)))
					};					
					if ((count ((_cfgVehName >> "weapons") call BIS_fnc_GetCfgData) <= 2)) then {
						if (_isPlayerFaction) then {
							_pInfClassesUnarmed pushBack _cfgName;
							(_pInfClassesUnarmedForWeights select _pFactionIndex) pushBack _cfgName;
							(_pInfClassUnarmedWeights select _pFactionIndex) pushBack 0.5;
						};
						if (_isEnemyFaction) then {
							_eInfClassesUnarmed pushBack _cfgName;
							(_eInfClassesUnarmedForWeights select _eFactionIndex) pushBack _cfgName;
							(_eInfClassUnarmedWeights select _eFactionIndex) pushBack 0.5;
						};
					} else {
						if (_isPlayerFaction) then {
							pInfClasses pushBack _cfgName;
						};
						if (_isEnemyFaction) then {
							eInfClasses pushBack _cfgName;
						};							
						_thisWeight = 0;							
						// Check config 'role' value
						_thisRole = ((_cfgVehName >> "role") call BIS_fnc_GetCfgData);
						switch (_thisRole) do {
							case "Crewman": {_thisWeight = 0};
							case "Assistant": {_thisWeight = 0.15};
							case "CombatLifeSaver": {_thisWeight = 0.25};
							case "Grenadier": {_thisWeight = 0.25};
							case "MachineGunner": {_thisWeight = 0.25};
							case "Marksman": {_thisWeight = 0.1};
							case "MissileSpecialist": {_thisWeight = 0.15};
							case "Rifleman": {_thisWeight = 1};
							case "Sapper": {_thisWeight = 0.15};
							case "SpecialOperative": {_thisWeight = 0.15};
							default {_thisWeight = 0.5};
						};						
						// Overwrite weight if certain words appear in unit name
						_thisDisplayName = ((_cfgVehName >> "displayName") call BIS_fnc_GetCfgData);
						{
							if (([(_x select 0), _thisDisplayName, false] call BIS_fnc_inString)) exitWith {
								_thisWeight = (_x select 1);
							};
						} forEach [
							["medic", 0.25],
							["grenadier", 0.25],
							["machine", 0.25],
							["auto", 0.25],
							["sniper", 0.1],
							["marksman", 0.1],
							["spotter", 0.1],
							["sharp", 0.1],
							["asst.", 0.15],
							["missile", 0.15],
							["AT", 0.15],
							["AA", 0.15],
							["special", 0.15],
							["leader", 0.15],
							["gunner", 0.15],
							["ammo", 0.15],
							["uav", 0.1],
							["engineer", 0.1],
							["pilot", 0],
							["crew", 0]
						];						
						if (_isPlayerFaction) then {
							(pInfClassesForWeights select _pFactionIndex) pushBack _cfgName;
							(pInfClassWeights select _pFactionIndex) pushBack _thisWeight;
							(_pInfEditorSubcats select _pFactionIndex) pushBackUnique ((_cfgVehName >> "editorSubcategory") call BIS_fnc_GetCfgData);
						};
						if (_isEnemyFaction) then {
							(eInfClassesForWeights select _eFactionIndex) pushBack _cfgName;
							(eInfClassWeights select _eFactionIndex) pushBack _thisWeight;
							(_eInfEditorSubcats select _eFactionIndex) pushBackUnique ((_cfgVehName >> "editorSubcategory") call BIS_fnc_GetCfgData);
						};
					};
				};					
			};
		} else {
			_checkSubcats = true;
			if (_cfgName isKindOf 'Car') then {
				if (_isCivFaction) exitWith {
					civCarClasses pushBack _cfgName;					
				};
				_edSubcat = ((_cfgVehName >> "editorSubcategory") call BIS_fnc_GetCfgData);
				if (!isNil "_edSubcat") then {
					if (_edSubcat == "EdSubcat_Drones") then {
						
					} else {
						if (_edSubcat == "EdSubcat_APCs") then {
							if (_isPlayerFaction) then {
								pAPCClasses pushBackUnique _cfgName;								
							};
							if (_isEnemyFaction) then {
								eAPCClasses pushBackUnique _cfgName;								
							};
						} else {
							if (_isPlayerFaction) then {
								pCarClasses pushBackUnique _cfgName;
								if (count ([_cfgName, false] call BIS_fnc_allTurrets) > 0) then {
									pCarTurretClasses pushBackUnique _cfgName;
								} else {
									pCarNoTurretClasses pushBackUnique _cfgName;
								};								
							};
							if (_isEnemyFaction) then {
								eCarClasses pushBackUnique _cfgName;
								if (count ([_cfgName, false] call BIS_fnc_allTurrets) > 0) then {
									eCarTurretClasses pushBackUnique _cfgName;
								} else {
									eCarNoTurretClasses pushBackUnique _cfgName;
								};								
							};
						};
						_checkSubcats = false;
						/*
						{
							if ((configName _x) == "Turrets") then {						
								_turretCfg = ([(_cfgVehName >> "Turrets"), 0, true] call BIS_fnc_returnChildren);						
								if (count _turretCfg > 0) then {									
									_noTurret = 0;
									{										
										if (((_cfgVehName >> "Turrets" >> (configName _x) >> "gun") call BIS_fnc_GetCfgData) == "mainGun") then {
											_noTurret = 1;
											if (_isPlayerFaction) then {
												pCarTurretClasses pushBackUnique _cfgName;
											};
											if (_isEnemyFaction) then {
												eCarTurretClasses pushBackUnique _cfgName;
											};
										};
									} forEach _turretCfg;
									if (_noTurret == 0) then {
										if (_isPlayerFaction) then {
											pCarNoTurretClasses pushBackUnique _cfgName;
										};
										if (_isEnemyFaction) then {
											eCarNoTurretClasses pushBackUnique _cfgName;
										};
									};
								} else {
									if (_isPlayerFaction) then {
										pCarNoTurretClasses pushBackUnique _cfgName;
									};
									if (_isEnemyFaction) then {
										eCarNoTurretClasses pushBackUnique _cfgName;
									};
								};
							};
							
						} forEach ([(configFile >> "CfgVehicles" >> _cfgName), 0, true] call BIS_fnc_returnChildren);
						*/
					};
				};								
			} else {
				if (_cfgName isKindOf 'Tank') then {
					_edSubcat = ((_cfgVehName >> "editorSubcategory") call BIS_fnc_GetCfgData);
					if (
						!(["artillery", ((_cfgVehName >> "editorSubcategory") call BIS_fnc_GetCfgData), false] call BIS_fnc_inString) &&
						!(["aa", ((_cfgVehName >> "editorSubcategory") call BIS_fnc_GetCfgData), false] call BIS_fnc_inString) &&
						!(["drone", ((_cfgVehName >> "editorSubcategory") call BIS_fnc_GetCfgData), false] call BIS_fnc_inString) 
					) then {
						if (_isPlayerFaction) then {
							pTankClasses pushBackUnique _cfgName;
						};
						if (_isEnemyFaction) then {
							eTankClasses pushBackUnique _cfgName;
						};
						_checkSubcats = false;
					};					
				};
			};
			if (_checkSubcats) then {
				_edSubcat = ((_cfgVehName >> "editorSubcategory") call BIS_fnc_GetCfgData);
				if (!isNil "_edSubcat") then {	
					_pVars = [pArtyClasses, pAAClasses, pTankClasses, pTankClasses, pHeliClasses, pPlaneClasses, pShipClasses, pUAVClasses];
					_eVars = [eArtyClasses, eAAClasses, eTankClasses, eTankClasses, eHeliClasses, ePlaneClasses, eShipClasses, eUAVClasses];
					{						
						if ( [_x, ((_cfgVehName >> "editorSubcategory") call BIS_fnc_GetCfgData), false] call BIS_fnc_inString ) exitWith {
							if (_isPlayerFaction) then {
								(_pVars select _forEachIndex) pushBackUnique _cfgName;
							};
							if (_isEnemyFaction) then {
								(_eVars select _forEachIndex) pushBackUnique _cfgName;
							};
						};
					} forEach ["artillery", "aa", "tank", "apc", "helicopter", "plane", "boat", "drone"];					
				};				
				_pVars = [pMortarClasses, pStaticClasses, pStaticClasses, pAmmoClasses];
				_eVars = [eMortarClasses, eStaticClasses, eStaticClasses, eAmmoClasses];
				{						
					if (_cfgName isKindOf 'StaticMortar') exitWith {
						if (_isPlayerFaction) then {
							(_pVars select _forEachIndex) pushBackUnique _cfgName;
						};
						if (_isEnemyFaction) then {
							(_eVars select _forEachIndex) pushBackUnique _cfgName;
						};
					};
				} forEach ["StaticMortar", "StaticMGWeapon", "StaticGrenadeLauncher", "ReammoBox_F"];			
			};
		};
	};
} forEach ("(getNumber (_x >> 'scope') == 2)" configClasses (configFile / "CfgVehicles"));

// Ensure there are officers
if (count pOfficerClasses == 0) then {
	pOfficerClasses = pInfClasses;
};
if (count eOfficerClasses == 0) then {
	eOfficerClasses = eInfClasses;
};

// Ensure there are mortars
if (count pMortarClasses == 0) then {
	pMortarClasses = ["B_Mortar_01_F"];
};
if (count eMortarClasses == 0) then {
	eMortarClasses = ["O_Mortar_01_F"];
};

// Check to see if there are a lot of unarmed units, in which case, allow them to be valid
if (count _pInfClassesUnarmed > count pInfClasses) then {
	pInfClasses = pInfClasses + _pInfClassesUnarmed;
	{	
		(pInfClassesForWeights set [_forEachIndex, ((pInfClassesForWeights select _forEachIndex) + (pInfClassesUnarmedForWeights select _forEachIndex))]);	
		(pInfClassWeights set [_forEachIndex, ((pInfClassWeights select _forEachIndex) + (pInfClassUnarmedWeights select _forEachIndex))]);			
	} forEach _playerFactions;
};

if (count _eInfClassesUnarmed > count eInfClasses) then {
	eInfClasses = eInfClasses + _eInfClassesUnarmed;
	{	
		(eInfClassesForWeights set [_forEachIndex, ((eInfClassesForWeights select _forEachIndex) + (eInfClassesUnarmedForWeights select _forEachIndex))]);	
		(eInfClassWeights set [_forEachIndex, ((eInfClassWeights select _forEachIndex) + (eInfClassUnarmedWeights select _forEachIndex))]);			
	} forEach _enemyFactions;
};

diag_log format ["DRO: _pInfEditorSubcats = %1", _pInfEditorSubcats];
diag_log format ["DRO: pInfClassWeights = %1", pInfClassWeights];
diag_log format ["DRO: _eInfEditorSubcats = %1", _eInfEditorSubcats];
diag_log format ["DRO: eInfClassWeights = %1", eInfClassWeights];

// If there are more than one subcategory of infantry units then select one
{
	_thisFactionIndex = _forEachIndex;
	if (count (_pInfEditorSubcats select _thisFactionIndex) > 1) then {
		_chosenClasses = [];
		_chosenWeights = [];
		
		// Check how many units are in a subcategory
		_unavailableSubcats = [];
		_availableSubcats = [];
		_subcatWeights = [];
		{
			_thisSubcat = _x;
			_chosenClasses = [];
			_chosenWeights = [];
						
			for "_i" from 0 to ((count (pInfClassesForWeights select _thisFactionIndex))-1) do {
				_unitSubcat = (((configFile >> "CfgVehicles" >> ((pInfClassesForWeights select _thisFactionIndex) select _i) >> "editorSubcategory")) call BIS_fnc_GetCfgData);
				if (_unitSubcat == _thisSubcat) then {
					_chosenClasses pushBack ((pInfClassesForWeights select _thisFactionIndex) select _i);
					_chosenWeights pushBack ((pInfClassWeights select _thisFactionIndex) select _i);
				};
			};
			
			diag_log format ["Subcat %2 _chosenWeights = %1", _chosenWeights, _thisSubcat];
			
			// Look at weights in this subcategory, if there are none above sniper level then disallow the subcategory
			_allowThisSubcat = false;
			{
				if (_x > 0.1) then {
					_allowThisSubcat = true;
				};
			} forEach _chosenWeights;
			
			if (!_allowThisSubcat) then {
				_unavailableSubcats pushBack _thisSubcat;
			} else {
				_availableSubcats pushBack _thisSubcat;
				_subcatWeights pushBack ((count _chosenClasses)/100);
			};
		} forEach (_pInfEditorSubcats select _thisFactionIndex);
		
		diag_log format ["_availableSubcats = %1", _availableSubcats];
		diag_log format ["_unavailableSubcats = %1", _unavailableSubcats];
		diag_log format ["_subcatWeights = %1", _subcatWeights];	
		
		// Choose a subcategory out of those remaining	
		_chosenSubcat = [_availableSubcats, _subcatWeights] call BIS_fnc_selectRandomWeighted;
		diag_log format ["_chosenSubcat = %1", _chosenSubcat];
		
		// Add units with that subcategory to the chosen units
		_chosenClasses = [];
		_chosenWeights = [];
		for "_i" from 0 to ((count (pInfClassesForWeights select _thisFactionIndex))-1) do {
			_thisSubcat = (((configFile >> "CfgVehicles" >> ((pInfClassesForWeights select _thisFactionIndex) select _i) >> "editorSubcategory")) call BIS_fnc_GetCfgData);
			if (_thisSubcat == _chosenSubcat) then {
				_chosenClasses pushBack ((pInfClassesForWeights select _thisFactionIndex) select _i);
				_chosenWeights pushBack ((pInfClassWeights select _thisFactionIndex) select _i);
			};		
		};
		pInfClassesForWeights set [_thisFactionIndex, _chosenClasses];
		pInfClassWeights set [_thisFactionIndex, _chosenWeights];		
	};
} forEach _playerFactions;


{
	_thisFactionIndex = _forEachIndex;
	if (count (_eInfEditorSubcats select _thisFactionIndex) > 1) then {
		_chosenClasses = [];
		_chosenWeights = [];
		
		// Check how many units are in a subcategory
		_unavailableSubcats = [];
		_availableSubcats = [];
		_subcatWeights = [];
		{
			_thisSubcat = _x;
			_chosenClasses = [];
			_chosenWeights = [];
						
			for "_i" from 0 to ((count (eInfClassesForWeights select _thisFactionIndex))-1) do {
				_unitSubcat = (((configFile >> "CfgVehicles" >> ((eInfClassesForWeights select _thisFactionIndex) select _i) >> "editorSubcategory")) call BIS_fnc_GetCfgData);
				if (_unitSubcat == _thisSubcat) then {
					_chosenClasses pushBack ((eInfClassesForWeights select _thisFactionIndex) select _i);
					_chosenWeights pushBack ((eInfClassWeights select _thisFactionIndex) select _i);
				};
			};
			
			diag_log format ["Subcat %2 _chosenWeights = %1", _chosenWeights, _x];
			
			// Look at weights in this subcategory, if there are none above sniper level then disallow the subcategory
			_allowThisSubcat = false;
			{
				if (_x > 0.1) then {
					_allowThisSubcat = true;
				};
			} forEach _chosenWeights;
			
			if (!_allowThisSubcat) then {
				_unavailableSubcats pushBack _x;
			} else {
				_availableSubcats pushBack _x;
				_subcatWeights pushBack ((count _chosenClasses)/100);
			};
		} forEach (_eInfEditorSubcats select _thisFactionIndex);
		
		diag_log format ["_availableSubcats = %1", _availableSubcats];
		diag_log format ["_unavailableSubcats = %1", _unavailableSubcats];
		diag_log format ["_subcatWeights = %1", _subcatWeights];	
		
		// Choose a subcategory out of those remaining	
		_chosenSubcat = [_availableSubcats, _subcatWeights] call BIS_fnc_selectRandomWeighted;
		diag_log format ["_chosenSubcat = %1", _chosenSubcat];
		
		// Add units with that subcategory to the chosen units
		_chosenClasses = [];
		_chosenWeights = [];
		for "_i" from 0 to ((count (eInfClassesForWeights select _thisFactionIndex))-1) do {
			_thisSubcat = (((configFile >> "CfgVehicles" >> ((eInfClassesForWeights select _thisFactionIndex) select _i) >> "editorSubcategory")) call BIS_fnc_GetCfgData);
			if (_thisSubcat == _chosenSubcat) then {
				_chosenClasses pushBack ((eInfClassesForWeights select _thisFactionIndex) select _i);
				_chosenWeights pushBack ((eInfClassWeights select _thisFactionIndex) select _i);
			};		
		};
		eInfClassesForWeights set [_thisFactionIndex, _chosenClasses];
		eInfClassWeights set [_thisFactionIndex, _chosenWeights];		
	};
} forEach _enemyFactions;

diag_log "DRO: Beginning DLC checks";

civCarClasses = civCarClasses - ["C_Kart_01_F", "C_Kart_01_Blu_F", "C_Kart_01_Fuel_F", "C_Kart_01_Red_F", "C_Kart_01_Vrana_F"];

if (civFaction == "CIV_F") then {
	private _worldName = worldName;
	if !(_worldName in ["Stratis","Altis","Malden","Tanoa","Enoch"]) then {_worldName = "Other"};
	civClasses = getArray (configfile >> "CfgVehicles" >> "ModuleCivilianPresence_F" >> "UnitTypes" >> _worldName);
};

_unavailableDLCS = getDLCS 2;
_unavailableVehicles = [];
{	
	{
		_veh = _x createVehicle [0,0,0];
		_appID = getObjectDLC _veh;		
		if (!isNil "_appID") then {			
			if (_appID in _unavailableDLCS) then {
				_unavailableVehicles pushBack _x;
			};
		};
		deleteVehicle _veh;
	} forEach _x;
} forEach [pCarClasses, pCarNoTurretClasses, pCarTurretClasses, pTankClasses, pHeliClasses, pPlaneClasses, pUAVClasses, pAPCClasses, eCarClasses, eCarNoTurretClasses, eCarTurretClasses, eTankClasses, eHeliClasses, ePlaneClasses, eUAVClasses, eAPCClasses];

diag_log format ["DRO: Unavailable DLC vehicles = %1", _unavailableVehicles];	
if (count _unavailableVehicles > 0) then {	
	pCarClasses = pCarClasses - _unavailableVehicles;
	pCarNoTurretClasses = pCarNoTurretClasses - _unavailableVehicles;
	pCarTurretClasses = pCarTurretClasses - _unavailableVehicles;
	pTankClasses = pTankClasses - _unavailableVehicles;
	pHeliClasses = pHeliClasses - _unavailableVehicles;
	pPlaneClasses = pPlaneClasses - _unavailableVehicles;
	pUAVClasses = pUAVClasses - _unavailableVehicles;
	pAPCClasses = pAPCClasses - _unavailableVehicles;
	eCarClasses = eCarClasses - _unavailableVehicles;
	eCarNoTurretClasses = eCarNoTurretClasses - _unavailableVehicles;
	eCarTurretClasses = eCarTurretClasses - _unavailableVehicles;
	eTankClasses = eTankClasses - _unavailableVehicles;
	eHeliClasses = eHeliClasses - _unavailableVehicles;
	ePlaneClasses = ePlaneClasses - _unavailableVehicles;
	eUAVClasses = eUAVClasses - _unavailableVehicles;
	eAPCClasses = eAPCClasses - _unavailableVehicles;
};
diag_log "DRO: Completed DLC checks";