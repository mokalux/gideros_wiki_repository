SShadow = Core.class()

function SShadow:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
end

function SShadow:filter(ent) -- tiny function
	return ent.shadow
end

function SShadow:onAdd(ent) -- tiny function
	ent.spritelayer:addChildAt(ent.shadow.sprite, 1) -- add shadow behind ent
end

function SShadow:onRemove(ent) -- tiny function
	ent.spritelayer:removeChild(ent.shadow.sprite)
end

function SShadow:process(ent, dt) -- tiny function
	local function fun()
		ent.shadow.sprite:setPosition(ent.pos+vector(ent.collbox.w/2, ent.collbox.h/2))
		if ent.body and not ent.body.isonfloor then
			ent.shadow.sprite:setPosition(ent.pos.x+ent.collbox.w/2, ent.positionystart+ent.collbox.h/2)
		end
		Core.yield(1)
	end
	Core.asyncCall(fun)
end
