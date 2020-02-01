
function NewGameScene()
    local scene = NewScene()

    scene.tileSize = 64
    scene.skyColor = { 0, 1, 1 }
    scene.camera = {
        x = 0,
        y = 0
    }

    -- Tilemap should be a table with rgb color hex values as keys and either a
    -- function or table as a value. For example:
    --
    -- scene.setTileMap {
    --     0xFF0000 = NewTile()
    -- }
    --
    -- If the value is a table, it will be called as follows with scene as the
    -- scene, i and j as the coordinates in the image, and mapTable as a 2D
    -- table that contains all of the tiles:
    --
    -- tile(scene, i, j, mapTable)
    -- 
    scene.setTileMap = function(self, tileMap)
        self.tileMap = tileMap
    end

    scene.loadMap = function(self, mapfile)
        if not self.tileMap then
            error("GameScene does not have tilemap. Call scene:setTileMap.")
        end
        local map = love.image.newImageData(mapfile)
        local mapWidth, mapHeight = map:getWidth(),map:getHeight()

        self.mapTable = {}
        self.mapWidth = mapWidth
        self.mapHeight = mapHeight
        
        for i = 1, mapWidth do
            self.mapTable[i] = {}
            for j = 1, mapHeight do
                local r, g, b = map:getPixel(i-1, j-1)
                local hex = (math.floor(b * 255)
                            + (math.floor(g * 255) * 256)
                            + (math.floor(r * 255) * 256 * 256))
                
                local tile = self.tileMap[hex]
                if tile then
                    if type(tile) == "table" then
                        self.mapTable[i][j] = tile
                    elseif type(tile) == "function" then
                        tile(scene, i, j, self.mapTable)
                    end
                end
            end
        end
    end

    -- Converts to a tile index, clipped to the map size.
    scene.coordToTileIndex = function(self, x, y)
        return math.min(math.max(math.floor(x
                / self.tileSize), 1), self.mapWidth),
            math.min(math.max(math.floor(y
                / self.tileSize), 1), self.mapHeight)
    end

    -- Converts to tile index, unclipped, e.g. can be less than one and greater
    -- than the map width.
    scene.coordToTileCoord = function(self, x, y)
        return math.floor(x / self.tileSize),
            math.floor(y / self.tileSize)
    end

    -- Gets the tile at the indexes i, j.
    scene.getTile = function(self, i, j)
        if i >= 1 and i <= self.mapWidth then
            if j >= 1 and j <= self.mapHeight then
                return self.mapTable[i][j]
            end
        end
        return nil
    end

    scene.coordToTile = function(self, x, y)
        return self:getTile(self:coordToTileCoord(x, y))
    end

    local sceneDraw = scene.draw
    scene.draw = function(self)
        love.graphics.setColor(
            self.skyColor[1],
            self.skyColor[2],
            self.skyColor[3])
        love.graphics.rectangle("fill", 0,0, Width,Height)

        local minI, minJ = self:coordToTileIndex(self.camera.x, self.camera.y)
        local maxI, maxJ = self:coordToTileIndex(
            self.camera.x + Width,
            self.camera.y + Height)

        for i = minI, maxI do
            local row = self.mapTable[i]
            for j = minJ, maxJ do
                if row[j] then
                    row[j]:drawTile(self, i-1, j-1)
                end
            end
        end
        sceneDraw(self)
    end

    return scene
end

