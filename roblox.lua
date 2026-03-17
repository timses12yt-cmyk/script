local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- SETTINGS
local ORB_COUNT = 220
local RADIUS = 60
local SPEED = 0.25

local enabled = true
local connection

local orbs = {}

local function createOrb()

    local part = Instance.new("Part")
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(1.4,1.4,1.4)
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(255,255,255)
    part.Transparency = 0.15
    part.Parent = workspace

    local data = {
        part = part,
        offset = Vector3.new(
            math.random(-RADIUS,RADIUS),
            math.random(-RADIUS,RADIUS),
            math.random(-RADIUS,RADIUS)
        ),
        vel = Vector3.new(
            math.random(-10,10)/50,
            math.random(-10,10)/50,
            math.random(-10,10)/50
        )
    }

    table.insert(orbs,data)

end

local function spawnOrbs()

    for i=1,ORB_COUNT do
        createOrb()
    end

end

local function removeOrbs()

    for _,v in pairs(orbs) do
        if v.part then
            v.part:Destroy()
        end
    end

    orbs = {}

end

local function start()

    spawnOrbs()

    connection = RunService.RenderStepped:Connect(function()

        if not camera then return end

        local cam = camera.CFrame.Position

        for _,v in pairs(orbs) do

            local p = v.part

            if p then

                v.offset += v.vel * SPEED

                if v.offset.Magnitude > RADIUS then
                    v.offset = Vector3.new(
                        math.random(-RADIUS,RADIUS),
                        math.random(-RADIUS,RADIUS),
                        math.random(-RADIUS,RADIUS)
                    )
                end

                p.Position = cam + v.offset

            end

        end

    end)

end

local function stop()

    if connection then
        connection:Disconnect()
        connection = nil
    end

    removeOrbs()

end

start()

UIS.InputBegan:Connect(function(input,gp)

    if gp then return end

    if input.KeyCode == Enum.KeyCode.F8 then

        enabled = not enabled

        if enabled then
            start()
        else
            stop()
        end

    end

end)
