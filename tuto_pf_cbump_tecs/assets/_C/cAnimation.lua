CAnimation = Core.class()

function CAnimation:init(xanimspeed)
	-- animation
	self.curranim = g_ANIM_DEFAULT
	self.frame = 0
	self.animspeed = xanimspeed
	self.animtimer = self.animspeed
end

function CAnimation:cutSpritesheet(xspritesheetpath, xcols, xrows, xanimsimgs, xoffx, xoffy, sx, sy)
	-- retrieve all anims in texture
	local myanimstex = Texture.new(xspritesheetpath)
	local cellw = myanimstex:getWidth()/xcols
	local cellh = myanimstex:getHeight()/xrows
	for r = 1, xrows do
		for c = 1, xcols do
			local myanimstexregion = TextureRegion.new(
				myanimstex, (c-1)*cellw, (r-1)*cellh, cellw, cellh
			)
			xanimsimgs[#xanimsimgs + 1] = myanimstexregion
		end
	end
	-- the bitmap
	self.bmp = Bitmap.new(xanimsimgs[1]) -- starting bmp texture
	self.bmp:setScale(sx, sy) -- scale!
	self.bmp:setAnchorPoint(0.5, 0.5) -- we will flip the bitmap
	-- set position inside sprite
	self.bmp:setPosition(xoffx*sx, xoffy*sy) -- work best with image centered spritesheets
	-- our final sprite
	self.sprite = Sprite.new()
	self.sprite:addChild(self.bmp)
	self.bmp:setColorTransform(8*32/255, 8*32/255, 8*32/255, 9*32/255)
end

function CAnimation:createAnim(xanims, xanimname, xanimsimgs, xtable, xstart, xfinish)
	xanims[xanimname] = {}
	if xtable and #xtable > 0 then
		for i = 1, #xtable do
			xanims[xanimname][#xanims[xanimname]+1] = xanimsimgs[xtable[i]]
		end
	else
		for i = xstart, xfinish do
			xanims[xanimname][#xanims[xanimname]+1] = xanimsimgs[i]
		end
	end
end
