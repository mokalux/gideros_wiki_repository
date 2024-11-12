SDynamicBodies = Core.class()

local random = math.random

function SDynamicBodies:init(xtiny, xmapdef) -- tiny function
	self.tiny = xtiny -- to access self.tiny variables
	self.tiny.processingSystem(self) -- called once on init and every update
	self.mapdef = xmapdef
end

function SDynamicBodies:filter(ent) -- tiny function
	return ent.body -- only actors with body component
end

function SDynamicBodies:onAdd(ent) -- tiny function
end

function SDynamicBodies:onRemove(ent) -- tiny function
end

local randomdir = 0 -- for nmes
function SDynamicBodies:process(ent, dt) -- tiny function
	-- is dead or hurt?
	if (ent.washurt and ent.washurt > 0) or (ent.wasbadlyhurt and ent.wasbadlyhurt > 0) or ent.currlives <= 0 then
		ent.body.vx = 0
		ent.body.vy = 0
		return
		-- TO REVISIT
	end
	-- movements
	if ent.isleft and not ent.isright and ent.pos.x > self.mapdef.l then -- LEFT
		ent.animation.curranim = g_ANIM_WALK_R
		ent.body.vx = -ent.body.currspeed*dt
		ent.flip = -1
	elseif ent.isright and not ent.isleft and ent.pos.x < self.mapdef.r - ent.w*0.5 then -- RIGHT
		ent.animation.curranim = g_ANIM_WALK_R
		ent.body.vx = ent.body.currspeed*dt
		ent.flip = 1
	else -- IDLE
		ent.animation.curranim = g_ANIM_IDLE_R
		ent.body.vx = 0
	end
	if ent.isup and not ent.isdown and ent.body.isonfloor and ent.pos.y > self.mapdef.t then -- UP
		ent.animation.curranim = g_ANIM_WALK_R
		ent.body.vy = -ent.body.currspeed*0.015*dt -- 0.01, you choose
	elseif ent.isdown and not ent.isup and ent.body.isonfloor and ent.pos.y < self.mapdef.b then -- DOWN
		ent.animation.curranim = g_ANIM_WALK_R
		ent.body.vy = ent.body.currspeed*0.015*dt -- 0.01, you choose
	else
		if ent.body.isonfloor then
			ent.body.vy = 0
		end
	end
	-- actions
	if ent.body.isonfloor then -- GROUND
		if ent.isactionpunch1 then
			ent.animation.curranim = g_ANIM_PUNCH_ATTACK1_R
			ent.body.vx = 0 -- *= 0.1*dt, you choose
			ent.body.vy = 0 -- *= 0.1*dt, you choose
		elseif ent.isactionpunch2 then
			ent.animation.curranim = g_ANIM_PUNCH_ATTACK2_R
			ent.body.vx = 0 -- *= 0.1*dt, you choose
			ent.body.vy = 0 -- *= 0.1*dt, you choose
		elseif ent.isactionkick1 then
			ent.animation.curranim = g_ANIM_KICK_ATTACK1_R
			ent.body.vx = 0 -- *= 0.1*dt, you choose
			ent.body.vy = 0 -- *= 0.1*dt, you choose
		elseif ent.isactionkick2 then
			ent.animation.curranim = g_ANIM_KICK_ATTACK2_R
			ent.body.vx = 0 -- *= 0.1*dt, you choose
			ent.body.vy = 0 -- *= 0.1*dt, you choose
		end
	else -- AIR
		if ent.isactionpunch1 then
			if ent.isplayer1 and ent.currjumps > 0 then
				ent.isactionjumppunch1 = true
			end
		elseif ent.isactionkick1 then
			if ent.isplayer1 and ent.currjumps > 0 then
				ent.isactionjumpkick1 = true
			end
		end
		if ent.isactionjump1 and not (ent.isactionjumppunch1 or ent.isactionjumpkick1) then -- JUMP ONLY
			ent.animation.curranim = g_ANIM_JUMP1_R
			if ent.isplayer1 then ent.body.vx *= 2 end -- 3, acceleration, you choose
			ent.body.currjumpspeed = ent.body.jumpspeed*1.1 -- higher jump
			if ent.body.isgoingup then ent.body.vy -= ent.body.currjumpspeed end
			if ent.pos.y < ent.positionystart - ent.h*0.5 then -- higher apex, you choose
--				ent.body.vx = ent.body.currspeed*dt*4*ent.flip -- acceleration? you choose
				ent.body.vy += ent.body.currjumpspeed*1.2 -- falling
				ent.body.isgoingup = false
			end
			if not ent.body.isgoingup and ent.pos.y >= ent.positionystart then -- grounded
				ent.body.vy = 0
--				ent.pos.y = ent.positionystart
				ent.pos = vector(ent.pos.x, ent.positionystart)
				ent.body.isonfloor = true
				ent.isactionjump1 = false -- sometimes bug! XXX
			end
		end
		if ent.isactionjumppunch1 then -- JUMP PUNCH
			ent.animation.curranim = g_ANIM_PUNCHJUMP_ATTACK1_R
			if ent.isplayer1 then ent.body.vx *= 2 end -- acceleration, you choose
			ent.body.currjumpspeed = ent.body.jumpspeed
			if ent.body.isgoingup then ent.body.vy -= ent.body.currjumpspeed end
			if ent.pos.y < ent.positionystart - ent.h*0.45 then -- apex, you choose
--				ent.body.vx = ent.body.currspeed*dt*3*ent.flip -- acceleration? you choose
				ent.body.vy += ent.body.currjumpspeed*1.2 -- falling
				ent.body.isgoingup = false
			end
			if not ent.body.isgoingup and ent.pos.y >= ent.positionystart then -- grounded
				ent.body.vy = 0
--				ent.pos.y = ent.positionystart
				ent.pos = vector(ent.pos.x, ent.positionystart)
				if ent.isnme then
					randomdir = random(100)
					if randomdir < 50 then ent.isleft = false ent.isright = true
					else ent.isleft = true ent.isright = false
					end
				end
				if ent.isplayer1 then
					ent.currjumps -= 1
					if ent.currjumps < 0 then ent.currjumps = 0 end
					self.tiny.hudcurrjumps:setText("JUMPS: "..ent.currjumps)
				end
				ent.body.isonfloor = true
				ent.isactionjump1 = false
				ent.isactionpunch1 = false -- TEST
				ent.isactionjumppunch1 = false -- sometimes bug! XXX
			end
		elseif ent.isactionjumpkick1 then -- JUMP KICK
			ent.animation.curranim = g_ANIM_KICKJUMP_ATTACK1_R
			if ent.isplayer1 then ent.body.vx *= 2 end -- acceleration, you choose
			ent.body.currjumpspeed = ent.body.jumpspeed
			if ent.body.isgoingup then ent.body.vy -= ent.body.currjumpspeed end
			if ent.pos.y < ent.positionystart - ent.h*0.5 then -- apex, you choose
--				ent.body.vx = ent.body.currspeed*dt*3*ent.flip -- acceleration? you choose
				ent.body.vy += ent.body.currjumpspeed*1.25 -- falling
				ent.body.isgoingup = false
			end
			if not ent.body.isgoingup and ent.pos.y >= ent.positionystart then -- grounded
				ent.body.vy = 0
--				ent.pos.y = ent.positionystart
				ent.pos = vector(ent.pos.x, ent.positionystart)
				if ent.isnme then
					randomdir = random(100)
					if randomdir < 50 then ent.isleft = false ent.isright = true
					else ent.isleft = true ent.isright = false
					end
				end
				if ent.isplayer1 then
					ent.currjumps -= 1
					if ent.currjumps < 0 then ent.currjumps = 0 end
					self.tiny.hudcurrjumps:setText("JUMPS: "..ent.currjumps)
				end
				ent.body.isonfloor = true
				ent.isactionjump1 = false
				ent.isactionkick1 = false -- TEST
				ent.isactionjumpkick1 = false -- sometimes bug!
			end
		end
	end
	-- catches the sometimes bug!
	if not ent.body.isonfloor and ent.body.vy == 0 then
		print("bug", dt)
		ent.body.vy += ent.body.currjumpspeed*16 -- makes the actor touch the ground
	end
end
