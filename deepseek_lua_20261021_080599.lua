local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LP = player
local Char = LP.Character or LP.CharacterAdded:Wait()
local HRP = Char:WaitForChild("HumanoidRootPart")
local Humanoid = Char:WaitForChild("Humanoid")

local farmSpeed = 50
local walkSpeed = 16
local isFarming = false
local farmingThread = nil
local isInvisible = false
local isMinimized = false
local dragging = false
local dragStart, startPos
local flyActive = false
local flySpeed = 1
local flyBg, flyBv, flyTpWalk
local flyUpHold, flyDownHold, flyUpConn, flyDownConn
local antiDieActive = false
local antiDieConns = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2FarmGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 440)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -220)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 16)
uiCorner.Parent = mainFrame

local glow = Instance.new("Frame")
glow.Size = UDim2.new(1.04, 0, 1.04, 0)
glow.Position = UDim2.new(-0.02, 0, -0.02, 0)
glow.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
glow.BackgroundTransparency = 0.6
glow.BorderSizePixel = 0
glow.Parent = mainFrame
local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 18)
glowCorner.Parent = glow

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 16)
topCorner.Parent = topBar

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 30, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 15, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 10, 10))
})
gradient.Parent = topBar

local umbrella = Instance.new("ImageLabel")
umbrella.Size = UDim2.new(0, 32, 0, 32)
umbrella.Position = UDim2.new(0, 12, 0.5, -16)
umbrella.BackgroundTransparency = 1
umbrella.Image = "rbxassetid:6031097223"
umbrella.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0, 52, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MM2 Farm"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextStrokeColor3 = Color3.fromRGB(80, 0, 0)
title.TextStrokeTransparency = 0.5
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -73, 0.5, -15)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.TextScaled = true
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = topBar
local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 10)
minimizeCorner.Parent = minimizeBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = topBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeBtn

local contentContainer = Instance.new("ScrollingFrame")
contentContainer.Size = UDim2.new(1, 0, 1, -42)
contentContainer.Position = UDim2.new(0, 0, 0, 42)
contentContainer.BackgroundTransparency = 1
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
contentContainer.ScrollBarThickness = 4
contentContainer.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)
layout.Parent = contentContainer
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end)

local function addLabel(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = contentContainer
    return lbl
end

local function addButton(text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 34)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 80)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = contentContainer
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function addSlider(label, minVal, maxVal, defVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 34)
    frame.BackgroundTransparency = 1
    frame.Parent = contentContainer
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. tostring(defVal)
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame
    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 28, 0, 28)
    minus.Position = UDim2.new(0.7, 0, 0.5, -14)
    minus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    minus.Text = "−"
    minus.TextColor3 = Color3.new(1,1,1)
    minus.TextScaled = true
    minus.Font = Enum.Font.GothamBold
    minus.Parent = frame
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 8)
    mc.Parent = minus
    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 28, 0, 28)
    plus.Position = UDim2.new(0.85, 0, 0.5, -14)
    plus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    plus.Text = "+"
    plus.TextColor3 = Color3.new(1,1,1)
    plus.TextScaled = true
    plus.Font = Enum.Font.GothamBold
    plus.Parent = frame
    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 8)
    pc.Parent = plus
    local value = defVal
    minus.MouseButton1Click:Connect(function()
        value = math.max(minVal, value - 5)
        lbl.Text = label .. ": " .. tostring(math.floor(value))
        callback(value)
    end)
    plus.MouseButton1Click:Connect(function()
        value = math.min(maxVal, value + 5)
        lbl.Text = label .. ": " .. tostring(math.floor(value))
        callback(value)
    end)
end

local statusLabel = addLabel("● Status: Ready!", Color3.fromRGB(200,200,200))
addSlider("Farm Speed", 10, 100, 50, function(v) farmSpeed = v end)
addSlider("Walk Speed", 10, 200, 16, function(v) walkSpeed = v; if Humanoid then Humanoid.WalkSpeed = v end end)

local startButton = addButton("▶ START", Color3.fromRGB(200,30,30), function() toggleFarming() end)
local invisibleBtn = addButton("👻 Invisible", Color3.fromRGB(70,70,180), function() toggleInvisibility() end)

local sep1 = Instance.new("Frame")
sep1.Size = UDim2.new(0.9, 0, 0, 2)
sep1.BackgroundColor3 = Color3.fromRGB(100,100,100)
sep1.BackgroundTransparency = 0.5
sep1.Parent = contentContainer

addLabel("--- Teleport ---", Color3.fromRGB(150,150,150))
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Size = UDim2.new(0.9, 0, 0, 100)
playerListFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
playerListFrame.BorderSizePixel = 0
playerListFrame.ScrollBarThickness = 4
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerListFrame.Parent = contentContainer
local plc = Instance.new("UICorner")
plc.CornerRadius = UDim.new(0, 6)
plc.Parent = playerListFrame
local pll = Instance.new("UIListLayout")
pll.FillDirection = Enum.FillDirection.Vertical
pll.SortOrder = Enum.SortOrder.LayoutOrder
pll.Padding = UDim.new(0, 2)
pll.Parent = playerListFrame
local plp = Instance.new("UIPadding")
plp.PaddingTop = UDim.new(0, 2)
plp.PaddingBottom = UDim.new(0, 2)
plp.PaddingLeft = UDim.new(0, 4)
plp.PaddingRight = UDim.new(0, 4)
plp.Parent = playerListFrame

local playerBtns = {}
local function updatePlayerList()
    for _, b in pairs(playerBtns) do b:Destroy() end
    playerBtns = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 26)
            b.BackgroundColor3 = Color3.fromRGB(40,40,50)
            b.Text = plr.Name
            b.TextColor3 = Color3.new(1,1,1)
            b.Font = Enum.Font.SourceSans
            b.TextSize = 14
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Parent = playerListFrame
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 4)
            c.Parent = b
            b.MouseButton1Click:Connect(function()
                local target = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if target and HRP then
                    HRP.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                end
            end)
            playerBtns[plr] = b
        end
    end
end
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

local sep2 = Instance.new("Frame")
sep2.Size = UDim2.new(0.9, 0, 0, 2)
sep2.BackgroundColor3 = Color3.fromRGB(100,100,100)
sep2.BackgroundTransparency = 0.5
sep2.Parent = contentContainer

addLabel("--- Fly ---", Color3.fromRGB(150,150,150))
local flyFrame = Instance.new("Frame")
flyFrame.Size = UDim2.new(0.9, 0, 0, 56)
flyFrame.BackgroundTransparency = 1
flyFrame.Parent = contentContainer
local flyUp = Instance.new("TextButton")
flyUp.Size = UDim2.new(0.3, 0, 0.5, 0)
flyUp.BackgroundColor3 = Color3.fromRGB(200,50,50)
flyUp.Text = "UP"
flyUp.TextColor3 = Color3.new(1,1,1)
flyUp.TextScaled = true
flyUp.Font = Enum.Font.GothamBold
flyUp.Parent = flyFrame
local fuc = Instance.new("UICorner")
fuc.CornerRadius = UDim.new(0, 6)
fuc.Parent = flyUp
local flyDown = Instance.new("TextButton")
flyDown.Size = UDim2.new(0.3, 0, 0.5, 0)
flyDown.Position = UDim2.new(0, 0, 0.5, 0)
flyDown.BackgroundColor3 = Color3.fromRGB(150,30,30)
flyDown.Text = "DOWN"
flyDown.TextColor3 = Color3.new(1,1,1)
flyDown.TextScaled = true
flyDown.Font = Enum.Font.GothamBold
flyDown.Parent = flyFrame
local fdc = Instance.new("UICorner")
fdc.CornerRadius = UDim.new(0, 6)
fdc.Parent = flyDown
local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(0.2, 0, 0.3, 0)
flySpeedLabel.Position = UDim2.new(0.35, 0, 0.35, 0)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "1"
flySpeedLabel.TextColor3 = Color3.fromRGB(255,200,100)
flySpeedLabel.TextScaled = true
flySpeedLabel.Font = Enum.Font.GothamBold
flySpeedLabel.Parent = flyFrame
local flyMinus = Instance.new("TextButton")
flyMinus.Size = UDim2.new(0.1, 0, 0.3, 0)
flyMinus.Position = UDim2.new(0.33, 0, 0.35, 0)
flyMinus.BackgroundColor3 = Color3.fromRGB(80,80,80)
flyMinus.Text = "-"
flyMinus.TextColor3 = Color3.new(1,1,1)
flyMinus.TextScaled = true
flyMinus.Font = Enum.Font.GothamBold
flyMinus.Parent = flyFrame
local fmc = Instance.new("UICorner")
fmc.CornerRadius = UDim.new(0, 6)
fmc.Parent = flyMinus
local flyPlus = Instance.new("TextButton")
flyPlus.Size = UDim2.new(0.1, 0, 0.3, 0)
flyPlus.Position = UDim2.new(0.55, 0, 0.35, 0)
flyPlus.BackgroundColor3 = Color3.fromRGB(80,80,80)
flyPlus.Text = "+"
flyPlus.TextColor3 = Color3.new(1,1,1)
flyPlus.TextScaled = true
flyPlus.Font = Enum.Font.GothamBold
flyPlus.Parent = flyFrame
local fpc = Instance.new("UICorner")
fpc.CornerRadius = UDim.new(0, 6)
fpc.Parent = flyPlus
local flyToggleBtn = Instance.new("TextButton")
flyToggleBtn.Size = UDim2.new(0.3, 0, 0.4, 0)
flyToggleBtn.Position = UDim2.new(0.7, 0, 0.3, 0)
flyToggleBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
flyToggleBtn.Text = "FLY OFF"
flyToggleBtn.TextColor3 = Color3.new(1,1,1)
flyToggleBtn.TextScaled = true
flyToggleBtn.Font = Enum.Font.GothamBold
flyToggleBtn.Parent = flyFrame
local ftc = Instance.new("UICorner")
ftc.CornerRadius = UDim.new(0, 6)
ftc.Parent = flyToggleBtn

local sep3 = Instance.new("Frame")
sep3.Size = UDim2.new(0.9, 0, 0, 2)
sep3.BackgroundColor3 = Color3.fromRGB(100,100,100)
sep3.BackgroundTransparency = 0.5
sep3.Parent = contentContainer

addLabel("--- Anti-Death ---", Color3.fromRGB(150,150,150))
local antiBtn = addButton("ANTI-DIE: OFF", Color3.fromRGB(180,0,0), function() toggleAntiDie() end)

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, 0, 0, 20)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "yuno le boss"
creditLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
creditLabel.TextScaled = true
creditLabel.Font = Enum.Font.GothamSemibold
creditLabel.TextTransparency = 0.3
creditLabel.Parent = contentContainer

local function GetMap()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:GetAttribute("MapID") and obj:FindFirstChild("CoinContainer") then
            return obj
        end
    end
    return nil
end

local function getNearest()
    local map = GetMap()
    if not map then return nil end
    local closest, dist = nil, math.huge
    for _, coin in ipairs(map.CoinContainer:GetChildren()) do
        local v = coin:FindFirstChild("CoinVisual")
        if v and not v:GetAttribute("Collected") then
            local d = (HRP.Position - coin.Position).Magnitude
            if d < dist then
                closest = coin
                dist = d
            end
        end
    end
    return closest
end

local function tp(hp)
    if not hp or not HRP or not Humanoid then return end
    Humanoid:ChangeState(11)
    local d = (HRP.Position - hp.Position).Magnitude
    local speedFactor = farmSpeed / 50
    local tweenTime = d / (25 * speedFactor)
    tweenTime = math.max(tweenTime, 0.05)
    local t = TweenService:Create(HRP, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = hp.CFrame})
    t:Play()
    t.Completed:Wait()
end

local function startFarming()
    if farmingThread then task.cancel(farmingThread); farmingThread = nil end
    isFarming = true
    farmingThread = task.spawn(function()
        while isFarming do
            local target = getNearest()
            if target and HRP and Humanoid then
                tp(target)
                local v = target:FindFirstChild("CoinVisual")
                while v and not v:GetAttribute("Collected") and v.Parent and isFarming do
                    local n = getNearest()
                    if n and n ~= target then break end
                    task.wait(0.05)
                end
            else
                task.wait(0.3)
            end
        end
    end)
end

local function stopFarming()
    isFarming = false
    if farmingThread then task.cancel(farmingThread); farmingThread = nil end
end

function toggleFarming()
    if isFarming then
        stopFarming()
        startButton.Text = "▶ START"
        startButton.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
        statusLabel.Text = "● Status: Stopped"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        startFarming()
        startButton.Text = "⏹ STOP"
        startButton.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
        statusLabel.Text = "● Status: Farming..."
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end

function toggleInvisibility()
    isInvisible = not isInvisible
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = isInvisible and 1 or 0
        elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then
            part.Handle.Transparency = isInvisible and 1 or 0
        end
    end
    if isInvisible then
        char:SetAttribute("Invisible", true)
        invisibleBtn.Text = "👁️ Visible"
        invisibleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    else
        char:SetAttribute("Invisible", false)
        invisibleBtn.Text = "👻 Invisible"
        invisibleBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 180)
    end
end

flyMinus.MouseButton1Click:Connect(function()
    if flySpeed > 1 then flySpeed = flySpeed - 1; flySpeedLabel.Text = tostring(flySpeed) end
end)
flyPlus.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 1; flySpeedLabel.Text = tostring(flySpeed)
end)

flyUp.MouseButton1Down:Connect(function()
    flyUpHold = true
    if flyUpConn then flyUpConn:Disconnect() end
    flyUpConn = RunService.Heartbeat:Connect(function()
        if flyUpHold and flyActive and HRP then
            HRP.CFrame = HRP.CFrame * CFrame.new(0, 1 * flySpeed, 0)
        end
    end)
end)
flyUp.MouseButton1Up:Connect(function()
    flyUpHold = false
    if flyUpConn then flyUpConn:Disconnect(); flyUpConn = nil end
end)
flyDown.MouseButton1Down:Connect(function()
    flyDownHold = true
    if flyDownConn then flyDownConn:Disconnect() end
    flyDownConn = RunService.Heartbeat:Connect(function()
        if flyDownHold and flyActive and HRP then
            HRP.CFrame = HRP.CFrame * CFrame.new(0, -1 * flySpeed, 0)
        end
    end)
end)
flyDown.MouseButton1Up:Connect(function()
    flyDownHold = false
    if flyDownConn then flyDownConn:Disconnect(); flyDownConn = nil end
end)

local function toggleFly()
    flyActive = not flyActive
    if flyActive then
        flyToggleBtn.Text = "FLY ON"
        flyToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        if not LP.Character then return end
        Humanoid.PlatformStand = true
        flyBg = Instance.new("BodyGyro", HRP)
        flyBg.P = 9e4
        flyBg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBg.CFrame = HRP.CFrame
        flyBv = Instance.new("BodyVelocity", HRP)
        flyBv.Velocity = Vector3.new(0, 0, 0)
        flyBv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyTpWalk = true
        task.spawn(function()
            while flyTpWalk and flyActive do
                RunService.Heartbeat:Wait()
                if Humanoid and Humanoid.MoveDirection.Magnitude > 0 then
                    HRP:TranslateBy(Humanoid.MoveDirection)
                end
            end
        end)
    else
        flyToggleBtn.Text = "FLY OFF"
        flyToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        if flyBg then flyBg:Destroy(); flyBg = nil end
        if flyBv then flyBv:Destroy(); flyBv = nil end
        flyTpWalk = false
        Humanoid.PlatformStand = false
    end
end
flyToggleBtn.MouseButton1Click:Connect(toggleFly)

local function activateAntiDie(char)
    if not char then char = LP.Character end
    if not char then return {} end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return {} end
    local conns = {}
    hum.BreakJointsOnDeath = false
    local hc = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum and hum.Parent and hum.Health <= 0 and hum.MaxHealth > 0 then
            hum.Health = hum.MaxHealth
            if hum:GetState() == Enum.HumanoidStateType.Dead then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end)
    table.insert(conns, hc)
    return conns
end

local function cleanupAntiDie()
    for _, c in ipairs(antiDieConns) do
        if c and c.Disconnect then c:Disconnect() end
    end
    antiDieConns = {}
end

function toggleAntiDie()
    antiDieActive = not antiDieActive
    if antiDieActive then
        antiBtn.Text = "ANTI-DIE: ON"
        antiBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 50)
        cleanupAntiDie()
        local char = LP.Character
        if char then antiDieConns = activateAntiDie(char) end
    else
        antiBtn.Text = "ANTI-DIE: OFF"
        antiBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        cleanupAntiDie()
    end
end
antiBtn.MouseButton1Click:Connect(toggleAntiDie)

local function toggleMinimize()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, 200, 0, 42), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        minimizeBtn.Text = "+"
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        contentContainer.Visible = false
        umbrella.Visible = false
        glow.Size = UDim2.new(1.08, 0, 1.12, 0)
        glow.Position = UDim2.new(-0.04, 0, -0.06, 0)
        title.Text = "Yuno farm"
        title.Position = UDim2.new(0, 12, 0, 0)
        title.Size = UDim2.new(0.8, 0, 1, 0)
        topCorner.CornerRadius = UDim.new(0, 20)
    else
        mainFrame:TweenSize(UDim2.new(0, 300, 0, 440), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        minimizeBtn.Text = "−"
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        contentContainer.Visible = true
        umbrella.Visible = true
        glow.Size = UDim2.new(1.04, 0, 1.04, 0)
        glow.Position = UDim2.new(-0.02, 0, -0.02, 0)
        title.Text = "MM2 Farm"
        title.Position = UDim2.new(0, 52, 0, 0)
        title.Size = UDim2.new(0.5, 0, 1, 0)
        topCorner.CornerRadius = UDim.new(0, 16)
    end
end
minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

closeBtn.MouseButton1Click:Connect(function()
    mainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
    task.wait(0.3)
    stopFarming()
    screenGui:Destroy()
end)

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        local connection
        connection = UserInputService.InputChanged:Connect(function(input2)
            if dragging and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch) then
                local delta = input2.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                connection:Disconnect()
            end
        end)
    end
end)

LP.CharacterAdded:Connect(function(char)
    Char = char
    HRP = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    if Humanoid then Humanoid.WalkSpeed = walkSpeed end
    if isInvisible then
        task.wait(0.2)
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.Transparency = 1
            elseif part:IsA("Accessory") and part:FindFirstChild("Handle") then part.Handle.Transparency = 1 end
        end
        char:SetAttribute("Invisible", true)
        invisibleBtn.Text = "👁️ Visible"
        invisibleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    end
    if antiDieActive then
        task.wait(0.2)
        cleanupAntiDie()
        antiDieConns = activateAntiDie(char)
    end
end)

print("MM2 Farm amélioré chargé !")