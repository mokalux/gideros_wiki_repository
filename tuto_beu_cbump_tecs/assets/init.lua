-- plugins
--require "classes/tiny-ecs" -- declared as a local variable in the Game Class
--require "cbump" -- declared as a local variable in the Game Class

-- global app variables
screenwidth, screenheight = application:get("screenSize") -- the actual user screen size!
myappleft, myapptop, myappright, myappbot = application:getLogicalBounds() -- for mobile
myappwidth, myappheight = myappright - myappleft, myappbot - myapptop
--print(myappleft, myapptop, myappright, myappbot)
--print(myappwidth, myappheight)
ismyappfullscreen = false

-- global ttf fonts
myttf = TTFont.new("fonts/Cabin-Regular-TTF.ttf", 2.8*8) -- for UI
myttf2 = TTFont.new("fonts/Cabin-Regular-TTF.ttf", 1.5*8) -- for HUD

-- global UI theme
g_ui_theme = {}
g_ui_theme.backgroundcolor = 0x46464a
g_ui_theme.pixelcolorup = 0x8d595d
g_ui_theme.pixelcolordown = 0xc09c98
g_ui_theme.textcolorup = 0xd9d2cb
g_ui_theme.textcolordown = 0xd9d2cb
g_ui_theme.textcolordisabled = 0xd9d2cb
g_ui_theme.tooltiptextcolor = 0x3a1d20
g_ui_theme.tooltipoffsetx = -7*8
g_ui_theme.tooltipoffsety = 1*4
g_ui_theme.exit = 0xf41212

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
