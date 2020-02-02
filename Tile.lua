
function NewTile(attributes)
    local tile = {}
    tile.drawable = attributes.drawable
    tile.isAnimated = attributes.isAnimated

    tile.offset = attributes.offset

    if attributes.isSolid ~= nil then
        tile.isSolid = attributes.isSolid
    else
        tile.isSolid = true
    end

    tile.onCollision = attributes.onCollision
    tile.onTileStay = attributes.onTileStay

    tile.drawTile = function(self, scene, i, j)
        local x, y = (i - 1) * scene.tileSize - scene.camera.x,
                     (j - 1) * scene.tileSize - scene.camera.y

        if self.offset ~= nil then
            x = x - self.offset
            y = y - self.offset
        end

        if not self.isAnimated then
	        love.graphics.draw(self.drawable, x, y, 0)
	    else
	        love.graphics.draw(self.drawable.source, self.drawable[1], x, y, 0)
	    end
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
    tile.onTileStay = attributes.onTileStay

    tile.getRotation = function(self, scene, i, j)
        if scene:isSolid(i, j + 1) then
            return 0 end
        if scene:isSolid(i, j - 1) then
            return math.pi end
        if scene:isSolid(i - 1, j) then
            return math.pi * (1 / 2) end
        if scene:isSolid(i + 1, j) then
            return math.pi * (3 / 2) end
        return 0
    end
    tile.drawTile = function(self, scene, i, j)
        local x, y = (i - 1) * scene.tileSize - scene.camera.x,
                     (j - 1) * scene.tileSize - scene.camera.y
        local rot = self:getRotation(scene, i, j)

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
    
    return tile
end

