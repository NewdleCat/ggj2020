function NewPlayer(x,y)
	local self = {}
	self.sprite = love.graphics.newImage("assets/robot.png")
	self.x = x
	self.y = y
	self.xSpeed = 0
	self.ySpeed = 0

	self.update = function (self, dt)
		return true
	end

	self.draw = function (self)
	end

	return self
end