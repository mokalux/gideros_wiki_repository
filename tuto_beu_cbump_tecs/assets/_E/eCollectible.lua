ECollectible = Core.class()

function ECollectible:init(xspritelayer, xpos)
	-- ids
	self.iscollectible = true
	-- sprite layer
	self.spritelayer = xspritelayer
	-- params
	self.pos = xpos
	self.positionystart = self.pos.y -- for sprite sorting
	self.sx = 1
	self.sy = self.sx
	self.flip = math.random(100)
	if self.flip > 80 then self.flip = 1
	else self.flip = -1
	end
	self.totallives = 1
	self.currlives = self.totallives
	-- COMPONENTS
	-- ANIMATION: CAnimation:init(xspritesheetpath, xcols, xrows, xanimspeed, xoffx, xoffy, sx, sy)
	local texpath = "gfx/collectible/Dragon Eggs 1.png"
	local framerate = 1
	self.animation = CAnimation.new(texpath, 1, 1, framerate, 0, 0, self.sx, self.sy)
	self.sprite = self.animation.sprite
	self.sprite:setScale(self.sx*self.flip, self.sy)
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
	local collw, collh = self.w*0.6, self.h*0.6
	self.collbox = CCollisionBox.new(collw, collh)
	-- SHADOW: CShadow:init(xparentw, xshadowsx, xshadowsy)
	self.shadow = CShadow.new(self.w*0.75)
	-- IDEA: CREATE AN OSCILLATION COMPONENT using body xspeed, xjumpspeed!
end
