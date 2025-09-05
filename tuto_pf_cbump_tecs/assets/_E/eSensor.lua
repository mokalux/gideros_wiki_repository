ESensor = Core.class()

function ESensor:init(xid, xspritelayer, xpos, w, h, xbgfxlayer)
	-- ids
	self.issensor = true
	self.eid = xid -- sensor will assign its eid to player inventory (doorid, keyid, ...)
--	print("issensor", self.eid)
	-- sprite layers
	self.spritelayer = xspritelayer
	self.bgfxlayer = xbgfxlayer
	-- params
	self.pos = xpos
	self.sx = 1
	self.sy = self.sx
	self.flip = 1
	self.w, self.h = w*self.sx, h*self.sy
	-- COMPONENTS
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
	local collw, collh = self.w//1, self.h//1 -- full size collision box, must be round numbers for cbump physics!
	self.collbox = CCollisionBox.new(collw, collh)
end
