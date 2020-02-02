function NewShip(x, y)
    local ret = NewTrigger {
        x = x,
        y = y,
        vy = 0,
        sprite = ShipSprite,
        width = 64,
        height = 64,
        animIndex = 1,
        playerInShip = false,
        particles = {},
        particleCount = 0,
        particleIndex = 1,
        nextParticleTime = 0,
        onTriggerEnter = function(self, scene, other)
            self.playerInShip = true
            scene.win = true
            scene.winTime = scene.time
            Music:stop()
            Music = MusicPalindroid
            Music:stop()
            Music:play()
        end
    }

    for i = 1, 100 do
        ret.particles[i] = {
            x = 0,
            y = 0,
            vx = 0,
            vy = 0,
            scale = 1
        }
    end

    ret.draw = function(self, scene)
        if self.playerInShip then
            for i, p in ipairs(self.particles) do
                love.graphics.setColor(1, p.scale * p.scale, 0, 1)
                if p.scale > 0 then
                    love.graphics.draw(
                        SmokeSprite,
                        p.x - scene.camera.x, p.y - scene.camera.y,
                        0, p.scale, p.scale)
                end
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
		love.graphics.draw(
            self.sprite.source,
            self.sprite[self.animIndex],
            self.x - scene.camera.x,self.y - scene.camera.y - 28,
            0, 1,1, 32,32)
    end

    local oldUpdate = ret.update
    ret.update = function(self, scene, dt)
        oldUpdate(self, scene, dt)
        if self.playerInShip then
            self.animIndex = 2
            self.y = self.y + self.vy * dt
            self.vy = self.vy - 256 * dt
            if scene.player then
                scene.player.shouldDestroy = true
            end

            if scene.time >= self.nextParticleTime then
                self.nextParticleTime = scene.time + 1 / 100
                if self.particleCount < 100 then
                    self.particleCount = self.particleCount + 1
                    self.particleIndex = self.particleCount
                else
                    self.particleIndex = self.particleIndex + 1
                    if self.particleIndex >= 100 then
                        self.particleIndex = 1
                    end
                end

                self.particles[self.particleIndex].x = self.x + 16
                self.particles[self.particleIndex].y = self.y + 48
                self.particles[self.particleIndex].vx = love.math.random() * 64
                    - love.math.random() * 32
                self.particles[self.particleIndex].vy = love.math.random() * 256

                for i = 1, self.particleCount do
                    local p = self.particles[i]
                    p.x = p.x + p.vx * dt
                    p.y = p.y + p.vy * dt
                    p.scale = p.scale - dt
                end
            end
        end
        return true
    end
    
    return ret
end
