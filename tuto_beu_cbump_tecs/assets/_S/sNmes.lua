SNmes = Core.class()

local random = math.random

function SNmes:init(xtiny, xbump) -- tiny function
	self.tiny = xtiny -- class ref so we can remove entities from tiny world
	self.tiny.processingSystem(self) -- called once on init and every update
	self.bworld = xbump
	-- sfx
	self.snd = Sound.new("audio/sfx/sfx_deathscream_human14.wav")
	self.channel = self.snd:play(0, false, true)
end

function SNmes:filter(ent) -- tiny function
	return ent.isnme
end

function SNmes:onAdd(ent) -- tiny function
	ent.flip = math.random(100)
	if ent.flip > 50 then ent.flip = 1 else ent.flip = -1 end
	ent.currlives = ent.totallives
	ent.currhealth = ent.totalhealth
	ent.washurt = 0
	ent.wasbadlyhurt = 0
	ent.isdead = false
	ent.curractiontimer = ent.actiontimer
	ent.positionystart = 0
	-- abilities
	ent.abilities = {}
	if ent.headhitboxattack1 then ent.abilities[#ent.abilities+1] = 1 end -- punch1
	if ent.headhitboxattack2 then ent.abilities[#ent.abilities+1] = 2 end -- punch2
	if ent.spinehitboxattack1 then ent.abilities[#ent.abilities+1] = 3 end -- kick1
	if ent.spinehitboxattack2 then ent.abilities[#ent.abilities+1] = 4 end -- kick2
	if ent.headhitboxjattack1 then ent.abilities[#ent.abilities+1] = 5 end -- jumppunch1
	if ent.spinehitboxjattack1 then ent.abilities[#ent.abilities+1] = 6 end -- jumpkick1
--	for k, v in pairs(ent.abilities) do print(k, v) end
end

function SNmes:onRemove(ent) -- tiny function
	self.bworld:remove(ent) -- remove collision box from cbump world here!
end

local resetanim = true
function SNmes:process(ent, dt) -- tiny function
	-- hurt fx
	if ent.washurt and ent.washurt > 0 and not (ent.wasbadlyhurt and ent.wasbadlyhurt > 0) and not ent.isdead then
		ent.washurt -= 1
		ent.animation.curranim = g_ANIM_HURT_R
		if ent.washurt < ent.recovertimer*0.5 then ent.hitfx:setVisible(false) end
		if ent.washurt <= 0 then ent.sprite:setColorTransform(1, 1, 1, 1) end
	elseif ent.wasbadlyhurt and ent.wasbadlyhurt > 0 and not ent.isdead then
		ent.wasbadlyhurt -= 1
		ent.animation.curranim = g_ANIM_LOSE1_R
		if ent.wasbadlyhurt < ent.recoverbadtimer*0.5 then
			ent.hitfx:setVisible(false)
			if resetanim then
				resetanim = false
				ent.animation.frame = 0
			end
			ent.animation.curranim = g_ANIM_STANDUP_R
		end
		if ent.wasbadlyhurt <= 0 then
			ent.sprite:setColorTransform(1, 1, 1, 1)
			resetanim = true
		end
	end
	if ent.isdirty then -- hit
		self.channel = self.snd:play()
		if self.channel then self.channel:setVolume(g_sfxvolume*0.01) end
		ent.hitfx:setVisible(true)
		ent.hitfx:setPosition(ent.pos.x+ent.collbox.w/2+(ent.headhurtbox.x*ent.flip), ent.pos.y+ent.headhurtbox.y-ent.headhurtbox.h/2)
		ent.spritelayer:addChild(ent.hitfx)
		ent.currhealth -= ent.damage
		ent.washurt = ent.recovertimer -- timer for a flash effect
--		ent.sprite:setColorTransform(0, 0, 2, 3) -- the flash effect (a bright red color)
		ent.isdirty = false
		if ent.currhealth <= 0 then
			ent.wasbadlyhurt = ent.recoverbadtimer -- timer for actor to stand back up
			ent.currlives -= 1
			if ent.currlives > 0 then ent.currhealth = ent.totalhealth end
		end
	end
	if ent.currlives <= 0 then -- deaded
		-- stop all movements
		ent.isleft = false
		ent.isright = false
		ent.isup = false
		ent.isdown = false
		-- play dead sequence
		ent.isdirty = false
		ent.washurt = ent.recovertimer
		ent.wasbadlyhurt = ent.recoverbadtimer
		-- blood
		if not ent.isdead then
			ent.hitfx:setVisible(true)
			ent.hitfx:setColorTransform(3, 0, 0, random(1, 3)/10) -- blood stain
			ent.hitfx:setPosition(ent.pos.x+ent.collbox.w/2, ent.pos.y)
			ent.hitfx:setRotation(random(360))
			ent.hitfx:setScale(random(5, 8)/10)
			ent.bgfxlayer:addChild(ent.hitfx)
			ent.isdead = true
		end
		ent.animation.curranim = g_ANIM_LOSE1_R
		resetanim = false -- ??? XXX
		ent.sprite:setColorTransform((-ent.pos.y<>ent.pos.y)/255, (-ent.pos.y<>ent.pos.y)/255, 0, 1)
		ent.shadow.sprite:setVisible(false)
		ent.pos -= vector(8*ent.flip, 8)
		ent.sprite:setPosition(ent.pos)
		ent.sprite:setScale(ent.sprite:getScale()+0.07)
		if ent.pos.y < -256 then
			self.tiny.tworld:removeEntity(ent) -- sprite is removed in SDrawable
			self.tiny.numberofnmes -= 1
		end
	end
end
