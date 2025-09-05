SDebugCollision = Core.class()

function SDebugCollision:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
end

function SDebugCollision:filter(ent) -- tiny function
	return ent.collbox
end

function SDebugCollision:onAdd(ent) -- tiny function
	local debugcolor = 0x9b009b
	if ent.isplayer1 then debugcolor = 0xff00ff end
	ent.debug = Pixel.new(debugcolor, 0.5, ent.collbox.w, ent.collbox.h)
	ent.spritelayer:addChild(ent.debug)
end

function SDebugCollision:onRemove(ent) -- tiny function
	ent.debug:removeFromParent()
end

function SDebugCollision:process(ent, dt) -- tiny function
	local function fun()
		ent.debug:setPosition(ent.pos)
		Core.yield(1)
	end
	Core.asyncCall(fun)
end
