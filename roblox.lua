-- загрузка
if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- BLUR
local blur = Lighting:FindFirstChild("VisionBlur")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "VisionBlur"
	blur.Size = 20
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
island.Size = UDim2.new(0,260,0,44)
island.Position = UDim2.new(0.5,-130,0,12)
island.BackgroundColor3 = Color3.fromRGB(0,0,0)
island.BackgroundTransparency = 0.35
island.Parent = gui

Instance.new("UICorner",island).CornerRadius = UDim.new(1,0)

local clock = Instance.new("TextLabel")
clock.Size = UDim2.new(1,0,1,0)
clock.BackgroundTransparency = 1
clock.Font = Enum.Font.GothamBold
clock.TextColor3 = Color3.new(1,1,1)
clock.TextScaled = true
clock.Parent = island

task.spawn(function()
	while task.wait(1) do
		clock.Text = os.date("%H:%M:%S")
	end
end)

-- MAIN WINDOW
local main = Instance.new("Frame")
main.Size = UDim2.new(0,1100,0,650)
main.Position = UDim2.new(0.5,-550,0.5,-325)
main.BackgroundColor3 = Color3.fromRGB(255,255,255)
main.BackgroundTransparency = 0.86
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,18)
corner.Parent = main

-- стеклянная рамка
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Transparency = 0.4
stroke.Color = Color3.fromRGB(255,255,255)
stroke.Parent = main

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "Vision Glass UI"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.Parent = main

-- TAB PANEL
local tabPanel = Instance.new("Frame")
tabPanel.Size = UDim2.new(0,220,1,-60)
tabPanel.Position = UDim2.new(0,0,0,60)
tabPanel.BackgroundTransparency = 1
tabPanel.Parent = main

-- CONTENT
local content = Instance.new("Frame")
content.Size = UDim2.new(1,-240,1,-70)
content.Position = UDim2.new(0,230,0,60)
content.BackgroundTransparency = 1
content.Parent = main

local tabs = {}

-- кнопка функция
local function makeButton(parent,text,pos,callback)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,260,0,50)
	btn.Position = UDim2.new(0,20,0,pos)
	btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
	btn.BackgroundTransparency = 0.75
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.Parent = parent

	Instance.new("UICorner",btn).CornerRadius = UDim.new(1,0)

	if callback then
		btn.MouseButton1Click:Connect(callback)
	end

end

-- TAB CREATOR
local function createTab(i,name)

	local tabButton = Instance.new("TextButton")
	tabButton.Size = UDim2.new(1,-20,0,44)
	tabButton.Position = UDim2.new(0,10,0,(i-1)*50)
	tabButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
	tabButton.BackgroundTransparency = 0.8
	tabButton.Text = name
	tabButton.Font = Enum.Font.GothamBold
	tabButton.TextScaled = true
	tabButton.Parent = tabPanel

	Instance.new("UICorner",tabButton).CornerRadius = UDim.new(1,0)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundTransparency = 1
	frame.Visible = (i==1)
	frame.Parent = content

	tabs[i] = frame

	tabButton.MouseButton1Click:Connect(function()
		for _,f in pairs(tabs) do
			f.Visible=false
		end
		frame.Visible=true
	end)

	return frame

end

-- ТАБЫ
for i=1,8 do

	local name="Таб "..i
	if i==7 then name="THEME" end

	local tab=createTab(i,name)

	if i<=6 then

		makeButton(tab,"Кнопка 1",0)
		makeButton(tab,"Кнопка 2",70)
		makeButton(tab,"Кнопка 3",140)

	end

	if i==7 then

		makeButton(tab,"Vision",0,function()
			main.BackgroundColor3=Color3.fromRGB(255,255,255)
		end)

		makeButton(tab,"Dark",70,function()
			main.BackgroundColor3=Color3.fromRGB(40,40,45)
		end)

		makeButton(tab,"Blue",140,function()
			main.BackgroundColor3=Color3.fromRGB(90,120,255)
		end)

	end

	if i==8 then

		makeButton(tab,"Кнопка 1",0)
		makeButton(tab,"Кнопка 2",70)

		makeButton(tab,"Выгрузка",140,function()
			gui:Destroy()
			if blur then blur:Destroy() end
		end)

	end

end

-- HOTKEY
UIS.InputBegan:Connect(function(input,gp)

	if gp then return end

	if input.KeyCode==Enum.KeyCode.M then
		main.Visible=not main.Visible
	end

	if input.KeyCode==Enum.KeyCode.F8 then
		gui:Destroy()
		if blur then blur:Destroy() end
	end

end)
