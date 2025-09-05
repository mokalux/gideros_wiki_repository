Tiled_Shape_Text = Core.class(Sprite)

function Tiled_Shape_Text:init(xparams)
	-- params
	local params = xparams or {}
	params.x = xparams.x or nil
	params.y = xparams.y or nil
	params.text = xparams.text or nil
	params.ttf = xparams.ttf or nil
	params.w = xparams.w or nil
	params.h = xparams.h or nil
	params.rotation = xparams.rotation or nil
	params.color = xparams.color or nil
	params.r = xparams.r or 255
	params.g = xparams.g or 255
	params.b = xparams.b or 255
	params.alpha = xparams.alpha or 1
	params.scalex = xparams.scalex or 1
	params.scaley = xparams.scaley or params.scalex
	params.data = xparams.data or nil
	params.value = xparams.value or nil
	-- image
	local img = TextField.new(params.ttf, params.text, params.text)
--	img:setAnchorPoint(0, -1)
	if params.color then
		img:setTextColor(params.color)
	end
	img:setRotation(params.rotation)
	img:setAlpha(params.alpha)
	img:setColorTransform(params.r/255, params.g/255, params.b/255, params.alpha)
	-- auto scale
	local currw = img:getWidth()
	img:setScale(params.w/currw)
	--
	self:addChild(img)
end
