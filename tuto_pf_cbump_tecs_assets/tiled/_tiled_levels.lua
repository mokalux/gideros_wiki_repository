TiledLevels = Core.class(Sprite)

function TiledLevels:init(tmpath, xtiny, xbworld, xlayers)
	local tm = require(tmpath) -- eg.: "tiled/test" without ".lua" extension + exclude from execution!
	local proto = false
	if tmpath:find("proto") then
		proto = true
	end
	-- some functions
	local function rgb2hex(r, g, b)
		return (r << 16) + (g << 8) + b
	end
	-- _______ _____ _      ______  _____ ______ _______ 
	--|__   __|_   _| |    |  ____|/ ____|  ____|__   __|
	--   | |    | | | |    | |__  | (___ | |__     | |   
	--   | |    | | | |    |  __|  \___ \|  __|    | |   
	--   | |   _| |_| |____| |____ ____) | |____   | |   
	--   |_|  |_____|______|______|_____/|______|  |_|   
	local dev = false -- true, false
	-- this is the classic: a tileset with a tilemap image
	local tsimgpath -- "tiled/", root path to tileset tilemap images
	if dev then -- in development
		tsimgpath = -- path to external folder
			"C:/X_MOKA/PROJECTS/_gideros/PROTOS/GAMES/PLATFORMERS/CBUMP_TECS/_assets/PLATFORMER_CBUMP_TECS_20250707/lvl001/gfx/"
	else -- prod
		if g_currlevel == 1 then tsimgpath = "tiled/lvl001/"
		elseif g_currlevel == 2 then tsimgpath = "tiled/lvl001/"
		elseif g_currlevel == 3 then tsimgpath = "tiled/lvl002/"
		end
	end
	for i = 1, #tm.tilesets do -- important
		local tileset = tm.tilesets[i]
		-- add extra values (variables) to a tm.tilesets[i] table
		if tileset.image then -- only tileset tilemap layers
			tileset.numcols = math.floor(
				(tileset.imagewidth-tileset.margin+tileset.spacing)/
				(tileset.tilewidth+tileset.spacing)
			)
			tileset.numrows = math.floor(
				(tileset.imageheight-tileset.margin+tileset.spacing)/
				(tileset.tileheight+tileset.spacing)
			)
			tileset.lastgid = tileset.firstgid+(tileset.numcols*tileset.numrows)-1
			if dev then -- dev
				tileset.texture = Texture.new(
					tsimgpath..tileset.image, false,
					{ transparentColor=tonumber(tileset.transparentcolor) }
				)
			else -- prod
				tileset.texture = Texture.new(
					tsimgpath..tileset.image, false,
					{ transparentColor=tonumber(tileset.transparentcolor) }
				)
			end
		end
	end
	-- tileset function
	local function gid2tileset(tm, gid)
		for i = 1, #tm.tilesets do
			local tileset = tm.tilesets[i]
			if tileset.image then -- only valid tileset layers
				if tileset.firstgid <= gid and gid <= tileset.lastgid then
					return tileset
				end
			end
		end
	end
	-- _______ _____ _      ______  _____ ______ _______ 
	--|__   __|_   _| |    |  ____|/ ____|  ____|__   __|
	--   | |    | | | |    | |__  | (___ | |__     | |   
	--   | |    | | | |    |  __|  \___ \|  __|    | |   
	--   | |   _| |_| |____| |____ ____) | |____   | |   
	--   |_|  |_____|______|______|_____/|______|  |_|   
	-- _____ __  __          _____ ______  _____ 
	--|_   _|  \/  |   /\   / ____|  ____|/ ____|
	--  | | | \  / |  /  \ | |  __| |__  | (___  
	--  | | | |\/| | / /\ \| | |_ |  __|  \___ \ 
	-- _| |_| |  | |/ ____ \ |__| | |____ ____) |
	--|_____|_|  |_/_/    \_\_____|______|_____/ 
	-- this one parses individual images stored in a tileset
	local tilesetimages = {} -- table holding all the tileset images info (path, width, height)
	for i = 1, #tm.tilesets do
		local tileset = tm.tilesets[i]
		if not tileset.image then -- filter out tileset tilemap layers, only tileset images
			local tiles = tileset.tiles
			for j = 1, #tiles do
				-- populate the tilesetimages table based on the tile gid and id
				-- note: you may have to adjust the path to point to the image folder
				tilesetimages[tileset.firstgid + tiles[j].id] = {
					path=tsimgpath..tiles[j].image,
					width=tiles[j].width,
					height=tiles[j].height,
				}
			end
		end
	end
	-- pack all the deco images (TexturePack), perfs? XXX
	local bgtpt = {} -- background texture pack table
	local bgtptx = {} -- background texture pack table x
	local fgtpt = {} -- foreground texture pack table
	local fgtptx = {} -- foreground texture pack table x
	for i = 1, #tm.layers do
		local layer = tm.layers[i]
		if layer.name:match("bg_deco_images") then
			if layer.name:match("x$") then -- x$ = string ends with x
				for i = 1, #layer.objects do
					if layer.objects[i].gid then -- if no gid then this is not an image, skip it!
--						print("bg", tilesetimages[layer.objects[i].gid].path)
						bgtptx[#bgtptx+1] = tilesetimages[layer.objects[i].gid].path
					end
				end
			else
				for i = 1, #layer.objects do
					if layer.objects[i].gid then -- if no gid then this is not an image, skip it!
--						print("bg", tilesetimages[layer.objects[i].gid].path)
						bgtpt[#bgtpt+1] = tilesetimages[layer.objects[i].gid].path
					end
				end
			end
		elseif layer.name:match("fg_deco_images") then
			if layer.name:match("x$") then -- x$ = string ends with x
				for i = 1, #layer.objects do
					if layer.objects[i].gid then -- if no gid then this is not an image, skip it!
--						print("fg", tilesetimages[layer.objects[i].gid].path)
						fgtptx[#fgtptx+1] = tilesetimages[layer.objects[i].gid].path
					end
				end
			else
				for i = 1, #layer.objects do
					if layer.objects[i].gid then -- if no gid then this is not an image, skip it!
--						print("fg", tilesetimages[layer.objects[i].gid].path)
						fgtpt[#fgtpt+1] = tilesetimages[layer.objects[i].gid].path
					end
				end
			end
		end
	end
	local bgtp = TexturePack.new(bgtpt, nil, nil, { format=TextureBase.RGBA4444, } ) -- perfs
	local bgtpx = TexturePack.new(bgtptx, nil, nil, { format=TextureBase.RGBA4444, } ) -- perfs
	local fgtp = TexturePack.new(fgtpt, nil, nil, { format=TextureBase.RGBA4444, } ) -- perfs
	local fgtpx = TexturePack.new(fgtptx, nil, nil, { format=TextureBase.RGBA4444, } ) -- perfs
	if #bgtp:getRegionsNames() > 0 then print("bgtp", bgtp:getSize()) end
	if #bgtpx:getRegionsNames() > 0 then print("bgtpx", bgtpx:getSize()) end
	if #fgtp:getRegionsNames() > 0 then print("fgtp", fgtp:getSize()) end
	if #fgtpx:getRegionsNames() > 0 then print("fgtpx", fgtpx:getSize()) end
	-- tileset images function
	local function parseImage(xobject, xlayer, xtplayer, xtexpack)
		local bitmap
		if xtplayer == "bg" then
			if xtexpack == "x" then
				bitmap = Bitmap.new(bgtpx:getTextureRegion(tilesetimages[xobject.gid].path))
			else
				bitmap = Bitmap.new(bgtp:getTextureRegion(tilesetimages[xobject.gid].path))
			end
		else -- fg
			if xtexpack == "x" then
				bitmap = Bitmap.new(fgtpx:getTextureRegion(tilesetimages[xobject.gid].path))
			else
				bitmap = Bitmap.new(fgtp:getTextureRegion(tilesetimages[xobject.gid].path))
			end
		end
		bitmap:setAnchorPoint(0, 1) -- because I always forget to modify Tiled objects alignment
		-- supports Tiled image scaling
		local scalex, scaley = xobject.width/bitmap:getWidth(), xobject.height/bitmap:getHeight()
		bitmap:setScale(scalex, scaley)
		bitmap:setRotation(xobject.rotation)
		bitmap:setPosition(xobject.x, xobject.y)
		xlayer:addChild(bitmap)
	end
	-- ____  _    _ _____ _      _____    _      ________      ________ _      
	--|  _ \| |  | |_   _| |    |  __ \  | |    |  ____\ \    / /  ____| |     
	--| |_) | |  | | | | | |    | |  | | | |    | |__   \ \  / /| |__  | |     
	--|  _ <| |  | | | | | |    | |  | | | |    |  __|   \ \/ / |  __| | |     
	--| |_) | |__| |_| |_| |____| |__| | | |____| |____   \  /  | |____| |____ 
	--|____/ \____/|_____|______|_____/  |______|______|   \/   |______|______|
	for i = 1, #tm.layers do
		local layer = tm.layers[i]
		local tilemaps = {}
		local group -- group = Sprite.new()
		-- _______ _____ _      ______ _           __     ________ _____  
		--|__   __|_   _| |    |  ____| |        /\\ \   / /  ____|  __ \ 
		--   | |    | | | |    | |__  | |       /  \\ \_/ /| |__  | |__) |
		--   | |    | | | |    |  __| | |      / /\ \\   / |  __| |  _  / 
		--   | |   _| |_| |____| |____| |____ / ____ \| |  | |____| | \ \ 
		--   |_|  |_____|______|______|______/_/    \_\_|  |______|_|  \_\
		if layer.type == "tilelayer" and (layer.name:match("bg") or layer.name:match("fg")) then
			if layer.name:match("bg") then group = xlayers["bg"]
			else group = xlayers["fg"]
			end
			for y = 1, layer.height do
				for x = 1, layer.width do
					local index = x + (y - 1) * layer.width
					local gid = layer.data[index]
					local gidtileset = gid2tileset(tm, gid)
					if gidtileset then
						local tilemap
						if tilemaps[gidtileset] then
							tilemap = tilemaps[gidtileset]
						else
							tilemap = TileMap.new(
								layer.width, layer.height,
								gidtileset.texture, gidtileset.tilewidth, gidtileset.tileheight,
								gidtileset.spacing, gidtileset.spacing,
								gidtileset.margin, gidtileset.margin,
								tm.tilewidth, tm.tileheight
							)
							tilemaps[gidtileset] = tilemap
							group:addChild(tilemap)
						end
						local tx = (gid - gidtileset.firstgid) % gidtileset.numcols + 1
						local ty = math.floor((gid - gidtileset.firstgid) / gidtileset.numcols) + 1
						-- set the tile with flip info
						tilemap:setTile(x, y, tx, ty)
					end
				end
			end
			group:setAlpha(layer.opacity)
		--  ____  ____       _ ______ _____ _______ _           __     ________ _____  
		-- / __ \|  _ \     | |  ____/ ____|__   __| |        /\\ \   / /  ____|  __ \ 
		--| |  | | |_) |    | | |__ | |       | |  | |       /  \\ \_/ /| |__  | |__) |
		--| |  | |  _ < _   | |  __|| |       | |  | |      / /\ \\   / |  __| |  _  / 
		--| |__| | |_) | |__| | |___| |____   | |  | |____ / ____ \| |  | |____| | \ \ 
		-- \____/|____/ \____/|______\_____|  |_|  |______/_/    \_\_|  |______|_|  \_\
		elseif layer.type == "objectgroup" then
			local o
			local myshape, mytable
			--                             _       __ _       _ _   _             
			--                            | |     / _(_)     (_) | (_)            
			-- _ __ ___   __ _ _ __     __| | ___| |_ _ _ __  _| |_ _  ___  _ __  
			--| '_ ` _ \ / _` | '_ \   / _` |/ _ \  _| | '_ \| | __| |/ _ \| '_ \ 
			--| | | | | | (_| | |_) | | (_| |  __/ | | | | | | | |_| | (_) | | | |
			--|_| |_| |_|\__,_| .__/   \__,_|\___|_| |_|_| |_|_|\__|_|\___/|_| |_|
			--                | |                                                 
			--                |_|                                                 
			if layer.name == "physics_map_def" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					self.mapdef = {}
					self.mapdef.t = o.y
					self.mapdef.l = o.x
					self.mapdef.r = o.width
					self.mapdef.b = o.height
				end
			--     _                  _                           
			--    | |                | |                          
			--  __| | ___  ___ ___   | | __ _ _   _  ___ _ __ ___ 
			-- / _` |/ _ \/ __/ _ \  | |/ _` | | | |/ _ \ '__/ __|
			--| (_| |  __/ (_| (_) | | | (_| | |_| |  __/ |  \__ \
			-- \__,_|\___|\___\___/  |_|\__,_|\__, |\___|_|  |___/
			--                                 __/ |              
			--                                |___/               
			elseif layer.name == "bg_deco_texts" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					mytable = {
						color=rgb2hex(table.unpack(o.color or { 255, 255, 255 } )),
					}
					myshape = self:buildShapes(o, mytable)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
				end
			elseif layer.name:match("bg_deco_shapes") then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local texpath
					local color = rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } )) -- math.random(0xffffff)
					local r, g, b
					if o.name == "hint" then
						color = 0xffffff
					elseif o.name == "lava" then
						texpath = "gfx/textures/Water_01_Grey_1.png"
						color = nil
						r, g, b = 124, 205, 70
					elseif o.name == "spikes" then
						color = 0xff5500
					end
					mytable = {
						texpath=texpath, istexpot=true, scalex=0.4,
						color=color, r=r, g=g, b=b,
					}
					myshape = self:buildShapes(o, mytable)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
				end
			elseif layer.name:match("bg_deco_images") then
				--parseImage(xobject, xlayer, xtplayer, xtexpack)
				for i = 1, #layer.objects do
					if layer.name:match("x$") then
						parseImage(layer.objects[i], xlayers["bg"], "bg", "x")
					else
						parseImage(layer.objects[i], xlayers["bg"], "bg", nil)
					end
				end
			elseif layer.name == "fg_deco_texts" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					mytable = {
						color=rgb2hex(table.unpack(o.color or { 255, 255, 255 } )),
					}
					myshape = self:buildShapes(o, mytable)
					myshape:setPosition(o.x, o.y)
					xlayers["fg"]:addChild(myshape)
				end
			elseif layer.name:match("fg_deco_shapes") then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					mytable = {
						color=rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } )),
					}
					myshape = self:buildShapes(o, mytable)
					myshape:setPosition(o.x, o.y)
					xlayers["fg"]:addChild(myshape)
				end
			elseif layer.name:match("fg_deco_images") then
				for i = 1, #layer.objects do
					if layer.name:match("x$") then
						if layer.objects[i].gid then -- if no gid then this is not an image, skip it!
							parseImage(layer.objects[i], xlayers["fg"], "fg", "x")
						end
					else
						if layer.objects[i].gid then -- if no gid then this is not an image, skip it!
							parseImage(layer.objects[i], xlayers["fg"], "fg", nil)
						end
					end
				end
			--       _               _            _                           
			--      | |             (_)          | |                          
			-- _ __ | |__  _   _ ___ _  ___ ___  | | __ _ _   _  ___ _ __ ___ 
			--| '_ \| '_ \| | | / __| |/ __/ __| | |/ _` | | | |/ _ \ '__/ __|
			--| |_) | | | | |_| \__ \ | (__\__ \ | | (_| | |_| |  __/ |  \__ \
			--| .__/|_| |_|\__, |___/_|\___|___/ |_|\__,_|\__, |\___|_|  |___/
			--| |           __/ |                          __/ |              
			--|_|          |___/                          |___/               
			--                    _     _ 
			--                   | |   | |
			--__      _____  _ __| | __| |
			--\ \ /\ / / _ \| '__| |/ _` |
			-- \ V  V / (_) | |  | | (_| |
			--  \_/\_/ \___/|_|  |_|\__,_|
			elseif layer.name == "physics_exits" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					if proto then
						mytable = {
							color=rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } )),
						}
						myshape = self:buildShapes(o, mytable)
						myshape:setPosition(o.x, o.y)
						xlayers["bg"]:addChild(myshape)
					end
					o.isexit = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_voids" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					if proto then
						mytable = {
							color=rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } )),
						}
						myshape = self:buildShapes(o, mytable)
						myshape:setPosition(o.x, o.y)
						xlayers["bg"]:addChild(myshape)
					end
					o.isvoid = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_spikes" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					if proto then
						mytable = {
							color=rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } )),
						}
						myshape = self:buildShapes(o, mytable)
						myshape:setPosition(o.x, o.y)
						xlayers["bg"]:addChild(myshape)
					end
					o.isspike = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_springs" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local vx, vy
					local index
					index = o.name:find("vx") -- index vx
					vx = tonumber(o.name:sub(index):match("%d+")) -- find vxNNN
					index = o.name:find("vy") -- index vy
					vy = tonumber(o.name:sub(index):match("%d+")) -- find vyNNN
					if proto then
						mytable = {
							color=rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } )),
						}
						myshape = self:buildShapes(o, mytable)
						myshape:setPosition(o.x, o.y)
						xlayers["bg"]:addChild(myshape)
					end
					o.isspring = true
					o.vx = vx*64 -- some multiplier, magik XXX
					o.vy = vy*64 -- some multiplier, magik XXX
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_sensors" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local xid = o.name -- examples: "mvgrAA", ...
					local opos = vector(o.x, o.y)
					if proto then
						mytable = {
							color=rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } )),
							alpha=0.25,
						}
						myshape = self:buildShapes(o, mytable)
						myshape:setPosition(o.x, o.y)
						xlayers["bg"]:addChild(myshape)
					end
					--ESensor:init(xid, xspritelayer, xpos, w, h, xlayers["bgfx"])
					local e = ESensor.new(
						xid, xlayers["actors"], opos, o.width, o.height, xlayers["bgfx"]
					)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
					-- some cleaning?
					e = nil
				end
			elseif layer.name:match("physics_doors") then -- doors = doorAAdx0dy8vel10dirU
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local xpos = vector(o.x, o.y)
					local dx, dy, vel, xdir
					local index
					index = o.name:find("dx") -- index dx
					local xid = o.name:sub(1, index-1) -- examples: "doorAA", "doorBB", ...
					dx = tonumber(o.name:sub(index):match("%d+")) -- find dxNNN
					index = o.name:find("dy") -- index dy
					dy = tonumber(o.name:sub(index):match("%d+")) -- find dyNNN
					index = o.name:find("vel") -- index vel
					vel = tonumber(o.name:sub(index):match("%d+")) -- find velNN
					index = o.name:find("dir") -- index dir
					xdir = o.name:sub(index+3) -- initial heading direction, examples: "U", "DR", "UL", ...
					local angle = math.atan2(dy, dx)
					local xspeed = vector(vel*math.cos(angle), vel*math.sin(angle))*vector(8, 8)
					local xtexpath
					local xcolor
					if proto then
						xcolor = rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } ))
					else
						xtexpath = "gfx/textures/Concrete_01_Grey_1.png"
						xcolor = 0xa76f53 -- plus a tint color
					end
					--EDoor:init(xid, xspritelayer, xpos, xtexpath, xcolor, w, h, dx, dy, xdir, xspeed, xbgfxlayer)
					local e = EDoor.new(
						xid, xlayers["actors"], xpos, xtexpath, xcolor, o.width, o.height,
						dx, dy, xdir, xspeed, xlayers["bgfx"]
					)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
					e.sprite:setPosition(e.pos + vector(e.collbox.w/2, -e.h/2+e.collbox.h))
					-- some cleaning?
					e = nil
				end
			elseif layer.name:match("physics_ptmvpfs") then -- passthrough moving platform
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local vpos = vector(o.x, o.y)
					local dx, dy, vel, xdir
					local index
					index = o.name:find("dx") -- index dx
					local xid = o.name:sub(1, index-1) -- examples: "idAA", "idBB", ...
					dx = tonumber(o.name:sub(index):match("%d+")) -- find dxNNN
					index = o.name:find("dy") -- index dy
					dy = tonumber(o.name:sub(index):match("%d+")) -- find dyNNN
					index = o.name:find("vel") -- index vel
					vel = tonumber(o.name:sub(index):match("%d+"))*8 -- find velNNN
					index = o.name:find("dir") -- index dir
					xdir = o.name:sub(index+3) -- initial heading direction, examples: "U", "DR", "UL", ...
					local angle = math.atan2(dy, dx)
					local vspeed = vector(vel*math.cos(angle), vel*math.sin(angle))
					local xtexpath
					local xcolor
					if proto then
						xcolor = rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } ))
					else
						xtexpath = "gfx/textures/wdipagu_2K_Albedo.jpg_0008.png"
						xcolor = 0xffaa7f -- plus a tint color
					end
					--EMvpf:init(xid, xspritelayer, xpos, xtexpath, xcolor, w, h, dx, dy, xdir, xspeed, xbgfxlayer)
					local e = EMvpf.new(
						xid, xlayers["actors"], vpos, xtexpath, xcolor, o.width, o.height,
						dx, dy, xdir, vspeed, true, xlayers["bgfx"]
					)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
					e.sprite:setPosition(e.pos + vector(e.collbox.w/2, -e.h/2+e.collbox.h))
					-- some cleaning?
					e = nil
				end
			elseif layer.name:match("physics_mvpfs") then -- non passthrough moving platform
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local vpos = vector(o.x, o.y)
					local dx, dy, vel, xdir
					local index
					index = o.name:find("dx") -- index dx
					local xid = o.name:sub(1, index-1) -- examples: "idAA", "idBB", ...
					dx = tonumber(o.name:sub(index):match("%d+")) -- find dxNNN
					index = o.name:find("dy") -- index dy
					dy = tonumber(o.name:sub(index):match("%d+")) -- find dyNNN
					index = o.name:find("vel") -- index vel
					vel = tonumber(o.name:sub(index):match("%d+"))*8 -- find velNNN
					index = o.name:find("dir") -- index dir
					xdir = o.name:sub(index+3) -- initial heading direction, examples: "N", "SE", "NW", ...
					local angle = math.atan2(dy, dx)
					local vspeed = vector(vel*math.cos(angle), vel*math.sin(angle))
					local xtexpath
					local xcolor
					if proto then
						xcolor = rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } ))
					else
						xtexpath = "gfx/textures/wdipagu_2K_Albedo.jpg_0008.png"
						xcolor = 0xffaa7f -- plus a tint color
					end
					--EMvpf:init(xid, xspritelayer, xpos, xtexpath, xcolor, w, h, dx, dy, xdir, xspeed, xbgfxlayer)
					local e = EMvpf.new(
						xid, xlayers["actors"], vpos, xtexpath, xcolor, o.width, o.height,
						dx, dy, xdir, vspeed, nil, xlayers["bgfx"]
					)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
					e.sprite:setPosition(e.pos + vector(e.collbox.w/2, -e.h/2+e.collbox.h))
					-- some cleaning?
					e = nil
				end
			elseif layer.name == "physics_ladders" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					if proto then
						mytable = {
							color=rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } )),
							alpha=0.5,
						}
						myshape = self:buildShapes(o, mytable)
						myshape:setPosition(o.x, o.y)
						xlayers["bg"]:addChild(myshape)
					end
					o.isladder = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_walls" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local texpath
					local color
					local r, g, b
					if proto then
						color = rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } ))
					else
						texpath = "gfx/textures/Rock_Grey_02.png"
						r, g, b =139, 56, 28
					end
					mytable = {
						texpath=texpath, istexpot=true, scalex=0.5,
						color=color,
						r=r, g=g, b=b,
					}
					myshape = self:buildShapes(o, mytable)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
					o.iswall = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_steps" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					if proto then
						mytable = {
							color=rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } )),
						}
						myshape = self:buildShapes(o, mytable)
						myshape:setPosition(o.x, o.y)
						xlayers["bg"]:addChild(myshape)
					end
					o.isstep = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_ptpfs" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.pos = vector(o.x, o.y)
					local texpath
					local color
					local r, g, b
					if proto then
						color = rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } ))
					else
						if o.name == "t" then
							-- use "t" as the object name to make it "transparent"
						else
							texpath = "gfx/textures/1K-brick_wall_17_baseColor.jpg_0001.png"
							r, g, b = 139, 56, 28 -- plus a tint color
						end
					end
					mytable = {
						texpath=texpath, istexpot=true, scalex=0.5,
						color=color,
						r=r, g=g, b=b,
					}
					myshape = self:buildShapes(o, mytable)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
					o.isptpf = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_grounds" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local texpath
					local color
					local r, g, b
					if proto then
						color = rgb2hex(table.unpack(layer.tintcolor or { 255, 255, 255 } ))
					else
						if o.name == "t" then -- transparent
							-- use "t" as the object name to make it "transparent"
						else
							texpath = "gfx/textures/wdipagu_2K_Albedo.jpg_0008.png"
							r, g, b = 255, 192, 160 -- plus a tint color
						end
					end
					mytable = {
						texpath=texpath, istexpot=true, scalex=1, skewx=3,
						color=color,
						r=r, g=g, b=b,
					}
					myshape = self:buildShapes(o, mytable)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
					o.isfloor = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			--           _ _           _   _ _     _           
			--          | | |         | | (_) |   | |          
			--  ___ ___ | | | ___  ___| |_ _| |__ | | ___  ___ 
			-- / __/ _ \| | |/ _ \/ __| __| | '_ \| |/ _ \/ __|
			--| (_| (_) | | |  __/ (__| |_| | |_) | |  __/\__ \
			-- \___\___/|_|_|\___|\___|\__|_|_.__/|_|\___||___/
			elseif layer.name == "physics_keys" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local xid = o.name -- example "doorAA", "mvpfBB", ...
					xid = "key"..tostring(xid) -- we append the keyword key to tell it is a key XXX
					local opos = vector(o.x, o.y)
					--ECollectibles:init(xid, xspritelayer, xpos, xspeed, xdx, xdy)
					local e = ECollectibles.new(xid, xlayers["actors"], opos, 1*8, 5*8, 4*8)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_coins" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local xid = layer.name:gsub("physics_", "")
					--ECollectibles:init(xid, xspritelayer, xpos, xspeed, xdx, xdy)
					local e = ECollectibles.new(xid, xlayers["actors"], opos, 1*8, 4*8, 4*8)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_lives" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local xid = layer.name:gsub("physics_", "")
					--ECollectibles:init(xid, xspritelayer, xpos, xspeed, xdx, xdy)
					local e = ECollectibles.new(xid, xlayers["actors"], opos, 1*8, 5*8, 4*8)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			--            _                 
			--           | |                
			--  __ _  ___| |_ ___  _ __ ___ 
			-- / _` |/ __| __/ _ \| '__/ __|
			--| (_| | (__| || (_) | |  \__ \
			-- \__,_|\___|\__\___/|_|  |___/
			elseif layer.name == "physics_ground_nmes03" then -- nmes
				-- 300: no move, no jump, shoot all angles
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local collectible = o.name
					if collectible == "" then collectible = "coins" -- default to coins
					elseif collectible == "x" then collectible = nil
					end
					--EGroundNmes:init(xid, xspritelayer, xpos, xlayers, xcollectible)
					local e = EGroundNmes.new(300, xlayers["actors"], opos, xlayers["bgfx"], collectible)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_ground_nmes02" then -- nmes
				-- 200: move, jump, no shoot
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local collectible = o.name
					if collectible == "" then collectible = "coins" -- default to coins
					elseif collectible == "x" then collectible = nil
					end
					--EGroundNmes:init(xid, xspritelayer, xpos, xlayers, xcollectible)
					local e = EGroundNmes.new(200, xlayers["actors"], opos, xlayers["bgfx"], collectible)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_ground_nmes" then
				-- 100: no move, no jump, no shoot
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local collectible = o.name
					if collectible == "" then collectible = nil -- default to coins
					elseif collectible == "x" then collectible = nil
					end
					--EGroundNmes:init(xid, xspritelayer, xpos, xlayers, xcollectible)
					local e = EGroundNmes.new(100, xlayers["actors"], opos, xlayers["bgfx"], collectible)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_players" then -- player1
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					-- EPlayer1:init(xspritelayer, xpos, xbgfxlayer)
					self.player1 = EPlayer1.new(xlayers["actors"], opos, xlayers["bgfx"])
					xtiny.tworld:addEntity(self.player1)
					xbworld:add(
						self.player1,
						self.player1.pos.x, self.player1.pos.y,
						self.player1.collbox.w, self.player1.collbox.h
					)
				end
			end
			-- some cleaning?
			o = nil
			myshape, mytable = nil, nil
		end
	end
end

function TiledLevels:buildShapes(xobject, xlevelsetup)
	local myshape -- Tiled shapes: ellipse, point, polygon, polyline, rectangle, text
	local tablebase = {}
	if xobject.shape == "ellipse" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			w=xobject.width, h=xobject.height,
			rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Ellipse.new(tablebase)
	elseif xobject.shape == "point" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Point.new(tablebase)
	elseif xobject.shape == "polygon" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			coords=xobject.polygon,
			rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Polygon.new(tablebase)
	elseif xobject.shape == "polyline" then -- lines
		tablebase = {
			x=xobject.x, y=xobject.y,
			coords=xobject.polyline,
			rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Polyline.new(tablebase)
	elseif xobject.shape == "rectangle" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			w=xobject.width, h=xobject.height,
			rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Rectangle.new(tablebase)
	elseif xobject.shape == "text" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			text=xobject.text,
			w=xobject.width, h=xobject.height,
			rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Text.new(tablebase)
	else
		print("*** CANNOT PROCESS THIS SHAPE! ***", xobject.shape, xobject.name)
		return
	end

	return myshape
end
