-- windows title and position
if not application:isPlayerMode() then
	application:set("windowTitle", "GIDEROS BEAT'EM UP TECS")
	application:set("windowPosition", (screenwidth-myappwidth)*0.5, (screenheight-myappheight)*0.4)
--	application:enableDrawInfo(vector(1, 1, 0, 1))
end

-- global prefs functions
function myLoadPrefs(xconfigfilepath)
	local mydata = getData(xconfigfilepath) -- try to read information from file
	if not mydata then -- if no prefs file, create it
		mydata = {}
		-- set prefs
		mydata.g_language = g_language
		mydata.g_bgmvolume = g_bgmvolume
		mydata.g_sfxvolume = g_sfxvolume
		mydata.g_difficulty = g_difficulty
--		mydata.g_unlockedlevel = g_unlockedlevel
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
		g_bgmvolume = mydata.g_bgmvolume
		g_sfxvolume = mydata.g_sfxvolume
		g_difficulty = mydata.g_difficulty
--		g_unlockedlevel = mydata.g_unlockedlevel
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
	mydata.g_bgmvolume = g_bgmvolume
	mydata.g_sfxvolume = g_sfxvolume
	mydata.g_difficulty = g_difficulty
--	mydata.g_unlockedlevel = g_unlockedlevel
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
g_configfilepath = "|D|configfile.txt"
g_language = application:getLanguage()
g_bgmvolume = 50 -- 0-100
g_sfxvolume = 20 -- 0-100
g_difficulty = 1 -- 0=easy, 1=normal, 2=hard
g_totallevels = 3
g_currlevel = 1 -- change here to test a specific level
--g_unlockedlevel = g_currlevel
g_keyleft = KeyCode.LEFT
g_keyright = KeyCode.RIGHT
g_keyup = KeyCode.UP
g_keydown = KeyCode.DOWN
g_keyaction1 = KeyCode.C -- punch
g_keyaction2 = KeyCode.X -- kick
g_keyaction3 = KeyCode.W -- jump

-- load saved prefs from file (|D|configfile.txt)
myLoadPrefs(g_configfilepath)

-- global functions
function switchToScene(xscene) -- scenes transition
	-- unload current assets
	stage:removeAllListeners()
	for i = stage:getNumChildren(), 1, -1 do
		stage:getChildAt(i):removeAllListeners()
		stage:removeChildAt(i)
	end collectgarbage()
	-- transition to next scene (eg.: Menu.new())
	stage:addChild(Transitions.new(xscene))
end

-- anims, faster accessed via int than string
local i = 1
g_ANIM_DEFAULT = i
i += 1
g_ANIM_IDLE_R = i
i += 1
g_ANIM_WALK_R = i
i += 1
g_ANIM_RUN_R = i
i += 1
g_ANIM_JUMP1_R = i
i += 1
g_ANIM_WIN_R = i
i += 1
g_ANIM_HURT_R = i
i += 1
g_ANIM_STANDUP_R = i
i += 1
g_ANIM_LOSE1_R = i
i += 1
g_ANIM_PUNCH_ATTACK1_R = i
i += 1
g_ANIM_PUNCH_ATTACK2_R = i
i += 1
g_ANIM_KICK_ATTACK1_R = i
i += 1
g_ANIM_KICK_ATTACK2_R = i
i += 1
g_ANIM_PUNCHJUMP_ATTACK1_R = i
i += 1
g_ANIM_KICKJUMP_ATTACK1_R = i

-- ***************
--  START THE APP
-- ***************
-- bg
application:setBackgroundColor(g_ui_theme.backgroundcolor)
-- company/app/game logo
local logo = Bitmap.new(Texture.new("gfx/logo.png"))
logo:setAnchorPoint(0.5, 0.5)
logo:setPosition(myappwidth/2+myappleft, myappheight/2)
stage:addChild(logo)

local function preloader() -- loading textures and sounds when app is starting
	stage:removeEventListener(Event.ENTER_FRAME, preloader) -- run it only once!
	-- preload your assets here or preload them calling a Class function eg.: MenuScene.preload(), SoundManager.preload()
	-- timer
	local timer = Timer.new(1500, 1) -- show logo: duration
	timer:addEventListener(Event.TIMER, function()
		switchToScene(Menu.new()) -- LevelX, Win, Menu
	end) timer:start()
end

-- on first app frame, start the app/game
stage:addEventListener(Event.ENTER_FRAME, preloader)
