-- ============================================
-- ULTIMATE FISH-IT SCRIPT v5.0 COMPLETE EDITION
-- SEMUA FITUR DARI SEMUA 10 LINK DIGABUNG
-- ============================================

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mdwpanel/Roblox/refs/heads/main/main_ui_modern.lua"))()

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera
local virtualInput = game:GetService("VirtualInputManager")
local teleportService = game:GetService("TeleportService")
local lighting = game:GetService("Lighting")
local coreGui = game:GetService("CoreGui")
local httpService = game:GetService("HttpService")
local tweenService = game:GetService("TweenService")
local soundService = game:GetService("SoundService")

-- ============================================
-- ADVANCED REMOTE DETECTION SYSTEM
-- ============================================
local remotes = {}
local detectedRemotes = {}

local function findAllRemotes()
    local function searchFolder(folder, depth, path)
        if depth > 6 then return end
        
        for _, obj in pairs(folder:GetChildren()) do
            local fullPath = path .. "/" .. obj.Name
            
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                table.insert(detectedRemotes, {name = obj.Name, path = fullPath, obj = obj, type = obj.ClassName})
                
                -- Comprehensive remote mapping from all sources
                if name:find("fish") or name:find("cast") then remotes.fish = obj end
                if name:find("reel") or name:find("catch") or name:find("complete") then remotes.reel = obj end
                if name:find("sell") or name:find("shop") or name:find("sellall") then remotes.sell = obj end
                if name:find("enchant") then remotes.enchant = obj end
                if name:find("crate") or name:find("open") then remotes.crate = obj end
                if name:find("equip") or name:find("skin") or name:find("hotbar") then remotes.equipSkin = obj end
                if name:find("buy") or name:find("purchase") then remotes.buy = obj end
                if name:find("trade") or name:find("accept") then remotes.trade = obj end
                if name:find("totem") then remotes.totem = obj end
                if name:find("weather") or name:find("storm") then remotes.weather = obj end
                if name:find("quest") or name:find("complete") then remotes.quest = obj end
                if name:find("artifact") or name:find("collect") then remotes.artifact = obj end
                if name:find("event") then remotes.event = obj end
                if name:find("bobber") or name:find("handle") then remotes.bobber = obj end
                if name:find("charge") or name:find("charging") then remotes.charge = obj end
                if name:find("minigame") or name:find("fishing") then remotes.minigame = obj end
                if name:find("auto") or name:find("state") then remotes.auto = obj end
                if name:find("radar") then remotes.radar = obj end
                if name:find("oxygen") or name:find("diving") then remotes.oxygen = obj end
                if name:find("dialog") or name:find("event") then remotes.dialog = obj end
                if name:find("notification") or name:find("notify") then remotes.notify = obj end
            elseif obj:IsA("Folder") then
                searchFolder(obj, depth + 1, fullPath)
            end
        end
    end
    
    -- Search ReplicatedStorage
    searchFolder(replicatedStorage, 0, "RS")
    
    -- Search player character for rod remotes
    if player.Character then
        for _, tool in pairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                searchFolder(tool, 0, "Tool")
            end
        end
    end
end

findAllRemotes()

-- ============================================
-- CONFIGURATION
-- ============================================
local CONFIG = {
    FishDelay = 1.0,
    SellDelay = 2,
    CrateDelay = 1.5,
    EnchantDelay = 2,
    TotemDelay = 60,
    CallMinDelay = 0.18,
    CallBackoff = 1.5,
    MaxBobberDistance = 25,
    InstantDelay = 0.35,
}

local lastCall = {}

local features = {
    -- Fishing
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
    
    -- Character
    antiAFK = false,
    antiDrown = false,
    autoHeal = false,
    infiniteJump = false,
    
    -- Movement
    flyEnabled = false,
    noclipEnabled = false,
    speedHack = false,
    freezeCharacter = false,
    
    -- Visual
    espEnabled = false,
    fpsBoost = false,
    disableNotif = false,
    blackScreen = false,
    
    -- Advanced Fishing (STREE HUB)
    kaitunMode = false,
    autoCharge = false,
    autoMinigame = false,
    disableAnimations = false,
    autoRadar = false,
    divingGear = false,
    
    -- SimpleAJA
    instantReel = false,
    fastBobber = false,
    zeroAnimation = false,
    instantCast = false,
    autoShake = false,
    silentMode = false,
    
    -- SkuyyHub
    autoShell = false,
    autoFishComplete = false,
    legacyPerfect = false,
}

local fishMode = "Legit"
local sellFilter = "All"
local flySpeed = 100
local fishingMode = "Instant"
local kaitunDelay = 0.35
local customJumpPower = 50

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
    if not features.disableNotif then
        Library:MakeNotify({Title = title, Content = desc, Duration = duration or 3})
    end
end

local function SafeFireServer(remote, ...)
    if remote then
        pcall(function() remote:FireServer(...) end)
    end
end

local function SafeInvokeServer(remote, ...)
    if remote then
        return pcall(function() return remote:InvokeServer(...) end)
    end
end

local function SafeCall(key, func)
    local now = os.clock()
    local minDelay = CONFIG.CallMinDelay
    if lastCall[key] and now - lastCall[key] < minDelay then
        wait(minDelay - (now - lastCall[key]))
    end
    local success, result = pcall(func)
    lastCall[key] = os.clock()
    if not success then
        local msg = tostring(result):lower()
        if msg:find("429") or msg:find("too many requests") then
            wait(CONFIG.CallBackoff)
        end
    end
    return success, result
end

-- ============================================
-- 1. AUTO FISHING SYSTEM (MAIN)
-- ============================================
local fishingLoop = nil

local function startAutoFish()
    features.autoFish = true
    Notify(" Auto Fishing", "ON - Mode: " .. fishMode)
    
    if fishingLoop then pcall(function() fishingLoop:Disconnect() end) end
    
    fishingLoop = runService.Heartbeat:Connect(function()
        if not features.autoFish then
            if fishingLoop then fishingLoop:Disconnect() end
            return
        end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = GetHumanoid()
        if not humanoid then return end
        
        -- Method 1: STREE HUB Auto State
        if remotes.auto then
            SafeCall("autoon", function()
                SafeInvokeServer(remotes.auto, true)
            end)
        end
        
        -- Method 2: Fire fishing remote
        if remotes.fish then
            SafeCall("fish", function()
                SafeFireServer(remotes.fish)
            end)
        end
        
        -- Method 3: Equip rod from hotbar
        if remotes.equipSkin then
            SafeCall("equiprod", function()
                SafeFireServer(remotes.equipSkin, 1)
            end)
        end
        
        -- Calculate delay based on mode
        local delay_time = fishMode == "Instant" and 0.3 or 
                          fishMode == "Blatant" and 0.8 or 
                          fishMode == "Extreme" and 0.5 or 1.5
        
        wait(delay_time)
        
        -- Reel in fish
        if remotes.reel then
            SafeCall("reel", function()
                SafeFireServer(remotes.reel)
            end)
        end
        
        -- Auto charge for minigames
        if features.autoCharge and remotes.charge then
            SafeCall("charge", function()
                SafeInvokeServer(remotes.charge, 1762631511.436375)
            end)
        end
    end)
end

local function stopAutoFish()
    features.autoFish = false
    if fishingLoop then
        pcall(function() fishingLoop:Disconnect() end)
        fishingLoop = nil
    end
    Notify(" Auto Fishing", "OFF")
end

-- ============================================
-- 2. AUTO SELL SYSTEM
-- ============================================
local function startAutoSell()
    features.autoSell = true
    Notify(" Auto Sell", "ON - Filter: " .. sellFilter)
    
    spawn(function()
        while features.autoSell do
            if remotes.sell then
                SafeCall("sell", function()
                    SafeInvokeServer(remotes.sell)
                    SafeFireServer(remotes.sell, sellFilter)
                    SafeFireServer(remotes.sell)
                end)
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
-- 3. KAITUN SYSTEM (STREE HUB PREMIUM)
-- ============================================
local kaitunScreenGui = nil

local function CreateKaitunBackground()
    if kaitunScreenGui then kaitunScreenGui:Destroy() end
    kaitunScreenGui = Instance.new("ScreenGui")
    kaitunScreenGui.IgnoreGuiInset = true
    kaitunScreenGui.ResetOnSpawn = false
    kaitunScreenGui.Name = "KAITUN_BG"
    kaitunScreenGui.Parent = coreGui
    
    local bg = Instance.new("Frame")
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.ZIndex = 0
    bg.Parent = kaitunScreenGui
    
    -- Add stars
    for i = 1, 80 do
        local star = Instance.new("Frame")
        star.Size = UDim2.new(0, math.random(3, 5), 0, math.random(3, 5))
        star.Position = UDim2.new(math.random(), 0, math.random(), 0)
        star.BackgroundTransparency = 1
        star.ZIndex = 0
        star.Parent = bg
        
        local circle = Instance.new("UICorner", star)
        circle.CornerRadius = UDim.new(1, 0)
        
        local glow = Instance.new("UIStroke", star)
        glow.Thickness = 1
        glow.Color = Color3.fromRGB(0, 255, 0)
        glow.Transparency = math.random(40, 80) / 100
        
        task.spawn(function()
            local tweenInfo = TweenInfo.new(math.random(2, 4), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
            tweenService:Create(glow, tweenInfo, {Transparency = math.random(0, 60) / 100}):Play()
        end)
    end
    
    -- Add Saturn image
    local saturn = Instance.new("ImageLabel")
    saturn.Image = "rbxassetid://122683047852451"
    saturn.BackgroundTransparency = 1
    saturn.Size = UDim2.new(0, 320, 0, 320)
    saturn.Position = UDim2.new(0.7, 0, 0.15, 0)
    saturn.ImageTransparency = 0.05
    saturn.ZIndex = 0
    saturn.Parent = bg
    
    task.spawn(function()
        while kaitunScreenGui and features.kaitunMode do
            for i = 0, 180, 2 do
                if not kaitunScreenGui then break end
                saturn.Rotation = i
                task.wait(0.02)
            end
            for i = 180, 0, -2 do
                if not kaitunScreenGui then break end
                saturn.Rotation = i
                task.wait(0.02)
            end
        end
    end)
    
    -- Add text
    local text = Instance.new("TextLabel")
    text.Parent = bg
    text.Position = UDim2.new(0.5, 0, 0.5, 0)
    text.AnchorPoint = Vector2.new(0.5, 0.5)
    text.Size = UDim2.new(0, 400, 0, 100)
    text.BackgroundTransparency = 1
    text.Text = " KAITUN SYSTEM\nAuto Fishing Active"
    text.TextColor3 = Color3.fromRGB(0, 255, 0)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 24
    text.ZIndex = 1
    
    -- Add sound
    local spaceSound = Instance.new("Sound")
    spaceSound.SoundId = "rbxassetid://1846351427"
    spaceSound.Volume = 0.2
    spaceSound.Looped = true
    spaceSound.Parent = soundService
    spaceSound:Play()
    
    kaitunScreenGui:SetAttribute("Sound", spaceSound)
end

local function RemoveKaitunBackground()
    if kaitunScreenGui then
        local sound = kaitunScreenGui:GetAttribute("Sound")
        if sound then
            sound:Stop()
            sound:Destroy()
        end
        kaitunScreenGui:Destroy()
        kaitunScreenGui = nil
    end
end

local function startKaitun()
    features.kaitunMode = true
    Notify(" Kaitun System", "ACTIVATED!")
    CreateKaitunBackground()
    
    spawn(function()
        while features.kaitunMode do
            -- Equip rod
            if remotes.equipSkin then
                SafeCall("eq", function()
                    SafeFireServer(remotes.equipSkin, 1)
                end)
            end
            
            -- Charge rod
            if remotes.charge then
                SafeCall("ch", function()
                    SafeInvokeServer(remotes.charge, 1762631511.436375)
                end)
            end
            
            -- Request minigame
            if remotes.minigame then
                SafeCall("mg", function()
                    SafeInvokeServer(remotes.minigame, -1.233, 0.996, 1761532005.497)
                end)
            end
            
            wait(kaitunDelay)
            
            -- Complete fishing
            if remotes.reel then
                SafeCall("ct", function()
                    SafeFireServer(remotes.reel)
                end)
            end
            
            -- Sell fish
            if remotes.sell then
                SafeCall("sl", function()
                    SafeInvokeServer(remotes.sell)
                end)
            end
            
            wait(kaitunDelay)
        end
    end)
end

local function stopKaitun()
    features.kaitunMode = false
    RemoveKaitunBackground()
    Notify(" Kaitun System", "DEACTIVATED")
end

-- ============================================
-- 4. INSTANT REEL SYSTEM (SimpleAJA)
-- ============================================
local isReelRunning = false

local function setupGUIListener()
    local playerGui = player.PlayerGui
    
    playerGui.ChildAdded:Connect(function(child)
        if (child.Name == "FishingGUI" or child.Name == "reel") and isReelRunning then
            task.wait(0.01)
            instantReelAction()
        end
    end)
    
    local fishingGui = playerGui:FindFirstChild("FishingGUI") or playerGui:FindFirstChild("reel")
    if fishingGui then
        fishingGui.ChildAdded:Connect(function(child)
            if isReelRunning and (child.Name == "Reel" or child.Name == "Shake") then
                task.wait(0.01)
                instantReelAction()
            end
        end)
        
        fishingGui.DescendantAdded:Connect(function(descendant)
            if isReelRunning and descendant:IsA("GuiButton") and (descendant.Name == "Reel" or descendant.Name == "Shake") then
                task.wait(0.01)
                instantReelAction()
            end
        end)
    end
end

local function instantReelAction()
    if not isReelRunning or not features.instantReel then return end
    
    local playerGui = player.PlayerGui
    local fishingGui = playerGui:FindFirstChild("FishingGUI") or playerGui:FindFirstChild("reel")
    
    if fishingGui then
        local reelButton = fishingGui:FindFirstChild("Reel")
        if reelButton and reelButton.Visible and reelButton.AbsoluteSize.X > 0 then
            pcall(function()
                firesignal(reelButton.Activated)
                firesignal(reelButton.MouseButton1Click)
            end)
            return
        end
        
        if features.autoShake then
            local shakeButton = fishingGui:FindFirstChild("Shake")
            if shakeButton and shakeButton.Visible and shakeButton.AbsoluteSize.X > 0 then
                pcall(function()
                    firesignal(shakeButton.Activated)
                    firesignal(shakeButton.MouseButton1Click)
                end)
            end
        end
    end
    
    -- Fire remotes
    pcall(function()
        if remotes.bobber then
            remotes.bobber:FireServer("reel")
        end
        if remotes.reel then
            remotes.reel:FireServer()
        end
    end)
end

local function enableInstantReel()
    features.instantReel = true
    isReelRunning = true
    Notify(" Instant Reel", "ON")
    
    setupGUIListener()
    
    local renderConnection = runService.RenderStepped:Connect(function()
        if isReelRunning then
            instantReelAction()
        end
    end)
end

local function disableInstantReel()
    features.instantReel = false
    isReelRunning = false
    Notify(" Instant Reel", "OFF")
end

-- ============================================
-- 5. FAST BOBBER SYSTEM (SimpleAJA)
-- ============================================
local function enableFastBobber()
    features.fastBobber = true
    Notify(" Fast Bobber", "ON")
    
    runService.Heartbeat:Connect(function()
        if not features.fastBobber then return end
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("bobber") or obj.Name:lower():find("float") then
                if obj:IsA("BasePart") then
                    if obj.AssemblyLinearVelocity then
                        obj.AssemblyLinearVelocity = Vector3.new(0, -120, 0)
                    end
                    
                    if not obj:FindFirstChild("BodyVelocity") then
                        local bodyVel = Instance.new("BodyVelocity")
                        bodyVel.MaxForce = Vector3.new(4000, 4000, 4000)
                        bodyVel.Velocity = Vector3.new(0, -120, 0)
                        bodyVel.Parent = obj
                        game:GetService("Debris"):AddItem(bodyVel, 2)
                    end
                    
                    -- Instant bobber teleport
                    if features.instantCast and obj.Position.Y > 10 then
                        local character = player.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local lookVec = character.HumanoidRootPart.CFrame.LookVector
                            local maxDist = CONFIG.MaxBobberDistance
                            local targetPos = character.HumanoidRootPart.Position + lookVec * maxDist
                            obj.CFrame = CFrame.new(targetPos.X, 5, targetPos.Z)
                            obj.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================
-- 6. INSTANT CAST SYSTEM
-- ============================================
local function enableInstantCast()
    features.instantCast = true
    Notify(" Instant Cast", "ON")
    
    runService.Heartbeat:Connect(function()
        if not features.instantCast then return end
        
        local character = player.Character
        if not character then return end
        
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and (tool.Name:lower():find("rod") or tool.Name:lower():find("fish")) then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    if track.Animation and track.Animation.AnimationId then
                        local animId = track.Animation.AnimationId:lower()
                        if animId:find("cast") or animId:find("throw") or animId:find("fish") then
                            track.Speed = 5
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================
-- 7. BLOCK ANIMATIONS
-- ============================================
local function blockAnimations()
    if not features.zeroAnimation then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        if track.Animation and track.Animation.AnimationId then
            local animId = track.Animation.AnimationId
            if animId:find("fish") or animId:find("reel") or animId:find("cast") then
                track:Stop()
            end
        end
    end
end

-- ============================================
-- 8. UPGRADE SYSTEMS
-- ============================================
local function startAutoEnchant()
    features.autoEnchant = true
    Notify(" Auto Enchant", "ON")
    
    spawn(function()
        while features.autoEnchant do
            if remotes.enchant then
                SafeCall("ench", function()
                    SafeFireServer(remotes.enchant)
                end)
            end
            wait(CONFIG.EnchantDelay)
        end
    end)
end

local function startAutoOpenCrate()
    features.autoOpenCrate = true
    Notify(" Auto Crate", "ON")
    
    spawn(function()
        while features.autoOpenCrate do
            if remotes.crate then
                SafeCall("crt", function()
                    SafeFireServer(remotes.crate)
                end)
            end
            wait(CONFIG.CrateDelay)
        end
    end)
end

local function startAutoEquipSkin()
    features.autoEquipSkin = true
    Notify(" Auto Equip Skin", "ON")
    
    spawn(function()
        while features.autoEquipSkin do
            if remotes.equipSkin then
                SafeCall("skins", function()
                    SafeFireServer(remotes.equipSkin, "best")
                    SafeFireServer(remotes.equipSkin)
                end)
            end
            wait(5)
        end
    end)
end

local function startAutoBuy()
    features.autoBuy = true
    Notify(" Auto Buy", "ON")
    
    spawn(function()
        while features.autoBuy do
            if remotes.buy then
                SafeCall("buy", function()
                    SafeFireServer(remotes.buy, "rod")
                    wait(1)
                    SafeFireServer(remotes.buy, "bait")
                    wait(1)
                    SafeFireServer(remotes.buy, "bobber")
                end)
            end
            wait(10)
        end
    end)
end

local function startAutoTotem()
    features.autoTotem = true
    Notify(" Auto Totem", "ON")
    
    spawn(function()
        while features.autoTotem do
            if remotes.totem then
                SafeCall("tot", function()
                    SafeFireServer(remotes.totem)
                end)
            end
            wait(CONFIG.TotemDelay)
        end
    end)
end

-- ============================================
-- 9. AUTO QUEST SYSTEM
-- ============================================
local questTypes = {"DeepSea", "AuraKid", "ElementJungle", "Quest1", "Quest2", "Ghostfin", "ElementJungle"}

local function startAutoQuest()
    features.autoQuest = true
    Notify(" Auto Quest", "ON")
    
    spawn(function()
        while features.autoQuest do
            for _, quest in pairs(questTypes) do
                if remotes.quest and features.autoQuest then
                    SafeCall(quest, function()
                        SafeFireServer(remotes.quest, quest)
                    end)
                    wait(2)
                end
            end
            wait(10)
        end
    end)
end

-- ============================================
-- 10. AUTO SHELL COLLECTION (SkuyyHub)
-- ============================================
local function startAutoShell()
    features.autoShell = true
    Notify(" Auto Shell", "ON")
    
    spawn(function()
        while features.autoShell do
            wait(0.3)
            
            for _, obj in pairs(workspace:GetChildren()) do
                if obj.Name:lower():find("shell") or obj.Name:lower():find("seashell") or 
                   obj.Name:lower():find("pearl") or obj.Name:lower():find("treasure") then
                    
                    if obj:FindFirstChild("ClickDetector") then
                        pcall(function()
                            fireclickdetector(obj.ClickDetector)
                        end)
                    elseif obj:FindFirstChild("ProximityPrompt") then
                        pcall(function()
                            fireproximityprompt(obj.ProximityPrompt)
                        end)
                    elseif obj:IsA("Part") or obj:IsA("MeshPart") then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local oldPos = player.Character.HumanoidRootPart.CFrame
                            pcall(function()
                                player.Character.HumanoidRootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
                                wait(0.1)
                                
                                if obj:FindFirstChild("RemoteEvent") then
                                    obj.RemoteEvent:FireServer()
                                end
                                
                                if obj.CanTouch then
                                    obj.Touched:Fire(player.Character.HumanoidRootPart)
                                end
                                
                                wait(0.1)
                                player.Character.HumanoidRootPart.CFrame = oldPos
                            end)
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================
-- 11. PERFECT CATCH SYSTEM (SkuyyHub)
-- ============================================
local function startLegitPerfect()
    features.legacyPerfect = true
    Notify(" Perfect Catch", "ON")
    
    spawn(function()
        while features.legacyPerfect do
            wait(0.01)
            
            if player.PlayerGui:FindFirstChild("FishingGui") then
                local fishingGui = player.PlayerGui.FishingGui
                
                if fishingGui:FindFirstChild("PerfectZone") and fishingGui.PerfectZone.Visible then
                    local perfectZone = fishingGui.PerfectZone
                    
                    if perfectZone:FindFirstChild("Indicator") then
                        local indicator = perfectZone.Indicator
                        local zoneFrame = perfectZone:FindFirstChild("Zone")
                        
                        if zoneFrame and indicator.Position.X.Scale >= zoneFrame.Position.X.Scale and 
                           indicator.Position.X.Scale <= (zoneFrame.Position.X.Scale + zoneFrame.Size.X.Scale) then
                            
                            wait(math.random(20, 80) / 1000)
                            
                            if remotes.reel then
                                SafeCall("pf", function()
                                    SafeFireServer(remotes.reel)
                                end)
                            end
                        end
                    end
                end
                
                if fishingGui:FindFirstChild("PerfectButton") and fishingGui.PerfectButton.Visible then
                    wait(math.random(30, 70) / 1000)
                    pcall(function()
                        fishingGui.PerfectButton.MouseButton1Click:Fire()
                    end)
                end
                
                if fishingGui:FindFirstChild("CatchIndicator") then
                    local indicator = fishingGui.CatchIndicator
                    if indicator.BackgroundColor3 == Color3.fromRGB(0, 255, 0) then
                        wait(math.random(20, 60) / 1000)
                        pcall(function()
                            indicator.MouseButton1Click:Fire()
                        end)
                    end
                end
            end
        end
    end)
end

-- ============================================
-- 12. CHARACTER ENHANCEMENT
-- ============================================
local function startAntiAFK()
    features.antiAFK = true
    Notify(" Anti-AFK", "ON")
    
    runService.RenderStepped:Connect(function()
        if features.antiAFK and player.Character then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid:Move(Vector3.new(0, 0, 0), true)
            end
        end
    end)
end

local function startAntiDrown()
    features.antiDrown = true
    Notify(" Anti-Drown", "ON")
    
    runService.RenderStepped:Connect(function()
        if features.antiDrown and player.Character then
            local humanoid = GetHumanoid()
            if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function startAutoHeal()
    features.autoHeal = true
    Notify(" Auto Heal", "ON")
    
    spawn(function()
        while features.autoHeal do
            local humanoid = GetHumanoid()
            if humanoid and humanoid.Health < humanoid.MaxHealth * 0.5 then
                for _, item in pairs(player.Backpack:GetChildren()) do
                    if item:IsA("Tool") and (item.Name:lower():find("heal") or item.Name:lower():find("pot")) then
                        humanoid:EquipTool(item)
                        wait(0.5)
                        break
                    end
                end
            end
            wait(2)
        end
    end)
end

local function toggleInfiniteJump()
    features.infiniteJump = not features.infiniteJump
    
    if features.infiniteJump then
        Notify(" Infinite Jump", "ON")
        userInput.JumpRequest:Connect(function()
            if features.infiniteJump then
                local character = player.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        Notify(" Infinite Jump", "OFF")
    end
end

local function toggleFreezeCharacter()
    features.freezeCharacter = not features.freezeCharacter
    
    if features.freezeCharacter then
        Notify(" Freeze", "ON")
        local character = player.Character
        if character then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                local originalCFrame = root.CFrame
                runService.Heartbeat:Connect(function()
                    if features.freezeCharacter and root then
                        root.CFrame = originalCFrame
                    end
                end)
            end
        end
    else
        Notify(" Freeze", "OFF")
    end
end

-- ============================================
-- 13. MOVEMENT ENHANCEMENTS
-- ============================================
local function toggleFly()
    features.flyEnabled = not features.flyEnabled
    local char = player.Character
    if char and GetHumanoid() then
        if features.flyEnabled then
            GetHumanoid().PlatformStand = true
            Notify(" Fly", "ON")
            
            runService.RenderStepped:Connect(function()
                if not features.flyEnabled then return end
                local root = GetRootPart()
                if not root then return end
                
                local moveVec = Vector3.new(0, 0, 0)
                if userInput:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + camera.CFrame.LookVector end
                if userInput:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - camera.CFrame.LookVector end
                if userInput:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - camera.CFrame.RightVector end
                if userInput:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + camera.CFrame.RightVector end
                
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
            GetHumanoid().PlatformStand = false
            Notify(" Fly", "OFF")
        end
    end
end

local function toggleNoclip()
    features.noclipEnabled = not features.noclipEnabled
    
    if features.noclipEnabled then
        Notify(" Noclip", "ON")
        runService.RenderStepped:Connect(function()
            if features.noclipEnabled and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        Notify(" Noclip", "OFF")
    end
end

local function toggleSpeedHack()
    features.speedHack = not features.speedHack
    
    if features.speedHack then
        Notify(" Speed Hack", "ON")
        runService.RenderStepped:Connect(function()
            if features.speedHack and GetHumanoid() then
                GetHumanoid().WalkSpeed = 100
                GetHumanoid().JumpPower = 200
            end
        end)
    else
        if GetHumanoid() then
            GetHumanoid().WalkSpeed = 16
            GetHumanoid().JumpPower = 50
        end
        Notify(" Speed Hack", "OFF")
    end
end

-- ============================================
-- 14. VISUAL ENHANCEMENTS
-- ============================================
local function enableESP()
    features.espEnabled = true
    Notify(" ESP", "ON")
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = v.Character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.3
            highlight.Parent = v.Character
        end
    end
    
    Players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(function(char)
            wait(0.5)
            if features.espEnabled then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = char
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.3
                highlight.Parent = char
            end
        end)
    end)
end

local function toggleFPSBoost()
    features.fpsBoost = not features.fpsBoost
    
    if features.fpsBoost then
        Notify(" FPS Boost", "ON")
        lighting.GlobalShadows = false
        lighting.Technology = Enum.Technology.Legacy
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") then v.Material = Enum.Material.Plastic end
            if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
        settings().Rendering.QualityLevel = 1
    else
        Notify(" FPS Boost", "OFF")
        lighting.GlobalShadows = true
        lighting.Technology = Enum.Technology.ShadowMap
        settings().Rendering.QualityLevel = 3
    end
end

local function toggleBlackScreen()
    features.blackScreen = not features.blackScreen
    
    if features.blackScreen then
        Notify(" Black Screen", "ON")
        local screenGui = Instance.new("ScreenGui")
        screenGui.IgnoreGuiInset = true
        screenGui.ResetOnSpawn = false
        screenGui.Name = "BLACK_SCREEN"
        screenGui.Parent = coreGui
        
        local frame = Instance.new("Frame")
        frame.Parent = screenGui
        frame.AnchorPoint = Vector2.new(0, 0)
        frame.Position = UDim2.new(0, 0, 0, 0)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BorderSizePixel = 0
        
        local text = Instance.new("TextLabel")
        text.Parent = frame
        text.Position = UDim2.new(0.5, 0, 0.5, 0)
        text.AnchorPoint = Vector2.new(0.5, 0.5)
        text.Size = UDim2.new(0, 400, 0, 100)
        text.BackgroundTransparency = 1
        text.Text = "ULTIMATE FISH-IT v5.0\nAll Features Loaded"
        text.TextColor3 = Color3.fromRGB(0, 255, 0)
        text.Font = Enum.Font.GothamBold
        text.TextSize = 24
    else
        if coreGui:FindFirstChild("BLACK_SCREEN") then
            coreGui.BLACK_SCREEN:Destroy()
        end
        Notify(" Black Screen", "OFF")
    end
end

-- ============================================
-- 15. RADAR & DIVING GEAR
-- ============================================
local function toggleAutoRadar()
    features.autoRadar = not features.autoRadar
    
    if features.autoRadar then
        Notify(" Radar", "ON")
        if remotes.radar then
            SafeFireServer(remotes.radar, true)
        end
    else
        Notify(" Radar", "OFF")
        if remotes.radar then
            SafeFireServer(remotes.radar, false)
        end
    end
end

local function toggleDivingGear()
    features.divingGear = not features.divingGear
    
    if features.divingGear then
        Notify(" Diving Gear", "ON")
        if remotes.oxygen then
            SafeInvokeServer(remotes.oxygen, 105)
        end
    else
        Notify(" Diving Gear", "OFF")
        if remotes.oxygen then
            SafeInvokeServer(remotes.oxygen)
        end
    end
end

-- ============================================
-- 16. TELEPORT SYSTEM
-- ============================================
local islands = {
    ["Spawn"] = Vector3.new(0, 5, 0),
    ["Coral Island"] = Vector3.new(100, 5, 50),
    ["Mermaid Lagoon"] = Vector3.new(-80, 5, 120),
    ["Deep Sea"] = Vector3.new(500, 5, 500),
    ["Frozen Fjord"] = Vector3.new(-300, 5, -300),
    ["Volcanic Island"] = Vector3.new(800, 50, -200),
    ["Ancient Ruins"] = Vector3.new(-600, 20, 400),
    ["Crystal Caverns"] = Vector3.new(200, -20, -500),
    ["Sky Islands"] = Vector3.new(0, 200, 800),
    ["Mushroom Forest"] = Vector3.new(-800, 10, 200),
}

local function teleportTo(pos)
    local root = GetRootPart()
    if root then
        root.CFrame = CFrame.new(pos)
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        Notify(" Teleport", "Success!")
    end
end

-- ============================================
-- 17. SERVER MANAGEMENT
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

local function startAutoServerHop()
    features.autoServerHop = true
    Notify(" Server Hop", "ON")
    spawn(function()
        while features.autoServerHop do
            wait(300)
            teleportService:Teleport(game.PlaceId)
        end
    end)
end

-- ============================================
-- WINDOW CREATION
-- ============================================
local Window = Library:Window({
    Title = " ULTIMATE FISH-IT v5.0 COMPLETE",
    Footer = "All Features from All 10 Links"
})

local FishTab = Window:AddTab({ Name = " Fishing", Icon = "home" })
local ToolTab = Window:AddTab({ Name = " Tools", Icon = "wrench" })
local CharTab = Window:AddTab({ Name = " Character", Icon = "user" })
local TPTab = Window:AddTab({ Name = " Teleport", Icon = "navigation" })
local UtilTab = Window:AddTab({ Name = " Utility", Icon = "settings" })

-- ============================================
-- FISHING TAB UI
-- ============================================
local FishSection = FishTab:AddSection(" Auto Fishing")

FishSection:AddToggle({
    Title = "Auto Fishing",
    Default = false,
    Callback = function(v)
        if v then startAutoFish() else stopAutoFish() end
    end
})

FishSection:AddDropdown({
    Title = "Fishing Mode",
    Options = {"Legit", "Blatant", "Instant", "Extreme"},
    Default = "Legit",
    Callback = function(v)
        fishMode = v
    end
})

FishSection:AddToggle({
    Title = "Auto Charge",
    Default = false,
    Callback = function(v)
        features.autoCharge = v
        Notify(" Auto Charge", v and "ON" or "OFF")
    end
})

local KaitunSection = FishTab:AddSection(" Kaitun System (Premium)")

KaitunSection:AddToggle({
    Title = "Enable Kaitun System",
    Default = false,
    Callback = function(v)
        if v then startKaitun() else stopKaitun() end
    end
})

KaitunSection:AddSlider({
    Title = "Kaitun Delay",
    Min = 0.1,
    Max = 2,
    Default = 0.35,
    Callback = function(v)
        kaitunDelay = v
    end
})

local ReelSection = FishTab:AddSection(" Advanced Reel System")

ReelSection:AddToggle({
    Title = "Instant Reel (SimpleAJA)",
    Default = false,
    Callback = function(v)
        if v then enableInstantReel() else disableInstantReel() end
    end
})

ReelSection:AddToggle({
    Title = "Fast Bobber",
    Default = false,
    Callback = function(v)
        if v then enableFastBobber() else features.fastBobber = false end
    end
})

ReelSection:AddToggle({
    Title = "Instant Cast",
    Default = false,
    Callback = function(v)
        if v then enableInstantCast() else features.instantCast = false end
    end
})

ReelSection:AddToggle({
    Title = "Auto Shake",
    Default = false,
    Callback = function(v)
        features.autoShake = v
    end
})

local SellSection = FishTab:AddSection(" Auto Sell")

SellSection:AddToggle({
    Title = "Auto Sell",
    Default = false,
    Callback = function(v)
        if v then startAutoSell() else stopAutoSell() end
    end
})

SellSection:AddDropdown({
    Title = "Sell Filter",
    Options = {"All", "Legendary", "Epic", "Rare", "Common"},
    Default = "All",
    Callback = function(v)
        sellFilter = v
    end
})

local UpgradeSection = FishTab:AddSection(" Auto Upgrades")

UpgradeSection:AddToggle({
    Title = "Auto Enchant",
    Default = false,
    Callback = function(v)
        if v then startAutoEnchant() else features.autoEnchant = false end
    end
})

UpgradeSection:AddToggle({
    Title = "Auto Open Crate",
    Default = false,
    Callback = function(v)
        if v then startAutoOpenCrate() else features.autoOpenCrate = false end
    end
})

UpgradeSection:AddToggle({
    Title = "Auto Equip Skin",
    Default = false,
    Callback = function(v)
        if v then startAutoEquipSkin() else features.autoEquipSkin = false end
    end
})

UpgradeSection:AddToggle({
    Title = "Auto Buy",
    Default = false,
    Callback = function(v)
        if v then startAutoBuy() else features.autoBuy = false end
    end
})

UpgradeSection:AddToggle({
    Title = "Auto Totem",
    Default = false,
    Callback = function(v)
        if v then startAutoTotem() else features.autoTotem = false end
    end
})

local QuestSection = FishTab:AddSection(" Quest System")

QuestSection:AddToggle({
    Title = "Auto Quest",
    Default = false,
    Callback = function(v)
        if v then startAutoQuest() else features.autoQuest = false end
    end
})

local PerfectSection = FishTab:AddSection(" Perfect Catch (SkuyyHub)")

PerfectSection:AddToggle({
    Title = "Legacy Perfect Catch",
    Default = false,
    Callback = function(v)
        if v then startLegitPerfect() else features.legacyPerfect = false end
    end
})

local CollectSection = FishTab:AddSection(" Item Collection (SkuyyHub)")

CollectSection:AddToggle({
    Title = "Auto Collect Shells",
    Default = false,
    Callback = function(v)
        if v then startAutoShell() else features.autoShell = false end
    end
})

-- ============================================
-- TOOLS TAB UI
-- ============================================
local MovementSection = ToolTab:AddSection(" Movement")

MovementSection:AddToggle({
    Title = "Fly",
    Default = false,
    Callback = function(v)
        toggleFly()
    end
})

MovementSection:AddSlider({
    Title = "Fly Speed",
    Min = 10,
    Max = 500,
    Default = 100,
    Callback = function(v)
        flySpeed = v
    end
})

MovementSection:AddToggle({
    Title = "Noclip",
    Default = false,
    Callback = function(v)
        toggleNoclip()
    end
})

MovementSection:AddToggle({
    Title = "Speed Hack",
    Default = false,
    Callback = function(v)
        toggleSpeedHack()
    end
})

local VisualSection = ToolTab:AddSection(" Visual")

VisualSection:AddToggle({
    Title = "ESP Players",
    Default = false,
    Callback = function(v)
        if v then enableESP() else features.espEnabled = false end
    end
})

VisualSection:AddToggle({
    Title = "FPS Boost",
    Default = false,
    Callback = function(v)
        toggleFPSBoost()
    end
})

VisualSection:AddToggle({
    Title = "Black Screen",
    Default = false,
    Callback = function(v)
        toggleBlackScreen()
    end
})

VisualSection:AddToggle({
    Title = "Disable Notifications",
    Default = false,
    Callback = function(v)
        features.disableNotif = v
    end
})

local SpecialSection = ToolTab:AddSection(" Special Features")

SpecialSection:AddToggle({
    Title = "Auto Radar",
    Default = false,
    Callback = function(v)
        toggleAutoRadar()
    end
})

SpecialSection:AddToggle({
    Title = "Diving Gear",
    Default = false,
    Callback = function(v)
        toggleDivingGear()
    end
})

-- ============================================
-- CHARACTER TAB UI
-- ============================================
local ProtectSection = CharTab:AddSection(" Protection")

ProtectSection:AddToggle({
    Title = "Anti-AFK",
    Default = false,
    Callback = function(v)
        if v then startAntiAFK() else features.antiAFK = false end
    end
})

ProtectSection:AddToggle({
    Title = "Anti-Drown",
    Default = false,
    Callback = function(v)
        if v then startAntiDrown() else features.antiDrown = false end
    end
})

ProtectSection:AddToggle({
    Title = "Auto Heal",
    Default = false,
    Callback = function(v)
        if v then startAutoHeal() else features.autoHeal = false end
    end
})

local EnhanceSection = CharTab:AddSection(" Enhancements")

EnhanceSection:AddToggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v)
        toggleInfiniteJump()
    end
})

EnhanceSection:AddToggle({
    Title = "Freeze Character",
    Default = false,
    Callback = function(v)
        toggleFreezeCharacter()
    end
})

EnhanceSection:AddSlider({
    Title = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(v)
        customJumpPower = v
        if GetHumanoid() then
            GetHumanoid().JumpPower = v
        end
    end
})

-- ============================================
-- TELEPORT TAB UI
-- ============================================
local TPSection = TPTab:AddSection(" Island Teleport")

for name, pos in pairs(islands) do
    TPSection:AddButton({
        Title = "TP: " .. name,
        Callback = function()
            teleportTo(pos)
        end
    })
end

TPSection:AddInput({
    Title = "Custom Teleport",
    Default = "0,5,0",
    Callback = function(v)
        local parts = {}
        for num in v:gmatch("%-?%d+%.?%d*") do
            table.insert(parts, tonumber(num))
        end
        if #parts >= 3 then
            teleportTo(Vector3.new(parts[1], parts[2], parts[3]))
        end
    end
})

-- ============================================
-- UTILITY TAB UI
-- ============================================
local InfoSection = UtilTab:AddSection(" Script Info")

InfoSection:AddLabel(" Detected Remotes: " .. tostring(#detectedRemotes))
InfoSection:AddLabel(" All 10 Links Features:  Integrated")

InfoSection:AddButton({
    Title = "Show Detected Remotes",
    Callback = function()
        local txt = "DETECTED REMOTES:\n\n"
        for i, r in pairs(detectedRemotes) do
            txt = txt .. i .. ". " .. r.name .. " (" .. r.type .. ")\n"
        end
        print(txt)
        Notify(" Remotes", "Printed to console! (" .. #detectedRemotes .. " found)")
    end
})

local ServerSection = UtilTab:AddSection(" Server Management")

ServerSection:AddToggle({
    Title = "Auto Rejoin",
    Default = false,
    Callback = function(v)
        if v then startAutoRejoin() else features.autoRejoin = false end
    end
})

ServerSection:AddToggle({
    Title = "Auto Server Hop",
    Default = false,
    Callback = function(v)
        if v then startAutoServerHop() else features.autoServerHop = false end
    end
})

ServerSection:AddButton({
    Title = "Server Hop Now",
    Callback = function()
        teleportService:Teleport(game.PlaceId)
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
        teleportTo(Vector3.new(0, 5, 0))
    elseif input.KeyCode == Enum.KeyCode.F3 then
        if features.autoOpenCrate then features.autoOpenCrate = false else startAutoOpenCrate() end
    elseif input.KeyCode == Enum.KeyCode.F4 then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        toggleSpeedHack()
    elseif input.KeyCode == Enum.KeyCode.F6 then
        if features.espEnabled then features.espEnabled = false else enableESP() end
    elseif input.KeyCode == Enum.KeyCode.F7 then
        if features.autoSell then stopAutoSell() else startAutoSell() end
    elseif input.KeyCode == Enum.KeyCode.F8 then
        if features.kaitunMode then stopKaitun() else startKaitun() end
    elseif input.KeyCode == Enum.KeyCode.F9 then
        if features.instantReel then disableInstantReel() else enableInstantReel() end
    elseif input.KeyCode == Enum.KeyCode.F10 then
        toggleNoclip()
    end
end)
 
-- ============================================
-- INITIALIZATION
-- ============================================
wait(1)
findAllRemotes()
Library:Initialize()

Notify(" ULTIMATE FISH-IT v5.0 COMPLETE", "Semua 10 Link Integrated!", 5)

print("========================================")
print(" ULTIMATE FISH-IT v5.0 COMPLETE")
print("========================================")
print(" Total Remotes Found: " .. #detectedRemotes)
print(" Features Integrated:")
print("  1. Original Fish-it v4 (Main script)")
print("  2. manager_fishing (Vesteria)")
print("  3. STREE HUB Dev.lua")
print("  4. STREE HUB Premium.lua")
print("  5. auto_reel_headless (SimpleAJA)")
print("  6. fishing_event_monitor")
print("  7. fishing_automation_exploits")
print("  8. fisch.lua (Generic fishing)")
print("  9. SkuyyHub FishIt Init")
print(" 10. Deepwoken Script")
print("========================================")
print(" HOTKEYS:")
print("F1 = Toggle Auto Fishing")
print("F2 = TP Spawn")
print("F3 = Toggle Crate")
print("F4 = Toggle Fly")
print("F5 = Toggle Speed")
print("F6 = Toggle ESP")
print("F7 = Toggle Sell")
print("F8 = Toggle Kaitun")
print("F9 = Toggle Instant Reel")
print("F10 = Toggle Noclip")
print("========================================")
