-- Nez0x UI - ПОЛНАЯ ВЕРСИЯ (ИСПРАВЛЕНО)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "Nez0xUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Затемнение
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

-- Главный контейнер
local main = Instance.new("Frame")
main.Name = "Main"
main.BackgroundTransparency = 1
main.Size = UDim2.new(1, 0, 1, 0)
main.Parent = gui

-- Затемнение фона
local bgDim = Instance.new("Frame")
bgDim.Name = "BackgroundDim"
bgDim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bgDim.BackgroundTransparency = 0.5
bgDim.Size = UDim2.new(1, 0, 1, 0)
bgDim.Parent = main

-- Контейнер для UI
local uiContainer = Instance.new("Frame")
uiContainer.Name = "UIContainer"
uiContainer.BackgroundTransparency = 1
uiContainer.Size = UDim2.new(0, 1650, 0, 700)
uiContainer.Position = UDim2.new(0.5, -825, 0.5, -350)
uiContainer.Parent = main

-- Функция создания колонки со скроллом
local function createColumn(name, xPos, yPos, width)
    width = width or 200
    
    local col = Instance.new("Frame")
    col.Name = name .. "Column"
    col.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    col.BackgroundTransparency = 0.1
    col.BorderSizePixel = 0
    col.Position = UDim2.new(0, xPos, 0, yPos)
    col.Size = UDim2.new(0, width, 0, 550)
    col.Parent = uiContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = col
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1
    stroke.Parent = col
    
    local colTitle = Instance.new("TextLabel")
    colTitle.Name = "Title"
    colTitle.BackgroundTransparency = 1
    colTitle.Font = Enum.Font.Gotham
    colTitle.Text = name
    colTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    colTitle.TextSize = 18
    colTitle.Position = UDim2.new(0, 15, 0, 10)
    colTitle.Size = UDim2.new(1, -30, 0, 25)
    colTitle.Parent = col
    
    local scrollingContainer = Instance.new("ScrollingFrame")
    scrollingContainer.Name = name .. "Scrolling"
    scrollingContainer.BackgroundTransparency = 1
    scrollingContainer.BorderSizePixel = 0
    scrollingContainer.Position = UDim2.new(0, 0, 0, 40)
    scrollingContainer.Size = UDim2.new(1, 0, 1, -45)
    scrollingContainer.CanvasSize = UDim2.new(0, 0, 2, 0) -- Увеличиваем размер холста
    scrollingContainer.ScrollBarThickness = 6
    scrollingContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
    scrollingContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Автоматический размер
    scrollingContainer.Parent = col
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = scrollingContainer
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    return {frame = col, scrolling = scrollingContainer, layout = layout}
end

-- Создаем 7 колонок
local startX = 30
local gap = 215
local colY = 30

local cols = {
    Combat = createColumn("COMBAT", startX, colY, 210),
    Movement = createColumn("MOVEMENT", startX + gap, colY, 210),
    Visuals = createColumn("VISUALS", startX + gap*2, colY, 210),
    Player = createColumn("PLAYER", startX + gap*3, colY, 210),
    ESP = createColumn("ESP", startX + gap*4, colY, 220),
    Misc = createColumn("MISC", startX + gap*5, colY, 230),
    Theme = createColumn("THEME", startX + gap*6 + 10, colY, 250),
}

-- Функции
local features = {
    aimbot = false,
    teamCheck = false,
    fly = false,
    noclip = false,
    infJump = false,
    fullbright = false,
    blur = false,
    clickTp = false,
    
    aimbotSpeed = 0.5,
    aimbotFOV = 90,
    aimbotShowFOV = false,
    
    flySpeed = 50,
    flyAntiKick = false,
    
    noclipAntiKick = false,
    
    espEnabled = false,
    espMode = "Обводка",
    espShowName = true,
    espShowHealth = true,
    espShowDistance = false,
    espColor = Color3.fromRGB(255, 80, 80),
    espTracerColor = Color3.fromRGB(80, 140, 255),
    espTeamColor = Color3.fromRGB(80, 255, 80),
}

local defaultBrightness = Lighting.Brightness
local defaultClock = Lighting.ClockTime
local defaultShadows = Lighting.GlobalShadows

-- FOV круг
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = features.aimbotFOV
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 2
fovCircle.NumSides = 60
fovCircle.Filled = false

-- Aimbot
RunService.RenderStepped:Connect(function()
    if not features.aimbot then return end
    
    if features.aimbotShowFOV then
        fovCircle.Visible = true
        fovCircle.Radius = features.aimbotFOV
        fovCircle.Position = UIS:GetMouseLocation()
    else
        fovCircle.Visible = false
    end
    
    if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local closest = nil
    local shortest = math.huge
    local mousePos = UIS:GetMouseLocation()
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            if features.teamCheck and p.Team == player.Team then continue end
            
            if features.aimbotShowFOV then
                local headPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local screenPos = Vector2.new(headPos.X, headPos.Y)
                    local dist = (screenPos - mousePos).Magnitude
                    if dist > features.aimbotFOV then continue end
                end
            end
            
            local dist = (player.Character.HumanoidRootPart.Position - p.Character.Head.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = p.Character.Head
            end
        end
    end
    
    if closest then
        local lookAt = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Position)
        workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(lookAt, features.aimbotSpeed)
    end
end)

-- Fly
RunService.Heartbeat:Connect(function()
    if not features.fly or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local dir = Vector3.new()
    local cam = workspace.CurrentCamera.CFrame
    
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
    
    if features.flyAntiKick then
        if hrp.Velocity.Y < -5 then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, -5, hrp.Velocity.Z)
        end
    end
    
    hrp.Velocity = dir * features.flySpeed
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not features.noclip or not player.Character then return end
    for _, p in ipairs(player.Character:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        end
    end
    
    if features.noclipAntiKick and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end
end)

-- Infinity Jump
UIS.JumpRequest:Connect(function()
    if not features.infJump or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, hum.JumpPower, hrp.Velocity.Z)
    end
end)

-- Click TP
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not features.clickTp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.F) then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local mouse = player:GetMouse()
            player.Character:MoveTo(mouse.Hit.Position)
        end
    end
end)

-- ESP система
local espObjects = {}

local function updateESP()
    for _, obj in ipairs(espObjects) do
        obj:Destroy()
    end
    espObjects = {}
    
    if not features.espEnabled then return end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        if not p.Character then continue end
        
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        local head = p.Character:FindFirstChild("Head")
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        
        if hrp and head and hum then
            local espColor = features.espColor
            if features.teamCheck and p.Team == player.Team then
                espColor = features.espTeamColor
            end
            
            if features.espMode == "Обводка" then
                local highlight = Instance.new("Highlight")
                highlight.Parent = p.Character
                highlight.FillColor = espColor
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = espColor
                highlight.OutlineTransparency = 0
                table.insert(espObjects, highlight)
            end
        end
    end
end

-- Particles система
local particles = {}
local particleFeatures = {
    enabled = false,
    particleType = "Шарики",
    count = 5,
    size = 1,
    speed = 3,
    spread = 50
}

local function updateParticles()
    for _, p in ipairs(particles) do
        p:Destroy()
    end
    particles = {}
    
    if not particleFeatures.enabled or not player.Character then return end
    
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local texture = "rbxasset://textures/particles/sparkles_main.dds"
    local color = Color3.fromRGB(255, 255, 255)
    
    if particleFeatures.particleType == "Шарики" then
        texture = "rbxasset://textures/particles/sparkles_main.dds"
        color = Color3.fromRGB(255, 255, 255)
    elseif particleFeatures.particleType == "Сердечки" then
        texture = "rbxasset://textures/particles/heart.dds"
        color = Color3.fromRGB(255, 100, 100)
    elseif particleFeatures.particleType == "Звездочки" then
        texture = "rbxasset://textures/particles/star.dds"
        color = Color3.fromRGB(255, 255, 100)
    elseif particleFeatures.particleType == "Доллары" then
        texture = "rbxasset://textures/particles/dollar.dds"
        color = Color3.fromRGB(100, 255, 100)
    end
    
    local attachment = Instance.new("Attachment")
    attachment.Parent = hrp
    
    local particle = Instance.new("ParticleEmitter")
    particle.Parent = attachment
    particle.Rate = particleFeatures.count
    particle.Lifetime = NumberRange.new(3)
    particle.SpreadAngle = Vector2.new(360, 360)
    particle.Speed = NumberRange.new(particleFeatures.speed)
    particle.Size = NumberSequence.new(particleFeatures.size)
    particle.Texture = texture
    particle.Color = ColorSequence.new(color)
    particle.VelocityInheritance = 0.5
    particle.Enabled = true
    
    table.insert(particles, attachment)
    table.insert(particles, particle)
end

-- Функция создания кнопки
local function createButton(col, text, isPremium, callback)
    local btn = Instance.new("TextButton")
    btn.Name = text .. "Btn"
    btn.AutoButtonColor = false
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.Text = ""
    btn.Parent = col.scrolling

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local txt = Instance.new("TextLabel")
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.Gotham
    txt.Text = text
    txt.TextColor3 = isPremium and Color3.fromRGB(255, 200, 100) or Color3.new(1, 1, 1)
    txt.TextSize = 14
    txt.Position = UDim2.new(0, 10, 0, 0)
    txt.Size = UDim2.new(1, -50, 1, 0)
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Parent = btn

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.Text = isPremium and "PREM" or "OFF"
    status.TextColor3 = isPremium and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(150, 150, 150)
    status.TextSize = isPremium and 10 or 12
    status.Position = UDim2.new(1, -45, 0, 0)
    status.Size = UDim2.new(0, 40, 1, 0)
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.Parent = btn

    local enabled = false
    
    btn.MouseButton1Click:Connect(function()
        if isPremium then return end
        
        enabled = not enabled
        if enabled then
            btn.BackgroundColor3 = Color3.fromRGB(60, 70, 120)
            status.Text = "ON"
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            status.Text = "OFF"
            status.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        
        if callback then
            callback(enabled)
        end
    end)

    return {btn = btn, txt = txt, status = status, enabled = enabled}
end

-- Функция создания ползунка
local function createSlider(col, text, min, max, default, callback, suffix)
    suffix = suffix or ""
    local container = Instance.new("Frame")
    container.Name = text .. "Slider"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 45)
    container.Parent = col.scrolling

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, -50, 0, 20)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.Text = tostring(default) .. suffix
    valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    valueLabel.TextSize = 14
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container

    local sliderBg = Instance.new("Frame")
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Parent = container

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = sliderBg

    local slider = Instance.new("Frame")
    slider.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    slider.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    slider.Parent = sliderBg

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = slider

    local dragButton = Instance.new("TextButton")
    dragButton.BackgroundTransparency = 1
    dragButton.Size = UDim2.new(1, 0, 1, 0)
    dragButton.Text = ""
    dragButton.Parent = sliderBg

    local value = default
    local dragging = false

    dragButton.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UIS:GetMouseLocation()
            local absPos = sliderBg.AbsolutePosition
            local size = sliderBg.AbsoluteSize.X
            
            local relative = math.clamp((mousePos.X - absPos.X) / size, 0, 1)
            slider.Size = UDim2.new(relative, 0, 1, 0)
            
            value = min + (max - min) * relative
            value = math.floor(value * 100) / 100
            valueLabel.Text = tostring(value) .. suffix
            
            if callback then
                callback(value)
            end
        end
    end)

    return container
end

-- Функция создания переключателя
local function createToggle(col, text, default, callback)
    local container = Instance.new("Frame")
    container.Name = text .. "Toggle"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 25)
    container.Parent = col.scrolling

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(60, 70, 120) or Color3.fromRGB(50, 50, 55)
    toggleBtn.Position = UDim2.new(1, -30, 0, 2)
    toggleBtn.Size = UDim2.new(0, 25, 0, 20)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = default and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(150, 150, 150)
    toggleBtn.TextSize = 10
    toggleBtn.Parent = container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = toggleBtn

    local state = default

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 70, 120)
            toggleBtn.Text = "ON"
            toggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            toggleBtn.Text = "OFF"
            toggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        if callback then
            callback(state)
        end
    end)

    return container
end

-- Функция создания выбора из списка
local function createDropdown(col, text, options, default, callback)
    local container = Instance.new("Frame")
    container.Name = text .. "Dropdown"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 45)
    container.Parent = col.scrolling

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, -60, 0, 20)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local selectBtn = Instance.new("TextButton")
    selectBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    selectBtn.Position = UDim2.new(0, 0, 0, 25)
    selectBtn.Size = UDim2.new(1, 0, 0, 20)
    selectBtn.Text = default or options[1]
    selectBtn.TextColor3 = Color3.new(1, 1, 1)
    selectBtn.TextSize = 12
    selectBtn.Parent = container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = selectBtn

    local currentIndex = 1
    for i, opt in ipairs(options) do
        if opt == default then
            currentIndex = i
            break
        end
    end

    selectBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        selectBtn.Text = options[currentIndex]
        if callback then
            callback(options[currentIndex])
            if text == "ESP Mode" then
                features.espMode = options[currentIndex]
                updateESP()
            end
        end
    end)

    return selectBtn
end

-- Функция создания выбора цвета
local function createColorPicker(col, text, defaultColor, callback)
    local container = Instance.new("Frame")
    container.Name = text .. "Color"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 25)
    container.Parent = col.scrolling

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local colorBtn = Instance.new("TextButton")
    colorBtn.BackgroundColor3 = defaultColor
    colorBtn.Position = UDim2.new(1, -30, 0, 2)
    colorBtn.Size = UDim2.new(0, 25, 0, 20)
    colorBtn.Text = ""
    colorBtn.Parent = container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = colorBtn

    local colors = {
        Color3.fromRGB(255, 80, 80),
        Color3.fromRGB(80, 140, 255),
        Color3.fromRGB(80, 255, 80),
        Color3.fromRGB(255, 255, 80),
        Color3.fromRGB(255, 80, 255),
        Color3.fromRGB(255, 255, 255),
    }
    local colorIndex = 1

    colorBtn.MouseButton1Click:Connect(function()
        colorIndex = colorIndex % #colors + 1
        colorBtn.BackgroundColor3 = colors[colorIndex]
        if callback then
            callback(colors[colorIndex])
            if text == "ESP Color" then
                features.espColor = colors[colorIndex]
                updateESP()
            elseif text == "Tracer Color" then
                features.espTracerColor = colors[colorIndex]
                updateESP()
            elseif text == "Team Color" then
                features.espTeamColor = colors[colorIndex]
                updateESP()
            end
        end
    end)

    return container
end

-- Создаем кнопки
-- COMBAT
local aimbotBtn = createButton(cols.Combat, "Aimbot 360", false, function(on) features.aimbot = on end)
createSlider(cols.Combat, "Скорость", 0.1, 1, 0.5, function(val) features.aimbotSpeed = val end, "")
createSlider(cols.Combat, "FOV", 30, 180, 90, function(val) features.aimbotFOV = val end, "°")
createToggle(cols.Combat, "Показать FOV", false, function(on) features.aimbotShowFOV = on end)
local teamCheckBtn = createButton(cols.Combat, "Team Check", false, function(on) features.teamCheck = on end)

-- MOVEMENT
local flyBtn = createButton(cols.Movement, "Fly", false, function(on) features.fly = on end)
createSlider(cols.Movement, "Скорость", 10, 200, 50, function(val) features.flySpeed = val end, "")
createToggle(cols.Movement, "Анти-кик", false, function(on) features.flyAntiKick = on end)
local noclipBtn = createButton(cols.Movement, "Noclip", false, function(on) features.noclip = on end)
createToggle(cols.Movement, "Анти-кик", false, function(on) features.noclipAntiKick = on end)
local infJumpBtn = createButton(cols.Movement, "Inf Jump", false, function(on) features.infJump = on end)

-- VISUALS
local fullbrightBtn = createButton(cols.Visuals, "Fullbright", false, function(on) 
    features.fullbright = on
    if on then
        Lighting.Brightness = 5
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = defaultBrightness
        Lighting.ClockTime = defaultClock
        Lighting.GlobalShadows = defaultShadows
    end
end)
local blurBtn = createButton(cols.Visuals, "Blur", false, function(on) 
    features.blur = on
    blur.Size = on and 16 or 0
end)

-- PLAYER
local clickTpBtn = createButton(cols.Player, "F+Click TP", false, function(on) features.clickTp = on end)
local killBtn = createButton(cols.Player, "Kill", false, function(on) 
    if on and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Health = 0
    end
end)

-- ESP
local espBtn = createButton(cols.ESP, "ESP", false, function(on) 
    features.espEnabled = on
    updateESP()
end)
createDropdown(cols.ESP, "ESP Mode", {"Обводка", "Хитбокс", "Палочки"}, "Обводка", function(val) 
    features.espMode = val
    updateESP()
end)
createToggle(cols.ESP, "Показать имя", true, function(on) 
    features.espShowName = on
    updateESP()
end)
createToggle(cols.ESP, "Показать ХП", true, function(on) 
    features.espShowHealth = on
    updateESP()
end)
createToggle(cols.ESP, "Показать дист.", false, function(on) 
    features.espShowDistance = on
    updateESP()
end)
createColorPicker(cols.ESP, "ESP Color", features.espColor, function(color) 
    features.espColor = color
    updateESP()
end)
createColorPicker(cols.ESP, "Tracer Color", features.espTracerColor, function(color) 
    features.espTracerColor = color
    updateESP()
end)
createColorPicker(cols.ESP, "Team Color", features.espTeamColor, function(color) 
    features.espTeamColor = color
    updateESP()
end)

-- MISC
local particlesBtn = createButton(cols.Misc, "Particles", false, function(on)
    particleFeatures.enabled = on
    updateParticles()
end)
createDropdown(cols.Misc, "Тип", {"Шарики", "Сердечки", "Звездочки", "Доллары"}, "Шарики", function(val)
    particleFeatures.particleType = val
    if particleFeatures.enabled then updateParticles() end
end)
createSlider(cols.Misc, "Кол-во", 1, 20, 5, function(val)
    particleFeatures.count = math.floor(val)
    if particleFeatures.enabled then updateParticles() end
end, "")
createSlider(cols.Misc, "Размер", 0.5, 3, 1, function(val)
    particleFeatures.size = val
    if particleFeatures.enabled then updateParticles() end
end, "")
createSlider(cols.Misc, "Скорость", 1, 10, 3, function(val)
    particleFeatures.speed = val
    if particleFeatures.enabled then updateParticles() end
end, "")
createSlider(cols.Misc, "Разброс", 10, 100, 50, function(val)
    particleFeatures.spread = val
    if particleFeatures.enabled then updateParticles() end
end, "")
createDropdown(cols.Misc, "Время", {"День", "Ночь", "Закат", "Рассвет"}, "День", function(val)
    if val == "День" then
        Lighting.ClockTime = 14
        Lighting.Brightness = 5
        Lighting.GlobalShadows = false
    elseif val == "Ночь" then
        Lighting.ClockTime = 0
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    elseif val == "Закат" then
        Lighting.ClockTime = 18
        Lighting.Brightness = 3
        Lighting.GlobalShadows = true
    elseif val == "Рассвет" then
        Lighting.ClockTime = 6
        Lighting.Brightness = 3
        Lighting.GlobalShadows = true
    end
end)
createButton(cols.Misc, "Unhook", false, function(on)
    if on then
        gui:Destroy()
        blur:Destroy()
    end
end)

-- THEME
local resetBtn = Instance.new("TextButton")
resetBtn.Name = "ResetBtn"
resetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
resetBtn.Size = UDim2.new(1, -20, 0, 28)
resetBtn.Text = "Сбросить прозрачность"
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.TextSize = 14
resetBtn.Parent = cols.Theme.scrolling

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetBtn

createSlider(cols.Theme, "Колонки прозрачность", 0, 0.5, 0.1, function(val)
    for name, col in pairs(cols) do
        col.frame.BackgroundTransparency = val
    end
end, "")
createSlider(cols.Theme, "Кнопки прозрачность", 0, 0.5, 0.2, function(val) end, "")
createColorPicker(cols.Theme, "Цвет фона", Color3.fromRGB(0, 0, 0), function(color)
    bgDim.BackgroundColor3 = color
end)
createColorPicker(cols.Theme, "Цвет колонок", Color3.fromRGB(30, 30, 35), function(color)
    for name, col in pairs(cols) do
        col.frame.BackgroundColor3 = color
    end
end)
createColorPicker(cols.Theme, "Цвет кнопок", Color3.fromRGB(40, 40, 45), function(color) end)

resetBtn.MouseButton1Click:Connect(function()
    bgDim.BackgroundTransparency = 0.5
    for name, col in pairs(cols) do
        col.frame.BackgroundTransparency = 0.1
    end
    bgDim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    for name, col in pairs(cols) do
        col.frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    end
end)

-- Строка поиска
local searchBar = Instance.new("Frame")
searchBar.Name = "SearchBar"
searchBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
searchBar.BackgroundTransparency = 0.1
searchBar.BorderSizePixel = 0
searchBar.Position = UDim2.new(0.5, -250, 0, 640)
searchBar.Size = UDim2.new(0, 500, 0, 40)
searchBar.Parent = uiContainer

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 10)
searchCorner.Parent = searchBar

local searchIcon = Instance.new("TextLabel")
searchIcon.BackgroundTransparency = 1
searchIcon.Font = Enum.Font.Gotham
searchIcon.Text = ">"
searchIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
searchIcon.TextSize = 20
searchIcon.Position = UDim2.new(0, 15, 0, 0)
searchIcon.Size = UDim2.new(0, 20, 1, 0)
searchIcon.Parent = searchBar

local searchText = Instance.new("TextLabel")
searchText.BackgroundTransparency = 1
searchText.Font = Enum.Font.Gotham
searchText.Text = "Search"
searchText.TextColor3 = Color3.fromRGB(150, 150, 150)
searchText.TextSize = 16
searchText.Position = UDim2.new(0, 40, 0, 0)
searchText.Size = UDim2.new(1, -80, 1, 0)
searchText.TextXAlignment = Enum.TextXAlignment.Left
searchText.Parent = searchBar

-- Мини-бар
local miniBar = Instance.new("Frame")
miniBar.Name = "MiniBar"
miniBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
miniBar.BackgroundTransparency = 0.1
miniBar.BorderSizePixel = 0
miniBar.Position = UDim2.new(0.5, -150, 0, 20)
miniBar.Size = UDim2.new(0, 300, 0, 50)
miniBar.Visible = false
miniBar.Parent = main

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 10)
miniCorner.Parent = miniBar

local miniText = Instance.new("TextLabel")
miniText.BackgroundTransparency = 1
miniText.Font = Enum.Font.Gotham
miniText.Text = "NEZ0X UI"
miniText.TextColor3 = Color3.new(1, 1, 1)
miniText.TextSize = 18
miniText.Size = UDim2.new(1, 0, 1, 0)
miniText.TextXAlignment = Enum.TextXAlignment.Center
miniText.Parent = miniBar

-- Управление клавишами
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode.Name == "F8" then
            gui:Destroy()
            blur:Destroy()
        end
        
        if input.KeyCode.Name == "M" then
            if uiContainer.Visible then
                uiContainer.Visible = false
                miniBar.Visible = true
                bgDim.Visible = false
                blur.Size = 0
            else
                uiContainer.Visible = true
                miniBar.Visible = false
                bgDim.Visible = true
                if features.blur then
                    blur.Size = 16
                end
            end
        end
    end
end)

print("UI загружен - ВСЕ ЭЛЕМЕНТЫ ВИДНЫ (используй колесико мыши для прокрутки)")
