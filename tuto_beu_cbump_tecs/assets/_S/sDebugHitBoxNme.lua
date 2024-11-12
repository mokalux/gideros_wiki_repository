SDebugHitBoxNme = Core.class()

function SDebugHitBoxNme:init(xtiny, xshowbox) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
	self.showbox = xshowbox
end

function SDebugHitBoxNme:filter(ent) -- tiny function
	return (ent.headhitboxattack1 or ent.headhitboxattack2 or ent.spinehitboxattack1 or ent.spinehitboxattack2 or
		ent.headhitboxjattack1 or ent.spinehitboxjattack1) and not ent.isplayer1
end

function SDebugHitBoxNme:onAdd(ent) -- tiny function
	-- debugheadhitboxp1
	if ent.headhitboxattack1 then
		ent.debugheadhitboxp1 = Pixel.new(0xaa0000, 0.5, ent.headhitboxattack1.w, ent.headhitboxattack1.h)
		ent.debugheadhitboxp1:setAnchorPoint(0.5, 0.5)
		ent.spritelayer:addChild(ent.debugheadhitboxp1)
		ent.debugheadhitboxp1:setVisible(self.showbox[1]) -- granular debugging
	end
	-- debugheadhitboxp2
	if ent.headhitboxattack2 then
		ent.debugheadhitboxp2 = Pixel.new(0xaa5500, 0.5, ent.headhitboxattack2.w, ent.headhitboxattack2.h)
		ent.debugheadhitboxp2:setAnchorPoint(0.5, 0.5)
		ent.spritelayer:addChild(ent.debugheadhitboxp2)
		ent.debugheadhitboxp2:setVisible(self.showbox[2]) -- granular debugging
	end
	-- debugspinehitboxk1
	if ent.spinehitboxattack1 then
		ent.debugspinehitboxk1 = Pixel.new(0x005500, 0.5, ent.spinehitboxattack1.w, ent.spinehitboxattack1.h)
		ent.debugspinehitboxk1:setAnchorPoint(0.5, 0.5)
		ent.spritelayer:addChild(ent.debugspinehitboxk1)
		ent.debugspinehitboxk1:setVisible(self.showbox[3]) -- granular debugging
	end
	-- debugspinehitboxk2
	if ent.spinehitboxattack2 then
		ent.debugspinehitboxk2 = Pixel.new(0x00aa00, 0.5, ent.spinehitboxattack2.w, ent.spinehitboxattack2.h)
		ent.debugspinehitboxk2:setAnchorPoint(0.5, 0.5)
		ent.spritelayer:addChild(ent.debugspinehitboxk2)
		ent.debugspinehitboxk2:setVisible(self.showbox[4]) -- granular debugging
	end
	-- debugheadhitboxjp1
	if ent.headhitboxjattack1 then
		ent.debugheadhitboxjp1 = Pixel.new(0xaaaa00, 0.5, ent.headhitboxjattack1.w, ent.headhitboxjattack1.h)
		ent.debugheadhitboxjp1:setAnchorPoint(0.5, 0.5)
		ent.spritelayer:addChild(ent.debugheadhitboxjp1)
		ent.debugheadhitboxjp1:setVisible(self.showbox[5]) -- granular debugging
	end
	-- debugspinehitboxjk1
	if ent.spinehitboxjattack1 then
		ent.debugspinehitboxjk1 = Pixel.new(0x00ff00, 0.5, ent.spinehitboxjattack1.w, ent.spinehitboxjattack1.h)
		ent.debugspinehitboxjk1:setAnchorPoint(0.5, 0.5)
		ent.spritelayer:addChild(ent.debugspinehitboxjk1)
		ent.debugspinehitboxjk1:setVisible(self.showbox[6]) -- granular debugging
	end
end

function SDebugHitBoxNme:onRemove(ent) -- tiny function
	if ent.headhitboxattack1 then ent.spritelayer:removeChild(ent.debugheadhitboxp1) end
	if ent.headhitboxattack2 then ent.spritelayer:removeChild(ent.debugheadhitboxp2) end
	if ent.spinehitboxattack1 then ent.spritelayer:removeChild(ent.debugspinehitboxk1) end
	if ent.spinehitboxattack2 then ent.spritelayer:removeChild(ent.debugspinehitboxk2) end
	if ent.headhitboxjattack1 then ent.spritelayer:removeChild(ent.debugheadhitboxjp1) end
	if ent.spinehitboxjattack1 then ent.spritelayer:removeChild(ent.debugspinehitboxjk1) end
end

function SDebugHitBoxNme:process(ent, dt) -- tiny function
	local function fun()
		if ent.headhitboxattack1 then
			ent.debugheadhitboxp1:setPosition(ent.x+ent.collbox.w/2+(ent.headhitboxattack1.x*ent.flip), ent.y+ent.headhitboxattack1.y)
		end
		if ent.headhitboxattack2 then
			ent.debugheadhitboxp2:setPosition(ent.x+ent.collbox.w/2+(ent.headhitboxattack2.x*ent.flip), ent.y+ent.headhitboxattack2.y)
		end
		if ent.spinehitboxattack1 then
			ent.debugspinehitboxk1:setPosition(ent.x+ent.collbox.w/2+(ent.spinehitboxattack1.x*ent.flip), ent.y+ent.spinehitboxattack1.y)
		end
		if ent.spinehitboxattack2 then
			ent.debugspinehitboxk2:setPosition(ent.x+ent.collbox.w/2+(ent.spinehitboxattack2.x*ent.flip), ent.y+ent.spinehitboxattack2.y)
		end
		if ent.headhitboxjattack1 then
			ent.debugheadhitboxjp1:setPosition(ent.x+ent.collbox.w/2+(ent.headhitboxjattack1.x*ent.flip), ent.y+ent.headhitboxjattack1.y)
		end
		if ent.spinehitboxjattack1 then
			ent.debugspinehitboxjk1:setPosition(ent.x+ent.collbox.w/2+(ent.spinehitboxjattack1.x*ent.flip), ent.y+ent.spinehitboxjattack1.y)
		end
		Core.yield(1)
	end
	Core.asyncCall(fun)
end



