require("tiles")
require("utils")
require("elevator")

-- forward decleration of local functions
local generateTerrainCurve
local fillTerrain
local generateBuildings

function generateRollingHills(w, h)
    local curve = generateTerrainCurve(w, h)
    local data = fillTerrain(w, h, curve)
    local elevators = {}
    -- curve, data, elevators = generateBuildings(w, h, curve, data)
    return data, elevators
end

-- Generate the basic curve of the terrain
generateTerrainCurve = function(w, h)
    local curve = {}

    local longSeed = love.math.random()
    local shortSeed = love.math.random()

    for i=1,w do
        local long = (love.math.noise(((i-1)/16) + longSeed) * h) - 4
        local short = love.math.noise(i + shortSeed) * 3

        local top = math.floor(long + short)
        top = math.max(3, top)

        curve[i] = h - top
    end

    -- Smooth the terrain and get rid of one off jaggies
    for i=2,w-1 do
        local next = curve[i+1]
        if i == level.w then
            next = level.terrain[i]
        end

        local previous = curve[i-1]
        if i == 1 then
            previous = curve[i]
        end

        local current = curve[i]
        if (current < previous and current < next) or (current > previous and current > next) then
            if math.abs(current - previous) < math.abs(current - next) then
                curve[i] = previous
            else
                curve[i] = next
            end
        end
    end

    return curve
end

fillTerrain = function(w, h, curve)
    local data = {}

    local grassSeed = love.math.random()
    local treeSeed = love.math.random()

    for i=1,w do
        data[i] = {}

        top = curve[i]
        
        local grass = love.math.noise(i + grassSeed)
        local tree = love.math.noise(i + treeSeed)

        for j=1,h do
            local offset = (i+ (j*w))%2 -- Offset for autotiling

            if j == top-1 and grass > 0.6 then
                if tree > 0.5 then
                    data[i][j] = { type = tiles.tree.id }
                else
                    data[i][j] = { type = tiles.tallgrass.id }
                end
            elseif j == h then
                data[i][j] = { type = tiles.bedrock.id + offset }
            elseif j == top then
                data[i][j] = { type = tiles.grass.id }
            elseif j > top and j < top + 3 then
                data[i][j] = { type = tiles.dirt.id + offset }
            elseif j > top then
                data[i][j] = { type = tiles.stone.id + offset }
            elseif j < top then
                data[i][j] = { type = tiles.air.id }
            end

        end
    end

    return data
end

function generateHitboxes(w, h, data, world)
    local startI = 1
    local previousTop = 0
    local top = 0

    for i=1,w do
        for j=1,h do
            local type = data[i][j].type
            if type ~= tiles.air.id and type ~= tiles.backwall.id
                and type ~= tiles.elevatorrail.id and type ~= tiles.opendoor.id
                and type ~= tiles.elevatorbottom.id and type ~= tiles.tallgrass.id
                and type ~= tiles.tree.id then
                world:addStatic("rect", fizzRect((i-1)*32, (j-1)*32, 32, 32))
            end
        end
    end

--     for i=1,w do
--         top  = curve[i]
--         if i == 1 then
--             previousTop = top
--         end

--         if previousTop ~= top then
--             local g = fizz.addStatic("rect", fizzRect((startI-1)*32, (previousTop-1)*32 + 24, (i-startI)*32, (h-previousTop+1)*32))
--             g.name = "ground"
--             startI=i
--         end
--         previousTop=top
--     end

--    local g = fizz.addStatic("rect", fizzRect((startI-1)*32, (previousTop-1)*32 + 24, (w+1-startI)*32, (h-previousTop+1)*32))
--     g.name = "ground"

    -- Add level boundaries
    world:addStatic("rect", fizzRect(-32, 0, 32, h*32)) -- left
    world:addStatic("rect", fizzRect(w*32, 0, 32, h*32)) -- right
end

generateBuildings = function(w, h, curve, data)
    local buildings = {}
    local elevators = {}

    local buildingSeed = love.math.random()

    for i=2,w-4 do
        local building = love.math.noise((i*0.66) + buildingSeed)

        if building > 0.85 then
            local spawn = math.max(curve[i], curve[i+1], curve[i+2], curve[i+3])
            -- print("building at x: ", i, " heights: ", curve[i], curve[i+1], curve[i+2], curve[i+3])
            
            if buildings[i-1] and buildings[i-1].exists then
                buildings[i-1].length = buildings[i-1].length + 1
            elseif buildings[i-2] and buildings[i-2].exists then
                buildings[i-2].length = buildings[i-2].length + 2
            elseif buildings[i-3] and buildings[i-3].exists then
                buildings[i-3].length = buildings[i-3].length + 3
            elseif buildings[i-4] and buildings[i-4].exists then
                buildings[i-4].length = buildings[i-4].length + 4
            else
                buildings[i] = { height = spawn, exists = true, length = 4 }
            end
        else
            buildings[i] = {height = 0, exists = false, length = 0}
        end
    end

    for i,b in pairs(buildings) do
        if b.exists then
            local spawn = b.height
            local length = b.length

            -- Make basic building
            for x=i,i+length-1 do
                for y=spawn-2,spawn+1 do
                    if y == spawn+2 then
                        data[x][y] = { type = tiles.bedrock.id }
                    elseif y == spawn+1 then
                        data[x][y] = { type = tiles.floor.id }
                    elseif (x > i and x < i+length-1) and (y>spawn-2) then
                        data[x][y] = { type = tiles.backwall.id }
                    else
                        data[x][y] = { type = tiles.brick.id }
                    end
                end

            end

            local roofX = (i-1)*32
            local roofW = length*32
            local elevLeft = false
            local elevRight = false

            -- Make doors
            if curve[i-1] >= spawn then
                local t = spawn + 1
                if curve[i-1] == spawn then
                    t = spawn
                end
                data[i][t-2] = { type = tiles.bulkhead.id } -- Bulkhead

                
                if t == spawn then
                    roofX = roofX + 32
                    roofW = roofW - 32
                end
                fizz.addStatic("rect", fizzRect((i-1)*32, (t-3)*32 + 24, 32, 32)) -- we don't wnat this to be ground because it'll interfere with climbing

                data[i][t-1] = { type = tiles.opendoor.id } -- Open Door
                data[i][t] = { type = tiles.doorbottom.id } -- Door bottom

                if t == spawn then
                    g = fizz.addStatic("rect", fizzRect((i-1)*32, (t-1)*32 + 24, 32, 32))
                    g.name = "ground"
                end
            else
                data[i][spawn+1] = { type = tiles.elevatorbottom.id } -- Elevator base
                data[i][spawn] = { type = tiles.elevatorrail.id } -- Elevator rail
                data[i][spawn-1] = { type = tiles.elevatorrail.id } -- Elevator rail
                data[i][spawn-2] = { type = tiles.elevatorrail.id } -- Elevator rail

                for e=curve[i],spawn-2 do
                    data[i][e] = { type = tiles.elevatorrail.id } -- Elevator rail
                end

                local elevTop = math.min(spawn-3, curve[i]-1)
                table.insert(elevators, createElevator((i-1)*32, (spawn)*32 + 24, elevTop*32 + 24))
                elevLeft = true

                roofX = roofX + 32
                roofW = roofW - 32
            end

            if curve[i-1] - spawn >= 4 then
                data[i-1][spawn+1] = { type = tiles.platform.id } 
            end

            if curve[i+length] >= spawn then
                local t = spawn + 1
                if curve[i+length] == spawn then
                    t = spawn
                end
                data[i+length-1][t-2] = { type = tiles.bulkhead.id } -- Bulkhead

                if t == spawn then
                    roofW = roofW - 32
                end

                fizz.addStatic("rect", fizzRect((i+length-2)*32, (t-3)*32 + 24, 32, 32))

                data[i+length-1][t-1] = { type = tiles.opendoor.id } -- Open Door
                data[i+length-1][t] = { type = tiles.doorbottom.id } -- Door bottom

                if t == spawn then
                    g = fizz.addStatic("rect", fizzRect((i+length-2)*32, (t-1)*32 + 24, 32, 32))
                    g.name = "ground"
                end
            else
                data[i+length-1][spawn+1] = { type = tiles.elevatorbottom.id } -- Elevator base
                data[i+length-1][spawn] = { type = tiles.elevatorrail.id } -- Elevator rail
                data[i+length-1][spawn-1] = { type = tiles.elevatorrail.id } -- Elevator rail
                data[i+length-1][spawn-2] = { type = tiles.elevatorrail.id } -- Elevator rail

                for e=curve[i+length-1],spawn-2 do
                    data[i+length-1][e] = { type = tiles.elevatorrail.id } -- Elevator rail
                end

                
                local elevTop = math.min(spawn-3, curve[i+length-1]-1)
                table.insert(elevators, createElevator((i+length-2)*32, (spawn)*32 + 24, elevTop*32 + 24))
                elevRight = true

                roofW = roofW - 32
            end

            if curve[i+length] - spawn >= 4 then
                data[i+length][spawn+1] = { type = tiles.platform.id } 
            end

            for x=i,i+length-1 do
                if ((elevLeft and x~=i) or not elevLeft) and ((elevRight and x~=i+length-1) or not elevRight) then
                    if curve[x] < spawn-2 then
                        g = fizz.addStatic("rect", fizzRect((x-1)*32, (curve[x]-1)*32 + 24, 32, (spawn-2-curve[x])*32))
                        g.name = "ground"
                    end
                end
                curve[x] = spawn+1
            end
            
            g = fizz.addStatic("rect", fizzRect(roofX, (spawn-3)*32 + 24, roofW, 32))
            g.name = "ground"
        end
    end

    return curve, data, elevators
end