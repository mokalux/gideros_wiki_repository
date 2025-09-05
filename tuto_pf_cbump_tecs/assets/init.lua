-- global app variables
screenwidth, screenheight = application:get("screenSize") -- the actual user screen size!
myappleft, myapptop, myappright, myappbot = application:getLogicalBounds()
myappwidth, myappheight = myappright - myappleft, myappbot - myapptop
ismyappfullscreen = false

-- UI global composite font
local str = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .:;()?!-+/*"
local myttf = TTFont.new("fonts/Cabin-Regular-TTF.ttf", 2*8, str)
local myttfo = TTFont.new("fonts/Cabin-Regular-TTF.ttf", 2*8, str, 2, 3)
cf2 = CompositeFont.new {
	{ font=myttfo, color=0x2a2a2a, alpha=1 }, -- draw outline in dark
	{ font=myttf, x=0, y=0 }, -- draw normal text with an offset
}

-- global ui theme
application:setBackgroundColor(0x363124)
g_ui_theme = {}
g_ui_theme.pixelcolorup = 0x34484b
g_ui_theme.pixelcolordown = 0x3c4550
g_ui_theme.textcolorup = 0xb3b5b1
g_ui_theme.textcolordown = 0xdea77f
g_ui_theme._textcolordisabled = 0x87837f
g_ui_theme.tooltiptextcolor = 0xc7dbe7
g_ui_theme.exit = 0xf41212
g_ui_theme.tooltipoffsetx = -10*8
g_ui_theme.tooltipoffsety = 1*8

-- tweens table for transitions
tweens = {
	"inBack", -- 1
	"outBack", -- 2
	"inOutBack", -- 3
	"inBounce", -- 4
	"outBounce", -- 5
	"inOutBounce", -- 6
	"inCircular", -- 7
	"outCircular", -- 8
	"inOutCircular", -- 9
	"inCubic", -- 10
	"outCubic", -- 11
	"inOutCubic", -- 12
	"inElastic", -- 13
	"outElastic", -- 14
	"inOutElastic", -- 15
	"inExponential", -- 16
	"outExponential", -- 17
	"inOutExponential", -- 18
	"linear", -- 19
	"inQuadratic", -- 20
	"outQuadratic", -- 21
	"inOutQuadratic", -- 22
	"inQuartic", -- 23
	"outQuartic", -- 24
	"inOutQuartic", -- 25
	"inQuintic", -- 26
	"outQuintic", -- 27
	"inOutQuintic", -- 28
	"inSine", -- 29
	"outSine", -- 30
	"inOutSine", -- 31
}
