
local doCameraMove = function(self, scene)
    -- Move the camera to the new area if necessary.
    if not scene.isCameraMoving then
        if self.x + self.width - scene.camera.x > Width
                and self.direction > 0 then
            scene:moveCameraTo(scene.camera.x + Width, scene.camera.y)
        end
        if self.x - scene.camera.x < 0
                and self.direction < 0 then
            scene:moveCameraTo(scene.camera.x - Width, scene.camera.y)
        end
        if self.y + self.height - scene.camera.y > Height
                and self.ySpeed > 0 then
            scene:moveCameraTo(scene.camera.x, scene.camera.y + Height)
        end
        if self.y - scene.camera.y < 0 
                and self.ySpeed < 0 then
            scene:moveCameraTo(scene.camera.x, scene.camera.y - Height)
        end
    end
end

function NewPlayer(x,y)
	local self = {}
	self.sprite = NewAnimatedSprite("assets/robotwalk.png")
	self.x = x
	self.y = y
	self.xSpeed = 0
	self.ySpeed = 0
	self.animIndex = 1
	self.direction = 1
	self.height = 32
	self.width = 24
	self.coyoteTime = 0
    self.isPlayer = true
    self.health = 1

	self.update = function (self, scene, dt)
		local maxWalkSpeed = 200
		local walkSpeed = 60
		local inAirSpeed = 15
		local friction = 0.5
		local jumpSpeed = -550

		self.coyoteTime = math.max(self.coyoteTime-dt, 0)

		-- adding graivty
		if self.ySpeed > 0 then
			self.ySpeed = self.ySpeed + dt*4000
		else
			self.ySpeed = self.ySpeed + dt*2000
		end

		-- floor collision
		local onGround = false
        local collision1 = scene:getCollisionAt(
            self.x+self.width,
            self.y + self.height + self.ySpeed*dt)
        local collision2 = scene:getCollisionAt(
            self.x-self.width,
            self.y + self.height + self.ySpeed*dt)
		if collision1 or collision2 then
			while not scene:getCollisionAt(self.x+self.width, self.y + self.height + 1)
			and not scene:getCollisionAt(self.x-self.width, self.y + self.height + 1) do
				self.y = self.y + 1
			end

			self.ySpeed = 0
			onGround = true
			self.coyoteTime = 0.1

            -- Call collision callback.
            if collision1 and collision1.onCollision then
                collision1:onCollision(self)
            end
            if collision2 and collision2.onCollision then
                collision2:onCollision(self)
            end
		end

		-- jumping
		if self.coyoteTime > 0 and ButtonPress("jump") then
			self.ySpeed = jumpSpeed
		end

		if not ButtonIsDown("jump") and self.ySpeed < 0 then
			self.ySpeed = self.ySpeed / 2
		end

		-- ceiling collision
		local headspace = 8
        collision1 = scene:getCollisionAt(
            self.x+self.width,
            self.y - self.height + self.ySpeed*dt + headspace)
        collision2 = scene:getCollisionAt(
            self.x-self.width,
            self.y - self.height + self.ySpeed*dt + headspace)
		if collision1 or collision2 then
			while not scene:getCollisionAt(self.x+self.width, self.y - self.height - 1 + headspace)
			and not scene:getCollisionAt(self.x-self.width, self.y - self.height - 1 + headspace) do
				self.y = self.y - 1
			end

			self.ySpeed = 0

            -- Call collision callback.
            if collision1 and collision1.onCollision then
                collision1:onCollision(self)
            end
            if collision2 and collision2.onCollision then
                collision2:onCollision(self)
            end
		end

		-- integrate y
		self.y = self.y + self.ySpeed*dt

		-- walking
		local walking = false
		if ButtonIsDown("right") then
			if self.xSpeed < maxWalkSpeed then
				if onGround then
					self.xSpeed = self.xSpeed + walkSpeed
					self.direction = 1
				else
					self.xSpeed = self.xSpeed + inAirSpeed
				end
			end
			walking = true
		end
		if ButtonIsDown("left") then
			if self.xSpeed > -1*maxWalkSpeed then
				if onGround then
					self.xSpeed = self.xSpeed - walkSpeed
					self.direction = -1
				else
					self.xSpeed = self.xSpeed - inAirSpeed
				end
			end
			walking = true
		end

		-- wall collision
        collision1 = scene:getCollisionAt(
            self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,
            self.y + self.height-1)
        collision2 = scene:getCollisionAt(
            self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,
            self.y - self.height+headspace)
		if collision1 or collision2 then
			while not scene:getCollisionAt(self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,self.y + self.height-1)
			and not scene:getCollisionAt(self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,self.y - self.height+headspace) do
				self.x = self.x + GetSign(self.xSpeed)
			end

			self.xSpeed = 0

            -- Call collision callback.
            if collision1 and collision1.onCollision then
                collision1:onCollision(self)
            end
            if collision2 and collision2.onCollision then
                collision2:onCollision(self)
            end
		end

		-- animate walking, friction when idling
		if not walking then
			self.xSpeed = self.xSpeed * friction*dt*60
			if math.floor(self.animIndex) ~= 1 and math.floor(self.animIndex) ~= 4 then
				self.animIndex = 1
			end

			local lastAnimIndex = self.animIndex
			self.animIndex = self.animIndex + dt*2
			if math.floor(lastAnimIndex) == 1 and math.floor(self.animIndex) > 1 then
				lastAnimIndex = 4
				self.animIndex = 4
			end
			if math.floor(lastAnimIndex) == 4 and math.floor(self.animIndex) > 4 then
				lastAnimIndex = 1
				self.animIndex = 1
			end
		else
			self.animIndex = math.max(self.animIndex + dt*5, 2)
			if math.floor(self.animIndex) > 3 then
				self.animIndex = 2
			end
		end

		if not onGround then
			if self.ySpeed < 0 then
				self.animIndex = 3
			else
				self.animIndex = 2
			end
		end

		-- integrate x
		self.x = self.x + self.xSpeed*dt

        doCameraMove(self, scene)

        -- Call onTileStay on the tile behind you.
        -- For spikes and shit

        local startI, startJ = scene:coordToTileCoord(
            self.x - self.width,
            self.y - self.height)
        local endI, endJ = scene:coordToTileCoord(
            self.x + self.width,
            self.y + self.height)
        for i = startI, endI do
            for j = startJ, endJ do
                local tile = scene:getTile(i, j)
                if tile and tile.onTileStay then
                    tile:onTileStay(self, scene, i, j)
                end
            end
        end

        -- Get deleted if you die.
        if self.health <= 0 then
            scene:onPlayerDie(self)
            return false
        end
		return true
	end

	self.draw = function (self, scene)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(
            self.sprite.source,
            self.sprite[math.floor(self.animIndex)],
            self.x - scene.camera.x,self.y - scene.camera.y,
            0, self.direction,1, 32,32)
	end

	return self
end

function NewHeadPlayer(x,y)
	local self = {}
	self.sprite = NewAnimatedSprite("assets/robothead.png")
	self.x = x
	self.y = y
	self.xSpeed = 0
	self.ySpeed = 0
	self.animIndex = 1
	self.direction = 1
	self.height = 16
	self.width = 16
	self.coyoteTime = 0
	self.hopHeight = -200
	self.upGrav = 800
	self.downGrav = 4000
	self.headspace = 8
	self.maxWalkSpeed = 120
	self.walkSpeed = 40
	self.inAirSpeed = 15
    self.isPlayer = true
    self.health = 1

	self.update = function (self, scene, dt)
		local maxWalkSpeed = self.maxWalkSpeed
		local walkSpeed = self.walkSpeed
		local inAirSpeed = self.inAirSpeed
		local friction = 0.5

		self.coyoteTime = math.max(self.coyoteTime-dt, 0)

		-- adding graivty
		if self.ySpeed > 0 then
			self.ySpeed = self.ySpeed + dt*self.downGrav
		else
			self.ySpeed = self.ySpeed + dt*self.upGrav
		end

		-- floor collision
		local onGround = false
        local collision1 = scene:getCollisionAt(
            self.x + self.width,
            self.y + self.height + self.ySpeed*dt)
        local collision2 = scene:getCollisionAt(
            self.x - self.width,
            self.y + self.height + self.ySpeed*dt)
		if collision1 or collision2 then
			while not scene:getCollisionAt(self.x+self.width, self.y + self.height + 1)
			and not scene:getCollisionAt(self.x-self.width, self.y + self.height + 1) do
				self.y = self.y + 1
			end

			self.ySpeed = 0
			onGround = true
			self.coyoteTime = 0.1

            -- Call collision callback.
            if collision1 and collision1.onCollision then
                collision1:onCollision(self)
            end
            if collision2 and collision2.onCollision then
                collision2:onCollision(self)
            end
		end

		-- ceiling collision
		local headspace = self.headspace

        collision1 = scene:getCollisionAt(
            self.x+self.width,
            self.y - self.height + self.ySpeed*dt + headspace)
        collision2 = scene:getCollisionAt(
            self.x-self.width,
            self.y - self.height + self.ySpeed*dt + headspace)
		if collision1 or collision2 then
			while not scene:getCollisionAt(self.x+self.width, self.y - self.height - 1 + headspace)
			and not scene:getCollisionAt(self.x-self.width, self.y - self.height - 1 + headspace) do
				self.y = self.y - 1
			end

			self.ySpeed = 0

            -- Call collision callback.
            if collision1 and collision1.onCollision then
                collision1:onCollision(self)
            end
            if collision2 and collision2.onCollision then
                collision2:onCollision(self)
            end
		end

		-- integrate y
		self.y = self.y + self.ySpeed*dt

		-- walking
		local walking = false
		if ButtonIsDown("right") then
			if self.xSpeed < maxWalkSpeed then
				if onGround then
					self.xSpeed = self.xSpeed + walkSpeed
				else
					self.xSpeed = self.xSpeed + inAirSpeed
				end
			end

			self.direction = 1
			if onGround then
				self.ySpeed = self.hopHeight
			end
			walking = true
		end
		if ButtonIsDown("left") then
			if self.xSpeed > -1*maxWalkSpeed then
				if onGround then
					self.xSpeed = self.xSpeed - walkSpeed
				else
					self.xSpeed = self.xSpeed - inAirSpeed
				end
			end

			self.direction = -1
			if onGround then
				self.ySpeed = self.hopHeight
			end
			walking = true
		end

		if not walking and self.ySpeed < 0 then
			self.ySpeed = self.ySpeed / 2
		end

        collision1 = scene:getCollisionAt(
            self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,
            self.y + self.height-1)
        collision2 = scene:getCollisionAt(
            self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,
            self.y - self.height+headspace)
		-- wall collision
		if collision1 or collision2 then
			while not scene:getCollisionAt(self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,self.y + self.height-1)
			and not scene:getCollisionAt(self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,self.y - self.height+headspace) do
				self.x = self.x + GetSign(self.xSpeed)
			end

			self.xSpeed = 0

            -- Call collision callback.
            if collision1 and collision1.onCollision then
                collision1:onCollision(self)
            end
            if collision2 and collision2.onCollision then
                collision2:onCollision(self)
            end
		end

		-- animate walking, friction when idling
		if not walking then
			self.xSpeed = self.xSpeed * friction*dt*60
		end

		self:animate(walking, scene, dt)
		-- integrate x
		self.x = self.x + self.xSpeed*dt

        doCameraMove(self, scene)

        -- Call onTileStay on the tiles behind you.
        -- For spikes and shit
        for m = -1, 1 do
            for n = -1, 1 do
                local i, j = scene:coordToTileCoord(
                    self.x + m * scene.tileSize,
                    self.y + n * scene.tileSize)
                local tile = scene:getTile(i, j)
                if tile and tile.onTileStay then
                    tile:onTileStay(self, scene, i, j)
                end
            end
        end

        -- Get deleted if you die.
        if self.health <= 0 then
            scene:onPlayerDie(self)
            return false
        end
		return true
	end

	self.draw = function (self, scene)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(
            self.sprite.source,
            self.sprite[math.floor(self.animIndex)],
            self.x - scene.camera.x,self.y - scene.camera.y,
            0, self.direction,1, 32,48)
	end

	self.animate = function (self, walking, scene, dt)
		if not walking then
			if math.floor(self.animIndex) ~= 1 and math.floor(self.animIndex) ~= 3 then
				self.animIndex = 1
			end

			local lastAnimIndex = self.animIndex
			self.animIndex = self.animIndex + dt*2
			if math.floor(lastAnimIndex) == 1 and math.floor(self.animIndex) > 1 then
				lastAnimIndex = 3
				self.animIndex = 3
			end
			if math.floor(lastAnimIndex) == 3 and math.floor(self.animIndex) > 3 then
				lastAnimIndex = 1
				self.animIndex = 1
			end
		else
			self.animIndex = 2
		end
	end

	return self
end

function NewOneLegPlayer(x,y)
	local self = NewHeadPlayer(x,y)
	self.sprite = NewAnimatedSprite("assets/robotOneLeg.png")
	self.hopHeight = -550
	self.upGrav = 2000
	self.downGrav = 4000
	self.headspace = 10
	self.height = 32
	self.maxWalkSpeed = 200
	self.walkSpeed = 60

	self.animate = function (self, walking, scene, dt)
	end

	self.draw = function (self, scene)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(
            self.sprite.source,
            self.sprite[math.floor(self.animIndex)],
            self.x - scene.camera.x,self.y - scene.camera.y,
            0, self.direction,1, 32,32)
	end

	return self
end
