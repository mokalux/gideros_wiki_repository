CBody = Core.class()

function CBody:init(xspeed, xjumpspeed)
	-- body physics properties
	self.vx = 0
	self.vy = 0
	self.speed = xspeed
	self.currspeed = self.speed
	self.jumpspeed = xjumpspeed
	self.currjumpspeed = self.jumpspeed
	self.isonfloor = true
	self.isgoingup = false
end
