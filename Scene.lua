function NewScene()
    local scene = {}
    scene.objects = {}
    
    -- Use this function, don't add by using objects.
    scene.add = function(self, object)
        self.objects[#self.objects + 1] = object
    end
    
    scene.remove = function(self, object)
        -- Find the object in the table.
        for i, v in ipairs(self.objects) do
            if v == object then
                table.remove(i)
                break
            end
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
        while i <= #self.objects do
            if not self.objects[i].update or self.objects[i]:update(dt) then
                i=i+1
            else
                table.remove(self.objects, i)
            end
        end
    end

    scene.draw = function(self)
        for i, v in ipairs(self.objects) do
            if v.draw then
                v:draw()
            end
        end
    end

    return scene
end

