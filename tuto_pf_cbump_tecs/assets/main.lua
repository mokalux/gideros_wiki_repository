-- windows title and position, winQt, win32
if not application:isPlayerMode() then
	application:set("windowTitle", "MY GAME")
	application:set("windowPosition",
		(screenwidth-myappwidth)*0.5, (screenheight-myappheight)*0.4
	)
--	application:enableDrawInfo(vector(1, 1, 0, 1)) -- for debuging
end

-- global prefs functions
function myLoadPrefs(xconfigfilepath)
	local mydata = getData(xconfigfilepath) -- try to read information from file
	if not mydata then -- if no prefs file, create it
		mydata = {}
		-- set prefs
		mydata.g_language = g_language
		mydata.g_difficulty = g_difficulty
		mydata.g_bgmvolume = g_bgmvolume
		mydata.g_sfxvolume = g_sfxvolume
		-- controls
		mydata.g_keyleft = g_keyleft
		mydata.g_keyright = g_keyright
		mydata.g_keyup = g_keyup
		mydata.g_keydown = g_keydown
		mydata.g_keyaction1 = g_keyaction1
		mydata.g_keyaction2 = g_keyaction2
		mydata.g_keyaction3 = g_keyaction3
		-- save prefs
		saveData(xconfigfilepath, mydata) -- create file and save datas
	else -- prefs file exists, use it!
		-- set prefs
		g_language = mydata.g_language
		g_difficulty = mydata.g_difficulty
		g_bgmvolume = mydata.g_bgmvolume
		g_sfxvolume = mydata.g_sfxvolume
		-- controls
		g_keyleft = mydata.g_keyleft
		g_keyright = mydata.g_keyright
		g_keyup = mydata.g_keyup
		g_keydown = mydata.g_keydown
		g_keyaction1 = mydata.g_keyaction1
		g_keyaction2 = mydata.g_keyaction2
		g_keyaction3 = mydata.g_keyaction3
	end
end

function mySavePrefs(xconfigfilepath)
	local mydata = {} -- clear the table
	-- set prefs
	mydata.g_language = g_language
	mydata.g_difficulty = g_difficulty
	mydata.g_bgmvolume = g_bgmvolume
	mydata.g_sfxvolume = g_sfxvolume
	-- controls
	mydata.g_keyleft = g_keyleft
	mydata.g_keyright = g_keyright
	mydata.g_keyup = g_keyup
	mydata.g_keydown = g_keydown
	mydata.g_keyaction1 = g_keyaction1
	mydata.g_keyaction2 = g_keyaction2
	mydata.g_keyaction3 = g_keyaction3
	-- save prefs
	saveData(xconfigfilepath, mydata) -- save new data
end

-- prefs file and initial default global prefs values
g_configfilepath = "|D|config.txt"
g_language = application:getLanguage()
g_currlevel = 2 -- 1, 2, change here when you want to test a level
g_difficulty = 1 -- 0=easy, 1=normal, 2=hard
g_bgmvolume = 20 -- 0-100
g_sfxvolume = 20 -- 0-100
g_keyleft = KeyCode.LEFT
g_keyright = KeyCode.RIGHT
g_keyup = KeyCode.UP
g_keydown = KeyCode.DOWN
g_keyaction1 = KeyCode.C
g_keyaction2 = KeyCode.X
g_keyaction3 = KeyCode.W

-- load saved prefs from file (|D|config.txt)
myLoadPrefs(g_configfilepath)

-- ANIMATIONS, faster accessed via int than string
local i : number = 1
g_ANIM_DEFAULT = i
i += 1
g_ANIM_IDLE_R = i
i += 1
g_ANIM_WALK_R = i
i += 1
g_ANIM_RUN_R = i
i += 1
g_ANIM_JUMPUP_R = i
i += 1
g_ANIM_JUMPDOWN_R = i
i += 1
g_ANIM_LADDER_IDLE_R = i
i += 1
g_ANIM_LADDER_UP_R = i
i += 1
g_ANIM_LADDER_DOWN_R = i
i += 1
g_ANIM_WALL_IDLE_R = i
i += 1
g_ANIM_WALL_UP_R = i
i += 1
g_ANIM_WALL_DOWN_R = i
i += 1
g_ANIM_WIN_R = i
i += 1
g_ANIM_HURT_R = i
i += 1
g_ANIM_LOSE1_R = i
i += 1
g_ANIM_STANDUP_R = i

-- global functions
function switchToScene(xscene) -- scenes transition
	-- unload current assets
	for i = stage:getNumChildren(), 1, -1 do
		stage:getChildAt(i):removeAllListeners() -- doublon of stage:removeAllListeners?
		stage:removeChildAt(i)
	end
	stage:removeAllListeners()
	collectgarbage()
	-- transition to next scene (eg.: Menu.new())
	stage:addChild(Transitions.new(xscene))
end

-- start the app
local logo = Bitmap.new(Texture.new("gfx/logo.png"))
logo:setAnchorPoint(0.5, 0.5)
logo:setPosition(myappwidth/2+myappleft, myappheight/2)
stage:addChild(logo)

-- preloader
local function preloader() -- loading textures and sounds when app is starting
	stage:removeEventListener(Event.ENTER_FRAME, preloader)
	-- timer
	local timer = Timer.new(1000, 1) -- show logo duration, you choose
	timer:addEventListener(Event.TIMER, function()
		switchToScene(Menu.new()) -- Menu, LevelX, Options, Win
	end) timer:start()
end
stage:addEventListener(Event.ENTER_FRAME, preloader)
