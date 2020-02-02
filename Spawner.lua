
-- Attributes expects constructor.
function NewSpawner(constructor)
    local ret = {}

    ret.constructor = constructor
    ret.isSpawner = true

    ret.spawn = function(self, scene, i, j)
        local x, y = scene:tileCoordToCoord(i, j)
        scene:add(self.constructor(scene, x, y))
    end
    return ret
end

