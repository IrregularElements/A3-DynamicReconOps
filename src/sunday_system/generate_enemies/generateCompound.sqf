params ["_buildings"];


/*
_marker = createMarker [format["mkr%1", random 100000], _avgPos];
_marker setMarkerShape "ICON";
_marker setMarkerColor "ColorOrange";
_marker setMarkerType "mil_dot";
//_marker setMarkerText format ["Patrol %2: %1", _thisGroup, _forEachIndex];
_marker setMarkerSize [2, 2];
*/

_leftX = 9999999;
_rightX = 0;
_bottomY = 9999999;
_topY = 0;

{
	
	_thisSize = sizeOf (typeOf _x);

	_thisPos = (getPos _x);
	_thisX = _thisPos select 0;
	_thisY = _thisPos select 1;
	
	if (_thisX < _leftX) then {_leftX = _thisX - (_thisSize / 2)};
	if (_thisX > _rightX) then {_rightX = _thisX + (_thisSize / 2)};
	if (_thisY < _bottomY) then {_bottomY = _thisY - (_thisSize / 2)};
	if (_thisY > _topY) then {_topY = _thisY + (_thisSize / 2)};
		
	_marker = createMarker [format["mkr%1", random 100000], (getPos _x)];
	_marker setMarkerShape "ICON";
	_marker setMarkerColor "ColorBlue";
	_marker setMarkerType "mil_dot";
} forEach _buildings;

_sizeX = _rightX - _leftX;
_sizeY = _topY - _bottomY;

_markerC = createMarker [format["mkr%1", random 100000], [(_leftX + (_sizeX / 2)), (_bottomY + (_sizeY / 2))]];
_markerC setMarkerShape "RECTANGLE";
_markerC setMarkerSize [_sizeX / 2, _sizeY / 2];
_markerC setMarkerBrush "Border";		
_markerC setMarkerColor "ColorOrange";

