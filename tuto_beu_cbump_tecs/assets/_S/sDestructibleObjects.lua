SDestructibleObjects = Core.class()

local random, cos, sin = math.random, math.cos, math.sin
local insert = table.insert

function SDestructibleObjects:init(xtiny, xbworld) -- tiny function
	self.tiny = xtiny -- ref so we can remove entities from tiny system
	self.tiny.processingSystem(self) -- called once on init and every update
	self.bworld = xbworld
	-- sfx
	self.snd = Sound.new("audio/sfx/footstep/Forest02.wav")
	self.channel = self.snd:play(0, false, true)
end

function SDestructibleObjects:filter(ent) -- tiny function
	return ent.isdestructibleobject
end

function SDestructibleObjects:onAdd(ent) -- tiny function
end

function SDestructibleObjects:onRemove(ent) -- tiny function
	-- spawn a random collectible: ECollectible:init(xspritelayer, xpos)
	local function fun()
		local el = ECollectible.new(ent.spritelayer, ent.pos+vector(ent.collbox.w/4, -1*ent.collbox.h))
		self.tiny.tworld:addEntity(el)
		self.bworld:add(el, el.pos.x, el.pos.y, el.collbox.w, el.collbox.h)
		Core.yield(1)
	end
	Core.asyncCall(fun)
	self.bworld:remove(ent) -- remove collision box from cbump world here!
end

function SDestructibleObjects:process(ent, dt) -- tiny function
	local function EffectExplode(s, scale, pos, r, speed, texture)
		local p = Particles.new()
		p:setPosition(pos)
		p:setTexture(texture)
		p:setScale(scale)
		s:addChild(p)
		local parts = {}
		for i = 1, 6 do -- 8
			local a = random()*6.3
			local dx, dy = cos(a), sin(a)
			local sr = random()*r
			local px, py = dx*sr, dy*sr
			local ss = (random()+0.5) * (speed or 1)
			insert(parts,
				{
					x = px, y = py,
					speedX = dx * ss,
					speedY = dy * ss,
					speedAngular = random()*4 - 2,
					decayAlpha = random()*0.04 + 0.95,
					ttl = 32, -- 500
					size = random()*10 + 20,
				}
			)
		end
		p:addParticles(parts)
		Core.yield(1)
		p:removeFromParent()
	end
	-- hurt fx
	if ent.washurt and ent.washurt > 0 then
		ent.washurt -= 1
		if ent.washurt < ent.recovertimer/2 then
			if ent.hitfx then ent.hitfx:setVisible(false) end
		end
		if ent.washurt <= 0 then
			ent.sprite:setColorTransform(1, 1, 1, 1)
		end
	end
	if ent.isdirty then -- hit
		self.channel = self.snd:play()
		if self.channel then self.channel:setVolume(g_sfxvolume*0.01) end
		ent.hitfx:setVisible(true)
		ent.hitfx:setPosition(ent.pos + vector(ent.headhurtbox.x+4, ent.headhurtbox.y))
		ent.spritelayer:addChild(ent.hitfx)
		ent.currhealth -= ent.damage
		ent.washurt = ent.recovertimer -- timer for a flash effect
		ent.sprite:setColorTransform(1, 1, 1, 3) -- a flash effect
		ent.isdirty = false
		if ent.currhealth <= 0 then
			--EffectExplode(s, scale, pos, r, speed, texture)
			Core.asyncCall(EffectExplode, ent.spritelayer, 2,
				ent.pos+vector(ent.collbox.w/2, -ent.h/2), 4, 2,
				Texture.new("gfx/fx/fxBarrel_02_0011.png"))
			ent.spritelayer:removeChild(ent.hitfx)
			self.tiny.tworld:removeEntity(ent) -- sprite is removed in SDrawable
			self.tiny.numberofdestructibleobjects -= 1
		end
	end
end
