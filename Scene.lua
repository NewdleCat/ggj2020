function NewScene()
    local scene = {}
    scene.objects = {}
    scene.triggers = {}

    scene.camera = {
        x = 0,
        y = 0
    }
    scene.endCamMovePos = {
        x = 0,
        y = 0
    }
    scene.startCamMovePos = {
        x = 0,
        y = 0
    }
    scene.startCamMoveTime = 0
    scene.endCamMoveTime = 0
    scene.time = 0
    scene.defaultCamMoveDuration = 0.5
    scene.isCameraMoving = false
    
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

        if not self.isCameraMoving then
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

        -- Move the camera
        do
            local t = (self.time - self.startCamMoveTime)
                / (self.endCamMoveTime - self.startCamMoveTime)
            self.isCameraMoving = t >= 0 and t <= 1
            self.camera.x = Slerp(
                self.startCamMovePos.x,
                self.endCamMovePos.x,
                Clamp01(t))
            self.camera.y = Slerp(
                self.startCamMovePos.y,
                self.endCamMovePos.y,
                Clamp01(t))
        end
        self.time = self.time + dt
    end

    scene.draw = function(self)
        for i, v in ipairs(self.objects) do
            if v.draw then
                v:draw(self)
            end
        end
    end

    scene.moveCameraTo = function(self, x, y, duration)
        if duration == nil then
            duration = self.defaultCamMoveDuration
        end
        self.startCamMovePos.x = self.camera.x
        self.startCamMovePos.y = self.camera.y
        self.endCamMovePos.x = x
        self.endCamMovePos.y = y
        self.startCamMoveTime = self.time
        self.endCamMoveTime = self.time + duration
    end

    return scene
end

