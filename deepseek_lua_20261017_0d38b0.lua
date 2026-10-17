--[[
    ============================================================
      ADOPT ME TRADE CALCULATOR  —  Delta Executor
      Version Mobile (Elvebredd / AMVGG Style)
    ============================================================
]]

local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")

local BASE_URL         = "https://elvebredd-api.onrender.com"
local REFRESH_SECONDS  = 120

-- ================= IMAGES DES PETS (ASSET IDs) =================
-- Ajoute ou modifie les IDs ici. 
-- J'ai mis les plus populaires pour que tu aies un beau rendu direct.
local PET_IMAGE_IDS = {
    ["Shadow Dragon"] = 10683341548,
    ["Bat Dragon"] = 8673880317,
    ["Frost Dragon"] = 5166226493,
    ["Giraffe"] = 5166227300,
    ["Owl"] = 8673885987,
    ["Parrot"] = 5166227911,
    ["Crow"] = 8673887683,
    ["Evil Unicorn"] = 5166225849,
    ["Arctic Reindeer"] = 5166224796,
    ["Kangaroo"] = 5166226894,
    ["Turtle"] = 5166229124,
    ["Unicorn"] = 5166227976,
    ["Dragon"] = 5166225561,
    ["Griffin"] = 5166226753,
    ["Cerberus"] = 10683337859,
    ["Queen Bee"] = 8673886682,
    ["King Bee"] = 8673886033,
    ["Albino Monkey"] = 8673881304,
    ["Golden Penguin"] = 10683341097,
    ["Guardian Lion"] = 10683341442,
    ["Metal Ox"] = 10683343044,
    ["Ninja Monkey"] = 10683343708,
    ["Skeleton T-Rex"] = 10683344049,
    ["Zombie Buffalo"] = 10683344706,
    ["T-Rex"] = 10683344983,
    ["Dodo"] = 10683339622,
    ["Snow Owl"] = 10683344300,
    ["Robo Dog"] = 10683344099,
    ["Golden Unicorn"] = 10683340931,
    ["Golden Dragon"] = 10683340592,
    ["Golden Griffin"] = 10683340780,
    ["Golden Rat"] = 10683341192,
}
-- ===============================================================

-- ================= THEME (Elvebredd / AMVGG) =================
local THEME = {
    bg          = Color3.fromRGB(248, 247, 245), -- Blanc cassé / Beige très clair
    panel       = Color3.fromRGB(255, 255, 255), -- Blanc pur
    card        = Color3.fromRGB(252, 252, 252),
    stroke      = Color3.fromRGB(225, 223, 220), -- Gris clair pour les bordures
    text        = Color3.fromRGB(30, 30, 30),    -- Presque noir
    sub         = Color3.fromRGB(130, 130, 130), -- Gris
    accent      = Color3.fromRGB(255, 85, 85),   -- Rouge/Corail (Style Elvebredd)
    win         = Color3.fromRGB(75, 200, 120),  -- Vert
    fair        = Color3.fromRGB(255, 180, 50),  -- Jaune/Orange
    lose        = Color3.fromRGB(255, 85, 85),   -- Rouge
    your        = Color3.fromRGB(85, 150, 255),  -- Bleu
    their       = Color3.fromRGB(230, 100, 180), -- Rose
}

-- ================= STATE =================
local petData       = {}
local petIndex      = {}
local yourOffer     = {}
local theirOffer    = {}
local currentFilter = ""
local currentTab    = "Pets" -- "Pets" ou "Trade"
local currentTier   = "Regular"
local currentPotion = "np" 
local currentModal  = nil
local mainGui       = nil
local uiRefs        = {}

-- ================= HELPERS =================
local function create(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function addCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.stroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function fmt(n)
    if n == nil then return "N/A" end
    if n >= 1e9 then return string.format("%.2fB", n/1e9) end
    if n >= 1e6 then return string.format("%.2fM", n/1e6) end
    if n >= 1e3 then return string.format("%.1fK", n/1e3) end
    if n == math.floor(n) then return tostring(math.floor(n)) end
    return string.format("%.1f", n)
end

local TIER_KEYS  = {Regular = "regular", Neon = "neon", Mega = "mega"}
local POTION_KEYS= {FR = "fr", NP = "np", R = "r", F = "f"}

local function lookupValue(petName, tier, potion)
    local p = petIndex[petName]
    if not p then return nil end
    local t = p[TIER_KEYS[tier]]
    if not t then return nil end
    return t[POTION_KEYS[potion]]
end

local function rebuildIndex()
    petIndex = {}
    for _, p in ipairs(petData) do
        if p.name then petIndex[p.name] = p end
    end
end

-- ================= HTTP =================
local function httpGet(url)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local ok, res = pcall(req, {Url = url, Method = "GET"})
        if ok and res and res.Body and res.Body ~= "" then return res.Body end
    end
    local ok, res = pcall(function() return HttpService:GetAsync(url) end)
    if ok then return res end
    return nil
end

local function fetchPets(retries)
    retries = retries or 3
    for _ = 1, retries do
        local body = httpGet(BASE_URL .. "/api/pets")
        if body then
            local ok, data = pcall(HttpService.JSONDecode, HttpService, body)
            if ok and type(data) == "table" and #data > 0 then return data end
        end
        task.wait(2)
    end
    return nil
end

-- ================= UI COMPONENTS =================
local function refreshPetList()
    local scroll = uiRefs.petScroll
    if not scroll then return end
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end

    local filter = string.lower(currentFilter)
    local sorted = {}
    for _, p in ipairs(petData) do
        if filter == "" or string.find(string.lower(p.name), filter, 1, true) then
            table.insert(sorted, p)
        end
    end
    table.sort(sorted, function(a, b)
        local av = lookupValue(a.name, currentTier, currentPotion) or 0
        local bv = lookupValue(b.name, currentTier, currentPotion) or 0
        return av > bv
    end)

    for i, p in ipairs(sorted) do
        local val = lookupValue(p.name, currentTier, currentPotion)
        
        local cell = create("TextButton", {
            Name = "Cell_" .. p.name,
            BackgroundColor3 = THEME.card,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 80, 0, 100),
            LayoutOrder = i,
            Text = "",
            AutoButtonColor = false,
        }, scroll)
        addCorner(cell, 12)
        addStroke(cell, THEME.stroke)

        local badge = create("Frame", {
            BackgroundColor3 = THEME.panel,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 60, 0, 60),
            Position = UDim2.new(0.5, -30, 0, 6),
        }, cell)
        addCorner(badge, 8)

        local imgId = PET_IMAGE_IDS[p.name]
        if imgId then
            create("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Image = "rbxassetid://" .. imgId,
                ScaleType = Enum.ScaleType.Fit,
            }, badge)
        else
            create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = string.sub(p.name, 1, 1),
                TextColor3 = THEME.sub,
                Font = Enum.Font.GothamBold,
                TextScaled = true,
            }, badge)
        end

        create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 2, 0, 68),
            Size = UDim2.new(1, -4, 0, 14),
            Text = p.name,
            TextColor3 = THEME.text,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, cell)

        create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 2, 0, 82),
            Size = UDim2.new(1, -4, 0, 14),
            Text = fmt(val),
            TextColor3 = THEME.accent,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
        }, cell)

        cell.MouseButton1Click:Connect(function()
            uiRefs.showModal(p.name)
        end)
    end
end

local function refreshTradeUI()
    -- Construction de la liste "Ton Offre"
    local function buildOffer(offer, scroll, sideColor)
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local total = 0
        for i, e in ipairs(offer) do
            local v = lookupValue(e.name, e.tier, e.potion)
            total = total + (v or 0)

            local row = create("Frame", {
                BackgroundColor3 = THEME.card,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -4, 0, 36),
                LayoutOrder = i,
            }, scroll)
            addCorner(row, 6)
            addStroke(row, THEME.stroke, 1)

            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = e.name .. " (" .. e.tier .. " " .. e.potion .. ")",
                TextColor3 = THEME.text,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, row)

            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -60, 0, 0),
                Size = UDim2.new(0, 50, 1, 0),
                Text = fmt(v),
                TextColor3 = sideColor,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Right,
            }, row)

            local x = create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -24, 0.5, -12),
                Text = "×",
                TextColor3 = THEME.lose,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
            }, row)
            x.MouseButton1Click:Connect(function()
                table.remove(offer, i)
                refreshTradeUI()
            end)
        end
        return total
    end

    local yt = buildOffer(yourOffer, uiRefs.yourScroll, THEME.your)
    local tt = buildOffer(theirOffer, uiRefs.theirScroll, THEME.their)

    uiRefs.yourTotal.Text = "Total: " .. fmt(yt)
    uiRefs.theirTotal.Text = "Total: " .. fmt(tt)

    -- Mise à jour du Résultat
    if yt == 0 and tt == 0 then
        uiRefs.resultLabel.Text = "Waiting..."
        uiRefs.resultLabel.TextColor3 = THEME.sub
        uiRefs.resultDiff.Text = "Ajoute des pets pour voir le résultat"
        return
    end

    local diff = tt - yt
    local ref  = math.max(yt, tt)
    local pct  = ref > 0 and (diff / ref) * 100 or 0

    local color, label
    if math.abs(pct) < 10 then
        color, label = THEME.fair, "FAIR"
    elseif diff > 0 then
        color, label = THEME.win, "WIN"
    else
        color, label = THEME.lose, "LOSE"
    end

    uiRefs.resultLabel.Text = label
    uiRefs.resultLabel.TextColor3 = color
    uiRefs.resultDiff.Text = string.format("Diff: %s%s (%.1f%%)", diff >= 0 and "+" or "-", fmt(math.abs(diff)), math.abs(pct))
    uiRefs.resultDiff.TextColor3 = THEME.sub
end

-- ================= MODAL =================
local function closeModal()
    if currentModal then
        currentModal:Destroy()
        currentModal = nil
    end
end

local function showModal(petName)
    closeModal()
    local pet = petIndex[petName]
    if not pet then return end

    local overlay = create("TextButton", {
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.5,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromScale(1,1),
        ZIndex = 10,
        Parent = uiRefs.main,
    })
    overlay.MouseButton1Click:Connect(closeModal)
    currentModal = overlay

    local box = create("Frame", {
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(320, 300),
        Position = UDim2.new(0.5, -160, 0.5, -150),
        ZIndex = 11,
        Parent = uiRefs.main,
    })
    addCorner(box, 16)
    addStroke(box, THEME.stroke, 1)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(1, -50, 0, 24),
        Text = petName,
        TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 11,
    }, box)

    local closeBtn = create("TextButton", {
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -38, 0, 12),
        Text = "×",
        TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        AutoButtonColor = false,
        ZIndex = 11,
    }, box)
    addCorner(closeBtn, 8)
    closeBtn.MouseButton1Click:Connect(closeModal)

    local state = {tier = currentTier, potion = currentPotion}
    local tierBtns, potionBtns = {}, {}
    local valueLabel

    local function updateBtnStates()
        for name, btn in pairs(tierBtns) do
            btn.BackgroundColor3 = (state.tier == name) and THEME.accent or THEME.bg
            btn.TextColor3 = (state.tier == name) and THEME.panel or THEME.text
        end
        for name, btn in pairs(potionBtns) do
            btn.BackgroundColor3 = (state.potion == name) and THEME.accent or THEME.bg
            btn.TextColor3 = (state.potion == name) and THEME.panel or THEME.text
        end
        valueLabel.Text = fmt(lookupValue(petName, state.tier, state.potion))
    end

    -- Boutons de Tier (Regular, Neon, Mega)
    for i, tier in ipairs({"Regular", "Neon", "Mega"}) do
        local b = create("TextButton", {
            BackgroundColor3 = THEME.bg,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 92, 0, 34),
            Position = UDim2.new(0, 15 + (i-1)*97, 0, 50),
            Text = tier,
            TextColor3 = THEME.text,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            AutoButtonColor = false,
            ZIndex = 11,
        }, box)
        addCorner(b, 8)
        addStroke(b, THEME.stroke, 1)
        tierBtns[tier] = b
        b.MouseButton1Click:Connect(function()
            state.tier = tier
            updateBtnStates()
        end)
    end

    -- Boutons de Potions (FR, NP, R, F)
    for i, potion in ipairs({"FR", "NP", "R", "F"}) do
        local b = create("TextButton", {
            BackgroundColor3 = THEME.bg,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 68, 0, 32),
            Position = UDim2.new(0, 15 + (i-1)*73, 0, 95),
            Text = potion,
            TextColor3 = THEME.text,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            AutoButtonColor = false,
            ZIndex = 11,
        }, box)
        addCorner(b, 8)
        addStroke(b, THEME.stroke, 1)
        potionBtns[potion] = b
        b.MouseButton1Click:Connect(function()
            state.potion = potion
            updateBtnStates()
        end)
    end

    valueLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 135),
        Size = UDim2.new(1, 0, 0, 36),
        Text = "",
        TextColor3 = THEME.accent,
        Font = Enum.Font.GothamBlack,
        TextSize = 28,
        ZIndex = 11,
    }, box)

    -- Boutons d'ajout
    local function addBtn(text, side, color, xPos)
        local b = create("TextButton", {
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 140, 0, 42),
            Position = UDim2.new(0, xPos, 0, 180),
            Text = text,
            TextColor3 = THEME.panel,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 11,
        }, box)
        addCorner(b, 10)
        b.MouseButton1Click:Connect(function()
            local offer = (side == "your") and yourOffer or theirOffer
            table.insert(offer, {name = petName, tier = state.tier, potion = state.potion})
            refreshTradeUI()
            closeModal()
            -- Bascule automatiquement sur l'onglet trade
            currentTab = "Trade"
            uiRefs.updateTabs()
        end)
    end
    addBtn("Add to Your",  "your",  THEME.your,  15)
    addBtn("Add to Their", "their", THEME.their, 165)

    local cancel = create("TextButton", {
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -30, 0, 30),
        Position = UDim2.new(0, 15, 0, 240),
        Text = "Cancel",
        TextColor3 = THEME.sub,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
        ZIndex = 11,
    }, box)
    addCorner(cancel, 8)
    cancel.MouseButton1Click:Connect(closeModal)

    updateBtnStates()
end

-- ================= MAIN UI =================
local function buildUI()
    if _G.__AdoptMeCalc and _G.__AdoptMeCalc.Parent then
        _G.__AdoptMeCalc:Destroy()
    end

    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    local gui = create("ScreenGui", {
        Name = "AdoptMeCalc",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() gui.Parent = parent end)
    if not gui.Parent then
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    _G.__AdoptMeCalc = gui
    mainGui = gui

    -- Fenêtre Principale (Format Mobile)
    local main = create("Frame", {
        Name = "Main",
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(370, 580),
        Position = UDim2.new(0.5, -185, 0.5, -290),
        Parent = gui,
    })
    addCorner(main, 24)
    addStroke(main, THEME.stroke, 1.5)
    uiRefs.main = main

    -- Adaptation automatique à la taille de l'écran (Mobile / PC)
    local scale = create("UIScale", {Parent = main})
    local function updateScale()
        local viewport = Workspace.CurrentCamera.ViewportSize
        local s = math.min(viewport.X / 400, viewport.Y / 620)
        if s > 1 then s = 1 end
        scale.Scale = s
    end
    updateScale()
    Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

    -- Top Bar
    local titleBar = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = main,
    })
    
    local closeBtn = create("TextButton", {
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -40, 0, 10),
        Text = "×",
        TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        AutoButtonColor = false,
    }, titleBar)
    addCorner(closeBtn, 8)
    addStroke(closeBtn, THEME.stroke, 1)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    local statusDot = create("Frame", {
        BackgroundColor3 = THEME.lose,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.new(1, -55, 0, 21),
    }, titleBar)
    addCorner(statusDot, 4)
    uiRefs.statusDot = statusDot

    -- Titre
    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Text = "Adopt Me Values",
        TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, titleBar)

    -- ===== ONGLETS (Pets / Trade) =====
    local tabsBar = create("Frame", {
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(15, 45),
        Size = UDim2.new(1, -30, 0, 38),
    }, main)
    addCorner(tabsBar, 10)
    addStroke(tabsBar, THEME.stroke, 1)

    local tabBtns = {}
    local function updateTabs()
        for name, btn in pairs(tabBtns) do
            local isActive = (currentTab == name)
            btn.BackgroundColor3 = isActive and THEME.bg or THEME.panel
            btn.TextColor3 = isActive and THEME.text or THEME.sub
        end
        uiRefs.petsContainer.Visible = (currentTab == "Pets")
        uiRefs.tradeContainer.Visible = (currentTab == "Trade")
    end
    uiRefs.updateTabs = updateTabs

    local function makeTabBtn(name, xPos)
        local b = create("TextButton", {
            BackgroundColor3 = THEME.panel,
            BorderSizePixel = 0,
            Position = UDim2.new(0, xPos, 0, 3),
            Size = UDim2.new(0.5, -4, 1, -6),
            Text = name,
            TextColor3 = THEME.sub,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            AutoButtonColor = false,
        }, tabsBar)
        addCorner(b, 8)
        tabBtns[name] = b
        b.MouseButton1Click:Connect(function()
            currentTab = name
            updateTabs()
        end)
    end
    makeTabBtn("Pets", 3)
    makeTabBtn("Trade", 0.5)

    -- ===== CONTENEUR : PETS (Onglet 1) =====
    local petsContainer = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 90),
        Size = UDim2.new(1, -30, 1, -100),
        Parent = main,
    })
    uiRefs.petsContainer = petsContainer

    -- Barre de recherche
    local searchBg = create("Frame", {
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
    }, petsContainer)
    addCorner(searchBg, 10)
    addStroke(searchBg, THEME.stroke, 1)

    local searchBox = create("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 1, 0),
        PlaceholderText = "Search pet...",
        Text = "",
        TextColor3 = THEME.text,
        PlaceholderColor3 = THEME.sub,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, searchBg)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        currentFilter = searchBox.Text
        refreshPetList()
    end)

    -- Grille des pets
    local scroll = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 42),
        Size = UDim2.new(1, 0, 1, -85),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = THEME.stroke,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = petsContainer,
    })
    create("UIGridLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        CellSize = UDim2.new(0, 82, 0, 100),
        CellPadding = UDim2.new(0, 6, 0, 6),
    }, scroll)
    uiRefs.petScroll = scroll

    -- Filtres (F R D N M)
    local filtersBar = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -38),
        Size = UDim2.new(1, 0, 0, 34),
        Parent = petsContainer,
    })
    
    local filters = {
        {label = "F", tier = "Regular", potion = "f"},
        {label = "R", tier = "Regular", potion = "r"},
        {label = "D", tier = "Regular", potion = "np"},
        {label = "N", tier = "Neon", potion = "fr"},
        {label = "M", tier = "Mega", potion = "fr"},
    }

    local filterBtns = {}
    local function updateFilterBtns()
        for _, item in ipairs(filterBtns) do
            local isSelected = (currentTier == item.tier and currentPotion == item.potion)
            item.btn.BackgroundColor3 = isSelected and THEME.accent or THEME.panel
            item.btn.TextColor3 = isSelected and THEME.panel or THEME.text
        end
        refreshPetList()
    end

    for i, f in ipairs(filters) do
        local b = create("TextButton", {
            BackgroundColor3 = THEME.panel,
            BorderSizePixel = 0,
            Position = UDim2.new((i-1)*0.2, 0, 0, 0),
            Size = UDim2.new(0.2, -4, 1, 0),
            Text = f.label,
            TextColor3 = THEME.text,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            AutoButtonColor = false,
        }, filtersBar)
        addCorner(b, 8)
        addStroke(b, THEME.stroke, 1)
        
        table.insert(filterBtns, {btn = b, tier = f.tier, potion = f.potion})
        b.MouseButton1Click:Connect(function()
            currentTier = f.tier
            currentPotion = f.potion
            updateFilterBtns()
        end)
    end
    updateFilterBtns()

    -- ===== CONTENEUR : TRADE (Onglet 2) =====
    local tradeContainer = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 90),
        Size = UDim2.new(1, -30, 1, -100),
        Visible = false,
        Parent = main,
    })
    uiRefs.tradeContainer = tradeContainer

    -- Ton Offre
    local yourFrame = create("Frame", {
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 170),
    }, tradeContainer)
    addCorner(yourFrame, 12)
    addStroke(yourFrame, THEME.stroke, 1)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 8),
        Size = UDim2.new(1, -20, 0, 20),
        Text = "Your Offer",
        TextColor3 = THEME.your,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, yourFrame)

    local yourScroll = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(5, 30),
        Size = UDim2.new(1, -10, 1, -60),
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, yourFrame)
    create("UIListLayout", { Padding = UDim.new(0, 4) }, yourScroll)
    uiRefs.yourScroll = yourScroll

    local yourTotal = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 1, -25),
        Size = UDim2.new(1, -20, 0, 20),
        Text = "Total: 0",
        TextColor3 = THEME.your,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, yourFrame)
    uiRefs.yourTotal = yourTotal

    -- Leur Offre
    local theirFrame = create("Frame", {
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 180),
        Size = UDim2.new(1, 0, 0, 170),
    }, tradeContainer)
    addCorner(theirFrame, 12)
    addStroke(theirFrame, THEME.stroke, 1)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 8),
        Size = UDim2.new(1, -20, 0, 20),
        Text = "Their Offer",
        TextColor3 = THEME.their,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, theirFrame)

    local theirScroll = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(5, 30),
        Size = UDim2.new(1, -10, 1, -60),
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, theirFrame)
    create("UIListLayout", { Padding = UDim.new(0, 4) }, theirScroll)
    uiRefs.theirScroll = theirScroll

    local theirTotal = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 1, -25),
        Size = UDim2.new(1, -20, 0, 20),
        Text = "Total: 0",
        TextColor3 = THEME.their,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, theirFrame)
    uiRefs.theirTotal = theirTotal

    -- Barre de Résultat
    local resultFrame = create("Frame", {
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 360),
        Size = UDim2.new(1, 0, 0, 80),
    }, tradeContainer)
    addCorner(resultFrame, 12)
    addStroke(resultFrame, THEME.stroke, 1)

    uiRefs.resultLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 0, 36),
        Text = "Waiting...",
        TextColor3 = THEME.sub,
        Font = Enum.Font.GothamBlack,
        TextSize = 32,
    }, resultFrame)

    uiRefs.resultDiff = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 0, 20),
        Text = "",
        TextColor3 = THEME.sub,
        Font = Enum.Font.Gotham,
        TextSize = 11,
    }, resultFrame)

    -- Bouton Clear
    local clearBtn = create("TextButton", {
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(60, 20),
        Position = UDim2.new(1, -70, 0, 10),
        Text = "Clear",
        TextColor3 = THEME.sub,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        AutoButtonColor = false,
    }, resultFrame)
    addCorner(clearBtn, 4)
    addStroke(clearBtn, THEME.stroke, 1)
    clearBtn.MouseButton1Click:Connect(function()
        yourOffer = {}
        theirOffer = {}
        refreshTradeUI()
    end)

    -- Drag Logic
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    uiRefs.showModal = showModal
    updateTabs()
end

-- ================= BOOT =================
buildUI()
refreshTradeUI()

local function loadLoop()
    local data = fetchPets(3)
    if data then
        petData = data
        rebuildIndex()
        refreshPetList()
        refreshTradeUI()
        uiRefs.statusDot.BackgroundColor3 = THEME.win
    end
    while mainGui and mainGui.Parent do
        task.wait(REFRESH_SECONDS)
        local d = fetchPets(1)
        if d then
            petData = d
            rebuildIndex()
            refreshPetList()
            refreshTradeUI()
            uiRefs.statusDot.BackgroundColor3 = THEME.win
        else
            uiRefs.statusDot.BackgroundColor3 = THEME.lose
        end
    end
end

task.spawn(loadLoop)