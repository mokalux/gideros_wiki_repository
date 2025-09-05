SDebugShield = Core.class()

function SDebugShield:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
end

function SDebugShield:filter(ent) -- tiny function
	return ent.shield
end

function SDebugShield:onAdd(ent) -- tiny function
	--ent.pos + vector(ent.collbox.w/2, 0) + ent.shield.offset*vector(ent.flip, 1)
	local pw, ph = ent.shield.sprite:getWidth(), ent.shield.sprite:getHeight()
	ent.debug = Pixel.new(0x5500ff, 0.2, pw, ph)
	ent.debug:setAnchorPoint(0.5, 0.5)
	ent.spritelayer:addChild(ent.debug)
	-- querry rect
	ent.debugqr = Pixel.new(0xaaff00, 0.3, pw, ph) -- querry rectangle
	ent.debugqr:setAnchorPoint(0, 0.01) -- a little offset
	ent.spritelayer:addChild(ent.debugqr)
end

function SDebugShield:onRemove(ent) -- tiny function
	ent.debug:removeFromParent()
	ent.debugqr:removeFromParent()
end

function SDebugShield:process(ent, dt) -- tiny function
	local function fun()
		if ent.currlives > 0 then
			ent.debug:setPosition(
				ent.pos +
				vector(ent.collbox.w/2, 0) +
				ent.shield.offset*vector(ent.shield.sprite.sx*ent.flip, ent.shield.sprite.sy)
			)
			local pw, ph = ent.shield.sprite:getWidth(), ent.shield.sprite:getHeight()
			ent.debugqr:setPosition(
				ent.pos +
				ent.shield.offset*vector(ent.shield.sprite.sx*ent.flip, ent.shield.sprite.sy) -
				vector(pw*0.5, ph*0.5) + vector(ent.collbox.w*0.5, 0)
			)
		end
		Core.yield(1)
	end
	Core.asyncCall(fun)
end
