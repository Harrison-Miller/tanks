fizz = require("libs/fizzx.fizz")
anim8 = require("libs/anim8")
require("tiles")
require("utils")
require("terrain")

interval = 1/60
accum = 0

maxJump = 64*3
minJump = 64
maxJumpT = 0.5
g = (2*maxJump)/(maxJumpT^2)
initJump = math.sqrt(2*g*maxJump)
termJump = math.sqrt(initJump^2 + 2*-g*(maxJump-minJump))
termJumpT = maxJump - (2*(maxJump - minJump)/(initJump + termJump))
jumpTerm = termJump
fizz.setGravity(0, g)

speed = 1000

-- The sprite sheet for the whole game
sheet = {}

-- Contains data about the level
level = {}

player = {}



function love.load()
    -- Turn off nasty filter so pixel art still looks good
    love.graphics.setBackgroundColor(178/255, 220/255, 239/255)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    sheet = love.graphics.newImage('sheet.png')
    local g = anim8.newGrid(16, 16, sheet:getWidth(), sheet:getHeight(), 0, 152)

    player = fizz.addDynamic("rect", fizzRect(128, 0, 32, 20))

    player.sideSensor = fizz.addDynamic("rect", fizzRect(128+16, 6, 16, 16))
    function player.sideSensor:onCollide(b, nx, ny, pen)
        if b.name and b.name == "ground" then
            player.side = true
        end
        return false
    end

    player.cornerSensor = fizz.addDynamic("rect", fizzRect(128+16, -16, 16, 16))
    function player.cornerSensor:onCollide(b, nx, ny, pen)
        if b.name and b.name == "ground" then
            player.corner = true
        end
        return false
    end

    -- player.bounce = 0.1
    player.friction = 0.1
    player.animation = anim8.newAnimation(g("1-4", 1), 0.2)
    player.animation:pause()
    player.facing = 1
    player.grounded = false
    player.jumping = false
    player.corner = false
    player.side = false

    function player:update(dt)
        local left = love.keyboard.isDown("left")
        local right = love.keyboard.isDown("right")
        local jump = love.keyboard.isDown("space")

        local vx, vy = fizz.getVelocity(player)
        local sx, sy = fizz.getDisplacement(player)

        player.grounded = false
        if sy < 0 then
            player.grounded = true
            player.jumping = false
        end

        local move = 0
        if left or right then
            player.animation:resume()
            if left then
                player.facing = -1
                move = -speed
            elseif right then
                player.facing = 1
                move = speed
            end

            if not player.grounded then
                move = move/8
            end

            if not player.corner and player.side then
                vy = -256
            end

            vx = vx + move*dt
        else
            player.animation:pause()
            player.animation:gotoFrame(1)
        end

        if jump and not player.jumping and player.grounded then
            player.jumping = true
            vy = -initJump
        elseif not jump and player.jumping and not player.grounded then
            if player.yv < 0 and player.yv < -jumpTerm then
                vy = -jumpTerm
            end
            player.jumping = false
        end

        fizz.setVelocity(player, vx, vy)

        fizz.setVelocity(player.sideSensor, vx, vy)
        fizz.setPosition(player.sideSensor, player.x+(16*player.facing), player.y-2)

        fizz.setVelocity(player.cornerSensor, vx, vy)
        fizz.setPosition(player.cornerSensor, player.x+(32*player.facing), player.y-32)

        player.corner = false
        player.side = false
    end

    -- Get quads of all the level tiles
    level.tileQuads = createTileQuads(sheet:getDimensions())

    -- Generate a level
    level.w = math.floor((love.graphics.getWidth()*5)/32)
    level.h = math.floor(love.graphics.getHeight()/32)
    level.data = {}

    -- seed = 1576396477
    seed = os.time()
    love.math.setRandomSeed(seed)

    level.data = generateRollingHills(level.w, level.h)
end

function love.update(dt)
    accum = accum + dt
    while accum >= interval do
        player:update(interval)
        fizz.update(interval)
        accum = accum - interval
    end

    player.animation:update(dt)
end

function love.draw()
    love.graphics.push()
    love.graphics.translate(-player.x + love.graphics.getWidth()/2, -player.y + love.graphics.getHeight()/2)
    -- Draw the map tiles
    for i,subtable in ipairs(level.data) do
        for j,elem in ipairs(subtable) do
            love.graphics.draw(sheet, level.tileQuads[elem.type], (i-1)*32, (j-1)*32 + 24, 0, 4, 4)
        end
    end

    -- Draw the player tank
    -- love.graphics.draw(sheet, player.frame, player.x, player.y, 0, 4*player.facing, 4, 8, 8)
    player.animation:draw(sheet, player.x, player.y-10, 0, 4*player.facing, 4, 8, 8)

    -- Draw fizz objects
    -- for i, v in ipairs(fizz.statics) do
    --     love.graphics.setColor(0, 127/255, 0, 127/255)
    --     if v.shape == 'rect' then
    --         love.graphics.rectangle('fill', v.x - v.hw, v.y - v.hh, v.hw*2, v.hh*2)
    --     elseif v.shape == 'line' then
    --         love.graphics.line(v.x, v.y, v.x2, v.y2)
    --     end        
    -- end

    -- for i, v in ipairs(fizz.dynamics) do
    --     love.graphics.setColor(127/255, 0, 0, 127/255)
    --     love.graphics.rectangle('fill', v.x - v.hw, v.y - v.hh, v.hw*2, v.hh*2)
    -- end

    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.pop()

    love.graphics.print(love.timer.getFPS() .. " fps", love.graphics.getWidth()-64, 16)
    love.graphics.print("seed: ".. seed, 10, love.graphics.getHeight()-16)
end