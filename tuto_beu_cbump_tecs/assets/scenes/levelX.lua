--!strict

LevelX = Core.class(Sprite)

local random = math.random
local ispaused : boolean = false

function LevelX:init()
	-- bg
	application:setBackgroundColor(g_ui_theme.backgroundcolor)
	-- move the cursor out of the way
--	if not application:isPlayerMode() then
--		local sw, sh = application:get("screenSize") -- the user's screen size!
--		application:set("cursorPosition", sw, sh) -- 0, 0
--	end
	-- _____  _     _    _  _____ _____ _   _  _____ 
	--|  __ \| |   | |  | |/ ____|_   _| \ | |/ ____|
	--| |__) | |   | |  | | |  __  | | |  \| | (___  
	--|  ___/| |   | |  | | | |_ | | | | . ` |\___ \ 
	--| |    | |___| |__| | |__| |_| |_| |\  |____) |
	--|_|    |______\____/ \_____|_____|_| \_|_____/ 
	-- tiny-ecs
	if not self.tiny then self.tiny = require "classes/tiny-ecs" end
	self.tiny.tworld = self.tiny.world()
	-- cbump (cworld)
	local bump = require "cbump"
	local bworld = bump.newWorld()
	-- _           __     ________ _____   _____ 
	--| |        /\\ \   / /  ____|  __ \ / ____|
	--| |       /  \\ \_/ /| |__  | |__) | (___  
	--| |      / /\ \\   / |  __| |  _  / \___ \ 
	--| |____ / ____ \| |  | |____| | \ \ ____) |
	--|______/_/    \_\_|  |______|_|  \_\_____/ 
	local mainlayer = Sprite.new() -- one Sprite to hold them all
	local bglayer = Sprite.new() -- bg layer
	local bgfxlayer = Sprite.new() -- bg fx layer
	local actorslayer = Sprite.new() -- actors layer
	local fgfxlayer = Sprite.new() -- fg fx layer
	local fglayer = Sprite.new() -- fg layer
	local player1inputlayer = Sprite.new() -- player1 input layer
	-- _      ________      ________ _       _____ 
	--| |    |  ____\ \    / /  ____| |     / ____|
	--| |    | |__   \ \  / /| |__  | |    | (___  
	--| |    |  __|   \ \/ / |  __| | |     \___ \ 
	--| |____| |____   \  /  | |____| |____ ____) |
	--|______|______|   \/   |______|______|_____/ 
	-- levels setup
	self.tiny.spriteslist = {} -- the actors
	self.tiny.numberofnmes = 0 -- some enemies
	self.tiny.numberofdestructibleobjects = 0 -- some destructible objects
	local mapdef = {} -- actors walking area (rect: top, left, right, bottom)
	local camfollowoffsety = 0 -- camera follow player1 y offset
	-- build level
	self:buildLevel(bglayer, fglayer, mapdef, actorslayer, bgfxlayer, bworld)
	if g_currlevel == 1 then
		camfollowoffsety = -1.7*32
		self.tiny.numberofdestructibleobjects = 8
	elseif g_currlevel == 2 then
		camfollowoffsety = -2.5*32
		self.tiny.numberofdestructibleobjects = 7
	elseif g_currlevel == 3 then
		camfollowoffsety = -2.5*32
		self.tiny.numberofdestructibleobjects = 6
	end
	-- add levels destructible objects if any
	local el
	for i = 1, self.tiny.numberofdestructibleobjects do
		-- EDestructibleObject:init(xspritelayer, xpos)
		el = EDestructibleObject.new(actorslayer, vector(
			random((mapdef.r-mapdef.l)*0.25, (mapdef.r-mapdef.l)*0.9), -- x
			random(mapdef.t, mapdef.b - 2*32)) -- y
		)
		self.tiny.tworld:addEntity(el)
		bworld:add(el, el.pos.x, el.pos.y, el.collbox.w, el.collbox.h)
	end
	-- _____  _           __     ________ _____  __ 
	--|  __ \| |        /\\ \   / /  ____|  __ \/_ |
	--| |__) | |       /  \\ \_/ /| |__  | |__) || |
	--|  ___/| |      / /\ \\   / |  __| |  _  / | |
	--| |    | |____ / ____ \| |  | |____| | \ \ | |
	--|_|    |______/_/    \_\_|  |______|_|  \_\|_|
	-- EPlayer1:init(xspritelayer, xpos, xbgfxlayer)
	self.player1 = EPlayer1.new(actorslayer, vector(mapdef.l+1*32, mapdef.t+3.2*32), bgfxlayer)
	self.tiny.tworld:addEntity(self.player1)
	bworld:add(self.player1, self.player1.pos.x, self.player1.pos.y, self.player1.collbox.w, self.player1.collbox.h)
	-- _    _ _    _ _____  
	--| |  | | |  | |  __ \ 
	--| |__| | |  | | |  | |
	--|  __  | |  | | |  | |
	--| |  | | |__| | |__| |
	--|_|  |_|\____/|_____/ 
	-- function
	local function map(v, minSrc, maxSrc, minDst, maxDst, clampValue)
		local newV = (v - minSrc) / (maxSrc - minSrc) * (maxDst - minDst) + minDst
		return not clampValue and newV or clamp(newV, minDst >< maxDst, minDst <> maxDst)
	end
	self.tiny.hud = Sprite.new()
	-- hud lives
	self.tiny.hudlives = {}
	local pixellife
	for i = 1, self.player1.currlives do
		pixellife = Pixel.new(0xffff00, 0.8, 16, 16)
		pixellife:setPosition(8+(i-1)*(16+8), 8)
		self.tiny.hud:addChild(pixellife)
		self.tiny.hudlives[i] = pixellife
	end
	-- hud health
	local hudhealthwidth = map(self.player1.currhealth, 0, self.player1.totalhealth, 0, 100)
	self.tiny.hudhealth = Pixel.new(0x00ff00, 2, hudhealthwidth, 8)
	self.tiny.hudhealth:setPosition(8, 8*3.5)
	self.tiny.hud:addChild(self.tiny.hudhealth)
	-- hud jumps
	self.tiny.hudcurrjumps = TextField.new(myttf2, "JUMPS: "..self.player1.currjumps)
	self.tiny.hudcurrjumps:setTextColor(0xffffff)
	self.tiny.hudcurrjumps:setPosition(8, 8*6.5)
	self.tiny.hud:addChild(self.tiny.hudcurrjumps)
	--  _____          __  __ ______ _____            
	-- / ____|   /\   |  \/  |  ____|  __ \     /\    
	--| |       /  \  | \  / | |__  | |__) |   /  \   
	--| |      / /\ \ | |\/| |  __| |  _  /   / /\ \  
	--| |____ / ____ \| |  | | |____| | \ \  / ____ \ 
	-- \_____/_/    \_\_|  |_|______|_|  \_\/_/    \_\
	-- camera: 'content' is a Sprite which holds all your graphics
	self.camera = GCam.new(mainlayer) -- (content [, anchorX, anchorY]) -- anchor default 0.5, 0.5
	self.camera:setAutoSize(true)
	self.camera:setBounds(myappwidth/2, mapdef.t+camfollowoffsety, mapdef.r-myappwidth/2, mapdef.b) -- left, top, right, bottom
	self.camera:setSoftSize(32, 32*1) -- w, h
	self.camera:setDeadSize(32*1.5, 32*1.5) -- w, h
	self.camera:setFollow(self.player1.sprite)
	self.camera:setFollowOffset(0, camfollowoffsety)
--	self.camera:setDebug(true) -- uncomment for camera debug mode
	--  ____  _____  _____  ______ _____  
	-- / __ \|  __ \|  __ \|  ____|  __ \ 
	--| |  | | |__) | |  | | |__  | |__) |
	--| |  | |  _  /| |  | |  __| |  _  / 
	--| |__| | | \ \| |__| | |____| | \ \ 
	-- \____/|_|  \_\_____/|______|_|  \_\
	if bglayer then mainlayer:addChild(bglayer) end
	if self.extragfx then mainlayer:addChild(self.extragfx) end -- you choose!
	if bgfxlayer then mainlayer:addChild(bgfxlayer) end
	mainlayer:addChild(actorslayer)
	if fgfxlayer then mainlayer:addChild(fgfxlayer) end
	if fglayer then mainlayer:addChild(fglayer) end
	self:addChild(self.camera)
	self:addChild(self.tiny.hud)
	self:addChild(player1inputlayer)
	--  _______     _______ _______ ______ __  __  _____ 
	-- / ____\ \   / / ____|__   __|  ____|  \/  |/ ____|
	--| (___  \ \_/ / (___    | |  | |__  | \  / | (___  
	-- \___ \  \   / \___ \   | |  |  __| | |\/| |\___ \ 
	-- ____) |  | |  ____) |  | |  | |____| |  | |____) |
	--|_____/   |_| |_____/   |_|  |______|_|  |_|_____/ 
	self.tiny.tworld:add(
		-- debug
--		SDebugCollision.new(self.tiny),
--	 	SDebugHurtBoxPlayer.new(self.tiny),
--	 	SDebugHurtBoxNme.new(self.tiny),
--		SDebugHitBoxPlayer.new(self.tiny, { true, true, true, true, false, false } ), -- the 6 abilities (granular debugging)
--		SDebugHitBoxNme.new(self.tiny, { true, true, true, true, true, true } ), -- the 6 abilities (granular debugging)
--		SDebugSpriteSorting.new(self.tiny),
		-- systems
		SDrawable.new(self.tiny),
		SAnimation.new(self.tiny),
		SPlayer1.new(self.tiny, self.camera),
		SPlayer1Control.new(self.tiny, player1inputlayer),
		SNmes.new(self.tiny, bworld),
		SAI.new(self.tiny, self.player1),
		SDynamicBodies.new(self.tiny, mapdef),
		SDestructibleObjects.new(self.tiny, bworld),
		SCollectible.new(self.tiny, bworld, self.player1),
		SCollision.new(self.tiny, bworld),
		SHitboxHurtboxCollision.new(self.tiny),
		SShadow.new(self.tiny),
		SSpritesSorting.new(self.tiny)
	)
	-- _      ______ _______ _  _____    _____  ____  _ 
	--| |    |  ____|__   __( )/ ____|  / ____|/ __ \| |
	--| |    | |__     | |  |/| (___   | |  __| |  | | |
	--| |    |  __|    | |     \___ \  | | |_ | |  | | |
	--| |____| |____   | |     ____) | | |__| | |__| |_|
	--|______|______|  |_|    |_____/   \_____|\____/(_)
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) -- the game loop
	self:myKeysPressed() -- keys handler
end

-- _      ____   ____  _____  
--| |    / __ \ / __ \|  __ \ 
--| |   | |  | | |  | | |__) |
--| |   | |  | | |  | |  ___/ 
--| |___| |__| | |__| | |     
--|______\____/ \____/|_|     
local leveltimer = 128 -- 128, 200, you choose
local endleveltimer = leveltimer
local extragfxx = 0
function LevelX:onEnterFrame(e)
	if self.tiny.numberofnmes <= 0 then endleveltimer -= 1 end
	if not ispaused then
		if endleveltimer < 0 then
			g_currlevel += 1
			if g_currlevel > g_totallevels then
				endleveltimer = leveltimer -- reset end level timer
				g_currlevel = 1 -- reset current level
				switchToScene(Win.new()) -- Win
			else
				endleveltimer = leveltimer -- reset end level timer
				switchToScene(LevelX.new()) -- next level
			end
		end
		if self.player1.isactionjump1 or self.player1.isactionjumppunch1 or self.player1.isactionjumpkick1 then
			self.camera:updateXOnly(e.deltaTime)
		else
			self.camera:update(e.deltaTime)
		end
		self.tiny.tworld:update(e.deltaTime) -- tiny world (last)
		if self.extragfx then
			extragfxx = self.extragfx:getX()
			extragfxx -= 196*e.deltaTime
			if extragfxx < -self.extragfx:getWidth() then extragfxx = self.wagonr end
			self.extragfx:setX(extragfxx)
		end
	end
end

-- levels graphics
function LevelX:buildLevel(xbglayer, xfglayer, xmapdef, xactorslayer, xbgfxlayer, xbworld)
	local el
	-- ____   _____ _____   ____  _    _ _   _ _____             _   _ _____  
	--|  _ \ / ____|  __ \ / __ \| |  | | \ | |  __ \      /\   | \ | |  __ \ 
	--| |_) | |  __| |__) | |  | | |  | |  \| | |  | |    /  \  |  \| | |  | |
	--|  _ <| | |_ |  _  /| |  | | |  | | . ` | |  | |   / /\ \ | . ` | |  | |
	--| |_) | |__| | | \ \| |__| | |__| | |\  | |__| |  / ____ \| |\  | |__| |
	--|____/ \_____|_|  \_\\____/ \____/|_| \_|_____/  /_/    \_\_| \_|_____/ 
	-- ______ _____ _____   ____  _    _ _   _ _____  
	--|  ____/ ____|  __ \ / __ \| |  | | \ | |  __ \ 
	--| |__ | |  __| |__) | |  | | |  | |  \| | |  | |
	--|  __|| | |_ |  _  /| |  | | |  | | . ` | |  | |
	--| |   | |__| | | \ \| |__| | |__| | |\  | |__| |
	--|_|    \_____|_|  \_\\____/ \____/|_| \_|_____/ 
	if g_currlevel == 1 then
		-- THE BACKGROUND AND FOREGROUND IF ANY
		el = DrawLevelsTiled.new(xbglayer,
			{
				"gfx/levels/beu_lvl1/untitled_0001.png",
				"gfx/levels/beu_lvl1/untitled_0002.png",
				"gfx/levels/beu_lvl1/untitled_0003.png",
			}, 0*32)
		el = DrawLevelsTiled.new(xfglayer,
			{
				"gfx/levels/beu_lvl1/beu_fg_lvl1_0001.png",
				"gfx/levels/beu_lvl1/beu_fg_lvl1_0002.png",
				"gfx/levels/beu_lvl1/beu_fg_lvl1_0003.png",
			}, 12*32)
		-- map definition (top, left, right, bottom)
		xmapdef.t, xmapdef.l = 9.5*32, 0*32 -- magik XXX
		xmapdef.r, xmapdef.b = el.mapwidth, xmapdef.t + 5.3*32 -- magik XXX
	elseif g_currlevel == 2 then
		-- the background and foreground if any
		el = DrawLevelsTiled.new(xbglayer,
			{
				"gfx/levels/beu_lvl2/untitled_0001.png",
				"gfx/levels/beu_lvl2/untitled_0002.png",
				"gfx/levels/beu_lvl2/untitled_0003.png",
			}, 0*32)
		el = DrawLevelsTiled.new(xfglayer,
			{
				"gfx/levels/beu_lvl1/beu_fg_lvl1_0001.png",
				"gfx/levels/beu_lvl1/beu_fg_lvl1_0002.png",
				"gfx/levels/beu_lvl1/beu_fg_lvl1_0003.png",
			}, 12*32)
		-- map definition (top, left, right, bottom)
		xmapdef.t, xmapdef.l = 8.55*32, 0*32 -- magik XXX
		xmapdef.r, xmapdef.b = el.mapwidth, xmapdef.t + 6*32 -- magik XXX
	elseif g_currlevel == 3 then
		-- the background and foreground if any
		el = DrawLevelsTiled.new(xbglayer,
			{
				"gfx/levels/beu_lvl3/untitled_0001.png",
				"gfx/levels/beu_lvl3/untitled_0002.png",
				"gfx/levels/beu_lvl3/untitled_0003.png",
			}, 0*32)
		el = DrawLevelsTiled.new(xfglayer,
			{
				"gfx/levels/beu_lvl3/untitledfg_0001.png",
				"gfx/levels/beu_lvl3/untitledfg_0002.png",
				"gfx/levels/beu_lvl3/untitledfg_0003.png",
			}, 0*32)
		xfglayer:setAlpha(0.87)
		-- map definition (top, left, right, bottom)
		xmapdef.t, xmapdef.l = 8.9*32, 0*32 -- magik XXX
		xmapdef.r, xmapdef.b = el.mapwidth, xmapdef.t + 6*32 -- magik XXX
	end
	-- _______ _    _ ______   ______ _   _ ______ __  __ _____ ______  _____ 
	--|__   __| |  | |  ____| |  ____| \ | |  ____|  \/  |_   _|  ____|/ ____|
	--   | |  | |__| | |__    | |__  |  \| | |__  | \  / | | | | |__  | (___  
	--   | |  |  __  |  __|   |  __| | . ` |  __| | |\/| | | | |  __|  \___ \ 
	--   | |  | |  | | |____  | |____| |\  | |____| |  | |_| |_| |____ ____) |
	--   |_|  |_|  |_|______| |______|_| \_|______|_|  |_|_____|______|_____/ 
	-- ENmeX:init(xspritelayer, x, y, dx, dy, xbgfxlayer)
	if g_currlevel == 1 then
		for i = 1, 6 do
			el = ENme1.new(xactorslayer,
				vector(random((xmapdef.r-xmapdef.l)*0.3, (xmapdef.r-xmapdef.l)*0.7), random(xmapdef.t, xmapdef.b-1*32)),
				random(12, 24)*16, random(myappheight*0.2), xbgfxlayer)
			self.tiny.tworld:addEntity(el)
			self.tiny.numberofnmes += 1
			xbworld:add(el, el.pos.x, el.pos.y, el.collbox.w, el.collbox.h)
		end
		for i = 1, 6 do
			el = ENme2.new(xactorslayer,
				vector(random((xmapdef.r-xmapdef.l)*0.75, (xmapdef.r-xmapdef.l)*1), random(xmapdef.t, xmapdef.b-2*32)),
				random(12, 24)*16, random(myappheight*0.1), xbgfxlayer)
			self.tiny.tworld:addEntity(el)
			self.tiny.numberofnmes += 1
			xbworld:add(el, el.pos.x, el.pos.y, el.collbox.w, el.collbox.h)
		end
	elseif g_currlevel == 2 then
		for i = 1, 7 do
			el = ENme1.new(xactorslayer,
				vector(random((xmapdef.r-xmapdef.l)*0.25, (xmapdef.r-xmapdef.l)*0.75), random(xmapdef.t, xmapdef.b-1*32)),
				random(12, 24)*16, random(myappheight*0.2), xbgfxlayer)
			self.tiny.tworld:addEntity(el)
			self.tiny.numberofnmes += 1
			xbworld:add(el, el.pos.x, el.pos.y, el.collbox.w, el.collbox.h)
		end
		for i = 1, 7 do
			el = ENme3.new(xactorslayer,
				vector(random((xmapdef.r-xmapdef.l)*0.75, (xmapdef.r-xmapdef.l)*1), random(xmapdef.t, xmapdef.b-1*32)),
				random(12, 24)*16, random(myappheight*0.1), xbgfxlayer)
			self.tiny.tworld:addEntity(el)
			self.tiny.numberofnmes += 1
			xbworld:add(el, el.pos.x, el.pos.y, el.collbox.w, el.collbox.h)
		end
	elseif g_currlevel == 3 then
		for i = 1, 8 do
			el = ENme1.new(xactorslayer,
				vector(random((xmapdef.r-xmapdef.l)*0.2, (xmapdef.r-xmapdef.l)*0.75), random(xmapdef.t, xmapdef.b-1*32)),
				random(12, 24)*16, random(myappheight*0.2), xbgfxlayer)
			self.tiny.tworld:addEntity(el)
			self.tiny.numberofnmes += 1
			xbworld:add(el, el.pos.x, el.pos.y, el.collbox.w, el.collbox.h)
		end
		for i = 1, 8 do
			el = ENme3.new(xactorslayer,
				vector(random((xmapdef.r-xmapdef.l)*0.5, (xmapdef.r-xmapdef.l)*0.9), random(xmapdef.t, xmapdef.b-1*32)),
				random(12, 24)*16, random(myappheight*0.1), xbgfxlayer)
			self.tiny.tworld:addEntity(el)
			self.tiny.numberofnmes += 1
			xbworld:add(el, el.pos.x, el.pos.y, el.collbox.w, el.collbox.h)
		end
		for i = 1, 3 do
			el = ENme4.new(xactorslayer,
				vector(random((xmapdef.r-xmapdef.l)*0.8, (xmapdef.r-xmapdef.l)*1), random(xmapdef.t, xmapdef.b-2*32)),
				random(12, 24)*16, random(myappheight*0.1), xbgfxlayer)
			self.tiny.tworld:addEntity(el)
			self.tiny.numberofnmes += 1
			xbworld:add(el, el.pos.x, el.pos.y, el.collbox.w, el.collbox.h)
		end
	end
	-- ________   _________ _____               _____ ________   __
	--|  ____\ \ / /__   __|  __ \     /\      / ____|  ____\ \ / /
	--| |__   \ V /   | |  | |__) |   /  \    | |  __| |__   \ V / 
	--|  __|   > <    | |  |  _  /   / /\ \   | | |_ |  __|   > <  
	--| |____ / . \   | |  | | \ \  / ____ \  | |__| | |     / . \ 
	--|______/_/ \_\  |_|  |_|  \_\/_/    \_\  \_____|_|    /_/ \_\
	if g_currlevel == 1 then
		-- nothing here
	elseif g_currlevel == 2 then
		-- nothing here
	elseif g_currlevel == 3 then
		-- a moving wagon
		self.extragfx = Bitmap.new(Texture.new("gfx/levels/beu_lvl3/subway_car.001_0013.png"))
		self.extragfx:setScale(0.65)
		self.wagonr = xmapdef.r
		self.extragfx:setPosition(random(xmapdef.r*0.5, xmapdef.r), 1*myappheight/10)
	end
	-- cleaning?
	el = nil
	collectgarbage()
end

-- keys handler
function LevelX:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e) -- KEY_UP
		-- Menu
		if e.keyCode == KeyCode.ESC or e.keyCode == KeyCode.BACK then switchToScene(Menu.new()) end
		-- pause
		if e.keyCode == KeyCode.P then ispaused = not ispaused end
		-- modifiers
		local modifier = application:getKeyboardModifiers()
		local alt = (modifier & KeyCode.MODIFIER_ALT) > 0
		-- nothing here!
		if not alt and e.keyCode == KeyCode.ENTER then
		-- switch fullscreen
		elseif alt and e.keyCode == KeyCode.ENTER then
			ismyappfullscreen = not ismyappfullscreen
			application:setFullScreen(ismyappfullscreen)
		end
	end)
end
