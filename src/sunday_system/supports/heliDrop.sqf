params ["_pos"];
hint "NEW";

// Create positions

_spawnPos = [startPos, 3000, ([_pos, startPos] call BIS_fnc_dirTo)] call BIS_fnc_relPos;
_spawnPos set [2, 150];
_destPos = [_pos, 3000, ([startPos, _pos] call BIS_fnc_dirTo)] call BIS_fnc_relPos;
_destPos set [2, 150];

// Create helicopter
_heliType = selectRandom pHeliClasses;
_heli = createVehicle [_heliType, _spawnPos, [], 0, "FLY"];
_heli setPos _spawnPos;
createVehicleCrew _heli;
_heli flyInHeight 150;
_heli setCaptive true;

dro_messageStack pushBack [
	[
		[str group ((crew _heli) select 0), "Supply drop en route.", 0]		
	],
	true
];	

//sleep 30;

// Get support types
_chuteType = ['B_Parachute_02_F', 'O_Parachute_02_F', 'I_Parachute_02_F'] select ([WEST, EAST, RESISTANCE] find playersSide); 
_crateType = ['B_supplyCrate_F', 'O_supplyCrate_F', 'I_supplyCrate_F'] select ([WEST, EAST, RESISTANCE] find playersSide);

// Create waypoints
_vehGroup = (group (driver _heli));
private _vWP0 = _vehGroup addWaypoint [(getPos _heli), 0];	
_vWP0 setWaypointBehaviour "CARELESS";
_vWP0 setWaypointCombatMode "GREEN";
_vWP0 setWaypointSpeed "NORMAL";
_vWP0 setWaypointType "MOVE";
	
private _vWP1 = _vehGroup addWaypoint [_pos, 0];
_vWP1 setWaypointType "MOVE";

private _fail = false;
_posAir = _pos;
_posAir set [2, 150];
while {_heli distance _posAir > 110} do {
	sleep 2;
	if (!alive _heli) exitWith {
		_fail = true;
	};
};

if (_fail) exitWith {
	dro_messageStack pushBack [
		[
			["Command", format ["We've lost contact with %1, supply drop cancelled.", driver _heli], 0]		
		],
		true
	];	
};

waitUntil {_heli distance _posAir < 110};

while {(count (waypoints (group (driver _heli)))) > 0} do {
	deleteWaypoint ((waypoints (group (driver _heli))) select 0);
};

_vWP2 = _vehGroup addWaypoint [_destPos, 0];
_vWP2 setWaypointType "MOVE";
_vWP2 setWaypointStatements ["true", "					
	deleteVehicle (vehicle this);
	{deleteVehicle _x} forEach thisList;	
"];

_chute = createVehicle [_chuteType, [100, 100, 200], [], 0, 'FLY'];
_chute setPos [(getPos _heli) select 0, (getPos _heli) select 1, ((getPos _heli) select 2) - 50];
//_chute setPos [_pos select 0, _pos select 1, ((getPos _heli) select 2) - 50];
_crate = createVehicle [_crateType, position _chute, [], 0, 'NONE'];

_crate attachTo [_chute, [0, 0, 0]];
//waitUntil {((velocity _crate) select 1 > 1) || isNull _chute};
//waitUntil {((velocity _crate) select 1 < 1) || isNull _chute};
//detach _crate;
//_chute setVelocity [0,5,0];

clearWeaponCargoGlobal _crate;
clearMagazineCargoGlobal _crate;
clearItemCargoGlobal _crate;

_crate addMagazineCargoGlobal ["SatchelCharge_Remote_Mag", 2];
_crate addMagazineCargoGlobal ["DemoCharge_Remote_Mag", 4];
_crate addItemCargoGlobal ["Medikit", 1];
_crate addItemCargoGlobal ["FirstAidKit", 10];

{
	//_magazines = magazines _x;
	_magazines = magazinesAmmoFull _x;
	
	{
		_crate addMagazineCargoGlobal [(_x select 0), 2];
	} forEach _magazines;	
} forEach (units (grpNetId call BIS_fnc_groupFromNetId));
[_crate, (grpNetId call BIS_fnc_groupFromNetId)] call sun_supplyBox;
//waitUntil {(((position _crate) select 2) < 100)};


waitUntil {((((position _crate) select 2) < 0.6) || (isNil "_chute"))};

detach _crate;
_crate setVelocity [0,0,-5];
sleep 0.3;
_crate setPos [(position _crate) select 0, (position _crate) select 1, 1];
_crate setVelocity [0,0,0];  

_markerName = format["supplyMkr%1", floor(random 10000)];
_markerSupply = createMarker [_markerName, (getPos _crate)];
_markerSupply setMarkerShape "ICON";
_markerSupply setMarkerType  "mil_flag";
_markerSupply setMarkerColor markerColorPlayers;
_markerSupply setMarkerText "Supply drop";	

