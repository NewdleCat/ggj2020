require "Scene"
require "player"
require "GameScene"
require "Tile"

function love.load()
	Scene = NewGameScene()
	love.graphics.setDefaultFilter("nearest")

	-- Tilemap
	-- Use scene.tileSize to change the tilesize.
	Scene:setTileMap {
	    [0xFF0000] = NewTile(love.graphics.newImage("assets/tile1.png"), 32),
	    [0x0000FF] = function (scene, x,y)
	    	scene:add(NewPlayer(x*scene.tileSize,y*scene.tileSize))
	    end,
	}

	Scene:loadMap("testMap.png")
	Width = 640*2
	Height = Width * 9 / 16
	Canvas = love.graphics.newCanvas(Width, Height)

	love.window.setMode(Width + 100, Height)
end

function love.update(dt)
    Scene:update(dt)
end


function love.draw()
    love.graphics.setCanvas(Canvas)
    Scene:draw()
    love.graphics.setCanvas()
    local scale = math.min(love.graphics.getWidth()/Width,love.graphics.getHeight()/Height)
    love.graphics.draw(Canvas, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, sclae,scale, Width/2,Height/2)
end

