-- ✈️ Fly Flew v3 | Mobile Support + Movable GUI + Smooth Controls
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local function refreshCharacter(newChar)
	character = newChar
	humanoid = newChar:WaitForChild("Humanoid")
	root = newChar:WaitForChild("HumanoidRootPart")
end
player.CharacterAdded:Connect(refreshCharacter)

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FlyFlewUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,180,0,120)
frame.Position = UDim2.new(0.5,-90,0.8,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true -- ✅ allows moving GUI
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0,14)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(70,130,255)

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0,160,0,44)
flyBtn.Position = UDim2.new(0,10,0,10)
flyBtn.Text = "🚀 Fly Mode"
flyBtn.Font = Enum.Font.GothamBold
flyBtn.TextSize = 20
flyBtn.TextColor3 = Color3.new(1,1,1)
flyBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
flyBtn.Parent = frame
Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0,10)

local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0,160,0,44)
speedBtn.Position = UDim2.new(0,10,0,66)
speedBtn.Text = "Speed: Normal"
speedBtn.Font = Enum.Font.GothamBold
speedBtn.TextSize = 18
speedBtn.TextColor3 = Color3.fromRGB(200,200,255)
speedBtn.BackgroundColor3 = Color3.fromRGB(30,30,40)
speedBtn.Parent = frame
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0,10)

-- Glow loop
task.spawn(function()
	while true do
		local hue = tick() % 5 / 5
		stroke.Color = Color3.fromHSV(hue,0.8,1)
		task.wait(0.05)
	end
end)

-- Variables
local speeds = {Normal = 70, Fast = 120, ["Super Fast"] = 200}
local speedMode = "Normal"
local flying = false
local bv, bg, conn
local currentVel = Vector3.zero
local easing = 6

-- Create forces
local function setupForces()
	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5,1e5,1e5)
	bv.Velocity = Vector3.zero
	bv.Parent = root

	bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
	bg.P = 9e4
	bg.Parent = root
end

local function cleanup()
	if bv then bv:Destroy() bv=nil end
	if bg then bg:Destroy() bg=nil end
end

-- Flight logic (mobile + PC)
local function flight(dt)
	if not flying then return end

	local dir = Vector3.zero
	local cam = camera.CFrame
	local moveVector = Vector3.zero

	-- For PC (WASD)
	if UserInputService.KeyboardEnabled then
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
	end

	-- For Mobile (Joystick)
	if UserInputService.TouchEnabled and humanoid.MoveDirection.Magnitude > 0 then
		moveVector = humanoid.MoveDirection
	end

	local total = dir + moveVector
	if total.Magnitude > 0 then total = total.Unit * speeds[speedMode] end

	currentVel = currentVel:Lerp(total, math.clamp(easing * dt, 0, 1))
	if bv then bv.Velocity = currentVel end
	if bg then bg.CFrame = CFrame.new(Vector3.zero, currentVel.Magnitude>0 and currentVel.Unit or cam.LookVector) end
end

-- Start/Stop flying
local function startFly()
	if flying then return end
	flying = true
	setupForces()
	humanoid.PlatformStand = true
	flyBtn.Text = "🛑 Stop Fly"
	conn = RunService.Heartbeat:Connect(flight)
end

local function stopFly()
	if not flying then return end
	flying = false
	if conn then conn:Disconnect() conn=nil end
	humanoid.PlatformStand = false
	currentVel = Vector3.zero
	flyBtn.Text = "🚀 Fly Mode"
	cleanup()
end

-- Button actions
flyBtn.MouseButton1Click:Connect(function()
	if flying then stopFly() else startFly() end
end)

speedBtn.MouseButton1Click:Connect(function()
	if speedMode=="Normal" then speedMode="Fast"
	elseif speedMode=="Fast" then speedMode="Super Fast"
	else speedMode="Normal" end
	speedBtn.Text = "Speed: "..speedMode
end)

player.CharacterAdded:Connect(function(newChar)
	refreshCharacter(newChar)
	stopFly()
end)
