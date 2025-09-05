SMvpf = Core.class()

function SMvpf:init(xtiny, xbworld)
	xtiny.processingSystem(self) -- called once on init and every frames
	self.bworld = xbworld -- cbump world
end

function SMvpf:filter(ent) -- tiny function
	return ent.ismvpf -- both mvpf and ptmvpf
end

function SMvpf:onAdd(ent) -- tiny function
--	print("SMvpf:onAdd")
end

function SMvpf:onRemove(ent) -- tiny function
--	print("SMvpf:onRemove")
end

function SMvpf:process(ent, dt) -- tiny function
	local function fun()
		local function collisionfilter(item, other) -- "touch", "cross", "slide", "bounce"
			return "cross"
		end
		-- cbump
		local goalx = ent.pos.x + ent.body.vx * dt
		local goaly = ent.pos.y + ent.body.vy * dt
		local nextx, nexty, _collisions, _len = self.bworld:move(ent, goalx, goaly, collisionfilter)
		-- motion ai x
		if ent.pos.x >= ent.distance.startpos.x + ent.distance.dx then
			ent.isleft, ent.isright = true, false
		elseif ent.pos.x <= ent.distance.startpos.x then
			ent.isleft, ent.isright = false, true
		end
		-- motion ai y
		if ent.dir == "SE" then -- initial movement going down to the right
			if ent.pos.y >= ent.distance.startpos.y + ent.distance.dy then
				ent.isup, ent.isdown = true, false
			elseif ent.pos.y <= ent.distance.startpos.y then
				ent.isup, ent.isdown = false, true
			end
		else
			if ent.pos.y <= ent.distance.startpos.y - ent.distance.dy then
				ent.isup, ent.isdown = false, true
			elseif ent.pos.y >= ent.distance.startpos.y then
				ent.isup, ent.isdown = true, false
			end
		end
		-- movement vx
		if ent.isleft and not ent.isright then -- LEFT
			ent.flip = -1
			ent.body.vx = -ent.body.speed
		elseif ent.isright and not ent.isleft then -- RIGHT
			ent.flip = 1
			ent.body.vx = ent.body.speed
		end
		-- movement vy
		if ent.isup and not ent.isdown then -- UP
			ent.body.vy = -ent.body.upspeed
		elseif ent.isdown and not ent.isup then -- DOWN
			ent.body.vy = ent.body.upspeed
		end
		-- move & flip
		ent.pos = vector(nextx, nexty)
		ent.sprite:setPosition(ent.pos + vector(ent.collbox.w/2, -ent.h/2+ent.collbox.h))
		Core.yield(1)
	end
	Core.asyncCall(fun)
end
