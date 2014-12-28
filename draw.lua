function love.draw()
	if gameMode == "error" then
		love.graphics.setColor(255,255,255)
		love.graphics.printf(errorMessage, 5, 5, 500)
	else
		local font_offset_y = (renderCellSize - love.graphics.getFont():getHeight()) / 2
		for x=1,cells.width do
			for y=1,cells.height do
				local X = (x-1)*renderCellSize 
				local Y = (y-1)*renderCellSize 
				local cell = cells.data[y][x]

				if isBurning(cell) then
					love.graphics.setColor(255,0,0)
				elseif cell.burnMass <= 0 then
					if cell.T > cell.T_inflame then
						love.graphics.setColor(150,50,0)
					else 
						love.graphics.setColor(0,0,20)
					end
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
end