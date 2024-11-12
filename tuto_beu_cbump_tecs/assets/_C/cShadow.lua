CShadow = Core.class()

function CShadow:init(xparentw, xshadowsx, xshadowsy)
	self.sprite = Bitmap.new(Texture.new("gfx/fx/shadow.png"))
	local sx = (self.sprite:getWidth()><xparentw)/(self.sprite:getWidth()<>xparentw)
	self.sprite:setScale(xshadowsx or sx, xshadowsy or sx)
	self.sprite:setAnchorPoint(0.5, 0.5)
--	self.sprite:setAlpha(0.5)
	self.sprite:setColorTransform(0, 0, 0, 0.65)
end
