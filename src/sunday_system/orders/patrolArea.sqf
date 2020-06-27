params ["_group", "_center", "_area", "_speed"];

_minArea = _area select 0;
_maxArea = _area select 1;
_speed = (toUpper _speed);
_behaviour = if (_speed == "LIMITED") then {
	"SAFE"
} else {
	"AWARE"
};

// Remove all current waypoints
while {(count (waypoints _group)) > 0} do {
	deleteWaypoint ((waypoints _group) select 0);
};

// Generate number of waypoints
_numWaypoints = [4, 7] call BIS_fnc_randomInt;

// Create first waypoint to set behaviour and speed
private _wp = _group addWaypoint [(getPos (leader _group)), 0];
_wp setWaypointCompletionRadius 10;
_wp setWaypointBehaviour _behaviour;
_wp setWaypointSpeed _speed;
_wp setWaypointType "MOVE";

// Generate first waypoint for reuse as the last cycle waypoint
_firstPos = [_center, _minArea, _maxArea, 0, 0, 0, 0] call BIS_fnc_findSafePos;

for "_i" from 0 to _numWaypoints do {
	
	if (_i == _numWaypoints) then {
		// Remove the first dummy waypoint and create the final cycle waypoint
		deleteWaypoint ((waypoints _group) select 0);
		_wpPos = _firstPos;
		private _wp = _group addWaypoint [_wpPos, 0];
		_wp setWaypointCompletionRadius 10;
		_wp setWaypointType "CYCLE";
	} else {
		// Create random move waypoint
		_wpPos = [_center, _minArea, _maxArea, 0, 0, 0, 0] call BIS_fnc_findSafePos;	
		private _wp = _group addWaypoint [_wpPos, 0];
		_wp setWaypointCompletionRadius 10;
		_wp setWaypointType "MOVE";
	};
	
};





