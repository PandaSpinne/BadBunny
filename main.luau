local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Falls schon vorhanden, entfernen
local existing = playerGui:FindFirstChild("DebugConsoleGui")
if existing then existing:Destroy() end

-- ========================
-- UI AUFBAU
-- ========================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugConsoleGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true

-- Haupt-Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 440, 0, 300)
mainFrame.Position = UDim2.new(1, -455, 1, -315)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(55, 55, 110)
mainStroke.Thickness = 1.2
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

-- Schatten
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6015897893"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)
shadow.ZIndex = mainFrame.ZIndex - 1
shadow.Parent = mainFrame

-- Titel-Leiste
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 52)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleFill = Instance.new("Frame")
titleFill.Size = UDim2.new(1, 0, 0, 10)
titleFill.Position = UDim2.new(0, 0, 1, -10)
titleFill.BackgroundColor3 = Color3.fromRGB(28, 28, 52)
titleFill.BorderSizePixel = 0
titleFill.Parent = titleBar

-- Icon
local iconLabel = Instance.new("ImageLabel")
iconLabel.Size = UDim2.new(0, 18, 0, 18)
iconLabel.Position = UDim2.new(0, 10, 0.5, -9)
iconLabel.BackgroundTransparency = 1
iconLabel.Image = "rbxassetid://121696069"
iconLabel.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 32, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Bad Bunny"
titleLabel.TextColor3 = Color3.fromRGB(190, 190, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.LuckiestGuy
titleLabel.TextSize = 13
titleLabel.Parent = titleBar

-- Schließen-Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -30, 0.5, -12)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
closeButton.BackgroundTransparency = 0.6
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(190, 190, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 26
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- Trennlinie
local separator = Instance.new("Frame")
separator.Size = UDim2.new(1, -16, 0, 1)
separator.Position = UDim2.new(0, 8, 0, 32)
separator.BackgroundColor3 = Color3.fromRGB(55, 55, 100)
separator.BackgroundTransparency = 0.5
separator.BorderSizePixel = 0
separator.Parent = mainFrame

-- Ausgabe-Bereich
local outputFrame = Instance.new("ScrollingFrame")
outputFrame.Name = "Output"
outputFrame.Size = UDim2.new(1, -16, 1, -90)
outputFrame.Position = UDim2.new(0, 8, 0, 38)
outputFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 24)
outputFrame.BorderSizePixel = 0
outputFrame.ScrollBarThickness = 3
outputFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 140)
outputFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
outputFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
outputFrame.Parent = mainFrame

local outputCorner = Instance.new("UICorner")
outputCorner.CornerRadius = UDim.new(0, 6)
outputCorner.Parent = outputFrame

local outputLayout = Instance.new("UIListLayout")
outputLayout.SortOrder = Enum.SortOrder.LayoutOrder
outputLayout.Padding = UDim.new(0, 1)
outputLayout.Parent = outputFrame

local outputPadding = Instance.new("UIPadding")
outputPadding.PaddingLeft = UDim.new(0, 8)
outputPadding.PaddingRight = UDim.new(0, 8)
outputPadding.PaddingTop = UDim.new(0, 6)
outputPadding.PaddingBottom = UDim.new(0, 6)
outputPadding.Parent = outputFrame

-- Eingabe-Leiste
local inputBar = Instance.new("Frame")
inputBar.Size = UDim2.new(1, -16, 0, 28)
inputBar.Position = UDim2.new(0, 8, 1, -35)
inputBar.BackgroundColor3 = Color3.fromRGB(22, 22, 42)
inputBar.BorderSizePixel = 0
inputBar.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = inputBar

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(70, 70, 140)
inputStroke.Thickness = 1
inputStroke.Transparency = 0.4
inputStroke.Parent = inputBar

local inputIcon = Instance.new("TextLabel")
inputIcon.Size = UDim2.new(0, 20, 1, 0)
inputIcon.Position = UDim2.new(0, 6, 0, 0)
inputIcon.BackgroundTransparency = 1
inputIcon.Text = ">"
inputIcon.TextColor3 = Color3.fromRGB(120, 120, 255)
inputIcon.Font = Enum.Font.GothamBold
inputIcon.TextSize = 14
inputIcon.Parent = inputBar

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -32, 1, 0)
inputBox.Position = UDim2.new(0, 26, 0, 0)
inputBox.BackgroundTransparency = 1
inputBox.Text = ""
inputBox.PlaceholderText = "Befehl eingeben..."
inputBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 140)
inputBox.TextColor3 = Color3.fromRGB(220, 220, 255)
inputBox.Font = Enum.Font.Code
inputBox.TextSize = 13
inputBox.TextXAlignment = Enum.TextXAlignment.Left
inputBox.ClearTextOnFocus = false
inputBox.Parent = inputBar

screenGui.Parent = playerGui

-- ========================
-- LOGIK
-- ========================

local commandHistory = {}
local historyIndex = 0
local isVisible = false

-- Nach Rejoin automatisch öffnen, falls TeleportData vorhanden
local teleportData = TeleportService:GetLocalPlayerTeleportData()
if type(teleportData) == "table" and teleportData.debugConsole then
    isVisible = true
    mainFrame.Visible = true
end

local function addOutput(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Text = text
    label.Parent = outputFrame

    task.defer(function()
        outputFrame.CanvasPosition = Vector2.new(0, math.huge)
    end)
end

local function executeCode(code)
    local func, err = loadstring(code)
    if func then
        local success, result = pcall(func)
        if success then
            local output = "✓ Ausgeführt"
            if result ~= nil then
                output = output .. " → " .. tostring(result)
            end
            addOutput(output, Color3.fromRGB(80, 255, 120))
        else
            addOutput("✗ Fehler: " .. tostring(result), Color3.fromRGB(255, 80, 80))
        end
    else
        addOutput("✗ Syntax-Fehler: " .. tostring(err), Color3.fromRGB(255, 80, 80))
    end
end

local function toggleConsole(show)
    isVisible = show
    mainFrame.Visible = show
    if show then
        mainFrame.BackgroundTransparency = 1
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0
        }):Play()
        inputBox:CaptureFocus()
    else
        local tweenOut = TweenService:Create(mainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            mainFrame.Visible = false
            mainFrame.BackgroundTransparency = 0
        end)
    end
end

-- Eingabe verarbeiten
inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
		-- NEU: Setzt den Cursor sofort wieder in das Textfeld zurück
        task.defer(function()
            inputBox:CaptureFocus()
        end)

        local text = string.match(inputBox.Text, "^%s*(.-)%s*$")
        inputBox.Text = ""

        if text == "" then return end

        table.insert(commandHistory, text)
        historyIndex = #commandHistory + 1

        if text == "clear" then
            for _, child in outputFrame:GetChildren() do
                if child:IsA("TextLabel") then
                    child:Destroy()
                end
            end
            return
        end

        if text == "rejoin" then
            addOutput("⟳ Rejoine Server...", Color3.fromRGB(255, 200, 80))
            local jobId = game.JobId
            local placeId = game.PlaceId
            local rejoinData = {debugConsole = true}
            if jobId ~= "" then
                TeleportService:TeleportToPlaceInstance(placeId, jobId, player, nil, rejoinData)
            else
                TeleportService:Teleport(placeId, player, rejoinData)
            end
            return
        end
        
        if text == "cobalt" then
            loadstring(game:HttpGet("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"))()
            return
        end

        -- NEU: Checkt, ob der Text mit "fly" anfängt und holt eine evtl. Zahl
        local speedParam = string.match(text, "^fly%s*(%d*)$")
        if speedParam then
            local speed = tonumber(speedParam)
            if speed then
                -- Falls eine Zahl übergeben wurde (z.B. "fly 50")
                loadstring(game:HttpGet("https://raw.githubusercontent.com/PandaSpinne/BadBunny/refs/heads/main/fly.luau"))("fly", speed)
            else
                -- Falls nur "fly" eingegeben wurde
                loadstring(game:HttpGet("https://raw.githubusercontent.com/PandaSpinne/BadBunny/refs/heads/main/fly.luau"))("fly")
            end
            return
        end

        if text == "unfly" then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/PandaSpinne/BadBunny/refs/heads/main/fly.luau"))("unfly")
            return
        end

        addOutput("> " .. text, Color3.fromRGB(160, 160, 255))
        executeCode(text)
    end
end)

-- Rechts-Shift Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleConsole(not isVisible)
    end
end)

-- Befehlsverlauf mit Pfeiltasten
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not isVisible then return end

    if input.KeyCode == Enum.KeyCode.Up then
        if historyIndex > 1 then
            historyIndex = historyIndex - 1
            inputBox.Text = commandHistory[historyIndex] or ""
        end
    elseif input.KeyCode == Enum.KeyCode.Down then
        if historyIndex < #commandHistory then
            historyIndex = historyIndex + 1
            inputBox.Text = commandHistory[historyIndex] or ""
        else
            historyIndex = #commandHistory + 1
            inputBox.Text = ""
        end
    end
end)

-- Schließen-Button
closeButton.MouseButton1Click:Connect(function()
    toggleConsole(false)
end)

-- Hover-Effekt Schließen-Button
closeButton.MouseEnter:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
end)
closeButton.MouseLeave:Connect(function()
    TweenService:Create(closeButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.6}):Play()
end)

-- ========================
-- DRAG (Fenster verschieben)
-- ========================

local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        inputBox:ReleaseFocus()
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
