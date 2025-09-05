EGroundNmes = Core.class()

function EGroundNmes:init(xid, xspritelayer, xpos, xbgfxlayer, xcollectible)
	-- ids
	self.isnme = true
	self.eid = xid
	self.ispersistent = false -- keep sprite visible when dead
	-- sprite layers
	self.spritelayer = xspritelayer
	self.bgfxlayer = xbgfxlayer
	-- actor holds a collectible?
	if xcollectible then
		self.collectible = xcollectible
	end
	-- params
	self.pos = xpos
	self.sx = 1 -- 0.96
	self.sy = self.sx
	self.totallives = 1 -- basic nme
	self.totalhealth = 3 -- basic nme
	-- 100: no move, no jump, shoot straight, you choose the nme abilities!
	-- 200: move, jump, no shoot, you choose the nme abilities!
	-- 300: no move, no jump, shoot all angles, shield, you choose the nme abilities!
	if self.eid == 200 then
		self.ispersistent = true -- keep sprite visible on dead
		self.totallives = 2
		self.totalhealth = 3
	end
	-- recovery
	self.recovertimer = 10
	self.recoverbadtimer = 30
	self.actiontimer = 90 -- 60, math.random(32, 96), low value=hard, high value=easy
	if g_difficulty == 0 then -- easy
		self.totallives = 1
		self.totalhealth = 3
		self.recovertimer *= 0.5
		self.recoverbadtimer *= 0.5
		self.actiontimer *= 2
	elseif g_difficulty == 2 then -- hard
		self.recovertimer *= 2
		self.recoverbadtimer *= 2
		self.actiontimer *= 0.5
	end
	self.hitfx = Bitmap.new(Texture.new("gfx/fxs/1.png"))
	self.hitfx:setAnchorPoint(0.5, 0.5)
	-- COMPONENTS
	-- ANIMATION
	local anims = {} -- table to hold actor animations
	local animsimgs = {} -- table to hold actor animations images
	-- CAnimation:init(xanimspeed)
	local framerate = 1/10 -- 1/12
	self.animation = CAnimation.new(framerate)
	-- CAnimation:cutSpritesheet(xspritesheetpath, xcols, xrows, xanimsimgs, xoffx, xoffy, sx, sy)
	local texpath
	local cols, rows
	if self.eid == 100 then
		texpath = "gfx/nmes/Zombie_0020.png"
		cols, rows = 4, 4
		self.animation:cutSpritesheet(texpath, cols, rows, animsimgs, 0, 1, self.sx, self.sy)
	elseif self.eid == 200 then
		texpath = "gfx/nmes/Zombie_0040.png"
		cols, rows = 3, 3
		self.animation:cutSpritesheet(texpath, cols, rows, animsimgs, 0, 1, self.sx, self.sy)
	elseif self.eid == 300 then
		texpath = "gfx/nmes/Zombie_0001.png"
		cols, rows = 5, 3
		self.animation:cutSpritesheet(texpath, cols, rows, animsimgs, 0, 1, self.sx, self.sy)
	end
	-- 1st set of animations: CAnimation:createAnim(xanims, xanimname, xanimsimgs, xtable, xstart, xfinish)
	if self.eid == 100 then
		self.animation:createAnim(anims, g_ANIM_DEFAULT, animsimgs, nil, 1, cols*rows)
		self.animation:createAnim(anims, g_ANIM_IDLE_R, animsimgs, nil, 1, cols*rows) -- fluid is best
	elseif self.eid == 200 then
		self.animation:createAnim(anims, g_ANIM_DEFAULT, animsimgs, nil, 1, cols*rows)
		self.animation:createAnim(anims, g_ANIM_IDLE_R, animsimgs, nil, 1, cols*rows) -- fluid is best
		self.animation:createAnim(anims, g_ANIM_RUN_R, animsimgs, nil, 1, cols*rows) -- fluid is best
	elseif self.eid == 300 then
		self.animation:createAnim(anims, g_ANIM_DEFAULT, animsimgs, nil, 5, 5)
		self.animation:createAnim(anims, g_ANIM_IDLE_R, animsimgs, nil, 5, 5) -- fluid is best
	end
	-- end animations
	self.animation.anims = anims
	self.sprite = self.animation.sprite
	self.animation.sprite = nil -- free some memory
	self.w, self.h = self.sprite:getWidth(), self.sprite:getHeight() -- with applied scale
	-- BODY: CBody:init(xmass, xspeed, xupspeed, xextra)
	if self.eid == 100 then
		self.body = CBody.new(1, 0, 0, true)
	elseif self.eid == 200 then
		self.body = CBody.new(1, 12*8, 64*8, true)
	elseif self.eid == 300 then
		self.body = CBody.new(1, 0, 0, true)
	end
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
	local collw, collh = (self.w*0.5)//1, (self.h*0.8)//1 -- must be round numbers for cbump physics!
	self.collbox = CCollisionBox.new(collw, collh)
	-- AI
	self.ai = true
	-- shield
	self.shield = {}
	self.shield.sprite = Pixel.new(0x5555ff, 0.75, 8, collh-6)
	self.shield.sprite.sx = 1
	self.shield.sprite.sy = self.shield.sprite.sx
	self.shield.sprite:setScale(self.shield.sprite.sx, self.shield.sprite.sy)
	self.shield.sprite:setAnchorPoint(0.5, 0.5)
	self.spritelayer:addChild(self.shield.sprite)
	self.shield.offset = vector(collw, (collh+6)*0.5)
	self.shield.timer = 4*8 -- 4*8, 2*8
	self.shield.currtimer = self.shield.timer
	self.shield.damage = 0.1
end
