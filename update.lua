function processNeighbour(x, y, deltaX, deltaY)
	if cells.data[y+deltaY] and cells.data[y+deltaY][x+deltaX] then
		local cell = cells.data[y][x]
		local neighbour = cells.data[y + deltaY][x + deltaX]
		local delta = heatTransportCoeff*(cell.T - neighbour.T)*randrangef(0.9, 1.1)
		neighbour.T = neighbour.T + delta
	end
end

function tickSimulation()
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