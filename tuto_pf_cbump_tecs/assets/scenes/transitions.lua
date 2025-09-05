Transitions = Core.class(Sprite)

function Transitions:init(xnextscene)
	self.nextscene = xnextscene
	-- a movieclip for transitions (you can replace the pixel with a bitmap, ...)
	local pixel = Pixel.new(g_ui_theme.pixelcolorup, 1, myappwidth, myappheight)
	local mc = MovieClip.new{{ -- you choose the duration, the effects, ...
		1, 64, pixel, -- 50, 64, 32
		{
			x = { myappleft, myappleft, },
			y = { 0, myappheight, tweens[31] }, -- tweens[random(#tweens)]
			alpha = { 1, 0, tweens[19] }, -- tweens[random(#tweens)]
		}
	}}
	mc:play() -- play only once
	-- order
	self:addChild(mc)
	-- listeners
	mc:addEventListener(Event.COMPLETE, function()
		self:gotoScene(self.nextscene)
	end)
	-- let's go
	local function fun()
		self:myKeysPressed()
		Core.yield(1)
	end
	Core.asyncCall(fun)
end

-- cancel the transition
function Transitions:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		if e.keyCode == KeyCode.ESC or
			e.keyCode == KeyCode.ENTER or
			e.keyCode == KeyCode.SPACE or
			e.keyCode == g_keyaction1 then
			self:gotoScene(self.nextscene)
		end
	end)
end

-- scenes navigation
function Transitions:gotoScene(xnextscene)
	self:removeAllListeners()
	for i = stage:getNumChildren(), 1, -1 do
		stage:getChildAt(i):removeAllListeners()
		stage:removeChildAt(i)
	end collectgarbage()
	-- transition to next scene (eg.: Menu.new())
	stage:addChild(xnextscene)
end
