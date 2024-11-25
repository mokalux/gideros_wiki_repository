--[[
-- ASlider
-- mokalux, cc0
-- Slith, Knob, steps, text, ...
v 0.0.1: 2024-04-23 my take on a ui slider
]]

-- Class
ASlider = Core.class(Sprite) -- integers only slider

local floor = math.floor

function ASlider:init(xparams)
	local params = xparams or {}
	params.initialvalue = xparams.initialvalue or 0
	params.maximum = xparams.maximum or 100
	params.steps = xparams.steps or params.maximum
	params.slitcolor = xparams.slitcolor or 0x0
	params.slitalpha = xparams.slitalpha or 1
	params.slitw = xparams.slitw or 64
	params.slith = xparams.slith or 64
	params.knobcolor = xparams.knobcolor or 0xffffff
	params.knobalpha = xparams.knobalpha or 1
	params.knobw = xparams.knobw or 32
	params.knobh = xparams.knobh or 32
	params.text = xparams.text or nil
	params.font = xparams.font or nil
	params.textscale = xparams.textscale or 1
	params.textcolor = xparams.textcolor or 0xffffff
	params.textoffsetx = xparams.textoffsetx or 0
	params.textoffsety = xparams.textoffsety or 0
	params.textrotation = xparams.textrotation or 0
	params.id = xparams.id or nil
	-- slit and knob
	self.slit = Pixel.new(params.slitcolor, params.slitalpha, params.slitw, params.slith)
	self.slit:setAnchorPoint(0, 0.5)
	self.knob = Pixel.new(params.knobcolor, params.knobalpha, params.knobw, params.knobh)
	self.knob:setAnchorPoint(0.5, 0.5)
	-- textfield
	self.textfield = TextField.new(params.font, params.text or params.maximum) -- if no text then maximum
	self.textfield:setRotation(params.textrotation)
	self.textfield:setScale(params.textscale)
	self.textfield:setTextColor(params.textcolor)
	-- position
	self.textfield:setPosition(self.slit:getX() + params.textoffsetx, self.slit:getY() + params.textoffsety)
	-- order
	self:addChild(self.slit)
	self:addChild(self.knob)
	self:addChild(self.textfield)
	-- class variables
	self.value = params.initialvalue
	self.maximum = params.maximum
	self.steps = params.steps
	self.width = self.slit:getWidth()
	self.text = params.text
	self.isFocus = false
	self.id = params.id
	-- let's go!
	self:setValue(self.value)
	-- event listeners
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
	self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
end

-- helper function
function ASlider:setRange(x, xstep)
	for s = 0, self.width do
		if x <= 0 + (self.width / xstep)/2 then
			return 0
		elseif x >= s * self.width / xstep and x <= (s + 1) * self.width / xstep - (self.width / xstep)/2 then
			return s * self.width / xstep
		elseif x >= (s + 1) * self.width / xstep - (self.width / xstep)/2 and x <= (s + 1) * self.width / xstep then
			return (s + 1) * self.width / xstep
		elseif x >= self.width - (self.width / xstep)/2 then
			return self.width
		end
	end
end

-- events
function ASlider:onMouseDown(event)
	if self.slit:hitTestPoint(event.x, event.y) or self.knob:hitTestPoint(event.x, event.y) then
		local function round(val, n)
			if (n) then return floor( (val * 10^n)+0.5 ) / (10^n) 
			else return floor(val+0.5)
			end
		end
		local x, _y = self:globalToLocal(event.x, event.y)
		self.isFocus = true
		self.knob:setX(self:setRange(x, self.steps))
		self.value = round(self.maximum * self.knob:getX() / self.width, 3)
		local e = Event.new("value_just_changed")
		e.value = self.value
		e.id = self.id
		self:dispatchEvent(e)
		event:stopPropagation()
	end
end

function ASlider:onMouseMove(event)
	if self.isFocus then
		local function round(val, n)
			if (n) then return floor( (val * 10^n)+0.5 ) / (10^n)
			else return floor(val+0.5)
			end
		end
		local x, _y = self:globalToLocal(event.x, event.y)
		self.knob:setX(self:setRange(x, self.steps))
		self.value = round(self.maximum * self.knob:getX() / self.width, 3)
		local e = Event.new("value_changing")
		e.value = self.value
		e.id = self.id
		self:dispatchEvent(e)
		event:stopPropagation()
	end
end

function ASlider:onMouseUp(event)
	if self.isFocus then
		self.isFocus = false
		local e = Event.new("value_changed")
		e.value = self.value
		e.id = self.id
		self:dispatchEvent(e)
		event:stopPropagation()
	end
end

-- function
function ASlider:setValue(xvalue)
	-- check within range [0, max]
	if xvalue < 0 then xvalue = 0 end
	if xvalue > self.maximum then xvalue = self.maximum end
	local posX = self.width * xvalue / self.maximum
	self.knob:setPosition(posX, 0)
	self.value = xvalue
	if self.text then self.textfield:setText(self.text.."\e[color=#ddc]"..self.value.."\e[color]") -- value is themed ;-)
	else self.textfield:setText("\e[color=#ddc]"..self.value.."\e[color]") -- value is themed ;-)
	end
end
