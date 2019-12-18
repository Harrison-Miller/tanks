require("states/game")
require("libs/fizzx.fizz")

init = {}

function init:enter()
    -- Create the server
    serverStarted, server = pcall(sock.newServer, "*", 50132)
    if not serverStarted then
        server = nil
    else
        print("starting server")
        server:setSerialization(bitser.dumps, bitser.loads)
        server:on("connect", function(data, client)
            print("client connected")
            client:send("map", {
                w = server.map.w,
                h = server.map.h,
                tiles = server.map.tiles
            })

            -- Create tank for the new player
            local tank = newTank(server.world, 128, 0, 1)
            tank.owner = client:getConnectId()
            tank.peer = client
            client.tank = tank
            table.insert(server.tanks, tank)
            
            server:sendToAllBut(client, "create_tanks", {
                {
                    x = tank.body.x,
                    y = tank.body.y,
                    spriteRow = tank.spriteRow,
                    owner = tank.owner
                }
            })

            -- Serialize all tanks to send to the new player
            local tanks = {}
            for i, tank in ipairs(server.tanks) do
                tanks[i] = {
                    x = tank.body.x,
                    y = tank.body.y,
                    spriteRow = tank.spriteRow,
                    owner = tank.owner
                }
            end

            client:send("create_tanks", tanks)
        end)
        server:on("disconnect", function(data, client)
            print("client disconnected")
        end)

        -- Init game systems
        server.world = newWorld()
        server.world:setGravity(0, 1000)

        -- Generate the level
        server.map = {}
        server.tanks = {}
        
        server.map.w = math.floor((love.graphics.getWidth()*5)/32)
        server.map.h = math.floor(love.graphics.getHeight()/32)

        server.seed = os.time()
        love.math.setRandomSeed(server.seed)

        server.map.tiles, server.map.elevators = generateRollingHills(server.map.w, server.map.h)
        generateHitboxes(server.map.w, server.map.h, server.map.tiles, server.world)

        gamestate.switch(game)
    end

    -- Create the client
    client = sock.newClient("localhost", 50132)
    client:setSerialization(bitser.dumps, bitser.loads)

    client:on("connect", function(data)
        print("connected to server")
    end)

    client.world = newWorld()
    client.world:setGravity(0, 1000)

    client.tanks = {}

    client:on("map", function(data)
        print("map")
        client.map = {}

        client.map.h = data.h
        client.map.w = data.w
        client.map.tiles = data.tiles

        generateHitboxes(client.map.w, client.map.h, client.map.tiles, client.world)

        gamestate.switch(game)
    end)

    client:on("create_tanks", function(tanks)
        print("create_tanks")

        for _, tank in ipairs(tanks) do
            local owner = tank.owner
            if owner == client:getConnectId() then
                player = newPlayer(client.world, tank.x, tank.y, tank.spriteRow)
                player.owner = owner
                table.insert(client.tanks, player)
            else
                local t = newTank(client.world, tank.x, tank.y, tank.spriteRow)
                t.owner = owner
                table.insert(client.tanks, t)
            end
        end

    end)

    print("attempting to connect to server")
    client:connect()
end

function init:update(dt)
    if server then
        server:update()
    end

    if client then
        client:update()
    end
end