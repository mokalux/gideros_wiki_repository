SCollision = Core.class()

function SCollision:init(xtiny, xbworld) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
	self.bworld = xbworld
end

function SCollision:filter(ent) -- tiny function
	return ent.collbox and ent.body
end

function SCollision:onAdd(ent) -- tiny function
end

function SCollision:onRemove(ent) -- tiny function
end

local col -- cbump perfs?
function SCollision:process(ent, dt) -- tiny function
	local function fun()
		-- collision filter
		local function collisionfilter(item, other) -- "touch", "cross", "slide", "bounce"
			if item.isactionjump1 or other.isactionjump1 or
				item.isactionjumppunch1 or other.isactionjumppunch1 or
				item.isactionjumpkick1 or other.isactionjumpkick1 or
				item.isdead or other.isdead then return nil
			elseif item.iscollectible or other.iscollectible then return "cross"
			end return "slide"
		end
		-- cbump
		local goalx = ent.pos.x + ent.body.vx * dt
		local goaly = ent.pos.y + ent.body.vy
		local nextx, nexty, collisions, len = self.bworld:move(ent, goalx, goaly, collisionfilter)
		-- collisions
		for i = 1, len do
			col = collisions[i]
			if col.item.iscollectible and col.other.isplayer1 then col.item.isdirty = true
			elseif col.item.isplayer1 and col.other.iscollectible then col.other.isdirty = true
			end
		end
		-- move & flip
		ent.pos = vector(nextx, nexty)
		ent.sprite:setPosition(ent.pos + vector(ent.collbox.w/2, -ent.h/2+ent.collbox.h/2))
		ent.animation.bmp:setScale(ent.sx * ent.flip, ent.sy)
		Core.yield(0.1)
	end
	Core.asyncCall(fun)
end
