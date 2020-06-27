params ["_center"];

_bestPlaces = selectBestPlaces [_center, (aoSize/2), "meadow - (2*houses)", 40, 25];
diag_log format ["DRO: Mines best places = %1", _bestPlaces];
_minefieldPlaces = [];
{
	if ((_x select 1) > 0.5) then {
		_continue = true;
		(_x select 0) pushBack 0;
		_nearPeople = (_x select 0) nearEntities ["Man", 300];
		{
			if (side _x == enemySide) then {
				_continue = false;
			};
		} forEach _nearPeople;
		if (_continue) then {
			_minefieldPlaces pushBack (_x select 0);
		};			
	};
} forEach _bestPlaces;

if (count _minefieldPlaces > 0) then {
	_enemyIntelMarkers = [];
	for "_i" from 1 to (([1,3] call BIS_fnc_randomInt) min (count _minefieldPlaces)) step 1 do {
		_thisPos = [_minefieldPlaces] call dro_selectRemove;
		_grid = [_thisPos, 5, 5, 25] call sun_defineGrid;
		
		_markerName = format["mineMkr%1", floor(random 10000)];
		_markerSizeX = ([60,100] call BIS_fnc_randomInt);
		_markerSizeY = ([60,100] call BIS_fnc_randomInt);
		_mineMarker = createMarker [_markerName, _thisPos];
		_mineMarker setMarkerShape "ELLIPSE";
		_mineMarker setMarkerBrush "Cross";
		_mineMarker setMarkerColor "ColorRed";
		_mineMarker setMarkerSize [_markerSizeX, _markerSizeY];
		_mineMarker setMarkerDir (random 360);
		_mineMarker setMarkerAlpha 0;
		_enemyIntelMarkers pushBack _mineMarker;
		
		{
			if (_x inArea _mineMarker) then {
				_mine = "APERSMine_Range_Ammo" createVehicle _x;
				[(selectRandom ["Land_Sign_Mines_F", "Land_Sign_MinesTall_F", "Land_Sign_MinesTall_English_F"]), _x, (random 360)] call dro_createSimpleObject;
			};
		} forEach _grid;		
		
		_markerSizeMax = _markerSizeX max _markerSizeY;
		_numSigns = 40;
		_angle = 0;
		_angleDif = 360/_numSigns;
		for "_i" from 1 to (_numSigns) step 1 do {
			_signPos = [_thisPos, _markerSizeMax, _angle] call dro_extendPos;
			if (_i % 3 == 0) then {
				["Land_Sign_MinesDanger_English_F", _signPos, ([_signPos, _thisPos] call BIS_fnc_dirTo)] call dro_createSimpleObject;	
			} else {
				[(selectRandom ["Land_Sign_Mines_F", "Land_Sign_MinesTall_F", "Land_Sign_MinesTall_English_F"]), _signPos, ([_signPos, _thisPos] call BIS_fnc_dirTo)] call dro_createSimpleObject;	
			};								
			_angle = _angle + _angleDif;
		};		
	};	
	missionNamespace setVariable ["enemyIntelMarkers", ((missionNamespace getVariable "enemyIntelMarkers") + _enemyIntelMarkers)];	
	publicVariable "enemyIntelMarkers";	
};

