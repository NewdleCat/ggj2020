require "Scene"

local scene = NewScene()

scene:add {
    draw = function(self)
        love.graphics.circle("fill", 32, 32, 32)
    end
}

function love.update(dt)
    scene:update(dt)
end

width = 1024
height = 1024 * 9 / 16
canvas = love.graphics.newCanvas(width, height)

love.window.setMode(width, height)

function love.draw()
    love.graphics.setCanvas(canvas)
    scene:draw()
    love.graphics.setCanvas()
    love.graphics.draw(canvas)
end
