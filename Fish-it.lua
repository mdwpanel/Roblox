-- ============================================
-- SCRIPT FISH IT - MEGA FULL FEATURES
-- ============================================
-- Gabungan fitur dari berbagai sumber:
-- Buncheats Hub, GLUA, Premium Script, dll.
-- ============================================

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera
local virtualInput = game:GetService("VirtualInputManager")

-- ============================================
-- KONFIGURASI
-- ============================================
local CONFIG = {
    -- Remote Events (sesuaikan dengan game)
    FishingRemote = "FishingEvent",
    ReelRemote = "ReelFish",
    SellRemote = "SellFish",
    EnchantRemote = "EnchantRod",
    OpenCrateRemote = "OpenCrate",
    EquipSkinRemote = "EquipSkin",
    BuyRemote = "BuyItem",
    TradeRemote = "Trade",
    AcceptTradeRemote = "AcceptTrade",
    TotemRemote = "PlaceTotem",
    WeatherRemote = "BuyWeather",
    QuestRemote = "CompleteQuest",
    ArtifactRemote = "CollectArtifact",
    EventRemote = "JoinEvent",
    
    -- Default Teleport Position
    TeleportPosition = Vector3.new(0, 5, 0),
    FishFolder = "Fish",
    
    -- Delays
    FishingDelay = 2,
    SellDelay = 1,
    CrateDelay = 1.5,
    EnchantDelay = 2,
    TotemDelay = 60,
}

-- ============================================
-- FUNGSI FIND REMOTE
-- ============================================
local function findRemote(namePattern)
    for _, obj in pairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find(namePattern:lower()) then
            return obj
        end
    end
    return nil
end

-- Auto-detect remotes
local remotes = {
    fish = findRemote("Fishing") or findRemote("Cast"),
    reel = findRemote("Reel") or findRemote("Catch"),
    sell = findRemote("Sell") or findRemote("Shop"),
    enchant = findRemote("Enchant"),
    crate = findRemote("Crate") or findRemote("OpenCrate"),
    equipSkin = findRemote("Equip") or findRemote("Skin"),
    buy = findRemote("Buy"),
    trade = findRemote("Trade"),
    acceptTrade = findRemote("Accept"),
    totem = findRemote("Totem"),
    weather = findRemote("Weather"),
    quest = findRemote("Quest"),
    artifact = findRemote("Artifact"),
    event = findRemote("Event"),
}

-- ============================================
-- VARIABEL FITUR
-- ============================================
local features = {
    autoFish = false,
    autoSell = false,
    autoEnchant = false,
    autoOpenCrate = false,
    autoEquipSkin = false,
    autoBuy = false,
    autoTrade = false,
    autoAcceptTrade = false,
    autoTotem = false,
    autoWeather = false,
    autoQuest = false,
    autoArtifact = false,
    autoEvent = false,
    autoRejoin = false,
    autoServerHop = false,
    antiAFK = false,
    antiDrown = false,
    espEnabled = false,
    flyEnabled = false,
    noclipEnabled = false,
    speedHack = false,
    instantCatch = false,
    perfectCatch = false,
    autoReCast = false,
    teleportEnabled = false,
}

-- ============================================
-- 1. AUTO FISHING (Dengan berbagai mode)
-- ============================================
local fishMode = "Stable" -- Stable, Blatant, Extreme, Instant

local function startAutoFish()
    features.autoFish = true
    print("Auto Fishing: ON (" .. fishMode .. " Mode)")
    spawn(function()
        while features.autoFish do
            if remotes.fish and not player.Character:FindFirstChild("Fishing") then
                remotes.fish:FireServer()
            end
            
            if fishMode == "Instant" then
                -- Instant catch - langsung reel tanpa delay
                if remotes.reel then
                    remotes.reel:FireServer()
                end
            else
                local delay = fishMode == "Extreme" and 0.5 or CONFIG.FishingDelay
                wait(delay)
                if remotes.reel then
                    remotes.reel:FireServer()
                end
            end
            
            if features.autoReCast then
                wait(0.5)
            else
                wait(1)
            end
        end
    end)
end

local function stopAutoFish()
    features.autoFish = false
    print("Auto Fishing: OFF")
end

-- ============================================
-- 2. AUTO SELL (Dengan filter)
-- ============================================
local sellFilter = "All" -- All, Legendary, Epic, Rare, Common

local function startAutoSell()
    features.autoSell = true
    print("Auto Sell: ON (" .. sellFilter .. ")")
    spawn(function()
        while features.autoSell do
            if remotes.sell then
                remotes.sell:FireServer(sellFilter)
            end
            wait(CONFIG.SellDelay)
        end
    end)
end

local function stopAutoSell()
    features.autoSell = false
    print("Auto Sell: OFF")
end

-- ============================================
-- 3. AUTO ENCHANT
-- ============================================
local function startAutoEnchant()
    features.autoEnchant = true
    print("Auto Enchant: ON")
    spawn(function()
        while features.autoEnchant do
            if remotes.enchant then
                remotes.enchant:FireServer()
            end
            wait(CONFIG.EnchantDelay)
        end
    end)
end

local function stopAutoEnchant()
    features.autoEnchant = false
    print("Auto Enchant: OFF")
end

-- ============================================
-- 4. AUTO OPEN CRATE
-- ============================================
local function startAutoOpenCrate()
    features.autoOpenCrate = true
    print("Auto Open Crate: ON")
    spawn(function()
        while features.autoOpenCrate do
            if remotes.crate then
                remotes.crate:FireServer()
            end
            wait(CONFIG.CrateDelay)
        end
    end)
end

local function stopAutoOpenCrate()
    features.autoOpenCrate = false
    print("Auto Open Crate: OFF")
end

-- ============================================
-- 5. AUTO EQUIP SKIN
-- ============================================
local function startAutoEquipSkin()
    features.autoEquipSkin = true
    print("Auto Equip Skin: ON")
    spawn(function()
        while features.autoEquipSkin do
            if remotes.equipSkin then
                remotes.equipSkin:FireServer("best")
            end
            wait(5)
        end
    end)
end

local function stopAutoEquipSkin()
    features.autoEquipSkin = false
    print("Auto Equip Skin: OFF")
end

-- ============================================
-- 6. AUTO BUY (Equipment, Bait, Totem, Weather)
-- ============================================
local function startAutoBuy()
    features.autoBuy = true
    print("Auto Buy: ON")
    spawn(function()
        while features.autoBuy do
            if remotes.buy then
                remotes.buy:FireServer("best") -- Beli equipment terbaik
            end
            wait(10)
            if remotes.buy then
                remotes.buy:FireServer("bait") -- Beli umpan
            end
            wait(5)
        end
    end)
end

local function stopAutoBuy()
    features.autoBuy = false
    print("Auto Buy: OFF")
end

-- ============================================
-- 7. AUTO TRADE
-- ============================================
local function startAutoTrade()
    features.autoTrade = true
    print("Auto Trade: ON")
    spawn(function()
        while features.autoTrade do
            if remotes.trade then
                remotes.trade:FireServer()
            end
            wait(30)
        end
    end)
end

local function stopAutoTrade()
    features.autoTrade = false
    print("Auto Trade: OFF")
end

-- ============================================
-- 8. AUTO ACCEPT TRADE
-- ============================================
local function startAutoAcceptTrade()
    features.autoAcceptTrade = true
    print("Auto Accept Trade: ON")
    -- Biasanya menggunakan event listener
    if remotes.acceptTrade then
        remotes.acceptTrade.OnClientEvent:Connect(function()
            if features.autoAcceptTrade then
                remotes.acceptTrade:FireServer()
            end
        end)
    end
end

local function stopAutoAcceptTrade()
    features.autoAcceptTrade = false
    print("Auto Accept Trade: OFF")
end

-- ============================================
-- 9. AUTO TOTEM
-- ============================================
local function startAutoTotem()
    features.autoTotem = true
    print("Auto Totem: ON")
    spawn(function()
        while features.autoTotem do
            if remotes.totem then
                remotes.totem:FireServer()
            end
            wait(CONFIG.TotemDelay)
        end
    end)
end

local function stopAutoTotem()
    features.autoTotem = false
    print("Auto Totem: OFF")
end

-- ============================================
-- 10. AUTO WEATHER
-- ============================================
local weatherTypes = {"Storm", "Cloudy", "Wind", "Snow"}

local function startAutoWeather()
    features.autoWeather = true
    print("Auto Weather: ON")
    spawn(function()
        local idx = 1
        while features.autoWeather do
            if remotes.weather then
                remotes.weather:FireServer(weatherTypes[idx])
                idx = idx % #weatherTypes + 1
            end
            wait(60)
        end
    end)
end

local function stopAutoWeather()
    features.autoWeather = false
    print("Auto Weather: OFF")
end

-- ============================================
-- 11. AUTO QUEST
-- ============================================
local questTypes = {"DeepSea", "AuraKid", "ElementJungle"}

local function startAutoQuest()
    features.autoQuest = true
    print("Auto Quest: ON")
    spawn(function()
        while features.autoQuest do
            for _, quest in pairs(questTypes) do
                if remotes.quest then
                    remotes.quest:FireServer(quest)
                end
                wait(2)
            end
            wait(10)
        end
    end)
end

local function stopAutoQuest()
    features.autoQuest = false
    print("Auto Quest: OFF")
end

-- ============================================
-- 12. AUTO ARTIFACT
-- ============================================
local function startAutoArtifact()
    features.autoArtifact = true
    print("Auto Artifact: ON")
    spawn(function()
        while features.autoArtifact do
            if remotes.artifact then
                remotes.artifact:FireServer()
            end
            wait(5)
        end
    end)
end

local function stopAutoArtifact()
    features.autoArtifact = false
    print("Auto Artifact: OFF")
end

-- ============================================
-- 13. AUTO EVENT (Megalodon Hunt, Worm Hunt, dll)
-- ============================================
local function startAutoEvent()
    features.autoEvent = true
    print("Auto Event: ON")
    spawn(function()
        while features.autoEvent do
            if remotes.event then
                remotes.event:FireServer()
            end
            wait(30)
        end
    end)
end

local function stopAutoEvent()
    features.autoEvent = false
    print("Auto Event: OFF")
end

-- ============================================
-- 14. AUTO REJOIN
-- ============================================
local function startAutoRejoin()
    features.autoRejoin = true
    print("Auto Rejoin: ON")
    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
        if features.autoRejoin then
            wait(5)
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end
    end)
end

local function stopAutoRejoin()
    features.autoRejoin = false
    print("Auto Rejoin: OFF")
end

-- ============================================
-- 15. AUTO SERVER HOP
-- ============================================
local function startAutoServerHop()
    features.autoServerHop = true
    print("Auto Server Hop: ON")
    spawn(function()
        while features.autoServerHop do
            wait(300) -- Hop setiap 5 menit
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end
    end)
end

local function stopAutoServerHop()
    features.autoServerHop = false
    print("Auto Server Hop: OFF")
end

-- ============================================
-- 16. ANTI-AFK (Premium Version)
-- ============================================
local function startAntiAFK()
    features.antiAFK = true
    print("Anti-AFK: ON")
    runService.RenderStepped:Connect(function()
        if features.antiAFK and player.Character and player.Character:FindFirstChild("Humanoid") then
            -- Gerakan halus agar tidak terdeteksi
            local humanoid = player.Character.Humanoid
            humanoid:Move(Vector3.new(0, 0, 0), true)
            -- Simulasi input kecil
            virtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            virtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end)
end

-- ============================================
-- 17. ANTI-DROWN
-- ============================================
local function startAntiDrown()
    features.antiDrown = true
    print("Anti-Drown: ON")
    runService.RenderStepped:Connect(function()
        if features.antiDrown and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                -- Force jump to stay above water
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- ============================================
-- 18. ESP + TRACERS + SPECTATE
-- ============================================
local espObjects = {}
local espLines = {}

local function enableESP()
    features.espEnabled = true
    print("ESP: ON")
    
    -- Highlight all players
    for _, v in pairs(players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Adornee = v.Character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.3
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = v.Character
            table.insert(espObjects, highlight)
            
            -- Tracer line
            local line = Instance.new("LineHandleAdornment")
            line.Name = "ESP_Tracer"
            line.Adornee = v.Character.HumanoidRootPart
            line.Color3 = Color3.fromRGB(255, 0, 0)
            line.Thickness = 1
            line.Parent = v.Character.HumanoidRootPart
            table.insert(espLines, line)
        end
    end
    
    -- ESP untuk player baru
    players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(function(char)
            wait(0.5)
            if features.espEnabled then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.Adornee = char
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.3
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Parent = char
                table.insert(espObjects, highlight)
                
                local line = Instance.new("LineHandleAdornment")
                line.Name = "ESP_Tracer"
                line.Adornee = char.HumanoidRootPart
                line.Color3 = Color3.fromRGB(255, 0, 0)
                line.Thickness = 1
                line.Parent = char.HumanoidRootPart
                table.insert(espLines, line)
            end
        end)
    end)
end

local function disableESP()
    features.espEnabled = false
    for _, obj in pairs(espObjects) do
        obj:Destroy()
    end
    for _, line in pairs(espLines) do
        line:Destroy()
    end
    espObjects = {}
    espLines = {}
    print("ESP: OFF")
end

-- ============================================
-- 19. FLY + NOCLIP
-- ============================================
local function toggleFly()
    features.flyEnabled = not features.flyEnabled
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        if features.flyEnabled then
            humanoid.PlatformStand = true
            print("Fly: ON")
        else
            humanoid.PlatformStand = false
            print("Fly: OFF")
        end
    end
end

local function toggleNoclip()
    features.noclipEnabled = not features.noclipEnabled
    print("Noclip: " .. (features.noclipEnabled and "ON" or "OFF"))
    runService.RenderStepped:Connect(function()
        if features.noclipEnabled and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- ============================================
-- 20. SPEED HACK
-- ============================================
local function toggleSpeedHack()
    features.speedHack = not features.speedHack
    print("Speed Hack: " .. (features.speedHack and "ON" or "OFF"))
    if features.speedHack then
        runService.RenderStepped:Connect(function()
            if features.speedHack and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 50
                player.Character.Humanoid.JumpPower = 100
            end
        end)
    else
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            player.Character.Humanoid.JumpPower = 50
        end
    end
end

-- ============================================
-- 21. TELEPORT SYSTEM (Semua Island)
-- ============================================
local islands = {
    ["Spawn"] = Vector3.new(0, 5, 0),
    ["Coral Island"] = Vector3.new(100, 5, 50),
    ["Mermaid Lagoon"] = Vector3.new(-80, 5, 120),
    ["Retro Island"] = Vector3.new(200, 5, -100),
    ["Esoteric Depths"] = Vector3.new(-150, 5, -80),
    ["Event Island"] = Vector3.new(50, 5, -150),
}

local function teleportTo(pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- ============================================
-- 22. FPS BOOST
-- ============================================
local function toggleFPSBoost()
    print("FPS Boost: ON")
    -- Reduce graphics quality
    game:GetService("Lighting").GlobalShadows = false
    game:GetService("Lighting").Technology = Enum.Technology.Legacy
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") then
            v.Material = Enum.Material.Plastic
        end
        if v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end
    settings().Rendering.QualityLevel = 1
end

-- ============================================
-- 23. SAVE & LOAD CONFIG
-- ============================================
local function saveConfig()
    local config = {}
    for name, value in pairs(features) do
        config[name] = value
    end
    writefile("FishIt_Config.json", game:GetService("HttpService"):JSONEncode(config))
    print("Config Saved!")
end

local function loadConfig()
    if isfile("FishIt_Config.json") then
        local data = game:GetService("HttpService"):JSONDecode(readfile("FishIt_Config.json"))
        for name, value in pairs(data) do
            if features[name] ~= nil then
                features[name] = value
            end
        end
        print("Config Loaded!")
    else
        print("No config file found.")
    end
end

-- ============================================
-- 24. GUI (Lengkap dengan semua fitur)
-- ============================================
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FishItMegaGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 580)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Fish It MEGA v3"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -40)
    scroll.Position = UDim2.new(0, 0, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
    scroll.ScrollBarThickness = 6
    scroll.Parent = frame

    local function makeButton(text, yPos, callback, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 28)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = color or Color3.fromRGB(50, 50, 60)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.Parent = scroll
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local function makeLabel(text, yPos)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 25)
        lbl.Position = UDim2.new(0, 10, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
        lbl.TextScaled = true
        lbl.Font = Enum.Font.GothamBold
        lbl.Parent = scroll
        return lbl
    end

    -- ====== SECTION: AUTOMATION ======
    local y = 5
    makeLabel("=== AUTOMATION ===", y)
    y = y + 30

    local fishBtn = makeButton("Auto Fishing: OFF", y, function()
        if features.autoFish then stopAutoFish() else startAutoFish() end
        fishBtn.Text = "Auto Fishing: " .. (features.autoFish and "ON" or "OFF")
    end)
    y = y + 32

    local fishModeBtn = makeButton("Mode: " .. fishMode, y, function()
        local modes = {"Stable", "Blatant", "Extreme", "Instant"}
        for i, m in pairs(modes) do
            if m == fishMode then
                fishMode = modes[i % #modes + 1]
                break
            end
        end
        fishModeBtn.Text = "Mode: " .. fishMode
        if features.autoFish then
            stopAutoFish()
            startAutoFish()
        end
    end, Color3.fromRGB(40, 40, 80))
    y = y + 32

    local sellBtn = makeButton("Auto Sell: OFF", y, function()
        if features.autoSell then stopAutoSell() else startAutoSell() end
        sellBtn.Text = "Auto Sell: " .. (features.autoSell and "ON" or "OFF")
    end)
    y = y + 32

    local enchantBtn = makeButton("Auto Enchant: OFF", y, function()
        if features.autoEnchant then stopAutoEnchant() else startAutoEnchant() end
        enchantBtn.Text = "Auto Enchant: " .. (features.autoEnchant and "ON" or "OFF")
    end)
    y = y + 32

    local crateBtn = makeButton("Auto Open Crate: OFF", y, function()
        if features.autoOpenCrate then stopAutoOpenCrate() else startAutoOpenCrate() end
        crateBtn.Text = "Auto Open Crate: " .. (features.autoOpenCrate and "ON" or "OFF")
    end)
    y = y + 32

    local equipSkinBtn = makeButton("Auto Equip Skin: OFF", y, function()
        if features.autoEquipSkin then stopAutoEquipSkin() else startAutoEquipSkin() end
        equipSkinBtn.Text = "Auto Equip Skin: " .. (features.autoEquipSkin and "ON" or "OFF")
    end)
    y = y + 32

    local buyBtn = makeButton("Auto Buy: OFF", y, function()
        if features.autoBuy then stopAutoBuy() else startAutoBuy() end
        buyBtn.Text = "Auto Buy: " .. (features.autoBuy and "ON" or "OFF")
    end)
    y = y + 32

    local tradeBtn = makeButton("Auto Trade: OFF", y, function()
        if features.autoTrade then stopAutoTrade() else startAutoTrade() end
        tradeBtn.Text = "Auto Trade: " .. (features.autoTrade and "ON" or "OFF")
    end)
    y = y + 32

    local acceptTradeBtn = makeButton("Auto Accept Trade: OFF", y, function()
        if features.autoAcceptTrade then stopAutoAcceptTrade() else startAutoAcceptTrade() end
        acceptTradeBtn.Text = "Auto Accept Trade: " .. (features.autoAcceptTrade and "ON" or "OFF")
    end)
    y = y + 32

    local totemBtn = makeButton("Auto Totem: OFF", y, function()
        if features.autoTotem then stopAutoTotem() else startAutoTotem() end
        totemBtn.Text = "Auto Totem: " .. (features.autoTotem and "ON" or "OFF")
    end)
    y = y + 32

    local weatherBtn = makeButton("Auto Weather: OFF", y, function()
        if features.autoWeather then stopAutoWeather() else startAutoWeather() end
        weatherBtn.Text = "Auto Weather: " .. (features.autoWeather and "ON" or "OFF")
    end)
    y = y + 32

    local questBtn = makeButton("Auto Quest: OFF", y, function()
        if features.autoQuest then stopAutoQuest() else startAutoQuest() end
        questBtn.Text = "Auto Quest: " .. (features.autoQuest and "ON" or "OFF")
    end)
    y = y + 32

    local artifactBtn = makeButton("Auto Artifact: OFF", y, function()
        if features.autoArtifact then stopAutoArtifact() else startAutoArtifact() end
        artifactBtn.Text = "Auto Artifact: " .. (features.autoArtifact and "ON" or "OFF")
    end)
    y = y + 32

    local eventBtn = makeButton("Auto Event: OFF", y, function()
        if features.autoEvent then stopAutoEvent() else startAutoEvent() end
        eventBtn.Text = "Auto Event: " .. (features.autoEvent and "ON" or "OFF")
    end)
    y = y + 32

    local rejoinBtn = makeButton("Auto Rejoin: OFF", y, function()
        if features.autoRejoin then stopAutoRejoin() else startAutoRejoin() end
        rejoinBtn.Text = "Auto Rejoin: " .. (features.autoRejoin and "ON" or "OFF")
    end)
    y = y + 32

    local hopBtn = makeButton("Auto Server Hop: OFF", y, function()
        if features.autoServerHop then stopAutoServerHop() else startAutoServerHop() end
        hopBtn.Text = "Auto Server Hop: " .. (features.autoServerHop and "ON" or "OFF")
    end)
    y = y + 32

    -- ====== SECTION: UTILITIES ======
    makeLabel("=== UTILITIES ===", y)
    y = y + 30

    local antiAFKBtn = makeButton("Anti-AFK: OFF", y, function()
        if features.antiAFK then 
            features.antiAFK = false
            antiAFKBtn.Text = "Anti-AFK: OFF"
        else 
            startAntiAFK()
            antiAFKBtn.Text = "Anti-AFK: ON"
        end
    end)
    y = y + 32

    local antiDrownBtn = makeButton("Anti-Drown: OFF", y, function()
        if features.antiDrown then 
            features.antiDrown = false
            antiDrownBtn.Text = "Anti-Drown: OFF"
        else 
            startAntiDrown()
            antiDrownBtn.Text = "Anti-Drown: ON"
        end
    end)
    y = y + 32

    local espBtn = makeButton("ESP: OFF", y, function()
        if features.espEnabled then disableESP() else enableESP() end
        espBtn.Text = "ESP: " .. (features.espEnabled and "ON" or "OFF")
    end)
    y = y + 32

    local flyBtn = makeButton("Fly: OFF", y, function()
        toggleFly()
        flyBtn.Text = "Fly: " .. (features.flyEnabled and "ON" or "OFF")
    end)
    y = y + 32

    local noclipBtn = makeButton("Noclip: OFF", y, function()
        toggleNoclip()
        noclipBtn.Text = "Noclip: " .. (features.noclipEnabled and "ON" or "OFF")
    end)
    y = y + 32

    local speedBtn = makeButton("Speed Hack: OFF", y, function()
        toggleSpeedHack()
        speedBtn.Text = "Speed Hack: " .. (features.speedHack and "ON" or "OFF")
    end)
    y = y + 32

    local fpsBtn = makeButton("FPS Boost", y, function()
        toggleFPSBoost()
        fpsBtn.Text = "FPS Boost: ON"
    end)
    y = y + 32

    -- ====== SECTION: TELEPORT ======
    makeLabel("=== TELEPORT ===", y)
    y = y + 30

    for name, pos in pairs(islands) do
        makeButton("TP: " .. name, y, function()
            teleportTo(pos)
        end, Color3.fromRGB(30, 60, 30))
        y = y + 32
    end

    -- ====== SECTION: CONFIG ======
    makeLabel("=== CONFIG ===", y)
    y = y + 30

    makeButton("Save Config", y, saveConfig, Color3.fromRGB(60, 60, 30))
    y = y + 32
    makeButton("Load Config", y, loadConfig, Color3.fromRGB(60, 30, 60))
    y = y + 32

    local closeBtn = makeButton("Close GUI", y, function()
        screenGui:Destroy()
    end, Color3.fromRGB(80, 20, 20))
    y = y + 32

    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end

-- ============================================
-- KEYBINDS
-- ============================================
userInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        if features.autoFish then stopAutoFish() else startAutoFish() end
    elseif input.KeyCode == Enum.KeyCode.F2 then
        teleportTo(CONFIG.TeleportPosition)
    elseif input.KeyCode == Enum.KeyCode.F3 then
        if features.autoOpenCrate then stopAutoOpenCrate() else startAutoOpenCrate() end
    elseif input.KeyCode == Enum.KeyCode.F4 then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        toggleSpeedHack()
    elseif input.KeyCode == Enum.KeyCode.F6 then
        if features.espEnabled then disableESP() else enableESP() end
    end
end)

-- ============================================
-- START
-- ============================================
createGUI()
print("========================================")
print("FISH IT MEGA SCRIPT v3 - ALL FEATURES")
print("========================================")
print("Fitur Lengkap:")
print("- Auto Fishing (4 mode: Stable/Blatant/Extreme/Instant)")
print("- Auto Sell (Filter: All/Legendary/Epic/Rare/Common)")
print("- Auto Enchant, Auto Open Crate, Auto Equip Skin")
print("- Auto Buy, Auto Trade, Auto Accept Trade")
print("- Auto Totem, Auto Weather, Auto Quest")
print("- Auto Artifact, Auto Event, Auto Rejoin, Auto Server Hop")
print("- Anti-AFK, Anti-Drown, ESP, Fly, Noclip, Speed Hack")
print("- Teleport ke semua Island, FPS Boost")
print("- Save/Load Config")
print("========================================")
print("Shortcut:")
print("F1 = Toggle Auto Fishing")
print("F2 = Teleport to Default Spot")
print("F3 = Toggle Auto Open Crate")
print("F4 = Toggle Fly")
print("F5 = Toggle Speed Hack")
print("F6 = Toggle ESP")
print("========================================")