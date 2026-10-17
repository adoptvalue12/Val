--[[
    ============================================================
      ADOPT ME VALUE & TRADE — Delta Executor
      Version FINALE (Fix Anti-Lag, Images, Drag & Trade)
    ============================================================
]]

local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")

local BASE_URL         = "https://elvebredd-api.onrender.com"

-- ================= IMAGES (ASSET IDs) =================
-- J'ai ajouté quelques IDs pour que tu voies le rendu. 
-- Si un pet n'est pas là, il aura une belle icône colorée avec sa 1ère lettre.
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
local yourOffer     = {}
local theirOffer    = {}
local currentFilter = ""
local currentTab    = "Values"
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
    if n == 0 then return "-" end
    if n >= 1e9 then return string.format("%.1fB", n/1e9) end
    if n >= 1e6 then return string.format("%.1fM", n/1e6) end
    if n >= 1e3 then return string.format("%.1fK", n/1e3) end
    if n == math.floor(n) then return tostring(math.floor(n)) end
    return string.format("%.1f", n)
end

-- Couleur aléatoire basée sur le nom pour les avatars
local function getColorForName(name)
    local hash = 0
    for i = 1, #name do hash = (hash + string.byte(name, i)) % 360 end
    return Color3.fromHSV(hash/360, 0.6, 0.9)
end

local TIER_KEYS  = {Regular = "regular", Neon = "neon", Mega = "mega"}
local POTION_KEYS= {FR = "fr", NP = "np", R = "r", F = "f"}

-- Conversion sécurisée des valeurs
local function parseNum(val)
    if type(val) == "number" then return val end
    if type(val) == "string" then return tonumber(val:gsub(",", "")) or 0 end
    return 0
end

local function getVal(petObj, tier, potion)
    if not petObj then return 0 end
    local t = petObj[TIER_KEYS[tier]]
    if not t then return 0 end
    return parseNum(t[POTION_KEYS[potion]])
end

-- ================= HTTP & FILTRE =================
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
        if ok and type(data) == "table" then 
            -- FILTRE ANTI-LAG : On ne garde QUE les pets qui ont une vraie valeur
            local filtered = {}
            for _, p in ipairs(data) do
                if p.name and p.regular and p.regular.fr then
                    local fr = parseNum(p.regular.fr)
                    local nfr = p.neon and parseNum(p.neon.fr) or 0
                    local mfr = p.mega and parseNum(p.mega.fr) or 0
                    
                    -- Si au moins une des valeurs est supérieure à 0, c'est un vrai pet
                    if fr > 0 or nfr > 0 or mfr > 0 then
                        table.insert(filtered, p)
                    end
                end
            end
            return filtered
        end
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
        Size = UDim2.fromOffset(340, 540), Position = UDim2.new(0.5, -170, 0.5, -270),
        ClipsDescendants = true, Parent = gui
    })
    addCorner(main, 16)
    addStroke(main, THEME.stroke, 1.5)
    uiRefs.main = main

    -- Auto-Scale
    local scale = create("UIScale", {Parent = main})
    local function updateScale()
        local vp = Workspace.CurrentCamera.ViewportSize
        scale.Scale = math.min(vp.X / 360, vp.Y / 560, 1)
    end
    updateScale()
    Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

    -- Drag Logic (Bords plus épais pour mobile)
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

    -- Bordures de drag (20px pour faciliter la prise en main)
    local dragTop = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,40), ZIndex = 10, Parent = main})
    local dragBottom = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,0,1,-20), ZIndex = 10, Parent = main})
    local dragLeft = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(0,20,1,0), ZIndex = 10, Parent = main})
    local dragRight = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(0,20,1,0), Position = UDim2.new(1,-20,0,0), ZIndex = 10, Parent = main})
    
    makeDraggable(main, dragTop)
    makeDraggable(main, dragBottom)
    makeDraggable(main, dragLeft)
    makeDraggable(main, dragRight)

    -- Top Bar
    local topBar = create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,40), Parent = main})
    
    create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(15, 0), Size = UDim2.new(1,-120,1,0),
        Text = "Adopt Me", TextColor3 = THEME.text, Font = Enum.Font.GothamBold,
        TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left,
    }, topBar)

    local statusBtn = create("TextButton", {
        BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Size = UDim2.fromOffset(70,24),
        Position = UDim2.new(1,-105,0.5,-12), Text = "Load...", TextColor3 = THEME.lose,
        Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false,
    }, topBar)
    addCorner(statusBtn, 6); addStroke(statusBtn, THEME.stroke, 1)

    local closeBtn = create("TextButton", {
        BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Size = UDim2.fromOffset(24,24),
        Position = UDim2.new(1,-32,0.5,-12), Text = "×", TextColor3 = THEME.text,
        Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false,
    }, topBar)
    addCorner(closeBtn, 6); addStroke(closeBtn, THEME.stroke, 1)

    -- Icône Flottante
    local floatBtn = create("TextButton", {
        BackgroundColor3 = THEME.accent, BorderSizePixel = 0, Size = UDim2.fromOffset(50,50),
        Position = UDim2.new(0, 20, 0.5, -25), Text = "🐾", TextColor3 = THEME.panel,
        Font = Enum.Font.GothamBold, TextSize = 24, AutoButtonColor = false, Visible = false, Parent = gui
    })
    addCorner(floatBtn, 25)
    addStroke(floatBtn, Color3.fromRGB(255, 255, 255), 2)
    makeDraggable(floatBtn, floatBtn)

    local function toggleUI(vis)
        main.Visible = vis; floatBtn.Visible = not vis
    end
    closeBtn.MouseButton1Click:Connect(function() toggleUI(false) end)
    floatBtn.MouseButton1Click:Connect(function() toggleUI(true) end)

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
            Text = t, TextColor3 = THEME.sub, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
        }, tabBar)
        addCorner(b, 6)
        tabBtns[t] = b
        b.MouseButton1Click:Connect(function() switchTab(t) end)
    end

    -- ================= TAB 1 : VALUES =================
    local valuesContainer = create("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(15, 80), Size = UDim2.new(1,-30,1,-90), Parent = main})
    uiRefs.valuesContainer = valuesContainer

    local searchBg = create("Frame", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Size = UDim2.new(1,0,0,32), Parent = valuesContainer})
    addCorner(searchBg, 8); addStroke(searchBg, THEME.stroke, 1)
    local searchBox = create("TextBox", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(10,0), Size = UDim2.new(1,-40,1,0),
        PlaceholderText = "Search pet...", Text = "", TextColor3 = THEME.text, PlaceholderColor3 = THEME.sub,
        Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    }, searchBg)
    
    -- Bouton Clear pour la recherche
    local clearSearch = create("TextButton", {BackgroundTransparency = 1, Position = UDim2.new(1,-30,0,0), Size = UDim2.fromOffset(30,32), Text = "×", TextColor3 = THEME.sub, Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false}, searchBg)
    clearSearch.MouseButton1Click:Connect(function() searchBox.Text = "" end)

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        currentFilter = searchBox.Text
        uiRefs.refreshList()
    end)

    local currentTier = "Regular"
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
            BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.new((i-1)*0.33, 2, 0, 38), Size = UDim2.new(0.33, -4, 0, 26),
            Text = t, TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false,
        }, valuesContainer)
        addCorner(b, 6); addStroke(b, THEME.stroke, 1)
        tierBtns[t] = b
        b.MouseButton1Click:Connect(function() currentTier = t; updateTierBtns() end)
    end

    local currentPotion = "fr"
    local potBtns = {}
    local function updatePotBtns()
        for name, btn in pairs(potBtns) do
            btn.BackgroundColor3 = (currentPotion == name) and THEME.accent or THEME.panel
            btn.TextColor3 = (currentPotion == name) and THEME.panel or THEME.text
        end
        uiRefs.refreshList()
    end
    for i, p in ipairs({"fr", "np", "r", "f"}) do
        local b = create("TextButton", {
            BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.new((i-1)*0.25, 2, 0, 70), Size = UDim2.new(0.25, -4, 0, 26),
            Text = string.upper(p), TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false,
        }, valuesContainer)
        addCorner(b, 6); addStroke(b, THEME.stroke, 1)
        potBtns[p] = b
        b.MouseButton1Click:Connect(function() currentPotion = p; updatePotBtns() end)
    end

    local listScroll = create("ScrollingFrame", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 105), Size = UDim2.new(1,0,1,-105),
        ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = valuesContainer
    })
    create("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}, listScroll)

    uiRefs.refreshList = function()
        for _, c in ipairs(listScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local filter = string.lower(currentFilter)
        local sorted = {}
        for _, p in ipairs(petData) do
            if filter == "" or string.find(string.lower(p.name), filter, 1, true) then 
                table.insert(sorted, p) 
            end
        end
        table.sort(sorted, function(a,b) return getVal(a, currentTier, currentPotion) > getVal(b, currentTier, currentPotion) end)

        for i, p in ipairs(sorted) do
            local val = getVal(p, currentTier, currentPotion)
            local row = create("TextButton", {BackgroundColor3 = THEME.card, BorderSizePixel = 0, Size = UDim2.new(1,-4,0,44), LayoutOrder = i, Text = "", AutoButtonColor = false}, listScroll)
            addCorner(row, 8); addStroke(row, THEME.stroke, 1)

            -- Image ou Avatar
            local imgFrame = create("Frame", {BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Size = UDim2.fromOffset(32,32), Position = UDim2.new(0,6,0.5,-16)}, row)
            addCorner(imgFrame, 6)
            local img = PET_IMAGE_IDS[p.name]
            if img then
                create("ImageLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), Image = "rbxassetid://"..img}, imgFrame)
            else
                -- Joli avatar coloré si pas d'image
                imgFrame.BackgroundColor3 = getColorForName(p.name)
                create("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), Text = string.sub(p.name,1,1):upper(), TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBlack, TextSize = 16}, imgFrame)
            end

            create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(45,0), Size = UDim2.new(1,-110,1,0), Text = p.name, TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, row)
            
            create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-65,0,0), Size = UDim2.fromOffset(60,44), Text = fmt(val), TextColor3 = val > 0 and THEME.accent or THEME.sub, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right}, row)

            -- Clic pour ajouter rapidement au trade
            row.MouseButton1Click:Connect(function()
                uiRefs.openSelector("your", p)
            end)
        end
    end
    updateTierBtns()
    updatePotBtns()

    -- ================= TAB 2 : TRADE =================
    local tradeContainer = create("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(15, 80), Size = UDim2.new(1,-30,1,-90), Visible = false, Parent = main})
    uiRefs.tradeContainer = tradeContainer

    local function createTradeBox(title, color, yPos, side)
        local box = create("Frame", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.fromOffset(0,yPos), Size = UDim2.new(1,0,0,160), Parent = tradeContainer})
        addCorner(box, 10); addStroke(box, THEME.stroke, 1)
        
        create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(12,8), Size = UDim2.new(1,-50,0,20), Text = title, TextColor3 = color, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, box)
        
        -- GROS BOUTON + bien visible
        local addBtn = create("TextButton", {BackgroundColor3 = color, BorderSizePixel = 0, Position = UDim2.new(1,-36,6), Size = UDim2.fromOffset(24,24), Text = "+", TextColor3 = THEME.panel, Font = Enum.Font.GothamBlack, TextSize = 18, AutoButtonColor = false}, box)
        addCorner(addBtn, 6)
        addBtn.MouseButton1Click:Connect(function() uiRefs.openSelector(side) end)
        
        local scroll = create("ScrollingFrame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(5,32), Size = UDim2.new(1,-10,1,-55), ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y}, box)
        create("UIListLayout", {Padding = UDim.new(0,4)}, scroll)
        
        local totalLbl = create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,12,1,-24), Size = UDim2.new(1,-24,0,16), Text = "Total: 0", TextColor3 = color, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right}, box)
        
        return scroll, totalLbl
    end

    uiRefs.yourScroll, uiRefs.yourTotal = createTradeBox("Your Offer", THEME.your, 0, "your")
    uiRefs.theirScroll, uiRefs.theirTotal = createTradeBox("Their Offer", THEME.their, 170, "their")

    local resultBox = create("Frame", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.fromOffset(0,340), Size = UDim2.new(1,0,0,90), Parent = tradeContainer})
    addCorner(resultBox, 10); addStroke(resultBox, THEME.stroke, 1)

    uiRefs.resultLbl = create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,0,5), Size = UDim2.new(1,0,30), Text = "Waiting...", TextColor3 = THEME.sub, Font = Enum.Font.GothamBlack, TextSize = 24}, resultBox)
    uiRefs.diffLbl = create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0,0,40), Size = UDim2.new(1,0,20), Text = "Add pets to calculate", TextColor3 = THEME.sub, Font = Enum.Font.Gotham, TextSize = 11}, resultBox)

    local copyBtn = create("TextButton", {BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Position = UDim2.new(0,10,1,-25), Size = UDim2.fromOffset(60,20), Text = "Copy", TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false}, resultBox)
    addCorner(copyBtn, 4); addStroke(copyBtn, THEME.stroke, 1)
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("Trade Result: "..uiRefs.resultLbl.Text.." | "..uiRefs.diffLbl.Text)
            copyBtn.Text = "Copied!"
            task.wait(1)
            copyBtn.Text = "Copy"
        end
    end)

    local clearBtn = create("TextButton", {BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Position = UDim2.new(1,-70,1,-25), Size = UDim2.fromOffset(60,20), Text = "Clear", TextColor3 = THEME.lose, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false}, resultBox)
    addCorner(clearBtn, 4); addStroke(clearBtn, THEME.stroke, 1)
    clearBtn.MouseButton1Click:Connect(function() yourOffer = {}; theirOffer = {}; uiRefs.refreshTrade() end)

    uiRefs.refreshTrade = function()
        local function build(offer, scroll, totalLbl)
            for _, c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
            local total = 0
            for i, e in ipairs(offer) do
                local v = getVal(e.pet, e.tier, e.potion)
                total = total + v
                local row = create("Frame", {BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Size = UDim2.new(1,-4,0,26), LayoutOrder = i}, scroll)
                addCorner(row, 4)
                create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(6,0), Size = UDim2.new(1,-40,1,0), Text = e.pet.name.." ("..e.tier.." "..string.upper(e.potion)..")", TextColor3 = THEME.text, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, row)
                create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-60,0,0), Size = UDim2.fromOffset(50,26), Text = fmt(v), TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right}, row)
                
                local x = create("TextButton", {BackgroundTransparency = 1, Position = UDim2.new(1,-22,0.5,-8), Size = UDim2.fromOffset(16,16), Text = "×", TextColor3 = THEME.lose, Font = Enum.Font.GothamBold, TextSize = 12}, row)
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

    -- ================= MODAL SÉLECTEUR =================
    uiRefs.openSelector = function(side, preSelectedPet)
        local modal = create("Frame", {
            BackgroundColor3 = THEME.bg, BorderSizePixel = 0, Size = UDim2.fromScale(1,1),
            Position = UDim2.fromScale(0,0), ZIndex = 20, Parent = main
        })
        addCorner(modal, 16)
        
        local sideText = (side == "your") and "Add to YOUR offer" or "Add to THEIR offer"
        local sideColor = (side == "your") and THEME.your or THEME.their

        create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(15,15), Size = UDim2.new(1,-50,0,20), Text = sideText, TextColor3 = sideColor, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 21}, modal)
        
        local close = create("TextButton", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.new(1,-36,12), Size = UDim2.fromOffset(24,24), Text = "×", TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 21}, modal)
        addCorner(close, 6); addStroke(close, THEME.stroke, 1)
        close.MouseButton1Click:Connect(function() modal:Destroy() end)

        local sBg = create("Frame", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.fromOffset(15,45), Size = UDim2.new(1,-30,0,32), ZIndex = 21}, modal)
        addCorner(sBg, 8); addStroke(sBg, THEME.stroke, 1)
        local sBox = create("TextBox", {BackgroundTransparency = 1, Position = UDim2.fromOffset(10,0), Size = UDim2.new(1,-20,1,0), PlaceholderText = "Search...", Text = preSelectedPet and preSelectedPet.name or "", TextColor3 = THEME.text, PlaceholderColor3 = THEME.sub, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 21}, sBg)

        local currentT = currentTier
        local tBtns = {}
        local function updateT()
            for name, btn in pairs(tBtns) do
                btn.BackgroundColor3 = (currentT == name) and THEME.accent or THEME.panel
                btn.TextColor3 = (currentT == name) and THEME.panel or THEME.text
            end
            uiRefs.refreshModalList(sBox.Text, currentT, currentP, side, mScroll)
        end
        for i, t in ipairs({"Regular", "Neon", "Mega"}) do
            local b = create("TextButton", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.fromOffset(15 + (i-1)*90, 85), Size = UDim2.fromOffset(85,26), Text = t, TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 21}, modal)
            addCorner(b, 6); addStroke(b, THEME.stroke, 1)
            tBtns[t] = b
            b.MouseButton1Click:Connect(function() currentT = t; updateT() end)
        end

        local currentP = currentPotion
        local pBtns = {}
        local function updateP()
            for name, btn in pairs(pBtns) do
                btn.BackgroundColor3 = (currentP == name) and THEME.accent or THEME.panel
                btn.TextColor3 = (currentP == name) and THEME.panel or THEME.text
            end
            uiRefs.refreshModalList(sBox.Text, currentT, currentP, side, mScroll)
        end
        for i, p in ipairs({"fr", "np", "r", "f"}) do
            local b = create("TextButton", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Position = UDim2.fromOffset(15 + (i-1)*72, 118), Size = UDim2.fromOffset(68,26), Text = string.upper(p), TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 21}, modal)
            addCorner(b, 6); addStroke(b, THEME.stroke, 1)
            pBtns[p] = b
            b.MouseButton1Click:Connect(function() currentP = p; updateP() end)
        end

        local mScroll = create("ScrollingFrame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(10,155), Size = UDim2.new(1,-20,1,-165), ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 21}, modal)
        create("UIListLayout", {Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder}, mScroll)

        uiRefs.refreshModalList = function(filterText, tier, potion, currentSide, scroll)
            for _, c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            local f = string.lower(filterText)
            local sorted = {}
            for _, p in ipairs(petData) do
                if f == "" or string.find(string.lower(p.name), f, 1, true) then table.insert(sorted, p) end
            end
            table.sort(sorted, function(a,b) return getVal(a, tier, potion) > getVal(b, tier, potion) end)

            for i, p in ipairs(sorted) do
                local val = getVal(p, tier, potion)
                local b = create("TextButton", {BackgroundColor3 = THEME.panel, BorderSizePixel = 0, Size = UDim2.new(1,-4,0,40), LayoutOrder = i, Text = "", AutoButtonColor = false, ZIndex = 21}, scroll)
                addCorner(b, 6); addStroke(b, THEME.stroke, 1)
                
                create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.fromOffset(8,0), Size = UDim2.new(1,-70,1,0), Text = p.name, TextColor3 = THEME.text, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 21}, b)
                create("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(1,-65,0,0), Size = UDim2.fromOffset(55,40), Text = fmt(val), TextColor3 = val > 0 and sideColor or THEME.sub, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 21}, b)
                
                b.MouseButton1Click:Connect(function()
                    local offer = (currentSide == "your") and yourOffer or theirOffer
                    table.insert(offer, {pet = p, tier = tier, potion = potion})
                    uiRefs.refreshTrade()
                    modal:Destroy()
                end)
            end
        end
        sBox:GetPropertyChangedSignal("Text"):Connect(function() uiRefs.refreshModalList(sBox.Text, currentT, currentP, side, mScroll) end)
        
        updateT()
        updateP()
    end

    switchTab("Values")

    -- Fonction de chargement
    local function loadData()
        statusBtn.Text = "Loading..."
        statusBtn.TextColor3 = THEME.fair
        task.spawn(function()
            local data = fetchPets()
            if data then
                petData = data
                statusBtn.Text = #petData .. " Pets"
                statusBtn.TextColor3 = THEME.win
                uiRefs.refreshList()
                uiRefs.refreshTrade()
            else
                statusBtn.Text = "Error"
                statusBtn.TextColor3 = THEME.lose
            end
        end)
    end

    statusBtn.MouseButton1Click:Connect(loadData)
    loadData()
end

-- ================= BOOT =================
buildUI()