local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

-- Modul laden
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local cameraModule = ReplicatedStorage:FindFirstChild("Modules", true):FindFirstChild("Camera")
local t = require(cameraModule)

local enabled = false
local speed = 1.0
local cameraCFrame = camera.CFrame
local rotX, rotY = 0, 0

local function toggleFreecam()
    enabled = not enabled
    if enabled then
        cameraCFrame = camera.CFrame
        local _, y, _ = cameraCFrame:ToEulerAnglesYXZ()
        rotX, rotY = y, 0
        t:Disable() -- Modul deaktivieren
    else
        t:Enable() -- Modul wieder aktivieren
        camera.CameraType = Enum.CameraType.Custom
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.O then toggleFreecam() end
end)

RunService:BindToRenderStep("FreecamLogic", Enum.RenderPriority.Camera.Value + 100, function(dt)
    if not enabled then return end
    
    -- 1. Charakter hart einfrieren
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.Anchored = true
    end
    
    -- 2. Kamera erzwingen
    camera.CameraType = Enum.CameraType.Scriptable
    
    local moveDir = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cameraCFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cameraCFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cameraCFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cameraCFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
    
    cameraCFrame = cameraCFrame + (moveDir * speed * dt * 60)
    camera.CFrame = cameraCFrame
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if not enabled or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local delta = input.Delta
        rotX -= delta.X * 0.005
        rotY -= delta.Y * 0.005
        rotY = math.clamp(rotY, -1.5, 1.5)
        cameraCFrame = CFrame.new(cameraCFrame.Position) * CFrame.fromEulerAnglesYXZ(rotY, rotX, 0)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if enabled and input.UserInputType == Enum.UserInputType.MouseWheel then
        speed = math.clamp(speed + (input.Position.Z * 0.5), 0.1, 20.0)
    end
end)
