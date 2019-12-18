require("../tank")

function newDummy(x, y, spriteRow)
    local dummy = newTank(x, y, spriteRow)
    dummy.nextJump = love.timer.getTime() + love.math.random() * 3
    dummy.nextMove = love.timer.getTime() + love.math.random() * 3
    dummy.direction = 0

    function dummy:onTick(dt)
        local time = love.timer.getTime()
        if dummy.nextJump - time < 0 then
            dummy.nextJump = time + love.math.random() * 2
            self:jump()
        end

        if dummy.nextMove - time < 0 then
            dummy.nextMove = time + love.math.random() * 2
            dummy.direction = love.math.random(-1, 1)
        end

        if dummy.direction == -1 then
            self:moveLeft(dt)
        elseif dummy.direction == 1 then
            self:moveRight(dt)
        end
    end

    return dummy
end