require("utils")

function createElevator(x, y, top)
    local elevator = fizz.addKinematic("rect", fizzRect(x, y, 32, 24))
    elevator.startY = y + 16
    elevator.top = top + 16 - 4.5
    elevator.stopTime = 0

    -- elevator particles
    elevator.particles = love.graphics.newParticleSystem(sheet, 32)
    local q = love.graphics.newQuad(176, 144, 8, 8, sheet:getDimensions())
    elevator.particles:setOffset(0, 0)
    elevator.particles:setQuads(q)
    elevator.particles:setParticleLifetime(0.2, 1.5)
    elevator.particles:setLinearAcceleration(-48, 5, 48, 10)
    elevator.particles:setSizes(1.5, 0.75)
    elevator.particles:setColors(0.8, 0.8, 0.8, 1, 0.8, 0.8, 0.8, 0)
    elevator.particles:setEmissionArea("normal", 4, 0)

    function elevator:update(dt, player)
        if love.timer.getTime() - elevator.stopTime < 1 then
            return
        end

        if math.abs(player.body.x - elevator.x) < 4 and player.body.y < elevator.y and elevator.y - player.body.y < 32 then
            if elevator.y < elevator.top then
                elevator.stopTime = love.timer.getTime()
                fizz.setVelocity(elevator, 0, 0)
                fizz.setPosition(elevator, elevator.x, elevator.top)
            else
                fizz.setVelocity(elevator, 0, -256)
                elevator.particles:emit(1)
            end
        elseif elevator.y < elevator.startY then
            fizz.setVelocity(elevator, 0, 48)
        else
            fizz.setVelocity(elevator, 0, 0)
            fizz.setPosition(elevator, elevator.x, elevator.startY)
        end

        -- if elevator.y > elevator.startY then
        --     fizz.setPosition(elevator, 0, elevator.startY)
        --     fizz.setVelocity(elevator, 0, 0)
        -- end
    end

    return elevator
end