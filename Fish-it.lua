

-- ============================================
-- SCRIPT FISH IT - MEGA FULL FEATURES
-- DENGAN LIBRARY MDW (SAMA SEPERTI SEBELUMNYA)
-- ============================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mdwpanel/Roblox/refs/heads/main/main_ui_modern.lua"))()

-- Services
local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera
local virtualInput = game:GetService("VirtualInputManager")
local teleportService = game:GetService("TeleportService")
local lighting = game:GetService("Lighting")
local coreGui = game:GetService("CoreGui")
local httpService = game:GetService("HttpService")
local tweenService = game:GetService("TweenService")

-- ============================================
-- KONFIGURASI
-- ============================================
local CONFIG = {
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
    TeleportPosition = Vector3.new(0, 5, 0),
    FishDelay = 2,
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
    fpsBoost = false,
    autoHeal = false,
}

local fishMode = "Stable"
local sellFilter = "All"
local flySpeed = 100

-- ============================================
-- HELPER FUNCTIONS
-- ============================================
local function GetHumanoid()
    return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function Notify(title, desc, duration)
    Library:MakeNotify({Title = title, Content = desc, Duration = duration or 3})
end

-- ============================================
-- 1. AUTO FISHING
-- ============================================
local function startAutoFish()
    features.autoFish = true
    Notify(" Auto Fishing", "ON (" .. fishMode .. " Mode)")
    spawn(function()
        while features.autoFish do
            if remotes.fish and not player.Character:FindFirstChild("Fishing") then
                remotes.fish:FireServer()
            end
            
            if fishMode == "Instant" then
                if remotes.reel then
                    remotes.reel:FireServer()
                end
            else
                local delay = fishMode == "Extreme" and 0.5 or CONFIG.FishDelay
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
    Notify(" Auto Fishing", "OFF")
end

-- ============================================
-- 2. AUTO SELL
-- ============================================
local function startAutoSell()
    features.autoSell = true
    Notify(" Auto Sell", "ON (" .. sellFilter .. ")")
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
    Notify(" Auto Sell", "OFF")
end

-- ============================================
-- 3. AUTO ENCHANT
-- ============================================
local function startAutoEnchant()
    features.autoEnchant = true
    Notify(" Auto Enchant", "ON")
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
    Notify(" Auto Enchant", "OFF")
end

-- ============================================
-- 4. AUTO OPEN CRATE
-- ============================================
local function startAutoOpenCrate()
    features.autoOpenCrate = true
    Notify(" Auto Open Crate", "ON")
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
    Notify(" Auto Open Crate", "OFF")
end

-- ============================================
-- 5. AUTO EQUIP SKIN
-- ============================================
local function startAutoEquipSkin()
    features.autoEquipSkin = true
    Notify(" Auto Equip Skin", "ON")
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
    Notify(" Auto Equip Skin", "OFF")
end

-- ============================================
-- 6. AUTO BUY
-- ============================================
local function startAutoBuy()
    features.autoBuy = true
    Notify(" Auto Buy", "ON")
    spawn(function()
        while features.autoBuy do
            if remotes.buy then
                remotes.buy:FireServer("best")
            end
            wait(10)
            if remotes.buy then
                remotes.buy:FireServer("bait")
            end
            wait(5)
        end
    end)
end

local function stopAutoBuy()
    features.autoBuy = false
    Notify(" Auto Buy", "OFF")
end

-- ============================================
-- 7. AUTO TRADE
-- ============================================
local function startAutoTrade()
    features.autoTrade = true
    Notify(" Auto Trade", "ON")
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
    Notify(" Auto Trade", "OFF")
end

-- ============================================
-- 8. AUTO ACCEPT TRADE
-- ============================================
local function startAutoAcceptTrade()
    features.autoAcceptTrade = true
    Notify(" Auto Accept Trade", "ON")
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
    Notify(" Auto Accept Trade", "OFF")
end

-- ============================================
-- 9. AUTO TOTEM
-- ============================================
local function startAutoTotem()
    features.autoTotem = true
    Notify(" Auto Totem", "ON")
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
    Notify(" Auto Totem", "OFF")
end

-- ============================================
-- 10. AUTO WEATHER
-- ============================================
local weatherTypes = {"Storm", "Cloudy", "Wind", "Snow"}

local function startAutoWeather()
    features.autoWeather = true
    Notify(" Auto Weather", "ON")
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
    Notify(" Auto Weather", "OFF")
end

-- ============================================
-- 11. AUTO QUEST
-- ============================================
local questTypes = {"DeepSea", "AuraKid", "ElementJungle"}

local function startAutoQuest()
    features.autoQuest = true
    Notify(" Auto Quest", "ON")
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
    Notify(" Auto Quest", "OFF")
end

-- ============================================
-- 12. AUTO ARTIFACT
-- ============================================
local function startAutoArtifact()
    features.autoArtifact = true
    Notify(" Auto Artifact", "ON")
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
    Notify(" Auto Artifact", "OFF")
end

-- ============================================
-- 13. AUTO EVENT
-- ============================================
local function startAutoEvent()
    features.autoEvent = true
    Notify(" Auto Event", "ON")
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
    Notify(" Auto Event", "OFF")
end

-- ============================================
-- 14. AUTO REJOIN
-- ============================================
local function startAutoRejoin()
    features.autoRejoin = true
    Notify(" Auto Rejoin", "ON")
    player.OnTeleport:Connect(function()
        if features.autoRejoin then
            wait(5)
            teleportService:Teleport(game.PlaceId)
        end
    end)
end

local function stopAutoRejoin()
    features.autoRejoin = false
    Notify(" Auto Rejoin", "OFF")
end

-- ============================================
-- 15. AUTO SERVER HOP
-- ============================================
local function startAutoServerHop()
    features.autoServerHop = true
    Notify(" Auto Server Hop", "ON")
    spawn(function()
        while features.autoServerHop do
            wait(300)
            teleportService:Teleport(game.PlaceId)
        end
    end)
end

local function stopAutoServerHop()
    features.autoServerHop = false
    Notify(" Auto Server Hop", "OFF")
end

-- ============================================
-- 16. ANTI-AFK
-- ============================================
local function startAntiAFK()
    features.antiAFK = true
    Notify(" Anti-AFK", "ON")
    runService.RenderStepped:Connect(function()
        if features.antiAFK and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            humanoid:Move(Vector3.new(0, 0, 0), true)
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
    Notify(" Anti-Drown", "ON")
    runService.RenderStepped:Connect(function()
        if features.antiDrown and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- ============================================
-- 18. AUTO HEAL
-- ============================================
local function startAutoHeal()
    features.autoHeal = true
    Notify(" Auto Heal", "ON")
    spawn(function()
        while features.autoHeal do
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum and hum.Health < hum.MaxHealth * 0.5 then
                for _, item in pairs(player.Backpack:GetChildren()) do
                    if item:IsA("Tool") and (item.Name:lower():find("heal") or item.Name:lower():find("pot") or item.Name:lower():find("med")) then
                        hum:EquipTool(item)
                        wait(0.5)
                        virtualInput:SendKeyEvent(true, Enum.KeyCode.ButtonR1, false, game)
                        wait(0.1)
                        virtualInput:SendKeyEvent(false, Enum.KeyCode.ButtonR1, false, game)
                        break
                    end
                end
            end
            wait(2)
        end
    end)
end

-- ============================================
-- 19. ESP + TRACERS
-- ============================================
local espHighlights = {}
local espLines = {}

local function enableESP()
    features.espEnabled = true
    Notify(" ESP", "ON")
    
    for _, v in pairs(players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Adornee = v.Character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.3
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Parent = v.Character
            table.insert(espHighlights, highlight)
        end
    end
    
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
                table.insert(espHighlights, highlight)
            end
        end)
    end)
end

local function disableESP()
    features.espEnabled = false
    for _, obj in pairs(espHighlights) do
        pcall(function() obj:Destroy() end)
    end
    espHighlights = {}
    Notify(" ESP", "OFF")
end

-- ============================================
-- 20. FLY
-- ============================================
local flyConnection = nil

local function toggleFly()
    features.flyEnabled = not features.flyEnabled
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        if features.flyEnabled then
            humanoid.PlatformStand = true
            Notify(" Fly", "ON")
            
            flyConnection = runService.RenderStepped:Connect(function()
                if not features.flyEnabled then return end
                local root = GetRootPart()
                if not root then return end
                
                local moveVec = Vector3.new(0, 0, 0)
                local cam = workspace.CurrentCamera
                
                if userInput:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
                if userInput:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
                if userInput:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
                if userInput:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
                
                local yVel = 0
                if userInput:IsKeyDown(Enum.KeyCode.Space) then yVel = flySpeed end
                if userInput:IsKeyDown(Enum.KeyCode.LeftControl) then yVel = -flySpeed end
                
                if moveVec.Magnitude > 0 then
                    root.AssemblyLinearVelocity = moveVec.Unit * flySpeed + Vector3.new(0, yVel, 0)
                else
                    root.AssemblyLinearVelocity = Vector3.new(0, yVel, 0)
                end
            end)
        else
            humanoid.PlatformStand = false
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            Notify(" Fly", "OFF")
        end
    end
end

-- ============================================
-- 21. NOCLIP
-- ============================================
local noclipConnection = nil

local function toggleNoclip()
    features.noclipEnabled = not features.noclipEnabled
    if features.noclipEnabled then
        Notify(" Noclip", "ON")
        noclipConnection = runService.RenderStepped:Connect(function()
            if features.noclipEnabled and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        Notify(" Noclip", "OFF")
    end
end

-- ============================================
-- 22. SPEED HACK
-- ============================================
local speedConnection = nil

local function toggleSpeedHack()
    features.speedHack = not features.speedHack
    if features.speedHack then
        Notify(" Speed Hack", "ON")
        speedConnection = runService.RenderStepped:Connect(function()
            if features.speedHack and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 50
                player.Character.Humanoid.JumpPower = 100
            end
        end)
    else
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            player.Character.Humanoid.JumpPower = 50
        end
        Notify(" Speed Hack", "OFF")
    end
end

-- ============================================
-- 23. TELEPORT SYSTEM
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
    local root = GetRootPart()
    if root then
        root.CFrame = CFrame.new(pos)
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        Notify(" Teleport", "Ke " .. pos)
    end
end

-- ============================================
-- 24. FPS BOOST
-- ============================================
local function toggleFPSBoost()
    features.fpsBoost = not features.fpsBoost
    if features.fpsBoost then
        Notify(" FPS Boost", "ON")
        lighting.GlobalShadows = false
        lighting.Technology = Enum.Technology.Legacy
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") then
                v.Material = Enum.Material.Plastic
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            end
        end
        settings().Rendering.QualityLevel = 1
    else
        Notify(" FPS Boost", "OFF")
        lighting.GlobalShadows = true
        lighting.Technology = Enum.Technology.ShadowMap
        settings().Rendering.QualityLevel = 3
    end
end

-- ============================================
-- 25. SAVE & LOAD CONFIG
-- ============================================
local function saveConfig()
    local config = {}
    for name, value in pairs(features) do
        config[name] = value
    end
    config.fishMode = fishMode
    config.sellFilter = sellFilter
    pcall(function()
        writefile("FishIt_Config.json", httpService:JSONEncode(config))
        Notify(" Config", "Saved!")
    end)
end

local function loadConfig()
    pcall(function()
        if isfile("FishIt_Config.json") then
            local data = httpService:JSONDecode(readfile("FishIt_Config.json"))
            for name, value in pairs(data) do
                if features[name] ~= nil then
                    features[name] = value
                end
            end
            fishMode = data.fishMode or "Stable"
            sellFilter = data.sellFilter or "All"
            Notify(" Config", "Loaded!")
        end
    end)
end

-- ============================================
-- WINDOW CREATION (Library MDW)
-- ============================================
local Window = Library:Window({
    Title = " FISH IT MEGA",
    Footer = "v3.0 | All Features"
})

-- ============================================
-- TAB: AUTOMATION
-- ============================================
local AutoTab = Window:AddTab({ Name = " Auto", Icon = "home" })

local AutoSection = AutoTab:AddSection(" Fishing Automation")

-- Auto Fishing Toggle
AutoSection:AddToggle({
    Title = "Auto Fishing",
    Description = "Menangkap ikan otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoFish() else stopAutoFish() end
    end
})

-- Fishing Mode Dropdown
AutoSection:AddDropdown({
    Title = "Fishing Mode",
    Description = "Pilih kecepatan fishing",
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

-- Auto Sell
AutoSection:AddToggle({
    Title = "Auto Sell",
    Description = "Menjual ikan secara otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoSell() else stopAutoSell() end
    end
})

-- Sell Filter
AutoSection:AddDropdown({
    Title = "Sell Filter",
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

-- Auto Enchant
AutoSection:AddToggle({
    Title = "Auto Enchant",
    Description = "Meng-enchant joran otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoEnchant() else stopAutoEnchant() end
    end
})

-- Auto Open Crate
AutoSection:AddToggle({
    Title = "Auto Open Crate",
    Description = "Membuka crate otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoOpenCrate() else stopAutoOpenCrate() end
    end
})

-- Auto Equip Skin
AutoSection:AddToggle({
    Title = "Auto Equip Skin",
    Description = "Memasang skin terbaik otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoEquipSkin() else stopAutoEquipSkin() end
    end
})

-- Auto Buy
AutoSection:AddToggle({
    Title = "Auto Buy",
    Description = "Membeli item terbaik otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoBuy() else stopAutoBuy() end
    end
})

-- ============================================
-- TAB: TRADE & SERVER
-- ============================================
local TradeTab = Window:AddTab({ Name = " Trade", Icon = "player" })

local TradeSection = TradeTab:AddSection(" Trade Automation")

TradeSection:AddToggle({
    Title = "Auto Trade",
    Description = "Melakukan trade otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoTrade() else stopAutoTrade() end
    end
})

TradeSection:AddToggle({
    Title = "Auto Accept Trade",
    Description = "Menerima trade otomatis",
    Default = false,
    Callback = function(v)
        if v then startAutoAcceptTrade() else stopAutoAcceptTrade() end
    end
})

local ServerSection = TradeTab:AddSection(" Server Management")

ServerSection:AddToggle({
    Title = "Auto Rejoin",
    Description = "Rejoin otomatis saat disconnect",
    Default = false,
    Callback = function(v)
        if v then startAutoRejoin() else stopAutoRejoin() end
    end
})

ServerSection:AddToggle({
    Title = "Auto Server Hop",
    Description = "Pindah server otomatis setiap 5 menit",
    Default = false,
    Callback = function(v)
        if v then startAutoServerHop() else stopAutoServerHop() end
    end
})

ServerSection:AddButton({
    Title = "Server Hop Now",
    Callback = function()
        teleportService:Teleport(game.PlaceId)
    end
})

-- ============================================
-- TAB: UTILITIES
-- ============================================
local UtilTab = Window:AddTab({ Name = " Util", Icon = "gamepad" })

local ProtectSection = UtilTab:AddSection(" Protection")

ProtectSection:AddToggle({
    Title = "Anti-AFK",
    Description = "Mencegah kick karena AFK",
    Default = false,
    Callback = function(v)
        if v then startAntiAFK() else features.antiAFK = false end
    end
})

ProtectSection:AddToggle({
    Title = "Anti-Drown",
    Description = "Mencegah tenggelam",
    Default = false,
    Callback = function(v)
        if v then startAntiDrown() else features.antiDrown = false end
    end
})

ProtectSection:AddToggle({
    Title = "Auto Heal",
    Description = "Heal otomatis saat HP rendah",
    Default = false,
    Callback = function(v)
        if v then startAutoHeal() else features.autoHeal = false end
    end
})

local MoveSection = UtilTab:AddSection(" Movement")

MoveSection:AddToggle({
    Title = "Fly",
    Description = "Mode terbang (WASD + Space/Ctrl)",
    Default = false,
    Callback = function(v)
        if v then
            features.flyEnabled = true
            toggleFly()
        else
            toggleFly()
        end
    end
})

MoveSection:AddInput({
    Title = "Fly Speed",
    Default = "100",
    Callback = function(v)
        flySpeed = tonumber(v) or 100
    end
})

MoveSection:AddToggle({
    Title = "Noclip",
    Description = "Tembus tembok",
    Default = false,
    Callback = function(v)
        if v then
            features.noclipEnabled = true
            toggleNoclip()
        else
            toggleNoclip()
        end
    end
})

MoveSection:AddToggle({
    Title = "Speed Hack",
    Description = "Kecepatan berjalan dan lompat tinggi",
    Default = false,
    Callback = function(v)
        if v then
            features.speedHack = true
            toggleSpeedHack()
        else
            toggleSpeedHack()
        end
    end
})

-- ============================================
-- TAB: ESP & VISUAL
-- ============================================
local ESPTab = Window:AddTab({ Name = " ESP", Icon = "web" })

local ESP_Section = ESPTab:AddSection(" ESP & Tracking")

ESP_Section:AddToggle({
    Title = "ESP Players",
    Description = "Melihat pemain lain dengan highlight",
    Default = false,
    Callback = function(v)
        if v then enableESP() else disableESP() end
    end
})

ESP_Section:AddToggle({
    Title = "FPS Boost",
    Description = "Meningkatkan FPS dengan mengurangi grafis",
    Default = false,
    Callback = function(v)
        if v then
            features.fpsBoost = true
            toggleFPSBoost()
        else
            toggleFPSBoost()
        end
    end
})

-- ============================================
-- TAB: TELEPORT
-- ============================================
local TeleportTab = Window:AddTab({ Name = " TP", Icon = "user" })

local TP_Section = TeleportTab:AddSection(" Island Teleport")

for name, pos in pairs(islands) do
    TP_Section:AddButton({
        Title = " " .. name,
        Callback = function()
            teleportTo(pos)
        end
    })
end

-- Custom Teleport
TP_Section:AddInput({
    Title = "Custom Teleport",
    Description = "X,Y,Z (contoh: 100,5,50)",
    Default = "",
    Callback = function(v)
        local parts = {}
        for num in v:gmatch("%-?%d+%.?%d*") do
            table.insert(parts, tonumber(num))
        end
        if #parts >= 3 then
            local pos = Vector3.new(parts[1], parts[2], parts[3])
            teleportTo(pos)
        end
    end
})

-- ============================================
-- TAB: SETTINGS
-- ============================================
local SettingsTab = Window:AddTab({ Name = " Settings", Icon = "settings" })

local ConfigSection = SettingsTab:AddSection(" Config Management")

ConfigSection:AddButton({
    Title = " Save Config",
    Callback = saveConfig
})

ConfigSection:AddButton({
    Title = " Load Config",
    Callback = loadConfig
})

-- Reset All
ConfigSection:AddButton({
    Title = " Reset All Features",
    Callback = function()
        for name, _ in pairs(features) do
            features[name] = false
        end
        if flyConnection then flyConnection:Disconnect() end
        if noclipConnection then noclipConnection:Disconnect() end
        if speedConnection then speedConnection:Disconnect() end
        disableESP()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            player.Character.Humanoid.JumpPower = 50
            player.Character.Humanoid.PlatformStand = false
        end
        Notify(" Reset", "All features disabled")
    end
})

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
        if features.flyEnabled then toggleFly() else features.flyEnabled = true; toggleFly() end
    elseif input.KeyCode == Enum.KeyCode.F5 then
        if features.speedHack then toggleSpeedHack() else features.speedHack = true; toggleSpeedHack() end
    elseif input.KeyCode == Enum.KeyCode.F6 then
        if features.espEnabled then disableESP() else enableESP() end
    end
end)

-- ============================================
-- START
-- ============================================
Library:Initialize()
Notify(" FISH IT MEGA", "Script Loaded Successfully!", 5)

print("========================================")
print(" FISH IT MEGA SCRIPT v3 - ALL FEATURES")
print("========================================")
print(" Fitur Lengkap:")
print("- Auto Fishing (4 mode: Stable/Blatant/Extreme/Instant)")
print("- Auto Sell (Filter: All/Legendary/Epic/Rare/Common)")
print("- Auto Enchant, Auto Open Crate, Auto Equip Skin")
print("- Auto Buy, Auto Trade, Auto Accept Trade")
print("- Auto Totem, Auto Weather, Auto Quest")
print("- Auto Artifact, Auto Event, Auto Rejoin, Auto Server Hop")
print("- Anti-AFK, Anti-Drown, Auto Heal")
print("- ESP, Fly, Noclip, Speed Hack")
print("- Teleport ke semua Island, FPS Boost")
print("- Save/Load Config")
print("========================================")
print(" Shortcut:")
print("F1 = Toggle Auto Fishing")
print("F2 = Teleport to Default Spot")
print("F3 = Toggle Auto Open Crate")
print("F4 = Toggle Fly")
print("F5 = Toggle Speed Hack")
print("F6 = Toggle ESP")
print("========================================")
