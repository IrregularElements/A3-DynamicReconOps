closeDialog 1;
cutText ["", "BLACK IN", 1];
_mapOpen = openMap [true, false];
[
	"mapStartSelect",
	"onMapSingleClick",
	{
		deleteMarker "aoSelectMkr";
		aoName = "";
		if (_shift) then {
			markerPlayerStart = createMarker ["aoSelectMkr", _pos];
			markerPlayerStart setMarkerShape "ICON";			
			markerPlayerStart setMarkerType "Select";		
			markerPlayerStart setMarkerAlpha 1;
			markerPlayerStart setMarkerColor "ColorGreen";
			_nearLoc = nearestLocation [_pos, ""];
			aoName = format ["Near %1", text _nearLoc];
			selectedLocMarker setMarkerColor "ColorPink";
			selectedLocMarker = markerPlayerStart;
		} else {
			_nearestMarker = [locMarkerArray, _pos] call BIS_fnc_nearestPosition;		
			markerPlayerStart = createMarker ["aoSelectMkr", getMarkerPos _nearestMarker];
			markerPlayerStart setMarkerShape "ICON";			
			markerPlayerStart setMarkerType "mil_dot";		
			markerPlayerStart setMarkerAlpha 0;		
			_loc = nearestLocation [getMarkerPos _nearestMarker, ""];
			aoName = text _loc;
			selectedLocMarker setMarkerColor "ColorPink";		
			selectedLocMarker = _nearestMarker;
		};
		_nearestMarker setMarkerColor "ColorGreen";
		publicVariableServer "markerPlayerStart";
		publicVariableServer "aoName";
		publicVariableServer "selectedLocMarker";		
		{
			[52525, 2010, (format ["AO location: %1", aoName])] remoteExec ["sun_lobbyChangeLabel", _x];	
		} forEach allPlayers;		
	},
	[]
] call BIS_fnc_addStackedEventHandler;

waitUntil {!visibleMap};
["mapStartSelect", "onMapSingleClick"] call BIS_fnc_removeStackedEventHandler;

_handle = CreateDialog "sundayDialog";
[] execVM "sunday_system\dialogs\populateStartupMenu.sqf";