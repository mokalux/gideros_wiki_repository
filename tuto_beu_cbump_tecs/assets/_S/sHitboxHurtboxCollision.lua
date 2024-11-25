SHitboxHurtboxCollision = Core.class()

function SHitboxHurtboxCollision:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
	self.spriteslist = xtiny.spriteslist
end

function SHitboxHurtboxCollision:filter(ent) -- tiny function
	return ent.headhitbox or ent.spinehitbox or ent.headhurtbox or ent.spinehurtbox
end

function SHitboxHurtboxCollision:onAdd(ent) -- tiny function
end

function SHitboxHurtboxCollision:onRemove(ent) -- tiny function
end

function SHitboxHurtboxCollision:process(ent, dt) -- tiny function
	local function checkY(actor1y, actor2y, prange)
		return (-(actor1y-actor2y)<>(actor1y-actor2y)) < prange
	end
	local function checkCollision(box1x, box1y, box1w, box1h, box2x, box2y, box2w, box2h)
		return not (box1x - box1w/2 > box2x + box2w/2 or -- is box1 on the right side of box2?
		   box1y - box1h/2 > box2y + box2h/2 or -- is box1 under box2?
		   box1x + box1w/2 < box2x - box2w/2 or -- is box1 on the left side of box2?
		   box1y + box1h/2 < box2y - box2h/2) -- is box1 above box2?
	end
	if ent.headhitbox and ent.headhitbox.isactive then -- HEAD
		for k, _ in pairs(self.spriteslist) do -- k = entity, v = true
			-- filter out unwanted collisions (player1 vs player1, nme vs nme, ... (you choose!)
			if (ent.isplayer1 and k.isplayer1) or
				ent.isdestructibleobject or -- destructible objects only receive damage
				(ent.iscollectible or k.iscollectible) or -- don't check for collectibles
				(ent.isnme and k.isnme) or
				(ent.isnme and k.isdestructibleobject) then -- nmes don't destroy objects, you choose
				-- nothing here!
			-- check head collisions according to actors action and use actor y or actor positionystart
			-- this prevents collisions between wrong hitbox and hurtbox (actors too far away on y axis)
			elseif (ent.isactionjumppunch1 or ent.isactionjump1) and (k.isactionjumppunch1 or k.isactionjumpkick1 or k.isactionjump1) then
				if checkY(ent.positionystart, k.positionystart, ent.collbox.h+k.collbox.h) and checkCollision(
					ent.pos.x+ent.collbox.w/2+(ent.headhitbox.x*ent.flip), ent.pos.y+ent.headhitbox.y,
					ent.headhitbox.w, ent.headhitbox.h,
					k.pos.x+k.collbox.w/2+(k.headhurtbox.x*k.flip), k.pos.y+k.headhurtbox.y,
					k.headhurtbox.w, k.headhurtbox.h) and
					k.washurt <= 0 and k.wasbadlyhurt <= 0 then -- <= here!
						k.isdirty = true
						k.damage = ent.headhitbox.damage
						if k.animation then k.animation.frame = 0 end
						ent.headhitbox.isactive = false
				else
					k.isdirty = false
					ent.headhitbox.isactive = false
				end
			elseif (ent.isactionjumppunch1 or ent.isactionjump1) and not (k.isactionjumppunch1 or k.isactionjumpkick1 or k.isactionjump1) then
				if checkY(ent.positionystart, k.pos.y, ent.collbox.h + k.collbox.h) and checkCollision(
					ent.pos.x+ent.collbox.w/2+(ent.headhitbox.x*ent.flip), ent.pos.y+ent.headhitbox.y,
					ent.headhitbox.w, ent.headhitbox.h,
					k.pos.x+k.collbox.w/2+(k.headhurtbox.x*k.flip), k.pos.y+k.headhurtbox.y,
					k.headhurtbox.w, k.headhurtbox.h) and
					k.washurt <= 0 and k.wasbadlyhurt <= 0 then -- <= here!
						k.isdirty = true
						k.damage = ent.headhitbox.damage
						if k.animation then k.animation.frame = 0 end
						ent.headhitbox.isactive = false
				else
					k.isdirty = false
					ent.headhitbox.isactive = false
				end
			elseif not (ent.isactionjumppunch1 or ent.isactionjump1) and (k.isactionjumppunch1 or k.isactionjumpkick1 or k.isactionjump1) then
				if checkY(ent.pos.y, k.positionystart, ent.collbox.h + k.collbox.h) and checkCollision(
					ent.pos.x+ent.collbox.w/2+(ent.headhitbox.x*ent.flip), ent.pos.y+ent.headhitbox.y,
					ent.headhitbox.w, ent.headhitbox.h,
					k.pos.x+k.collbox.w/2+(k.headhurtbox.x*k.flip), k.pos.y+k.headhurtbox.y,
					k.headhurtbox.w, k.headhurtbox.h) and
					k.washurt <= 0 and k.wasbadlyhurt <= 0 then -- <= here!
						k.isdirty = true
						k.damage = ent.headhitbox.damage
						if k.animation then k.animation.frame = 0 end
						ent.headhitbox.isactive = false
				else
					k.isdirty = false
					ent.headhitbox.isactive = false
				end
			else
				if checkY(ent.pos.y, k.pos.y, ent.collbox.h+k.collbox.h) and checkCollision(
				ent.pos.x+ent.collbox.w/2+(ent.headhitbox.x*ent.flip), ent.pos.y+ent.headhitbox.y,
				ent.headhitbox.w, ent.headhitbox.h,
				k.pos.x+k.collbox.w/2+(k.headhurtbox.x*k.flip), k.pos.y+k.headhurtbox.y,
				k.headhurtbox.w, k.headhurtbox.h) and
				k.washurt <= 0 and k.wasbadlyhurt <= 0 then -- <= here!
					k.isdirty = true
					k.damage = ent.headhitbox.damage
					if k.animation then k.animation.frame = 0 end
					ent.headhitbox.isactive = false
				else
					k.isdirty = false
					ent.headhitbox.isactive = false
				end
			end
		end
	elseif ent.spinehitbox and ent.spinehitbox.isactive then -- SPINE
		for k, _ in pairs(self.spriteslist) do
			-- filter out unwanted collisions (player1 vs player1, nme vs nme, ... (you choose!)
			if (ent.isplayer1 and k.isplayer1) or
				ent.isdestructibleobject or -- destructible objects only receive damage
				(ent.iscollectible or k.iscollectible) or -- don't check for collectibles
				(ent.isnme and k.isnme) or
				(ent.isnme and k.isdestructibleobject) then -- nmes don't destroy objects, you choose
				-- nothing here!
			-- check spine collisions according to actors action and use actor y or actor positionystart
			-- this prevents collisions between wrong hitbox and hurtbox (actors too far away on y axis)
			elseif (ent.isactionjumpkick1 or ent.isactionjump1) and (k.isactionjumppunch1 or k.isactionjumpkick1 or k.isactionjump1) then
				if checkY(ent.positionystart, k.positionystart, ent.collbox.h + k.collbox.h) and checkCollision(
					ent.pos.x+ent.collbox.w/2+(ent.spinehitbox.x*ent.flip), ent.pos.y+ent.spinehitbox.y,
					ent.spinehitbox.w, ent.spinehitbox.h,
					k.pos.x+k.collbox.w/2+(k.spinehurtbox.x*k.flip), k.pos.y+k.spinehurtbox.y,
					k.spinehurtbox.w, k.spinehurtbox.h) and
					k.washurt <= 0 and k.wasbadlyhurt <= 0 then -- <= here!
						k.isdirty = true
						k.damage = ent.spinehitbox.damage
						if k.animation then k.animation.frame = 0 end
						ent.spinehitbox.isactive = false
				else
					k.isdirty = false
					ent.spinehitbox.isactive = false
				end
			elseif (ent.isactionjumpkick1 or ent.isactionjump1) and not (k.isactionjumppunch1 or k.isactionjumpkick1 or k.isactionjump1) then
				if checkY(ent.positionystart, k.pos.y, ent.collbox.h + k.collbox.h) and checkCollision(
					ent.pos.x+ent.collbox.w/2+(ent.spinehitbox.x*ent.flip), ent.pos.y+ent.spinehitbox.y,
					ent.spinehitbox.w, ent.spinehitbox.h,
					k.pos.x+k.collbox.w/2+(k.spinehurtbox.x*k.flip), k.pos.y+k.spinehurtbox.y,
					k.spinehurtbox.w, k.spinehurtbox.h) and
					k.washurt <= 0 and k.wasbadlyhurt <= 0 then -- <= here!
						k.isdirty = true
						k.damage = ent.spinehitbox.damage
						if k.animation then k.animation.frame = 0 end
						ent.spinehitbox.isactive = false
				else
					k.isdirty = false
					ent.spinehitbox.isactive = false
				end
			elseif not (ent.isactionjumpkick1 or ent.isactionjump1) and (k.isactionjumppunch1 or k.isactionjumpkick1 or k.isactionjump1) then
				if checkY(ent.pos.y, k.positionystart, ent.collbox.h + k.collbox.h) and checkCollision(
					ent.pos.x+ent.collbox.w/2+(ent.spinehitbox.x*ent.flip), ent.pos.y+ent.spinehitbox.y,
					ent.spinehitbox.w, ent.spinehitbox.h,
					k.pos.x+k.collbox.w/2+(k.spinehurtbox.x*k.flip), k.pos.y+k.spinehurtbox.y,
					k.spinehurtbox.w, k.spinehurtbox.h) and
					k.washurt <= 0 and k.wasbadlyhurt <= 0 then -- <= here!
						k.isdirty = true
						k.damage = ent.spinehitbox.damage
						if k.animation then k.animation.frame = 0 end
						ent.spinehitbox.isactive = false
				else
					k.isdirty = false
					ent.spinehitbox.isactive = false
				end
			else
				if checkY(ent.pos.y, k.pos.y, ent.collbox.h + k.collbox.h) and checkCollision(
					ent.pos.x+ent.collbox.w/2+(ent.spinehitbox.x*ent.flip), ent.pos.y+ent.spinehitbox.y,
					ent.spinehitbox.w, ent.spinehitbox.h,
					k.pos.x+k.collbox.w/2+(k.spinehurtbox.x*k.flip), k.pos.y+k.spinehurtbox.y,
					k.spinehurtbox.w, k.spinehurtbox.h) and
					k.washurt <= 0 and k.wasbadlyhurt <= 0 then -- <= here!
						k.isdirty = true
						k.damage = ent.spinehitbox.damage
						if k.animation then k.animation.frame = 0 end
						ent.spinehitbox.isactive = false
				else
					k.isdirty = false
					ent.spinehitbox.isactive = false
				end
			end
		end
	end
end
