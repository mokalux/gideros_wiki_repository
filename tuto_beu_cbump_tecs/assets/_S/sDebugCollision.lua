SDebugCollision = Core.class()

function SDebugCollision:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
end

function SDebugCollision:filter(ent) -- tiny function
	return ent.collbox
end

function SDebugCollision:onAdd(ent) -- tiny function
	local debugcolor = 0xff00ff
	if ent.isplayer1 then debugcolor = 0x00ffff end
	ent.debug = Pixel.new(debugcolor, 0.25, ent.collbox.w, ent.collbox.h)
	ent.spritelayer:addChild(ent.debug)
end

function SDebugCollision:onRemove(ent) -- tiny function
	ent.spritelayer:removeChild(ent.debug)
end

function SDebugCollision:process(ent, dt) -- tiny function
	ent.debug:setPosition(ent.x, ent.y)
end
