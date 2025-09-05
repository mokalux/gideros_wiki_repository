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
	-- abilities
	-- ent.abilities[#ent.abilities+1] = 1 -- jump/climb
	-- ent.abilities[#ent.abilities+1] = 10 -- action1, shoot
	-- ent.abilities[#ent.abilities+1] = 20 -- action2, shield
	-- ent.abilities[#ent.abilities+1] = 30 -- action3, dash
	ent.abilities = {}
	if ent.body.upspeed > 0 then
		ent.abilities[#ent.abilities+1] = 1 -- jump/climb up
	end
	if ent.eid == 200 then
		ent.abilities[#ent.abilities+1] = 20 -- action2, shield
		if ent.body.speed > 0 then
			ent.abilities[#ent.abilities+1] = 30 -- action3, dash
		end
	elseif ent.eid == 300 then -- nme boss1
		ent.abilities[#ent.abilities+1] = 10 -- action1, shoot
		ent.abilities[#ent.abilities+1] = 20 -- action2, shield
		if ent.body.speed > 0 then
			ent.abilities[#ent.abilities+1] = 30 -- action3, dash
		end
	else
		ent.abilities[#ent.abilities+1] = 20 -- action2, shield
	end
--	for k, v in pairs(ent.abilities) do print(k, v) end
end

function SAI:onRemove(ent) -- tiny function
end

local p1rangetoofarx = myappwidth*2 -- 0.7, disable systems to save some CPU, magik XXX
local p1rangetoofary = myappheight*2 -- 0.7, disable systems to save some CPU, magik XXX
local p1outofrangex = myappwidth*1 -- 0.5, magik XXX
local p1outofrangey = myappheight*1 -- 0.5, magik XXX
local p1actionrange = myappwidth*0.2 -- 3*8, 1*8, myappwidth*0.1, magik XXX
function SAI:process(ent, dt) -- tiny function
	if ent.currlives <= 0 then
		return
	end
	local function fun()
		-- some flags
		ent.doanimate = true -- to save some cpu
		-- OUTSIDE VISIBLE RANGE
		if (ent.pos.x > self.player1.pos.x + p1rangetoofarx or
			ent.pos.x < self.player1.pos.x - p1rangetoofarx) or
			(ent.pos.y > self.player1.pos.y + p1rangetoofary or
			ent.pos.y < self.player1.pos.y - p1rangetoofary) then
			ent.doanimate = false
			return
		end
		-- OUTSIDE ACTION RANGE
		if (ent.pos.x > self.player1.pos.x+p1outofrangex or
			ent.pos.x < self.player1.pos.x-p1outofrangex) or
			(ent.pos.y > self.player1.pos.y+p1outofrangey or
			ent.pos.y < self.player1.pos.y-p1outofrangey) then
			-- idle
			ent.isleft, ent.isright = false, false
			ent.isup, ent.isdown = false, false
			ent.body.currspeed = ent.body.speed
			ent.body.currupspeed = ent.body.upspeed
			ent.readyforaction = false
		else -- INSIDE ACTION RANGE
			-- x
			local rnd = random(100)
			if rnd > 1 and ent.body.speed > 0 then -- allow nme to stop walking, magik XXX
				if ent.pos.x > random(self.player1.pos.x+p1actionrange, self.player1.pos.x+p1outofrangex) then
					ent.isleft, ent.isright = true, false
					ent.body.currspeed = ent.body.speed*random(8, 12)*0.1 -- magik XXX
				elseif ent.pos.x < random(self.player1.pos.x-p1outofrangex, self.player1.pos.x-p1actionrange) then
					ent.isleft, ent.isright = false, true
					ent.body.currspeed = ent.body.speed*random(8, 12)*0.1 -- magik XXX
				end
			elseif ent.body.speed == 0 then -- nme always faces player1
				if ent.pos.x > self.player1.pos.x then
					ent.isleft, ent.isright = true, false
				else
					ent.isleft, ent.isright = false, true
				end
			else -- stop moving
				ent.isleft, ent.isright = false, false
				ent.body.currspeed = ent.body.speed
			end
			-- no going left or right on stairs/ladders
			if ent.isladdercontacts and not (ent.isfloorcontacts or ent.isptpfcontacts) then
				ent.isright, ent.isleft = false, false
			end
			-- bumping on a wall unless isleftofplayer
			ent.isleftofplayer = false
			if ent.pos.x < self.player1.pos.x then
				ent.isleftofplayer = true
			end
			-- y
			-- impulse on top of stairs/ladders and actor is going up
			if ent.isladdercontacts and ent.isptpfcontacts and ent.body.vy < 0 then
				ent.isup, ent.isdown = true, false
				ent.wasup = false
				ent.body.currinputbuffer = ent.body.inputbuffer
				ent.body.currupspeed = ent.body.upspeed*random(8, 12)*0.1 -- magik XXX
			end
			-- only act if entity has abilities
			if #ent.abilities > 0 then
				ent.readyforaction = true
			end
		end
		-- ACTION
		if ent.readyforaction then
			ent.curractiontimer -= 1
			-- don't let the entity get stuck in place when in range
			if ent.body.vx == 0 and ent.body.speed > 0 then
				if ent.pos.x > self.player1.pos.x then ent.isleft, ent.isright = true, false
				else ent.isleft, ent.isright = false, true
				end
				ent.body.currspeed = ent.body.speed*random(8, 12)*0.1 -- magik XXX
			end
			if ent.curractiontimer < 0 then
				-- actor above player1, go down
				if ent.pos.y < self.player1.pos.y and ent.body.upspeed > 0 then
					if ent.isptpfcontacts then
						local rnd = random(100)
						if rnd > 30 then -- 80, magik XXX
							ent.isup, ent.isdown = false, true
							ent.wasdown = false
							ent.body.currupspeed = ent.body.upspeed*random(8, 12)*0.1 -- magik XXX
						end
					elseif ent.body.upspeed > 0 then -- ladders/stairs
						ent.isup, ent.isdown = false, true
						ent.wasdown = false
						ent.body.currupspeed = ent.body.upspeed*random(8, 12)*0.1 -- magik XXX
					end
				end
				-- actor below player1, jump
				if ent.pos.y > self.player1.pos.y + 8 and ent.body.upspeed > 0 then
					local rnd = random(100)
					if rnd > 40 then -- 80, magik XXX
						ent.isup, ent.isdown = true, false
						ent.wasup = false
						ent.body.currinputbuffer = ent.body.inputbuffer
						ent.body.currupspeed = ent.body.upspeed*random(8, 12)*0.1 -- magik XXX
					end
				end
				-- pick a random available action
				local rndaction = ent.abilities[random(#ent.abilities)]
				-- movements
				if rndaction == 1 and ent.body.upspeed > 0 then -- jump
					local rnd = random(100)
					if rnd > 70 then -- 80, jump
						ent.isup, ent.isdown = true, false
						ent.wasup = false
						ent.body.currinputbuffer = ent.body.inputbuffer
						ent.body.currupspeed = ent.body.upspeed*random(8, 12)*0.1 -- magik XXX
					end
				end
				-- actions
				local rnd = random(100)
				if rndaction == 10 then -- shoot
					ent.isaction1 = false
					if rnd > 99 then -- rate
						ent.isaction1 = true
					end
				elseif rndaction == 20 then -- shield
					ent.isaction2 = false
					if rnd > 98 then -- rate
						ent.isaction2 = true
					end
				elseif rndaction == 30 then -- dash
					ent.isaction3 = false
					if rnd > 95 then -- rate
						ent.body.currspeed = ent.body.speed*0.5 -- magik XXX
						ent.isaction3 = true
					end
				end
			end
			-- extra attack on jumping peak
			if ent.body.vy > 0 and ent.body.vy < 30 and ent.body.upspeed > 0 then -- magik XXX
				if ent.curractiontimer < 0 then
					local rndaction = ent.abilities[random(#ent.abilities)]
					local rnd = random(100)
					if rnd > 70 then -- rate
						if rndaction == 10 then -- shoot
							ent.isaction1 = true
						elseif rndaction == 20 then -- shield
							ent.isaction2 = true
						end
					else -- dash/shield
						local rnd2 = random(100)
						if rnd2 > 30 then
							if rndaction == 30 then -- dash
								ent.isaction3 = true
							end
						else
							ent.body.currspeed = ent.body.speed*0.5 -- magik XXX
							if rndaction == 20 then -- shield
								ent.isaction2 = true
							end
						end
					end
					ent.curractiontimer = ent.actiontimer
				end
			end
		end
		Core.yield(1)
	end
	Core.asyncCall(fun) -- profiler seems to be faster without asyncCall (because of pairs traversing?)
end
