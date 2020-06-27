disableSerialization;
menuComplete = false;

menuSliderArray = [
	["INFO", 1140],
	["SCENARIO", 2000],
	["ENVIRONMENT", 3000],	
	["OBJECTIVES", 4000],
	["ADVANCED FACTIONS", 5000]
];
menuSliderCurrent = 0;

ctrlSetFocus ((findDisplay 52525) displayCtrl 1150);

{	
	if ((ctrlIDC _x != 1098) && (ctrlIDC _x != 1052) && (ctrlIDC _x != 1053)) then {
		((findDisplay 52525) displayCtrl (ctrlIDC _x)) ctrlSetFade 0;
	};	
	if (ctrlIDC _x < 5000) then {
		((findDisplay 52525) displayCtrl (ctrlIDC _x)) ctrlCommit 0.3;
	}; 		
} forEach (allControls findDisplay 52525);
[] spawn {
	//sleep 2;
	((findDisplay 52525) displayCtrl 1098) ctrlSetFade 0;
	((findDisplay 52525) displayCtrl 1098) ctrlCommit 1.5;
};
/*
_index = lbAdd [2103, "Random"];
_index = lbAdd [2103, "Dawn"];
_index = lbAdd [2103, "Day"];
_index = lbAdd [2103, "Dusk"];
_index = lbAdd [2103, "Night"];
*/
lbAdd [2104, "Random"];
lbAdd [2104, "January"];
lbAdd [2104, "February"];
lbAdd [2104, "March"];
lbAdd [2104, "April"];
lbAdd [2104, "May"];
lbAdd [2104, "June"];
lbAdd [2104, "July"];
lbAdd [2104, "August"];
lbAdd [2104, "September"];
lbAdd [2104, "October"];
lbAdd [2104, "November"];
lbAdd [2104, "December"];
/*
lbAdd [2116, "Random"];
lbAdd [2116, "Custom"];
*/
_index = lbAdd [2106, "Random"];
_index = lbAdd [2106, "1"];
_index = lbAdd [2106, "2"];
_index = lbAdd [2106, "3"];

["MAIN", 2020, false] call sun_switchButton;
["MAIN", 2030, false] call sun_switchButton;
["MAIN", 2050, false] call sun_switchButton;
["MAIN", 2060, false] call sun_switchButton;
["MAIN", 2070, false] call sun_switchButton;
["MAIN", 2080, false] call sun_switchButton;
["MAIN", 2090, false] call sun_switchButton;
["MAIN", 2400, false] call sun_switchButton;
["MAIN", 3010, false, "TIME"] call sun_switchButton;
['MAIN', 3020, false] call sun_switchButtonWeather;
["MAIN", 3030, false] call sun_switchButton;
["MAIN", 4010, false] call sun_switchButton;
//["MAIN", 3020, false] call sun_switchButton;

/*
lbAdd [2117, "Enabled"];
lbAdd [2117, "Disabled"];
*/
//lbSetCurSel [2106, numObjectives];

lbSetCurSel [2104, month];
//lbSetCurSel [2117, animalsEnabled];
[2301] call dro_inputDaysData;
lbSetCurSel [2301, day];
//lbSetCurSel [2103, timeOfDay];

// Slider items
sliderSetRange [2041, 5, 17];
sliderSetPosition [2041, aiMultiplier*10];
((findDisplay 52525) displayCtrl 2041) ctrlSetText format ["Enemy force size multiplier: x%1", profileNamespace getVariable ['DRO_aiMultiplier', 1]];


sliderSetRange [2109, 0, 10];

if (weatherOvercast isEqualType "") then {	
	sliderSetPosition [2109, 3];
	lbSetCurSel [2116, 0];
} else {	
	sliderSetPosition [2109, (weatherOvercast*10)];
	lbSetCurSel [2116, 1];
};

if (!isNil "aoName") then {
	ctrlSetText [2202, format ["AO location: %1", aoName]];
};

// Objective preferences
if (count preferredObjectives > 0) then {
	{
		switch (_x) do {
			case "HVT": {((findDisplay 52525) displayCtrl 2200) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "POW": {((findDisplay 52525) displayCtrl 2201) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "INTEL": {((findDisplay 52525) displayCtrl 2202) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "CACHE": {((findDisplay 52525) displayCtrl 2203) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "MORTAR": {((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "WRECK": {((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [0.05, 1, 0.5, 1]};			
			case "VEHICLE": {((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "VEHICLESTEAL": {((findDisplay 52525) displayCtrl 2207) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "ARTY": {((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "HELI": {((findDisplay 52525) displayCtrl 2204) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "CLEARLZ": {((findDisplay 52525) displayCtrl 2210) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "FORTIFY": {((findDisplay 52525) displayCtrl 2211) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "DISARM": {((findDisplay 52525) displayCtrl 2212) ctrlSetTextColor [0.05, 1, 0.5, 1]};
			case "PROTECTCIV": {((findDisplay 52525) displayCtrl 2213) ctrlSetTextColor [0.05, 1, 0.5, 1]};
		}; 
		
	} forEach preferredObjectives;
};

{
	_indexP = lbAdd [_x, "NONE"];					
	lbSetData [_x, _indexP, ""];
	lbSetColor [_x, _indexP, [1, 1, 1, 1]];	
} forEach [3800, 3801, 3802, 3803, 3804, 3805];	

{
	_index = lbAdd [_x, "RANDOM"];					
	lbSetData [_x, _index, "RANDOM"];
} forEach [1301, 1311];	

_pFactionSel = pFactionIndex;
_eFactionSel = eFactionIndex;

{	
	_thisFaction = (_x select 0);
	_thisFactionName = (_x select 1);
	_thisFactionFlag = (_x select 2);
	diag_log _thisFactionFlag;
	_thisSideNum = (_x select 3);
	// Add factions to combo boxes
	_color = "";
	switch (_thisSideNum) do {
		case 1: {
			_color = [0, 0.3, 0.6, 1];
		};
		case 0: {
			_color = [0.5, 0, 0, 1];
		};
		case 2: {
			_color = [0, 0.5, 0, 1];
		};
		case 3: {
			_color = [1, 1, 1, 1];
		};						
	};				
	if (_thisSideNum == 3) then {
		_indexC = lbAdd [1321, _thisFactionName];					
		lbSetData [1321, _indexC, _thisFaction];
		lbSetColor [1321, _indexC, _color];		
		if (!isNil "_thisFactionFlag" && !(_thisFaction isEqualTo "IND_L_F")) then {
			if (count _thisFactionFlag > 0) then {
				lbSetPicture [1321, _indexC, _thisFactionFlag];
				lbSetPictureColor [1321, _indexC, [1, 1, 1, 1]];
				lbSetPictureColorSelected [1321, _indexC, [1, 1, 1, 1]];
			};
		};
	} else {		
		_indexP = lbAdd [1301, _thisFactionName];					
		lbSetData [1301, _indexP, _thisFaction];
		lbSetColor [1301, _indexP, _color];
		
		if (!isNil "_thisFactionFlag" && !(_thisFaction isEqualTo "IND_L_F")) then {
			if (count _thisFactionFlag > 0) then {
				lbSetPicture [1301, _indexP, _thisFactionFlag];
				lbSetPictureColor [1301, _indexP, [1, 1, 1, 1]];
				lbSetPictureColorSelected [1301, _indexP, [1, 1, 1, 1]];
			};
		};
		if ((profileNamespace getVariable ["DRO_playersFaction", ""]) == _thisFaction) then {
			_pFactionSel = _indexP;
		};
		_indexE = lbAdd [1311, _thisFactionName];					
		lbSetData [1311, _indexE, _thisFaction];
		lbSetColor [1311, _indexE, _color];
		if (!isNil "_thisFactionFlag" && !(_thisFaction isEqualTo "IND_L_F")) then {
			if (count _thisFactionFlag > 0) then {
				lbSetPicture [1311, _indexE, _thisFactionFlag];
				lbSetPictureColor [1311, _indexE, [1, 1, 1, 1]];
				lbSetPictureColorSelected [1311, _indexE, [1, 1, 1, 1]];
			};
		};
		if ((profileNamespace getVariable ["DRO_enemyFaction", ""]) == _thisFaction) then {
			_eFactionSel = _indexE;
		};
	};				
} forEach availableFactionsData;


{
	_thisFaction = (_x select 0);
	_thisFactionName = (_x select 1);
	_thisFactionFlag = (_x select 2);
	_thisSideNum = (_x select 3);
	// Add factions to combo boxes
	_color = "";
	switch (_thisSideNum) do {
		case 1: {
			_color = [0, 0.3, 0.6, 1];
		};
		case 0: {
			_color = [0.5, 0, 0, 1];
		};
		case 2: {
			_color = [0, 0.5, 0, 1];
		};
		case 3: {
			_color = [1, 1, 1, 1];
		};						
	};				
	if (_thisSideNum != 3) then {	
		{
			_indexP = lbAdd [_x, _thisFactionName];					
			lbSetData [_x, _indexP, _thisFaction];
			lbSetColor [_x, _indexP, _color];
			if (!isNil "_thisFactionFlag" && !(_thisFaction isEqualTo "IND_L_F")) then {
				if (count _thisFactionFlag > 0) then {
					lbSetPicture [_x, _indexP, _thisFactionFlag];
					lbSetPictureColor [_x, _indexP, [1, 1, 1, 1]];
					lbSetPictureColorSelected [_x, _indexP, [1, 1, 1, 1]];
				};
			};
		} forEach [3800, 3801, 3802];	
		
		{
			_indexE = lbAdd [_x, _thisFactionName];					
			lbSetData [_x, _indexE, _thisFaction];
			lbSetColor [_x, _indexE, _color];
			if (!isNil "_thisFactionFlag" && !(_thisFaction isEqualTo "IND_L_F")) then {
				if (count _thisFactionFlag > 0) then {
					lbSetPicture [_x, _indexE, _thisFactionFlag];
					lbSetPictureColor [_x, _indexE, [1, 1, 1, 1]];
					lbSetPictureColorSelected [_x, _indexE, [1, 1, 1, 1]];
				};
			};
		} forEach [3803, 3804, 3805];		
		
	};				
} forEach (availableFactionsData + availableFactionsDataNoInf);

lbSetCurSel [1301, _pFactionSel];
lbSetCurSel [1311, _eFactionSel];
lbSetCurSel [1321, cFactionIndex];

lbSetCurSel [3800, (playersFactionAdv select 0)];
lbSetCurSel [3801, (playersFactionAdv select 1)];
lbSetCurSel [3802, (playersFactionAdv select 2)];
lbSetCurSel [3803, (enemyFactionAdv select 0)];
lbSetCurSel [3804, (enemyFactionAdv select 1)];
lbSetCurSel [3805, (enemyFactionAdv select 2)];

// Add multiline tooltips
_tooltip = str composeText [
	"Mission Presets",
	toString [13, 10],
	"Recon: The classic gamemode. As a small squad, conduct a recon mission into a randomised AO. Your selection of vehicles will be limited to those appropriate for a small operation.",
	toString [13, 10],
	"Sniper Ops: Eliminate a single HVT in a more sparsely populated AO while remaining undetected.",
	toString [13, 10],
	"Combined Arms: As part of a larger force, and with more vehicle options at your disposal, take on a densely populated AO with potential enemy armour to contend with.",
	toString [13, 10]
];
((findDisplay 52525) displayCtrl 2094) ctrlSetTooltip _tooltip;
_tooltip = str composeText [	 
	"AI Skill",
	toString [13, 10],
	"Normal: Reduces the AI's aiming ability dramatically while leaving their strategic skills almost unchanged. This is the default setting for DRO, balanced for the number of enemy units you're likely to encounter.",
	toString [13, 10],
	"Hard: Reduces the AI's aiming ability less dramatically while leaving their strategic skills almost unchanged.",
	toString [13, 10],
	"Realism: Makes no changes to any AI skills and leaves them as set in your Arma options menu.",
	toString [13, 10]
];
((findDisplay 52525) displayCtrl 2034) ctrlSetTooltip _tooltip;



// Search for incompatible mods
_modList = "";
/*
if ((configfile >> "CfgPatches" >> "ace_main") call BIS_fnc_getCfgIsClass) then {		
	_modList = composeText [_modList, lineBreak, "ACE3"];
};
*/
_warningList = "";
if (isClass (configfile >> "CfgPatches" >> "ace_medical")) then {	
	if (!isNil "ace_medical_enableRevive") then {
		if (ace_medical_enableRevive > 0) then {
			_warningList = composeText [lineBreak, "ACE medical revive is enabled, DRO revive will be automatically disabled."];
		};
	};
};

if ((configfile >> "CfgPatches" >> "C2_CORE") call BIS_fnc_getCfgIsClass) then {		
	_modList = composeText [_modList, lineBreak, "C2 - Command And Control"];
};
if (!(_modList isEqualType "") || !(_warningList isEqualType "")) then {
	_text = composeText ["Warning!", lineBreak, "The following mods may cause compatibility issues with this scenario:", lineBreak, _modList, _warningList];
	((findDisplay 52525) displayCtrl 1053) ctrlSetStructuredText _text;
	[] spawn {
		disableSerialization;
		{
			_x ctrlSetFade 0;
		} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
		{
			_x ctrlCommit 0.2;
		} forEach [((findDisplay 52525) displayCtrl 1052), ((findDisplay 52525) displayCtrl 1053)];
	};
};

menuComplete = true;