SCollision = Core.class()

function SCollision:init(xtiny, xbworld, xplayer1) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
	self.tiny = xtiny
	self.bworld = xbworld
	self.player1 = xplayer1
end

function SCollision:filter(ent) -- tiny function
	return ent.collbox and ent.body and
		not (ent.isprojectile or ent.ismvpf or ent.isdoor)
end

function SCollision:onAdd(ent) -- tiny function
end

function SCollision:onRemove(ent) -- tiny function
end

local p1rangetoofarx = myappwidth*2 -- disable systems to save some CPU, magik XXX
local p1rangetoofary = myappheight*2 -- disable systems to save some CPU, magik XXX
function SCollision:process(ent, dt) -- tiny function
	-- OUTSIDE VISIBLE RANGE
	if ent.isnme then
		if (ent.pos.x > self.player1.pos.x + p1rangetoofarx or
			ent.pos.x < self.player1.pos.x - p1rangetoofarx) or
			(ent.pos.y > self.player1.pos.y + p1rangetoofary or
			ent.pos.y < self.player1.pos.y - p1rangetoofary) then
			ent.doanimate = false
			return
		end
	end
	-- physics flags
	ent.isstepcontacts = false
	ent.isfloorcontacts = false
	ent.isladdercontacts = false
	ent.isptpfcontacts = false
	ent.ismvpfcontacts = false
	ent.iswallcontacts = false
	ent.isspringcontacts = false
	--  _____ ____  _      _      _____  _____ _____ ____  _   _ 
	-- / ____/ __ \| |    | |    |_   _|/ ____|_   _/ __ \| \ | |
	--| |   | |  | | |    | |      | | | (___   | || |  | |  \| |
	--| |   | |  | | |    | |      | |  \___ \  | || |  | | . ` |
	--| |___| |__| | |____| |____ _| |_ ____) |_| || |__| | |\  |
	-- \_____\____/|______|______|_____|_____/|_____\____/|_| \_|
	-- ______ _____ _   _______ ______ _____  
	--|  ____|_   _| | |__   __|  ____|  __ \ 
	--| |__    | | | |    | |  | |__  | |__) |
	--|  __|   | | | |    | |  |  __| |  _  / 
	--| |     _| |_| |____| |  | |____| | \ \ 
	--|_|    |_____|______|_|  |______|_|  \_\
	local function collisionfilter(item, other) -- "touch", "cross", "slide", "bounce"
		if other.isnpc then return "cross"
		elseif other.isdoor then return "slide" -- needed 20250720
		elseif other.iswall then return "slide" -- "touch"
		elseif other.isfloor then return "slide"
		elseif other.isptpf then
			if item.isdown and item.isup then -- prevents ptpf while holding both up and down keys
				item.wasdown = true
				item.wasup = true
			end
			if item.isdown and not item.wasdown then
				return "cross"
			end
			if item.body.vy > 0 then -- actor going down
				local itembottom = item.pos.y + item.collbox.h
				local otherbottom = other.pos.y -- don't add margin here!
				if itembottom <= otherbottom then return "slide" end
			end
			if item.iswalkingnme and item.breed == "C" then
				return "slide"
			end
		elseif other.ismvpf then
			if item.isdown and item.isup then -- prevents pt mvpf while holding both up and down keys
				item.wasdown = true
				item.wasup = true
			end
			if item.isdown and not item.wasdown then
				if other.isptmvpf then return "cross" end -- passthrough moving pf
			end
			if item.body.vy > 0 then -- actor going down
				local itembottom = item.pos.y + item.collbox.h
				local otherbottom = other.pos.y + 1
				if other.body.vy < 0 then -- mvpf going up
					otherbottom += 1 -- margin prevents player from falling when the pf is going up
				end
				if itembottom <= otherbottom then return "slide" end
			end
		elseif other.isspring then return "slide"
		elseif other.isspike then return "slide"
		else return "cross"
		end
	end
	--  _____ ____  _    _ __  __ _____  
	-- / ____|  _ \| |  | |  \/  |  __ \ 
	--| |    | |_) | |  | | \  / | |__) |
	--| |    |  _ <| |  | | |\/| |  ___/ 
	--| |____| |_) | |__| | |  | | |     
	-- \_____|____/ \____/|_|  |_|_|     
	local goalx = ent.pos.x + ent.body.vx * dt
	local goaly = ent.pos.y + ent.body.vy * dt
	local nextx, nexty, collisions, len = self.bworld:move(ent, goalx, goaly, collisionfilter)
	--  _____ ____  _      _      _____  _____ _____ ____  _   _  _____ 
	-- / ____/ __ \| |    | |    |_   _|/ ____|_   _/ __ \| \ | |/ ____|
	--| |   | |  | | |    | |      | | | (___   | || |  | |  \| | (___  
	--| |   | |  | | |    | |      | |  \___ \  | || |  | | . ` |\___ \ 
	--| |___| |__| | |____| |____ _| |_ ____) |_| || |__| | |\  |____) |
	-- \_____\____/|______|______|_____|_____/|_____\____/|_| \_|_____/ 
	-- COLLISION FROM ANY SIDES
	for i = 1, len do
		local item = collisions[i].item
		local other = collisions[i].other
		local normal = collisions[i].normal
		--
		if other.isvoid then
			if item.isplayer1 then
				item.restart = true -- load lose scene?
			else
				item.currlives = 0
				item.readytoremove = true
			end
		elseif item.isplayer1 and other.isexit then
			g_currlevel += 1
			item.restart = true
		elseif other.isladder then
			item.body.currcoyotetimer = item.body.coyotetimer
			item.isladdercontacts = true
			if item.currlives <= 0 then
				item.readytoremove = true -- only remove actor when 'grounded'
			end
		elseif other.isptpf then
			item.isptpfcontacts = true
		elseif other.isstep then -- CBump stairs effect ;-)
			item.isstepcontacts = true
		elseif other.ismvpf then
			if item.body.vy > 0 then -- actor going down
				local itembottom = item.pos.y + item.collbox.h
				local otherbottom = other.pos.y + 1 -- some margin prevent player from sliding/falling
				if itembottom <= otherbottom then -- actor above mvpf
					item.ismvpfcontacts = true
					item.body.currjumpcount = item.body.jumpcount
					item.body.currcoyotetimer = item.body.coyotetimer
--					item.body.vy = 0 -- don't reset velocity y here because prevents ptpf!
				end
				if item.currlives <= 0 then
					item.readytoremove = true -- only remove actor when 'grounded'
				end
			end
			if item.isleft and not item.isright and other.body.vx < 0 then
				item.body.vx = -item.body.currspeed*0.9 -- slow down speed on mvpf, you choose!
			elseif item.isright and not item.isleft and other.body.vx < 0 then
				item.body.vx = item.body.currspeed*0.9 -- slow down speed on mvpf, you choose!
			elseif (item.isleft and item.isright) and other.body.vx < 0 then
				item.body.vx = other.body.vx
			elseif not(item.isleft and item.isright) and other.body.vx < 0 then
				item.body.vx = other.body.vx
			elseif item.isleft and not item.isright and other.body.vx > 0 then
				item.body.vx = -item.body.currspeed*0.9 -- slow down speed on mvpf, you choose!
			elseif item.isright and not item.isleft and other.body.vx > 0 then
				item.body.vx = item.body.currspeed*0.9 -- slow down speed on mvpf, you choose!
			elseif (item.isleft and item.isright) and other.body.vx > 0 then
				item.body.vx = other.body.vx
			elseif not (item.isleft and item.isright) and other.body.vx > 0 then
				item.body.vx = other.body.vx
			elseif item.isleft and not item.isright and other.body.vx == 0 then
				item.body.vx = -item.body.currspeed*0.9 -- slow down speed on mvpf, you choose!
			elseif item.isright and not item.isleft and other.body.vx == 0 then
				item.body.vx = item.body.currspeed*0.9 -- slow down speed on mvpf, you choose!
			elseif (item.isleft and item.isright) and other.body.vx == 0 then
				item.body.vx = 0
			elseif not (item.isleft and item.isright) and other.body.vx == 0 then
				item.body.vx = 0
			end
		elseif other.iswall then
			item.body.currjumpcount = item.body.jumpcount
			item.body.currcoyotetimer = item.body.coyotetimer + 1*8 -- increase timer for fun, magik XXX
			item.iswallcontacts = true
			item.wasonwall = true
--			item.wasup = false -- you can uncomment this line, GAMEPLAY: walls jumping too permissive
		elseif other.isspring then
			item.body.vy = -other.vy -- reset velocity y (don't accumulate gravity)
			item.isspringcontacts = true
			if item.currlives <= 0 then
				item.readytoremove = true -- only remove actor when 'grounded'
			end
		elseif other.isspike then
			item.body.vx = item.body.currspeed*5*-item.flip -- 3, magik XXX
			item.body.vy = -item.body.currupspeed*0.7 -- magik XXX
			if item.isplayer1 then
				item.isdirty = true
				item.damage = 1
			end
			if item.currlives <= 0 then
				item.readytoremove = true -- only remove actor when 'grounded'
			end
			item.wasup = false
		end
		-- COLLISION FROM TOP
		if normal.y == -1 then
			if other.isfloor then
				item.body.vy = 0 -- reset velocity y (don't accumulate gravity)
				item.isfloorcontacts = true
				item.body.currjumpcount = item.body.jumpcount
				item.body.currcoyotetimer = item.body.coyotetimer
				if item.currlives <= 0 then
					item.readytoremove = true -- only remove actor when 'grounded'
				end
			elseif other.isptpf then
				item.body.vy = 0 -- reset velocity y (don't accumulate gravity)
				item.isptpfcontacts = true
				item.body.currjumpcount = item.body.jumpcount
				item.body.currcoyotetimer = item.body.coyotetimer
				if item.currlives <= 0 then
					item.readytoremove = true -- only remove actor when 'grounded'
				end
			elseif other.isnme and item.isplayer1 then -- player1 on top of nme
				other.isdirty = true
				other.damage = 1
				item.body.currjumpcount = item.body.jumpcount
				if item.isup then
					item.body.vy = -ent.body.currupspeed*1.1
				else
					item.body.vy = -item.body.currupspeed*0.7 -- magik XXX, linked to 'stomp'
				end
			elseif other.isnme and item.isnme then -- nme on top of nme
				item.body.currjumpcount = item.body.jumpcount
				if item.isup then
					item.body.vy = -ent.body.currupspeed*1.1
				else
					item.body.vy = -item.body.currupspeed*0.7 -- magik XXX, linked to 'stomp'
				end
				if item.currlives <= 0 then
					item.readytoremove = true -- only remove actor when 'grounded'
				end
			elseif other.isplayer1 and item.isnme then -- nme on top of player1
				other.isdirty = true
				other.damage = 1
				item.wasup = false -- ??? XXX
				item.body.currjumpcount = item.body.jumpcount
				item.body.currinputbuffer = item.body.inputbuffer
				item.body.currcoyotetimer = item.body.coyotetimer
			end
		-- COLLISION FROM BOTTOM
		elseif normal.y == 1 then
			if other.isfloor then -- cancel body gravity when hitting from below (can adjust)
				item.body.vy *= 0.5 -- = 0
			end
		end
		-- COLLISION FROM SIDES, -1 collision from item right, 1 collision from item left
		if normal.x == -1 or normal.x == 1 then
			if item.isplayer1 and other.isfloor then
				item.body.vx = -item.flip
			elseif item.isnme and other.isdoor then
				item.isleft, item.isright = not item.isleft, not item.isright
			elseif item.isnme and other.isfloor then
				if normal.x == -1 and not item.isleftofplayer then
					item.isleft, item.isright = true, false
				elseif normal.x == 1 and item.isleftofplayer then
					item.isleft, item.isright = false, true
				end
			end
		end
		-- PLAYER1
		if item.isplayer1 and other.iscollectible then
			other.isdirty = true
			if other.eid:find("key") then -- add key to inventory
				self.tiny.player1inventory[other.eid:sub(4)] = true -- eid with "key" truncated
--				print("key", other.eid, dt)
			end
		end
	end
	--  _____ _____       __      _______ _________     __
	-- / ____|  __ \     /\ \    / /_   _|__   __\ \   / /
	--| |  __| |__) |   /  \ \  / /  | |    | |   \ \_/ / 
	--| | |_ |  _  /   / /\ \ \/ /   | |    | |    \   /  
	--| |__| | | \ \  / ____ \  /   _| |_   | |     | |   
	-- \_____|_|  \_\/_/    \_\/   |_____|  |_|     |_|   
	-- gravity after collisions because ptpfs may modify actor body vy
	if ent.body.vy < 0 then -- going up
		ent.body.vy += 3*8 * ent.body.currmass -- gravity, magik XXX
	else -- going down
		ent.body.vy += 3*8 * ent.body.currmass -- 3*8, gravity, magik XXX
		if ent.body.vy > 500 then -- 500, cap falling speed
			ent.body.vy = 500
		end
		if ent.wasonmvpf then -- prevent fast fall when going off pf
			ent.body.vy = ent.body.currupspeed*0.25 -- *0.5, ent going down mvpf, magik XXX
			ent.wasonmvpf = false
		elseif ent.wasonwall then -- ent wall sliding
			ent.body.vy = ent.body.currupspeed*0.01 -- *0.25, magik XXX
			ent.wasonwall = false
		end
	end
	--  _____  _    ___     _______ _____ _____  _____ 
	-- |  __ \| |  | \ \   / / ____|_   _/ ____|/ ____|
	-- | |__) | |__| |\ \_/ / (___   | || |    | (___  
	-- |  ___/|  __  | \   / \___ \  | || |     \___ \ 
	-- | |    | |  | |  | |  ____) |_| || |____ ____) |
	-- |_|    |_|  |_|  |_| |_____/|_____\_____|_____/ 
	if ent.body.currinputbuffer > 0 then -- floor input buffer
		ent.body.currinputbuffer -= 1
	end
	if ent.body.currcoyotetimer > 0 then -- coyote time
		ent.body.currcoyotetimer -= 1
	end
	if ent.body.currdashtimer > 0 then -- dash
		ent.body.currdashtimer -= 1
	end
	if ent.body.currdashcooldown > 0 then -- dash cooldown
		ent.body.currdashcooldown -= 1
	end
	-- IS ON STEP
	if ent.isstepcontacts then
--		if ent.isplayer1 then print("isstepcontacts", dt) end
		if ent.isleft and not ent.isright then -- LEFT
			ent.animation.curranim = g_ANIM_RUN_R
			ent.flip = -1
			ent.body.vx = -ent.body.currspeed
			ent.body.vy = -ent.body.currupspeed*0.4 -- 0.5, step climb speed here XXX
		elseif ent.isright and not ent.isleft then -- RIGHT
			ent.animation.curranim = g_ANIM_RUN_R
			ent.flip = 1
			ent.body.vx = ent.body.currspeed
			ent.body.vy = -ent.body.currupspeed*0.4 -- 0.5, step climb speed here XXX
		else
			ent.animation.curranim = g_ANIM_IDLE_R
			ent.body.vx *= 0.75 -- 0.8, 0.9, = 0
			if (-ent.body.vx<>ent.body.vx) < 0.001 then ent.body.vx = 0 end
		end
	-- IS ON FLOOR
	elseif (ent.isfloorcontacts or
			(ent.isfloorcontacts and ent.isladdercontacts)) and
			not ent.isptpfcontacts and
			not ent.ismvpfcontacts and
			not ent.iswallcontacts
			then
--		if ent.isplayer1 then print("isonfloor", dt) end
		if ent.isleft and not ent.isright then -- LEFT
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_RUN_R
			end
			if ent.wasbadlyhurt > 0 then
				ent.body.vx *= 0.1 -- cancel move! magik XXX
			else
				ent.flip = -1
				if ent.body.currdashtimer > 0 then 
					ent.body.vx -= ent.body.currspeed*ent.body.dashmultiplier
				else
					ent.body.vx = -ent.body.currspeed
				end
			end
		elseif ent.isright and not ent.isleft then -- RIGHT
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_RUN_R
			end
			if ent.wasbadlyhurt > 0 then
				ent.body.vx *= 0.1 -- cancel move! magik XXX
			else
				ent.flip = 1
				if ent.body.currdashtimer > 0 then 
					ent.body.vx += ent.body.currspeed*ent.body.dashmultiplier
				else
					ent.body.vx = ent.body.currspeed
				end
			end
		else
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_IDLE_R
			end
			if ent.wasbadlyhurt > 0 then
				ent.body.vx *= 0.1 -- cancel move! magik XXX
			else
				ent.body.vx *= 0.75 -- 0.8, 0.9, = 0
			end
			if (-ent.body.vx<>ent.body.vx) < 0.001 then ent.body.vx = 0 end
		end
		if ent.body.currinputbuffer > 0 and not ent.isdown and not ent.wasup then -- UP
			if ent.wasbadlyhurt > 0 then
				-- cannot jump
			else
				ent.body.vy = -ent.body.currupspeed
				ent.wasup = true
				ent.body.currjumpcount = ent.body.jumpcount
				ent.body.currinputbuffer = 0 -- prevents double jump when releasing up key
			end
--		elseif ent.isdown and not ent.isup then -- DOWN
		end
	-- IS ON LADDER
	elseif not ent.isfloorcontacts and
			ent.isladdercontacts and
			not ent.isptpfcontacts and
			not ent.ismvpfcontacts and
			not ent.iswallcontacts
			then
--		if ent.isplayer1 then print("isladdercontacts", dt) end
		if ent.isflyingnme then return end -- flying nmes don't collide with ladders
		if ent.isleft and not ent.isright then -- LEFT
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_RUN_R
			end
			if ent.wasbadlyhurt > 0 then
				ent.body.vx *= 0.1 -- cancel move! magik XXX
			else
				ent.flip = -1
				ent.body.vx = -ent.body.currspeed*0.5
			end
		elseif ent.isright and not ent.isleft then -- RIGHT
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_RUN_R
			end
			if ent.wasbadlyhurt > 0 then
				ent.body.vx *= 0.1 -- cancel move! magik XXX
			else
				ent.flip = 1
				ent.body.vx = ent.body.currspeed*0.5
			end
		else
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_IDLE_R
			end
			if ent.wasbadlyhurt > 0 then
				ent.body.vx *= 0.1 -- cancel move! magik XXX
			else
				ent.body.vx *= 0.75 -- 0.8, 0.9, = 0
			end
			if (-ent.body.vx<>ent.body.vx) < 0.001 then ent.body.vx = 0 end
		end
		if ent.isup and not ent.isdown then -- UP
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 or ent.currlives <= 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_RUN_R
			end
			if ent.wasbadlyhurt > 0 or ent.currlives <= 0 then
				-- cannot move
			else
				ent.body.vy = -ent.body.currupspeed*0.2 -- magik XXX
				ent.wasup = false -- allows jumping up off ladder
			end
		elseif ent.isdown and not ent.isup then -- DOWN
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 or ent.currlives <= 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_RUN_R
			end
			if ent.wasbadlyhurt > 0 or ent.currlives <= 0 then
				-- cannot move
			else
				ent.body.vy = ent.body.currupspeed*0.2 -- magik XXX
			end
		else
			if ent.wasbadlyhurt > 0 or ent.currlives <= 0 then
				ent.body.vy = ent.body.currupspeed -- fall off ladder
			else
				ent.body.vy = 0
			end
		end
		ent.wasonladder = true
	-- IS ON PTPF
	elseif not ent.isfloorcontacts and
			not ent.isladdercontacts and
			ent.isptpfcontacts and
			not ent.ismvpfcontacts and
			not ent.iswallcontacts
			then
--		if ent.isplayer1 then print("isptpfcontacts", dt) end
		if ent.isleft and not ent.isright then -- LEFT
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_RUN_R
			end
			if ent.wasbadlyhurt > 0 then
				ent.body.vx *= 0.1 -- cancel move! magik XXX
			else
				ent.flip = -1
				if ent.body.currdashtimer > 0 then 
					ent.body.vx -= ent.body.currspeed*ent.body.dashmultiplier
				else
					ent.body.vx = -ent.body.currspeed
				end
			end
		elseif ent.isright and not ent.isleft then -- RIGHT
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_RUN_R
			end
			if ent.wasbadlyhurt > 0 then
				ent.body.vx *= 0.1 -- cancel move! magik XXX
			else
				ent.flip = 1
				if ent.body.currdashtimer > 0 then 
					ent.body.vx += ent.body.currspeed*ent.body.dashmultiplier
				else
					ent.body.vx = ent.body.currspeed
				end
			end
		else
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_IDLE_R
			end
			if ent.wasbadlyhurt > 0 then
				ent.body.vx *= 0.1 -- cancel move! magik XXX
			else
				ent.body.vx *= 0.75 -- 0.8, 0.9, = 0
			end
			if (-ent.body.vx<>ent.body.vx) < 0.001 then ent.body.vx = 0 end
		end
		if ent.body.currinputbuffer > 0 and not ent.isdown and not ent.wasup then -- UP
			if ent.wasbadlyhurt > 0 then
				-- cannot jump
			else
				ent.body.vy = -ent.body.currupspeed
				ent.wasup = true
				ent.body.currinputbuffer = 0 -- prevents double jump when releasing up key
			end
		elseif ent.isdown and not ent.isup and not ent.wasdown then -- DOWN
			if ent.wasbadlyhurt > 0 then
				-- cannot jump down
			else
				ent.body.vy = ent.body.currupspeed*0.1
				ent.wasdown = true
			end
		end
	-- IS ON MVPF
	elseif not ent.isfloorcontacts and
			not ent.isladdercontacts and
			not ent.isptpfcontacts and
			ent.ismvpfcontacts and
			not ent.iswallcontacts
			then -- also controlled in collisions
--		if ent.isplayer1 then print("ismvpfcontacts", dt) end
		if ent.isleft and not ent.isright then -- LEFT
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_RUN_R
			end
			if ent.wasbadlyhurt > 0 then
				ent.body.vx *= 0.1 -- cancel move! magik XXX
			else
				ent.flip = -1
			end
		elseif ent.isright and not ent.isleft then -- RIGHT
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_RUN_R
			end
			if ent.wasbadlyhurt > 0 then
				ent.body.vx *= 0.1 -- cancel move! magik XXX
			else
				ent.flip = 1
			end
		else
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_IDLE_R
			end
		end
		if ent.body.currinputbuffer > 0 and not ent.isdown and not ent.wasup then -- UP
			if ent.wasbadlyhurt > 0 then
				-- cannot jump
			else
				ent.body.vy = -ent.body.currupspeed
				ent.wasup = true -- if set to true cannot jump!
				ent.body.currinputbuffer = 0 -- prevents double jump when releasing up key
			end
		elseif ent.isdown and not ent.isup and not ent.wasdown then -- DOWN
			if ent.wasbadlyhurt > 0 then
				-- cannot jump down
			else
				ent.body.vy = ent.body.currupspeed*0.1
				ent.wasdown = true
			end
		end
		ent.wasonmvpf = true
	-- IS ON WALL
	elseif not ent.isfloorcontacts and
			not ent.isladdercontacts and
			not ent.isptpfcontacts and
			not ent.ismvpfcontacts and
			ent.iswallcontacts
			then
--		if ent.isplayer1 then print("isonwall", dt) end
		if ent.isleft and not ent.isright then -- LEFT
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_WALL_IDLE_R
			end
			ent.flip = -1
			ent.body.vx = -ent.body.currspeed
		elseif ent.isright and not ent.isleft then -- RIGHT
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_WALL_IDLE_R
			end
			ent.flip = 1
			ent.body.vx = ent.body.currspeed
		else
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_WALL_DOWN_R
			end
			ent.body.vy = ent.body.currupspeed*0.25
		end
		if ent.isup and not ent.isdown then -- UP
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_WALL_UP_R
			end
			ent.body.vy = -ent.body.currupspeed*0.01
		elseif ent.isdown and not ent.isup then -- DOWN
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			else ent.animation.curranim = g_ANIM_WALL_DOWN_R
			end
			ent.body.vy = ent.body.currupspeed*0.05
		end
		ent.wasonwall = true
	-- IS ON SPRING
	elseif ent.isspringcontacts then
--		if ent.isplayer1 then print("isspringcontacts", dt) end
	-- IS IN THE AIR
	else
--		if ent.isplayer1 then print("isintheair", dt) end
		-- anims
		if ent.isplayer1 and ent.currlives > 0 then
			if ent.washurt > 0 or ent.wasbadlyhurt > 0 then -- animations in ent system
			elseif ent.body.vy < 0 then ent.animation.curranim = g_ANIM_JUMPUP_R -- going UP
			else ent.animation.curranim = g_ANIM_JUMPDOWN_R -- going DOWN
			end
		end
		-- movements
		if ent.isleft and not ent.isright then -- LEFT
			ent.flip = -1
			if ent.body.currdashtimer > 0 then 
				ent.body.vx -= ent.body.currspeed*ent.body.dashmultiplier
			else
				if ent.wasonwall then -- vx acceleration
					ent.body.vx = -ent.body.currspeed*1.5 -- 2, magik XXX
				else
					ent.body.vx = -ent.body.currspeed
				end
			end
		elseif ent.isright and not ent.isleft then -- RIGHT
			ent.flip = 1
			if ent.body.currdashtimer > 0 then 
				ent.body.vx += ent.body.currspeed*ent.body.dashmultiplier
			else
				if ent.wasonwall then -- vx acceleration
					ent.body.vx = ent.body.currspeed*1.5 -- 2, magik XXX
				else
					ent.body.vx = ent.body.currspeed
				end
			end
		else
			ent.body.vx *= 0.9 -- 0.99, [0, 1], GAMEPLAY, some air friction, you choose!
		end
		if ent.isup and not ent.isdown and not ent.wasup
			and ent.body.currcoyotetimer > 0 and ent.body.currjumpcount > 0 then -- UP
			ent.wasup = true -- you can comment this line, GAMEPLAY WALLS JUMPING
			ent.body.currcoyotetimer = 0
			ent.body.currjumpcount -= 1
			if ent.body.vy >= 0 then -- prevent double jump when fast pressing up!
				ent.body.vy = -ent.body.currupspeed
			end
			if ent.wasonladder then -- attenuate ent jumping off on top of ladder
				ent.body.vy *= 0.5
				ent.wasonladder = false
			end
		elseif ent.isdown and not ent.isup and not ent.wasdown then -- DOWN
			ent.wasdown = true -- ok
		end
	end
	-- move & flip
	ent.pos = vector(nextx, nexty)
	ent.sprite:setPosition(ent.pos + vector(ent.collbox.w/2, -ent.h/2+ent.collbox.h))
--	if ent.animation then
		ent.animation.bmp:setScale(ent.sx*ent.flip, ent.sy)
--	end
end
