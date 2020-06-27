class DRO_lobbyDialog {
	idd = 626262;
	movingenable = false;
	
	class controls {		
		class menuBackground1: sundayText {
			idc = 1050;		
			x = "safezoneX + (0 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (0 * pixelGridNoUIScale * pixelH)";
			w = "40 * pixelGridNoUIScale * pixelW";	
			h = safezoneH;
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };
			text = "";
		};
		class teamPlanningTitle: sundayHeading
		{
			idc = 1098;			
			text = "TEAM PLANNING";
			x = "safezoneX + (0 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (0 * pixelGridNoUIScale * pixelH)";
			w = "40 * pixelGridNoUIScale * pixelW";	
			h = "15 * pixelGridNoUIScale * pixelH";
			sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 5) * 0.5";					
		};		
		class sundayTitleChoose: sundayHeading
		{
			idc = 1101;			
			style = ST_CENTER;
			text = "SQUAD LOADOUT";
			x = "safezoneX + (0 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (15.5 * pixelGridNoUIScale * pixelH)";
			w = "40 * pixelGridNoUIScale * pixelW";	
			h = "3 * pixelGridNoUIScale * pixelH";		
			sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.5) * 0.5";
			colorBackground[] = {0.20,0.40,0.65,1};
		};			
		class menuLeft: DROBasicButton
		{			
			idc = 1150;
			text = "<";
			x = "safezoneX + (0 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (15.5 * pixelGridNoUIScale * pixelH)";
			w = "2.5 * pixelGridNoUIScale * pixelW";	
			h = "3 * pixelGridNoUIScale * pixelH";
			sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 2) * 0.5";
			action = "['LEFT', (findDisplay 626262)] spawn dro_menuSlider";
			soundClick[] = {"A3\missions_f\data\sounds\border_out.ogg",1,1.3};
		};
		class menuRight: DROBasicButton
		{			
			idc = 1151;
			text = ">";
			x = "safezoneX + (37.5 * pixelGridNoUIScale * pixelW)";
			y = "safezoneY + (15.5 * pixelGridNoUIScale * pixelH)";
			w = "2.5 * pixelGridNoUIScale * pixelW";	
			h = "3 * pixelGridNoUIScale * pixelH";
			sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 2) * 0.5";		
			action = "['RIGHT', (findDisplay 626262)] spawn dro_menuSlider";	
			soundClick[] = {"A3\missions_f\data\sounds\border_in.ogg",1,1.3};			
		};
		class loadoutGroup: RscControlsGroup {
			idc = 6060;			
			x = safezoneX;
			y = "safezoneY + (20 * pixelGridNoUIScale * pixelH)";
			w = "40 * pixelGridNoUIScale * pixelW";			
			h = "46 * pixelGridNoUIScale * pixelH";					
		};
		class unitTextBG: sundayText {
			idc = 1159;
			text = "";			
			x = 0.73 * safezoneW + safezoneX;			
			y = 0.14 * safezoneH + safezoneY;
			w = 0.27 * safezoneW;
			h = 0.1 * safezoneH;			
			colorBackground[] = { 0.1, 0.1, 0.1, 0.6 };			
		};		
		class unitText: sundayTextMT {
			idc = 1160;
			text = "";			
			x = 0.74 * safezoneW + safezoneX;			
			y = 0.15 * safezoneH + safezoneY;
			w = 0.26 * safezoneW;
			h = 0.08 * safezoneH;
			font = "RobotoCondensed";					
			sizeEx = 0.02 * safezoneH;
		};		
		class previewMap: DROBasicButton
		{
			idc = 1161;
			style = 48 + 2048;			
			text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\map_ca.paa";			
			x = safezoneX;
			y = "safezoneH - (4 * pixelGridNoUIScale * pixelH)";
			w = "4 * pixelGridNoUIScale * pixelW";
			h = "4 * pixelGridNoUIScale * pixelH";			
			action = "[] spawn sun_lobbyMapPreview";
		};
		class insertGroup: RscControlsGroup {
			idc = 6070;			
			x = -0.4 * safezoneW + safezoneX;			
			y = "safezoneY + (20 * pixelGridNoUIScale * pixelH)";
			w = "40 * pixelGridNoUIScale * pixelW";			
			h = "46 * pixelGridNoUIScale * pixelH";		
			class Controls {
				class lobbySelectStartText: sundayText {
					idc = 6006;
					text = "Insertion position: RANDOM";
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "0 * pixelGridNoUIScale * pixelH";
					w = "33 * pixelGridNoUIScale * pixelW";	
					h = "1.5 * pixelGridNoUIScale * pixelH";
				};							
				class lobbySelectStartClear: DROBasicButton
				{			
					idc = 6005;
					text = "Clear Insert Location";
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "2.5 * pixelGridNoUIScale * pixelH";
					w = "16.75 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";				
					action = "[] call sun_clearInsert;";		
				};
				class lobbySelectStart: DROBasicButton
				{			
					idc = 6004;
					text = "Set Insert Location";
					x = "20 * pixelGridNoUIScale * pixelW";
					y = "2.5 * pixelGridNoUIScale * pixelH";
					w = "16.75 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";		
					action = "_nil=[]ExecVM 'sunday_system\dialogs\selectStart.sqf';";		
				};					
				class lobbySelectInsertText: sundayText {
					idc = 6007;
					text = "Insertion type";
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "7 * pixelGridNoUIScale * pixelH";
					w = "33 * pixelGridNoUIScale * pixelW";	
					h = "1.5 * pixelGridNoUIScale * pixelH";				
				};				
				class lobbyComboInsert: DROCombo
				{
					idc = 6009;
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "9 * pixelGridNoUIScale * pixelH";
					w = "16.75 * pixelGridNoUIScale * pixelW";	
					h = "1.75 * pixelGridNoUIScale * pixelH";					
					onLBSelChanged = "insertType = (_this select 1); publicVariable 'insertType'; profileNamespace setVariable ['DRO_insertType', insertType]; if (insertType > 1) then {((findDisplay 626262) displayCtrl 6021) ctrlEnable false; ((findDisplay 626262) displayCtrl 6022) ctrlEnable false;} else {((findDisplay 626262) displayCtrl 6021) ctrlEnable true; ((findDisplay 626262) displayCtrl 6022) ctrlEnable true;};";					
				};
				class lobbySelectVehText: sundayText {
					idc = 6020;
					text = "Starting ground vehicle(s)";
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "12 * pixelGridNoUIScale * pixelH";
					w = "33 * pixelGridNoUIScale * pixelW";	
					h = "1.5 * pixelGridNoUIScale * pixelH";	
					tooltip = "Picks a custom ground vehicle for insertion. If the chosen vehicle does not have enough room for all units additional random vehicles will be chosen.";
				};	
				class lobbyComboVeh: DROCombo
				{
					idc = 6021;
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "14 * pixelGridNoUIScale * pixelH";
					w = "16.75 * pixelGridNoUIScale * pixelW";	
					h = "1.75 * pixelGridNoUIScale * pixelH";	
					//rowHeight = 0.1;			
					onLBSelChanged = "startVehicles set [0, (_this select 0) lbData (_this select 1)]; publicVariable 'startVehicles'";					
				};
				class lobbyComboVeh2: DROCombo
				{
					idc = 6022;
					x = "20 * pixelGridNoUIScale * pixelW";
					y = "14 * pixelGridNoUIScale * pixelH";
					w = "16.75 * pixelGridNoUIScale * pixelW";	
					h = "1.75 * pixelGridNoUIScale * pixelH";
					//rowHeight = 0.1;			
					onLBSelChanged = "startVehicles set [1, (_this select 0) lbData (_this select 1)]; publicVariable 'startVehicles'";				
				};
				
			};
		};	
		class supportsGroup: RscControlsGroup {
			idc = 6080;			
			x = -0.4 * safezoneW + safezoneX;			
			y = "safezoneY + (20 * pixelGridNoUIScale * pixelH)";
			w = "40 * pixelGridNoUIScale * pixelW";			
			h = "46 * pixelGridNoUIScale * pixelH";		
			class Controls {
				class lobbySupportCombo: DROCombo
				{
					idc = 6010;
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "0 * pixelGridNoUIScale * pixelH";
					w = "34 * pixelGridNoUIScale * pixelW";	
					h = "2 * pixelGridNoUIScale * pixelH";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.5) * 0.5";						
					onLBSelChanged = "randomSupports = (_this select 1); publicVariable 'randomSupports'; profileNamespace setVariable ['DRO_randomSupports', randomSupports];";					
				};
				class lobbySupportSupply: DROBasicButton
				{			
					idc = 6011;
					text = "Supply Drop";
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "5 * pixelGridNoUIScale * pixelH";	
					w = "34 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";		
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";	
					action = "if ('SUPPLY' in customSupports) then {customSupports = customSupports - ['SUPPLY']; ((findDisplay 626262) displayCtrl 6011) ctrlSetTextColor [1, 1, 1, 1]} else {customSupports pushBackUnique 'SUPPLY'; ((findDisplay 626262) displayCtrl 6011) ctrlSetTextColor [0.05, 1, 0.5, 1]}; lbSetCurSel [6010, 1]; publicVariable 'customSupports';  randomSupports = 1; publicVariable 'randomSupports'; profileNamespace setVariable ['DRO_supportPrefs', customSupports]; profileNamespace setVariable ['DRO_randomSupports', randomSupports];";		
				};
				class lobbySupportArty: DROBasicButton
				{			
					idc = 6012;
					text = "Artillery";
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "8.25 * pixelGridNoUIScale * pixelH";	
					w = "34 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";				
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";	
					action = "if ('ARTY' in customSupports) then {customSupports = customSupports - ['ARTY']; ((findDisplay 626262) displayCtrl 6012) ctrlSetTextColor [1, 1, 1, 1]} else {customSupports pushBackUnique 'ARTY'; ((findDisplay 626262) displayCtrl 6012) ctrlSetTextColor [0.05, 1, 0.5, 1]}; lbSetCurSel [6010, 1]; publicVariable 'customSupports';  randomSupports = 1; publicVariable 'randomSupports'; profileNamespace setVariable ['DRO_supportPrefs', customSupports]; profileNamespace setVariable ['DRO_randomSupports', randomSupports];";		
				};
				class lobbySupportCAS: DROBasicButton
				{			
					idc = 6013;
					text = "CAS";
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "11.5 * pixelGridNoUIScale * pixelH";	
					w = "34 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";			
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";	
					action = "if ('CAS' in customSupports) then {customSupports = customSupports - ['CAS']; ((findDisplay 626262) displayCtrl 6013) ctrlSetTextColor [1, 1, 1, 1]} else {customSupports pushBackUnique 'CAS'; ((findDisplay 626262) displayCtrl 6013) ctrlSetTextColor [0.05, 1, 0.5, 1]}; lbSetCurSel [6010, 1]; publicVariable 'customSupports';  randomSupports = 1; publicVariable 'randomSupports'; profileNamespace setVariable ['DRO_supportPrefs', customSupports]; profileNamespace setVariable ['DRO_randomSupports', randomSupports];";		
				};
				class lobbySupportUAV: DROBasicButton
				{			
					idc = 6014;
					text = "UAV";
					x = "3 * pixelGridNoUIScale * pixelW";
					y = "14.75 * pixelGridNoUIScale * pixelH";	
					w = "34 * pixelGridNoUIScale * pixelW";	
					h = "3 * pixelGridNoUIScale * pixelH";		
					onMouseEnter = "";
					onMouseExit = "";
					sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.75) * 0.5";	
					action = "if ('UAV' in customSupports) then {customSupports = customSupports - ['UAV']; ((findDisplay 626262) displayCtrl 6014) ctrlSetTextColor [1, 1, 1, 1]} else {customSupports pushBackUnique 'UAV'; ((findDisplay 626262) displayCtrl 6014) ctrlSetTextColor [0.05, 1, 0.5, 1]}; lbSetCurSel [6010, 1]; publicVariable 'customSupports';  randomSupports = 1; publicVariable 'randomSupports'; profileNamespace setVariable ['DRO_supportPrefs', customSupports]; profileNamespace setVariable ['DRO_randomSupports', randomSupports];";		
				};						
			};
		};
		class sundayStartButton: DROBigButton
		{
			idc = 1601;
			text = "READY";
			x = "(safezoneX + safezoneW) - (23 * pixelGridNoUIScale * pixelW)";
			y = "(safezoneY + safezoneH) - (4 * pixelGridNoUIScale * pixelH)";			
			w = "23 * pixelGridNoUIScale * pixelW";
			h = "4 * pixelGridNoUIScale * pixelH";	
			sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 2.5) * 0.5";	
			action = "[] call sun_lobbyReadyButton;";			
		};		
	};
};





