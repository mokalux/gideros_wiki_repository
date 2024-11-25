SAI = Core.class()

local random = math.random

function SAI:init(xtiny, xplayer1) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
	self.player1 = xplayer1
end

function SAI:filter(ent) -- tiny function
	return ent.ai
end

function SAI:onAdd(ent) -- tiny function
end

function SAI:onRemove(ent) -- tiny function
end

local p1rangex = 192 -- 192 -- magik XXX
local p1hitrangex = 64 -- magik XXX
local p1rangey = 96 -- 96 -- magik XXX
local p1hitrangey = 16 -- magik XXX
local rndaction = 0 -- random punch/kick action
local p1rangetoofar = myappwidth -- disable system to save some CPU, magik XXX
function SAI:process(ent, dt) -- tiny function
	if ent.isdead then return end
	local function fun()
		-- some flags
		ent.doanimate = true -- to save some cpu
		ent.readytohit = false
		if (ent.pos.x > self.player1.pos.x + p1rangetoofar or ent.pos.x < self.player1.pos.x - p1rangetoofar) then
			ent.doanimate = false
			return
		end
		if (ent.pos.x > self.player1.pos.x + p1rangex or ent.pos.x < self.player1.pos.x - p1rangex) or
			(ent.pos.y > self.player1.pos.y + p1rangey or ent.pos.y < self.player1.pos.y - p1rangey) then -- OUTSIDE ATTACK RANGE
			-- idle
			ent.isleft, ent.isright = false, false
			ent.isup, ent.isdown = false, false
			ent.body.currspeed = ent.body.speed
			ent.body.currjumpspeed = ent.body.jumpspeed
		else -- INSIDE ATTACK RANGE
			-- x
			if ent.pos.x > random(self.player1.pos.x+p1hitrangex, self.player1.pos.x+p1rangex) then
				ent.isleft, ent.isright = true, false
				ent.body.currspeed = ent.body.speed * random(10, 15)*0.1 -- magik XXX
			elseif ent.pos.x < random(self.player1.pos.x-p1rangex, self.player1.pos.x-p1hitrangex) then
				ent.isleft, ent.isright = false, true
				ent.body.currspeed = ent.body.speed * random(10, 15)*0.1 -- magik XXX
			end
			-- y
			if ent.pos.y > random(self.player1.pos.y, self.player1.pos.y+p1hitrangey) then
				ent.isup, ent.isdown = true, false
				ent.body.currjumpspeed = ent.body.jumpspeed * random(10, 64) -- magik XXX
				ent.readytohit = true
			elseif ent.pos.y < random(self.player1.pos.y-p1hitrangey, self.player1.pos.y) then
				ent.isup, ent.isdown = false, true
				ent.body.currjumpspeed = ent.body.jumpspeed * random(10, 64) -- magik XXX
				ent.readytohit = true
			end
			-- nmes always face player1
			if not (ent.isactionjumppunch1 or ent.isactionjumpkick1) then
				if ent.pos.x > self.player1.pos.x then ent.flip = -1
				else ent.flip = 1
				end
			end
		end
		-- ATTACK
		if ent.readytohit then
			ent.curractiontimer -= 1
			if ent.curractiontimer < 0 then
				ent.animation.frame = 0
				rndaction = ent.abilities[random(#ent.abilities)] -- pick a random attack
				if rndaction == 1 and not (ent.isactionjumppunch1 or ent.isactionjumpkick1) then 
					ent.isactionpunch1 = true
				elseif rndaction == 2 and not (ent.isactionjumppunch1 or ent.isactionjumpkick1) then
					ent.isactionpunch2 = true
				elseif rndaction == 3 and not (ent.isactionjumppunch1 or ent.isactionjumpkick1) then
					ent.isactionkick1 = true
				elseif rndaction == 4 and not (ent.isactionjumppunch1 or ent.isactionjumpkick1) then
					ent.isactionkick2 = true
				elseif rndaction == 5 and not (ent.isactionjumppunch1 or ent.isactionjumpkick1) then
					ent.positionystart = ent.pos.y
					ent.body.isonfloor = false
					ent.body.isgoingup = true
					ent.isactionjumppunch1 = true
					ent.body.currspeed *= 1+random(4)*0.1 -- randomize speed, you choose to add it and the params
					-- jump in the direction of the flip
					if ent.flip == 1 then ent.isleft = false ent.isright = true
					else ent.isleft = true ent.isright = false
					end
				elseif rndaction == 6 and not (ent.isactionjumppunch1 or ent.isactionjumpkick1) then
					ent.positionystart = ent.pos.y
					ent.body.isonfloor = false
					ent.body.isgoingup = true
					ent.isactionjumpkick1 = true
					ent.body.currspeed *= 1+random(3)*0.1 -- randomize speed, you choose to add it and the params
					-- jump in the direction of the flip
					if ent.flip == 1 then ent.isleft = false ent.isright = true
					else ent.isleft = true ent.isright = false
					end
				end
				ent.curractiontimer = ent.actiontimer
			end
		end
		Core.yield(1)
	end
	Core.asyncCall(fun) -- profiler seems to be faster without asyncCall (because of pairs traversing?)
end
