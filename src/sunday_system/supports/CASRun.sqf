params ["_provider", "_supportCoords", "_CASType"];

_startPos = getPos _provider;
_providerClass = typeOf _provider;
_isPlane = if (_provider isKindOf "Plane") then {true} else {false};
_providerCfg = configfile >> "cfgvehicles" >> _providerClass;


// Collect weapons
_weapons = [];
_weaponTypes = [];
{		
	_modes = getarray (configfile >> "cfgweapons" >> _x >> "modes");
	if (count _modes > 0) then {_weapons pushBack _x};	
} foreach (_providerClass call bis_fnc_weaponsEntityType);

_dir = direction _provider;

_dis = 3000;
_alt = if (_isPlane) then {1000} else {250};
_pitch = atan (_alt / _dis);
_speed = if (_isPlane) then {400 / 3.6} else {200 / 3.6};
_duration = ([0,0] distance [_dis,_alt]) / _speed;

//--- Setup plane
_providerPos = [_supportCoords,_dis,_dir + 180] call bis_fnc_relpos;
_providerPos set [2,(_supportCoords select 2) + _alt];
_providerSide = (getNumber (_providerCfg >> "side")) call bis_fnc_sideType;

_provider setPosASL _providerPos;
_provider move ([_supportCoords,_dis,_dir] call bis_fnc_relpos);
_provider disableAI "move";
_provider disableAI "target";
_provider disableAI "autotarget";
_provider setCombatMode "blue";

_vectorDir = [_providerPos,_supportCoords] call bis_fnc_vectorFromXtoY;
_velocity = [_vectorDir,_speed] call bis_fnc_vectorMultiply;
_provider setVectorDir _vectorDir;
[_provider,-90 + atan (_dis / _alt),0] call bis_fnc_setpitchbank;
_vectorUp = vectorUp _provider;

//--- Remove all other weapons;
_currentWeapons = weapons _provider;
{
	if !(toLower ((_x call bis_fnc_itemType) select 1) in (_weaponTypes + ["countermeasureslauncher"])) then {
		_provider removeWeapon _x;
	};
} forEach _currentWeapons;
/*
//--- Debug - visualize tracers
if (false) then {
	BIS_draw3d = [];
	//{deletemarker _x} foreach allmapmarkers;
	_m = createMarker ["mkrDebug",_pos];
	_m setMarkerType "mil_dot";
	_m setMarkerSize [1,1];
	_m setMarkerColor "colorgreen";
	_provider addEventHandler [
		"fired",
		{
			_projectile = _this select 6;
			[_projectile,position _projectile] spawn {
				_projectile = _this select 0;
				_posStart = _this select 1;
				_posEnd = _posStart;
				_m = str _projectile;
				_mColor = "colorred";
				_color = [1,0,0,1];
				if (speed _projectile < 1000) then {
					_mColor = "colorblue";
					_color = [0,0,1,1];
				};
				while {!isnull _projectile} do {
					_posEnd = position _projectile;
					sleep 0.01;
				};
				createmarker [_m,_posEnd];
				_m setmarkertype "mil_dot";
				_m setmarkersize [1,1];
				_m setmarkercolor _mColor;
				BIS_draw3d set [count BIS_draw3d,[_posStart,_posEnd,_color]];
			};
		}
	];
	if (isnil "BIS_draw3Dhandler") then {
		BIS_draw3Dhandler = addmissioneventhandler ["draw3d",{{drawline3d _x;} foreach (missionnamespace getvariable ["BIS_draw3d",[]]);}];
	};
};
*/
//--- Approach
_fire = [] spawn {waituntil {false}};
_fireNull = true;
_time = time;
_offset = if ({_x == "missilelauncher"} count _weaponTypes > 0) then {20} else {0};
waituntil {
	_fireProgress = _provider getvariable ["fireProgress",0];

	//--- Set the plane approach vector
	_provider setVelocityTransformation [
		_providerPos, [_supportCoords select 0,_supportCoords select 1,(_supportCoords select 2) + _offset + _fireProgress * 12],
		_velocity, _velocity,
		_vectorDir,_vectorDir,
		_vectorUp, _vectorUp,
		(time - _time) / _duration
	];
	_provider setVelocity velocity _provider;

	//--- Fire!
	if ((getPosAsl _provider) distance _supportCoords < 1000 && _fireNull) then {

		//--- Create laser target		
		if (side group _provider == WEST) then {BIS_SUPP_laserTGT = "LaserTargetW" createVehicle _supportCoords};
		if (side group _provider == EAST) then {BIS_SUPP_laserTGT = "LaserTargetE" createVehicle _supportCoords};
		if (side group _provider == RESISTANCE) then {
			if (WEST getFriend RESISTANCE == 1) then {BIS_SUPP_laserTGT = "LaserTargetW" createVehicle _supportCoords} else {BIS_SUPP_laserTGT = "LaserTargetE" createVehicle _supportCoords}
		};
				
		_provider reveal laserTarget BIS_SUPP_laserTGT;
		_provider doWatch laserTarget BIS_SUPP_laserTGT;
		_provider doTarget laserTarget BIS_SUPP_laserTGT;

		_fireNull = false;
		terminate _fire;
		_fire = [_provider,_weapons, _CASType] spawn {
			_provider = _this select 0;
			_providerDriver = driver _provider;
			_weapons = _this select 1;
			_CASType = _this select 2;
			_duration = 3;
			_time = time + _duration;
			waitUntil {
				{
					//_provider selectweapon (_x select 0);
					//_providerDriver forceweaponfire _x;
					_providerDriver fireAtTarget [BIS_SUPP_laserTGT, _x];
				} forEach _weapons;
				_provider setVariable ["fireProgress",(1 - ((_time - time) / _duration)) max 0 min 1];
				sleep 0.1;
				time > _time || (_CASType == "CAS_Bombing") || isNull _provider //--- Shoot only for specific period or only one bomb
			};
			sleep 1;
		};
	};

	sleep 0.01;
	scriptDone _fire || isNull _provider
};
_provider setVelocity velocity _provider;
_provider flyInHeight _alt;
_provider enableAI "move";
_provider doMove _startPos;

//--- Fire CM
if (_CASType == "CAS_Bombing") then {
	for "_i" from 0 to 1 do {
		driver _provider forceWeaponFire ["CMFlareLauncher","Burst"];
		_time = time + 1.1;
		waitUntil {time > _time || isNull _provider};
	};
};

waitUntil {_provider distance _supportCoords > _dis || !alive _provider};
//--- Delete plane
if (alive _provider) then {
	_group = group _provider;
	_crew = crew _provider;
	deleteVehicle _provider;
	{deleteVehicle _x} foreach _crew;
	deleteGroup _group;
};
	