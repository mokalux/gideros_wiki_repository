SSpritesSorting = Core.class()

function SSpritesSorting:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
	self.spriteslist = xtiny.spriteslist
end

function SSpritesSorting:filter(ent) -- tiny function
	return ent.sprite
end

function SSpritesSorting:onAdd(ent) -- tiny function
--	print("SSpritesSorting added", ent)
	self.spriteslist[ent] = true
end

function SSpritesSorting:onRemove(ent) -- tiny function
--	print("SSpritesSorting removed", ent)
	self.spriteslist[ent] = nil
end

local p1rangetoofar = myappwidth*0.5 -- save some CPU
function SSpritesSorting:process(ent, dt) -- tiny function
	local function fun()
		for k, _ in pairs(self.spriteslist) do
			if ent.currlives <= 0 or k.currlives <= 0 then -- don't sort if dead
				return
			end
			if k.isplayer1 then -- don't sort out of range actors to save frames
				if -(k.pos.x-ent.pos.x)<>(k.pos.x-ent.pos.x) > p1rangetoofar then
					return
				end
			end
			if not ent.body.isonfloor then
				if ent.positionystart < k.positionystart and -- ent is behind
					ent.spritelayer:getChildIndex(ent.sprite) > k.spritelayer:getChildIndex(k.sprite) then -- sprite is in front
					ent.spritelayer:swapChildren(ent.sprite, k.sprite)
				end
			else
				if ent.pos.y < k.pos.y and -- ent is behind
					ent.spritelayer:getChildIndex(ent.sprite) > k.spritelayer:getChildIndex(k.sprite) then -- sprite is in front
					ent.spritelayer:swapChildren(ent.sprite, k.sprite)
				end
			end
		end
		Core.yield(0.5)
	end
	Core.asyncCall(fun) -- profiler seems to be faster without asyncCall (because of pairs traversing?)
end
