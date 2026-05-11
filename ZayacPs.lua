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

-- ========== GLOBALS FOR INTERACT ==========
local rs = game:GetService("RunService")
local plr = game:GetService("Players").LocalPlayer

local cons = {}                -- зберігаємо коннекшени
local doors = {}               -- промпти дверей
local money = {}               -- промпти валюти (ProximityPrompt)
local monsters = {}            -- трекінг монстрів
local doorCodes = {}           -- RemoteFunction door codes
local lockers = {}             -- шафки
local searchlights = {}        -- searchlight remoteevents
local originalDistances = {}   -- збережені MaxActivationDistance

-- ======= SIMPLE, RELIABLE INTERACT SYSTEM =======
-- Вставити після оголошення fireproximityprompt і глобалів (rs, plr, cons, doors, money, monsters)

-- Універсальна функція, що обробляє нові об'єкти
local function handleDescendant(obj)
    if not obj or not obj.Parent then return end

    -- Промпти
    if obj:IsA("ProximityPrompt") then
        -- зберігаємо оригінальну дистанцію
        originalDistances[obj] = obj.MaxActivationDistance
        obj.MaxActivationDistance = obj.MaxActivationDistance * ((vals.ExtraPrompt or 0) / 100 + 1)

        -- якщо дверний промпт (Root -> Model)
        if obj.Parent.Name == "Root" and obj.Parent.Parent and obj.Parent.Parent:IsA("Model") then
            table.insert(doors, obj)
            return
        end

        -- шукаємо Amount по всіх батьках (універсально)
        local parent = obj.Parent
        local foundAmount = nil
        while parent do
            if parent.GetAttribute then
                local a = parent:GetAttribute("Amount")
                if a ~= nil then
                    foundAmount = a
                    break
                end
            end
            parent = parent.Parent
        end

        if foundAmount ~= nil then
            table.insert(money, obj)
            -- тимчасовий лог для діагностики (видалити після тесту)
            print("[INTERACT] Currency prompt added:", obj:GetFullName(), "Amount=", foundAmount)
        else
            -- предмет/інший промпт — робимо ESP як у скрипті
            local espTarget = obj.Parent
            if espTarget and espTarget.Parent and espTarget.Parent:IsA("Model") then
                espTarget = espTarget.Parent
            end
            pcall(esp, espTarget, {HighlightEnabled = false, Color = getColor(espTarget), Text = getText(espTarget), ESPName = "ItemESP"})
        end

        return
    end

    -- Звуки на частинах — монстри
    if obj:IsA("Sound") and obj.Parent and obj.Parent:IsA("BasePart") then
        local name = obj.Parent.Name:lower()
        if not (name:find("ambience") or name:find("orb") or name:find("vent") or name:find("proxy")) then
            if obj.Parent.Parent == workspace or obj.Parent.Parent == workspace.GameplayFolder.Monsters then
                onMonster(obj.Parent)
            end
        end
        return
    end

    -- Моделі: двері, монстри
    if obj:IsA("Model") then
        if obj.Parent and obj.Parent.Name == "Entrances" then
            esp(obj:WaitForChild("Door", 2.5) or obj, { HighlightEnabled = true, Color = obj:FindFirstChild("Lock", math.huge) and Color3.fromRGB(100, 175, 255) or Color3.fromRGB(0, 255, 100), Text = "Room " .. ( (game:GetService("ReplicatedStorage").Events.CurrentRoomNumber:InvokeServer() or 0) + 1 ) .. (obj:FindFirstChild("Lock", math.huge) and "\n[ Locked ]" or ""), ESPName = "DoorESP" })
        elseif obj.Parent == workspace.GameplayFolder.Monsters or obj.Name == "Eyefestation" then
            onMonster(obj)
        end
        return
    end

    -- RemoteEvent searchlights
    if obj:IsA("RemoteEvent") and obj.Parent and obj.Parent:IsA("Part") and obj.Name == "RemoteEvent" and obj.Parent.Name:lower():match("searchlight") then
        task.spawn(blockInstance, obj, "AntiSearchlights")
        table.insert(searchlights, obj)
        return
    end

    -- RemoteFunction door codes / lockers
    if obj:IsA("RemoteFunction") then
        if obj.Parent and obj.Parent.Name == "Main" and obj.Name == "RemoteFunction" and obj.Parent.Parent and obj.Parent.Parent:FindFirstChild("Keypad0") then
            table.insert(doorCodes, obj)
        end
        if obj.Name == "Enter" and obj.Parent and obj.Parent:IsA("Folder") and obj.Parent.Parent and obj.Parent.Parent.Name == "Locker" then
            table.insert(lockers, obj.Parent.Parent)
        end
    end
end

-- Первинне сканування
for _, v in ipairs(workspace:GetDescendants()) do
    task.spawn(handleDescendant, v)
end

-- Слухаємо нові об'єкти
cons[#cons + 1] = workspace.DescendantAdded:Connect(function(obj)
    -- невелика затримка, щоб об'єкт встиг ініціалізуватись
    task.wait(0.05)
    pcall(handleDescendant, obj)
end)

-- InstantInteract (PromptButtonHoldBegan)
cons[#cons + 1] = game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
    if vals.InstantInteract then
        pcall(function()
            prompt:InputHoldEnd()
            task.wait()
            fireproximityprompt(prompt)
        end)
    end
end)

-- Надійний RenderStepped (ітеруємо з кінця до початку)
cons[#cons + 1] = rs.RenderStepped:Connect(function(dt)
    -- BetterDoors
    if vals.BetterDoors then
        for i = #doors, 1, -1 do
            local doorPrompt = doors[i]
            if doorPrompt and doorPrompt.Parent then
                pcall(fireproximityprompt, doorPrompt, false)
            else
                table.remove(doors, i)
            end
        end
    end

    -- AutoGrabCurrency
    if vals.AutoGrabCurrency then
        for i = #money, 1, -1 do
            local prompt = money[i]
            if prompt and prompt.Parent then
                pcall(fireproximityprompt, prompt, false)
            else
                table.remove(money, i)
            end
        end
    end

    -- Очищення монстрів
    for i = #monsters, 1, -1 do
        local m = monsters[i]
        if not m or not m.Parent then
            table.remove(monsters, i)
        end
    end
end)
-- ======= END INTERACT SYSTEM =======

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

-- ================================
-- СПИСКИ МОНСТРІВ (з Pressure1)
-- ================================

local KEYCARDS = {
    NormalKeyCard = { label = "Ключ Карта",       fill = Color3.fromRGB(255, 50,  50),  outline = Color3.fromRGB(255, 150, 150) },
    InnerKeyCard  = { label = "Иннер Карта", fill = Color3.fromRGB(0,   120, 255), outline = Color3.fromRGB(100, 180, 255) },
    RidgeKeyCard  = { label = "Хэбэт Карта", fill = Color3.fromRGB(255, 150, 0),   outline = Color3.fromRGB(255, 200, 100) },
    PasswordPaper = { label = "Пароль",      fill = Color3.fromRGB(0,   200, 80),  outline = Color3.fromRGB(100, 255, 150) },
}

local ITEM_PATTERNS = {
    { pattern = "Lantern",      label = "Фонарь",       fill = Color3.fromRGB(255, 200, 0),   outline = Color3.fromRGB(255, 230, 100) },
    { pattern = "Flashlight",   label = "Фонарик",    fill = Color3.fromRGB(200, 200, 255), outline = Color3.fromRGB(255, 255, 255) },
    { pattern = "Blacklight",   label = "Фонарик против степашек",    fill = Color3.fromRGB(150, 0,   255), outline = Color3.fromRGB(200, 100, 255) },
    { pattern = "Medkit",       label = "Медкит",        fill = Color3.fromRGB(255, 50,  50),  outline = Color3.fromRGB(255, 150, 150) },
    { pattern = "HealthBoost",  label = "Хилка",  fill = Color3.fromRGB(255, 100, 100), outline = Color3.fromRGB(255, 180, 180) },
    { pattern = "Defib",        label = "Дефибрилятор",         fill = Color3.fromRGB(255, 0,   100), outline = Color3.fromRGB(255, 100, 180) },
    { pattern = "FlashBeacon",  label = "Флеш Маяк",  fill = Color3.fromRGB(255, 255, 50),  outline = Color3.fromRGB(255, 255, 150) },
    { pattern = "Scanner",      label = "Сканер",       fill = Color3.fromRGB(0,   255, 200), outline = Color3.fromRGB(100, 255, 230) },
    { pattern = "^Book$",       label = "Книга",          fill = Color3.fromRGB(180, 120, 40),  outline = Color3.fromRGB(220, 170, 100) },
    { pattern = "CodeBreacher", label = "Взлом Замка", fill = Color3.fromRGB(0,   200, 255), outline = Color3.fromRGB(100, 230, 255) },
    { pattern = "Gummylight",   label = "Зеленый фонарь",    fill = Color3.fromRGB(255, 100, 200), outline = Color3.fromRGB(255, 180, 230) },
    { pattern = "WindupLight",  label = "Синий Фонарик",  fill = Color3.fromRGB(255, 180, 50),  outline = Color3.fromRGB(255, 210, 120) },
    { pattern = "SPRINT",       label = "Спринт",        fill = Color3.fromRGB(50,  255, 100), outline = Color3.fromRGB(150, 255, 180) },
    { pattern = "ToyRemote",    label = "Шиза",    fill = Color3.fromRGB(100, 100, 255), outline = Color3.fromRGB(180, 180, 255) },
    { pattern = "Battery",      label = "Батарейка",       fill = Color3.fromRGB(255, 230, 0),   outline = Color3.fromRGB(255, 245, 100) },
    { pattern = "[Nn]eostyk",   label = "НеоСтик",       fill = Color3.fromRGB(0,   255, 150), outline = Color3.fromRGB(100, 255, 200) },
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
    { pattern="^Blueprint$",     label="Чертежь(75$)",          fill=Color3.fromRGB(0,180,255),   outline=Color3.fromRGB(100,220,255) },
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

local pageVisual = window:AddPage({Title = "Визуал/ЕСП"})

-- Items
pageVisual:AddLabel({Caption = "Лут"})

-- Keycard ESP
pageVisual:AddToggle({Caption = "Есп Карт и паролей", Default = false, Callback = function(b)
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
pageVisual:AddToggle({Caption = "Деньги ЕСП", Default = false, Callback = function(b)
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
pageVisual:AddToggle({Caption = "Вещи ЕСП", Default = false, Callback = function(b)
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
pageVisual:AddToggle({Caption = "Монстры ЕСП", Default = false, Callback = function(b)
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
pageVisual:AddToggle({Caption = "ЕСП фейк шкафов", Default = false, Callback = function(b)
    vals.ESP.MonsterLockerESP = b
    local cfg = {
        label = "⚠ ФЕЙК ШКАФ",
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
pageVisual:AddToggle({Caption = "Фейк двери ЕСП", Default = false, Callback = function(b)
    vals.ESP.FakeDoorESP = b
    local cfg = {
        label = "✖ ФЕЙК ДВЕРЬ",
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
pageVisual:AddToggle({Caption = "Генераторы ЕСП", Default = false, Callback = function(b)
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
pageVisual:AddToggle({Caption = "Оповещение о монстрах", Default = false, Callback = function(b)
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
pageVisual:AddToggle({Caption = "Двери ЕСП", Default = false, Callback = function(b)
    vals.ESP.DoorESP = b
    local e = game:GetService("ReplicatedStorage").Events.CurrentRoomNumber

    local function addDoorESP(d)
        if d:FindFirstChild("ESP_Label") then return end
        local door = d:FindFirstChild("Door") or d
        local locked = d:FindFirstChild("Lock", true)
        local cr = e:InvokeServer()
        AddESP(door, {
            label = "Room " .. (cr + 1) .. (locked and "\n[ Locked ]" or ""),
            fill = locked and Color3.fromRGB(100,175,255) or Color3.fromRGB(0,255,100),
            outline = Color3.new(1,1,1),
            size = 10 -- Встанови бажаний розмір тут
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
local pageWorld = window:AddPage({Title = "Мир/освещение"})
pageWorld:AddToggle({Caption = "Фулл брайт", Default = false, Callback = function(b)
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

local pageBypass = window:AddPage({Title = "Анти"})

-- ===== Bypass throttling core =====
local bypassQueue = {}
local bypassConns = {}
local BYPASS_BATCH_SIZE = 12
local BYPASS_BATCH_INTERVAL = 0.12 -- обробка ~8 разів/сек
local BYPASS_ROOM_WAIT = 0.06 -- пауза між кімнатами при первинному скануванні
local bypassDebounce = {}

local function enqueueForBypass(obj)
    if not obj or not obj.Parent then return end
    bypassQueue[#bypassQueue + 1] = obj
end

local function processBypassQueueStep()
    local removed = 0
    for i = #bypassQueue, 1, -1 do
        if removed >= BYPASS_BATCH_SIZE then break end
        local obj = bypassQueue[i]
        if obj and obj.Parent then
            pcall(function() obj:Destroy() end)
        end
        table.remove(bypassQueue, i)
        removed = removed + 1
    end
end

-- Heartbeat processor (додаємо в cons)
do
    local tickAccum = 0
    cons[#cons + 1] = rs.Heartbeat:Connect(function(dt)
        tickAccum = tickAccum + dt
        if tickAccum >= BYPASS_BATCH_INTERVAL then
            tickAccum = 0
            if #bypassQueue > 0 then
                processBypassQueueStep()
            end
        end
    end)
end

-- Throttled room scanner: додає підходящі об'єкти в чергу
local function scanRoomsThrottled(matchFn)
    task.spawn(function()
        for _, room in ipairs(workspace.GameplayFolder.Rooms:GetChildren()) do
            for _, d in ipairs(room:GetDescendants()) do
                if matchFn(d) then
                    enqueueForBypass(d)
                end
            end
            task.wait(BYPASS_ROOM_WAIT)
        end
    end)
end

-- Новий setupRemoval: не видаляє миттєво, а ставить в чергу і підписується
local function setupRemoval(nameTable, valKey, connsVar)
    -- debounce key для кожного valKey
    if bypassDebounce[valKey] then return end
    bypassDebounce[valKey] = true

    if vals[valKey] then
        -- первинне сканування по кімнатах (throttled)
        scanRoomsThrottled(function(d)
            return nameTable[d.Name] == true
        end)

        -- підписки: додаємо в чергу при появі нових об'єктів
        _G[connsVar] = _G[connsVar] or {}
        local function onDesc(d)
            if not vals[valKey] then return end
            if nameTable[d.Name] then
                enqueueForBypass(d)
            end
        end

        table.insert(_G[connsVar], workspace.GameplayFolder.Rooms.DescendantAdded:Connect(onDesc))
        table.insert(_G[connsVar], workspace.GameplayFolder.Rooms.ChildAdded:Connect(function(room)
            task.wait(0.05)
            if not vals[valKey] then return end
            -- скануємо нову кімнату швидко
            for _, d in ipairs(room:GetDescendants()) do
                if nameTable[d.Name] then enqueueForBypass(d) end
            end
            -- підписуємося на майбутні десценданти
            table.insert(_G[connsVar], room.DescendantAdded:Connect(onDesc))
        end))

        -- додаткові контейнерні підписки (Monsters, workspace)
        table.insert(_G[connsVar], workspace.DescendantAdded:Connect(onDesc))
        table.insert(_G[connsVar], workspace.ChildAdded:Connect(onDesc))
        table.insert(_G[connsVar], workspace.GameplayFolder.Monsters.DescendantAdded:Connect(onDesc))
        table.insert(_G[connsVar], workspace.GameplayFolder.Monsters.ChildAdded:Connect(onDesc))

        -- завершення debounce через короткий час
        task.delay(0.2, function() bypassDebounce[valKey] = nil end)
    else
        -- вимкнення: відключаємо всі коннекшени, черга буде поступово оброблена
        if _G[connsVar] then
            for _, c in ipairs(_G[connsVar]) do
                pcall(function() c:Disconnect() end)
            end
        end
        _G[connsVar] = {}
        bypassDebounce[valKey] = nil
    end
end

-- Anti Eyefestation
pageBypass:AddToggle({Caption = "Анти акула", Default = false, Callback = function(b)
    vals.AntiEyefestation = b
    local EF = { Eyefestation=true, EngragedEyeInfestation=true }
    setupRemoval(EF, "AntiEyefestation", "eyefestationConns")
end})

-- Remove Pandemonium
pageBypass:AddToggle({Caption = "Анти ПАНДЕМОНИУМ!!!!!", Default = false, Callback = function(b)
    vals.RemovePandemonium = b
    setupRemoval(PANDEMONIUM_NAMES, "RemovePandemonium", "pandemoniumConns")
end})

-- Remove WallDweller
pageBypass:AddToggle({Caption = "Убрать Стену", Default = false, Callback = function(b)
    vals.RemoveWallDweller = b
    local WD = { WallDweller=true, MeatWallDweller=true, RottenWallDweller=true, WallDwellers=true }
    setupRemoval(WD, "RemoveWallDweller", "wallDwellerConns")
end})

-- Remove Bouncer
pageBypass:AddToggle({Caption = "Убрать вышибалу", Default = false, Callback = function(b)
    vals.RemoveBouncer = b
    local B = { Bouncer=true }
    setupRemoval(B, "RemoveBouncer", "bouncerConns")
end})

-- Remove Skeleton Head
pageBypass:AddToggle({Caption = "Убрать башку скелета", Default = false, Callback = function(b)
    vals.RemoveSkeletonHead = b
    local S = { SkeletonHead=true }
    setupRemoval(S, "RemoveSkeletonHead", "skeletonConns")
end})

-- Remove Statue
pageBypass:AddToggle({Caption = "Убрать статую(бесконечный режим)", Default = false, Callback = function(b)
    vals.RemoveStatue = b
    local ST = { StatueRoot=true }
    setupRemoval(ST, "RemoveStatue", "statueConns")
end})

-- Remove DiVine
pageBypass:AddToggle({Caption = "Убрать Растения(нельзя ходить по траве)", Default = false, Callback = function(b)
    vals.RemoveDiVine = b
    local DV = { DiVine=true, DiVineRoot=true }
    setupRemoval(DV, "RemoveDiVine", "divineConns")
end})

-- Remove Searchlights
pageBypass:AddToggle({Caption = "Убрать Прожектора", Default = false, Callback = function(b)
    vals.RemoveSearchlights = b
    local SL = { Searchlights=true }
    setupRemoval(SL, "RemoveSearchlights", "searchlightConns")
end})

-- Remove Monster Locker
pageBypass:AddToggle({Caption = "Убрать Фейк Шкафы", Default = false, Callback = function(b)
    vals.RemoveMonsterLocker = b
    local ML = { MonsterLocker=true }
    setupRemoval(ML, "RemoveMonsterLocker", "lockerConns")
end})

pageBypass:AddSeparator()
pageBypass:AddLabel({Caption = "Предметы"})

-- Remove Turrets
pageBypass:AddToggle({Caption = "Убрать Турели", Default = false, Callback = function(b)
    vals.RemoveTurrets = b
    local TR = { Turret=true, TurretSpawn=true }
    setupRemoval(TR, "RemoveTurrets", "turretConns")
end})

-- Remove Tripwires
pageBypass:AddToggle({Caption = "Убрать Мины на дверях", Default = false, Callback = function(b)
    vals.RemoveTripwires = b
    local TW = { Tripwire=true, TripwireSpawn=true }
    setupRemoval(TW, "RemoveTripwires", "tripwireConns")
end})

-- Remove Landmines
pageBypass:AddToggle({Caption = "Убрать Лежачии Мины", Default = false, Callback = function(b)
    vals.RemoveLandmines = b
    local LM = { Landmine=true, LandmineSpawn=true }
    setupRemoval(LM, "RemoveLandmines", "landmineConns")
end})

pageBypass:AddSeparator()
pageBypass:AddLabel({Caption = "Паркур"})

-- Remove Firewall
pageBypass:AddToggle({Caption = "Убрать Огненую Стену", Default = false, Callback = function(b)
    vals.RemoveFirewall = b
    local FW = { Firewall=true }
    setupRemoval(FW, "RemoveFirewall", "firewallConns")
end})


-- ================================
-- ВКЛАДКА MOVEMENT (з Pressure1)
-- ================================

local pageMove = window:AddPage({Title = "Движение"})

-- Noclip toggle
pageMove:AddToggle({Caption = "Ноуклип(проходка сквозь стени)", Default = false, Callback = function(b)
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
pageMove:AddToggle({Caption = "Спиды", Default = false, Callback = function(b)
    vals.SpeedHack = b
    getgenv().SpeedEnabled = b
end})

-- Speed Value slider
pageMove:AddSlider({
    Caption = "Значение Скорости",
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
    Caption = "Высота прыжка",
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

local pageInteract = window:AddPage({Title = "Взаимодействие"})

-- Auto loot currency
pageInteract:AddToggle({Caption = "Авто лут деняг", Default = false, Callback = function(b)
    vals.AutoGrabCurrency = b
end})

pageInteract:AddSeparator()

-- Instant interact
pageInteract:AddToggle({Caption = "Взаемодействие на дистанции(50/50)", Default = false, Callback = function(b)
    vals.InstantInteract = b
end})

-- Notify monsters
pageInteract:AddToggle({Caption = "Оповещение о монстрах", Default = false, Callback = function(b)
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
pageInteract:AddToggle({Caption = "Лучшее откритие дверей( нету разницы как повернута камера)", Default = false, Callback = function(b)
    vals.BetterDoors = b
end})

-- Auto input code
pageInteract:AddToggle({Caption = "авто ввод кода(не работает)", Default = false, Callback = function(b)
    vals.AutoInputCode = b
end})

-- Teleport to door lock
pageInteract:AddToggle({Caption = "Телепорт к вводу кода(баганое)", Default = false, Callback = function(b)
    vals.TeleportToDoorLock = b
end})

-- Button for bruteforce
pageInteract:AddButton({Caption = "Авто дверной замок", Callback = function()
    for _, door in doorCodes do
        if door and door.Parent and (door.Parent.Position - game.Players.LocalPlayer.Character:GetPivot().Position).Magnitude < 9.5 then
            bruteforce(door, true)
        end
    end
end})

-- ================================
-- ЛОГІКА АВТОЛУТУ (RenderStepped)
-- ================================

-- Автолут і BetterDoors з batch-обробкою
local batchSize = 20   -- скільки промптів обробляти за цикл
local tickAccum = 0

cons[#cons + 1] = rs.Heartbeat:Connect(function(dt)
    tickAccum = tickAccum + dt
    if tickAccum < 0.12 then return end -- ~8 разів/сек
    tickAccum = 0

    -- AutoGrabCurrency
    if vals.AutoGrabCurrency then
        local count = #money
        if count > 0 then
            for i = count, math.max(count - batchSize + 1, 1), -1 do
                local prompt = money[i]
                if prompt and prompt.Parent then
                    pcall(fireproximityprompt, prompt, false)
                else
                    table.remove(money, i)
                end
            end
        end
    end

    -- BetterDoors
    if vals.BetterDoors then
        local count = #doors
        if count > 0 then
            for i = count, math.max(count - batchSize + 1, 1), -1 do
                local doorPrompt = doors[i]
                if doorPrompt and doorPrompt.Parent then
                    pcall(fireproximityprompt, doorPrompt, false)
                else
                    table.remove(doors, i)
                end
            end
        end
    end

     -- Очищення монстрів
    for i = #monsters, 1, -1 do
        local m = monsters[i]
        if not m or not m.Parent then
            table.remove(monsters, i)
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
