
-- Creates a new trigger from the following attributes:
-- x, y, width, height,
-- onTriggerEnter, <- optional
-- onTriggerExit, <- optional
-- draw <- optional
--
function NewTrigger(attributes)
    local trigger = {}

    trigger.containsPlayer = false
    trigger.lastContainsPlayer = false
    trigger.isTrigger = true

    for i,v in pairs(attributes) do
        trigger[i] = v
    end

    trigger.overlaps = function(self, other)
        return self.x + self.width >= other.x
           and self.y + self.height >= other.y
           and self.x <= other.x + other.width
           and self.y <= other.y + other.height
    end

    trigger.update = function(self, scene, dt)
        if not self.lastContainsPlayer and self.containsPlayer then
            if self.onTriggerEnter then
                self:onTriggerEnter(scene, scene.player)
            end
        end
        if self.lastContainsPlayer and not self.containsPlayer then
            if self.onTriggerExit then
                self:onTriggerExit(scene, scene.player)
            end
        end
        self.lastContainsPlayer = self.containsPlayer
        if self.customUpdate then
            self:customUpdate(scene, dt)
        end
        return true
    end
    return trigger
end

function NewBodyTrigger(x,y, sprite, transformation, song, foundSprite)
    local self = NewTrigger {
        x = x,
        y = y,
        width = 64,
        height = 64,
        sprite = sprite,
        transformation = transformation,
        animIndex = 1,
        timer = 0,
        song = song,
        foundSprite = foundSprite,

        onTriggerEnter = function(self, scene, other)
            scene:transformPlayer(self.transformation)
            self.dead = true
            if Music ~= self.song then
                Music:stop()
                Music = self.song
                Music:stop()
                Music:play()
            end

            scene:hudAdd(NewFoundHudObject(self.foundSprite))
        end,
        onTriggerExit = function(self, scene, other)
        end,

        customUpdate = function (self, scene, dt)
            self.animIndex = self.animIndex + dt*10
            self.timer = self.timer + dt
            if self.animIndex > #self.sprite then
                self.animIndex = 1
            end
        end,

        draw = function (self, scene)
            love.graphics.draw(self.sprite.source, self.sprite[math.floor(self.animIndex)], self.x - scene.camera.x,self.y - scene.camera.y -16 + math.sin(self.timer)*12)
        end,
    }

    return self
end
