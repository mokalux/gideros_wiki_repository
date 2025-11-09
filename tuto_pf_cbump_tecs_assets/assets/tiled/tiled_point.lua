Tiled_Shape_Point = Core.class(Sprite)

function Tiled_Shape_Point:init(xparams)
	-- params
	local params = xparams or {}
	params.x = xparams.x or nil
	params.y = xparams.y or nil
	params.shapelinewidth = xparams.shapelinewidth or 0
	params.color = xparams.color or nil -- hex
	params.alpha = xparams.alpha or 1
	params.rotation = xparams.rotation or 0
	params.data = xparams.data or nil
	params.value = xparams.value or nil
	-- image
	local img = Shape.new()
	img:setLineStyle(params.shapelinewidth, params.color, params.alpha) -- (width, color, alpha)
	img:beginPath()
	img:moveTo(0,0)
	img:lineTo(1, 0)
	img:endPath()
	img:setRotation(params.rotation)
	img:setAlpha(params.alpha)
	self.w, self.h = img:getWidth(), img:getHeight()
	self:addChild(img)
end
