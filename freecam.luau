local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local enabled = false
local speed = 1.0
local cameraCFrame = camera.CFrame
local rotX, rotY = 0, 0

-- Funktion zum Umschalten
local function toggleFreecam()
    enabled = not enabled
    if enabled then
        cameraCFrame = camera.CFrame
        local _, y, _ = cameraCFrame:ToEulerAnglesYXZ()
        rotX, rotY = y, 0
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        camera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.O then toggleFreecam() end
end)

-- Maussteuerung (Direktes Abfangen der Delta-Bewegung)
UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if not enabled or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    
    local delta = input.Delta
    rotX -= delta.X * 0.005
    rotY -= delta.Y * 0.005
    rotY = math.clamp(rotY, -1.5, 1.5)
    
    -- Hier setzen wir die CFrame direkt, um das Spiel-Skript zu überschreiben
    cameraCFrame = CFrame.new(cameraCFrame.Position) * CFrame.fromEulerAnglesYXZ(rotY, rotX, 0)
end)

-- Scrollrad für Geschwindigkeit
UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if not enabled then return end
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        speed = math.clamp(speed + (input.Position.Z * 0.5), 0.1, 10.0)
    end
end)

-- Freecam Loop
RunService:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value + 100, function(dt)
    if not enabled then return end
    
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
    
    -- Charakter-Animationen verhindern:
    -- Wir setzen den HumanoidState auf 'Physics', damit er keine Lauf-Animationen abspielt
    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Physics)
    end
end)
