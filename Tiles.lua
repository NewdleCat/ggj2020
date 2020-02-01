
SpikeTile = NewTile {
    drawable = love.graphics.newImage("assets/spikes1.png"),
    isSolid = false,
    onTileStay = function(self, other, scene, i, j)
        local x, y = scene:tileCoordToCoord(i, j)
        if other.health then
            if scene:isSolid(i, j + 1) then
                if other.y + other.height
                        >= y + self.drawable:getHeight() - 8 then
                    other.health = other.health - 1
                end
            end
            if scene:isSolid(i, j - 1) then
                if other.y + other.height
                        <= y + 8 then
                    other.health = other.health - 1
                end
            end
            if scene:isSolid(i + 1, j) then
                if other.x + other.width
                        >= x + self.drawable:getWidth() - 8 then
                    other.health = other.health - 1
                end
            end
            if scene:isSolid(i - 1, j) then
                if other.x + other.width
                        <= x + 8 then
                    other.health = other.health - 1
                end
            end
        end
    end
}

SpikeTile.drawTileRotated = function(self, scene, i, j, rot)
    local x, y = (i - 1) * scene.tileSize - scene.camera.x,
                 (j - 1) * scene.tileSize - scene.camera.y
    if self.offset ~= nil then
        x = x - self.offset
        y = y - self.offset
    end
    love.graphics.draw(self.drawable,
        x + scene.tileSize * 0.5,
        y + scene.tileSize * 0.5,
        rot, 1, 1,
        self.drawable:getWidth() / 2, self.drawable:getWidth() / 2)
end

SpikeTile.drawTile = function(self, scene, i, j)
    -- Look at surrounding tiles.

    -- Bottom.
    if scene:isSolid(i, j + 1) then
        self:drawTileRotated(scene, i, j, 0) end
    -- Top.
    if scene:isSolid(i, j - 1) then
        self:drawTileRotated(scene, i, j, math.pi) end
    -- Left.
    if scene:isSolid(i - 1, j) then
        self:drawTileRotated(scene, i, j, math.pi * (1 / 2)) end
    -- Right.
    if scene:isSolid(i + 1, j) then
        self:drawTileRotated(scene, i, j, math.pi * (3 / 2)) end
end
