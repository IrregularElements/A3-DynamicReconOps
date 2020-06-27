params ["_object", "_task", "_customMarkerName", "_subTaskName", ["_markerColor", markerColorEnemy], ["_markerSize", 800], ["_markerBrush", "BDiagonal"]];

_followMarkerName = if (!isNil "_customMarkerName") then {	
	_customMarkerName
} else {
	format["followMkr%1", floor(random 10000)]
};

_shiftAmount = [0, ((_markerSize-30) max 0)] call BIS_fnc_randomNum;
_extendPos = [(getPos _object), _shiftAmount, (random 360)] call BIS_fnc_relPos;
_followMarker = createMarker [_followMarkerName, _extendPos];
_followMarker setMarkerShape "ELLIPSE";		
_followMarker setMarkerBrush _markerBrush;
_followMarker setMarkerSize [_markerSize, _markerSize];
_followMarker setMarkerAlpha 1;
_followMarker setMarkerColor _markerColor;
_object setVariable ["followMarker", _followMarker, true];

diag_log format ["DRO: Follow marker created for %1 and attached to %2 - size: %3", _task, _object, getMarkerSize _followMarker];

if (!isNil "enemyIntelMarkers") then {
	taskIntel pushBack [_task, _object, (if (!isNil "_subTaskName") then {_subTaskName} else {""}), "MARKER"];
};
/*
if (!isNil "enemyIntelMarkers") then {
	enemyIntelMarkers pushBack [_followMarker, _object];
	publicVariable "enemyIntelMarkers";
};
*/

while {((getMarkerSize _followMarker) select 0) > 0} do {
	sleep 10;
	if (((getMarkerSize _followMarker) select 0) > 0) then {
		if (!(_object inArea _followMarker)) then {
			_alpha = markerAlpha _followMarker;
			for "_i" from 1 to 20 do {
				sleep 0.1;
				_alpha = _alpha - 0.025;
				_followMarker setMarkerAlpha _alpha;
			};
			_followMarker setMarkerAlpha 0;		
			_shiftAmount = [0, ((((getMarkerSize _followMarker) select 0)-30) max 0)] call BIS_fnc_randomNum;
			_extendPos = [(getPos _object), _shiftAmount, (random 360)] call BIS_fnc_relPos;
			_followMarker setMarkerPos _extendPos;
			[_task, _extendPos] call BIS_fnc_taskSetDestination;
			for "_i" from 1 to 20 do {
				sleep 0.1;
				_alpha = _alpha + 0.025;
				_followMarker setMarkerAlpha _alpha;
			};
			_followMarker setMarkerAlpha 1;
		};
	};	
	//if ((([_task] call BIS_fnc_taskState) == "SUCCEEDED") OR (([_task] call BIS_fnc_taskState) == "FAILED") OR (([_task] call BIS_fnc_taskState) == "CANCELED") OR (!alive _object)) then {
	if (([_task] call BIS_fnc_taskCompleted) OR (!alive _object)) exitWith {
		_followMarker setMarkerAlpha 0;
	};
};