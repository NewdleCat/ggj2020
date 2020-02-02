
function NewRobotCorpse(robot)
    local ret = {}
    ret.particles = {}
    ret.time = 0.0
    ret.duration = 2.0

    function newParticle(sprite)
        ret.particles[#ret.particles + 1] = {
            sprite = sprite,
            x = robot.x,
            y = robot.y,
            rot = love.math.random() * math.pi * 2,
            vx = love.math.random() * 256 - love.math.random() * 256,
            vy = love.math.random() * 256 - love.math.random() * 1024,
            vr = love.math.random() * math.pi - love.math.random() * math.pi
        }
    end

    newParticle(SpriteRobotLeg)
    newParticle(SpriteRobotArms)
    newParticle(SpriteRobotHead)

    ret.draw = function(self, scene)
        for i, v in ipairs(self.particles) do
            love.graphics.draw(
                v.sprite.source,
                v.sprite[1],
                v.x,
                v.y,
                v.rot,
                1, 1,
                32, 32)
        end
    end
    ret.update = function(self, scene, dt)
        for i, v in ipairs(self.particles) do
            v.x = v.x + v.vx * dt
            v.y = v.y + v.vy * dt
            v.rot = v.rot + v.vr * dt
            v.vy = v.vy + dt * 1024
        end
        self.time = self.time + dt
        return self.time <= self.duration
    end
    return ret
end

