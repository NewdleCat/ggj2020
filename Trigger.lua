
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
        return true
    end
    return trigger
end

