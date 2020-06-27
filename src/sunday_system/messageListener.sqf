if (isNil "dro_messageStack") then {dro_messageStack = []};
while {true} do {
	sleep 3;	
	if (count dro_messageStack > 0) then {
		diag_log dro_messageStack;
		// Check the stack for any unplayed messages and play the first one
		_thisMessage = (dro_messageStack deleteAt 0);
		_message = (_thisMessage select 0);		
		_playAudio = (_thisMessage select 1);		
		if (getSubtitleOptions select 0) then {
			_message remoteExec ['BIS_fnc_EXP_camp_playSubtitles', 0];
		
			if (_playAudio) then {[] remoteExec ['sun_playSubtitleRadio', 0]};
		
			waitUntil {!isNil "bis_fnc_showsubtitle_subtitle"};
			waitUntil {!isNull bis_fnc_showsubtitle_subtitle};
			waitUntil {isNull bis_fnc_showsubtitle_subtitle};
		};
		
		/*
		if (!isNil "bis_fnc_showsubtitle_subtitle") then {
			waitUntil {sleep (random [2, 3, 2.5]); isNull bis_fnc_showsubtitle_subtitle};
		};
		*/			
	};
};