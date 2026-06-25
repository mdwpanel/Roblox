-- ============================================
-- FISH IT MEGA - FULLY FIXED & ENHANCED
-- Dengan Library MDW Modern
-- ============================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mdwpanel/Roblox/refs/heads/main/main_ui_modern.lua"))()

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local camera = Workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

-- ============================================
-- KONFIGURASI UTAMA
-- ============================================
local CONFIG = {
    -- Remote Names (coba berbagai variasi nama)
    FishingRemotes = {"FishingEvent", "Fish", "CastRod", "StartFishing", "Cast", "Reel", "CatchFish"},
    SellRemotes = {"SellFish", "Sell", "SellAll", "SellInventory"},
    EnchantRemotes = {"EnchantRod", "Enchant", "ApplyEnchant"},
    CrateRemotes = {"OpenCrate", "OpenBox", "Crate", "Unbox"},
    EquipRemotes = {"EquipSkin", "Equip", "EquipRod", "ChangeSkin"},
    BuyRemotes = {"BuyItem", "Buy", "Purchase"},
    TradeRemotes = {"Trade", "RequestTrade"},
    AcceptTradeRemotes = {"AcceptTrade", "Accept", "ConfirmTrade"},
    TotemRemotes = {"PlaceTotem", "UseTotem", "Totem"},
    WeatherRemotes = {"BuyWeather", "ChangeWeather", "Weather"},
    QuestRemotes = {"CompleteQuest", "Quest", "FinishQuest"},
    ArtifactRemotes = {"CollectArtifact", "Artifact", "Collect"},
    EventRemotes = {"JoinEvent", "Event", "Participate"},
    
    -- Timing
    FishDelay = 1.5,
    SellDelay = 3,
    CrateDelay = 2,
    EnchantDelay = 3,
    TotemDelay = 120,
    HealThreshold = 0.4,
    
    -- Default Positions
    SafePosition = Vector3.new(0, 50, 0),
    FishingSpots = {
        Vector3.new(0, 5, 0),
        Vector3.new(50, 5, 50),
        Vector3.new(-50, 5, -50)
    }
}

-- ============================================
-- VARIABEL STATE (semua fitur dimatikan secara default)
-- ============================================
local Features = {
    -- Automation
    AutoFish = false,
    AutoSell = false,
    AutoEnchant = false,
    AutoOpenCrate = false,
    AutoEquipSkin = false,
    AutoBuy = false,
    AutoTrade = false,
    AutoAcceptTrade = false,
    AutoTotem = false,
    AutoWeather = false,
    AutoQuest = false,
    AutoArtifact = false,
    AutoEvent = false,
    
    -- Server
    AutoRejoin = false,
    AutoServerHop = false,
    
    -- Protection
    AntiAFK = false,
    AntiDrown = false,
    AntiKick = false,
    AutoHeal = false,
    
    -- Visual
    ESP = false,
    FishESP = false,
    CrateESP = false,
    NPCESP = false,
    
    -- Movement
    Fly = false,
    Noclip = false,
    SpeedHack = false,
    InfiniteJump = false,
    
    -- Misc
    FPSBoost = false,
    FullBright = false,
    InstantCatch = false,
    PerfectReel = false,
    AutoReCast = true,
    AutoCollect = false,
}

-- Settings
local Settings = {
    FishMode = "Stable",
    SellFilter = "All",
    FlySpeed = 100,
    WalkSpeed = 50,
    JumpPower = 100,
    ESPColor = Color3.fromRGB(255, 0, 0),
    FishESPColor = Color3.fromRGB(0, 255, 255),
    SelectedIsland = "Spawn",
    AutoSave = true,
}

-- ============================================
-- REMOTE FINDER (IMPROVED)
-- ============================================
local Remotes = {}

local function FindRemote(namePatterns)
    for _, pattern in ipairs(namePatterns) do
        -- Cari di ReplicatedStorage
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                if obj.Name:lower():find(pattern:lower()) then
                    return obj
                end
            end
        end
        
        -- Cari di workspace
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                if obj.Name:lower():find(pattern:lower()) then
                    return obj
                end
            end
        end
    end
    return nil
end

-- Initialize Remotes
local function InitializeRemotes()
    Remotes.Fish = FindRemote(CONFIG.FishingRemotes)
    Remotes.Sell = FindRemote(CONFIG.SellRemotes)
    Remotes.Enchant = FindRemote(CONFIG.EnchantRemotes)
    Remotes.Crate = FindRemote(CONFIG.CrateRemotes)
    Remotes.Equip = FindRemote(CONFIG.EquipRemotes)
    Remotes.Buy = FindRemote(CONFIG.BuyRemotes)
    Remotes.Trade = FindRemote(CONFIG.TradeRemotes)
    Remotes.AcceptTrade = FindRemote(CONFIG.AcceptTradeRemotes)
    Remotes.Totem = FindRemote(CONFIG.TotemRemotes)
    Remotes.Weather = FindRemote(CONFIG.WeatherRemotes)
    Remotes.Quest = FindRemote(CONFIG.QuestRemotes)
    Remotes.Artifact = FindRemote(CONFIG.ArtifactRemotes)
    Remotes.Event = FindRemote(CONFIG.EventRemotes)
    
    -- Debug info
    for name, remote in pairs(Remotes) do
        if remote then
            print("[] Remote found:", name, "->", remote.Name)
        else
            warn("[] Remote not found:", name)
        end
    end
end

-- ============================================
-- HELPER FUNCTIONS
-- ============================================
local function GetCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function Notify(title, desc, duration)
    pcall(function()
        Library:MakeNotify({
            Title = title or "Notification",
            Content = desc or "",
            Duration = duration or 3
        })
    end)
end

local function SafeFireServer(remote, ...)
    if remote and remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer(...)
        end)
        return true
    elseif remote and remote:IsA("RemoteFunction") then
        pcall(function()
            remote:InvokeServer(...)
        end)
        return true
    end
    return false
end

-- ============================================
-- CONNECTION MANAGER (Anti Memory Leak)
-- ============================================
local ActiveConnections = {}

local function AddConnection(name, connection)
    if ActiveConnections[name] then
        pcall(function() ActiveConnections[name]:Disconnect() end)
    end
    ActiveConnections[name] = connection
end

local function RemoveConnection(name)
    if ActiveConnections[name] then
        pcall(function() ActiveConnections[name]:Disconnect() end)
        ActiveConnections[name] = nil
    end
end

local function StopAllFeatures()
    for feature, _ in pairs(Features) do
        Features[feature] = false
    end
    
    for name, _ in pairs(ActiveConnections) do
        RemoveConnection(name)
    end
    
    -- Reset character
    local hum = GetHumanoid()
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum.PlatformStand = false
    end
    
    -- Clear ESP
    ClearESP()
    
    Notify(" System", "All features stopped!")
end

-- ============================================
-- 1. AUTO FISHING (FIXED)
-- ============================================
local function StartAutoFish()
    if not Remotes.Fish then
        Notify(" Error", "Fishing remote not found!")
        return
    end
    
    Features.AutoFish = true
    Notify(" Auto Fishing", "ON [" .. Settings.FishMode .. "]")
    
    AddConnection("AutoFish", task.spawn(function()
        while Features.AutoFish do
            task.wait()
            
            local char = GetCharacter()
            local hum = GetHumanoid()
            if not hum or hum.Health <= 0 then
                task.wait(2)
                continue
            end
            
            -- Check if already fishing
            local isFishing = char:FindFirstChild("Fishing") or 
                             char:FindFirstChild("FishingRod") or
                             player:FindFirstChild("Fishing")
            
            if not isFishing then
                SafeFireServer(Remotes.Fish)
                task.wait(0.5)
            end
            
            -- Reel logic based on mode
            if Settings.FishMode == "Instant" then
                SafeFireServer(Remotes.Fish, "Reel") -- Try different args
                SafeFireServer(Remotes.Fish, "Catch")
                task.wait(0.3)
            elseif Settings.FishMode == "Extreme" then
                task.wait(0.8)
                SafeFireServer(Remotes.Fish, "Reel")
                task.wait(0.2)
            elseif Settings.FishMode == "Blatant" then
                task.wait(1.2)
                SafeFireServer(Remotes.Fish, "Reel")
                task.wait(0.5)
            else -- Stable
                task.wait(CONFIG.FishDelay)
                SafeFireServer(Remotes.Fish, "Reel")
                task.wait(1)
            end
            
            -- Auto re-cast
            if Features.AutoReCast then
                task.wait(0.5)
            else
                task.wait(1.5)
            end
        end
    end))
end

local function StopAutoFish()
    Features.AutoFish = false
    RemoveConnection("AutoFish")
    Notify(" Auto Fishing", "OFF")
end

-- ============================================
-- 2. AUTO SELL (FIXED)
-- ============================================
local function StartAutoSell()
    if not Remotes.Sell then
        Notify(" Error", "Sell remote not found!")
        return
    end
    
    Features.AutoSell = true
    Notify(" Auto Sell", "ON [" .. Settings.SellFilter .. "]")
    
    AddConnection("AutoSell", task.spawn(function()
        while Features.AutoSell do
            local args = Settings.SellFilter == "All" and "All" or {Settings.SellFilter}
            SafeFireServer(Remotes.Sell, args)
            task.wait(CONFIG.SellDelay)
        end
    end))
end

local function StopAutoSell()
    Features.AutoSell = false
    RemoveConnection("AutoSell")
    Notify(" Auto Sell", "OFF")
end

-- ============================================
-- 3. AUTO ENCHANT (FIXED)
-- ============================================
local function StartAutoEnchant()
    if not Remotes.Enchant then
        Notify(" Error", "Enchant remote not found!")
        return
    end
    
    Features.AutoEnchant = true
    Notify(" Auto Enchant", "ON")
    
    AddConnection("AutoEnchant", task.spawn(function()
        while Features.AutoEnchant do
            SafeFireServer(Remotes.Enchant, "Enchant")
            task.wait(CONFIG.EnchantDelay)
        end
    end))
end

local function StopAutoEnchant()
    Features.AutoEnchant = false
    RemoveConnection("AutoEnchant")
    Notify(" Auto Enchant", "OFF")
end

-- ============================================
-- 4. AUTO OPEN CRATE (FIXED)
-- ============================================
local function StartAutoOpenCrate()
    if not Remotes.Crate then
        Notify(" Error", "Crate remote not found!")
        return
    end
    
    Features.AutoOpenCrate = true
    Notify(" Auto Open Crate", "ON")
    
    AddConnection("AutoOpenCrate", task.spawn(function()
        while Features.AutoOpenCrate do
            SafeFireServer(Remotes.Crate, "Open")
            task.wait(CONFIG.CrateDelay)
        end
    end))
end

local function StopAutoOpenCrate()
    Features.AutoOpenCrate = false
    RemoveConnection("AutoOpenCrate")
    Notify(" Auto Open Crate", "OFF")
end

-- ============================================
-- 5. AUTO EQUIP SKIN (FIXED)
-- ============================================
local function StartAutoEquipSkin()
    if not Remotes.Equip then
        Notify(" Error", "Equip remote not found!")
        return
    end
    
    Features.AutoEquipSkin = true
    Notify(" Auto Equip Skin", "ON")
    
    AddConnection("AutoEquipSkin", task.spawn(function()
        while Features.AutoEquipSkin do
            SafeFireServer(Remotes.Equip, "Best")
            task.wait(5)
        end
    end))
end

local function StopAutoEquipSkin()
    Features.AutoEquipSkin = false
    RemoveConnection("AutoEquipSkin")
    Notify(" Auto Equip Skin", "OFF")
end

-- ============================================
-- 6. AUTO BUY (FIXED)
-- ============================================
local function StartAutoBuy()
    if not Remotes.Buy then
        Notify(" Error", "Buy remote not found!")
        return
    end
    
    Features.AutoBuy = true
    Notify(" Auto Buy", "ON")
    
    AddConnection("AutoBuy", task.spawn(function()
        while Features.AutoBuy do
            SafeFireServer(Remotes.Buy, "Bait", "Best")
            task.wait(10)
            SafeFireServer(Remotes.Buy, "Rod", "Upgrade")
            task.wait(5)
        end
    end))
end

local function StopAutoBuy()
    Features.AutoBuy = false
    RemoveConnection("AutoBuy")
    Notify(" Auto Buy", "OFF")
end

-- ============================================
-- 7. AUTO TRADE (FIXED)
-- ============================================
local function StartAutoTrade()
    if not Remotes.Trade then
        Notify(" Error", "Trade remote not found!")
        return
    end
    
    Features.AutoTrade = true
    Notify(" Auto Trade", "ON")
    
    AddConnection("AutoTrade", task.spawn(function()
        while Features.AutoTrade do
            for _, target in pairs(Players:GetPlayers()) do
                if target ~= player then
                    SafeFireServer(Remotes.Trade, target)
                    break
                end
            end
            task.wait(30)
        end
    end))
end

local function StopAutoTrade()
    Features.AutoTrade = false
    RemoveConnection("AutoTrade")
    Notify(" Auto Trade", "OFF")
end

-- ============================================
-- 8. AUTO ACCEPT TRADE (FIXED)
-- ============================================
local function StartAutoAcceptTrade()
    if not Remotes.AcceptTrade then
        Notify(" Error", "AcceptTrade remote not found!")
        return
    end
    
    Features.AutoAcceptTrade = true
    Notify(" Auto Accept Trade", "ON")
    
    AddConnection("AutoAcceptTrade", Remotes.AcceptTrade.OnClientEvent:Connect(function(...)
        if Features.AutoAcceptTrade then
            task.wait(1)
            SafeFireServer(Remotes.AcceptTrade, true)
        end
    end))
end

local function StopAutoAcceptTrade()
    Features.AutoAcceptTrade = false
    RemoveConnection("AutoAcceptTrade")
    Notify(" Auto Accept Trade", "OFF")
end

-- ============================================
-- 9. AUTO TOTEM (FIXED)
-- ============================================
local function StartAutoTotem()
    if not Remotes.Totem then
        Notify(" Error", "Totem remote not found!")
        return
    end
    
    Features.AutoTotem = true
    Notify(" Auto Totem", "ON")
    
    AddConnection("AutoTotem", task.spawn(function()
        while Features.AutoTotem do
            SafeFireServer(Remotes.Totem, "Place")
            task.wait(CONFIG.TotemDelay)
        end
    end))
end

local function StopAutoTotem()
    Features.AutoTotem = false
    RemoveConnection("AutoTotem")
    Notify(" Auto Totem", "OFF")
end

-- ============================================
-- 10. AUTO WEATHER (FIXED)
-- ============================================
local WeatherTypes = {"Storm", "Cloudy", "Wind", "Snow", "Rain", "Sunny"}

local function StartAutoWeather()
    if not Remotes.Weather then
        Notify(" Error", "Weather remote not found!")
        return
    end
    
    Features.AutoWeather = true
    Notify(" Auto Weather", "ON")
    
    AddConnection("AutoWeather", task.spawn(function()
        local idx = 1
        while Features.AutoWeather do
            SafeFireServer(Remotes.Weather, WeatherTypes[idx])
            idx = idx % #WeatherTypes + 1
            task.wait(60)
        end
    end))
end

local function StopAutoWeather()
    Features.AutoWeather = false
    RemoveConnection("AutoWeather")
    Notify(" Auto Weather", "OFF")
end

-- ============================================
-- 11. AUTO QUEST (FIXED)
-- ============================================
local QuestTypes = {"Daily", "Weekly", "DeepSea", "Legendary", "Event"}

local function StartAutoQuest()
    if not Remotes.Quest then
        Notify(" Error", "Quest remote not found!")
        return
    end
    
    Features.AutoQuest = true
    Notify(" Auto Quest", "ON")
    
    AddConnection("AutoQuest", task.spawn(function()
        while Features.AutoQuest do
            for _, quest in ipairs(QuestTypes) do
                SafeFireServer(Remotes.Quest, "Complete", quest)
                task.wait(2)
            end
            task.wait(10)
        end
    end))
end

local function StopAutoQuest()
    Features.AutoQuest = false
    RemoveConnection("AutoQuest")
    Notify(" Auto Quest", "OFF")
end

-- ============================================
-- 12. AUTO ARTIFACT (FIXED)
-- ============================================
local function StartAutoArtifact()
    if not Remotes.Artifact then
        Notify(" Error", "Artifact remote not found!")
        return
    end
    
    Features.AutoArtifact = true
    Notify(" Auto Artifact", "ON")
    
    AddConnection("AutoArtifact", task.spawn(function()
        while Features.AutoArtifact do
            SafeFireServer(Remotes.Artifact, "Collect")
            task.wait(5)
        end
    end))
end

local function StopAutoArtifact()
    Features.AutoArtifact = false
    RemoveConnection("AutoArtifact")
    Notify(" Auto Artifact", "OFF")
end

-- ============================================
-- 13. AUTO EVENT (FIXED)
-- ============================================
local function StartAutoEvent()
    if not Remotes.Event then
        Notify(" Error", "Event remote not found!")
        return
    end
    
    Features.AutoEvent = true
    Notify(" Auto Event", "ON")
    
    AddConnection("AutoEvent", task.spawn(function()
        while Features.AutoEvent do
            SafeFireServer(Remotes.Event, "Join")
            task.wait(30)
        end
    end))
end

local function StopAutoEvent()
    Features.AutoEvent = false
    RemoveConnection("AutoEvent")
    Notify(" Auto Event", "OFF")
end

-- ============================================
-- 14. AUTO REJOIN (FIXED)
-- ============================================
local function StartAutoRejoin()
    Features.AutoRejoin = true
    Notify(" Auto Rejoin", "ON")
    
    AddConnection("AutoRejoin", player.OnTeleport:Connect(function(state)
        if Features.AutoRejoin and state == Enum.TeleportState.Failed then
            task.wait(5)
            TeleportService:Teleport(game.PlaceId)
        end
    end))
end

local function StopAutoRejoin()
    Features.AutoRejoin = false
    RemoveConnection("AutoRejoin")
    Notify(" Auto Rejoin", "OFF")
end

-- ============================================
-- 15. AUTO SERVER HOP (FIXED)
-- ============================================
local function StartAutoServerHop()
    Features.AutoServerHop = true
    Notify(" Auto Server Hop", "ON")
    
    AddConnection("AutoServerHop", task.spawn(function()
        while Features.AutoServerHop do
            task.wait(300) -- 5 menit
            if Features.AutoServerHop then
                pcall(function()
                    TeleportService:Teleport(game.PlaceId)
                end)
            end
        end
    end))
end

local function StopAutoServerHop()
    Features.AutoServerHop = false
    RemoveConnection("AutoServerHop")
    Notify(" Auto Server Hop", "OFF")
end

-- ============================================
-- 16. ANTI-AFK (FIXED)
-- ============================================
local function StartAntiAFK()
    Features.AntiAFK = true
    Notify(" Anti-AFK", "ON")
    
    AddConnection("AntiAFK", RunService.Heartbeat:Connect(function()
        if Features.AntiAFK then
            local hum = GetHumanoid()
            if hum then
                hum:Move(Vector3.new(math.random(-1,1), 0, math.random(-1,1)), false)
            end
            
            -- Simulate mouse activity
            pcall(function()
                VirtualInputManager:SendMouseMovementEvent(0, 0, 0, game)
            end)
        end
    end))
end

local function StopAntiAFK()
    Features.AntiAFK = false
    RemoveConnection("AntiAFK")
    Notify(" Anti-AFK", "OFF")
end

-- ============================================
-- 17. ANTI-DROWN (FIXED)
-- ============================================
local function StartAntiDrown()
    Features.AntiDrown = true
    Notify(" Anti-Drown", "ON")
    
    AddConnection("AntiDrown", RunService.Heartbeat:Connect(function()
        if Features.AntiDrown then
            local hum = GetHumanoid()
            if hum and hum:GetState() == Enum.HumanoidStateType.Swimming then
                -- Keep health full while swimming
                if hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
                -- Auto jump to surface
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
end

local function StopAntiDrown()
    Features.AntiDrown = false
    RemoveConnection("AntiDrown")
    Notify(" Anti-Drown", "OFF")
end

-- ============================================
-- 18. ANTI-KICK (NEW)
-- ============================================
local function StartAntiKick()
    Features.AntiKick = true
    Notify(" Anti-Kick", "ON")
    
    -- Hook kick function
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" and Features.AntiKick then
            Notify(" Anti-Kick", "Kick blocked!")
            return nil
        end
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
end

-- ============================================
-- 19. AUTO HEAL (FIXED)
-- ============================================
local function StartAutoHeal()
    Features.AutoHeal = true
    Notify(" Auto Heal", "ON")
    
    AddConnection("AutoHeal", task.spawn(function()
        while Features.AutoHeal do
            local hum = GetHumanoid()
            if hum and hum.Health < hum.MaxHealth * CONFIG.HealThreshold then
                -- Search for healing items
                local backpack = player:FindFirstChild("Backpack")
                if backpack then
                    for _, item in pairs(backpack:GetChildren()) do
                        if item:IsA("Tool") then
                            local name = item.Name:lower()
                            if name:find("heal") or name:find("pot") or name:find("med") or 
                               name:find("food") or name:find("bandage") then
                                pcall(function()
                                    hum:EquipTool(item)
                                    task.wait(0.5)
                                    item:Activate()
                                end)
                                break
                            end
                        end
                    end
                end
            end
            task.wait(2)
        end
    end))
end

local function StopAutoHeal()
    Features.AutoHeal = false
    RemoveConnection("AutoHeal")
    Notify(" Auto Heal", "OFF")
end

-- ============================================
-- 20. ESP SYSTEM (FIXED & ENHANCED)
-- ============================================
local ESPObjects = {}

local function CreateESP(target, color, name)
    if not target then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "FishIt_ESP"
    highlight.Adornee = target
    highlight.FillColor = color or Settings.ESPColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.Parent = target
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "FishIt_Label"
    billboard.Adornee = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head") or target
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target
    
    local label = Instance.new("TextLabel")
    label.Name = "NameLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Settings.ESPColor
    label.TextStrokeTransparency = 0.5
    label.TextScaled = true
    label.Text = name or target.Name
    label.Parent = billboard
    
    table.insert(ESPObjects, {Highlight = highlight, Billboard = billboard})
    
    return highlight, billboard
end

local function ClearESP()
    for _, obj in ipairs(ESPObjects) do
        pcall(function()
            if obj.Highlight then obj.Highlight:Destroy() end
            if obj.Billboard then obj.Billboard:Destroy() end
        end)
    end
    ESPObjects = {}
end

-- Player ESP
local function EnablePlayerESP()
    Features.ESP = true
    Notify(" Player ESP", "ON")
    
    local function AddPlayerESP(p)
        if p == player then return end
        p.CharacterAdded:Connect(function(char)
            task.wait(1)
            if Features.ESP then
                CreateESP(char, Settings.ESPColor, p.Name)
            end
        end)
        
        if p.Character then
            CreateESP(p.Character, Settings.ESPColor, p.Name)
        end
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        AddPlayerESP(p)
    end
    
    AddConnection("PlayerESP", Players.PlayerAdded:Connect(AddPlayerESP))
end

local function DisablePlayerESP()
    Features.ESP = false
    RemoveConnection("PlayerESP")
    ClearESP()
    Notify(" Player ESP", "OFF")
end

-- Fish ESP (NEW)
local function EnableFishESP()
    Features.FishESP = true
    Notify(" Fish ESP", "ON")
    
    AddConnection("FishESP", RunService.Heartbeat:Connect(function()
        if not Features.FishESP then return end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("Part") then
                local name = obj.Name:lower()
                if (name:find("fish") or name:find("catch") or name:find("spawn")) and 
                   not obj:FindFirstChild("FishIt_ESP") then
                    CreateESP(obj, Settings.FishESPColor, " " .. obj.Name)
                end
            end
        end
    end))
end

local function DisableFishESP()
    Features.FishESP = false
    RemoveConnection("FishESP")
    -- Clear only fish ESP
    for i = #ESPObjects, 1, -1 do
        if ESPObjects[i].Highlight and ESPObjects[i].Highlight.FillColor == Settings.FishESPColor then
            pcall(function()
                ESPObjects[i].Highlight:Destroy()
                ESPObjects[i].Billboard:Destroy()
            end)
            table.remove(ESPObjects, i)
        end
    end
    Notify(" Fish ESP", "OFF")
end

-- NPC ESP (NEW)
local function EnableNPCESP()
    Features.NPCESP = true
    Notify(" NPC ESP", "ON")
    
    AddConnection("NPCESP", RunService.Heartbeat:Connect(function()
        if not Features.NPCESP then return end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local name = obj.Name:lower()
                if (name:find("npc") or name:find("shop") or name:find("merchant") or 
                    name:find("quest") or name:find("vendor")) and 
                   not obj:FindFirstChild("FishIt_ESP") then
                    CreateESP(obj, Color3.fromRGB(0, 255, 0), " " .. obj.Name)
                end
            end
        end
    end))
end

local function DisableNPCESP()
    Features.NPCESP = false
    RemoveConnection("NPCESP")
    Notify(" NPC ESP", "OFF")
end

-- ============================================
-- 21. FLY (FIXED)
-- ============================================
local function ToggleFly()
    Features.Fly = not Features.Fly
    
    local hum = GetHumanoid()
    local root = GetRootPart()
    
    if not hum or not root then
        Features.Fly = false
        return
    end
    
    if Features.Fly then
        hum.PlatformStand = true
        Notify(" Fly", "ON")
        
        AddConnection("Fly", RunService.RenderStepped:Connect(function()
            if not Features.Fly then return end
            
            local currentRoot = GetRootPart()
            if not currentRoot then return end
            
            local moveDir = Vector3.zero
            local camCF = camera.CFrame
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + camCF.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - camCF.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - camCF.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + camCF.RightVector
            end
            
            local yVel = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                yVel = Settings.FlySpeed
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                yVel = -Settings.FlySpeed
            end
            
            if moveDir.Magnitude > 0 then
                currentRoot.AssemblyLinearVelocity = moveDir.Unit * Settings.FlySpeed + Vector3.new(0, yVel, 0)
            else
                currentRoot.AssemblyLinearVelocity = Vector3.new(0, yVel, 0)
            end
            
            -- Anti-gravity
            currentRoot.AssemblyLinearVelocity = currentRoot.AssemblyLinearVelocity * Vector3.new(1, 0.9, 1)
        end))
    else
        hum.PlatformStand = false
        RemoveConnection("Fly")
        Notify(" Fly", "OFF")
    end
end

-- ============================================
-- 22. NOCLIP (FIXED)
-- ============================================
local function ToggleNoclip()
    Features.Noclip = not Features.Noclip
    
    if Features.Noclip then
        Notify(" Noclip", "ON")
        
        AddConnection("Noclip", RunService.Stepped:Connect(function()
            if Features.Noclip then
                local char = GetCharacter()
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end))
    else
        RemoveConnection("Noclip")
        -- Restore collision
        local char = GetCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
        Notify(" Noclip", "OFF")
    end
end

-- ============================================
-- 23. SPEED HACK (FIXED)
-- ============================================
local function ToggleSpeedHack()
    Features.SpeedHack = not Features.SpeedHack
    
    if Features.SpeedHack then
        Notify(" Speed Hack", "ON")
        
        AddConnection("SpeedHack", RunService.Heartbeat:Connect(function()
            if Features.SpeedHack then
                local hum = GetHumanoid()
                if hum then
                    hum.WalkSpeed = Settings.WalkSpeed
                    hum.JumpPower = Settings.JumpPower
                end
            end
        end))
    else
        RemoveConnection("SpeedHack")
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
        Notify(" Speed Hack", "OFF")
    end
end

-- ============================================
-- 24. INFINITE JUMP (NEW)
-- ============================================
local function ToggleInfiniteJump()
    Features.InfiniteJump = not Features.InfiniteJump
    
    if Features.InfiniteJump then
        Notify(" Infinite Jump", "ON")
        
        AddConnection("InfiniteJump", UserInputService.JumpRequest:Connect(function()
            if Features.InfiniteJump then
                local hum = GetHumanoid()
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end))
    else
        RemoveConnection("InfiniteJump")
        Notify(" Infinite Jump", "OFF")
    end
end

-- ============================================
-- 25. TELEPORT SYSTEM (FIXED & EXPANDED)
-- ============================================
local Islands = {
    ["Spawn"] = Vector3.new(0, 10, 0),
    ["Coral Island"] = Vector3.new(100, 10, 50),
    ["Mermaid Lagoon"] = Vector3.new(-80, 10, 120),
    ["Retro Island"] = Vector3.new(200, 10, -100),
    ["Esoteric Depths"] = Vector3.new(-150, 10, -80),
    ["Event Island"] = Vector3.new(50, 10, -150),
    ["Volcano Island"] = Vector3.new(300, 50, 200),
    ["Frozen Lake"] = Vector3.new(-200, 5, -200),
    ["Mystic Pond"] = Vector3.new(150, 5, 150),
    ["Deep Ocean"] = Vector3.new(0, -50, 500),
}

local function TeleportTo(position)
    local root = GetRootPart()
    if root then
        -- Safe teleport with velocity reset
        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
        
        -- Double check position
        task.wait(0.1)
        if (root.Position - position).Magnitude > 10 then
            root.CFrame = CFrame.new(position)
        end
        
        Notify(" Teleport", "Teleported to " .. tostring(position))
    else
        Notify(" Error", "Character not found!")
    end
end

-- ============================================
-- 26. FPS BOOST (FIXED)
-- ============================================
local OriginalSettings = {}

local function EnableFPSBoost()
    Features.FPSBoost = true
    Notify(" FPS Boost", "ON")
    
    -- Save original settings
    OriginalSettings.GlobalShadows = Lighting.GlobalShadows
    OriginalSettings.Technology = Lighting.Technology
    OriginalSettings.Brightness = Lighting.Brightness
    
    -- Apply optimizations
    Lighting.GlobalShadows = false
    Lighting.Technology = Enum.Technology.Compatibility
    Lighting.Brightness = 2
    
    -- Optimize workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if not OriginalSettings[obj] then
                OriginalSettings[obj] = obj.Material
            end
            obj.Material = Enum.Material.Plastic
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = false
        end
    end
    
    -- Lower render quality
    pcall(function()
        settings().Rendering.QualityLevel = 1
    end)
end

local function DisableFPSBoost()
    Features.FPSBoost = false
    Notify(" FPS Boost", "OFF")
    
    -- Restore settings
    Lighting.GlobalShadows = OriginalSettings.GlobalShadows or true
    Lighting.Technology = OriginalSettings.Technology or Enum.Technology.ShadowMap
    Lighting.Brightness = OriginalSettings.Brightness or 1
    
    pcall(function()
        settings().Rendering.QualityLevel = 3
    end)
end

-- ============================================
-- 27. FULL BRIGHT (NEW)
-- ============================================
local function ToggleFullBright()
    Features.FullBright = not Features.FullBright
    
    if Features.FullBright then
        Lighting.Brightness = 10
        Lighting.ClockTime = 12
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Notify(" Full Bright", "ON")
    else
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1000
        Lighting.GlobalShadows = true
        Notify(" Full Bright", "OFF")
    end
end

-- ============================================
-- 28. AUTO COLLECT (NEW)
-- ============================================
local function StartAutoCollect()
    Features.AutoCollect = true
    Notify(" Auto Collect", "ON")
    
    AddConnection("AutoCollect", RunService.Heartbeat:Connect(function()
        if not Features.AutoCollect then return end
        
        local root = GetRootPart()
        if not root then return end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                local name = obj.Name:lower()
                if name:find("coin") or name:find("gem") or name:find("orb") or 
                   name:find("drop") or name:find("loot") or name:find("collect") then
                    if (obj.Position - root.Position).Magnitude < 50 then
                        -- Tween to item
                        pcall(function()
                            obj.CFrame = root.CFrame
                        end)
                    end
                end
            end
        end
    end))
end

local function StopAutoCollect()
    Features.AutoCollect = false
    RemoveConnection("AutoCollect")
    Notify(" Auto Collect", "OFF")
end

-- ============================================
-- 29. SAVE & LOAD CONFIG (FIXED)
-- ============================================
local ConfigFile = "FishIt_Mega_Config.json"

local function SaveConfig()
    local config = {
        Features = {},
        Settings = Settings
    }
    
    for name, value in pairs(Features) do
        config.Features[name] = value
    end
    
    pcall(function()
        writefile(ConfigFile, HttpService:JSONEncode(config))
        Notify(" Config", "Saved successfully!")
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile(ConfigFile) then
            local data = HttpService:JSONDecode(readfile(ConfigFile))
            
            if data.Settings then
                for k, v in pairs(data.Settings) do
                    Settings[k] = v
                end
            end
            
            Notify(" Config", "Loaded successfully!")
        else
            Notify(" Config", "No config file found")
        end
    end)
end

-- ============================================
-- 30. AUTO SAVE (NEW)
-- ============================================
local function StartAutoSave()
    AddConnection("AutoSave", task.spawn(function()
        while true do
            task.wait(60) -- Save every minute
            if Settings.AutoSave then
                SaveConfig()
            end
        end
    end))
end

-- ============================================
-- UI CREATION - MODERN DESIGN
-- ============================================
local Window = Library:Window({
    Title = " FISH IT MEGA v4.0",
    Footer = "Fixed & Enhanced | By AI Assistant"
})

-- ============================================
-- TAB 1: AUTOMATION
-- ============================================
local AutoTab = Window:AddTab({ Name = " Auto", Icon = "bot" })

local FishingSection = AutoTab:AddSection(" Fishing")

FishingSection:AddToggle({
    Title = "Auto Fishing",
    Description = "Catch fish automatically",
    Default = false,
    Callback = function(v)
        if v then StartAutoFish() else StopAutoFish() end
    end
})

FishingSection:AddDropdown({
    Title = "Fishing Mode",
    Description = "Select fishing speed",
    Options = {"Stable", "Blatant", "Extreme", "Instant"},
    Default = "Stable",
    Callback = function(v)
        Settings.FishMode = v
        if Features.AutoFish then
            StopAutoFish()
            task.wait(0.5)
            StartAutoFish()
        end
    end
})

FishingSection:AddToggle({
    Title = "Auto Re-Cast",
    Description = "Automatically re-cast rod",
    Default = true,
    Callback = function(v)
        Settings.AutoReCast = v
    end
})

FishingSection:AddToggle({
    Title = "Perfect Reel",
    Description = "Always perfect reel timing",
    Default = false,
    Callback = function(v)
        Features.PerfectReel = v
    end
})

local SellSection = AutoTab:AddSection(" Selling")

SellSection:AddToggle({
    Title = "Auto Sell",
    Description = "Sell fish automatically",
    Default = false,
    Callback = function(v)
        if v then StartAutoSell() else StopAutoSell() end
    end
})

SellSection:AddDropdown({
    Title = "Sell Filter",
    Options = {"All", "Legendary", "Epic", "Rare", "Common"},
    Default = "All",
    Callback = function(v)
        Settings.SellFilter = v
        if Features.AutoSell then
            StopAutoSell()
            task.wait(0.5)
            StartAutoSell()
        end
    end
})

local ItemSection = AutoTab:AddSection(" Items")

ItemSection:AddToggle({
    Title = "Auto Open Crate",
    Description = "Open crates automatically",
    Default = false,
    Callback = function(v)
        if v then StartAutoOpenCrate() else StopAutoOpenCrate() end
    end
})

ItemSection:AddToggle({
    Title = "Auto Enchant",
    Description = "Enchant rod automatically",
    Default = false,
    Callback = function(v)
        if v then StartAutoEnchant() else StopAutoEnchant() end
    end
})

ItemSection:AddToggle({
    Title = "Auto Equip Skin",
    Description = "Equip best skin automatically",
    Default = false,
    Callback = function(v)
        if v then StartAutoEquipSkin() else StopAutoEquipSkin() end
    end
})

ItemSection:AddToggle({
    Title = "Auto Buy",
    Description = "Buy items automatically",
    Default = false,
    Callback = function(v)
        if v then StartAutoBuy() else StopAutoBuy() end
    end
})

ItemSection:AddToggle({
    Title = "Auto Collect Drops",
    Description = "Collect nearby drops",
    Default = false,
    Callback = function(v)
        if v then StartAutoCollect() else StopAutoCollect() end
    end
})

-- ============================================
-- TAB 2: WORLD & QUESTS
-- ============================================
local WorldTab = Window:AddTab({ Name = " World", Icon = "globe" })

local QuestSection = WorldTab:AddSection(" Quests")

QuestSection:AddToggle({
    Title = "Auto Quest",
    Description = "Complete quests automatically",
    Default = false,
    Callback = function(v)
        if v then StartAutoQuest() else StopAutoQuest() end
    end
})

QuestSection:AddToggle({
    Title = "Auto Artifact",
    Description = "Collect artifacts automatically",
    Default = false,
    Callback = function(v)
        if v then StartAutoArtifact() else StopAutoArtifact() end
    end
})

QuestSection:AddToggle({
    Title = "Auto Event",
    Description = "Join events automatically",
    Default = false,
    Callback = function(v)
        if v then StartAutoEvent() else StopAutoEvent() end
    end
})

local WorldSection = WorldTab:AddSection(" World Control")

WorldSection:AddToggle({
    Title = "Auto Totem",
    Description = "Place totems automatically",
    Default = false,
    Callback = function(v)
        if v then StartAutoTotem() else StopAutoTotem() end
    end
})

WorldSection:AddToggle({
    Title = "Auto Weather",
    Description = "Cycle weather automatically",
    Default = false,
    Callback = function(v)
        if v then StartAutoWeather() else StopAutoWeather() end
    end
})

-- ============================================
-- TAB 3: TRADE & SERVER
-- ============================================
local TradeTab = Window:AddTab({ Name = " Trade", Icon = "repeat" })

local TradeSection = TradeTab:AddSection(" Trading")

TradeSection:AddToggle({
    Title = "Auto Trade",
    Description = "Send trade requests automatically",
    Default = false,
    Callback = function(v)
        if v then StartAutoTrade() else StopAutoTrade() end
    end
})

TradeSection:AddToggle({
    Title = "Auto Accept Trade",
    Description = "Accept all trade requests",
    Default = false,
    Callback = function(v)
        if v then StartAutoAcceptTrade() else StopAutoAcceptTrade() end
    end
})

local ServerSection = TradeTab:AddSection(" Server")

ServerSection:AddToggle({
    Title = "Auto Rejoin",
    Description = "Rejoin on disconnect",
    Default = false,
    Callback = function(v)
        if v then StartAutoRejoin() else StopAutoRejoin() end
    end
})

ServerSection:AddToggle({
    Title = "Auto Server Hop",
    Description = "Switch server every 5 min",
    Default = false,
    Callback = function(v)
        if v then StartAutoServerHop() else StopAutoServerHop() end
    end
})

ServerSection:AddButton({
    Title = "Server Hop Now",
    Callback = function()
        pcall(function()
            TeleportService:Teleport(game.PlaceId)
        end)
    end
})

ServerSection:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
        end)
    end
})

-- ============================================
-- TAB 4: MOVEMENT
-- ============================================
local MoveTab = Window:AddTab({ Name = " Movement", Icon = "zap" })

local FlySection = MoveTab:AddSection(" Flight")

FlySection:AddToggle({
    Title = "Fly",
    Description = "WASD + Space/Ctrl",
    Default = false,
    Callback = function(v)
        if Features.Fly ~= v then
            ToggleFly()
        end
    end
})

FlySection:AddSlider({
    Title = "Fly Speed",
    Min = 10,
    Max = 500,
    Default = 100,
    Callback = function(v)
        Settings.FlySpeed = v
    end
})

local MoveSection = MoveTab:AddSection(" Movement")

MoveSection:AddToggle({
    Title = "Speed Hack",
    Description = "Fast walk and jump",
    Default = false,
    Callback = function(v)
        if Features.SpeedHack ~= v then
            ToggleSpeedHack()
        end
    end
})

MoveSection:AddSlider({
    Title = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 50,
    Callback = function(v)
        Settings.WalkSpeed = v
    end
})

MoveSection:AddSlider({
    Title = "Jump Power",
    Min = 50,
    Max = 200,
    Default = 100,
    Callback = function(v)
        Settings.JumpPower = v
    end
})

MoveSection:AddToggle({
    Title = "Noclip",
    Description = "Walk through walls",
    Default = false,
    Callback = function(v)
        if Features.Noclip ~= v then
            ToggleNoclip()
        end
    end
})

MoveSection:AddToggle({
    Title = "Infinite Jump",
    Description = "Jump infinitely",
    Default = false,
    Callback = function(v)
        if Features.InfiniteJump ~= v then
            ToggleInfiniteJump()
        end
    end
})

-- ============================================
-- TAB 5: VISUAL
-- ============================================
local VisualTab = Window:AddTab({ Name = " Visual", Icon = "eye" })

local ESPSection = VisualTab:AddSection(" ESP")

ESPSection:AddToggle({
    Title = "Player ESP",
    Description = "See all players",
    Default = false,
    Callback = function(v)
        if v then EnablePlayerESP() else DisablePlayerESP() end
    end
})

ESPSection:AddToggle({
    Title = "Fish ESP",
    Description = "See fish locations",
    Default = false,
    Callback = function(v)
        if v then EnableFishESP() else DisableFishESP() end
    end
})

ESPSection:AddToggle({
    Title = "NPC ESP",
    Description = "See NPCs and shops",
    Default = false,
    Callback = function(v)
        if v then EnableNPCESP() else DisableNPCESP() end
    end
})

local VisualSection = VisualTab:AddSection(" Visual Effects")

VisualSection:AddToggle({
    Title = "FPS Boost",
    Description = "Reduce graphics for FPS",
    Default = false,
    Callback = function(v)
        if v then EnableFPSBoost() else DisableFPSBoost() end
    end
})

VisualSection:AddToggle({
    Title = "Full Bright",
    Description = "Maximum brightness",
    Default = false,
    Callback = function(v)
        ToggleFullBright()
    end
})

-- ============================================
-- TAB 6: PROTECTION
-- ============================================
local ProtectTab = Window:AddTab({ Name = " Protect", Icon = "shield" })

local ProtectSection = ProtectTab:AddSection(" Protection")

ProtectSection:AddToggle({
    Title = "Anti-AFK",
    Description = "Prevent AFK kick",
    Default = false,
    Callback = function(v)
        if v then StartAntiAFK() else StopAntiAFK() end
    end
})

ProtectSection:AddToggle({
    Title = "Anti-Drown",
    Description = "Prevent drowning",
    Default = false,
    Callback = function(v)
        if v then StartAntiDrown() else StopAntiDrown() end
    end
})

ProtectSection:AddToggle({
    Title = "Anti-Kick",
    Description = "Block kick attempts",
    Default = false,
    Callback = function(v)
        if v then StartAntiKick() end
    end
})

ProtectSection:AddToggle({
    Title = "Auto Heal",
    Description = "Auto heal when low HP",
    Default = false,
    Callback = function(v)
        if v then StartAutoHeal() else StopAutoHeal() end
    end
})

-- ============================================
-- TAB 7: TELEPORT
-- ============================================
local TPTab = Window:AddTab({ Name = " Teleport", Icon = "map-pin" })

local IslandSection = TPTab:AddSection(" Islands")

for name, pos in pairs(Islands) do
    IslandSection:AddButton({
        Title = " " .. name,
        Callback = function()
            TeleportTo(pos)
        end
    })
end

local CustomTPSection = TPTab:AddSection(" Custom")

CustomTPSection:AddInput({
    Title = "Custom Position",
    Description = "Format: X,Y,Z",
    Default = "",
    Callback = function(v)
        local coords = {}
        for num in v:gmatch("%-?%d+%.?%d*") do
            table.insert(coords, tonumber(num))
        end
        
        if #coords >= 3 then
            TeleportTo(Vector3.new(coords[1], coords[2], coords[3]))
        else
            Notify(" Error", "Invalid coordinates!")
        end
    end
})

CustomTPSection:AddButton({
    Title = "Teleport to Safe Zone",
    Callback = function()
        TeleportTo(CONFIG.SafePosition)
    end
})

CustomTPSection:AddButton({
    Title = "Teleport to Random Fishing Spot",
    Callback = function()
        local spot = CONFIG.FishingSpots[math.random(1, #CONFIG.FishingSpots)]
        TeleportTo(spot)
    end
})

-- ============================================
-- TAB 8: SETTINGS
-- ============================================
local SettingsTab = Window:AddTab({ Name = " Settings", Icon = "settings" })

local ConfigSection = SettingsTab:AddSection(" Configuration")

ConfigSection:AddToggle({
    Title = "Auto Save",
    Description = "Auto save settings",
    Default = true,
    Callback = function(v)
        Settings.AutoSave = v
    end
})

ConfigSection:AddButton({
    Title = " Save Config",
    Callback = SaveConfig
})

ConfigSection:AddButton({
    Title = " Load Config",
    Callback = LoadConfig
})

ConfigSection:AddButton({
    Title = " Reset All Features",
    Callback = function()
        StopAllFeatures()
    end
})

ConfigSection:AddButton({
    Title = " Destroy UI",
    Callback = function()
        StopAllFeatures()
        Library:Destroy()
    end
})

-- ============================================
-- KEYBINDS (FIXED)
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        if Features.AutoFish then StopAutoFish() else StartAutoFish() end
    elseif input.KeyCode == Enum.KeyCode.F2 then
        ToggleFly()
    elseif input.KeyCode == Enum.KeyCode.F3 then
        if Features.AutoOpenCrate then StopAutoOpenCrate() else StartAutoOpenCrate() end
    elseif input.KeyCode == Enum.KeyCode.F4 then
        ToggleSpeedHack()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        if Features.ESP then DisablePlayerESP() else EnablePlayerESP() end
    elseif input.KeyCode == Enum.KeyCode.F6 then
        ToggleNoclip()
    elseif input.KeyCode == Enum.KeyCode.F7 then
        TeleportTo(CONFIG.SafePosition)
    elseif input.KeyCode == Enum.KeyCode.Insert then
        -- Toggle UI visibility
        pcall(function()
            Library:Toggle()
        end)
    end
end)

-- ============================================
-- CHARACTER HANDLING
-- ============================================
player.CharacterAdded:Connect(function(char)
    -- Re-apply active features on respawn
    task.wait(1)
    
    if Features.SpeedHack then
        ToggleSpeedHack()
        ToggleSpeedHack()
    end
    
    if Features.Noclip then
        ToggleNoclip()
        ToggleNoclip()
    end
    
    if Features.Fly then
        ToggleFly()
        ToggleFly()
    end
end)

-- ============================================
-- INITIALIZATION
-- ============================================
task.spawn(function()
    -- Wait for game to load
    repeat task.wait() until game:IsLoaded()
    
    -- Initialize remotes
    InitializeRemotes()
    
    -- Start auto save
    StartAutoSave()
    
    -- Load config
    LoadConfig()
    
    -- Initialize UI
    Library:Initialize()
    
    -- Welcome notification
    Notify(" FISH IT MEGA", "v4.0 Loaded Successfully!", 5)
end)