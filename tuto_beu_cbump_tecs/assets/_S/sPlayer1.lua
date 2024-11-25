SPlayer1 = Core.class()

function SPlayer1:init(xtiny, xcamera) -- tiny function
	self.tiny = xtiny -- ref so we can remove entities from tiny system
	self.tiny.processingSystem(self) -- called once on init and every update
	-- fx
	self.camera = xcamera -- camera shake
	-- sfx
	self.snd = Sound.new("audio/sfx/sfx_deathscream_human14.wav")
	self.channel = self.snd:play(0, false, true)
end

function SPlayer1:filter(ent) -- tiny function
	return ent.isplayer1
end

function SPlayer1:onAdd(ent) -- tiny function
end

function SPlayer1:onRemove(ent) -- tiny function
end

local resetanim = true
function SPlayer1:process(ent, dt) -- tiny function
	-- hurt fx
	if ent.washurt and ent.washurt > 0 and not (ent.wasbadlyhurt and ent.wasbadlyhurt > 0) then
		ent.washurt -= 1
		ent.animation.curranim = g_ANIM_HURT_R
		if ent.washurt < ent.recovertimer*0.5 then ent.hitfx:setVisible(false) end
		if ent.washurt <= 0 then
			ent.sprite:setColorTransform(1, 1, 1, 1)
			self.camera:setZoom(1) -- zoom
		end
	elseif ent.wasbadlyhurt and ent.wasbadlyhurt > 0 then
		ent.hitfx:setVisible(false)
		ent.wasbadlyhurt -= 1
		ent.animation.curranim = g_ANIM_LOSE1_R
		if ent.wasbadlyhurt < ent.recoverbadtimer/2 then
			if resetanim then
				resetanim = false
				ent.animation.frame = 0
			end
			ent.animation.curranim = g_ANIM_STANDUP_R
		end
		if ent.wasbadlyhurt <= 0 then
			ent.sprite:setColorTransform(1, 1, 1, 1)
			self.camera:setZoom(1) -- zoom
			resetanim = true
		end
	end
	if ent.isdirty then -- hit
		local function map(v, minSrc, maxSrc, minDst, maxDst, clampValue)
			local newV = (v - minSrc) / (maxSrc - minSrc) * (maxDst - minDst) + minDst
			return not clampValue and newV or clamp(newV, minDst><maxDst, minDst<>maxDst)
		end
		self.channel = self.snd:play()
		if self.channel then self.channel:setVolume(g_sfxvolume*0.01) end
		ent.hitfx:setVisible(true)
		ent.hitfx:setPosition(ent.pos.x+ent.collbox.w/2+(ent.headhurtbox.x*ent.flip), ent.pos.y+ent.headhurtbox.y-ent.headhurtbox.h/2)
		ent.spritelayer:addChild(ent.hitfx)
		ent.currhealth -= ent.damage
		local hudhealthwidth = map(ent.currhealth, 0, ent.totalhealth, 0, 100)
		self.tiny.hudhealth:setWidth(hudhealthwidth)
		if ent.currhealth < ent.totalhealth/3 then self.tiny.hudhealth:setColor(0xff0000)
		elseif ent.currhealth < ent.totalhealth/2 then self.tiny.hudhealth:setColor(0xff5500)
		else self.tiny.hudhealth:setColor(0x00ff00)
		end
		ent.washurt = ent.recovertimer -- timer for a flash effect
		ent.sprite:setColorTransform(2, 0, 0, 2) -- the flash effect (a bright red color)
		ent.isdirty = false
		self.camera:shake(0.6, 16) -- (duration, distance), you choose
		self.camera:setZoom(1.2) -- zoom
		if ent.currhealth <= 0 then
			ent.wasbadlyhurt = ent.recoverbadtimer -- timer for player1 to stand back up
			self.camera:shake(0.8, 64) -- (duration, distance), you choose
			ent.currlives -= 1
			for i = 1, ent.totallives do self.tiny.hudlives[i]:setVisible(false) end -- dirty but easy XXX
			for i = 1, ent.currlives do self.tiny.hudlives[i]:setVisible(true) end -- dirty but easy XXX
			if ent.currlives > 0 then
				ent.currhealth = ent.totalhealth
				hudhealthwidth = map(ent.currhealth, 0, ent.totalhealth, 0, 100)
				self.tiny.hudhealth:setWidth(hudhealthwidth)
				self.tiny.hudhealth:setColor(0x00ff00)
				if ent.currlives == 1 then self.tiny.hudlives[1]:setColor(0xff0000) end
			end
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
		resetanim = false
		ent.washurt = ent.recovertimer
		ent.wasbadlyhurt = ent.recoverbadtimer
		ent.animation.curranim = g_ANIM_LOSE1_R
		ent.sprite:setColorTransform(255*0.5/255, 255*0.5/255, 255*0.5/255, 1)
		self.camera:setZoom(1) -- zoom
		ent.animation.bmp:setY(ent.animation.bmp:getY()-1)
		if ent.animation.bmp:getY() < -200 then -- you choose
			switchToScene(LevelX.new())
		end
	end
end
