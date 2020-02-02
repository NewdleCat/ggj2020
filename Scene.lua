function NewScene()
    local scene = {}
    scene.objects = {}
    scene.triggers = {}

    scene.camera = {
        x = 0,
        y = 0
    }
    scene.startCamMoveTime = 0
    scene.endCamMoveTime = 0
    scene.time = 0
    scene.defaultCamMoveDuration = 0.4
    scene.isCameraMoving = false
    scene.moveWithCameraFunction = nil
    scene.hudObjects = {}
    scene.paused = false

    -- Use this function, don't add by using objects.
    scene.add = function(self, object)
        self.objects[#self.objects + 1] = object
        if object.isTrigger == true then
            self.triggers[#self.triggers + 1] = object
        end
        return object
    end

    scene.hudAdd = function (self, object)
        self.hudObjects[#self.hudObjects + 1] = object
        return object
    end

    -- Use this function to iterate through objects.
    scene.forEach = function(self, fun)
        for i, v in ipairs(self.objects) do
            fun(v)
        end
    end

    scene.update = function(self, dt)
        -- Tell the triggers whether the player is inside or not.
        if self.player then
            for j, trigger in ipairs(self.triggers) do
                trigger.containsPlayer = trigger:overlaps(self.player)
            end
        end

        local keep = false
        self.paused = false
        if #self.hudObjects > 0 then
            keep, self.paused = self.hudObjects[1]:update(self, dt)
            if not keep then
                table.remove(self.hudObjects, 1)
            end
        end

        if not self.isCameraMoving and not self.paused then
            local i=1

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
        if self.startCamMovePos then
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
    end

    scene.draw = function(self)
        for i, v in ipairs(self.objects) do
            if v.draw then
                v:draw(self)
            end
        end
    end

    scene.isVisible = function(self, obj)
        if obj.x - self.camera.x < -obj.width 
                or obj.x - self.camera.x > Width + obj.width then
            return false
        end
        if obj.y - self.camera.y < -obj.height 
                or obj.y - self.camera.y > Height + obj.height then
            return false
        end
        return true
    end

    scene.moveCameraTo = function(self, x, y, duration)
        if duration == nil then
            duration = self.defaultCamMoveDuration
        end
        local useSpawners = not self.endCamMovePos or x ~= self.endCamMovePos.x
            and y ~= self.endCamMovePos.y

        if not self.startCamMovePos then
            self.startCamMovePos = {} end
        if not self.endCamMovePos then
            self.endCamMovePos = {} end
        
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
        
        if useSpawners then
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
    end

    return scene
end

function NewFadeToBlackHudObject(pause, sceneChange)
    local self = {}
    self.timer = 0
    self.pause = pause
    self.sceneChange = sceneChange

    self.update = function (self, scene, dt)
        self.timer = self.timer + dt

        if self.timer >= 1 and self.sceneChange then
            ChangeScene(self.sceneChange)
        end

        return self.timer < 1, self.pause
    end

    self.draw = function (self, scene)
        love.graphics.setColor(0,0,0,self.timer)
        love.graphics.rectangle("fill", 0,0, Width,Height)
        love.graphics.setColor(1,1,1)
    end

    return self
end

function NewFadeFromBlackHudObject(pause, sceneChange)
    local self = {}
    self.timer = 0
    self.pause = pause
    self.sceneChange = sceneChange

    self.update = function (self, scene, dt)
        self.timer = self.timer + dt/4

        if self.timer >= 1 and self.sceneChange then
            ChangeScene(self.sceneChange)
        end

        return self.timer < 1, self.pause
    end

    self.draw = function (self, scene)
        love.graphics.setColor(0,0,0,1-self.timer)
        love.graphics.rectangle("fill", 0,0, Width,Height)
        love.graphics.setColor(1,1,1)
    end

    return self
end
