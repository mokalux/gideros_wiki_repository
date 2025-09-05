EDoor = Core.class()

function EDoor:init(xid, xspritelayer, xpos, xtexpath, xcolor, w, h, dx, dy, xdir, xspeed, xbgfxlayer)
	local function hexToRgb(hex)
		return (hex >> 16 & 0xff), (hex >> 8 & 0xff), (hex & 0xff)
	end
	-- ids
	self.isdoor = true
	self.eid = xid -- player1 needs key matching eid
	-- sprite layers
	self.spritelayer = xspritelayer
	self.bgfxlayer = xbgfxlayer
	-- params
	self.pos = xpos
	self.sx = 1
	self.sy = self.sx
	self.flip = 1
	if xtexpath then -- texture + color modulate?
		local tex = Texture.new(xtexpath)
		local texsx, texsy = tex:getWidth()/w, tex:getHeight()/h
		self.sprite = Pixel.new(tex, w, h, texsx, texsy)
		if xcolor then -- color modulate
			local r, g, b = hexToRgb(xcolor)
			self.sprite:setColorTransform(r/255, g/255, b/255, 1)
		end
	else -- color only
		self.sprite = Pixel.new(xcolor or 0xffffff, 1, w, h)
	end
	self.sprite:setAnchorPoint(0.5, 0.5)
	self.sprite:setScale(self.sx, self.sy)
	self.w, self.h = self.sprite:getWidth(), self.sprite:getHeight()
	-- COMPONENTS
	-- BODY: CBody:init(xmass, xspeed, xupspeed)
	self.body = CBody.new(1, xspeed.x, xspeed.y)
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
	local collw, collh = self.w//1, self.h//1 -- must be round numbers for cbump physics!
	self.collbox = CCollisionBox.new(collw, collh)
	-- motion AI: CDistance:init(xstartpos, dx, dy)
	self.distance = CDistance.new(self.pos, dx, dy)
	self.dir = xdir
end
