
function NewTile(attributes)
    local tile = {}
    tile.drawable = attributes.drawable

    tile.offset = attributes.offset

    if attributes.isSolid ~= nil then
        tile.isSolid = attributes.isSolid
    else
        tile.isSolid = true
    end

    tile.onCollision = attributes.onCollision
    tile.onEnter = attributes.onEnter

    tile.drawTile = function(self, scene, i, j)
        local x, y = (i - 1) * scene.tileSize - scene.camera.x,
                     (j - 1) * scene.tileSize - scene.camera.y

        if self.offset ~= nil then
            x = x - self.offset
            y = y - self.offset
        end

        love.graphics.draw(self.drawable, x, y, 0)
    end
    
    return tile
end

function NewDirectionalTile(attributes)
    local tile = {}
    tile.drawable = attributes.drawable

    tile.offset = attributes.offset
    if attributes.isSolid ~= nil then
        tile.isSolid = attributes.isSolid
    else
        tile.isSolid = true
    end
    tile.onCollision = attributes.onCollision
    tile.onEnter = attributes.onEnter

    tile.drawTile = function(self, scene, i, j)
        local x, y = (i - 1) * scene.tileSize - scene.camera.x,
                     (j - 1) * scene.tileSize - scene.camera.y
        local rot

        if self.offset ~= nil then
            x = x - self.offset
            y = y - self.offset
        end

        if scene:isSolid(i, j + 1) then
            rot = 0 end
        if scene:isSolid(i, j - 1) then
            rot = math.pi end
        if scene:isSolid(i - 1, j) then
            rot = math.pi * (1 / 2) end
        if scene:isSolid(i + 1, j) then
            rot = math.pi * (3 / 2) end

        love.graphics.draw(self.drawable,
            x + scene.tileSize * 0.5,
            y + scene.tileSize * 0.5,
            rot, 1, 1,
            self.drawable:getWidth() / 2, self.drawable:getWidth() / 2)
    end
    
    return tile
end

