fizz = require("libs/fizzx.fizz")
anim8 = require("libs/anim8")
require("tiles")
require("utils")
require("terrain")
require("player")
require("bots/dummy")

tick = 0
interval = 1/60
accum = 0

maxJump = 64*3
minJump = 64
maxJumpT = 0.5
grav = (2*maxJump)/(maxJumpT^2)
initJump = math.sqrt(2*grav*maxJump)
termJump = math.sqrt(initJump^2 + 2*-grav*(maxJump-minJump))
termJumpT = maxJump - (2*(maxJump - minJump)/(initJump + termJump))
jumpTerm = termJump
fizz.setGravity(0, 1000)

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
    elevatorQuad = love.graphics.newQuad(72, 192, 8, 8, sheet:getDimensions())

    player = createPlayer(128, 0)

    -- Get quads of all the level tiles
    level.tileQuads = createTileQuads(sheet:getDimensions())

    -- Generate a level
    level.w = math.floor((love.graphics.getWidth()*5)/32)
    level.h = math.floor(love.graphics.getHeight()/32)
    level.data = {}

    -- seed = 1576471146
    seed = os.time()
    love.math.setRandomSeed(seed)

    level.data, level.elevators = generateRollingHills(level.w, level.h)

    tanks = {}
    for i=1,4 do
         table.insert(tanks, newDummy(400 + 50*i, 100))
    end
end

function love.update(dt)
    accum = accum + dt
    while accum >= interval do
        for i,t in ipairs(tanks) do
            t:tick(dt)
        end

        player:update(interval)
        for i,e in ipairs(level.elevators) do
            e:update(interval, player)
        end
        fizz.update(interval)
        accum = accum - interval
    end

    for i,t in ipairs(tanks) do
        t:update(dt)
    end
    player.animation:update(dt)
    player.dustParticles:update(dt)
    for i,e in ipairs(level.elevators) do
        e.particles:update(dt)
    end
    tick = tick + 1
end

function love.draw()
    love.graphics.push()

    local cameraY =  -player.y + love.graphics.getHeight()/2
    cameraY = math.max(cameraY, 0)

    local cameraX = -player.x + love.graphics.getWidth()/2
    cameraX = math.min(cameraX, 0)
    -- if cameraX < 0 then
    --     print(cameraX, -level.w*32 + love.graphics.getWidth()/2 + 48)
    --     cameraX = math.max(cameraX, -level.w*32 + love.graphics.getWidth()/2 + 48)
    -- end

    love.graphics.translate(cameraX, cameraY)
    -- Draw the map tiles
    for i,subtable in ipairs(level.data) do
        for j,elem in ipairs(subtable) do
            love.graphics.draw(sheet, level.tileQuads[elem.type], (i-1)*32, (j-1)*32 + 24, 0, 4, 4)
        end
    end

    for i,e in ipairs(level.elevators) do
        love.graphics.draw(sheet, elevatorQuad, e.x, e.y-8, 0, 4, 4, 4, 4)
        e.particles:setPosition(e.x, e.y-8)
        love.graphics.draw(e.particles)
    end

    for i,t in ipairs(tanks) do
        t:draw()
    end

    -- Draw the player tank
    -- love.graphics.draw(sheet, player.frame, player.x, player.y, 0, 4*player.facing, 4, 8, 8)
    player.animation:draw(sheet, player.x, player.y, 0, 4*player.facing, 4, 8, 8)
    player.dustParticles:setPosition(player.x-16*player.facing, player.y)
    love.graphics.draw(player.dustParticles)

    -- fizzDebug()

    love.graphics.pop()

    love.graphics.print(love.timer.getFPS() .. " fps", love.graphics.getWidth()-64, 16)
    love.graphics.print("seed: ".. seed, 10, love.graphics.getHeight()-16)
    love.graphics.print("x: " .. math.floor(player.x) .. " y: " .. math.floor(player.y), 10, love.graphics.getHeight()-48)
end