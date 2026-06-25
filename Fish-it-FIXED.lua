-- ============================================
-- 🔒 FISH IT MEGA - FIXED & ENHANCED v4.0
-- ============================================
-- Script diperbaiki dengan auto-detection yang lebih baik
-- ============================================

-- ============================================
-- ANTI-DETECTION LAYER (AWAL) - PERBAIKAN
-- ============================================

local randomDelayValues = {}
local function randomDelay(min, max)
    return math.random(min * 100, max * 100) / 100
end

local function safeWait(time)
    local actual = time + (math.random(-10, 10) / 100)
    task.wait(math.max(0.1, actual))
end

-- ============================================
-- SERVICES INITIALIZATION
-- ============================================
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local ClientCache = {}
local RemoteCache = {}

-- ============================================
-- ADVANCED REMOTE DETECTION SYSTEM
-- ============================================

local function findRemotesByPattern(patterns)
    local found = {}
    local locations = {
        ReplicatedStorage,
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("Events"),
        game:FindFirstChild("ServerStorage"),
    }
    
    for _, location in pairs(locations) do
        if not location then continue end
        for _, obj in pairs(location:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                for _, pattern in pairs(patterns) do
                    if name:find(pattern:lower()) then
                        found[obj.Name] = obj
                        break
                    end
                end
            end
        end
    end
    return found
end

-- Smart Remote Detection
local remotePatterns = {
    fish = {"fish", "cast", "fishing", "reel", "catch", "hook"},
    sell = {"sell", "shop", "trade", "market", "vendor"},
    enchant = {"enchant", "upgrade", "enhance", "boost"},
    crate = {"crate", "box", "chest", "open", "reward"},
    equip = {"equip", "skin", "cosmetic", "wear", "item"},
    buy = {"buy", "purchase", "shop", "merchant"},
    trade = {"trade", "swap", "exchange"},
    accept = {"accept", "confirm", "approve"},
    totem = {"totem", "place", "summon"},
    weather = {"weather", "storm", "climate"},
    quest = {"quest", "mission", "task", "objective"},
    artifact = {"artifact", "ancient", "relic", "treasure"},
    event = {"event", "join", "participate"},
}

local remotes = {}
for key, patterns in pairs(remotePatterns) do
    local detected = findRemotesByPattern(patterns)
    if next(detected) then
        remotes[key] = detected[next(detected)]
    end
end

-- Fallback: Direct access jika auto-detect gagal
if not remotes.fish then
    pcall(function()
        remotes.fish = ReplicatedStorage:WaitForChild("CastLine") or 
                       ReplicatedStorage:WaitForChild("FishEvent")
    end)
end

-- ============================================
-- KONFIGURASI DAN VARIABEL GLOBAL
-- ============================================

local CONFIG = {
    FishingDelay = 3.5,
    SellDelay = 2.5,
    CrateDelay = 2,
    EnchantDelay = 3,
    TotemDelay = 60,
    TradeDelay = 30,
    WeatherDelay = 60,
    TeleportPosition = Vector3.new(0, 5, 0),
    SafeDelayMin = 0.5,
    SafeDelayMax = 1.5,
}

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
    fullbright = false,
    fpsBoost = false,
    autoMultiBait = false,
    autoLootCollector = false,
    autoAreaHop = false,
    friendlyESP = false,
}

local fishMode = "Stable"
local sellFilter = "All"
local weatherTypes = {"Storm", "Cloudy", "Wind", "Snow", "Sunny"}
local questTypes = {"DeepSea", "AuraKid", "ElementJungle"}
local espObjects = {}
local espLines = {}
local SelectedTarget = ""
local targetHighlight = nil

-- ============================================
-- HELPER FUNCTIONS - IMPROVED
-- ============================================

function GetHumanoid()
    if not LocalPlayer or not LocalPlayer.Character then return nil end
    return LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

function GetRootPart()
    if not LocalPlayer or not LocalPlayer.Character then return nil end
    return LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

function TeleportTo(pos)
    local root = GetRootPart()
    if root then
        root.CFrame = CFrame.new(pos)
        return true
    end
    return false
end

function GetPlayerByName(name)
    if not name or name == "" then return nil end
    name = name:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name then
            return p
        end
    end
    return nil
end

function GetPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then 
            table.insert(list, p.Name) 
        end
    end
    if #list == 0 then 
        return {"Tidak ada pemain"} 
    end
    table.sort(list)
    return list
end

function SafeFireRemote(remote, ...)
    if not remote then return false end
    pcall(function()
        safeWait(randomDelay(CONFIG.SafeDelayMin, CONFIG.SafeDelayMax))
        remote:FireServer(...)
    end)
    return true
end

-- ============================================
-- LIBRARY LOAD
-- ============================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mdwpanel/Roblox/refs/heads/main/main_ui_modern.lua"))()

function Notify(title, desc, duration)
    if Library and Library.MakeNotify then
        Library:MakeNotify({Title = title, Content = desc, Duration = duration or 3})
    else
        print("[" .. title .. "] " .. desc)
    end
end

-- ============================================
-- 1. AUTO FISHING - IMPROVED
-- ============================================

local function startAutoFish()
    if features.autoFish then return end
    features.autoFish = true
    Notify("✅ Auto Fishing", "ON (" .. fishMode .. " Mode)", 3)
    
    task.spawn(function()
        while features.autoFish do
            safeWait(randomDelay(0.8, 1.2))
            
            if not features.autoFish then break end
            
            local root = GetRootPart()
            if not root then continue end
            
            -- Deteksi fishing rod
            local char = LocalPlayer.Character
            if not char then continue end
            
            local hasFishingRod = char:FindFirstChild("FishingRod") or 
                                 char:FindFirstChild("Fishing") or
                                 char:FindFirstChildOfClass("Tool")
            
            -- Fire cast remote
            local castRemotes = {remotes.fish, remotes.catch, remotes.reel}
            for _, remote in pairs(castRemotes) do
                if remote then
                    SafeFireRemote(remote)
                    break
                end
            end
            
            -- Mode-specific delays
            local delayTime
            if fishMode == "Stable" then
                delayTime = 4 + randomDelay(-0.5, 0.5)
            elseif fishMode == "Blatant" then
                delayTime = 2.5 + randomDelay(-0.3, 0.3)
            elseif fishMode == "Extreme" then
                delayTime = 1.5 + randomDelay(-0.2, 0.2)
            else
                delayTime = CONFIG.FishingDelay
            end
            
            safeWait(delayTime)
            
            -- Auto reel jika ada
            if features.autoReCast or fishMode == "Instant" then
                for _, remote in pairs({remotes.reel, remotes.catch, remotes.fish}) do
                    if remote and remote.Name:lower():find("reel") then
                        SafeFireRemote(remote)
                        break
                    end
                end
            end
        end
    end)
end

local function stopAutoFish()
    features.autoFish = false
    Notify("❌ Auto Fishing", "OFF", 2)
end

-- ============================================
-- 2. AUTO SELL - IMPROVED
-- ============================================

local function startAutoSell()
    if features.autoSell then return end
    features.autoSell = true
    Notify("✅ Auto Sell", "ON (" .. sellFilter .. ")", 3)
    
    task.spawn(function()
        while features.autoSell do
            safeWait(randomDelay(2, 3))
            
            if not features.autoSell then break end
            
            local sellRemotes = {remotes.sell, remotes.trade, remotes.vendor}
            for _, remote in pairs(sellRemotes) do
                if remote then
                    SafeFireRemote(remote, sellFilter)
                    break
                end
            end
            
            safeWait(CONFIG.SellDelay)
        end
    end)
end

local function stopAutoSell()
    features.autoSell = false
    Notify("❌ Auto Sell", "OFF", 2)
end

-- ============================================
-- 3. AUTO ENCHANT
-- ============================================

local function startAutoEnchant()
    if features.autoEnchant then return end
    features.autoEnchant = true
    Notify("✅ Auto Enchant", "ON", 2)
    
    task.spawn(function()
        while features.autoEnchant do
            safeWait(randomDelay(2.5, 3.5))
            
            if not features.autoEnchant then break end
            
            if remotes.enchant then
                SafeFireRemote(remotes.enchant)
            end
            
            safeWait(CONFIG.EnchantDelay)
        end
    end)
end

local function stopAutoEnchant()
    features.autoEnchant = false
    Notify("❌ Auto Enchant", "OFF", 2)
end

-- ============================================
-- 4. AUTO OPEN CRATE
-- ============================================

local function startAutoOpenCrate()
    if features.autoOpenCrate then return end
    features.autoOpenCrate = true
    Notify("✅ Auto Open Crate", "ON", 2)
    
    task.spawn(function()
        while features.autoOpenCrate do
            safeWait(randomDelay(1.5, 2.5))
            
            if not features.autoOpenCrate then break end
            
            local crateRemotes = {remotes.crate, remotes.box, remotes.chest}
            for _, remote in pairs(crateRemotes) do
                if remote then
                    SafeFireRemote(remote)
                    break
                end
            end
            
            safeWait(CONFIG.CrateDelay)
        end
    end)
end

local function stopAutoOpenCrate()
    features.autoOpenCrate = false
    Notify("❌ Auto Open Crate", "OFF", 2)
end

-- ============================================
-- 5. AUTO EQUIP SKIN
-- ============================================

local function startAutoEquipSkin()
    if features.autoEquipSkin then return end
    features.autoEquipSkin = true
    Notify("✅ Auto Equip Skin", "ON", 2)
    
    task.spawn(function()
        while features.autoEquipSkin do
            safeWait(8 + randomDelay(-1, 1))
            
            if not features.autoEquipSkin then break end
            
            local equipRemotes = {remotes.equip, remotes.skin, remotes.cosmetic}
            for _, remote in pairs(equipRemotes) do
                if remote then
                    SafeFireRemote(remote, "best")
                    break
                end
            end
        end
    end)
end

local function stopAutoEquipSkin()
    features.autoEquipSkin = false
    Notify("❌ Auto Equip Skin", "OFF", 2)
end

-- ============================================
-- 6. AUTO BUY
-- ============================================

local function startAutoBuy()
    if features.autoBuy then return end
    features.autoBuy = true
    Notify("✅ Auto Buy", "ON", 2)
    
    task.spawn(function()
        while features.autoBuy do
            safeWait(15 + randomDelay(-2, 2))
            
            if not features.autoBuy then break end
            
            local buyRemotes = {remotes.buy, remotes.purchase, remotes.shop}
            for _, remote in pairs(buyRemotes) do
                if remote then
                    SafeFireRemote(remote, "best")
                    safeWait(1)
                    SafeFireRemote(remote, "bait")
                    break
                end
            end
        end
    end)
end

local function stopAutoBuy()
    features.autoBuy = false
    Notify("❌ Auto Buy", "OFF", 2)
end

-- ============================================
-- 7. AUTO MULTI-BAIT (FITUR BARU)
-- ============================================

local function startAutoMultiBait()
    if features.autoMultiBait then return end
    features.autoMultiBait = true
    Notify("✅ Auto Multi-Bait", "ON", 2)
    
    task.spawn(function()
        local baits = {"Bread", "Worms", "Shrimp", "Flies", "Premium"}
        local baitIndex = 1
        
        while features.autoMultiBait do
            safeWait(20 + randomDelay(-3, 3))
            
            if not features.autoMultiBait then break end
            
            if remotes.buy then
                SafeFireRemote(remotes.buy, baits[baitIndex])
                baitIndex = baitIndex % #baits + 1
            end
        end
    end)
end

local function stopAutoMultiBait()
    features.autoMultiBait = false
    Notify("❌ Auto Multi-Bait", "OFF", 2)
end

-- ============================================
-- 8. AUTO LOOT COLLECTOR (FITUR BARU)
-- ============================================

local function startAutoLootCollector()
    if features.autoLootCollector then return end
    features.autoLootCollector = true
    Notify("✅ Auto Loot Collector", "ON", 2)
    
    task.spawn(function()
        while features.autoLootCollector do
            safeWait(2)
            
            if not features.autoLootCollector then break end
            
            local root = GetRootPart()
            if not root then continue end
            
            -- Cari loot items di sekitar pemain
            for _, item in pairs(Workspace:GetChildren()) do
                if item:IsA("Model") or item:IsA("BasePart") then
                    local itemName = item.Name:lower()
                    if itemName:find("drop") or itemName:find("loot") or itemName:find("reward") then
                        local dist = (root.Position - item.Position).Magnitude
                        if dist < 50 then
                            root.CFrame = item.CFrame + Vector3.new(0, 3, 0)
                            safeWait(0.5)
                        end
                    end
                end
            end
        end
    end)
end

local function stopAutoLootCollector()
    features.autoLootCollector = false
    Notify("❌ Auto Loot Collector", "OFF", 2)
end

-- ============================================
-- 9. AUTO AREA HOP (FITUR BARU)
-- ============================================

local areas = {
    {name = "Spawn", pos = Vector3.new(0, 5, 0)},
    {name = "Coral Island", pos = Vector3.new(100, 5, 50)},
    {name = "Mermaid Lagoon", pos = Vector3.new(-80, 5, 120)},
    {name = "Deep Sea", pos = Vector3.new(-150, 5, -80)},
    {name = "Sky Islands", pos = Vector3.new(200, 100, -100)},
    {name = "Volcano Area", pos = Vector3.new(-200, 50, 200)},
}

local function startAutoAreaHop()
    if features.autoAreaHop then return end
    features.autoAreaHop = true
    Notify("✅ Auto Area Hop", "ON", 2)
    
    task.spawn(function()
        local areaIndex = 1
        while features.autoAreaHop do
            safeWait(45 + randomDelay(-5, 5))
            
            if not features.autoAreaHop then break end
            
            local area = areas[areaIndex]
            TeleportTo(area.pos)
            Notify("🏝️ Area Hop", "Ke " .. area.name, 2)
            
            areaIndex = areaIndex % #areas + 1
            safeWait(3)
        end
    end)
end

local function stopAutoAreaHop()
    features.autoAreaHop = false
    Notify("❌ Auto Area Hop", "OFF", 2)
end

-- ============================================
-- 10. AUTO TRADE & ACCEPT
-- ============================================

local function startAutoTrade()
    if features.autoTrade then return end
    features.autoTrade = true
    Notify("✅ Auto Trade", "ON", 2)
    
    task.spawn(function()
        while features.autoTrade do
            safeWait(45 + randomDelay(-5, 5))
            
            if not features.autoTrade then break end
            
            if remotes.trade then
                SafeFireRemote(remotes.trade)
            end
        end
    end)
end

local function stopAutoTrade()
    features.autoTrade = false
    Notify("❌ Auto Trade", "OFF", 2)
end

local function startAutoAcceptTrade()
    if features.autoAcceptTrade then return end
    features.autoAcceptTrade = true
    Notify("✅ Auto Accept Trade", "ON", 2)
    
    if remotes.accept then
        pcall(function()
            remotes.accept.OnClientEvent:Connect(function()
                if features.autoAcceptTrade then
                    safeWait(randomDelay(2, 4))
                    SafeFireRemote(remotes.accept)
                end
            end)
        end)
    end
end

local function stopAutoAcceptTrade()
    features.autoAcceptTrade = false
    Notify("❌ Auto Accept Trade", "OFF", 2)
end

-- ============================================
-- 11. AUTO TOTEM
-- ============================================

local function startAutoTotem()
    if features.autoTotem then return end
    features.autoTotem = true
    Notify("✅ Auto Totem", "ON", 2)
    
    task.spawn(function()
        while features.autoTotem do
            safeWait(60 + randomDelay(-10, 10))
            
            if not features.autoTotem then break end
            
            if remotes.totem then
                SafeFireRemote(remotes.totem)
            end
        end
    end)
end

local function stopAutoTotem()
    features.autoTotem = false
    Notify("❌ Auto Totem", "OFF", 2)
end

-- ============================================
-- 12. AUTO WEATHER
-- ============================================

local function startAutoWeather()
    if features.autoWeather then return end
    features.autoWeather = true
    Notify("✅ Auto Weather", "ON", 2)
    
    task.spawn(function()
        local idx = 1
        while features.autoWeather do
            safeWait(60 + randomDelay(-10, 10))
            
            if not features.autoWeather then break end
            
            if remotes.weather then
                SafeFireRemote(remotes.weather, weatherTypes[idx])
                idx = idx % #weatherTypes + 1
            end
        end
    end)
end

local function stopAutoWeather()
    features.autoWeather = false
    Notify("❌ Auto Weather", "OFF", 2)
end

-- ============================================
-- 13. AUTO QUEST
-- ============================================

local function startAutoQuest()
    if features.autoQuest then return end
    features.autoQuest = true
    Notify("✅ Auto Quest", "ON", 2)
    
    task.spawn(function()
        while features.autoQuest do
            for _, quest in pairs(questTypes) do
                if not features.autoQuest then break end
                safeWait(5 + randomDelay(-1, 1))
                
                if remotes.quest then
                    SafeFireRemote(remotes.quest, quest)
                end
            end
            safeWait(15 + randomDelay(-3, 3))
        end
    end)
end

local function stopAutoQuest()
    features.autoQuest = false
    Notify("❌ Auto Quest", "OFF", 2)
end

-- ============================================
-- 14. AUTO ARTIFACT
-- ============================================

local function startAutoArtifact()
    if features.autoArtifact then return end
    features.autoArtifact = true
    Notify("✅ Auto Artifact", "ON", 2)
    
    task.spawn(function()
        while features.autoArtifact do
            safeWait(8 + randomDelay(-1, 1))
            
            if not features.autoArtifact then break end
            
            if remotes.artifact then
                SafeFireRemote(remotes.artifact)
            end
        end
    end)
end

local function stopAutoArtifact()
    features.autoArtifact = false
    Notify("❌ Auto Artifact", "OFF", 2)
end

-- ============================================
-- 15. AUTO EVENT
-- ============================================

local function startAutoEvent()
    if features.autoEvent then return end
    features.autoEvent = true
    Notify("✅ Auto Event", "ON", 2)
    
    task.spawn(function()
        while features.autoEvent do
            safeWait(45 + randomDelay(-10, 10))
            
            if not features.autoEvent then break end
            
            if remotes.event then
                SafeFireRemote(remotes.event)
            end
        end
    end)
end

local function stopAutoEvent()
    features.autoEvent = false
    Notify("❌ Auto Event", "OFF", 2)
end

-- ============================================
-- 16. AUTO REJOIN & SERVER HOP
-- ============================================

local function startAutoRejoin()
    if features.autoRejoin then return end
    features.autoRejoin = true
    Notify("✅ Auto Rejoin", "ON", 2)
    
    pcall(function()
        LocalPlayer.OnTeleport:Connect(function(state)
            if features.autoRejoin and state == Enum.TeleportState.Failed then
                safeWait(10)
                TeleportService:Teleport(game.PlaceId)
            end
        end)
    end)
end

local function stopAutoRejoin()
    features.autoRejoin = false
    Notify("❌ Auto Rejoin", "OFF", 2)
end

local function startAutoServerHop()
    if features.autoServerHop then return end
    features.autoServerHop = true
    Notify("✅ Auto Server Hop", "ON (Every 15 min)", 2)
    
    task.spawn(function()
        while features.autoServerHop do
            safeWait(900 + randomDelay(-60, 60))
            if features.autoServerHop then
                TeleportService:Teleport(game.PlaceId)
            end
        end
    end)
end

local function stopAutoServerHop()
    features.autoServerHop = false
    Notify("❌ Auto Server Hop", "OFF", 2)
end

-- ============================================
-- 17. ANTI-AFK (SAFE)
-- ============================================

local function startAntiAFK()
    if features.antiAFK then return end
    features.antiAFK = true
    Notify("✅ Anti-AFK", "ON", 2)
    
    task.spawn(function()
        while features.antiAFK do
            safeWait(60 + randomDelay(-10, 10))
            
            if not features.antiAFK then break end
            
            pcall(function()
                local hum = GetHumanoid()
                if hum then
                    hum:Move(Vector3.new(0.1, 0, 0.1), true)
                    safeWait(0.2)
                    hum:Move(Vector3.new(-0.1, 0, -0.1), true)
                end
            end)
        end
    end)
end

local function stopAntiAFK()
    features.antiAFK = false
    Notify("❌ Anti-AFK", "OFF", 2)
end

-- ============================================
-- 18. ANTI-DROWN
-- ============================================

local function startAntiDrown()
    if features.antiDrown then return end
    features.antiDrown = true
    Notify("✅ Anti-Drown", "ON", 2)
    
    task.spawn(function()
        while features.antiDrown do
            safeWait(0.5)
            
            if not features.antiDrown then break end
            
            local hum = GetHumanoid()
            if hum and hum:GetState() == Enum.HumanoidStateType.Swimming then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function stopAntiDrown()
    features.antiDrown = false
    Notify("❌ Anti-Drown", "OFF", 2)
end

-- ============================================
-- 19. ESP SYSTEM
-- ============================================

function ClearESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
end

local function enableESP()
    features.espEnabled = true
    Notify("✅ ESP", "ON", 2)
    ClearESP()
    
    local function addESP(player)
        if player == LocalPlayer then return end
        if not player.Character then return end
        
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local myRoot = GetRootPart()
        if not myRoot then return end
        
        local dist = (myRoot.Position - root.Position).Magnitude
        if dist > 200 then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Adornee = player.Character
        highlight.FillColor = Color3.fromRGB(255, 50, 50)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Parent = player.Character
        table.insert(espObjects, highlight)
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        addESP(player)
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            safeWait(0.5)
            if features.espEnabled then
                addESP(player)
            end
        end)
    end)
end

local function disableESP()
    features.espEnabled = false
    ClearESP()
    Notify("❌ ESP", "OFF", 2)
end

-- ============================================
-- 20. FRIENDLY ESP (FITUR BARU)
-- ============================================

local function enableFriendlyESP()
    features.friendlyESP = true
    Notify("✅ Friendly ESP", "ON", 2)
    
    task.spawn(function()
        while features.friendlyESP do
            safeWait(1)
            
            for _, player in pairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                if not player.Character then continue end
                
                local existing = player.Character:FindFirstChild("FriendlyESP")
                if not existing then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "FriendlyESP"
                    billboard.Size = UDim2.new(4, 0, 2, 0)
                    billboard.MaxDistance = 100
                    
                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 0
                    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    textLabel.Text = player.Name .. " [" .. player.Character.Humanoid.Health .. "HP]"
                    textLabel.TextScaled = true
                    textLabel.Parent = billboard
                    
                    billboard.Parent = player.Character.Head
                end
            end
        end
    end)
end

local function disableFriendlyESP()
    features.friendlyESP = false
    Notify("❌ Friendly ESP", "OFF", 2)
end

-- ============================================
-- 21. FLY SYSTEM
-- ============================================

local flyConnections = {}

function CleanupFly()
    for _, conn in pairs(flyConnections) do
        pcall(function() conn:Disconnect() end)
    end
    flyConnections = {}
    
    local root = GetRootPart()
    if root then
        if root:FindFirstChild("FlyVel") then root.FlyVel:Destroy() end
        if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
    end
    
    local hum = GetHumanoid()
    if hum then hum.PlatformStand = false end
end

local function startFly()
    local root = GetRootPart()
    local hum = GetHumanoid()
    if not root or not hum then return end

    CleanupFly()

    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.Name = "FlyVel"
    bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVel.Velocity = Vector3.new(0, 0, 0)
    bodyVel.Parent = root

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "FlyGyro"
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 9e4
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    hum.PlatformStand = true
    
    local speed = 50
    
    local conn = RunService.RenderStepped:Connect(function()
        if not features.flyEnabled or not root or not root.Parent or not hum then
            CleanupFly()
            return
        end
        
        local cam = Workspace.CurrentCamera
        local moveVec = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
        
        local yVel = 0
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then yVel = speed
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then yVel = -speed end

        if moveVec.Magnitude > 0 then
            bodyVel.Velocity = (moveVel.Unit * speed) + Vector3.new(0, yVel, 0)
        else
            bodyVel.Velocity = Vector3.new(0, yVel, 0)
        end
        
        bodyGyro.CFrame = cam.CFrame
    end)
    
    table.insert(flyConnections, conn)
    Notify("✅ Fly", "ON (WASD + Space/Shift)", 2)
end

local function toggleFly()
    features.flyEnabled = not features.flyEnabled
    if features.flyEnabled then
        startFly()
    else
        CleanupFly()
        Notify("❌ Fly", "OFF", 2)
    end
end

-- ============================================
-- 22. NOCLIP
-- ============================================

local function toggleNoclip()
    features.noclipEnabled = not features.noclipEnabled
    Notify(features.noclipEnabled and "✅ Noclip" or "❌ Noclip", features.noclipEnabled and "ON" or "OFF", 2)
    
    if features.noclipEnabled then
        local conn = RunService.RenderStepped:Connect(function()
            if features.noclipEnabled and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        table.insert(flyConnections, conn)
    end
end

-- ============================================
-- 23. SPEED HACK
-- ============================================

local function toggleSpeedHack()
    features.speedHack = not features.speedHack
    
    if features.speedHack then
        Notify("✅ Speed Hack", "ON (35 Walk)", 2)
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = 35
            hum.JumpPower = 70
        end
    else
        Notify("❌ Speed Hack", "OFF", 2)
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end
end

-- ============================================
-- 24. FULLBRIGHT & FPS BOOST
-- ============================================

local function toggleFullbright()
    features.fullbright = not features.fullbright
    
    if features.fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Notify("✅ Fullbright", "ON", 2)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        Notify("❌ Fullbright", "OFF", 2)
    end
end

local function toggleFPSBoost()
    features.fpsBoost = not features.fpsBoost
    
    if features.fpsBoost then
        Lighting.GlobalShadows = false
        Lighting.Technology = Enum.Technology.Legacy
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Part") then
                v.Material = Enum.Material.Plastic
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                pcall(function() v:Destroy() end)
            end
        end
        settings().Rendering.QualityLevel = 1
        Notify("✅ FPS Boost", "ON", 2)
    else
        Lighting.GlobalShadows = true
        Lighting.Technology = Enum.Technology.Future
        settings().Rendering.QualityLevel = 4
        Notify("❌ FPS Boost", "OFF", 2)
    end
end

-- ============================================
-- 25. TELEPORT SYSTEM
-- ============================================

local teleportPlaces = {
    ["Spawn"] = Vector3.new(0, 5, 0),
    ["Coral Island"] = Vector3.new(100, 5, 50),
    ["Mermaid Lagoon"] = Vector3.new(-80, 5, 120),
    ["Retro Island"] = Vector3.new(200, 5, -100),
    ["Esoteric Depths"] = Vector3.new(-150, 5, -80),
    ["Event Island"] = Vector3.new(50, 5, -150),
    ["Sky Peak"] = Vector3.new(0, 150, 0),
    ["Underground"] = Vector3.new(0, -50, 0),
}

local function teleportToPlayer(target)
    if not target or target == "" then
        Notify("❌ Error", "Pilih pemain dulu!", 2)
        return
    end
    
    local player = GetPlayerByName(target)
    if not player or not player.Character then
        Notify("❌ Error", "Pemain tidak ditemukan!", 2)
        return
    end
    
    local root = GetRootPart()
    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
    
    if root and targetRoot then
        root.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
        Notify("✅ Teleport", "Ke " .. player.Name, 2)
    end
end

-- ============================================
-- 26. CONFIG SAVE/LOAD
-- ============================================

local function saveConfig()
    local config = {}
    for name, value in pairs(features) do
        config[name] = value
    end
    config.fishMode = fishMode
    config.sellFilter = sellFilter
    
    pcall(function()
        writefile("FishIt_Config.json", HttpService:JSONEncode(config))
        Notify("💾 Config", "Saved!", 2)
    end)
end

local function loadConfig()
    pcall(function()
        if isfile("FishIt_Config.json") then
            local data = HttpService:JSONDecode(readfile("FishIt_Config.json"))
            for name, value in pairs(data) do
                if features[name] ~= nil then
                    features[name] = value
                end
            end
            if data.fishMode then fishMode = data.fishMode end
            if data.sellFilter then sellFilter = data.sellFilter end
            Notify("📂 Config", "Loaded!", 2)
        end
    end)
end

-- ============================================
-- UI WINDOW CREATION
-- ============================================

local Window = Library:Window({
    Title = "🐟 FISH IT MEGA v4.0",
    Footer = "FIXED & ENHANCED | Safe Mode"
})

-- ============================================
-- TAB 1: AUTO FARMING
-- ============================================

local AutoFarmTab = Window:AddTab({ Name = "🎣 Auto Farm", Icon = "robot" })

local FishSection = AutoFarmTab:AddSection("🎯 Fishing Control")

FishSection:AddToggle({
    Title = "Auto Fishing",
    Description = "Mancing otomatis dengan delay aman",
    Default = false,
    Callback = function(v)
        if v then startAutoFish() else stopAutoFish() end
    end
})

FishSection:AddDropdown({
    Title = "Fishing Mode",
    Options = {"Stable", "Blatant", "Extreme", "Instant"},
    Default = "Stable",
    Callback = function(v) fishMode = v end
})

FishSection:AddToggle({
    Title = "Auto Re-Cast",
    Default = false,
    Callback = function(v) features.autoReCast = v end
})

local SellSection = AutoFarmTab:AddSection("💰 Sell System")

SellSection:AddToggle({
    Title = "Auto Sell",
    Description = "Jual ikan otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoSell() else stopAutoSell() end
    end
})

SellSection:AddDropdown({
    Title = "Sell Filter",
    Options = {"All", "Legendary", "Epic", "Rare", "Common"},
    Default = "All",
    Callback = function(v) sellFilter = v end
})

local SystemSection = AutoFarmTab:AddSection("⚙️ Auto Systems")

local autoSystemsOptions = {
    {name = "Auto Enchant", start = startAutoEnchant, stop = stopAutoEnchant},
    {name = "Auto Open Crate", start = startAutoOpenCrate, stop = stopAutoOpenCrate},
    {name = "Auto Equip Skin", start = startAutoEquipSkin, stop = stopAutoEquipSkin},
    {name = "Auto Buy", start = startAutoBuy, stop = stopAutoBuy},
    {name = "Auto Multi-Bait", start = startAutoMultiBait, stop = stopAutoMultiBait},
    {name = "Auto Loot Collector", start = startAutoLootCollector, stop = stopAutoLootCollector},
    {name = "Auto Area Hop", start = startAutoAreaHop, stop = stopAutoAreaHop},
    {name = "Auto Trade", start = startAutoTrade, stop = stopAutoTrade},
    {name = "Auto Accept Trade", start = startAutoAcceptTrade, stop = stopAutoAcceptTrade},
    {name = "Auto Totem", start = startAutoTotem, stop = stopAutoTotem},
    {name = "Auto Weather", start = startAutoWeather, stop = stopAutoWeather},
    {name = "Auto Quest", start = startAutoQuest, stop = stopAutoQuest},
    {name = "Auto Artifact", start = startAutoArtifact, stop = stopAutoArtifact},
    {name = "Auto Event", start = startAutoEvent, stop = stopAutoEvent},
}

for _, system in pairs(autoSystemsOptions) do
    SystemSection:AddToggle({
        Title = system.name,
        Default = false,
        Callback = function(v)
            if v then system.start() else system.stop() end
        end
    })
end

local MaintenanceSection = AutoFarmTab:AddSection("🔄 Maintenance")

MaintenanceSection:AddToggle({
    Title = "Auto Rejoin",
    Default = false,
    Callback = function(v)
        if v then startAutoRejoin() else stopAutoRejoin() end
    end
})

MaintenanceSection:AddToggle({
    Title = "Auto Server Hop",
    Description = "Setiap 15 menit",
    Default = false,
    Callback = function(v)
        if v then startAutoServerHop() else stopAutoServerHop() end
    end
})

-- ============================================
-- TAB 2: UTILITIES
-- ============================================

local UtilTab = Window:AddTab({ Name = "🛠️ Utilities", Icon = "tools" })

local ProtectSection = UtilTab:AddSection("🛡️ Protection")

ProtectSection:AddToggle({
    Title = "Anti-AFK",
    Description = "Gerakan halus, tidak terdeteksi",
    Default = false,
    Callback = function(v)
        if v then startAntiAFK() else stopAntiAFK() end
    end
})

ProtectSection:AddToggle({
    Title = "Anti-Drown",
    Default = false,
    Callback = function(v)
        if v then startAntiDrown() else stopAntiDrown() end
    end
})

local MovementSection = UtilTab:AddSection("🏃 Movement")

MovementSection:AddToggle({
    Title = "Fly Mode",
    Description = "WASD + Space/Shift",
    Default = false,
    Callback = function(v)
        if v then
            features.flyEnabled = true
            startFly()
        else
            features.flyEnabled = false
            CleanupFly()
        end
    end
})

MovementSection:AddToggle({
    Title = "Noclip",
    Default = false,
    Callback = function(v) toggleNoclip() end
})

MovementSection:AddToggle({
    Title = "Speed Hack",
    Description = "Walk Speed 35",
    Default = false,
    Callback = function(v) toggleSpeedHack() end
})

MovementSection:AddInput({
    Title = "Custom Walk Speed",
    Default = "16",
    Callback = function(v)
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = tonumber(v) or 16 end
    end
})

MovementSection:AddInput({
    Title = "Custom Jump Power",
    Default = "50",
    Callback = function(v)
        local hum = GetHumanoid()
        if hum then hum.JumpPower = tonumber(v) or 50 end
    end
})

local ESPSection = UtilTab:AddSection("👁️ ESP System")

ESPSection:AddToggle({
    Title = "Player ESP",
    Description = "Jarak max 200 studs",
    Default = false,
    Callback = function(v)
        if v then enableESP() else disableESP() end
    end
})

ESPSection:AddToggle({
    Title = "Friendly ESP",
    Description = "Tampilkan nama & HP pemain",
    Default = false,
    Callback = function(v)
        if v then enableFriendlyESP() else disableFriendlyESP() end
    end
})

local VisualSection = UtilTab:AddSection("🎨 Visual")

VisualSection:AddToggle({
    Title = "Fullbright",
    Default = false,
    Callback = function(v) toggleFullbright() end
})

VisualSection:AddToggle({
    Title = "FPS Boost",
    Default = false,
    Callback = function(v) toggleFPSBoost() end
})

-- ============================================
-- TAB 3: TELEPORT
-- ============================================

local TeleportTab = Window:AddTab({ Name = "🗺️ Teleport", Icon = "map" })

local PlacesSection = TeleportTab:AddSection("🏝️ Teleport to Places")

for name, pos in pairs(teleportPlaces) do
    PlacesSection:AddButton({
        Title = "TP: " .. name,
        Callback = function()
            TeleportTo(pos)
            Notify("✅ Teleport", "Ke " .. name, 2)
        end
    })
end

local PlayerTPSection = TeleportTab:AddSection("👤 Teleport to Player")

PlayerTPSection:AddDropdown({
    Title = "Pilih Pemain",
    Options = GetPlayerList(),
    Default = "",
    Callback = function(v) SelectedTarget = v end
})

PlayerTPSection:AddButton({
    Title = "🚀 Teleport",
    Callback = function() teleportToPlayer(SelectedTarget) end
})

PlayerTPSection:AddButton({
    Title = "🔄 Refresh",
    Callback = function() UpdateDropdown() end
})

-- ============================================
-- TAB 4: CONFIG
-- ============================================

local ConfigTab = Window:AddTab({ Name = "⚙️ Settings", Icon = "settings" })

local SaveSection = ConfigTab:AddSection("💾 Config")

SaveSection:AddButton({
    Title = "💾 Save Config",
    Callback = function() saveConfig() end
})

SaveSection:AddButton({
    Title = "📂 Load Config",
    Callback = function() loadConfig() end
})

local ResetSection = ConfigTab:AddSection("🔄 Reset")

ResetSection:AddButton({
    Title = "Reset Character",
    Callback = function()
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.Health = 0
        end
        Notify("✅ Reset", "Character respawned!", 2)
    end
})

ResetSection:AddButton({
    Title = "Reset Movement",
    Callback = function()
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        features.flyEnabled = false
        CleanupFly()
        Notify("✅ Reset", "Movement reset!", 2)
    end
})

local ExitSection = ConfigTab:AddSection("❌ Exit")

ExitSection:AddButton({
    Title = "Stop All",
    Description = "Matikan semua fitur",
    Callback = function()
        for name, _ in pairs(features) do
            features[name] = false
        end
        ClearESP()
        CleanupFly()
        Notify("✅ Stopped", "Semua fitur OFF!", 2)
    end
})

ExitSection:AddButton({
    Title = "Destroy UI",
    Callback = function()
        for name, _ in pairs(features) do
            features[name] = false
        end
        ClearESP()
        CleanupFly()
        task.wait(1)
        Window:Destroy()
    end
})

-- ============================================
-- KEYBINDS
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        if features.autoFish then stopAutoFish() else startAutoFish() end
    elseif input.KeyCode == Enum.KeyCode.F2 then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.F3 then
        if features.espEnabled then disableESP() else enableESP() end
    elseif input.KeyCode == Enum.KeyCode.F4 then
        toggleSpeedHack()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        toggleFullbright()
    elseif input.KeyCode == Enum.KeyCode.F6 then
        if features.autoSell then stopAutoSell() else startAutoSell() end
    end
end)

-- ============================================
-- AUTO UPDATER
-- ============================================

local function UpdatePlayerList()
    local list = GetPlayerList()
    -- Update dropdown jika ada
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- ============================================
-- INITIALIZE & START
-- ============================================

Window:Initialize()

Notify("🐟 FISH IT MEGA", "v4.0 FIXED & ENHANCED - Loaded!", 5)

print("╔════════════════════════════════════════╗")
print("║   FISH IT MEGA v4.0 - FIXED VERSION   ║")
print("║         Safe Mode Activated           ║")
print("╚════════════════════════════════════════╝")
print("✅ Auto-Detection: ACTIVE")
print("✅ Remote Finding: OPTIMIZED")
print("✅ Anti-Detection: ENABLED")
print("✅ Safe Delays: RANDOMIZED")
print("")
print("🎣 FITUR FARMING:")
print("   • Auto Fishing (4 Mode)")
print("   • Auto Sell (Filter)")
print("   • Auto Enchant")
print("   • Auto Crate")
print("   • Auto Equip Skin")
print("   • Auto Buy")
print("   • Auto Multi-Bait ⭐ NEW")
print("   • Auto Loot Collector ⭐ NEW")
print("   • Auto Area Hop ⭐ NEW")
print("   • Auto Trade")
print("   • Auto Totem")
print("   • Auto Weather")
print("   • Auto Quest")
print("   • Auto Artifact")
print("   • Auto Event")
print("")
print("🛡️ FITUR PROTECTION:")
print("   • Anti-AFK (Safe)")
print("   • Anti-Drown")
print("   • Auto Rejoin")
print("   • Auto Server Hop")
print("")
print("🚀 FITUR MOVEMENT:")
print("   • Fly Mode")
print("   • Noclip")
print("   • Speed Hack")
print("   • Teleport System")
print("")
print("👁️ FITUR VISUAL:")
print("   • Player ESP")
print("   • Friendly ESP ⭐ NEW")
print("   • Fullbright")
print("   • FPS Boost")
print("")
print("⌨️ KEYBINDS:")
print("   F1 = Auto Fishing")
print("   F2 = Fly")
print("   F3 = ESP")
print("   F4 = Speed")
print("   F5 = Fullbright")
print("   F6 = Auto Sell")
print("")
print("╔════════════════════════════════════════╗")
print("║   Ready for farming! Happy fishing! 🎣 ║")
print("╚════════════════════════════════════════╝")
