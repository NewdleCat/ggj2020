function NewScene()
    local scene = {}
    scene.objects = {}
    scene.triggers = {}
    
    -- Use this function, don't add by using objects.
    scene.add = function(self, object)
        self.objects[#self.objects + 1] = object
        if object.isTrigger == true then
            self.triggers[#self.triggers + 1] = object
        end
    end

    -- Use this function to iterate through objects.
    scene.forEach = function(self, fun)
        for i, v in ipairs(self.objects) do
            fun(v)
        end
    end

    scene.update = function(self, dt)
        local i=1

        -- Tell the triggers whether the player is inside or not.
        for j, trigger in ipairs(self.triggers) do
            trigger.containsPlayer = trigger:overlaps(self.player)
        end

        while i <= #self.objects do
            local object = self.objects[i]
            if not object.update or object:update(self, dt) then
                i=i+1
            else
                table.remove(self.objects, i)

                -- If the object is a trigger, remove it from the trigger list.
                if object.trigger then
                    for j, v in ipairs(self.triggers) do
                        if v == object then
                            table.remove(self.triggers, v)
                        end
                    end
                end
            end
        end
    end

    scene.draw = function(self)
        for i, v in ipairs(self.objects) do
            if v.draw then
                v:draw(self)
            end
        end
    end

    return scene
end

