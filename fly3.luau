local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local action, speedParam = ...

_G.FlyState = _G.FlyState or {
    isFlying = false,
    flySpeed = 30,
    connection = nil,
    cframeConnection = nil,
    targetPart = nil,
    lastCF = nil,
    stopCFChange = false,
    bodyVel = nil,
    bodyGyro = nil,
    moveKeys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}
}

local state = _G.FlyState

if type(speedParam) == "number" then
    state.flySpeed = speedParam
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
    
    if state.connection then state.connection:Disconnect() state.connection = nil end
    if state.cframeConnection then state.cframeConnection:Disconnect() state.cframeConnection = nil end

    if state.bodyVel then state.bodyVel:Destroy() state.bodyVel = nil end
    if state.bodyGyro then state.bodyGyro:Destroy() state.bodyGyro = nil end

    if state.targetPart then
        state.targetPart.Anchored = false
        local hum = state.targetPart.Parent and state.targetPart.Parent:FindFirstChildOfClass("Humanoid")
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
    state.targetPart.Anchored = false 
    print("[FLY] AKTIVIERT! Ziel: " .. state.targetPart.Name .. " (Speed: " .. state.flySpeed .. ")")

    -- Character in den PlatformStand setzen (verhindert, dass Roblox Lauf-Physik anwendet)
    local hum = state.targetPart.Parent and state.targetPart.Parent:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end

    -- DER TRICK: BodyVelocity auf 0 setzen. 
    -- Das blockiert die Schwerkraft, ABER das Anti-Cheat sieht eine Geschwindigkeit von 0!
    state.bodyVel = Instance.new("BodyVelocity")
    state.bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    state.bodyVel.Velocity = Vector3.zero
    state.bodyVel.Parent = state.targetPart

    state.bodyGyro = Instance.new("BodyGyro")
    state.bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    state.bodyGyro.P = 9e4
    state.bodyGyro.CFrame = camera.CFrame
    state.bodyGyro.Parent = state.targetPart

    -- DEIN ANTI-TELEPORT (CFrame-Lock)
    -- Da wir via Script fliegen, feuert das hier NUR, wenn der Server dich zurücksetzt.
    state.cframeConnection = state.targetPart:GetPropertyChangedSignal("CFrame"):Connect(function()
        if not state.isFlying or state.stopCFChange then return end 
        
        -- Server greift ein -> Wir schlagen sofort zurück!
        state.stopCFChange = true
        state.targetPart.CFrame = state.lastCF
        RunService.Heartbeat:Wait()
        state.stopCFChange = false
    end)

    if not state.inputConnected then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if state.moveKeys[input.KeyCode.Name] ~= nil then state.moveKeys[input.KeyCode.Name] = true end
        end)
        UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if state.moveKeys[input.KeyCode.Name] ~= nil then state.moveKeys[input.KeyCode.Name] = false end
        end)
        state.inputConnected = true
    end

    -- Flug-Schleife (Wir bewegen dich manuell über CFrame)
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

        -- Neue Position berechnen
        local newPos = state.targetPart.Position + (moveVector * deltaTime)
        local targetCFrame = CFrame.new(newPos, newPos + camera.CFrame.LookVector)

        -- Position setzen. Wir schalten unseren Anti-Teleport-Alarm für diese 
        -- eine Millisekunde ab, damit wir uns nicht selbst blockieren!
        state.stopCFChange = true
        state.targetPart.CFrame = targetCFrame
        state.lastCF = targetCFrame
        state.stopCFChange = false

        state.bodyGyro.CFrame = camera.CFrame
    end)
end

if action == "fly" then
    startFly()
elseif action == "unfly" then
    stopFly()
end
