local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "ZayacHub",
    Icon = 0,
    LoadingTitle = "Pressure|Script",
    LoadingSubtitle = "by Zayac",
    Theme = {
        TextColor = Color3.fromRGB(200, 225, 255),
        Background = Color3.fromRGB(10, 18, 35),
        Topbar = Color3.fromRGB(15, 25, 50),
        Shadow = Color3.fromRGB(5, 10, 20),
        NotificationBackground = Color3.fromRGB(12, 22, 45),
        NotificationActionsBackground = Color3.fromRGB(30, 60, 120),
        TabBackground = Color3.fromRGB(20, 35, 70),
        TabStroke = Color3.fromRGB(30, 55, 110),
        TabBackgroundSelected = Color3.fromRGB(40, 90, 180),
        TabTextColor = Color3.fromRGB(150, 190, 255),
        SelectedTabTextColor = Color3.fromRGB(220, 235, 255),
        ElementBackground = Color3.fromRGB(15, 28, 58),
        ElementBackgroundHover = Color3.fromRGB(20, 38, 78),
        SecondaryElementBackground = Color3.fromRGB(10, 18, 40),
        ElementStroke = Color3.fromRGB(35, 65, 130),
        SecondaryElementStroke = Color3.fromRGB(25, 48, 100),
        SliderBackground = Color3.fromRGB(30, 80, 170),
        SliderProgress = Color3.fromRGB(50, 120, 220),
        SliderStroke = Color3.fromRGB(70, 150, 255),
        ToggleBackground = Color3.fromRGB(15, 28, 58),
        ToggleEnabled = Color3.fromRGB(40, 110, 220),
        ToggleDisabled = Color3.fromRGB(40, 55, 90),
        ToggleEnabledStroke = Color3.fromRGB(60, 140, 255),
        ToggleDisabledStroke = Color3.fromRGB(50, 70, 120),
        ToggleEnabledOuterStroke = Color3.fromRGB(35, 90, 180),
        ToggleDisabledOuterStroke = Color3.fromRGB(25, 40, 80),
        DropdownSelected = Color3.fromRGB(20, 40, 85),
        DropdownUnselected = Color3.fromRGB(15, 28, 58),
        InputBackground = Color3.fromRGB(15, 28, 58),
        InputStroke = Color3.fromRGB(40, 75, 150),
        PlaceholderColor = Color3.fromRGB(100, 140, 200),
    },
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = { Enabled = true, FolderName = "Pressure", FileName = "Pressure" },
    KeySystem = false
})

local function CleanupCharacter(char)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if root then root.Anchored = false end
    if hum  then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
end

local Players     = game:GetService("Players")
local Player      = Players.LocalPlayer
local RunService  = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local noclipActive = false
local noclipLoop = nil


CleanupCharacter(Player.Character)
Player.CharacterAdded:Connect(CleanupCharacter)

local Esp  = Window:CreateTab("Visuals", "eye")
local Auto = Window:CreateTab("Automations", "zap")
local Anti = Window:CreateTab("Antis", "shield")
local Move = Window:CreateTab("Movement", "arrow-big-right")

local WHITE     = Color3.fromRGB(255, 255, 255)
local RED       = Color3.fromRGB(255, 0, 0)
local Rooms     = workspace.GameplayFolder.Rooms

-- ================================================
-- CONFIGS
-- ================================================

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

-- Todos os monstros incluindo Ridge variants
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

-- ================================================
-- HELPERS
-- ================================================

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
            return { label=e.label, fill=e.fill, outline=e.outline or WHITE }
        end
    end
    return nil
end

local function IsCurrencyOrBlueprint(name)
    return GetCurrencyConfig(name) ~= nil
end

local function GetRootPart()
    local char = Player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = Player.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local lastNotify = {}
local function NotifyOnce(key, title, content, duration, image)
    if lastNotify[key] and (tick() - lastNotify[key]) < 8 then return end
    lastNotify[key] = tick()
    Rayfield:Notify({ Title=title, Content=content, Duration=duration, Image=image })
end

-- ================================================
-- ESP FUNCTIONS
-- ================================================

local Workspace = game:GetService("Workspace")
local Rooms = Workspace:FindFirstChild("Rooms") or Workspace:FindFirstChild("CurrentRooms")
local WHITE = Color3.new(1, 1, 1)

-- [[ 1. СИСТЕМА ВІЗУАЛІЗАЦІЇ (ESP) ]] --

local function AddESP(part, config)
    if not part or not part.Parent then return end
    if part:FindFirstChild("ESP_Container") then return end 

    local container = Instance.new("Folder")
    container.Name = "ESP_Container"
    container.Parent = part

    -- Підсвітка (Highlight)
    local h = Instance.new("Highlight")
    h.Adornee = part
    h.FillColor = config.fill or Color3.new(0, 1, 0)
    h.OutlineColor = config.outline or WHITE
    h.FillTransparency = config.fillTransparency or 0.4
    h.OutlineTransparency = 0
    h.Parent = container

    -- Текст (BillboardGui)
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_Label"
    bb.Adornee = part
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 140, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Parent = container

    local lbl = Instance.new("TextLabel")
    lbl.Text = config.label or "Object"
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = config.textColor or WHITE
    lbl.TextStrokeTransparency = 0.3
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = bb

    -- Оптимізація: Автовидалення (наприклад, для дверей)
    if config.autoDelete then
        task.delay(30, function()
            if container then container:Destroy() end
        end)
    end
end

local function RemoveESP(part)
    if not part then return end
    local container = part:FindFirstChild("ESP_Container")
    if container then container:Destroy() end
end

-- [[ 2. УНІВЕРСАЛЬНИЙ СКАНЕР (Rooms & Workspace) ]] --

local function ScanObjects(enabledFn, matchFn, onFound)
    local connections = {}
    
    local function process(d)
        if not enabledFn() or not d.Parent then return end
        local config = matchFn(d.Name)
        if config then
            -- Знаходимо найкращу точку для кріплення ESP
            local target = d:FindFirstChild("ProxyPart") or (d:IsA("Model") and d.PrimaryPart) or d
            onFound(target, config)
        end
    end

    -- Сканування кімнат (якщо вони є)
    if Rooms then
        for _, room in ipairs(Rooms:GetChildren()) do
            for _, d in ipairs(room:GetDescendants()) do process(d) end
            table.insert(connections, room.DescendantAdded:Connect(function(d)
                task.wait(0.1)
                process(d)
            end))
        end
        
        table.insert(connections, Rooms.ChildAdded:Connect(function(room)
            task.wait(0.5)
            for _, d in ipairs(room:GetDescendants()) do process(d) end
            table.insert(connections, room.DescendantAdded:Connect(function(d)
                task.wait(0.1)
                process(d)
            end))
        end))
    end

    return connections
end

-- [[ 3. ФУНКЦІЇ ДЛЯ ТАБІВ (RAYFIELD) ]] --

-- Створює перемикач для ESP будь-чого
function CreateESPToggle(tab, name, flag, matchFn)
    local connections = {}
    local targets = {}
    local active = false

    tab:CreateToggle({
        Name = name,
        CurrentValue = false,
        Flag = flag,
        Callback = function(Value)
            active = Value
            if Value then
                connections = ScanObjects(
                    function() return active end,
                    matchFn,
                    function(target, config)
                        AddESP(target, config)
                        table.insert(targets, target)
                    end
                )
            else
                for _, c in ipairs(connections) do c:Disconnect() end
                connections = {}
                for _, t in ipairs(targets) do pcall(RemoveESP, t) end
                targets = {}
            end
        end
    })
end

-- Створює перемикач для видалення будь-чого (Anti-Trap)
function CreateAntiToggle(tab, name, flag, matchFn)
    local conns = {}
    local active = false

    tab:CreateToggle({
        Name = name,
        CurrentValue = false,
        Flag = flag,
        Callback = function(Value)
            active = Value
            if Value then
                local function clean(d)
                    if active and matchFn(d.Name) then
                        pcall(function() d:Destroy() end)
                    end
                end
                for _, d in ipairs(workspace:GetDescendants()) do clean(d) end
                table.insert(conns, workspace.DescendantAdded:Connect(function(d)
                    task.wait(0.05)
                    clean(d)
                end))
            else
                for _, c in ipairs(conns) do c:Disconnect() end
                conns = {}
            end
        end
    })
end
-- [[ ПРИКЛАД ВИКОРИСТАННЯ (ДОДАТИ В ТАБИ) ]] --

-- Для дверей:
-- matchFn = function(name) 
--    if name == "Door" then 
--        return {label = "Door", fill = Color3.new(0,1,0), autoDelete = true} 
--    end 
-- end
-- ================================================
-- VISUALS TAB
-- ================================================

Esp:CreateSection("Items")
CreateESPToggle(Esp, "Keycard ESP",              "EspKeycard",  function(n) return KEYCARDS[n] end)
CreateESPToggle(Esp, "Currency & Blueprint ESP", "EspCurrency", function(n) return GetCurrencyConfig(n) end)
CreateESPToggle(Esp, "Item ESP",                 "EspItems",    function(n) return GetItemConfig(n) end)

Esp:CreateSection("Monsters")

local lockerConns, lockerActive = {}, false
Esp:CreateToggle({
    Name="Monster Locker ESP", CurrentValue=false, Flag="EspMonsterLocker",
    Callback=function(Value)
        lockerActive = Value
        local cfg = { label="⚠ MONSTER LOCKER", fill=Color3.fromRGB(200,0,0), outline=Color3.fromRGB(255,80,80), textColor=Color3.fromRGB(255,80,80), fillTransparency=0.3 }
        if Value then
            lockerConns = ScanRooms(
                function() return lockerActive end,
                function(n) return n=="MonsterLocker" and cfg or nil end,
                function(target, config) AddESP(target, config) end
            )
        else
            for _, c in ipairs(lockerConns) do c:Disconnect() end
            lockerConns = {}
            for _, room in ipairs(Rooms:GetChildren()) do
                for _, d in ipairs(room:GetDescendants()) do
                    if d.Name == "MonsterLocker" then pcall(RemoveESP, d) end
                end
            end
        end
    end
})

local fakeDoorConns, fakeDoorActive = {}, false
Esp:CreateToggle({
    Name="Fake Door ESP", CurrentValue=false, Flag="EspFakeDoor",
    Callback=function(Value)
        fakeDoorActive = Value
        local cfg = { label="✖ FAKE DOOR", fill=Color3.fromRGB(180,0,0), outline=RED, textColor=RED, fillTransparency=0.3 }
        if Value then
            fakeDoorConns = ScanRooms(
                function() return fakeDoorActive end,
                function(n) return n=="Door" and cfg or nil end,
                function(target, config)
                    if target.Parent and target.Parent.Name == "TricksterDoor" then
                        AddESP(target, config)
                    end
                end
            )
        else
            for _, c in ipairs(fakeDoorConns) do c:Disconnect() end
            fakeDoorConns = {}
            for _, room in ipairs(Rooms:GetChildren()) do
                for _, d in ipairs(room:GetDescendants()) do
                    if d.Name=="Door" and d.Parent and d.Parent.Name=="TricksterDoor" then
                        pcall(RemoveESP, d)
                    end
                end
            end
        end
    end
})

local generatorConns, generatorActive = {}, false
Esp:CreateToggle({
    Name="Generator ESP", CurrentValue=false, Flag="EspGenerator",
    Callback=function(Value)
        generatorActive = Value
        local trackedGenerators = {}

        local function getGeneratorCfg(fixedVal)
            local pct = tonumber(fixedVal) or 0
            if pct >= 100 then return nil end
            local r = math.floor(255 * (1 - pct/100))
            local g = math.floor(255 * (pct/100))
            return {
                label="⚙ Generator " .. math.floor(pct) .. "%",
                fill=Color3.fromRGB(r, g, 0),
                outline=Color3.fromRGB(255,200,0),
                textColor=WHITE, fillTransparency=0.3,
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
            if cfg then pcall(AddESP, proxy, cfg) end
            table.insert(generatorConns, fixed:GetPropertyChangedSignal("Value"):Connect(function()
                if not generatorActive then return end
                pcall(RemoveESP, proxy)
                local newCfg = getGeneratorCfg(fixed.Value)
                if newCfg then pcall(AddESP, proxy, newCfg) end
            end))
        end

        local function scanRoom(room)
            for _, d in ipairs(room:GetDescendants()) do
                if not generatorActive then break end
                if d.Name=="PresetGenerator" or d.Name=="Generator" then
                    pcall(setupGenerator, d)
                end
                if d.Name=="Fixed" and d.Parent then
                    pcall(setupGenerator, d.Parent)
                end
            end
        end

        if Value then
            for _, room in ipairs(Rooms:GetChildren()) do
                task.defer(function() scanRoom(room) end)
                table.insert(generatorConns, room.DescendantAdded:Connect(function(d)
                    task.wait(0.2)
                    if not generatorActive then return end
                    if d.Name=="PresetGenerator" or d.Name=="Generator" or d.Name=="Fixed" then
                        pcall(setupGenerator, d.Name=="Fixed" and d.Parent or d)
                    end
                end))
            end
            table.insert(generatorConns, Rooms.ChildAdded:Connect(function(room)
                task.wait(0.3)
                if generatorActive then scanRoom(room) end
                table.insert(generatorConns, room.DescendantAdded:Connect(function(d)
                    task.wait(0.2)
                    if not generatorActive then return end
                    if d.Name=="PresetGenerator" or d.Name=="Generator" or d.Name=="Fixed" then
                        pcall(setupGenerator, d.Name=="Fixed" and d.Parent or d)
                    end
                end))
            end))
        else
            for _, c in ipairs(generatorConns) do c:Disconnect() end
            generatorConns = {}
            trackedGenerators = {}
            for _, room in ipairs(Rooms:GetChildren()) do
                for _, d in ipairs(room:GetDescendants()) do
                    if d.Name=="PresetGenerator" or d.Name=="Generator" then
                        pcall(RemoveESP, d:FindFirstChild("ProxyPart") or d)
                    end
                end
            end
        end
    end
})

local monsterEspConns, monsterEspActive = {}, false
Esp:CreateToggle({
    Name="Monster ESP", CurrentValue=false, Flag="EspMonster",
    Callback=function(Value)
        monsterEspActive = Value
        local tracked = {}

        local function applyESP(child)
            if not monsterEspActive then return end
            if tracked[child] then return end
            tracked[child] = true
            pcall(AddESP, child, {
                fill=Color3.fromRGB(200,0,0),
                outline=Color3.fromRGB(255,200,0),
                textColor=RED,
                fillTransparency=0.3,
                label="☠ " .. child.Name
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
                if MONSTERS[child.Name] then applyESP(child) end
            end
        end

        local function listenContainer(container)
            table.insert(monsterEspConns, container.ChildAdded:Connect(function(child)
                if monsterEspActive and MONSTERS[child.Name] then applyESP(child) end
            end))
        end

        if Value then
            scanWorkspace()
                
            for _, child in ipairs(workspace.GameplayFolder.Monsters:GetChildren()) do
                if MONSTERS[child.Name] then applyESP(child) end
            end
            listenContainer(workspace)
            listenContainer(workspace.GameplayFolder.Monsters)
        else
            for _, c in ipairs(monsterEspConns) do c:Disconnect() end
            monsterEspConns = {}
            tracked = {}
            for _, child in ipairs(workspace:GetChildren()) do
                if MONSTERS[child.Name] then pcall(RemoveESP, child) end
            end
            for _, child in ipairs(workspace.GameplayFolder.Monsters:GetChildren()) do
                pcall(RemoveESP, child)
            end
        end
    end
})


local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")


local playerGui = player:WaitForChild("PlayerGui")

local scriptEnabled = true
local activeMonsters = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MonsterSystemFinal"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local alertLabel = Instance.new("TextLabel")
alertLabel.Size = UDim2.new(1, 0, 0.2, 0)
alertLabel.Position = UDim2.new(0, 0, 0.25, 0)
alertLabel.BackgroundTransparency = 1
alertLabel.Text = ""
alertLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
alertLabel.TextSize = 45
alertLabel.Font = Enum.Font.LuckiestGuy
alertLabel.Parent = screenGui

local function notify(text, color)
    local note = Instance.new("TextLabel")
    note.Size = UDim2.new(0, 300, 0, 50)
    note.Position = UDim2.new(0.5, -150, 0.8, 0)
    note.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    note.TextColor3 = color
    note.Text = text
    note.TextSize = 25
    note.Font = Enum.Font.SourceSansBold
    note.Parent = screenGui
    Instance.new("UICorner", note)
    task.delay(2, function()
        TweenService:Create(note, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        note:Destroy()
    end)
end

local function applyVisuals(monster)
    local root = monster:IsA("Model") and (monster.PrimaryPart or monster:FindFirstChildWhichIsA("BasePart")) or monster
    if not root then return end

    if not monster:FindFirstChild("MonsterHighlight") then
        local hl = Instance.new("Highlight", monster)
        hl.Name = "MonsterHighlight"
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    
    if not monster:FindFirstChild("MonsterTracer") then
        local att0 = Instance.new("Attachment", root)
        local beam = Instance.new("Beam", monster)
        beam.Name = "MonsterTracer"
        beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
        beam.Width0, beam.Width1 = 1, 1
        beam.Attachment0 = att0
        
        local pRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if pRoot then
            local pAtt = pRoot:FindFirstChild("MT_Att") or Instance.new("Attachment", pRoot)
            pAtt.Name = "MT_Att"
            beam.Attachment1 = pAtt
        end
    end

    if not monster:FindFirstChild("MonsterSphere") then
        local sphere = Instance.new("SelectionSphere")
        sphere.Name = "MonsterSphere"
        sphere.Adornee = root
        sphere.Color3 = Color3.fromRGB(255, 0, 0)
        sphere.Transparency = 0.6
        sphere.Parent = monster
    end
end

-- 3. ДЕТЕКЦІЯ (ДОДАНО БЛЕКЛІСТ)
local function checkMonster(child)
    task.wait(0.2)
    if not scriptEnabled or not child or not child.Parent then return end
    
    local name = child.Name:lower()
    -- Твій новий блекліст тут:
    if name:find("orb") or name:find("ambience") or name:find("light") or name:find("proxy") or name:find("vent") then 
        return 
    end
    
    if (child:IsA("Model") or child:IsA("BasePart")) and not Players:GetPlayerFromCharacter(child) then
        local inEntities = child.Parent.Name == "Entities" or child.Parent.Name == "Monsters"
        local hasSound = child:FindFirstChildOfClass("Sound", true)
        
        if (inEntities or hasSound) then
            local id = child:GetDebugId()
            if not activeMonsters[id] then
                activeMonsters[id] = {instance = child, name = child.Name, startTime = tick()}
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    local text = ""
    local currentTime = tick()
    
    if scriptEnabled then
        for id, data in pairs(activeMonsters) do
            local duration = currentTime - data.startTime
            
            if duration > 60 or not data.instance or not data.instance.Parent then
                activeMonsters[id] = nil
            else
                local root = data.instance:IsA("Model") and (data.instance.PrimaryPart or data.instance:FindFirstChildWhichIsA("BasePart")) or data.instance
                if root and player.Character and player.Character.PrimaryPart then
                    local dist = math.floor((root.Position - player.Character.PrimaryPart.Position).Magnitude)
                    if dist < 1500 then
                        text = text .. "⚠️ " .. data.name:upper() .. " [" .. dist .. "m] - " .. math.floor(duration) .. "s\n"
                        applyVisuals(data.instance)
                    else activeMonsters[id] = nil end
                end
            end
        end
        alertLabel.Text = text
    else
        alertLabel.Text = ""
    end
end)

workspace.ChildAdded:Connect(checkMonster)

UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    if input.KeyCode == Enum.KeyCode.B then
        scriptEnabled = not scriptEnabled
        if scriptEnabled then
            notify("Скрипт увімкнено", Color3.fromRGB(0, 255, 0))
        else
            notify("Скрипт відключено", Color3.fromRGB(255, 0, 0))
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "MonsterHighlight" or v.Name == "MonsterTracer" or v.Name == "MonsterSphere" then v:Destroy() end
            end
        end
    end
end)

Esp:CreateSection("World")

local originalLighting, fullbrightEffects = {}, {}
Esp:CreateToggle({
    Name="Fullbright", CurrentValue=false, Flag="Fullbright",
    Callback=function(Value)
        local L = game:GetService("Lighting")
        if Value then
            originalLighting = {
                Brightness=L.Brightness, ClockTime=L.ClockTime,
                FogEnd=L.FogEnd, GlobalShadows=L.GlobalShadows,
                Ambient=L.Ambient, OutdoorAmbient=L.OutdoorAmbient,
            }
            fullbrightEffects = {}
            for _, e in ipairs(L:GetChildren()) do
                if e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect")
                or e:IsA("DepthOfFieldEffect") or e:IsA("SunRaysEffect") then
                    fullbrightEffects[e] = e.Enabled
                    e.Enabled = false
                end
            end
            L.Brightness=10; L.ClockTime=14; L.FogEnd=100000
            L.GlobalShadows=false
            L.Ambient=Color3.fromRGB(255,255,255)
            L.OutdoorAmbient=Color3.fromRGB(255,255,255)
        else
            L.Brightness=originalLighting.Brightness
            L.ClockTime=originalLighting.ClockTime
            L.FogEnd=originalLighting.FogEnd
            L.GlobalShadows=originalLighting.GlobalShadows
            L.Ambient=originalLighting.Ambient
            L.OutdoorAmbient=originalLighting.OutdoorAmbient
            for effect, wasEnabled in pairs(fullbrightEffects) do
                if effect and effect.Parent then effect.Enabled = wasEnabled end
            end
            fullbrightEffects = {}
        end
    end
})

Esp:CreateSection("Camera")

local originalFOV = nil
local fovSlider = Esp:CreateSlider({
    Name="FOV Changer",
    Range={70, 120},
    Increment=1,
    Suffix="",
    CurrentValue=70,
    Flag="FOVChanger",
    Callback=function(Value)
        if workspace.CurrentCamera then
            if not originalFOV then
                originalFOV = Value
            end
            workspace.CurrentCamera.FieldOfView = Value
        end
    end
})

-- ================================================
-- AUTOMATIONS
-- ================================================

Auto:CreateSection("Safety")

local dodgeActive = false
Auto:CreateToggle({
    Name="Monster Dodge", CurrentValue=false, Flag="MonsterDodge",
    Callback=function(Value)
        dodgeActive = Value
        if not Value then return end

        local platform      = nil
        local dodging       = false
        local dodgeConns    = {}
        local heartbeatConn = nil

        local function cleanupDodge()
            if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn=nil end
            if platform and platform.Parent then platform:Destroy(); platform=nil end
        end

        -- Garante que o personagem fica limpo mesmo se der erro
        local function safeRestorePlayer(savedCFrame)
            pcall(function()
                local root = GetRootPart()
                local hum  = GetHumanoid()
                if root then
                    root.Anchored = false
                    if savedCFrame then root.CFrame = savedCFrame end
                end
                if hum then
                    hum.WalkSpeed = 16
                    hum.JumpPower = 50
                end
            end)
        end

        local function freezePlayer(freeze)
            local hum  = GetHumanoid()
            local root = GetRootPart()
            if hum then
                hum.WalkSpeed = freeze and 0 or 16
                hum.JumpPower = freeze and 0 or 50
            end
            if root then root.Anchored = freeze end
        end

        local function returnPlayer(savedCFrame, reason)
            cleanupDodge()
            safeRestorePlayer(savedCFrame)
            dodging = false
            NotifyOnce("dodge_return","🛡 Monster Dodge", reason .. " Returning.", 3, "shield-off")
        end

        local function startDodge(monsterName, monsterInstance)
            if dodging or not dodgeActive then return end
            dodging = true

            local root = GetRootPart()
            if not root then dodging=false; return end

            local savedCFrame = root.CFrame

            -- Usa pcall em tudo para garantir cleanup mesmo com erro
            local ok = pcall(function()
                freezePlayer(true)

                platform = Instance.new("Part")
                platform.Size = Vector3.new(10,1,10)
                platform.CFrame = CFrame.new(savedCFrame.Position + Vector3.new(0,320,0))
                platform.Anchored = true
                platform.CanCollide = true
                platform.Transparency = 0.3
                platform.Material = Enum.Material.SmoothPlastic
                platform.BrickColor = BrickColor.new("Bright blue")
                platform.Parent = workspace

                root.Anchored = false
                root.CFrame = CFrame.new(platform.Position + Vector3.new(0,4,0))
                task.wait(0.05)
                root.Anchored = true
            end)

            if not ok then
                -- Se deu erro, garante limpeza
                cleanupDodge()
                safeRestorePlayer(savedCFrame)
                dodging = false
                return
            end

            local targetCFrame = CFrame.new(platform.Position + Vector3.new(0,4,0))
            heartbeatConn = RunService.Heartbeat:Connect(function()
                if not dodging then return end
                local r = GetRootPart()
                if r then r.CFrame = targetCFrame end
            end)

            NotifyOnce("dodge_"..monsterName,"🛡 Monster Dodge", monsterName.." spawned! Holding 40s...", 5, "shield")

            local returned = false

            task.delay(40, function()
                if dodging and not returned then
                    returned = true
                    returnPlayer(savedCFrame, monsterName.." timeout.")
                end
            end)

            local waitConn
            waitConn = monsterInstance.AncestryChanged:Connect(function()
                if monsterInstance:IsDescendantOf(workspace) or
                   monsterInstance:IsDescendantOf(workspace.GameplayFolder.Monsters) then return end
                waitConn:Disconnect()
                if not returned then
                    returned = true
                    returnPlayer(savedCFrame, monsterName.." gone.")
                end
            end)
        end

        local function listenContainer(container)
            table.insert(dodgeConns, container.ChildAdded:Connect(function(child)
                if dodgeActive and MONSTERS[child.Name] then
                    startDodge(child.Name, child)
                end
            end))
        end

        listenContainer(workspace)
        listenContainer(workspace.GameplayFolder.Monsters)

        task.spawn(function()
            while dodgeActive do task.wait(0.3) end
            for _, c in ipairs(dodgeConns) do c:Disconnect() end
            dodgeConns = {}
            cleanupDodge()
            -- Restaura sempre ao desligar
            local root = GetRootPart()
            local hum  = GetHumanoid()
            if root then root.Anchored = false end
            if hum  then hum.WalkSpeed=16; hum.JumpPower=50 end
            dodging = false
        end)
    end
})


-- ================================================
-- LOOT AURA
-- ================================================

local lootAuraActive = false
local lootAuraRadius = 10
local lootAuraLoop = nil
local lootAuraCache = {}
local lootAuraLastScan = 0

local function BuildLootCache()
    lootAuraCache = {}
    for _, room in ipairs(Rooms:GetChildren()) do
        for _, desc in ipairs(room:GetDescendants()) do
            if desc:IsA("Model") or desc:IsA("BasePart") then
                local name = desc.Name
                if IsCurrencyOrBlueprint(name) or KEYCARDS[name] or GetItemConfig(name) then
                    local prompt = desc:FindFirstChildWhichIsA("ProximityPrompt")
                    if not prompt then
                        prompt = desc:FindFirstChildWhichIsA("ClickDetector")
                    end
                    if not prompt then
                        for _, d in ipairs(desc:GetDescendants()) do
                            if d:IsA("ProximityPrompt") then
                                prompt = d
                                break
                            end
                        end
                    end
                    if prompt then
                        table.insert(lootAuraCache, { target = desc, prompt = prompt })
                    end
                end
            end
        end
    end
end

local function CollectNearbyItems()
    local root = GetRootPart()
    if not root then return end


    local now = tick()
    if now - lootAuraLastScan > 2 then
        BuildLootCache()
        lootAuraLastScan = now
    end

    local r = tonumber(lootAuraRadius) or 15

    for _, entry in ipairs(lootAuraCache) do
        if not lootAuraActive then break end
        local prompt = entry.prompt
        if prompt and prompt:IsDescendantOf(workspace) then
            local promptPart = prompt.Parent
            local checkPart = nil
            if promptPart and promptPart:IsA("BasePart") then
                checkPart = promptPart
            elseif prompt:IsA("BasePart") then
                checkPart = prompt
            end
            if checkPart then
                local dist = (root.Position - checkPart.Position).Magnitude
                if dist < r and dist > 0 then
                    pcall(function()
                        if prompt:IsA("ProximityPrompt") then
                            fireproximityprompt(prompt)
                        elseif prompt:IsA("ClickDetector") then
                            fireclickdetector(prompt)
                        end
                    end)
                end
            end
        end
    end
end

local lootAuraSection = Auto:CreateSection("Looting")

Auto:CreateSlider({
    Name="Loot Aura Radius",
    Range={5, 50},
    Increment=1,
    Suffix=" studs",
    CurrentValue=15,
    Flag="LootAuraRadius",
    Callback=function(Value)
        lootAuraRadius = Value
    end
})

Auto:CreateToggle({
    Name="Loot Aura",
    CurrentValue=false,
    Flag="LootAura",
    Callback=function(Value)
        lootAuraActive = Value
        if Value then
            NotifyOnce("loot_aura_on", "Loot Aura Enabled", "Collecting items within " .. lootAuraRadius .. " studs.", 3, "sparkles")
            if not lootAuraLoop then
                lootAuraLoop = RunService.Heartbeat:Connect(function()
                    if lootAuraActive then
                        CollectNearbyItems()
                    end
                end)
            end
        else
            if lootAuraLoop then
                lootAuraLoop:Disconnect()
                lootAuraLoop = nil
            end
        end
    end
})


-- ================================================
-- KEYPAD SOLVE
-- ================================================

local keypadSolveActive = false
local keypadSolveConns = {}
local keypadSolving = {}

local function FindPasswordForRoom(keypad)
    -- Search up the room hierarchy from the keypad
    local room = keypad
    for _ = 1, 10 do
        room = room.Parent
        if not room then return nil end
        if room.Name == "Room" and room.Parent and room.Parent.Parent == Rooms then
            break
        end
    end
    if not room or room.Parent and room.Parent.Parent ~= Rooms then
        room = keypad.Parent
        while room and room.Parent and room.Parent.Parent ~= Rooms do
            room = room.Parent
        end
        if not room then return nil end
    end

    -- Find PasswordPaper in this room (or adjacent rooms)
    local scanTargets = {room}
    -- Check the room and siblings
    if room.Parent then
        for _, sibling in ipairs(room.Parent:GetChildren()) do
            if sibling ~= room then
                table.insert(scanTargets, sibling)
            end
        end
    end

    for _, target in ipairs(scanTargets) do
        for _, desc in ipairs(target:GetDescendants()) do
            if desc.Name == "PasswordPaper" then
                local codeChild = desc:FindFirstChild("Code")
                if codeChild then
                    local surfaceGui = codeChild:FindFirstChildWhichIsA("SurfaceGui")
                    if surfaceGui and surfaceGui:FindFirstChild("TextLabel") then
                        local code = surfaceGui.TextLabel.Text
                        -- Clean the code to just digits
                        code = string.gsub(code, "[^0-9]", "")
                        if #code > 0 then
                            return code
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function SolveKeypad(keypad)
    if keypadSolving[keypad] then return end
    keypadSolving[keypad] = true

    task.spawn(function()
        pcall(function()
            local root = GetRootPart()
            if not root then keypadSolving[keypad] = nil; return end

            -- Find the interactive part / proxy
            local proxy = keypad:FindFirstChild("ProxyPart")
            if not proxy then
                for _, part in ipairs(keypad:GetDescendants()) do
                    if part:IsA("BasePart") and part:FindFirstChildWhichIsA("ProximityPrompt") then
                        proxy = part
                        break
                    end
                end
            end
            if not proxy then proxy = keypad end

            local targetPos = proxy:IsA("BasePart") and proxy.Position or keypad:GetPivot().Position
            local dir = (targetPos - root.Position).Unit
            local approachPos = targetPos - (dir * 4)

            root.CFrame = CFrame.new(approachPos + Vector3.new(0, 3, 0))
            task.wait(0.2)

            -- Read the password from PasswordPaper
            local code = FindPasswordForRoom(keypad)
            if not code or #code == 0 then
                NotifyOnce("keypad_nocode_" .. keypad:GetFullName(), "Keypad Solve", "Could not find the password paper nearby.", 4, "alert-circle")
                keypadSolving[keypad] = nil
                return
            end

            NotifyOnce("keypad_solving_" .. keypad:GetFullName(), "Keypad Solve", "Entering code: " .. code, 3, "loader")

            -- Collect all parts with prompts/clickdetectors ONCE
            local keypadParts = keypad:GetDescendants()
            local digitButtons = {}
            local submitPart = nil

            for _, part in ipairs(keypadParts) do
                local pn = part.Name
                local prompt = part:FindFirstChildWhichIsA("ProximityPrompt")
                local cd = part:FindFirstChildWhichIsA("ClickDetector")
                local interact = prompt or cd
                if interact then
                    if pn == "submit" or pn == "enter" or pn == "KeypadSubmit" or pn == "KeypadEnter" or
                       string.lower(pn) == "submit" or string.lower(pn) == "enter" then
                        submitPart = interact
                    elseif pn == "0" or pn == "Keypad0" or string.match(pn, "Button0$") then
                        digitButtons["0"] = interact
                    elseif pn == "1" or pn == "Keypad1" or string.match(pn, "Button1$") then
                        digitButtons["1"] = interact
                    elseif pn == "2" or pn == "Keypad2" or string.match(pn, "Button2$") then
                        digitButtons["2"] = interact
                    elseif pn == "3" or pn == "Keypad3" or string.match(pn, "Button3$") then
                        digitButtons["3"] = interact
                    elseif pn == "4" or pn == "Keypad4" or string.match(pn, "Button4$") then
                        digitButtons["4"] = interact
                    elseif pn == "5" or pn == "Keypad5" or string.match(pn, "Button5$") then
                        digitButtons["5"] = interact
                    elseif pn == "6" or pn == "Keypad6" or string.match(pn, "Button6$") then
                        digitButtons["6"] = interact
                    elseif pn == "7" or pn == "Keypad7" or string.match(pn, "Button7$") then
                        digitButtons["7"] = interact
                    elseif pn == "8" or pn == "Keypad8" or string.match(pn, "Button8$") then
                        digitButtons["8"] = interact
                    elseif pn == "9" or pn == "Keypad9" or string.match(pn, "Button9$") then
                        digitButtons["9"] = interact
                    end
                end
            end

            -- Enter each digit
            for i = 1, #code do
                if not keypadSolveActive then break end
                local digit = string.sub(code, i, i)
                local btn = digitButtons[digit]
                if btn then
                    if btn:IsA("ProximityPrompt") then
                        fireproximityprompt(btn)
                    elseif btn:IsA("ClickDetector") then
                        fireclickdetector(btn)
                    end
                end
                task.wait(0.1)
            end

            -- Submit
            if submitPart then
                if submitPart:IsA("ProximityPrompt") then
                    fireproximityprompt(submitPart)
                elseif submitPart:IsA("ClickDetector") then
                    fireclickdetector(submitPart)
                end
            end

            NotifyOnce("keypad_done_" .. keypad:GetFullName(), "Keypad Solve", "Code entered: " .. code, 3, "check")
        end)
        keypadSolving[keypad] = nil
    end)
end

local keypadSection = Auto:CreateSection("Keypad")

Auto:CreateToggle({
    Name="Auto Keypad Solve",
    CurrentValue=false,
    Flag="AutoKeypadSolve",
    Callback=function(Value)
        keypadSolveActive = Value
        if Value then
            -- Scan existing keypads
            for _, room in ipairs(Rooms:GetChildren()) do
                for _, desc in ipairs(room:GetDescendants()) do
                    if desc.Name == "Keypad" or desc.Name == "PresetKeypad" then
                        SolveKeypad(desc)
                    end
                end
            end
            -- Listen for new keypads
            table.insert(keypadSolveConns, Rooms.ChildAdded:Connect(function(room)
                task.wait(1)
                if not keypadSolveActive then return end
                for _, desc in ipairs(room:GetDescendants()) do
                    if desc.Name == "Keypad" or desc.Name == "PresetKeypad" then
                        SolveKeypad(desc)
                    end
                end
                table.insert(keypadSolveConns, room.DescendantAdded:Connect(function(d)
                    if keypadSolveActive and (d.Name == "Keypad" or d.Name == "PresetKeypad") then
                        task.wait(0.5)
                        SolveKeypad(d)
                    end
                end))
            end))
        else
            for _, c in ipairs(keypadSolveConns) do c:Disconnect() end
            keypadSolveConns = {}
            keypadSolving = {}
        end
    end
})

Auto:CreateSection("Convenience")

local autoRetryActive = false
local autoRetryConns = {}

Auto:CreateToggle({
    Name="Auto Retry",
    CurrentValue=false,
    Flag="AutoRetry",
    Callback=function(Value)
        autoRetryActive = Value
        if Value then
            local conn = RunService.Heartbeat:Connect(function()
                if not autoRetryActive then return end
                pcall(function()
                    if Player.PlayerGui and Player.PlayerGui:FindFirstChild("Main")
                       and Player.PlayerGui.Main:FindFirstChild("AfterDeath")
                       and Player.PlayerGui.Main.AfterDeath.Visible then
                        ReplicatedStorage.Events.PlayAfterDeath:FireServer()
                    end
                end)
            end)
            table.insert(autoRetryConns, conn)
        else
            for _, c in ipairs(autoRetryConns) do c:Disconnect() end
            autoRetryConns = {}
        end
    end
})


-- ================================================
-- MOVEMENT
-- ================================================

Move:CreateSection("Collision")

Move:CreateToggle({
    Name="Noclip",
    CurrentValue=false,
    Flag="Noclip",
    Callback=function(Value)
        noclipActive = Value
        if Value then
            if not noclipLoop then
                noclipLoop = RunService.Heartbeat:Connect(function()
                    if not noclipActive then return end
                    local char = Player.Character
                    if not char then return end
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
            end
            -- Immediate effect on current character
            local char = Player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        else
            if noclipLoop then
                noclipLoop:Disconnect()
                noclipLoop = nil
            end
            -- Restore collision on current character
            local char = Player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then root.CanCollide = false end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part ~= root then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})


-- ================================================
-- ANTIS
-- ================================================

Anti:CreateSection("Monsters")

Anti:CreateToggle({
     Name = "Anti-Shark Protection",
     CurrentValue = false,
     Callback = function(Value)
       _G.AntiShark = Value
       task.spawn(function()
         while _G.AntiShark do
            pcall(function()
               for _, v in pairs(workspace.CurrentCamera:GetChildren()) do
                  if v.Name:find("Eye") or v.Name:find("Gaze") or v.Name == "Static" then
                     v:Destroy()
                  end
               end
               local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
               if pg and pg:FindFirstChild("MainGui") then
                  local static = pg.MainGui:FindFirstChild("Static", true)
                  if static then static.Visible = false end
               end
            end)
            task.wait(0.2)
         end
      end)
   end,
})
      
Anti:CreateToggle({
    Name="Remove Pandemonium", CurrentValue=false, Flag="RemovePandemonium",
    Callback=function(Value)
        local conn=nil; local active=Value
        if Value then
            for _, child in ipairs(workspace:GetChildren()) do
                if PANDEMONIUM_NAMES[child.Name] then pcall(function() child:Destroy() end) end
            end
            conn = workspace.ChildAdded:Connect(function(child)
                if active and PANDEMONIUM_NAMES[child.Name] then pcall(function() child:Destroy() end) end
            end)
        else
            active=false
            if conn then conn:Disconnect(); conn=nil end
        end
    end
})

Anti:CreateToggle({
    Name="Remove WallDweller", CurrentValue=false, Flag="RemoveWallDweller",
    Callback=function(Value)
        local conn=nil; local active=Value
        local WD = { WallDweller=true, MeatWallDweller=true, RottenWallDweller=true, WallDwellers=true }
        if Value then
            for _, child in ipairs(workspace:GetChildren()) do
                if WD[child.Name] then pcall(function() child:Destroy() end) end
            end
            conn = workspace.ChildAdded:Connect(function(child)
                if active and WD[child.Name] then pcall(function() child:Destroy() end) end
            end)
        else
            active=false
            if conn then conn:Disconnect(); conn=nil end
        end
    end
})

Anti:CreateToggle({
    Name="Remove Bouncer", CurrentValue=false, Flag="RemoveBouncer",
    Callback=function(Value)
        local conn=nil; local active=Value
        local mf = workspace.GameplayFolder.Monsters
        if Value then
            for _, c in ipairs(mf:GetChildren()) do
                if c.Name=="Bouncer" then pcall(function() c:Destroy() end) end
            end
            conn = mf.ChildAdded:Connect(function(child)
                if active and child.Name=="Bouncer" then pcall(function() child:Destroy() end) end
            end)
        else
            active=false
            if conn then conn:Disconnect(); conn=nil end
        end
    end
})

Anti:CreateToggle({
    Name="Remove Skeleton Head", CurrentValue=false, Flag="RemoveSkeletonHead",
    Callback=function(Value)
        local conn=nil; local active=Value
        local mf = workspace.GameplayFolder.Monsters
        if Value then
            for _, c in ipairs(mf:GetChildren()) do
                if c.Name=="SkeletonHead" then pcall(function() c:Destroy() end) end
            end
            conn = mf.ChildAdded:Connect(function(child)
                if active and child.Name=="SkeletonHead" then pcall(function() child:Destroy() end) end
            end)
        else
            active=false
            if conn then conn:Disconnect(); conn=nil end
        end
    end
})

Anti:CreateToggle({
    Name="Remove Statue", CurrentValue=false, Flag="RemoveStatue",
    Callback=function(Value)
        local conn=nil; local active=Value
        local mf = workspace.GameplayFolder.Monsters
        if Value then
            for _, d in ipairs(mf:GetChildren()) do
                if d.Name=="StatueRoot" then pcall(function() d:Destroy() end) end
            end
            conn = mf.ChildAdded:Connect(function(child)
                if active and child.Name=="StatueRoot" then pcall(function() child:Destroy() end) end
            end)
        else
            active=false
            if conn then conn:Disconnect(); conn=nil end
        end
    end
})

CreateAntiToggle(Anti,"Remove DiVine",        "RemoveDiVine",       function(n) return n=="DiVine" or n=="DiVineRoot" end)
CreateAntiToggle(Anti,"Remove Searchlights",  "RemoveSearchlights", function(n) return n=="Searchlights" end)
CreateAntiToggle(Anti,"Remove Monster Locker","RemoveMonsterLocker",function(n) return n=="MonsterLocker" end)

Anti:CreateSection("Spawns")
CreateAntiToggle(Anti,"Remove Turrets",  "RemoveTurrets",  function(n) return n=="Turret" or string.match(n,"^TurretSpawn")~=nil end)
CreateAntiToggle(Anti,"Remove Tripwires","RemoveTripwires",function(n) return n=="Tripwire" or n=="TripwireSpawn" end)
CreateAntiToggle(Anti,"Remove Landmines","RemoveLandmines",function(n) return n=="Landmine" or n=="LandmineSpawn" end)

Anti:CreateSection("Encounters")

Anti:CreateToggle({
    Name="Remove Firewall", CurrentValue=false, Flag="RemoveFirewall",
    Callback=function(Value)
        local conn=nil; local active=Value
        if Value then
            local fw = workspace:FindFirstChild("Firewall")
            if fw then fw:Destroy() end
            conn = workspace.ChildAdded:Connect(function(child)
                if active and child.Name=="Firewall" then pcall(function() child:Destroy() end) end
            end)
        else
            active=false
            if conn then conn:Disconnect(); conn=nil end
        end
    end
})

Rayfield:LoadConfiguration()
