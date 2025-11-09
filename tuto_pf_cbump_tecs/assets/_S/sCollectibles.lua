SCollectibles = Core.class()

function SCollectibles:init(xtiny, xbump, xplayer1) -- tiny function
	self.tiny = xtiny -- make a class ref
	self.tiny.processingSystem(self) -- called once on init and every update
	self.bworld = xbump
	self.player1 = xplayer1
	-- sfx
	self.snd = { sound=Sound.new("audio/sfx/sfx_coin_double1.wav"), time=0, delay=0.2, }
end

function SCollectibles:filter(ent) -- tiny function
	return ent.iscollectible
end

function SCollectibles:onAdd(ent) -- tiny function
end

function SCollectibles:onRemove(ent) -- tiny function
	self.bworld:remove(ent) -- remove collision box from cbump world here!
end

function SCollectibles:process(ent, dt) -- tiny function
	if ent.isdirty then -- hit
		local function map(v, minSrc, maxSrc, minDst, maxDst, clampValue)
			local newV = (v - minSrc) / (maxSrc - minSrc) * (maxDst - minDst) + minDst
			return not clampValue and newV or clamp(newV, minDst >< maxDst, minDst <> maxDst)
		end
		local snd = self.snd -- sfx
		local curr = os.timer()
		local prev = snd.time
		if curr - prev > snd.delay then
			local channel = snd.sound:play()
			if channel then channel:setVolume(g_sfxvolume*0.01) end
			snd.time = curr
		end
		if ent.eid == "coins" then -- coins
			self.tiny.numberofcoins += 1
			self.tiny.hudcoins:setText("COINS: "..self.tiny.numberofcoins)
		elseif ent.eid == "lives" then -- hearts
			self.player1.currhealth += 1
			-- hud
			local hudhealthwidth = map(self.player1.currhealth, 0, self.player1.totalhealth, 0, 100)
			self.tiny.hudhealth:setWidth(hudhealthwidth)
			if self.player1.currhealth < self.player1.totalhealth/3 then self.tiny.hudhealth:setColor(0xff0000)
			elseif self.player1.currhealth < self.player1.totalhealth/2 then self.tiny.hudhealth:setColor(0xff5500)
			else self.tiny.hudhealth:setColor(0x00ff00)
			end
		elseif ent.eid == "dash" then -- ???
			self.player1.body.candash = true
		end
		self.tiny.tworld:removeEntity(ent) -- sprite is removed in SDrawable
	end
end
