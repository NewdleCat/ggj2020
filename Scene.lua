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
    scene.defaultCamMoveDuration = 0.4
    scene.isCameraMoving = false
    scene.moveWithCameraFunction = nil
    
    -- Use this function, don't add by using objects.
    scene.add = function(self, object)
        self.objects[#self.objects + 1] = object
        if object.isTrigger == true then
            self.triggers[#self.triggers + 1] = object
        end
        return object
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
        if self.player then
            for j, trigger in ipairs(self.triggers) do
                trigger.containsPlayer = trigger:overlaps(self.player)
            end
        end

        if not self.isCameraMoving then
            while i <= #self.objects do
                local object = self.objects[i]
                if (not object.update or object:update(self, dt)) and not object.dead then
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
        local t = (self.time - self.startCamMoveTime)
            / (self.endCamMoveTime - self.startCamMoveTime)
        self.isCameraMoving = t >= 0 and t <= 1
        if self.moveWithCameraFunction and self.isCameraMoving then
            self.moveWithCameraFunction(self, t)
        end
        self.camera.x = Slerp(
            self.startCamMovePos.x,
            self.endCamMovePos.x,
            Clamp01(t))
        self.camera.y = Slerp(
            self.startCamMovePos.y,
            self.endCamMovePos.y,
            Clamp01(t))
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
        if duration > 0 then
            self.startCamMovePos.x = self.camera.x
            self.startCamMovePos.y = self.camera.y
            self.endCamMovePos.x = x
            self.endCamMovePos.y = y
            self.startCamMoveTime = self.time
            self.endCamMoveTime = self.time + duration
        else
            self.startCamMovePos.x = x
            self.startCamMovePos.y = y
            self.endCamMovePos.x = x
            self.endCamMovePos.y = y
            self.startCamMoveTime = self.time - 1
            self.endCamMoveTime = self.time + duration
            self.camera.x = x
            self.camera.y = y
        end

        -- Go through the spawners in the range and call spawn on them.
        local startI, startJ = scene:coordToTileIndex(
            self.camera.x,
            self.camera.y)
        local endI, endJ = scene:coordToTileIndex(
            self.camera.x + Width,
            self.camera.y + Height)
        
        if self.getTile then
            for i = startI, endI do
                for j = startJ, endJ do
                    local tile = self:getTile(i, j)
                    if tile and tile.isSpawner then
                        tile:spawn(self, i, j)
                    end
                end
            end
        end
    end

    return scene
end

