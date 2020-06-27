diag_log "DRO: Main DRO script started";

#include "sunday_system\fnc_lib\sundayFunctions.sqf";
#include "sunday_system\fnc_lib\droFunctions.sqf";
#include "sunday_revive\reviveFunctions.sqf";
#include "sunday_system\generate_enemies\generateEnemiesFunctions.sqf";

[] execVM "sunday_system\fnc_lib\objectsLibrary.sqf";

diag_log "DRO: Libraries included";

respawnTime = switch (paramsArray select 0) do {
	case 0: {20};
	case 1: {45};
	case 2: {90};
	case 3: {nil};
};
publicVariable "respawnTime";

diag_log "DRO: Waiting for player count";

waitUntil {(count ([] call BIS_fnc_listPlayers) > 0)};
_topUnit = (([] call BIS_fnc_listPlayers) select 0);

{
	[_x, false] remoteExec ["allowDamage", _x];
	[_x, "ALL"] remoteExec ["disableAI", _x];
} forEach units(group _topUnit);
topUnit = _topUnit;
publicVariable "topUnit";

diag_log format ["DRO: topUnit = %1", topUnit];

[(profileNamespace getVariable ["DRO_timeOfDay", 0])] call sun_randomTime;

playersFaction = "";
enemyFaction = "";
civFaction = "";
pFactionIndex = 1;
publicVariable "pFactionIndex";
playersFactionAdv = [0,0,0];
publicVariable "playersFactionAdv";
eFactionIndex = 2;
publicVariable "eFactionIndex";
enemyFactionAdv = [0,0,0];
publicVariable "enemyFactionAdv";
cFactionIndex = 0;
publicVariable "cFactionIndex";
customPos = [];
publicVariable "customPos";
playerGroup = [];
civTrue = false;
startVehicles = ["", ""];
publicVariable "startVehicles";
firstLobbyOpen = true;
publicVariable "firstLobbyOpen";
enemyIntelMarkers = [];
publicVariable "enemyIntelMarkers";

extractLeave = false;
publicVariable "extractLeave";
extractHeliUsed = false;
reinforceChance = 0.5;
stealthActive = false;
enemyCommsActive = true;
hostileCivsEnabled = if (random 1 > 0.5) then {true} else {false};

civDeathCounter = 0;
publicVariable "civDeathCounter";
hostileCivilians = [];
publicVariable "hostileCivilians";
neutralTasksChosen = false;
noNeutralTasksChosen = false;
taskCreationInProgress = false;
insertType = 0;
friendlySquad = nil;
reactiveChance = random 1;
holdAO = [];
droGroupIconsVisible = false;
publicVariable "droGroupIconsVisible";
dro_messageStack = [];
enemyPosCollection = [];

diag_log "DRO: Variables defined";
diag_log "DRO: Compiling scripts";

fnc_generateAO = compile preprocessFile "sunday_system\generate_ao\generateAO.sqf";
fnc_generateAOLoc = compile preprocessFile "sunday_system\generate_ao\generateAOLocation.sqf";
fnc_generateCampsite = compile preprocessFile "sunday_system\generate_ao\generateCampsite.sqf";

fnc_selectObjective = compile preprocessFile "sunday_system\objectives\objSelect.sqf";
fnc_selectReactiveObjective = compile preprocessFile "sunday_system\objectives\selectReactiveTask.sqf";
fnc_defineFactionClasses = compile preprocessFile "sunday_system\fnc_lib\defineFactionClasses.sqf";

fnc_generateRoadblock = compile preprocessFile "sunday_system\generate_enemies\generateRoadblock.sqf";
fnc_generateBunker = compile preprocessFile "sunday_system\generate_enemies\generateBunker.sqf";
fnc_generateBarrier = compile preprocessFile "sunday_system\generate_enemies\generateBarrier.sqf";
fnc_generateEmplacement = compile preprocessFile "sunday_system\generate_enemies\generateEmplacement.sqf";
fnc_spawnEnemyCompound = compile preprocessFile "sunday_system\generate_enemies\generateCompound.sqf";

diag_log "DRO: Compiling scripts finished";

blackList = [];

_musicIntroStings = [
	"EventTrack02_F_EPB",
	"EventTrack02a_F_EPB",
	"EventTrack01a_F_EPA"
];
musicIntroSting = selectRandom _musicIntroStings;
publicVariable "musicIntroSting";

diag_log "DRO: Music sting chosen";

// *****
// EXTRACT FACTION DATA
// *****

// Check for factions that have units
_availableFactions = [];
availableFactionsData = [];
availableFactionsDataNoInf = [];
_unavailableFactions = [];
//_factionsWithUnits = [];
_factionsWithNoInf = [];
_factionsWithUnitsFiltered = [];
// Record all factions with valid vehicles
{
	if (isNumber (configFile >> "CfgVehicles" >> (configName _x) >> "scope")) then {
		if (((configFile >> "CfgVehicles" >> (configName _x) >> "scope") call BIS_fnc_GetCfgData) == 2) then {
			_factionClass = ((configFile >> "CfgVehicles" >> (configName _x) >> "faction") call BIS_fnc_GetCfgData);
			//_factionsWithUnits pushBackUnique _factionClass;		
			if ((configName _x) isKindOf "Man") then {
				_index = ([_factionsWithUnitsFiltered, _factionClass] call BIS_fnc_findInPairs);
				if (_index == -1) then {
					_factionsWithUnitsFiltered pushBack [_factionClass, 1];
				} else {
					_factionsWithUnitsFiltered set [_index, [((_factionsWithUnitsFiltered select _index) select 0), ((_factionsWithUnitsFiltered select _index) select 1)+1]];
				}; 
			};		
		};
	};
} forEach ("(configName _x) isKindOf 'AllVehicles'" configClasses (configFile / "CfgVehicles"));
// Filter factions with 1 or less infantry units
/*
{
	_factionsWithUnitsFiltered pushBack [_x, 0];
} forEach _factionsWithUnits;
{		
	_index = [_factionsWithUnitsFiltered, ((configFile >> "CfgVehicles" >> (configName _x) >> "faction") call BIS_fnc_GetCfgData)] call BIS_fnc_findInPairs; 
	if (_index > -1) then {		
		_factionsWithUnitsFiltered set [_index, [((_factionsWithUnitsFiltered select _index) select 0), ((_factionsWithUnitsFiltered select _index) select 1)+1]];
	};
} forEach ("(configName _x) isKindOf 'Man'" configClasses (configFile / "CfgVehicles"));
*/
diag_log format ["DRO: _factionsWithUnitsFiltered = %1", _factionsWithUnitsFiltered];

// Filter out factions that have no vehicles
{
	_thisFaction = (_x select 0);
	_thisSideNum = ((configFile >> "CfgFactionClasses" >> _thisFaction >> "side") call BIS_fnc_GetCfgData);
	//diag_log format ["DRO: Fetching faction info for %1", _thisFaction];	
	//diag_log format ["DRO: faction sideNum = %1", _thisSideNum];
	if (!isNil "_thisSideNum") then {
		if (typeName _thisSideNum == "TEXT") then {
			if ((["west", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 1;
			};
			if ((["east", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 0;
			};
			if ((["guer", _thisSideNum, false] call BIS_fnc_inString) || (["ind", _thisSideNum, false] call BIS_fnc_inString)) then {
				_thisSideNum = 2;
			};
		};	
		
		if (typeName _thisSideNum == "SCALAR") then {
			if (_thisSideNum <= 3 && _thisSideNum > -1) then {
					
				_thisFactionName = ((configFile >> "CfgFactionClasses" >> _thisFaction >> "displayName") call BIS_fnc_GetCfgData);			
				_thisFactionFlag = ((configfile >> "CfgFactionClasses" >> _thisFaction >> "flag") call BIS_fnc_GetCfgData);
				
				if ((_x select 1) <= 1) then {
					if (!isNil "_thisFactionFlag") then {
						availableFactionsDataNoInf pushBack [_thisFaction, _thisFactionName, _thisFactionFlag, _thisSideNum];
					} else {
						availableFactionsDataNoInf pushBack [_thisFaction, _thisFactionName, "", _thisSideNum];
					};
				} else {				
					if (!isNil "_thisFactionFlag") then {
						availableFactionsData pushBack [_thisFaction, _thisFactionName, _thisFactionFlag, _thisSideNum];
					} else {
						availableFactionsData pushBack [_thisFaction, _thisFactionName, "", _thisSideNum];
					};
				};
						
			};	
		};
	};
} forEach _factionsWithUnitsFiltered;

publicVariable "availableFactionsData";
publicVariable "availableFactionsDataNoInf";

{
	diag_log format ["DRO: availableFactionsData %2: %1", _x, _forEachIndex];
} forEach availableFactionsData;
{
	diag_log format ["DRO: availableFactionsDataNoInf %2: %1", _x, _forEachIndex];
} forEach availableFactionsDataNoInf;

missionNameSpace setVariable ["factionDataReady", 1, true];
diag_log "DRO: factionDataReady set";

// Initialise potential AO markers
[] execVM "sunday_system\generate_ao\initAO.sqf";
diag_log "DRO: AO markers initialised";

// *****
// PLAYERS SETUP
// *****

diag_log "DRO: Waiting for factions to be chosen by host";
waitUntil {(missionNameSpace getVariable ["factionsChosen", 0]) == 1};
diag_log "DRO: Factions chosen";

// Disable dynamic simulation if desired
if (dynamicSim == 1) then {
	enableDynamicSimulationSystem false;
};

if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then {	
	if (!isNil "ace_medical_enableRevive") then {
		if (ace_medical_enableRevive > 0) then {
			reviveDisabled = 3;
			publicVariable "reviveDisabled";
		};
	};
};

// Get player faction
playersFactionName = (configFile >> "CfgFactionClasses" >> playersFaction >> "displayName") call BIS_fnc_GetCfgData;
_playerSideNum = (configFile >> "CfgFactionClasses" >> playersFaction >> "side") call BIS_fnc_GetCfgData;
playersSide = [_playerSideNum] call sun_getCfgSide;
playersSideCfgGroups = "West";
switch (playersSide) do {
	case east: {		
		playersSideCfgGroups = "East";		
	};
	case west: {		
		playersSideCfgGroups = "West";		
	};
	case resistance: {		
		playersSideCfgGroups = "Indep";		
	};
	case civilian: {
		playersSide = civilian
	};
};
publicVariable "playersSide";
publicVariable "playersSideCfgGroups";
diag_log format ["DRO: playersSide = %1, playersFaction = %2", playersSide, playersFaction];

diag_log "DRO: Define player group";
playerGroup = (units(group _topUnit));
DROgroupPlayers = (group _topUnit);
groupLeader = leader DROgroupPlayers;
callsigns = ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Lima", "Kilo", "Viper", "Scorpion", "Hunter"];
playerCallsign = [callsigns] call sun_selectRemove; 
publicVariable "playerCallsign";

grpNetId = group _topUnit call BIS_fnc_netId;
publicVariable "grpNetId";
diag_log grpNetId;

publicVariable "playerGroup";
publicVariable "DROgroupPlayers";
publicVariable "groupLeader";

diag_log format ["DRO: grpNetId = %1", grpNetId];

// Keep group name assigned throughout setup process
/*
[] spawn {
	while {(missionNameSpace getVariable ["playersReady", 0] == 0)} do {	
		if (isNull (grpNetId call BIS_fnc_groupFromNetId)) then {
			grpNetId = (group(([] call BIS_fnc_listPlayers) select 0)) call BIS_fnc_netId;
			publicVariable "grpNetId";
		};
	};
};
*/
//unitDirs = [];
{
	if (!isNull _x) then {
		_x setVariable ["startDir", (getDir _x), true];
		//unitDirs set [_forEachIndex, (getDir _x)];
	};
	removeFromRemainsCollector [_x];
	diag_log format ["DRO: %1 startDir set and removed from remains collector", _x];
} forEach playerGroup;
//publicVariable "unitDirs";

// Prepare data for player lobby
_scriptStartTime = time;
[((findDisplay 888888) displayCtrl 8889), "EXTRACTING FACTION DATA"] remoteExecCall ["ctrlSetText", 0];
diag_log "DRO: Beginning faction extraction";
[] call fnc_defineFactionClasses;

DROgroupPlayers = (group _topUnit);

publicVariable "pCarClasses";
publicVariable "pTankClasses";
publicVariable "pHeliClasses";
publicVariable "pMortarClasses";
publicVariable "pUAVClasses";
publicVariable "pArtyClasses";

enemyGVPool = [];
if (count eCarNoTurretClasses > 0) then {	
	for "_gv" from 1 to ([2,3] call BIS_fnc_randomInt) step 1 do {
		enemyGVPool pushBack (selectRandom eCarNoTurretClasses);
	};	
};
enemyGVTPool = [];
if (count eCarTurretClasses > 0) then {
	enemyGVTPool pushBack (selectRandom eCarTurretClasses);	
};
enemyHeliPool = [];
if (count eHeliClasses > 0) then {	
	for "_h" from 1 to ([1,3] call BIS_fnc_randomInt) step 1 do {
		enemyHeliPool pushBack (selectRandom eHeliClasses);
	};	
};

// Get CAS options
availableCASClasses = [];
if (count pHeliClasses > 0 || count pPlaneClasses > 0) then {	
	{
		_availableSupportTypes = (configfile >> "CfgVehicles" >> _x >> "availableForSupportTypes") call BIS_fnc_GetCfgData;	
		if ("CAS_Bombing" in _availableSupportTypes) then {			
			availableCASClasses pushBack _x;
		};
		if ("CAS_Heli" in _availableSupportTypes) then {			
			availableCASClasses pushBack _x;
		};
	} forEach (pHeliClasses + pPlaneClasses);
};
publicVariable "availableCASClasses";

_pInfGroups = [];
_playersFaction = playersFaction;
if (playersFaction == "BLU_G_F") then {_playersFaction = "Guerilla"};
if (playersFaction == "BLU_GEN_F") then {_playersFaction = "Gendarmerie"};
{	
	_thisCategory = _x;
	{
		_thisGroup = _x;
		if (
			!(["diver", (configName _thisGroup)] call BIS_fnc_inString) &&
			!(["support", (configName _thisGroup)] call BIS_fnc_inString)
		) then {
			_save = true;
			{			
				_vehicle = ((_x >> "vehicle") call BIS_fnc_getCfgData);
				if !(_vehicle isKindOf "Man") then {_save = false};
			} forEach ([_thisGroup] call BIS_fnc_returnChildren);
			if (_save) then {_pInfGroups pushBack [_thisGroup, ((_thisGroup >> "name") call BIS_fnc_getCfgData)]};
		};
	} forEach ([_thisCategory] call BIS_fnc_returnChildren);
} forEach ([configfile >> "CfgGroups" >> playersSideCfgGroups >> _playersFaction] call BIS_fnc_returnChildren);
//diag_log format ["DRO: _pInfGroups: %1", _pInfGroups];

_pInfGroups8 = [];
_pInfGroupsNon8 = [];
_startingLoadoutGroup = [];

// Use sniper preset classes
if (missionPreset == 2) then {
	_spotterClasses = [];
	_sniperClasses = [];	
	{
		_thisClass = _x;
		_thisRole = ((configFile >> "CfgVehicles" >> _thisClass >> "role") call BIS_fnc_GetCfgData);
		switch (_thisRole) do {		
			case "Marksman": {_sniperClasses pushBackUnique _thisClass};			
			case "SpecialOperative": {_spotterClasses pushBackUnique _thisClass};
			default {};
		};				
		_thisDisplayName = ((configFile >> "CfgVehicles" >> _thisClass >> "displayName") call BIS_fnc_GetCfgData);		
		{			
			if (([_x, _thisDisplayName, false] call BIS_fnc_inString)) exitWith {
				_sniperClasses pushBackUnique _thisClass;
			};
		} forEach ["sniper", "marksman"];
		if ((["spotter", _thisDisplayName, false] call BIS_fnc_inString)) exitWith {
			_spotterClasses pushBackUnique _thisClass;
		};		
	} forEach pInfClasses;
	if (count _spotterClasses > 0) then {_startingLoadoutGroup set [1, (selectRandom _spotterClasses)]} else {
		if (count _sniperClasses > 0) then {_startingLoadoutGroup set [1, (selectRandom _sniperClasses)]};
	};
	if (count _sniperClasses > 0) then {_startingLoadoutGroup set [0, (selectRandom _sniperClasses)]};
}; 

if (count _startingLoadoutGroup == 0) then {
	{
		if (count ([(_x select 0)] call BIS_fnc_returnChildren) >= 8) then {		
			_pInfGroups8 pushBack (_x select 0);	
		} else {
			_pInfGroupsNon8 pushBack (_x select 0);
		};
	} forEach _pInfGroups;
	//diag_log format ["DRO: _pInfGroups8: %1", _pInfGroups8];

	if (count _pInfGroups8 > 0) then {
		_chosenGroup = selectRandom _pInfGroups8;
		{
			_startingLoadoutGroup pushBack ((_x >> "vehicle") call BIS_fnc_getCfgData);
		} forEach ([_chosenGroup] call BIS_fnc_returnChildren);
	} else {
		if (count _pInfGroupsNon8 > 0) then {
			_chosenGroup = selectRandom _pInfGroupsNon8;
			{
				_startingLoadoutGroup pushBack ((_x >> "vehicle") call BIS_fnc_getCfgData);
			} forEach ([_chosenGroup] call BIS_fnc_returnChildren);
		};
	};
};
//diag_log format ["DRO: _startingLoadoutGroup: %1", _startingLoadoutGroup];

// Define unitList for all selectable lobby classes
unitList = [];
publicVariable "unitList";
{
	_displayName = ((configfile >> "CfgVehicles" >> _x >> "displayName") call BIS_fnc_getCfgData);
	_factionClass = ((configfile >> "CfgVehicles" >> _x >> "faction") call BIS_fnc_getCfgData);
	_factionName = ((configfile >> "CfgFactionClasses" >> _factionClass >> "displayName") call BIS_fnc_getCfgData);	
	unitList pushBackUnique [_x, _displayName, _factionName];
} forEach pInfClasses;
publicVariable "unitList";
/*
{
	diag_log _x;
} forEach unitList;
*/
//diag_log format ["DRO: unitList: %1", unitList];

diag_log format ["DRO: Player side extraction scripts run time = %1", time - _scriptStartTime];
// Init player unit lobby variables
{
	_thisUnitType = if (count _startingLoadoutGroup > 0) then {
		_desiredUnit = if (_forEachIndex < (count _startingLoadoutGroup)) then {
			_startingLoadoutGroup select _forEachIndex			
		} else {
			selectRandom _startingLoadoutGroup
		};		
		//diag_log format ["DRO: _desiredUnit: %1", _desiredUnit];
		
		_index = {
			if ((_x select 0) == _desiredUnit) exitWith {_forEachIndex};
		} forEach unitList;
		
		if (isNil "_index") then {
			selectRandom unitList
		} else {
			unitList select _index	
		};			
	} else {
		selectRandom unitList
	};		
	_x setVariable ['unitLoadoutIDC', (1200 + _forEachIndex), true];
	_x setVariable ['unitArsenalIDC', (1300 + _forEachIndex), true];
	_x setVariable ['unitDeleteIDC', (1500 + _forEachIndex), true];
	_x setVariable ['unitNameTagIDC', (1700 + _forEachIndex), true];
	
	[[_x, _thisUnitType], 'sunday_system\player_setup\switchUnitLoadout.sqf'] remoteExec ["execVM", _x, false];	
	
} forEach playerGroup;

// *****
// ENEMY SETUP
// *****

// Get enemy faction
enemyFactionName = (configFile >> "CfgFactionClasses" >> enemyFaction >> "displayName") call BIS_fnc_GetCfgData;
_enemySideNum = (configFile >> "CfgFactionClasses" >> enemyFaction >> "side") call BIS_fnc_GetCfgData;
sleep 0.01;
enemySide = [_enemySideNum] call sun_getCfgSide;

if (playersSide == enemySide) then {
	enemySide = switch (enemySide) do {
		case east: {resistance};
		default {east};				
	};
	publicVariable "enemySide";	
};

_enemySides = [];
{
	if (count _x > 0) then {
		_thisSide = switch ((configFile >> "CfgFactionClasses" >> _x >> "side") call BIS_fnc_GetCfgData) do {
			case 0: {east};
			case 1: {west};
			case 2: {resistance};
			case 3: {civilian};
		};
		_enemySides pushBack _thisSide;
	};
} forEach [enemyFaction] + enemyFactionAdv;

{
	_thisSide = _x;
	if (_thisSide != playersSide) then {
		{
			if (_thisSide != _x) then {
				if (_x != playersSide) then {
					_thisSide setFriend [_x, 1];
				};
			};
		} forEach _enemySides;
	};
} forEach _enemySides;

publicVariable "enemySide";
diag_log format ["DRO: Enemy side detected as %1", enemySide];

// *****
// DEFINE MARKER COLOURS
// *****

markerColorPlayers = "colorBLUFOR";
colorPlayers = [(profilenamespace getvariable ['Map_BLUFOR_R',0]),(profilenamespace getvariable ['Map_BLUFOR_G',1]),(profilenamespace getvariable ['Map_BLUFOR_B',1]),(profilenamespace getvariable ['Map_BLUFOR_A',0.8])];
switch (playersSide) do {
	case west: {		
		markerColorPlayers = "colorBLUFOR";
		colorPlayers = [(profilenamespace getvariable ['Map_BLUFOR_R',0]),(profilenamespace getvariable ['Map_BLUFOR_G',1]),(profilenamespace getvariable ['Map_BLUFOR_B',1]),(profilenamespace getvariable ['Map_BLUFOR_A',0.8])];
	};
	case east: {		
		markerColorPlayers = "colorOPFOR";
		colorPlayers = [(profilenamespace getvariable ['Map_OPFOR_R',0]),(profilenamespace getvariable ['Map_OPFOR_G',1]),(profilenamespace getvariable ['Map_OPFOR_B',1]),(profilenamespace getvariable ['Map_OPFOR_A',0.8])];
	};
	case resistance: {		
		markerColorPlayers = "colorIndependent";
		colorPlayers = [(profilenamespace getvariable ['Map_Independent_R',0]),(profilenamespace getvariable ['Map_Independent_G',1]),(profilenamespace getvariable ['Map_Independent_B',1]),(profilenamespace getvariable ['Map_Independent_A',0.8])];
	};	
};
publicVariable "markerColorPlayers";

markerColorEnemy = "colorOPFOR";
colorEnemy = [(profilenamespace getvariable ['Map_OPFOR_R',0]),(profilenamespace getvariable ['Map_OPFOR_G',1]),(profilenamespace getvariable ['Map_OPFOR_B',1]),(profilenamespace getvariable ['Map_OPFOR_A',0.8])];
switch (enemySide) do {
	case west: {		
		markerColorEnemy = "colorBLUFOR";
		colorEnemy = [(profilenamespace getvariable ['Map_BLUFOR_R',0]),(profilenamespace getvariable ['Map_BLUFOR_G',1]),(profilenamespace getvariable ['Map_BLUFOR_B',1]),(profilenamespace getvariable ['Map_BLUFOR_A',0.8])];
	};
	case east: {		
		markerColorEnemy = "colorOPFOR";
		colorEnemy = [(profilenamespace getvariable ['Map_OPFOR_R',0]),(profilenamespace getvariable ['Map_OPFOR_G',1]),(profilenamespace getvariable ['Map_OPFOR_B',1]),(profilenamespace getvariable ['Map_OPFOR_A',0.8])];
	};
	case resistance: {		
		markerColorEnemy = "colorIndependent";
		colorEnemy = [(profilenamespace getvariable ['Map_Independent_R',0]),(profilenamespace getvariable ['Map_Independent_G',1]),(profilenamespace getvariable ['Map_Independent_B',1]),(profilenamespace getvariable ['Map_Independent_A',0.8])];
	};	
};
publicVariable "markerColorEnemy";

// *****
// AO SETUP
// *****

diag_log "DRO: Call AO script";
_scriptStartTime = time;
[((findDisplay 888888) displayCtrl 8889), "GENERATING AREA OF OPERATIONS"] remoteExecCall ["ctrlSetText", 0];
// Generate AO and collect data
[] call fnc_generateAO;
diag_log format ["DRO: AO script run time = %1", time - _scriptStartTime];
// Reconfigure AO markers
{
	_x setMarkerColor markerColorEnemy;
} forEach AOMarkers;


// Enemy AO flag marker
_enemyFactionFlagIcon = ((configfile >> "CfgFactionClasses" >> enemyFaction >> "flag") call BIS_fnc_GetCfgData);
_enemyFactionName = ((configfile >> "CfgFactionClasses" >> enemyFaction >> "displayName") call BIS_fnc_GetCfgData);
_enemyFactionFlag = "";
_nonBaseFaction = 0;

if (!isNil "_enemyFactionName") then {
	{ 
		if (((configFile >> "CfgMarkers" >> (configName _x) >> "name") call BIS_fnc_GetCfgData) == _enemyFactionName) then {
			_enemyFactionFlag = (configName _x);			
		};
	} forEach ("true" configClasses (configFile / "CfgMarkers"));
};

if (count _enemyFactionFlag == 0) then {
	if (!isNil "_enemyFactionFlagIcon") then {		
		{ 
			if ([((configFile >> "CfgMarkers" >> (configName _x) >> "icon") call BIS_fnc_GetCfgData), _enemyFactionFlagIcon, false] call BIS_fnc_inString) then {
				_enemyFactionFlag = (configName _x);
				_nonBaseFaction = 1;
			};
		} forEach ("true" configClasses (configFile / "CfgMarkers"));

		switch (enemyFaction) do {
			case "BLU_F": {
				_enemyFactionFlag = "flag_NATO";
			};
			case "BLU_G_F": {
				_enemyFactionFlag = "flag_FIA";
			};
			case "IND_F": {
				_enemyFactionFlag = "flag_AAF";
			};
			case "OPF_F": {
				_enemyFactionFlag = "flag_CSAT";
			};
		};
	};
};
if (count _enemyFactionFlag == 0) then {
	deleteMarker "mkrFlag";
} else {
	"mkrFlag" setMarkerType _enemyFactionFlag;
	if (_nonBaseFaction == 1) then {
		"mkrFlag" setMarkerSize [2, 1.3];
	};
};

if (aoOptionSelect == 0) then {
	aoOptionSelect = [1,3] call BIS_fnc_randomInt;
};


// *****
// INTRO SETUP
// *****

// Intro Music
_musicArrayDay = [
	"LeadTrack02_F_EXP",	
	"AmbientTrack03_F",
	"LeadTrack02_F_EPA",
	"LeadTrack01_F_EPA",
	"LeadTrack03_F_EPA",
	"LeadTrack01_F_EPB",
	"LeadTrack06_F",
	"BackgroundTrack02_F_EPC",	
	"LeadTrack03_F_Mark",
	"LeadTrack02_F_EPB"	
];
_musicArrayNight = [
	"AmbientTrack04_F",
	"AmbientTrack04a_F",
	"AmbientTrack01_F_EPB",
	"AmbientTrack01b_F",
	"AmbientTrack01_F_EXP",
	"LeadTrack03_F_EPA",
	"LeadTrack03_F_EPC",
	"BackgroundTrack04_F_EPC",
	"EventTrack03_F_EPC"	
];
musicMain = nil;
if (timeOfDay <= 2) then {
	musicMain = selectRandom _musicArrayDay;
} else {
	musicMain = selectRandom _musicArrayNight;
};

// Mission Name

FOBNames = ["Partisan", "Shepherd", "Warden", "Stone", "Gullion", "Beech", "Elm", "Ash", "Cedar", "Hammer", "Axe", "Stanford", "Yale", "Oxford", "Cambridge", "Farmstead", "Temple", "Humboldt", "Herringbone", "Dogtooth", "Underhill", "Matterhorn", "Snowdon", "Coniston", "Windermere", "Victoria", "Ontario", "Como", "Bear", "Eiger"];

missionNameSpace setVariable ["weatherChanged", 1, true];


// *****
// PLAYERS SETUP
// *****

// Setup player identities
_firstNameClass = (configFile >> "CfgWorlds" >> "GenericNames" >> pGenericNames >> "FirstNames");
_firstNames = [];
for "_i" from 0 to count _firstNameClass - 1 do {
	_firstNames pushBack (getText (_firstNameClass select _i));
};
_lastNameClass = (configFile >> "CfgWorlds" >> "GenericNames" >> pGenericNames >> "LastNames");
_lastNames = [];
for "_i" from 0 to count _lastNameClass - 1 do {
	_lastNames pushBack (getText (_lastNameClass select _i));
};

// Extract voice data
_speakersArray = [];
{
	_thisVoice = (configName _x);	
	_scopeVar = typeName ((configFile >> "CfgVoice" >> _thisVoice >> "scope") call BIS_fnc_GetCfgData);
	switch (_scopeVar) do {
		case "STRING": {
			if ( ((configFile >> "CfgVoice" >> _thisVoice >> "scope") call BIS_fnc_GetCfgData) == "public") then {		
				{
					if (typeName _x == "STRING") then {
						_thisVoiceID = _x;
						{
							if ([_x, _thisVoiceID, false] call BIS_fnc_inString) then {						
								_speakersArray pushBack _thisVoice;
							};
						} forEach pIdentityTypes;						
					};
				} forEach ((configFile >> "CfgVoice" >> _thisVoice >> "identityTypes") call BIS_fnc_GetCfgData);
			};	
		};		
		case "SCALAR": {
			if ( ((configFile >> "CfgVoice" >> _thisVoice >> "scope") call BIS_fnc_GetCfgData) == 2) then {		
				{			
					if (typeName _x == "STRING") then {
						_thisVoiceID = _x;
						{
							if ([_x, _thisVoiceID, false] call BIS_fnc_inString) then {						
								_speakersArray pushBack _thisVoice;
							};
						} forEach pIdentityTypes;
					};
				} forEach ((configFile >> "CfgVoice" >> _thisVoice >> "identityTypes") call BIS_fnc_GetCfgData);
			};	
		};		
	};	
} forEach ("true" configClasses (configFile / "CfgVoice"));

if (count _speakersArray == 0) then {	
	switch (playersSide) do {
		case west: {_speakersArray = ["Male01ENG", "Male02ENG", "Male03ENG", "Male04ENG", "Male05ENG", "Male06ENG", "Male07ENG", "Male08ENG", "Male10ENG", "Male11ENG", "Male12ENG", "Male01ENGB", "Male02ENGB", "Male03ENGB", "Male04ENGB", "Male05ENGB"]};
		case east: {_speakersArray = ["Male01PER", "Male02PER", "Male03PER"]};
		case resistance: {_speakersArray = ["Male01GRE", "Male02GRE", "Male03GRE", "Male04GRE", "Male05GRE", "Male06GRE"]};
	};	
};

diag_log format ["DRO: Available voices: %1", _speakersArray];

// Extract face data
pFacesArray = [];
eFacesArray = [];
{
	{		
		_thisFace = (configName _x);
		{
			_thisIDType = _x;
			{
				if ([_thisIDType, _x, false] call BIS_fnc_inString) then {						
					pFacesArray pushBack _thisFace;
				};
			} forEach pIdentityTypes;
			{
				if ([_thisIDType, _x, false] call BIS_fnc_inString) then {						
					eFacesArray pushBack _thisFace;
				};
			} forEach eIdentityTypes;
		} forEach ((_x >> "identityTypes") call BIS_fnc_GetCfgData);
	} forEach ([(configFile >> "CfgFaces" >> (configName _x)), 0, false] call BIS_fnc_returnChildren);
} forEach ("true" configClasses (configFile / "CfgFaces"));

diag_log format ["DRO: Available player faces: %1", pFacesArray];
diag_log format ["DRO: Available enemy faces: %1", eFacesArray];

// Change units to correct ethnicity and voices
nameLookup = [];
// Generate 24 identities
if (count _speakersArray > 0) then {
	for "_p" from 0 to 23 do {		
		_firstName = selectRandom _firstNames;
		_lastName = selectRandom _lastNames;
		_speaker = selectRandom _speakersArray;
		_face = selectRandom pFacesArray;		
		nameLookup pushBack [_firstName, _lastName, _speaker, _face];					
	};
};
// Assign identities to players
{		
	_identity = (nameLookup select _forEachIndex);
	[_x, (_identity select 0), (_identity select 1), (_identity select 2), (_identity select 3)] remoteExec ["sun_setNameMP", 0, true];
	_x setVariable ["respawnIdentity", [_x, (_identity select 0), (_identity select 1), (_identity select 2), (_identity select 3)], true];	
} forEach playerGroup;
publicVariable "nameLookup";

missionNameSpace setVariable ["initArsenal", 1];
publicVariable "initArsenal";
/*
if (month == 0 || day == 0) then {
	[timeOfDay] remoteExec ['sun_randomTime', 0, true];
};
*/

// *****
// OBJECTIVES SETUP
// *****
_scriptStartTime = time;
// Get number of tasks
_numObjs = 1;
if (numObjectives == 0) then {
	_numObjs = [1,3] call BIS_fnc_randomInt;
} else {
	_numObjs = numObjectives;
};
diag_log format ["DRO: _numObjs = %1", _numObjs];

// Generate task data and physical objects
allObjectives = [];
objData = [];
taskIDs = [];
taskIntel = [];
publicVariable "taskIntel";
baseReconChance = 0.8;
publicVariable "baseReconChance";
hvtCodenames = ["Condor", "Vulture", "Scorpion", "Einstein", "Pascal", "Loner", "Spearhead", "Dalton", "Damocles", "Paris", "Huxley", "Ghost", "Gaunt", "Goblin", "Reptile"];
powJoinTasks = [];
powClass = "";
powType = "";
UXOUsed = false;

if (random 1 > 0.4) then {
	_soldierType = [0,2] call BIS_fnc_randomInt;
	if (_soldierType < 2) then {
		switch (_soldierType) do {
			case 0: {
				// Helicopter crew
				_heliCrewClasses = [];
				{
					if (["heli", _x, false] call BIS_fnc_inString) then {
						_heliCrewClasses pushBack _x;
					};
				} forEach pInfClasses;
				if (count _heliCrewClasses > 0) then {
					powClass = selectRandom _heliCrewClasses;
					powType = "HELICREW";
				} else {
					powClass = selectRandom pInfClasses;
					powType = "INFANTRY";
				};				
			};
			case 1: {
				// Engineers
				_engineerClasses = [];
				{
					if (["engineer", _x, false] call BIS_fnc_inString OR ["repair", _x, false] call BIS_fnc_inString) then {
						_engineerClasses pushBack _x;
					};
				} forEach pInfClasses;
				if (count _engineerClasses > 0) then {
					powClass = selectRandom _engineerClasses;
					powType = "ENGINEERS";
				} else {
					powClass = selectRandom pInfClasses;
					powType = "INFANTRY";
				};		
			};				
		};
	} else {
		powClass = selectRandom pInfClasses;
		powType = "INFANTRY";
	};		
} else {
	powClass = selectRandom ["C_journalist_F", "C_scientist_F"];
	powType	= switch (powClass) do {
		case "C_journalist_F": {"JOURNALISTS"};
		case "C_scientist_F": {"SCIENTISTS"};
	};
};
reconPatrolUnused = true;
for "_i" from 1 to (_numObjs) do {
	[((findDisplay 888888) displayCtrl 8889), (format ["GENERATING OBJECTIVE %1", _i])] remoteExecCall ["ctrlSetText", 0];
	if (_i == 1) then {		
		[0] call fnc_selectObjective;
	} else {		
		[(AOLocations call BIS_fnc_randomIndex)] call fnc_selectObjective;	
	};	
};
waitUntil {count allObjectives == _numObjs};
{
	diag_log format ["DRO: objData %1 = %2", _forEachIndex, objData select _forEachIndex];
} forEach objData;

_objGroupingHandle = [] execVM "sunday_system\objectives\objGrouping.sqf";
waitUntil {scriptDone _objGroupingHandle};

// Based on task data, assign tasks to players or assign recon tasks instead
{
	diag_log format ["DRO: %1 recon chance %2 checked against %3", (_x select 0), (_x select 6), baseReconChance]; 
	if ((_x select 6) < baseReconChance) then {
		// Create task from task data
		diag_log "DRO: Creating regular task";
		[_x, true, true] call sun_assignTask;			
	} else {		
		// Create recon addition
		diag_log "DRO: Creating a recon task";
		[_x, true, true] execVM "sunday_system\objectives\reconTask.sqf";		
	};
} forEach objData;

diag_log format ["DRO: Objective scripts run time = %1", time - _scriptStartTime];

// Mission name
_missionName = [] call dro_missionName;
missionNameSpace setVariable ["mName", _missionName, true];

// *****
// CIVILIAN SETUP
// *****

// Collect civilian classes
if (civiliansEnabled == 0) then {
	// Civilians only randomly spawned if time of day is not nighttime
	if (timeOfDay <= 3) then {		
		civiliansEnabled = (selectRandom [1, 3]);
	} else {civiliansEnabled = 3};
};
if (civiliansEnabled == 1 || civiliansEnabled == 2) then {	
	[((findDisplay 888888) displayCtrl 8889), "SPAWNING CIVILIANS"] remoteExecCall ["ctrlSetText", 0];			
		civTrue = true;
		[] spawn {			
			_scripts = [];
			{
				_civSpawn = [_forEachIndex] execVM "sunday_system\civilians\generateCivilians.sqf";
				_scripts pushBack _civSpawn;
			} forEach AOLocations;			
			//waitUntil {({!scriptDone _x} count _scripts) == 0};			
			if (random 1 > 0.3) then {				
				[] execVM "sunday_system\intel\addCivilianIntel.sqf";				
			};					
		};
};

missionNameSpace setVariable ["objectivesSpawned", 1, true];

// *****
// WEATHER & TIME
// *****

if (timeOfDay == 0) then {
	timeOfDay = [1,4] call BIS_fnc_randomInt;
};
publicVariable "timeOfDay";

if (month == 0 || day == 0) then {
	_newDate = date;
	if (month == 0) then {
		_newDate set [1, ([1, 12] call BIS_fnc_randomInt)];
	};
	if (day == 0) then {
		_days = [(date select 0), (date select 1)] call BIS_fnc_monthDays;
		_newDate set [2, ([1, _days] call BIS_fnc_randomInt)];
	};
	[_newDate] remoteExec ['setDate', 0, true];	 
};

sleep 0.4;
if (typeName weatherOvercast == "STRING") then {
	[(random [0, 0.4, 1])] call BIS_fnc_setOvercast;
};
_fog = if (overcast < 0.7) then {
	//diag_log (date);
	if (((date select 3) <= 7) || ((date select 3) >= 17)) then {
		if (random 1 > 0.2) then {
			//diag_log 0;
			[0.3, (random 0.05), 20];
		} else {
			//diag_log 1;
			0;
		};
	} else {
		if (random 1 > 0.9) then {
			//diag_log 2;
			[(random 0.1), (random [0.03, 0.05, 0.04]), 20];
		} else {
			//diag_log 3;
			0;
		};
	};	
} else {
	if (random 1 > 0.6) then {
		//diag_log 4;
		[(random 0.3), (random [0.03, 0.05, 0.04]), 20];
	} else {
		//diag_log 5;
		0;
	};
};
0 setFog _fog;
simulWeatherSync;

diag_log format ["DRO: Overcast = %1", overcast];
diag_log format ["DRO: Fog = %1", _fog];

_nextOvercast = (random 1);
_nextFog = if (_nextOvercast < 0.7) then {
	if (random 1 > 0.6) then {
		[(random 0.3), (random [0.03, 0.05, 0.04]), 20];
	} else {
		0;
	};
} else {
	if (random 1 > 0.3) then {
		[0.3, (random 0.05), 20];
	} else {
		0;
	};	
};
2500 setFog _nextFog;
[2500, _nextOvercast] remoteExec ["setOvercast", 0, true];
diag_log format ["DRO: time of day is %1", timeOfDay];

// *****
// GENERATE ENEMIES
// *****

[((findDisplay 888888) displayCtrl 8889), "SPAWNING ENEMIES"] remoteExecCall ["ctrlSetText", 0];

_garrisionScriptHandle = [] execVM "sunday_system\generate_ao\findGarrisonBuildings.sqf";
waitUntil {scriptDone _garrisionScriptHandle};

_enemyScripts = [];
{
	if (((AOLocations select _forEachIndex) select 4) == 0) then {
		if (_forEachIndex > 0) then {
			_enemyScripts pushBack ([_forEachIndex, "SMALL"] execVM "sunday_system\generate_enemies\generateEnemies.sqf");
		} else {
			_enemyScripts pushBack ([0, "REGULAR"] execVM "sunday_system\generate_enemies\generateEnemies.sqf");
		};
	};
} forEach AOLocations;

waitUntil {({!scriptDone _x} count _enemyScripts) == 0};
[] execVM "sunday_system\intel\addIntelObjects.sqf";

if (stealthEnabled == 0) then {
	if (timeOfDay >= 3 && missionPreset != 3) then {
		stealthEnabled = selectRandom [1,2];
	} else {
		stealthEnabled = 2;
	};
}; 
publicVariable "stealthEnabled";

// Generate power units
if (stealthEnabled == 1) then {
	_maxPowerUnits = ([1,3] call BIS_fnc_randomInt);
	_p = 0;
	while {_p <= _maxPowerUnits} do {
		_AOIndexes = [];
		{
			_AOIndexes pushBack _forEachIndex;			
		} forEach AOLocations;
		_AOIndexesShuffled = _AOIndexes call BIS_fnc_arrayShuffle;
		{
			if (count (((AOLocations select _x) select 2) select 7) > 0) exitWith {
				_building = [(((AOLocations select _x) select 2) select 7)] call sun_selectRemove;
				[_building] execVM "sunday_system\objectives\destroyPowerUnit.sqf";
			};
		} forEach _AOIndexesShuffled;		
		_p = _p + 1;
	};	
}; 
if (random 1 > 0.5) then {
	[] execVM "sunday_system\objectives\destroyCommsTower.sqf";
};

// Create intro sequence
// Collect all possible camera targets
/*
_introPosCollect = travelPosPOIMil + enemyPosCollection;
{_introPosCollect pushBack (_x select 5)} forEach objData;
for "_c" from 0 to 2 do {
	_thisTarget = [_introPosCollect] call sun_selectRemove;
	_randPos = [_thisTarget, 5, 15, 3, 1, 0.4, 0, [], [0,0,0]] call BIS_fnc_findSafePos;
	if !(_randPos isEqualTo [0,0,0]) then {
	
	};
};
*/
missionNamespace setVariable ["dro_introCamReady", 1, true];

// *****
// GENERATE FRIENDLIES
// *****

// Generate chances
//_friendlyChance = if (count AOLocations > 1) then {random 1} else {0};
_friendlyChance = if (missionPreset == 3) then {1} else {0};
//_friendlyChance = 1; // DEBUG
/*
_ambFriendlyChance = if (count AOLocations > 1 || stealthEnabled == 2) then {
	if (_friendlyChance > 0.75) then {random 1.2} else {random 1};
} else {0};
*/
_ambFriendlyChance = if (missionPreset == 3) then {1} else {0};
//if (missionPreset == 3) then {_ambFriendlyChance = 1};

if (_friendlyChance > 0.8 || _ambFriendlyChance > 0.8) then {
	[_friendlyChance, _ambFriendlyChance] execVM "sunday_system\player_setup\generateFriendlies.sqf";	
};


// *****
// WAIT FOR LOBBY COMPLETION
// *****
_scriptStartTime = time;
waitUntil {(missionNameSpace getVariable "lobbyComplete") == 1};

_setupPlayersHandle = [] execVM "sunday_system\player_setup\setupPlayersFaction.sqf";
waitUntil {scriptDone _setupPlayersHandle};

missionNameSpace setVariable ["playersReady", 1, true];

diag_log "DRO: setupPlayersFaction completed";
diag_log format ["DRO: Player setup script run time = %1", time - _scriptStartTime];


// *****
// Set all simple objects
// *****
if (!isNil "DRO_simpleObjects") then {
	if (count DRO_simpleObjects > 0) then {
		{
			[_x] call sun_replaceSimpleObject;
		} forEach DRO_simpleObjects;
	};
};


// *****
// MISC EXTRAS
// *****

// Start message listener
[] execVM "sunday_system\messageListener.sqf";

// Create a few empty enemy vehicles for use in escape
if (random 1 > 0.4) then {
	_numEscapeVehicles = [1,2] call BIS_fnc_randomInt;
	for "_i" from 1 to _numEscapeVehicles do {
		_vehClass = "";
		if (count eCarNoTurretClasses > 0) then {
			_vehClass = selectRandom eCarNoTurretClasses;
		} else {
			if (count eCarClasses > 0) then {
				_vehClass = selectRandom eCarClasses;
			};
		};
		if (count _vehClass > 0) then {
			if (count (((AOLocations select 0) select 2) select 0) > 0) then {
				_pos = [(((AOLocations select 0) select 2) select 0)] call sun_selectRemove;
				_veh = _vehClass createVehicle _pos;			
				_roadList = _pos nearRoads 10;
				if (count _roadList > 0) then {
					_thisRoad = _roadList select 0;
					_roadConnectedTo = roadsConnectedTo _thisRoad;
					_direction = 0;
					if (count _roadConnectedTo == 0) then {
						_direction = 0; 
					} else {
						_connectedRoad = _roadConnectedTo select 0;
						_direction = [_thisRoad, _connectedRoad] call BIS_fnc_DirTo;
					};				
					_veh setDir _direction;
					_newPos = [_pos, 4, (_direction + 90)] call BIS_fnc_relPos;
					_veh setPos _newPos;
				};
			};
		};
	};
};

// Ambient flyover setup
_ambientFlyByChance = random 1;
if (_ambientFlyByChance > 0.65) then {
	_flyerClasses = (eHeliClasses + ePlaneClasses);
	if (count _flyerClasses > 0) then {
		[centerPos, _flyerClasses] execVM "sunday_system\generate_ao\ambientFlyBy.sqf";
	};
};

if (animalsEnabled == 0) then {
	[centerPos] execVM "sunday_system\generate_ao\generateAnimals.sqf";
};
[] execVM "sunday_system\civilians\civMoveAction.sqf";

// Add intel items
[] execVM "sunday_system\intel\addEnemyIntel.sqf";


// Briefing init
[_missionName] execVM "briefing.sqf";

if (minesEnabled == 1) then {
	[centerPos] execVM "sunday_system\generate_ao\generateMinefield.sqf";
};
[] call sun_removeEnemyNVG;

// *****
// SEQUENCING
// *****

// Reinforcement trigger
if (((AOLocations select 0) select 4) == 0) then {
	_trgReinf = createTrigger ["EmptyDetector", centerPos, true];
	_trgReinf setTriggerArea [400, 400, 0, false];
	_trgReinf setTriggerActivation ["ANY", "PRESENT", false];
	_trgReinf setTriggerStatements ["
		(({alive _x && side _x == enemySide} count thisList) < (({alive _x && group _x == (grpNetId call BIS_fnc_groupFromNetId)} count thisList)*4.5)) &&
		enemyCommsActive &&
		!stealthActive
		
	", "diag_log 'DRO: Reinforcing due to player incursion'; [getPos thisTrigger, [1,2]] execVM 'sunday_system\reinforce.sqf';", ""];	
};

// Wait until all basic tasks are complete
diag_log format ["DRO: taskIDs = %1", taskIDs];
waituntil { 
	sleep 10;	
	_completeReturn = true;
	if (taskCreationInProgress) then {_completeReturn = false};
	{		
		_complete = [_x] call BIS_fnc_taskCompleted;
		if (!_complete) then {
			_completeReturn = false;
		};
	} forEach taskIDs;
	if (_completeReturn) then {
		sleep 6;
		{		
			_complete = [_x] call BIS_fnc_taskCompleted;
			if (!_complete) then {
				_completeReturn = false;
			};
		} forEach taskIDs;
	};
	_completeReturn	
};

reinforceChance = reinforceChance + 0.1;

// Create extract task
[] execVM "sunday_system\createExtractTask.sqf";





