SCollectible = Core.class()

local random = math.random

function SCollectible:init(xtiny, xbump, xplayer1) -- tiny function
	self.tiny = xtiny -- make a class ref
	self.tiny.processingSystem(self) -- called once on init and every update
	self.bworld = xbump
	self.player1 = xplayer1
	-- sfx
	self.snd = Sound.new("audio/sfx/sfx_coin_double1.wav")
	self.channel = self.snd:play(0, false, true)
end

function SCollectible:filter(ent) -- tiny function
	return ent.iscollectible
end

function SCollectible:onAdd(ent) -- tiny function
end

function SCollectible:onRemove(ent) -- tiny function
	self.bworld:remove(ent) -- remove collision box from cbump world here!
end

function SCollectible:process(ent, dt) -- tiny function
	if ent.isdirty then -- hit
		local function map(v, minSrc, maxSrc, minDst, maxDst, clampValue)
			local newV = (v - minSrc) / (maxSrc - minSrc) * (maxDst - minDst) + minDst
			return not clampValue and newV or clamp(newV, minDst >< maxDst, minDst <> maxDst)
		end
		self.channel = self.snd:play()
		if self.channel then self.channel:setVolume(g_sfxvolume*0.01) end
--		ent.hitfx:setVisible(true)
--		ent.hitfx:setPosition(ent.pos.x+ent.headhurtbox.x, ent.y+ent.headhurtbox.y)
--		ent.spritelayer:addChild(ent.hitfx)
--		ent.currhealth -= ent.damage
--		ent.washurt = ent.recovertimer -- timer for a flash effect
		if random(100) > 50 then
			if self.player1.currjumps < 0 then self.player1.currjumps = 0 end
			self.player1.currjumps += 3
			self.tiny.hudcurrjumps:setText("JUMPS: "..self.player1.currjumps)
		else
			self.player1.currhealth += 1
			-- hud
			local hudhealthwidth = map(self.player1.currhealth, 0, self.player1.totalhealth, 0, 100)
			self.tiny.hudhealth:setWidth(hudhealthwidth)
			if self.player1.currhealth < self.player1.totalhealth/3 then self.tiny.hudhealth:setColor(0xff0000)
			elseif self.player1.currhealth < self.player1.totalhealth/2 then self.tiny.hudhealth:setColor(0xff5500)
			else self.tiny.hudhealth:setColor(0x00ff00)
			end
		end
		ent.sprite:setColorTransform(0, 2, 0, 3) -- the flash effect (a bright color)
		ent.isdirty = false
--[[
		if ent.currhealth <= 0 then
			ent.hitfx:setColorTransform(3, 0, 0, random(1, 3)/10)
			ent.hitfx:setY(ent.hitfx:getY()+ent.h/1.1) -- magik XXX
			ent.hitfx:setRotation(random(360))
			ent.hitfx:setScale(random(5, 10)/10)
			ent.bgfxlayer:addChild(ent.hitfx)
			self.tiny.tworld:removeEntity(ent) -- sprite is removed in SDrawable
--			self.tiny.numberofnmes -= 1
		end
]]
		self.tiny.tworld:removeEntity(ent) -- sprite is removed in SDrawable
	end
end
