CAnimation = Core.class()

function CAnimation:init(xspritesheetpath, xcols, xrows, xanimspeed, xoffx, xoffy, sx, sy)
	-- animation
	self.curranim = g_ANIM_DEFAULT
	self.frame = 0
	self.animspeed = xanimspeed
	self.animtimer = self.animspeed
	-- retrieve all anims in texture
	local myanimstex = Texture.new(xspritesheetpath)
	local cellw = myanimstex:getWidth() / xcols
	local cellh = myanimstex:getHeight() / xrows
	self.myanimsimgs = {}
	local myanimstexregion
	for r = 1, xrows do
		for c = 1, xcols do
			myanimstexregion = TextureRegion.new(myanimstex, (c - 1) * cellw, (r - 1) * cellh, cellw, cellh)
			self.myanimsimgs[#self.myanimsimgs + 1] = myanimstexregion
		end
	end
	-- anims table ("walk", "jump", "shoot", ...)
	self.anims = {}
	-- the bitmap
	self.bmp = Bitmap.new(self.myanimsimgs[1]) -- starting bmp texture
	self.bmp:setScale(sx, sy) -- scale!
	self.bmp:setAnchorPoint(0.5, 0.5) -- we will flip the bitmap
	-- set position inside sprite
	self.bmp:setPosition(xoffx*sx, xoffy*sy) -- work best with image centered spritesheets
	-- our final sprite
	self.sprite = Sprite.new()
	self.sprite:addChild(self.bmp)
end

function CAnimation:createAnim(xanimname, xstart, xfinish)
	self.anims[xanimname] = {}
	for i = xstart, xfinish do
		self.anims[xanimname][#self.anims[xanimname]+1] = self.myanimsimgs[i]
	end
end
