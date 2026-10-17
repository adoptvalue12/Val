-- language: Luau, file: yuno_hub_adopt_me.lua, target: Roblox / Adopt Me (2026)
-- 界面: 现代圆角 Dark Mode + Yuno Hub 动态打字机开场动画
-- 功能: 宠物自动养护、宝宝自动养护、沙龙/医院全自动化、Remote 智能拦截与动态分发

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 防止重复注入
if CoreGui:FindFirstChild("YunoHubGUI") then
    CoreGui.YunoHubGUI:Destroy()
end

-- ==========================================
-- 1. 炫酷开场动画：Yuno Hub 动态打字机效果
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YunoHubGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local IntroFrame = Instance.new("Frame")
IntroFrame.Size = UDim2.new(0, 400, 0, 150)
IntroFrame.Position = UDim2.new(0.5, -200, 0.5, -75)
IntroFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
IntroFrame.BorderSizePixel = 0
IntroFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = IntroFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(138, 43, 226)
UIStroke.Thickness = 2
UIStroke.Parent = IntroFrame

local IntroText = Instance.new("TextLabel")
IntroText.Size = UDim2.new(1, 0, 1, 0)
IntroText.BackgroundTransparency = 1
IntroText.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroText.TextSize = 24
IntroText.Font = Enum.Font.GothamBold
IntroText.Text = ""
IntroText.Parent = IntroFrame

-- 打字机动画协程
task.spawn(function()
    local titleString = "Yuno Hub v3.5..."
    for i = 1, #titleString do
        IntroText.Text = string.sub(titleString, 1, i)
        task.wait(0.08)
    end
    task.wait(0.5)
    
    local fadeInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(IntroFrame, fadeInfo, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)})
    local textTween = TweenService:Create(IntroText, fadeInfo, {TextTransparency = 1})
    local strokeTween = TweenService:Create(UIStroke, fadeInfo, {Transparency = 1})
    
    tween:Play()
    textTween:Play()
    strokeTween:Play()
    tween.Completed:Wait()
    IntroFrame:Destroy()
end)

-- ==========================================
-- 2. 主控制面板 UI 界面构建
-- ==========================================
task.wait(2.2) -- 等待开场动画结束

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(138, 43, 226)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- 顶栏
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(220, 150, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Yuno Hub | Adopt Me 2026 Automation"
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- 容器区 (放置开关按钮)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 52)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 450)
Container.ScrollBarThickness = 4
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.Parent = Container

-- 创建开关组件的辅助函数
local function createToggle(name, callback)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 0, 45)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    ToggleBtn.Text = ""
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = ToggleBtn
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamMedium
    Label.Text = name
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleBtn
    
    local StatusIndicator = Instance.new("Frame")
    StatusIndicator.Size = UDim2.new(0, 22, 0, 22)
    StatusIndicator.Position = UDim2.new(1, -35, 0.5, -11)
    StatusIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    StatusIndicator.Parent = ToggleBtn
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(1, 0)
    StatusCorner.Parent = StatusIndicator
    
    local enabled = false
    ToggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        local targetColor = enabled and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(60, 60, 75)
        TweenService:Create(StatusIndicator, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        callback(enabled)
    end)
end

-- ==========================================
-- 3. 自动化核心逻辑与 Remote 动态分发
-- ==========================================
local PetFarmActive = false
local BabyFarmActive = false
local SalonFarmActive = false

-- 获取 2026 Adopt Me 核心 API
local ReplicatedAPI = ReplicatedStorage:WaitForChild("API", 10)
local PetAPI = ReplicatedStorage:FindFirstChild("ToolAPI") or (ReplicatedAPI and ReplicatedAPI:FindFirstChild("PetAPI"))

-- 宠物养护自动化
createToggle("Auto Farm Pet (自动喂养/睡觉/口渴)", function(state)
    PetFarmActive = state
    task.spawn(function()
        while PetFarmActive do
            pcall(function()
                -- 自动触发宠物任务需求事件
                local petAPI = ReplicatedStorage:FindFirstChild("PetAPI") or ReplicatedStorage:FindFirstChild("API")
                if petAPI and petAPI:FindFirstChild("PayPetTask") then
                    petAPI.PayPetTask:FireServer("hungry", LocalPlayer.Character.HumanoidRootPart.Position)
                    task.wait(0.5)
                    petAPI.PayPetTask:FireServer("thirsty", LocalPlayer.Character.HumanoidRootPart.Position)
                    task.wait(0.5)
                    petAPI.PayPetTask:FireServer("sleepy", LocalPlayer.Character.HumanoidRootPart.Position)
                end
            end)
            task.wait(3.0)
        end
    end)
end)

-- 宝宝养护自动化
createToggle("Auto Farm Baby (宝宝自动洗澡/吃饭/上学)", function(state)
    BabyFarmActive = state
    task.spawn(function()
        while BabyFarmActive do
            pcall(function()
                local housingAPI = ReplicatedStorage:FindFirstChild("HousingAPI")
                if housingAPI and housingAPI:FindFirstChild("TriggerFurniture") then
                    -- 自动坐下、洗澡、进食交互
                    housingAPI.TriggerFurniture:InvokeServer("Mat", "Use", {}, LocalPlayer.Character)
                end
            end)
            task.wait(4.0)
        end
    end)
end)

-- 沙龙与医院自动化
createToggle("Auto Salon & Hospital Farm (沙龙与医院全自动)", function(state)
    SalonFarmActive = state
    task.spawn(function()
        while SalonFarmActive do
            pcall(function()
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    -- 传送至沙龙/医院位置并执行任务交互
                    character.HumanoidRootPart.CFrame = CFrame.new(-285.3, 12.8, -55.2)
                    task.wait(1.0)
                    local salonAPI = ReplicatedStorage:FindFirstChild("SalonAPI") or ReplicatedStorage:FindFirstChild("HospitalAPI")
                    if salonAPI and salonAPI:FindFirstChild("DoTask") then
                        salonAPI.DoTask:FireServer("salon_chair")
                    end
                end
            end)
            task.wait(6.0)
        end
    end)
end)

print("Yuno Hub 2026 loaded successfully.")
