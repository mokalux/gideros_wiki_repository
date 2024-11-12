Transitions = Core.class(Sprite)

function Transitions:init(xnextscene)
	self.nextscene = xnextscene
	-- a movieclip for transitions (you can change it to anything you want!)
	local pixel = Pixel.new(g_ui_theme.pixelcolorup, 1, myappwidth, myappheight)
	local mc = MovieClip.new{{ -- you choose the duration, the effects, ...
		1, 50, pixel, -- duration: 64, 32
		{
			y = { 0, myappheight, tweens[31] }, -- tweens[math.random(#tweens)]
			alpha = { 1, 0, tweens[19] }, -- tweens[math.random(#tweens)]
		}
	}}
	mc:play() -- play only once
	-- position
	mc:setPosition(myappleft, myapptop) -- for mobile
	-- order
	self:addChild(mc)
	-- listeners
	mc:addEventListener(Event.COMPLETE, function()
		self:gotoScene(self.nextscene)
	end)
	-- let's go
--	self:myKeysPressed() -- optional
end

-- cut the transition (optional)
function Transitions:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		if e.keyCode == KeyCode.ESC or e.keyCode == KeyCode.ENTER or
			e.keyCode == KeyCode.SPACE or e.keyCode == g_keyaction1 then
			self:gotoScene(self.nextscene)
		end
	end)
end

-- scenes navigation
function Transitions:gotoScene(xnextscene)
	-- unload current assets
	stage:removeAllListeners()
	for i = stage:getNumChildren(), 1, -1 do
		stage:getChildAt(i):removeAllListeners()
		stage:removeChildAt(i)
	end collectgarbage()
	-- load next scene (eg.: Menu.new())
	stage:addChild(xnextscene)
end
