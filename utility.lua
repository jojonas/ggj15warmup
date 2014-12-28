function clamp(value, lo, hi)
	return math.max(math.min(value, hi), lo)
end

function randrangef(min, max)
    return min + (max - min)*love.math.random()
end