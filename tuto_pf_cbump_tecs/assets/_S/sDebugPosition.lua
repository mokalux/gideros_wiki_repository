SDebugPosition = Core.class()

function SDebugPosition:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
end

function SDebugPosition:filter(ent) -- tiny function
	return ent.pos
end

function SDebugPosition:onAdd(ent) -- tiny function
	local debugcolor = 0x0000a5
	if ent.isplayer1 then debugcolor = 0x0000ff end
	ent.debug = Pixel.new(debugcolor, 2, 5, 5)
	ent.spritelayer:addChild(ent.debug)
end

function SDebugPosition:onRemove(ent) -- tiny function
	ent.debug:removeFromParent()
end

function SDebugPosition:process(ent, dt) -- tiny function
	local function fun()
		ent.debug:setPosition(ent.pos)
		Core.yield(1)
	end
	Core.asyncCall(fun)
end
