_missionName = _this select 0;

// Mission name diary entry
_missionText = "";
if (count _missionName > 0) then {
	//_missionName = [_missionName, 15] call BIS_fnc_trimString;
	_missionText = format ["<font size='20' face='PuristaBold'>%1</font>",_missionName];	
};

// Insertion diary entry
_textLocation = "";
if (count "campMkr" > 0) then {
	_markerText = markerText "campMkr";
	switch (insertType) do {
		case "GROUND": {
			if (AOLocType == "NameLocal") then {
				_textLocation = format ["<br /><br />From their deployed position at <marker name=%4>%5</marker> fireteam %6 will perform a patrol into <marker name=%3>%1</marker>. Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr",_markerText, playerCallsign];
			} else {	
				_textLocation = format ["<br /><br />From their deployed position at <marker name=%4>%5</marker> fireteam %6 will perform a patrol into the %2 of <marker name=%3>%1.</marker> Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr",_markerText, playerCallsign];
			};
		};
		case "SEA": {
			if (AOLocType == "NameLocal") then {
				_textLocation = format ["<br /><br />Fireteam %5 will insert via boat starting from the marked <marker name=%4>drop point</marker>. From there they will perform a patrol into %1 at <marker name=%3>this location</marker>. Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr", playerCallsign];
			} else {	
				_textLocation = format ["<br /><br />Fireteam %5 will insert via boat starting from the marked <marker name=%4>drop point</marker>. From there they will perform a patrol into the %2 of <marker name=%3>%1</marker>. Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr", playerCallsign];
			};
		};
		case "HELI": {
			if (AOLocType == "NameLocal") then {
				_textLocation = format ["<br /><br />Fireteam %5 will insert via heli at the marked <marker name=%4>drop point</marker>. From there they will perform a patrol into %1 at <marker name=%3>this location</marker>. Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr", playerCallsign];
			} else {	
				_textLocation = format ["<br /><br />Fireteam %5 will insert via heli at the marked <marker name=%4>drop point</marker>. From there they will perform a patrol into the %2 of <marker name=%3>%1</marker>. Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr", playerCallsign];
			};
		};
		case "HALO": {
			if (AOLocType == "NameLocal") then {
				_textLocation = format ["<br /><br />Fireteam %5 will insert via HALO at the marked <marker name=%4>drop point</marker>. From there they will perform a patrol into %1 at <marker name=%3>this location</marker>. Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr", playerCallsign];
			} else {	
				_textLocation = format ["<br /><br />Fireteam %5 will insert via HALO at the marked <marker name=%4>drop point</marker>. From there they will perform a patrol into the %2 of <marker name=%3>%1</marker>. Check task list for objectives.", aoName, AOBriefingLocType, "centerMkr","campMkr", playerCallsign];
			};
		};
	};	
};

// Enemy makeup diary entry
_textEnemies = "";
_numEnemies = 0;
{
	if (side _x == enemySide) then {
		_numEnemies = _numEnemies + 1;
	};
} forEach allUnits;

if (_numEnemies < 60) then {
	_textEnemies = format ["<br /><br />%1 have a weak occupying force in the region. ", enemyFactionName];
};
if (_numEnemies >= 60 && _numEnemies < 80) then {
	_textEnemies = format ["<br /><br />%1 have a moderate occupying force in the region. ", enemyFactionName];
};
if (_numEnemies >= 80) then {
	_textEnemies = format ["<br /><br />%1 have a strong occupying force in the region; expect heavy resistance. ", enemyFactionName];
};

_textSecondaryLocs = "";
if (count AOLocations > 1) then {
	_aoNames = [];	
	{
		if (_forEachIndex > 0) then {
			if ((_x select 4) == 0) then {
				_secondaryLoc = nearestLocation [_x select 0, ""];
				_mkrName = format ["mkrSecondaryLoc%1", _forEachIndex];							
				_aoNames pushBack (format ["<marker name=%2>%1</marker>", (text _secondaryLoc), _mkrName]);
			};
		};
	} forEach AOLocations;
	if (count _aoNames > 0) then {
		_aoNamesFull = [_aoNames] call sun_stringCommaList;			
		_reportText = selectRandom ["received reports of", "detected", "been made aware of"];
		if (count _aoNames > 1) then {		
			_textSecondaryLocs = format ["We have also %3 %1 occupying forces in %2.", enemyFactionName, _aoNamesFull, _reportText];
		} else {
			_textSecondaryLocs = format ["We have also %3 a %1 occupying force in %2.", enemyFactionName, _aoNamesFull, _reportText];
		};
	};
} else {
	_textSecondaryLocs = "";
};

// Civilians present diary entry
_textCivs = "";
if (!isNil "civTrue") then {	
	if (civTrue) then {
		_textCivs = "As well as that you can expect to encounter civilians in the area of operations so check your targets and exercise extreme caution before using ordnance. Command considers any collateral damage to be unacceptable and ROE violations may result in severe punishment.";		
		if (!isNil "hostileCivIntel") then {
			_randHostileCivs = selectRandom [
				"<br /><br />We have reason to believe that a hostile militia is operating in the region and are hiding themselves among the civilian population.",
				"<br /><br />Intel shows that a number of civilians have banded together to form a militia hostile to our forces.",
				"<br /><br />Recent reports show that a hostile militia has sprung up to support the enemy forces."
			];
			_textCivs = format [" %1%2 %3 You will be going into a complex situation that will require close attention to apparent non-combatants. Keep this in mind and ensure collateral damage is kept to a bare minimum.", _textCivs, _randHostileCivs, hostileCivIntel];
		};
	} else {
		_textCivs = " The area of operations is clear of civilians. You are cleared to use any tools at your disposal to complete objectives.";
	};	
};

_textResupply = if (getMarkerColor "resupplyMkr" == "") then {
	""
} else {
	"<br /><br />A <marker name='resupplyMkr'>resupply point</marker> has been prepared by a guerilla element. It contains a basic selection of arms for you to use in the field including explosives to deal with any objectives that may require them.";
};

_textCancel = "<br /><br />If at any time you find yourself unable to complete an objective you have the option to cancel that task under its task listing.";

_textStealth = if (stealthEnabled == 1) then {
	format ["<br /><br />The %1 forces will not be expecting %2 operations near %3, a fact which you can use to your advantage. Keep a low profile and eliminate enemies before they can raise the alarm and you'll stay undetected.", enemyFactionName, playersFactionName, aoName]
} else {
	""
};

_textFriendly = if (!isNil "friendlyText") then {friendlyText} else {""};

briefingString = format["%1%2%9%7%4%3%5%8%6", _missionText, _textLocation, _textSecondaryLocs, _textCivs, _textResupply, _textCancel, _textEnemies, _textStealth, _textFriendly];
publicVariable "briefingString";
/*
{
	[_x, ["Diary", ["Briefing", _briefingString]]] remoteExec ["createDiaryRecord", _x, true];
} forEach allPlayers;
*/

//[_briefingString] remoteExec ["sun_briefingJIP", 0, true];

//player createDiaryRecord ["Diary", ["Briefing", _briefingString]];
[briefingString, {player createDiaryRecord ["Diary", ["Briefing", _this]]}] remoteExec ["call", 0, true];

["BRIEFING"] spawn dro_sendProgressMessage;
