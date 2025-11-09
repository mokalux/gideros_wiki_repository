--[[
-- ButtonMonster
-- mokalux, cc0
-- Pixel, Image, 9patch, Text, Tooltip,
-- Up, Down, Disabled, Hover,
-- Sfx, Touch, Mouse and Keyboard navigation!
-- Functions
v 0.2.1: 2024-04-22 added function callback (functions with no parameters for now!)
v 0.2.0: 2023-12-01 terminator, should be fine in games too now
v 0.1.0: 2021-06-01 total recall, this class has become a Monster! best used in menus but who knows?
v 0.0.1: 2020-03-28 init (based on the initial generic Gideros Button class)
]]

-- Class
ButtonMonster = Core.class(Sprite)

function ButtonMonster:init(xparams, xselector, xttlayer)
	-- user params
	self.params = xparams or {}
	-- add keyboard navigation?
	self.selector = xselector or nil -- button id selector
	self.btns = nil -- assign this value directly from your code (you assign it a list of buttons)
	-- add a layer for the tooltip?
	self.tooltiplayer = xttlayer or nil
	-- button params
	self.params.autoscale = xparams.autoscale or (xparams.autoscale == nil) -- bool (default = true)
	self.params.btnscalexup = xparams.btnscalexup or 1 -- number
	self.params.btnscaleyup = xparams.btnscaleyup or self.params.btnscalexup -- number
	self.params.btnscalexdown = xparams.btnscalexdown or self.params.btnscalexup -- number
	self.params.btnscaleydown = xparams.btnscaleydown or self.params.btnscaleyup -- number
	self.params.btnalphaup = xparams.btnalphaup or 1 -- number
	self.params.btnalphadown = xparams.btnalphadown or self.params.btnalphaup -- number
	-- pixel?
	self.params.pixelcolorup = xparams.pixelcolorup or 0xffffff -- color
	self.params.pixelcolordown = xparams.pixelcolordown or self.params.pixelcolorup -- color
	self.params.pixelcolordisabled = xparams.pixelcolordisabled or 0x555555 -- color
	self.params.pixelimgup = xparams.pixelimgup or nil -- img Up Texture
	self.params.pixelimgdown = xparams.pixelimgdown or self.params.pixelimgup -- img Down Texture
	self.params.pixelimgdisabled = xparams.pixelimgdisabled or self.params.pixelimgup -- img Disabled Texture
	self.params.pixelalphaup = xparams.pixelalphaup or 1 -- number
	self.params.pixelalphadown = xparams.pixelalphadown or self.params.pixelalphaup -- number
	self.params.pixelscalexup = xparams.pixelscalexup or 1 -- number
	self.params.pixelscaleyup = xparams.pixelscaleyup or self.params.pixelscalexup -- number
	self.params.pixelscalexdown = xparams.pixelscalexdown or self.params.pixelscalexup -- number
	self.params.pixelscaleydown = xparams.pixelscaleydown or self.params.pixelscaleyup -- number
	self.params.pixelwidth = xparams.pixelwidth or 24 -- 24, number (autoscale = x padding else width)
	self.params.pixelheight = xparams.pixelheight or self.params.pixelwidth -- number (autoscale = y padding else height)
	self.params.ninepatch = xparams.ninepatch or 16 -- 0, 8, number
	-- text?
	self.params.text = xparams.text or nil -- string
	self.params.ttf = xparams.ttf or nil -- ttf font
	self.params.textcolorup = xparams.textcolorup or 0x0 -- color
	self.params.textcolordown = xparams.textcolordown or self.params.textcolorup -- color
	self.params.textcolordisabled = xparams.textcolordisabled or 0x777777 -- color
	self.params.textalphaup = xparams.textalphaup or 1 -- number
	self.params.textalphadown = xparams.textalphaup or self.params.textalphaup -- number
	self.params.textscalexup = xparams.textscalexup or 1 -- number
	self.params.textscaleyup = xparams.textscaleyup or self.params.textscalexup -- number
	self.params.textscalexdown = xparams.textscalexdown or self.params.textscalexup -- number
	self.params.textscaleydown = xparams.textscaleydown or self.params.textscaleyup -- number
	-- tool tip?
	self.params.tooltiptext = xparams.tooltiptext or nil -- string
	self.params.tooltipttf = xparams.tooltipttf or nil -- ttf font
	self.params.tooltiptextcolor = xparams.tooltiptextcolor or 0x0 -- color
	self.params.tooltiptextscale = xparams.tooltiptextscale or 1 -- number
	self.params.tooltipoffsetx = xparams.tooltipoffsetx or 0 -- number
	self.params.tooltipoffsety = xparams.tooltipoffsety or 0 -- self.params.tooltipoffsetx -- number
	-- audio?
	self.params.sound = xparams.sound or nil -- sound fx
	self.params.volume = xparams.volume or 0.5 -- sound volume
	-- EXTRAS
	self.params.fun = xparams.fun or nil -- function (please check function name if not working!)
	-- set warnings, errors
	if self.params.fun and type(self.params.fun) ~= "function" then
		print("*** ERROR ***", "ON BUTTON: "..self.selector or "?", "YOU ARE NOT PASSING A FUNCTION")
		if self.params.text then self.params.text = self.params.text.." (error)"
		else self.params.text = "error"
		end
		self.params.ttf = nil self.params.textscalexup = 3 self.params.textscaleyup = 3
		self.params.textcolorup = 0xff0000
	end
	-- let's go!
	self:setButton()
	-- update visual state
	self.focus = false
	self.hover = false
	self.disabled = false
	self:updateVisualState()
	-- mouse event listeners
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
	self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
	self:addEventListener(Event.MOUSE_HOVER, self.onMouseHover, self)
	-- touch event listeners
	self:addEventListener(Event.TOUCHES_BEGIN, self.onTouchesBegin, self)
	self:addEventListener(Event.TOUCHES_MOVE, self.onTouchesMove, self)
	self:addEventListener(Event.TOUCHES_END, self.onTouchesEnd, self)
	self:addEventListener(Event.TOUCHES_CANCEL, self.onTouchesCancel, self)
end

-- FUNCTIONS
function ButtonMonster:setButton()
	-- text dimensions
	local textwidth, textheight
	if self.params.text then
		if self.tf then self:removeChild(self.tf) self.tf = nil end
		self.tf = TextField.new(self.params.ttf, self.params.text, self.params.text)
		self.tf:setAnchorPoint(0.5, 0.5)
		self.tf:setScale(self.params.textscalexup, self.params.textscaleyup)
		self.tf:setTextColor(self.params.textcolorup)
		self.tf:setAlpha(self.params.textalphaup)
		textwidth, textheight = self.tf:getWidth(), self.tf:getHeight()
	end
	-- first add pixel
	if self.pixel then self:removeChild(self.pixel) self.pixel = nil end
	if self.params.autoscale and self.params.text then
		self.pixel = Pixel.new(self.params.pixelcolorup, self.params.pixelalphaup,
			textwidth+self.params.pixelwidth, textheight+self.params.pixelheight)
	else
		self.pixel = Pixel.new(self.params.pixelcolorup, self.params.pixelalphaup,
			self.params.pixelwidth, self.params.pixelheight)
	end
	self.pixel:setScale(self.params.pixelscalexup, self.params.pixelscaleyup)
	self.pixel:setAnchorPoint(0.5, 0.5)
	self.pixel:setNinePatch(self.params.ninepatch)
	if self.params.pixelimgup then self.pixel:setTexture(self.params.pixelimgup)
	elseif self.params.pixelimgdown then self.pixel:setTexture(self.params.pixelimgdown)
	elseif self.params.pixelimgdisabled then self.pixel:setTexture(self.params.pixelimgdisabled)
	end
	self:addChild(self.pixel)
	-- then add text?
	if self.params.text then self:addChild(self.tf) end
	-- finally add tooltip?
	if self.params.tooltiptext then
		if self.ttiptf then
			if self.tooltiplayer then self.tooltiplayer:removeChild(self.ttiptf)
			else self:removeChild(self.ttiptf)
			end self.ttiptf = nil
		end
		self.ttiptf = TextField.new(self.params.tooltipttf, self.params.tooltiptext, self.params.tooltiptext)
		self.ttiptf:setScale(self.params.tooltiptextscale)
		self.ttiptf:setTextColor(self.params.tooltiptextcolor)
		self.ttiptf:setVisible(false)
		if self.tooltiplayer then self.tooltiplayer:addChild(self.ttiptf)
		else self:addChild(self.ttiptf)
		end
	end
end

function ButtonMonster:updateVisualState()
	local function visualState(btn, btnscalex, btnscaley, btnalpha, textcolor, textscalex, textscaley,
			pixeltex, pixelcolor, pixelalpha, pixelscalex, pixelscaley)
		btn:setScale(btnscalex, btnscaley)
		btn:setAlpha(btnalpha)
		if btn.params.text then
			btn.tf:setTextColor(textcolor)
			btn.tf:setScale(textscalex, textscaley)
		end
		if pixeltex then btn.pixel:setTexture(pixeltex) end
		btn.pixel:setColor(pixelcolor, pixelalpha)
		btn.pixel:setScale(pixelscalex, pixelscaley)
	end
	if self.btns then
--		print("KEYBOARD NAVIGATION")
		for k, v in ipairs(self.btns) do
			if v.disabled then -- disabledState
				visualState(v, v.params.btnscalexdown, v.params.btnscaleydown, v.params.btnalphadown,
					v.params.textcolordisabled, v.params.textscalexdown, v.params.textscaleydown,
					v.params.pixelimgdisabled, v.params.pixelcolordisabled,
					v.params.pixelalphadown, v.params.pixelscalexdown, v.params.pixelscaleydown)
--				if v.ttiptf and not v.disabled then -- OPTION 1: hides tooltip when button is Disabled
				if v.ttiptf then -- OPTION 2: shows tooltip even if button is Disabled, you choose!
					v.ttiptf:setText("("..v.params.tooltiptext..")") -- extra!
					if k == v.currselector then v.ttiptf:setVisible(true)
					else v.ttiptf:setVisible(false)
					end
				end
			elseif k == v.currselector then -- downState
				visualState(v, v.params.btnscalexdown, v.params.btnscaleydown, v.params.btnalphadown,
					v.params.textcolordown, v.params.textscalexdown, v.params.textscaleydown,
					v.params.pixelimgdown, v.params.pixelcolordown,
					v.params.pixelalphadown, v.params.pixelscalexdown, v.params.pixelscaleydown)
				if v.ttiptf then
					v.ttiptf:setText(v.params.tooltiptext)
					if v.tooltiplayer then -- reset tooltip text position
						v.ttiptf:setPosition(
							v:getX()+v.params.tooltipoffsetx, v:getY()+v.params.tooltipoffsety)
					else
						v.ttiptf:setPosition(v:globalToLocal(
							v:getX()+v.params.tooltipoffsetx, v:getY()+v.params.tooltipoffsety))
					end
					v.ttiptf:setVisible(true)
				end
			else -- upState
				visualState(v, v.params.btnscalexup, v.params.btnscaleyup, v.params.btnalphaup,
					v.params.textcolorup, v.params.textscalexup, v.params.textscaleyup,
					v.params.pixelimgup, v.params.pixelcolorup,
					v.params.pixelalphaup, v.params.pixelscalexup, v.params.pixelscaleyup)
				if v.ttiptf then v.ttiptf:setVisible(false) end
			end
		end
	else
--		print("TOUCH, MOUSE NAVIGATION")
		if self.disabled then -- disabledState
			visualState(self, self.params.btnscalexdown, self.params.btnscaleydown, self.params.btnalphadown,
				self.params.textcolordisabled, self.params.textscalexdown, self.params.textscaleydown,
				self.params.pixelimgdisabled, self.params.pixelcolordisabled,
				self.params.pixelalphadown, self.params.pixelscalexdown, self.params.pixelscaleydown)
--			if self.ttiptf and not self.disabled then -- OPTION 1: hides tooltip when button is Disabled
			if self.ttiptf then -- OPTION 2: shows tooltip even if button is Disabled, you choose!
				self.ttiptf:setText("("..self.params.tooltiptext..")") -- extra!
				if self.focus then self.ttiptf:setVisible(true)
				else self.ttiptf:setVisible(false)
				end
			end
		elseif self.focus or self.hover then -- downState
			visualState(self, self.params.btnscalexdown, self.params.btnscaleydown, self.params.btnalphadown,
				self.params.textcolordown, self.params.textscalexdown, self.params.textscaleydown,
				self.params.pixelimgdown, self.params.pixelcolordown,
				self.params.pixelalphadown, self.params.pixelscalexdown, self.params.pixelscaleydown)
			if self.ttiptf then
				self.ttiptf:setText(self.params.tooltiptext)
				self.ttiptf:setVisible(true)
			end
		else -- upState
			visualState(self, self.params.btnscalexup, self.params.btnscaleyup, self.params.btnalphaup,
				self.params.textcolorup, self.params.textscalexup, self.params.textscaleyup,
				self.params.pixelimgup, self.params.pixelcolorup,
				self.params.pixelalphaup, self.params.pixelscalexup, self.params.pixelscaleyup)
			if self.ttiptf then self.ttiptf:setVisible(false) end
		end
	end
end

-- SOME UTILITY FUNCTIONS
function ButtonMonster:changeText(xtext)
	self.params.text = xtext
	self:setButton()
end
function ButtonMonster:getText()
	return self.params.text
end
function ButtonMonster:setDisabled(disabled)
	if self.disabled == disabled then return end
	self.disabled = disabled
	self:updateVisualState()
end
function ButtonMonster:getDisabled()
	return self.disabled
end

-- LISTENERS
-- MOUSE
function ButtonMonster:onMouseDown(ev) -- both mouse and touch
	if self:hitTestPoint(ev.x, ev.y, true) then -- (x,y,onlyvisible,ref)
		self.focus = true
		if self.btns then -- update keyboard button id selector
			for k, v in ipairs(self.btns) do v.currselector = self.selector end
		end
		self:updateVisualState()
--		self:selectionSfx() -- play sound fx, you choose!
		local e = Event.new("pressed")
		e.currselector = self.selector -- update button id selector
		e.disabled = self.disabled -- update button disabled
		self:dispatchEvent(e) -- button is clicked, dispatch "clicked" event
--		if self.params.fun then self.params.fun(self:getParent()) end -- YOU CAN ADD THIS HERE
		if self.ttiptf then -- set tooltip initial position
			if self.tooltiplayer then
				self.ttiptf:setPosition(
					self:getX()+self.params.tooltipoffsetx, self:getY()+self.params.tooltipoffsety)
			else
				self.ttiptf:setPosition(self:globalToLocal(
					self:getX()+self.params.tooltipoffsetx, self:getY()+self.params.tooltipoffsety))
			end
		end
		ev:stopPropagation()
	end
end
function ButtonMonster:onMouseMove(ev) -- both mouse and touch
	if self.focus then
		if self.ttiptf then -- tooltip follows position
			if self.tooltiplayer then
				self.ttiptf:setPosition(
					ev.x + self.params.tooltipoffsetx, ev.y + self.params.tooltipoffsety)
			else
				self.ttiptf:setPosition(self:globalToLocal(
					ev.x + self.params.tooltipoffsetx, ev.y + self.params.tooltipoffsety))
			end
		end
		if not self:hitTestPoint(ev.x, ev.y, true) then -- (x,y,onlyvisible,ref)
			self.focus = false
			self:updateVisualState()
		end
		ev:stopPropagation()
	elseif self.ttiptf then -- reset tooltip text position
		if self.tooltiplayer then
			self.ttiptf:setPosition(
				self:getX()+self.params.tooltipoffsetx, self:getY()+self.params.tooltipoffsety)
		else
			self.ttiptf:setPosition(self:globalToLocal(
				self:getX()+self.params.tooltipoffsetx, self:getY()+self.params.tooltipoffsety))
		end
	end
end
function ButtonMonster:onMouseUp(ev) -- both mouse and touch
	if self.focus then
		self.focus = false
		self:updateVisualState()
		local e = Event.new("clicked")
		e.currselector = self.selector -- update button id selector
		e.disabled = self.disabled -- update button disabled
		self:dispatchEvent(e) -- button is clicked, dispatch "clicked" event
		if self.params.fun then self.params.fun(self:getParent()) end -- OR EVEN HERE?
		ev:stopPropagation()
	end
end
function ButtonMonster:onMouseHover(ev) -- mouse only
	if self:hitTestPoint(ev.x, ev.y, true) then -- onenter
		self.focus = true
		self.hover = true
		if self.ttiptf then -- tooltip follows mouse position
			if self.tooltiplayer then
				self.ttiptf:setPosition(
					ev.x + self.params.tooltipoffsetx, ev.y + self.params.tooltipoffsety)
			else
				self.ttiptf:setPosition(self:globalToLocal(
					ev.x + self.params.tooltipoffsetx, ev.y + self.params.tooltipoffsety))
			end
		end
		-- execute onenter code only once
		self.onenter = not self.onenter
		if not self.onenter then self.moving = true end
		if not self.moving then
			if self.btns then -- update keyboard button id selector
				for k, v in ipairs(self.btns) do v.currselector = self.selector end
			end
			local e = Event.new("hovered") -- dispatch "hovered" event
			e.currselector = self.selector -- update button id selector
			e.disabled = self.disabled -- update button disabled
			self:dispatchEvent(e)
			self:selectionSfx() -- play sound fx? you choose!
			-- trick to remove residuals when fast moving mouse
			local timer = Timer.new(100*1, 1) -- number of repetition, the higher the safer, (delay,repeatCount)
			timer:addEventListener(Event.TIMER, function() self:updateVisualState() end)
			timer:start()
--			if self.params.fun then self.params.fun(self:getParent()) end -- HERE COULD ALSO BE USEFUL?
		else
			self.onexit = true
		end
		ev:stopPropagation()
	else -- onexit
		self.focus = false
		self.hover = false
		self.onenter = false
		self.moving = false
		if self.onexit then -- execute onexit code only once
			self.onexit = false
			self:updateVisualState()
		end
	end
end

-- TOUCHES
-- if button is on focus, stop propagation of touch events
function ButtonMonster:onTouchesBegin(ev) -- touch only
	if self.focus then
		ev:stopPropagation()
	end
end
-- if button is on focus, stop propagation of touch events
function ButtonMonster:onTouchesMove(ev) -- touch only
	if self.focus then
		ev:stopPropagation()
	end
end
-- if button is on focus, stop propagation of touch events
function ButtonMonster:onTouchesEnd(ev) -- touch only
	if self.focus then
		ev:stopPropagation()
	elseif self.ttiptf then -- reset tooltip text position
		if self.tooltiplayer then
			self.ttiptf:setPosition(
				self:getX()+self.params.tooltipoffsetx, self:getY()+self.params.tooltipoffsety)
		else
			self.ttiptf:setPosition(self:globalToLocal(
				self:getX()+self.params.tooltipoffsetx, self:getY()+self.params.tooltipoffsety))
		end
	end
end
-- if touches are cancelled, reset the state of the button
function ButtonMonster:onTouchesCancel(ev) -- app interrupted (phone call, ...), touch only
	if self.focus then
		self.focus = false
		if self.btns then -- update keyboard button id selector
			for k, v in ipairs(self.btns) do v.currselector = self.selector end
		end
		self:updateVisualState()
	elseif self.ttiptf then -- reset tooltip text position
		if self.tooltiplayer then
			self.ttiptf:setPosition(
				self:getX()+self.params.tooltipoffsetx, self:getY()+self.params.tooltipoffsety)
		else
			self.ttiptf:setPosition(self:globalToLocal(
				self:getX()+self.params.tooltipoffsetx, self:getY()+self.params.tooltipoffsety))
		end
	end
end

-- AUDIO
function ButtonMonster:selectionSfx()
	if self.params.sound then
		local snd = self.params.sound
		local curr = os.timer()
		local prev = snd.time
		if curr - prev > snd.delay then
			local channel = snd.sound:play()
			if channel then channel:setVolume(self.params.volume) end
			snd.time = curr
		end
	end
end
function ButtonMonster:setVolume(xvolume)
	self.params.volume = xvolume
end
function ButtonMonster:getVolume()
	return self.params.volume
end
