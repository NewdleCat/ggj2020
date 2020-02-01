function NewPlayer(x,y)
	local self = {}
	self.sprite = love.graphics.newImage("assets/robot.png")
	self.x = x
	self.y = y
	self.xSpeed = 0
	self.ySpeed = 0

	self.update = function (self, dt)
		local walkSpeed = 250
		local friction = 0.825

		self.xSpeed = self.xSpeed * friction*dt*60

		if ButtonIsDown("right") then
			self.xSpeed = walkSpeed
		end
		if ButtonIsDown("left") then
			self.xSpeed = -1*walkSpeed
		end

		self.x = self.x + self.xSpeed*dt
		self.y = self.y + self.ySpeed*dt

		return true
	end

	self.draw = function (self)
		love.graphics.setColor(1,1,1)
		love.graphics.draw(self.sprite, self.x,self.y, 0, 1,1, 32,32)
	end

	return self
end