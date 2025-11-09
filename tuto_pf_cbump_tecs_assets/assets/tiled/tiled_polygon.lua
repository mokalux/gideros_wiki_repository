Tiled_Shape_Polygon = Core.class(Sprite)

function Tiled_Shape_Polygon:init(xparams)
	-- params
	local params = xparams or {}
	params.x = xparams.x or nil
	params.y = xparams.y or nil
	params.coords = xparams.coords or nil
	params.color = xparams.color or nil -- hex
	params.r = xparams.r or 255
	params.g = xparams.g or 255
	params.b = xparams.b or 255
	params.alpha = xparams.alpha or 1
	params.texpath = xparams.texpath or nil
	params.istexpot = xparams.istexpot or nil
	params.shapelinewidth = xparams.shapelinewidth or 0
	params.shapelinecolor = xparams.shapelinecolor or nil
	params.shapelinealpha = xparams.shapelinealpha or 1
	params.scalex = xparams.scalex or 1
	params.scaley = xparams.scaley or params.scalex
	params.skewx = xparams.skewx or 0 -- angle in degrees
	params.skewy = xparams.skewy or params.skewx -- angle in degrees
	params.rotation = xparams.rotation or 0
	params.data = xparams.data or nil
	params.value = xparams.value or nil
	-- image
	local img = Shape.new()
	img:setLineStyle(params.shapelinewidth, params.shapelinecolor, params.shapelinealpha) -- (width, color, alpha)
	if params.texpath then
		local tex
		if not params.istexpot then
			tex = Texture.new(params.texpath, false, {wrap = Texture.REPEAT, extend = false})
		else
			tex = Texture.new(params.texpath, false, {wrap = Texture.REPEAT})
		end
		local skewanglex = math.rad(params.skewx)
		local skewangley = math.rad(params.skewy)
		local matrix = Matrix.new(
			params.scalex, math.tan(skewanglex), math.tan(skewangley), params.scaley, 0, 0
		)
		img:setFillStyle(Shape.TEXTURE, tex, matrix)
		tex = nil
	elseif params.color then
		img:setFillStyle(Shape.SOLID, params.color, params.alpha)
	else
		img:setFillStyle(Shape.NONE)
	end
	img:beginPath()
	img:moveTo(params.coords[1].x, params.coords[1].y)
	for p = 2, #params.coords do
		img:lineTo(params.coords[p].x, params.coords[p].y)
	end
	img:closePath()
	img:endPath()
	img:setRotation(params.rotation)
	img:setAlpha(params.alpha)
	img:setColorTransform(params.r/255, params.g/255, params.b/255, params.alpha)
	self.w, self.h = img:getWidth(), img:getHeight()
	self:addChild(img)
end
