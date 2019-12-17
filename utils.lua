-- takes x, y, w, h returns x, y, hw, hh
function fizzRect(x, y, w, h)
    return x + w/2, y + h/2, w/2, h/2
end

function fizzDebug()
    -- Draw fizz objects
    love.graphics.setColor(0, 127/255, 0, 127/255)
    for i, v in ipairs(fizz.statics) do
        if v.shape == "rect" then
            love.graphics.rectangle("fill", v.x - v.hw, v.y - v.hh, v.hw*2, v.hh*2)
        elseif v.shape == "line" then
            love.graphics.line(v.x, v.y, v.x2, v.y2)
        end        
    end

    love.graphics.setColor(127/255, 0, 0, 127/255)
    for i, v in ipairs(fizz.dynamics) do
        if v.shape == "rect" then
            love.graphics.rectangle("fill", v.x - v.hw, v.y - v.hh, v.hw*2, v.hh*2)
        elseif v.shape == "circle" then
            love.graphics.circle("fill", v.x, v.y, v.r)
        end
    end

    love.graphics.setColor(0, 0, 127/255, 127/255)
    for i, v in ipairs(fizz.kinematics) do
        love.graphics.rectangle("fill", v.x - v.hw, v.y - v.hh, v.hw*2, v.hh*2)
    end

    love.graphics.setColor(1, 1, 1, 1)
end