-- ============================================
-- ULTIMATE FISH-IT SCRIPT v5.0 - DELTA FIX
-- SEMUA FITUR DARI SEMUA 10 LINK DIGABUNG
-- ============================================

-- [[ DELTA EXECUTOR COMPATIBILITY ]]
local isDelta = syn and syn.protect_gui or false

-- Load Library dengan fallback untuk Delta
local Library = nil
local LibraryLoaded = false

local function LoadLibrary()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/mdwpanel/Roblox/refs/heads/main/main_ui_modern.lua"))()
    end)
    if success and result then
        Library = result
        LibraryLoaded = true
        return true
    end
    return false
end

-- Tunggu library
local attempts = 0
while not LibraryLoaded and attempts < 15 do
    attempts = attempts + 1
    if LoadLibrary() then break end
    task.wait(0.5)
end

if not LibraryLoaded then
    -- Fallback: buat UI sederhana
    print("Library not loaded, using fallback UI")
    Library = {
        MakeNotify = function(t)
            print("[" .. t.Title .. "] " .. t.Content)
        end,
        Window = function(t)
            return {
                AddTab = function()
                    return {
                        AddSection = function()
                            return {
                                AddToggle = function() end,
                                AddDropdown = function() end,
                                AddButton = function() end,
                                AddSlider = function() end,
                                AddInput = function() end,
                                AddLabel = function() end,
                            }
                        end
                    }
                end
            }
        end,
        Initialize = function() end
    }
    LibraryLoaded = true
end

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
local teleportService = game:GetService("TeleportService")
local lighting = game:GetService("Lighting")
local coreGui = game:GetService("CoreGui")
local tweenService = game:GetService("TweenService")

-- ============================================
-- REMOTE DETECTION
-- ============================================
local remotes = {}
local detectedRemotes = {}

local function findAllRemotes()
    detectedRemotes = {}
    remotes = {}
    
    local function searchFolder(folder, depth, path)
        if depth > 6 then return end
        for _, obj in pairs(folder:GetChildren()) do
            local fullPath = path .. "/" .. obj.Name
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                table.insert(detectedRemotes, {name = obj.Name, path = fullPath, obj = obj, type = obj.ClassName})
                
                if name:find("fish") or name:find("cast") then remotes.fish = obj end
                if name:find("reel") or name:find("catch") or name:find("complete") then remotes.reel = obj end
                if name:find("sell") or name:find("shop") or name:find("sellall") then remotes.sell = obj end
                if name:find("enchant") then remotes.enchant = obj end
                if name:find("crate") or name:find("open") then remotes.crate = obj end
                if name:find("equip") or name:find("skin") or name:find("hotbar") then remotes.equipSkin = obj end
                if name:find("buy") or name:find("purchase") then remotes.buy = obj end
                if name:find("totem") then remotes.totem = obj end
                if name:find("quest") then remotes.quest = obj end
                if name:find("bobber") or name:find("handle") then remotes.bobber = obj end
                if name:find("charge") or name:find("charging") then remotes.charge = obj end
                if name:find("minigame") then remotes.minigame = obj end
                if name:find("auto") or name:find("state") then remotes.auto = obj end
                if name:find("radar") then remotes.radar = obj end
                if name:find("oxygen") or name:find("diving") then remotes.oxygen = obj end
            elseif obj:IsA("Folder") then
                searchFolder(obj, depth + 1, fullPath)
            end
        end
    end
    
    searchFolder(replicatedStorage, 0, "RS")
    
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
}

local lastCall = {}

local features = {
    autoFish = false,
    autoSell = false,
    autoEnchant = false,
    autoOpenCrate = false,
    autoEquipSkin = false,
    autoBuy = false,
    autoTotem = false,
    autoQuest = false,
    antiAFK = false,
    antiDrown = false,
    autoHeal = false,
    infiniteJump = false,
    flyEnabled = false,
    noclipEnabled = false,
    speedHack = false,
    freezeCharacter = false,
    espEnabled = false,
    fpsBoost = false,
    disableNotif = false,
    blackScreen = false,
    kaitunMode = false,
    autoCharge = false,
    autoRadar = false,
    divingGear = false,
    instantReel = false,
    fastBobber = false,
    instantCast = false,
    autoShake = false,
    autoShell = false,
    legacyPerfect = false,
}

local fishMode = "Legit"
local sellFilter = "All"
local flySpeed = 100
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
    if not features.disableNotif and Library and Library.MakeNotify then
        pcall(function()
            Library:MakeNotify({Title = title, Content = desc, Duration = duration or 3})
        end)
    end
    print("[" .. title .. "] " .. desc)
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
        task.wait(minDelay - (now - lastCall[key]))
    end
    local success, result = pcall(func)
    lastCall[key] = os.clock()
    if not success then
        local msg = tostring(result):lower()
        if msg:find("429") or msg:find("too many requests") then
            task.wait(CONFIG.CallBackoff)
        end
    end
    return success, result
end

-- ============================================
-- AUTO FISHING
-- ============================================
local fishingLoop = nil

local function startAutoFish()
    features.autoFish = true
    Notify(" Auto Fishing", "ON - Mode: " .. fishMode)
    
    if fishingLoop then
        pcall(function() fishingLoop:Disconnect() end)
        fishingLoop = nil
    end
    
    fishingLoop = runService.Heartbeat:Connect(function()
        if not features.autoFish then
            if fishingLoop then fishingLoop:Disconnect() end
            return
        end
        
        local character = player.Character
        if not character then return end
        
        if remotes.auto then
            SafeCall("autoon", function()
                SafeInvokeServer(remotes.auto, true)
            end)
        end
        
        if remotes.fish then
            SafeCall("fish", function()
                SafeFireServer(remotes.fish)
            end)
        end
        
        if remotes.equipSkin then
            SafeCall("equiprod", function()
                SafeFireServer(remotes.equipSkin, 1)
            end)
        end
        
        local delay_time = fishMode == "Instant" and 0.3 or 
                          fishMode == "Blatant" and 0.8 or 
                          fishMode == "Extreme" and 0.5 or 1.5
        
        task.wait(delay_time)
        
        if remotes.reel then
            SafeCall("reel", function()
                SafeFireServer(remotes.reel)
            end)
        end
        
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
-- AUTO SELL
-- ============================================
local sellLoop = nil

local function startAutoSell()
    features.autoSell = true
    Notify(" Auto Sell", "ON - Filter: " .. sellFilter)
    
    if sellLoop then
        pcall(function() sellLoop:Disconnect() end)
        sellLoop = nil
    end
    
    sellLoop = runService.Heartbeat:Connect(function()
        if not features.autoSell then
            if sellLoop then sellLoop:Disconnect() end
            return
        end
        
        if remotes.sell then
            SafeCall("sell", function()
                SafeInvokeServer(remotes.sell)
                SafeFireServer(remotes.sell, sellFilter)
                SafeFireServer(remotes.sell)
            end)
        end
        task.wait(CONFIG.SellDelay)
    end)
end

local function stopAutoSell()
    features.autoSell = false
    if sellLoop then
        pcall(function() sellLoop:Disconnect() end)
        sellLoop = nil
    end
    Notify(" Auto Sell", "OFF")
end

-- ============================================
-- KAITUN SYSTEM
-- ============================================
local kaitunScreenGui = nil
local kaitunLoop = nil

local function CreateKaitunBackground()
    if kaitunScreenGui then kaitunScreenGui:Destroy() end
    
    kaitunScreenGui = Instance.new("ScreenGui")
    kaitunScreenGui.IgnoreGuiInset = true
    kaitunScreenGui.ResetOnSpawn = false
    kaitunScreenGui.Name = "KAITUN_BG"
    
    -- Untuk Delta, parent ke PlayerGui
    local success, err = pcall(function()
        kaitunScreenGui.Parent = player.PlayerGui
    end)
    if not success then
        kaitunScreenGui.Parent = coreGui
    end
    
    local bg = Instance.new("Frame")
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.ZIndex = 0
    bg.Parent = kaitunScreenGui
    
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
end

local function RemoveKaitunBackground()
    if kaitunScreenGui then
        kaitunScreenGui:Destroy()
        kaitunScreenGui = nil
    end
end

local function startKaitun()
    features.kaitunMode = true
    Notify(" Kaitun System", "ACTIVATED!")
    CreateKaitunBackground()
    
    if kaitunLoop then
        pcall(function() kaitunLoop:Disconnect() end)
        kaitunLoop = nil
    end
    
    kaitunLoop = runService.Heartbeat:Connect(function()
        if not features.kaitunMode then
            if kaitunLoop then kaitunLoop:Disconnect() end
            return
        end
        
        if remotes.equipSkin then
            SafeCall("eq", function()
                SafeFireServer(remotes.equipSkin, 1)
            end)
        end
        
        if remotes.charge then
            SafeCall("ch", function()
                SafeInvokeServer(remotes.charge, 1762631511.436375)
            end)
        end
        
        if remotes.minigame then
            SafeCall("mg", function()
                SafeInvokeServer(remotes.minigame, -1.233, 0.996, 1761532005.497)
            end)
        end
        
        task.wait(kaitunDelay)
        
        if remotes.reel then
            SafeCall("ct", function()
                SafeFireServer(remotes.reel)
            end)
        end
        
        if remotes.sell then
            SafeCall("sl", function()
                SafeInvokeServer(remotes.sell)
            end)
        end
        
        task.wait(kaitunDelay)
    end)
end

local function stopKaitun()
    features.kaitunMode = false
    if kaitunLoop then
        pcall(function() kaitunLoop:Disconnect() end)
        kaitunLoop = nil
    end
    RemoveKaitunBackground()
    Notify(" Kaitun System", "DEACTIVATED")
end

-- ============================================
-- INSTANT REEL
-- ============================================
local isReelRunning = false
local reelHeartbeat = nil

local function instantReelAction()
    if not isReelRunning or not features.instantReel then return end
    
    local playerGui = player.PlayerGui
    local fishingGui = playerGui:FindFirstChild("FishingGUI") or playerGui:FindFirstChild("reel")
    
    if fishingGui then
        local reelButton = fishingGui:FindFirstChild("Reel")
        if reelButton and reelButton.Visible then
            pcall(function()
                if reelButton:IsA("ImageButton") or reelButton:IsA("TextButton") then
                    reelButton:FireEvent("MouseButton1Click")
                end
            end)
            return
        end
        
        if features.autoShake then
            local shakeButton = fishingGui:FindFirstChild("Shake")
            if shakeButton and shakeButton.Visible then
                pcall(function()
                    if shakeButton:IsA("ImageButton") or shakeButton:IsA("TextButton") then
                        shakeButton:FireEvent("MouseButton1Click")
                    end
                end)
            end
        end
    end
    
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
    
    if reelHeartbeat then
        pcall(function() reelHeartbeat:Disconnect() end)
        reelHeartbeat = nil
    end
    
    reelHeartbeat = runService.RenderStepped:Connect(function()
        if isReelRunning and features.instantReel then
            instantReelAction()
        end
    end)
end

local function disableInstantReel()
    features.instantReel = false
    isReelRunning = false
    if reelHeartbeat then
        pcall(function() reelHeartbeat:Disconnect() end)
        reelHeartbeat = nil
    end
    Notify(" Instant Reel", "OFF")
end

-- ============================================
-- FAST BOBBER
-- ============================================
local bobberConnection = nil

local function enableFastBobber()
    features.fastBobber = true
    Notify(" Fast Bobber", "ON")
    
    if bobberConnection then
        pcall(function() bobberConnection:Disconnect() end)
        bobberConnection = nil
    end
    
    bobberConnection = runService.Heartbeat:Connect(function()
        if not features.fastBobber then return end
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("bobber") or obj.Name:lower():find("float") then
                if obj:IsA("BasePart") then
                    if obj.AssemblyLinearVelocity then
                        obj.AssemblyLinearVelocity = Vector3.new(0, -120, 0)
                    end
                    
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
-- INSTANT CAST
-- ============================================
local castConnection = nil

local function enableInstantCast()
    features.instantCast = true
    Notify(" Instant Cast", "ON")
    
    if castConnection then
        pcall(function() castConnection:Disconnect() end)
        castConnection = nil
    end
    
    castConnection = runService.Heartbeat:Connect(function()
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
-- AUTO UPGRADES
-- ============================================
local enchantLoop = nil

local function startAutoEnchant()
    features.autoEnchant = true
    Notify(" Auto Enchant", "ON")
    
    if enchantLoop then
        pcall(function() enchantLoop:Disconnect() end)
        enchantLoop = nil
    end
    
    enchantLoop = runService.Heartbeat:Connect(function()
        if not features.autoEnchant then
            if enchantLoop then enchantLoop:Disconnect() end
            return
        end
        if remotes.enchant then
            SafeCall("ench", function()
                SafeFireServer(remotes.enchant)
            end)
        end
        task.wait(CONFIG.EnchantDelay)
    end)
end

local crateLoop = nil

local function startAutoOpenCrate()
    features.autoOpenCrate = true
    Notify(" Auto Crate", "ON")
    
    if crateLoop then
        pcall(function() crateLoop:Disconnect() end)
        crateLoop = nil
    end
    
    crateLoop = runService.Heartbeat:Connect(function()
        if not features.autoOpenCrate then
            if crateLoop then crateLoop:Disconnect() end
            return
        end
        if remotes.crate then
            SafeCall("crt", function()
                SafeFireServer(remotes.crate)
            end)
        end
        task.wait(CONFIG.CrateDelay)
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
            task.wait(5)
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
                    task.wait(1)
                    SafeFireServer(remotes.buy, "bait")
                    task.wait(1)
                    SafeFireServer(remotes.buy, "bobber")
                end)
            end
            task.wait(10)
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
            task.wait(CONFIG.TotemDelay)
        end
    end)
end

-- ============================================
-- AUTO QUEST
-- ============================================
local questTypes = {"DeepSea", "AuraKid", "ElementJungle", "Quest1", "Quest2", "Ghostfin"}

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
                    task.wait(2)
                end
            end
            task.wait(10)
        end
    end)
end

-- ============================================
-- AUTO SHELL
-- ============================================
local shellLoop = nil

local function startAutoShell()
    features.autoShell = true
    Notify(" Auto Shell", "ON")
    
    if shellLoop then
        pcall(function() shellLoop:Disconnect() end)
        shellLoop = nil
    end
    
    shellLoop = runService.Heartbeat:Connect(function()
        if not features.autoShell then
            if shellLoop then shellLoop:Disconnect() end
            return
        end
        
        task.wait(0.3)
        
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name:lower():find("shell") or obj.Name:lower():find("seashell") or 
               obj.Name:lower():find("pearl") or obj.Name:lower():find("treasure") then
                
                local clickDetector = obj:FindFirstChildOfClass("ClickDetector")
                if clickDetector then
                    pcall(function()
                        clickDetector:FireClick(mouse.X, mouse.Y)
                    end)
                end
                
                local proximityPrompt = obj:FindFirstChildOfClass("ProximityPrompt")
                if proximityPrompt then
                    pcall(function()
                        proximityPrompt:Prompt(player.Character)
                    end)
                end
            end
        end
    end)
end

-- ============================================
-- PERFECT CATCH
-- ============================================
local perfectLoop = nil

local function startLegitPerfect()
    features.legacyPerfect = true
    Notify(" Perfect Catch", "ON")
    
    if perfectLoop then
        pcall(function() perfectLoop:Disconnect() end)
        perfectLoop = nil
    end
    
    perfectLoop = runService.Heartbeat:Connect(function()
        if not features.legacyPerfect then
            if perfectLoop then perfectLoop:Disconnect() end
            return
        end
        
        task.wait(0.01)
        
        local fishingGui = player.PlayerGui:FindFirstChild("FishingGui")
        if not fishingGui then return end
        
        local perfectZone = fishingGui:FindFirstChild("PerfectZone")
        if perfectZone and perfectZone.Visible then
            local indicator = perfectZone:FindFirstChild("Indicator")
            local zoneFrame = perfectZone:FindFirstChild("Zone")
            
            if zoneFrame and indicator then
                local indicatorPos = indicator.Position.X.Scale
                local zoneStart = zoneFrame.Position.X.Scale
                local zoneEnd = zoneFrame.Position.X.Scale + zoneFrame.Size.X.Scale
                
                if indicatorPos >= zoneStart and indicatorPos <= zoneEnd then
                    task.wait(math.random(20, 80) / 1000)
                    if remotes.reel then
                        SafeCall("pf", function()
                            SafeFireServer(remotes.reel)
                        end)
                    end
                end
            end
        end
    end)
end

-- ============================================
-- CHARACTER ENHANCEMENT
-- ============================================
local antiAFKConnection = nil

local function startAntiAFK()
    features.antiAFK = true
    Notify(" Anti-AFK", "ON")
    
    if antiAFKConnection then
        pcall(function() antiAFKConnection:Disconnect() end)
        antiAFKConnection = nil
    end
    
    antiAFKConnection = runService.RenderStepped:Connect(function()
        if features.antiAFK and player.Character then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid:Move(Vector3.new(0, 0, 0), true)
            end
        end
    end)
end

local antiDrownConnection = nil

local function startAntiDrown()
    features.antiDrown = true
    Notify(" Anti-Drown", "ON")
    
    if antiDrownConnection then
        pcall(function() antiDrownConnection:Disconnect() end)
        antiDrownConnection = nil
    end
    
    antiDrownConnection = runService.RenderStepped:Connect(function()
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
                        task.wait(0.5)
                        break
                    end
                end
            end
            task.wait(2)
        end
    end)
end

local infiniteJumpConnection = nil

local function toggleInfiniteJump()
    features.infiniteJump = not features.infiniteJump
    
    if features.infiniteJump then
        Notify(" Infinite Jump", "ON")
        if infiniteJumpConnection then
            pcall(function() infiniteJumpConnection:Disconnect() end)
            infiniteJumpConnection = nil
        end
        infiniteJumpConnection = userInput.JumpRequest:Connect(function()
            if features.infiniteJump then
                local humanoid = GetHumanoid()
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if infiniteJumpConnection then
            pcall(function() infiniteJumpConnection:Disconnect() end)
            infiniteJumpConnection = nil
        end
        Notify(" Infinite Jump", "OFF")
    end
end

-- ============================================
-- MOVEMENT ENHANCEMENTS
-- ============================================
local flyConnection = nil

local function toggleFly()
    features.flyEnabled = not features.flyEnabled
    
    if features.flyEnabled then
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.PlatformStand = true
            Notify(" Fly", "ON")
            
            if flyConnection then
                pcall(function() flyConnection:Disconnect() end)
                flyConnection = nil
            end
            
            flyConnection = runService.RenderStepped:Connect(function()
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
        end
    else
        if flyConnection then
            pcall(function() flyConnection:Disconnect() end)
            flyConnection = nil
        end
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.PlatformStand = false
        end
        Notify(" Fly", "OFF")
    end
end

local noclipConnection = nil

local function toggleNoclip()
    features.noclipEnabled = not features.noclipEnabled
    
    if features.noclipEnabled then
        Notify(" Noclip", "ON")
        if noclipConnection then
            pcall(function() noclipConnection:Disconnect() end)
            noclipConnection = nil
        end
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
            pcall(function() noclipConnection:Disconnect() end)
            noclipConnection = nil
        end
        Notify(" Noclip", "OFF")
    end
end

local speedConnection = nil

local function toggleSpeedHack()
    features.speedHack = not features.speedHack
    
    if features.speedHack then
        Notify(" Speed Hack", "ON")
        if speedConnection then
            pcall(function() speedConnection:Disconnect() end)
            speedConnection = nil
        end
        speedConnection = runService.RenderStepped:Connect(function()
            if features.speedHack then
                local humanoid = GetHumanoid()
                if humanoid then
                    humanoid.WalkSpeed = 100
                    humanoid.JumpPower = 200
                end
            end
        end)
    else
        if speedConnection then
            pcall(function() speedConnection:Disconnect() end)
            speedConnection = nil
        end
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
        Notify(" Speed Hack", "OFF")
    end
end

local freezeConnection = nil
local originalCFrame = nil

local function toggleFreezeCharacter()
    features.freezeCharacter = not features.freezeCharacter
    
    if features.freezeCharacter then
        Notify(" Freeze", "ON")
        local root = GetRootPart()
        if root then
            originalCFrame = root.CFrame
            if freezeConnection then
                pcall(function() freezeConnection:Disconnect() end)
                freezeConnection = nil
            end
            freezeConnection = runService.Heartbeat:Connect(function()
                if features.freezeCharacter then
                    local rootPart = GetRootPart()
                    if rootPart and originalCFrame then
                        rootPart.CFrame = originalCFrame
                        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        end
    else
        if freezeConnection then
            pcall(function() freezeConnection:Disconnect() end)
            freezeConnection = nil
        end
        Notify(" Freeze", "OFF")
    end
end

-- ============================================
-- VISUAL ENHANCEMENTS
-- ============================================
local espConnection = nil

local function enableESP()
    features.espEnabled = true
    Notify(" ESP", "ON")
    
    if espConnection then
        pcall(function() espConnection:Disconnect() end)
        espConnection = nil
    end
    
    local function addHighlight(char)
        if char and not char:FindFirstChildOfClass("Highlight") then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = char
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.3
            highlight.Parent = char
        end
    end
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character then
            addHighlight(v.Character)
        end
    end
    
    espConnection = Players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if features.espEnabled then
                addHighlight(char)
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
        settings().Rendering.QualityLevel = 1
    else
        Notify(" FPS Boost", "OFF")
        lighting.GlobalShadows = true
        lighting.Technology = Enum.Technology.ShadowMap
        settings().Rendering.QualityLevel = 3
    end
end

local blackScreenGui = nil

local function toggleBlackScreen()
    features.blackScreen = not features.blackScreen
    
    if features.blackScreen then
        Notify(" Black Screen", "ON")
        if blackScreenGui then blackScreenGui:Destroy() end
        
        blackScreenGui = Instance.new("ScreenGui")
        blackScreenGui.IgnoreGuiInset = true
        blackScreenGui.ResetOnSpawn = false
        blackScreenGui.Name = "BLACK_SCREEN"
        blackScreenGui.Parent = player.PlayerGui or coreGui
        
        local frame = Instance.new("Frame")
        frame.Parent = blackScreenGui
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
        if blackScreenGui then
            blackScreenGui:Destroy()
            blackScreenGui = nil
        end
        Notify(" Black Screen", "OFF")
    end
end

-- ============================================
-- RADAR & DIVING
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
-- TELEPORT
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
-- SERVER MANAGEMENT
-- ============================================
local rejoinActive = false

local function startAutoRejoin()
    features.autoRejoin = true
    rejoinActive = true
    Notify(" Auto Rejoin", "ON")
    player.OnTeleport:Connect(function()
        if rejoinActive then
            task.wait(5)
            teleportService:Teleport(game.PlaceId)
        end
    end)
end

local serverHopLoop = nil

local function startAutoServerHop()
    features.autoServerHop = true
    Notify(" Server Hop", "ON")
    
    if serverHopLoop then
        pcall(function() serverHopLoop:Disconnect() end)
        serverHopLoop = nil
    end
    
    serverHopLoop = runService.Heartbeat:Connect(function()
        if not features.autoServerHop then
            if serverHopLoop then serverHopLoop:Disconnect() end
            return
        end
        task.wait(300)
        teleportService:Teleport(game.PlaceId)
    end)
end

-- ============================================
-- CREATE WINDOW - PASTIKAN MUNCUL
-- ============================================
local function CreateUI()
    -- Tunggu sampai UI library siap
    if not LibraryLoaded then
        task.wait(1)
        if not LibraryLoaded then
            print("Library not loaded, cannot create UI")
            return
        end
    end
    
    -- Buat Window
    local Window = Library:Window({
        Title = " ULTIMATE FISH-IT v5.0",
        Footer = "All Features from All 10 Links | Delta Compatible"
    })
    
    if not Window then
        print("Failed to create window")
        return
    end
    
    -- === FISHING TAB ===
    local FishTab = Window:AddTab({ Name = " Fishing", Icon = "home" })
    
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
    
    -- Kaitun Section
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
    
    -- Reel Section
    local ReelSection = FishTab:AddSection(" Advanced Reel System")
    
    ReelSection:AddToggle({
        Title = "Instant Reel",
        Default = false,
        Callback = function(v)
            if v then enableInstantReel() else disableInstantReel() end
        end
    })
    
    ReelSection:AddToggle({
        Title = "Fast Bobber",
        Default = false,
        Callback = function(v)
            if v then enableFastBobber() else 
                features.fastBobber = false
                if bobberConnection then
                    pcall(function() bobberConnection:Disconnect() end)
                    bobberConnection = nil
                end
            end
        end
    })
    
    ReelSection:AddToggle({
        Title = "Instant Cast",
        Default = false,
        Callback = function(v)
            if v then enableInstantCast() else 
                features.instantCast = false
                if castConnection then
                    pcall(function() castConnection:Disconnect() end)
                    castConnection = nil
                end
            end
        end
    })
    
    ReelSection:AddToggle({
        Title = "Auto Shake",
        Default = false,
        Callback = function(v)
            features.autoShake = v
        end
    })
    
    -- Sell Section
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
    
    -- Upgrade Section
    local UpgradeSection = FishTab:AddSection(" Auto Upgrades")
    
    UpgradeSection:AddToggle({
        Title = "Auto Enchant",
        Default = false,
        Callback = function(v)
            if v then startAutoEnchant() else 
                features.autoEnchant = false
                if enchantLoop then
                    pcall(function() enchantLoop:Disconnect() end)
                    enchantLoop = nil
                end
            end
        end
    })
    
    UpgradeSection:AddToggle({
        Title = "Auto Open Crate",
        Default = false,
        Callback = function(v)
            if v then startAutoOpenCrate() else 
                features.autoOpenCrate = false
                if crateLoop then
                    pcall(function() crateLoop:Disconnect() end)
                    crateLoop = nil
                end
            end
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
    
    -- Quest Section
    local QuestSection = FishTab:AddSection(" Quest System")
    
    QuestSection:AddToggle({
        Title = "Auto Quest",
        Default = false,
        Callback = function(v)
            if v then startAutoQuest() else features.autoQuest = false end
        end
    })
    
    -- Perfect Catch
    local PerfectSection = FishTab:AddSection(" Perfect Catch")
    
    PerfectSection:AddToggle({
        Title = "Legacy Perfect Catch",
        Default = false,
        Callback = function(v)
            if v then startLegitPerfect() else 
                features.legacyPerfect = false
                if perfectLoop then
                    pcall(function() perfectLoop:Disconnect() end)
                    perfectLoop = nil
                end
            end
        end
    })
    
    -- Collect Section
    local CollectSection = FishTab:AddSection(" Item Collection")
    
    CollectSection:AddToggle({
        Title = "Auto Collect Shells",
        Default = false,
        Callback = function(v)
            if v then startAutoShell() else 
                features.autoShell = false
                if shellLoop then
                    pcall(function() shellLoop:Disconnect() end)
                    shellLoop = nil
                end
            end
        end
    })
    
    -- === TOOLS TAB ===
    local ToolTab = Window:AddTab({ Name = " Tools", Icon = "wrench" })
    
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
            if v then enableESP() else 
                features.espEnabled = false
                if espConnection then
                    pcall(function() espConnection:Disconnect() end)
                    espConnection = nil
                end
            end
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
    
    -- === CHARACTER TAB ===
    local CharTab = Window:AddTab({ Name = " Character", Icon = "user" })
    
    local ProtectSection = CharTab:AddSection(" Protection")
    
    ProtectSection:AddToggle({
        Title = "Anti-AFK",
        Default = false,
        Callback = function(v)
            if v then startAntiAFK() else 
                features.antiAFK = false
                if antiAFKConnection then
                    pcall(function() antiAFKConnection:Disconnect() end)
                    antiAFKConnection = nil
                end
            end
        end
    })
    
    ProtectSection:AddToggle({
        Title = "Anti-Drown",
        Default = false,
        Callback = function(v)
            if v then startAntiDrown() else 
                features.antiDrown = false
                if antiDrownConnection then
                    pcall(function() antiDrownConnection:Disconnect() end)
                    antiDrownConnection = nil
                end
            end
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
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.JumpPower = v
            end
        end
    })
    
    -- === TELEPORT TAB ===
    local TPTab = Window:AddTab({ Name = " Teleport", Icon = "navigation" })
    
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
    
    -- === UTILITY TAB ===
    local UtilTab = Window:AddTab({ Name = " Utility", Icon = "settings" })
    
    local InfoSection = UtilTab:AddSection(" Script Info")
    
    InfoSection:AddLabel(" Detected Remotes: " .. tostring(#detectedRemotes))
    InfoSection:AddLabel(" All 10 Links Features:  Integrated")
    InfoSection:AddLabel(" Delta Executor:  Compatible")
    
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
            if v then startAutoRejoin() else 
                features.autoRejoin = false
                rejoinActive = false
            end
        end
    })
    
    ServerSection:AddToggle({
        Title = "Auto Server Hop",
        Default = false,
        Callback = function(v)
            if v then startAutoServerHop() else 
                features.autoServerHop = false
                if serverHopLoop then
                    pcall(function() serverHopLoop:Disconnect() end)
                    serverHopLoop = nil
                end
            end
        end
    })
    
    ServerSection:AddButton({
        Title = "Server Hop Now",
        Callback = function()
            teleportService:Teleport(game.PlaceId)
        end
    })
    
    -- Initialize UI
    pcall(function()
        Library:Initialize()
    end)
    
    Notify(" UI Loaded", "ULTIMATE FISH-IT v5.0 Ready!", 3)
    print(" ULTIMATE FISH-IT v5.0 - UI Loaded Successfully!")
end

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
        if features.autoOpenCrate then 
            features.autoOpenCrate = false
            if crateLoop then
                pcall(function() crateLoop:Disconnect() end)
                crateLoop = nil
            end
        else 
            startAutoOpenCrate() 
        end
    elseif input.KeyCode == Enum.KeyCode.F4 then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        toggleSpeedHack()
    elseif input.KeyCode == Enum.KeyCode.F6 then
        if features.espEnabled then 
            features.espEnabled = false
            if espConnection then
                pcall(function() espConnection:Disconnect() end)
                espConnection = nil
            end
        else 
            enableESP() 
        end
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
-- EXECUTE UI
-- ============================================
-- Tunggu sebentar agar game siap
task.wait(1)

-- Buat UI
local success, err = pcall(CreateUI)
if not success then
    print("Error creating UI: " .. tostring(err))
    -- Fallback: coba lagi
    task.wait(2)
    pcall(CreateUI)
end

-- ============================================
-- INITIALIZATION LOG
-- ============================================
print("========================================")
print(" ULTIMATE FISH-IT v5.0 - DELTA FIX")
print("========================================")
print(" Total Remotes Found: " .. #detectedRemotes)
print(" Features from 10 Links Integrated")
print(" Delta Executor Compatible")
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