params ["_center"];

// [Classname, Correct rotation for left side of road]
_marketStalls = [
	["Land_WoodenCounter_01_F", -90],
	["Land_WoodenTable_large_F", 0]
];
_marketSheltersLong = [
	["Land_MarketShelter_F", 90],
	["Land_MetalShelter_01_F", 180]
];
_marketSheltersShort = [
	["Land_ClothShelter_01_F", 0],
	["Land_ClothShelter_02_F", 90],
	["Land_WoodenShelter_01_F", -90],
	["Land_cargo_addon02_V2_F", 90],
	["Land_cargo_addon02_V1_F", 90],
	["Land_Boat_03_abandoned_cover_F", 180]
];
_marketSheltersLone = [
	["Land_Shed_03_F", -90],
	["Land_Shed_06_F", 0],
	["Land_Slum_House01_F", -90],
	["Land_cargo_house_slum_F", -90],
	["Land_LampShabby_F", 180]
];
_marketObjects = [
	"Land_StallWater_F",	
	"Land_Basket_F",
	"Land_Cages_F",	
	"Land_Sack_F",
	"Land_Sacks_goods_F",
	"Land_Sacks_heap_F",
	"Land_WoodenCrate_01_F",		
	"Land_Pallets_F",
	"Land_Pallets_stack_F"
];
_marketObjectsLarge = [
	"Land_WoodenCart_F",
	"Land_CratesWooden_F",
	"Land_WoodenCrate_01_stack_x3_F",
	"Land_WoodenCrate_01_stack_x5_F"
];
_garbage = [
	"Land_Garbage_square3_F",
	"Land_Garbage_square5_F",
	"Land_Garbage_line_F"	
];
_return = [];
_allRoads = (_center nearRoads 30);
if (count _allRoads > 0) then {
	{		
		_thisRoad = _x;
		_continue = true;
		if (isNil "marketRoads") then {_continue = true} else {
			if (_thisRoad in marketRoads) then {
				_continue = false
			} else {
				{
					if ((_thisRoad distance _x) < 6) exitWith {
						_continue = false
					};
				} forEach marketRoads;				
			};
		};
		if (count (roadsConnectedTo _thisRoad) <= 2 && _continue) then {
			_dir = [_thisRoad] call sun_getRoadDir;
			for "_roadSide" from 0 to 180 step 180 do {	
				_stallPositions = [];
				_shelters = [];		
				
				if (random 1 > 0.25) then {
					// Create shelter
					_thisPos = getPos _thisRoad;
					_return	pushBack _thisPos;					
					_spawnPos = [_thisPos, 7, ((_dir - 90)+_roadSide)] call BIS_fnc_relPos;					
					if (random 1 > 0.5) then {
						// Long shelter
						_shelter = selectRandom _marketSheltersLong;
						_object = createVehicle [(_shelter select 0), _spawnPos, [], 0, "NONE"];		
						_object setDir _dir + (_shelter select 1) + _roadSide;
						_shelters pushBack _object;
						//_shelters pushBack ([(_shelter select 0), _spawnPos, _dir + (_shelter select 1) + _roadSide, "NONE"] call dro_createSimpleObject);						
						_numStalls = ([3,4] call BIS_fnc_randomInt) * 2;
						for "_i" from -_numStalls to _numStalls step 4 do {
							_stallPos = [_spawnPos, _i, _dir] call BIS_fnc_relPos;
							_stallPositions pushBack _stallPos;					
						};				
					} else {
						// Small shelters
						_numShelters = ([2,4] call BIS_fnc_randomInt) * 3;				
						for "_i" from -_numShelters to _numShelters step 6 do {
							_spawnPosNew = [_spawnPos, _i, _dir] call BIS_fnc_relPos;
							_shelter = selectRandom _marketSheltersShort;
							if (random 1 > 0.25) then {
								_object = createVehicle [(_shelter select 0), _spawnPosNew, [], 0, "NONE"];		
								_object setDir _dir + (_shelter select 1) + _roadSide;
								_shelters pushBack _object;
								//_shelters pushBack ([(_shelter select 0), _spawnPosNew, _dir + (_shelter select 1) + _roadSide, "NONE"] call dro_createSimpleObject);						
							} else {						
								_object = createVehicle [(_shelter select 0), _spawnPosNew, [], 0, "NONE"];		
								_object setDir _dir + (_shelter select 1) + _roadSide;
								_shelters pushBack _object;
								//_shelters pushBack ([(_shelter select 0), _spawnPosNew, _dir + (_shelter select 1) + _roadSide, "NONE"] call dro_createSimpleObject);							 						
							};
							_stallPositions pushBack _spawnPosNew;					
						};				
					};
				} else {
					// Stall positions with no shelter
					_thisPos = getPos _thisRoad;
					_spawnPos = [_thisPos, 6, (_dir - 90)+_roadSide] call BIS_fnc_relPos;
					for "_i" from -2 to 2 step 4 do {
						_spawnPosNew = [_spawnPos, _i, _dir] call BIS_fnc_relPos;				
						_stallPositions pushBack _spawnPosNew;				
					};
				};
				{			
					if (random 1 > 0.25) then {					
						_thisStall = selectRandom _marketStalls;
						[(_thisStall select 0), _x, _dir + (_thisStall select 1) + _roadSide] call dro_createSimpleObject;
						if (random 1 > 0.4) then {
							_spawnPos = [_x, 2, (_dir + (selectRandom [0, 180]))] call BIS_fnc_relPos;					
							[selectRandom _marketObjects, _spawnPos, random 360] call dro_createSimpleObject;
						};
					} else {
						_numObjects = [0,2] call BIS_fnc_randomInt;
						for "_i" from 0 to _numObjects step 1 do {		
							_spawnPos = [_x, _i*2, (_dir + _roadSide)] call BIS_fnc_relPos;
							if (_numObjects == 0) then {
								[selectRandom _marketObjectsLarge, _spawnPos, random 360] call dro_createSimpleObject;
							} else {
								[selectRandom _marketObjects, _spawnPos, random 360] call dro_createSimpleObject;
							};
							
						};				
					};
				} forEach _stallPositions;
				if (!isNil "marketRoads") then {
					marketRoads pushBack _thisRoad;
				} else {
					marketRoads = [_thisRoad];
				};
				
			};
		};
	} forEach _allRoads;	
};
_return