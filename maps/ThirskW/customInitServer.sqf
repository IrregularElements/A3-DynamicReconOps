// Disable rain
[] spawn {
	_rainLevel = rain;
	while {rain != 0} do {
		0 setRain 0;
		forceWeatherChange;
		999999 setRain 0;
		_sleeptime = 15 max (nextWeatherChange / 2);
		sleep _sleeptime;
		_rainLevel = rain;
	};
};


// Create snow storms
[] spawn {
	while {true} do {
		_sleeptime = [120, 240] call BIS_fnc_randomInt;

		_snowfall = true;
		_durationStorm = [round(_sleeptime * 0.6), round(_sleeptime * 0.9)] call BIS_fnc_randomInt;
		_ambientSounds = 30;
		_vapors = true;
		_snowburst = 0;
		_objects = false;
		_vanillaFog = true;
		_localFog = true;
		_intensifyWind = true;
		_sneeze = true;

		[[_snowfall, _durationStorm, _ambientSounds, _vapors, _snowburst, _objects,
		_vanillaFog, _localFog, _intensifyWind, _sneeze],
		"AL_snowstorm\al_snow.sqf"] remoteExec ["BIS_fnc_execVM", 0];

		_durationBeforeFogReduction = [round(_sleeptime*0.1), round(_sleeptime*0.7)] call BIS_fnc_randomInt;
		_fogReductionTime = [20, 40] call BIS_fnc_randomInt;
		_fogReductionValue = random [0.3, 0.4, 0.8];

		sleep _durationBeforeFogReduction;
		_fogReductionTime setFog (fog * _fogReductionValue);
		sleep (_sleeptime - _durationBeforeFogReduction);
	};
};
