SDebugHurtBoxPlayer = Core.class()

function SDebugHurtBoxPlayer:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
end

function SDebugHurtBoxPlayer:filter(ent) -- tiny function
	return (ent.headhurtbox or ent.spinehurtbox) and not ent.isnme
end

function SDebugHurtBoxPlayer:onAdd(ent) -- tiny function
	-- debugheadhurtbox
	ent.debugheadhurtbox = Pixel.new(0x5500ff, 0.5, ent.headhurtbox.w, ent.headhurtbox.h)
	ent.debugheadhurtbox:setAnchorPoint(0.5, 0.5)
	ent.spritelayer:addChild(ent.debugheadhurtbox)
	-- debugspinehurtbox
	ent.debugspinehurtbox = Pixel.new(0xff00ff, 0.5, ent.spinehurtbox.w, ent.spinehurtbox.h)
	ent.debugspinehurtbox:setAnchorPoint(0.5, 0.5)
	ent.spritelayer:addChild(ent.debugspinehurtbox)
end

function SDebugHurtBoxPlayer:onRemove(ent) -- tiny function
	ent.spritelayer:removeChild(ent.debugheadhurtbox)
	ent.spritelayer:removeChild(ent.debugspinehurtbox)
end

function SDebugHurtBoxPlayer:process(ent, dt) -- tiny function
	ent.debugheadhurtbox:setPosition(ent.x+ent.collbox.w/2+(ent.headhurtbox.x*ent.flip), ent.y+ent.headhurtbox.y)
	ent.debugspinehurtbox:setPosition(ent.x+ent.collbox.w/2+(ent.spinehurtbox.x*ent.flip), ent.y+ent.spinehurtbox.y)
end






