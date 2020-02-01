function LoadMap(mapfile, mapTable)
    local map = love.image.newImageData("maps/"..CurrentMap)
    local mapWidth,mapHeight = map:getWidth(),map:getHeight()

    mapTable = {}
    
    for i=1, mapWidth do
		mapTable[i] = {}
    	for j=1, mapHeight do
			mapTable[i][j] = 0

			local r,g,b = mapTable:getPixel(i-1,j-1)
			local sx,sy = (i-1)*TileSize +0.5*TileSize, (j-1)*TileSize +0.5*TileSize

			if r == 0 and g == 0 and b == 0 then
				mapTable[i][j] = 1
			end
    	end
    end
end