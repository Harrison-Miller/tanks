anim8 = require("libs/anim8")
sock = require("libs/sock")
bitser = require("libs/bitser")
Gamestate = require("../libs/hump/gamestate")
require("states/init")

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

speed = 1000

seed = 0

-- Contains data about the level
level = {}

function love.load()
    -- serverStarted, server = pcall(sock.newServer, "*", 50132)
    -- print(serverStarted)
    -- if not serverStarted then
    --     server = nil
    --     client = sock.newClient("localhost", 50132)
    --     client:setSerialization(bitser.dumps, bitser.loads)
    --     client:on("connect", function(data)
    --         print("connected to server")
            
    --     end)
    --     client:on("level", function(data)
    --         level.data = data.tiles
    --         level.elevators = data.elevators
    --         fizz.statics = data.statics

    --         table.insert(tanks, newTank(128, 0, 1))
    --         player = newPlayer(200, 0, 3)
    --         table.insert(tanks, player)
    --     end)
    --     client:connect()
    -- else
    --     print("server started")
    --     server:setSerialization(bitser.dumps, bitser.loads)
    --     server:on("connect", function(data, client)
    --         client:send("level", {
    --             tiles = level.data,
    --             -- elevators = level.elevators,
    --             statics = fizz.statics
    --         })

    --         table.insert(tanks, newTank(200, 0, 3))
    --     end)
    -- end

    -- Turn off nasty filter so pixel art still looks good
    love.graphics.setBackgroundColor(178/255, 220/255, 239/255)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    sheet = love.graphics.newImage('sheet.png')
    elevatorQuad = love.graphics.newQuad(72, 192, 8, 8, sheet:getDimensions())

    -- Get quads of all the level tiles
    tileQuads = createTileQuads(sheet:getDimensions())

    Gamestate.switch(init)

    -- -- Generate a level
    -- level.w = math.floor((love.graphics.getWidth()*5)/32)
    -- level.h = math.floor(love.graphics.getHeight()/32)
    -- level.data = {}

    -- -- seed = 1576471146
    -- if server then
    --     seed = os.time()
    --     love.math.setRandomSeed(seed)

    --     level.data, level.elevators = generateRollingHills(level.w, level.h)
    -- end

    -- tanks = {}

    -- if server then
    --     player = newPlayer(128, 0, 1)
    --     table.insert(tanks, player)
    -- end
end

function love.update(dt)
    Gamestate.update(dt)
    -- accum = accum + dt
    -- while accum >= interval do
    --     for i,t in ipairs(tanks) do
    --         t:tick(dt)
    --     end

    --     if level.elevators then
    --         for i,e in ipairs(level.elevators) do
    --             e:update(interval, player)
    --         end
    --     end
    --     fizz.update(interval)
    --     accum = accum - interval
    -- end

    -- if server then
    --     server:update()
    -- else
    --     client:update()
    -- end

    -- for i,t in ipairs(tanks) do
    --     t:update(dt)
    -- end

    -- if level.elevators then
    --     for i,e in ipairs(level.elevators) do
    --         e.particles:update(dt)
    --     end
    -- end
    -- tick = tick + 1
end

function love.draw()
    Gamestate.draw()
    -- love.graphics.push()

    -- if player then
    --     local cameraY =  -player.body.y + love.graphics.getHeight()/2
    --     cameraY = math.max(cameraY, 0)

    --     local cameraX = -player.body.x + love.graphics.getWidth()/2
    --     cameraX = math.min(cameraX, 0)
    --     -- if cameraX < 0 then
    --     --     print(cameraX, -level.w*32 + love.graphics.getWidth()/2 + 48)
    --     --     cameraX = math.max(cameraX, -level.w*32 + love.graphics.getWidth()/2 + 48)
    --     -- end

    --     love.graphics.translate(cameraX, cameraY)
    -- end

    -- -- Draw the map tiles
    -- for i,subtable in ipairs(level.data) do
    --     for j,elem in ipairs(subtable) do
    --         love.graphics.draw(sheet, level.tileQuads[elem.type], (i-1)*32, (j-1)*32 + 24, 0, 4, 4)
    --     end
    -- end

    -- if level.elevators then
    --     for i,e in ipairs(level.elevators) do
    --         love.graphics.draw(sheet, elevatorQuad, e.x, e.y-8, 0, 4, 4, 4, 4)
    --         e.particles:setPosition(e.x, e.y-8)
    --         love.graphics.draw(e.particles)
    --     end
    -- end

    -- for i,t in ipairs(tanks) do
    --     t:draw()
    -- end

    -- fizzDebug()

    -- love.graphics.pop()

    -- love.graphics.print(love.timer.getFPS() .. " fps", love.graphics.getWidth()-64, 16)
    -- love.graphics.print("seed: ".. seed, 10, love.graphics.getHeight()-16)

    -- if player then
    --     love.graphics.print("x: " .. math.floor(player.body.x) .. " y: " .. math.floor(player.body.y), 10, love.graphics.getHeight()-48)
    -- end
end

function love.quit()
    if client then
        client:disconnectNow()
    end
end