SProjectiles = Core.class()

function SProjectiles:init(xtiny, xbworld) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
	self.tiny = xtiny
	self.bworld = xbworld
end

function SProjectiles:filter(ent) -- tiny function
	return ent.isprojectile
end

function SProjectiles:onAdd(ent) -- tiny function
end

function SProjectiles:onRemove(ent) -- tiny function
	self.bworld:remove(ent) -- remove collision box from cbump world here!
end

local col -- cbump perfs?
function SProjectiles:process(ent, dt) -- tiny function
	-- hurt
	if ent.washurt > 0 and ent.wasbadlyhurt <= 0 and ent.currlives > 0 then -- lose 1 nrg
		ent.washurt -= 1
		ent.isdirty = false
		ent.animation.curranim = g_ANIM_HURT_R
		if ent.washurt <= 0 then
			ent.sprite:setColorTransform(1, 1, 1, 1) -- reset color transform
		elseif ent.washurt < ent.recovertimer*0.5 then
			ent.hitfx:setVisible(false)
		end
	elseif ent.wasbadlyhurt > 0 and ent.currlives > 0 then -- lose 1 life
		ent.wasbadlyhurt -= 1
		ent.isdirty = false
		ent.animation.curranim = g_ANIM_LOSE1_R
		if ent.wasbadlyhurt <= 0 then
			ent.sprite:setColorTransform(1, 1, 1, 1) -- reset color transform
		elseif ent.wasbadlyhurt < ent.recoverbadtimer*0.5 then
			ent.hitfx:setVisible(false)
			ent.animation.curranim = g_ANIM_STANDUP_R
			ent.animation.frame = 0 -- start animation at frame 0
		end
	end
	-- hit
	if ent.isdirty then
		ent.isdirty = false
		ent.currlives -= 1
	end
	-- deaded
	if ent.currlives <= 0 or
		ent.pos.x > (ent.dist.startpos.x+ent.dist.dx) or
		ent.pos.x < (ent.dist.startpos.x-ent.dist.dx) or
		ent.pos.y > (ent.dist.startpos.y+ent.dist.dy) or
		ent.pos.y < (ent.dist.startpos.y-ent.dist.dy) then
		-- stop all movements
		ent.isleft = false
		ent.isright = false
		ent.isup = false
		ent.isdown = false
		-- play dead sequence
		ent.isdirty = false
		self.tiny.tworld:removeEntity(ent) -- sprite is removed in SDrawable
	end
	-- already deaded
	if ent.currlives <= 0 or
		ent.pos.x > (ent.dist.startpos.x+ent.dist.dx) or
		ent.pos.x < (ent.dist.startpos.x-ent.dist.dx) or
		ent.pos.y > (ent.dist.startpos.y+ent.dist.dy) or
		ent.pos.y < (ent.dist.startpos.y-ent.dist.dy) then
		return
	end
	local function fun()
		--  _____ ____  _      _      _____  _____ _____ ____  _   _ 
		-- / ____/ __ \| |    | |    |_   _|/ ____|_   _/ __ \| \ | |
		--| |   | |  | | |    | |      | | | (___   | || |  | |  \| |
		--| |   | |  | | |    | |      | |  \___ \  | || |  | | . ` |
		--| |___| |__| | |____| |____ _| |_ ____) |_| || |__| | |\  |
		-- \_____\____/|______|______|_____|_____/|_____\____/|_| \_|
		-- ______ _____ _   _______ ______ _____  
		--|  ____|_   _| | |__   __|  ____|  __ \ 
		--| |__    | | | |    | |  | |__  | |__) |
		--|  __|   | | | |    | |  |  __| |  _  / 
		--| |     _| |_| |____| |  | |____| | \ \ 
		--|_|    |_____|______|_|  |______|_|  \_\
		local function collisionfilter(item, other) -- "touch", "cross", "slide", "bounce"
			return "cross"
		end
		--  _____ ____  _    _ __  __ _____  
		-- / ____|  _ \| |  | |  \/  |  __ \ 
		--| |    | |_) | |  | | \  / | |__) |
		--| |    |  _ <| |  | | |\/| |  ___/ 
		--| |____| |_) | |__| | |  | | |     
		-- \_____|____/ \____/|_|  |_|_|     
		local goalx = ent.pos.x + ent.body.vx * dt
		local goaly = ent.pos.y + ent.body.vy * dt
		local nextx, nexty, collisions, len = self.bworld:move(ent, goalx, goaly, collisionfilter)
		--  _____ ____  _      _      _____  _____ _____ ____  _   _  _____ 
		-- / ____/ __ \| |    | |    |_   _|/ ____|_   _/ __ \| \ | |/ ____|
		--| |   | |  | | |    | |      | | | (___   | || |  | |  \| | (___  
		--| |   | |  | | |    | |      | |  \___ \  | || |  | | . ` |\___ \ 
		--| |___| |__| | |____| |____ _| |_ ____) |_| || |__| | |\  |____) |
		-- \_____\____/|______|______|_____|_____/|_____\____/|_| \_|_____/ 
		-- we handle ALL collisions here!
		for i = 1, len do
			col = collisions[i]
			if col.other.isplayer1 and col.item.eid > 1 then -- nme bullet vs player1
				if col.other.body.currdashtimer <= 0 then
					col.other.damage = 1
					col.other.isdirty = true
					col.item.damage = 1
					col.item.isdirty = true
					-- don't destroy bullet if it is persistent
					if col.item.ispersistant then col.item.isdirty = false end
				end
			elseif col.other.isnme and col.item.eid == 1 then -- player1 bullet vs nmes
				if col.other.body.currdashtimer <= 0 then
					col.item.damage = 1
					col.other.damage = 1
					col.item.isdirty = true
					if col.item.ispersistant then col.item.isdirty = false end
					col.other.isdirty = true
				end
			elseif col.other.isdoor then -- bullets vs door
				col.item.damage = 1
				col.item.isdirty = true
--			elseif col.other.isfloor then -- bullets vs floor
--				col.item.damage = 1
--				col.item.isdirty = true
			end
		end
		--  _____  _    ___     _______ _____ _____  _____ 
		-- |  __ \| |  | \ \   / / ____|_   _/ ____|/ ____|
		-- | |__) | |__| |\ \_/ / (___   | || |    | (___  
		-- |  ___/|  __  | \   / \___ \  | || |     \___ \ 
		-- | |    | |  | |  | |  ____) |_| || |____ ____) |
		-- |_|    |_|  |_|  |_| |_____/|_____\_____|_____/ 
		-- gravity
--		ent.body.vy += 1*8 * ent.body.currmass -- 3*8, gravity, magik XXX
		-- move & flip
		ent.pos = vector(nextx, nexty)
		ent.sprite:setPosition(ent.pos + vector(ent.collbox.w/2, -ent.h/2+ent.collbox.h))
		if ent.animation then
			ent.animation.bmp:setScale(ent.sx*ent.flip, ent.sy)
		end
		Core.yield(1)
	end
	Core.asyncCall(fun)
end
