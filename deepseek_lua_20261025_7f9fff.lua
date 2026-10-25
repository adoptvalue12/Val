--[[
    YUNO FARM v7.0 - ENHANCED EDITION
    ✓ Base: Yuno v6.3 (structure UI + core tasks)
    ✓ + Yuno Hub v2: Halloween amélioré, Pet Pen, Skelicorn, Hauntlet, Potion Feeder
    ✓ + Dusk & Shine: Icons InventoryDB, Trade Calculator, Auto Lure, Pet Unstack, Pet Pen Dashboard
    ✓ Toutes les features v6.3 conservées
]]

print("═══════════════════════════════════════════")
print("[Yuno v7.0] 🚀 Starting Enhanced Edition...")
print("═══════════════════════════════════════════")

if not game:IsLoaded() then game.Loaded:Wait() end
if not pcall(function() game:GetService("ReplicatedStorage"):WaitForChild("Fsys", 30) end) then
    warn("[Yuno] ❌ Fsys not found"); return
end

local Players, LP = game:GetService("Players"), game:GetService("Players").LocalPlayer
local UIS, TS = game:GetService("UserInputService"), game:GetService("TweenService")
local RS, CoreGui = game:GetService("ReplicatedStorage"), game:GetService("CoreGui")
local RunService, Workspace = game:GetService("RunService"), game:GetService("Workspace")
local CollectionService, Lighting = game:GetService("CollectionService"), game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
local IS_MOBILE = UIS.TouchEnabled or vp.X < 900

if not isfolder("YunoFarm") then pcall(makefolder, "YunoFarm") end
if not isfolder("YunoFarm/Values") then pcall(makefolder, "YunoFarm/Values") end
local vu = game:GetService("VirtualUser")
LP.Idled:Connect(function() vu:CaptureController() vu:ClickButton2(Vector2.new()) end)

-- ══════════ SOUNDS ══════════
local SoundEnabled, AmbientEnabled = true, false
local SoundCache = {}
local SOUND_IDS = {
    click = "rbxassetid://6042053626", toggle = "rbxassetid://6042053626",
    success = "rbxassetid://9114353209", error = "rbxassetid://9118823105",
    ambient = "rbxassetid://1837879082",
}
local function PlaySound(name, vol, pitch)
    if not SoundEnabled and name ~= "ambient" then return end
    if name == "ambient" and not AmbientEnabled then return end
    local s = SoundCache[name]
    if not s then
        s = Instance.new("Sound")
        s.SoundId = SOUND_IDS[name] or SOUND_IDS.click
        s.Looped = (name == "ambient")
        s.Volume = 0
        s.Parent = CoreGui:FindFirstChild("YunoFarm_UI") or LP:WaitForChild("PlayerGui")
        SoundCache[name] = s
    end
    s.Volume = vol or (name == "ambient" and 0.15 or 0.4)
    s.PlaybackSpeed = pitch or 1
    pcall(function() if name ~= "ambient" then s:Play() else if not s.IsPlaying then s:Play() end end end)
end

-- ══════════ MODULES ══════════
local Fsys
do local att = 0
    while att < 30 and not Fsys do
        att = att + 1
        local m = RS:FindFirstChild("Fsys")
        if m then local ok, r = pcall(function() return require(m) end); if ok and r then Fsys = r; break end end
        task.wait(1)
    end
end
if not Fsys then warn("[Yuno] ❌ Fsys failed"); return end
local function SafeLoad(n) local ok, m = pcall(function() return Fsys.load(n) end); return ok and m or nil end
local M = {
    RouterClient = SafeLoad("RouterClient"), ClientData = SafeLoad("ClientData"),
    InteriorsM = SafeLoad("InteriorsM"), InventoryDB = SafeLoad("InventoryDB"),
    PetEntityManager = SafeLoad("PetEntityManager"), PetEntityHelper = SafeLoad("PetEntityHelper"),
    KindDB = SafeLoad("KindDB"), LiveOpsTime = SafeLoad("LiveOpsTime"),
}
if not M.RouterClient or not M.ClientData then warn("[Yuno] ❌ critical module missing"); return end

local AilmentsClient
pcall(function()
    AilmentsClient = require(RS:WaitForChild("new", 2):WaitForChild("modules", 2)
        :WaitForChild("Ailments", 2):WaitForChild("AilmentsClient", 2))
end)
local MYSTERY_PRIORITY = {"bored", "salon", "school", "camping", "sick", "beach_party", "pizza_party"}

local function SafeGet(e) local ok, r = pcall(function() return M.RouterClient.get(e) end); return ok and r or nil end
local API = {
    Equip = SafeGet("ToolAPI/Equip"), Unequip = SafeGet("ToolAPI/Unequip"),
    ServerUseTool = SafeGet("ToolAPI/ServerUseTool"), DoNeonFusion = SafeGet("PetAPI/DoNeonFusion"),
    ConsumeFoodObject = SafeGet("PetAPI/ConsumeFoodObject"), ExitFurniture = SafeGet("PetAPI/ExitFurnitureUseStates"),
    CreatePetObject = SafeGet("PetObjectAPI/CreatePetObject"), GrabPetObject = SafeGet("PetObjectAPI/GrabPetObject"),
    DropPetObject = SafeGet("PetObjectAPI/DropPetObject"), ProgressPetMe = SafeGet("AilmentsAPI/ProgressPetMeAilment"),
    ChooseMystery = SafeGet("AilmentsAPI/ChooseMysteryAilment"),
    AddPet = SafeGet("IdleProgressionAPI/AddPet"), RemovePet = SafeGet("IdleProgressionAPI/RemovePet"),
    ClaimProgression = SafeGet("IdleProgressionAPI/CommitAllProgression"),
    BuyItem = SafeGet("ShopAPI/BuyItem"), SetLocation = SafeGet("LocationAPI/SetLocation"),
    UnsubscribeHouse = SafeGet("HousingAPI/UnsubscribeFromHouse"),
    ActivateInterior = SafeGet("HousingAPI/ActivateInteriorFurniture"),
    ActivateFurniture = SafeGet("HousingAPI/ActivateFurniture"),
    ExitSeats = SafeGet("AdoptAPI/ExitSeatStates"), EjectBaby = SafeGet("AdoptAPI/EjectBaby"),
    SetPetRP = SafeGet("SettingsAPI/SetPetRoleplayName"),
    Download = SafeGet("DownloadsAPI/Download"),
    BuyFurnitures = SafeGet("HousingAPI/BuyFurnitures"),
}
local RawAPI = RS:WaitForChild("API", 15)
local function RawGet(n) return RawAPI and RawAPI:FindFirstChild(n) or nil end
API.HealWithDoctor = RawGet("MonitorAPI/HealWithDoctor")
API.FinishObby = RawGet("MinigameAPI/FinishObby")
API.ClaimDailyReward = RawGet("DailyLoginAPI/ClaimDailyReward")
API.ChooseTeam = RawGet("TeamAPI/ChooseTeam")
API.BeginTradeQuiz = RawGet("TradeAPI/BeginQuiz")
API.AnswerQuiz = RawGet("TradeAPI/AnswerQuizQuestion")
API.ClaimQuest = RawGet("QuestAPI/ClaimQuest")
API.OpenGift = RawGet("ShopAPI/OpenGift")
API.MinigameMsg = RawGet("MinigameAPI/MessageServer")
API.ShootGhost = RawGet("MinigameAPI/ShootGhost") or RawGet("MinigameAPI/ClickGhost")
local EventNet = RS:FindFirstChild("adoptme_new_net")
local function EventGet(n) return EventNet and (EventNet:FindFirstChild(n) or EventNet:WaitForChild(n, 3)) or nil end

print("[Yuno] ✅ API ready")

-- ══════════ STATE ══════════
local Cac = {
    CurrentLocation = nil, AilmentPlatform = nil,
    StrollerUID = nil, LastStrollerEquip = 0, LastMysteryAttempt = nil,
    PetMeAttempts = {}, MysteryBlacklist = {}, MysteryFails = {},
    CryptPendingLocks = {},
}
getgenv().YunoCac = Cac

local FarmEnabled, PetFarmEnabled, BabyFarmEnabled = false, false, false
local SWFEnabled, SwfMode, SwfSplitMode, SWFTargets = false, "Regular", false, {}
local AutoHatch, HatchPriority, HatchLimits = false, {}, {}
local ActiveHatchUIDs, HatchedSessionCounts = {}, {}
local AutoAgePot = false
local FastMegaEnabled, FastMegaPipeline, FastMegaPipeMode, FastMegaMode = false, false, "Selected", "Neon"
local FastMegaTargets, FastMegaFarmPots, FastMegaTimer = {}, false, 0
local TaskFailTrack = { time = 0 }
local MiniGamesEnabled, AutoObbies = false, false
local AutoSpleef, AutoSimonSays, AutoWinterCastle = false, false, false
local AutoGhostGallery, AutoHauntedHouse, AutoStitchesSpot = false, false, false
local AutoDailyReward, AutoFreeFood = false, false
local ObbiesDone, LastDailyClaim, LastFreeFoodClaim = {}, 0, 0
local AutoQuestClaim, AutoOpenGifts = false, false
local AutoNeonCombine, CombineQueue, CombineTargetMode = false, {}, "NEON"
local PotionFeederEnabled, FeederSelectedPotions, FeederUntilFG = false, {}, true
local FeederAutoSelectEquipped, FeederCooldowns, FeederFedCount = false, {}, 0
local Auto2DTuesdays, AutoHalloweenQuests, VisualBucksLoop = false, false, false
local VisualBucksAmount = 1000
local AutoTradeLicense = false
local HalloweenEnabled = false
local HalloweenCrypt, HalloweenTwigs, HalloweenCandy, HalloweenGhost = false, false, false, false
local HalloweenSkelicorn = false
local LowerGraphicsWhenUnfocused = false

-- ══════════ NEW v7.0 STATE ══════════
local PetPenEnabled, PetPenSlots, PetPenPriority, EggPenPriority = false, 4, {}, {}
local PetPenAutoLoot, PetPenLootAmount, PetPenAutoAgeUp = false, 50, false
local PetPenXPMode, PetPenXPLimit = "On Age-Up", 100
local AutoLureEnabled, LureBaitSelection, LureStatus = false, nil, "Idle"
local TradeCalcEnabled, TradeValueType = false, "Starpets (Beta)"
local TradeTargetPlayer, AutoAcceptTrades, AutoAcceptMode = "", false, "Target"
local AutoAcceptOnlyGifts, AutoAddFood, ProtectProfileTrades = false, false, true
local TradeBlacklist, TradeFilters = {}, { CustomMode = false, CustomLimits = {}, CustomVariants = {} }
local PetVisCustomColor = Color3.new(1,1,1)
local VisualVars = { Mega = false, Neon = false, Fly = false, Ride = false, Eggs = false, CustomColorOn = false }
local SavedPetVisuals = {}
local TradeValuesCache, TradeValuesReady = {}, {}
local ShowTradeDemands = false

-- Location sync
LiveOpsMap = "MainMap"
pcall(function()
    local ok, S = pcall(function()
        return require(RS:WaitForChild("new", 2):WaitForChild("modules", 2)
            :WaitForChild("InteriorHelpers", 2):WaitForChild("LiveOpsMapSwap", 2)
            :WaitForChild("SwappableInteriors", 2))
    end)
    if ok and S and S.get_current_map_type then LiveOpsMap = S.get_current_map_type() or "MainMap" end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if M.InteriorsM and M.InteriorsM.get_current_location then
                local loc = M.InteriorsM.get_current_location()
                if loc and loc.id then Cac.CurrentLocation = loc.id; return end
            end
            if M.ClientData then
                local data = M.ClientData.get_data() or {}
                local pd = data[LP.Name] or {}
                if pd.char_wrapper and pd.char_wrapper.location then
                    Cac.CurrentLocation = pd.char_wrapper.location.destination_id
                elseif Cac.CurrentLocation == nil then Cac.CurrentLocation = "MainMap" end
            end
        end)
    end
end)

-- ══════════ ICON HELPER (from Dusk & Shine) ══════════
local ICON_CATEGORIES = {"pets","food","toys","transport","strollers","pet_accessories","gifts"}
local IconCache = {}
local function GetIcon(kind, category)
    if not kind then return "rbxassetid://122697490518955" end
    local cacheKey = tostring(category or "auto") .. "|" .. tostring(kind)
    if IconCache[cacheKey] then return IconCache[cacheKey] end
    if not M.InventoryDB then return "rbxassetid://122697490518955" end
    local Db
    if category and M.InventoryDB[category] and M.InventoryDB[category][kind] then
        Db = M.InventoryDB[category][kind]
    else
        for _, c in ipairs(ICON_CATEGORIES) do
            if M.InventoryDB[c] and M.InventoryDB[c][kind] then
                Db = M.InventoryDB[c][kind]
                break
            end
        end
    end
    if not Db then return "rbxassetid://122697490518955" end
    local Img = Db.icon or Db.image or Db.shop_image or "122697490518955"
    if not string.find(tostring(Img), "rbxassetid") and tonumber(Img) then
        Img = "rbxassetid://" .. tostring(Img)
    end
    IconCache[cacheKey] = Img
    return Img
end
local function GetItemName(kind, category)
    if not kind or not M.InventoryDB then return tostring(kind) end
    local Db
    if category and M.InventoryDB[category] and M.InventoryDB[category][kind] then
        Db = M.InventoryDB[category][kind]
    else
        for _, c in ipairs(ICON_CATEGORIES) do
            if M.InventoryDB[c] and M.InventoryDB[c][kind] then Db = M.InventoryDB[c][kind]; break end
        end
    end
    return Db and Db.name or tostring(kind)
end

-- ══════════ THEMES ══════════
local THEMES = {
    Yuno = { Background=Color3.fromRGB(12,14,22), Sidebar=Color3.fromRGB(18,21,32), Section=Color3.fromRGB(24,28,42), Text=Color3.fromRGB(240,245,255), SubText=Color3.fromRGB(120,140,170), Accent=Color3.fromRGB(110,170,255), Stroke=Color3.fromRGB(40,48,70), ToggleOff=Color3.fromRGB(45,52,72), Knob=Color3.fromRGB(240,245,255) },
    Dark = { Background=Color3.fromRGB(15,15,20), Sidebar=Color3.fromRGB(20,20,25), Section=Color3.fromRGB(28,28,33), Text=Color3.fromRGB(255,255,255), SubText=Color3.fromRGB(120,120,130), Accent=Color3.fromRGB(255,255,255), Stroke=Color3.fromRGB(45,45,50), ToggleOff=Color3.fromRGB(55,55,60), Knob=Color3.fromRGB(20,20,25) },
    Galaxy = { Background=Color3.fromRGB(12,10,20), Sidebar=Color3.fromRGB(18,15,30), Section=Color3.fromRGB(25,20,42), Text=Color3.fromRGB(240,240,255), SubText=Color3.fromRGB(150,140,190), Accent=Color3.fromRGB(110,60,255), Stroke=Color3.fromRGB(50,40,80), ToggleOff=Color3.fromRGB(40,30,70), Knob=Color3.fromRGB(20,15,35) },
    Light = { Background=Color3.fromRGB(245,245,250), Sidebar=Color3.fromRGB(255,255,255), Section=Color3.fromRGB(235,235,240), Text=Color3.fromRGB(20,20,25), SubText=Color3.fromRGB(100,100,110), Accent=Color3.fromRGB(0,122,255), Stroke=Color3.fromRGB(220,220,230), ToggleOff=Color3.fromRGB(200,200,210), Knob=Color3.fromRGB(255,255,255) },
    Emerald = { Background=Color3.fromRGB(15,22,18), Sidebar=Color3.fromRGB(20,28,22), Section=Color3.fromRGB(26,36,28), Text=Color3.fromRGB(240,255,240), SubText=Color3.fromRGB(130,160,140), Accent=Color3.fromRGB(46,204,113), Stroke=Color3.fromRGB(45,60,50), ToggleOff=Color3.fromRGB(40,55,45), Knob=Color3.fromRGB(20,28,22) },
    Halloween = { Background=Color3.fromRGB(20,8,4), Sidebar=Color3.fromRGB(30,12,6), Section=Color3.fromRGB(40,18,10), Text=Color3.fromRGB(255,220,180), SubText=Color3.fromRGB(180,120,90), Accent=Color3.fromRGB(255,140,20), Stroke=Color3.fromRGB(60,30,15), ToggleOff=Color3.fromRGB(50,25,12), Knob=Color3.fromRGB(255,220,180) },
}
local ThemeName = getgenv().YunoThemeName or "Yuno"
local Theme = THEMES[ThemeName] or THEMES.Yuno
local ThemeObjects, Flags = {}, {}

local function ApplyTheme(n)
    if not THEMES[n] then return end
    ThemeName = n; getgenv().YunoThemeName = n; Theme = THEMES[n]
    for obj, props in pairs(ThemeObjects) do
        if obj and obj.Parent then
            for prop, key in pairs(props) do pcall(function() obj[prop] = Theme[key] end) end
        end
    end
end

local function Make(class, props, theme)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    if theme then
        ThemeObjects[inst] = {}
        for k, v in pairs(theme) do ThemeObjects[inst][k] = v; inst[k] = Theme[v] end
        inst.Destroying:Connect(function() ThemeObjects[inst] = nil end)
    end
    return inst
end
local function Tween(o, d, p, s, dir)
    local t = TS:Create(o, TweenInfo.new(d or 0.25, s or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), p)
    t:Play(); return t
end

local notifyHolder
local function Notify(title, msg, dur)
    if not notifyHolder then return end
    dur = dur or 3
    PlaySound("success", 0.3)
    local f = Make("Frame", { Size = UDim2.new(0, 300, 0, 70), BackgroundTransparency = 1, Parent = notifyHolder })
    local bg = Make("Frame", { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(1, 40, 0, 0), BackgroundColor3 = Theme.Section, Parent = f })
    Make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = bg })
    Make("UIStroke", { Thickness = 1, Color = Theme.Stroke, Parent = bg })
    Make("Frame", { Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = bg })
    Make("TextLabel", { Size = UDim2.new(1, -30, 0, 20), Position = UDim2.new(0, 15, 0, 12), BackgroundTransparency = 1, Text = title or "Yuno", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = bg })
    Make("TextLabel", { Size = UDim2.new(1, -30, 0, 30), Position = UDim2.new(0, 15, 0, 32), BackgroundTransparency = 1, Text = msg or "", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = bg })
    Tween(bg, 0.3, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint)
    task.delay(dur, function()
        local t = Tween(bg, 0.3, { Position = UDim2.new(1, 40, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        t.Completed:Connect(function() f:Destroy() end)
    end)
end

-- ══════════ UI HELPERS ══════════
local UI = {}
local screenGui, mainFrame, mainScale, floatBtn, floatScale

function UI.Toggle(parent, cfg)
    cfg = cfg or {}
    local flag = cfg.Flag or cfg.Name
    local state = cfg.Default == true
    if Flags[flag] ~= nil then state = Flags[flag] end
    Flags[flag] = state
    local card = Make("Frame", { Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Theme.Section, Parent = parent })
    Make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = card })
    Make("UIStroke", { Thickness = 1, Color = Theme.Stroke, Parent = card })
    Make("TextLabel", { Size = UDim2.new(1, -80, 0, 18), Position = UDim2.new(0, 15, 0, 10), BackgroundTransparency = 1, Text = cfg.Name or "Toggle", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
    if cfg.Description then
        Make("TextLabel", { Size = UDim2.new(1, -80, 0, 14), Position = UDim2.new(0, 15, 0, 30), BackgroundTransparency = 1, Text = cfg.Description, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
    end
    local btn = Make("TextButton", { Size = UDim2.new(0, 44, 0, 24), Position = UDim2.new(1, -58, 0.5, -12), BackgroundTransparency = 1, Text = "", Parent = card })
    local track = Make("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff, Parent = btn })
    Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
    local knob = Make("Frame", { Size = UDim2.new(0, 20, 0, 20), BackgroundColor3 = Theme.Knob, Parent = track })
    Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })
    knob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    local function setState(v, silent)
        state = v; Flags[flag] = v
        PlaySound("toggle", 0.3, v and 1.15 or 0.85)
        Tween(track, 0.25, { BackgroundColor3 = v and Theme.Accent or Theme.ToggleOff })
        Tween(knob, 0.25, { Position = v and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10) }, Enum.EasingStyle.Back)
        if not silent and cfg.Callback then pcall(cfg.Callback, v) end
    end
    btn.MouseButton1Click:Connect(function() setState(not state) end)
    return { Set = setState, Get = function() return state end }
end

function UI.Button(parent, cfg)
    cfg = cfg or {}
    local btn = Make("TextButton", { Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Theme.Section, Text = "", AutoButtonColor = false, Parent = parent })
    Make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
    local stroke = Make("UIStroke", { Thickness = 1, Color = Theme.Stroke, Parent = btn })
    Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = cfg.Name or "Button", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Text, Parent = btn })
    btn.MouseEnter:Connect(function() Tween(stroke, 0.2, { Color = Theme.Accent }) end)
    btn.MouseLeave:Connect(function() Tween(stroke, 0.2, { Color = Theme.Stroke }) end)
    btn.MouseButton1Click:Connect(function()
        PlaySound("click", 0.3)
        if cfg.Callback then pcall(cfg.Callback) end
    end)
    return btn
end

function UI.Section(parent, title)
    return Make("TextLabel", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1, Text = title or "Section", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = parent })
end

function UI.Slider(parent, cfg)
    cfg = cfg or {}
    local flag = cfg.Flag or cfg.Name
    local minV, maxV = cfg.Min or 0, cfg.Max or 100
    local val = math.clamp(Flags[flag] or cfg.Default or minV, minV, maxV)
    local card = Make("Frame", { Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Theme.Section, Parent = parent })
    Make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = card })
    Make("UIStroke", { Thickness = 1, Color = Theme.Stroke, Parent = card })
    Make("TextLabel", { Size = UDim2.new(1, -80, 0, 18), Position = UDim2.new(0, 15, 0, 10), BackgroundTransparency = 1, Text = cfg.Name or "Slider", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
    local valLbl = Make("TextLabel", { Size = UDim2.new(0, 60, 0, 18), Position = UDim2.new(1, -75, 0, 10), BackgroundTransparency = 1, Text = tostring(val), Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right, Parent = card })
    local track = Make("Frame", { Size = UDim2.new(1, -30, 0, 6), Position = UDim2.new(0, 15, 0, 40), BackgroundColor3 = Theme.Sidebar, Parent = card })
    Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
    local fill = Make("Frame", { Size = UDim2.new((val - minV) / (maxV - minV), 0, 1, 0), BackgroundColor3 = Theme.Accent, Parent = track })
    Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
    local trig = Make("TextButton", { Size = UDim2.new(1, 0, 1, 30), Position = UDim2.new(0, 0, 0.5, -15), BackgroundTransparency = 1, Text = "", Parent = track })
    local drag = false
    local function update(px)
        local p = math.clamp((px - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local nv = math.floor(minV + (maxV - minV) * p)
        val = nv; fill.Size = UDim2.new(p, 0, 1, 0); valLbl.Text = tostring(nv); Flags[flag] = nv
        if cfg.Callback then pcall(cfg.Callback, nv) end
    end
    trig.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; update(i.Position.X) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
    UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i.Position.X) end end)
    return { Get = function() return val end }
end

function UI.Dropdown(parent, cfg)
    cfg = cfg or {}
    local flag = cfg.Flag or cfg.Name
    local options = cfg.Options or {}
    local val = Flags[flag] or cfg.Default or (options[1] or "")
    Flags[flag] = val
    local card = Make("Frame", { Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Theme.Section, Parent = parent })
    Make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = card })
    Make("UIStroke", { Thickness = 1, Color = Theme.Stroke, Parent = card })
    Make("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = cfg.Name or "Dropdown", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
    local picker = Make("TextButton", { Size = UDim2.new(0.45, -20, 0, 28), Position = UDim2.new(0.5, 10, 0.5, -14), BackgroundColor3 = Theme.Sidebar, Text = tostring(val), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Text, Parent = card })
    Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = picker })
    local list = Make("ScrollingFrame", { Size = UDim2.new(0.45, -20, 0, 0), Position = UDim2.new(0.5, 10, 1, 2), BackgroundColor3 = Theme.Section, Visible = false, ZIndex = 20, ScrollBarThickness = 2, Parent = card })
    Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = list })
    Make("UIStroke", { Thickness = 1, Color = Theme.Stroke, Parent = list })
    local open = false
    local function refresh()
        for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for i, opt in ipairs(options) do
            local b = Make("TextButton", { Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, (i-1)*24), BackgroundTransparency = 1, Text = tostring(opt), Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.SubText, ZIndex = 21, Parent = list })
            b.MouseEnter:Connect(function() b.TextColor3 = Theme.Accent end)
            b.MouseLeave:Connect(function() b.TextColor3 = Theme.SubText end)
            b.MouseButton1Click:Connect(function()
                PlaySound("click", 0.25)
                val = opt; picker.Text = tostring(opt); Flags[flag] = val
                list.Visible = false; open = false; list.Size = UDim2.new(0.45, -20, 0, 0)
                if cfg.Callback then pcall(cfg.Callback, val) end
            end)
        end
        list.CanvasSize = UDim2.new(0, 0, 0, #options * 24)
    end
    picker.MouseButton1Click:Connect(function()
        PlaySound("click", 0.25)
        open = not open
        if open then refresh(); list.Visible = true; list.Size = UDim2.new(0.45, -20, 0, math.min(#options * 24, 120))
        else list.Visible = false; list.Size = UDim2.new(0.45, -20, 0, 0) end
    end)
    return { Get = function() return val end }
end

-- ══════════ BUILD UI ══════════
screenGui = Make("ScreenGui", { Name = "YunoFarm_UI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Global })
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = LP:WaitForChild("PlayerGui") end

notifyHolder = Make("Frame", { Size = UDim2.new(0, 320, 1, -40), Position = UDim2.new(1, -330, 0, 20), BackgroundTransparency = 1, Parent = screenGui })
Make("UIListLayout", { HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8), Parent = notifyHolder })

mainFrame = Make("CanvasGroup", { Size = UDim2.new(0, 660, 0, 500), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Background, BackgroundTransparency = 0.05, BorderSizePixel = 0, Parent = screenGui })
Make("UICorner", { CornerRadius = UDim.new(0, 14), Parent = mainFrame })
Make("UIStroke", { Thickness = 1, Color = Theme.Stroke, Transparency = 0.3, Parent = mainFrame })
mainScale = Instance.new("UIScale", mainFrame)
mainScale.Scale = (getgenv().YunoScale or (IS_MOBILE and 0.62 or 1))

local titleBar = Make("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = mainFrame })
Make("UICorner", { CornerRadius = UDim.new(0, 14), Parent = titleBar })
Make("ImageLabel", { Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, 12, 0.5, -13), BackgroundTransparency = 1, Image = "rbxassetid://7733960981", ImageColor3 = Theme.Accent, Parent = titleBar })
Make("TextLabel", { Size = UDim2.new(0, 40, 0, 18), Position = UDim2.new(0, 44, 0, 8), BackgroundTransparency = 1, Text = "Yuno", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar })
Make("TextLabel", { Size = UDim2.new(0, 40, 0, 18), Position = UDim2.new(0, 84, 0, 8), BackgroundTransparency = 1, Text = "Farm", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar })
Make("TextLabel", { Size = UDim2.new(0, 60, 0, 14), Position = UDim2.new(0, 128, 0, 10), BackgroundTransparency = 1, Text = "v7.0", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar })

local closeBtn = Make("TextButton", { Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, -36, 0, 9), BackgroundColor3 = Color3.fromRGB(255, 90, 90), Text = "", AutoButtonColor = false, Parent = titleBar })
Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = closeBtn })
Make("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "✕", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.new(1,1,1), Parent = closeBtn })

local sidebar = Make("Frame", { Size = UDim2.new(0, 60, 1, -44), Position = UDim2.new(0, 0, 0, 44), BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0.5, BorderSizePixel = 0, Parent = mainFrame })
Make("UICorner", { CornerRadius = UDim.new(0, 14), Parent = sidebar })
Make("UIListLayout", { Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Top, Parent = sidebar })
Make("UIPadding", { PaddingTop = UDim.new(0, 15), Parent = sidebar })

local content = Make("Frame", { Size = UDim2.new(1, -80, 1, -60), Position = UDim2.new(0, 70, 0, 50), BackgroundTransparency = 1, ClipsDescendants = true, Parent = mainFrame })

local tabs = {}
local function AddTab(icon, name, builder)
    local btn = Make("TextButton", { Size = UDim2.new(0, 40, 0, 40), BackgroundColor3 = Theme.Section, Text = "", AutoButtonColor = false, Parent = sidebar })
    Make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
    Make("ImageLabel", { Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(0.5, -11, 0.5, -11), BackgroundTransparency = 1, Image = "rbxassetid://" .. icon, ImageColor3 = Theme.SubText, Parent = btn })
    local page = Make("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.SubText, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, Parent = content })
    Make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
    Make("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 20), Parent = page })
    local tab = { btn = btn, page = page, icon = btn:FindFirstChildOfClass("ImageLabel") }
    table.insert(tabs, tab)
    btn.MouseButton1Click:Connect(function()
        PlaySound("click", 0.2)
        for _, t in ipairs(tabs) do
            t.page.Visible = false
            Tween(t.icon, 0.2, { ImageColor3 = Theme.SubText })
            Tween(t.btn, 0.2, { BackgroundColor3 = Theme.Section })
        end
        page.Visible = true
        Tween(tab.icon, 0.2, { ImageColor3 = Theme.Accent })
        Tween(tab.btn, 0.2, { BackgroundColor3 = Theme.Accent })
    end)
    if builder then pcall(builder, page) end
    return page
end

-- Floating button
floatBtn = Make("TextButton", {
    Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(0.5, -28, 0, 80),
    BackgroundColor3 = Theme.Accent, Text = "", AutoButtonColor = false,
    Visible = false, ZIndex = 500, Parent = screenGui,
})
Make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = floatBtn })
local floatStroke = Make("UIStroke", { Thickness = 2, Color = Theme.Accent, Transparency = 0.2, Parent = floatBtn })
Make("ImageLabel", { Size = UDim2.new(1, -14, 1, -14), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://7733960981", ImageColor3 = Color3.new(1, 1, 1), Parent = floatBtn })
floatScale = Instance.new("UIScale", floatBtn)

local fDragging, fStart, fPos, fMoved = false, nil, nil, false
floatBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        fDragging = true; fMoved = false; fStart = i.Position; fPos = floatBtn.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if fDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - fStart
        if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then fMoved = true end
        if fMoved then floatBtn.Position = UDim2.new(fPos.X.Scale, fPos.X.Offset + delta.X, fPos.Y.Scale, fPos.Y.Offset + delta.Y) end
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        if fDragging and not fMoved then
            PlaySound("click", 0.4)
            floatBtn.Visible = false; mainFrame.Visible = true
            mainScale.Scale = 0.85
            Tween(mainScale, 0.3, { Scale = (getgenv().YunoScale or (IS_MOBILE and 0.62 or 1)) }, Enum.EasingStyle.Back)
        end
        fDragging = false
    end
end)

local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; startPos = mainFrame.Position
    end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    PlaySound("click", 0.4)
    Tween(mainScale, 0.25, { Scale = 0.6 }, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
        mainFrame.Visible = false
        floatBtn.Visible = true
        floatScale.Scale = 0.5
        Tween(floatScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
    end)
end)

UIS.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.RightControl then
        if mainFrame.Visible then
            mainFrame.Visible = false; floatBtn.Visible = true
            floatScale.Scale = 0.5; Tween(floatScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
        else
            floatBtn.Visible = false; mainFrame.Visible = true
            mainScale.Scale = 0.85; Tween(mainScale, 0.3, { Scale = (getgenv().YunoScale or (IS_MOBILE and 0.62 or 1)) }, Enum.EasingStyle.Back)
        end
    end
end)

-- ══════════ CORE ══════════
local lastStatus = ""
local DebugInfo = { Pets = 0, BabyNeeds = 0, PetNeeds = 0 }
local function SetStatus(s)
    if s ~= lastStatus then
        lastStatus = s
        local lbl = Flags.__statusLbl
        if lbl and lbl.Parent then lbl.Text = "Status: " .. s end
    end
end

local TaskFailures = {}
local function CanTry(k) local f = TaskFailures[k]; return not (f and (tick() - f.time) < 30) end
local function MarkFailed(k) local f = TaskFailures[k] or { count = 0 }; f.count = f.count + 1; f.time = tick(); TaskFailures[k] = f end
local function ClearFailure(k) TaskFailures[k] = nil end

local AILMENT_ALIASES = {
    sad = "bored", tired = "sleepy", exhausted = "sleepy",
    itchy = "dirty", smelly = "dirty", stinky = "dirty", dirty_pet = "dirty",
    ill = "sick", food = "hungry", food_bowl = "hungry",
    water = "thirsty", water_bowl = "thirsty",
    toy = "play", play_time = "play", bored_special = "bored",
    sleep = "sleepy", bed = "sleepy", shower = "dirty", bath = "dirty",
    mystery_special = "mystery", mystery_box = "mystery",
    pet_me_special = "pet_me", cat = "cat_cafe", cafe = "cat_cafe",
    pizza = "pizza_party", school_quest = "school", salon_quest = "salon",
}
local LoggedUnknown = {}
local function NormalizeAilment(k) return AILMENT_ALIASES[k] or k end
local function LogUnknownAilment(k)
    if LoggedUnknown[k] then return end
    LoggedUnknown[k] = true
    warn("[Yuno] ⚠ Unknown ailment: "..tostring(k))
end
local function GetHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ══════════ ENTER INTERIOR ══════════
local function EnterInterior(location, door, data)
    if not M.InteriorsM then return false end
    local fn = M.InteriorsM.enter_smooth
    if not fn then return false end
    local SetId = (syn and syn.set_thread_identity) or setthreadidentity or setidentity
    local GetId = (syn and syn.get_thread_identity) or getthreadidentity or getidentity
    local old = GetId and GetId() or 7
    if SetId then pcall(SetId, 2) end
    local ok = pcall(function()
        fn(location, door or "MainDoor", data or {})
    end)
    if SetId then pcall(SetId, old) end
    return ok
end

local function IsInHouse()
    local hi = Workspace:FindFirstChild("HouseInteriors")
    if not hi then return false end
    local bp = hi:FindFirstChild("blueprint")
    if not bp then return false end
    return bp:FindFirstChildWhichIsA("Model") ~= nil
end

local function GoToHouse()
    if IsInHouse() then return true end
    SetStatus("Entering house...")
    local loc = Cac.CurrentLocation or "MainMap"
    if loc ~= "MainMap" and loc ~= "housing" then
        EnterInterior("MainMap", "MainDoor", {})
        task.wait(3)
    end
    if loc == "housing" and API.UnsubscribeHouse then
        pcall(function() API.UnsubscribeHouse:InvokeServer() end)
        task.wait(1)
    end
    EnterInterior("housing", "MainDoor", { house_owner = LP })
    local s = tick()
    while tick() - s < 20 do
        task.wait(0.5)
        if IsInHouse() then task.wait(2); return true end
    end
    return IsInHouse()
end

-- ══════════ FURNITURE ══════════
local BEDS_MODELS = {
    "FancyPetBed", "ModernPetBed", "CircularPetBed", "RectangularPetBed",
    "NormalCrib", "BasicCrib", "RoyalCrib", "PoshCrib", "sleepingbag"
}
local SHOWERS_MODELS = {
    "StylishShower", "CheapBathtub", "ModernShower", "Bathtub",
    "GingerbreadShower", "HotTub", "camping_shower"
}

local function FindFurnitureID(kind)
    local hi = Workspace:FindFirstChild("HouseInteriors")
    if not hi then return {} end
    local furniture = hi:FindFirstChild("furniture")
    if not furniture then return {} end
    local modelList = (kind == "sleepy") and BEDS_MODELS or SHOWERS_MODELS
    local found = {}
    for _, v in pairs(furniture:GetChildren()) do
        local model = v:FindFirstChildWhichIsA("Model")
        if model and table.find(modelList, model.Name) then
            local parts = string.split(v.Name, "true/")
            local fid = parts[2]
            if fid and fid ~= "" then
                table.insert(found, { fid = fid, name = model.Name })
            end
        end
    end
    return found
end

local function GetFarmTargets()
    local out = { Baby = {}, Pets = {} }
    if not M.ClientData then return out end
    local data = M.ClientData.get_data() or {}
    local pd = data[LP.Name] or {}
    local am = data.ailments_manager or pd.ailments_manager or M.ClientData.get("ailments_manager")
    if not am then return out end
    if BabyFarmEnabled and am.baby_ailments then
        for _, a in pairs(am.baby_ailments) do
            if a.kind then out.Baby[NormalizeAilment(a.kind)] = true; LogUnknownAilment(a.kind) end
        end
    end
    if PetFarmEnabled then
        local wrappers = data.pet_char_wrappers or pd.pet_char_wrappers or M.ClientData.get("pet_char_wrappers")
        if wrappers then
            for _, w in pairs(wrappers) do
                if (w.player == LP or tostring(w.player) == LP.Name) then
                    local al = am.ailments[w.pet_unique] or {}
                    local needs = {}
                    for _, a in pairs(al) do
                        if a.kind then needs[NormalizeAilment(a.kind)] = true; LogUnknownAilment(a.kind) end
                    end
                    if next(needs) then
                        table.insert(out.Pets, { uid = w.pet_unique, char = w.char, needs = needs, id = w.pet_id })
                    end
                end
            end
        end
    end
    local bc = 0
    for _ in pairs(out.Baby) do bc = bc + 1 end
    DebugInfo.Pets, DebugInfo.BabyNeeds, DebugInfo.PetNeeds = #out.Pets, bc, #out.Pets
    return out
end

local function WaitForNeedDone(kind, timeout, loc)
    local s = os.time()
    while os.time() - s < timeout do
        task.wait(1)
        if not FarmEnabled then return false end
        if loc and (Cac.CurrentLocation or "MainMap") ~= loc then return false end
        local t = GetFarmTargets()
        local still = t.Baby[kind] and true or false
        if not still then for _, p in ipairs(t.Pets) do if p.needs[kind] then still = true; break end end end
        if not still then return true end
    end
    return false
end

local function GetFoodUID(kind)
    if not M.ClientData then return nil end
    local inv = M.ClientData.get("inventory", "Raw")
    if not inv or not inv.food then return nil end
    local list = {}
    for uid, v in pairs(inv.food) do if v.id == kind or v.kind == kind then table.insert(list, uid) end end
    table.sort(list); return list[1]
end

-- Platform
local function CreatePlatform(name)
    if not Cac.AilmentPlatform or not Cac.AilmentPlatform.Parent then
        local plat = Instance.new("Part")
        plat.Name = "YunoPlatform"; plat.Anchored = true; plat.CanCollide = true
        plat.Transparency = 0; plat.Size = Vector3.new(2048, 4, 2048)
        plat.CFrame = CFrame.new(-100000, 1000, -100000)
        plat.Color = Color3.fromRGB(80, 200, 120); plat.Parent = Workspace
        CollectionService:AddTag(plat, "YunoPlat"); Cac.AilmentPlatform = plat
    end
    local plat = Cac.AilmentPlatform
    plat.Name = name
    local origin, offset = nil, Vector3.new(0, 0, 0)
    if name == "Camping" then
        local cs = Workspace:FindFirstChild("StaticMap") and Workspace.StaticMap:FindFirstChild("Campsite")
        origin = cs and cs:FindFirstChild("CampsiteOrigin"); offset = Vector3.new(0, -1, 0)
    elseif name == "Playground" then
        local park = Workspace:FindFirstChild("StaticMap") and Workspace.StaticMap:FindFirstChild("Park")
        origin = park and park:FindFirstChild("BoredAilmentTarget"); offset = Vector3.new(0, -2.5, 0)
    elseif name == "Beach" then
        local tl = Workspace:FindFirstChild("StaticMap") and Workspace.StaticMap:FindFirstChild("TeleportLocations")
        origin = tl and tl:FindFirstChild("exterior_beach"); offset = Vector3.new(0, -10, 0)
    elseif name == "Pool" then
        local p = Workspace:FindFirstChild("StaticMap") and Workspace.StaticMap:FindFirstChild("Pool")
        origin = p and p:FindFirstChild("PoolOrigin"); offset = Vector3.new(0, -3, 0)
    elseif name == "Toilet" then
        local interact = Workspace:FindFirstChild("StaticMap") and Workspace.StaticMap:FindFirstChild("Interactables")
        if interact then
            for _, c in ipairs(interact:GetDescendants()) do
                if c.Name:find("AilmentsRefresh2024FireHydrant") then origin = c:FindFirstChild("Center") or c; break end
            end
        end
        offset = Vector3.new(0, -4, 0)
    end
    local loc = Cac.CurrentLocation
    if loc == "Salon" or loc == "School" or loc == "PizzaShop" or loc == "Hospital" or loc == "CatCafe" then
        plat.Position = Vector3.new(0, 15, 0)
    elseif name == "Main" then
        plat.Position = Vector3.new(2270 + math.random(-40, 40), 4780 + math.random(-40, 40), -2310 + math.random(-40, 40))
    elseif not origin then plat.Position = Vector3.new(2270, 4780, -2310)
    else plat.Position = origin.Position + offset + Vector3.new(math.random(-4, 4), 0, math.random(-4, 4)) end
    return plat
end

local function TPAllToPlatform(plat)
    local hrp = GetHRP()
    if not hrp or not plat then return end
    hrp.CFrame = CFrame.new(plat.Position + Vector3.new(0, 6, 0))
    if M.ClientData then
        for _, w in pairs(M.ClientData.get("pet_char_wrappers") or {}) do
            if (w.player == LP or tostring(w.player) == LP.Name) and w.char and w.char:IsA("Model") then
                pcall(function() w.char:PivotTo(hrp.CFrame * CFrame.new(math.random(-4,4), 0, math.random(-1,1))) end)
            end
        end
    end
end

local function TP(location, door, data)
    local loc = Cac.CurrentLocation or "MainMap"
    if loc == location then return true end
    if loc == "housing" and API.UnsubscribeHouse then
        pcall(function() API.UnsubscribeHouse:InvokeServer() end)
        task.wait(1)
    end
    EnterInterior(location, door or "MainDoor", data or {})
    local s, retried = tick(), false
    while tick() - s < 20 do
        task.wait(0.5)
        if (Cac.CurrentLocation or "MainMap") == location then
            if API.Download and location ~= "MainMap" then
                pcall(function() API.Download:InvokeServer("Interiors", location) end)
            end
            task.wait(1)
            return true
        end
        if tick() - s > 8 and not retried then
            retried = true
            EnterInterior(location, door or "MainDoor", data or {})
        end
    end
    return (Cac.CurrentLocation or "MainMap") == location
end

-- ══════════ TASK FUNCTIONS ══════════
local function DoFeedTask(kind)
    local t = GetFarmTargets()
    local foodKind = kind == "hungry" and "apple" or "water"
    local babyN = t.Baby[kind]
    local pets = {}
    for _, p in ipairs(t.Pets) do if p.needs[kind] then table.insert(pets, p) end end
    if not babyN and #pets == 0 then return true end
    if M.ClientData then
        local money = M.ClientData.get("money") or 0
        if money < 3 and not GetFoodUID(foodKind) then MarkFailed(kind); return false end
    end
    if babyN and API.ServerUseTool then
        local fid = GetFoodUID(foodKind)
        if not fid and API.BuyItem and (M.ClientData.get("money") or 0) >= 5 then
            pcall(function() API.BuyItem:InvokeServer("food", foodKind, { buy_count = 5 }) end)
            task.wait(0.8); fid = GetFoodUID(foodKind)
        end
        if fid then
            local n = kind == "thirsty" and 8 or 3
            for i = 1, n do pcall(function() API.ServerUseTool:InvokeServer(fid, "END") end); task.wait(0.08) end
        end
    end
    if API.CreatePetObject and API.ConsumeFoodObject then
        for _, pet in ipairs(pets) do
            local fid = GetFoodUID(foodKind)
            if not fid and API.BuyItem and (M.ClientData.get("money") or 0) >= 1 then
                pcall(function() API.BuyItem:InvokeServer("food", foodKind, { buy_count = 1 }) end)
                task.wait(0.8); fid = GetFoodUID(foodKind)
            end
            if fid then
                pcall(function()
                    local obj = API.CreatePetObject:InvokeServer("__Enum_PetObjectCreatorType_2", { pet_unique = pet.uid, unique_id = fid })
                    local model = obj and (obj:FindFirstChild("Model") or obj)
                    if not model then
                        local po = Workspace:FindFirstChild("PetObjects")
                        if po then for _, c in ipairs(po:GetChildren()) do
                            local iu = c:FindFirstChild("ItemUniqueId")
                            if iu and iu.Value == fid then model = c:FindFirstChild("Model") or c; break end
                        end end
                    end
                    if model then API.ConsumeFoodObject:FireServer(model, pet.uid) end
                end)
                task.wait(0.5)
            end
        end
    end
    local done = WaitForNeedDone(kind, 15)
    if done then ClearFailure(kind) else MarkFailed(kind) end
    return done
end

local function DoPlayTask()
    local t = GetFarmTargets()
    local toyUid
    if M.ClientData then
        local inv = M.ClientData.get("inventory", "Raw")
        if inv and inv.toys then
            for uid, v in pairs(inv.toys) do
                local k = tostring(v.kind or v.id)
                if k == "squeaky_bone_default" or k:find("chew_toy") then toyUid = uid; break end
            end
        end
    end
    if not toyUid then MarkFailed("play"); return false end
    if t.Baby.play and API.ServerUseTool then
        pcall(function() API.ServerUseTool:InvokeServer(toyUid, "END") end); task.wait(0.5)
    end
    if API.CreatePetObject and API.GrabPetObject and API.DropPetObject then
        for _, pet in ipairs(t.Pets) do
            if pet.needs.play and pet.char then
                task.spawn(function()
                    for att = 1, 2 do
                        if not FarmEnabled then break end
                        local ok, obj = pcall(function()
                            return API.CreatePetObject:InvokeServer("__Enum_PetObjectCreatorType_1", { reaction_name = "ThrowToyReaction", unique_id = toyUid, pet_unique = pet.uid })
                        end)
                        local model = obj and (obj:FindFirstChild("Model") or obj)
                        if not model then
                            task.wait(0.15)
                            local po = Workspace:FindFirstChild("PetObjects")
                            if po then for _, c in ipairs(po:GetChildren()) do
                                local iu = c:FindFirstChild("ItemUniqueId")
                                if iu and iu.Value == toyUid then model = c:FindFirstChild("Model") or c; break end
                            end end
                        end
                        if model and pet.char then
                            pcall(function() API.GrabPetObject:FireServer(pet.char, model) end)
                            task.wait(0.3)
                            pcall(function() API.DropPetObject:FireServer(pet.char) end)
                            task.wait(0.4)
                        end
                        task.wait(0.8)
                    end
                end)
                task.wait(0.5)
            end
        end
    end
    local done = WaitForNeedDone("play", 15)
    if done then ClearFailure("play") else MarkFailed("play") end
    return done
end

local function DoSleepDirtyTask(kind)
    local t = GetFarmTargets()
    local isBaby = t.Baby[kind]
    local pets = {}
    for _, p in ipairs(t.Pets) do if p.needs[kind] then table.insert(pets, p) end end
    if not isBaby and #pets == 0 then return true end

    SetStatus(kind .. ": entering house...")
    if not GoToHouse() then
        SetStatus(kind .. ": FAILED house")
        Notify("Dirty/Sleep", "Can't enter house. Rejoin.")
        MarkFailed(kind); return false
    end
    task.wait(2)

    local found = FindFurnitureID(kind)
    if not found or #found == 0 then
        SetStatus(kind .. ": NO " .. (kind == "sleepy" and "BED" or "SHOWER"))
        Notify(kind, "Buy a " .. (kind == "sleepy" and "bed" or "shower") .. " in your house!")
        MarkFailed(kind); return false
    end

    local fid = found[1].fid
    SetStatus(kind .. ": " .. found[1].name)

    local targets = {}
    if isBaby and LP.Character then
        table.insert(targets, { char = LP.Character, isBaby = true })
    end
    for _, pet in ipairs(pets) do
        if pet.char then table.insert(targets, { char = pet.char, isBaby = false, uid = pet.uid }) end
    end
    if #targets == 0 then return true end

    local start = tick()
    local lastSend = 0
    while tick() - start < 90 do
        task.wait(0.3)
        if not FarmEnabled then break end
        if not IsInHouse() then
            if not GoToHouse() then break end
            task.wait(1.5)
        end
        local tt = GetFarmTargets()
        local still = tt.Baby[kind] and true or false
        if not still then
            for _, p in ipairs(tt.Pets) do if p.needs[kind] then still = true; break end end
        end
        if not still then break end
        if tick() - lastSend >= 3 then
            lastSend = tick()
            local lpHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if lpHrp then
                local cf = lpHrp.CFrame
                if isBaby and LP.Character then
                    pcall(function() API.ActivateFurniture:InvokeServer(LP, fid, "UseBlock", { cframe = cf }, LP.Character) end)
                end
                for _, pet in ipairs(pets) do
                    if pet.char and pet.char.Parent then
                        pcall(function() API.ActivateFurniture:InvokeServer(LP, fid, "UseBlock", { cframe = cf }, pet.char) end)
                        task.wait(0.1)
                    end
                end
            end
        end
    end

    if API.ExitSeats then pcall(function() API.ExitSeats:FireServer() end) end
    for _, pet in ipairs(pets) do
        if API.ExitFurniture and pet.uid then pcall(function() API.ExitFurniture:InvokeServer(pet.uid) end) end
    end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Sit = false end

    local done = WaitForNeedDone(kind, 5)
    if done then ClearFailure(kind) else MarkFailed(kind) end
    return done
end

local function DoSickTask()
    local t = GetFarmTargets()
    local still = t.Baby.sick and true or false
    if not still then for _, p in ipairs(t.Pets) do if p.needs.sick then still = true; break end end end
    if not still then return true end
    if not API.HealWithDoctor then
        if not TP("Hospital") then MarkFailed("sick"); return false end
        task.wait(2)
        if API.ActivateInterior then pcall(function() API.ActivateInterior:InvokeServer("f-14", "UseBlock", "Yes", LP.Character) end) end
        local done = WaitForNeedDone("sick", 30, "Hospital")
        if done then ClearFailure("sick") else MarkFailed("sick") end
        return done
    end
    SetStatus("sick: healing...")
    local s = tick()
    while tick() - s < 30 do
        pcall(function() API.HealWithDoctor:FireServer() end)
        task.wait(1)
        local tt = GetFarmTargets()
        local sn = tt.Baby.sick and true or false
        if not sn then for _, p in ipairs(tt.Pets) do if p.needs.sick then sn = true; break end end end
        if not sn then ClearFailure("sick"); return true end
    end
    MarkFailed("sick"); return false
end

local function DoToiletTask()
    TPAllToPlatform(CreatePlatform("Main")); task.wait(0.5)
    if not TP("MainMap") then MarkFailed("toilet"); return false end
    task.wait(0.5)
    TPAllToPlatform(CreatePlatform("Toilet")); task.wait(1)
    local interact = Workspace:FindFirstChild("StaticMap") and Workspace.StaticMap:FindFirstChild("Interactables")
    if not interact then MarkFailed("toilet"); return false end
    local hydrant
    for _, c in ipairs(interact:GetDescendants()) do
        if c.Name:find("AilmentsRefresh2024FireHydrant") then hydrant = c; break end
    end
    if not hydrant then MarkFailed("toilet"); return false end
    local fid, p = nil, hydrant
    while p do local m = p.Name:match("f%-%d+"); if m then fid = m; break end; p = p.Parent end
    if fid and LP.Character and API.ActivateInterior then
        pcall(function() API.ActivateInterior:InvokeServer(fid, "UseBlock", { cframe = LP.Character:GetPivot() }, LP.Character) end)
    end
    local done = WaitForNeedDone("toilet", 25, "MainMap")
    if done then ClearFailure("toilet") else MarkFailed("toilet") end
    return done
end

local function DoPoolPartyTask()
    TPAllToPlatform(CreatePlatform("Main")); task.wait(0.5)
    if not TP("MainMap") then MarkFailed("pool_party"); return false end
    task.wait(1)
    local pool = Workspace:FindFirstChild("StaticMap") and Workspace.StaticMap:FindFirstChild("Pool")
    local origin = pool and pool:FindFirstChild("PoolOrigin")
    if not origin then MarkFailed("pool_party"); return false end
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(origin.Position + Vector3.new(0, 5, 0)) end
    task.wait(0.5)
    TPAllToPlatform(CreatePlatform("Pool"))
    local done = WaitForNeedDone("pool_party", 30)
    if done then ClearFailure("pool_party") else MarkFailed("pool_party") end
    return done
end

local function DoMysteryTask()
    local t = GetFarmTargets()
    local pets = {}
    for _, p in ipairs(t.Pets) do
        if p.needs.mystery or p.needs.misery then
            if not Cac.MysteryBlacklist[p.uid] or os.time() - Cac.MysteryBlacklist[p.uid] > 60 then
                table.insert(pets, { pet = p, kind = p.needs.mystery and "mystery" or "misery" })
            end
        end
    end
    if #pets == 0 then return true end
    if Cac.LastMysteryAttempt and os.time() - Cac.LastMysteryAttempt < 3 then return false end
    Cac.LastMysteryAttempt = os.time()
    local data = M.ClientData.get_data() or {}
    local pd = data[LP.Name] or {}
    local petData = (pd.inventory and pd.inventory.pets) or {}
    for _, e in ipairs(pets) do
        local petUID = e.pet.uid
        local petInfo = petData[petUID]
        if petInfo and AilmentsClient and API.ChooseMystery then
            local entityRef = { pet_unique = petUID, pet_id = petInfo.kind or petInfo.id, is_egg = false, is_doll = false, player = LP }
            local mysteryValue
            pcall(function()
                for _, fn in pairs(AilmentsClient) do
                    if type(fn) == "function" then
                        local uvs = debug.getupvalues(fn)
                        if uvs then
                            for _, uv in pairs(uvs) do
                                if type(uv) == "table" then
                                    local pa = rawget(uv, petUID)
                                    if pa and type(pa) == "table" then
                                        local v = rawget(pa, e.kind) or rawget(pa, "mystery")
                                        if v then mysteryValue = v; break end
                                    end
                                end
                            end
                        end
                        if mysteryValue then break end
                    end
                end
            end)
            if mysteryValue and mysteryValue.action and mysteryValue.action.options then
                local gs = mysteryValue.action.options.get_ailment_slots
                local seed = mysteryValue.action.options.random_seed
                if gs and seed then
                    local SetId = (syn and syn.set_thread_identity) or setthreadidentity or setidentity
                    local GetId = (syn and syn.get_thread_identity) or getthreadidentity or getidentity
                    local old = GetId and GetId() or 7
                    if SetId then pcall(SetId, 2) end
                    local ok, slots = pcall(function() return gs(seed, {}, entityRef) end)
                    if SetId then pcall(SetId, old) end
                    if ok and slots and type(slots) == "table" then
                        local pk, pKind
                        for _, easy in ipairs(MYSTERY_PRIORITY) do
                            for k, v in pairs(slots) do if v == easy then pk = k; pKind = easy; break end end
                            if pk then break end
                        end
                        if not pk then for k, v in pairs(slots) do pk = k; pKind = v; break end end
                        if pk and pKind then
                            pcall(function() API.ChooseMystery:FireServer(petUID, e.kind, pk, pKind) end)
                            task.wait(1.2)
                        end
                    end
                end
            end
        end
    end
    local done = WaitForNeedDone("mystery", 10) or WaitForNeedDone("misery", 10)
    if done then ClearFailure("mystery"); ClearFailure("misery")
    else
        for _, e in ipairs(pets) do
            Cac.MysteryFails[e.pet.uid] = (Cac.MysteryFails[e.pet.uid] or 0) + 1
            if Cac.MysteryFails[e.pet.uid] >= 3 then
                Cac.MysteryBlacklist[e.pet.uid] = os.time()
                Cac.MysteryFails[e.pet.uid] = nil
            end
        end
        MarkFailed("mystery")
    end
    return done
end

local function DoPetMeTask()
    local t = GetFarmTargets()
    local processed = false
    local entities
    if M.PetEntityManager and M.PetEntityManager.get_local_owned_pet_entities then
        pcall(function() entities = M.PetEntityManager.get_local_owned_pet_entities() end)
    end
    for _, pet in ipairs(t.Pets) do
        if pet.needs.pet_me then
            if not Cac.PetMeAttempts[pet.uid] or os.time() - Cac.PetMeAttempts[pet.uid] > 10 then
                Cac.PetMeAttempts[pet.uid] = os.time()
                local entity
                if entities then for _, e in pairs(entities) do if e.base and e.base.char_wrapper and e.base.char_wrapper.pet_unique == pet.uid then entity = e; break end end end
                if entity and M.PetEntityHelper and M.PetEntityHelper.stage_performance then
                    pcall(function() M.PetEntityHelper.stage_performance(entity, { name = "FocusPet" }) end); task.wait(0.15)
                end
                if API.ProgressPetMe then pcall(function() API.ProgressPetMe:FireServer(pet.uid) end) end
                if entity and M.PetEntityHelper and M.PetEntityHelper.end_performance then
                    task.wait(0.15)
                    pcall(function() M.PetEntityHelper.end_performance(entity, "FocusPet") end)
                end
                task.wait(1.5); processed = true
            end
        end
    end
    if not processed then return true end
    local done = WaitForNeedDone("pet_me", 15)
    if done then ClearFailure("pet_me") else MarkFailed("pet_me") end
    return done
end

local function DoWalkTask()
    local t = GetFarmTargets()
    local hasWalkPet = false
    for _, p in ipairs(t.Pets) do if p.needs.walk then hasWalkPet = true; break end end
    if not t.Baby.walk and not hasWalkPet then return true end
    TPAllToPlatform(CreatePlatform("Main")); task.wait(0.5)
    if not TP("MainMap") then MarkFailed("walk"); return false end
    task.wait(1)
    TPAllToPlatform(CreatePlatform("Main")); task.wait(1)
    local plat = Cac.AilmentPlatform
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if not plat or not hum then MarkFailed("walk"); return false end
    SetStatus("walk: circling...")
    local start = tick(); local angle = 0; local lastRefresh = tick()
    while tick() - start < 60 do
        task.wait(0.2)
        if not FarmEnabled then break end
        if tick() - lastRefresh > 5 then lastRefresh = tick(); TPAllToPlatform(plat) end
        local tt = GetFarmTargets()
        local still = tt.Baby.walk and true or false
        if not still then for _, p in ipairs(tt.Pets) do if p.needs.walk then still = true; break end end end
        if not still then break end
        angle = angle + 0.2
        local radius = 25
        pcall(function() hum:MoveTo(plat.Position + Vector3.new(math.cos(angle) * radius, 6, math.sin(angle) * radius)) end)
        if math.random() < 0.05 then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
        if M.ClientData then
            for _, w in pairs(M.ClientData.get("pet_char_wrappers") or {}) do
                if (w.player == LP or tostring(w.player) == LP.Name) and w.char and w.char.PrimaryPart then
                    local hrp = GetHRP()
                    if hrp and (w.char.PrimaryPart.Position - hrp.Position).Magnitude > 15 then
                        pcall(function() w.char:PivotTo(hrp.CFrame * CFrame.new(math.random(-3,3), 0, math.random(-3,3))) end)
                    end
                end
            end
        end
    end
    local done = WaitForNeedDone("walk", 10)
    if done then ClearFailure("walk") else MarkFailed("walk") end
    return done
end

local function DoRideTask()
    local t = GetFarmTargets()
    local pets = {}
    for _, p in ipairs(t.Pets) do if p.needs.ride then table.insert(pets, p) end end
    if not t.Baby.ride and #pets == 0 then return true end
    TPAllToPlatform(CreatePlatform("Main")); task.wait(0.5)
    if not TP("MainMap") then MarkFailed("ride"); return false end
    task.wait(1)
    TPAllToPlatform(CreatePlatform("Main")); task.wait(1)
    if not Cac.StrollerUID and M.ClientData then
        local inv = M.ClientData.get("inventory", "Raw")
        if inv and inv.strollers then for uid, v in pairs(inv.strollers) do
            if (v.kind or v.id) == "stroller-default" then Cac.StrollerUID = uid; break end
        end end
    end
    if Cac.StrollerUID and os.time() - Cac.LastStrollerEquip > 3 and API.Equip then
        Cac.LastStrollerEquip = os.time()
        pcall(function() API.Equip:InvokeServer(Cac.StrollerUID) end); task.wait(1)
    end
    local plat = Cac.AilmentPlatform
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    local s, angle = tick(), 0
    while tick() - s < 30 do
        task.wait(0.15)
        if not FarmEnabled then break end
        local tt = GetFarmTargets()
        local still = tt.Baby.ride and true or false
        if not still then for _, p in ipairs(tt.Pets) do if p.needs.ride then still = true; break end end end
        if not still then break end
        if plat and hum then
            angle = angle + 0.12
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
            pcall(function() hum:MoveTo(plat.Position + Vector3.new(math.cos(angle) * 20, 6, math.sin(angle) * 20)) end)
        end
    end
    if Cac.StrollerUID and API.Unequip then pcall(function() API.Unequip:InvokeServer(Cac.StrollerUID) end) end
    local done = WaitForNeedDone("ride", 10)
    if done then ClearFailure("ride") else MarkFailed("ride") end
    return done
end

local function DoQuestTask(kind, location, platName)
    TPAllToPlatform(CreatePlatform("Main")); task.wait(0.5)
    if not TP(location) then MarkFailed(kind); return false end
    task.wait(1.5)
    if platName then TPAllToPlatform(CreatePlatform(platName)); task.wait(1.5) else TPAllToPlatform(CreatePlatform("Main")); task.wait(1) end
    local s = tick()
    while tick() - s < 60 do
        task.wait(2)
        if not FarmEnabled then break end
        if (Cac.CurrentLocation or "MainMap") ~= location then break end
        if not Cac.AilmentPlatform or not Cac.AilmentPlatform.Parent then
            if platName then TPAllToPlatform(CreatePlatform(platName)) else TPAllToPlatform(CreatePlatform("Main")) end
        end
        local t = GetFarmTargets()
        local still = t.Baby[kind] and true or false
        if not still then for _, p in ipairs(t.Pets) do if p.needs[kind] then still = true; break end end end
        if not still then break end
    end
    local done = WaitForNeedDone(kind, 5)
    if done then ClearFailure(kind) else MarkFailed(kind) end
    return done
end

-- ══════════ HALLOWEEN (Enhanced from Yuno Hub v2) ══════════
local BEDS_MODELS_LEN = 0

local function GetHWR(name)
    if not EventNet then EventNet = RS:FindFirstChild("adoptme_new_net") end
    if not EventNet then return nil end
    return EventNet:FindFirstChild(name) or EventNet:WaitForChild(name, 3)
end

local function EquipCryptKey()
    local char = LP.Character
    if char and char:FindFirstChild("Halloween2026RustyKey") then return true end
    local inv = M.ClientData.get("inventory", "Raw") or {}
    local keyUid
    for cat, items in pairs(inv) do
        if type(items) == "table" then
            for uid, item in pairs(items) do
                if type(item) == "table" and tostring(item.kind or item.id) == "halloween_2026_rusty_key" then
                    keyUid = uid; break
                end
            end
        end
        if keyUid then break end
    end
    if not keyUid then return false end
    if API.Equip then
        pcall(function() API.Equip:InvokeServer(keyUid) end)
        task.wait(1.5)
    end
    return char and char:FindFirstChild("Halloween2026RustyKey") ~= nil
end

local function GetCryptData()
    return M.ClientData.get("halloween_2026_crypt_manager")
end

local function GetNestData()
    return M.ClientData.get("halloween_2026_jacobean_pigeon_nest_manager")
end

local function GetTwigUIDs()
    local inv = M.ClientData.get("inventory", "Raw") or {}
    local twigs = {}
    for uid, item in pairs(inv.toys or {}) do
        if (item.kind or item.id) == "halloween_2026_twig" then table.insert(twigs, uid) end
    end
    return twigs
end

-- Crypt plan: prioritize Twig graves -> Ladder -> other -> Spider
local function CryptPlan(cryptData, preferTwig)
    if type(cryptData) ~= "table" or type(cryptData.floors) ~= "table" then return nil end
    local openedSet = {}
    for _, v in ipairs(cryptData.opened or {}) do openedSet[tonumber(v)] = true end

    local function getCoffins(floor)
        return type(floor) == "table" and floor.coffins or nil
    end

    -- First pass: if preferTwig, find highest floor reachable with twig grave not opened
    if preferTwig then
        for i = #cryptData.floors, 1, -1 do
            local floor = cryptData.floors[i]
            if type(floor) == "table" and type(floor.coffins) == "table" then
                -- check if ladder below this floor is opened
                local ladderOpen = false
                for j = 1, i - 1 do
                    local f = cryptData.floors[j]
                    if type(f) == "table" and type(f.coffins) == "table" then
                        for gid, val in pairs(f.coffins) do
                            if val == "ladder" then
                                local idx = j * 16 + tonumber(gid)
                                if openedSet[idx] then ladderOpen = true end
                                break
                            end
                        end
                    end
                end
                if i == 1 or ladderOpen then
                    for gid, val in pairs(floor.coffins) do
                        if val == "twig" then
                            local idx = i * 16 + tonumber(gid)
                            if not openedSet[idx] then
                                return { floor = i, grave = tonumber(gid), reward = "twig" }
                            end
                        end
                    end
                end
            end
        end
    end

    -- Second pass: standard plan
    for i = 1, #cryptData.floors do
        local floor = cryptData.floors[i]
        if type(floor) == "table" then
            if floor.is_final or (type(floor.coffins) == "table" and next(floor.coffins) == nil) then
                return { spider = true, floor = i }
            end
            local coffins = getCoffins(floor)
            if coffins then
                -- check if ladder is unopened
                local ladderGid
                for gid, val in pairs(coffins) do
                    if val == "ladder" then ladderGid = tonumber(gid); break end
                end
                if ladderGid and not openedSet[i * 16 + ladderGid] then
                    return { floor = i, grave = ladderGid, reward = "ladder" }
                end
                -- pick best remaining grave
                local bestGid, bestVal = nil, -1
                for gid, val in pairs(coffins) do
                    if not openedSet[i * 16 + tonumber(gid)] and val ~= "ladder" then
                        local value = (val == "candy_corn_pile_ginormous" and 3) or (val == "candy_corn_pile_small" and 2) or (val == "twig" and 1) or 0.5
                        if value > bestVal then bestGid, bestVal = tonumber(gid), value end
                    end
                end
                if bestGid then
                    return { floor = i, grave = bestGid, reward = coffins[bestGid] }
                end
            end
        end
    end
    return { spider = true }
end

local function DoHalloweenCrypt()
    if not EventNet then return false end
    local unlock = GetHWR("Halloween2026/UnlockPadlock")
    local claimSpider = GetHWR("Halloween2026/ClaimTombSpider")
    if not unlock then return false end
    local crypt = GetCryptData()
    if not crypt or not crypt.floors then return false end

    local spiderOnly = false
    local mode = Flags.YF_HWCryptMode or "Fast Spider"
    local plan = CryptPlan(crypt, mode == "Twigs + Spider")
    if not plan then return false end
    if mode == "Twigs + Spider" then
        -- prefer twig graves
        plan = CryptPlan(crypt, true) or plan
    end

    if Cac.CurrentLocation ~= "TheCrypt" then
        SetStatus("HW: entering Crypt...")
        if Cac.CurrentLocation == "housing" then pcall(function() API.UnsubscribeHouse:InvokeServer() end); task.wait(1) end
        EnterInterior("TheCrypt", "MainDoor", {})
        local s = tick()
        while tick() - s < 15 do task.wait(0.5); if Cac.CurrentLocation == "TheCrypt" then break end end
        if Cac.CurrentLocation ~= "TheCrypt" then SetStatus("HW: crypt fail"); return false end
        if API.Download then pcall(function() API.Download:InvokeServer("Interiors", "TheCrypt") end) end
        task.wait(2)
    end

    if plan.spider then
        if claimSpider then
            pcall(function() claimSpider:InvokeServer() end)
            Notify("Halloween", "🕷 Tomb Spider claimed!")
            PlaySound("success", 0.7)
            task.wait(3)
        end
        return true
    end

    if not EquipCryptKey() then SetStatus("HW: no key"); return false end

    local gidx = plan.floor * 16 + plan.grave
    if Cac.CryptPendingLocks[gidx] then return true end
    Cac.CryptPendingLocks[gidx] = true
    pcall(function() unlock:InvokeServer({ padlock_index = plan.grave, floor_index = plan.floor }) end)
    SetStatus("HW: crypt floor " .. plan.floor .. " grave " .. plan.grave)
    task.wait(1.5)
    Cac.CryptPendingLocks[gidx] = nil
    return true
end

local function DoHalloweenTwigs()
    local contribute = GetHWR("Halloween2026/JacobeanPigeonNestContributeTwig")
    if not contribute then return false end
    local nest = GetNestData()
    if not nest then return false end
    if (nest.twigs_contributed or 0) >= 8 then return false end
    local twigs = GetTwigUIDs()
    if #twigs == 0 then SetStatus("HW: no twigs"); return false end

    if Cac.CurrentLocation ~= "HauntedHotel" then
        SetStatus("HW: entering hotel...")
        if Cac.CurrentLocation == "housing" then pcall(function() API.UnsubscribeHouse:InvokeServer() end); task.wait(1) end
        EnterInterior("HauntedHotel", "MainDoor", {})
        local s = tick()
        while tick() - s < 15 do task.wait(0.5); if Cac.CurrentLocation == "HauntedHotel" then break end end
        task.wait(2)
    end

    local hrp = GetHRP()
    if hrp then
        hrp.CFrame = hrp.CFrame * CFrame.new(0, 10, 0)
        hrp.AssemblyLinearVelocity = Vector3.zero
        task.wait(1)
    end

    for _, uid in ipairs(twigs) do
        local fresh = GetNestData()
        if fresh and (fresh.twigs_contributed or 0) >= 8 then break end
        SetStatus("HW: twig " .. (fresh and fresh.twigs_contributed or "?") .. "/8")
        local ok, result = pcall(function() return contribute:InvokeServer({ unique = uid }) end)
        if ok and result and result.ok then
            Notify("Halloween", "🪵 Twig " .. (result.twigs_contributed or "?") .. "/8")
            task.wait(1)
            if (result.twigs_contributed or 0) >= 8 then
                Notify("Halloween", "🎉 Jacobean Pigeon unlocked!")
                PlaySound("success", 0.7)
                break
            end
        else
            local reason = result and result.reason or "unknown"
            SetStatus("HW: twig fail (" .. reason .. ")")
            if reason ~= "too_far" and reason ~= "nest_complete" then break end
            task.wait(2)
        end
    end
    return true
end

local function DoHalloweenCandy()
    local claim = GetHWR("Halloween2026/CandyCornPileClaim")
    if not claim then return false end
    local mgr = M.ClientData.get("halloween_2026_candy_corn_pile_manager")
    if not mgr or not mgr.pending then return false end
    if mgr.pending < 15000 then SetStatus("HW: candy " .. mgr.pending .. "/15000"); return false end
    local loc = Cac.CurrentLocation or ""
    if string.find(loc, "Crypt") or string.find(loc, "Manor") or string.find(loc, "Minigame") then return false end

    SetStatus("HW: claiming " .. mgr.pending .. " candy")
    if loc ~= "MainMap" then
        if loc == "housing" then pcall(function() API.UnsubscribeHouse:InvokeServer() end); task.wait(1) end
        EnterInterior("MainMap", "MainDoor", {})
        task.wait(3)
    end

    local hrp = GetHRP()
    if hrp then
        local pickup
        if Workspace:FindFirstChild("Interiors") then pickup = Workspace.Interiors:FindFirstChild("PickupArea", true) end
        if pickup then
            hrp.CFrame = pickup.CFrame * CFrame.new(0, 3, 0)
            hrp.AssemblyLinearVelocity = Vector3.zero
            task.wait(1)
        end
    end
    pcall(function() claim:InvokeServer() end)
    Notify("Halloween", "🍬 Claimed " .. mgr.pending .. " candy")
    PlaySound("success", 0.6)
    task.wait(2)
    return true
end

local function DoHalloweenGhost()
    if not API.MinigameMsg then return false end
    local ts = M.ClientData.get("ghost_clusters_cycle_timestamp")
    if not ts or not ts.timestamp then return false end
    local remain = ts.timestamp - os.time()
    if remain > 15 or remain < -120 then
        SetStatus("HW: ghost inactive (" .. remain .. "s)")
        return false
    end

    SetStatus("HW: entering Manor...")
    if Cac.CurrentLocation ~= "HauntedManor" and Cac.CurrentLocation ~= "ManorMinigameInterior" then
        if Cac.CurrentLocation == "housing" then pcall(function() API.UnsubscribeHouse:InvokeServer() end); task.wait(1) end
        pcall(function() API.SetLocation:FireServer("MainMap", nil, "MainMap") end)
        task.wait(1)
        EnterInterior("HauntedManor", "MainDoor", {
            spawn_cframe = CFrame.new(-5976.8955078125, 10010.609375, 9001.478515625, 1, 0, 0, 0, 1, 0, 0, 0, 1),
            start_transparency = 1,
        })
        local s = tick()
        while tick() - s < 10 do task.wait(0.5); if Cac.CurrentLocation == "HauntedManor" or Cac.CurrentLocation == "ManorMinigameInterior" then break end end
    end

    local mg = M.ClientData.get("minigame_client_manager")
    local mgid
    if mg and mg.get then
        local inst = mg.get("ghost_clusters")
        if inst and inst.instanced_minigame then mgid = inst.instanced_minigame.minigame_id end
    end
    if not mgid then SetStatus("HW: no mgid"); return false end

    SetStatus("HW: contributing ghosts...")
    local live = Workspace:FindFirstChild("GhostClustersLive")
    local contributed = 0
    if live then
        for _, desc in ipairs(live:GetDescendants()) do
            if desc:IsA("Model") and desc.PrimaryPart then
                local gid = desc:GetAttribute("GhostClustersId")
                if gid then
                    local prog = desc:GetAttribute("GhostClustersProgress") or 0
                    local req = desc:GetAttribute("GhostClustersProgressRequired") or 1
                    local orbit = desc:GetAttribute("GhostClustersOrbiting")
                    local shield = desc:GetAttribute("GhostClustersShielded")
                    local isBoss = desc:GetAttribute("GhostClustersSize") == "Large"
                    local canContribute = (prog < req) and not orbit
                    if isBoss and shield then canContribute = false end
                    if canContribute then
                        local token = HttpService:GenerateGUID(false)
                        pcall(function()
                            API.MinigameMsg:FireServer(mgid, "start_contribute", { use_token = token, ghost_id = gid })
                        end)
                        contributed = contributed + 1
                        task.wait(0.4)
                    end
                end
            end
        end
    end
    if contributed > 0 then Notify("Halloween", "👻 " .. contributed .. " ghosts targeted") end
    task.wait(10)
    return true
end

-- ══════════ AUTO SKELICORN (from Yuno Hub v2) ══════════
local SkelicornState = { delivered = false, activated = false, bought = false, leverRequired = false, buyRefusedAt = 0 }
local function FindLeverInInventory()
    local inv = M.ClientData.get("inventory", "Raw") or {}
    for cat, items in pairs(inv) do
        if type(items) == "table" then
            for uid, item in pairs(items) do
                if type(item) == "table" and (item.id == "halloween_2026_lightning_lever" or item.kind == "halloween_2026_lightning_lever") then
                    return uid
                end
            end
        end
    end
    return nil
end

local function GetSkelicornPrice()
    local price = 120000
    pcall(function()
        if M.InventoryDB and M.InventoryDB.pets and M.InventoryDB.pets["halloween_2026_skelicorn"] then
            local c = tonumber(M.InventoryDB.pets["halloween_2026_skelicorn"].cost or M.InventoryDB.pets["halloween_2026_skelicorn"].price)
            if c and c > 0 then price = c end
        end
    end)
    return price
end

local function GetCandyCount()
    local n = tonumber(M.ClientData.get("candy_2026")) or tonumber(M.ClientData.get("candy")) or 0
    return n
end

local function GetGrowingSkelicorns()
    local count = 0
    local inv = M.ClientData.get("inventory", "Raw") or {}
    for _, p in pairs(inv.pets or {}) do
        if (p.kind or p.id) == "halloween_2026_skelicorn" then
            local props = p.properties or {}
            local age = tonumber(props.age) or 1
            if age < 6 and not props.mega_neon then count = count + 1 end
        end
    end
    return count
end

local function FindLeverMachine()
    local found
    pcall(function()
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("Model") or desc:IsA("BasePart") then
                local n = string.lower(desc.Name)
                if string.find(n, "lightning") and string.find(n, "lever") then
                    local part = desc:IsA("BasePart") and desc or (desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart", true))
                    if part then found = { node = desc, part = part }; break end
                end
            end
        end
    end)
    return found
end

local function DoSkelicorn()
    local candy = GetCandyCount()
    local price = GetSkelicornPrice()
    local maxGrowing = (PetPenSlots or 4) + 1
    local growing = GetGrowingSkelicorns()

    if growing >= maxGrowing then
        SetStatus("Skelicorn: " .. growing .. " growing (max " .. maxGrowing .. ")")
        return false
    end

    local leverUid = FindLeverInInventory()
    local machine = FindLeverMachine()

    if leverUid and machine and not SkelicornState.delivered then
        SetStatus("Skelicorn: installing lever...")
        if not TP("MainMap") then return false end
        task.wait(2)
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(machine.part.Position + Vector3.new(0, 5, 6))
            task.wait(0.5)
        end
        if API.Equip then pcall(function() API.Equip:InvokeServer(leverUid) end); task.wait(0.6) end
        local deliverRemote = GetHWR("Halloween2026/LightningLeverDeliver")
        if deliverRemote then
            pcall(function() deliverRemote:InvokeServer({}) end)
            SkelicornState.delivered = true
            SkelicornState.activated = true
            Notify("Skelicorn", "⚡ Lever installed!")
            task.wait(2)
        end
        return true
    end

    if candy >= price then
        SetStatus("Skelicorn: buying (" .. candy .. "/" .. price .. ")")
        local before = {}
        local inv = M.ClientData.get("inventory", "Raw") or {}
        for uid, p in pairs(inv.pets or {}) do
            if (p.kind or p.id) == "halloween_2026_skelicorn" then before[uid] = true end
        end
        local ok, reason = pcall(function() API.BuyItem:InvokeServer("pets", "halloween_2026_skelicorn", { buy_count = 1 }) end)
        task.wait(3)
        local inv2 = M.ClientData.get("inventory", "Raw") or {}
        local got = false
        for uid, p in pairs(inv2.pets or {}) do
            if (p.kind or p.id) == "halloween_2026_skelicorn" and not before[uid] then got = true; break end
        end
        if got then
            SkelicornState.bought = true
            Notify("Skelicorn", "🦄 Skelicorn bought!")
            PlaySound("success", 0.7)
        else
            SkelicornState.buyRefusedAt = tick()
            SkelicornState.leverRequired = true
            SetStatus("Skelicorn: shop refused, need lever")
        end
        return got
    end

    SetStatus("Skelicorn: waiting candy (" .. candy .. "/" .. price .. ")")
    return false
end

-- ══════════ PET PEN (from Yuno Hub v2 / Dusk & Shine) ══════════
local function GetPetPenData()
    return M.ClientData.get("idle_progression_manager")
end

local function GetPenActivePets()
    local ipm = GetPetPenData()
    if not ipm or not ipm.active_pets then return {} end
    local list = {}
    for uid, data in pairs(ipm.active_pets) do
        table.insert(list, { uid = uid, data = data })
    end
    return list
end

local function GetGrowablePets(excludeUIDs, kindsPriority)
    excludeUIDs = excludeUIDs or {}
    kindsPriority = kindsPriority or {}
    local inv = M.ClientData.get("inventory", "Raw") or {}
    local petPen = {}
    for _, p in ipairs(GetPenActivePets()) do petPen[p.uid] = true end
    local growables = {}
    for uid, p in pairs(inv.pets or {}) do
        if petPen[uid] or excludeUIDs[uid] then goto skip end
        local kind = p.kind or p.id
        if kind == "practice_dog" then goto skip end
        local db = M.InventoryDB and M.InventoryDB.pets and M.InventoryDB.pets[kind]
        if not db then goto skip end
        local props = p.properties or {}
        local age = tonumber(props.age) or 1
        local isEgg = db.is_egg == true
        local isNeon = props.neon or props.is_neon
        local isMega = props.mega_neon or props.is_mega
        if age < 6 and not isMega then
            table.insert(growables, {
                uid = uid, kind = kind, age = age, isEgg = isEgg, isNeon = isNeon,
                priority = kindsPriority[kind] or 100,
            })
        end
        ::skip::
    end
    table.sort(growables, function(a, b)
        if a.priority ~= b.priority then return a.priority < b.priority end
        return a.age > b.age
    end)
    return growables
end

local function DoPetPen()
    if not PetPenEnabled then return false end
    if not IsInHouse() then
        if not GoToHouse() then return false end
        task.wait(2)
    end
    local penPets = GetPenActivePets()
    local equipped = {}
    if M.ClientData then
        local eq = M.ClientData.get("equip_manager")
        if eq and eq.pets then for _, p in ipairs(eq.pets) do equipped[p.unique] = true end end
    end
    -- CLAIM first
    if #penPets > 0 or PetPenAutoLoot then
        SetStatus("PetPen: claiming...")
        if API.ClaimProgression then pcall(function() API.ClaimProgression:InvokeServer(true) end) end
        task.wait(2)
    end
    -- Remove full grown
    local removed = 0
    for _, p in ipairs(penPets) do
        local db = M.InventoryDB and M.InventoryDB.pets and M.InventoryDB.pets[p.data.item_info and p.data.item_info.kind]
        -- use max_age flag from server data
        if p.data.max_age == true or (db and db.is_egg == false and (p.data.item_info and (tonumber((p.data.item_info.properties or {}).age) or 0) >= 6)) then
            if API.RemovePet then
                pcall(function() API.RemovePet:InvokeServer(p.uid) end)
                removed = removed + 1
                task.wait(1.5)
            end
        end
    end
    if removed > 0 then Notify("PetPen", "🔄 Removed " .. removed .. " full grown") end
    -- Add growables
    local currentPen = GetPenActivePets()
    local slotsLeft = (PetPenSlots or 4) - #currentPen
    if slotsLeft > 0 then
        local priorityMap = {}
        for i, kind in ipairs(PetPenPriority) do priorityMap[kind] = i end
        local growables = GetGrowablePets(nil, priorityMap)
        local added = 0
        for _, g in ipairs(growables) do
            if slotsLeft <= 0 then break end
            if API.AddPet then
                pcall(function() API.AddPet:InvokeServer(g.uid) end)
                added = added + 1
                slotsLeft = slotsLeft - 1
                task.wait(1.5)
            end
        end
        if added > 0 then Notify("PetPen", "➕ Added " .. added .. " growing pets") end
    end
    return true
end

-- ══════════ AUTO LURE (from Dusk & Shine) ══════════
local function DoAutoLure()
    if not AutoLureEnabled then return false end
    -- Check ghost event first
    local gts = M.ClientData.get("ghost_clusters_cycle_timestamp")
    if HalloweenGhost and gts and gts.timestamp then
        local remain = gts.timestamp - os.time()
        if remain < 50 and remain > -120 then
            LureStatus = "Paused: Ghost Event"
            return false
        end
    end
    if not IsInHouse() then
        LureStatus = "Going home..."
        if not GoToHouse() then LureStatus = "Failed"; return false end
        task.wait(2)
    end
    LureStatus = "Checking lures..."
    local lures = M.ClientData.get("lures_2023_lure_manager")
    local hasCozyPass = false
    local gp = M.ClientData.get("gamepass_manager")
    if type(gp) == "table" then
        for k, v in pairs(gp) do
            if v == "lures_2023_cozy_home_lure" or k == "lures_2023_cozy_home_lure" then hasCozyPass = true; break end
        end
    end
    local targetLures = { { id = "lures_2023_normal_lure", mapName = "BasicLure" } }
    if hasCozyPass then table.insert(targetLures, { id = "lures_2023_cozy_home_lure", mapName = "PremiumLure" }) end
    if not lures or not lures.lures_map then LureStatus = "No lure data"; return false end
    for _, target in ipairs(targetLures) do
        local lm = lures.lures_map[target.mapName]
        if not lm then
            LureStatus = "Buying " .. target.mapName
            if API.BuyFurnitures then
                pcall(function() API.BuyFurnitures:InvokeServer({ { kind = target.id, properties = { cframe = CFrame.new(0, 3, 0) } } }) end)
                task.wait(2)
            end
        elseif lm.finished then
            LureStatus = "Collecting " .. target.mapName
            -- find furniture id
            local hi = Workspace:FindFirstChild("HouseInteriors")
            local furn = hi and hi:FindFirstChild("furniture")
            local myName = LP.Name .. "/"
            if furn then
                for _, v in ipairs(furn:GetChildren()) do
                    if string.sub(v.Name, 1, #myName) == myName then
                        local model = v:FindFirstChildWhichIsA("Model")
                        if model and model.Name == target.id:gsub("lures_2023_", ""):gsub("_lure", "") then
                            local parts = string.split(v.Name, "true/")
                            local fid = parts[2]
                            if fid and API.ActivateFurniture then
                                pcall(function() API.ActivateFurniture:InvokeServer(LP, fid, "UseBlock", false, LP.Character) end)
                                task.wait(1.5)
                            end
                        end
                    end
                end
            end
        else
            -- needs charge
            if LureBaitSelection then
                local baitUID
                local inv = M.ClientData.get("inventory", "Raw") or {}
                for uid, item in pairs(inv.food or {}) do
                    if tostring(item.kind or item.id) == LureBaitSelection then baitUID = uid; break end
                end
                if baitUID then
                    LureStatus = "Charging " .. target.mapName
                    local startTs = lm.lure_start_timestamp or lm.start_timestamp or 0
                    if startTs == 0 or (startTs + 14400 <= os.time()) then
                        -- need to charge
                        local hi = Workspace:FindFirstChild("HouseInteriors")
                        local furn = hi and hi:FindFirstChild("furniture")
                        if furn then
                            for _, v in ipairs(furn:GetChildren()) do
                                local model = v:FindFirstChildWhichIsA("Model")
                                if model and string.find(string.lower(model.Name), target.id:gsub("lures_2023_", ""):gsub("_lure", "")) then
                                    local parts = string.split(v.Name, "true/")
                                    local fid = parts[2]
                                    if fid and API.ActivateFurniture then
                                        pcall(function() API.ActivateFurniture:InvokeServer(LP, fid, "UseBlock", { bait_unique = baitUID }, LP.Character) end)
                                        task.wait(1.5)
                                    end
                                    break
                                end
                            end
                        end
                    end
                else
                    LureStatus = "No bait: " .. tostring(LureBaitSelection)
                end
            else
                LureStatus = "No bait selected"
                AutoLureEnabled = false
            end
        end
    end
    return true
end

-- ══════════ TRADE CALCULATOR (from Dusk & Shine) ══════════
local function LoadTradeValues()
    local url = "https://duskandshine.com/raw/values/"
    local files = { ["Starpets (Beta)"] = "starpets.json", ["Elvebredd (Beta)"] = "elvebredd.json", ["AMVGG (Beta)"] = "amvgg.json" }
    for name, file in pairs(files) do
        if not TradeValuesReady[name] then
            task.spawn(function()
                local cacheFile = "YunoFarm/Values/" .. string.gsub(name, "[^%w]", "") .. ".json"
                local cacheTimeFile = "YunoFarm/Values/" .. string.gsub(name, "[^%w]", "") .. "_time.txt"
                local function readCache()
                    if isfile(cacheFile) and isfile(cacheTimeFile) then
                        local t = tonumber(readfile(cacheTimeFile)) or 0
                        if os.time() - t < 3600 then
                            local ok, data = pcall(function() return HttpService:JSONDecode(readfile(cacheFile)) end)
                            if ok and type(data) == "table" then return data end
                        end
                    end
                    return nil
                end
                local cached = readCache()
                if cached then
                    TradeValuesCache[name] = cached; TradeValuesReady[name] = true
                    return
                end
                local ok, raw = pcall(function() return game:HttpGet(url .. file) end)
                if ok and raw and #raw > 10 then
                    local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
                    if ok2 and type(data) == "table" then
                        TradeValuesCache[name] = data; TradeValuesReady[name] = true
                        pcall(function()
                            writefile(cacheFile, HttpService:JSONEncode(data))
                            writefile(cacheTimeFile, tostring(os.time()))
                        end)
                    end
                end
            end)
        end
    end
end

local function GetTradeItemValue(kind, props)
    if not kind then return 0, "N/A" end
    props = props or {}
    local valueType = TradeValueType
    if valueType == "None" or not TradeValuesReady[valueType] then return 0, "N/A" end
    local db = TradeValuesCache[valueType]
    if not db then return 0, "N/A" end
    local name = GetItemName(kind)
    local function norm(s) return string.lower(tostring(s)):gsub("[%s%-_]+", "") end
    local n = norm(name)
    local entry = db[n] or db[kind]
    if type(entry) ~= "table" then
        -- fuzzy
        for k, v in pairs(db) do
            if norm(k) == n then entry = v; break end
        end
    end
    if type(entry) ~= "table" then return 0, "N/A" end
    local isMega = props.mega_neon or props.is_mega
    local isNeon = props.neon or props.is_neon
    local isFly = props.flyable or props.is_flyable
    local isRide = props.rideable or props.is_rideable
    local val = 0
    if valueType == "Elvebredd (Beta)" then
        local key = isMega and "m" or (isNeon and "n" or "r")
        local key2 = isFly and isRide and "fr" or (isFly and "f" or (isRide and "r" or "none"))
        if entry.val and entry.val[key] then
            val = tonumber(entry.val[key][key2] or entry.val[key].none or entry.val[key].main) or 0
        end
    else
        if entry.standard and entry.standard.price then
            val = tonumber(entry.standard.price) or 0
        else
            local tier = isMega and "mega_neon" or (isNeon and "neon" or "regular")
            local stage = isNeon and "reborn" or "newborn"
            local f = isFly and "True" or "False"
            local r = isRide and "True" or "False"
            local fullKey = tier .. "_" .. f .. "_" .. r .. "_" .. stage
            if entry[fullKey] and entry[fullKey].price then val = tonumber(entry[fullKey].price) or 0
            else
                for k, v in pairs(entry) do
                    if type(v) == "table" and v.price and string.match(k, "^" .. tier) then
                        val = tonumber(v.price) or 0; break
                    end
                end
            end
        end
    end
    return val, entry.demand or "N/A"
end

-- ══════════ PET UNSTACK (from Dusk & Shine) ══════════
local function InstallPetUnstack()
    local realGet = M.ClientData.get
    local cache = nil
    M.ClientData.get = function(self, key, sub, ...)
        local result = realGet(self, key, sub, ...)
        if key == "inventory" and sub ~= "Raw" and type(result) == "table" and result.pets and getgenv().YunoUnstack then
            local unstacked = {}
            local seen = {}
            local zeroWidth = utf8.char(8203)
            for uid, pet in pairs(result.pets) do
                local kind = tostring(pet.kind or pet.id)
                seen[kind] = (seen[kind] or 0) + 1
                if seen[kind] > 1 then
                    local clone = {}
                    for k, v in pairs(pet) do clone[k] = v end
                    local props = {}
                    for k, v in pairs(pet.properties or {}) do props[k] = v end
                    props.rp_name = "yuno" .. string.rep(zeroWidth, seen[kind] - 1)
                    clone.properties = props
                    unstacked[uid] = clone
                else
                    unstacked[uid] = pet
                end
            end
            local copy = {}
            for k, v in pairs(result) do copy[k] = v end
            copy.pets = unstacked
            return copy
        end
        return result
    end
end

-- ══════════ VISUALS ══════════
local VisualParts = {}
local RAINBOW = {
    Color3.fromRGB(255, 72, 69), Color3.fromRGB(255, 96, 93), Color3.fromRGB(245, 255, 99),
    Color3.fromRGB(149, 255, 79), Color3.fromRGB(73, 255, 82), Color3.fromRGB(80, 255, 159),
    Color3.fromRGB(78, 47, 255), Color3.fromRGB(160, 97, 255), Color3.fromRGB(255, 97, 189),
}

local function RefreshPetVisuals()
    table.clear(VisualParts)
    if not M.ClientData or not M.InventoryDB then return end
    for _, w in pairs(M.ClientData.get("pet_char_wrappers") or {}) do
        if (w.player == LP or tostring(w.player) == LP.Name) and w.char then
            local s = SavedPetVisuals[w.pet_unique]
            if s then
                local model = w.char:FindFirstChild("PetModel") or w.char
                local db = M.InventoryDB.pets[w.pet_id]
                if db and (s.Mega or s.Neon) then
                    local parts = s.Mega and (db.mega_neon_parts or db.neon_parts) or db.neon_parts or {}
                    for k, v in pairs(parts) do
                        local pn = type(k) == "string" and k or v
                        for _, desc in ipairs(model:GetDescendants()) do
                            if desc:IsA("BasePart") and desc.Name == pn then
                                table.insert(VisualParts, { Part = desc, IsMega = s.Mega, Color = s.CustomColorOn and PetVisCustomColor or (db.neon_color or Color3.new(1,1,1)) })
                                pcall(function()
                                    if desc:IsA("MeshPart") and desc.TextureID ~= "" then desc.TextureID = "" end
                                    desc.Material = Enum.Material.Neon
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end

task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if #VisualParts == 0 then return end
        local t = tick() * 2
        local idx = math.floor(t % #RAINBOW) + 1
        local c = RAINBOW[idx]:Lerp(RAINBOW[idx % #RAINBOW + 1], t % 1)
        for _, v in ipairs(VisualParts) do
            if v.Part and v.Part.Parent then
                v.Part.Material = Enum.Material.Neon
                v.Part.Transparency = 0
                v.Part.Color = v.IsMega and c or v.Color
            end
        end
    end)
end)

do
    local realGet = M.ClientData.get
    M.ClientData.get = function(self, key, sub, ...)
        local res = realGet(self, key, sub, ...)
        if key == "inventory" and sub ~= "Raw" and type(res) == "table" and res.pets and next(SavedPetVisuals) then
            local newPets = {}
            for uid, pet in pairs(res.pets) do
                local s = SavedPetVisuals[uid]
                if s then
                    local clone = {}
                    for k, v in pairs(pet) do clone[k] = v end
                    local props = {}
                    for k, v in pairs(pet.properties or {}) do props[k] = v end
                    props.neon = s.Neon; props.mega_neon = s.Mega
                    props.flyable = s.Fly; props.is_flyable = s.Fly
                    props.rideable = s.Ride; props.is_rideable = s.Ride
                    clone.properties = props
                    newPets[uid] = clone
                else newPets[uid] = pet end
            end
            local c = {}; for k, v in pairs(res) do c[k] = v end; c.pets = newPets
            return c
        end
        return res
    end
end

-- ══════════ SWF/HATCH/AGEPOT/FASTMEGA ══════════
local function GetMaxSlots()
    if not M.ClientData then return 1 end
    local data = M.ClientData.get_data() or {}
    local pd = data[LP.Name] or {}
    local sub = data.subscription_manager or pd.subscription_manager
    if sub and sub.equip_2x_pets then
        local s = tostring(sub.equip_2x_pets.state):lower()
        if s ~= "neversubscribed" and s ~= "expired" and s ~= "canceled" then return 2 end
    end
    return 1
end

local function GetLockedUIDs()
    if not M.ClientData then return {} end
    local data = M.ClientData.get_data() or {}
    local pd = data[LP.Name] or {}
    local ipm = data.idle_progression_manager or pd.idle_progression_manager
    local locked = {}
    if ipm and ipm.active_pets then for uid in pairs(ipm.active_pets) do locked[uid] = true end end
    return locked
end

local function ProcessSWFQueue()
    if not SWFEnabled or not M.ClientData or not M.InventoryDB then return end
    local data = M.ClientData.get_data() or {}
    local pd = data[LP.Name] or {}
    local inv = data.inventory or pd.inventory or M.ClientData.get("inventory")
    if not inv or not inv.pets then return end
    local eq = data.equip_manager or pd.equip_manager
    local maxSlots = GetMaxSlots()
    local locked = GetLockedUIDs()
    local activePets = eq and eq.pets or {}
    local activeUIDs = {}
    for _, p in ipairs(activePets) do activeUIDs[p.unique] = true end
    local validByKind = {}
    for uid, p in pairs(inv.pets) do
        if not locked[uid] then
            local k = p.kind or p.id
            if SWFTargets[k] then
                local db = M.InventoryDB.pets[k]
                if db and not db.is_egg then
                    local pr = p.properties or {}
                    local isM, isN = pr.mega_neon or pr.is_mega, pr.neon or pr.is_neon
                    local age = tonumber(pr.age) or 1
                    if not isM and age < 6 then
                        if (SwfMode == "Neon" and isN) or (SwfMode == "Regular" and not isN) then
                            validByKind[k] = validByKind[k] or {}
                            table.insert(validByKind[k], { uid = uid, age = age })
                        end
                    end
                end
            end
        end
    end
    for _, list in pairs(validByKind) do table.sort(list, function(a,b) return a.age > b.age end) end
    local sorted = {}
    for k in pairs(validByKind) do table.insert(sorted, k) end
    table.sort(sorted)
    local ideal, used = {}, {}
    for _, ap in ipairs(activePets) do
        for _, k in ipairs(sorted) do
            if used[k] and SwfSplitMode then break end
            for _, p in ipairs(validByKind[k]) do
                if p.uid == ap.unique then table.insert(ideal, ap.unique); used[k] = true; break end
            end
            if #ideal >= maxSlots then break end
        end
        if #ideal >= maxSlots then break end
    end
    if #ideal < maxSlots then
        for _, k in ipairs(sorted) do
            if not (SwfSplitMode and used[k]) then
                for _, p in ipairs(validByKind[k]) do
                    if not table.find(ideal, p.uid) then table.insert(ideal, p.uid); used[k] = true; break end
                end
            end
            if #ideal >= maxSlots then break end
        end
    end
    if #ideal == 0 then return end
    local needsSwap = #ideal ~= #activePets
    if not needsSwap then for _, uid in ipairs(ideal) do if not activeUIDs[uid] then needsSwap = true; break end end end
    if needsSwap then
        for _, ap in ipairs(activePets) do
            if not table.find(ideal, ap.unique) and API.Unequip then pcall(function() API.Unequip:InvokeServer(ap.unique) end); task.wait(1.5) end
        end
        for _, uid in ipairs(ideal) do
            if not activeUIDs[uid] and API.Equip then pcall(function() API.Equip:InvokeServer(uid, { equip_as_last = true }) end); task.wait(1.5) end
        end
    end
end

local function ProcessHatchQueue()
    if not AutoHatch or not M.ClientData or not M.InventoryDB then return end
    local data = M.ClientData.get_data() or {}
    local pd = data[LP.Name] or {}
    local inv = data.inventory or pd.inventory or M.ClientData.get("inventory")
    if not inv or not inv.pets then return end
    local eq = data.equip_manager or pd.equip_manager
    local maxSlots = GetMaxSlots()
    local locked = GetLockedUIDs()
    local activePets = eq and eq.pets or {}
    local activeUIDs = {}
    for _, p in ipairs(activePets) do activeUIDs[p.unique] = true end
    local available, total = {}, 0
    for uid, p in pairs(inv.pets) do
        if not locked[uid] then
            local k = p.kind or p.id
            local db = M.InventoryDB.pets[k]
            if db and db.is_egg then
                local lim = HatchLimits[k] or 0
                local hat = HatchedSessionCounts[k] or 0
                if lim == 0 or hat < lim then
                    available[k] = available[k] or {}
                    table.insert(available[k], uid); total = total + 1
                end
            end
        end
    end
    if total == 0 then AutoHatch = false; table.clear(ActiveHatchUIDs); return end
    for _, l in pairs(available) do table.sort(l) end
    local ideal = {}
    for _, ap in ipairs(activePets) do
        for k, l in pairs(available) do
            if table.find(l, ap.unique) then
                if #HatchPriority == 0 or table.find(HatchPriority, k) then table.insert(ideal, ap.unique); break end
            end
        end
        if #ideal >= maxSlots then break end
    end
    if #ideal == 0 then
        for _, l in pairs(available) do for _, uid in ipairs(l) do
            if not table.find(ideal, uid) then table.insert(ideal, uid); if #ideal >= maxSlots then break end end
        end; if #ideal >= maxSlots then break end end
    end
    local needsSwap = #ideal ~= #activePets
    if not needsSwap then for _, uid in ipairs(ideal) do if not activeUIDs[uid] then needsSwap = true; break end end end
    if needsSwap and #ideal > 0 then
        table.clear(ActiveHatchUIDs)
        for _, ap in ipairs(activePets) do
            if not table.find(ideal, ap.unique) and API.Unequip then pcall(function() API.Unequip:InvokeServer(ap.unique) end); task.wait(1.5) end
        end
        for i, uid in ipairs(ideal) do
            if inv.pets[uid] then ActiveHatchUIDs[uid] = inv.pets[uid].kind or inv.pets[uid].id end
            if not activeUIDs[uid] and API.Equip then
                pcall(function() API.Equip:InvokeServer(uid, { equip_as_last = (i > 1) }) end); task.wait(1.5)
            end
        end
    end
end

local function ProcessAgePotQueue()
    if not AutoAgePot and not (FastMegaTimer > os.time()) then return end
    if not M.ClientData or not M.InventoryDB then return end
    local data = M.ClientData.get_data() or {}
    local pd = data[LP.Name] or {}
    local inv = data.inventory or pd.inventory or M.ClientData.get("inventory")
    if not inv or not inv.pets then return end
    local eq = data.equip_manager or pd.equip_manager
    local maxSlots = GetMaxSlots()
    local locked = GetLockedUIDs()
    local activePets = eq and eq.pets or {}
    local activeUIDs = {}
    for _, p in ipairs(activePets) do activeUIDs[p.unique] = true end
    local ideal = {}
    for _, ap in ipairs(activePets) do
        if inv.pets[ap.unique] then
            local k = inv.pets[ap.unique].kind or inv.pets[ap.unique].id
            local db = M.InventoryDB.pets[k]
            if db and not db.is_egg then
                local pr = inv.pets[ap.unique].properties or {}
                if (pr.age or 1) == 6 and not (pr.neon or pr.mega_neon) then
                    table.insert(ideal, ap.unique); if #ideal >= maxSlots then break end
                end
            end
        end
    end
    if #ideal < maxSlots then
        for uid, p in pairs(inv.pets) do
            if not locked[uid] and not table.find(ideal, uid) then
                local k = p.kind or p.id
                local db = M.InventoryDB.pets[k]
                if db and not db.is_egg then
                    local pr = p.properties or {}
                    if (pr.age or 1) == 6 and not (pr.neon or pr.mega_neon) then
                        table.insert(ideal, uid); if #ideal >= maxSlots then break end
                    end
                end
            end
        end
    end
    if #ideal == 0 then
        if FastMegaTimer > os.time() then FastMegaTimer = 0 end
        if AutoAgePot then AutoAgePot = false; Flags.YF_AgePot = false end
        return
    end
    local needsSwap = #ideal ~= #activePets
    if not needsSwap then for _, uid in ipairs(ideal) do if not activeUIDs[uid] then needsSwap = true; break end end end
    if needsSwap then
        for _, ap in ipairs(activePets) do
            if not table.find(ideal, ap.unique) and API.Unequip then pcall(function() API.Unequip:InvokeServer(ap.unique) end); task.wait(1.5) end
        end
        for _, uid in ipairs(ideal) do
            if not activeUIDs[uid] and API.Equip then pcall(function() API.Equip:InvokeServer(uid, { equip_as_last = true }) end); task.wait(3) end
        end
    end
end

local function ProcessFastMegaQueue()
    if not (FastMegaEnabled or FastMegaPipeline) then return end
    if not M.ClientData or not M.InventoryDB then return end
    local data = M.ClientData.get_data() or {}
    local pd = data[LP.Name] or {}
    local inv = data.inventory or pd.inventory or M.ClientData.get("inventory")
    if not inv or not inv.pets then return end
    local potCount = 0
    for _, f in pairs(inv.food or {}) do
        local id = f.id or f.kind
        if id == "pet_age_potion" or id == "age_potion" or id == "small_age_potion" then potCount = potCount + 1 end
    end
    if FastMegaFarmPots and potCount < 7 and FastMegaTimer == 0 then FastMegaTimer = os.time() + 3600 end
    if FastMegaTimer > os.time() then ProcessAgePotQueue(); return end
    if FastMegaTimer ~= 0 and FastMegaTimer <= os.time() then FastMegaTimer = 0 end
    local targetKinds = {}
    if FastMegaPipeline and FastMegaPipeMode == "All" then
        for _, p in pairs(inv.pets) do
            local k = p.kind or p.id
            local db = M.InventoryDB.pets[k]
            if db and not db.is_egg and not table.find(targetKinds, k) then table.insert(targetKinds, k) end
        end
    else for k, v in pairs(FastMegaTargets) do if v then table.insert(targetKinds, k) end end end
    local groups = {}
    for uid, p in pairs(inv.pets) do
        local k = p.kind or p.id
        if table.find(targetKinds, k) then
            local pr = p.properties or {}
            local age = pr.age or 1
            local isN = pr.neon or pr.is_neon
            local isM = pr.mega_neon or pr.is_mega
            if age == 6 and not isN and not isM then
                groups[k] = groups[k] or { regular = {}, neon = {} }
                table.insert(groups[k].regular, uid)
            elseif isN and not isM then
                groups[k] = groups[k] or { regular = {}, neon = {} }
                table.insert(groups[k].neon, uid)
            end
        end
    end
    if not API.DoNeonFusion then return end
    for k, g in pairs(groups) do
        if #g.regular >= 4 then
            pcall(function() API.DoNeonFusion:InvokeServer({ g.regular[1], g.regular[2], g.regular[3], g.regular[4] }) end)
            task.wait(4)
        elseif FastMegaMode == "Mega" and #g.neon >= 4 then
            pcall(function() API.DoNeonFusion:InvokeServer({ g.neon[1], g.neon[2], g.neon[3], g.neon[4] }) end)
            task.wait(4)
        end
    end
end

-- ══════════ POTION FEEDER (from Yuno Hub v2) ══════════
local function ProcessPotionFeeder()
    if not PotionFeederEnabled then return end
    if not API.CreatePetObject or not API.ConsumeFoodObject then return end
    local data = M.ClientData.get_data() or {}
    local pd = data[LP.Name] or {}
    local inv = pd.inventory or data.inventory or M.ClientData.get("inventory")
    if not inv or not inv.pets then return end
    local eq = data.equip_manager or pd.equip_manager
    local targetUid
    if FeederAutoSelectEquipped then
        targetUid = eq and eq.pets and eq.pets[1] and eq.pets[1].unique
    else
        -- pick from selected kinds
        local priority = {}
        for kind in pairs(FeederSelectedPotions or {}) do
            for uid, pet in pairs(inv.pets) do
                local kind2 = pet.kind or pet.id
                if kind2 == kind or (pet.properties and pet.properties.age and pet.properties.age < 6) then
                    -- just pick any growing pet from selected kinds
                end
            end
        end
        for uid, pet in pairs(inv.pets) do
            local pr = pet.properties or {}
            local age = tonumber(pr.age) or 1
            if age < 6 and not pr.mega_neon then targetUid = uid; break end
        end
    end
    if not targetUid then return end
    local petData = inv.pets[targetUid]
    if not petData then return end
    local pr = petData.properties or {}
    local age = tonumber(pr.age) or 1
    if FeederUntilFG and age >= 6 then return end
    for uid, food in pairs(inv.food or {}) do
        local k = food.kind or food.id
        if FeederSelectedPotions[k] then
            local cd = FeederCooldowns[uid]
            if not cd or os.time() - cd > 600 then
                SetStatus("Feeder: " .. k)
                pcall(function()
                    local obj = API.CreatePetObject:InvokeServer("__Enum_PetObjectCreatorType_2", { pet_unique = targetUid, unique_id = uid })
                    local model = obj and (obj:FindFirstChild("Model") or obj)
                    if not model then
                        local po = Workspace:FindFirstChild("PetObjects")
                        if po then for _, c in ipairs(po:GetChildren()) do
                            local iu = c:FindFirstChild("ItemUniqueId")
                            if iu and iu.Value == uid then model = c:FindFirstChild("Model") or c; break end
                        end end
                    end
                    if model then API.ConsumeFoodObject:FireServer(model, targetUid) end
                end)
                FeederCooldowns[uid] = os.time()
                FeederFedCount = FeederFedCount + 1
                task.wait(2)
                return
            end
        end
    end
end

-- ══════════ UTILITIES ══════════
local function ClearAllPetRPNames()
    if not M.ClientData or not API.SetPetRP then return Notify("RP Clear", "Remote not found") end
    local inv = M.ClientData.get("inventory", "Raw")
    if not inv or not inv.pets then return end
    local count = 0
    for uid, p in pairs(inv.pets) do
        local pr = p.properties or {}
        if pr.rp_name and pr.rp_name ~= "" then
            if API.Equip then pcall(function() API.Equip:InvokeServer(uid, { use_sound = false }) end); task.wait(0.15) end
            pcall(function() API.SetPetRP:InvokeServer(uid, "") end)
            count = count + 1
            task.wait(0.1)
        end
    end
    Notify("RP Clear", "Cleared " .. count .. " names")
end

local function DoAutoDailyReward()
    if not API.ClaimDailyReward then return false end
    if os.time() - LastDailyClaim < 3600 then return false end
    LastDailyClaim = os.time()
    pcall(function() API.ClaimDailyReward:InvokeServer() end)
    task.wait(1); return true
end

local FREE_FOODS = { "ham_vip", "water_vip", "chocolate_milk_vip", "popcorn_vip", "marshmallow_on_a_stick", "healing_apple", "teachers_apple" }
local function DoAutoFreeFood()
    if not API.BuyItem then return false end
    if os.time() - LastFreeFoodClaim < 300 then return false end
    LastFreeFoodClaim = os.time()
    for _, food in ipairs(FREE_FOODS) do
        pcall(function() API.BuyItem:InvokeServer("food", food, {}) end)
        task.wait(0.3)
    end
    return true
end

local function DoAutoQuestClaim()
    if not API.ClaimQuest then return false end
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return false end
    local qa = pg:FindFirstChild("QuestApp")
    if not qa then return false end
    local template = qa:FindFirstChild("QuestTemplate")
    if not template then return false end
    local qid = template:GetAttribute("QuestId")
    if qid then
        pcall(function() API.ClaimQuest:InvokeServer(tostring(qid)) end)
        task.wait(0.5); return true
    end
    return false
end

local function DoTradeLicense()
    if not API.BeginTradeQuiz or not API.AnswerQuiz then return false end
    SetStatus("License: starting...")
    pcall(function() API.BeginTradeQuiz:InvokeServer() end)
    task.wait(0.5)
    local found = false
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "question_index") then
                if v.quiz then
                    for _, q in pairs(v.quiz) do
                        if q.answer ~= nil then
                            pcall(function() API.AnswerQuiz:InvokeServer(q.answer) end)
                            found = true
                            task.wait(0.3)
                        end
                    end
                end
            end
        end
    end)
    if not found then
        for i = 1, 3 do pcall(function() API.AnswerQuiz:InvokeServer(true) end); task.wait(0.4) end
    end
    Notify("License", "Trade quiz done!")
    return true
end

local function DoAutoOpenGifts()
    if not API.OpenGift or not M.ClientData then return false end
    local inv = M.ClientData.get("inventory", "Raw")
    if not inv or not inv.gifts then return false end
    local any = false
    for uid in pairs(inv.gifts) do
        any = true
        if API.Equip then pcall(function() API.Equip:InvokeServer(uid) end); task.wait(0.4) end
        pcall(function() API.OpenGift:InvokeServer(uid) end)
        task.wait(0.6)
    end
    return any
end

local function DoAuto2DTuesdays()
    if not EventNet then return false end
    local dm = M.ClientData.get("dailies_manager")
    if not dm or not dm.serialized_tabs then return false end
    local tab = dm.serialized_tabs["2d_tuesdays"]
    if not tab then return false end
    local did = false
    if tab.active_dailies then
        local remote = EventNet:FindFirstChild("adoptme_new.modules.Dailies.DailiesNetService:9")
        if remote then
            for _, d in pairs(tab.active_dailies) do
                if d.state and d.state.steps_to_complete <= d.state.steps_completed then
                    pcall(function() remote:FireServer("2d_tuesdays") end)
                    did = true; task.wait(0.5)
                end
            end
        end
    end
    if tab.reward_claimed == false then
        local r2 = EventNet:FindFirstChild("adoptme_new.modules.Dailies.DailiesNetService:15")
        if r2 then pcall(function() r2:FireServer("2d_tuesdays") end); did = true end
    end
    return did
end

local function DoAutoHalloweenQuests()
    if not EventNet then return false end
    local dm = M.ClientData.get("dailies_manager")
    if not dm or not dm.serialized_tabs then return false end
    local tab = dm.serialized_tabs["halloween_2026"]
    if not tab then return false end
    local did = false
    if tab.active_dailies then
        local remote = EventNet:FindFirstChild("adoptme_new.modules.Dailies.DailiesNetService:9")
        if remote then
            for _, d in pairs(tab.active_dailies) do
                if d.state and d.state.steps_to_complete <= d.state.steps_completed then
                    pcall(function() remote:FireServer("halloween_2026") end)
                    did = true; task.wait(0.5)
                end
            end
        end
    end
    if tab.reward_claimed == false then
        local r2 = EventNet:FindFirstChild("adoptme_new.modules.Dailies.DailiesNetService:15")
        if r2 then pcall(function() r2:FireServer("halloween_2026") end); did = true end
    end
    return did
end

local function AddVisualBucks(amount)
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end
    local bia = pg:FindFirstChild("BucksIndicatorApp")
    if not bia then return end
    local ci = bia:FindFirstChild("CurrencyIndicator")
    if not ci then return end
    local c = ci:FindFirstChild("Container")
    local al = c and c:FindFirstChild("Amount")
    if al then
        local current = tonumber(string.gsub(al.Text, "%D", "")) or 0
        al.Text = tostring(current + amount)
    end
end

-- ══════════ MINI-GAMES ══════════
local ObbiesList = { "miniworld", "coastal_climb", "shipwreck_bay", "ancient_ruins", "lonelypeak", "pyramid", "tinyisles" }

local function DoAutoObbies()
    if not API.FinishObby then return false end
    SetStatus("Obbies: finishing...")
    for _, obby in ipairs(ObbiesList) do
        if not FarmEnabled then return false end
        if not ObbiesDone[obby] then
            pcall(function() API.FinishObby:FireServer(obby) end)
            ObbiesDone[obby] = true
            task.wait(0.5)
        end
    end
    PlaySound("success", 0.4)
    return true
end

local function DoSpleefMinigame()
    if Cac.CurrentLocation == "SpleefMinigame" then task.wait(30); return true end
    if not TP("SpleefMinigame") then return false end
    task.wait(5); return true
end

local function DoSimonSaysMinigame()
    if Cac.CurrentLocation == "SimonSaysMinigame" then task.wait(30); return true end
    if not TP("SimonSaysMinigame") then return false end
    task.wait(5); return true
end

local function DoWinterCastle()
    if Cac.CurrentLocation == "WinterCastle" then task.wait(30); return true end
    if not TP("WinterCastle") then return false end
    task.wait(5); return true
end

local function DoGhostGallery()
    if not API.ShootGhost then return false end
    local gc = Workspace:FindFirstChild("GhostGallery") or Workspace:FindFirstChild("ActiveGhosts")
    if not gc then return false end
    SetStatus("GhostGallery: shooting...")
    local count = 0
    for _, ghost in ipairs(gc:GetChildren()) do
        if ghost:IsA("BasePart") or ghost:FindFirstChild("HumanoidRootPart") then
            pcall(function() API.ShootGhost:FireServer(ghost.Name) end)
            count = count + 1
            task.wait(0.05)
        end
    end
    if count > 0 then SetStatus("GhostGallery: shot " .. count) end
    return count > 0
end

local function DoHauntedHouse()
    local hauntlet = Workspace:FindFirstChild("HauntletMinigame") or Workspace:FindFirstChild("Minigames")
    if not hauntlet then return false end
    local hrp = GetHRP()
    if not hrp then return false end
    SetStatus("HauntedHouse: finding door...")
    for _, zone in ipairs(hauntlet:GetChildren()) do
        local doorSet = zone:FindFirstChild("Doors") or zone:FindFirstChild("Gates")
        if doorSet then
            for _, door in ipairs(doorSet:GetChildren()) do
                if door:IsA("BasePart") then
                    local isTrap = door:GetAttribute("Trap") or door:GetAttribute("IsFake")
                    if isTrap == false or door.Transparency > 0 then
                        hrp.CFrame = door.CFrame
                        task.wait(0.3)
                        break
                    end
                end
            end
        end
    end
    return true
end

local function DoStitchesSpot()
    local eventMap = Workspace:FindFirstChild("StitchesSpotlight") or Workspace:FindFirstChild("SpotlightGame")
    if not eventMap then return false end
    local candyDrops = eventMap:FindFirstChild("CandyCornDrops") or eventMap:FindFirstChild("Drops")
    local lights = eventMap:FindFirstChild("ActiveSpotlights") or Workspace:FindFirstChild("Spotlights")
    if not candyDrops then return false end
    local hrp = GetHRP()
    if not hrp then return false end
    SetStatus("Stitches: collecting safe candy...")
    local collected = 0
    for _, candy in ipairs(candyDrops:GetChildren()) do
        if candy:IsA("BasePart") then
            local safe = true
            if lights then
                for _, beam in ipairs(lights:GetChildren()) do
                    if beam:IsA("BasePart") and (candy.Position - beam.Position).Magnitude < 15 then
                        safe = false; break
                    end
                end
            end
            if safe then
                hrp.CFrame = candy.CFrame + Vector3.new(0, 3, 0)
                collected = collected + 1
                task.wait(0.1)
            end
        end
    end
    if collected > 0 then SetStatus("Stitches: " .. collected .. " candies") end
    return collected > 0
end

-- ══════════ MAIN LOOP ══════════
task.spawn(function()
    while task.wait(2) do
        if not FarmEnabled then SetStatus("Farm OFF"); continue end
        if not PetFarmEnabled and not BabyFarmEnabled then SetStatus("No modes"); continue end
        local ok, err = pcall(function()
            local t = GetFarmTargets()
            local b, pets = t.Baby, t.Pets
            local function has(k)
                if b[k] then return true end
                for _, p in ipairs(pets) do if p.needs[k] then return true end end
                return false
            end
            local priorities = {
                { "mystery",    function() return DoMysteryTask() end },
                { "misery",     function() return DoMysteryTask() end },
                { "pet_me",     function() return DoPetMeTask() end },
                { "camping",    function() return DoQuestTask("camping", "MainMap", "Camping") end },
                { "bored",      function() return DoQuestTask("bored", "MainMap", "Playground") end },
                { "beach_party",function() return DoQuestTask("beach_party", "MainMap", "Beach") end },
                { "pool_party", function() return DoPoolPartyTask() end },
                { "adoption_party", function() return DoQuestTask("adoption_party", "Nursery") end },
                { "salon",      function() return DoQuestTask("salon", "Salon") end },
                { "school",     function() return DoQuestTask("school", "School") end },
                { "pizza_party",function() return DoQuestTask("pizza_party", "PizzaShop") end },
                { "cat_cafe",   function() return DoQuestTask("cat_cafe", "CatCafe") end },
                { "sick",       function() return DoSickTask() end },
                { "play",       function() return DoPlayTask() end },
                { "hungry",     function() return DoFeedTask("hungry") end },
                { "thirsty",    function() return DoFeedTask("thirsty") end },
                { "walk",       function() return DoWalkTask() end },
                { "ride",       function() return DoRideTask() end },
                { "dirty",      function() return DoSleepDirtyTask("dirty") end },
                { "sleepy",     function() return DoSleepDirtyTask("sleepy") end },
                { "toilet",     function() return DoToiletTask() end },
            }
            for _, e in ipairs(priorities) do
                if has(e[1]) then
                    if CanTry(e[1]) then
                        SetStatus(e[1] .. "...")
                        local ok2 = RunTaskWithTimeout(e[1], e[2], 90)
                        if ok2 then ClearFailure(e[1]) end
                    else
                        local f = TaskFailures[e[1]]
                        local s = f and math.max(0, math.floor(30 - (tick() - f.time))) or 30
                        SetStatus(e[1] .. " retry " .. s .. "s")
                    end
                    return
                end
            end
            SetStatus("Idle " .. DebugInfo.Pets .. "p " .. DebugInfo.BabyNeeds .. "b")
        end)
        if not ok then SetStatus("Error: " .. tostring(err)) end
    end
end)

-- Halloween Loop
task.spawn(function()
    while task.wait(15) do
        if not HalloweenEnabled then continue end
        if not RS:FindFirstChild("adoptme_new_net") then continue end
        pcall(function()
            if HalloweenCandy then DoHalloweenCandy() end
            if HalloweenTwigs then DoHalloweenTwigs() end
            if HalloweenCrypt then DoHalloweenCrypt() end
            if HalloweenGhost then DoHalloweenGhost() end
            if HalloweenSkelicorn then DoSkelicorn() end
        end)
    end
end)

-- Pet Pen loop
task.spawn(function()
    while task.wait(30) do
        if not PetPenEnabled then continue end
        pcall(DoPetPen)
    end
end)

-- Auto Lure loop
task.spawn(function()
    while task.wait(5) do
        if not AutoLureEnabled then LureStatus = "Idle"; continue end
        pcall(DoAutoLure)
    end
end)

-- Util loops
task.spawn(function() while task.wait(3) do if FarmEnabled and AutoQuestClaim then pcall(DoAutoQuestClaim) end end end)
task.spawn(function() while task.wait(5) do if FarmEnabled and AutoOpenGifts then pcall(DoAutoOpenGifts) end end end)
task.spawn(function()
    while task.wait(30) do
        if not FarmEnabled then continue end
        pcall(function()
            if Auto2DTuesdays then DoAuto2DTuesdays() end
            if AutoHalloweenQuests then DoAutoHalloweenQuests() end
        end)
    end
end)
task.spawn(function()
    while task.wait(30) do
        if AutoDailyReward then pcall(DoAutoDailyReward) end
        if AutoFreeFood then pcall(DoAutoFreeFood) end
        if VisualBucksLoop then pcall(function() AddVisualBucks(VisualBucksAmount) end) end
        if AutoTradeLicense then pcall(DoTradeLicense) end
    end
end)
task.spawn(function()
    while task.wait(5) do
        if not MiniGamesEnabled or not FarmEnabled then continue end
        pcall(function()
            if AutoObbies and API.FinishObby then DoAutoObbies() end
            if AutoSpleef then DoSpleefMinigame() end
            if AutoSimonSays then DoSimonSaysMinigame() end
            if AutoWinterCastle then DoWinterCastle() end
            if AutoGhostGallery then DoGhostGallery() end
            if AutoHauntedHouse then DoHauntedHouse() end
            if AutoStitchesSpot then DoStitchesSpot() end
        end)
    end
end)
task.spawn(function()
    while task.wait(2.5) do
        if not FarmEnabled then continue end
        pcall(function()
            if AutoHatch then ProcessHatchQueue() end
            if SWFEnabled and not AutoHatch then ProcessSWFQueue() end
            if AutoAgePot then ProcessAgePotQueue() end
            if FastMegaEnabled or FastMegaPipeline then ProcessFastMegaQueue() end
            if PotionFeederEnabled then ProcessPotionFeeder() end
        end)
    end
end)

-- ══════════ TRADE ACCEPT LISTENER ══════════
task.spawn(function()
    local reqEvent = M.RouterClient.get_event("TradeAPI/TradeRequestReceived")
    if not reqEvent then return end
    reqEvent.OnClientEvent:Connect(function(senderPlayer, something, profileItems)
        if profileItems and type(profileItems) == "table" and ProtectProfileTrades then
            Notify("Trade", "⛔ Profile trade blocked from " .. tostring(senderPlayer))
            pcall(function()
                local apiFolder = RS:WaitForChild("API")
                apiFolder["TradeAPI/AcceptOrDeclineTradeRequest"]:InvokeServer(senderPlayer, false)
            end)
            return
        end
        if AutoAcceptTrades and senderPlayer then
            if AutoAcceptMode == "All" or tostring(senderPlayer) == TradeTargetPlayer then
                pcall(function()
                    local apiFolder = RS:WaitForChild("API")
                    apiFolder["TradeAPI/AcceptOrDeclineTradeRequest"]:InvokeServer(senderPlayer, true)
                end)
            end
        end
    end)
end)

-- Trade Calculator Loop
task.spawn(function()
    while task.wait(1) do
        if not TradeCalcEnabled then continue end
        pcall(function()
            local data = M.ClientData.get_data() or {}
            local pd = data[LP.Name] or {}
            local trade = pd.trade
            if not trade then return end
            -- just log values to status
            if trade.current_stage == "negotiation" then
                local senderOffer = trade.sender_offer and trade.sender_offer.player_name == LP.Name and trade.sender_offer or trade.recipient_offer
                local recipientOffer = trade.sender_offer and trade.sender_offer.player_name == LP.Name and trade.recipient_offer or trade.sender_offer
                local myVal, theirVal = 0, 0
                if senderOffer and senderOffer.items then
                    for _, item in ipairs(senderOffer.items) do
                        local v = GetTradeItemValue(item.kind or item.id, item.properties)
                        myVal = myVal + v
                    end
                end
                if recipientOffer and recipientOffer.items then
                    for _, item in ipairs(recipientOffer.items) do
                        local v = GetTradeItemValue(item.kind or item.id, item.properties)
                        theirVal = theirVal + v
                    end
                end
                local diff = theirVal - myVal
                if diff > 0.01 then
                    SetStatus("Trade: WIN +" .. string.format("%.2f", diff))
                elseif diff < -0.01 then
                    SetStatus("Trade: LOSE " .. string.format("%.2f", diff))
                else
                    SetStatus("Trade: FAIR")
                end
            end
        end)
    end
end)

-- ══════════ BUILD TABS ══════════
AddTab("7733960981", "Home", function(page)
    Make("TextLabel", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "Yuno Farm v7.0", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = page })
    local sc = Make("Frame", { Size = UDim2.new(1, 0, 0, 120), BackgroundColor3 = Theme.Section, BackgroundTransparency = 0.3, Parent = page })
    Make("UICorner", { CornerRadius = UDim.new(0, 10), Parent = sc })
    local lbl = Make("TextLabel", { Size = UDim2.new(1, -30, 0, 20), Position = UDim2.new(0, 15, 0, 12), BackgroundTransparency = 1, Text = "Status: Idle", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = sc })
    Flags.__statusLbl = lbl
    local info = Make("TextLabel", { Size = UDim2.new(1, -30, 0, 16), Position = UDim2.new(0, 15, 0, 32), BackgroundTransparency = 1, Text = "-", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = sc })
    local loc = Make("TextLabel", { Size = UDim2.new(1, -30, 0, 16), Position = UDim2.new(0, 15, 0, 50), BackgroundTransparency = 1, Text = "-", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = sc })
    local info2 = Make("TextLabel", { Size = UDim2.new(1, -30, 0, 16), Position = UDim2.new(0, 15, 0, 68), BackgroundTransparency = 1, Text = "-", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = sc })
    Make("TextLabel", { Size = UDim2.new(1, -30, 0, 16), Position = UDim2.new(0, 15, 0, 86), BackgroundTransparency = 1, Text = "💡 RightCtrl = minimize", Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = sc })
    task.spawn(function()
        while task.wait(1) do
            if not sc.Parent then break end
            info.Text = string.format("🐾 %d pets • 🍼 %d baby • Lure: %s", DebugInfo.Pets, DebugInfo.BabyNeeds, LureStatus)
            loc.Text = "Loc: " .. tostring(Cac.CurrentLocation) .. " • Candy: " .. tostring(GetCandyCount())
            info2.Text = string.format("🎮 Mini: %s • 🎃 HW: %s • Trade: %s", MiniGamesEnabled and "ON" or "OFF", HalloweenEnabled and "ON" or "OFF", TradeCalcEnabled and TradeValueType or "OFF")
        end
    end)
    UI.Button(page, { Name = "🏠 Test: Enter House", Callback = function()
        local ok = GoToHouse()
        Notify("House", ok and "Entered!" or "Failed — rejoin")
    end })
    UI.Button(page, { Name = "🛏 Test: Find Beds", Callback = function()
        local beds = FindFurnitureID("sleepy")
        if #beds > 0 then Notify("Beds", #beds .. " found") else Notify("Beds", "❌ No beds!") end
    end })
    UI.Button(page, { Name = "🚿 Test: Find Showers", Callback = function()
        local sh = FindFurnitureID("dirty")
        if #sh > 0 then Notify("Showers", #sh .. " found") else Notify("Showers", "❌ No showers!") end
    end })
end)

AddTab("6908632622", "AutoFarm", function(page)
    UI.Section(page, "Master")
    UI.Toggle(page, { Name = "Farm Master", Flag = "YF_FarmMaster", Description = "Toggle all pet + baby farming", Callback = function(v) FarmEnabled = v end })
    UI.Toggle(page, { Name = "Pet Farm", Flag = "YF_PetFarm", Callback = function(v) PetFarmEnabled = v end })
    UI.Toggle(page, { Name = "Baby Farm", Flag = "YF_BabyFarm", Callback = function(v) BabyFarmEnabled = v end })
    UI.Section(page, "Tools")
    UI.Button(page, { Name = "🩹 Force Heal (Sick)", Callback = function()
        if API.HealWithDoctor then
            for i = 1, 5 do pcall(function() API.HealWithDoctor:FireServer() end); task.wait(0.5) end
            Notify("Sick", "Heal sent!")
        end
    end })
    UI.Button(page, { Name = "Reset Task Failures", Callback = function() TaskFailures = {}; Notify("Yuno", "Cleared") end })
    UI.Button(page, { Name = "Destroy Platform", Callback = function() if Cac.AilmentPlatform then Cac.AilmentPlatform:Destroy(); Cac.AilmentPlatform = nil end end })
end)

AddTab("128557027005598", "Advanced", function(page)
    UI.Section(page, "SWF")
    UI.Toggle(page, { Name = "SWF Enabled", Flag = "YF_SWF", Callback = function(v) SWFEnabled = v end })
    UI.Dropdown(page, { Name = "SWF Mode", Flag = "YF_SWFMode", Options = { "Regular", "Neon" }, Default = "Regular", Callback = function(v) SwfMode = v end })
    UI.Toggle(page, { Name = "Split Mode", Flag = "YF_SWFSplit", Callback = function(v) SwfSplitMode = v end })
    UI.Section(page, "Auto Hatch")
    UI.Toggle(page, { Name = "Auto Hatch Eggs", Flag = "YF_AutoHatch", Callback = function(v) AutoHatch = v end })
    UI.Section(page, "Age-Pot")
    UI.Toggle(page, { Name = "Auto Age-Pot Farm", Flag = "YF_AgePot", Callback = function(v) AutoAgePot = v end })
    UI.Section(page, "Fast Mega")
    UI.Toggle(page, { Name = "Fast Mega Enabled", Flag = "YF_FastMega", Callback = function(v) FastMegaEnabled = v end })
    UI.Toggle(page, { Name = "Fast Mega Pipeline", Flag = "YF_FastPipe", Callback = function(v) FastMegaPipeline = v end })
    UI.Dropdown(page, { Name = "Fast Mega Mode", Flag = "YF_FMMode", Options = { "Neon", "Mega" }, Default = "Neon", Callback = function(v) FastMegaMode = v end })
    UI.Toggle(page, { Name = "Farm Pots on Low", Flag = "YF_FarmPots", Callback = function(v) FastMegaFarmPots = v end })
end)

AddTab("13549782519", "Mini-Games", function(page)
    UI.Toggle(page, { Name = "Enable Mini-Games", Flag = "YF_MiniMaster", Callback = function(v) MiniGamesEnabled = v end })
    UI.Toggle(page, { Name = "Auto Obbies", Flag = "YF_AutoObbies", Callback = function(v) AutoObbies = v; if not v then ObbiesDone = {} end end })
    UI.Toggle(page, { Name = "Auto Spleef", Flag = "YF_Spleef", Callback = function(v) AutoSpleef = v end })
    UI.Toggle(page, { Name = "Auto Simon Says", Flag = "YF_SimonSays", Callback = function(v) AutoSimonSays = v end })
    UI.Toggle(page, { Name = "Auto Winter Castle", Flag = "YF_WinterCastle", Callback = function(v) AutoWinterCastle = v end })
    UI.Toggle(page, { Name = "Auto Ghost Gallery", Flag = "YF_GhostGallery", Callback = function(v) AutoGhostGallery = v end })
    UI.Toggle(page, { Name = "Auto Haunted House", Flag = "YF_HauntedHouse", Callback = function(v) AutoHauntedHouse = v end })
    UI.Toggle(page, { Name = "Auto Stitches Spotlight", Flag = "YF_StitchesSpot", Callback = function(v) AutoStitchesSpot = v end })
end)

-- ─── HALLOWEEN TAB (Enhanced) ───
AddTab("128544079472562", "Halloween", function(page)
    UI.Section(page, "Halloween Farm")
    UI.Toggle(page, { Name = "Enable Halloween", Flag = "YF_HWMaster", Callback = function(v) HalloweenEnabled = v; if v then ApplyTheme("Halloween") end end })
    UI.Toggle(page, { Name = "Auto Crypt", Flag = "YF_HWCrypt", Description = "Clé + coffres + Tomb Spider", Callback = function(v) HalloweenCrypt = v end })
    UI.Dropdown(page, { Name = "Crypt Mode", Flag = "YF_HWCryptMode", Options = { "Fast Spider", "All", "Twigs + Spider" }, Default = "Fast Spider", Callback = function(v) end })
    UI.Toggle(page, { Name = "Auto Twigs", Flag = "YF_HWTwigs", Callback = function(v) HalloweenTwigs = v end })
    UI.Toggle(page, { Name = "Auto Candy", Flag = "YF_HWCandy", Callback = function(v) HalloweenCandy = v end })
    UI.Toggle(page, { Name = "Auto Ghost Cluster", Flag = "YF_HWGhost", Callback = function(v) HalloweenGhost = v end })
    UI.Toggle(page, { Name = "Auto Skelicorn", Flag = "YF_HWSkelicorn", Description = "Lever + machine + buy 120k candy", Callback = function(v) HalloweenSkelicorn = v end })
    UI.Section(page, "Quick Actions")
    UI.Button(page, { Name = "🍬 Claim Candy Now", Callback = function() task.spawn(DoHalloweenCandy) end })
    UI.Button(page, { Name = "🪵 Place Twigs Now", Callback = function() task.spawn(DoHalloweenTwigs) end })
    UI.Button(page, { Name = "🕷 Enter Crypt Now", Callback = function() task.spawn(DoHalloweenCrypt) end })
    UI.Button(page, { Name = "👻 Ghost Cluster Now", Callback = function() task.spawn(DoHalloweenGhost) end })
    UI.Button(page, { Name = "🦄 Try Skelicorn Now", Callback = function() task.spawn(DoSkelicorn) end })
end)

-- ─── PET PEN TAB (New) ───
AddTab("128557027005598", "PetPen", function(page)
    UI.Section(page, "Auto Pet Pen")
    UI.Toggle(page, { Name = "Enable Pet Pen", Flag = "YF_PetPen", Description = "Auto manage pen (claim/remove/add)", Callback = function(v) PetPenEnabled = v end })
    UI.Slider(page, { Name = "Pen Slots", Flag = "YF_PetPenSlots", Min = 4, Max = 5, Default = 4, Callback = function(v) PetPenSlots = v end })
    UI.Toggle(page, { Name = "Auto Claim Bucks", Flag = "YF_PetPenLoot", Callback = function(v) PetPenAutoLoot = v end })
    UI.Slider(page, { Name = "Bucks Threshold", Flag = "YF_PetPenLootAmt", Min = 10, Max = 1500, Default = 50, Callback = function(v) PetPenLootAmount = v end })
    UI.Toggle(page, { Name = "Auto Claim XP", Flag = "YF_PetPenAgeUp", Callback = function(v) PetPenAutoAgeUp = v end })
    UI.Button(page, { Name = "🎯 Force Pet Pen Now", Callback = function() task.spawn(DoPetPen) end })
    UI.Section(page, "Priority Pet Selection (Enter pet kind IDs, comma sep)")
    local inputBg = Make("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Section, Parent = page })
    Make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = inputBg })
    local input = Make("TextBox", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = "e.g. halloween_2026_tomb_spider, red_panda", Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false, Parent = inputBg, TextColor3 = Theme.Text, PlaceholderColor3 = Theme.SubText })
    input.FocusLost:Connect(function()
        PetPenPriority = {}
        for kind in string.gmatch(input.Text, "[^,]+") do
            local k = kind:gsub("^%s+", ""):gsub("%s+$", "")
            if k ~= "" then table.insert(PetPenPriority, k) end
        end
        Notify("PetPen", "Priority set: " .. #PetPenPriority .. " kinds")
    end)
end)

-- ─── AUTO LURE TAB (New) ───
AddTab("135780702746673", "AutoLure", function(page)
    UI.Toggle(page, { Name = "Enable Auto Lure", Flag = "YF_AutoLure", Description = "Buy, place, charge, collect lures", Callback = function(v) AutoLureEnabled = v end })
    local baitBg = Make("Frame", { Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Theme.Section, Parent = page })
    Make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = baitBg })
    Make("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Bait Kind", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = baitBg })
    local baitInput = Make("TextBox", { Size = UDim2.new(0.45, -20, 0, 28), Position = UDim2.new(0.5, 10, 0.5, -14), BackgroundColor3 = Theme.Sidebar, Text = "", PlaceholderText = "e.g. popcorn", Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false, Parent = baitBg, TextColor3 = Theme.Text })
    Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = baitInput })
    baitInput.FocusLost:Connect(function() LureBaitSelection = baitInput.Text ~= "" and baitInput.Text or nil end)
    Make("TextLabel", { Size = UDim2.new(1, -30, 0, 16), Position = UDim2.new(0, 15, 0, 50), BackgroundTransparency = 1, Text = "Status: " .. LureStatus, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = page })
    UI.Button(page, { Name = "🏠 Force Run Once", Callback = function() task.spawn(DoAutoLure) end })
end)

-- ─── TRADE CALC TAB (New) ───
AddTab("9695309046", "TradeCalc", function(page)
    UI.Toggle(page, { Name = "Enable Trade Calculator", Flag = "YF_TradeCalc", Description = "Show W/F/L in trade window", Callback = function(v)
        TradeCalcEnabled = v
        if v then LoadTradeValues() end
    end })
    UI.Dropdown(page, { Name = "Values Source", Flag = "YF_TradeValues", Options = { "Starpets (Beta)", "Elvebredd (Beta)", "AMVGG (Beta)" }, Default = "Starpets (Beta)", Callback = function(v) TradeValueType = v; LoadTradeValues() end })
    UI.Toggle(page, { Name = "Show Demands", Flag = "YF_ShowDemands", Callback = function(v) ShowTradeDemands = v end })
    UI.Section(page, "Trade Settings")
    UI.Toggle(page, { Name = "Auto Accept Trades", Flag = "YF_AutoAccept", Callback = function(v) AutoAcceptTrades = v end })
    UI.Dropdown(page, { Name = "Accept Mode", Flag = "YF_AcceptMode", Options = { "Target", "All" }, Default = "Target", Callback = function(v) AutoAcceptMode = v end })
    local targetBg = Make("Frame", { Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Theme.Section, Parent = page })
    Make("UICorner", { CornerRadius = UDim.new(0, 8), Parent = targetBg })
    Make("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = "Target Player", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = targetBg })
    local targetInput = Make("TextBox", { Size = UDim2.new(0.45, -20, 0, 28), Position = UDim2.new(0.5, 10, 0.5, -14), BackgroundColor3 = Theme.Sidebar, Text = TradeTargetPlayer, PlaceholderText = "username", Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false, Parent = targetBg, TextColor3 = Theme.Text })
    Make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = targetInput })
    targetInput.FocusLost:Connect(function() TradeTargetPlayer = targetInput.Text end)
    UI.Toggle(page, { Name = "Only Accept With Gifts", Flag = "YF_OnlyGifts", Callback = function(v) AutoAcceptOnlyGifts = v end })
    UI.Toggle(page, { Name = "Add Food (Auto Refill)", Flag = "YF_AddFood", Callback = function(v) AutoAddFood = v end })
    UI.Toggle(page, { Name = "Protect Profile Trades", Flag = "YF_ProtectProfile", Default = true, Callback = function(v) ProtectProfileTrades = v end })
    UI.Section(page, "Quick Actions")
    UI.Button(page, { Name = "📜 Get Trade License", Callback = function() task.spawn(DoTradeLicense) end })
    UI.Button(page, { Name = "🔄 Reload Values DB", Callback = function() TradeValuesReady = {}; LoadTradeValues(); Notify("Values", "Reloading...") end })
end)

-- ─── UTILITIES TAB ───
AddTab("135780702746673", "Utilities", function(page)
    UI.Section(page, "Auto Claim")
    UI.Toggle(page, { Name = "Auto Quest Claim", Flag = "YF_AutoQuest", Callback = function(v) AutoQuestClaim = v end })
    UI.Toggle(page, { Name = "Auto 2D Tuesdays", Flag = "YF_Auto2D", Callback = function(v) Auto2DTuesdays = v end })
    UI.Toggle(page, { Name = "Auto Halloween Quests", Flag = "YF_AutoHW", Callback = function(v) AutoHalloweenQuests = v end })
    UI.Toggle(page, { Name = "Auto Open Gifts", Flag = "YF_AutoGifts", Callback = function(v) AutoOpenGifts = v end })
    UI.Toggle(page, { Name = "Auto Trade License", Flag = "YF_AutoLicense", Callback = function(v) AutoTradeLicense = v end })
    UI.Toggle(page, { Name = "Visual Bucks Loop", Flag = "YF_VisBucks", Callback = function(v) VisualBucksLoop = v end })
    UI.Section(page, "Pet Utilities")
    UI.Toggle(page, { Name = "Pet Unstack (inventory)", Flag = "YF_Unstack", Description = "Visually unstack duplicates", Callback = function(v) getgenv().YunoUnstack = v end })
    UI.Button(page, { Name = "🗑️ Clear All Pet RP Names", Callback = function() task.spawn(ClearAllPetRPNames) end })
    UI.Section(page, "Potion Feeder")
    UI.Toggle(page, { Name = "Potion Feeder", Flag = "YF_Feeder", Callback = function(v) PotionFeederEnabled = v end })
    UI.Toggle(page, { Name = "Auto Select Equipped", Flag = "YF_FeederEquip", Callback = function(v) FeederAutoSelectEquipped = v end })
    UI.Toggle(page, { Name = "Feed Until FullGrown", Flag = "YF_FeedFG", Default = true, Callback = function(v) FeederUntilFG = v end })
    UI.Toggle(page, { Name = "Feed Age Potion", Flag = "YF_PotAge", Callback = function(v) FeederSelectedPotions["pet_age_potion"] = v end })
    UI.Toggle(page, { Name = "Feed Tiny Age Potion", Flag = "YF_PotTiny", Callback = function(v) FeederSelectedPotions["tiny_pet_age_potion"] = v end })
    UI.Toggle(page, { Name = "Feed Small Age Potion", Flag = "YF_PotSmall", Callback = function(v) FeederSelectedPotions["small_age_potion"] = v end })
    UI.Toggle(page, { Name = "Feed Super Age Potion", Flag = "YF_PotSuper", Callback = function(v) FeederSelectedPotions["super_age_potion"] = v end })
end)

AddTab("128557027005598", "Visuals", function(page)
    UI.Toggle(page, { Name = "Mega Neon", Flag = "YF_VisMega", Callback = function(v) VisualVars.Mega = v; if v then VisualVars.Neon = false end; RefreshPetVisuals() end })
    UI.Toggle(page, { Name = "Neon", Flag = "YF_VisNeon", Callback = function(v) VisualVars.Neon = v; if v then VisualVars.Mega = false end; RefreshPetVisuals() end })
    UI.Toggle(page, { Name = "Fly", Flag = "YF_VisFly", Callback = function(v) VisualVars.Fly = v end })
    UI.Toggle(page, { Name = "Ride", Flag = "YF_VisRide", Callback = function(v) VisualVars.Ride = v end })
    UI.Toggle(page, { Name = "Apply to Eggs", Flag = "YF_VisEggs", Callback = function(v) VisualVars.Eggs = v end })
    UI.Section(page, "Apply")
    UI.Button(page, { Name = "Current Pet", Callback = function()
        if not M.ClientData then return end
        for _, w in pairs(M.ClientData.get("pet_char_wrappers") or {}) do
            if w.player == LP then
                SavedPetVisuals[w.pet_unique] = { Mega = VisualVars.Mega, Neon = VisualVars.Neon, Fly = VisualVars.Fly, Ride = VisualVars.Ride, Eggs = VisualVars.Eggs }
                break
            end
        end
        RefreshPetVisuals()
        pcall(function() M.ClientData.DataChangedEvent:Fire("inventory", M.ClientData.get("inventory")) end)
        Notify("Visuals", "Applied")
    end })
    UI.Button(page, { Name = "ALL Pets", Callback = function()
        if not M.ClientData then return end
        local inv = M.ClientData.get("inventory", "Raw")
        if inv and inv.pets then for uid in pairs(inv.pets) do
            SavedPetVisuals[uid] = { Mega = VisualVars.Mega, Neon = VisualVars.Neon, Fly = VisualVars.Fly, Ride = VisualVars.Ride, Eggs = VisualVars.Eggs }
        end end
        RefreshPetVisuals()
        pcall(function() M.ClientData.DataChangedEvent:Fire("inventory", M.ClientData.get("inventory")) end)
        Notify("Visuals", "All applied")
    end })
    UI.Button(page, { Name = "Reset", Callback = function()
        SavedPetVisuals = {}
        VisualVars = { Mega = false, Neon = false, Fly = false, Ride = false, Eggs = false, CustomColorOn = false }
        RefreshPetVisuals()
        if M.ClientData then pcall(function() M.ClientData.DataChangedEvent:Fire("inventory", M.ClientData.get("inventory")) end) end
        Notify("Visuals", "Reset")
    end })
end)

AddTab("135780702746673", "Shop", function(page)
    UI.Toggle(page, { Name = "Auto Daily Reward", Flag = "YF_AutoDaily", Callback = function(v) AutoDailyReward = v end })
    UI.Toggle(page, { Name = "Auto Free Food", Flag = "YF_AutoFreeFood", Callback = function(v) AutoFreeFood = v end })
    UI.Section(page, "Quick Buy")
    UI.Button(page, { Name = "🥚 Buy Cracked Egg", Callback = function()
        if API.BuyItem then pcall(function() API.BuyItem:InvokeServer("pets", "cracked_egg", { buy_count = 1 }) end); Notify("Shop", "Bought cracked egg") end
    end })
    UI.Button(page, { Name = "🦄 Buy Skelicorn (120k candy)", Callback = function()
        if API.BuyItem then pcall(function() API.BuyItem:InvokeServer("pets", "halloween_2026_skelicorn", { buy_count = 1 }) end); Notify("Shop", "Tried to buy skelicorn") end
    end })
end)

AddTab("7734053495", "Settings", function(page)
    UI.Dropdown(page, { Name = "Theme", Flag = "YF_Theme", Options = { "Yuno", "Dark", "Light", "Galaxy", "Emerald", "Halloween" }, Default = ThemeName, Callback = ApplyTheme })
    UI.Slider(page, { Name = "UI Scale %", Flag = "YF_Scale", Min = 40, Max = 150, Default = math.floor((getgenv().YunoScale or 1) * 100), Callback = function(v)
        getgenv().YunoScale = v / 100; mainScale.Scale = v / 100
    end })
    UI.Section(page, "Sound")
    UI.Toggle(page, { Name = "UI Sounds", Flag = "YF_SndUI", Default = true, Callback = function(v) SoundEnabled = v end })
    UI.Toggle(page, { Name = "Ambient Music", Flag = "YF_SndAmbient", Default = false, Callback = function(v)
        AmbientEnabled = v
        if v then PlaySound("ambient", 0.15) else local s = SoundCache["ambient"]; if s then s:Stop() end end
    end })
    UI.Section(page, "Performance")
    UI.Toggle(page, { Name = "Lower GFX on Unfocus", Flag = "YF_LowerGFX", Callback = function(v) LowerGraphicsWhenUnfocused = v end })
    UI.Button(page, { Name = "Destroy Script", Callback = function()
        if Cac.AilmentPlatform then Cac.AilmentPlatform:Destroy() end
        if screenGui then screenGui:Destroy() end
    end })
end)

-- ══════════ INIT ══════════
InstallPetUnstack()

if tabs[1] then tabs[1].btn.MouseButton1Click:Fire() end
mainFrame.Visible = true
mainScale.Scale = (getgenv().YunoScale or (IS_MOBILE and 0.62 or 1))

-- Window focus graphics
UIS.WindowFocusReleased:Connect(function()
    if LowerGraphicsWhenUnfocused then
        Lighting.GlobalShadows = false
        pcall(function() settings().Rendering.QualityLevel = 1 end)
    end
end)
UIS.WindowFocused:Connect(function()
    if LowerGraphicsWhenUnfocused then
        Lighting.GlobalShadows = true
        pcall(function() settings().Rendering.QualityLevel = 10 end)
    end
end)

-- Anti-stuck and ghost pet swapping
task.spawn(function()
    while task.wait(2) do
        if not FarmEnabled then TaskFailTrack.time = 0; continue end
        if not M.ClientData then continue end
        pcall(function()
            local data = M.ClientData.get_data() or {}
            local pd = data[LP.Name] or {}
            local eq = data.equip_manager or pd.equip_manager
            local wrappers = data.pet_char_wrappers or pd.pet_char_wrappers or M.ClientData.get("pet_char_wrappers") or {}
            if eq and eq.pets then
                local ghost = false
                for _, ap in ipairs(eq.pets) do
                    local has = false
                    for _, w in pairs(wrappers) do
                        if w.pet_unique == ap.unique and w.char and w.char.Parent then has = true; break end
                    end
                    if not has then
                        SetStatus("Ghost swap...")
                        if API.Unequip then pcall(function() API.Unequip:InvokeServer(ap.unique) end); task.wait(1.5) end
                        if API.Equip then pcall(function() API.Equip:InvokeServer(ap.unique, { equip_as_last = true }) end) end
                        ghost = true
                    end
                end
                if ghost then task.wait(2.5); return end
            end
            local targets = GetFarmTargets()
            local has = next(targets.Baby) or #targets.Pets > 0
            if not has then TaskFailTrack.time = 0
            elseif TaskFailTrack.time == 0 then TaskFailTrack.time = os.time()
            elseif os.time() - TaskFailTrack.time > 40 then
                SetStatus("Anti-Stuck!")
                if eq and eq.pets then
                    for _, ap in ipairs(eq.pets) do if API.Unequip then pcall(function() API.Unequip:InvokeServer(ap.unique) end) end end
                    task.wait(1.5)
                    for _, ap in ipairs(eq.pets) do if API.Equip then pcall(function() API.Equip:InvokeServer(ap.unique, { equip_as_last = true }) end) end end
                end
                TaskFailTrack.time = 0
            end
        end)
    end
end)

task.delay(1, function()
    Notify("Yuno Farm v7.0", "Enhanced Edition — Icons + Trade Calc + PetPen + Skelicorn", 6)
end)

print("═══════════════════════════════════════════")
print("[Yuno] ✅ v7.0 ENHANCED READY")
print("[Yuno] ✅ + PetPen avec priorité (fichier 2+3)")
print("[Yuno] ✅ + Auto Skelicorn (fichier 2)")
print("[Yuno] ✅ + Crypt avec plan intelligent (fichier 2)")
print("[Yuno] ✅ + Ghost Cluster amélioré (fichier 2)")
print("[Yuno] ✅ + Trade Value Calculator (fichier 3)")
print("[Yuno] ✅ + Icons via InventoryDB (fichier 3)")
print("[Yuno] ✅ + Auto Lure (fichier 3)")
print("[Yuno] ✅ + Pet Unstack (fichier 3)")
print("[Yuno] ✅ + Potion Feeder auto (fichier 2)")
print("═══════════════════════════════════════════")