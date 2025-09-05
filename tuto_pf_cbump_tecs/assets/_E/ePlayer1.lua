EPlayer1 = Core.class()

function EPlayer1:init(xspritelayer, xpos, xbgfxlayer)
	-- ids
	self.isplayer1 = true
	self.doanimate = true -- to save some cpu
	self.ispersistent = true -- keep sprite visible when dead
	-- sprite layers
	self.spritelayer = xspritelayer
	self.bgfxlayer = xbgfxlayer
	-- params
	self.pos = xpos
	self.sx = 1 -- 0.96, 0.8, 1.05, 1.1, 1.2
	self.sy = self.sx
	self.flip = 1
	self.totallives = 3
	self.totalhealth = 3
	if g_difficulty == 0 then -- easy
		self.totallives *= 2
		self.totalhealth *= 2
	end
	self.currlives = self.totallives
	self.currhealth = self.totalhealth
	-- recovery
	self.washurt = 0
	self.wasbadlyhurt = 0
	self.recovertimer = 20 -- 30
	self.recoverbadtimer = 60 -- 90
	if g_difficulty == 0 then -- easy
		self.recovertimer *= 2
		self.recoverbadtimer *= 2
	elseif g_difficulty == 2 then -- hard
		self.recovertimer *= 0.5
		self.recoverbadtimer *= 0.5
	end
	self.hitfx = Bitmap.new(Texture.new("gfx/fxs/2.png"))
	self.hitfx:setAnchorPoint(0.5, 0.5)
	-- COMPONENTS
	-- ANIMATION
	local anims = {} -- table to hold actor animations
	local animsimgs = {} -- table to hold actor animations images
	-- CAnimation:init(xanimspeed)
	local framerate = 1/10 -- 1/14, 1/18
	self.animation = CAnimation.new(framerate)
	-- CAnimation:cutSpritesheet(xspritesheetpath, xcols, xrows, xanimsimgs, xoffx, xoffy, sx, sy)
	local texpath = "gfx/player1/Matt_0001.png"
	self.animation:cutSpritesheet(texpath, 9, 6, animsimgs, 0, 1, self.sx, self.sy)
	-- 1st set of animations: CAnimation:createAnim(xanims, xanimname, xanimsimgs, xtable, xstart, xfinish)
	self.animation:createAnim(anims, g_ANIM_DEFAULT, animsimgs, nil, 1, 15)
	self.animation:createAnim(anims, g_ANIM_IDLE_R, animsimgs, nil, 1, 15) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_RUN_R, animsimgs, nil, 16, 22) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_JUMPUP_R, animsimgs, nil, 23, 23) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_JUMPDOWN_R, animsimgs, nil, 23, 25) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_LADDER_IDLE_R, animsimgs, nil, 1, 15) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_LADDER_UP_R, animsimgs, nil, 16, 22) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_LADDER_DOWN_R, animsimgs, nil, 16, 22) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_WALL_IDLE_R, animsimgs, nil, 33, 33) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_WALL_UP_R, animsimgs, nil, 26, 37) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_WALL_DOWN_R, animsimgs, nil, 43, 54) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_HURT_R, animsimgs, { 38, 39, 38, 39, 1, }) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_LOSE1_R, animsimgs, nil, 38, 42) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_STANDUP_R, animsimgs, { 42, 41, 40, 39, 1, }) -- fluid is best
	self.animation.anims = anims
	self.sprite = self.animation.sprite
	self.animation.sprite = nil -- free some memory
	self.w, self.h = self.sprite:getWidth(), self.sprite:getHeight() -- with applied scale
	print("player1 size (scaled): ", self.w, self.h)
	-- BODY: CBody:init(xmass, xspeed, xupspeed, xextra)
	self.body = CBody.new(1, 18*8, 68*8, true) -- (1, 22*8, 70*8, true)
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
	local collw, collh = (self.w*0.3)//1, (self.h*0.75)//1 -- must be round numbers for cbump physics!
	self.collbox = CCollisionBox.new(collw, collh)
	-- shield
	self.shield = {}
--	self.shield.sprite = Bitmap.new(Texture.new("gfx/fxs/Husky_0001.png"))
	self.shield.sprite = Pixel.new(0xffaa00, 0.75, 8, collh+4)
	self.shield.sprite.sx = 1
	self.shield.sprite.sy = self.shield.sprite.sx
	self.shield.sprite:setScale(self.shield.sprite.sx, self.shield.sprite.sy)
	self.shield.sprite:setAlpha(0.8)
	self.shield.sprite:setAnchorPoint(0.5, 0.5)
	self.spritelayer:addChild(self.shield.sprite)
	self.shield.offset = vector(collw, (collh-4)*0.5) -- (5*8, -1*8)
	self.shield.timer = 3*8 -- 2*8
	self.shield.currtimer = self.shield.timer
	self.shield.damage = 0.5
end
