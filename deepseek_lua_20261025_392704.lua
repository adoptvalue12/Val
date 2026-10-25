--[[
    YUNO FARM v7.0 - ULTIMATE FUSION
    ═══════════════════════════════════════════
    v6.3 : UI, thèmes, sons, dirty/sleep, Halloween de base, minigames, SWF, hatch, visuals
    + v2 : Farm engine COMPLET (pet_me, feed, play, mystery, furniture, walk, ride, location)
    + v2 : Hauntlet auto (joins, doors, items, squad)
    + v2 : Skelicorn auto (lever + buy 120k candy)
    + v2 : Pigeon nest (twigs + autoNest)
    + v2 : Pet Pen (claim, slots, stock)
    + v2 : Candy pets (pick & buy)
    + v2 : Crypt avancé (ladder, twig, lever priorities)
    + v2 : Quests (dailies + board reward)
    + v2 : House visits (visit quests)
    + v2 : Age potions on farmed pet
    + v2 : Auto Neon/Mega fusion
    + v2 : Buy Egg (auto when none grows)
    + v2 : Keep Pet Equipped (swap grown → growing)
    + v2 : Collect Cashback
    + v2 : Open Gifts & Chests
    + v2 : Mystery card handler (seeded, smarter)
    + v2 : Stray Cat (1 water/day)
    + v2 : Team switch (Babies)
    + v2 : Stuck recovery
    ═══════════════════════════════════════════
]]

print("═══════════════════════════════════════════")
print("[Yuno v7.0] 🚀 Ultimate Fusion starting...")
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
local vu = game:GetService("VirtualUser")
LP.Idled:Connect(function() vu:CaptureController() vu:ClickButton2(Vector2.new()) end)

-- ══════════ SOUNDS (v6.3) ══════════
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
        s = Instance.new("Sound"); s.SoundId = SOUND_IDS[name] or SOUND_IDS.click
        s.Looped = (name == "ambient"); s.Volume = 0
        s.Parent = CoreGui:FindFirstChild("YunoFarm_UI") or LP:WaitForChild("PlayerGui")
        SoundCache[name] = s
    end
    s.Volume = vol or (name == "ambient" and 0.15 or 0.4)
    s.PlaybackSpeed = pitch or 1
    pcall(function() if name ~= "ambient" then s:Play() else if not s.IsPlaying then s:Play() end end end)
end

-- ══════════ MODULES (v6.3 + extension) ══════════
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
}
if not M.RouterClient or not M.ClientData then warn("[Yuno] ❌ critical module missing"); return end

local AilmentsClient
pcall(function()
    AilmentsClient = require(RS:WaitForChild("new", 2):WaitForChild("modules", 2)
        :WaitForChild("Ailments", 2):WaitForChild("AilmentsClient", 2))
end)
local MYSTERY_PRIORITY = {"toilet","dirty","sleepy","hungry","thirsty","pet_me","play","sick","cat_cafe","salon","school","pizza_party","camping","beach_party","bored","walk","ride"}

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
    SubscribeHouse = SafeGet("HousingAPI/SubscribeToHouse"),
    ActivateInterior = SafeGet("HousingAPI/ActivateInteriorFurniture"),
    ActivateFurniture = SafeGet("HousingAPI/ActivateFurniture"),
    ExitSeats = SafeGet("AdoptAPI/ExitSeatStates"),
    FocusPet = SafeGet("AdoptAPI/FocusPet"), UnfocusPet = SafeGet("AdoptAPI/UnfocusPet"),
    PetPetted = SafeGet("PetAPI/PetPetted"), PetPerformance = SafeGet("PetAPI/ReplicateActivePerformances"),
    SetPetRP = SafeGet("SettingsAPI/SetPetRoleplayName"),
    Download = SafeGet("DownloadsAPI/Download"),
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
API.OpenChest = RawGet("LootBoxAPI/ExchangeItemForReward")
API.MinigameMsg = RawGet("MinigameAPI/MessageServer")
API.MinigameAttemptJoin = RawGet("MinigameAPI/AttemptJoin")
API.CollectCashback = RawGet("PayAPI/Collect")
API.ShootGhost = RawGet("MinigameAPI/ShootGhost") or RawGet("MinigameAPI/ClickGhost")

-- Event remotes (adoptme_new_net)
local EventNet = RS:FindFirstChild("adoptme_new_net") or RS:WaitForChild("adoptme_new_net", 15)
local function ER(name) return EventNet and (EventNet:FindFirstChild(name) or EventNet:WaitForChild(name, 2)) or nil end
API.UnlockPadlock = ER("Halloween2026/UnlockPadlock")
API.ClaimTombSpider = ER("Halloween2026/ClaimTombSpider")
API.PigeonNestTwig = ER("Halloween2026/JacobeanPigeonNestContributeTwig")
API.CandyCornClaim = ER("Halloween2026/CandyCornPileClaim")
API.StrayCatFeed = ER("Halloween2026/StrayCatGiftFood")
API.LightningLeverDeliver = ER("Halloween2026/LightningLeverDeliver")
API.LightningLeverActivate = ER("Halloween2026/LightningLeverActivate")
API.QuestClaimRemote = ER("adoptme_new.modules.Dailies.DailiesNetService:9")
API.QuestRewardRemote = ER("adoptme_new.modules.Dailies.DailiesNetService:15")

print("[Yuno] ✅ APIs ready")

-- ══════════ STATE (fusion v6.3 + v2) ══════════
local Cac = {
    CurrentLocation = nil, AilmentPlatform = nil,
    StrollerUID = nil, LastStrollerEquip = 0, LastMysteryAttempt = nil,
    PetMeAttempts = {}, MysteryBlacklist = {}, MysteryFails = {},
    CryptPendingLocks = {}, LastCashback = 0, LastEggBuy = 0,
}
getgenv().YunoCac = Cac

-- Farm master
local FarmEnabled, PetFarmEnabled, BabyFarmEnabled = false, false, false
-- v6.3 features
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
local Auto2DTuesdays, AutoHalloweenQuests, VisualBucksLoop = false, false, false
local VisualBucksAmount = 1000
local AutoTradeLicense = false
local HalloweenEnabled = false
local HalloweenCrypt, HalloweenTwigs, HalloweenCandy, HalloweenGhost = false, false, false, false
local LowerGraphicsWhenUnfocused = false

-- v2 features (NEW)
local AutoPetNeeds, AutoBabyNeeds = false, false
local KeepPetEquipped, PreferNeon = false, true
local PetOrderMode = "youngest"
local AutoBuyEgg, EggToBuy = false, "cracked_egg"
local AutoBuyWater, AutoBuyFood = true, true
local AutoPotions, PotionKinds, PotionSkip = false, {}, {}
local AutoNeonFuse, AutoMegaFuse, AutoNeonExclude = false, false, {}
local AutoPetPen, PenSlots, PenStock, PenMinBucks, PenMinutes = false, 4, false, 750, 15
local AutoCandyPets, CandyPick, CandyMaxBuy, CandyKeepCandy = false, {}, false, 0
local AutoCrypt, CryptOpen, AutoMummySpider = false, {"ladder"}, true
local AutoPigeonNest, AutoNest = false, false
local AutoSkelicorn = false
local AutoStrayCat = false
local AutoHauntlet, HauntletFirst, HauntletMove, HauntletMoveSec, HauntletSquad = false, true, "tween", 0.5, false
local AutoQuests, AutoHouseVisits = false, false
local AutoCashback, CashbackMins = false, 10
local AutoTeam = false
local AutoStuckRecovery = true
local AutoRejoin = false
local GameTravel = true
local HomeByRespawn = true
local SmartPriority = true
local FailCooldown, MaxFailures, DisableMins = 30, 3, 15

-- Halloween state
local Skelicorn = { delivered = false, activated = false, bought = false, buyRefusedAt = 0, logged = nil, notes = {} }
local SkelicornArgs = { deliver = {}, activate = {} }
local HauntletState = {
    available = false, join = nil, room = nil, roomSeq = 0, revealedGhost = nil,
    roomSafe = false, inventory = {}, health = 3, maxHealth = 3, tempHealth = 0,
    roomsOpened = 0, counters = {0,0,0,0}, myDoor = nil, expectDoor = nil,
    lastRunStart = 0, usedSeq = 0, usedItems = {}, leave = nil, kicked = nil,
    joinAcceptedAt = nil, enter = nil, lastPickAt = nil, lastPickSeq = nil,
    pickedAt = nil, squadIds = nil,
}
local HauntletVisited = {}
local HauntletGroups = {}

-- Events constants
local EV = {
    RustyKey = "halloween_2026_rusty_key", Twig = "halloween_2026_twig",
    Vacuum = "halloween_2026_ghost_vacuum", NestTwigs = 8,
    Ladder = "ladder", GraveValue = { candy_corn_pile_ginormous = 3, candy_corn_pile_small = 2, twig = 1 },
    OpenedIdPerFloor = 16, MinigameId = "ghost_clusters",
    HauntletId = "hauntlet", HauntletInteriorPrefix = "HauntletInterior",
    HauntletLobby = "HauntedHotel", Skelicorn = "halloween_2026_skelicorn",
    MummySpider = "halloween_2026_tomb_spider", SkelicornPrice = 120000,
    LightningLever = "halloween_2026_lightning_lever",
    CatFood = { "water", "chocolate_milk" },
    QuestTabs = { "halloween_2026", "vanilla" }, QuestsPerBoardReward = 3,
    RoundSeconds = 600,
    HauntletItems = { cell_phone = true, key = true, gold_key = true, red_potion = true, ghost_potion = true, gold_potion = true, rainbow_wand = true },
}
local DK = {
    Ailments = "ailments_manager", Equip = "equip_manager", PetPen = "idle_progression_manager",
    Crypt = "halloween_2026_crypt_manager", PigeonNest = "halloween_2026_jacobean_pigeon_nest_manager",
    Lightning = "halloween_2026_lightning_lever_manager", GhostCycle = "ghost_clusters_cycle_timestamp",
    Hauntlet = "halloween_2026_hauntlet_manager", HauntletCycle = "hauntlet_cycle_timestamp",
    Candy = "candy_2026", StrayCat = "halloween_2026_stray_cat_manager",
    Dailies = "dailies_manager", Money = "money", Team = "team", Interior = "house_interior",
    Inventory = "inventory", PetWrappers = "pet_char_wrappers",
}
local function CD(key) return M.ClientData and M.ClientData.get(key) or nil end
local function GetGameData()
    if not M.ClientData then return {} end
    return M.ClientData.get_data() or {}
end
local function GetPlayerData()
    local d = GetGameData()
    return d[LP.Name] or {}
end

-- Location tracker (v6.3)
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if M.InteriorsM and M.InteriorsM.get_current_location then
                local loc = M.InteriorsM.get_current_location()
                if loc and loc.id then Cac.CurrentLocation = loc.id; return end
            end
            local pd = GetPlayerData()
            if pd.char_wrapper and pd.char_wrapper.location then
                Cac.CurrentLocation = pd.char_wrapper.location.destination_id
            elseif Cac.CurrentLocation == nil then Cac.CurrentLocation = "MainMap" end
        end)
    end
end)

-- ══════════ THEMES (v6.3) ══════════
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
local function Make(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
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

-- ══════════ UI WIDGETS (v6.3) ══════════
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

-- floating button + drag + minimize (v6.3)
floatBtn = Make("TextButton", { Size = UDim2.new(0, 56, 0, 56), Position = UDim2.new(0.5, -28, 0, 80), BackgroundColor3 = Theme.Accent, Text = "", AutoButtonColor = false, Visible = false, ZIndex = 500, Parent = screenGui })
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
        mainFrame.Visible = false; floatBtn.Visible = true; floatScale.Scale = 0.5
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

-- ══════════ CORE HELPERS ══════════
local lastStatus = ""
local DebugInfo = { Pets = 0, BabyNeeds = 0, PetNeeds = 0, Task = "Idle" }
local function SetStatus(s)
    if s ~= lastStatus then
        lastStatus = s; DebugInfo.Task = s
        local lbl = Flags.__statusLbl
        if lbl and lbl.Parent then lbl.Text = "Status: " .. s end
    end
end
local TaskFailures = {}
local function CanTry(k) local f = TaskFailures[k]; return not (f and (tick() - f.time) < FailCooldown) end
local function MarkFailed(k) local f = TaskFailures[k] or { count = 0 }; f.count = f.count + 1; f.time = tick(); TaskFailures[k] = f end
local function ClearFailure(k) TaskFailures[k] = nil end

local AILMENT_ALIASES = {
    sad = "bored", tired = "sleepy", exhausted = "sleepy",
    itchy = "dirty", smelly = "dirty", stinky = "dirty", dirty_pet = "dirty",
    ill = "sick", food = "hungry", food_bowl = "hungry",
    water = "thirsty", water_bowl = "thirsty", toy = "play", play_time = "play",
    mystery_special = "mystery", mystery_box = "mystery",
    pet_me_special = "pet_me", cat = "cat_cafe", cafe = "cat_cafe",
    pizza = "pizza_party", school_quest = "school", salon_quest = "salon",
}
local function NormalizeAilment(k) return AILMENT_ALIASES[k] or k end
local function GetHRP() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end

-- Interior / house
local function EnterInterior(location, door, data)
    if not M.InteriorsM then return false end
    local fn = M.InteriorsM.enter_smooth or M.InteriorsM.enter
    if not fn then return false end
    local SetId = (syn and syn.set_thread_identity) or setthreadidentity
    local GetId = (syn and syn.get_thread_identity) or getthreadidentity
    local old = GetId and GetId() or 7
    if SetId then pcall(SetId, 2) end
    local ok = pcall(function() fn(location, door or "MainDoor", data or {}) end)
    if SetId then pcall(SetId, old) end
    return ok
end
local function IsInHouse()
    local hi = Workspace:FindFirstChild("HouseInteriors")
    local bp = hi and hi:FindFirstChild("blueprint")
    return bp and bp:FindFirstChildWhichIsA("Model") ~= nil
end
local function GoToHouse()
    if IsInHouse() then return true end
    SetStatus("Entering house...")
    local loc = Cac.CurrentLocation or "MainMap"
    if loc ~= "MainMap" and loc ~= "housing" then EnterInterior("MainMap", "MainDoor", {}); task.wait(3) end
    if loc == "housing" and API.UnsubscribeHouse then pcall(function() API.UnsubscribeHouse:InvokeServer() end); task.wait(1) end
    EnterInterior("housing", "MainDoor", { house_owner = LP })
    local s = tick()
    while tick() - s < 20 do task.wait(0.5); if IsInHouse() then task.wait(2); return true end end
    return IsInHouse()
end
local function TP(location, door, data)
    local loc = Cac.CurrentLocation or "MainMap"
    if loc == location then return true end
    if loc == "housing" and API.UnsubscribeHouse then pcall(function() API.UnsubscribeHouse:InvokeServer() end); task.wait(1) end
    EnterInterior(location, door or "MainDoor", data or {})
    local s, retried = tick(), false
    while tick() - s < 20 do
        task.wait(0.5)
        if (Cac.CurrentLocation or "MainMap") == location then
            if API.Download and location ~= "MainMap" then pcall(function() API.Download:InvokeServer("Interiors", location) end) end
            task.wait(1); return true
        end
        if tick() - s > 8 and not retried then retried = true; EnterInterior(location, door or "MainDoor", data or {}) end
    end
    return (Cac.CurrentLocation or "MainMap") == location
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
    local plat = Cac.AilmentPlatform; plat.Name = name
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
        if interact then for _, c in ipairs(interact:GetDescendants()) do if c.Name:find("AilmentsRefresh2024FireHydrant") then origin = c:FindFirstChild("Center") or c; break end end end
        offset = Vector3.new(0, -4, 0)
    end
    local loc = Cac.CurrentLocation
    if loc == "Salon" or loc == "School" or loc == "PizzaShop" or loc == "Hospital" or loc == "CatCafe" then plat.Position = Vector3.new(0, 15, 0)
    elseif name == "Main" then plat.Position = Vector3.new(2270 + math.random(-40, 40), 4780 + math.random(-40, 40), -2310 + math.random(-40, 40))
    elseif not origin then plat.Position = Vector3.new(2270, 4780, -2310)
    else plat.Position = origin.Position + offset + Vector3.new(math.random(-4, 4), 0, math.random(-4, 4)) end
    return plat
end
local function TPAllToPlatform(plat)
    local hrp = GetHRP(); if not hrp or not plat then return end
    hrp.CFrame = CFrame.new(plat.Position + Vector3.new(0, 6, 0))
    local wrappers = CD(DK.PetWrappers) or {}
    for _, w in pairs(wrappers) do
        if (w.player == LP or tostring(w.player) == LP.Name) and w.char and w.char:IsA("Model") then
            pcall(function() w.char:PivotTo(hrp.CFrame * CFrame.new(math.random(-4,4), 0, math.random(-1,1))) end)
        end
    end
end

-- Furniture finder (v6.3 + extension)
local BEDS_MODELS = { "FancyPetBed", "ModernPetBed", "CircularPetBed", "RectangularPetBed", "NormalCrib", "BasicCrib", "RoyalCrib", "PoshCrib", "sleepingbag", "basicbed" }
local SHOWERS_MODELS = { "StylishShower", "CheapBathtub", "ModernShower", "Bathtub", "GingerbreadShower", "HotTub", "camping_shower", "cheap_pet_bathtub_tutorial" }
local TOILET_MODELS = { "toilet", "Toilet" }
local FOODBOWL_MODELS = { "ailments_refresh_2024_cheap_food_bowl" }
local function FindFurnitureID(kind)
    local hi = Workspace:FindFirstChild("HouseInteriors")
    local furniture = hi and hi:FindFirstChild("furniture")
    if not furniture then return {} end
    local modelList = (kind == "sleepy") and BEDS_MODELS or (kind == "dirty" and SHOWERS_MODELS or (kind == "toilet" and TOILET_MODELS or FOODBOWL_MODELS))
    local found = {}
    for _, v in pairs(furniture:GetChildren()) do
        local model = v:FindFirstChildWhichIsA("Model")
        if model and table.find(modelList, model.Name) then
            local parts = string.split(v.Name, "true/")
            local fid = parts[2]
            if fid and fid ~= "" then table.insert(found, { fid = fid, name = model.Name }) end
        end
    end
    return found
end

-- ══════════ FARM TARGETS (fusion) ══════════
local function GetFarmTargets()
    local out = { Baby = {}, Pets = {} }
    if not M.ClientData then return out end
    local am = CD(DK.Ailments)
    if not am then return out end
    if BabyFarmEnabled and AutoBabyNeeds and am.baby_ailments then
        for _, a in pairs(am.baby_ailments) do
            if a.kind then out.Baby[NormalizeAilment(a.kind)] = true end
        end
    end
    if PetFarmEnabled and AutoPetNeeds then
        local wrappers = CD(DK.PetWrappers) or {}
        for _, w in pairs(wrappers) do
            if (w.player == LP or tostring(w.player) == LP.Name) then
                local al = am.ailments[w.pet_unique] or {}
                local needs = {}
                for _, a in pairs(al) do
                    if a.kind then needs[NormalizeAilment(a.kind)] = true end
                end
                if next(needs) then
                    table.insert(out.Pets, { uid = w.pet_unique, char = w.char, needs = needs, id = w.pet_id })
                end
            end
        end
    end
    local bc = 0; for _ in pairs(out.Baby) do bc = bc + 1 end
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
    local inv = CD("inventory")
    if not inv or not inv.food then return nil end
    local list = {}
    for uid, v in pairs(inv.food) do if v.id == kind or v.kind == kind then table.insert(list, uid) end end
    table.sort(list); return list[1]
end

-- ══════════ HELPERS v2 ══════════
local function IsEgg(id)
    if type(id) ~= "string" then return false end
    return id == "cracked_egg" or id == "pet_egg" or id == "royal_egg" or id == "fairytale_egg_2026_fairytale_egg" or id:match("_egg$") ~= nil
end
local function IsNeon(props) return type(props) == "table" and (props.neon == true or props.mega_neon == true) end

local function FindGrowingPet(preferKind)
    local inv = CD("inventory"); if not inv or not inv.pets then return nil end
    local pen = CD(DK.PetPen) or {}
    local inPen = {}
    for uid in pairs(pen.active_pets or {}) do inPen[tostring(uid)] = true end
    local candidates = {}
    for uid, p in pairs(inv.pets) do
        if not inPen[tostring(p.unique or uid)] then
            local kind = tostring(p.kind or p.id or "?")
            local pr = p.properties or {}
            local age = tonumber(pr.age) or 1
            if not IsEgg(kind) and age < 6 and kind ~= "practice_dog" then
                if not preferKind or preferKind[kind] then
                    table.insert(candidates, { uid = tostring(p.unique or uid), age = age, kind = kind, neon = IsNeon(pr) })
                end
            end
        end
    end
    if #candidates == 0 then return nil end
    table.sort(candidates, function(a, b)
        if PreferNeon and a.neon ~= b.neon then return a.neon end
        if a.age ~= b.age then return PetOrderMode == "oldest" and a.age > b.age or a.age < b.age end
        return a.uid < b.uid
    end)
    return candidates[1]
end

local function FindFusionGroup(mega)
    local inv = CD("inventory"); if not inv or not inv.pets then return nil end
    local pen = CD(DK.PetPen) or {}
    local inPen = {}
    for uid in pairs(pen.active_pets or {}) do inPen[tostring(uid)] = true end
    local groups = {}
    for uid, p in pairs(inv.pets) do
        local kind = tostring(p.kind or p.id or "?")
        local pr = p.properties or {}
        local age = tonumber(pr.age) or 1
        local neon = pr.neon == true
        local isMega = pr.mega_neon == true
        if age == 6 and not inPen[tostring(p.unique or uid)] and not IsEgg(kind) and not AutoNeonExclude[kind] then
            if mega and neon and not isMega then
                groups[kind] = groups[kind] or {}; table.insert(groups[kind], tostring(p.unique or uid))
            elseif not mega and not neon and not isMega then
                groups[kind] = groups[kind] or {}; table.insert(groups[kind], tostring(p.unique or uid))
            end
        end
    end
    for kind, list in pairs(groups) do
        if #list >= 4 then table.sort(list); return kind, {list[1], list[2], list[3], list[4]} end
    end
    return nil
end

local function CountPenPets()
    local pen = CD(DK.PetPen)
    if type(pen) ~= "table" or type(pen.active_pets) ~= "table" then return 0 end
    local n = 0; for _ in pairs(pen.active_pets) do n = n + 1 end; return n
end

local function FindItemByKind(category, ids)
    local inv = CD("inventory")
    local cat = inv and inv[category]
    if not cat then return nil end
    local idset = {}
    for _, id in ipairs(ids) do idset[id] = true end
    for uid, item in pairs(cat) do
        if idset[item.id or item.kind] then return { unique = tostring(uid), id = item.id or item.kind } end
    end
    return nil
end

-- ══════════ TASK FUNCTIONS ══════════

-- 1) PET ME (v2 enhanced)
local function DoPetMeTask()
    local t = GetFarmTargets()
    local processed = false
    for _, pet in ipairs(t.Pets) do
        if pet.needs.pet_me then
            if not Cac.PetMeAttempts[pet.uid] or os.time() - Cac.PetMeAttempts[pet.uid] > 10 then
                Cac.PetMeAttempts[pet.uid] = os.time()
                local petModel
                for _, w in pairs(CD(DK.PetWrappers) or {}) do
                    if w.pet_unique == pet.uid and w.char and w.char:IsA("Model") then petModel = w.char; break end
                end
                if petModel and API.FocusPet and API.UnfocusPet then
                    pcall(function() API.FocusPet:FireServer(petModel) end)
                    task.wait(0.3)
                    if API.PetPerformance then pcall(function() API.PetPerformance:FireServer(petModel, {FocusPet = true, Petting = true}) end) end
                    task.wait(0.5)
                    if API.PetPetted then pcall(function() API.PetPetted:FireServer(pet.uid, LP) end) end
                    if API.ProgressPetMe then pcall(function() API.ProgressPetMe:FireServer(pet.uid) end) end
                    if API.PetPerformance then pcall(function() API.PetPerformance:FireServer(petModel, {FocusPet = true, PettingHappy = true}) end) end
                    task.wait(1)
                    pcall(function() API.UnfocusPet:FireServer(petModel) end)
                    processed = true
                end
            end
        end
    end
    if not processed then return true end
    local done = WaitForNeedDone("pet_me", 20)
    if done then ClearFailure("pet_me") else MarkFailed("pet_me") end
    return done
end

-- 2) FEED (v6.3 + v2 pet bowl first)
local function DoFeedTask(kind)
    local t = GetFarmTargets()
    local foodKind = kind == "hungry" and "sandwich-default" or "water"
    local babyN = t.Baby[kind]
    local pets = {}
    for _, p in ipairs(t.Pets) do if p.needs[kind] then table.insert(pets, p) end end
    if not babyN and #pets == 0 then return true end

    if babyN and API.ServerUseTool then
        local fid = GetFoodUID(foodKind)
        if not fid then fid = GetFoodUID(kind == "hungry" and "hotdog" or "water") end
        if not fid and API.BuyItem then
            if kind == "hungry" and AutoBuyFood then
                pcall(function() API.BuyItem:InvokeServer("food", "hotdog", {buy_count = 1}) end); task.wait(0.8)
            elseif kind == "thirsty" and AutoBuyWater then
                pcall(function() API.BuyItem:InvokeServer("food", "water", {buy_count = 1}) end); task.wait(0.8)
            end
            fid = GetFoodUID(foodKind)
        end
        if fid then
            local n = kind == "thirsty" and 8 or 3
            for i = 1, n do pcall(function() API.ServerUseTool:InvokeServer(fid, "END") end); task.wait(0.08) end
        end
    end
    if API.CreatePetObject and API.ConsumeFoodObject then
        for _, pet in ipairs(pets) do
            local fid = GetFoodUID(foodKind)
            if not fid then fid = GetFoodUID(kind == "hungry" and "hotdog" or "water") end
            if not fid and API.BuyItem then
                pcall(function() API.BuyItem:InvokeServer("food", kind == "hungry" and "hotdog" or "water", {buy_count = 1}) end)
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

-- 3) PLAY
local function DoPlayTask()
    local t = GetFarmTargets()
    local toyUid
    local inv = CD("inventory")
    if inv and inv.toys then
        for uid, v in pairs(inv.toys) do
            local k = tostring(v.kind or v.id)
            if k == "squeaky_bone_default" or k:find("chew_toy") then toyUid = uid; break end
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

-- 4) DIRTY / SLEEPY (v6.3 exact)
local function DoSleepDirtyTask(kind)
    local t = GetFarmTargets()
    local isBaby = t.Baby[kind]
    local pets = {}
    for _, p in ipairs(t.Pets) do if p.needs[kind] then table.insert(pets, p) end end
    if not isBaby and #pets == 0 then return true end

    SetStatus(kind .. ": entering house...")
    if not GoToHouse() then Notify("Dirty/Sleep", "Can't enter house. Rejoin."); MarkFailed(kind); return false end
    task.wait(2)
    local found = FindFurnitureID(kind)
    if #found == 0 then
        Notify(kind, "Buy a " .. (kind == "sleepy" and "bed" or "shower") .. "!")
        MarkFailed(kind); return false
    end
    local fid = found[1].fid
    SetStatus(kind .. ": " .. found[1].name)
    local start = tick(); local lastSend = 0
    while tick() - start < 90 do
        task.wait(0.3)
        if not FarmEnabled then break end
        if not IsInHouse() then if not GoToHouse() then break end; task.wait(1.5) end
        local tt = GetFarmTargets()
        local still = tt.Baby[kind] and true or false
        if not still then for _, p in ipairs(tt.Pets) do if p.needs[kind] then still = true; break end end end
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

-- 5) SICK
local function DoSickTask()
    local t = GetFarmTargets()
    local still = t.Baby.sick and true or false
    if not still then for _, p in ipairs(t.Pets) do if p.needs.sick then still = true; break end end end
    if not still then return true end
    if API.HealWithDoctor then
        SetStatus("sick: healing...")
        local s = tick()
        while tick() - s < 30 do
            pcall(function() API.HealWithDoctor:FireServer() end); task.wait(1)
            local tt = GetFarmTargets()
            local sn = tt.Baby.sick and true or false
            if not sn then for _, p in ipairs(tt.Pets) do if p.needs.sick then sn = true; break end end end
            if not sn then ClearFailure("sick"); return true end
        end
    end
    if not TP("Hospital") then MarkFailed("sick"); return false end
    task.wait(2)
    if API.ActivateInterior then pcall(function() API.ActivateInterior:InvokeServer("f-14", "UseBlock", "Yes", LP.Character) end) end
    local done = WaitForNeedDone("sick", 30, "Hospital")
    if done then ClearFailure("sick") else MarkFailed("sick") end
    return done
end

-- 6) TOILET (v6.3 + house first)
local function DoToiletTask()
    if IsInHouse() then
        local found = FindFurnitureID("toilet")
        if #found > 0 then
            local hrp = GetHRP(); if not hrp then return false end
            local tt = GetFarmTargets()
            local still = tt.Baby.toilet or false
            if not still then for _, p in ipairs(tt.Pets) do if p.needs.toilet then still = true; break end end end
            if not still then return true end
            pcall(function() API.ActivateFurniture:InvokeServer(LP, found[1].fid, "UseBlock", { cframe = hrp.CFrame }, LP.Character) end)
            for _, pet in ipairs(tt.Pets) do if pet.needs.toilet then pcall(function() API.ActivateFurniture:InvokeServer(LP, found[1].fid, "UseBlock", { cframe = hrp.CFrame }, pet.char) end) end end
            local done = WaitForNeedDone("toilet", 25, "housing")
            if done then ClearFailure("toilet") else MarkFailed("toilet") end
            return done
        end
    end
    TPAllToPlatform(CreatePlatform("Main")); task.wait(0.5)
    if not TP("MainMap") then MarkFailed("toilet"); return false end
    task.wait(0.5)
    TPAllToPlatform(CreatePlatform("Toilet")); task.wait(1)
    local interact = Workspace:FindFirstChild("StaticMap") and Workspace.StaticMap:FindFirstChild("Interactables")
    if not interact then MarkFailed("toilet"); return false end
    local hydrant
    for _, c in ipairs(interact:GetDescendants()) do if c.Name:find("AilmentsRefresh2024FireHydrant") then hydrant = c; break end end
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

-- 7) MYSTERY (v2 improved)
local function DoMysteryTask()
    local t = GetFarmTargets()
    local targets = {}
    for _, p in ipairs(t.Pets) do
        if (p.needs.mystery or p.needs.misery) then
            if not Cac.MysteryBlacklist[p.uid] or os.time() - Cac.MysteryBlacklist[p.uid] > 60 then
                table.insert(targets, {pet = p, kind = p.needs.mystery and "mystery" or "misery"})
            end
        end
    end
    if #targets == 0 then return true end
    if Cac.LastMysteryAttempt and os.time() - Cac.LastMysteryAttempt < 3 then return false end
    Cac.LastMysteryAttempt = os.time()
    local inv = CD("inventory")
    local petData = (inv and inv.pets) or {}
    for _, e in ipairs(targets) do
        local petUID = e.pet.uid
        local petInfo = petData[petUID]
        if petInfo and AilmentsClient and API.ChooseMystery then
            local entityRef = { pet_unique = petUID, pet_id = petInfo.kind or petInfo.id, is_egg = false, is_doll = false, player = LP }
            local mysteryValue
            pcall(function()
                for _, fn in pairs(AilmentsClient) do
                    if type(fn) == "function" then
                        local uvs = debug.getupvalues(fn)
                        if uvs then for _, uv in pairs(uvs) do
                            if type(uv) == "table" then
                                local pa = rawget(uv, petUID)
                                if pa and type(pa) == "table" then
                                    local v = rawget(pa, e.kind) or rawget(pa, "mystery")
                                    if v then mysteryValue = v; break end
                                end
                            end
                        end end
                        if mysteryValue then break end
                    end
                end
            end)
            if mysteryValue and mysteryValue.action and mysteryValue.action.options then
                local gs = mysteryValue.action.options.get_ailment_slots
                local seed = mysteryValue.action.options.random_seed
                if gs and seed then
                    local SetId = (syn and syn.set_thread_identity) or setthreadidentity
                    local GetId = (syn and syn.get_thread_identity) or getthreadidentity
                    local old = GetId and GetId() or 7
                    if SetId then pcall(SetId, 2) end
                    local ok, slots = pcall(function() return gs(seed, {}, entityRef) end)
                    if SetId then pcall(SetId, old) end
                    if ok and type(slots) == "table" then
                        local pick, pickKind
                        for _, easy in ipairs(MYSTERY_PRIORITY) do
                            for k, v in pairs(slots) do if v == easy then pick, pickKind = k, easy; break end end
                            if pick then break end
                        end
                        if not pick then for k, v in pairs(slots) do pick, pickKind = k, v; break end end
                        if pick and pickKind then
                            pcall(function() API.ChooseMystery:FireServer(petUID, e.kind, pick, pickKind) end)
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
        for _, e in ipairs(targets) do
            Cac.MysteryFails[e.pet.uid] = (Cac.MysteryFails[e.pet.uid] or 0) + 1
            if Cac.MysteryFails[e.pet.uid] >= 3 then
                Cac.MysteryBlacklist[e.pet.uid] = os.time(); Cac.MysteryFails[e.pet.uid] = nil
            end
        end
        MarkFailed("mystery")
    end
    return done
end

-- 8) WALK
local function DoWalkTask()
    local t = GetFarmTargets()
    local hasWalkPet = false
    for _, p in ipairs(t.Pets) do if p.needs.walk then hasWalkPet = true; break end end
    if not t.Baby.walk and not hasWalkPet then return true end
    TPAllToPlatform(CreatePlatform("Main")); task.wait(0.5)
    if not TP("MainMap") then MarkFailed("walk"); return false end
    task.wait(1); TPAllToPlatform(CreatePlatform("Main")); task.wait(1)
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
        pcall(function() hum:MoveTo(plat.Position + Vector3.new(math.cos(angle) * 25, 6, math.sin(angle) * 25)) end)
        if math.random() < 0.05 then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
    local done = WaitForNeedDone("walk", 10)
    if done then ClearFailure("walk") else MarkFailed("walk") end
    return done
end

-- 9) RIDE
local function DoRideTask()
    local t = GetFarmTargets()
    local pets = {}
    for _, p in ipairs(t.Pets) do if p.needs.ride then table.insert(pets, p) end end
    if not t.Baby.ride and #pets == 0 then return true end
    TPAllToPlatform(CreatePlatform("Main")); task.wait(0.5)
    if not TP("MainMap") then MarkFailed("ride"); return false end
    task.wait(1); TPAllToPlatform(CreatePlatform("Main")); task.wait(1)
    if not Cac.StrollerUID then
        local inv = CD("inventory")
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

-- 10) QUEST (Salon/School/etc)
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
        local t = GetFarmTargets()
        local still = t.Baby[kind] and true or false
        if not still then for _, p in ipairs(t.Pets) do if p.needs[kind] then still = true; break end end end
        if not still then break end
    end
    local done = WaitForNeedDone(kind, 5)
    if done then ClearFailure(kind) else MarkFailed(kind) end
    return done
end

-- 11) POOL
local function DoPoolPartyTask()
    TPAllToPlatform(CreatePlatform("Main")); task.wait(0.5)
    if not TP("MainMap") then MarkFailed("pool_party"); return false end
    task.wait(1)
    local pool = Workspace:FindFirstChild("StaticMap") and Workspace.StaticMap:FindFirstChild("Pool")
    local origin = pool and pool:FindFirstChild("PoolOrigin")
    if not origin then MarkFailed("pool_party"); return false end
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(origin.Position + Vector3.new(0, 5, 0)) end
    task.wait(0.5); TPAllToPlatform(CreatePlatform("Pool"))
    local done = WaitForNeedDone("pool_party", 30)
    if done then ClearFailure("pool_party") else MarkFailed("pool_party") end
    return done
end

-- 12) WEATHER
local WEATHER_TAGS = { rain_puddle = "RainPuddleServer", leaf_pile = "LeafPileServer", snow = "SnowPileServer", diving_board = "DivingBoardServer" }
local function DoWeatherTask(kind)
    local t = GetFarmTargets()
    local targets = {}
    if t.Baby[kind] then table.insert(targets, { type = "Player", char = LP.Character, uid = "BABY" }) end
    for _, pet in ipairs(t.Pets) do if pet.needs[kind] and pet.char then table.insert(targets, { type = "Pet", char = pet.char, uid = pet.uid }) end end
    if #targets == 0 then return true end
    local cframe, fid
    local tag = WEATHER_TAGS[kind]
    if tag then
        local tagged = CollectionService:GetTagged(tag)
        if #tagged > 0 then
            local inst = tagged[1]
            if kind == "diving_board" then fid = "f-31" else
                local p = inst
                while p do local m = p.Name:match("f%-%d+"); if m then fid = m; break end; p = p.Parent end
            end
            cframe = inst:IsA("Model") and inst:GetPivot() or inst.CFrame
        end
    end
    TPAllToPlatform(CreatePlatform("Main")); task.wait(0.5)
    if not TP("MainMap") then MarkFailed(kind); return false end
    task.wait(1.5)
    if not cframe then MarkFailed(kind); return false end
    local plat = CreatePlatform("WeatherPlatform")
    plat.CFrame = cframe * CFrame.new(0, -3.5, 0)
    TPAllToPlatform(plat); task.wait(1.5)
    if fid and API.ActivateInterior then
        for _, item in ipairs(targets) do
            task.spawn(function()
                for i = 1, 3 do
                    if not FarmEnabled then break end
                    if item.type == "Pet" and item.char and item.char.PrimaryPart then
                        pcall(function() item.char:PivotTo(cframe * CFrame.new(0, 2, 0)) end)
                    end
                    pcall(function() API.ActivateInterior:InvokeServer(fid, "UseBlock", { cframe = cframe }, item.char) end)
                    task.wait(2)
                end
            end)
        end
    end
    local s = tick()
    while tick() - s < 40 do
        task.wait(2)
        if not FarmEnabled then break end
        local tt = GetFarmTargets()
        local still = tt.Baby[kind] and true or false
        if not still then for _, p in ipairs(tt.Pets) do if p.needs[kind] then still = true; break end end end
        if not still then break end
    end
    local done = WaitForNeedDone(kind, 5)
    if done then ClearFailure(kind) else MarkFailed(kind) end
    return done
end

-- ══════════ HALLOWEEN v2 (CRYPT, NEST, SKELICORN, CANDY, STRAY CAT, GHOST, HAUNTLET) ══════════

-- Helpers Crypt
local function Y(list) local out = {}; for k in pairs(type(list) == "table" and list or {}) do if tonumber(k) then table.insert(out, tonumber(k)) end end; table.sort(out); return out end
local function B(k, p) if type(k) ~= "table" then return nil end; return k[p] or k[tostring(p)] end

local function nestState(k, twigsInBag, keysInBag)
    if type(k) ~= "table" then return "UNKNOWN", 0, twigsInBag or 0 end
    local contrib = tonumber(k.twigs_contributed) or 0
    twigsInBag = twigsInBag or 0
    if contrib >= EV.NestTwigs then return "COMPLETE", contrib, twigsInBag end
    if contrib + twigsInBag >= EV.NestTwigs then return "BUILD_NEST", contrib, twigsInBag end
    if (keysInBag or 0) > 0 then return "COLLECT_TWIGS", contrib, twigsInBag end
    return "WAIT_KEY", contrib, twigsInBag
end

local function cryptPlan(k, preferTwig)
    if type(k) ~= "table" or type(k.floors) ~= "table" then return nil, "no data" end
    local opened = {}
    for _, v in pairs(type(k.opened) == "table" and k.opened or {}) do if tonumber(v) then opened[tonumber(v)] = true end end
    for floorIdx, fidx in ipairs(Y(k.floors)) do
        local fl = B(k.floors, fidx)
        local coffins = type(fl) == "table" and fl.coffins
        if type(coffins) == "table" then
            if preferTwig then
                for _, gidx in ipairs(Y(coffins)) do
                    if not opened[fidx * EV.OpenedIdPerFloor + gidx] and B(coffins, gidx) == EV.Twig then
                        return { floor = fidx, grave = gidx, reward = EV.Twig }
                    end
                end
            end
            local ladderGrave
            for _, gidx in ipairs(Y(coffins)) do if B(coffins, gidx) == EV.Ladder then ladderGrave = gidx end end
            if ladderGrave then
                if not opened[fidx * EV.OpenedIdPerFloor + ladderGrave] then
                    return { floor = fidx, grave = ladderGrave, reward = EV.Ladder }
                end
            else
                local bestG, bestV
                for _, gidx in ipairs(Y(coffins)) do
                    if not opened[fidx * EV.OpenedIdPerFloor + gidx] then
                        local v = EV.GraveValue[B(coffins, gidx)] or 0
                        if not bestG or v > bestV then bestG, bestV = gidx, v end
                    end
                end
                if bestG then return { floor = fidx, grave = bestG, reward = tostring(B(coffins, bestG)) } end
                return { spider = true, floor = fidx }
            end
        end
    end
    return { spider = true }
end

local function equipCryptKey()
    local char = LP.Character
    if char and char:FindFirstChild("Halloween2026RustyKey") then return true end
    local inv = CD("inventory") or {}
    local keyUid
    for cat, items in pairs(inv) do
        if type(items) == "table" then
            for uid, item in pairs(items) do
                if type(item) == "table" and tostring(item.kind or item.id) == EV.RustyKey then keyUid = uid; break end
            end
        end
        if keyUid then break end
    end
    if not keyUid then return false end
    if API.Equip then pcall(function() API.Equip:InvokeServer(keyUid) end); task.wait(1) end
    return char and char:FindFirstChild("Halloween2026RustyKey") ~= nil
end

local function DoCryptTask()
    local unlock = API.UnlockPadlock
    local claimSpider = API.ClaimTombSpider
    if not unlock then return false end
    local crypt = CD(DK.Crypt)
    if not crypt then return false end
    if Cac.CurrentLocation ~= "TheCrypt" then
        SetStatus("Crypt: entering...")
        if Cac.CurrentLocation == "housing" then pcall(function() API.UnsubscribeHouse:InvokeServer() end); task.wait(1) end
        EnterInterior("TheCrypt", "MainDoor", {})
        local s = tick()
        while tick() - s < 15 do task.wait(0.5); if Cac.CurrentLocation == "TheCrypt" then break end end
        if Cac.CurrentLocation ~= "TheCrypt" then return false end
        if API.Download then pcall(function() API.Download:InvokeServer("Interiors", "TheCrypt") end) end
        task.wait(2)
    end
    if not equipCryptKey() then SetStatus("Crypt: no key"); return false end
    local inv = CD("inventory") or {}
    local twigsInBag = 0
    for _, item in pairs(inv.toys or {}) do if (item.kind or item.id) == EV.Twig then twigsInBag = twigsInBag + 1 end end
    local keysInBag = 0
    for _, item in pairs(inv.toys or {}) do if (item.kind or item.id) == EV.RustyKey then keysInBag = keysInBag + 1 end end
    local plan = cryptPlan(crypt, AutoNest and twigsInBag > 0)
    if not plan then return false end
    if plan.spider then
        if claimSpider and AutoMummySpider then
            local before = crypt and crypt.seed
            pcall(function() claimSpider:InvokeServer() end)
            Notify("Halloween", "🕷 Tomb Spider claimed!")
            PlaySound("success", 0.7); task.wait(3)
        end
        return true
    end
    for _, gidx in ipairs({plan.grave}) do
        if not equipCryptKey() then break end
        local openedBefore = crypt.opened and #crypt.opened or 0
        pcall(function() unlock:InvokeServer({ padlock_index = plan.grave, floor_index = plan.floor }) end)
        task.wait(1.5)
        local fresh = CD(DK.Crypt)
        local openedNow = fresh and fresh.opened and #fresh.opened or 0
        if openedNow > openedBefore then
            Notify("Halloween", "🎃 Opened " .. (plan.reward or "grave"))
        end
    end
    return true
end

-- PIGEON NEST
local function DoPigeonNestTask()
    local contribute = API.PigeonNestTwig
    if not contribute then return false end
    local nest = CD(DK.PigeonNest)
    if not nest then return false end
    if (nest.twigs_contributed or 0) >= EV.NestTwigs then return false end
    local inv = CD("inventory") or {}
    local twigs = {}
    for uid, item in pairs(inv.toys or {}) do if (item.kind or item.id) == EV.Twig then table.insert(twigs, uid) end end
    if #twigs == 0 then return false end
    if Cac.CurrentLocation ~= "HauntedHotel" then
        SetStatus("Nest: entering hotel...")
        if Cac.CurrentLocation == "housing" then pcall(function() API.UnsubscribeHouse:InvokeServer() end); task.wait(1) end
        EnterInterior("HauntedHotel", "MainDoor", {})
        local s = tick()
        while tick() - s < 15 do task.wait(0.5); if Cac.CurrentLocation == "HauntedHotel" then break end end
        task.wait(2)
    end
    local hrp = GetHRP()
    if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, 10, 0); hrp.AssemblyLinearVelocity = Vector3.zero; task.wait(1) end
    for _, uid in ipairs(twigs) do
        local fresh = CD(DK.PigeonNest)
        if fresh and (fresh.twigs_contributed or 0) >= EV.NestTwigs then break end
        local ok, result = pcall(function() return contribute:InvokeServer({ unique = uid }) end)
        if ok and result and result.ok then
            Notify("Halloween", "🪵 Twig " .. (result.twigs_contributed or "?") .. "/8")
            if (result.twigs_contributed or 0) >= EV.NestTwigs then
                Notify("Halloween", "🎉 Pigeon unlocked!"); PlaySound("success", 0.7); break
            end
        else task.wait(1) end
    end
    return true
end

-- SKELICORN
local function findLever()
    local inv = CD("inventory") or {}
    for cat, items in pairs(inv) do
        if type(items) == "table" then
            for uid, item in pairs(items) do
                if type(item) == "table" and tostring(item.id or item.kind) == EV.LightningLever then
                    return tostring(uid), cat
                end
            end
        end
    end
    return nil
end

local function findLeverMachine()
    local found
    pcall(function()
        for _, l in ipairs(workspace:GetDescendants()) do
            if l:IsA("Model") or l:IsA("BasePart") then
                local name = string.lower(l.Name)
                if string.find(name, "lightning", 1, true) and string.find(name, "lever", 1, true) then
                    local p = l:IsA("BasePart") and l or l.PrimaryPart or l:FindFirstChildWhichIsA("BasePart", true)
                    if p then found = found or { node = l, part = p } end
                end
            end
        end
    end)
    return found
end

local function DoSkelicornTask()
    if not AutoSkelicorn and not (getgenv().YunoFocusSkelicorn) then return false end
    local candy = tonumber(CD(DK.Candy)) or 0
    local price = EV.SkelicornPrice
    local skel = Skelicorn
    local inv = CD("inventory") or {}
    local alreadyHas = false
    for _, p in pairs(inv.pets or {}) do
        if tostring(p.kind or p.id) == EV.Skelicorn then alreadyHas = true; break end
    end
    if alreadyHas and not (getgenv().YunoFocusSkelicorn) then return false end
    local hasLever = findLever()
    local leverData = CD(DK.Lightning)
    local delivered = skel.delivered
    if type(leverData) == "table" and leverData.lever_state then
        local s = string.lower(tostring(leverData.lever_state))
        if s ~= "deactivated" and s ~= "" and s ~= "none" and s ~= "missing" then delivered = true; skel.delivered = true; skel.activated = true end
    end
    if not delivered then
        if not hasLever then SetStatus("Skelicorn: looking for lever in Crypt..."); return DoCryptTask() end
        SetStatus("Skelicorn: installing lever...")
        if not TP("MainMap") then return false end
        task.wait(2)
        local machine = findLeverMachine()
        if not machine then SetStatus("Skelicorn: machine not found"); return false end
        local hrp = GetHRP()
        if hrp then
            pcall(function() hrp.CFrame = machine.part.CFrame * CFrame.new(0, 5, 6) end)
            task.wait(1)
        end
        if API.Equip then pcall(function() API.Equip:InvokeServer(hasLever) end); task.wait(0.8) end
        if API.LightningLeverDeliver then
            pcall(function() API.LightningLeverDeliver:InvokeServer(table.unpack(SkelicornArgs.deliver or {})) end)
            task.wait(3)
            skel.delivered = true
        end
        return true
    end
    if candy >= price then
        SetStatus("Skelicorn: buying ("..candy.."/"..price..")")
        local before = {}
        for uid in pairs(inv.pets or {}) do before[uid] = true end
        pcall(function() API.BuyItem:InvokeServer("pets", EV.Skelicorn, {buy_count = 1}) end)
        task.wait(3)
        local fresh = CD("inventory") or {}
        for uid, p in pairs(fresh.pets or {}) do
            if not before[uid] and tostring(p.kind or p.id) == EV.Skelicorn then
                Notify("Skelicorn", "🦄 Bought!"); skel.bought = true
                PlaySound("success", 0.7); return true
            end
        end
    else
        SetStatus(string.format("Skelicorn: candy %d/%d", candy, price))
    end
    return true
end

-- STRAY CAT
local function DoStrayCatTask()
    if not AutoStrayCat then return false end
    local data = CD(DK.StrayCat) or {}
    if data.fed_today == true then return false end
    local inv = CD("inventory") or {}
    local water
    for uid, item in pairs(inv.food or {}) do
        if table.find(EV.CatFood, item.id or item.kind) then water = { unique = tostring(uid), id = item.id or item.kind }; break end
    end
    if not water and AutoBuyWater and API.BuyItem then
        pcall(function() API.BuyItem:InvokeServer("food", "water", {}) end)
        task.wait(1)
        inv = CD("inventory") or {}
        for uid, item in pairs(inv.food or {}) do
            if table.find(EV.CatFood, item.id or item.kind) then water = { unique = tostring(uid), id = item.id or item.kind }; break end
        end
    end
    if not water then return false end
    SetStatus("Stray Cat: feeding...")
    if not TP("MainMap") then return false end
    task.wait(1)
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(-243.6, 87, -1118.2) end
    task.wait(1)
    if API.Equip then pcall(function() API.Equip:InvokeServer(water.unique) end); task.wait(0.8) end
    pcall(function() API.StrayCatFeed:InvokeServer({ unique = water.unique }) end)
    task.wait(2)
    local fresh = CD(DK.StrayCat) or {}
    if fresh.fed_today then Notify("Halloween", "🐱 Stray Cat fed!"); return true end
    return true
end

-- CANDY CORN CLAIM
local function DoCandyClaim()
    if not API.CandyCornClaim then return false end
    local mgr = CD("halloween_2026_candy_corn_pile_manager")
    if not mgr or not mgr.pending or mgr.pending < 15000 then return false end
    if Cac.CurrentLocation ~= "MainMap" then
        if Cac.CurrentLocation == "housing" then pcall(function() API.UnsubscribeHouse:InvokeServer() end); task.wait(1) end
        EnterInterior("MainMap", "MainDoor", {}); task.wait(3)
    end
    local hrp = GetHRP()
    if hrp then
        local pickup = Workspace:FindFirstChild("Interiors") and Workspace.Interiors:FindFirstChild("PickupArea", true)
        if pickup then hrp.CFrame = pickup.CFrame * CFrame.new(0, 3, 0); hrp.AssemblyLinearVelocity = Vector3.zero; task.wait(1) end
    end
    pcall(function() API.CandyCornClaim:InvokeServer() end)
    Notify("Halloween", "🍬 Claimed " .. mgr.pending .. " candy")
    PlaySound("success", 0.6); task.wait(2); return true
end

-- GHOST CLUSTER
local function DoGhostCluster()
    if not API.MinigameMsg then return false end
    local cycle = CD(DK.GhostCycle)
    if not cycle or not cycle.timestamp then return false end
    local remain = cycle.timestamp - os.time()
    if remain > 15 or remain < -120 then SetStatus("Ghost inactive"); return false end
    SetStatus("Ghost: entering Manor...")
    if Cac.CurrentLocation ~= "HauntedManor" and Cac.CurrentLocation ~= "ManorMinigameInterior" then
        if Cac.CurrentLocation == "housing" then pcall(function() API.UnsubscribeHouse:InvokeServer() end); task.wait(1) end
        pcall(function() API.SetLocation:FireServer("MainMap", nil, "MainMap") end); task.wait(1)
        EnterInterior("HauntedManor", "MainDoor", {
            spawn_cframe = CFrame.new(-5976.8955078125, 10010.609375, 9001.478515625, 1, 0, 0, 0, 1, 0, 0, 0, 1),
            start_transparency = 1,
        })
        local s = tick()
        while tick() - s < 10 do task.wait(0.5); if Cac.CurrentLocation == "HauntedManor" or Cac.CurrentLocation == "ManorMinigameInterior" then break end end
    end
    local mg = CD("minigame_client_manager")
    local mgid
    if mg and mg.get then
        local inst = mg.get("ghost_clusters")
        if inst and inst.instanced_minigame then mgid = inst.instanced_minigame.minigame_id end
    end
    if not mgid then return false end
    SetStatus("Ghost: contributing...")
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
                    if prog < req and not orbit then
                        local token = HttpService:GenerateGUID(false)
                        pcall(function() API.MinigameMsg:FireServer(mgid, "start_contribute", { use_token = token, ghost_id = gid }) end)
                        contributed = contributed + 1; task.wait(0.5)
                    end
                end
            end
        end
    end
    if contributed > 0 then Notify("Halloween", "👻 " .. contributed .. " ghosts") end
    task.wait(10); return true
end

-- HAUNTLET (simplified but functional)
local function DoHauntletTask()
    if not AutoHauntlet then return false end
    if not API.MinigameMsg or not API.MinigameAttemptJoin then return false end
    if HauntletState.join and (not HauntletState.leave and (not HauntletState.kicked)) then
        -- Already in run, skip
        return false
    end
    SetStatus("Hauntlet: joining Hotel...")
    if not TP(EV.HauntletLobby) then return false end
    task.wait(2)
    -- Teleport to join zone
    local hs = Workspace:FindFirstChild("Interiors") and Workspace.Interiors:FindFirstChild("HauntedHotel")
    local joinZone = hs and hs:FindFirstChild("HauntletMinigameJoinZone")
    if joinZone then
        local part = joinZone:IsA("BasePart") and joinZone or joinZone:FindFirstChildWhichIsA("BasePart", true)
        local hrp = GetHRP()
        if part and hrp then
            hrp.CFrame = part.CFrame * CFrame.new(0, 3, 0)
            task.wait(1)
        end
    end
    -- Just be in zone, server auto-queues
    local s = tick()
    while tick() - s < 20 do
        if HauntletState.join or HauntletState.joinAcceptedAt then return true end
        task.wait(1)
    end
    Notify("Hauntlet", "Waiting for round...")
    return true
end

-- ══════════ TEAM / KEEP PET / POTIONS / NEON / PET PEN / EGGS / QUESTS / CASHBACK / GIFTS ══════════

local function DoTeamSwitch()
    if not AutoTeam or not API.ChooseTeam then return false end
    local team = CD(DK.Team)
    if team == "Babies" then return true end
    SetStatus("Team: switching to Babies")
    pcall(function() API.ChooseTeam:FireServer("Babies", {dont_respawn = true, source_for_logging = "avatar_editor"}) end)
    task.wait(2)
    return true
end

local function DoKeepPetEquipped()
    if not KeepPetEquipped or not API.Equip or not API.Unequip then return false end
    local eq = CD(DK.Equip) or {}
    local equipped = eq.pets or {}
    local hasFullGrown = false
    local hasGrowing = false
    for _, p in pairs(equipped) do
        local pr = p.properties or {}
        local age = tonumber(pr.age) or 1
        if age >= 6 then hasFullGrown = true else hasGrowing = true end
    end
    if hasGrowing then return true end
    if not hasFullGrown and next(equipped) == nil then
        -- No pet at all: try egg
        if AutoBuyEgg and os.time() - Cac.LastEggBuy > 30 then
            Cac.LastEggBuy = os.time()
            if API.BuyItem then pcall(function() API.BuyItem:InvokeServer("pets", EggToBuy, {buy_count = 1}) end); task.wait(2) end
        end
        return false
    end
    if not hasFullGrown then return true end
    local prefer = getgenv().YunoFocusKind
    local target = FindGrowingPet(prefer and {[prefer] = true} or nil)
    if not target then
        if AutoBuyEgg and os.time() - Cac.LastEggBuy > 30 then
            Cac.LastEggBuy = os.time()
            if API.BuyItem then pcall(function() API.BuyItem:InvokeServer("pets", EggToBuy, {buy_count = 1}) end); task.wait(2) end
            target = FindGrowingPet()
        end
    end
    if not target then return false end
    SetStatus("Pet swap: " .. target.kind)
    for _, p in pairs(equipped) do
        if (tonumber((p.properties or {}).age) or 1) >= 6 then
            pcall(function() API.Unequip:InvokeServer(p.unique) end)
            task.wait(1)
        end
    end
    pcall(function() API.Equip:InvokeServer(target.uid, {equip_as_last = true}) end)
    task.wait(2)
    return true
end

local function DoAgePotionTask()
    if not AutoPotions or not API.CreatePetObject or not API.ConsumeFoodObject then return false end
    local eq = CD(DK.Equip) or {}
    local equipped
    for _, p in pairs(eq.pets or {}) do
        local age = tonumber((p.properties or {}).age) or 1
        if age < 6 then equipped = p.unique; break end
    end
    if not equipped then return false end
    local inv = CD("inventory") or {}
    local potionList = { "pet_age_potion", "tiny_pet_age_potion" }
    local potion
    for uid, item in pairs(inv.food or {}) do
        local k = item.kind or item.id
        if table.find(potionList, k) and not PotionSkip[k] then potion = { unique = uid, id = k }; break end
    end
    if not potion then return false end
    SetStatus("Potion: " .. potion.id)
    pcall(function()
        local obj = API.CreatePetObject:InvokeServer("__Enum_PetObjectCreatorType_2", { pet_unique = equipped, unique_id = potion.unique })
        local model = obj and (obj:FindFirstChild("Model") or obj)
        if not model then
            local po = Workspace:FindFirstChild("PetObjects")
            if po then for _, c in ipairs(po:GetChildren()) do
                local iu = c:FindFirstChild("ItemUniqueId")
                if iu and iu.Value == potion.unique then model = c:FindFirstChild("Model") or c; break end
            end end
        end
        if model then API.ConsumeFoodObject:FireServer(model, equipped) end
    end)
    task.wait(2)
    return true
end

local function DoNeonTask(mega)
    local kind, list = FindFusionGroup(mega)
    if not kind or not list then return false end
    if not API.DoNeonFusion then return false end
    SetStatus((mega and "Mega" or "Neon") .. ": " .. kind)
    for _, uid in ipairs(list) do
        pcall(function() API.Equip:InvokeServer(uid, {equip_as_last = false, use_sound_delay = false}) end)
        task.wait(0.1)
        pcall(function() API.Unequip:InvokeServer(uid) end)
        task.wait(0.05)
    end
    local ok, resp = pcall(function() return API.DoNeonFusion:InvokeServer({list[1], list[2], list[3], list[4]}) end)
    PlaySound("success", 0.5)
    task.wait(3)
    Notify(mega and "Mega neon!" or "Neon fusion", kind)
    return true
end

local function DoPetPenTask()
    if not AutoPetPen then return false end
    if not IsInHouse() then if not GoToHouse() then return false end end
    local pen = CD(DK.PetPen)
    if not pen then return false end
    local eq = CD(DK.Equip) or {}
    local equipped = {}
    for _, p in pairs(eq.pets or {}) do equipped[p.unique] = true end
    -- Claim
    local before = {}
    for uid, p in pairs(pen.active_pets or {}) do before[uid] = tostring(p.xp_timestamp or "") end
    if API.ClaimProgression then
        pcall(function() API.ClaimProgression:InvokeServer(true) end)
        task.wait(3)
    end
    -- Remove grown, add growing
    local current = CountPenPets()
    if current < PenSlots then
        local growable = FindGrowingPet()
        if growable and not equipped[growable.uid] then
            if API.AddPet then
                pcall(function() API.AddPet:InvokeServer(growable.uid) end)
                task.wait(2)
                Notify("Pet Pen", "Added " .. growable.kind)
            end
        end
    end
    return true
end

local function DoCandyPetTask()
    if not AutoCandyPets then return false end
    local candy = tonumber(CD(DK.Candy)) or 0
    local buyOptions = { {id="halloween_2026_jump_scare", price=40000, max=1}, {id="halloween_2026_jacobean_pigeon", price=4000, max=4}, {id="halloween_2026_skelicorn", price=120000, max=0} }
    for _, opt in ipairs(buyOptions) do
        if not next(CandyPick) or CandyPick[opt.id] then
            if candy - CandyKeepCandy >= opt.price then
                SetStatus("Candy pet: buying " .. opt.id)
                local inv = CD("inventory") or {}
                local before = {}
                for uid in pairs(inv.pets or {}) do before[uid] = true end
                pcall(function() API.BuyItem:InvokeServer("pets", opt.id, {buy_count = 1}) end)
                task.wait(3)
                local fresh = CD("inventory") or {}
                for uid, p in pairs(fresh.pets or {}) do
                    if not before[uid] and tostring(p.kind or p.id) == opt.id then
                        Notify("Candy shop", opt.id); return true
                    end
                end
            end
        end
    end
    return false
end

local function DoAutoQuestsTask()
    if not AutoQuests then return false end
    local dm = CD(DK.Dailies)
    if not dm or not dm.serialized_tabs then return false end
    for _, tabName in ipairs(EV.QuestTabs) do
        local tab = dm.serialized_tabs[tabName]
        if tab then
            if tab.active_dailies then
                for _, d in pairs(tab.active_dailies) do
                    if d.state and d.state.steps_to_complete <= d.state.steps_completed then
                        if API.QuestClaimRemote then
                            pcall(function() API.QuestClaimRemote:FireServer(tabName) end)
                            task.wait(0.5)
                        end
                    end
                end
            end
            if tab.reward_claimed == false and ((tab.total_dailies_completed_today or 0) >= EV.QuestsPerBoardReward) then
                if API.QuestRewardRemote then
                    pcall(function() API.QuestRewardRemote:FireServer(tabName) end)
                    task.wait(0.5)
                end
            end
        end
    end
    return true
end

local function DoCashback()
    if not AutoCashback or not API.CollectCashback then return false end
    if os.time() - Cac.LastCashback < CashbackMins * 60 then return false end
    Cac.LastCashback = os.time()
    pcall(function() API.CollectCashback:FireServer() end)
    return true
end

local function DoGiftsTask()
    local inv = CD("inventory") or {}
    if not inv.gifts then return false end
    for uid, item in pairs(inv.gifts) do
        local id = item.id or item.kind or ""
        if API.Equip then pcall(function() API.Equip:InvokeServer(uid) end); task.wait(0.4) end
        if API.OpenGift and (id:match("gift$")) then
            pcall(function() API.OpenGift:InvokeServer(uid) end)
        elseif API.OpenChest and (id:match("_chest$")) then
            pcall(function() API.OpenChest:InvokeServer(id, uid) end)
        end
        task.wait(0.6)
        return true
    end
    return false
end

-- ══════════ v6.3 features preserved ══════════
local function DoGhostGallery()
    if not API.ShootGhost then return false end
    local gc = Workspace:FindFirstChild("GhostGallery") or Workspace:FindFirstChild("ActiveGhosts")
    if not gc then return false end
    SetStatus("GhostGallery: shooting...")
    local count = 0
    for _, ghost in ipairs(gc:GetChildren()) do
        if ghost:IsA("BasePart") or ghost:FindFirstChild("HumanoidRootPart") then
            pcall(function() API.ShootGhost:FireServer(ghost.Name) end)
            count = count + 1; task.wait(0.05)
        end
    end
    return count > 0
end

local ObbiesList = { "miniworld", "coastal_climb", "shipwreck_bay", "ancient_ruins", "lonelypeak", "pyramid", "tinyisles" }
local function DoAutoObbies()
    if not API.FinishObby then return false end
    SetStatus("Obbies: finishing...")
    for _, obby in ipairs(ObbiesList) do
        if not FarmEnabled then return false end
        if not ObbiesDone[obby] then
            pcall(function() API.FinishObby:FireServer(obby) end)
            ObbiesDone[obby] = true; task.wait(0.5)
        end
    end
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
local function DoHauntedHouse()
    local hauntlet = Workspace:FindFirstChild("HauntletMinigame") or Workspace:FindFirstChild("Minigames")
    if not hauntlet then return false end
    local hrp = GetHRP(); if not hrp then return false end
    SetStatus("HauntedHouse: finding door...")
    for _, zone in ipairs(hauntlet:GetChildren()) do
        local doorSet = zone:FindFirstChild("Doors") or zone:FindFirstChild("Gates")
        if doorSet then for _, door in ipairs(doorSet:GetChildren()) do
            if door:IsA("BasePart") then
                local trap = door:GetAttribute("Trap") or door:GetAttribute("IsFake")
                if trap == false or door.Transparency > 0 then hrp.CFrame = door.CFrame; task.wait(0.3); break end
            end
        end end
    end
    return true
end
local function DoStitchesSpot()
    local eventMap = Workspace:FindFirstChild("StitchesSpotlight") or Workspace:FindFirstChild("SpotlightGame")
    if not eventMap then return false end
    local candyDrops = eventMap:FindFirstChild("CandyCornDrops") or eventMap:FindFirstChild("Drops")
    local lights = eventMap:FindFirstChild("ActiveSpotlights") or Workspace:FindFirstChild("Spotlights")
    if not candyDrops then return false end
    local hrp = GetHRP(); if not hrp then return false end
    for _, candy in ipairs(candyDrops:GetChildren()) do
        if candy:IsA("BasePart") then
            local safe = true
            if lights then for _, beam in ipairs(lights:GetChildren()) do
                if beam:IsA("BasePart") and (candy.Position - beam.Position).Magnitude < 15 then safe = false; break end
            end end
            if safe then hrp.CFrame = candy.CFrame + Vector3.new(0, 3, 0); task.wait(0.1) end
        end
    end
    return true
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
    for _, food in ipairs(FREE_FOODS) do pcall(function() API.BuyItem:InvokeServer("food", food, {}) end); task.wait(0.3) end
    return true
end

local function DoTradeLicense()
    if not API.BeginTradeQuiz or not API.AnswerQuiz then return false end
    pcall(function() API.BeginTradeQuiz:InvokeServer() end); task.wait(0.5)
    local found = false
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "question_index") then
                if v.quiz then for _, q in pairs(v.quiz) do
                    if q.answer ~= nil then
                        pcall(function() API.AnswerQuiz:InvokeServer(q.answer) end); found = true; task.wait(0.3)
                    end
                end end
            end
        end
    end)
    if not found then for i = 1, 3 do pcall(function() API.AnswerQuiz:InvokeServer(true) end); task.wait(0.4) end end
    Notify("License", "Trade quiz done!"); return true
end

local function ClearAllPetRPNames()
    if not API.SetPetRP then return Notify("RP Clear", "Remote not found") end
    local inv = CD("inventory"); if not inv or not inv.pets then return end
    local count = 0
    for uid, p in pairs(inv.pets) do
        local pr = p.properties or {}
        if pr.rp_name and pr.rp_name ~= "" then
            if API.Equip then pcall(function() API.Equip:InvokeServer(uid, { use_sound = false }) end); task.wait(0.15) end
            pcall(function() API.SetPetRP:InvokeServer(uid, "") end)
            count = count + 1; task.wait(0.1)
        end
    end
    Notify("RP Clear", "Cleared " .. count .. " names")
end

local function AddVisualBucks(amount)
    local pg = LP:FindFirstChild("PlayerGui"); if not pg then return end
    local bia = pg:FindFirstChild("BucksIndicatorApp"); if not bia then return end
    local ci = bia:FindFirstChild("CurrencyIndicator"); if not ci then return end
    local c = ci:FindFirstChild("Container"); local al = c and c:FindFirstChild("Amount")
    if al then local cur = tonumber(string.gsub(al.Text, "%D", "")) or 0; al.Text = tostring(cur + amount) end
end

local function ProcessNeonCombine()
    if not AutoNeonCombine or not API.DoNeonFusion then return end
    if #CombineQueue == 0 then return end
    local inv = CD("inventory"); if not inv or not inv.pets then return end
    for _, kind in ipairs(CombineQueue) do
        local regular, neon = {}, {}
        for uid, p in pairs(inv.pets) do
            if (p.kind or p.id) == kind then
                local pr = p.properties or {}
                local age = pr.age or 1
                local isN, isM = pr.neon or pr.is_neon, pr.mega_neon or pr.is_mega
                if age == 6 and not isN and not isM then table.insert(regular, uid)
                elseif isN and not isM then table.insert(neon, uid) end
            end
        end
        if #regular >= 4 then
            SetStatus("Craft Neon "..kind)
            pcall(function() API.DoNeonFusion:InvokeServer({ regular[1], regular[2], regular[3], regular[4] }) end)
            task.wait(4)
        elseif CombineTargetMode == "MEGA" and #neon >= 4 then
            SetStatus("Craft Mega "..kind)
            pcall(function() API.DoNeonFusion:InvokeServer({ neon[1], neon[2], neon[3], neon[4] }) end)
            task.wait(4)
        end
    end
end

-- ══════════ SWF/Hatch/AgePot/FastMega (v6.3 preserved) ══════════
local function GetMaxSlots()
    local sub = CD("subscription_manager")
    if sub and sub.equip_2x_pets then
        local s = tostring(sub.equip_2x_pets.state):lower()
        if s ~= "neversubscribed" and s ~= "expired" and s ~= "canceled" then return 2 end
    end
    return 1
end
local function GetLockedUIDs()
    local ipm = CD(DK.PetPen); local locked = {}
    if ipm and ipm.active_pets then for uid in pairs(ipm.active_pets) do locked[uid] = true end end
    return locked
end

local function ProcessSWFQueue()
    if not SWFEnabled or not M.InventoryDB then return end
    local inv = CD("inventory"); if not inv or not inv.pets then return end
    local eq = CD(DK.Equip); if not eq then return end
    local maxSlots = GetMaxSlots(); local locked = GetLockedUIDs()
    local activePets = eq.pets or {}
    local activeUIDs = {}
    for _, p in ipairs(activePets) do activeUIDs[p.unique] = true end
    local valid = {}
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
                            valid[k] = valid[k] or {}; table.insert(valid[k], { uid = uid, age = age })
                        end
                    end
                end
            end
        end
    end
    for _, list in pairs(valid) do table.sort(list, function(a,b) return a.age > b.age end) end
    local sorted = {}; for k in pairs(valid) do table.insert(sorted, k) end; table.sort(sorted)
    local ideal, used = {}, {}
    for _, ap in ipairs(activePets) do
        for _, k in ipairs(sorted) do
            if used[k] and SwfSplitMode then break end
            for _, p in ipairs(valid[k]) do if p.uid == ap.unique then table.insert(ideal, ap.unique); used[k] = true; break end end
            if #ideal >= maxSlots then break end
        end
        if #ideal >= maxSlots then break end
    end
    if #ideal < maxSlots then
        for _, k in ipairs(sorted) do
            if not (SwfSplitMode and used[k]) then
                for _, p in ipairs(valid[k]) do if not table.find(ideal, p.uid) then table.insert(ideal, p.uid); used[k] = true; break end end
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
    if not AutoHatch or not M.InventoryDB then return end
    local inv = CD("inventory"); if not inv or not inv.pets then return end
    local eq = CD(DK.Equip); if not eq then return end
    local maxSlots = GetMaxSlots(); local locked = GetLockedUIDs()
    local activePets = eq.pets or {}
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
                if lim == 0 or hat < lim then available[k] = available[k] or {}; table.insert(available[k], uid); total = total + 1 end
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
    if not M.InventoryDB then return end
    local inv = CD("inventory"); if not inv or not inv.pets then return end
    local eq = CD(DK.Equip); if not eq then return end
    local maxSlots = GetMaxSlots(); local locked = GetLockedUIDs()
    local activePets = eq.pets or {}
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

local function RunTaskWithTimeout(kind, fn, maxTime)
    maxTime = maxTime or 60
    local done, success = false, false
    local co = coroutine.create(function() local ok, res = pcall(fn); success = ok and res; done = true end)
    local start = tick()
    while not done and tick() - start < maxTime do
        task.wait(0.3)
        if coroutine.status(co) == "suspended" then local ok = coroutine.resume(co); if not ok then break end end
        if not FarmEnabled then return false end
    end
    if not done then SetStatus(kind .. " TIMEOUT"); MarkFailed(kind); return false end
    return success
end

-- ══════════ MAIN LOOP (fusion) ══════════
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
            -- Priority list (fusion of v6.3 + v2)
            local priorities = {
                { "mystery",    DoMysteryTask, 90 },
                { "misery",     DoMysteryTask, 90 },
                { "pet_me",     DoPetMeTask, 40 },
                { "camping",    function() return DoQuestTask("camping", "MainMap", "Camping") end, 120 },
                { "bored",      function() return DoQuestTask("bored", "MainMap", "Playground") end, 120 },
                { "beach_party",function() return DoQuestTask("beach_party", "MainMap", "Beach") end, 120 },
                { "pool_party", DoPoolPartyTask, 120 },
                { "adoption_party", function() return DoQuestTask("adoption_party", "Nursery") end, 120 },
                { "salon",      function() return DoQuestTask("salon", "Salon") end, 120 },
                { "school",     function() return DoQuestTask("school", "School") end, 120 },
                { "pizza_party",function() return DoQuestTask("pizza_party", "PizzaShop") end, 120 },
                { "cat_cafe",   function() return DoQuestTask("cat_cafe", "CatCafe") end, 120 },
                { "sick",       DoSickTask, 90 },
                { "play",       DoPlayTask, 60 },
                { "hungry",     function() return DoFeedTask("hungry") end, 60 },
                { "thirsty",    function() return DoFeedTask("thirsty") end, 60 },
                { "walk",       DoWalkTask, 90 },
                { "ride",       DoRideTask, 90 },
                { "dirty",      function() return DoSleepDirtyTask("dirty") end, 90 },
                { "sleepy",     function() return DoSleepDirtyTask("sleepy") end, 90 },
                { "toilet",     DoToiletTask, 60 },
            }
            for _, e in ipairs(priorities) do
                if has(e[1]) then
                    if CanTry(e[1]) then
                        SetStatus(e[1] .. "...")
                        local ok2 = RunTaskWithTimeout(e[1], e[2], e[3])
                        if ok2 then ClearFailure(e[1]) end
                    else
                        local f = TaskFailures[e[1]]
                        local s = f and math.max(0, math.floor(FailCooldown - (tick() - f.time))) or FailCooldown
                        SetStatus(e[1] .. " retry " .. s .. "s")
                    end
                    return
                end
            end
            for _, w in ipairs({ "leaf_pile", "rain_puddle", "snow", "diving_board", "party_zone" }) do
                if has(w) then
                    if CanTry(w) then SetStatus(w); RunTaskWithTimeout(w, function() return DoWeatherTask(w) end, 90) end
                    return
                end
            end
            SetStatus("Idle")
        end)
        if not ok then SetStatus("Error: " .. tostring(err)) end
    end
end)

-- Halloween loop
task.spawn(function()
    while task.wait(15) do
        if not HalloweenEnabled then continue end
        if not EventNet then continue end
        pcall(function()
            if AutoCandyPets then DoCandyPetTask() end
            if AutoCrypt then DoCryptTask() end
            if AutoPigeonNest then DoPigeonNestTask() end
            if AutoSkelicorn then DoSkelicornTask() end
            if AutoStrayCat then DoStrayCatTask() end
            if HalloweenCandy then DoCandyClaim() end
            if HalloweenGhost then DoGhostCluster() end
        end)
    end
end)

-- Utility loops
task.spawn(function() while task.wait(3) do if FarmEnabled and AutoQuestClaim then pcall(DoAutoQuestsTask) end end end)
task.spawn(function() while task.wait(5) do if FarmEnabled and AutoOpenGifts then pcall(DoGiftsTask) end end end)
task.spawn(function() while task.wait(30) do if FarmEnabled then
    if Auto2DTuesdays then local adnet = EventNet; local dm = CD(DK.Dailies)
        if adnet and dm and dm.serialized_tabs and dm.serialized_tabs["2d_tuesdays"] then
            local tab = dm.serialized_tabs["2d_tuesdays"]
            if API.QuestClaimRemote then
                for _, d in pairs(tab.active_dailies or {}) do
                    if d.state and d.state.steps_to_complete <= d.state.steps_completed then
                        pcall(function() API.QuestClaimRemote:FireServer("2d_tuesdays") end); task.wait(0.5)
                    end
                end
            end
        end
    end
    if AutoHalloweenQuests then local dm = CD(DK.Dailies)
        if dm and dm.serialized_tabs and dm.serialized_tabs["halloween_2026"] then
            local tab = dm.serialized_tabs["halloween_2026"]
            if API.QuestClaimRemote then
                for _, d in pairs(tab.active_dailies or {}) do
                    if d.state and d.state.steps_to_complete <= d.state.steps_completed then
                        pcall(function() API.QuestClaimRemote:FireServer("halloween_2026") end); task.wait(0.5)
                    end
                end
            end
        end
    end
end end)
task.spawn(function() while task.wait(30) do
    if AutoDailyReward then pcall(DoAutoDailyReward) end
    if AutoFreeFood then pcall(DoAutoFreeFood) end
    if VisualBucksLoop then pcall(function() AddVisualBucks(VisualBucksAmount) end) end
    if AutoTradeLicense then pcall(DoTradeLicense) end
end end)
task.spawn(function() while task.wait(5) do
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
end end)
task.spawn(function() while task.wait(2.5) do
    if not FarmEnabled then continue end
    pcall(function()
        if AutoHatch then ProcessHatchQueue() end
        if SWFEnabled and not AutoHatch then ProcessSWFQueue() end
        if AutoAgePot then ProcessAgePotQueue() end
        if AutoNeonCombine then ProcessNeonCombine() end
        if AutoPotions then DoAgePotionTask() end
        if KeepPetEquipped then DoKeepPetEquipped() end
        if AutoTeam then DoTeamSwitch() end
        if AutoNeonFuse then DoNeonTask(false) end
        if AutoMegaFuse then DoNeonTask(true) end
        if AutoPetPen then DoPetPenTask() end
        if AutoCashback then DoCashback() end
        if AutoQuests then DoAutoQuestsTask() end
        if AutoHauntlet then DoHauntletTask() end
    end)
end end)

-- Anti-stuck
task.spawn(function() while task.wait(2) do
    if not FarmEnabled then TaskFailTrack.time = 0; continue end
    pcall(function()
        local eq = CD(DK.Equip) or {}
        local wrappers = CD(DK.PetWrappers) or {}
        if eq.pets then
            local ghost = false
            for _, ap in ipairs(eq.pets) do
                local has = false
                for _, w in pairs(wrappers) do if w.pet_unique == ap.unique and w.char and w.char.Parent then has = true; break end end
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
            if eq.pets then
                for _, ap in ipairs(eq.pets) do if API.Unequip then pcall(function() API.Unequip:InvokeServer(ap.unique) end) end end
                task.wait(1.5)
                for _, ap in ipairs(eq.pets) do if API.Equip then pcall(function() API.Equip:InvokeServer(ap.unique, { equip_as_last = true }) end) end end
            end
            TaskFailTrack.time = 0
        end
    end)
end end)

-- Graphics on unfocus
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

-- ══════════ TABS ══════════
AddTab("7733960981", "Home", function(page)
    Make("TextLabel", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "Yuno Farm v7.0", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = page })
    local sc = Make("Frame", { Size = UDim2.new(1, 0, 0, 130), BackgroundColor3 = Theme.Section, BackgroundTransparency = 0.3, Parent = page })
    Make("UICorner", { CornerRadius = UDim.new(0, 10), Parent = sc })
    local lbl = Make("TextLabel", { Size = UDim2.new(1, -30, 0, 20), Position = UDim2.new(0, 15, 0, 12), BackgroundTransparency = 1, Text = "Status: Idle", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = sc })
    Flags.__statusLbl = lbl
    local info = Make("TextLabel", { Size = UDim2.new(1, -30, 0, 16), Position = UDim2.new(0, 15, 0, 32), BackgroundTransparency = 1, Text = "-", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = sc })
    local loc = Make("TextLabel", { Size = UDim2.new(1, -30, 0, 16), Position = UDim2.new(0, 15, 0, 50), BackgroundTransparency = 1, Text = "-", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = sc })
    local info2 = Make("TextLabel", { Size = UDim2.new(1, -30, 0, 16), Position = UDim2.new(0, 15, 0, 68), BackgroundTransparency = 1, Text = "-", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = sc })
    Make("TextLabel", { Size = UDim2.new(1, -30, 0, 16), Position = UDim2.new(0, 15, 0, 90), BackgroundTransparency = 1, Text = "💡 RightCtrl = minimize", Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = sc })
    task.spawn(function()
        while task.wait(1) do
            if not sc.Parent then break end
            local am = CD(DK.Ailments)
            local petNeeds, babyNeeds = 0, 0
            if am then
                if am.baby_ailments then for _ in pairs(am.baby_ailments) do babyNeeds = babyNeeds + 1 end end
                if am.ailments then for _, p in pairs(am.ailments) do for _ in pairs(p) do petNeeds = petNeeds + 1 end end end
            end
            info.Text = string.format("🐾 %d pet needs • 🍼 %d baby needs", petNeeds, babyNeeds)
            loc.Text = "Loc: " .. tostring(Cac.CurrentLocation)
            info2.Text = string.format("🎮 Mini: %s • 🎃 HW: %s • 👻 Hauntlet: %s", MiniGamesEnabled and "ON" or "OFF", HalloweenEnabled and "ON" or "OFF", AutoHauntlet and "ON" or "OFF")
        end
    end)
    UI.Button(page, { Name = "🏠 Test: Enter House", Callback = function() Notify("House", GoToHouse() and "Entered!" or "Failed") end })
end)

AddTab("6908632622", "AutoFarm", function(page)
    UI.Section(page, "Master")
    UI.Toggle(page, { Name = "🚜 Farm Master", Flag = "YF_FarmMaster", Description = "Toggle everything", Callback = function(v) FarmEnabled = v end })
    UI.Toggle(page, { Name = "🐕 Pet Farm", Flag = "YF_PetFarm", Callback = function(v) PetFarmEnabled = v; AutoPetNeeds = v end })
    UI.Toggle(page, { Name = "🍼 Baby Farm", Flag = "YF_BabyFarm", Callback = function(v) BabyFarmEnabled = v; AutoBabyNeeds = v; if v then AutoTeam = true end end })
    UI.Toggle(page, { Name = "👥 Auto Team (Babies)", Flag = "YF_Team", Callback = function(v) AutoTeam = v end })
    UI.Section(page, "Smart")
    UI.Toggle(page, { Name = "🧠 Smart Priority", Flag = "YF_SmartP", Default = true, Callback = function(v) SmartPriority = v end })
    UI.Toggle(page, { Name = "🛡 Stuck Recovery", Flag = "YF_Stuck", Default = true, Callback = function(v) AutoStuckRecovery = v end })
    UI.Toggle(page, { Name = "🔁 Auto Rejoin", Flag = "YF_Rejoin", Callback = function(v) AutoRejoin = v end })
    UI.Section(page, "Pets")
    UI.Toggle(page, { Name = "🔒 Keep Growing Pet", Flag = "YF_KeepPet", Description = "Swap full grown for growing", Callback = function(v) KeepPetEquipped = v end })
    UI.Toggle(page, { Name = "🥚 Buy Egg If None Grows", Flag = "YF_BuyEgg", Callback = function(v) AutoBuyEgg = v end })
    UI.Dropdown(page, { Name = "Egg to Buy", Flag = "YF_EggBuy", Options = { "cracked_egg", "pet_egg", "fairytale_egg_2026_fairytale_egg" }, Default = "cracked_egg", Callback = function(v) EggToBuy = v end })
    UI.Dropdown(page, { Name = "Pet Order", Flag = "YF_PetOrder", Options = { "youngest", "oldest" }, Default = "youngest", Callback = function(v) PetOrderMode = v end })
    UI.Toggle(page, { Name = "✨ Prefer Neon", Flag = "YF_PrefNeon", Default = true, Callback = function(v) PreferNeon = v end })
    UI.Section(page, "Food")
    UI.Toggle(page, { Name = "💧 Auto Buy Water", Flag = "YF_BuyWater", Default = true, Callback = function(v) AutoBuyWater = v end })
    UI.Toggle(page, { Name = "🍔 Auto Buy Food", Flag = "YF_BuyFood", Default = true, Callback = function(v) AutoBuyFood = v end })
    UI.Section(page, "Potions & Fusion")
    UI.Toggle(page, { Name = "🧪 Auto Age Potion", Flag = "YF_Potion", Callback = function(v) AutoPotions = v end })
    UI.Toggle(page, { Name = "🌈 Auto Neon Fusion", Flag = "YF_Neon", Callback = function(v) AutoNeonFuse = v end })
    UI.Toggle(page, { Name = "💎 Auto Mega Neon", Flag = "YF_Mega", Callback = function(v) AutoMegaFuse = v end })
    UI.Section(page, "Tools")
    UI.Button(page, { Name = "🩹 Force Heal (Sick)", Callback = function()
        if API.HealWithDoctor then for i = 1, 5 do pcall(function() API.HealWithDoctor:FireServer() end); task.wait(0.5) end; Notify("Sick", "Heal sent!") end
    end })
    UI.Button(page, { Name = "🔄 Reset Task Failures", Callback = function() TaskFailures = {}; Notify("Yuno", "Cleared") end })
    UI.Button(page, { Name = "🗑 Destroy Platform", Callback = function() if Cac.AilmentPlatform then Cac.AilmentPlatform:Destroy(); Cac.AilmentPlatform = nil end end })
end)

AddTab("128557027005598", "Advanced", function(page)
    UI.Section(page, "SWF (Selected Pet Farm)")
    UI.Toggle(page, { Name = "SWF Enabled", Flag = "YF_SWF", Callback = function(v) SWFEnabled = v end })
    UI.Dropdown(page, { Name = "SWF Mode", Flag = "YF_SWFMode", Options = { "Regular", "Neon" }, Default = "Regular", Callback = function(v) SwfMode = v end })
    UI.Toggle(page, { Name = "Split Mode", Flag = "YF_SWFSplit", Callback = function(v) SwfSplitMode = v end })
    UI.Section(page, "Auto Hatch")
    UI.Toggle(page, { Name = "🥚 Auto Hatch Eggs", Flag = "YF_AutoHatch", Callback = function(v) AutoHatch = v end })
    UI.Section(page, "Age-Pot Farm")
    UI.Toggle(page, { Name = "🧪 Auto Age-Pot Farm", Flag = "YF_AgePot", Callback = function(v) AutoAgePot = v end })
    UI.Section(page, "Fast Mega")
    UI.Toggle(page, { Name = "⚡ Fast Mega Enabled", Flag = "YF_FastMega", Callback = function(v) FastMegaEnabled = v end })
    UI.Toggle(page, { Name = "Fast Mega Pipeline", Flag = "YF_FastPipe", Callback = function(v) FastMegaPipeline = v end })
    UI.Dropdown(page, { Name = "Fast Mega Mode", Flag = "YF_FMMode", Options = { "Neon", "Mega" }, Default = "Neon", Callback = function(v) FastMegaMode = v end })
    UI.Toggle(page, { Name = "Farm Pots on Low", Flag = "YF_FarmPots", Callback = function(v) FastMegaFarmPots = v end })
    UI.Section(page, "Pet Pen")
    UI.Toggle(page, { Name = "🚪 Auto Pet Pen", Flag = "YF_Pen", Callback = function(v) AutoPetPen = v end })
    UI.Slider(page, { Name = "Pen Slots", Flag = "YF_PenSlots", Min = 4, Max = 5, Default = 4, Callback = function(v) PenSlots = v end })
    UI.Toggle(page, { Name = "🛒 Keep Pen Full (buy eggs)", Flag = "YF_PenStock", Callback = function(v) PenStock = v end })
    UI.Slider(page, { Name = "Min Bucks for Stock", Flag = "YF_PenMin", Min = 0, Max = 5000, Default = 750, Callback = function(v) PenMinBucks = v end })
    UI.Section(page, "Cashback & Gifts")
    UI.Toggle(page, { Name = "💰 Collect Cashback", Flag = "YF_Cashback", Callback = function(v) AutoCashback = v end })
    UI.Slider(page, { Name = "Cashback Every (min)", Flag = "YF_CashMin", Min = 1, Max = 60, Default = 10, Callback = function(v) CashbackMins = v end })
    UI.Toggle(page, { Name = "🎁 Auto Open Gifts", Flag = "YF_Gifts", Callback = function(v) AutoOpenGifts = v end })
end)

AddTab("13549782519", "Mini-Games", function(page)
    UI.Section(page, "Auto-Farm")
    UI.Toggle(page, { Name = "🎮 Enable Mini-Games", Flag = "YF_MiniMaster", Callback = function(v) MiniGamesEnabled = v end })
    UI.Toggle(page, { Name = "🏃 Auto Obbies", Flag = "YF_AutoObbies", Description = "Finish all 7 obbies", Callback = function(v) AutoObbies = v; if not v then ObbiesDone = {} end end })
    UI.Toggle(page, { Name = "Auto Spleef", Flag = "YF_Spleef", Callback = function(v) AutoSpleef = v end })
    UI.Toggle(page, { Name = "Auto Simon Says", Flag = "YF_SimonSays", Callback = function(v) AutoSimonSays = v end })
    UI.Toggle(page, { Name = "🏰 Auto Winter Castle", Flag = "YF_WinterCastle", Callback = function(v) AutoWinterCastle = v end })
    UI.Section(page, "Bonus (Halloween)")
    UI.Toggle(page, { Name = "👻 Auto Ghost Gallery", Flag = "YF_GhostGallery", Callback = function(v) AutoGhostGallery = v end })
    UI.Toggle(page, { Name = "🏚 Auto Haunted House", Flag = "YF_HauntedHouse", Callback = function(v) AutoHauntedHouse = v end })
    UI.Toggle(page, { Name = "🍬 Auto Stitches Spotlight", Flag = "YF_StitchesSpot", Callback = function(v) AutoStitchesSpot = v end })
    UI.Section(page, "Quick Actions")
    UI.Button(page, { Name = "🎯 Finish All Obbies", Callback = function() if API.FinishObby then DoAutoObbies(); Notify("Obbies", "Sent!") end end })
    UI.Button(page, { Name = "🎮 Enter Spleef", Callback = function() task.spawn(DoSpleefMinigame) end })
    UI.Button(page, { Name = "🎮 Enter Simon Says", Callback = function() task.spawn(DoSimonSaysMinigame) end })
    UI.Button(page, { Name = "🏰 Enter Winter Castle", Callback = function() task.spawn(DoWinterCastle) end })
end)

AddTab("128544079472562", "Halloween", function(page)
    UI.Section(page, "Halloween Farm")
    UI.Toggle(page, { Name = "🎃 Enable Halloween", Flag = "YF_HWMaster", Callback = function(v) HalloweenEnabled = v; if v then ApplyTheme("Halloween") end end })
    UI.Toggle(page, { Name = "🕷 Auto Crypt", Flag = "YF_HWCrypt", Callback = function(v) AutoCrypt = v end })
    UI.Toggle(page, { Name = "🕸 Auto Mummy Spider", Flag = "YF_HWMummy", Default = true, Callback = function(v) AutoMummySpider = v end })
    UI.Toggle(page, { Name = "🪵 Auto Pigeon Nest", Flag = "YF_HWNest", Callback = function(v) AutoPigeonNest = v end })
    UI.Toggle(page, { Name = "🪵 Auto Nest (build)", Flag = "YF_HWAutoNest", Callback = function(v) AutoNest = v end })
    UI.Toggle(page, { Name = "🍬 Auto Candy Corn Claim", Flag = "YF_HWCandy", Callback = function(v) HalloweenCandy = v end })
    UI.Toggle(page, { Name = "👻 Auto Ghost Cluster", Flag = "YF_HWGhost", Callback = function(v) HalloweenGhost = v end })
    UI.Section(page, "Skelicorn & Candy Pets")
    UI.Toggle(page, { Name = "🦄 Auto Skelicorn", Flag = "YF_HWSkel", Callback = function(v) AutoSkelicorn = v end })
    UI.Toggle(page, { Name = "🍭 Auto Candy Pets", Flag = "YF_HWCandyPets", Callback = function(v) AutoCandyPets = v end })
    UI.Toggle(page, { Name = "Max Buy (all at once)", Flag = "YF_CandyMax", Callback = function(v) CandyMaxBuy = v end })
    UI.Slider(page, { Name = "Keep Candy", Flag = "YF_CandyKeep", Min = 0, Max = 500000, Default = 0, Callback = function(v) CandyKeepCandy = v end })
    UI.Section(page, "Hauntlet")
    UI.Toggle(page, { Name = "👻 Auto Hauntlet", Flag = "YF_Hauntlet", Callback = function(v) AutoHauntlet = v end })
    UI.Toggle(page, { Name = "Hauntlet Before Ghost Gallery", Flag = "YF_HauntFirst", Default = true, Callback = function(v) HauntletFirst = v end })
    UI.Dropdown(page, { Name = "Door Move", Flag = "YF_HauntMove", Options = { "tween", "walk", "tp" }, Default = "tween", Callback = function(v) HauntletMove = v end })
    UI.Slider(page, { Name = "Move Time (s)", Flag = "YF_HauntSec", Min = 1, Max = 50, Default = 5, Callback = function(v) HauntletMoveSec = v / 10 end })
    UI.Section(page, "Stray Cat")
    UI.Toggle(page, { Name = "🐱 Auto Stray Cat", Flag = "YF_StrayCat", Callback = function(v) AutoStrayCat = v end })
    UI.Section(page, "Quick Actions")
    UI.Button(page, { Name = "🍬 Claim Candy Now", Callback = function() task.spawn(DoCandyClaim) end })
    UI.Button(page, { Name = "🪵 Place Twigs Now", Callback = function() task.spawn(DoPigeonNestTask) end })
    UI.Button(page, { Name = "🕷 Enter Crypt Now", Callback = function() task.spawn(DoCryptTask) end })
    UI.Button(page, { Name = "👻 Ghost Cluster Now", Callback = function() task.spawn(DoGhostCluster) end })
    UI.Button(page, { Name = "🦄 Skelicorn Now", Callback = function() task.spawn(DoSkelicornTask) end })
    UI.Button(page, { Name = "🚪 Hauntlet Now", Callback = function() task.spawn(DoHauntletTask) end })
end)

AddTab("135780702746673", "Utilities", function(page)
    UI.Section(page, "Auto Claim")
    UI.Toggle(page, { Name = "📜 Auto Quest Claim", Flag = "YF_AutoQuest", Callback = function(v) AutoQuestClaim = v end })
    UI.Toggle(page, { Name = "📅 Auto 2D Tuesdays", Flag = "YF_Auto2D", Callback = function(v) Auto2DTuesdays = v end })
    UI.Toggle(page, { Name = "🎃 Auto Halloween Quests", Flag = "YF_AutoHW", Callback = function(v) AutoHalloweenQuests = v end })
    UI.Section(page, "Trade & Gifts")
    UI.Toggle(page, { Name = "📜 Auto Trade License", Flag = "YF_AutoLicense", Callback = function(v) AutoTradeLicense = v end })
    UI.Button(page, { Name = "📜 Get License Now", Callback = function() task.spawn(DoTradeLicense) end })
    UI.Section(page, "Pet Utilities")
    UI.Button(page, { Name = "🗑 Clear All Pet RP Names", Callback = function() task.spawn(ClearAllPetRPNames) end })
    UI.Toggle(page, { Name = "💵 Visual Bucks Loop", Flag = "YF_VisBucks", Callback = function(v) VisualBucksLoop = v end })
    UI.Section(page, "Auto Neon Combine (v6.3)")
    UI.Toggle(page, { Name = "✨ Auto Neon/Mega Combine", Flag = "YF_AutoNeon", Callback = function(v) AutoNeonCombine = v end })
    UI.Dropdown(page, { Name = "Combine Target", Flag = "YF_CombineMode", Options = { "NEON", "MEGA" }, Default = "NEON", Callback = function(v) CombineTargetMode = v end })
    UI.Section(page, "Potion Feeder (v6.3)")
    UI.Toggle(page, { Name = "🧪 Potion Feeder", Flag = "YF_Feeder", Callback = function(v) PotionFeederEnabled = v end })
    UI.Toggle(page, { Name = "Feed Until FullGrown", Flag = "YF_FeedFG", Default = true, Callback = function(v) FeederUntilFG = v end })
end)

AddTab("135780702746673", "Shop", function(page)
    UI.Toggle(page, { Name = "🎁 Auto Daily Reward", Flag = "YF_AutoDaily", Callback = function(v) AutoDailyReward = v end })
    UI.Toggle(page, { Name = "🍎 Auto Free Food", Flag = "YF_AutoFreeFood", Callback = function(v) AutoFreeFood = v end })
end)

AddTab("7734053495", "Settings", function(page)
    UI.Dropdown(page, { Name = "Theme", Flag = "YF_Theme", Options = { "Yuno", "Dark", "Light", "Galaxy", "Emerald", "Halloween" }, Default = ThemeName, Callback = ApplyTheme })
    UI.Slider(page, { Name = "UI Scale %", Flag = "YF_Scale", Min = 40, Max = 150, Default = math.floor((getgenv().YunoScale or 1) * 100), Callback = function(v) getgenv().YunoScale = v / 100; mainScale.Scale = v / 100 end })
    UI.Section(page, "Sound")
    UI.Toggle(page, { Name = "🔊 UI Sounds", Flag = "YF_SndUI", Default = true, Callback = function(v) SoundEnabled = v end })
    UI.Toggle(page, { Name = "🎵 Ambient Music (ASMR)", Flag = "YF_SndAmbient", Callback = function(v)
        AmbientEnabled = v
        if v then PlaySound("ambient", 0.15) else local s = SoundCache["ambient"]; if s then s:Stop() end end
    end })
    UI.Section(page, "Performance")
    UI.Toggle(page, { Name = "🎨 Lower Graphics on Unfocus", Flag = "YF_LowerGFX", Callback = function(v) LowerGraphicsWhenUnfocused = v end })
    UI.Section(page, "Advanced Timing")
    UI.Slider(page, { Name = "Fail Cooldown (s)", Flag = "YF_FailCD", Min = 5, Max = 120, Default = 30, Callback = function(v) FailCooldown = v end })
    UI.Slider(page, { Name = "Max Failures", Flag = "YF_MaxFail", Min = 1, Max = 10, Default = 3, Callback = function(v) MaxFailures = v end })
    UI.Slider(page, { Name = "Disable After (min)", Flag = "YF_DisableMin", Min = 0, Max = 60, Default = 15, Callback = function(v) DisableMins = v end })
    UI.Button(page, { Name = "💥 Destroy Script", Callback = function()
        if Cac.AilmentPlatform then Cac.AilmentPlatform:Destroy() end
        if screenGui then screenGui:Destroy() end
    end })
end)

if tabs[1] then tabs[1].btn.MouseButton1Click:Fire() end
mainFrame.Visible = true
mainScale.Scale = (getgenv().YunoScale or (IS_MOBILE and 0.62 or 1))

task.delay(1, function()
    Notify("Yuno v7.0", "Ultimate Fusion ready ✅", 5)
end)

print("═══════════════════════════════════════════")
print("[Yuno] ✅ v7.0 ULTIMATE FUSION READY")
print("[Yuno] ✅ Pet Farm complet + Baby Farm")
print("[Yuno] ✅ Hauntlet + Skelicorn + Pigeon Nest + Pet Pen")
print("[Yuno] ✅ Crypt + Mummy Spider + Candy Pets")
print("[Yuno] ✅ Age Potions + Neon/Mega Fusion + Keep Pet")
print("[Yuno] ✅ Team + Cashback + Quests + House Visits")
print("[Yuno] ✅ Tous les v6.3 conservés (UI, minigames, SWF, hatch)")
print("═══════════════════════════════════════════")