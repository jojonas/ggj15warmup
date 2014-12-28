require "utility"
require "update"
require "draw"

function makeCell(cellType) 
	cell = {}
	cell.T = outsideTemperature
	cell.T_inflame = inflameTemperatures[cellType] 
	cell.burnMass = burnMasses[cellType] -- seconds of burning
	cell.T_burn = burnTemperatures[cellType]
	return cell
end

function isBurning(cell) 
	return (cell.T > cell.T_inflame) and (cell.burnMass > 0)
end

function loadConfig()
	local conf = {}
	local f, err = loadstring(love.filesystem.read("CONFIGURE.ME"))
	if f == nil then
		gameMode = "error"
		errorMessage = "CONFIGURE.ME could not be interpreted. Error message: " .. err
	else
		conf = f()
		if conf == nil then
			gameMode = "error"
			errorMessage = "CONFIGURE.ME corrupted."
		end
	end
	w, h = conf.width, conf.height
	if w == nil then w = 1024 end
	if h == nil then h = 768 end
	conf.width, conf.height = nil, nil
	
	love.window.setMode(w, h, conf)
end

function love.load()
	fireDT = 0.25
	renderCellSize = 10
	outsideTemperature = 20.0
	outsideCooling = 0.0
	heatTransportCoeff = 0.045

	inflameTemperatures = {[0] = 100000.0, [128] = 900.0, [255] = 300.0}
	burnTemperatures = {[0] = 100000.0, [128] = 1300.0, [255] = 1000.0}
	burnMasses = {[0] = 0.0, [128] = 10.0, [255] = 25.0}
	deltaTuples = {{1,0}, {1,1}, {0,1}, {-1,1}, {-1,0}, {-1,-1}, {0,-1}, {1,-1}}

	gameMode = "running"

	loadConfig()

	mapImageData = love.image.newImageData("poc_map.png")
	mapImage = love.graphics.newImage(mapImageData)

	cells = {width = mapImageData:getWidth(), height = mapImageData:getHeight(), data = {}}
	for y = 1, cells.height do
		table.insert(cells.data, {})
		for x = 1, cells.width do
			local pixel = mapImageData:getPixel(x-1,y-1)
			table.insert(cells.data[y], makeCell(pixel))
		end
	end
	
	nextCellUpdate = simulationTime
end

function love.run()
	math.randomseed(os.time())
	math.random() math.random()
	
	simulationTime = love.timer.getTime()
	simulationDt = 1.0/30.0

	if love.load then love.load(arg) end

	-- Main loop time.
   while true do
		while simulationTime < love.timer.getTime() do
			simulationTime = simulationTime + simulationDt
			-- Process events.
			if love.event then
				love.event.pump()
				for e,a,b,c,d in love.event.poll() do
					if e == "quit" then
						if not love.quit or not love.quit() then
							if love.audio then
								love.audio.stop()
							end
							return
						end
					end
					love.handlers[e](a,b,c,d)
				end
			end
			
			tickSimulation()
		end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
		if love.graphics then
			love.graphics.clear()
			if love.draw then love.draw() end
		end

		if love.timer then love.timer.sleep(0.001) end
		if love.graphics then love.graphics.present() end
	end
end