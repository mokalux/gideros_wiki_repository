SAnimation = Core.class()

function SAnimation:init(xtiny)
	xtiny.processingSystem(self) -- called once on init and every frames
	self.sndstepgrass = Sound.new("audio/sfx/footstep/Grass02.wav")
	self.channel = self.sndstepgrass:play(0, false, true)
end

function SAnimation:filter(ent) -- tiny function
	return ent.animation
end

function SAnimation:onAdd(ent) -- tiny function
end

function SAnimation:onRemove(ent) -- tiny function
	ent.animation = nil -- free some memory?
end

local checkanim
function SAnimation:process(ent, dt) -- tiny function
	-- a little boost?
	local anim = ent.animation

--	checkanim = anim.curranim -- if you are sure all animations are set else use below ternary operator code
	-- luau ternary operator (no end at the end), it's a 1 liner and seems fast?
	checkanim = if anim.anims[ent.animation.curranim] then anim.curranim else g_ANIM_DEFAULT
--	print(#anim.anims[checkanim])

	if not ent.doanimate then return end

	anim.animtimer -= dt
	if anim.animtimer < 0 then
		anim.frame += 1
		anim.animtimer = anim.animspeed
		if checkanim == g_ANIM_DEFAULT then
			if anim.frame > #anim.anims[checkanim] then
				anim.frame = 1
			end
		elseif checkanim == g_ANIM_LOSE1_R or checkanim == g_ANIM_STANDUP_R then
			if anim.frame >= #anim.anims[checkanim] then
				anim.frame = #anim.anims[checkanim]
			end
		elseif checkanim == g_ANIM_PUNCH_ATTACK1_R then
			ent.headhitbox = ent.headhitboxattack1
			if #anim.anims[checkanim] == 1 then -- 1 frame animation
				anim.frame = 1
				ent.headhitboxattack1.isactive = true
				ent.isactionpunch1 = false
			else -- multi frames animation
				if anim.frame > #anim.anims[checkanim] then
--					anim.frame = 1
					anim.frame = #anim.anims[checkanim]
					ent.headhitboxattack1.isactive = false
					ent.isactionpunch1 = false
				elseif anim.frame > ent.headhitbox.hitendframe then
					ent.headhitboxattack1.isactive = false
				elseif anim.frame >= ent.headhitbox.hitstartframe then
					ent.headhitboxattack1.isactive = true
				end
			end
		elseif checkanim == g_ANIM_PUNCH_ATTACK2_R then
			ent.headhitbox = ent.headhitboxattack2
			if anim.frame > #anim.anims[checkanim] then
--				anim.frame = 1
				anim.frame = #anim.anims[checkanim]
				ent.headhitboxattack2.isactive = false
				ent.isactionpunch2 = false
			elseif anim.frame > ent.headhitbox.hitendframe then
				ent.headhitboxattack2.isactive = false
			elseif anim.frame >= ent.headhitbox.hitstartframe then
				ent.headhitboxattack2.isactive = true
			end
		elseif checkanim == g_ANIM_KICK_ATTACK1_R then
			ent.spinehitbox = ent.spinehitboxattack1
			if #anim.anims[checkanim] == 1 then -- 1 frame animation
				anim.frame = 1
				ent.spinehitboxattack1.isactive = true
				ent.isactionkick1 = false
			else -- multi frames animation
				if anim.frame > #anim.anims[checkanim] then
--					anim.frame = 1
					anim.frame = #anim.anims[checkanim]
					ent.spinehitboxattack1.isactive = false
					ent.isactionkick1 = false
				elseif anim.frame > ent.spinehitbox.hitendframe then
					ent.spinehitboxattack1.isactive = false
				elseif anim.frame >= ent.spinehitbox.hitstartframe then
					ent.spinehitboxattack1.isactive = true
				end
			end
		elseif checkanim == g_ANIM_KICK_ATTACK2_R then
			ent.spinehitbox = ent.spinehitboxattack2
			if anim.frame > #anim.anims[checkanim] then
--				anim.frame = 1
				anim.frame = #anim.anims[checkanim]
				ent.spinehitboxattack2.isactive = false
				ent.isactionkick2 = false
			elseif anim.frame > ent.spinehitbox.hitendframe then
				ent.spinehitboxattack2.isactive = false
			elseif anim.frame >= ent.spinehitbox.hitstartframe then
				ent.spinehitboxattack2.isactive = true
			end
		elseif checkanim == g_ANIM_JUMP1_R then -- only jump, no attacks
			if anim.frame > #anim.anims[checkanim] then
				anim.frame = #anim.anims[checkanim]
			end
		elseif checkanim == g_ANIM_PUNCHJUMP_ATTACK1_R then
			ent.headhitbox = ent.headhitboxjattack1
			if anim.frame > #anim.anims[checkanim] then
				anim.frame = #anim.anims[checkanim]
				ent.headhitboxjattack1.isactive = false
--				ent.isactionjumppunch1 = false -- don't set to false here otherwise BUGGGZZZZ!!!
			else
				ent.headhitboxjattack1.isactive = true
			end
		elseif checkanim == g_ANIM_KICKJUMP_ATTACK1_R then
			ent.spinehitbox = ent.spinehitboxjattack1
			if anim.frame > #anim.anims[checkanim] then
				anim.frame = #anim.anims[checkanim]
				ent.spinehitboxjattack1.isactive = false
--				ent.isactionjumpkick1 = false -- don't set to false here otherwise BUGGGZZZZ!!!
			else
				ent.spinehitboxjattack1.isactive = true
			end
		else
			-- player1 steps sound fx
			if ent.isplayer1 and
				(anim.curranim == g_ANIM_WALK_R or anim.curranim == g_ANIM_RUN_R) and
				(anim.frame == 4 or anim.frame == 9) then
				self.channel = self.sndstepgrass:play()
				if self.channel then self.channel:setVolume(g_sfxvolume*0.01) end
			end
			-- loop animations
			if anim.frame > #anim.anims[checkanim] then
				anim.frame = 1
			end
		end
		anim.bmp:setTextureRegion(anim.anims[checkanim][anim.frame])
	end
end
