local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Empfängt die übergebenen Argumente (Aktion & optionale Geschwindigkeit)
local action, speedParam = ...

-- Globale Speicherung der Verbindungen und Daten, damit sie beim Script-Neustart erhalten bleiben
_G.FlyState = _G.FlyState or {
    isFlying = false,
    flySpeed = 30,
    connection = nil,
    targetPart = nil,
    moveKeys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}
}

local state = _G.FlyState

-- Geschwindigkeit anpassen, falls übergeben (Standard: 30)
if type(speedParam) == "number" then
    state.flySpeed = speedParam
    print("[FLY] Geschwindigkeit gesetzt auf: " .. state.flySpeed)
end

local function getTarget()
    local subject = camera.CameraSubject
    if subject then
        local model = subject:FindFirstAncestorOfClass("Model")
        if model then
            return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        elseif subject:IsA("BasePart") then
            return subject
        end
    end
    
    if player.Character then
        return player.Character:FindFirstChild("HumanoidRootPart")
    end
    
    return nil
end

local function stopFly()
    state.isFlying = false
    if state.connection then 
        state.connection:Disconnect()
        state.connection = nil 
    end
    if state.targetPart then
        state.targetPart.Anchored = false
        print("[FLY] DEAKTIVIERT.")
    end
end

local function startFly()
    if state.isFlying then stopFly() end -- Falls noch aktiv, erst sauber stoppen

    state.targetPart = getTarget()
    if not state.targetPart then 
        warn("[ABBRUCH] Kein flugfähiges Objekt gefunden!")
        return 
    end

    state.isFlying = true
    print("[FLY] AKTIVIERT! Ziel: " .. state.targetPart.Name .. " (Speed: " .. state.flySpeed .. ")")
    state.targetPart.Anchored = true 

    -- Tastatur-Inputs beim ersten Start einmalig registrieren
    if not state.inputConnected then
        local UserInputService = game:GetService("UserInputService")
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if state.moveKeys[input.KeyCode.Name] ~= nil then 
                state.moveKeys[input.KeyCode.Name] = true 
            end
        end)

        UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if state.moveKeys[input.KeyCode.Name] ~= nil then 
                state.moveKeys[input.KeyCode.Name] = false 
            end
        end)
        state.inputConnected = true
    end

    state.connection = RunService.RenderStepped:Connect(function(deltaTime)
        if not state.isFlying or not state.targetPart or not state.targetPart.Parent then
            stopFly()
            return
        end

        local moveVector = Vector3.zero
        if state.moveKeys.W then moveVector += camera.CFrame.LookVector end
        if state.moveKeys.S then moveVector -= camera.CFrame.LookVector end
        if state.moveKeys.A then moveVector -= camera.CFrame.RightVector end
        if state.moveKeys.D then moveVector += camera.CFrame.RightVector end
        if state.moveKeys.Space then moveVector += Vector3.new(0, 1, 0) end
        if state.moveKeys.LeftShift then moveVector -= Vector3.new(0, 1, 0) end

        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * state.flySpeed
        end

        local newPos = state.targetPart.Position + (moveVector * deltaTime)
        state.targetPart.CFrame = CFrame.new(newPos, newPos + camera.CFrame.LookVector)
    end)
end

-- Ausführung basierend auf der übergebenen 'action'
if action == "fly" then
    startFly()
elseif action == "unfly" then
    stopFly()
else
    warn("[FLY] Ungültige oder fehlende Aktion! Nutze 'fly' oder 'unfly'. Beispiel: ...(\"fly\", 50)")
end
