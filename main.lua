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

function clamp(value, lo, hi)
    return math.max(math.min(value, hi), lo)
end

function love.load()
    simDT = 1.0/60.0
    fireDT = 0.25
    renderCellSize = 10
	outsideTemperature = 20.0
	outsideCooling = 0.0
	heatTransportCoeff = 0.045
    
    inflameTemperatures = {[0] = 100000.0, [128] = 900.0, [255] = 300.0}
	burnTemperatures = {[0] = 100000.0, [128] = 1300.0, [255] = 1000.0}
	burnMasses = {[0] = 0.0, [128] = 10.0, [255] = 25.0}
    deltaTuples = {{1,0}, {1,1}, {0,1}, {-1,1}, {-1,0}, {-1,-1}, {0,-1}, {1,-1}}
    
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
    
    simulationTime = love.timer.getTime()
    nextCellUpdate = simulationTime
end

function randrangef(min, max)
    return min + (max - min)*love.math.random()
end

function processNeighbour(x, y, deltaX, deltaY)
    if cells.data[y+deltaY] and cells.data[y+deltaY][x+deltaX] then
        local cell = cells.data[y][x]
        local neighbour = cells.data[y + deltaY][x + deltaX]
		local delta = heatTransportCoeff*(cell.T - neighbour.T)*randrangef(0.9, 1.1)
        neighbour.T = neighbour.T + delta
    end
end

function love.update()
    if simulationTime < love.timer.getTime() then
        simulationTime = simulationTime + simDT
        
        local sx = math.floor(love.mouse.getX() / renderCellSize)+1
        local sy = math.floor(love.mouse.getY() / renderCellSize)+1
        if cells.data[sy] and cells.data[sy][sx] then
            cells.data[sy][sx].T = cells.data[sy][sx].T + ((love.mouse.isDown("l") and 1 or 0) - (love.mouse.isDown("r") and 1 or 0)) * 10
        end
        
        if nextCellUpdate < simulationTime then
            for y = 1, cells.height do
                for x = 1, cells.width do
                    cell = cells.data[y][x]
                    if isBurning(cells.data[y][x]) and love.math.random() < 0.8 then
                        cell.burnMass = cell.burnMass - 1
                        cell.T = cell.T_burn
					else
						cell.T = cell.T - (cell.T - outsideTemperature) * outsideCooling
                    end
                    
                    for i = 1, #deltaTuples do
                        processNeighbour(x, y, deltaTuples[i][1], deltaTuples[i][2]) 
                    end
                end
            end

            nextCellUpdate = simulationTime + fireDT
        end
    end
end

function love.draw()
    local font_offset_y = (renderCellSize - love.graphics.getFont():getHeight()) / 2
    for x=1,cells.width do
        for y=1,cells.height do
                local X = (x-1)*renderCellSize 
                local Y = (y-1)*renderCellSize 
            local cell = cells.data[y][x]
            
            if isBurning(cell) then
                love.graphics.setColor(255,0,0)
            elseif cell.burnMass <= 0 then
                     love.graphics.setColor(0,0,20)
                else
                local val = clamp((1000-cell.T_inflame)*255/1000, 0, 255)
                love.graphics.setColor(val, val, val)
            end
            love.graphics.rectangle("fill", X, Y, renderCellSize, renderCellSize)
        end
    end
    
    local sx = math.floor(love.mouse.getX() / renderCellSize)+1
    local sy = math.floor(love.mouse.getY() / renderCellSize)+1
    if cells.data[sy] and cells.data[sy][sx] then
        local selected = cells.data[sy][sx]
        local text = ""
        text = text .. "(" .. sx .. ", " .. sy .. ")\n"
        text = text .. "T: " .. selected.T .. " (inflame at " .. selected.T_inflame .. ")\n"
        text = text .. "m: " .. selected.burnMass .. "\n"
        love.graphics.setColor(255,255,255)
        love.graphics.printf(text, 5, 5, 500)
    end
end