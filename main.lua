require "Scene"
require "GameScene"
require "Tile"

local scene = NewGameScene()

-- Tilemap
-- Use scene.tileSize to change the tilesize.
scene:setTileMap {
    [0xFF0000] = NewTile(love.graphics.newImage("testTile.png"))
}

scene:loadMap("testMap.png")

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

