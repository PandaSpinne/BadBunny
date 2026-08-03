local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local isFlying = false
local flySpeed = 30 -- Startgeschwindigkeit (etwas moderater)
local targetPart = nil
local connection = nil
local moveKeys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

print("\n=======================================")
print("[FLY-DEBUG] Script geladen!")
print("[FLY-DEBUG] Drücke 'F' zum Starten/Stoppen.")
print("[FLY-DEBUG] Drücke 'E' für SCHNELLER, 'Q' für LANGSAMER.")
print("=======================================\n")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if moveKeys[input.KeyCode.Name] ~= nil then moveKeys[input.KeyCode.Name] = true end
    
    if input.KeyCode == Enum.KeyCode.F then
        if isFlying then stopFly() else startFly() end
    elseif isFlying and input.KeyCode == Enum.KeyCode.Q then
        flySpeed = flySpeed + 10
        print("[SPEED] Erhöht auf: " .. flySpeed)
    elseif isFlying and input.KeyCode == Enum.KeyCode.E then
        flySpeed = math.max(5, flySpeed - 10)
        print("[SPEED] Verringert auf: " .. flySpeed)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if moveKeys[input.KeyCode.Name] ~= nil then moveKeys[input.KeyCode.Name] = false end
end)

local function getTarget()
    -- Kamera-Fokus nehmen (funktioniert auch bei Custom-Charakteren)
    local subject = camera.CameraSubject
    if subject then
        local model = subject:FindFirstAncestorOfClass("Model")
        if model then
            return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        elseif subject:IsA("BasePart") then
            return subject
        end
    end
    
    -- Fallback auf normalen Player
    if player.Character then
        return player.Character:FindFirstChild("HumanoidRootPart")
    end
    
    return nil
end

function startFly()
    targetPart = getTarget()
    if not targetPart then 
        warn("[ABBRUCH] Kein flugfähiges Objekt gefunden!")
        return 
    end

    isFlying = true
    print("[FLUG] AKTIVIERT! Ziel: " .. targetPart.Name)
    targetPart.Anchored = true 

    connection = RunService.RenderStepped:Connect(function(deltaTime)
        if not isFlying or not targetPart or not targetPart.Parent then
            stopFly()
            return
        end

        local moveVector = Vector3.zero
        if moveKeys.W then moveVector += camera.CFrame.LookVector end
        if moveKeys.S then moveVector -= camera.CFrame.LookVector end
        if moveKeys.A then moveVector -= camera.CFrame.RightVector end
        if moveKeys.D then moveVector += camera.CFrame.RightVector end
        if moveKeys.Space then moveVector += Vector3.new(0, 1, 0) end
        if moveKeys.LeftShift then moveVector -= Vector3.new(0, 1, 0) end

        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * flySpeed
        end

        local newPos = targetPart.Position + (moveVector * deltaTime)
        targetPart.CFrame = CFrame.new(newPos, newPos + camera.CFrame.LookVector)
    end)
end

function stopFly()
    isFlying = false
    if connection then connection:Disconnect(); connection = nil end
    if targetPart then
        targetPart.Anchored = false
        print("[FLUG] DEAKTIVIERT.")
    end
end
