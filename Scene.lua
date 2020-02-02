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
        local minX = math.min(self.camera.x, self.endCamMovePos.x)
        local maxX = math.max(self.camera.x, self.endCamMovePos.x)
        local minY = math.min(self.camera.y, self.endCamMovePos.y)
        local maxY = math.max(self.camera.y, self.endCamMovePos.y)

        if obj.x - minX < -obj.width
                or obj.x - maxX > Width + obj.width then
            return false
        end
        if obj.y - minY < -obj.height
                or obj.y - maxY > Height + obj.height then
            return false
        end
        return true
    end

    scene.moveCameraTo = function(self, x, y, duration)
        if duration == nil then
            duration = self.defaultCamMoveDuration
        end
        local useSpawners = not self.endCamMovePos or x ~= self.endCamMovePos.x
            or y ~= self.endCamMovePos.y

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
            self.endCamMovePos.x,
            self.endCamMovePos.y)
        local endI, endJ = scene:coordToTileIndex(
            self.endCamMovePos.x + Width,
            self.endCamMovePos.y + Height)

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

function NewFoundHudObject(sprite)
    local self = {}
    self.timer = 0
    self.sprite = sprite
    self.found = love.graphics.newImage("assets/found.png")
    self.maxTimer = 5

    self.update = function (self, scene, dt)
        local lastTimer = self.timer
        self.timer = self.timer + dt
        if self.timer >= 1.8 + 1/2.4 and lastTimer < 1.8 + 1/2.4 then
            ShakeScreen()
            SfxThud2:play()
        end
        if self.timer >= self.maxTimer then
            Music:play()
        end
        return self.timer < self.maxTimer, true
    end

    self.draw = function (self)
        local fadeOut = 0.7
        love.graphics.setColor(0,0,0, Lerp(0, 0.8, math.min(self.timer*2, 1)))
        if self.timer > self.maxTimer-1 then
        love.graphics.setColor(0,0,0, Lerp(0.8, 0, self.timer-self.maxTimer+1))
        end
        love.graphics.rectangle("fill", 0,0, Width,Height)
        love.graphics.setColor(1,1,1)
        if self.timer > 0.9 then
            if self.timer > self.maxTimer-1 then
                love.graphics.setColor(1,1,1, Lerp(1, 0, self.timer-self.maxTimer+1))
            end
            love.graphics.draw(self.sprite)
        end

        love.graphics.setColor(1,1,1)
        local foundTime = 1.8
        if self.timer > foundTime then
            local scale = math.max(Lerp(15,1, (self.timer-foundTime)*2.4), 1)
            if self.timer > self.maxTimer-1 then
                love.graphics.setColor(1,1,1, Lerp(1, 0, self.timer-self.maxTimer+1))
            end
            love.graphics.draw(self.found, Width/2, Height/2, 0, scale,scale, Width/2,Height/2)
        end
    end

    return self
end
