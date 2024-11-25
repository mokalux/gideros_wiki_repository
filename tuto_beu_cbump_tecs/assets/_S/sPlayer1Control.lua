SPlayer1Control = Core.class()

function SPlayer1Control:init(xtiny, xplayer1inputlayer) -- tiny function
	xtiny.system(self) -- called only once on init (no update)
	self.player1inputlayer = xplayer1inputlayer
end

function SPlayer1Control:filter(ent) -- tiny function
	return ent.isplayer1
end

function SPlayer1Control:onAdd(ent) -- tiny function
	self.player1inputlayer:addEventListener(Event.KEY_DOWN, function(e)
		if ent.currlives > 0 then
			if e.keyCode == KeyCode.LEFT or e.keyCode == g_keyleft then ent.isleft = true end
			if e.keyCode == KeyCode.RIGHT or e.keyCode == g_keyright then ent.isright = true end
			if e.keyCode == KeyCode.UP or e.keyCode == g_keyup then ent.isup = true end
			if e.keyCode == KeyCode.DOWN or e.keyCode == g_keydown then ent.isdown = true end
			-- ACTIONS:
			-- isactionpunch1, isactionpunch2, isactionjumppunch1,
			-- isactionkick1, isactionkick2, isactionjumpkick1,
			-- isactionjump1
			if e.keyCode == g_keyaction1 then
				ent.animation.frame = 0
				ent.isactionpunch1 = true
			elseif e.keyCode == g_keyaction2 then
				ent.animation.frame = 0
				ent.isactionkick1 = true
			end
			if e.keyCode == g_keyaction3 then
				if ent.body.isonfloor then
					ent.animation.frame = 0
					ent.positionystart = ent.pos.y
					ent.body.isonfloor = false
					ent.body.isgoingup = true
					ent.isactionjump1 = true
				end
			end
		end
	end)
	self.player1inputlayer:addEventListener(Event.KEY_UP, function(e)
		if ent.currlives > 0 then
			if e.keyCode == KeyCode.LEFT or e.keyCode == g_keyleft then ent.isleft = false end
			if e.keyCode == KeyCode.RIGHT or e.keyCode == g_keyright then ent.isright = false end
			if e.keyCode == KeyCode.UP or e.keyCode == g_keyup then ent.isup = false end
			if e.keyCode == KeyCode.DOWN or e.keyCode == g_keydown then ent.isdown = false end
--			if e.keyCode == g_keyaction1 then ent.isactionpunch1 = false end
--			if e.keyCode == g_keyaction2 then ent.isactionkick1 = false end
--			if e.keyCode == g_keyaction3 then end
		end
	end)
end
