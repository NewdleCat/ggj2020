
function NewTile(attributes)
    local tile = {}
    tile.drawable = attributes.drawable

    tile.offset = attributes.offset
    tile.isSolid = attributes.isSolid

    tile.drawTile = function(self, scene, i, j)
        local x, y = i * scene.tileSize, j * scene.tileSize

        if self.offset ~= nil then
            x = x - self.offset
            y = y - self.offset
        end

        love.graphics.draw(
            self.drawable,
            i * scene.tileSize - self.offset,
            j * scene.tileSize - self.offset)
    end
    
    return tile
end

