if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- SERVICES
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- BLUR (ВСЕГДА)
local blur = Lighting:FindFirstChild("VisionBlur")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "VisionBlur"
	blur.Size = 24
	blur.Parent = Lighting
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "VisionUI"
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- DYNAMIC ISLAND
local island = Instance.new("Frame")
island.Size = UDim2.new(0,260,0,42)
island.Position = UDim2.new(0.5,-130,0,12)
island.BackgroundColor3 = Color3.fromRGB(20,20,20)
island.BackgroundTransparency = 0.25
island.Parent = gui

Instance.new("UICorner", island).CornerRadius = UDim.new(1,0)

local clock = Instance.new("TextLabel")
clock.Size = UDim2.new(1,0,1,0)
clock.BackgroundTransparency = 1
clock.Font = Enum.Font.GothamBold
clock.TextScaled = true
clock.TextColor3 = Color3.new(1,1,1)
clock.Parent = island

task.spawn(function()
	while true do
		clock.Text = os.date("%H:%M:%S")
		task.wait(1)
	end
end)

-- MAIN WINDOW
local main = Instance.new("Frame")
main.Size = UDim2.new(0,1100,0,650)
main.Position = UDim2.new(0.5,-550,0.5,-325)
main.BackgroundColor3 = Color3.fromRGB(255,255,255)
main.BackgroundTransparency = 0.87
main.Parent = gui

Instance.new("UICorner",main).CornerRadius = UDim.new(0,18)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255,255,255)
stroke.Transparency = 0.4
stroke.Thickness = 2
stroke.Parent = main

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "Vision UI"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.Parent = main

-- TAB PANEL
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(0,220,1,-60)
tabsFrame.Position = UDim2.new(0,0,0,60)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = main

-- CONTENT
local content = Instance.new("Frame")
content.Size = UDim2.new(1,-240,1,-70)
content.Position = UDim2.new(0,230,0,60)
content.BackgroundTransparency = 1
content.Parent = main

local tabs = {}
local tabButtons = {}

-- BUTTON CREATOR
local function createButton(parent,text,y)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,260,0,48)
	btn.Position = UDim2.new(0,20,0,y)
	btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	btn.BackgroundTransparency = 0.75
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.Parent = parent

	Instance.new("UICorner",btn).CornerRadius = UDim.new(1,0)

	return btn
end

-- TAB CREATOR
local function createTab(i,name)

	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(1,-20,0,44)
	tabBtn.Position = UDim2.new(0,10,0,(i-1)*50)
	tabBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
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
			v.Visible = false
			tabButtons[k].BackgroundTransparency = 0.8
		end

		frame.Visible = true
		tabBtn.BackgroundTransparency = 0.5

	end)

	return frame
end

-- CREATE TABS
for i=1,8 do

	local name = "Таб "..i
	if i == 7 then name = "THEME" end

	local tab = createTab(i,name)

	if i <= 6 then
		createButton(tab,"Кнопка 1",0)
		createButton(tab,"Кнопка 2",70)
		createButton(tab,"Кнопка 3",140)
	end

	if i == 7 then

		local b1 = createButton(tab,"Vision",0)
		local b2 = createButton(tab,"Dark",70)
		local b3 = createButton(tab,"Blue",140)

		b1.MouseButton1Click:Connect(function()
			main.BackgroundColor3 = Color3.fromRGB(255,255,255)
		end)

		b2.MouseButton1Click:Connect(function()
			main.BackgroundColor3 = Color3.fromRGB(35,35,40)
		end)

		b3.MouseButton1Click:Connect(function()
			main.BackgroundColor3 = Color3.fromRGB(80,120,255)
		end)

	end

	if i == 8 then

		createButton(tab,"Кнопка 1",0)
		createButton(tab,"Кнопка 2",70)

		local unload = createButton(tab,"Выгрузка",140)

		unload.MouseButton1Click:Connect(function()
			gui:Destroy()
		end)

	end

end

-- HOTKEYS
UIS.InputBegan:Connect(function(input,gp)

	if gp then return end

	if input.KeyCode == Enum.KeyCode.M then
		main.Visible = not main.Visible
	end

	if input.KeyCode == Enum.KeyCode.F8 then
		gui:Destroy()
	end

end)
