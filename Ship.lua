function NewShip(x, y)
    local ret = NewTrigger {
        x = x,
        y = y,
        vy = 0,
        sprite = ShipSprite,
        width = 64,
        height = 64,
        animIndex = 1,
        playerInShip = false,
        onTriggerEnter = function(self, scene, other)
            self.playerInShip = true
            scene.win = true
            scene.winTime = scene.time
            Music:stop()
            Music = MusicPalindroid
            Music:stop()
            Music:play()
        end
    }

    ret.draw = function(self, scene)
		love.graphics.draw(
            self.sprite.source,
            self.sprite[self.animIndex],
            self.x - scene.camera.x,self.y - scene.camera.y - 28,
            0, 1,1, 32,32)
    end

    local oldUpdate = ret.update
    ret.update = function(self, scene, dt)
        oldUpdate(self, scene, dt)
        if self.playerInShip then
            self.animIndex = 2
            self.y = self.y + self.vy * dt
            self.vy = self.vy - 256 * dt
            if scene.player then
                scene.player.shouldDestroy = true
            end
        end
        return true
    end
    
    return ret
end
