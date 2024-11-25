SDebugSpriteSorting = Core.class()

function SDebugSpriteSorting:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
end

function SDebugSpriteSorting:filter(ent) -- tiny function
	return ent.sprite
end

function SDebugSpriteSorting:onAdd(ent) -- tiny function
	-- debugposition
	ent.debugposition = Pixel.new(0xaa5500, 1, 16, 16)
	ent.debugposition:setAnchorPoint(0.5, 0.5)
	if ent.isplayer1 then ent.debugposition:setColor(0xaa5500, 1) end
	ent.spritelayer:addChild(ent.debugposition)
	-- debugstartyposition
	ent.debugstartyposition = Pixel.new(0xaa557f, 1, 16, 16)
	ent.debugstartyposition:setAnchorPoint(0.5, 0.5)
	if ent.isplayer1 then ent.debugstartyposition:setColor(0xaa557f, 1) end
	ent.spritelayer:addChild(ent.debugstartyposition)
end

function SDebugSpriteSorting:onRemove(ent) -- tiny function
	ent.spritelayer:removeChild(ent.debugposition)
	ent.spritelayer:removeChild(ent.debugstartyposition)
end

function SDebugSpriteSorting:process(ent, dt) -- tiny function
	local function fun()
		ent.debugposition:setPosition(ent.pos)
		ent.debugstartyposition:setPosition(ent.pos.x, ent.positionystart)
		Core.yield(1)
	end
	Core.asyncCall(fun)
end
