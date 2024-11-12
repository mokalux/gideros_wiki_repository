Menu = Core.class(Sprite)

function Menu:init()
	-- bg
	application:setBackgroundColor(g_ui_theme.backgroundcolor)
	-- init
	local sndbtn = {sound=Sound.new("audio/ui/sfx_sounds_button1.wav"), time=0, delay=0.2}
	local sfxvolume = g_sfxvolume * 0.01 -- sound between 0 and 1
	local tooltiplayer = Sprite.new()
	local difficulty = g_difficulty
	if difficulty >= 2 then difficulty = "hard"
	elseif difficulty >= 1 then difficulty = "normal"
	else difficulty = "easy"
	end
	-- buttons
	local mybtnstart = ButtonMonster.new({
		autoscale=false, pixelwidth=20*8, pixelheight=8*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text="START", ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=sndbtn, volume=sfxvolume,
		tooltiptext=difficulty, tooltipttf=myttf, tooltiptextcolor=g_ui_theme.tooltiptextcolor,
		tooltipoffsetx=g_ui_theme.tooltipoffsetx-1.7*8, tooltipoffsety=g_ui_theme.tooltipoffsety+0.5*8,
	}, 1, tooltiplayer)
	local mybtnoptions = ButtonMonster.new({
		autoscale=false, pixelwidth=20*8, pixelheight=8*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text="OPTIONS", ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=sndbtn, volume=sfxvolume,
	}, 2)
	local mybtnexit = ButtonMonster.new({
		autoscale=false, pixelwidth=20*8, pixelheight=8*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.exit,
		text="EXIT", ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=sndbtn, volume=sfxvolume,
	}, 3)
	-- buttons table for keyboard navigation
	self.btns = {}
	self.btns[#self.btns + 1] = mybtnstart
	self.btns[#self.btns + 1] = mybtnoptions
	self.btns[#self.btns + 1] = mybtnexit
	self.selector = 1 -- starting button
	-- position
	mybtnstart:setPosition(12*myappwidth/16+myappleft, 4*myappheight/16)
	mybtnoptions:setPosition(12*myappwidth/16+myappleft, 8*myappheight/16)
	mybtnexit:setPosition(12*myappwidth/16+myappleft, 13*myappheight/16)
	-- order
	for k, v in ipairs(self.btns) do self:addChild(v) end
	self:addChild(tooltiplayer)
	-- buttons listeners
	for k, v in ipairs(self.btns) do
		v:addEventListener("clicked", function() self.selector = k self:buttonsAction() end)
		v:addEventListener("hovered", function(e) self.selector = e.currselector end)
		v.btns = self.btns -- for keyboard navigation
	end
	-- let's go
	local function fun()
		-- called async otherwise may crash the app
		self:updateButtons()
		Core.yield(1)
	end
	Core.asyncCall(fun)
	self:myKeysPressed()
end

-- update buttons state
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
		if e.keyCode == KeyCode.UP or e.keyCode == g_keyup or
			e.keyCode == KeyCode.LEFT or e.keyCode == g_keyleft then
			self.selector -= 1 if self.selector < 1 then self.selector = #self.btns end
			self:updateButtons()
		elseif e.keyCode == KeyCode.DOWN or e.keyCode == g_keydown or
			e.keyCode == KeyCode.RIGHT or e.keyCode == g_keyright then
			self.selector += 1 if self.selector > #self.btns then self.selector = 1 end
			self:updateButtons()
		elseif e.keyCode == KeyCode.SPACE or e.keyCode == g_keyaction1 then
			self:buttonsAction()
		elseif e.keyCode == KeyCode.ESC or e.keyCode == KeyCode.BACK then
--			if not application:isPlayerMode() then application:exit() else print("EXIT") end
		end
		-- modifier
		local modifier = application:getKeyboardModifiers()
		local alt = (modifier & KeyCode.MODIFIER_ALT) > 0
		if not alt and e.keyCode == KeyCode.ENTER then self:buttonsAction()
		elseif alt and e.keyCode == KeyCode.ENTER then -- switch full screen
			if not application:isPlayerMode() then
				ismyappfullscreen = not ismyappfullscreen
				application:setFullScreen(ismyappfullscreen)
			end
		end
	end)
end

-- buttons action
function Menu:buttonsAction()
	for k, v in ipairs(self.btns) do
		if k == self.selector then
			if v.isdisabled then -- nothing here
				print("btn disabled!", k)
			elseif k == 1 then
				switchToScene(LevelX.new()) -- LevelX
			elseif k == 2 then
				switchToScene(Options.new()) -- Options
			elseif k == 3 then -- EXIT
				if not application:isPlayerMode() then
					stage:removeAllListeners()
					for i = stage:getNumChildren(), 1, -1 do
						stage:getChildAt(i):removeAllListeners()
						stage:removeChildAt(i)
					end collectgarbage()
					-- exit
					application:exit()
				else
					print("Exit button ", k)
				end
			end
		end
	end
end
