SOscillation = Core.class()

function SOscillation:init(xtiny, xbworld, xplayer1)
	xtiny.processingSystem(self) -- called once on init and every frames
	self.bworld = xbworld -- cbump world
	self.player1 = xplayer1
end

function SOscillation:filter(ent) -- tiny function
	return ent.oscillation
end

function SOscillation:onAdd(ent) -- tiny function
--	print("SOscillation:onAdd")
	ent.angle = 0 -- add an extra params, important XXX
end

function SOscillation:onRemove(ent) -- tiny function
--	print("SOscillation:onRemove")
end

local p1rangetoofarx = myappwidth*1 -- disable systems to save some CPU, magik XXX
local p1rangetoofary = myappheight*1 -- disable systems to save some CPU, magik XXX
function SOscillation:process(ent, dt) -- tiny function
	local function fun()
		ent.doanimate = true
		-- OUTSIDE VISIBLE RANGE
		if (ent.pos.x > self.player1.pos.x + p1rangetoofarx or
			ent.pos.x < self.player1.pos.x - p1rangetoofarx) or
			(ent.pos.y > self.player1.pos.y + p1rangetoofary or
			ent.pos.y < self.player1.pos.y - p1rangetoofary) then
			ent.doanimate = false
			return
		end
		local function collisionfilter(item, other) -- "touch", "cross", "slide", "bounce"
			return nil -- "cross"
		end
		-- cbump
		local goalx = ent.pos.x + ent.oscillation.vx * dt
		local goaly = ent.pos.y + ent.oscillation.vy * dt
		local nextx, nexty = self.bworld:move(ent, goalx, goaly, collisionfilter)
		-- oscillation
		ent.angle += ent.oscillation.speed
		ent.oscillation.vx = math.cos(^<ent.angle)*ent.oscillation.amplitudex
		ent.oscillation.vy = math.sin(^<ent.angle)*ent.oscillation.amplitudey
		-- move & flip
		ent.pos = vector(nextx, nexty)
		ent.sprite:setPosition(ent.pos + vector(ent.collbox.w/2, -ent.h/2+ent.collbox.h))
		Core.yield(1)
	end
	Core.asyncCall(fun)
end
