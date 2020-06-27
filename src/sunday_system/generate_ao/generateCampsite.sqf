params ["_center"];

_tents = [
	"Land_TentA_F",
	"Land_TentDome_F"
];
_fires = [
	"Land_Campfire_F",
	"Land_FirePlace_F"
];
_campObjects = [
	"Land_Sleeping_bag_F",
	"Land_Sleeping_bag_brown_F",
	"Land_CampingTable_F",
	"Land_Camping_Light_F",
	"Land_CampingChair_V2_F",
	"Land_CampingChair_V1_F",	
	"Land_GasCooker_F",	
	"Land_GasCanister_F",	
	"Land_Ground_sheet_khaki_F",	
	"Land_WoodenLog_F",
	"Land_WoodPile_F",
	"ShootingMat_01_Olive_F",
	"ShootingMat_01_Khaki_F",
	"Land_WoodenCrate_01_F"	
];

// Central fire
if (random 1 > 0.3) then {
	[(selectRandom _fires), _center, random 360] call dro_createSimpleObject;
};

_tentType = selectRandom _tents;
_numCampObjects = [7,10] call BIS_fnc_randomInt;
_dirMod = 360 / _numCampObjects;
_direction = (random 360);
_numTents = round (_numCampObjects * 0.3);
for "_i" from 1 to _numCampObjects step 1 do {	
	_spawnPos = [_center, (4 + random 1), _direction] call BIS_fnc_relPos;
	_selectedObject = if (_i <= _numTents) then {_tentType} else {selectRandom _campObjects};
	_object = createVehicle [_selectedObject, _spawnPos, [], 2, "NONE"];
	_object setDir ([_spawnPos, _center] call BIS_fnc_dirTo);
	_direction = _direction + _dirMod;
};