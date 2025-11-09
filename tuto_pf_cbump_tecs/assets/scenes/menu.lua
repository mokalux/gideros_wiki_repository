Menu = Core.class(Sprite)

function Menu:init()
	-- background
	local tex = Texture.new("gfx/menu_bg.png")
	local bg = Bitmap.new(tex)
	bg:setScale(3.2)
	-- buttons
	local myttf = TTFont.new("fonts/Cabin-Regular-TTF.ttf", 3*8) -- UI
	local btnsnd = { sound=Sound.new("audio/ui/sfx_sounds_button1.wav"), time=0, delay=0.2, }
	local btnvolume = g_sfxvolume*0.01
	local tooltiplayer = Sprite.new()
	local difficulty = g_difficulty
	if difficulty >= 2 then difficulty = "hard"
	elseif difficulty >= 1 then difficulty = "normal"
	else difficulty = "easy"
	end
	-- title
	local mytitle = ButtonMonster.new({
		pixelalphaup=0.25,
		text="GIDEROS\n   PF", ttf=myttf, textcolorup=0xffff00,
	}, 0)
	-- buttons
	local mybtn = ButtonMonster.new({
		autoscale=false, pixelwidth=20*8, pixelheight=8*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text="START", ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=btnsnd, volume=btnvolume,
		tooltiptext=difficulty, tooltipttf=myttf, tooltiptextcolor=g_ui_theme.tooltiptextcolor,
		tooltipoffsetx=g_ui_theme.tooltipoffsetx-2*8, tooltipoffsety=g_ui_theme.tooltipoffsety+0.5*8,
	}, 1, tooltiplayer)
	local mybtn02 = ButtonMonster.new({
		autoscale=false, pixelwidth=20*8, pixelheight=8*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text="OPTIONS", ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=btnsnd, volume=btnvolume,
	}, 2)
	local mybtn03 = ButtonMonster.new({
		autoscale=false, pixelwidth=16*8, pixelheight=7*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.exit,
		text="EXIT", ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=btnsnd, volume=btnvolume,
	}, 3)
	-- buttons table for keyboard navigation
	self.btns = {}
	self.btns[#self.btns + 1] = mybtn
	self.btns[#self.btns + 1] = mybtn02
	self.btns[#self.btns + 1] = mybtn03
	self.selector = 1 -- starting button
	-- position
	bg:setPosition(0*myappwidth/16+myappleft, -1*myappheight/16)
	mytitle:setPosition(6*myappwidth/16+myappleft, 2*myappheight/16)
	mybtn:setPosition(3*myappwidth/16+myappleft, 12*myappheight/16)
	mybtn02:setPosition(7*myappwidth/16+myappleft, 12*myappheight/16)
	mybtn03:setPosition(14*myappwidth/16+myappleft, 14*myappheight/16)
	-- order
	self:addChild(bg)
	self:addChild(mytitle)
	for k, v in ipairs(self.btns) do self:addChild(v) end
	self:addChild(tooltiplayer)
	-- buttons listeners
	for k, v in ipairs(self.btns) do
		v:addEventListener("clicked", function() self.selector = k self:gotoScene() end)
		v:addEventListener("hovered", function(e) self.selector = e.currselector end)
		v.btns = self.btns -- FOR KEYBOARD NAVIGATION
	end
	-- let's go
	local function fun()
		self:updateButtons()
		self:myKeysPressed()
		Core.yield(1)
	end
	Core.asyncCall(fun)
end

-- update button state
function Menu:updateButtons()
	for k, v in ipairs(self.btns) do
		v.currselector = self.selector
		v:updateVisualState()
		if k == self.selector then v:selectionSfx() end -- play sound on keyboard navigation
	end
end

-- keyboard navigation
function Menu:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		-- keyboard navigation
		if e.keyCode == KeyCode.DOWN or e.keyCode == g_keydown or
			e.keyCode == KeyCode.LEFT or e.keyCode == g_keyleft then
			self.selector -= 1 if self.selector < 1 then self.selector = #self.btns end
			self:updateButtons()
		elseif e.keyCode == KeyCode.UP or e.keyCode == g_keyup or
			e.keyCode == KeyCode.RIGHT or e.keyCode == g_keyright then
			self.selector += 1 if self.selector > #self.btns then self.selector = 1 end
			self:updateButtons()
		elseif e.keyCode == KeyCode.SPACE or e.keyCode == g_keyaction1 then
			self:gotoScene()
		elseif e.keyCode == KeyCode.ESC or e.keyCode == KeyCode.BACK then
			if not application:isPlayerMode() then application:exit()
			else print("EXIT")
			end
		end
		-- modifier
		local modifier = application:getKeyboardModifiers()
		local alt = (modifier & KeyCode.MODIFIER_ALT) > 0
		if not alt and e.keyCode == KeyCode.ENTER then self:gotoScene() -- validate
		elseif alt and e.keyCode == KeyCode.ENTER then -- switch full screen
			if not application:isPlayerMode() then
				ismyappfullscreen = not ismyappfullscreen
				application:setFullScreen(ismyappfullscreen)
			end
		end
	end)
end

-- scenes navigation
function Menu:gotoScene()
	for k, v in ipairs(self.btns) do
		if k == self.selector then
			if v.isdisabled then -- nothing here
				print("btn disabled!", k)
			elseif k == 1 then -- go to LevelX
				switchToScene(LevelX.new()) -- next scene
			elseif k == 2 then -- go to Options
				switchToScene(Options.new()) -- next scene
			elseif k == 3 then -- exit
				if not application:isPlayerMode() then application:exit()
				else print("Exit button ", k)
				end
			end
		end
	end
end
