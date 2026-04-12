-- ================================
-- ZayacHub Pressure Combined Script
-- ================================

-- Глобальні таблиці та дефолтні значення
local defaults = {
    ESP = {
        DoorESP = false,
        CurrencyESP = false,
        ItemESP = false,
        MonsterESP = false,
        GeneratorESP = false,
        FakeDoorESP = false,
        MonsterLockerESP = false,
    },

    AutoInputCode = false,
    TeleportToDoorLock = false,

    NoLocalDamage = false,
    AutoHide = false,

    AntiSearchlights = false,
    AntiEyefestation = false,
    AntiTraps = false, -- додано з Pressure1
    AntiFakeDoors = false, -- додано з Pressure1

    ExtraPrompt = 0,
    InstantInteract = false,
    AutoGrabCurrency = false,
    NotifyMonsters = false,
    SpectateEntity = false,
    BetterDoors = false
}

local vals = table.clone(defaults)
vals.ESP = table.clone(defaults.ESP)

-- Автозбереження налаштувань (з Pressure1)
local ConfigurationSaving = {
    Enabled = true,
    FolderName = "Pressure",
    FileName = "Pressure"
}

-- Глобальна таблиця
local function getGlobalTable()
    return typeof(getfenv().getgenv) == "function" and typeof(getfenv().getgenv()) == "table" and getfenv().getgenv() or _G
end

getGlobalTable().GameName = "true"
getGlobalTable().FireHubLoaded = true

-- Підключення бібліотек
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zayac333/Pressure/main/Menu.lua", true))()
local espLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zayac333/Pressure/main/Librare2.lua", true))()
local txtf = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zayac333/Pressure/main/SideText.lua", true))()
local network = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zayac333/Pressure/main/Librare.lua", true))()

local fireproximityprompt = function(...)
    return network.Other:FireProximityPrompt(...)
end
-- ================================
-- СТВОРЕННЯ ВІКНА
-- ================================

local window = lib:MakeWindow({
    Title = "ZayacHub - Pressure",
    CloseCallback = function()
        for i, v in defaults.ESP do
            espLib.ESPValues[i] = v
        end
        for i, v in defaults do
            vals[i] = v
        end
        getGlobalTable().FireHubLoaded = false
    end
}, true)

-- Перша сторінка
local page = window:AddPage({Title = "! READ ME NOW !"})
page:AddLabel({Caption = "Because pressure has been updated, ZayacHub got patched"})
page:AddLabel({Caption = "At this moment script being fully rewrited"})
page:AddLabel({Caption = "Expect more features to be added"})
-- ================================
-- СПИСКИ МОНСТРІВ (з Pressure1)
-- ================================

local KEYCARDS = {
    NormalKeyCard = { label = "Keycard",       fill = Color3.fromRGB(255, 50,  50),  outline = Color3.fromRGB(255, 150, 150) },
    InnerKeyCard  = { label = "Inner Keycard", fill = Color3.fromRGB(0,   120, 255), outline = Color3.fromRGB(100, 180, 255) },
    RidgeKeyCard  = { label = "Ridge Keycard", fill = Color3.fromRGB(255, 150, 0),   outline = Color3.fromRGB(255, 200, 100) },
    PasswordPaper = { label = "Password",      fill = Color3.fromRGB(0,   200, 80),  outline = Color3.fromRGB(100, 255, 150) },
}

local ITEM_PATTERNS = {
    { pattern = "Lantern",      label = "Lantern",       fill = Color3.fromRGB(255, 200, 0),   outline = Color3.fromRGB(255, 230, 100) },
    { pattern = "Flashlight",   label = "Flashlight",    fill = Color3.fromRGB(200, 200, 255), outline = Color3.fromRGB(255, 255, 255) },
    { pattern = "Blacklight",   label = "Blacklight",    fill = Color3.fromRGB(150, 0,   255), outline = Color3.fromRGB(200, 100, 255) },
    { pattern = "Medkit",       label = "Medkit",        fill = Color3.fromRGB(255, 50,  50),  outline = Color3.fromRGB(255, 150, 150) },
    { pattern = "HealthBoost",  label = "Health Boost",  fill = Color3.fromRGB(255, 100, 100), outline = Color3.fromRGB(255, 180, 180) },
    { pattern = "Defib",        label = "Defib",         fill = Color3.fromRGB(255, 0,   100), outline = Color3.fromRGB(255, 100, 180) },
    { pattern = "FlashBeacon",  label = "Flash Beacon",  fill = Color3.fromRGB(255, 255, 50),  outline = Color3.fromRGB(255, 255, 150) },
    { pattern = "Scanner",      label = "Scanner",       fill = Color3.fromRGB(0,   255, 200), outline = Color3.fromRGB(100, 255, 230) },
    { pattern = "^Book$",       label = "Book",          fill = Color3.fromRGB(180, 120, 40),  outline = Color3.fromRGB(220, 170, 100) },
    { pattern = "CodeBreacher", label = "Code Breacher", fill = Color3.fromRGB(0,   200, 255), outline = Color3.fromRGB(100, 230, 255) },
    { pattern = "Gummylight",   label = "Gummylight",    fill = Color3.fromRGB(255, 100, 200), outline = Color3.fromRGB(255, 180, 230) },
    { pattern = "WindupLight",  label = "Windup Light",  fill = Color3.fromRGB(255, 180, 50),  outline = Color3.fromRGB(255, 210, 120) },
    { pattern = "SPRINT",       label = "SPRINT",        fill = Color3.fromRGB(50,  255, 100), outline = Color3.fromRGB(150, 255, 180) },
    { pattern = "ToyRemote",    label = "Toy Remote",    fill = Color3.fromRGB(100, 100, 255), outline = Color3.fromRGB(180, 180, 255) },
    { pattern = "Battery",      label = "Battery",       fill = Color3.fromRGB(255, 230, 0),   outline = Color3.fromRGB(255, 245, 100) },
    { pattern = "[Nn]eostyk",   label = "NeoStyk",       fill = Color3.fromRGB(0,   255, 150), outline = Color3.fromRGB(100, 255, 200) },
}

local MONSTERS = {
    A60=true, AbstractArt=true, Angler=true,
    Bottomfeeder=true, Bouncers=true, Candlebearers=true, Candlebrutes=true,
    Eyefestation=true, GuardianAngel=true, Harbinger=true,
    ImaginaryFriend=true, Lopee=true, Pandemonium=true,
    Parasite=true, Pipsqueak=true, Rebarb=true, Redeemer=true,
    Skelepede=true, Stan=true, TheDiVine=true, TheEducator=true,
    TheMindscape=true, ThePainter=true, TheSaboteur=true,
    Trenchbleeder=true, WallDwellers=true, WitchingHour=true,
    Blitz=true, Squiddles=true, NaviAI=true, Void=true,
    RottenCoral=true, Searchlights=true, DefenseSystem=true,
    Froger=true, Chainsmoker=true, Pinkie=true,
    WallDweller=true, MeatWallDweller=true, RottenWallDweller=true,
    Bouncer=true, SkeletonHead=true,
    -- Ridge variants
    RidgeAngler=true, RidgeChainsmoker=true, RidgePinkie=true,
    RidgeBlitz=true, RidgeFroger=true, RidgePandemonium=true,
}

local PANDEMONIUM_NAMES = {
    Pandemonium=true, Anglemonium=true, Frogermonium=true,
    Blitzemonium=true, Pandesmoker=true, Pinkimonium=true,
    RidgePandemonium=true,
}

local CURRENCY_PATTERNS = {
    { pattern="^UCurrency5%-",   label="~5$",                fill=Color3.fromRGB(100,220,255), outline=Color3.fromRGB(180,240,255) },
    { pattern="^UCurrency10%-",  label="~10$",               fill=Color3.fromRGB(50,180,255),  outline=Color3.fromRGB(150,220,255) },
    { pattern="^UCurrency15%-",  label="~15$",               fill=Color3.fromRGB(0,150,255),   outline=Color3.fromRGB(100,200,255) },
    { pattern="^UCurrency25%-",  label="~25$",               fill=Color3.fromRGB(0,100,220),   outline=Color3.fromRGB(80,170,255)  },
    { pattern="^UCurrency50%-",  label="~50$",               fill=Color3.fromRGB(0,80,200),    outline=Color3.fromRGB(60,150,240)  },
    { pattern="^UCurrency100%-", label="~100$",              fill=Color3.fromRGB(0,50,180),    outline=Color3.fromRGB(50,120,220)  },
    { pattern="^UCurrency200%-", label="~200$",              fill=Color3.fromRGB(0,30,150),    outline=Color3.fromRGB(30,100,200)  },
    { pattern="^Currency5%-",    label="5$",                 fill=Color3.fromRGB(180,255,100), outline=Color3.fromRGB(220,255,170) },
    { pattern="^Currency10%-",   label="10$",                fill=Color3.fromRGB(100,220,50),  outline=Color3.fromRGB(170,240,120) },
    { pattern="^Currency15%-",   label="15$",                fill=Color3.fromRGB(50,200,50),   outline=Color3.fromRGB(130,230,130) },
    { pattern="^Currency25%-",   label="25$",                fill=Color3.fromRGB(0,180,80),    outline=Color3.fromRGB(80,220,150)  },
    { pattern="^Currency50%-",   label="50$",                fill=Color3.fromRGB(0,150,255),   outline=Color3.fromRGB(80,200,255)  },
    { pattern="^Currency100%-",  label="100$",               fill=Color3.fromRGB(255,200,0),   outline=Color3.fromRGB(255,230,100) },
    { pattern="^Currency200%-",  label="200$",               fill=Color3.fromRGB(255,100,0),   outline=Color3.fromRGB(255,180,80)  },
    { pattern="^Caps$",          label="Rare: Caps",         fill=Color3.fromRGB(200,0,255),   outline=Color3.fromRGB(255,100,255) },
    { pattern="^DoorsGold",      label="Rare: Doors Gold",   fill=Color3.fromRGB(200,0,255),   outline=Color3.fromRGB(255,100,255) },
    { pattern="^GOLDDD$",        label="Rare: GOLDDD",       fill=Color3.fromRGB(200,0,255),   outline=Color3.fromRGB(255,100,255) },
    { pattern="^HypnoCoin$",     label="Rare: Hypno Coin",   fill=Color3.fromRGB(200,0,255),   outline=Color3.fromRGB(255,100,255) },
    { pattern="^Regret$",        label="Rare: Regret",       fill=Color3.fromRGB(200,0,255),   outline=Color3.fromRGB(255,100,255) },
    { pattern="^Studs$",         label="Rare: Studs",        fill=Color3.fromRGB(200,0,255),   outline=Color3.fromRGB(255,100,255) },
    { pattern="^SuperCredits$",  label="Rare: Super Credits",fill=Color3.fromRGB(200,0,255),   outline=Color3.fromRGB(255,100,255) },
    { pattern="^RareCurrency",   label="RARE$",              fill=Color3.fromRGB(200,0,255),   outline=Color3.fromRGB(255,100,255) },
    { pattern="^Blueprint$",     label="Blueprint",          fill=Color3.fromRGB(0,180,255),   outline=Color3.fromRGB(100,220,255) },
}



-- ================================
-- ХЕЛПЕРИ ДЛЯ ESP
-- ================================

local function GetItemConfig(name)
    for _, e in ipairs(ITEM_PATTERNS) do
        if string.match(name, e.pattern) then
            return { label=e.label, fill=e.fill, outline=e.outline }
        end
    end
    return nil
end

local function GetCurrencyConfig(name)
    for _, e in ipairs(CURRENCY_PATTERNS) do
        if string.match(name, e.pattern) then
            return { label=e.label, fill=e.fill, outline=e.outline }
        end
    end
    return nil
end

local function AddESP(part, config)
    if not part or not part.Parent then return end
    if part:FindFirstChildOfClass("Highlight") then return end

    local h = Instance.new("Highlight")
    h.Adornee = part
    h.FillColor = config.fill
    h.OutlineColor = config.outline or Color3.new(1,1,1)
    h.FillTransparency = config.fillTransparency or 0.4
    h.OutlineTransparency = 0
    h.Parent = part

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_Label"
    bb.Adornee = part
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 140, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Parent = part

    local lbl = Instance.new("TextLabel")
    lbl.Text = config.label
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = config.textColor or Color3.new(1,1,1)
    lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    lbl.TextStrokeTransparency = 0.3
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = bb
end

local function RemoveESP(part)
    if not part then return end
    local h = part:FindFirstChildOfClass("Highlight")
    if h then h:Destroy() end
    local b = part:FindFirstChild("ESP_Label")
    if b then b:Destroy() end
end

-- ================================
-- ВКЛАДКА VISUAL (з групами як у Pressure1)
-- ================================

local pageVisual = window:AddPage({Title = "Visual"})

-- Items
pageVisual:AddLabel({Caption = "Items"})

-- Keycard ESP
pageVisual:AddToggle({Caption = "Keycard ESP", Default = false, Callback = function(b)
    vals.ESP.KeycardESP = b
    if b then
        -- первинне сканування
        for _, obj in ipairs(workspace:GetDescendants()) do
            if KEYCARDS[obj.Name] then AddESP(obj, KEYCARDS[obj.Name]) end
        end
        -- цикл
        keycardConns = {}
        table.insert(keycardConns, workspace.DescendantAdded:Connect(function(obj)
            if vals.ESP.KeycardESP and KEYCARDS[obj.Name] then AddESP(obj, KEYCARDS[obj.Name]) end
        end))
    else
        for _, obj in ipairs(workspace:GetDescendants()) do
            if KEYCARDS[obj.Name] then RemoveESP(obj) end
        end
        if keycardConns then for _, c in ipairs(keycardConns) do c:Disconnect() end end
        keycardConns = {}
    end
end})

-- Currency & Blueprint ESP
pageVisual:AddToggle({Caption = "Currency & Blueprint ESP", Default = false, Callback = function(b)
    vals.ESP.CurrencyESP = b
    if b then
        for _, obj in ipairs(workspace:GetDescendants()) do
            local cfg = GetCurrencyConfig(obj.Name)
            if cfg then AddESP(obj, cfg) end
        end
        currencyConns = {}
        table.insert(currencyConns, workspace.DescendantAdded:Connect(function(obj)
            local cfg = GetCurrencyConfig(obj.Name)
            if vals.ESP.CurrencyESP and cfg then AddESP(obj, cfg) end
        end))
    else
        for _, obj in ipairs(workspace:GetDescendants()) do
            local cfg = GetCurrencyConfig(obj.Name)
            if cfg then RemoveESP(obj) end
        end
        if currencyConns then for _, c in ipairs(currencyConns) do c:Disconnect() end end
        currencyConns = {}
    end
end})

-- Item ESP
pageVisual:AddToggle({Caption = "Item ESP", Default = false, Callback = function(b)
    vals.ESP.ItemESP = b
    if b then
        for _, obj in ipairs(workspace:GetDescendants()) do
            local cfg = GetItemConfig(obj.Name)
            if cfg then AddESP(obj, cfg) end
        end
        itemConns = {}
        table.insert(itemConns, workspace.DescendantAdded:Connect(function(obj)
            local cfg = GetItemConfig(obj.Name)
            if vals.ESP.ItemESP and cfg then AddESP(obj, cfg) end
        end))
    else
        for _, obj in ipairs(workspace:GetDescendants()) do
            local cfg = GetItemConfig(obj.Name)
            if cfg then RemoveESP(obj) end
        end
        if itemConns then for _, c in ipairs(itemConns) do c:Disconnect() end end
        itemConns = {}
    end
end})

-- Monster ESP
pageVisual:AddToggle({Caption = "Monster ESP", Default = false, Callback = function(b)
    vals.ESP.MonsterESP = b
    monsterEspActive = b
    local tracked = {}

    local function applyESP(child)
        if not monsterEspActive then return end
        if tracked[child] then return end
        tracked[child] = true
        pcall(AddESP, child, {
            fill = Color3.fromRGB(200,0,0),
            outline = Color3.fromRGB(255,200,0),
            textColor = Color3.fromRGB(255,0,0),
            fillTransparency = 0.3,
            label = "☠ " .. child.Name
        })
        table.insert(monsterEspConns, child.AncestryChanged:Connect(function()
            if not child:IsDescendantOf(game) then
                pcall(RemoveESP, child)
                tracked[child] = nil
            end
        end))
    end

    local function scanWorkspace()
        for _, child in ipairs(workspace:GetChildren()) do
            if MONSTERS[child.Name] or PANDEMONIUM_NAMES[child.Name] then
                applyESP(child)
            end
        end
    end

    local function listenContainer(container)
        table.insert(monsterConns, container.ChildAdded:Connect(function(child)
            if monsterEspActive and (MONSTERS[child.Name] or PANDEMONIUM_NAMES[child.Name]) then
                applyESP(child)
            end
        end))
        table.insert(monsterConns, container.DescendantAdded:Connect(function(child)
            if monsterEspActive and (MONSTERS[child.Name] or PANDEMONIUM_NAMES[child.Name]) then
                applyESP(child)
            end
        end))
    end

    if b then
        scanWorkspace()
        for _, child in ipairs(workspace.GameplayFolder.Monsters:GetChildren()) do
            if MONSTERS[child.Name] or PANDEMONIUM_NAMES[child.Name] then
                applyESP(child)
            end
        end
        monsterConns = {}
        listenContainer(workspace)
        listenContainer(workspace.GameplayFolder.Monsters)
    else
        if monsterConns then for _, c in ipairs(monsterConns) do c:Disconnect() end end
        monsterConns = {}
        tracked = {}
        for _, child in ipairs(workspace:GetChildren()) do
            if MONSTERS[child.Name] or PANDEMONIUM_NAMES[child.Name] then pcall(RemoveESP, child) end
        end
        for _, child in ipairs(workspace.GameplayFolder.Monsters:GetChildren()) do
            if MONSTERS[child.Name] or PANDEMONIUM_NAMES[child.Name] then pcall(RemoveESP, child) end
        end
    end
end})

-- Monster Locker ESP
pageVisual:AddToggle({Caption = "Monster Locker ESP", Default = false, Callback = function(b)
    vals.ESP.MonsterLockerESP = b
    local cfg = {
        label = "⚠ MONSTER LOCKER",
        fill = Color3.fromRGB(200,0,0),
        outline = Color3.fromRGB(255,80,80),
        textColor = Color3.fromRGB(255,80,80),
        fillTransparency = 0.3
    }

    if b then
        -- первинне сканування
        for _, room in ipairs(workspace.GameplayFolder.Rooms:GetChildren()) do
            for _, d in ipairs(room:GetDescendants()) do
                if d.Name == "MonsterLocker" then AddESP(d, cfg) end
            end
        end

        -- цикл: нові шафки
        lockerConns = {}
        table.insert(lockerConns, workspace.GameplayFolder.Rooms.DescendantAdded:Connect(function(d)
            if vals.ESP.MonsterLockerESP and d.Name == "MonsterLocker" then
                AddESP(d, cfg)
            end
        end))
    else
        -- вимкнення: прибираємо ESP
        for _, room in ipairs(workspace.GameplayFolder.Rooms:GetChildren()) do
            for _, d in ipairs(room:GetDescendants()) do
                if d.Name == "MonsterLocker" then RemoveESP(d) end
            end
        end
        if lockerConns then
            for _, c in ipairs(lockerConns) do c:Disconnect() end
            lockerConns = {}
        end
    end
end})

--Fake door ESP
pageVisual:AddToggle({Caption = "Fake Door ESP", Default = false, Callback = function(b)
    vals.ESP.FakeDoorESP = b
    local cfg = {
        label = "✖ FAKE DOOR",
        fill = Color3.fromRGB(180,0,0),
        outline = Color3.fromRGB(255,0,0),
        textColor = Color3.fromRGB(255,0,0),
        fillTransparency = 0.3
    }

    if b then
        -- первинне сканування
        for _, room in ipairs(workspace.GameplayFolder.Rooms:GetChildren()) do
            for _, d in ipairs(room:GetDescendants()) do
                if d.Name == "Door" and d.Parent and d.Parent.Name == "TricksterDoor" then
                    AddESP(d, cfg)
                end
            end
        end

        -- цикл: нові двері
        fakeDoorConns = {}
        table.insert(fakeDoorConns, workspace.GameplayFolder.Rooms.DescendantAdded:Connect(function(d)
            if vals.ESP.FakeDoorESP and d.Name == "Door" and d.Parent and d.Parent.Name == "TricksterDoor" then
                AddESP(d, cfg)
            end
        end))
    else
        -- вимкнення
        for _, room in ipairs(workspace.GameplayFolder.Rooms:GetChildren()) do
            for _, d in ipairs(room:GetDescendants()) do
                if d.Name == "Door" and d.Parent and d.Parent.Name == "TricksterDoor" then
                    RemoveESP(d)
                end
            end
        end
        if fakeDoorConns then for _, c in ipairs(fakeDoorConns) do c:Disconnect() end end
        fakeDoorConns = {}
    end
end})

--Generator ESP
pageVisual:AddToggle({Caption = "Generator ESP", Default = false, Callback = function(b)
    vals.ESP.GeneratorESP = b
    generatorActive = b
    local trackedGenerators = {}

    local function getGeneratorCfg(fixedVal)
        local pct = tonumber(fixedVal) or 0
        if pct >= 100 then return nil end
        local r = math.floor(255 * (1 - pct/100))
        local g = math.floor(255 * (pct/100))
        return {
            label = "⚙ Generator " .. math.floor(pct) .. "%",
            fill = Color3.fromRGB(r,g,0),
            outline = Color3.fromRGB(255,200,0),
            textColor = Color3.new(1,1,1),
            fillTransparency = 0.3
        }
    end

    local function setupGenerator(gen)
        if not generatorActive then return end
        if trackedGenerators[gen] then return end
        trackedGenerators[gen] = true
        local fixed = gen:FindFirstChild("Fixed")
        if not fixed then return end
        local proxy = gen:FindFirstChild("ProxyPart") or gen
        local cfg = getGeneratorCfg(fixed.Value)
        if cfg then AddESP(proxy, cfg) end
        table.insert(generatorConns, fixed:GetPropertyChangedSignal("Value"):Connect(function()
            if not generatorActive then return end
            RemoveESP(proxy)
            local newCfg = getGeneratorCfg(fixed.Value)
            if newCfg then AddESP(proxy, newCfg) end
        end))
    end

    local function scanRoom(room)
        for _, d in ipairs(room:GetDescendants()) do
            if not generatorActive then break end
            if d.Name == "Generator" or d.Name == "PresetGenerator" then
                setupGenerator(d)
            elseif d.Name == "Fixed" and d.Parent then
                setupGenerator(d.Parent)
            end
        end
    end

    if b then
        generatorConns = {}
        for _, room in ipairs(workspace.GameplayFolder.Rooms:GetChildren()) do
            scanRoom(room)
            table.insert(generatorConns, room.DescendantAdded:Connect(function(d)
                if generatorActive and (d.Name == "Generator" or d.Name == "PresetGenerator" or d.Name == "Fixed") then
                    setupGenerator(d.Name == "Fixed" and d.Parent or d)
                end
            end))
        end
        table.insert(generatorConns, workspace.GameplayFolder.Rooms.ChildAdded:Connect(function(room)
            if generatorActive then scanRoom(room) end
            table.insert(generatorConns, room.DescendantAdded:Connect(function(d)
                if generatorActive and (d.Name == "Generator" or d.Name == "PresetGenerator" or d.Name == "Fixed") then
                    setupGenerator(d.Name == "Fixed" and d.Parent or d)
                end
            end))
        end))
    else
        if generatorConns then for _, c in ipairs(generatorConns) do c:Disconnect() end end
        generatorConns = {}
        trackedGenerators = {}
        for _, room in ipairs(workspace.GameplayFolder.Rooms:GetChildren()) do
            for _, d in ipairs(room:GetDescendants()) do
                if d.Name == "Generator" or d.Name == "PresetGenerator" then
                    RemoveESP(d:FindFirstChild("ProxyPart") or d)
                end
            end
        end
    end
end})

-- Monster Alert (оновлено з Monster.txt)
pageVisual:AddToggle({Caption = "Monster Alert", Default = false, Callback = function(b)
    vals.MonsterAlert = b
    if b then
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "MonsterSystemFinal"
        screenGui.IgnoreGuiInset = true
        screenGui.ResetOnSpawn = false
        screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

        local function notify(text, color)
            local note = Instance.new("TextLabel")
            note.Size = UDim2.new(0, 300, 0, 50)
            note.Position = UDim2.new(1, -310, 1, -60) -- низ справа
            note.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            note.TextColor3 = color
            note.Text = text
            note.TextSize = 25
            note.Font = Enum.Font.SourceSansBold
            note.Parent = screenGui
            Instance.new("UICorner", note)
            task.delay(2, function()
                game:GetService("TweenService"):Create(note, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
                task.wait(0.5)
                note:Destroy()
            end)
        end

        workspace.ChildAdded:Connect(function(child)
            task.wait(0.2)
            local name = child.Name:lower()
            if name:find("orb") or name:find("ambience") or name:find("light") or name:find("proxy") or name:find("vent") then return end
            if (child:IsA("Model") or child:IsA("BasePart")) and not game.Players:GetPlayerFromCharacter(child) then
                local inEntities = child.Parent.Name == "Entities" or child.Parent.Name == "Monsters"
                local hasSound = child:FindFirstChildOfClass("Sound", true)
                if (inEntities or hasSound) then
                    notify("⚠️ Monster: "..child.Name, Color3.fromRGB(255,0,0))
                    -- додаємо Highlight + Tracer + Sphere
                    local root = child:IsA("Model") and (child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")) or child
                    if root then
                        if not child:FindFirstChild("MonsterHighlight") then
                            local hl = Instance.new("Highlight", child)
                            hl.Name = "MonsterHighlight"
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                        if not child:FindFirstChild("MonsterSphere") then
                            local sphere = Instance.new("SelectionSphere")
                            sphere.Name = "MonsterSphere"
                            sphere.Adornee = root
                            sphere.Color3 = Color3.fromRGB(255,0,0)
                            sphere.Transparency = 0.6
                            sphere.Parent = child
                        end
                    end
                end
            end
        end)
    end
end})

-- Door ESP (Pressure2 logic)
pageVisual:AddToggle({Caption = "Door ESP", Default = false, Callback = function(b)
    vals.ESP.DoorESP = b
    local e = game:GetService("ReplicatedStorage").Events.CurrentRoomNumber

    local function addDoorESP(d)
        if d:FindFirstChild("ESP_Label") then return end -- вже є ESP
        local door = d:FindFirstChild("Door") or d
        local locked = d:FindFirstChild("Lock", math.huge)
        local cr = e:InvokeServer()
        AddESP(door, {
            label = "Room " .. (cr + 1) .. (locked and "\n[ Locked ]" or ""),
            fill = locked and Color3.fromRGB(100,175,255) or Color3.fromRGB(0,255,100),
            outline = Color3.new(1,1,1)
        })
    end

    if b then
        -- первинне сканування тільки поточних кімнат
        for _, room in ipairs(workspace.GameplayFolder.Rooms:GetChildren()) do
            for _, d in ipairs(room:GetDescendants()) do
                if d:IsA("Model") and d.Parent and d.Parent.Name == "Entrances" then
                    addDoorESP(d)
                end
            end
        end

        -- слухаємо нові кімнати та двері
        doorConns = {}
        table.insert(doorConns, workspace.GameplayFolder.Rooms.ChildAdded:Connect(function(room)
            for _, d in ipairs(room:GetDescendants()) do
                if d:IsA("Model") and d.Parent and d.Parent.Name == "Entrances" then
                    addDoorESP(d)
                end
            end
            table.insert(doorConns, room.DescendantAdded:Connect(function(d)
                if vals.ESP.DoorESP and d:IsA("Model") and d.Parent and d.Parent.Name == "Entrances" then
                    addDoorESP(d)
                end
            end))
        end))
    else
        -- вимкнення: прибираємо ESP
        for _, room in ipairs(workspace.GameplayFolder.Rooms:GetChildren()) do
            for _, d in ipairs(room:GetDescendants()) do
                if d:IsA("Model") and d.Parent and d.Parent.Name == "Entrances" then
                    local door = d:FindFirstChild("Door") or d
                    RemoveESP(door)
                end
            end
        end
        if doorConns then for _, c in ipairs(doorConns) do c:Disconnect() end end
        doorConns = {}
    end
end})

-- World
local pageWorld = window:AddPage({Title = "World"})
pageWorld:AddToggle({Caption = "Fullbright", Default = false, Callback = function(b)
    if b then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").Ambient = Color3.new(1,1,1)
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").Ambient = Color3.new(0.5,0.5,0.5)
    end
end})


-- ================================
-- ВКЛАДКА BYPASS
-- ================================

local pageBypass = window:AddPage({Title = "Bypasses"})

-- Універсальний хелпер для видалення сутностей
local function setupRemoval(nameTable, valKey, connsVar)
    if vals[valKey] then
        -- первинне очищення
        for _, child in ipairs(workspace:GetDescendants()) do
            if nameTable[child.Name] then pcall(function() child:Destroy() end) end
        end

        -- функція перевірки
        local function checkChild(child)
            if vals[valKey] and nameTable[child.Name] then
                pcall(function() child:Destroy() end)
            end
        end

        -- коннекти
        _G[connsVar] = {}
        table.insert(_G[connsVar], workspace.DescendantAdded:Connect(checkChild))
        table.insert(_G[connsVar], workspace.ChildAdded:Connect(checkChild))
        table.insert(_G[connsVar], workspace.GameplayFolder.Monsters.DescendantAdded:Connect(checkChild))
        table.insert(_G[connsVar], workspace.GameplayFolder.Monsters.ChildAdded:Connect(checkChild))
        table.insert(_G[connsVar], workspace.GameplayFolder.Rooms.DescendantAdded:Connect(checkChild))
        table.insert(_G[connsVar], workspace.GameplayFolder.Rooms.ChildAdded:Connect(checkChild))

        -- періодична перевірка
        task.spawn(function()
            while vals[valKey] do
                for _, child in ipairs(workspace:GetDescendants()) do
                    checkChild(child)
                end
                task.wait(1)
            end
        end)
    else
        if _G[connsVar] then
            for _, c in ipairs(_G[connsVar]) do c:Disconnect() end
        end
        _G[connsVar] = {}
    end
end

-- Anti Eyefestation
pageBypass:AddToggle({Caption = "Anti Eyefestation", Default = false, Callback = function(b)
    vals.AntiEyefestation = b
    local EF = { Eyefestation=true, EngragedEyeInfestation=true }
    setupRemoval(EF, "AntiEyefestation", "eyefestationConns")
end})

-- Remove Pandemonium
pageBypass:AddToggle({Caption = "Remove Pandemonium", Default = false, Callback = function(b)
    vals.RemovePandemonium = b
    setupRemoval(PANDEMONIUM_NAMES, "RemovePandemonium", "pandemoniumConns")
end})

-- Remove WallDweller
pageBypass:AddToggle({Caption = "Remove WallDweller", Default = false, Callback = function(b)
    vals.RemoveWallDweller = b
    local WD = { WallDweller=true, MeatWallDweller=true, RottenWallDweller=true, WallDwellers=true }
    setupRemoval(WD, "RemoveWallDweller", "wallDwellerConns")
end})

-- Remove Bouncer
pageBypass:AddToggle({Caption = "Remove Bouncer", Default = false, Callback = function(b)
    vals.RemoveBouncer = b
    local B = { Bouncer=true }
    setupRemoval(B, "RemoveBouncer", "bouncerConns")
end})

-- Remove Skeleton Head
pageBypass:AddToggle({Caption = "Remove Skeleton Head", Default = false, Callback = function(b)
    vals.RemoveSkeletonHead = b
    local S = { SkeletonHead=true }
    setupRemoval(S, "RemoveSkeletonHead", "skeletonConns")
end})

-- Remove Statue
pageBypass:AddToggle({Caption = "Remove Statue", Default = false, Callback = function(b)
    vals.RemoveStatue = b
    local ST = { StatueRoot=true }
    setupRemoval(ST, "RemoveStatue", "statueConns")
end})

-- Remove DiVine
pageBypass:AddToggle({Caption = "Remove DiVine", Default = false, Callback = function(b)
    vals.RemoveDiVine = b
    local DV = { DiVine=true, DiVineRoot=true }
    setupRemoval(DV, "RemoveDiVine", "divineConns")
end})

-- Remove Searchlights
pageBypass:AddToggle({Caption = "Remove Searchlights", Default = false, Callback = function(b)
    vals.RemoveSearchlights = b
    local SL = { Searchlights=true }
    setupRemoval(SL, "RemoveSearchlights", "searchlightConns")
end})

-- Remove Monster Locker
pageBypass:AddToggle({Caption = "Remove Monster Locker", Default = false, Callback = function(b)
    vals.RemoveMonsterLocker = b
    local ML = { MonsterLocker=true }
    setupRemoval(ML, "RemoveMonsterLocker", "lockerConns")
end})

pageBypass:AddSeparator()
pageBypass:AddLabel({Caption = "Spawns"})

-- Remove Turrets
pageBypass:AddToggle({Caption = "Remove Turrets", Default = false, Callback = function(b)
    vals.RemoveTurrets = b
    local TR = { Turret=true, TurretSpawn=true }
    setupRemoval(TR, "RemoveTurrets", "turretConns")
end})

-- Remove Tripwires
pageBypass:AddToggle({Caption = "Remove Tripwires", Default = false, Callback = function(b)
    vals.RemoveTripwires = b
    local TW = { Tripwire=true, TripwireSpawn=true }
    setupRemoval(TW, "RemoveTripwires", "tripwireConns")
end})

-- Remove Landmines
pageBypass:AddToggle({Caption = "Remove Landmines", Default = false, Callback = function(b)
    vals.RemoveLandmines = b
    local LM = { Landmine=true, LandmineSpawn=true }
    setupRemoval(LM, "RemoveLandmines", "landmineConns")
end})

pageBypass:AddSeparator()
pageBypass:AddLabel({Caption = "Encounters"})

-- Remove Firewall
pageBypass:AddToggle({Caption = "Remove Firewall", Default = false, Callback = function(b)
    vals.RemoveFirewall = b
    local FW = { Firewall=true }
    setupRemoval(FW, "RemoveFirewall", "firewallConns")
end})


-- ================================
-- ВКЛАДКА MOVEMENT (з Pressure1)
-- ================================

local pageMove = window:AddPage({Title = "Movement"})

-- Noclip toggle
pageMove:AddToggle({Caption = "Noclip", Default = false, Callback = function(b)
    if b then
        vals.NoclipActive = true
        vals.NoclipLoop = game:GetService("RunService").Stepped:Connect(function()
            local char = game.Players.LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        vals.NoclipActive = false
        if vals.NoclipLoop then vals.NoclipLoop:Disconnect() end
    end
end})

-- Speed Hack toggle
pageMove:AddToggle({Caption = "Speed Hack", Default = false, Callback = function(b)
    vals.SpeedHack = b
    getgenv().SpeedEnabled = b
end})

-- Speed Value slider
pageMove:AddSlider({
    Caption = "Speed Value",
    Default = 16,
    Min = 16,
    Max = 300,
    Step = 1,
    Callback = function(val)
        getgenv().SpeedValue = val
    end
})

-- Цикл для застосування Speed Hack
game:GetService("RunService").Stepped:Connect(function()
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if getgenv().SpeedEnabled and hum and root then
        hum.WalkSpeed = getgenv().SpeedValue
        if hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * (getgenv().SpeedValue / 110))
        end
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end
end)

-- JumpPower slider
pageMove:AddSlider({
    Caption = "JumpPower",
    Default = 50,
    Min = 50,
    Max = 200,
    Step = 5,
    Callback = function(val)
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = val
            end
        end
    end
})

-- ================================
-- ВКЛАДКА INTERACT (з Pressure2)
-- ================================

local pageInteract = window:AddPage({Title = "Interact"})

-- Auto loot currency
pageInteract:AddToggle({Caption = "Auto loot currency", Default = false, Callback = function(b)
    vals.AutoGrabCurrency = b
end})

pageInteract:AddSeparator()

-- Instant interact
pageInteract:AddToggle({Caption = "Instant proximity prompt interact", Default = false, Callback = function(b)
    vals.InstantInteract = b
end})

-- Notify monsters
pageInteract:AddToggle({Caption = "Notify monsters", Default = false, Callback = function(b)
    vals.NotifyMonsters = b
end})

-- Extra prompt range
pageInteract:AddSlider({
    Caption = "Extra proximity prompt activation range",
    Default = 0,
    Min = 0,
    Max = 100,
    Step = 0.25,
    Callback = function(b)
        vals.ExtraPrompt = b
    end,
    CustomTextDisplay = function(x)
        return "+ " .. math.floor(x) .. "%"
    end
})

pageInteract:AddSeparator()

-- Better doors
pageInteract:AddToggle({Caption = "Open doors no matter what your camera rotation is", Default = false, Callback = function(b)
    vals.BetterDoors = b
end})

-- Auto input code
pageInteract:AddToggle({Caption = "Auto input door code (uses bruteforcing)", Default = false, Callback = function(b)
    vals.AutoInputCode = b
end})

-- Teleport to door lock
pageInteract:AddToggle({Caption = "Teleport to enter code", Default = false, Callback = function(b)
    vals.TeleportToDoorLock = b
end})

-- Button for bruteforce
pageInteract:AddButton({Caption = "Bruteforce closest door codelock", Callback = function()
    for _, door in doorCodes do
        if door and door.Parent and (door.Parent.Position - game.Players.LocalPlayer.Character:GetPivot().Position).Magnitude < 9.5 then
            bruteforce(door, true)
        end
    end
end})

-- ================================
-- ЛОГІКА АВТОЛУТУ (RenderStepped)
-- ================================

cons[#cons + 1] = rs.RenderStepped:Connect(function(dt)
    -- Better doors
    if vals.BetterDoors then
        for idx, doorPrompt in doors do
            if doorPrompt and doorPrompt.Parent then
                fireproximityprompt(doorPrompt, false)
            else
                table.remove(doors, idx)
                break
            end
        end
    end

    -- Auto loot currency
    if vals.AutoGrabCurrency then
        for i, v in money do
            if not v or not v.Parent then
                table.remove(money, i)
                break
            else
                fireproximityprompt(v, false)
            end
        end
    end
end)

-- ================================
-- ЗАВЕРШЕННЯ СКРИПТА
-- ================================

-- Коли вікно закривається, повертаємо дефолтні значення
window.CloseCallback = function()
    for i, v in defaults.ESP do
        espLib.ESPValues[i] = v
    end
    for i, v in defaults do
        vals[i] = v
    end
    getGlobalTable().FireHubLoaded = false
end

-- ================================
-- КІНЕЦЬ ОБ'ЄДНАНОГО СКРИПТА
-- ================================
