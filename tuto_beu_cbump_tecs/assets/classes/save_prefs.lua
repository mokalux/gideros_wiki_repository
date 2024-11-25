require "json"

function saveData(filepath, value)
	local contents = json.encode(value)
	local file = io.open(filepath, "w") -- create file
	file:write(contents) -- save json string in file
	io.close(file)
end

function getData(filepath)
	local value
	local file = io.open(filepath, "r")
	if file then
		local contents = file:read("*a") -- read contents
		value = json.decode(contents) -- decode json
		io.close(file)
	end
	return value
end

--[[
--try to read information
local someData = getData("someData")

if not someData then -- if no information, create it
	someData = {"some text", 42}
	saveData("someData.txt", someData)
	print("Created someData")
else
	print("Read someData", someData[1], someData[2])
end
]]
