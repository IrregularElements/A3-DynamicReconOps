class SUN_loadScreen {
	idd = 888888;
	movingenable = false;
	class controls {
		class loadScreen: sundayText
		{
			idc = 8888;
			style = ST_CENTER;
			text = "";
			fade = 1;
			x = 0 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 1 * safezoneW;
			h = 1 * safezoneH;
			colorBackground[] = { 0, 0, 0, 0 };			
		};
		class loadScreenText: sundayText
		{
			idc = 8889;
			style = ST_CENTER;
			text = "";
			fade = 1;
			x = 0 * safezoneW + safezoneX;
			y = 0.5 * safezoneH + safezoneY;
			w = 1 * safezoneW;
			h = 0.5 * safezoneH;
			colorBackground[] = { 0, 0, 0, 0 };
			font = "RobotoCondensed";
			sizeEx = 0.035;
		};
	};	
};

class DRO_facade {
	idd = 999999;
	movingenable = false;
	class controls {
		class facade: sundayText
		{
			idc = 9999;
			text = "";
			x = -2 * safezoneW + safezoneX;
			y = -2 * safezoneH + safezoneY;
			w = 2 * safezoneW;
			h = 2 * safezoneH;
			colorBackground[] = { 0, 0, 0, 1 };
			font = "RobotoCondensed";
			sizeEx = 0.033;
		};
	};
};

class DRO_splash {
	idd = 999991;
	movingenable = false;
	class controls {
		class facade1: sundayText
		{
			idc = 1000;
			text = "";
			x = 0 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 0.2 * safezoneW;
			h = 1 * safezoneH;
			colorBackground[] = { 0, 0, 0, 1 };			
			fade = 0;
		};
		class facade2: sundayText
		{
			idc = 1001;
			text = "";
			x = 0.8 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 0.2 * safezoneW;
			h = 1 * safezoneH;
			colorBackground[] = { 0, 0, 0, 1 };			
			fade = 0;
		};	
		class splash: RscPicture
		{			
			idc = 1002;
			text = "images\DRO_splash_square.paa";
			x = 0.15 * safezoneW + safezoneX;
			y = 0.0 * safezoneH + safezoneY;
			w = 0.7 * safezoneW;
			h = 1 * safezoneH;
			fade = 0;
		};		
	};
};

