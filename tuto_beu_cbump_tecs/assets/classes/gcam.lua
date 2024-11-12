local random = math.random

local function clamp(v,mn,mx) return (v><mx)<>mn end
local function map(v, minSrc, maxSrc, minDst, maxDst, clampValue)
	local newV = (v - minSrc) / (maxSrc - minSrc) * (maxDst - minDst) + minDst
	return not clampValue and newV or clamp(newV, minDst >< maxDst, minDst <> maxDst)
end
local function outExponential(ratio) if ratio == 1 then return 1 end return 1-2^(-10 * ratio) end

-- **********************
GCam = Core.class(Sprite)

GCam.SHAKE_DELAY = 10 -- magik XXX

function GCam:init(content, ax, ay)
	assert(content ~= stage, "bad argument #1 (сontent should be different from the 'stage')")

	self.viewport = Viewport.new()
	self.viewport:setContent(content)

	self.content = Sprite.new()
	self.content:addChild(self.viewport)
	self:addChild(self.content)

	self.matrix = Matrix.new()
	self.viewport:setMatrix(self.matrix)

	-- some vars
	self.w = 0
	self.h = 0
	self.ax = ax or 0.5
	self.ay = ay or 0.5
	self.x = 0
	self.y = 0
	self.zoomFactor = 1
	self.rotation = 0

	self.followOX = 0
	self.followOY = 0

	-- Bounds
	self.leftBound = -1000000
	self.rightBound = 1000000
	self.topBound = -1000000
	self.bottomBound = 1000000
	
	-- Shaker
	self.shakeTimer = Timer.new(GCam.SHAKE_DELAY, 1)
	self.shakeDistance = 0
	self.shakeCount = 0
	self.shakeAmount = 0
	self.shakeTimer:addEventListener("timerComplete", self.shakeDone, self)
	self.shakeTimer:addEventListener("timer", self.shakeUpdate, self)
	self.shakeTimer:stop()
	
	-- Follow
	self.smoothX = 0.9 -- 0 - instant move
	self.smoothY = 0.9 -- 0 - instant move
	-- Dead zone
	self.deadWidth = 50
	self.deadHeight = 50
	self.deadRadius = 25
	-- Soft zone
	self.softWidth = 150
	self.softHeight = 150
	self.softRadius = 75
	
	---------------------------------------
	------------- debug stuff -------------
	---------------------------------------
	self.__debugSoftColor = 0xffff00
	self.__debugAnchorColor = 0xff0000
	self.__debugDotColor = 0x00ff00
	self.__debugAlpha = 0.5
	
	self.__debugRMesh = Mesh.new()
	self.__debugRMesh:setIndexArray(1,3,4, 1,2,4, 1,3,7, 3,5,7, 2,4,8, 4,8,6, 5,6,8, 5,8,7, 9,10,11, 9,11,12, 13,14,15, 13,15,16, 17,18,19, 17,19,20)
	self.__debugRMesh:setColorArray(self.__debugSoftColor,self.__debugAlpha, self.__debugSoftColor,self.__debugAlpha, self.__debugSoftColor,self.__debugAlpha, self.__debugSoftColor,self.__debugAlpha,  self.__debugSoftColor,self.__debugAlpha, self.__debugSoftColor,self.__debugAlpha, self.__debugSoftColor,self.__debugAlpha, self.__debugSoftColor,self.__debugAlpha, self.__debugAnchorColor,self.__debugAlpha, self.__debugAnchorColor,self.__debugAlpha, self.__debugAnchorColor,self.__debugAlpha, self.__debugAnchorColor,self.__debugAlpha,  self.__debugAnchorColor,self.__debugAlpha, self.__debugAnchorColor,self.__debugAlpha, self.__debugAnchorColor,self.__debugAlpha, self.__debugAnchorColor,self.__debugAlpha, self.__debugDotColor,self.__debugAlpha, self.__debugDotColor,self.__debugAlpha, self.__debugDotColor,self.__debugAlpha, self.__debugDotColor,self.__debugAlpha)
	
	---------------------------------------
	---------------------------------------
	---------------------------------------
	self:setAnchor(self.ax,self.ay)
	self:updateClip()
end

---------------------------------------------------
------------------- DEBUG STUFF -------------------
---------------------------------------------------
function GCam:setDebug(flag)
	self.__debug__ = flag
	if flag then 
		self:addChild(self.__debugRMesh)
		self:debugUpdate()
		self:debugUpdate(true, 0, 0)
	else
		self.__debugRMesh:removeFromParent()
	end
end

function GCam:switchDebug()
	self:setDebug(not self.__debug__)
end

function GCam:debugMeshUpdate()
	local w,h = self.w, self.h
	local zoom = self.zoomFactor
	local rot = self.rotation
	
	local ax,ay = w * self.ax,h * self.ay
	
	local TS = 1
	local off = w <> h
	
	local dw = (self.deadWidth  * zoom) / 2
	local dh = (self.deadHeight * zoom) / 2
	local sw = (self.softWidth  * zoom) / 2
	local sh = (self.softHeight * zoom) / 2
	--[[
	Mesh vertices
	1-----------------2
	| \  soft zone  / |
	|  3-----------4  |
	|  | dead zone |  |
	|  5-----------6  |
	| /             \ |
	7-----------------8
	]]	
	self.__debugRMesh:setVertexArray(
		ax-sw,ay-sh, 
		ax+sw,ay-sh,
		
		ax-dw,ay-dh,
		ax+dw,ay-dh,
		ax-dw,ay+dh,
		ax+dw,ay+dh,
		
		ax-sw,ay+sh,
		ax+sw,ay+sh,
		
		ax-TS,-off, ax+TS,-off,
		ax+TS,h+off, ax-TS,h+off,
		
		-off,ay-TS, -off,ay+TS,
		w+off,ay+TS, w+off,ay-TS
	)
	self.__debugRMesh:setAnchorPosition(ax,ay)
	self.__debugRMesh:setPosition(ax,ay)
	self.__debugRMesh:setRotation(rot)
end

function GCam:debugUpdate(dotOnly, gx, gy)
	if self.__debug__ then 
		if dotOnly then 
			local zoom = self:getZoom()
			local ax = self.w * self.ax
			local ay = self.h * self.ay
			local size = 4 * zoom
			
			local x = (gx * zoom - self.x * zoom) + ax
			local y = (gy * zoom - self.y * zoom) + ay
			self.__debugRMesh:setVertex(17, x-size,y-size)
			self.__debugRMesh:setVertex(18, x+size,y-size)
			self.__debugRMesh:setVertex(19, x+size,y+size)
			self.__debugRMesh:setVertex(20, x-size,y+size)
		else
			self:debugMeshUpdate()
		end
	end
end

---------------------------------------------------
----------------- RESIZE LISTENER -----------------
---------------------------------------------------
-- set camera size to window size
function GCam:setAutoSize(flag)
	if flag then 
		self:addEventListener(Event.APPLICATION_RESIZE, self.appResize, self)
		self:appResize()
	elseif self:hasEventListener(Event.APPLICATION_RESIZE) then
		self:removeEventListener(Event.APPLICATION_RESIZE, self.appResize, self)
	end
end

function GCam:appResize()
	local minX,minY,maxX,maxY = application:getLogicalBounds()
	self.w = maxX+minX
	self.h = maxY+minY
	self.matrix:setPosition(self.w * self.ax,self.h * self.ay)
	self.viewport:setMatrix(self.matrix)
	self:debugUpdate()
	self:updateClip()
end

---------------------------------------------------
---------------------- SHAPES ---------------------
---------------------------------------------------
function GCam:rectangle(dt, x, y)
	local function smoothOver(smoothTime, convergenceFraction)
		return 1 - (1 - convergenceFraction)^(dt / smoothTime)
	end
	local function lerp(a,b,t) return a + (b-a) * t end
	local sw = self.softWidth  / 2
	local sh = self.softHeight / 2
	local dw = self.deadWidth  / 2
	local dh = self.deadHeight / 2

	local dstX = self.x
	local dstY = self.y

	-- X smoothing
	if x > self.x + dw then -- out of dead zone on right side
		local dx = x - self.x - dw
		local fx = smoothOver(self.smoothX, 0.99)
		dstX = lerp(self.x, self.x + dx, fx)
	elseif x < self.x - dw then  -- out of dead zone on left side
		local dx = self.x - dw - x
		local fx = smoothOver(self.smoothX, 0.99)
		dstX = lerp(self.x, self.x - dx, fx)
	end
	-- clamp to soft zone
	dstX = clamp(dstX, x - sw,x + sw)

	-- Y smoothing
	if y > self.y + dh then -- out of dead zone on bottom side
		local dy = y - self.y - dh
		local fy = smoothOver(self.smoothY, 0.99)
		dstY = lerp(self.y, self.y + dy, fy)
	elseif y < self.y - dh then  -- out of dead zone on top side
		local dy = self.y - dh - y
		local fy = smoothOver(self.smoothY, 0.99)
		dstY = lerp(self.y, self.y - dy, fy)
	end
	-- clamp to soft zone
	dstY = clamp(dstY, y - sh,y + sh)

	return dstX, dstY
end

---------------------------------------------------
---------------------- UPDATE ---------------------
---------------------------------------------------
function GCam:update(dt)
	local obj = self.followObj
	if obj then
		local x,y = obj:getPosition()
		x += self.followOX
		y += self.followOY
		local dstX, dstY = self:rectangle(dt,x,y)
		if self.x ~= dstX or self.y ~= dstY then self:goto(dstX,dstY) end
		self:debugUpdate(true,x,y)
	end
	self:updateClip()
end
function GCam:updateXOnly(dt)
	local obj = self.followObj
	if obj then
		local x,_ = obj:getPosition()
		x += self.followOX
		local dstX, dstY = self:rectangle(dt,x,self.y)
		if self.x ~= dstX then self:goto(dstX,dstY) end
		self:debugUpdate(true,x,self.y)
	end
	self:updateClip()
end

---------------------------------------------------
--------------------- FOLLOW ----------------------
---------------------------------------------------
function GCam:setFollow(obj)
	self.followObj = obj
end
function GCam:setFollowOffset(x,y)
	self.followOX = x
	self.followOY = y
end

---------------------------------------------------
---------------------- SHAKE ----------------------
---------------------------------------------------
-- duration (number): time in seconds
-- distance (number): maximum shake offset
function GCam:shake(duration, distance)
	self.shaking = true
	self.shakeCount = 0
	self.shakeDistance = distance or 100
	self.shakeAmount = (duration*1000) // GCam.SHAKE_DELAY

	self.shakeTimer:reset()
	self.shakeTimer:setRepeatCount(self.shakeAmount)
	self.shakeTimer:start()
end
function GCam:shakeDone()
	self.shaking = false
	self.shakeCount = 0
	self.content:setPosition(0,0)
end
function GCam:shakeUpdate()
	self.shakeCount += 1
	local amplitude = 1 - outExponential(self.shakeCount/self.shakeAmount)
	local hd = self.shakeDistance / 2
	local x = random(-hd,hd)*amplitude
	local y = random(-hd,hd)*amplitude
	self.content:setPosition(x, y)
end

--------------------------------------------------
--------------------- ZONES ----------------------
--------------------------------------------------
--	Camera intepolates its position towards target
-- w (number): soft zone width
-- h (number): soft zone height
function GCam:setSoftSize(w,h)
	self.softWidth = w
	self.softHeight = h or w
	self:debugUpdate()
end
function GCam:setSoftWidth(w)
	self.softWidth = w
	self:debugUpdate()
end
function GCam:setSoftHeight(h)
	self.softHeight = h
	self:debugUpdate()
end

--	Camera does not move in dead zone
-- w (number): dead zone width
-- h (number): dead zone height
function GCam:setDeadSize(w,h)
	self.deadWidth = w
	self.deadHeight = h or w
	self:debugUpdate()
end
function GCam:setDeadWidth(w)
	self.deadWidth = w
	self:debugUpdate()
end
function GCam:setDeadHeight(h)
	self.deadHeight = h
	self:debugUpdate()
end

-- Smooth factor
--	x (number):
--	y (number):
function GCam:setSmooth(x,y)
	self.smoothX = x
	self.smoothY = y or x
end
function GCam:setSmoothX(x)
	self.smoothX = x
end
function GCam:setSmoothY(y)
	self.smoothY = y
end

--------------------------------------------------
--------------------- BOUNDS ---------------------
--------------------------------------------------
function GCam:updateBounds()
	local x = clamp(self.x, self.leftBound, self.rightBound)
	local y = clamp(self.y, self.topBound, self.bottomBound)
	if x ~= self.x or y ~= self.y then self:goto(x,y) end
end
-- Camera can move only inside given bbox
function GCam:setBounds(left, top, right, bottom)
	self.leftBound = left or 0
	self.topBound = top or 0
	self.rightBound = right or 0
	self.bottomBound = bottom or 0
	self:updateBounds()
end
function GCam:setLeftBound(left)
	self.leftBound = left or 0
	self:updateBounds()
end
function GCam:setTopBound(top)
	self.topBound = top or 0
	self:updateBounds()
end
function GCam:setRightBound(right)
	self.rightBound = right or 0
	self:updateBounds()
end
function GCam:setBottomBound(bottom)
	self.bottomBound = bottom or 0
	self:updateBounds()
end
function GCam:getBounds() 
	return self.leftBound, self.topBound, self.rightBound, self.bottomBound
end

---------------------------------------------------
----------------- TRANSFORMATIONS -----------------
---------------------------------------------------
function GCam:move(dx, dy)
	self:goto(self.x + dx, self.y + dy)
end
function GCam:zoom(value)
	local v = self.zoomFactor + value
	if v > 0 then self:setZoom(v) end
end
function GCam:rotate(ang)
	self.rotation += ang
	self:setAngle(self.rotation)
end

------------------------------------------
---------------- POSITION ----------------
------------------------------------------
function GCam:rawGoto(x,y)
	x = clamp(x, self.leftBound, self.rightBound)
	y = clamp(y, self.topBound, self.bottomBound)
	self.matrix:setAnchorPosition(x,y)
	self.viewport:setMatrix(self.matrix)	
end
function GCam:goto(x,y)
	x = clamp(x, self.leftBound, self.rightBound)
	y = clamp(y, self.topBound, self.bottomBound)
	
	self.x = x
	self.y = y
	self.matrix:setAnchorPosition(x,y)
	self.viewport:setMatrix(self.matrix)
end
function GCam:gotoX(x)
	x = clamp(x, self.leftBound, self.rightBound)
	self.x = x
	self.matrix:setAnchorPosition(x,self.y)
	self.viewport:setMatrix(self.matrix)
end
function GCam:gotoY(y)
	y = clamp(y, self.topBound, self.bottomBound)
	self.y = y
	self.matrix:setAnchorPosition(self.x,y)
	self.viewport:setMatrix(self.matrix)
end

------------------------------------------
------------------ ZOOM ------------------
------------------------------------------
function GCam:setZoom(zoom)
	self.zoomFactor = zoom
	self.matrix:setScale(zoom, zoom, 1)
	self.viewport:setMatrix(self.matrix)
	self:debugUpdate()
end
function GCam:getZoom()
	return self.zoomFactor
end

------------------------------------------
---------------- ROTATION ----------------
------------------------------------------
function GCam:setAngle(angle)
	self.rotation = angle
	self.matrix:setRotationZ(angle)
	self.viewport:setMatrix(self.matrix)
	self:debugUpdate()
end
function GCam:getAngle()
	return self.matrix:getRotationZ()
end

------------------------------------------
-------------- ANCHOR POINT --------------
------------------------------------------
function GCam:setAnchor(anchorX, anchorY)
	self.ax = anchorX
	self.ay = anchorY
	self.matrix:setPosition(self.w * anchorX,self.h * anchorY)
	self.viewport:setMatrix(self.matrix)
	self:debugUpdate()
end
function GCam:setAnchorX(anchorX)
	self.ax = anchorX
	self.matrix:setPosition(self.w * anchorX,self.h * self.ay)
	self.viewport:setMatrix(self.matrix)
	self:debugUpdate()
end
function GCam:setAnchorY(anchorY)
	self.ay = anchorY
	self.matrix:setPosition(self.w * self.ax,self.h * anchorY)
	self.viewport:setMatrix(self.matrix)
	self:debugUpdate()
end
function GCam:getAnchor()
	return self.ax, self.ay
end

------------------------------------------
------------------ SIZE ------------------
------------------------------------------
function GCam:updateClip()
	local ax = self.w * self.ax
	local ay = self.h * self.ay
	self.viewport:setClip(self.x-ax,self.y-ay,self.w,self.h+ay)
	self.viewport:setAnchorPosition(self.x,self.y)
end
function GCam:setSize(w,h)
	self.w = w
	self.h = h
	self:debugUpdate()
	self:updateClip()
end
