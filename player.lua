require("utils")

require("tank")

function newPlayer(x, y, spriteRow)
    local player = newTank(x, y, spriteRow)

    function player:onTick(dt)
        local left = love.keyboard.isDown("left")
        local right = love.keyboard.isDown("right")
        local jump = love.keyboard.isDown("space")

        if left then
            self:moveLeft(dt)
        end

        if right then
            self:moveRight(dt)
        end

        if jump then
            self:jump()
        end
    end

    return player
end

-- function createPlayer(x, y)
--     -- setup physics objects
--     local player = fizz.addDynamic("rect", fizzRect(x, y, 32, 20))
--     player.friction = 0.1
--     player.name = "player"

--     player.sideSensor = fizz.addDynamic("rect", fizzRect(x, y, 16, 16))
--     player.side = false -- boolean detecting side collision
--     function player.sideSensor:onCollide(b, nx, ny, pen)
--         if b.name and b.name == "ground" then
--             player.side = true
--         end
--         return false
--     end

--     player.cornerSensor = fizz.addDynamic("rect", fizzRect(x, y, 16, 16))
--     player.corner = false -- boolean detecting corner collision
--     function player.cornerSensor:onCollide(b, nx, ny, pen)
--         if b.name and b.name == "ground" then
--             player.corner = true
--         end
--         return false
--     end

--     -- setup animations
--     local g = anim8.newGrid(16, 16, sheet:getWidth(), sheet:getHeight(), 0, 152)
--     player.animation = anim8.newAnimation(g("1-2", 2), 0.2)
--     player.animation:pause()
--     player.facing = 1

--     -- particle system
--     player.dustParticles = love.graphics.newParticleSystem(sheet, 32)
--     local dq = love.graphics.newQuad(168, 144, 8, 8, sheet:getDimensions())
--     player.dustParticles:setOffset(0, 0)
--     player.dustParticles:setQuads(dq)
--     player.dustParticles:setParticleLifetime(0.2, 1)
--     player.dustParticles:setLinearAcceleration(-5, -5, 5, -7)
--     player.dustParticles:setColors(1, 1, 1, 1, 1, 1, 1, 0)
--     -- player.dustParticles:setEmissionRate(4)
--     player.lastTrail = 0

--     -- controls
--     player.grounded = false
--     player.jumping = false

--     function player:update(dt)
--         local left = love.keyboard.isDown("left")
--         local right = love.keyboard.isDown("right")
--         local jump = love.keyboard.isDown("space")

--         local vx, vy = fizz.getVelocity(player)
--         local sx, sy = fizz.getDisplacement(player)

--         player.grounded = false
--         if sy < 0 then
--             player.grounded = true
--             player.jumping = false
--         end

--         local move = 0
--         if left or right then
--             player.animation:resume()
--             if left then
--                 player.facing = -1
--                 move = -speed
--             elseif right then
--                 player.facing = 1
--                 move = speed
--             end

--             if not player.grounded then
--                 move = move/8
--             end

--             if not player.corner and player.side then
--                 vy = -256
--             end

--             if player.grounded and love.timer.getTime() - player.lastTrail >= 0.25 then
--                 player.dustParticles:emit(1)
--                 player.lastTrail = love.timer.getTime()
--             end

--             vx = vx + move*dt
--         else
--             player.animation:pause()
--             player.animation:gotoFrame(1)
--         end

--         -- if (left or right) and player.grounded then
--         --     player.dustParticles:start()
--         -- else
--         --     player.dustParticles:pause()
--         -- end

--         if jump and not player.jumping and player.grounded then
--             player.jumping = true
--             vy = -initJump
--         elseif not jump and player.jumping and not player.grounded then
--             if player.yv < 0 and player.yv < -jumpTerm then
--                 vy = -jumpTerm
--             end
--             player.jumping = false
--         end

--         fizz.setVelocity(player, vx, vy)

--         fizz.setVelocity(player.sideSensor, vx, vy)
--         fizz.setPosition(player.sideSensor, player.x+(16*player.facing), player.y-4)

--         fizz.setVelocity(player.cornerSensor, vx, vy)
--         fizz.setPosition(player.cornerSensor, player.x+(32*player.facing), player.y-32)

--         player.corner = false
--         player.side = false
--     end

--     return player
-- end