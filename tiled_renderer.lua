function load(filename) 
	local map = dofile(filename)
	assert(map.orientation=="orthogonal", "Cannot load non-orthogonal maps.")
	for i in 1,#map.tilesets do
		local tileset = map.tilesets[i]
		tileset.image = love.graphics.newImage(tileset.image)
		tileset.width  = tileset.imagewidth / tileset.tilewidth
		tileset.height = tileset.imageheight / tileset.tileheight
		tileset.count = tileset.width*tileset.height
		
		tileset.quads = {}
		for y=0,tileset.height-1 do
			for x=0,tileset.width-1 do
				local id = y*tileset.width + x
				tileset.quads[id] = love.graphics.newQuad(x*tileset.tilewidth, y*tileset.tileheight, tileset.tilewidth, tileset.tileheight, tileset.imagewidth, tileset.imageheight)
			end
		end 
		
		tileset.batch = love.graphics.newSpriteBatch(tileset.image, map.with*map.height)
	end
	return map
end

function find_tileset(map, id) 
	for k=1,#map.tilesets do
		if map.tilesets[k].firstgid > id then 
			return map.tilsets[k-1]
		end
	end
end

function draw(map)
	for i=1,#map.layers do
		for j=1,#map.tilesets do
			map.tileset[j].batch:bind()
			map.tileset[j].batch:clear()
		end
		local layer = map.layers[i]
		for j=0,#layer.data-1 do
			local id = layer.data[j+1]
			local x = j % layer.width
			local y = math.floor(j / layer.width)
			local tileset = find_tileset(map, id)
			tileset.batch:add(tileset.quads[id - tileset.firstgid], x*map.tilewidth, y*map.tileheight)
		end
		for j=1,#map.tilesets do
			map.tileset[j].batch:unbind()
		end
	end
end