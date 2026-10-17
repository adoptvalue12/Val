--[[
    ============================================================
      ADOPT ME VALUE & TRADE — Delta Executor
      UI Mobile (320x480) — Elvebredd Style
    ============================================================
]]

local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")

local BASE_URL         = "https://elvebredd-api.onrender.com"
local REFRESH_SECONDS  = 120

-- ================= IMAGES (ASSET IDs) =================
local PET_IMAGE_IDS = {
    ["Shadow Dragon"] = 10683341548, ["Bat Dragon"] = 8673880317, ["Frost Dragon"] = 5166226493,
    ["Giraffe"] = 5166227300, ["Owl"] = 8673885987, ["Parrot"] = 5166227911,
    ["Crow"] = 8673887683, ["Evil Unicorn"] = 5166225849, ["Arctic Reindeer"] = 5166224796,
    ["Kangaroo"] = 5166226894, ["Turtle"] = 5166229124, ["Unicorn"] = 5166227976,
    ["Dragon"] = 5166225561, ["Griffin"] = 5166226753, ["Cerberus"] = 10683337859,
    ["Queen Bee"] = 8673886682, ["King Bee"] = 8673886033, ["Albino Monkey"] = 8673881304,
    ["Golden Penguin"] = 10683341097, ["Guardian Lion"] = 10683341442, ["Metal Ox"] = 10683343044,
    ["Ninja Monkey"] = 10683343708, ["Skeleton T-Rex"] = 10683344049, ["Zombie Buffalo"] = 10683344706,
    ["T-Rex"] = 10683344983, ["Dodo"] = 10683339622, ["Snow Owl"] = 10683344300,
    ["Robo Dog"] = 10683344099, ["Golden Unicorn"] = 10683340931, ["Golden Dragon"] = 10683340592,
}

-- ================= THEME =================
local THEME = {
    bg          = Color3.fromRGB(248, 247, 245),
    panel       = Color3.fromRGB(255, 255, 255),
    card        = Color3.fromRGB(252, 252, 252),
    stroke      = Color3.fromRGB(225, 223, 220),
    text        = Color3.fromRGB(30, 30, 30),
    sub         = Color3.fromRGB(130, 130, 130),
    accent      = Color3.fromRGB(255, 85, 85),
    win         = Color3.fromRGB(75, 200, 120),
    fair        = Color3.fromRGB(255, 180, 50),
    lose        = Color3.fromRGB(255, 85, 85),
    your        = Color3.fromRGB(85, 150, 255),
    their       = Color3.fromRGB(230, 100, 180),
}

-- ================= STATE =================
local petData       = {}
local petIndex      = {}
local yourOffer     = {}
local theirOffer    = {}
local currentFilter = ""
local currentTab    = "Values"
local currentTier   = "Regular"
local currentPotion = "np" 
local mainGui       = nil
local uiRefs        = {}
local selectorSide  = "your" -- "your" ou "their" pour le modal

-- ================= HELPERS =================
local function create(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function addCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.stroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
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

local function getVal(petName, tier, potion)
    local p = petIndex[petName]
    if not p then return 0 end
    local t = p[TIER_KEYS[tier]]
    if not t then return 0 end
    return t[POTION_KEYS[potion]] or 0
end

local function rebuildIndex()
    petIndex = {}
    for _, p in ipairs(petData) do
        if p.name then petIndex[p.name] = p end
    end
end

-- ================= HTTP =================
local function fetchPets()
    local req = (syn and syn.request) or (http and http.request) or request
    local url = BASE_URL .. "/api/pets"
    local success, body
    
    if req then
        local ok, res = pcall(req, {Url = url, Method = "GET"})
        if ok and res and res.Body then success, body = true, res.Body end
    end
    
    if not success then
        local ok, res = pcall(function() return HttpService:GetAsync(url) end)
        if ok then success, body = true, res end
    end

    if success and body then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, body)
        if ok and type(data) == "table" then return data end
    end
    return nil
end

-- ================= UI: MAIN =================
local function buildUI()
    if _G.__AdoptMeUI and _G.__AdoptMeUI.Parent then _G.__AdoptMeUI:Destroy() end
    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    local gui = create("ScreenGui", {Name = "AdoptMeUI", ResetOnSpawn = false, Parent = parent})
    _G.__AdoptMeUI = gui
    mainGui = gui

    -- Fenêtre Principale
    local main = create("Frame", {
        Name = "Main", BackgroundColor3 = THEME.bg, BorderSizePixel = 0,
        Size = UDim2.fromOffset(320, 480), Position = UDim2.new(0.5, -160, 0.5, -240),
        Parent = gui
    })
    addCorner(main, 16)
    addStroke(main, THEME.stroke, 1.5)
    uiRefs.main = main

    -- Auto-Scale pour mobile
    local scale = create("UIScale", {Parent = main})
    local vp = Workspace.CurrentCamera.ViewportSize
    scale.Scale = math.min(vp.X / 350, vp.Y / 520, 1)

    -- Top Bar
    local topBar = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,40), Parent = main})
    
    -- Titre
    create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(15, 0), Size = UDim2.new(1,-80,1,0),
        Text = "Adopt Me Values", TextColor3 = THEME.text, Font = Enum.Font.GothamBold,
        TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
    }, topBar)

    -- Bouton Réduire
    local minBtn = create("TextButton", {
        BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Size = UDim2.fromOffset(24,24),
        Position = UDim2.new(1,-60,0.5,-12), Text = "—", TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
    }, topBar)
    addCorner(minBtn, 6); addStroke(minBtn, THEME.stroke, 1)

    -- Bouton Fermer
    local closeBtn = create("TextButton", {
        BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Size = UDim2.fromOffset(24,24),
        Position = UDim2.new(1,-32,0.5,-12), Text = "×", TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false,
    }, topBar)
    addCorner(closeBtn, 6); addStroke(closeBtn, THEME.stroke, 1)

    -- Icône Flottante (quand fermé)
    local floatBtn = create("TextButton", {
        BackgroundColor3 = THEME.accent, BorderSizePixel = 0, Size = UDim2.fromOffset(50,50),
        Position = UDim2.new(0, 20, 0.5, -25), Text = "🐾", TextColor3 = THEME.panel,
        Font = Enum.Font.GothamBold, TextSize = 24, AutoButtonColor = false, Visible = false,
        Parent = gui
    })
    addCorner(floatBtn, 25)
    
    -- Drag Logic
    local function makeDraggable(frame, dragArea)
        local dragging, dragInput, dragStart, startPos
        dragArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = frame.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        dragArea.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local d = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    makeDraggable(main, topBar)
    makeDraggable(floatBtn, floatBtn)

    closeBtn.MouseButton1Click:Connect(function() main.Visible = false; floatBtn.Visible = true end)
    minBtn.MouseButton1Click:Connect(function() main.Visible = false; floatBtn.Visible = true end)
    floatBtn.MouseButton1Click:Connect(function() main.Visible = true; floatBtn.Visible = false end)

    -- ================= ONGLETS =================
    local tabBar = create("Frame", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.fromOffset(15, 40), Size = UDim2.new(1,-30,0,32), Parent = main})
    addCorner(tabBar, 8); addStroke(tabBar, THEME.stroke, 1)

    local tabBtns = {}
    local function switchTab(tab)
        currentTab = tab
        for name, btn in pairs(tabBtns) do
            btn.BackgroundColor3 = (name == currentTab) and THEME.bg or THEME.panel
            btn.TextColor3 = (name == currentTab) and THEME.text or THEME.sub
        end
        uiRefs.valuesContainer.Visible = (currentTab == "Values")
        uiRefs.tradeContainer.Visible = (currentTab == "Trade")
    end

    for i, t in ipairs({"Values", "Trade"}) do
        local b = create("TextButton", {
            BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.new((i-1)*0.5, 2, 0, 2), Size = UDim2.new(0.5, -4, 1, -4),
            Text = t, TextColor3 = THEME.sub, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false,
        }, tabBar)
        addCorner(b, 6)
        tabBtns[t] = b
        b.MouseButton1Click:Connect(function() switchTab(t) end)
    end

    -- ================= TAB 1 : VALUES =================
    local valuesContainer = create("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(15, 80), Size = UDim2.new(1,-30,1,-90), Parent = main})
    uiRefs.valuesContainer = valuesContainer

    -- Recherche
    local searchBg = create("Frame", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Size = UDim2.new(1,0,0,30), Parent = valuesContainer})
    addCorner(searchBg, 6); addStroke(searchBg, THEME.stroke, 1)
    local searchBox = create("TextBox", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(8,0), Size = UDim2.new(1,-16,1,0),
        PlaceholderText = "Search a pet...", Text = "", TextColor3 = THEME.text, PlaceholderColor3 = THEME.sub,
        Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
    }, searchBg)
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        currentFilter = searchBox.Text
        uiRefs.refreshList()
    end)

    -- Filtres Tiers (Reg / Neon / Mega)
    local filterBar = create("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 35), Size = UDim2.new(1,0,0,24), Parent = valuesContainer})
    local tierBtns = {}
    local function updateTierBtns()
        for name, btn in pairs(tierBtns) do
            btn.BackgroundColor3 = (currentTier == name) and THEME.accent or THEME.panel
            btn.TextColor3 = (currentTier == name) and THEME.panel or THEME.text
        end
        uiRefs.refreshList()
    end
    for i, t in ipairs({"Regular", "Neon", "Mega"}) do
        local b = create("TextButton", {
            BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.new((i-1)*0.33, 2, 0, 0), Size = UDim2.new(0.33, -4, 1, 0),
            Text = t, TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false,
        }, filterBar)
        addCorner(b, 4); addStroke(b, THEME.stroke, 1)
        tierBtns[t] = b
        b.MouseButton1Click:Connect(function() currentTier = t; updateTierBtns() end)
    end

    -- Liste Scrollable
    local listScroll = create("ScrollingFrame", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 65), Size = UDim2.new(1,0,1,-65),
        ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = valuesContainer
    })
    create("UIListLayout", {Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder}, listScroll)

    uiRefs.refreshList = function()
        for _, c in ipairs(listScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local filter = string.lower(currentFilter)
        local sorted = {}
        for _, p in ipairs(petData) do
            if filter == "" or string.find(string.lower(p.name), filter, 1, true) then table.insert(sorted, p) end
        end
        table.sort(sorted, function(a,b) return getVal(a.name, currentTier, "fr") > getVal(b.name, currentTier, "fr") end)

        for i, p in ipairs(sorted) do
            local val = getVal(p.name, currentTier, "fr")
            local row = create("Frame", {BackgroundColor3 = THEME.card, BorderSizePixel = 0, Size = UDim2.new(1,-4,0,36), LayoutOrder = i}, listScroll)
            addCorner(row, 6); addStroke(row, THEME.stroke, 1)

            -- Image
            local img = PET_IMAGE_IDS[p.name]
            local imgFrame = create("Frame", {BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Size = UDim2.fromOffset(28,28), Position = UDim2.new(0,4,0.5,-14)}, row)
            addCorner(imgFrame, 4)
            if img then
                create("ImageLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), Image = "rbxassetid://"..img}, imgFrame)
            else
                create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), Text = string.sub(p.name,1,1), TextColor3 = THEME.sub, Font = Enum.Font.GothamBold}, imgFrame)
            end

            -- Nom
            create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(38,0), Size = UDim2.new(1,-90,1,0), Text = p.name, TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, row)
            -- Valeur
            create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-50,0,0), Size = UDim2.fromOffset(45,36), Text = fmt(val), TextColor3 = THEME.accent, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right}, row)
        end
    end
    updateTierBtns()

    -- ================= TAB 2 : TRADE =================
    local tradeContainer = create("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(15, 80), Size = UDim2.new(1,-30,1,-90), Visible = false, Parent = main})
    uiRefs.tradeContainer = tradeContainer

    local function createTradeBox(title, color, yPos, side)
        local box = create("Frame", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.fromOffset(0,yPos), Size = UDim2.new(1,0,0,130), Parent = tradeContainer})
        addCorner(box, 8); addStroke(box, THEME.stroke, 1)
        
        create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(10,5), Size = UDim2.new(1,-50,0,16), Text = title, TextColor3 = color, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, box)
        
        local addBtn = create("TextButton", {BackgroundColor3 = color, BorderSizePixel = 0, Position = UDim2.new(1,-30,5), Size = UDim2.fromOffset(24,24), Text = "+", TextColor3 = THEME.panel, Font = Enum.Font.GothamBold, TextSize = 14}, box)
        addCorner(addBtn, 6)
        
        local scroll = create("ScrollingFrame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(5,25), Size = UDim2.new(1,-10,1,-30), ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y}, box)
        create("UIListLayout", {Padding = UDim.new(0,2)}, scroll)
        
        local totalLbl = create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,10,1,-20), Size = UDim2.new(1,-20,0,15), Text = "Total: 0", TextColor3 = color, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right}, box)
        
        addBtn.MouseButton1Click:Connect(function()
            selectorSide = side
            uiRefs.openSelector()
        end)
        return scroll, totalLbl
    end

    uiRefs.yourScroll, uiRefs.yourTotal = createTradeBox("Your Offer", THEME.your, 0, "your")
    uiRefs.theirScroll, uiRefs.theirTotal = createTradeBox("Their Offer", THEME.their, 140, "their")

    -- Résultat
    local resultBox = create("Frame", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.fromOffset(0,280), Size = UDim2.new(1,0,0,80), Parent = tradeContainer})
    addCorner(resultBox, 8); addStroke(resultBox, THEME.stroke, 1)

    uiRefs.resultLbl = create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,0,10), Size = UDim2.new(1,0,30), Text = "Waiting...", TextColor3 = THEME.sub, Font = Enum.Font.GothamBlack, TextSize = 24}, resultBox)
    uiRefs.diffLbl = create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,0,45), Size = UDim2.new(1,0,20), Text = "Add pets to calculate", TextColor3 = THEME.sub, Font = Enum.Font.Gotham, TextSize = 10}, resultBox)

    local clearBtn = create("TextButton", {BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Position = UDim2.new(1,-60,10), Size = UDim2.fromOffset(50,20), Text = "Clear", TextColor3 = THEME.lose, Font = Enum.Font.GothamBold, TextSize = 10}, resultBox)
    addCorner(clearBtn, 4); addStroke(clearBtn, THEME.stroke, 1)
    clearBtn.MouseButton1Click:Connect(function() yourOffer = {}; theirOffer = {}; uiRefs.refreshTrade() end)

    -- Refresh Trade UI
    uiRefs.refreshTrade = function()
        local function build(offer, scroll, totalLbl)
            for _, c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
            local total = 0
            for i, e in ipairs(offer) do
                local v = getVal(e.name, e.tier, e.potion)
                total = total + v
                local row = create("Frame", {BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Size = UDim2.new(1,-4,0,24), LayoutOrder = i}, scroll)
                addCorner(row, 4)
                create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(5,0), Size = UDim2.new(1,-30,1,0), Text = e.name.." ("..e.tier.." "..e.potion..")", TextColor3 = THEME.text, Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, row)
                create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-50,0,0), Size = UDim2.fromOffset(45,24), Text = fmt(v), TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Right}, row)
                
                local x = create("TextButton", {BackgroundTransparency = 1, Position = UDim2.new(1,-20,0.5,-8), Size = UDim2.fromOffset(16,16), Text = "×", TextColor3 = THEME.lose, Font = Enum.Font.GothamBold, TextSize = 12}, row)
                x.MouseButton1Click:Connect(function() table.remove(offer, i); uiRefs.refreshTrade() end)
            end
            totalLbl.Text = "Total: "..fmt(total)
            return total
        end
        local yt = build(yourOffer, uiRefs.yourScroll, uiRefs.yourTotal)
        local tt = build(theirOffer, uiRefs.theirScroll, uiRefs.theirTotal)

        if yt == 0 and tt == 0 then
            uiRefs.resultLbl.Text = "Waiting..."; uiRefs.resultLbl.TextColor3 = THEME.sub
            uiRefs.diffLbl.Text = "Add pets to calculate"; return
        end
        local diff = tt - yt
        local ref = math.max(yt, tt)
        local pct = ref > 0 and (diff / ref) * 100 or 0
        
        local c, t
        if math.abs(pct) < 10 then c, t = THEME.fair, "FAIR"
        elseif diff > 0 then c, t = THEME.win, "WIN"
        else c, t = THEME.lose, "LOSE" end
        
        uiRefs.resultLbl.Text = t; uiRefs.resultLbl.TextColor3 = c
        uiRefs.diffLbl.Text = string.format("Diff: %s%s (%.1f%%)", diff>=0 and "+" or "-", fmt(math.abs(diff)), math.abs(pct))
        uiRefs.diffLbl.TextColor3 = THEME.sub
    end

    -- ================= MODAL SÉLECTEUR DE PETS =================
    uiRefs.openSelector = function()
        local modal = create("Frame", {
            BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Size = UDim2.fromOffset(280, 380),
            Position = UDim2.new(0.5,-140,0.5,-190), ZIndex = 20, Parent = main
        })
        addCorner(modal, 12); addStroke(modal, THEME.accent, 1.5)
        
        local sideText = (selectorSide == "your") and "Add to YOUR offer" or "Add to THEIR offer"
        local sideColor = (selectorSide == "your") and THEME.your or THEME.their

        create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(10,10), Size = UDim2.new(1,-40,0,20), Text = sideText, TextColor3 = sideColor, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 20}, modal)
        
        local close = create("TextButton", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.new(1,-30,10), Size = UDim2.fromOffset(22,22), Text = "×", TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 20}, modal)
        addCorner(close, 4); addStroke(close, THEME.stroke, 1)
        close.MouseButton1Click:Connect(function() modal:Destroy() end)

        -- Recherche modal
        local sBg = create("Frame", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.fromOffset(10,35), Size = UDim2.new(1,-20,0,26), ZIndex = 20}, modal)
        addCorner(sBg, 4); addStroke(sBg, THEME.stroke, 1)
        local sBox = create("TextBox", {BackgroundTransparency = 1, Position = UDim2.fromOffset(5,0), Size = UDim2.new(1,-10,1,0), PlaceholderText = "Search...", Text = "", TextColor3 = THEME.text, PlaceholderColor3 = THEME.sub, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 20}, sBg)

        -- Boutons Potions
        local potions = {"FR", "NP", "R", "F"}
        local pBtns = {}
        local function updatePots()
            for name, btn in pairs(pBtns) do
                btn.BackgroundColor3 = (currentPotion == name) and THEME.accent or THEME.panel
                btn.TextColor3 = (currentPotion == name) and THEME.panel or THEME.text
            end
        end
        for i, p in ipairs(potions) do
            local b = create("TextButton", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.fromOffset(10 + (i-1)*65, 68), Size = UDim2.fromOffset(60,20), Text = p, TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 20}, modal)
            addCorner(b, 4); addStroke(b, THEME.stroke, 1)
            pBtns[p] = b
            b.MouseButton1Click:Connect(function() currentPotion = p; updatePots() end)
        end
        updatePots()

        -- Liste modal
        local mScroll = create("ScrollingFrame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(5,95), Size = UDim2.new(1,-10,1,-105), ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 20}, modal)
        create("UIListLayout", {Padding = UDim.new(0,3), SortOrder = Enum.SortOrder.LayoutOrder}, mScroll)

        local function refreshModalList()
            for _, c in ipairs(mScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            local f = string.lower(sBox.Text)
            local sorted = {}
            for _, p in ipairs(petData) do
                if f == "" or string.find(string.lower(p.name), f, 1, true) then table.insert(sorted, p) end
            end
            table.sort(sorted, function(a,b) return getVal(a.name, currentTier, currentPotion) > getVal(b.name, currentTier, currentPotion) end)

            for i, p in ipairs(sorted) do
                local b = create("TextButton", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Size = UDim2.new(1,-4,0,30), LayoutOrder = i, Text = "", AutoButtonColor = false, ZIndex = 20}, mScroll)
                addCorner(b, 4); addStroke(b, THEME.stroke, 1)
                
                create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(5,0), Size = UDim2.new(1,-60,1,0), Text = p.name.." ("..currentTier..")", TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 20}, b)
                create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-55,0,0), Size = UDim2.fromOffset(50,30), Text = fmt(getVal(p.name, currentTier, currentPotion)), TextColor3 = sideColor, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 20}, b)
                
                b.MouseButton1Click:Connect(function()
                    local offer = (selectorSide == "your") and yourOffer or theirOffer
                    table.insert(offer, {name = p.name, tier = currentTier, potion = currentPotion})
                    uiRefs.refreshTrade()
                    modal:Destroy()
                end)
            end
        end
        sBox:GetPropertyChangedSignal("Text"):Connect(refreshModalList)
        refreshModalList()
    end

    switchTab("Values")
end

-- ================= BOOT =================
buildUI()

task.spawn(function()
    local data = fetchPets()
    if data then
        petData = data
        rebuildIndex()
        uiRefs.refreshList()
        uiRefs.refreshTrade()
    else
        uiRefs.resultLbl.Text = "API Error (Retry in a sec)"
        uiRefs.resultLbl.TextColor3 = THEME.lose
    end
end)