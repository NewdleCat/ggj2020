
function NewCheckpoint(scene, x, y)
    local checkpoint = NewTrigger {
        x = x,
        y = y,
        width = scene.tileSize,
        height = scene.tileSize,
        sprite = NewAnimatedSprite("assets/checkpoint.png"),

        isSpawner = true,

        onTriggerEnter = function(self, scene, other)
            scene.lastCheckpoint = self
        end,

        spawn = function(self, scene, constructor)
            return scene:add(constructor(
                self.x + 0.5 * scene.tileSize,
                self.y + 0.5 * scene.tileSize))
        end,
        draw = function (self, scene)
            if scene.lastCheckpoint == self then
                love.graphics.draw(
                    self.sprite.source,
                    self.sprite[2],
                    self.x - scene.camera.x,
                    self.y - scene.camera.y,
                    0, 1, 1, 0, 0)
            else
                love.graphics.draw(
                    self.sprite.source,
                    self.sprite[1],
                    self.x - scene.camera.x,
                    self.y - scene.camera.y,
                    0, 1, 1, 0, 0)
            end
        end
    }
    return checkpoint
end

