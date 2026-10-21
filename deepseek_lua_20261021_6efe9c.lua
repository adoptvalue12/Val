local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local flyBg, flyBv
local flyTpWalk = false
local flyUpHold, flyDownHold
local flyUpConn, flyDownConn
local antiDieActive = false
local antiDieConnections = {}
local antiDieKeybind = Enum.KeyCode.G
local waitingForKeybind = false
local spawnerGui = nil

local AllowedWeapons = {
    ["BaubleChroma"]=true,["Blossom_G"]=true,["GingerLuger"]=true,["Bioblade"]=true,
    ["Blossom_K"]=true,["Chill"]=true,["ChromaBioblade"]=true,["ChromaBoneblade"]=true,
    ["ChromaCookieblade"]=true,["ChromaDarksword"]=true,["ChromaDeathshard"]=true,
    ["ChromaFang"]=true,["ChromaFlames"]=true,["ChromaFrostbite"]=true,["ChromaGingersword"]=true,
    ["ChromaHeat"]=true,["ChromaLaser"]=true,["ChromaLightbringer"]=true,["ChromaLuger"]=true,
    ["ChromaLugercane"]=true,["ChromaLugerGG"]=true,["ChromaLugerXmas"]=true,["ChromaSaw"]=true,
    ["ChromaSeer"]=true,["ChromaShark"]=true,["ChromaSlasher"]=true,["ChromaSugar"]=true,
    ["ChromaTides"]=true,["ChromaTidesV2"]=true,["ChromaVampire"]=true,["ChromaVampireGun"]=true,
    ["ChromaXmas"]=true,["ChromaXmasGun"]=true,["ChromaYoru"]=true,["Cookieblade"]=true,
    ["Corrupt"]=true,["DarkSword"]=true,["Deathshard"]=true,["ElderwoodBlade"]=true,
    ["ElderwoodScythe"]=true,["Fang"]=true,["Flames"]=true,["Frostbite"]=true,
    ["Gingersword"]=true,["GreenLuger"]=true,["Hallowscythe"]=true,["Hallowscythe2025"]=true,
    ["Iceblaster"]=true,["Icecrusher"]=true,["Icepiercer"]=true,["Iceshard"]=true,
    ["Icewing"]=true,["Icebreaker"]=true,["Icebeam"]=true,["Icehammer"]=true,
    ["Lightbringer"]=true,["LogChopper"]=true,["Luger"]=true,["LugerCane"]=true,
    ["LugerGG"]=true,["LugerXmas"]=true,["Minty"]=true,["Nebula"]=true,["Pixel"]=true,
    ["Prismatic"]=true,["RedLuger"]=true,["Ripper"]=true,["Saw"]=true,["Seer"]=true,
    ["Shark"]=true,["Slasher"]=true,["Snowflake"]=true,["Sugar"]=true,["Tides"]=true,
    ["TidesV2"]=true,["Virtual"]=true,["Vampire"]=true,["VampireGun"]=true,
    ["Xmas"]=true,["XmasGun"]=true,["Yoru"]=true
}
local mysteryBoxes = {"MLG Box","Summer2025Box","KnifeBox5","KnifeBox2","MysteryBox1","GunBox3","GunBox2","KnifeBox3","KnifeBox4","KnifeBox1","MysteryBox2","GunBox1"}
local BoxControllerRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Shop") and ReplicatedStorage.Remotes.Shop:FindFirstChild("BoxController")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YunoHubFarm"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 460)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -230)
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
title.Text = "Yuno Hub"
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
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 80)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = contentContainer
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function addSlider(label, minVal, maxVal, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 34)
    frame.BackgroundTransparency = 1
    frame.Parent = contentContainer

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. tostring(defaultValue)
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
    local mcorner = Instance.new("UICorner")
    mcorner.CornerRadius = UDim.new(0, 8)
    mcorner.Parent = minus

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 28, 0, 28)
    plus.Position = UDim2.new(0.85, 0, 0.5, -14)
    plus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    plus.Text = "+"
    plus.TextColor3 = Color3.new(1,1,1)
    plus.TextScaled = true
    plus.Font = Enum.Font.GothamBold
    plus.Parent = frame
    local pcorner = Instance.new("UICorner")
    pcorner.CornerRadius = UDim.new(0, 8)
    pcorner.Parent = plus

    local value = defaultValue
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
local playerListCorner = Instance.new("UICorner")
playerListCorner.CornerRadius = UDim.new(0, 6)
playerListCorner.Parent = playerListFrame
local playerListLayout = Instance.new("UIListLayout")
playerListLayout.FillDirection = Enum.FillDirection.Vertical
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Padding = UDim.new(0, 2)
playerListLayout.Parent = playerListFrame
local playerListPadding = Instance.new("UIPadding")
playerListPadding.PaddingTop = UDim.new(0, 2)
playerListPadding.PaddingBottom = UDim.new(0, 2)
playerListPadding.PaddingLeft = UDim.new(0, 4)
playerListPadding.PaddingRight = UDim.new(0, 4)
playerListPadding.Parent = playerListFrame

local playerButtons = {}

local function updatePlayerList()
    for _, btn in pairs(playerButtons) do btn:Destroy() end
    playerButtons = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 26)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 14
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = playerListFrame
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = btn
            btn.MouseButton1Click:Connect(function()
                local target = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if target and HRP then
                    HRP.CFrame = target.CFrame + Vector3.new(0, 3, 0)
                end
            end)
            playerButtons[plr] = btn
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
local flyUpCorner = Instance.new("UICorner")
flyUpCorner.CornerRadius = UDim.new(0, 6)
flyUpCorner.Parent = flyUp

local flyDown = Instance.new("TextButton")
flyDown.Size = UDim2.new(0.3, 0, 0.5, 0)
flyDown.Position = UDim2.new(0, 0, 0.5, 0)
flyDown.BackgroundColor3 = Color3.fromRGB(150,30,30)
flyDown.Text = "DOWN"
flyDown.TextColor3 = Color3.new(1,1,1)
flyDown.TextScaled = true
flyDown.Font = Enum.Font.GothamBold
flyDown.Parent = flyFrame
local flyDownCorner = Instance.new("UICorner")
flyDownCorner.CornerRadius = UDim.new(0, 6)
flyDownCorner.Parent = flyDown

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
local flyMinusCorner = Instance.new("UICorner")
flyMinusCorner.CornerRadius = UDim.new(0, 6)
flyMinusCorner.Parent = flyMinus

local flyPlus = Instance.new("TextButton")
flyPlus.Size = UDim2.new(0.1, 0, 0.3, 0)
flyPlus.Position = UDim2.new(0.55, 0, 0.35, 0)
flyPlus.BackgroundColor3 = Color3.fromRGB(80,80,80)
flyPlus.Text = "+"
flyPlus.TextColor3 = Color3.new(1,1,1)
flyPlus.TextScaled = true
flyPlus.Font = Enum.Font.GothamBold
flyPlus.Parent = flyFrame
local flyPlusCorner = Instance.new("UICorner")
flyPlusCorner.CornerRadius = UDim.new(0, 6)
flyPlusCorner.Parent = flyPlus

local flyToggleBtn = Instance.new("TextButton")
flyToggleBtn.Size = UDim2.new(0.3, 0, 0.4, 0)
flyToggleBtn.Position = UDim2.new(0.7, 0, 0.3, 0)
flyToggleBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
flyToggleBtn.Text = "FLY OFF"
flyToggleBtn.TextColor3 = Color3.new(1,1,1)
flyToggleBtn.TextScaled = true
flyToggleBtn.Font = Enum.Font.GothamBold
flyToggleBtn.Parent = flyFrame
local flyToggleCorner = Instance.new("UICorner")
flyToggleCorner.CornerRadius = UDim.new(0, 6)
flyToggleCorner.Parent = flyToggleBtn

local sep3 = Instance.new("Frame")
sep3.Size = UDim2.new(0.9, 0, 0, 2)
sep3.BackgroundColor3 = Color3.fromRGB(100,100,100)
sep3.BackgroundTransparency = 0.5
sep3.Parent = contentContainer

addLabel("--- Anti-Death ---", Color3.fromRGB(150,150,150))
local antiFrame = Instance.new("Frame")
antiFrame.Size = UDim2.new(0.9, 0, 0, 32)
antiFrame.BackgroundTransparency = 1
antiFrame.Parent = contentContainer

local antiToggle = Instance.new("TextButton")
antiToggle.Size = UDim2.new(0.5, 0, 1, 0)
antiToggle.BackgroundColor3 = Color3.fromRGB(180,0,0)
antiToggle.Text = "ANTI-DIE: OFF"
antiToggle.TextColor3 = Color3.new(1,1,1)
antiToggle.TextScaled = true
antiToggle.Font = Enum.Font.GothamBold
antiToggle.Parent = antiFrame
local antiCorner = Instance.new("UICorner")
antiCorner.CornerRadius = UDim.new(0, 6)
antiCorner.Parent = antiToggle

local keybindDisplay = Instance.new("TextButton")
keybindDisplay.Size = UDim2.new(0.15, 0, 0.7, 0)
keybindDisplay.Position = UDim2.new(0.55, 0, 0.15, 0)
keybindDisplay.BackgroundColor3 = Color3.fromRGB(30,30,40)
keybindDisplay.Text = "G"
keybindDisplay.TextColor3 = Color3.fromRGB(255,255,255)
keybindDisplay.TextScaled = true
keybindDisplay.Font = Enum.Font.GothamBold
keybindDisplay.Parent = antiFrame
local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 4)
keyCorner.Parent = keybindDisplay

local changeKey = Instance.new("TextButton")
changeKey.Size = UDim2.new(0.2, 0, 0.7, 0)
changeKey.Position = UDim2.new(0.72, 0, 0.15, 0)
changeKey.BackgroundColor3 = Color3.fromRGB(150,0,0)
changeKey.Text = "CHANGE"
changeKey.TextColor3 = Color3.new(1,1,1)
changeKey.TextScaled = true
changeKey.Font = Enum.Font.GothamBold
changeKey.Parent = antiFrame
local changeCorner = Instance.new("UICorner")
changeCorner.CornerRadius = UDim.new(0, 4)
changeCorner.Parent = changeKey

local spawnerOpenBtn = addButton("🔫 Weapon Spawner", Color3.fromRGB(50,150,50), function()
    if spawnerOpen then spawnerOpen() end
end)

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
    if farmingThread then
        task.cancel(farmingThread)
        farmingThread = nil
    end
    isFarming = true
    farmingThread = task.spawn(function()
        while isFarming do
            local target = getNearest()
            if target and LP:GetAttribute("Alive") and HRP and Humanoid then
                tp(target)
                local v = target:FindFirstChild("CoinVisual")
                while v and not v:GetAttribute("Collected") and v.Parent and isFarming do
                    if not LP:GetAttribute("Alive") then break end
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
    if farmingThread then
        task.cancel(farmingThread)
        farmingThread = nil
    end
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

startButton.MouseButton1Click:Connect(toggleFarming)

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

invisibleBtn.MouseButton1Click:Connect(toggleInvisibility)

local function updateFlySpeedDisplay()
    flySpeedLabel.Text = tostring(flySpeed)
end

flyMinus.MouseButton1Click:Connect(function()
    if flySpeed > 1 then flySpeed = flySpeed - 1; updateFlySpeedDisplay() end
end)
flyPlus.MouseButton1Click:Connect(function()
    flySpeed = flySpeed + 1; updateFlySpeedDisplay()
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
        local char = LP.Character
        if not char then return end
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
    local healthConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum and hum.Parent and hum.Health <= 0 and hum.MaxHealth > 0 then
            hum.Health = hum.MaxHealth
            if hum:GetState() == Enum.HumanoidStateType.Dead then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end)
    table.insert(conns, healthConn)
    return conns
end

local function cleanupAntiDie()
    for _, conn in ipairs(antiDieConnections) do
        if conn and conn.Disconnect then conn:Disconnect() end
    end
    antiDieConnections = {}
end

local function toggleAntiDie()
    antiDieActive = not antiDieActive
    if antiDieActive then
        antiToggle.Text = "ANTI-DIE: ON"
        antiToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 50)
        cleanupAntiDie()
        local char = LP.Character
        if char then antiDieConnections = activateAntiDie(char) end
    else
        antiToggle.Text = "ANTI-DIE: OFF"
        antiToggle.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        cleanupAntiDie()
    end
end

antiToggle.MouseButton1Click:Connect(toggleAntiDie)

local function changeKeybind()
    if waitingForKeybind then return end
    waitingForKeybind = true
    keybindDisplay.Text = "..."
    keybindDisplay.TextColor3 = Color3.fromRGB(255, 255, 0)
    local conn
    conn = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            antiDieKeybind = input.KeyCode
            keybindDisplay.Text = tostring(antiDieKeybind):gsub("Enum.KeyCode.", "")
            keybindDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
            waitingForKeybind = false
            conn:Disconnect()
        end
    end)
end

changeKey.MouseButton1Click:Connect(changeKeybind)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == antiDieKeybind then
        toggleAntiDie()
    end
end)

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
        title.Text = "Yuno Hub"
        title.Position = UDim2.new(0, 12, 0, 0)
        title.Size = UDim2.new(0.8, 0, 1, 0)
        topCorner.CornerRadius = UDim.new(0, 20)
    else
        mainFrame:TweenSize(UDim2.new(0, 300, 0, 460), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
        minimizeBtn.Text = "−"
        minimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        contentContainer.Visible = true
        umbrella.Visible = true
        glow.Size = UDim2.new(1.04, 0, 1.04, 0)
        glow.Position = UDim2.new(-0.02, 0, -0.02, 0)
        title.Text = "Yuno Hub"
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
    if spawnerGui then spawnerGui:Destroy() end
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
        antiDieConnections = activateAntiDie(char)
    end
end)

function spawnerOpen()
    if spawnerGui then
        spawnerGui:Destroy()
        spawnerGui = nil
        return
    end
    local sg = Instance.new("ScreenGui")
    sg.Name = "WeaponSpawnerGui"
    sg.ResetOnSpawn = false
    sg.Parent = playerGui
    local mf = Instance.new("Frame")
    mf.Size = UDim2.new(0, 400, 0, 420)
    mf.Position = UDim2.new(0.5, -200, 0.5, -210)
    mf.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mf.BorderSizePixel = 0
    mf.Active = true
    mf.Draggable = true
    mf.Parent = sg
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 12)
    mc.Parent = mf
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 30)
    minBtn.Position = UDim2.new(1, -35, 0, 5)
    minBtn.Text = "-"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 18
    minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    minBtn.TextColor3 = Color3.new(1,1,1)
    minBtn.Parent = mf
    local minC = Instance.new("UICorner")
    minC.CornerRadius = UDim.new(0, 6)
    minC.Parent = minBtn
    local closed = false
    local miniBtn = Instance.new("TextButton")
    miniBtn.Size = UDim2.new(0, 120, 0, 30)
    miniBtn.Position = UDim2.new(0.5, -60, 0, 10)
    miniBtn.Text = "Open Spawner"
    miniBtn.Font = Enum.Font.GothamBold
    miniBtn.TextSize = 14
    miniBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    miniBtn.TextColor3 = Color3.new(1,1,1)
    miniBtn.Visible = false
    miniBtn.Parent = sg
    local miniC = Instance.new("UICorner")
    miniC.CornerRadius = UDim.new(0, 6)
    miniC.Parent = miniBtn
    minBtn.MouseButton1Click:Connect(function()
        mf.Visible = false
        miniBtn.Visible = true
    end)
    miniBtn.MouseButton1Click:Connect(function()
        mf.Visible = true
        miniBtn.Visible = false
    end)
    local search = Instance.new("TextBox")
    search.Size = UDim2.new(0.9, 0, 0.1, 0)
    search.Position = UDim2.new(0.05, 0, 0.05, 0)
    search.BackgroundColor3 = Color3.fromRGB(255,255,255)
    search.PlaceholderText = "Search weapon..."
    search.Text = ""
    search.TextColor3 = Color3.fromRGB(0,0,0)
    search.Font = Enum.Font.SourceSansBold
    search.TextScaled = true
    search.ClearTextOnFocus = false
    search.Parent = mf
    local searchC = Instance.new("UICorner")
    searchC.CornerRadius = UDim.new(0, 8)
    searchC.Parent = search
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(0.9, 0, 0.6, 0)
    list.Position = UDim2.new(0.05, 0, 0.18, 0)
    list.BackgroundColor3 = Color3.fromRGB(40,40,50)
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 4
    list.CanvasSize = UDim2.new(0,0,0,0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Parent = mf
    local listC = Instance.new("UICorner")
    listC.CornerRadius = UDim.new(0, 8)
    listC.Parent = list
    local listL = Instance.new("UIListLayout")
    listL.FillDirection = Enum.FillDirection.Vertical
    listL.SortOrder = Enum.SortOrder.LayoutOrder
    listL.Padding = UDim.new(0,2)
    listL.Parent = list
    local listP = Instance.new("UIPadding")
    listP.PaddingTop = UDim.new(0,4)
    listP.PaddingBottom = UDim.new(0,4)
    listP.PaddingLeft = UDim.new(0,4)
    listP.PaddingRight = UDim.new(0,4)
    listP.Parent = list
    local selected = ""
    local function populate(filter)
        for _, c in pairs(list:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local f = string.lower(filter or "")
        local sorted = {}
        for w in pairs(AllowedWeapons) do table.insert(sorted, w) end
        table.sort(sorted)
        for _, w in ipairs(sorted) do
            if string.find(string.lower(w), f) then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1,0,0,28)
                btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
                btn.Text = w
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Font = Enum.Font.SourceSans
                btn.TextSize = 16
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Parent = list
                local bc = Instance.new("UICorner")
                bc.CornerRadius = UDim.new(0,4)
                bc.Parent = btn
                btn.MouseButton1Click:Connect(function()
                    selected = w
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0,170,255)}):Play()
                    search.Text = w
                end)
            end
        end
    end
    populate("")
    search:GetPropertyChangedSignal("Text"):Connect(function()
        populate(search.Text)
    end)
    local spawnBtn = Instance.new("TextButton")
    spawnBtn.Size = UDim2.new(0.9, 0, 0.1, 0)
    spawnBtn.Position = UDim2.new(0.05, 0, 0.82, 0)
    spawnBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
    spawnBtn.Text = "Spawn Weapon"
    spawnBtn.TextColor3 = Color3.new(1,1,1)
    spawnBtn.Font = Enum.Font.GothamBold
    spawnBtn.TextScaled = true
    spawnBtn.Parent = mf
    local spawnC = Instance.new("UICorner")
    spawnC.CornerRadius = UDim.new(0,8)
    spawnC.Parent = spawnBtn
    local confirm = Instance.new("TextLabel")
    confirm.Size = UDim2.new(0.9,0,0.06,0)
    confirm.Position = UDim2.new(0.05,0,0.93,0)
    confirm.BackgroundTransparency = 1
    confirm.Text = ""
    confirm.Font = Enum.Font.SourceSansBold
    confirm.TextScaled = true
    confirm.TextColor3 = Color3.fromRGB(0,255,0)
    confirm.Visible = false
    confirm.Parent = mf
    spawnBtn.MouseButton1Click:Connect(function()
        if selected ~= "" and AllowedWeapons[selected] then
            local ok = false
            pcall(function()
                local data = ReplicatedStorage:FindFirstChild("Database") and ReplicatedStorage.Database:FindFirstChild("Sync") and ReplicatedStorage.Database.Sync:FindFirstChild("Item")
                local pd = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("ProfileData")
                if data and pd then
                    local db = require(data)
                    local pdata = require(pd)
                    if db[selected] then
                        if not pdata.Weapons then pdata.Weapons = {} end
                        if not pdata.Weapons.Owned then pdata.Weapons.Owned = {} end
                        pdata.Weapons.Owned[selected] = (pdata.Weapons.Owned[selected] or 0) + 1
                        if BoxControllerRemote then
                            local box = mysteryBoxes[math.random(1,#mysteryBoxes)]
                            BoxControllerRemote:Fire(box, selected)
                        end
                        game.ReplicatedStorage.Remotes.Inventory.InventoryDataChanged:Fire()
                        ok = true
                    end
                end
            end)
            if ok then
                confirm.Text = selected .. " Spawned!"
                confirm.TextColor3 = Color3.fromRGB(0,255,0)
            else
                confirm.Text = "Failed to spawn (missing modules)"
                confirm.TextColor3 = Color3.fromRGB(255,50,50)
            end
            confirm.Visible = true
            task.delay(2, function() confirm.Visible = false end)
        else
            confirm.Text = "Select a valid weapon!"
            confirm.TextColor3 = Color3.fromRGB(255,50,50)
            confirm.Visible = true
            task.delay(2, function() confirm.Visible = false end)
        end
    end)
    spawnerGui = sg
end

print("Yuno Hub Farm MM2 loaded")