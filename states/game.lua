Camera = require("libs/hump/camera")

game = {}

function game:enter()
    if server then
        server:on("position", function(data, client)
            if client.tank then
                client.tank:setPosition(data.x, data.y)
                server:sendToAllBut(client, "position", data)
            end
        end)
    end

    if client then
        camera = Camera(client.map.w/2, client.map.h/2)
        client:on("position", function(data)
            local owner = data.owner
            for _, tank in ipairs(client.tanks) do
                if tank.owner == owner then
                    tank:setPosition(data.x, data.y)
                    break
                end
            end
        end)
    end
end

function game:update(dt)
    if server then
        server:update()
    end

    if client then
        client:update()

        -- do physics updates
        accum = accum + dt
        while accum >= interval do
            for _, tank in ipairs(client.tanks) do
                tank:tick(dt)
            end

            client.world:update(interval)
            accum = accum - interval
        end

        -- do once a frame updates
        for _, tank in ipairs(client.tanks) do
            tank:update(dt)
        end

        -- send player updates to server
        if player then
            camera:lockPosition(player.body.x, player.body.y, Camera.smooth.damped(10))
            camera.x = math.max(camera.x, love.graphics.getWidth()/2)
            camera.x = math.min(camera.x, client.map.w*32 - love.graphics.getWidth()/2)
            camera.y = math.min(camera.y, love.graphics.getHeight()/2 - 32)

            client:send("position", {
                owner = player.owner,
                x = player.body.x,
                y = player.body.y
            })
        end

    end
end

function game:draw(dt)
    if server then
    end

    if client.map then
        camera:attach()

        -- Draw the map
        for i, col in ipairs(client.map.tiles) do
            for j, tile in ipairs(col) do
                love.graphics.draw(sheet, tileQuads[tile.type], (i-1)*32, (j-1)*32, 0, 4, 4)
            end
        end

        -- Draw the tanks
        if client.tanks then
            for i, tank in ipairs(client.tanks) do
                tank:draw()
            end
        end

        fizzDebug(client.world)

        camera:detach()


        love.graphics.print(love.timer.getFPS() .. " fps", love.graphics.getWidth()-64, 16)

        -- love.graphics.print("ping: " .. client:getRoundTripTime() .. " ms", 10, love.graphics.getHeight()-96)

        if player then
            love.graphics.print("x: " .. math.floor(player.body.x) .. " y: " .. math.floor(player.body.y), 10, love.graphics.getHeight()-48)
        end

        love.graphics.print("seed: ".. seed, 10, love.graphics.getHeight()-16)
    end
end