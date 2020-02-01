
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
        if self.y + self.height - scene.camera.y > Height then
            scene:moveCameraTo(scene.camera.x, scene.camera.y + Height)
        end
        if self.y - scene.camera.y < 0 then
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
		if scene:isCollisionAt(self.x+self.width,self.y + self.height + self.ySpeed*dt)
		or scene:isCollisionAt(self.x-self.width,self.y + self.height + self.ySpeed*dt) then
			while not scene:isCollisionAt(self.x+self.width, self.y + self.height + 1)
			and not scene:isCollisionAt(self.x-self.width, self.y + self.height + 1) do
				self.y = self.y + 1
			end

			self.ySpeed = 0
			onGround = true
			self.coyoteTime = 0.1
		end

		-- jumping
		if self.coyoteTime > 0 and ButtonPress("a") then
			self.ySpeed = jumpSpeed
		end

		if not ButtonIsDown("a") and self.ySpeed < 0 then
			self.ySpeed = self.ySpeed / 2
		end

		-- ceiling collision
		local headspace = 8
		if scene:isCollisionAt(self.x+self.width,self.y - self.height + self.ySpeed*dt + headspace)
		or scene:isCollisionAt(self.x-self.width,self.y - self.height + self.ySpeed*dt + headspace) then
			while not scene:isCollisionAt(self.x+self.width, self.y - self.height - 1 + headspace)
			and not scene:isCollisionAt(self.x-self.width, self.y - self.height - 1 + headspace) do
				self.y = self.y - 1
			end

			self.ySpeed = 0
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
		if scene:isCollisionAt(self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,self.y + self.height-1)
		or scene:isCollisionAt(self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,self.y - self.height+headspace) then
			while not scene:isCollisionAt(self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,self.y + self.height-1)
			and not scene:isCollisionAt(self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,self.y - self.height+headspace) do
				self.x = self.x + GetSign(self.xSpeed)
			end

			self.xSpeed = 0
		end

		-- animate walking, friction when idling
		if not walking then
			self.xSpeed = self.xSpeed * friction*dt*60
			self.animIndex = 1
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

	self.update = function (self, scene, dt)
		local maxWalkSpeed = 120
		local walkSpeed = 40
		local inAirSpeed = 15
		local friction = 0.5
		local jumpSpeed = -550

		self.coyoteTime = math.max(self.coyoteTime-dt, 0)

		-- adding graivty
		if self.ySpeed > 0 then
			self.ySpeed = self.ySpeed + dt*4000
		else
			self.ySpeed = self.ySpeed + dt*800
		end

		-- floor collision
		local onGround = false
		if scene:isCollisionAt(self.x+self.width,self.y + self.height + self.ySpeed*dt)
		or scene:isCollisionAt(self.x-self.width,self.y + self.height + self.ySpeed*dt) then
			while not scene:isCollisionAt(self.x+self.width, self.y + self.height + 1)
			and not scene:isCollisionAt(self.x-self.width, self.y + self.height + 1) do
				self.y = self.y + 1
			end

			self.ySpeed = 0
			onGround = true
			self.coyoteTime = 0.1
		end

		-- ceiling collision
		local headspace = 8
		if scene:isCollisionAt(self.x+self.width,self.y - self.height + self.ySpeed*dt + headspace)
		or scene:isCollisionAt(self.x-self.width,self.y - self.height + self.ySpeed*dt + headspace) then
			while not scene:isCollisionAt(self.x+self.width, self.y - self.height - 1 + headspace)
			and not scene:isCollisionAt(self.x-self.width, self.y - self.height - 1 + headspace) do
				self.y = self.y - 1
			end

			self.ySpeed = 0
		end

		-- integrate y
		self.y = self.y + self.ySpeed*dt

		-- walking
		local walking = false
		local hopHeight = -200
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
				self.ySpeed = hopHeight
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
				self.ySpeed = hopHeight
			end
			walking = true
		end

		if not ButtonIsDown("left") and not ButtonIsDown("right") and self.ySpeed < 0 then
			self.ySpeed = self.ySpeed / 2
		end

		-- wall collision
		if scene:isCollisionAt(self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,self.y + self.height-1)
		or scene:isCollisionAt(self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,self.y - self.height+headspace) then
			while not scene:isCollisionAt(self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,self.y + self.height-1)
			and not scene:isCollisionAt(self.x+self.width*GetSign(self.xSpeed) + self.xSpeed*dt,self.y - self.height+headspace) do
				self.x = self.x + GetSign(self.xSpeed)
			end

			self.xSpeed = 0
		end

		-- animate walking, friction when idling
		if not walking then
			self.xSpeed = self.xSpeed * friction*dt*60
			self.animIndex = 1
		else
			self.animIndex = 2
		end

		-- integrate x
		self.x = self.x + self.xSpeed*dt

        doCameraMove(self, scene)
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

	return self
end
