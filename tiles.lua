require("libs/enum")

tiles = enum({
    'bedrock',
    'bedrock2',
    'stone',
    'stone2',
    'dirt',
    'dirt2',
    'grass',
    'air',
    'tallgrass',
    'tree',
    'brick',
    'backwall',
    'floor',
    'opendoor',
    'bulkhead',
    'doorbottom',
    'elevatorbottom',
    'elevatorrail'
})

function createTileQuads(w, h)
    local quads = {}

    quads[tiles.bedrock.id] = love.graphics.newQuad(72, 160, 8, 8, w, h) -- Bedrock
    quads[tiles.bedrock2.id] = love.graphics.newQuad(72, 168, 8, 8, w, h) -- Bedrock 2
    quads[tiles.stone.id] = love.graphics.newQuad(80, 160, 8, 8, w, h) -- Stone
    quads[tiles.stone2.id] = love.graphics.newQuad(80, 168, 8, 8, w, h) -- Stone 2
    quads[tiles.dirt.id] = love.graphics.newQuad(88, 160, 8, 8, w, h) -- Dirt
    quads[tiles.dirt2.id] = love.graphics.newQuad(88, 168, 8, 8, w, h) -- Dirt 2
    quads[tiles.grass.id] = love.graphics.newQuad(96, 160, 8, 8, w, h) -- Grass
    quads[tiles.air.id] = love.graphics.newQuad(152, 176, 8, 8, w, h) -- Air
    quads[tiles.tallgrass.id] = love.graphics.newQuad(96, 152, 8, 8, w, h) -- Tall Grass
    quads[tiles.tree.id] = love.graphics.newQuad(112, 152, 8, 8, w, h) -- Tree
    quads[tiles.brick.id] = love.graphics.newQuad(96, 176, 8, 8, w, h) -- Brick
    quads[tiles.backwall.id] = love.graphics.newQuad(120, 184, 8, 8, w, h) -- Backwall
    quads[tiles.floor.id] = love.graphics.newQuad(112, 192, 8, 8, w, h) -- Floor
    quads[tiles.opendoor.id] = love.graphics.newQuad(104, 184, 8, 8, w, h) -- Open Door
    quads[tiles.bulkhead.id] = love.graphics.newQuad(104, 176, 8, 8, w, h) -- Bulkhead
    quads[tiles.doorbottom.id] = love.graphics.newQuad(104, 192, 8, 8, w, h) -- Door bottom
    quads[tiles.elevatorbottom.id] = love.graphics.newQuad(136, 192, 8, 8, w, h) -- Elevator bottom
    quads[tiles.elevatorrail.id] = love.graphics.newQuad(136, 184, 8, 8, w, h) -- Elevator rail

    return quads
end