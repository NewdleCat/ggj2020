
function NewRobotCorpse(robot)
    local ret = {}
    ret.particles = {}
    ret.time = 0.0
    ret.duration = 4.0
    ret.fadeTime = 1.0

    function newParticle(sprite)
        local vx
        local vy
        vx = love.math.random() * 256 - love.math.random() * 256
        vy = -love.math.random() * 256 - 256
        ret.particles[#ret.particles + 1] = {
            sprite = sprite,
            x = robot.x,
            y = robot.y,
            rot = love.math.random() * math.pi * 2,
            vx = vx,
            vy = vy,
            vr = love.math.random() * math.pi - love.math.random() * math.pi
        }
    end

    newParticle(deathArmLeft)
    newParticle(deathArmRight)
    newParticle(deathFootLeft)
    newParticle(deathFootRight)
    for i = 1, 3 do
        newParticle(deathGear1)
    end
    for i = 1, 3 do
        newParticle(deathGear2)
    end
    newParticle(deathHead)

    ret.draw = function(self, scene)
        love.graphics.setColor(1, 1, 1,
            1 - Clamp01(self.time - self.duration + self.fadeTime))
        for i, v in ipairs(self.particles) do
            love.graphics.draw(
                v.sprite.source,
                v.sprite[1],
                v.x - scene.camera.x,
                v.y - scene.camera.y,
                v.rot,
                1, 1,
                32, 32)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
    ret.update = function(self, scene, dt)
        for i, v in ipairs(self.particles) do
            v.x = v.x + v.vx * dt
            v.y = v.y + v.vy * dt
            v.rot = v.rot + v.vr * dt
            v.vy = v.vy + dt * 1024

            local tile = scene:coordToTile(v.x, v.y)
            if tile and tile.isSolid then
                v.vx = 0
                v.vy = 0
                v.vr = 0
            end
        end
        self.time = self.time + dt
        return self.time <= self.duration
    end
    return ret
end

