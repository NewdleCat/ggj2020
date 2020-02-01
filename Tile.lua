
function NewTile(drawable)
    local tile = {}
    tile.drawable = drawable

    tile.drawTile = function(self, scene, i, j)
        love.graphics.draw(
            self.drawable,
            i * scene.tileSize,
            j * scene.tileSize)
    end
    
    return tile
end

