SNmes = Core.class()

local random, atan2, cos, sin = math.random, math.atan2, math.cos, math.sin

function SNmes:init(xtiny, xbump, xplayer1) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
	self.tiny = xtiny -- class ref so we can remove entities from tiny world
	self.bworld = xbump
	self.player1 = xplayer1
	-- sfx
	self.snd = Sound.new("audio/sfx/sfx_deathscream_human14.wav")
	self.channel = self.snd:play(0, false, true) -- startTime, looping, paused
end

function SNmes:filter(ent) -- tiny function
	return ent.isnme
end

function SNmes:onAdd(ent) -- tiny function
--	print("SNmes:onAdd")
	ent.flip = random(100)
	if ent.flip > 50 then ent.flip = 1 else ent.flip = -1 end
	ent.currlives = ent.totallives
	ent.currhealth = ent.totalhealth
	ent.washurt = 0
	ent.wasbadlyhurt = 0
	ent.curractiontimer = ent.actiontimer
end

function SNmes:onRemove(ent) -- tiny function
--	print("SNmes:onRemove")
	local function fun()
		ent.shield.sprite:setVisible(false)
		ent.shield.sprite = nil
		if ent.collectible then
			if ent.collectible:find("door") then -- append "key" to eid
				ent.collectible = "key"..tostring(ent.collectible)
			end
			--ECollectibles:init(xid, xspritelayer, xpos, xspeed, xdx, xdy)
			local el = ECollectibles.new(
				ent.collectible, ent.spritelayer,
				ent.pos+vector(ent.collbox.w/4, 0*ent.collbox.h),
				0.8*8, 6*8, 8*8
			)
			self.tiny.tworld:addEntity(el)
			self.bworld:add(el, el.pos.x, el.pos.y, el.collbox.w, el.collbox.h)
		end
		Core.yield(1)
	end
	Core.asyncCall(fun)
	self.bworld:remove(ent) -- remove collision box from cbump world here!
end

function SNmes:process(ent, dt) -- tiny function
	if ent.isaction1 then -- shoot
		ent.isaction1 = false
		local projectilespeed = 28*8
		local xangle = atan2(self.player1.pos.y-ent.pos.y, self.player1.pos.x-ent.pos.x)
		local offset = vector(ent.collbox.w*0.5, ent.collbox.h*0.4)
		if ent.eid == 100 then -- shoot straight
			if ent.flip == 1 then xangle = ^<0 -- shoot right
			else xangle = ^<180 -- shoot left
			end
			projectilespeed = 26*8
		end
		local vx, vy = projectilespeed*cos(xangle), projectilespeed*sin(xangle)
		--EProjectiles:init(xid, xmass, xangle, xspritelayer, xpos, xvx, xvy, dx, dy, xpersist)
		local p = EProjectiles.new(
			100, 0.1, xangle, ent.spritelayer, ent.pos+offset, vx, vy, 32*8, 32*8
		)
		p.body.vx = vx
		p.body.vy = vy
		self.tiny.tworld:addEntity(p)
		self.bworld:add(p, p.pos.x, p.pos.y, p.collbox.w, p.collbox.h)
	end
	if ent.isaction2 then -- shield
		ent.isaction2 = false
		if ent.shield then
			ent.shield.currtimer = ent.shield.timer
			ent.shield.sprite:setVisible(true)
		end
	end
	if ent.isaction3 then -- dash
		ent.isaction3 = false
		ent.body.currdashtimer = ent.body.dashtimer
		ent.body.currdashcooldown = ent.body.dashcooldown
	end
	-- shield collision
	if ent.shield and ent.currlives > 0 then
		local function collisionfilter2(item) -- only one param: "item", return true, false or nil
			if item.isplayer1 or (item.isprojectile and item.eid == 1) then
				return true
			end
		end
		local shiledsprite = ent.shield.sprite -- faster
		shiledsprite:setScale(shiledsprite.sx*ent.flip, shiledsprite.sy)
		shiledsprite:setPosition(
			ent.pos +
			vector(ent.collbox.w/2, 0) +
			ent.shield.offset*vector(shiledsprite.sx*ent.flip, shiledsprite.sy)
		)
		local pw, ph = shiledsprite:getWidth(), shiledsprite:getHeight()
		--local items, len = world:queryRect(l,t,w,h, filter)
		local items, len2 = self.bworld:queryRect(
			ent.pos.x+ent.shield.offset.x*ent.flip-pw*0.5+ent.collbox.w*0.5,
			ent.pos.y+ent.shield.offset.y-ph*0.5,
			pw, ph,
			collisionfilter2)
		for i = 1, len2 do
			local item = items[i]
			if shiledsprite:isVisible() then
				item.damage = ent.shield.damage
				item.isdirty = true
			end
		end
	end
	if ent.shield and ent.shield.currtimer > 0 then
		ent.shield.currtimer -= 1
		if ent.shield.currtimer <= 0 then
			ent.shield.sprite:setVisible(false)
		end
	end
	-- hurt
	if ent.washurt > 0 and ent.wasbadlyhurt <= 0 and ent.currlives > 0 then -- lose 1 nrg
		ent.washurt -= 1
		ent.isdirty = false
		if ent.washurt <= 0 then
			ent.sprite:setColorTransform(1, 1, 1, 1) -- reset color transform
		elseif ent.washurt < ent.recovertimer*0.5 then
			ent.hitfx:setVisible(false)
		end
	elseif ent.wasbadlyhurt > 0 and ent.currlives > 0 then -- lose 1 life
		ent.wasbadlyhurt -= 1
		ent.isdirty = false
		if ent.wasbadlyhurt <= 0 then
			ent.sprite:setColorTransform(1, 1, 1, 1) -- reset color transform
		elseif ent.wasbadlyhurt < ent.recoverbadtimer*0.5 then
			ent.hitfx:setVisible(false)
			ent.animation.curranim = g_ANIM_STANDUP_R
			ent.animation.frame = 0 -- start animation at frame 0
		end
	end
	if ent.body.currdashtimer > 0 then -- invicible while dashing
		ent.isdirty = false
	end
	-- hit
	if ent.isdirty then
		ent.sprite:setColorTransform(0, 1, 0, 2)
		ent.hitfx:setVisible(true)
		ent.hitfx:setPosition(ent.pos.x+ent.collbox.w*0.5, ent.pos.y)
		ent.spritelayer:addChild(ent.hitfx)
		ent.currhealth -= ent.damage
		ent.washurt = ent.recovertimer -- timer for a flash effect
		ent.animation.curranim = g_ANIM_HURT_R
		ent.animation.frame = 0 -- start animation at frame 0
		ent.isdirty = false
		if ent.currhealth <= 0 then
			ent.sprite:setColorTransform(0, 1, 1, 2)
			ent.currlives -= 1
			if ent.currlives > 0 then
				ent.currhealth = ent.totalhealth
			end
			ent.wasbadlyhurt = ent.recoverbadtimer -- timer for actor to stand back up
			ent.animation.curranim = g_ANIM_LOSE1_R
		end
	end
	-- deaded
	if ent.currlives <= 0 then
		if self.channel and not self.channel:isPlaying() then -- sfx
			self.channel = self.snd:play()
			if self.channel then
				self.channel:setVolume(g_sfxvolume*0.01)
			else
				print("SNmes lost channel!", self.channel)
				self.channel = self.snd:play(0, false, true)
			end
		end
		-- stop all movements
		ent.isleft = false
		ent.isright = false
		ent.isup = false
		ent.isdown = false
		-- play dead sequence
		ent.isdirty = false
		ent.washurt = 0 -- ent.recovertimer
		ent.wasbadlyhurt = 0 -- ent.recoverbadtimer
		if ent.readytoremove then
			-- blood
			ent.hitfx:setVisible(true)
			ent.hitfx:setColorTransform(3, 0, 0, random(1, 3)*0.1) -- red color modulate
			ent.hitfx:setPosition(ent.pos.x+ent.collbox.w*0.5, ent.pos.y+ent.h*0.5)
			ent.hitfx:setRotation(random(360))
			ent.hitfx:setScale(random(5, 8)*0.1)
			ent.bgfxlayer:addChild(ent.hitfx)
			ent.animation.curranim = g_ANIM_LOSE1_R
			ent.sprite:setColorTransform(0.5, 0.5, 0.5, 0.5)
			self.tiny.tworld:removeEntity(ent) -- sprite is removed in SDrawable
		end
	end
end
