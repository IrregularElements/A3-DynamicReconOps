_center = _this select 0;
_vehTypes = _this select 1;

_numFlyBys = [1,4] call BIS_fnc_randomInt;

for "_i" from 1 to _numFlyBys step 1 do {
	
	sleep ([300, 600] call BIS_fnc_randomInt);

	_vehType = selectRandom _vehTypes;

	_startPosTemp = [_center, 100, 150, 0, 1, 60, 0] call BIS_fnc_findSafePos;
	_startDir = [_center, _startPosTemp] call BIS_fnc_dirTo;
	_startDist = 3000;
	_startPos = [_center, _startDist, _startDir] call BIS_fnc_relPos;

	_endDir = [_startPos, _center] call BIS_fnc_dirTo;
	_endDist = 3000;
	_endPos = [_center, _endDist, _endDir] call BIS_fnc_relPos;

	[_startPos, _endPos, 200, "FULL", _vehType, enemySide] call BIS_fnc_ambientFlyby;

};