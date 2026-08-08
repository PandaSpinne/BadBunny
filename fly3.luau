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
    targetPart = nil,
    linearVelocity = nil,
    attachment = nil,
    moveKeys = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}
}

local state = _G.FlyState

if type(speedParam) == "number" then
    state.flySpeed = speedParam
end

-- Findet flexibel das richtige Part (auch bei Custom-Characters/Rigs/Vehicles)
local function getTarget()
    -- 1. Versuch: Über das Zielobjekt der Kamera (CameraSubject)
    local subject = camera.CameraSubject
    if subject then
        if subject:IsA("BasePart") then
            return subject
        elseif subject:IsA("Humanoid") then
            local parentModel = subject.Parent
            if parentModel then
                return parentModel:FindFirstChild("HumanoidRootPart") 
                    or parentModel.PrimaryPart 
                    or parentModel:FindFirstChildWhichIsA("BasePart")
            end
        end
    end
    
    -- 2. Versuch: Über das normale Character-Model des Spielers
    local char = player.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart") 
            or char.PrimaryPart 
            or char:FindFirstChildWhichIsA("BasePart")
    end

    -- 3. Versuch: Wenn sich der Charakter in einem Unterordner/Modell befindet
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and (child.Name == player.Name or child:GetAttribute("Owner") == player.Name) then
            return child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
        end
    end

    return nil
end

local function stopFly()
    state.isFlying = false
    
    if state.connection then 
        state.connection:Disconnect()
        state.connection = nil 
    end

    if state.linearVelocity then
        state.linearVelocity:Destroy()
        state.linearVelocity = nil
    end

    if state.attachment then
        state.attachment:Destroy()
        state.attachment = nil
    end

    if state.targetPart then
        state.targetPart.AssemblyLinearVelocity = Vector3.zero
        print("[FLY] DEAKTIVIERT.")
    end
end

local function startFly()
    if state.isFlying then stopFly() end

    state.targetPart = getTarget()
    if not state.targetPart then 
        warn("[ABBRUCH] Kein steuerbares Objekt / Part für den Flug gefunden!")
        return 
    end

    state.isFlying = true
    print("[FLY] AKTIVIERT! Flug-Objekt: " .. state.targetPart:GetFullName() .. " (Speed: " .. state.flySpeed .. ")")

    -- Attachment & LinearVelocity an das gefundene Custom-Part hängen
    state.attachment = Instance.new("Attachment")
    state.attachment.Name = "FlyAttachment"
    state.attachment.Parent = state.targetPart

    state.linearVelocity = Instance.new("LinearVelocity")
    state.linearVelocity.Name = "FlyLinearVelocity"
    state.linearVelocity.Attachment0 = state.attachment
    state.linearVelocity.MaxForce = math.huge
    state.linearVelocity.VectorVelocity = Vector3.zero
    state.linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    state.linearVelocity.Parent = state.targetPart

    -- Tastatur-Inputs registrieren
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

    -- Flug-Schleife
    state.connection = RunService.RenderStepped:Connect(function()
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

        if state.linearVelocity then
            state.linearVelocity.VectorVelocity = moveVector
        end
    end)
end

if action == "fly" then
    startFly()
elseif action == "unfly" then
    stopFly()
end
