-- ============================================
-- SCRIPT FISH IT - MEGA FULL FEATURES
-- ============================================
-- Menggunakan Library MDW Panel
-- Gabungan fitur dari berbagai sumber
-- ============================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mdwpanel/Roblox/refs/heads/main/main_ui_modern.lua"))()

-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

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
    TradeDelay = 30,
    WeatherDelay = 60,
}

-- ============================================
-- FUNGSI FIND REMOTE
-- ============================================
local function findRemote(namePattern)
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find(namePattern:lower()) then
            return obj
        end
    end
    return nil
end

-- Auto-detect remotes
local remotes = {
    fish = findRemote("Fishing") or findRemote("Cast") or findRemote("Fish"),
    reel = findRemote("Reel") or findRemote("Catch") or findRemote("ReelFish"),
    sell = findRemote("Sell") or findRemote("Shop") or findRemote("SellFish"),
    enchant = findRemote("Enchant") or findRemote("EnchantRod"),
    crate = findRemote("Crate") or findRemote("OpenCrate"),
    equipSkin = findRemote("Equip") or findRemote("Skin") or findRemote("EquipSkin"),
    buy = findRemote("Buy") or findRemote("Purchase") or findRemote("BuyItem"),
    trade = findRemote("Trade") or findRemote("TradeRequest"),
    acceptTrade = findRemote("Accept") or findRemote("AcceptTrade"),
    totem = findRemote("Totem") or findRemote("PlaceTotem"),
    weather = findRemote("Weather") or findRemote("BuyWeather"),
    quest = findRemote("Quest") or findRemote("CompleteQuest"),
    artifact = findRemote("Artifact") or findRemote("CollectArtifact"),
    event = findRemote("Event") or findRemote("JoinEvent"),
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
    teleportToPlayer = false,
}

local fishMode = "Stable" -- Stable, Blatant, Extreme, Instant
local sellFilter = "All" -- All, Legendary, Epic, Rare, Common
local weatherTypes = {"Storm", "Cloudy", "Wind", "Snow"}
local questTypes = {"DeepSea", "AuraKid", "ElementJungle"}
local espObjects = {}
local espLines = {}
local flyConnections = {}
local SelectedTarget = ""

-- ============================================
-- HELPER FUNCTIONS
-- ============================================
function GetHumanoid()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

function GetRootPart()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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
    name = name:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name then
            return p
        end
    end
    return nil
end

function GetAllPlayers()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    if #list == 0 then table.insert(list, "No Players") end
    return list
end

function Notify(title, desc, duration)
    Library:MakeNotify({Title = title, Content = desc, Duration = duration or 3})
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

function UpdateDropdown()
    local currentPlayers = GetPlayerList()
    if PlayerDropdown and PlayerDropdown.SetValues then
        PlayerDropdown:SetValues(currentPlayers)
    end
end

-- ============================================
-- 1. AUTO FISHING
-- ============================================
local function startAutoFish()
    features.autoFish = true
    Notify("Auto Fishing", "ON (" .. fishMode .. " Mode)", 2)
    task.spawn(function()
        while features.autoFish do
            task.wait(0.5)
            local char = LocalPlayer.Character
            if not char then continue end
            
            -- Cek apakah sedang fishing
            local fishingPart = char:FindFirstChild("Fishing") or char:FindFirstChild("FishingRod")
            if not fishingPart then
                if remotes.fish then
                    pcall(function() remotes.fish:FireServer() end)
                    if fishMode == "Instant" then
                        task.wait(0.2)
                        if remotes.reel then
                            pcall(function() remotes.reel:FireServer() end)
                        end
                    end
                end
            else
                -- Jika sudah fishing, reel
                if remotes.reel then
                    pcall(function() remotes.reel:FireServer() end)
                end
            end
            
            local delay = fishMode == "Extreme" and 0.3 or fishMode == "Instant" and 0.1 or CONFIG.FishingDelay
            task.wait(delay)
            
            if features.autoReCast then
                task.wait(0.3)
            end
        end
    end)
end

local function stopAutoFish()
    features.autoFish = false
    Notify("Auto Fishing", "OFF", 2)
end

-- ============================================
-- 2. AUTO SELL
-- ============================================
local function startAutoSell()
    features.autoSell = true
    Notify("Auto Sell", "ON (" .. sellFilter .. ")", 2)
    task.spawn(function()
        while features.autoSell do
            if remotes.sell then
                pcall(function() remotes.sell:FireServer(sellFilter) end)
            end
            task.wait(CONFIG.SellDelay)
        end
    end)
end

local function stopAutoSell()
    features.autoSell = false
    Notify("Auto Sell", "OFF", 2)
end

-- ============================================
-- 3. AUTO ENCHANT
-- ============================================
local function startAutoEnchant()
    features.autoEnchant = true
    Notify("Auto Enchant", "ON", 2)
    task.spawn(function()
        while features.autoEnchant do
            if remotes.enchant then
                pcall(function() remotes.enchant:FireServer() end)
            end
            task.wait(CONFIG.EnchantDelay)
        end
    end)
end

local function stopAutoEnchant()
    features.autoEnchant = false
    Notify("Auto Enchant", "OFF", 2)
end

-- ============================================
-- 4. AUTO OPEN CRATE
-- ============================================
local function startAutoOpenCrate()
    features.autoOpenCrate = true
    Notify("Auto Open Crate", "ON", 2)
    task.spawn(function()
        while features.autoOpenCrate do
            if remotes.crate then
                pcall(function() remotes.crate:FireServer() end)
            end
            task.wait(CONFIG.CrateDelay)
        end
    end)
end

local function stopAutoOpenCrate()
    features.autoOpenCrate = false
    Notify("Auto Open Crate", "OFF", 2)
end

-- ============================================
-- 5. AUTO EQUIP SKIN
-- ============================================
local function startAutoEquipSkin()
    features.autoEquipSkin = true
    Notify("Auto Equip Skin", "ON", 2)
    task.spawn(function()
        while features.autoEquipSkin do
            if remotes.equipSkin then
                pcall(function() remotes.equipSkin:FireServer("best") end)
            end
            task.wait(5)
        end
    end)
end

local function stopAutoEquipSkin()
    features.autoEquipSkin = false
    Notify("Auto Equip Skin", "OFF", 2)
end

-- ============================================
-- 6. AUTO BUY
-- ============================================
local function startAutoBuy()
    features.autoBuy = true
    Notify("Auto Buy", "ON", 2)
    task.spawn(function()
        while features.autoBuy do
            if remotes.buy then
                pcall(function() remotes.buy:FireServer("best") end)
                task.wait(3)
                pcall(function() remotes.buy:FireServer("bait") end)
            end
            task.wait(10)
        end
    end)
end

local function stopAutoBuy()
    features.autoBuy = false
    Notify("Auto Buy", "OFF", 2)
end

-- ============================================
-- 7. AUTO TRADE
-- ============================================
local function startAutoTrade()
    features.autoTrade = true
    Notify("Auto Trade", "ON", 2)
    task.spawn(function()
        while features.autoTrade do
            if remotes.trade then
                pcall(function() remotes.trade:FireServer() end)
            end
            task.wait(CONFIG.TradeDelay)
        end
    end)
end

local function stopAutoTrade()
    features.autoTrade = false
    Notify("Auto Trade", "OFF", 2)
end

-- ============================================
-- 8. AUTO ACCEPT TRADE
-- ============================================
local function startAutoAcceptTrade()
    features.autoAcceptTrade = true
    Notify("Auto Accept Trade", "ON", 2)
    if remotes.acceptTrade then
        remotes.acceptTrade.OnClientEvent:Connect(function()
            if features.autoAcceptTrade then
                pcall(function() remotes.acceptTrade:FireServer() end)
            end
        end)
    end
end

local function stopAutoAcceptTrade()
    features.autoAcceptTrade = false
    Notify("Auto Accept Trade", "OFF", 2)
end

-- ============================================
-- 9. AUTO TOTEM
-- ============================================
local function startAutoTotem()
    features.autoTotem = true
    Notify("Auto Totem", "ON", 2)
    task.spawn(function()
        while features.autoTotem do
            if remotes.totem then
                pcall(function() remotes.totem:FireServer() end)
            end
            task.wait(CONFIG.TotemDelay)
        end
    end)
end

local function stopAutoTotem()
    features.autoTotem = false
    Notify("Auto Totem", "OFF", 2)
end

-- ============================================
-- 10. AUTO WEATHER
-- ============================================
local function startAutoWeather()
    features.autoWeather = true
    Notify("Auto Weather", "ON", 2)
    task.spawn(function()
        local idx = 1
        while features.autoWeather do
            if remotes.weather then
                pcall(function() remotes.weather:FireServer(weatherTypes[idx]) end)
                idx = idx % #weatherTypes + 1
            end
            task.wait(CONFIG.WeatherDelay)
        end
    end)
end

local function stopAutoWeather()
    features.autoWeather = false
    Notify("Auto Weather", "OFF", 2)
end

-- ============================================
-- 11. AUTO QUEST
-- ============================================
local function startAutoQuest()
    features.autoQuest = true
    Notify("Auto Quest", "ON", 2)
    task.spawn(function()
        while features.autoQuest do
            for _, quest in pairs(questTypes) do
                if remotes.quest then
                    pcall(function() remotes.quest:FireServer(quest) end)
                end
                task.wait(2)
            end
            task.wait(10)
        end
    end)
end

local function stopAutoQuest()
    features.autoQuest = false
    Notify("Auto Quest", "OFF", 2)
end

-- ============================================
-- 12. AUTO ARTIFACT
-- ============================================
local function startAutoArtifact()
    features.autoArtifact = true
    Notify("Auto Artifact", "ON", 2)
    task.spawn(function()
        while features.autoArtifact do
            if remotes.artifact then
                pcall(function() remotes.artifact:FireServer() end)
            end
            task.wait(5)
        end
    end)
end

local function stopAutoArtifact()
    features.autoArtifact = false
    Notify("Auto Artifact", "OFF", 2)
end

-- ============================================
-- 13. AUTO EVENT
-- ============================================
local function startAutoEvent()
    features.autoEvent = true
    Notify("Auto Event", "ON", 2)
    task.spawn(function()
        while features.autoEvent do
            if remotes.event then
                pcall(function() remotes.event:FireServer() end)
            end
            task.wait(30)
        end
    end)
end

local function stopAutoEvent()
    features.autoEvent = false
    Notify("Auto Event", "OFF", 2)
end

-- ============================================
-- 14. AUTO REJOIN
-- ============================================
local function startAutoRejoin()
    features.autoRejoin = true
    Notify("Auto Rejoin", "ON", 2)
    LocalPlayer.OnTeleport:Connect(function()
        if features.autoRejoin then
            task.wait(5)
            TeleportService:Teleport(game.PlaceId)
        end
    end)
end

local function stopAutoRejoin()
    features.autoRejoin = false
    Notify("Auto Rejoin", "OFF", 2)
end

-- ============================================
-- 15. AUTO SERVER HOP
-- ============================================
local function startAutoServerHop()
    features.autoServerHop = true
    Notify("Auto Server Hop", "ON (Every 5 min)", 2)
    task.spawn(function()
        while features.autoServerHop do
            task.wait(300)
            TeleportService:Teleport(game.PlaceId)
        end
    end)
end

local function stopAutoServerHop()
    features.autoServerHop = false
    Notify("Auto Server Hop", "OFF", 2)
end

-- ============================================
-- 16. ANTI-AFK
-- ============================================
local function startAntiAFK()
    features.antiAFK = true
    Notify("Anti-AFK", "ON", 2)
    task.spawn(function()
        while features.antiAFK do
            task.wait(30)
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            end)
        end
    end)
end

local function stopAntiAFK()
    features.antiAFK = false
    Notify("Anti-AFK", "OFF", 2)
end

-- ============================================
-- 17. ANTI-DROWN
-- ============================================
local function startAntiDrown()
    features.antiDrown = true
    Notify("Anti-Drown", "ON", 2)
    task.spawn(function()
        while features.antiDrown do
            task.wait(0.5)
            local hum = GetHumanoid()
            if hum and hum:GetState() == Enum.HumanoidStateType.Swimming then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function stopAntiDrown()
    features.antiDrown = false
    Notify("Anti-Drown", "OFF", 2)
end

-- ============================================
-- 18. ESP + TRACERS
-- ============================================
function ClearESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    for _, line in pairs(espLines) do
        pcall(function() line:Destroy() end)
    end
    espObjects = {}
    espLines = {}
end

local function enableESP()
    features.espEnabled = true
    Notify("ESP", "ON", 2)
    ClearESP()
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Adornee = v.Character
            highlight.FillColor = Color3.fromRGB(255, 50, 50)
            highlight.FillTransparency = 0.3
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = v.Character
            table.insert(espObjects, highlight)
        end
    end
    
    Players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if features.espEnabled then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.Adornee = char
                highlight.FillColor = Color3.fromRGB(255, 50, 50)
                highlight.FillTransparency = 0.3
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Parent = char
                table.insert(espObjects, highlight)
            end
        end)
    end)
end

local function disableESP()
    features.espEnabled = false
    ClearESP()
    Notify("ESP", "OFF", 2)
end

-- ============================================
-- 19. FLY + NOCLIP
-- ============================================
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
    if not features.flyEnabled then return end
    
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
    
    local speed = 100
    
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
            bodyVel.Velocity = (moveVec.Unit * speed) + Vector3.new(0, yVel, 0)
        else
            bodyVel.Velocity = Vector3.new(0, yVel, 0)
        end
        
        bodyGyro.CFrame = cam.CFrame
    end)
    
    table.insert(flyConnections, conn)
end

local function toggleFly()
    features.flyEnabled = not features.flyEnabled
    if features.flyEnabled then
        startFly()
        Notify("Fly", "ON", 2)
    else
        CleanupFly()
        Notify("Fly", "OFF", 2)
    end
end

local function toggleNoclip()
    features.noclipEnabled = not features.noclipEnabled
    Notify("Noclip", features.noclipEnabled and "ON" or "OFF", 2)
    
    local conn = RunService.RenderStepped:Connect(function()
        if features.noclipEnabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    if features.noclipEnabled then
        table.insert(flyConnections, conn)
    end
end

-- ============================================
-- 20. SPEED HACK
-- ============================================
local function toggleSpeedHack()
    features.speedHack = not features.speedHack
    Notify("Speed Hack", features.speedHack and "ON" or "OFF", 2)
    
    if features.speedHack then
        local conn = RunService.RenderStepped:Connect(function()
            if features.speedHack and LocalPlayer.Character then
                local hum = GetHumanoid()
                if hum then
                    hum.WalkSpeed = 50
                    hum.JumpPower = 100
                end
            end
        end)
        table.insert(flyConnections, conn)
    else
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end
end

-- ============================================
-- 21. TELEPORT SYSTEM
-- ============================================
local islands = {
    ["Spawn"] = Vector3.new(0, 5, 0),
    ["Coral Island"] = Vector3.new(100, 5, 50),
    ["Mermaid Lagoon"] = Vector3.new(-80, 5, 120),
    ["Retro Island"] = Vector3.new(200, 5, -100),
    ["Esoteric Depths"] = Vector3.new(-150, 5, -80),
    ["Event Island"] = Vector3.new(50, 5, -150),
}

-- ============================================
-- 22. FPS BOOST
-- ============================================
local function toggleFPSBoost()
    Notify("FPS Boost", "ON", 2)
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
end

-- ============================================
-- 23. SAVE & LOAD CONFIG
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
        Notify("Config", "Saved!", 2)
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
            Notify("Config", "Loaded!", 2)
        else
            Notify("Config", "No config found!", 2)
        end
    end)
end

-- ============================================
-- 24. TELEPORT TO PLAYER
-- ============================================
local function teleportToPlayer(target)
    if not target or target == "" or target == "Tidak ada pemain" then
        Notify("Error", "Pilih pemain dulu!", 2)
        return
    end
    
    local player = GetPlayerByName(target)
    if not player or not player.Character then
        Notify("Error", "Pemain tidak ditemukan!", 2)
        return
    end
    
    local root = GetRootPart()
    local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
    
    if root and targetRoot then
        root.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
        Notify("Teleport", "Ke " .. player.Name, 2)
    else
        Notify("Error", "Gagal teleport!", 2)
    end
end

-- ============================================
-- 25. ESP TARGET PLAYER
-- ============================================
local targetHighlight = nil

local function espTargetPlayer(target)
    if not target or target == "" or target == "Tidak ada pemain" then
        Notify("Error", "Pilih pemain dulu!", 2)
        return
    end
    
    if targetHighlight then
        pcall(function() targetHighlight:Destroy() end)
        targetHighlight = nil
    end
    
    local player = GetPlayerByName(target)
    if not player or not player.Character then
        Notify("Error", "Pemain tidak ditemukan!", 2)
        return
    end
    
    targetHighlight = Instance.new("Highlight")
    targetHighlight.Name = "Target_Highlight"
    targetHighlight.Adornee = player.Character
    targetHighlight.FillColor = Color3.fromRGB(255, 0, 255)
    targetHighlight.FillTransparency = 0.2
    targetHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    targetHighlight.Parent = player.Character
    
    Notify("ESP Target", "Highlighting " .. player.Name, 2)
end

local function clearTargetESP()
    if targetHighlight then
        pcall(function() targetHighlight:Destroy() end)
        targetHighlight = nil
        Notify("ESP Target", "Cleared", 2)
    end
end

-- ============================================
-- WINDOW CREATION
-- ============================================
local Window = Library:Window({
    Title = "Fish It MEGA",
    Footer = "v3.0 | All Features"
})

-- Player Dropdown untuk berbagai fitur
local PlayerDropdown = nil

-- ============================================
-- TAB: AUTOMATION
-- ============================================
local AutomationTab = Window:AddTab({ Name = "Automation", Icon = "robot" })

-- Auto Fishing Section
local FishingSection = AutomationTab:AddSection(" Auto Fishing")

local fishBtn = FishingSection:AddToggle({
    Title = "Auto Fishing",
    Description = "Mancing otomatis dengan berbagai mode",
    Default = false,
    Callback = function(v)
        if v then startAutoFish() else stopAutoFish() end
    end
})

FishingSection:AddDropdown({
    Title = "Fishing Mode",
    Description = "Pilih kecepatan mancing",
    Options = {"Stable", "Blatant", "Extreme", "Instant"},
    Default = "Stable",
    Callback = function(v)
        fishMode = v
        if features.autoFish then
            stopAutoFish()
            startAutoFish()
        end
    end
})

FishingSection:AddToggle({
    Title = "Auto Re-Cast",
    Description = "Otomatis casting ulang setelah mancing",
    Default = false,
    Callback = function(v)
        features.autoReCast = v
    end
})

FishingSection:AddInput({
    Title = "Fishing Delay (detik)",
    Description = "Jeda antar mancing",
    Default = "2",
    Callback = function(v)
        CONFIG.FishingDelay = tonumber(v) or 2
    end
})

-- Auto Sell Section
local SellSection = AutomationTab:AddSection(" Auto Sell")

local sellBtn = SellSection:AddToggle({
    Title = "Auto Sell",
    Description = "Jual ikan otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoSell() else stopAutoSell() end
    end
})

SellSection:AddDropdown({
    Title = "Sell Filter",
    Description = "Filter ikan yang dijual",
    Options = {"All", "Legendary", "Epic", "Rare", "Common"},
    Default = "All",
    Callback = function(v)
        sellFilter = v
        if features.autoSell then
            stopAutoSell()
            startAutoSell()
        end
    end
})

SellSection:AddInput({
    Title = "Sell Delay (detik)",
    Description = "Jeda antar penjualan",
    Default = "1",
    Callback = function(v)
        CONFIG.SellDelay = tonumber(v) or 1
    end
})

-- Auto System Section
local SystemSection = AutomationTab:AddSection(" Auto Systems")

SystemSection:AddToggle({
    Title = "Auto Enchant",
    Description = "Enchant rod otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoEnchant() else stopAutoEnchant() end
    end
})

SystemSection:AddToggle({
    Title = "Auto Open Crate",
    Description = "Buka crate otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoOpenCrate() else stopAutoOpenCrate() end
    end
})

SystemSection:AddToggle({
    Title = "Auto Equip Skin",
    Description = "Equip skin terbaik otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoEquipSkin() else stopAutoEquipSkin() end
    end
})

SystemSection:AddToggle({
    Title = "Auto Buy",
    Description = "Beli equipment & bait otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoBuy() else stopAutoBuy() end
    end
})

SystemSection:AddToggle({
    Title = "Auto Trade",
    Description = "Trade otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoTrade() else stopAutoTrade() end
    end
})

SystemSection:AddToggle({
    Title = "Auto Accept Trade",
    Description = "Terima trade otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoAcceptTrade() else stopAutoAcceptTrade() end
    end
})

SystemSection:AddToggle({
    Title = "Auto Totem",
    Description = "Pasang totem otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoTotem() else stopAutoTotem() end
    end
})

SystemSection:AddToggle({
    Title = "Auto Weather",
    Description = "Beli weather random otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoWeather() else stopAutoWeather() end
    end
})

SystemSection:AddToggle({
    Title = "Auto Quest",
    Description = "Selesaikan quest otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoQuest() else stopAutoQuest() end
    end
})

SystemSection:AddToggle({
    Title = "Auto Artifact",
    Description = "Kumpulkan artifact otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoArtifact() else stopAutoArtifact() end    end
})

SystemSection:AddToggle({
    Title = "Auto Event",
    Description = "Join event otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoEvent() else stopAutoEvent() end
    end
})

SystemSection:AddToggle({
    Title = "Auto Rejoin",
    Description = "Rejoin otomatis saat teleport",
    Default = false,
    Callback = function(v)
        if v then startAutoRejoin() else stopAutoRejoin() end
    end
})

SystemSection:AddToggle({
    Title = "Auto Server Hop",
    Description = "Pindah server setiap 5 menit",
    Default = false,
    Callback = function(v)
        if v then startAutoServerHop() else stopAutoServerHop() end
    end
})

-- ============================================
-- TAB: UTILITIES
-- ============================================
local UtilitiesTab = Window:AddTab({ Name = "Utilities", Icon = "tools" })

-- Protection Section
local ProtectionSection = UtilitiesTab:AddSection(" Protection")

ProtectionSection:AddToggle({
    Title = "Anti-AFK",
    Description = "Mencegah kick karena AFK",
    Default = false,
    Callback = function(v)
        if v then startAntiAFK() else stopAntiAFK() end
    end
})

ProtectionSection:AddToggle({
    Title = "Anti-Drown",
    Description = "Mencegah tenggelam di air",
    Default = false,
    Callback = function(v)
        if v then startAntiDrown() else stopAntiDrown() end
    end
})

-- Movement Section
local MovementSection = UtilitiesTab:AddSection(" Movement")

MovementSection:AddToggle({
    Title = "Fly Mode",
    Description = "Terbang bebas (WASD + Space/Shift)",
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
    Description = "Tembus tembok",
    Default = false,
    Callback = function(v)
        if v then 
            features.noclipEnabled = true
            toggleNoclip()
        else 
            features.noclipEnabled = false
        end
    end
})

MovementSection:AddToggle({
    Title = "Speed Hack",
    Description = "Kecepatan berjalan & lompat tinggi",
    Default = false,
    Callback = function(v)
        if v then 
            features.speedHack = true
            toggleSpeedHack()
        else 
            features.speedHack = false
            toggleSpeedHack()
        end
    end
})

MovementSection:AddInput({
    Title = "Walk Speed",
    Description = "Kecepatan berjalan",
    Default = "16",
    Callback = function(v)
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = tonumber(v) or 16
        end
    end
})

MovementSection:AddInput({
    Title = "Jump Power",
    Description = "Kekuatan lompat",
    Default = "50",
    Callback = function(v)
        local hum = GetHumanoid()
        if hum then
            hum.JumpPower = tonumber(v) or 50
        end
    end
})

-- ESP Section
local ESPSection = UtilitiesTab:AddSection(" ESP & Visual")

ESPSection:AddToggle({
    Title = "ESP Players",
    Description = "Highlight semua pemain",
    Default = false,
    Callback = function(v)
        if v then enableESP() else disableESP() end
    end
})

ESPSection:AddButton({
    Title = "Clear ESP",
    Description = "Hapus semua ESP",
    Callback = function()
        ClearESP()
        Notify("ESP", "Cleared!", 2)
    end
})

-- Player Dropdown untuk ESP Target
local EspTargetSection = UtilitiesTab:AddSection(" ESP Target")

EspTargetSection:AddDropdown({
    Title = "Pilih Pemain",
    Description = "Pilih target untuk ESP",
    Options = GetPlayerList(),
    Default = "",
    Callback = function(v)
        SelectedTarget = v
    end
})

EspTargetSection:AddButton({
    Title = " Highlight Target",
    Description = "Highlight pemain yang dipilih",
    Callback = function()
        espTargetPlayer(SelectedTarget)
    end
})

EspTargetSection:AddButton({
    Title = " Clear Target Highlight",
    Description = "Hapus highlight target",
    Callback = function()
        clearTargetESP()
    end
})

-- Refresh Button
EspTargetSection:AddButton({
    Title = " Refresh Daftar Pemain",
    Callback = function()
        UpdateDropdown()
        Notify("Refresh", "Daftar pemain diperbarui!", 2)
    end
})

-- Visual Section
local VisualSection = UtilitiesTab:AddSection(" Visual")

VisualSection:AddButton({
    Title = "FPS Boost",
    Description = "Optimasi grafis untuk FPS tinggi",
    Callback = function()
        toggleFPSBoost()
    end
})

VisualSection:AddToggle({
    Title = "Fullbright",
    Description = "Terang sepanjang waktu",
    Default = false,
    Callback = function(v)
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = true
        end
    end
})

-- ============================================
-- TAB: TELEPORT
-- ============================================
local TeleportTab = Window:AddTab({ Name = "Teleport", Icon = "map" })

-- Island Teleport Section
local IslandSection = TeleportTab:AddSection(" Teleport to Island")

for name, pos in pairs(islands) do
    IslandSection:AddButton({
        Title = "TP: " .. name,
        Callback = function()
            TeleportTo(pos)
            Notify("Teleport", "Ke " .. name, 2)
        end
    })
end

-- Custom TP Section
local CustomSection = TeleportTab:AddSection(" Custom Teleport")

CustomSection:AddInput({
    Title = "X Position",
    Default = "0",
    Callback = function(v)
        CONFIG.TeleportPosition = Vector3.new(
            tonumber(v) or 0,
            CONFIG.TeleportPosition.Y,
            CONFIG.TeleportPosition.Z
        )
    end
})

CustomSection:AddInput({
    Title = "Y Position",
    Default = "5",
    Callback = function(v)
        CONFIG.TeleportPosition = Vector3.new(
            CONFIG.TeleportPosition.X,
            tonumber(v) or 5,
            CONFIG.TeleportPosition.Z
        )
    end
})

CustomSection:AddInput({
    Title = "Z Position",
    Default = "0",
    Callback = function(v)
        CONFIG.TeleportPosition = Vector3.new(
            CONFIG.TeleportPosition.X,
            CONFIG.TeleportPosition.Y,
            tonumber(v) or 0
        )
    end
})

CustomSection:AddButton({
    Title = "Teleport to Custom Position",
    Callback = function()
        TeleportTo(CONFIG.TeleportPosition)
        Notify("Teleport", "Ke posisi custom!", 2)
    end
})

-- Player Teleport Section
local PlayerTPSection = TeleportTab:AddSection(" Teleport to Player")

PlayerTPSection:AddDropdown({
    Title = "Pilih Pemain",
    Description = "Pilih target teleport",
    Options = GetPlayerList(),
    Default = "",
    Callback = function(v)
        SelectedTarget = v
    end
})

PlayerTPSection:AddButton({
    Title = "Teleport to Player",
    Description = "TP ke pemain yang dipilih",
    Callback = function()
        teleportToPlayer(SelectedTarget)
    end
})

PlayerTPSection:AddButton({
    Title = " Refresh Daftar Pemain",
    Callback = function()
        UpdateDropdown()
        Notify("Refresh", "Daftar pemain diperbarui!", 2)
    end
})

-- ============================================
-- TAB: CONFIG
-- ============================================
local ConfigTab = Window:AddTab({ Name = "Config", Icon = "settings" })

local ConfigSection = ConfigTab:AddSection(" Save/Load Config")

ConfigSection:AddButton({
    Title = " Save Config",
    Description = "Simpan semua pengaturan",
    Callback = function()
        saveConfig()
    end
})

ConfigSection:AddButton({
    Title = " Load Config",
    Description = "Muat pengaturan yang disimpan",
    Callback = function()
        loadConfig()
    end
})

-- Reset Section
local ResetSection = ConfigTab:AddSection(" Reset")

ResetSection:AddButton({
    Title = "Reset Character",
    Description = "Respawn karakter",
    Callback = function()
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.Health = 0
        else
            LocalPlayer:LoadCharacter()
        end
        Notify("Reset", "Character reset!", 2)
    end
})

ResetSection:AddButton({
    Title = "Reset Movement",
    Description = "Reset kecepatan & lompat ke default",
    Callback = function()
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        Workspace.Gravity = 196
        features.flyEnabled = false
        CleanupFly()
        Notify("Reset", "Movement reset!", 2)
    end
})

-- Exit Section
local ExitSection = ConfigTab:AddSection(" Exit")

ExitSection:AddButton({
    Title = "Stop All Features",
    Description = "Matikan semua fitur aktif",
    Callback = function()
        for name, value in pairs(features) do
            features[name] = false
        end
        ClearESP()
        CleanupFly()
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Notify("Stopped", "Semua fitur dimatikan!", 3)
    end
})

ExitSection:AddButton({
    Title = "Destroy UI",
    Description = "Tutup GUI dan matikan semua",
    Callback = function()
        for name, value in pairs(features) do
            features[name] = false
        end
        ClearESP()
        CleanupFly()
        Notify("Shutdown", "Fish It MEGA ditutup", 2)
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
        -- Update toggle state
        pcall(function()
            if fishBtn and fishBtn.SetValue then
                fishBtn:SetValue(features.autoFish)
            end
        end)
    elseif input.KeyCode == Enum.KeyCode.F2 then
        TeleportTo(CONFIG.TeleportPosition)
        Notify("Teleport", "Ke posisi default!", 2)
    elseif input.KeyCode == Enum.KeyCode.F3 then
        if features.autoOpenCrate then stopAutoOpenCrate() else startAutoOpenCrate() end
    elseif input.KeyCode == Enum.KeyCode.F4 then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        features.speedHack = not features.speedHack
        toggleSpeedHack()
    elseif input.KeyCode == Enum.KeyCode.F6 then
        if features.espEnabled then disableESP() else enableESP() end
    end
end)

-- ============================================
-- AUTO UPDATE DROPDOWN
-- ============================================
Players.PlayerAdded:Connect(UpdateDropdown)
Players.PlayerRemoving:Connect(UpdateDropdown)

-- ============================================
-- INITIALIZE
-- ============================================
Window:Initialize()

Notify("Fish It MEGA", "Loaded with all features!", 5)

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