disableSerialization;
{	
	if (ctrlIDC _x >= 3000) then {
		((findDisplay 52525) displayCtrl (ctrlIDC _x)) ctrlCommit 0.3;
	}; 		
} forEach (allControls findDisplay 52525);
