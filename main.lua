require "Enemies"
require "RobotCorpse"
require "Scene"
require "player"
require "GameScene"
require "Tile"
require "Tiles"
require "Trigger"
require "Checkpoint"
require "Spawner"

function love.load()
    Music = love.audio.newSource( 'music/sleep mode.mp3', 'static' )
    Music:setLooping(true) --the groove dont stop babey
    Music:play()

    MusicBootup = love.audio.newSource('music/bootup.mp3', 'static')
    MusicBootup:setLooping(true)
    MusicDigital = love.audio.newSource('music/digital.mp3', 'static')
    MusicDigital:setLooping(true)
    MusicVibeTime = love.audio.newSource('music/vibe time.mp3', 'static')
    MusicVibeTime:setLooping(true)

    SfxLaserFire = love.audio.newSource('sfx/laserfire.mp3', 'static')

	Width = 64*24
	Height = 64*14

	Scene = NewGameScene()
	love.graphics.setDefaultFilter("nearest")

    DeathArmLeft = NewAnimatedSprite("assets/deathArmLeft.png")
    DeathArmRight = NewAnimatedSprite("assets/deathArmRight.png")
    DeathFootLeft = NewAnimatedSprite("assets/deathFootLeft.png")
    DeathFootRight = NewAnimatedSprite("assets/deathFootRight.png")
    DeathGear1 = NewAnimatedSprite("assets/deathGear1.png")
    DeathGear2 = NewAnimatedSprite("assets/deathGear2.png")
    DeathHead = NewAnimatedSprite("assets/deathHead.png")

    MikeSprite = NewAnimatedSprite("assets/mike.png")
    LaserSprite = NewAnimatedSprite("assets/laser.png")

	-- Tilemap
	-- Use scene.tileSize to change the tilesize.
	Scene:setTileMap {
	    [0xFFFFFF] = NewTile { ------------------------------------- GROUND
            drawable = love.graphics.newImage("assets/tile1.png"),
            offset = 32
        },
	    [0x0000FF] = function (scene, i, j) ------------------------ PLAYER SPAWN
            local x, y = scene:tileCoordToCoord(i, j)
            scene.lastCheckpoint = {
                x = x,
                y = y,
                spawn = function(self, scene, constructor)
                	scene.player = scene:add(constructor(self.x + 0.5 * scene.tileSize, self.y + 0.5 * scene.tileSize))
                    return scene.player
                end
            }
	    end,
        [0x00FF00] = function (scene, i, j) ------------------------ ROBOT LEG AND BODY
            local x, y = scene:tileCoordToCoord(i, j)
            scene:add(NewBodyTrigger(x,y,
                NewAnimatedSprite("assets/bodypickup1.png"),
                NewOneLegPlayer,
                MusicBootup))
        end,
        [0x00EB00] = function (scene, i, j) ------------------------ ROBOT LEG 2
            local x, y = scene:tileCoordToCoord(i, j)
            scene:add(NewBodyTrigger(x,y,
                NewAnimatedSprite("assets/bodypickup2.png"),
                NewArmlessPlayer,
                MusicDigital))
        end,
        [0x00D700] = function (scene, i, j) ------------------------ ROBOT NORMAL
            local x, y = scene:tileCoordToCoord(i, j)
            scene:add(NewBodyTrigger(x,y,
                NewAnimatedSprite("assets/bodypickup3.png"),
                NewPlayer,
                MusicVibeTime))
        end,
        [0xFF0000] = SpikeTile, ------------------------------------ SPIKES,
        [0XFFFF00] = function (scene, i, j) ------------------------ CHECKPOINT
            local x, y = scene:tileCoordToCoord(i, j)
            scene:add(NewCheckpoint(scene, x, y))
        end,
        [0x8949FF] = function (scene, i, j)
            local x, y = scene:tileCoordToCoord(i, j)
        	scene:add(NewTrigger{
		        x = x,
		        y = y,
		        width = 64,
		        height = 64,

		        onTriggerEnter = function(self, scene, other)
		            scene:transformPlayer(self.transformation)
		            self.dead = true
		        end,
		        onTriggerExit = function(self, scene, other)
		        end,
        	})
        end,
        [0x00FFFF] = NewSpawner(NewMike)
	}

	Scene:loadMap("maps/testMap.png")
	Canvas = love.graphics.newCanvas(Width, Height)

	local dw,dh = love.window.getDesktopDimensions()
	love.window.setMode(math.min(Width, dw), math.min(Height, dh), {resizable = true, highdpi = true})

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
        ["jump"] = false,
    }

    BackgroundGradientShader = love.graphics.newShader[[
    	number lerp(number a, number b, number t)
    	{
    		return (1.0-t)*a/255.0 + t*b/255.0;
    	}

		vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
		{
		    return vec4(lerp(92.0, 51.0, texture_coords.y),lerp(38.0, 0.0, texture_coords.y),lerp(212.0, 103.0, texture_coords.y),1);
		}
  	]]
  	FullCanvas = love.graphics.newCanvas(Width,Height)
  	love.graphics.setCanvas(FullCanvas)
  	love.graphics.clear(1,1,1,1)
  	love.graphics.setCanvas()
end

function love.update(dt)
    Scene:update(dt)
    UpdateButtons()
end


function love.draw()
    love.graphics.setCanvas(Canvas)
    love.graphics.clear(0,0,0,0)
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

    if btn == "jump" then
        if love.keyboard.isDown("x") then return true end
        if love.keyboard.isDown("space") then return true end
        if love.keyboard.isDown("up") then return true end
        if GamepadExists() then
            if Gamepad:isGamepadDown("a") then return true end
            if Gamepad:isGamepadDown("dpup") then return true end
            if Gamepad:getGamepadAxis("lefty") < -1*JoystickSensitivity then return true end
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
function Slerp(a, b, t)
    return a + (0.5 - math.cos(t * math.pi) * 0.5) * (b - a)
end
function DeltaLerp(a,b,t, dt) 
    return Lerp(a,b, 1 - t^(dt))
end
function Clamp(a, b, t)
    return math.max(a, math.min(b, t))
end
function Clamp01(t)
    return Clamp(0, 1, t)
end

function Contains(table, value)
    for i,v in pairs(table) do
        if v == value then return true end
    end
    return false
end


