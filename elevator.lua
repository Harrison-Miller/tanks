require("utils")

function createElevator(x, y, top)
    local elevator = fizz.addKinematic("rect", fizzRect(x, y, 32, 24))
    elevator.startY = y + 16
    elevator.top = top + 16
    elevator.stopTime = 0

    function elevator:update(dt, player)
        if love.timer.getTime() - elevator.stopTime < 1 then
            return
        end

        if math.abs(player.x - elevator.x) < 4 and player.y < elevator.y and elevator.y - player.y < 32 then
            if elevator.y < elevator.top then
                elevator.stopTime = love.timer.getTime()
                fizz.setVelocity(elevator, 0, 0)
                fizz.setPosition(elevator, elevator.x, elevator.top)
            else
                fizz.setVelocity(elevator, 0, -256)
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