Options = Core.class(Sprite)

local keyNames = { -- display nice KeyCode name
  [KeyCode.LEFT] = "LEFT",
  [KeyCode.RIGHT] = "RIGHT",
  [KeyCode.UP] = "UP",
  [KeyCode.DOWN] = "DOWN",
  [KeyCode.NUM0] = "NUMPAD 0",
  [KeyCode.NUM1] = "NUMPAD 1",
  [KeyCode.NUM2] = "NUMPAD 2",
  [KeyCode.NUM3] = "NUMPAD 3",
  [KeyCode.NUM4] = "NUMPAD 4",
  [KeyCode.NUM5] = "NUMPAD 5",
  [KeyCode.NUM6] = "NUMPAD 6",
  [KeyCode.NUM7] = "NUMPAD 7",
  [KeyCode.NUM8] = "NUMPAD 8",
  [KeyCode.NUM9] = "NUMPAD 9",
  [KeyCode.SPACE] = "SPACE",
  [KeyCode.SHIFT] = "SHIFT",
  [KeyCode.CTRL] = "CONTROL",
  [KeyCode.ALT] = "ALT",
  [KeyCode.TAB] = "TAB",
}

function Options:init()
	-- bg
	application:setBackgroundColor(g_ui_theme.backgroundcolor)
	-- TITLE
	self.mytitle = ButtonMonster.new({
		autoscale=false, pixelwidth=16*8, pixelheight=4*8,
		pixelcolorup=0xaaaaaa,
		text="OPTIONS", ttf=myttf,
	})
	-- SLIDERS
	local slitcolor, knobcolor = g_ui_theme.pixelcolorup, g_ui_theme.pixelcolordown
	self.bgmvolumeslider = ASlider.new({
		initialvalue=g_bgmvolume, maximum=100, --steps=2,
		slitcolor=slitcolor, slitalpha=1, slitw=5*myappwidth/10, slith=24,
		knobcolor=knobcolor, knobalpha=0.6, knobw=12, knobh=26,
		text="BGM VOLUME: ", textscale=2, textoffsetx=-26*8, textoffsety=7,
		id=1,
	})
	self.sfxvolumeslider = ASlider.new({
		initialvalue=g_sfxvolume, maximum=100, --steps=2,
		slitcolor=slitcolor, slitalpha=1, slitw=5*myappwidth/10, slith=24,
		knobcolor=knobcolor, knobalpha=0.6, knobw=12, knobh=26,
		text="SFX VOLUME: ", textscale=2, textoffsetx=-26*8, textoffsety=7,
		id=2,
	})
	self.difficultyslider = ASlider.new({
		initialvalue=g_difficulty, maximum=2, --steps=2,
		slitcolor=slitcolor, slitalpha=1, slitw=5*myappwidth/10, slith=24,
		knobcolor=knobcolor, knobalpha=0.6, knobw=12, knobh=26,
		text="DIFFICULTY: ", textscale=2, textoffsetx=-26*8, textoffsety=7, textrotation=0,
		id=3,
	})
	-- position
	self.mytitle:setPosition(myappwidth/2, 0.75*myappheight/10)
	self.bgmvolumeslider:setPosition(29*8, 2.5*myappheight/10)
	self.sfxvolumeslider:setPosition(29*8, 3.5*myappheight/10)
	self.difficultyslider:setPosition(29*8, 4.5*myappheight/10)
	-- order
	self:addChild(self.mytitle)
	self:addChild(self.bgmvolumeslider)
	self:addChild(self.sfxvolumeslider)
	self:addChild(self.difficultyslider)
	-- tooltip layer
	local tooltiplayer = Sprite.new()
	-- buttons
	local key
	self.sfxsound = {sound=Sound.new("audio/ui/sfx_sounds_button1.wav"), time=0, delay=0.2}
	self.sfxvolume = g_sfxvolume * 0.01
	-- movement
	if (keyNames[g_keyleft] or 0) == 0 then key = utf8.char(g_keyleft)
	else key = keyNames[g_keyleft] -- display nice KeyCode name
	end
	self.btnLEFT = ButtonMonster.new({
		autoscale=false, pixelwidth=17*8, pixelheight=6*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text=key, ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=self.sfxsound, volume=self.sfxvolume,
		tooltiptext="left", tooltipttf=myttf, tooltiptextcolor=g_ui_theme.tooltiptextcolor,
		tooltipoffsetx=g_ui_theme.tooltipoffsetx, tooltipoffsety=g_ui_theme.tooltipoffsety,
	}, 2, tooltiplayer)
	if (keyNames[g_keyright] or 0) == 0 then key = utf8.char(g_keyright)
	else key = keyNames[g_keyright] -- display nice KeyCode name
	end
	self.btnRIGHT = ButtonMonster.new({
		autoscale=false, pixelwidth=17*8, pixelheight=6*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text=key, ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=self.sfxsound, volume=self.sfxvolume,
		tooltiptext="right", tooltipttf=myttf, tooltiptextcolor=g_ui_theme.tooltiptextcolor,
		tooltipoffsetx=g_ui_theme.tooltipoffsetx, tooltipoffsety=g_ui_theme.tooltipoffsety,
	}, 3, tooltiplayer)
	if (keyNames[g_keyup] or 0) == 0 then key = utf8.char(g_keyup)
	else key = keyNames[g_keyup] -- display nice KeyCode name
	end
	self.btnUP = ButtonMonster.new({
		autoscale=false, pixelwidth=17*8, pixelheight=6*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text=key, ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=self.sfxsound, volume=self.sfxvolume,
		tooltiptext="up", tooltipttf=myttf, tooltiptextcolor=g_ui_theme.tooltiptextcolor,
		tooltipoffsetx=g_ui_theme.tooltipoffsetx, tooltipoffsety=g_ui_theme.tooltipoffsety,
	}, 1, tooltiplayer)
	if (keyNames[g_keydown] or 0) == 0 then key = utf8.char(g_keydown)
	else key = keyNames[g_keydown] -- display nice KeyCode name
	end
	self.btnDOWN = ButtonMonster.new({
		autoscale=false, pixelwidth=17*8, pixelheight=6*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text=key, ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=self.sfxsound, volume=self.sfxvolume,
		tooltiptext="down", tooltipttf=myttf, tooltiptextcolor=g_ui_theme.tooltiptextcolor,
		tooltipoffsetx=g_ui_theme.tooltipoffsetx, tooltipoffsety=g_ui_theme.tooltipoffsety,
	}, 4, tooltiplayer)
	-- actions
	if (keyNames[g_keyaction1] or 0) == 0 then key = utf8.char(g_keyaction1)
	else key = keyNames[g_keyaction1] -- display nice KeyCode name
	end
	self.btnACTION1 = ButtonMonster.new({
		autoscale=false, pixelwidth=17*8, pixelheight=6*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text=key, ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=self.sfxsound, volume=self.sfxvolume,
		tooltiptext="punch", tooltipttf=myttf, tooltiptextcolor=g_ui_theme.tooltiptextcolor,
		tooltipoffsetx=g_ui_theme.tooltipoffsetx, tooltipoffsety=g_ui_theme.tooltipoffsety,
	}, 5, tooltiplayer)
	if (keyNames[g_keyaction2] or 0) == 0 then key = utf8.char(g_keyaction2)
	else key = keyNames[g_keyaction2] -- display nice KeyCode name
	end
	self.btnACTION2 = ButtonMonster.new({
		autoscale=false, pixelwidth=17*8, pixelheight=6*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text=key, ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=self.sfxsound, volume=self.sfxvolume,
		tooltiptext="kick", tooltipttf=myttf, tooltiptextcolor=g_ui_theme.tooltiptextcolor,
		tooltipoffsetx=g_ui_theme.tooltipoffsetx, tooltipoffsety=g_ui_theme.tooltipoffsety,
	}, 6, tooltiplayer)
	if (keyNames[g_keyaction3] or 0) == 0 then key = utf8.char(g_keyaction3)
	else key = keyNames[g_keyaction3] -- display nice KeyCode name
	end
	self.btnACTION3 = ButtonMonster.new({
		autoscale=false, pixelwidth=17*8, pixelheight=6*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text=key, ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=self.sfxsound, volume=self.sfxvolume,
		tooltiptext="jump", tooltipttf=myttf, tooltiptextcolor=g_ui_theme.tooltiptextcolor,
		tooltipoffsetx=g_ui_theme.tooltipoffsetx, tooltipoffsety=g_ui_theme.tooltipoffsety,
	}, 7, tooltiplayer)
	-- btn menu
	self.btnMENU = ButtonMonster.new({
		autoscale=false, pixelwidth=12*8, pixelheight=6*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text="MENU", ttf=myttf, textcolorup=0x0009B3, textcolordown=0x45d1ff,
		sound=self.sfxsound, volume=self.sfxvolume,
		tooltiptext="Enter", tooltipttf=myttf, tooltiptextcolor=g_ui_theme.tooltiptextcolor,
		tooltipoffsetx=g_ui_theme.tooltipoffsetx, tooltipoffsety=g_ui_theme.tooltipoffsety,
	}, 8, tooltiplayer)
	-- put the btns in a table for keyboard navigation
	self.btns = {}
	self.btns[#self.btns + 1] = self.btnUP -- 1
	self.btns[#self.btns + 1] = self.btnLEFT -- 2
	self.btns[#self.btns + 1] = self.btnRIGHT -- 3
	self.btns[#self.btns + 1] = self.btnDOWN -- 4
	self.btns[#self.btns + 1] = self.btnACTION1 -- 5
	self.btns[#self.btns + 1] = self.btnACTION2 -- 6
	self.btns[#self.btns + 1] = self.btnACTION3 -- 7
	self.btns[#self.btns + 1] = self.btnMENU -- 8
	self.selector = 1 -- starting button
	self.iskeyboardnavigation = false
	-- position
	self.btnLEFT:setPosition(2.5*myappwidth/10+myappleft, 6*8+6*myappheight/10)
	self.btnRIGHT:setPosition(4.5*myappwidth/10+myappleft, 6*8+6*myappheight/10)
	self.btnUP:setPosition(3.5*myappwidth/10+myappleft, 6*8+4.6*myappheight/10)
	self.btnDOWN:setPosition(3.5*myappwidth/10+myappleft, 6*8+7.4*myappheight/10)
	for i = 5, 7 do -- buttons actions
		self.btns[i]:setPosition(7.6*myappwidth/10+myappleft, (i-5)*6*8+6*myappheight/10)
	end
	self.btnMENU:setPosition(myappwidth-self.btnMENU:getWidth()/2+myappleft, myappheight-self.btnMENU:getHeight()/2)
	-- order
	for k, v in ipairs(self.btns) do self:addChild(v) end
	self:addChild(tooltiplayer) -- last add tooltip layer
	-- sliders listeners
	self.bgmvolumeslider:addEventListener("value_just_changed", self.onValueJustChanged, self)
	self.bgmvolumeslider:addEventListener("value_changing", self.onValueChanging, self)
	self.bgmvolumeslider:addEventListener("value_changed", self.onValueChanged, self)
	self.sfxvolumeslider:addEventListener("value_just_changed", self.onValueJustChanged, self)
	self.sfxvolumeslider:addEventListener("value_changing", self.onValueChanging, self)
	self.sfxvolumeslider:addEventListener("value_changed", self.onValueChanged, self)
	self.difficultyslider:addEventListener("value_just_changed", self.onValueJustChanged, self)
	self.difficultyslider:addEventListener("value_changing", self.onValueChanging, self)
	self.difficultyslider:addEventListener("value_changed", self.onValueChanged, self)
	-- buttons listeners
	for k, v in ipairs(self.btns) do
--		v:addEventListener("pressed", function(e) -- e.currselector, e.disabled
--			self.selector = k
--			self:buttonsAction()
--		end)
		v:addEventListener("clicked", function(e) -- e.currselector, e.disabled
			self:cancelKeyRemapping() -- setColorTransform, self.isremapping = false, updateButton()
			self.selector = k
			self:buttonsAction()
		end)
		v:addEventListener("hovered", function(e) -- e.currselector, e.disabled
			if not self.isremapping then
				self.selector = e.currselector
			end
		end)
		v.btns = self.btns -- for keyboard navigation
	end
	-- mouse listener
	self:addEventListener(Event.MOUSE_DOWN, function(e)
		if self:hitTestPoint(e.x, e.y) then -- cancel key remapping
			self.iskeyboardnavigation = false
			self:cancelKeyRemapping()
			e:stopPropagation()
		end
	end)
	-- let's go!
	self:difficulty(g_difficulty)
	self.isremapping = false
	local function fun()
		-- called async otherwise may crash the app
		self:updateButtons()
		Core.yield(1)
	end
	Core.asyncCall(fun)
	self:myKeysPressed()
end

-- sliders
function Options:difficulty(x) -- translate int to text
	if x >= 2 then self.difficultyslider.textfield:setText("DIFFICULTY: \e[color=#ddc]HARD\e[color]")
	elseif x >= 1 then self.difficultyslider.textfield:setText("DIFFICULTY: \e[color=#ddc]NORMAL\e[color]")
	else self.difficultyslider.textfield:setText("DIFFICULTY: \e[color=#ddc]EASY\e[color]")
	end
end
function Options:onValueJustChanged(e)
	self:cancelKeyRemapping()
	if e.id == 1 then -- bgm volume
		g_bgmvolume = e.value
		self.bgmvolumeslider:setValue(g_bgmvolume)
	elseif e.id == 2 then -- sfx volume
		g_sfxvolume = e.value
		self.sfxvolumeslider:setValue(g_sfxvolume)
	elseif e.id == 3 then -- difficulty
		g_difficulty = e.value
		self:difficulty(g_difficulty)
	end
end
function Options:onValueChanging(e)
	if e.id == 1 then -- bgm volume
		g_bgmvolume = e.value
		self.bgmvolumeslider:setValue(g_bgmvolume)
	elseif e.id == 2 then -- sfx volume
		g_sfxvolume = e.value
		self.sfxvolumeslider:setValue(g_sfxvolume)
	elseif e.id == 3 then -- difficulty
		self:difficulty(e.value)
	end
end
function Options:onValueChanged(e)
	if e.id == 1 then -- bgm volume
		g_bgmvolume = e.value
		local audio = Sound.new("audio/sfx/sfx_wpn_laser4.wav")
		local channel = audio:play() -- feedback
		if channel then channel:setVolume(g_bgmvolume*0.01) end
		self.bgmvolumeslider:setValue(g_bgmvolume)
	elseif e.id == 2 then -- sfx volume
		g_sfxvolume = e.value
		local audio = Sound.new("audio/sfx/sfx_wpn_laser4.wav")
		local channel = audio:play() -- feedback
		if channel then channel:setVolume(g_sfxvolume*0.01) end
		self.sfxvolumeslider:setValue(g_sfxvolume)
		for _, v in pairs(self.btns) do v:setVolume(g_sfxvolume*0.01) end -- change the ui buttons sfx volume
	elseif e.id == 3 then -- difficulty
		g_difficulty = e.value
		self:difficulty(g_difficulty)
	end
	mySavePrefs(g_configfilepath)
end

-- key remapping
function Options:remapKey(xbool)
	local btn = self.btns[self.selector]
	if xbool then btn:setColorTransform(255/255, 255/255, 0/255, 255/255)
	else btn:setColorTransform(255/255, 255/255, 255/255, 255/255)
	end
end
function Options:cancelKeyRemapping()
	self.isremapping = false
	self:remapKey(self.isremapping)
	self:updateButtons()
end

-- update buttons state
function Options:updateButtons()
	for k, v in ipairs(self.btns) do
		v.currselector = self.selector
		v:updateVisualState()
		if self.iskeyboardnavigation then
			if k == self.selector then v:selectionSfx() end -- play sound on keyboard navigation
		end
	end
end

-- keys handler
function Options:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		if self.isremapping then -- KEY REMAPPING
			if e.keyCode == KeyCode.ESC or e.keyCode == KeyCode.ENTER then
				self:cancelKeyRemapping()
				return
			end
			local keycode = e.keyCode
			local key = keyNames[keycode]
			if (keyNames[keycode] or 0) == 0 then key = utf8.char(keycode) end
			self.btns[self.selector]:changeText(key)
			if self.selector == 1 then g_keyup = keycode -- follows self.btns order
			elseif self.selector == 2 then g_keyleft = keycode -- follows self.btns order
			elseif self.selector == 3 then g_keyright = keycode -- follows self.btns order
			elseif self.selector == 4 then g_keydown = keycode -- follows self.btns order
			elseif self.selector == 5 then g_keyaction1 = keycode -- follows self.btns order
			elseif self.selector == 6 then g_keyaction2 = keycode -- follows self.btns order
			elseif self.selector == 7 then g_keyaction3 = keycode -- follows self.btns order
			end
			self:cancelKeyRemapping()
			mySavePrefs(g_configfilepath)
		else -- KEYBOARD NAVIGATION
			if e.keyCode == KeyCode.ESC or e.keyCode == KeyCode.BACK then switchToScene(Menu.new()) end
			-- keyboard
			if e.keyCode == KeyCode.UP or e.keyCode == g_keyup or e.keyCode == KeyCode.LEFT or e.keyCode == g_keyleft then
				self.selector -= 1 if self.selector < 1 then self.selector = #self.btns end
				self.iskeyboardnavigation = true
				self:updateButtons()
			elseif e.keyCode == KeyCode.DOWN or e.keyCode == g_keydown or e.keyCode == KeyCode.RIGHT or e.keyCode == g_keyright then
				self.selector += 1 if self.selector > #self.btns then self.selector = 1 end
				self.iskeyboardnavigation = true
				self:updateButtons()
			end
			-- modifier
			local modifier = application:getKeyboardModifiers()
			local alt = (modifier & KeyCode.MODIFIER_ALT) > 0
			if not alt and (e.keyCode == KeyCode.ENTER or e.keyCode == KeyCode.SPACE or e.keyCode == g_keyaction1) then
				self:buttonsAction()
			elseif alt and e.keyCode == KeyCode.ENTER then -- switch full screen
				if not application:isPlayerMode() then
					ismyappfullscreen = not ismyappfullscreen
					application:setFullScreen(ismyappfullscreen)
				end
			end
		end
	end)
end

-- buttons action
function Options:buttonsAction()
	self.isremapping = false
	for k, v in ipairs(self.btns) do
		if k == self.selector then
			if v.isdisabled then
				print("btn disabled!", k)
			elseif k >= 1 and k <= #self.btns-1 then -- action buttons
				self.isremapping = true
				self:remapKey(self.isremapping)
			elseif k == #self.btns then -- MENU button
				switchToScene(Menu.new())
			else
				print("nothing here!", k)
			end
		end
	end
end
