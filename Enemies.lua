
function NewMike(scene, x, y)
    local ret = {}
    
    ret.animTime = 0
    ret.sprite = MikeSprite
    ret.direction = 1
    ret.x = x + 32
    ret.y = y + 32
    ret.maxShotInterval = 4
    ret.minShotInterval = 2
    ret.nextShotTime = scene.time +
        ret.minShotInterval 
        + love.math.random()
        * (ret.maxShotInterval - ret.minShotInterval)
    ret.width = 32
    ret.height = 32

    local i, j = scene:coordToTileCoord(x, y)
    if scene:getTile(i + 1, j) then
        ret.direction = -1
    end
    
    ret.draw = function(self, scene)
        animIndex = 1 + math.floor(self.animTime) % #self.sprite
		love.graphics.draw(
            self.sprite.source,
            self.sprite[animIndex],
            self.x - scene.camera.x,self.y - scene.camera.y,
            0, self.direction,1, 32,32)
    end

    ret.update = function(self, scene, dt)
        self.animTime = self.animTime + dt

        -- Shooting
        if scene.time >= self.nextShotTime then
            if self.direction < 0 then
                scene:add(NewLaser(x, y + 4, math.pi * 3 / 2))
            else
                scene:add(NewLaser(x, y + 4, math.pi * 1 / 2))
            end
            SfxLaserFire:clone():play()

            self.nextShotTime = scene.time +
                self.minShotInterval 
                + love.math.random()
                * (self.maxShotInterval - self.minShotInterval)
        end

        return scene:isVisible(self)
    end
    return ret
end

function NewEyeDude(scene, x, y)
    local ret = {}
    
    ret.animTime = 0
    ret.sprite = EyeDudeSprite
    ret.x = x + 32
    ret.y = y + 32
    ret.maxShotInterval = 4
    ret.minShotInterval = 2
    ret.nextShotTime = scene.time +
        ret.minShotInterval 
        + love.math.random()
        * (ret.maxShotInterval - ret.minShotInterval)
    ret.width = 32
    ret.height = 32
    
    ret.draw = function(self, scene)
        animIndex = 1 + math.floor(self.animTime) % #self.sprite
		love.graphics.draw(
            self.sprite.source,
            self.sprite[animIndex],
            self.x - scene.camera.x,self.y - scene.camera.y,
            0, 1,1, 32,32)
    end

    ret.update = function(self, scene, dt)
        self.animTime = self.animTime + dt

        -- Shooting
        if scene.time >= self.nextShotTime then
            if scene.player then
                local rot = math.atan2(
                    scene.player.x - self.x,
                    scene.player.y - self.y)
                scene:add(NewLaser(x, y, rot))
                SfxLaserFire:clone():play()

                self.nextShotTime = scene.time +
                    self.minShotInterval 
                    + love.math.random()
                    * (self.maxShotInterval - self.minShotInterval)
            end
        end

        return scene:isVisible(self)
    end
    return ret
end
function NewLaser(x, y, rot)
    local ret = {}

    ret.animTime = 0
    ret.sprite = LaserSprite
    ret.x = x + 32
    ret.y = y + 32
    if rot ~= nil then
        ret.rot = rot
    else
        ret.rot = 0
    end
    ret.speed = 512
    ret.width = 4
    ret.height = 4
    
    ret.draw = function(self, scene)
        animIndex = 1 + math.floor(self.animTime) % #self.sprite
		love.graphics.draw(
            self.sprite.source,
            self.sprite[animIndex],
            self.x - scene.camera.x,self.y - scene.camera.y,
            -self.rot, self.direction,1, 32,32)
    end

    ret.overlaps = function(self, other)
        return self.x + self.width >= other.x
           and self.y + self.height >= other.y
           and self.x - self.width <= other.x + other.width
           and self.y - self.height <= other.y + other.height
    end

    ret.update = function(self, scene, dt)
        local sin, cos = math.sin(self.rot), math.cos(self.rot)
        self.x = self.x + self.speed * sin * dt
        self.y = self.y + self.speed * cos * dt
        self.animTime = self.animTime + dt

        local tile = scene:coordToTile(self.x, self.y)
        if tile and tile.isSolid then
            return false
        elseif scene.player and self:overlaps(scene.player) then
            scene.player.health = scene.player.health - 1
            return false
        elseif not scene:isVisible(self) then
            return false
        end
        return true
    end
    return ret
end

