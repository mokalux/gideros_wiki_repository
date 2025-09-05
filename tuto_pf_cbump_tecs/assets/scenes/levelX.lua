LevelX = Core.class(Sprite)

local ispaused = false

function LevelX:init()
	-- move the cursor out of the way
	if not application:isPlayerMode() then
		local sw, sh = application:get("screenSize") -- the user's screen size!
		application:set("cursorPosition", sw-10, sh-10) -- 0, 0
	end
	-- _____  _     _    _  _____ _____ _   _  _____ 
	--|  __ \| |   | |  | |/ ____|_   _| \ | |/ ____|
	--| |__) | |   | |  | | |  __  | | |  \| | (___  
	--|  ___/| |   | |  | | | |_ | | | | . ` |\___ \ 
	--| |    | |___| |__| | |__| |_| |_| |\  |____) |
	--|_|    |______\____/ \_____|_____|_| \_|_____/ 
	-- tiny-ecs
	if not self.tiny then self.tiny = require "classes/tiny-ecs" end
	self.tiny.tworld = self.tiny.world()
	-- cbump (bworld)
	local bump = require "cbump"
	local bworld = bump.newWorld() -- 16, grid cell size, default = 64
	-- _           __     ________ _____   _____ 
	--| |        /\\ \   / /  ____|  __ \ / ____|
	--| |       /  \\ \_/ /| |__  | |__) | (___  
	--| |      / /\ \\   / |  __| |  _  / \___ \ 
	--| |____ / ____ \| |  | |____| | \ \ ____) |
	--|______/_/    \_\_|  |______|_|  \_\_____/ 
	local layers = {}
	layers["main"] = Sprite.new() -- one Sprite to hold them all
	layers["bg"] = Sprite.new() -- bg layer
	layers["bgfx"] = Sprite.new() -- bg fx layer
	layers["actors"] = Sprite.new() -- actors layer
	layers["fgfx"] = Sprite.new() -- fg fx layer
	layers["fg"] = Sprite.new() -- fg layer
	layers["player1input"] = Sprite.new() -- player1 input layer
	-- _      ________      ________ _       _____ 
	--| |    |  ____\ \    / /  ____| |     / ____|
	--| |    | |__   \ \  / /| |__  | |    | (___  
	--| |    |  __|   \ \/ / |  __| | |     \___ \ 
	--| |____| |____   \  /  | |____| |____ ____) |
	--|______|______|   \/   |______|______|_____/ 
	self.tiledlevels = {}
	self.tiledlevels[1] = "tiled/lvl001/_level1_proto" -- lua file without extension
	self.tiledlevels[2] = "tiled/lvl001/level1" -- lua file without extension
--	self.tiledlevels[3] = "tiled/lvl002/level1_proto" -- lua file without extension
	local mapdef = {} -- game area (rect: top, left, right, bottom)
	local zoom = 1 -- 1.3, 1.5, 1.7
	local camfollowoffsety = 28 -- 32, 36, 48, camera follow player1 y offset, magik XXX
	self.tiny.player1inventory = {} -- player1 inventory
	self.tiny.numberofcoins = 0
	local currlevel = TiledLevels.new(
		self.tiledlevels[g_currlevel], self.tiny, bworld, layers
	)
	-- currlevel map definition (top, left, right, bottom) for the camera
	mapdef.t, mapdef.l =
		currlevel.mapdef.t, currlevel.mapdef.l
	mapdef.r, mapdef.b =
		currlevel.mapdef.l+currlevel.mapdef.r, currlevel.mapdef.t+currlevel.mapdef.b
	-- _____  _           __     ________ _____  __ 
	--|  __ \| |        /\\ \   / /  ____|  __ \/_ |
	--| |__) | |       /  \\ \_/ /| |__  | |__) || |
	--|  ___/| |      / /\ \\   / |  __| |  _  / | |
	--| |    | |____ / ____ \| |  | |____| | \ \ | |
	--|_|    |______/_/    \_\_|  |______|_|  \_\|_|
	self.player1 = currlevel.player1
	-- _    _ _    _ _____  
	--| |  | | |  | |  __ \ 
	--| |__| | |  | | |  | |
	--|  __  | |  | | |  | |
	--| |  | | |__| | |__| |
	--|_|  |_|\____/|_____/ 
	-- function
	local function clamp(v, mn, mx) return (v><mx)<>mn end
	local function map(v, minSrc, maxSrc, minDst, maxDst, clampValue)
		local newV = (v-minSrc)/(maxSrc-minSrc)*(maxDst-minDst)+minDst
		return not clampValue and newV or clamp(newV, minDst><maxDst, minDst<>maxDst)
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
	local hudhealthwidth = map(self.player1.currhealth, 0, self.player1.totalhealth, 0, 100, true)
	self.tiny.hudhealth = Pixel.new(0x00ff00, 2, hudhealthwidth, 8)
	self.tiny.hudhealth:setPosition(8*1, 8*3.5)
	self.tiny.hud:addChild(self.tiny.hudhealth)
	-- hud coins
	self.tiny.hudcoins = TextField.new(cf2, "COINS: "..self.tiny.numberofcoins)
	self.tiny.hudcoins:setTextColor(0xff5500)
	self.tiny.hudcoins:setPosition(8*20, 8*2.3)
	self.tiny.hud:addChild(self.tiny.hudcoins)
	--  _____          __  __ ______ _____            
	-- / ____|   /\   |  \/  |  ____|  __ \     /\    
	--| |       /  \  | \  / | |__  | |__) |   /  \   
	--| |      / /\ \ | |\/| |  __| |  _  /   / /\ \  
	--| |____ / ____ \| |  | | |____| | \ \  / ____ \ 
	-- \_____/_/    \_\_|  |_|______|_|  \_\/_/    \_\
	-- camera: 'content' is a Sprite which holds all your graphics
	self.camera = GCam.new(layers["main"], nil, nil, self.player1) -- (content [, anchorX, anchorY]) -- anchor default 0.5, 0.5
	self.camera:setAutoSize(true)
	self.camera:setZoom(zoom)
	self.camera:setBounds(
		mapdef.l+myappwidth/2/zoom, -- left
		mapdef.t+myappheight/2/zoom, -- top
		mapdef.r-myappwidth/2/zoom, -- right
		mapdef.b-myappheight/2/zoom -- bottom
	)
	self.camera:setSoftSize(1.5*32, 2.2*32) -- 1.5*32, 3*32, w, h
	self.camera:setDeadSize(3*32, 4.4*32) -- 3*32, 5*32, w, h
	self.camera:setFollow(self.player1.sprite)
	self.camera:setFollowOffset(0, camfollowoffsety)
	self.camera:setPredictMode(true)
	self.camera:setPrediction(0.9) -- 0.8, 0.75, 0.5, number betwwen 0 and 1
	self.camera:lockPredictionY() -- no prediction on Y axis
	self.camera:setPredictionSmoothing(4) -- 8, 4, smooth prediction
--	self.camera:setDebug(true) -- uncomment for camera debug mode
	--  ____  _____  _____  ______ _____  
	-- / __ \|  __ \|  __ \|  ____|  __ \ 
	--| |  | | |__) | |  | | |__  | |__) |
	--| |  | |  _  /| |  | |  __| |  _  / 
	--| |__| | | \ \| |__| | |____| | \ \ 
	-- \____/|_|  \_\_____/|______|_|  \_\
	layers["main"]:addChild(layers["bg"])
	layers["main"]:addChild(layers["bgfx"])
	layers["main"]:addChild(layers["actors"])
	layers["main"]:addChild(layers["fgfx"])
	layers["main"]:addChild(layers["fg"])
	self:addChild(self.camera)
	self:addChild(self.tiny.hud)
	self:addChild(layers["player1input"])
	--  _______     _______ _______ ______ __  __  _____ 
	-- / ____\ \   / / ____|__   __|  ____|  \/  |/ ____|
	--| (___  \ \_/ / (___    | |  | |__  | \  / | (___  
	-- \___ \  \   / \___ \   | |  |  __| | |\/| |\___ \ 
	-- ____) |  | |  ____) |  | |  | |____| |  | |____) |
	--|_____/   |_| |_____/   |_|  |______|_|  |_|_____/ 
	self.tiny.tworld:add(
		-- debug
--		SDebugPosition.new(self.tiny),
--		SDebugCollision.new(self.tiny),
--	 	SDebugShield.new(self.tiny),
		-- systems
		SDrawable.new(self.tiny),
		SAnimation.new(self.tiny),
		SPlayer1.new(self.tiny, bworld, self.camera),
		SPlayer1Control.new(self.tiny, self.camera, mapdef, player1inputlayer),
		SNmes.new(self.tiny, bworld, self.player1),
		SAI.new(self.tiny, self.player1),
		SSensor.new(self.tiny, bworld, self.player1),
		SDoor.new(self.tiny, bworld, self.player1),
		SMvpf.new(self.tiny, bworld),
		SCollectibles.new(self.tiny, bworld, self.player1),
		SProjectiles.new(self.tiny, bworld),
		SOscillation.new(self.tiny, bworld, self.player1),
		SCollision.new(self.tiny, bworld, self.player1)
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

-- game loop
local timer = 40*8 -- magik XXX
function LevelX:onEnterFrame(e)
	if not ispaused then
		local dt = e.deltaTime
		if self.player1.restart then
			if g_currlevel > #self.tiledlevels then
				timer -= 1
				if self.camera:getZoom() < 2 then
					self.camera:setZoom(self.camera:getZoom()+0.4*dt)
				end
				if timer <= 0 then
					self:gotoScene(Win.new())
					timer = 40*8
				end
			else
				self:gotoScene(LevelX.new())
			end
			self.camera:setPredictionSmoothing(1) -- 4, smooth prediction
			self.camera:update(dt) -- e.deltaTime, 1/60
		else
			self.camera:update(dt) -- e.deltaTime, 1/60
			self.tiny.tworld:update(dt) -- tiny world (last)
		end
	end
end

-- keys handler
function LevelX:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e) -- KEY_UP
		if e.keyCode == KeyCode.ESC or e.keyCode == KeyCode.BACK then -- MENU
			self:gotoScene(Menu.new())
		elseif e.keyCode == KeyCode.P then -- PAUSE
			ispaused = not ispaused
		elseif e.keyCode == KeyCode.R then -- RESTART
			self.player1.restart = true
		end
		-- modifier
		local modifier = application:getKeyboardModifiers()
		local alt = (modifier & KeyCode.MODIFIER_ALT) > 0
		if (not alt and e.keyCode == KeyCode.ENTER) then -- nothing here!
		elseif alt and e.keyCode == KeyCode.ENTER then -- SWITCH FULLSCREEN
			ismyappfullscreen = not ismyappfullscreen
			application:setFullScreen(ismyappfullscreen)
		end
	end)
end

-- scenes navigation
function LevelX:gotoScene(xscene)
	switchToScene(xscene) -- next scene
end
