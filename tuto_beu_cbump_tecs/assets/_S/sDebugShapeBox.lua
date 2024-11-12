SDebugShapeBox = Core.class()

function SDebugShapeBox:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
end

function SDebugShapeBox:filter(ent) -- tiny function
	return ent.shapebox
end

function SDebugShapeBox:onAdd(ent) -- tiny function
	ent.debugshapebox = Pixel.new(0x0, 0.5, ent.shapebox.w, ent.shapebox.h)
	ent.debugshapebox:setAnchorPoint(0.5, 0.5)
	if ent.isplayer1 then ent.debugshapebox:setColor(0xffff00, 0.5) end
	ent.spritelayer:addChild(ent.debugshapebox)
end

function SDebugShapeBox:onRemove(ent) -- tiny function
	ent.spritelayer:removeChild(ent.debugshapebox)
end

function SDebugShapeBox:process(ent, dt) -- tiny function
	ent.debugshapebox:setPosition(ent.x+(ent.shapebox.x*ent.flip), ent.y+ent.shapebox.y)
end






