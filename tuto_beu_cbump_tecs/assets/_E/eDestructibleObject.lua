EDestructibleObject = Core.class()

function EDestructibleObject:init(xspritelayer, xpos)
	-- ids
	self.isdestructibleobject = true
	-- sprite layer
	self.spritelayer = xspritelayer
	-- params
	self.pos = xpos
	self.positionystart = self.pos.y -- for sprite sorting
	self.sx = 1
	self.sy = self.sx
	self.flip = math.random(100)
	if self.flip > 50 then self.flip = 1
	else self.flip = -1
	end
	self.totallives = 1
	self.totalhealth = 2
	if g_difficulty == 0 then -- easy
		self.totalhealth *= 0.5
	end
	self.currlives = self.totallives
	self.currhealth = self.totalhealth
	-- recovery
	self.washurt = 0
	self.wasbadlyhurt = 0
	self.recovertimer = 10
	self.hitfx = Bitmap.new(Texture.new("gfx/fx/1.png"))
	self.hitfx:setAnchorPoint(0.5, 0.5)
	-- COMPONENTS
	-- ANIMATION: CAnimation:init(xspritesheetpath, xcols, xrows, xanimspeed, xoffx, xoffy, sx, sy)
	local texpath = "gfx/breakable/Barrel_02_0012.png"
	local framerate = 1
	self.animation = CAnimation.new(texpath, 1, 1, framerate, 0, 0, self.sx, self.sy)
	self.sprite = self.animation.sprite
	self.sprite:setScale(self.sx*self.flip, self.sy) -- for the flip
	self.animation.sprite = nil -- free some memory
	self.w, self.h = self.sprite:getWidth(), self.sprite:getHeight()
	-- create animations: CAnimation:createAnim(xanimname, xstart, xfinish)
	self.animation:createAnim(g_ANIM_DEFAULT, 1, 1)
	self.animation:createAnim(g_ANIM_IDLE_R, 1, 1)
	-- clean up
	self.animation.myanimsimgs = nil
	-- BODY: CBody:init(xspeed, xjumpspeed)
	self.body = CBody.new(0, 0) -- xspeed, xjumpspeed
	self.body.defaultmass = 1
	self.body.currmass = self.body.defaultmass
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
	local collw, collh = self.w*1, 8*self.sy
	self.collbox = CCollisionBox.new(collw, collh)
	-- hurt box
	local hhbw, hhbh = self.w, 1*self.h/2
	self.headhurtbox = {
		isactive=false,
		x=0*self.sx,
		y=-self.h+hhbh*0.5+self.collbox.h/2,
		w=hhbw,
		h=hhbh,
	}
	local shbw, shbh = self.w, 3*self.h/4
	self.spinehurtbox = {
		isactive=false,
		x=0*self.sx,
		y=self.collbox.h/2-shbh/2,
		w=shbw,
		h=shbh,
	}
	-- SHADOW: CShadow:init(xparentw, xshadowsx, xshadowsy)
	self.shadow = CShadow.new(self.w*1.1)
end
