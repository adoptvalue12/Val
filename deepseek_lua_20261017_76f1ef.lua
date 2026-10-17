--[[
    ============================================================
      ADOPT ME TRADE CALCULATOR  —  Delta Executor
      Style : Elvebredd (Thème clair) + Scan Joueurs + Mini Mode
    ============================================================
]]

local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local BASE_URL         = "https://elvebredd-api.onrender.com"
local REFRESH_SECONDS  = 120

-- ================= IMAGES DES PETS =================
-- Ajoute les ID Roblox ici pour voir les vraies images.
local PET_IMAGE_IDS = {
    -- ["Shadow Dragon"] = 1234567,
}
-- ===================================================

-- ================= THEME (Style Elvebredd) =================
local THEME = {
    bg          = Color3.fromRGB(242, 240, 235),
    panel       = Color3.fromRGB(255, 255, 255),
    btnBg       = Color3.fromRGB(248, 248, 248),
    btnStroke   = Color3.fromRGB(210, 210, 210),
    text        = Color3.fromRGB(40, 40, 40),
    sub         = Color3.fromRGB(120, 120, 120),
    accent      = Color3.fromRGB(255, 90, 90),
    win         = Color3.fromRGB(80, 200, 120),
    fair        = Color3.fromRGB(255, 180, 50),
    lose        = Color3.fromRGB(255, 90, 90),
    your        = Color3.fromRGB(90, 160, 255),
    their       = Color3.fromRGB(255, 120, 180),
}

-- ================= STATE =================
local petData       = {}
local petIndex      = {}
local yourOffer     = {}
local theirOffer    = {}
local currentFilter = ""
local currentTab    = "Pets"
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
    s.Color = color or THEME.btnStroke
    s.Thickness = thickness or 1.5
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
    return string.format("%.2f", n)
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

-- ================= SCAN JOUEURS =================
local function scanPlayers()
    local found = {}
    -- Scanne tous les joueurs du serveur
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and plr.Character then
            for _, obj in ipairs(plr.Character:GetDescendants()) do
                if obj:IsA("Model") and petIndex[obj.Name] then
                    table.insert(found, { player = plr.Name, pet = obj.Name, obj = obj })
                end
            end
        end
    end
    -- Scan les pets qui traînent dans le monde (ex: Adopt Me)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and petIndex[obj.Name] and not obj:FindFirstAncestorOfClass("Model") then
            table.insert(found, { player = "Monde", pet = obj.Name, obj = obj })
        end
    end
    return found
end

-- ================= PET LIST (GRID UI) =================
local function refreshPetList()
    local scroll = uiRefs.petScroll
    if not scroll then return end
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end

    if currentTab == "Players" then
        local playersPets = scanPlayers()
        for i, p in ipairs(playersPets) do
            local val = lookupValue(p.pet, "Regular", "fr")
            local cell = create("TextButton", {
                BackgroundColor3 = THEME.panel,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 98, 0, 115),
                LayoutOrder = i,
                Text = "",
                AutoButtonColor = false,
            }, scroll)
            addCorner(cell, 12)
            addStroke(cell, THEME.btnStroke)
            
            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 10),
                Size = UDim2.new(1, 0, 0, 14),
                Text = p.player,
                TextColor3 = THEME.sub,
                Font = Enum.Font.GothamBold,
                TextSize = 10,
            }, cell)
            
            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 16),
                Text = p.pet,
                TextColor3 = THEME.text,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, cell)

            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 85),
                Size = UDim2.new(1, 0, 0, 16),
                Text = fmt(val),
                TextColor3 = THEME.accent,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
            }, cell)
        end
        return
    end

    -- Mode "Pets"
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
            BackgroundColor3 = THEME.panel,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 98, 0, 115),
            LayoutOrder = i,
            Text = "",
            AutoButtonColor = false,
        }, scroll)
        addCorner(cell, 12)
        addStroke(cell, THEME.btnStroke)

        local badge = create("Frame", {
            BackgroundColor3 = THEME.bg,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 60, 0, 60),
            Position = UDim2.new(0.5, -30, 0, 10),
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
            Position = UDim2.new(0, 2, 0, 74),
            Size = UDim2.new(1, -4, 0, 14),
            Text = p.name,
            TextColor3 = THEME.text,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, cell)

        create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 2, 0, 88),
            Size = UDim2.new(1, -4, 0, 14),
            Text = fmt(val),
            TextColor3 = THEME.accent,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
        }, cell)

        cell.MouseEnter:Connect(function()
            TweenService:Create(cell, TweenInfo.new(0.1), {BackgroundColor3 = THEME.bg}):Play()
        end)
        cell.MouseLeave:Connect(function()
            TweenService:Create(cell, TweenInfo.new(0.1), {BackgroundColor3 = THEME.panel}):Play()
        end)
        cell.MouseButton1Click:Connect(function()
            uiRefs.showModal(p.name)
        end)
    end
end

-- ================= TRADE LISTS & MINI MODE =================
local function refreshTrades()
    local function build(offer, scroll, sideColor)
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local total = 0
        for i, e in ipairs(offer) do
            local v = lookupValue(e.name, e.tier, e.potion)
            total = total + (v or 0)

            local row = create("Frame", {
                BackgroundColor3 = THEME.panel,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 42),
                LayoutOrder = i,
            }, scroll)
            addCorner(row, 8)
            addStroke(row, THEME.btnStroke, 1)

            local bar = create("Frame", {
                BackgroundColor3 = sideColor,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 6, 1, -12),
                Position = UDim2.new(0, 6, 0, 6),
            }, row)
            addCorner(bar, 3)

            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 18, 0, 4),
                Size = UDim2.new(1, -50, 0, 18),
                Text = e.name,
                TextColor3 = THEME.text,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, row)

            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 18, 0, 22),
                Size = UDim2.new(1, -50, 0, 16),
                Text = e.tier .. " " .. e.potion .. "  •  " .. fmt(v),
                TextColor3 = sideColor,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, row)

            local x = create("TextButton", {
                BackgroundColor3 = THEME.bg,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -32, 0.5, -12),
                Text = "×",
                TextColor3 = THEME.lose,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                AutoButtonColor = false,
            }, row)
            addCorner(x, 6)
            x.MouseButton1Click:Connect(function()
                table.remove(offer, i)
                refreshTrades()
            end)
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, #offer * 46)
        return total
    end

    local yt = build(yourOffer,  uiRefs.yourList,  THEME.your)
    local tt = build(theirOffer, uiRefs.theirList, THEME.their)

    uiRefs.yourTotal.Text  = "Total : " .. fmt(yt)
    uiRefs.theirTotal.Text = "Total : " .. fmt(tt)
    uiRefs.yourTotal.TextColor3  = THEME.your
    uiRefs.theirTotal.TextColor3 = THEME.their

    -- Update Mini Mode Bar
    if uiRefs.miniBar then
        uiRefs.miniBar.Your.Text = "You: " .. fmt(yt)
        uiRefs.miniBar.Their.Text = "Them: " .. fmt(tt)
    end

    if yt == 0 and tt == 0 then
        uiRefs.resultLabel.Text = "Waiting for pets…"
        uiRefs.resultLabel.TextColor3 = THEME.sub
        uiRefs.diffLabel.Text = "Add pets to both sides to calculate."
        if uiRefs.miniBar then uiRefs.miniBar.Result.Text = "IDLE"; uiRefs.miniBar.Result.TextColor3 = THEME.sub end
        return
    end

    local diff = tt - yt
    local ref  = math.max(yt, tt)
    local pct  = ref > 0 and (diff / ref) * 100 or 0

    local color, label
    if math.abs(pct) < 5 then
        color, label = THEME.fair, "FAIR"
    elseif diff > 0 then
        color, label = THEME.win, "WIN"
    else
        color, label = THEME.lose, "LOSE"
    end

    uiRefs.resultLabel.Text = label
    uiRefs.resultLabel.TextColor3 = color
    uiRefs.diffLabel.Text = string.format(
        "Your Offer: %s   •   Their Offer: %s   •   Diff: %s%s (%.1f%%)",
        fmt(yt), fmt(tt), diff >= 0 and "+" or "", fmt(math.abs(diff)), pct
    )
    uiRefs.diffLabel.TextColor3 = THEME.sub

    -- Update Mini Mode Bar
    if uiRefs.miniBar then
        uiRefs.miniBar.Result.Text = label
        uiRefs.miniBar.Result.TextColor3 = color
    end
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
        Name = "ModalOverlay",
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.4,
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
        Size = UDim2.fromOffset(360, 320),
        Position = UDim2.new(0.5, -180, 0.5, -160),
        ZIndex = 11,
        Parent = uiRefs.main,
    })
    addCorner(box, 16)
    addStroke(box, THEME.btnStroke, 1.5)

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(1, -60, 0, 26),
        Text = petName,
        TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 11,
    }, box)

    local closeBtn = create("TextButton", {
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -38, 0, 15),
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

    local function refreshBtnStates()
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

    for i, tier in ipairs({"Regular", "Neon", "Mega"}) do
        local b = create("TextButton", {
            BackgroundColor3 = THEME.bg,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 105, 0, 36),
            Position = UDim2.new(0, 15 + (i-1)*110, 0, 55),
            Text = tier,
            TextColor3 = THEME.text,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 11,
        }, box)
        addCorner(b, 10)
        addStroke(b, THEME.btnStroke, 1)
        tierBtns[tier] = b
        b.MouseButton1Click:Connect(function()
            state.tier = tier
            refreshBtnStates()
        end)
    end

    local potions = {"FR", "NP", "R", "F"}
    for i, potion in ipairs(potions) do
        local b = create("TextButton", {
            BackgroundColor3 = THEME.bg,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 75, 0, 32),
            Position = UDim2.new(0, 15 + (i-1)*82, 0, 105),
            Text = potion,
            TextColor3 = THEME.text,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 11,
        }, box)
        addCorner(b, 8)
        addStroke(b, THEME.btnStroke, 1)
        potionBtns[potion] = b
        b.MouseButton1Click:Connect(function()
            state.potion = potion
            refreshBtnStates()
        end)
    end

    valueLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 150),
        Size = UDim2.new(1, 0, 0, 42),
        Text = "",
        TextColor3 = THEME.accent,
        Font = Enum.Font.GothamBlack,
        TextSize = 32,
        ZIndex = 11,
    }, box)

    local function addBtn(text, side, color, xPos)
        local b = create("TextButton", {
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 155, 0, 44),
            Position = UDim2.new(0, xPos, 0, 205),
            Text = text,
            TextColor3 = THEME.panel,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            AutoButtonColor = false,
            ZIndex = 11,
        }, box)
        addCorner(b, 10)
        b.MouseButton1Click:Connect(function()
            local offer = (side == "your") and yourOffer or theirOffer
            table.insert(offer, {name = petName, tier = state.tier, potion = state.potion})
            refreshTrades()
            closeModal()
        end)
    end
    addBtn("Add to Your",  "your",  THEME.your,  15)
    addBtn("Add to Their", "their", THEME.their, 190)

    local cancel = create("TextButton", {
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -30, 0, 32),
        Position = UDim2.new(0, 15, 0, 265),
        Text = "Cancel",
        TextColor3 = THEME.sub,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 11,
    }, box)
    addCorner(cancel, 8)
    cancel.MouseButton1Click:Connect(closeModal)

    refreshBtnStates()
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

    -- Fenêtre Principale
    local main = create("Frame", {
        Name = "Main",
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(980, 660),
        Position = UDim2.new(0.5, -490, 0.5, -330),
        Parent = gui,
    })
    addCorner(main, 20)
    addStroke(main, THEME.btnStroke, 1.5)
    uiRefs.main = main

    -- Top Bar
    local titleBar = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = main,
    })
    
    local closeBtn = create("TextButton", {
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(1, -42, 0, 8),
        Text = "×",
        TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        AutoButtonColor = false,
    }, titleBar)
    addCorner(closeBtn, 10)
    addStroke(closeBtn, THEME.btnStroke, 1.5)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- Mini Mode Button (Permet de réduire l'UI pour trade)
    local miniBtn = create("TextButton", {
        BackgroundColor3 = THEME.accent,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(80, 32),
        Position = UDim2.new(1, -130, 0, 8),
        Text = "Mini Mode",
        TextColor3 = THEME.panel,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
    }, titleBar)
    addCorner(miniBtn, 10)

    local statusDot = create("Frame", {
        BackgroundColor3 = THEME.lose,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.new(1, -150, 0, 19),
    }, titleBar)
    addCorner(statusDot, 5)
    uiRefs.statusDot = statusDot

    -- ===== LEFT PANEL (Pet Browser) =====
    local left = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 45),
        Size = UDim2.fromOffset(430, 600),
        Parent = main,
    })

    local searchBg = create("Frame", {
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -45, 0, 48),
    }, left)
    addCorner(searchBg, 16)
    addStroke(searchBg, THEME.btnStroke, 1.5)

    local searchBox = create("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 0),
        Size = UDim2.new(1, -20, 1, 0),
        PlaceholderText = "Search",
        Text = "",
        TextColor3 = THEME.text,
        PlaceholderColor3 = THEME.sub,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, searchBg)

    local searchClear = create("TextButton", {
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 10, 0, 0),
        Size = UDim2.fromOffset(48, 48),
        Text = "×",
        TextColor3 = THEME.sub,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        AutoButtonColor = false,
    }, left)
    addCorner(searchClear, 16)
    addStroke(searchClear, THEME.btnStroke, 1.5)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        currentFilter = searchBox.Text
        if currentTab == "Pets" then refreshPetList() end
    end)
    searchClear.MouseButton1Click:Connect(function() searchBox.Text = "" end)

    -- Tabs (Pets, Players)
    local tabsData = {"Pets", "Players"}
    local tabBtns = {}
    
    local function updateTabs()
        for name, btn in pairs(tabBtns) do
            local isActive = (currentTab == name)
            btn.BackgroundColor3 = isActive and THEME.panel or THEME.bg
            btn.TextColor3 = isActive and THEME.text or THEME.sub
        end
        refreshPetList()
    end

    for i, t in ipairs(tabsData) do
        local tab = create("TextButton", {
            BackgroundColor3 = THEME.bg,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset((i-1)*125, 60),
            Size = UDim2.fromOffset(115, 40),
            Text = t,
            TextColor3 = THEME.sub,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            AutoButtonColor = false,
        }, left)
        addCorner(tab, 16)
        addStroke(tab, THEME.btnStroke, 1.5)
        tabBtns[t] = tab
        tab.MouseButton1Click:Connect(function()
            currentTab = t
            updateTabs()
        end)
    end

    -- Grid
    local scroll = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 115),
        Size = UDim2.new(1, 0, 1, -180),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = THEME.btnStroke,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = left,
    })
    create("UIGridLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        CellSize = UDim2.new(0, 98, 0, 115),
        CellPadding = UDim2.new(0, 10, 0, 10),
    }, scroll)
    uiRefs.petScroll = scroll

    -- Bottom Filters (F R D N M)
    local bottomBar = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 1, -55),
        Size = UDim2.new(1, 0, 0, 50),
        Parent = left,
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
        if currentTab == "Pets" then refreshPetList() end
    end

    for i, f in ipairs(filters) do
        local b = create("TextButton", {
            BackgroundColor3 = THEME.panel,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset((i-1)*86, 0),
            Size = UDim2.new(0, 78, 1, 0),
            Text = f.label,
            TextColor3 = THEME.text,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            AutoButtonColor = false,
        }, bottomBar)
        addCorner(b, 16)
        addStroke(b, THEME.btnStroke, 1.5)
        
        table.insert(filterBtns, {btn = b, tier = f.tier, potion = f.potion})
        b.MouseButton1Click:Connect(function()
            currentTier = f.tier
            currentPotion = f.potion
            updateFilterBtns()
        end)
    end
    updateFilterBtns()
    updateTabs()

    -- ===== RIGHT PANEL (Trade Calculator) =====
    local right = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(460, 45),
        Size = UDim2.fromOffset(505, 600),
        Parent = main,
    })

    local function makeTradePanel(side, xPos, color, title)
        local p = create("Frame", {
            BackgroundColor3 = THEME.panel,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(xPos, 0),
            Size = UDim2.fromOffset(242, 430),
            Parent = right,
        })
        addCorner(p, 16)
        addStroke(p, THEME.btnStroke, 1.5)

        local header = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            Parent = p,
        })
        
        create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 0),
            Size = UDim2.new(1, -30, 1, 0),
            Text = title,
            TextColor3 = color,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, header)

        local list = create("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(5, 40),
            Size = UDim2.fromOffset(232, 335),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = THEME.btnStroke,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = p,
        })
        create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
        }, list)
        create("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5) }, list)

        local total = create("TextLabel", {
            BackgroundColor3 = THEME.bg,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(10, 385),
            Size = UDim2.new(1, -20, 0, 34),
            Text = "Total : 0",
            TextColor3 = color,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Parent = p,
        })
        addCorner(total, 10)

        return list, total
    end

    uiRefs.yourList,  uiRefs.yourTotal  = makeTradePanel("your",  0,   THEME.your,  "Your Offer")
    uiRefs.theirList, uiRefs.theirTotal = makeTradePanel("their", 260, THEME.their, "Their Offer")

    local resultBar = create("Frame", {
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 445),
        Size = UDim2.fromOffset(502, 110),
        Parent = right,
    })
    addCorner(resultBar, 16)
    addStroke(resultBar, THEME.btnStroke, 1.5)

    uiRefs.resultLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 15),
        Size = UDim2.new(1, 0, 0, 46),
        Text = "Waiting for pets…",
        TextColor3 = THEME.sub,
        Font = Enum.Font.GothamBlack,
        TextSize = 38,
    }, resultBar)

    uiRefs.diffLabel = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 65),
        Size = UDim2.new(1, -20, 0, 24),
        Text = "Add pets to both sides to calculate.",
        TextColor3 = THEME.sub,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
    }, resultBar)

    local clearBtn = create("TextButton", {
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(100, 32),
        Position = UDim2.new(1, -110, 0, 10),
        Text = "Clear All",
        TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
    }, resultBar)
    addCorner(clearBtn, 8)
    addStroke(clearBtn, THEME.btnStroke, 1)
    clearBtn.MouseButton1Click:Connect(function()
        yourOffer = {}
        theirOffer = {}
        refreshTrades()
    end)

    -- ===== MINI MODE BAR =====
    local miniBar = create("Frame", {
        BackgroundColor3 = THEME.panel,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(400, 50),
        Position = UDim2.new(0.5, -200, 0, 10),
        Visible = false,
        ZIndex = 50,
    }, gui)
    addCorner(miniBar, 25)
    addStroke(miniBar, THEME.accent, 2)
    uiRefs.miniBar = miniBar

    uiRefs.miniBar.Your = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Text = "You: 0",
        TextColor3 = THEME.your,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
    }, miniBar)

    uiRefs.miniBar.Result = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -50, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Text = "IDLE",
        TextColor3 = THEME.sub,
        Font = Enum.Font.GothamBlack,
        TextSize = 18,
    }, miniBar)

    uiRefs.miniBar.Their = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -120, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Text = "Them: 0",
        TextColor3 = THEME.their,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
    }, miniBar)

    local restoreBtn = create("TextButton", {
        BackgroundColor3 = THEME.bg,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, 10, 0.5, -15),
        Text = "⤢",
        TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        AutoButtonColor = false,
    }, miniBar)
    addCorner(restoreBtn, 15)
    addStroke(restoreBtn, THEME.btnStroke, 1.5)

    -- Toggle Mini Mode
    miniBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        miniBar.Visible = true
    end)
    restoreBtn.MouseButton1Click:Connect(function()
        main.Visible = true
        miniBar.Visible = false
    end)

    -- Drag Logic for both Main and MiniBar
    local function makeDraggable(frame, dragArea)
        local dragging, dragInput, dragStart, startPos
        dragArea.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        dragArea.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local d = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    makeDraggable(main, titleBar)
    makeDraggable(miniBar, miniBar)

    uiRefs.showModal = showModal
end

-- ================= BOOT =================
buildUI()
refreshTrades()

local function loadLoop()
    local data = fetchPets(3)
    if data then
        petData = data
        rebuildIndex()
        refreshPetList()
        refreshTrades()
        uiRefs.statusDot.BackgroundColor3 = THEME.win
    end
    while mainGui and mainGui.Parent do
        task.wait(REFRESH_SECONDS)
        local d = fetchPets(1)
        if d then
            petData = d
            rebuildIndex()
            refreshPetList()
            refreshTrades()
            uiRefs.statusDot.BackgroundColor3 = THEME.win
        else
            uiRefs.statusDot.BackgroundColor3 = THEME.lose
        end
    end
end

task.spawn(loadLoop)