SDebugCollectible = Core.class()

function SDebugCollectible:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
end

function SDebugCollectible:filter(ent) -- tiny function
	return ent.iscollectible
end

function SDebugCollectible:onAdd(ent) -- tiny function
	ent.debugpickablebox = Pixel.new(0xff00ff, 0.5, ent.collbox.w, ent.collbox.h)
	ent.debugpickablebox:setAnchorPoint(0.5, 0.5)
	ent.spritelayer:addChild(ent.debugpickablebox)
end

function SDebugCollectible:onRemove(ent) -- tiny function
	ent.spritelayer:removeChild(ent.debugpickablebox)
end

function SDebugCollectible:process(ent, dt) -- tiny function
	ent.debugpickablebox:setPosition(ent.x+(ent.collbox.x*ent.flip), ent.y+ent.collbox.y)
end



















