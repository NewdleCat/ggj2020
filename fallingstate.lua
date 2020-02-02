function NewFallingScene()
	local self = {}
	self.player = NewAnimatedSprite("assets/robotwalk.png")
	self.y = 50
	self.color = 0
	self.fadeIn = 1
	self.yFloor = 20000
	self.hit = false
	self.hitTimer = 0
	self.objects = {}

	self.update = function (self, dt)
		if self.y < self.yFloor - 64 then
			self.y = self.y + dt*200
			self.yFloor = 1000-self.y
		else
			if self.hitTimer == 0 then
				ShakeScreen()
			end
			self.hitTimer = self.hitTimer + dt

			if not self.hit and self.hitTimer > 0.65 then
				self.hit = true

				self.objects[#self.objects+1] = { sprite = DeathArmLeft, }
				self.objects[#self.objects+1] = { sprite = DeathArmRight, }
				self.objects[#self.objects+1] = { sprite = NewAnimatedSprite("assets/floatingBodyLeg.png"), }
				self.objects[#self.objects+1] = { sprite = DeathFootRight, }
				self.objects[#self.objects+1] = { sprite = DeathHead, }

				for i=1, #self.objects do
					self.objects[i].x = Width/2
					self.objects[i].y = self.y
					local direction = love.math.random()*math.pi + math.pi
					local speed = love.math.random()*100 + 200
					self.objects[i].angle = love.math.random()*math.pi*2
					self.objects[i].xSpeed = math.cos(direction)*speed*0.5
					self.objects[i].ySpeed = math.sin(direction)*speed*1.25
				end
			end
			self.yFloor = self.y + 64
		end
		if self.hitTimer == 0 then
			self.color = self.color + dt
		end
		self.fadeIn = math.max(self.fadeIn - dt, 0)

		for i=1, #self.objects do
			local o = self.objects[i]
			o.x = o.x + o.xSpeed*dt
			o.ySpeed = o.ySpeed + 100*dt
			o.y = o.y + o.ySpeed*dt
		end

		if self.hitTimer > 5 then
			ChangeScene(GameScene)
            Scene:moveCameraTo(Scene.camera.x, Scene.camera.y + Height*2, 0.000001)
            Scene.player = Scene:add(NewHeadPlayer(Scene.camera.x + Width/2, Scene.camera.y + Height - 64*3))
		end
	end

	self.draw = function (self)
		love.graphics.setColor(HSV(self.color*80, 200,200))
		if self.hitTimer > 0 then
			love.graphics.setColor(1,0,0)
		end
		if self.hit then
			love.graphics.setColor(0,0,0)
		end
		love.graphics.rectangle("fill", 0,0, Width,Height)
		love.graphics.setColor(0,0,0, self.fadeIn)
		love.graphics.rectangle("fill", 0,0, Width,Height)
		if self.hitTimer > 0 then
			love.graphics.setColor(1,1,1)--, Lerp(1,0, 5-self.hitTimer))
		else
			love.graphics.setColor(1,1,1)
		end
		for i=1, #self.objects do
			local o = self.objects[i]
			love.graphics.draw(o.sprite.source, o.sprite[1], o.x,o.y, o.angle, 1,1)
		end
		love.graphics.setColor(1,1,1)
		if not self.hit then
			if self.hitTimer == 0 then
				love.graphics.draw(self.player.source, self.player[7], Width/2, self.y)
			else
				love.graphics.draw(self.player.source, self.player[9], Width/2, self.y)
			end
			love.graphics.setColor(0,0,0)
			love.graphics.rectangle("fill", 0,self.yFloor, Width,Height)
		end
		love.graphics.setColor(1,1,1)
	end

	return self
end