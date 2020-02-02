
function NewGameScene()
    local scene = NewScene()
    scene.player = nil
    scene.tileSize = 64
    scene.skyColor = { 0, 1, 1 }
    scene.lastCheckpoint = nil
    scene.playerConstructor = NewHeadPlayer
    scene.background = love.graphics.newImage("assets/bg3.png")
    scene.backgroundTimer = 0
    scene.respawnWaitDuration = 1
    scene.playerTimeOfDeath = 0
    scene.frontObjects = {}

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
        
        Scene:spawnPlayer()
    end

    local sceneAdd = scene.add
    scene.add = function(self, object)
        sceneAdd(self, object)
        if object.isPlayer then
            self.player = object
        end
        return object
    end

    scene.frontAdd = function (self, object)
        self.frontObjects[#self.frontObjects + 1] = object
        return object
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
        return math.floor(x / self.tileSize) + 1,
               math.floor(y / self.tileSize) + 1
    end

    -- Converts a tile index coordinate to a position in world space.
    scene.tileCoordToCoord = function(self, i, j)
        return (i - 1) * self.tileSize,
               (j - 1) * self.tileSize
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

    -- Returns whether the tile at the indexes i, j is solid.
    scene.isSolid = function(self, i, j)
        if i >= 1 and i <= self.mapWidth then
            if j >= 1 and j <= self.mapHeight then
                local tile = self.mapTable[i][j]
                return tile and tile.isSolid
            end
        end
        return false
    end

    scene.coordToTile = function(self, x, y)
        return self:getTile(self:coordToTileCoord(x, y))
    end

    scene.getCollisionAt = function (self, x,y)
        local tile = self:coordToTile(x,y)
        if tile ~= nil and tile.isSolid then
            return tile
        end
        return nil
    end

    scene.parentUpdate = scene.update
    scene.update = function(self, dt)
        self:parentUpdate(dt)
        self.backgroundTimer = self.backgroundTimer + dt

        if self.player == nil
                and self.time - self.playerTimeOfDeath
                    >= self.respawnWaitDuration then
            self:spawnPlayer()
        end

        if not self.isCameraMoving then
            local i = 1
            while i <= #self.frontObjects do
                local object = self.frontObjects[i]
                if (not object.update or object:update(self, dt)) and not object.dead then
                    i=i+1
                else
                    table.remove(self.frontObjects, i)
                end
            end
        end
    end

    local sceneDraw = scene.draw
    scene.draw = function(self)
        love.graphics.setColor(1,1,1)
        love.graphics.setShader(BackgroundGradientShader)
        love.graphics.draw(FullCanvas)
        love.graphics.setShader()
        local background = self.background
        local bgSize = background:getWidth()
        local bgDir = math.pi*0.25
        for i=0, math.ceil(Width/bgSize) +1 do
            for j=0, math.ceil(Height/bgSize) +1 do
                love.graphics.draw(background,math.floor((i-1)*bgSize + self.backgroundTimer*24*math.cos(bgDir)%bgSize),math.floor((j-1)*bgSize + self.backgroundTimer*24*math.sin(bgDir)%bgSize))
            end
        end

        sceneDraw(self)
        local minI, minJ = self:coordToTileIndex(
            self.camera.x - self.tileSize,
            self.camera.y - self.tileSize)
        local maxI, maxJ = self:coordToTileIndex(
            self.camera.x + Width + self.tileSize,
            self.camera.y + Height + self.tileSize)

        for i = minI, maxI do
            local row = self.mapTable[i]
            for j = minJ, maxJ do
                local e = row[j]
                if e and e.drawTile then
                    e:drawTile(self, i, j)
                end
            end
        end

        for i=1, #self.frontObjects do
            self.frontObjects[i]:draw(scene)
        end
    end

    scene.onPlayerDie = function(self, player)
        self.playerTimeOfDeath = self.time
        self.player = nil
    end

    scene.spawnPlayer = function(self)
        self.lastCheckpoint:spawn(self, self.playerConstructor)
        self:frontAdd(NewPlayerSpawnAnimation())
        self:moveCameraTo(
            math.floor(self.player.x / Width) * Width,
            math.floor(self.player.y / Height) * Height,
            0)
    end

    scene.transformPlayer = function (self, newplayer)
        self.playerConstructor = newplayer
        self.player.dead = true
        --self.player = self:add(self.playerConstructor(math.floor(self.player.x/self.tileSize)*self.tileSize +self.tileSize/2,math.floor(self.player.y/self.tileSize)*self.tileSize + self.tileSize/2))
        self.player = self:add(self.playerConstructor(self.player.x,self.player.y))
    end

    return scene
end
