params ["_object", "_task", "_customMarkerName", "_subTaskName", ["_markerColor", markerColorEnemy], ["_markerSize", 100], ["_markerBrush", "BDiagonal"]];

diag_log format["DRO: Static marker called: %1 on object %2", _customMarkerName, _object];

_staticMarkerName = if (!isNil "_customMarkerName") then {	
	_customMarkerName
} else {
	format["staticMkr%1", floor(random 10000)]
};

_shiftAmount = [0, ((_markerSize-30) max 0)] call BIS_fnc_randomNum;
_extendPos = [(getPos _object), _shiftAmount, (random 360)] call BIS_fnc_relPos;
_staticMarker = createMarker [_staticMarkerName, _extendPos];
_staticMarker setMarkerShape "ELLIPSE";		
_staticMarker setMarkerBrush _markerBrush;
_staticMarker setMarkerSize [_markerSize, _markerSize];
_staticMarker setMarkerAlpha 1;
_staticMarker setMarkerColor _markerColor;
_object setVariable ["staticMarker", _staticMarker, true];

/*
if (!isNil "enemyIntelMarkers") then {
	taskIntel pushBack [_task, _object, (if (!isNil "_subTaskName") then {_subTaskName} else {""}), "MARKER"];
};
*/

/*
if (!isNil "enemyIntelMarkers") then {
	enemyIntelMarkers pushBack [_staticMarker, _object];
	publicVariable "enemyIntelMarkers";
};
*/
