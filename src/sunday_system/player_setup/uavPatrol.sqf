_center = getPos trgAOC;
_availableUAVs = [];
if (count pUAVClasses > 0) then {
	{
		if (_x isKindOf "Plane") then {
			_availableUAVs pushBack _x;
		};
	} forEach pUAVClasses;
};

_uavClass = selectRandom _availableUAVs;
_uavPos = _center;
_uavPos set [2, 1300];
_spawn = [_uavPos, 0, _uavClass, playersSide] call BIS_fnc_spawnVehicle;
_uav = _spawn select 0;
_uav setCaptive true;
_uav flyInHeight 1300;
_markerSize = getMarkerSize "mkrAOC";
_loiterRadius = if ((_markerSize select 0) > (_markerSize select 1)) then {
	(_markerSize select 0)
} else {
	(_markerSize select 1)
};
_loiterRadius = _loiterRadius/2;

_wpLast = (group _uav) addWaypoint [_uavPos, 0];
_wpLast setWaypointType "LOITER";
_wpLast setWaypointLoiterRadius _loiterRadius;
_wpLast setWaypointLoiterType "CIRCLE_L";

/*
_markerSize = getMarkerSize "mkrAOC";
_topLeftTrue = [((_center select 0) - (_markerSize select 0)), ((_center select 1) + (_markerSize select 1))];
_topRightTrue = [((_center select 0) + (_markerSize select 0)), ((_center select 1) + (_markerSize select 1))];
_bottomLeftTrue = [((_center select 0) - (_markerSize select 0)), ((_center select 1) - (_markerSize select 1))];
_bottomRightTrue = [((_center select 0) - (_markerSize select 0)), ((_center select 1) + (_markerSize select 1))];

_topLeft = [_topLeftTrue, 300, ([_topLeftTrue, _center] call BIS_fnc_dirTo)] call BIS_fnc_relPos;
_topRight = [_topRightTrue, 300, ([_topRightTrue, _center] call BIS_fnc_dirTo)] call BIS_fnc_relPos;
_bottomLeft = [_bottomLeftTrue, 300, ([_bottomLeftTrue, _center] call BIS_fnc_dirTo)] call BIS_fnc_relPos;
_bottomRight = [_bottomRightTrue, 300, ([_bottomRightTrue, _center] call BIS_fnc_dirTo)] call BIS_fnc_relPos;

_topLeft set [2, 400];
_topRight set [2, 400];
_bottomLeft set [2, 400];
_bottomRight set [2, 400];

(group uav) addWaypoint [_topLeft, 0];
(group uav) addWaypoint [_topRight, 0];
(group uav) addWaypoint [_bottomLeft, 0];
(group uav) addWaypoint [_bottomRight, 0];
_wpLast = (group uav) addWaypoint [_topLeft, 0];

*/