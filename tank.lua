local Tank = {}
Tank.__index = Tank

function newTank(world, x, y, spriteRow, speed, jump)
    -- Default values
    x = x or 0
    y = y or 0
    spriteRow = spriteRow or 1
    speed = speed or 500
    jumpVel = jumpVel or 500

    local tank = {} -- the new tank to create
    tank.world = world

    setmetatable(tank, Tank)

    -- Create physics body
    local body = tank.world:addDynamic("circle", x, y, 16)
    body.friction = 0.1
    body.bounce = 0

    tank.body = body

    -- Default control values
    tank.grounded = false
    tank.left = false
    tank.right = false

    tank.jumping = false

    -- Movement variables
    tank.speed = speed
    tank.jumpVel = jumpVel

    -- Create tank animations
    local grid = anim8.newGrid(16, 16, sheet:getWidth(), sheet:getHeight(), 0, 152)

    tank.anims = {}
    tank.anims["move"] = anim8.newAnimation(grid("1-4", spriteRow), 0.2)
    tank.anims["jump"] = anim8.newAnimation(grid("1-4", spriteRow + 1), 0.2)
    tank.anims["idle"] = anim8.newAnimation(grid("1-2", spriteRow + 2), 0.4)

    tank.anim = "idle"

    tank.facing = 1 --Used to flip the sprite 1 is right, -1 is left

    return tank
end

function Tank:tick(dt)
    -- Determine if touching any walls or the floor
    self:resetControls()
    local dx, dy = getDisplacement(self.body)
    
    if dy < 0 then
        self.grounded = true
    end

    if dx > 0 then
        self.left = true
    elseif dx < 0 then
        self.right = true
    end

    self:resetAnimations()

    self:onTick(dt)
end

-- Logic to execute during a physics step
-- put player controls and AI here
function Tank:onTick(dt)
    -- Stub
end

function Tank:update(dt)
    local anim = self.anims[self.anim]
    if anim then
        anim:update(dt)
    end
    self:onUpdate(dt)
end

-- Called once a frame
function Tank:onUpdate(dt)
    -- Stub
end

function Tank:draw()
    local anim = self.anims[self.anim]
    if anim then
        -- Sprite scale 4, origin of original sprite at 8
        local x, y = self.body.x, self.body.y
        anim:draw(sheet, x, y-4, 0, 4*self.facing, 4, 8, 8)
    end
    self:onDraw()
end

-- Called when the tank is drawn
function Tank:onDraw()
    -- Stub
end

function Tank:resetControls()
    self.grounded = false
    self.left = false
    self.right = false
end

function Tank:resetAnimations()
    if self.jumping and self.grounded then
        self.jumping = false
        self.anim = "idle"
    end

    -- calling move always resets to move anim
    if not self.jumping then
        self.anim = "idle"
    end
end

-- Standard tank controls
function Tank:jump()
    if not self.jumping and self.grounded then
        local vx, vy = getVelocity(self.body)

        self.jumping = true
        self.anim = "jump"

        vy = -self.jumpVel
        setVelocity(self.body, vx, vy)
    end

end

function Tank:moveLeft(dt)
    self.facing = -1
    self:move(dt)
end

function Tank:moveRight(dt)
    self.facing = 1
    self:move(dt)
end

-- In the direction already facing
function Tank:move(dt)
    local vx, vy = getVelocity(self.body)
    local move = self.facing*self.speed

    if not self.grounded then
        move = move/4
    end

    if not self.jumping then
        self.anim = "move"
    end

    vx = vx + move*dt
    setVelocity(self.body, vx, vy)
end

-- Network commands
function Tank:setPosition(x, y)
    self.world:setPosition(self.body, x, y)
end