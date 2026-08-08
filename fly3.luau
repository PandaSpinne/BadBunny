local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Empfängt die übergebenen Argumente (Aktion & optionale Geschwindigkeit)
local action, speedParam = ...

-- Globale Speicherung der Verbindungen und Daten
_G.FlyState = _G.FlyState or {
    isFlying = false,
    flySpeed = 30,
    connection = nil,
    cframeConnection = nil,
    targetPart = nil,
    lastCF = nil,
    stopCFChange = false,
    isUpdatingCFrame = false, -- Verhindert, dass wir uns selbst blockieren
    moveKeys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}
}

local state = _G.FlyState

-- Geschwindigkeit anpassen
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
    
    if state.cframeConnection then
        state.cframeConnection:Disconnect()
        state.cframeConnection = nil
    end

    if state.targetPart then
        state.targetPart.Anchored = false
        
        -- Den Charakter wieder normal laufen lassen
        local hum = state.targetPart.Parent:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        
        print("[FLY] DEAKTIVIERT.")
    end
end

local function startFly()
    if state.isFlying then stopFly() end 

    state.targetPart = getTarget()
    if not state.targetPart then 
        warn("[ABBRUCH] Kein flugfähiges Objekt gefunden!")
        return 
    end

    state.isFlying = true
    state.lastCF = state.targetPart.CFrame
    print("[FLY] AKTIVIERT! Ziel: " .. state.targetPart.Name .. " (Speed: " .. state.flySpeed .. ")")
    
    -- WICHTIG: NICHT ANCHOREN! Nur so sendet der Client deine Position an den Server für Interaktionen.
    state.targetPart.Anchored = false 

    -- PlatformStand verhindert, dass der Charakter in der Luft komische Lauf-Animationen abspielt
    local hum = state.targetPart.Parent:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end

    -- CFrame-Lock Logik: Deine Anti-Teleport/Lagback Methode
    state.cframeConnection = state.targetPart:GetPropertyChangedSignal("CFrame"):Connect(function()
        -- Wenn WIR die Position gerade updaten, blockiere es nicht
        if not state.isFlying or state.isUpdatingCFrame then return end 
        
        -- Wenn wir HIER landen, hat das Anti-Cheat vom Server versucht dich zu teleportieren!
        state.stopCFChange = true
        state.targetPart.CFrame = state.lastCF
        RunService.Heartbeat:Wait()
        state.stopCFChange = false
    end)

    -- Tastatur-Inputs beim ersten Start einmalig registrieren
    if not state.inputConnected then
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

    -- Haupt-Flug-Schleife
    state.connection = RunService.RenderStepped:Connect(function(deltaTime)
        if not state.isFlying or not state.targetPart or not state.targetPart.Parent then
            stopFly()
            return
        end

        -- Da wir nicht "Anchored" sind, müssen wir die Schwerkraft jeden Frame töten:
        state.targetPart.AssemblyLinearVelocity = Vector3.zero
        state.targetPart.AssemblyAngularVelocity = Vector3.zero

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
        local targetCFrame = CFrame.new(newPos, newPos + camera.CFrame.LookVector)

        -- Position aktualisieren und CFrame-Sperre kurz pausieren, damit wir uns selbst bewegen dürfen
        if not state.stopCFChange then
            state.lastCF = targetCFrame
            
            state.isUpdatingCFrame = true
            state.targetPart.CFrame = targetCFrame
            state.isUpdatingCFrame = false
        end
    end)
end

-- Ausführung
if action == "fly" then
    startFly()
elseif action == "unfly" then
    stopFly()
else
    warn("[FLY] Ungültige oder fehlende Aktion! Nutze 'fly' oder 'unfly'.")
end
