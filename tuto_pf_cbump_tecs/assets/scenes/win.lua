Win = Core.class(Sprite)

function Win:init()
	-- bg
	local myttf = TTFont.new("fonts/Cabin-Regular-TTF.ttf", 4*8) -- UI
	-- typewriter effect
	local text = [[

	Platformer Tuto for the Gideros
	framework (what else?).

	Programmer: mokalux Aug. 2025 ;-)

	]]
	-- TypeWriter:init(font, text, delay, char)
	local tw = TypeWriter.new(cf2, text, 32*8, 3)
	tw:setTextColor(math.random(0xff0000, 0xffffff))
	tw:setLayout( { w=myappwidth/1.8, flags=FontBase.TLF_CENTER } )
	tw:addEventListener("finished", function(e) --
	end)
	-- buttons setup
	local sndbtn = Sound.new("audio/ui/sfx_sounds_button1.wav")
	local sfxvolume = g_sfxvolume * 0.01
	local tooltiplayer = Sprite.new()
	-- buttons (only one button)
	local mybtnmenu = ButtonMonster.new({
		autoscale=false, pixelwidth=20*8, pixelheight=8*8,
		pixelscalexup=0.8, pixelscalexdown=0.9,
		pixelcolorup=g_ui_theme.pixelcolorup, pixelcolordown=g_ui_theme.pixelcolordown,
		text="MENU", ttf=myttf, textcolorup=g_ui_theme.textcolorup, textcolordown=g_ui_theme.textcolordown,
		sound=sndbtn, volume=sfxvolume,
	}, 1, tooltiplayer)
	-- buttons table for keyboard navigation
	self.btns = {}
	self.btns[#self.btns + 1] = mybtnmenu
	self.selector = 1 -- starting button
	-- position
	tw:setPosition(5*myappwidth/16, 1*myappheight/16)
	mybtnmenu:setPosition(8*myappwidth/16, 14*myappheight/16)
	-- order
	self:addChild(tw)
	for k, v in ipairs(self.btns) do self:addChild(v) end
	self:addChild(tooltiplayer)
	-- buttons listeners
	for k, v in ipairs(self.btns) do
		v:addEventListener("clicked", function(e) self.selector = k self:gotoScene() end) -- Menu
		v:addEventListener("hovered", function(e) self.selector = e.currselector end)
		v.btns = self.btns -- for keyboard navigation
	end
	-- let's go
	local function fun()
		self:updateButtons()
		self:myKeysPressed()
		Core.yield(1)
	end
	Core.asyncCall(fun)
end

-- update buttons state
function Win:updateButtons()
	for k, v in ipairs(self.btns) do
		v.currselector = self.selector
		v:updateVisualState()
		if k == self.selector then v:selectionSfx() end -- play sound on keyboard navigation
	end
end

-- keyboard navigation
function Win:myKeysPressed()
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
		-- Menu
		elseif e.keyCode == KeyCode.SPACE or e.keyCode == g_keyaction1 then self:gotoScene()
		elseif e.keyCode == KeyCode.ESC then self:gotoScene()
		end
		-- modifiers
		local modifier = application:getKeyboardModifiers()
		local alt = (modifier & KeyCode.MODIFIER_ALT) > 0
		if not alt and e.keyCode == KeyCode.ENTER then self:gotoScene() -- Menu
		elseif alt and e.keyCode == KeyCode.ENTER then -- switch fullscreen
			if not application:isPlayerMode() then
				ismyappfullscreen = not ismyappfullscreen
				application:setFullScreen(ismyappfullscreen)
			end
		end
	end)
end

-- scenes navigation
function Win:gotoScene()
	g_currlevel = 1
	switchToScene(Menu.new()) -- next scene
end
