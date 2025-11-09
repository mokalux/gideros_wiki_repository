--[[
* TextField TypeWriter Effect *
-- based on the work of @pie, @koeosstudio, @hgy29, mixed by @mokalux ;-)
-- function TypeWriter:init(font, text, speed, char)
---- font: Font
---- text: string
---- speed: number (millisecond)
---- char: the number of characters to display at a time, default = 1
-- return event:
---- "finished", data: speed, char
]]

TypeWriter = Core.class(TextField)

function TypeWriter:init(font, text, delay, char)
	self:setVisible(false) -- start invisible
	local i = 0
	local in_str = text
	local str_length = utf8.len(in_str)
	local typeSpeedTimer = Timer.new(delay or 100, str_length)
	char = char or 1

	local function getString()
		if i <= str_length then
			i += char -- number of characters to add each time
			local out_str = utf8.sub(in_str, 1, i)
			self:setText(out_str)
			self:setVisible(true)
		else
			local ev = Event.new("finished")
			ev.delay = delay
			ev.char = char
			self:dispatchEvent(ev)
		end
	end
	typeSpeedTimer:addEventListener(Event.TIMER, getString)
	typeSpeedTimer:start()
end
