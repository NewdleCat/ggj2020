
function NewTile(drawable, offset)
    local tile = {}
    tile.drawable = drawable

    if not offset then
    	offset = 0
    end
    tile.offset = offset

    tile.drawTile = function(self, scene, i, j)
        love.graphics.draw(
            self.drawable,
            i * scene.tileSize - offset,
            j * scene.tileSize - offset)
    end
    
    return tile
end

