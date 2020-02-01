
-- Creates a new trigger from the following attributes:
-- x, y, width, height,
-- onTriggerEnter, <- optional
-- onTriggerExit, <- optional
-- draw <- optional
--
function NewTrigger(attributes)
    local trigger = {}

    trigger.x = attributes.x
    trigger.y = attributes.y
    
    trigger.width = attributes.width
    trigger.height = attributes.height

    trigger.containsPlayer = false
    trigger.lastContainsPlayer = false

    trigger.isTrigger = true
    trigger.onTriggerEnter = attributes.onTriggerEnter
    trigger.onTriggerExit = attributes.onTriggerExit
    trigger.draw = attributes.draw

    trigger.overlaps = function(self, other)
        return self.x + self.width >= other.x
           and self.y + self.height >= other.y
           and self.x <= other.x + other.width
           and self.y <= other.y + other.height
    end

    trigger.update = function(self, scene, dt)
        if not self.lastContainsPlayer and self.containsPlayer then
            self:onTriggerEnter(scene.player)
        end
        if self.lastContainsPlayer and not self.containsPlayer then
            self:onTriggerExit(scene.player)
        end
        self.lastContainsPlayer = self.containsPlayer
        return true
    end
    return trigger
end

