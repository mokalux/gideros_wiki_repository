SSensor = Core.class()

function SSensor:init(xtiny, xbworld, xplayer1)
	xtiny.processingSystem(self) -- called once on init and every frames
	self.bworld = xbworld -- cbump world
	self.player1 = xplayer1
end

function SSensor:filter(ent) -- tiny function
	return ent.issensor
end

function SSensor:onAdd(ent) -- tiny function
--	print("SSensor:onAdd")
end

function SSensor:onRemove(ent) -- tiny function
--	print("SSensor:onRemove")
end

local p1rangetoofarx = myappwidth*1 -- disable systems to save some CPU, magik XXX
local p1rangetoofary = myappheight*1 -- disable systems to save some CPU, magik XXX
function SSensor:process(ent, dt) -- tiny function
	local function fun()
		-- OUTSIDE VISIBLE RANGE
		if (ent.pos.x > self.player1.pos.x + p1rangetoofarx or
			ent.pos.x < self.player1.pos.x - p1rangetoofarx) or
			(ent.pos.y > self.player1.pos.y + p1rangetoofary or
			ent.pos.y < self.player1.pos.y - p1rangetoofary) then
			ent.doanimate = false
			return
		end
		local function collisionfilter2(item) -- only one param: "item", return true, false or nil
			if item.isplayer1 then return true end
		end
		--local items, len = world:queryRect(l,t,w,h, filter)
		local items, len2 = self.bworld:queryRect(
			ent.pos.x, ent.pos.y, ent.w, ent.h, collisionfilter2
		)
		for i = 1, len2 do
			items[i].insensor = ent.eid -- add an extra var to player1
		end
		Core.yield(1)
	end
	Core.asyncCall(fun)
end
