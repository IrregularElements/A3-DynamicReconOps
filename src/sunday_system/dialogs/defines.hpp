
// Control types
#define CT_STATIC           0
#define CT_BUTTON           1
#define CT_EDIT             2
#define CT_SLIDER           3
#define CT_COMBO            4
#define CT_LISTBOX          5
#define CT_TOOLBOX          6
#define CT_CHECKBOXES       7
#define CT_PROGRESS         8
#define CT_HTML             9
#define CT_STATIC_SKEW      10
#define CT_ACTIVETEXT       11
#define CT_TREE             12
#define CT_STRUCTURED_TEXT  13
#define CT_CONTEXT_MENU     14
#define CT_CONTROLS_GROUP   15
#define CT_SHORTCUTBUTTON   16
#define CT_XKEYDESC         40
#define CT_XBUTTON          41
#define CT_XLISTBOX         42
#define CT_XSLIDER          43
#define CT_XCOMBO           44
#define CT_ANIMATED_TEXTURE 45
#define CT_OBJECT           80
#define CT_OBJECT_ZOOM      81
#define CT_OBJECT_CONTAINER 82
#define CT_OBJECT_CONT_ANIM 83
#define CT_LINEBREAK        98
#define CT_USER             99
#define CT_MAP              100
#define CT_MAP_MAIN         101
#define CT_LISTNBOX         102

// Static styles
#define ST_POS            0x0F
#define ST_HPOS           0x03
#define ST_VPOS           0x0C
#define ST_LEFT           0x00
#define ST_RIGHT          0x01
#define ST_CENTER         0x02
#define ST_DOWN           0x04
#define ST_UP             0x08
#define ST_VCENTER        0x0C
#define ST_GROUP_BOX       96
#define ST_GROUP_BOX2      112
#define ST_ROUNDED_CORNER  ST_GROUP_BOX + ST_CENTER
#define ST_ROUNDED_CORNER2 ST_GROUP_BOX2 + ST_CENTER

#define ST_TYPE           0xF0
#define ST_SINGLE         0x00
#define ST_MULTI          0x10
#define ST_TITLE_BAR      0x20
#define ST_PICTURE        0x30
#define ST_FRAME          0x40
#define ST_BACKGROUND     0x50
#define ST_GROUP_BOX      0x60
#define ST_GROUP_BOX2     0x70
#define ST_HUD_BACKGROUND 0x80
#define ST_TILE_PICTURE   0x90
#define ST_WITH_RECT      0xA0
#define ST_LINE           0xB0

#define ST_SHADOW         0x100
#define ST_NO_RECT        0x200
#define ST_KEEP_ASPECT_RATIO  0x800

#define ST_TITLE          ST_TITLE_BAR + ST_CENTER

// Slider styles
#define SL_DIR            0x400
#define SL_VERT           0
#define SL_HORZ           0x400

#define SL_TEXTURES       0x10

// progress bar 
#define ST_VERTICAL       0x01
#define ST_HORIZONTAL     0

// Listbox styles
#define LB_TEXTURES       0x10
#define LB_MULTI          0x20

// Tree styles
#define TR_SHOWROOT       1
#define TR_AUTOCOLLAPSE   2

// MessageBox styles
#define MB_BUTTON_OK      1
#define MB_BUTTON_CANCEL  2
#define MB_BUTTON_USER    4


////////////////
//Base Classes//
////////////////



class sundayHeading
{
    access = 0;
    idc = -1;
	fade = 1;	
    type = CT_STATIC;
    style = ST_CENTER;
    linespacing = 1;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    text = "";
    shadow = 0;
    font = "RobotoCondensed";
    sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 2) * 0.5";
    fixedWidth = 0;
    x = 0;
    y = 0;
    h = 0;
    w = 0;
   
};

class sundayText
{
    access = 0;
    idc = -1;
	fade = 1;	
    type = CT_STATIC;
    style = ST_LEFT;
    linespacing = 1;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    text = "";
    shadow = 0;
    font = "RobotoCondensed";
    sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.25) * 0.5";
    fixedWidth = 0;
    x = 0;
    y = 0;
    h = 0;
    w = 0;
   
};

class sundayTextMT
{
    access = 0;
    idc = -1;
	fade = 1;	
    type = CT_STATIC;
    style = ST_MULTI;
    linespacing = 1;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    text = "";
    shadow = 0;
    font = "RobotoCondensed";
    sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.2) * 0.5";
    fixedWidth = 0;
    x = 0;
    y = 0;
    h = 0;
    w = 0;   
};

class sundaySelButtonPic
{			
	idc = -1;
	access = 0;
	type = CT_STATIC;   
	style = ST_PICTURE + ST_KEEP_ASPECT_RATIO;
	text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\navigate_ca.paa";	
	fade = 1;
    colorBackground[] = {0,0,0,1};
    colorText[] = {1,1,1,0.3};
    font = "PuristaLight";
    sizeEx = 0;
    lineSpacing = 0;    
    fixedWidth = 0;
    shadow = 0;  	
	x = "0.5 * pixelGridNoUIScale * pixelW";
	y = 0;	
	w = "3 * pixelGridNoUIScale * pixelW";
	h = "3 * pixelGridNoUIScale * pixelH";
};

class sundaySelButtonTitle
{
    access = 0;
    idc = -1;
	fade = 1;	
    type = CT_STATIC;
    style = ST_LEFT; 
    linespacing = 0;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
	colorShadow[] = {0,0,0,0.5};
    text = "";
    shadow = 0;
    font = "PuristaMedium";    
	sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.25) * 0.5";	
    fixedWidth = 0;   
	x = "3.5 * pixelGridNoUIScale * pixelW";
	y = 0;		
	w = "11 * pixelGridNoUIScale * pixelW";
	h = "3 * pixelGridNoUIScale * pixelH";
};

class sundaySelButtonSelect
{
    access = 0;
    idc = -1;
	fade = 1;	
    type = CT_STATIC;
    style = ST_RIGHT;
    linespacing = 0;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
	colorShadow[] = {0,0,0,0.5};
    text = "";
    shadow = 0;
    font = "PuristaMedium";   
	sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.5) * 0.5";	
    fixedWidth = 0;   
	x = "11.5 * pixelGridNoUIScale * pixelW";
	y = 0;	
	w = "12 * pixelGridNoUIScale * pixelW";
	h = "3 * pixelGridNoUIScale * pixelH";
};

class sundaySelButton {
	idc = -1;
	access = 0;
    type = CT_BUTTON;
	style = 2;
    text = "";
	fade = 1;
	colorBackground[] = {0,0,0,0.3};
	//colorActive[] = {0,0,0,1};
	colorBackgroundActive[] = {0,0,0,0.1};
	colorBackgroundDisabled[] = {0.17,0.17,0.17,0.2};
	colorBorder[] = {0,0,0,1};
	colorDisabled[] = {1,1,1,0};
	colorFocused[] = {0,0,0,0.3};
	colorShadow[] = {0,0,0,0};
	colorText[] = {1,1,1,1};
	
	onMouseEnter = "(_this select 0) ctrlsettextcolor [0,0,0,1];";
	onMouseExit = "(_this select 0) ctrlsettextcolor [1,1,1,1];";
				
	soundEnter[] = {"\A3\ui_f\data\sound\ReadOut\readoutHideClick2",0.75,1};
	soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.08,0};
	soundClick[] = {"\A3\ui_f\data\sound\ReadOut\readoutHideClick1",4,1};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.07,1};
	
	sizeEx = 0.033;
	shadow = 0;
    font = "RobotoCondensed";
	borderSize = 0;	
    offsetX = 0.00;
    offsetY = 0.00;
    offsetPressedX = 0.00;
    offsetPressedY = 0.00;
	
	x = 0;
	y = 0;
	//w = 0.16 * safezoneW; 
	//w = "16 * (((safezoneW / safezoneH) min 1.2) / 40)";
	w = "24 * pixelGridNoUIScale * pixelW";
	h = "4 * pixelGridNoUIScale * pixelW";
	//h = 0.04 * safezoneH;
};


class DROCombo {
	idc = -1;
	access = 0;
	fade = 1;
	type = CT_COMBO;
	style = ST_LEFT;
	w = 0.1 * safezoneW;
	h = 0.025 * safezoneH;
	x = 0 * safezoneW + safezoneX;
	y = 0 * safezoneH + safezoneY;
	sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.25) * 0.5";
	rowHeight = "((pixelH * (pixelGridNoUIScale) * 2) * 1.3) * 0.5";
	wholeHeight = "((pixelH * (pixelGridNoUIScale) * 2) * 25) * 0.5";
	
	colorSelect[] = {0,0,0,1};
	colorText[] = {1,1,1,1};
	colorDisabled[] = {1,1,1,0.85}; // Disabled text color
	colorBackground[] = {0,0,0,0.85};
	colorSelectBackground[] = {0.20,0.40,0.65,0.9}; // Selected item fill color
	colorScrollbar[] = {1,1,1,0.85};
	font = "RobotoCondensed";
	
	soundSelect[] = {"\a3\Ui_f\data\Sound\ReadOut\readoutClick",0.5,1};
	soundExpand[] = {"\A3\ui_f\data\sound\ReadOut\readoutHideClick2",0.75,1};
	soundCollapse[] = {"\A3\ui_f\data\sound\ReadOut\readoutHideClick2",0.5,1};
	maxHistoryDelay = 1.0;
	shadow = 0;
	
	arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_ca.paa"; // Expand arrow
	arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa"; // Collapse arrow
	
	class ComboScrollBar
	{
		width = 0.05; // width of ComboScrollBar
		height = 0; // height of ComboScrollBar
		scrollSpeed = 0.01; // scrollSpeed of ComboScrollBar

		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa"; // Arrow
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa"; // Arrow when clicked on
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa"; // Slider background (stretched vertically)
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa"; // Dragging element (stretched vertically)

		color[] = {1,1,1,1}; // Scrollbar color
	};
	
};

class sundaySpacer: sundayText {
	access = 0;
    idc = -1;	
    colorBackground[] = {1,1,1,0.6};    
    text = "";
    x = "1 * pixelGridNoUIScale * pixelW";
    y = 0;
	w = "24 * pixelGridNoUIScale * pixelW";	
	h = "0.1 * pixelGridNoUIScale * pixelH";
	//h = 0.002 * safezoneH;
    //w = 0.16 * safezoneW;	
};

class DROLoadoutSwitch: DROCombo {	
	sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.25) * 0.5";
	rowHeight = "((pixelH * (pixelGridNoUIScale) * 2) * 1.3) * 0.5";
	wholeHeight = "((pixelH * (pixelGridNoUIScale) * 2) * 25) * 0.5";	
}

class DROToolBoxMenu {
    idc = -1;	
    type = CT_TOOLBOX;
    style = ST_CENTER;
	fade = 1;
	
	w = 0.10 * safezoneW;
	h = 0.025 * safezoneH;
    
	font = "RobotoCondensed";
	
	colorBackground[] = {0.1, 0.1, 0.1, 1};
    colorText[] = {1, 1, 1, 1};
    color[] = {0, 1, 0, 1};
    colorTextSelect[] = {0, 0, 0, 1};
    colorSelect[] = {1, 1, 1, 1};
	colorSelectedBg[] = {0.20,0.40,0.65,1};
    colorTextDisable[] = {0.4, 0.4, 0.4, 1};
    colorDisable[] = {0.4, 0.4, 0.4, 1};
 
	sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1) * 0.5";	
    
    rows = 1;
    columns = 1;
    strings[] = {};
	
	
		
};

class DROCheckBoxRemove {
    idc = -1;
    type = CT_CHECKBOXES;
    style = ST_CENTER;
	fade = 1;
    
    x = 0.1;
    y = 0.18;
	w = 0.02 * safezoneW;
	h = 0.02 * safezoneH;
    
	font = "RobotoCondensed";
	
	colorBackground[] = {0.2, 0.2, 0.2, 1};
    colorText[] = {0.1, 0.8, 0, 1};
    color[] = {0, 1, 0, 1};
	colorTextSelect[] = {0.8, 0, 0, 1};    
    colorSelect[] = {0, 0, 0, 1};
	colorSelectedBg[] = {0.1, 0.1, 0.1, 1};
    colorTextDisable[] = {0.4, 0.4, 0.4, 1};
    colorDisable[] = {0.4, 0.4, 0.4, 1};
	
	sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1) * 0.75";
    
    rows = 1;
    columns = 1;
    checked_strings[] = {"X"};
	strings[] = {"√"};
};

class DROCheckBoxSupports {
    idc = -1;
    type = CT_CHECKBOXES;
    style = ST_CENTER;
	fade = 1;
    
    x = 0.1;
    y = 0.18;
	w = 0.1 * safezoneW;
	h = 0.09 * safezoneH;
    
	font = "RobotoCondensed";
	
	colorBackground[] = {0.17,0.17,0.17,1};
    colorText[] = {1, 1, 1, 1};
    color[] = {0, 1, 0, 1};
    colorTextSelect[] = {0.20,0.40,0.65,1};
    colorSelect[] = {1, 1, 1, 1};
	colorSelectedBg[] = {0.17,0.17,0.17,1};
    colorTextDisable[] = {0.4, 0.4, 0.4, 1};
    colorDisable[] = {0.4, 0.4, 0.4, 1};
 
	sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1) * 0.5";
    
    rows = 3;
    columns = 1;
    strings[] = {"Supply drop", "Artillery", "CAS", "UAV"};		
};


class DROBigButton {
	access = 0;
    type = CT_BUTTON;
	style = 2;
    text = "";
	fade = 1;
	
	colorText[] = {1,1,1,1};
	colorActive[] = {1,1,1,1};
    colorDisabled[] = {0.17,0.17,0.17,0.85};
	colorBackground[] = {0.17,0.17,0.17,0.85};
    colorBackgroundDisabled[] = {0,0,0,0.85};
    colorBackgroundActive[] = {0.20,0.40,0.65,0.85};
    colorFocused[] = {0.17,0.17,0.17,0.85};
    colorShadow[] = {0,0,0,1};
    colorBorder[] = {0,0,0,1};
	
    soundEnter[] = {"\A3\ui_f\data\sound\ReadOut\readoutHideClick2",0.75,1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.08,0};
    soundClick[] = {"\A3\ui_f\data\sound\ReadOut\readoutHideClick1",4,1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.07,1};
    
	onMouseEnter = "(_this select 0) ctrlsettextcolor [0,0,0,1];";
	onMouseExit = "(_this select 0) ctrlsettextcolor [1,1,1,1];";
	
    x = 0;
    y = 0;
    w = 0.055589;
    h = 0.039216;
    shadow = 0;
    font = "RobotoCondensed";
    sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.5) * 0.5";
    offsetX = 0.00;
    offsetY = 0.00;
    offsetPressedX = 0.00;
    offsetPressedY = 0.00;
    borderSize = 0;
		
};


class DROBasicButton {
	access = 0;
    type = CT_BUTTON;
	style = 2;
    text = "";
	fade = 1;
	
	colorBackground[] = {0.17,0.17,0.17,0.85};
	//colorActive[] = {0,0,0,1};
	colorBackgroundActive[] = {0.20,0.40,0.65,0.85};
	colorBackgroundDisabled[] = {0.17,0.17,0.17,0.85};
	colorBorder[] = {0,0,0,1};
	colorDisabled[] = {1,1,1,0.25};
	colorFocused[] = {0.17,0.17,0.17,0.85};
	colorShadow[] = {0,0,0,0};
	colorText[] = {1,1,1,1};
	
	//onKillFocus = "(_this select 0) ctrlsettextcolor [1,1,1,1];";
	onMouseEnter = "(_this select 0) ctrlsettextcolor [0,0,0,1];";
	onMouseExit = "(_this select 0) ctrlsettextcolor [1,1,1,1];";
	//onSetFocus = "(_this select 0) ctrlsettextcolor [0,0,0,1];";
	
    soundEnter[] = {"\A3\ui_f\data\sound\ReadOut\readoutHideClick2",0.75,1};
    soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.08,0};
    soundClick[] = {"\A3\ui_f\data\sound\ReadOut\readoutHideClick1",4,1};
    soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.07,1};
    
    x = 0;
    y = 0;
    w = 0.055589;
    h = 0.039216;
    shadow = 0;
    font = "PuristaMedium";
	sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.25) * 0.5";
    offsetX = 0.00;
    offsetY = 0.00;
    offsetPressedX = 0.00;
    offsetPressedY = 0.00;
    borderSize = 0;
		
};

class DRONameButton: DROBasicButton{
	style = 0;	
	onMouseEnter = "";
	onMouseExit = "";
	sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.25) * 0.5";
};

class DROVAButton: DROBasicButton {
	style = 48 + 2048;
	text = "\A3\ui_f\data\igui\cfg\simpleTasks\types\rifle_ca.paa";		
	sizeEx = "((pixelH * (pixelGridNoUIScale) * 2) * 1.25) * 0.5";
};

class sundaySlider {
	idc = -1; 
	style = SL_HORZ;
	type = CT_SLIDER;
    x = -0.2; 
    y = 0; 
    w = 0.14; 
    h = 0.025; 
    color[] = {1,1,1,0.8};
	colorActive[] = {1,1,1,1};
	deletable = 0;   
	shadow = 0;    
};

class RscPicture
{
    access = 0;
    idc = -1;
    type = CT_STATIC;
    style = ST_PICTURE;
	fade = 1;
    colorBackground[] = {0,0,0,0};
    colorText[] = {1,1,1,1};
    font = "PuristaLight";
    sizeEx = 0;
    lineSpacing = 0;
    text = "";
    fixedWidth = 0;
    shadow = 0;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.15;
};

class RscControlsGroupNoScrollbars
{
	class VScrollbar
	{
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		color[] = {1,1,1,1};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		autoScrollDelay = 5;
		autoScrollEnabled = 1;
		autoScrollRewind = 0;
		autoScrollSpeed = -1;
		scrollSpeed = 0.06;
		width = 0;
		height = 0;
		shadow = 0;
	};
	class HScrollbar
	{
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		color[] = {1,1,1,1};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		autoScrollDelay = 5;
		autoScrollEnabled = 0;
		autoScrollRewind = 0;
		autoScrollSpeed = -1;
		scrollSpeed = 0.06;
		width = 0;
		height = 0;
		shadow = 0;
	};	
	class Controls
	{
	};
	type = 15;
	idc = -1;
	x = "1 * pixelGridNoUIScale * pixelW";
	y = "0 * pixelGridNoUIScale * pixelH";					
	w = "24 * pixelGridNoUIScale * pixelW";	
	h = "4 * pixelGridNoUIScale * pixelH";
	shadow = 1;
	style = 16;
	fade = 0;
};

class RscControlsGroup
{
	class VScrollbar
	{
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		color[] = {1,1,1,1};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		autoScrollDelay = 5;
		autoScrollEnabled = 1;
		autoScrollRewind = 0;
		autoScrollSpeed = -1;
		scrollSpeed = 0.06;
		width = 0.021;
		height = 0;
		shadow = 0;
	};
	class HScrollbar
	{
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		color[] = {1,1,1,1};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		autoScrollDelay = 5;
		autoScrollEnabled = 0;
		autoScrollRewind = 0;
		autoScrollSpeed = -1;
		scrollSpeed = 0.06;
		width = 0;
		height = 0.028;
		shadow = 0;
	};	
	class Controls
	{
	};
	type = 15;
	idc = -1;
	x = 0;
	y = 0;
	w = 1;
	h = 1;
	shadow = 1;
	style = 16;
	fade = 0;
};

class RscMapControl
{
	access = 0;
	idc = -1;
	type = CT_MAP_MAIN;
	style = ST_PICTURE;
	fade = 1;
	
	x =0 * safezoneW + safezoneX;
	y = 0 * safezoneH + safezoneY;
	w = 0 * safezoneW;
	h = 0 * safezoneH;
	
	alphaFadeStartScale = 2;
	alphaFadeEndScale = 2;	
	colorBackground[] = {0.369,0.457,0.949,0.2};
	colorCountlines[] = {0.572,0.354,0.188,0.25};
	colorCountlinesWater[] = {0.491,0.577,0.702,0};
	colorForest[] = {0.624,0.78,0.388,0};
	colorForestBorder[] = {0,0,0,0};
	colorGrid[] = {0.1,0.1,0.1,0};
	colorGridMap[] = {0.1,0.1,0.1,0};
	colorInactive[] = {1,1,1,0.5};
	colorLevels[] = {0.286,0.177,0.094,0};
	colorMainCountlines[] = {0.572,0.354,0.188,0.5};
	colorMainCountlinesWater[] = {0.491,0.577,0.702,0};
	colorMainRoads[] = {0.65,0.5,0.3,1};  
	colorMainRoadsFill[] = {0.7,0.6,0.4,1};
	colorNames[] = {0.1,0.1,0.1,0.9};
	colorOutside[] = {0,0,0,1};
	colorPowerLines[] = {0.1,0.1,0.1,0};
	colorRailWay[] = {0.8,0.2,0,1};
	colorRoads[] = {0.7,0.7,0.7,1};
	colorRoadsFill[] = {1,1,1,1};
	colorRocks[] = {0,0,0,0};
	colorRocksBorder[] = {0,0,0,0};  
	colorSea[] = {0.467,0.631,0.851,0};
	colorText[] = {0,0,0,1};
	colorTracks[] = {0.84,0.76,0.65,0.15};
	colorTracksFill[] = {0.84,0.76,0.65,0.75};
	colorTrails[] = {0.84,0.76,0.65,0.15}; 
	colorTrailsFill[] = {0.84,0.76,0.65,0.65};
	
	font = "TahomaB";
	sizeEx = 0.040000;
	
	fontLabel = "RobotoCondensed";
	sizeExLabel = 0.02;
	fontGrid = "TahomaB";
	sizeExGrid = 0.02;
	fontUnits = "TahomaB";
	sizeExUnits = 0.02;
	fontNames = "EtelkaNarrowMediumPro";
	sizeExNames = 0.02;	
	fontInfo = "RobotoCondensed";
	sizeExInfo = 0.02;
	fontLevel = "TahomaB";
	sizeExLevel = 0.02;

	maxSatelliteAlpha = 0.85;
	moveOnEdges = 1;
	
	stickX[] = {0.20, {"Gamma", 1.00, 1.50} };
	stickY[] = {0.20, {"Gamma", 1.00, 1.50} };
	ptsPerSquareSea = 6;
	ptsPerSquareTxt = 8;
	ptsPerSquareCLn = 8;
	ptsPerSquareExp = 8;
	ptsPerSquareCost = 8;
	ptsPerSquareFor = "4.0f";
	ptsPerSquareForEdge = "10.0f";
	ptsPerSquareRoad = 2;
	ptsPerSquareObj = 10;

	text = "#(argb,8,8,3)color(1,1,1,1)";
	showCountourInterval=2;
	scaleDefault = 0.1;
	scaleMax = 1;
	scaleMin = 0.001;
	onMouseButtonClick = "";
	onMouseButtonDblClick = "";
	widthRailWay = 4;
	
	
	class ActiveMarker {
		color[] = {0.30, 0.10, 0.90, 1.00};
		size = 50;
	  };
	class Bunker {
		icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
		color[] = {0.00, 0.0, 0.0, 1.00};
		size = 14;
		importance = "1.5 * 14 * 0.05";
		coefMin = 0.25;
		coefMax = 4.00;
	};
	class Bush {
		icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
		color[] = {0.45,0.64,0.33,0.4};
		size = 14;
		importance = "0.2 * 14 * 0.05";
		coefMin = 0.25;
		coefMax = 4.00;
	  };
	class BusStop {
		icon = "\A3\ui_f\data\map\mapcontrol\busstop_CA.paa";
		color[] = {1,1,1,1};
		size = 10;
		importance = "1 * 10 * 0.05";
		coefMin = 0.25;
		coefMax = 4.00;
	  };
	class Chapel {
		icon = "\A3\ui_f\data\map\mapcontrol\Chapel_CA.paa";
		color[] = {0,0,0,1};
		size = 16;
		importance = "1 * 16 * 0.05";
		coefMin = 0.90;
		coefMax = 4.00;
	};
	class Church {
		icon = "\A3\ui_f\data\map\mapcontrol\church_CA.paa";
		color[] = {1,1,1,1};
		size = 16;
		importance = "2 * 16 * 0.05";
		coefMin = 0.90;
		coefMax = 4.00;
	};
	class Command {
		icon = "\a3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
		color[] = {1,1,1,1};
		size = 18;
		importance = 1.00;
		coefMin = 1.00;
		coefMax = 1.00;
	};
	class Cross {
		icon = "\A3\ui_f\data\map\mapcontrol\Cross_CA.paa";
		color[] = {0,0,0,1};
		size = 24;
		importance = 1;
		coefMin = 0.25;
		coefMax = 4.00;
	};
	class CustomMark {
		icon = "\a3\ui_f\data\map\mapcontrol\custommark_ca.paa";
		color[] = {1,1,1,1};
		size = 18;
		importance = 1;
		coefMin = 1;
		coefMax = 1;
	};
	class Fortress {
		icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
		color[] = {0,0,0,1};
		size = 16;
		importance = "2 * 16 * 0.05";
		coefMin = 0.25;
		coefMax = 4.00;
	};
	
	class Fountain {
		icon = "\A3\ui_f\data\map\mapcontrol\fountain_ca.paa";
		color[] = {0,0,0,1};
		size = 11;
		importance = "1 * 12 * 0.05";
		coefMin = 0.25;
		coefMax = 4;
	};
	class Fuelstation {
		icon = "\A3\ui_f\data\map\mapcontrol\fuelstation_CA.paa";
		color[] = {1,1,1,1};
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1.00;
	};
	class Hospital {
		icon = "\A3\ui_f\data\map\mapcontrol\hospital_CA.paa";
		color[] = {1,1,1,1};
		size = 24;		
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Legend {
		color[] = {0,0,0,1};
		colorBackground[] = {1,1,1,0.5};
		font = "RobotoCondensed";
		h = "3.5 * 					(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
		sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		w = "10 * 					(			((safezoneW / safezoneH) min 1.2) / 40)";
		x = "SafeZoneX + 					(			((safezoneW / safezoneH) min 1.2) / 40)";
		y = "SafeZoneY + safezoneH - 4.5 * 					(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
	};
	class Lighthouse {
		icon = "\A3\ui_f\data\map\mapcontrol\lighthouse_CA.paa";
		color[] = {1,1,1,1};
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class LineMarker {
		lineDistanceMin = 3e-005;
		lineLengthMin = 5;
		lineWidthThick = 0.014;
		lineWidthThin = 0.008;
		textureComboBoxColor = "#(argb,8,8,3)color(1,1,1,1)";
	};
	class power {
		icon = "\A3\ui_f\data\map\mapcontrol\power_CA.paa";
		color[] = {1,1,1,1};
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class powersolar {
		icon = "\A3\ui_f\data\map\mapcontrol\powersolar_CA.paa";
		color[] = {1,1,1,1};
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};	
	class powerwave {
		icon = "\A3\ui_f\data\map\mapcontrol\powerwave_CA.paa";
		color[] = {1,1,1,1};
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class powerwind {
		icon = "\A3\ui_f\data\map\mapcontrol\powerwind_CA.paa";
		color[] = {1,1,1,1};
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Quay {
		icon = "\A3\ui_f\data\map\mapcontrol\quay_CA.paa";
		color[] = {1,1,1,1};
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Rock {
		icon = "\A3\ui_f\data\map\mapcontrol\rock_ca.paa";
		color[] = {0.1,0.1,0.1,0.8};
		size = 12;
		importance = "0.5 * 12 * 0.05";
		coefMin = 0.25;
		coefMax = 4.00;
	};	
	class Ruin {
		icon = "\A3\ui_f\data\map\mapcontrol\ruin_ca.paa";
		color[] = {0,0,0,1};
		size = 16;
		importance = "1.2 * 16 * 0.05";
		coefMin = 1.00;
		coefMax = 4.00;
	};
	class Shipwreck {
		icon = "\A3\ui_f\data\map\mapcontrol\Shipwreck_CA.paa";
		color[] = {0,0,0,1};
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class SmallTree {
		icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
		color[] = {0.45,0.64,0.33,0.4};
		size = 12;
		importance = "0.6 * 12 * 0.05";
		coefMin = 0.25;
		coefMax = 4.00;
	};
	class Stack {
		icon = "\A3\ui_f\data\map\mapcontrol\stack_ca.paa";
		color[] = {0,0,0,1};
		size = 20;
		importance = "2 * 16 * 0.05";
		coefMin = 0.90;
		coefMax = 4.00;
	};
	class Task {
		coefMax = 1;
		coefMin = 1;
		color[] = {"(profilenamespace getvariable ['IGUI_TEXT_RGB_R',0])","(profilenamespace getvariable ['IGUI_TEXT_RGB_G',1])","(profilenamespace getvariable ['IGUI_TEXT_RGB_B',1])","(profilenamespace getvariable ['IGUI_TEXT_RGB_A',0.8])"};
		colorCanceled[] = {0.7,0.7,0.7,1};
		colorCreated[] = {1,1,1,1};
		colorDone[] = {0.7,1,0.3,1};
		colorFailed[] = {1,0.3,0.2,1};
		icon = "\A3\ui_f\data\map\mapcontrol\taskIcon_CA.paa";
		iconCanceled = "\A3\ui_f\data\map\mapcontrol\taskIconCanceled_CA.paa";
		iconCreated = "\A3\ui_f\data\map\mapcontrol\taskIconCreated_CA.paa";
		iconDone = "\A3\ui_f\data\map\mapcontrol\taskIconDone_CA.paa";
		iconFailed = "\A3\ui_f\data\map\mapcontrol\taskIconFailed_CA.paa";
		importance = 1;
		size = 27;
		taskAssigned = "#(argb,8,8,3)color(1,1,1,1)";
		taskCanceled = "#(argb,8,8,3)color(1,0.5,0,1)";
		taskCreated = "#(argb,8,8,3)color(0,0,0,1)";
		taskFailed = "#(argb,8,8,3)color(1,0,0,1)";
		taskNone = "#(argb,8,8,3)color(0,0,0,0)";
		taskSucceeded = "#(argb,8,8,3)color(0,1,0,1)";
	};
	class Tourism {
		icon = "\A3\ui_f\data\map\mapcontrol\tourism_ca.paa";
		color[] = {0,0,0,1};
		size = 16;
		importance = "1 * 16 * 0.05";
		coefMin = 0.70;
		coefMax = 4.00;
	};
	class Transmitter {
		icon = "\A3\ui_f\data\map\mapcontrol\transmitter_CA.paa";
		color[] = {1,1,1,1};
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Tree {
		icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
		color[] = {0.45,0.64,0.33,0.4};
		size = 12;
		importance = "0.9 * 16 * 0.05";
		coefMin = 0.25;
		coefMax = 4.00;
	};	 
	class ViewTower {
		icon = "\A3\ui_f\data\map\mapcontrol\viewtower_ca.paa";
		color[] = {0,0,0,1};
		size = 16;
		importance = "2.5 * 16 * 0.05";
		coefMin = 0.50;
		coefMax = 4.00;
	};
	class Watertower {
		icon = "\A3\ui_f\data\map\mapcontrol\watertower_CA.paa";
		color[] = {1,1,1,1};
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1.00;
	};
	class Waypoint {
		icon = "\a3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
		color[] = {1,1,1,1};
		size = 18;
		importance = 1.00;
		coefMin = 1.00;
		coefMax = 1.00;
	};
	  class WaypointCompleted {
		icon = "\a3\ui_f\data\map\mapcontrol\waypointcompleted_ca.paa";
		color[] = {1,1,1,1};
		size = 18;
		importance = 1.00;
		coefMin = 1.00;
		coefMax = 1.00;
	  };
};

