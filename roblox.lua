if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- SERVICES
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- SETTINGS
local particleSettings = {
	count = 25,
	size = 0.6,
	color = Color3.fromRGB(180,220,255),
	radius = 8
}

-- THEME
local theme = {
	gui = Color3.fromRGB(255,255,255),
	button = Color3.fromRGB(255,255,255),
	tab = Color3.fromRGB(255,255,255),
	time = Color3.fromRGB(255,255,255)
}

-- BLUR
local blur = Instance.new("BlurEffect")
blur.Size = 20
blur.Enabled = false
blur.Parent = Lighting

-- GUI
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999
gui.Parent = playerGui

-- CLOCK
local island = Instance.new("Frame")
island.Size = UDim2.new(0,260,0,40)
island.Position = UDim2.new(0.5,-130,0,10)
island.BackgroundColor3 = Color3.fromRGB(20,20,20)
island.BackgroundTransparency = 0.25
island.Parent = gui
Instance.new("UICorner",island).CornerRadius = UDim.new(1,0)

local clock = Instance.new("TextLabel")
clock.Size = UDim2.new(1,0,1,0)
clock.BackgroundTransparency = 1
clock.Font = Enum.Font.GothamBold
clock.TextScaled = true
clock.TextColor3 = theme.time
clock.Parent = island

task.spawn(function()
	while true do
		clock.Text = os.date("%H:%M:%S")
		task.wait(1)
	end
end)

-- MAIN
local main = Instance.new("Frame")
main.Size = UDim2.new(0,1100,0,650)
main.Position = UDim2.new(0.5,-550,0.5,-325)
main.BackgroundColor3 = theme.gui
main.BackgroundTransparency = 0.87
main.Visible = false
main.Parent = gui
Instance.new("UICorner",main).CornerRadius = UDim.new(0,18)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "Vision UI"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.Parent = main

-- TABS
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(0,220,1,-60)
tabsFrame.Position = UDim2.new(0,0,0,60)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = main

local content = Instance.new("Frame")
content.Size = UDim2.new(1,-240,1,-70)
content.Position = UDim2.new(0,230,0,60)
content.BackgroundTransparency = 1
content.Parent = main

local tabs = {}
local tabButtons = {}

local function createButton(parent,text,y)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,240,0,46)
	btn.Position = UDim2.new(0,20,0,y)
	btn.BackgroundColor3 = theme.button
	btn.BackgroundTransparency = 0.75
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.Parent = parent

	Instance.new("UICorner",btn).CornerRadius = UDim.new(1,0)

	return btn
end

local function createTab(i,name)

	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(1,-20,0,44)
	tabBtn.Position = UDim2.new(0,10,0,(i-1)*50)
	tabBtn.BackgroundColor3 = theme.tab
	tabBtn.BackgroundTransparency = 0.8
	tabBtn.Text = name
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextScaled = true
	tabBtn.Parent = tabsFrame

	Instance.new("UICorner",tabBtn).CornerRadius = UDim.new(1,0)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundTransparency = 1
	frame.Visible = (i==1)
	frame.Parent = content

	tabs[i] = frame
	tabButtons[i] = tabBtn

	tabBtn.MouseButton1Click:Connect(function()

		for k,v in pairs(tabs) do
			v.Visible=false
			tabButtons[k].BackgroundTransparency=0.8
		end

		frame.Visible=true
		tabBtn.BackgroundTransparency=0.5

	end)

	return frame
end

-- PARTICLES
local particlesEnabled = false
local particles = {}
local angles = {}

local function createParticles()

	for i=1,particleSettings.count do

		local p = Instance.new("Part")
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(
			particleSettings.size,
			particleSettings.size,
			particleSettings.size
		)
		p.Material = Enum.Material.Neon
		p.Color = particleSettings.color
		p.Anchored = true
		p.CanCollide = false
		p.Parent = workspace

		particles[i] = p
		angles[i] = math.random()*math.pi*2

	end

end

local function clearParticles()

	for _,p in pairs(particles) do
		p:Destroy()
	end

	particles={}
	angles={}

end

RunService.RenderStepped:Connect(function(dt)

	if not particlesEnabled then return end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")

	if not root then return end

	for i,p in pairs(particles) do

		angles[i] = angles[i] + dt*0.5

		local x = math.cos(angles[i]) * particleSettings.radius
		local z = math.sin(angles[i]) * particleSettings.radius
		local y = math.sin(angles[i]*0.5) * 2

		local target = root.Position + Vector3.new(x,y,z)

		p.Position = p.Position:Lerp(target,0.05)

	end

end)

local function toggleParticles()

	particlesEnabled = not particlesEnabled

	if particlesEnabled then
		createParticles()
	else
		clearParticles()
	end

end

-- ESP
local espEnabled = false
local espList = {}

local function createESP(plr)

	if plr==player then return end

	local function onChar(char)

		local head = char:WaitForChild("Head")

		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.fromRGB(0,255,180)
		highlight.Parent = char

		local bill = Instance.new("BillboardGui")
		bill.Size = UDim2.new(0,150,0,36)
		bill.StudsOffset = Vector3.new(0,3,0)
		bill.AlwaysOnTop = true
		bill.Parent = head

		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1,0,1,0)
		name.BackgroundTransparency = 1
		name.Text = plr.Name
		name.Font = Enum.Font.GothamBold
		name.TextScaled = true
		name.TextColor3 = Color3.new(1,1,1)
		name.Parent = bill

		espList[plr] = {highlight,bill}

	end

	if plr.Character then
		onChar(plr.Character)
	end

	plr.CharacterAdded:Connect(onChar)

end

task.spawn(function()

	while true do

		if espEnabled then

			for _,plr in pairs(Players:GetPlayers()) do
				if plr~=player and not espList[plr] then
					createESP(plr)
				end
			end

		end

		task.wait(1)

	end

end)

-- SPRINT
local sprintEnabled=false

local function setSprint(state)

	sprintEnabled=state

	local char=player.Character
	if not char then return end

	local hum=char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if state then
		hum.WalkSpeed=32
	else
		hum.WalkSpeed=16
	end

end

-- CREATE TABS
for i=1,8 do

	local name="TAB "..i
	if i==7 then name="THEME" end

	local tab=createTab(i,name)

	if i==1 then

		local sprintBtn=createButton(tab,"SPRINT OFF",0)

		sprintBtn.MouseButton1Click:Connect(function()

			sprintEnabled=not sprintEnabled
			setSprint(sprintEnabled)

			sprintBtn.Text = sprintEnabled and "SPRINT ON" or "SPRINT OFF"

		end)

	end

	if i==2 then

		local partBtn=createButton(tab,"PARTICLES OFF",0)

		partBtn.MouseButton1Click:Connect(function()

			toggleParticles()

			partBtn.Text = particlesEnabled and "PARTICLES ON" or "PARTICLES OFF"

		end)

	end

	if i==3 then

		local espBtn=createButton(tab,"ESP OFF",0)

		espBtn.MouseButton1Click:Connect(function()

			espEnabled=not espEnabled

			if espEnabled then
				espBtn.Text="ESP ON"
				espBtn.BackgroundColor3=Color3.fromRGB(140,255,180)
			else
				espBtn.Text="ESP OFF"
				espBtn.BackgroundColor3=theme.button
			end

		end)

	end

	if i==7 then

		local red=createButton(tab,"RED",0)
		local blue=createButton(tab,"BLUE",70)
		local green=createButton(tab,"GREEN",140)

		red.MouseButton1Click:Connect(function()
			main.BackgroundColor3=Color3.fromRGB(40,0,0)
		end)

		blue.MouseButton1Click:Connect(function()
			main.BackgroundColor3=Color3.fromRGB(0,20,40)
		end)

		green.MouseButton1Click:Connect(function()
			main.BackgroundColor3=Color3.fromRGB(0,40,20)
		end)

	end

end

-- HOTKEYS
UIS.InputBegan:Connect(function(input,gp)

	if gp then return end

	if input.KeyCode==Enum.KeyCode.M then
		main.Visible=not main.Visible
		blur.Enabled=main.Visible
	end

end)
