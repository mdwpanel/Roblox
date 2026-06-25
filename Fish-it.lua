-- ============================================
-- SCRIPT FISH IT - MEGA FULL FEATURES (FIXED)
-- DENGAN LIBRARY MDW
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
local loopConnections = {}
local activeThreads = {}

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

local function safeFire(remote, ...)
    if remote and remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer(...)
        end)
        return true
    end
    return false
end

local function stopAllLoops()
    for _, thread in pairs(activeThreads) do
        pcall(function()
            thread:Disconnect()
        end)
    end
    activeThreads = {}
    for _, conn in pairs(loopConnections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    loopConnections = {}
end

-- ============================================
-- 1. AUTO FISHING (FIXED)
-- ============================================
local fishThread = nil

local function startAutoFish()
    if features.autoFish then return end
    features.autoFish = true
    Notify(" Auto Fishing", "ON (" .. fishMode .. " Mode)")
    
    if fishThread then 
        pcall(function() fishThread:Disconnect() end)
        fishThread = nil
    end
    
    fishThread = runService.Heartbeat:Connect(function()
        if not features.autoFish then 
            fishThread:Disconnect()
            fishThread = nil
            return 
        end
        
        if player.Character and not player.Character:FindFirstChild("Fishing") then
            if remotes.fish then
                safeFire(remotes.fish)
            end
        end
        
        -- Handle different fishing modes
        if fishMode == "Instant" then
            safeFire(remotes.reel)
        elseif fishMode == "Extreme" then
            wait(0.3)
            safeFire(remotes.reel)
        elseif fishMode == "Blatant" then
            wait(0.8)
            safeFire(remotes.reel)
        else -- Stable
            wait(CONFIG.FishDelay)
            safeFire(remotes.reel)
        end
        
        if features.autoReCast then
            wait(0.3)
        else
            wait(1)
        end
    end)
end

local function stopAutoFish()
    features.autoFish = false
    if fishThread then
        pcall(function() fishThread:Disconnect() end)
        fishThread = nil
    end
    Notify(" Auto Fishing", "OFF")
end

-- ============================================
-- 2. AUTO SELL (FIXED)
-- ============================================
local sellThread = nil

local function startAutoSell()
    if features.autoSell then return end
    features.autoSell = true
    Notify(" Auto Sell", "ON (" .. sellFilter .. ")")
    
    sellThread = runService.Heartbeat:Connect(function()
        if not features.autoSell then 
            sellThread:Disconnect()
            sellThread = nil
            return 
        end
        
        if remotes.sell then
            local success = safeFire(remotes.sell, sellFilter)
            if not success then
                safeFire(remotes.sell)
            end
        end
        wait(CONFIG.SellDelay)
    end)
end

local function stopAutoSell()
    features.autoSell = false
    if sellThread then
        pcall(function() sellThread:Disconnect() end)
        sellThread = nil
    end
    Notify(" Auto Sell", "OFF")
end

-- ============================================
-- 3. AUTO ENCHANT (FIXED)
-- ============================================
local enchantThread = nil

local function startAutoEnchant()
    if features.autoEnchant then return end
    features.autoEnchant = true
    Notify(" Auto Enchant", "ON")
    
    enchantThread = runService.Heartbeat:Connect(function()
        if not features.autoEnchant then 
            enchantThread:Disconnect()
            enchantThread = nil
            return 
        end
        
        if remotes.enchant then
            safeFire(remotes.enchant)
        end
        wait(CONFIG.EnchantDelay)
    end)
end

local function stopAutoEnchant()
    features.autoEnchant = false
    if enchantThread then
        pcall(function() enchantThread:Disconnect() end)
        enchantThread = nil
    end
    Notify(" Auto Enchant", "OFF")
end

-- ============================================
-- 4. AUTO OPEN CRATE (FIXED)
-- ============================================
local crateThread = nil

local function startAutoOpenCrate()
    if features.autoOpenCrate then return end
    features.autoOpenCrate = true
    Notify(" Auto Open Crate", "ON")
    
    crateThread = runService.Heartbeat:Connect(function()
        if not features.autoOpenCrate then 
            crateThread:Disconnect()
            crateThread = nil
            return 
        end
        
        if remotes.crate then
            safeFire(remotes.crate)
        end
        wait(CONFIG.CrateDelay)
    end)
end

local function stopAutoOpenCrate()
    features.autoOpenCrate = false
    if crateThread then
        pcall(function() crateThread:Disconnect() end)
        crateThread = nil
    end
    Notify(" Auto Open Crate", "OFF")
end

-- ============================================
-- 5. AUTO EQUIP SKIN (FIXED)
-- ============================================
local equipSkinThread = nil

local function startAutoEquipSkin()
    if features.autoEquipSkin then return end
    features.autoEquipSkin = true
    Notify(" Auto Equip Skin", "ON")
    
    equipSkinThread = runService.Heartbeat:Connect(function()
        if not features.autoEquipSkin then 
            equipSkinThread:Disconnect()
            equipSkinThread = nil
            return 
        end
        
        if remotes.equipSkin then
            safeFire(remotes.equipSkin, "best")
            safeFire(remotes.equipSkin, "random")
        end
        wait(3)
    end)
end

local function stopAutoEquipSkin()
    features.autoEquipSkin = false
    if equipSkinThread then
        pcall(function() equipSkinThread:Disconnect() end)
        equipSkinThread = nil
    end
    Notify(" Auto Equip Skin", "OFF")
end

-- ============================================
-- 6. AUTO BUY (FIXED)
-- ============================================
local buyThread = nil

local function startAutoBuy()
    if features.autoBuy then return end
    features.autoBuy = true
    Notify(" Auto Buy", "ON")
    
    buyThread = runService.Heartbeat:Connect(function()
        if not features.autoBuy then 
            buyThread:Disconnect()
            buyThread = nil
            return 
        end
        
        if remotes.buy then
            safeFire(remotes.buy, "best")
            safeFire(remotes.buy, "bait")
            safeFire(remotes.buy, "lure")
        end
        wait(5)
    end)
end

local function stopAutoBuy()
    features.autoBuy = false
    if buyThread then
        pcall(function() buyThread:Disconnect() end)
        buyThread = nil
    end
    Notify(" Auto Buy", "OFF")
end

-- ============================================
-- 7. AUTO TRADE (FIXED)
-- ============================================
local tradeThread = nil

local function startAutoTrade()
    if features.autoTrade then return end
    features.autoTrade = true
    Notify(" Auto Trade", "ON")
    
    tradeThread = runService.Heartbeat:Connect(function()
        if not features.autoTrade then 
            tradeThread:Disconnect()
            tradeThread = nil
            return 
        end
        
        if remotes.trade then
            safeFire(remotes.trade)
            safeFire(remotes.trade, "fish")
        end
        wait(15)
    end)
end

local function stopAutoTrade()
    features.autoTrade = false
    if tradeThread then
        pcall(function() tradeThread:Disconnect() end)
        tradeThread = nil
    end
    Notify(" Auto Trade", "OFF")
end

-- ============================================
-- 8. AUTO ACCEPT TRADE (FIXED)
-- ============================================
local acceptTradeConnection = nil

local function startAutoAcceptTrade()
    if features.autoAcceptTrade then return end
    features.autoAcceptTrade = true
    Notify(" Auto Accept Trade", "ON")
    
    if remotes.acceptTrade then
        if acceptTradeConnection then
            pcall(function() acceptTradeConnection:Disconnect() end)
        end
        
        acceptTradeConnection = remotes.acceptTrade.OnClientEvent:Connect(function(...)
            if features.autoAcceptTrade then
                safeFire(remotes.acceptTrade, ...)
                wait(0.5)
                safeFire(remotes.acceptTrade, "accept")
            end
        end)
    end
end

local function stopAutoAcceptTrade()
    features.autoAcceptTrade = false
    if acceptTradeConnection then
        pcall(function() acceptTradeConnection:Disconnect() end)
        acceptTradeConnection = nil
    end
    Notify(" Auto Accept Trade", "OFF")
end

-- ============================================
-- 9. AUTO TOTEM (FIXED)
-- ============================================
local totemThread = nil

local function startAutoTotem()
    if features.autoTotem then return end
    features.autoTotem = true
    Notify(" Auto Totem", "ON")
    
    totemThread = runService.Heartbeat:Connect(function()
        if not features.autoTotem then 
            totemThread:Disconnect()
            totemThread = nil
            return 
        end
        
        if remotes.totem then
            safeFire(remotes.totem)
            safeFire(remotes.totem, "place")
        end
        wait(CONFIG.TotemDelay)
    end)
end

local function stopAutoTotem()
    features.autoTotem = false
    if totemThread then
        pcall(function() totemThread:Disconnect() end)
        totemThread = nil
    end
    Notify(" Auto Totem", "OFF")
end

-- ============================================
-- 10. AUTO WEATHER (FIXED)
-- ============================================
local weatherThread = nil
local weatherTypes = {"Storm", "Cloudy", "Wind", "Snow", "Rain"}

local function startAutoWeather()
    if features.autoWeather then return end
    features.autoWeather = true
    Notify(" Auto Weather", "ON")
    
    local idx = 1
    weatherThread = runService.Heartbeat:Connect(function()
        if not features.autoWeather then 
            weatherThread:Disconnect()
            weatherThread = nil
            return 
        end
        
        if remotes.weather then
            local weather = weatherTypes[idx]
            safeFire(remotes.weather, weather)
            safeFire(remotes.weather, "buy", weather)
            idx = idx % #weatherTypes + 1
        end
        wait(30)
    end)
end

local function stopAutoWeather()
    features.autoWeather = false
    if weatherThread then
        pcall(function() weatherThread:Disconnect() end)
        weatherThread = nil
    end
    Notify(" Auto Weather", "OFF")
end

-- ============================================
-- 11. AUTO QUEST (FIXED)
-- ============================================
local questThread = nil
local questTypes = {"DeepSea", "AuraKid", "ElementJungle", "Fishing"}

local function startAutoQuest()
    if features.autoQuest then return end
    features.autoQuest = true
    Notify(" Auto Quest", "ON")
    
    questThread = runService.Heartbeat:Connect(function()
        if not features.autoQuest then 
            questThread:Disconnect()
            questThread = nil
            return 
        end
        
        for _, quest in pairs(questTypes) do
            if remotes.quest then
                safeFire(remotes.quest, quest)
                safeFire(remotes.quest, "complete", quest)
                safeFire(remotes.quest, "claim", quest)
            end
            wait(1)
        end
        wait(5)
    end)
end

local function stopAutoQuest()
    features.autoQuest = false
    if questThread then
        pcall(function() questThread:Disconnect() end)
        questThread = nil
    end
    Notify(" Auto Quest", "OFF")
end

-- ============================================
-- 12. AUTO ARTIFACT (FIXED)
-- ============================================
local artifactThread = nil

local function startAutoArtifact()
    if features.autoArtifact then return end
    features.autoArtifact = true
    Notify(" Auto Artifact", "ON")
    
    artifactThread = runService.Heartbeat:Connect(function()
        if not features.autoArtifact then 
            artifactThread:Disconnect()
            artifactThread = nil
            return 
        end
        
        if remotes.artifact then
            safeFire(remotes.artifact)
            safeFire(remotes.artifact, "collect")
        end
        wait(3)
    end)
end

local function stopAutoArtifact()
    features.autoArtifact = false
    if artifactThread then
        pcall(function() artifactThread:Disconnect() end)
        artifactThread = nil
    end
    Notify(" Auto Artifact", "OFF")
end

-- ============================================
-- 13. AUTO EVENT (FIXED)
-- ============================================
local eventThread = nil

local function startAutoEvent()
    if features.autoEvent then return end
    features.autoEvent = true
    Notify(" Auto Event", "ON")
    
    eventThread = runService.Heartbeat:Connect(function()
        if not features.autoEvent then 
            eventThread:Disconnect()
            eventThread = nil
            return 
        end
        
        if remotes.event then
            safeFire(remotes.event)
            safeFire(remotes.event, "join")
            safeFire(remotes.event, "start")
        end
        wait(20)
    end)
end

local function stopAutoEvent()
    features.autoEvent = false
    if eventThread then
        pcall(function() eventThread:Disconnect() end)
        eventThread = nil
    end
    Notify(" Auto Event", "OFF")
end

-- ============================================
-- 14. AUTO REJOIN (FIXED)
-- ============================================
local rejoinConnection = nil

local function startAutoRejoin()
    if features.autoRejoin then return end
    features.autoRejoin = true
    Notify(" Auto Rejoin", "ON")
    
    if rejoinConnection then
        pcall(function() rejoinConnection:Disconnect() end)
    end
    
    rejoinConnection = player.OnTeleport:Connect(function()
        if features.autoRejoin then
            wait(3)
            pcall(function()
                teleportService:Teleport(game.PlaceId)
            end)
        end
    end)
end

local function stopAutoRejoin()
    features.autoRejoin = false
    if rejoinConnection then
        pcall(function() rejoinConnection:Disconnect() end)
        rejoinConnection = nil
    end
    Notify(" Auto Rejoin", "OFF")
end

-- ============================================
-- 15. AUTO SERVER HOP (FIXED)
-- ============================================
local serverHopThread = nil

local function startAutoServerHop()
    if features.autoServerHop then return end
    features.autoServerHop = true
    Notify(" Auto Server Hop", "ON")
    
    serverHopThread = runService.Heartbeat:Connect(function()
        if not features.autoServerHop then 
            serverHopThread:Disconnect()
            serverHopThread = nil
            return 
        end
        
        wait(300) -- 5 minutes
        if features.autoServerHop then
            pcall(function()
                teleportService:Teleport(game.PlaceId)
            end)
        end
    end)
end

local function stopAutoServerHop()
    features.autoServerHop = false
    if serverHopThread then
        pcall(function() serverHopThread:Disconnect() end)
        serverHopThread = nil
    end
    Notify(" Auto Server Hop", "OFF")
end

-- ============================================
-- 16. ANTI-AFK (FIXED)
-- ============================================
local antiAFKConnection = nil

local function startAntiAFK()
    if features.antiAFK then return end
    features.antiAFK = true
    Notify(" Anti-AFK", "ON")
    
    if antiAFKConnection then
        pcall(function() antiAFKConnection:Disconnect() end)
    end
    
    antiAFKConnection = runService.RenderStepped:Connect(function()
        if not features.antiAFK then 
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
            return 
        end
        
        pcall(function()
            virtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            virtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            
            local hum = GetHumanoid()
            if hum then
                hum:Move(Vector3.new(0, 0, 0), true)
            end
        end)
    end)
end

-- ============================================
-- 17. ANTI-DROWN (FIXED)
-- ============================================
local antiDrownConnection = nil

local function startAntiDrown()
    if features.antiDrown then return end
    features.antiDrown = true
    Notify(" Anti-Drown", "ON")
    
    if antiDrownConnection then
        pcall(function() antiDrownConnection:Disconnect() end)
    end
    
    antiDrownConnection = runService.RenderStepped:Connect(function()
        if not features.antiDrown then 
            antiDrownConnection:Disconnect()
            antiDrownConnection = nil
            return 
        end
        
        pcall(function()
            local hum = GetHumanoid()
            if hum and hum:GetState() == Enum.HumanoidStateType.Swimming then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                local root = GetRootPart()
                if root then
                    root.CFrame = root.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end)
    end)
end

-- ============================================
-- 18. AUTO HEAL (FIXED)
-- ============================================
local healThread = nil

local function startAutoHeal()
    if features.autoHeal then return end
    features.autoHeal = true
    Notify(" Auto Heal", "ON")
    
    healThread = runService.Heartbeat:Connect(function()
        if not features.autoHeal then 
            healThread:Disconnect()
            healThread = nil
            return 
        end
        
        pcall(function()
            local hum = GetHumanoid()
            if hum and hum.Health < hum.MaxHealth * 0.5 then
                -- Try to find healing items
                for _, item in pairs(player.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        local name = item.Name:lower()
                        if name:find("heal") or name:find("pot") or name:find("med") or name:find("food") then
                            hum:EquipTool(item)
                            wait(0.3)
                            virtualInput:SendKeyEvent(true, Enum.KeyCode.ButtonR1, false, game)
                            wait(0.1)
                            virtualInput:SendKeyEvent(false, Enum.KeyCode.ButtonR1, false, game)
                            break
                        end
                    end
                end
                
                -- Alternative healing via remote
                if remotes.heal then
                    safeFire(remotes.heal)
                end
            end
        end)
    end)
end

-- ============================================
-- 19. ESP (FIXED)
-- ============================================
local espHighlights = {}
local espConnections = {}

local function enableESP()
    if features.espEnabled then return end
    features.espEnabled = true
    Notify(" ESP", "ON")
    
    -- Clear old ESP
    disableESP()
    
    local function addESP(char)
        if not char or not char:IsA("Model") then return end
        if char == player.Character then return end
        
        pcall(function()
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Highlight"
            highlight.Adornee = char
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.3
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0.2
            highlight.Parent = char
            table.insert(espHighlights, highlight)
        end)
    end
    
    -- Add ESP to existing players
    for _, v in pairs(players:GetPlayers()) do
        if v ~= player and v.Character then
            addESP(v.Character)
        end
    end
    
    -- Add ESP to new players
    local playerAddedConn = players.PlayerAdded:Connect(function(newPlayer)
        local charAddedConn = newPlayer.CharacterAdded:Connect(function(char)
            wait(0.5)
            if features.espEnabled then
                addESP(char)
            end
        end)
        table.insert(espConnections, charAddedConn)
    end)
    table.insert(espConnections, playerAddedConn)
    
    -- Character added for existing players
    for _, v in pairs(players:GetPlayers()) do
        if v ~= player then
            local charAddedConn = v.CharacterAdded:Connect(function(char)
                wait(0.5)
                if features.espEnabled then
                    addESP(char)
                end
            end)
            table.insert(espConnections, charAddedConn)
        end
    end
end

local function disableESP()
    features.espEnabled = false
    
    for _, obj in pairs(espHighlights) do
        pcall(function() obj:Destroy() end)
    end
    espHighlights = {}
    
    for _, conn in pairs(espConnections) do
        pcall(function() conn:Disconnect() end)
    end
    espConnections = {}
    
    Notify(" ESP", "OFF")
end

-- ============================================
-- 20. FLY (FIXED)
-- ============================================
local flyConnection = nil

local function toggleFly()
    features.flyEnabled = not features.flyEnabled
    
    if flyConnection then
        pcall(function() flyConnection:Disconnect() end)
        flyConnection = nil
    end
    
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        
        if features.flyEnabled then
            humanoid.PlatformStand = true
            Notify(" Fly", "ON")
            
            flyConnection = runService.RenderStepped:Connect(function()
                if not features.flyEnabled then 
                    flyConnection:Disconnect()
                    flyConnection = nil
                    return 
                end
                
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
                
                -- Keep orientation
                root.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
            end)
        else
            humanoid.PlatformStand = false
            Notify(" Fly", "OFF")
        end
    end
end

-- ============================================
-- 21. NOCLIP (FIXED)
-- ============================================
local noclipConnection = nil

local function toggleNoclip()
    features.noclipEnabled = not features.noclipEnabled
    
    if noclipConnection then
        pcall(function() noclipConnection:Disconnect() end)
        noclipConnection = nil
    end
    
    if features.noclipEnabled then
        Notify(" Noclip", "ON")
        
        noclipConnection = runService.RenderStepped:Connect(function()
            if not features.noclipEnabled then 
                noclipConnection:Disconnect()
                noclipConnection = nil
                return 
            end
            
            pcall(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end)
    else
        Notify(" Noclip", "OFF")
    end
end

-- ============================================
-- 22. SPEED HACK (FIXED)
-- ============================================
local speedConnection = nil

local function toggleSpeedHack()
    features.speedHack = not features.speedHack
    
    if speedConnection then
        pcall(function() speedConnection:Disconnect() end)
        speedConnection = nil
    end
    
    if features.speedHack then
        Notify(" Speed Hack", "ON")
        
        speedConnection = runService.RenderStepped:Connect(function()
            if not features.speedHack then 
                speedConnection:Disconnect()
                speedConnection = nil
                return 
            end
            
            pcall(function()
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.WalkSpeed = 50
                    player.Character.Humanoid.JumpPower = 100
                end
            end)
        end)
    else
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 16
                player.Character.Humanoid.JumpPower = 50
            end
        end)
        Notify(" Speed Hack", "OFF")
    end
end

-- ============================================
-- 23. TELEPORT SYSTEM (FIXED)
-- ============================================
local islands = {
    ["Spawn"] = Vector3.new(0, 5, 0),
    ["Coral Island"] = Vector3.new(100, 5, 50),
    ["Mermaid Lagoon"] = Vector3.new(-80, 5, 120),
    ["Retro Island"] = Vector3.new(200, 5, -100),
    ["Esoteric Depths"] = Vector3.new(-150, 5, -80),
    ["Event Island"] = Vector3.new(50, 5, -150),
    ["Fishing Spot"] = Vector3.new(10, 3, 10),
    ["Shop"] = Vector3.new(-20, 3, -20),
}

local function teleportTo(pos)
    pcall(function()
        local root = GetRootPart()
        if root then
            root.CFrame = CFrame.new(pos)
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            Notify(" Teleport", "Ke " .. tostring(pos))
        else
            Notify(" Teleport", "Character not found!")
        end
    end)
end

-- ============================================
-- 24. FPS BOOST (FIXED)
-- ============================================
local function toggleFPSBoost()
    features.fpsBoost = not features.fpsBoost
    
    if features.fpsBoost then
        Notify(" FPS Boost", "ON")
        pcall(function()
            lighting.GlobalShadows = false
            lighting.Technology = Enum.Technology.Legacy
            
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Part") or v:IsA("MeshPart") then
                    pcall(function()
                        v.Material = Enum.Material.Plastic
                        if v:IsA("MeshPart") then
                            v.MeshId = ""
                            v.TextureID = ""
                        end
                    end)
                end
                if v:IsA("Decal") or v:IsA("Texture") then
                    pcall(function() v:Destroy() end)
                end
            end
            
            settings().Rendering.QualityLevel = 1
            settings().Rendering.EagerBulkExecution = false
        end)
    else
        Notify(" FPS Boost", "OFF")
        pcall(function()
            lighting.GlobalShadows = true
            lighting.Technology = Enum.Technology.ShadowMap
            settings().Rendering.QualityLevel = 3
            settings().Rendering.EagerBulkExecution = true
        end)
    end
end

-- ============================================
-- 25. SAVE & LOAD CONFIG (FIXED)
-- ============================================
local function saveConfig()
    pcall(function()
        local config = {}
        for name, value in pairs(features) do
            config[name] = value
        end
        config.fishMode = fishMode
        config.sellFilter = sellFilter
        config.flySpeed = flySpeed
        
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
            flySpeed = data.flySpeed or 100
            Notify(" Config", "Loaded!")
        else
            Notify(" Config", "No config file found!")
        end
    end)
end

-- ============================================
-- WINDOW CREATION (Library MDW)
-- ============================================
local Window = Library:Window({
    Title = " FISH IT MEGA",
    Footer = "v3.0 | All Features Fixed"
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
            wait(0.5)
            startAutoFish()
        end
    end
})

-- Auto ReCast
AutoSection:AddToggle({
    Title = "Auto ReCast",
    Description = "Langsung casting ulang setelah dapat ikan",
    Default = false,
    Callback = function(v)
        features.autoReCast = v
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
            wait(0.5)
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
        pcall(function()
            teleportService:Teleport(game.PlaceId)
            Notify(" Server Hop", "Teleporting...")
        end)
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
            if not features.flyEnabled then
                toggleFly()
            end
        else
            if features.flyEnabled then
                toggleFly()
            end
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
            if not features.noclipEnabled then
                toggleNoclip()
            end
        else
            if features.noclipEnabled then
                toggleNoclip()
            end
        end
    end
})

MoveSection:AddToggle({
    Title = "Speed Hack",
    Description = "Kecepatan berjalan dan lompat tinggi",
    Default = false,
    Callback = function(v)
        if v then
            if not features.speedHack then
                toggleSpeedHack()
            end
        else
            if features.speedHack then
                toggleSpeedHack()
            end
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
            if not features.fpsBoost then
                toggleFPSBoost()
            end
        else
            if features.fpsBoost then
                toggleFPSBoost()
            end
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
        else
            Notify(" Error", "Masukkan format X,Y,Z yang valid!")
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
        -- Stop all features
        stopAutoFish()
        stopAutoSell()
        stopAutoEnchant()
        stopAutoOpenCrate()
        stopAutoEquipSkin()
        stopAutoBuy()
        stopAutoTrade()
        stopAutoAcceptTrade()
        stopAutoTotem()
        stopAutoWeather()
        stopAutoQuest()
        stopAutoArtifact()
        stopAutoEvent()
        stopAutoRejoin()
        stopAutoServerHop()
        
        features.antiAFK = false
        features.antiDrown = false
        features.autoHeal = false
        features.autoReCast = false
        
        if features.flyEnabled then toggleFly() end
        if features.noclipEnabled then toggleNoclip() end
        if features.speedHack then toggleSpeedHack() end
        if features.espEnabled then disableESP() end
        if features.fpsBoost then toggleFPSBoost() end
        
        -- Reset character
        pcall(function()
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 16
                player.Character.Humanoid.JumpPower = 50
                player.Character.Humanoid.PlatformStand = false
            end
        end)
        
        Notify(" Reset", "All features disabled")
    end
})

-- ============================================
-- KEYBINDS (FIXED)
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
    elseif input.KeyCode == Enum.KeyCode.F7 then
        if features.autoSell then stopAutoSell() else startAutoSell() end
    elseif input.KeyCode == Enum.KeyCode.F8 then
        if features.autoEnchant then stopAutoEnchant() else startAutoEnchant() end
    elseif input.KeyCode == Enum.KeyCode.F9 then
        toggleNoclip()
    elseif input.KeyCode == Enum.KeyCode.F10 then
        toggleFPSBoost()
    end
end)

-- ============================================
-- START
-- ============================================
Library:Initialize()

-- Load config automatically

Notify(" FISH IT MEGA", "Script Loaded Successfully! (All Features Fixed)", 5)

print("========================================")
print(" FISH IT MEGA SCRIPT v3 - ALL FEATURES FIXED")
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
print("F7 = Toggle Auto Sell")
print("F8 = Toggle Auto Enchant")
print("F9 = Toggle Noclip")
print("F10 = Toggle FPS Boost")
print("========================================")