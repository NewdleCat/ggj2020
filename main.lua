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
	    	scene:addPlayer(NewHeadPlayer((x-0.5)*scene.tileSize,(y-0.5)*scene.tileSize))
	    end,
	}

	Scene:loadMap("maps/testMap.png")
	Width = 640*2
	Height = Width * 9 / 16
	Canvas = love.graphics.newCanvas(Width, Height)

	local dw,dh = love.window.getDesktopDimensions()
	love.window.setMode(math.min(Width, dw), math.min(Height, dh), {resizable = true})

    local joysticks = love.joystick.getJoysticks()
    Gamepad = nil
    if #joysticks > 0 and joysticks[1]:isGamepad() then
        Gamepad = joysticks[1]
    end
    JoystickSensitivity = 0.25

    ButtonsDown = {
        ["right"] = false, 
        ["left"] = false, 
        ["up"] = false,
        ["down"] = false,
        ["a"] = false,
        ["b"] = false,
        ["start"] = false,
    }
end

function love.update(dt)
    UpdateButtons()
    Scene:update(dt)
end


function love.draw()
    love.graphics.setCanvas(Canvas)
    Scene:draw()
    love.graphics.setCanvas()
    local scale = math.min(love.graphics.getWidth()/Width,love.graphics.getHeight()/Height)
    love.graphics.draw(Canvas, love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0, scale,scale, Width/2,Height/2)
end


--------------------------------------------------------------------------------------------------------
--- GAMEPAD SUPPORT
--------------------------------------------------------------------------------------------------------


function GamepadExists()
    return Gamepad ~= nil 
end

function ButtonPress(btn)
    return ButtonIsDown(btn) and not ButtonWasDown(btn)
end

function ButtonWasDown(btn)
    return ButtonsDown[btn]
end

function ButtonIsDown(btn)
    if btn == "right" then
        if love.keyboard.isDown("right") then return true end
        if GamepadExists() then
            if Gamepad:isGamepadDown("dpright") then return true end
            if Gamepad:getGamepadAxis("leftx") > JoystickSensitivity then return true end
        end
    end
    if btn == "left" then
        if love.keyboard.isDown("left") then return true end
        if GamepadExists() then
            if Gamepad:isGamepadDown("dpleft") then return true end
            if Gamepad:getGamepadAxis("leftx") < -1*JoystickSensitivity then return true end
        end
    end
    if btn == "up" then
        if love.keyboard.isDown("up") then return true end
        if GamepadExists() then
            if Gamepad:isGamepadDown("dpup") then return true end
            if Gamepad:getGamepadAxis("lefty") < -1*JoystickSensitivity then return true end
        end
    end
    if btn == "down" then
        if love.keyboard.isDown("down") then return true end
        if GamepadExists() then
            if Gamepad:isGamepadDown("dpdown") then return true end
            if Gamepad:getGamepadAxis("lefty") > JoystickSensitivity then return true end
        end
    end

    if btn == "a" then
        if love.keyboard.isDown("x") then return true end
        if GamepadExists() then
            if Gamepad:isGamepadDown("a") then return true end
        end
    end
    if btn == "b" then
        if love.keyboard.isDown("z") then return true end
        if GamepadExists() then
            if Gamepad:isGamepadDown("b") then return true end
        end
    end

    if btn == "start" then
        if love.keyboard.isDown("space") then return true end
        if love.keyboard.isDown("escape") then return true end
        if love.keyboard.isDown("return") then return true end

        if GamepadExists() then
            if Gamepad:isGamepadDown("start") then return true end
        end
    end

    return false
end

function UpdateButtons()
    for i,v in pairs(ButtonsDown) do
        ButtonsDown[i] = ButtonIsDown(i)
    end
end


--------------------------------------------------------------------------------------------------------
--- UTILITY FUNCTIONS
--------------------------------------------------------------------------------------------------------


function NewAnimatedSprite(path)
	local Floor, Ceil = math.floor, math.ceil
	local lg = love.graphics
    local imgData = love.image.newImageData(path)
    local iw,ih = imgData:getDimensions()
    local frameCount = iw/ih
    local chunkWidth = math.min(ih*100, iw)

    imgDataGrid = love.image.newImageData(chunkWidth, Ceil(iw/chunkWidth)*ih)
    for i=1, Ceil(iw/chunkWidth) do
        imgDataGrid:paste(imgData, 0,(i-1)*ih, (i-1)*chunkWidth, 0, chunkWidth, ih)
    end

    img = lg.newImage(imgDataGrid)
    local w = img:getWidth()
    local h = img:getHeight()

    local spr = {}
    spr.source = img
    spr.cellSize = ih

    local total = 0
    for j=1, Ceil(iw/chunkWidth) do
        for i=1, chunkWidth/ih do
            total = total + 1
            if total <= frameCount then
                spr[total] = lg.newQuad((i-1)*ih,(j-1)*ih, ih,ih, w,h)
            end
        end
    end

    return spr
end

function CopyTable(table)
    local ret = {}
    for i,v in pairs(table) do
        ret[i] = v
    end
    return ret
end

function Choose(arr)
    return arr[Floor(love.math.random()*(#arr))+1]
end
function Rand(min,max, interval)
    local interval = interval or 1
    local c = {}
    local index = 1
    for i=min, max, interval do
        c[index] = i
        index = index + 1
    end

    return Choose(c)
end

function GetSign(n)
    if n > 0 then
        return 1
    end
    if n < 0 then
        return -1
    end
    return 0
end
function Lerp(a,b,t) return (1-t)*a + t*b end
function DeltaLerp(a,b,t, dt) 
    return Lerp(a,b, 1 - t^(dt))
end

function Contains(table, value)
    for i,v in pairs(table) do
        if v == value then return true end
    end
    return false
end


