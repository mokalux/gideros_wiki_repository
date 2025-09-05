Tiled_Shape_Polyline = Core.class(Sprite)

function Tiled_Shape_Polyline:init(xparams)
	-- params
	local params = xparams or {}
	params.x = xparams.x or nil
	params.y = xparams.y or nil
	params.shapelinewidth = xparams.shapelinewidth or 1 -- 0
	params.color = xparams.color or nil -- hex
	params.r = xparams.r or 255
	params.g = xparams.g or 255
	params.b = xparams.b or 255
	params.alpha = xparams.alpha or 1
	params.coords = xparams.coords or nil
	params.rotation = xparams.rotation or 0
	params.data = xparams.data or nil
	params.value = xparams.value or nil
	-- image
	local img = Shape.new()
	img:setLineStyle(params.shapelinewidth, params.color, params.alpha) -- (width, color, alpha)
	img:setFillStyle(Shape.NONE)
	img:beginPath()
	img:moveTo(params.coords[1].x, params.coords[1].y)
	for p = 2, #params.coords do
		img:lineTo(params.coords[p].x, params.coords[p].y)
	end
--	img:closePath()
	img:endPath()
	img:setRotation(params.rotation)
	img:setAlpha(params.alpha)
	img:setColorTransform(params.r/255, params.g/255, params.b/255, params.alpha)
	self.w, self.h = img:getWidth(), img:getHeight()
	self:addChild(img)
end
