local Players = game:GetService("Players")

local player = Players.LocalPlayer
if not player then
	return
end

local playerGui = player:WaitForChild("PlayerGui")

--// SERVICES
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

--// SETTINGS
local TOGGLE_KEY = Enum.KeyCode.M
local UNLOAD_KEY = Enum.KeyCode.F8

--// THEMES
local THEMES = {
	["Vision"] = {bg = Color3.fromRGB(255,255,255), text = Color3.fromRGB(0,0,0)},
	["Dark"] = {bg = Color3.fromRGB(30,30,35), text = Color3.fromRGB(255,255,255)},
	["Blue"] = {bg = Color3.fromRGB(90,120,255), text = Color3.fromRGB(255,255,255)},
	["Mint"] = {bg = Color3.fromRGB(120,255,200), text = Color3.fromRGB(0,0,0)},
	["Rose"] = {bg = Color3.fromRGB(255,140,170), text = Color3.fromRGB(0,0,0)},
}

--// BLUR
local blur = Lighting:FindFirstChild("VisionBlur")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "VisionBlur"
	blur.Size = 18
	blur.Parent = Lighting
end

--// SCREEN GUI
local gui = Instance.new("ScreenGui")
gui.Name = "VisionUI"
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.ResetOnSpawn = false
gui.Parent = guiParent

--// DYNAMIC ISLAND
local island = Instance.new("Frame")
island.Size = UDim2.new(0,260,0,44)
island.Position = UDim2.new(0.5,-130,0,10)
island.BackgroundColor3 = Color3.fromRGB(0,0,0)
island.BackgroundTransparency = 0.25
island.Parent = gui

Instance.new("UICorner",island).CornerRadius = UDim.new(1,0)

local clock = Instance.new("TextLabel")
clock.Size = UDim2.new(1,0,1,0)
clock.BackgroundTransparency = 1
clock.Font = Enum.Font.GothamBold
clock.TextScaled = true
clock.TextColor3 = Color3.new(1,1,1)
clock.Parent = island

task.spawn(function()
	while task.wait(1) do
		clock.Text = os.date("%H:%M:%S")
	end
end)

--// MAIN WINDOW
local main = Instance.new("Frame")
main.Size = UDim2.new(0,900,0,560)
main.Position = UDim2.new(0.5,-450,0.5,-280)
main.BackgroundColor3 = Color3.fromRGB(255,255,255)
main.BackgroundTransparency = 0.82
main.Parent = gui

Instance.new("UICorner",main).CornerRadius = UDim.new(0,22)

--// TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "Vision Framework"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.new(1,1,1)
title.Parent = main

--// TAB PANEL
local tabPanel = Instance.new("Frame")
tabPanel.Size = UDim2.new(0,200,1,-60)
tabPanel.Position = UDim2.new(0,0,0,60)
tabPanel.BackgroundTransparency = 1
tabPanel.Parent = main

--// CONTENT
local content = Instance.new("Frame")
content.Size = UDim2.new(1,-210,1,-70)
content.Position = UDim2.new(0,210,0,60)
content.BackgroundTransparency = 1
content.Parent = main

--// STORAGE
local tabs = {}

--// THEME APPLY
local function applyTheme(name)

	local theme = THEMES[name]
	main.BackgroundColor3 = theme.bg
	
	for _,v in pairs(gui:GetDescendants()) do
		if v:IsA("TextLabel") or v:IsA("TextButton") then
			v.TextColor3 = theme.text
		end
	end
	
end

--// CREATE TAB
local function createTab(i,name)

	local tabButton = Instance.new("TextButton")
	tabButton.Size = UDim2.new(1,-20,0,40)
	tabButton.Position = UDim2.new(0,10,0,(i-1)*46)
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
			f.Visible = false
		end
		frame.Visible = true
	end)

	return frame
end

--// CREATE BUTTON
local function createButton(parent,text,pos,callback)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,220,0,50)
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

	return btn
end

--// CREATE 8 TABS
for i=1,8 do

	local name = "Таб "..i
	
	if i==7 then
		name="THEME"
	end
	
	local tab = createTab(i,name)

	if i<=6 then
		for b=1,3 do
			createButton(tab,"Кнопка "..b,(b-1)*70)
		end
	end
	
	if i==7 then
		
		local y=0
		for theme,_ in pairs(THEMES) do
			
			createButton(tab,theme,y,function()
				applyTheme(theme)
			end)
			
			y=y+70
			
		end
		
	end
	
	if i==8 then
		
		createButton(tab,"Кнопка 1",0)
		createButton(tab,"Кнопка 2",70)
		
		createButton(tab,"Выгрузка",140,function()
			if blur then blur:Destroy() end
			gui:Destroy()
		end)
		
	end
	
end

--// TOGGLE
local open=true

UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	
	if input.KeyCode==TOGGLE_KEY then
		open=not open
		main.Visible=open
	end
	
	if input.KeyCode==UNLOAD_KEY then
		if blur then blur:Destroy() end
		gui:Destroy()
	end
	
end)

--// DEFAULT THEME
applyTheme("Vision")
