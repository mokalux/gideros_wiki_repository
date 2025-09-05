Tiled_Shape_Rectangle = Core.class(Sprite)

function Tiled_Shape_Rectangle:init(xparams)
	-- params
	local params = xparams or {}
	params.x = xparams.x or nil
	params.y = xparams.y or nil
	params.w = xparams.w or nil
	params.h = xparams.h or nil
	params.rotation = xparams.rotation or nil
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
	params.skewy = xparams.skewy or 0 -- params.skewx, angle in degrees
	params.data = xparams.data or nil
	params.value = xparams.value or nil
	-- image
	local img = Shape.new()
	img:setLineStyle(params.shapelinewidth, params.shapelinecolor, params.shapelinealpha) -- (width, color, alpha)
	if params.texpath then
		local tex
		if not params.istexpot then
			tex = Texture.new(params.texpath, false, { wrap=Texture.REPEAT, extend=false, } )
		else
			tex = Texture.new(params.texpath, false, { wrap=Texture.REPEAT, } )
		end
		local skewanglex = math.rad(params.skewx)
		local skewangley = math.rad(params.skewy)
		local matrix = Matrix.new(
			params.scalex, math.tan(skewanglex), math.tan(skewangley), params.scaley, 0, 0
		)
		img:setFillStyle(Shape.TEXTURE, tex, matrix)
--		img:setShader(Effect.colour_pixelation)
		tex = nil
	elseif params.color then
		img:setFillStyle(Shape.SOLID, params.color)
	else
		img:setFillStyle(Shape.NONE)
	end
	img:beginPath()
	img:moveTo(0, 0)
	img:lineTo(params.w, 0)
	img:lineTo(params.w, params.h)
	img:lineTo(0, params.h)
	img:lineTo(0, 0)
	img:endPath()
	img:setRotation(params.rotation)
	img:setAlpha(params.alpha)
	img:setColorTransform(params.r/255, params.g/255, params.b/255, params.alpha)
	self:addChild(img)
end
