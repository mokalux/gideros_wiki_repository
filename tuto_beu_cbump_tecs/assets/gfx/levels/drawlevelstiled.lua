DrawLevelsTiled = Core.class(Sprite)

function DrawLevelsTiled:init(xlayer, xtexpaths, xposy)
	-- tilemaps textures
	local textures = {}
	for i = 1, #xtexpaths do
--		textures[i] = Texture.new(xtexpaths[i])
--		textures[i] = Texture.new(xtexpaths[i], false, { format=TextureBase.YA8}) -- best win32 perfs but b&w!
		textures[i] = Texture.new(xtexpaths[i], false, { format=TextureBase.RGBA4444}) -- better win32 perfs but !
--		textures[i] = Texture.new(xtexpaths[i], false, { format=TextureBase.RGBA5551}) -- better win32 perfs but !
	end
	-- map size
	local tilesizetarget = 64
	local tilesetcols, tilesetrows = textures[1]:getWidth()/tilesizetarget, textures[1]:getHeight()/tilesizetarget
	-- create the tilemaps
	local function createTilemap(xtex)
		local tm = TileMap.new(
			tilesetcols, tilesetrows, -- map size in tiles
			xtex, -- tileset texture
			tilesizetarget, tilesizetarget -- tile size in pixel
		)
		-- build the map
		for i=1,tilesetcols do
			for j=1,tilesetrows do
				tm:setTile(i, j, i, j)
			end
		end
		return tm
	end
	-- the maps
	for i = 1, #textures do
		local map = createTilemap(textures[i])
		map:setPosition(map:getWidth()*(i-1), xposy)
--		self:addChild(map)
		xlayer:addChild(map)
	end
	-- params
--	self.mapwidth = self:getWidth()
--	self.mapheight = self:getHeight()
	self.mapwidth = xlayer:getWidth()
	self.mapheight = xlayer:getHeight()
	-- clean
	textures = {}
end
