local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Alte GUI entfernen
local old = playerGui:FindFirstChild("ToggleGUI")
if old then
	old:Destroy()
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToggleGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Hauptfenster
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,500,0,300)
frame.Position = UDim2.new(0.5,-250,0.5,-150)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

Instance.new("UICorner",frame).CornerRadius = UDim.new(0,10)

-- Titel
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "Bad Bunny"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = frame

---------------------------------------------------
-- Sidebar
---------------------------------------------------

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0,140,1,-40)
sidebar.Position = UDim2.new(0,0,0,40)
sidebar.BackgroundColor3 = Color3.fromRGB(28,28,28)
sidebar.BorderSizePixel = 0
sidebar.Parent = frame

local sidebarOpen = true

local toggleSidebar = Instance.new("TextButton")
toggleSidebar.Size = UDim2.new(0,35,0,35)
toggleSidebar.Position = UDim2.new(0,5,0,2)
toggleSidebar.Text = "☰"
toggleSidebar.TextSize = 20
toggleSidebar.Font = Enum.Font.GothamBold
toggleSidebar.BackgroundTransparency = 1
toggleSidebar.TextColor3 = Color3.new(1,1,1)
toggleSidebar.Parent = frame

---------------------------------------------------
-- Main Bereich
---------------------------------------------------

local main = Instance.new("Frame")
main.Size = UDim2.new(1,-140,1,-40)
main.Position = UDim2.new(0,140,0,40)
main.BackgroundTransparency = 1
main.Parent = frame

local tabTitle = Instance.new("TextLabel")
tabTitle.Size = UDim2.new(1,0,0,40)
tabTitle.BackgroundTransparency = 1
tabTitle.Text = "Main"
tabTitle.Font = Enum.Font.GothamBold
tabTitle.TextSize = 22
tabTitle.TextColor3 = Color3.new(1,1,1)
tabTitle.Parent = main

---------------------------------------------------
-- Switch
---------------------------------------------------

local switchFrame = Instance.new("Frame")
switchFrame.Size = UDim2.new(0,70,0,30)
switchFrame.Position = UDim2.new(0,20,0,60)
switchFrame.BackgroundColor3 = Color3.fromRGB(60,60,60)
switchFrame.Parent = main
Instance.new("UICorner",switchFrame).CornerRadius = UDim.new(1,0)

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0,26,0,26)
knob.Position = UDim2.new(0,2,0,2)
knob.BackgroundColor3 = Color3.new(1,1,1)
knob.Parent = switchFrame
Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

local switch = false

switchFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		switch = not switch

		if switch then
			TweenService:Create(
				knob,
				TweenInfo.new(0.2),
				{Position = UDim2.new(1,-28,0,2)}
			):Play()

			TweenService:Create(
				switchFrame,
				TweenInfo.new(0.2),
				{BackgroundColor3 = Color3.fromRGB(0,170,255)}
			):Play()

		else
			TweenService:Create(
				knob,
				TweenInfo.new(0.2),
				{Position = UDim2.new(0,2,0,2)}
			):Play()

			TweenService:Create(
				switchFrame,
				TweenInfo.new(0.2),
				{BackgroundColor3 = Color3.fromRGB(60,60,60)}
			):Play()
		end

		print("Switch:",switch)
	end
end)

---------------------------------------------------
-- Sidebar ein-/ausklappen
---------------------------------------------------

toggleSidebar.MouseButton1Click:Connect(function()

	sidebarOpen = not sidebarOpen

	if sidebarOpen then

		TweenService:Create(
			sidebar,
			TweenInfo.new(0.25),
			{Size = UDim2.new(0,140,1,-40)}
		):Play()

		TweenService:Create(
			main,
			TweenInfo.new(0.25),
			{
				Position = UDim2.new(0,140,0,40),
				Size = UDim2.new(1,-140,1,-40)
			}
		):Play()

	else

		TweenService:Create(
			sidebar,
			TweenInfo.new(0.25),
			{Size = UDim2.new(0,0,1,-40)}
		):Play()

		TweenService:Create(
			main,
			TweenInfo.new(0.25),
			{
				Position = UDim2.new(0,0,0,40),
				Size = UDim2.new(1,0,1,-40)
			}
		):Play()

	end
end)

---------------------------------------------------
-- GUI mit Right Shift anzeigen/verstecken
---------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)

	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		frame.Visible = not frame.Visible
	end

end)
