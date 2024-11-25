SDebugHurtBoxNme = Core.class()

function SDebugHurtBoxNme:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
end

function SDebugHurtBoxNme:filter(ent) -- tiny function
	return (ent.headhurtbox or ent.spinehurtbox) and not ent.isplayer1
end

function SDebugHurtBoxNme:onAdd(ent) -- tiny function
	-- debugheadhurtbox
	ent.debugheadhurtbox = Pixel.new(0x5500ff, 0.5, ent.headhurtbox.w, ent.headhurtbox.h)
	ent.debugheadhurtbox:setAnchorPoint(0.5, 0.5)
	ent.spritelayer:addChild(ent.debugheadhurtbox)
	-- debugspinehurtbox
	ent.debugspinehurtbox = Pixel.new(0xff00ff, 0.5, ent.spinehurtbox.w, ent.spinehurtbox.h)
	ent.debugspinehurtbox:setAnchorPoint(0.5, 0.5)
	ent.spritelayer:addChild(ent.debugspinehurtbox)
end

function SDebugHurtBoxNme:onRemove(ent) -- tiny function
	if not ent.isdestructibleobject then -- isdestructibleobject is somehow already removed!
		ent.spritelayer:removeChild(ent.debugheadhurtbox)
		ent.spritelayer:removeChild(ent.debugspinehurtbox)
	end
end

function SDebugHurtBoxNme:process(ent, dt) -- tiny function
	local function fun()
		ent.debugheadhurtbox:setPosition(ent.pos+vector(ent.collbox.w/2+(ent.headhurtbox.x*ent.flip), ent.headhurtbox.y))
		ent.debugspinehurtbox:setPosition(ent.pos+vector(ent.collbox.w/2+(ent.spinehurtbox.x*ent.flip), ent.spinehurtbox.y))
		Core.yield(1)
	end
	Core.asyncCall(fun)
end
