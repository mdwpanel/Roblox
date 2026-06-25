-- ============================================
-- ULTIMATE FISH-IT v5.0 FIXED VERSION
-- KOMPATIBEL DENGAN DELTA EXECUTOR
-- ============================================

print("🚀 Loading Ultimate Fish-IT v5.0...")

-- Check executor capabilities
local success = pcall(function()
    if not getgenv then error("Executor tidak support getgenv") end
    if not loadstring then error("Executor tidak support loadstring") end
end)

if not success then
    print("❌ Error: Executor capabilities tidak lengkap")
    return
end

-- ============================================
-- SAFE LIBRARY LOADING
-- ============================================
local Library = nil
local LibraryLoadSuccess = false

-- Try multiple UI libraries
local libraries = {
    "https://raw.githubusercontent.com/mdwpanel/Roblox/refs/heads/main/main_ui_modern.lua",
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/Citizen-Scripting/Citizen-UI/main/main.lua"
}

for _, libUrl in pairs(libraries) do
    print("📚 Trying to load library: " .. libUrl:sub(1, 50) .. "...")
    local success, result = pcall(function()
        return loadstring(game:HttpGet(libUrl, true))()
    end)
    
    if success and result then
        Library = result
        LibraryLoadSuccess = true
        print("✅ Library loaded successfully!")
        break
    else
        print("⚠️ Failed to load: " .. tostring(result))
    end
end

-- If no library loaded, use simple notification system
if not LibraryLoadSuccess then
    print("⚠️ Using simplified UI (no external library)")
    Library = {
        MakeNotify = function(self, data)
            print(data.Title .. ": " .. data.Content)
        end,
        Window = function(self, data)
            print("🪟 " .. data.Title)
            return {
                AddTab = function(self, data)
                    print("  📑 Tab: " .. data.Name)
                    return {
                        AddSection = function(self, data)
                            print("    📋 Section: " .. data)
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
                end,
                Initialize = function() end
            }
        end
    }
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

print("✅ All services loaded")

-- ============================================
-- REMOTE DETECTION
-- ============================================
local remotes = {}
local detectedRemotes = {}

local function findAllRemotes()
    print("🔍 Searching for remotes...")
    
    local function searchFolder(folder, depth)
        if depth > 5 then return end
        
        for _, obj in pairs(folder:GetChildren()) do
            pcall(function()
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    table.insert(detectedRemotes, obj.Name)
                    
                    if name:find("fish") or name:find("cast") then remotes.fish = obj end
                    if name:find("reel") or name:find("catch") then remotes.reel = obj end
                    if name:find("sell") then remotes.sell = obj end
                    if name:find("enchant") then remotes.enchant = obj end
                    if name:find("crate") then remotes.crate = obj end
                    if name:find("equip") or name:find("skin") then remotes.equipSkin = obj end
                    if name:find("buy") then remotes.buy = obj end
                    if name:find("trade") then remotes.trade = obj end
                    if name:find("totem") then remotes.totem = obj end
                    if name:find("quest") then remotes.quest = obj end
                    if name:find("auto") then remotes.auto = obj end
                    if name:find("charge") then remotes.charge = obj end
                elseif obj:IsA("Folder") then
                    searchFolder(obj, depth + 1)
                end
            end)
        end
    end
    
    searchFolder(replicatedStorage, 0)
    print("✅ Found " .. #detectedRemotes .. " remotes")
end

findAllRemotes()

-- ============================================
-- CONFIG
-- ============================================
local CONFIG = {
    FishDelay = 1.0,
    SellDelay = 2,
    CrateDelay = 1.5,
    EnchantDelay = 2,
}

local features = {
    autoFish = false,
    autoSell = false,
    autoEnchant = false,
    autoOpenCrate = false,
    autoEquipSkin = false,
    autoBuy = false,
    autoQuest = false,
    autoTotem = false,
    antiAFK = false,
    antiDrown = false,
    autoHeal = false,
    flyEnabled = false,
    noclipEnabled = false,
    speedHack = false,
    espEnabled = false,
    fpsBoost = false,
    instantReel = false,
    fastBobber = false,
    kaitunMode = false,
    autoShell = false,
}

local fishMode = "Legit"
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
    print("📢 [" .. title .. "] " .. desc)
    if Library and Library.MakeNotify then
        pcall(function()
            Library:MakeNotify({Title = title, Content = desc, Duration = duration or 3})
        end)
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

-- ============================================
-- AUTO FISHING
-- ============================================
local fishingLoop = nil

local function startAutoFish()
    if features.autoFish then return end
    features.autoFish = true
    Notify("🎣 Auto Fishing", "ON - Mode: " .. fishMode)
    
    if fishingLoop then 
        pcall(function() fishingLoop:Disconnect() end) 
    end
    
    fishingLoop = runService.Heartbeat:Connect(function()
        if not features.autoFish then
            if fishingLoop then 
                pcall(function() fishingLoop:Disconnect() end)
                fishingLoop = nil
            end
            return
        end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = GetHumanoid()
        if not humanoid then return end
        
        -- Fire remotes
        if remotes.auto then
            pcall(function() SafeInvokeServer(remotes.auto, true) end)
        end
        
        if remotes.fish then
            pcall(function() SafeFireServer(remotes.fish) end)
        end
        
        if remotes.equipSkin then
            pcall(function() SafeFireServer(remotes.equipSkin, 1) end)
        end
        
        local delay_time = fishMode == "Instant" and 0.3 or fishMode == "Blatant" and 0.8 or 1.5
        wait(delay_time)
        
        if remotes.reel then
            pcall(function() SafeFireServer(remotes.reel) end)
        end
    end)
end

local function stopAutoFish()
    features.autoFish = false
    if fishingLoop then
        pcall(function() fishingLoop:Disconnect() end)
        fishingLoop = nil
    end
    Notify("❌ Auto Fishing", "OFF")
end

-- ============================================
-- AUTO SELL
-- ============================================
local function startAutoSell()
    if features.autoSell then return end
    features.autoSell = true
    Notify("💰 Auto Sell", "ON")
    
    spawn(function()
        while features.autoSell do
            if remotes.sell then
                pcall(function()
                    SafeInvokeServer(remotes.sell)
                    SafeFireServer(remotes.sell, sellFilter)
                end)
            end
            wait(CONFIG.SellDelay)
        end
    end)
end

local function stopAutoSell()
    features.autoSell = false
    Notify("❌ Auto Sell", "OFF")
end

-- ============================================
-- AUTO UPGRADES
-- ============================================
local function startAutoEnchant()
    if features.autoEnchant then return end
    features.autoEnchant = true
    Notify("✨ Auto Enchant", "ON")
    
    spawn(function()
        while features.autoEnchant do
            if remotes.enchant then
                pcall(function() SafeFireServer(remotes.enchant) end)
            end
            wait(CONFIG.EnchantDelay)
        end
    end)
end

local function startAutoOpenCrate()
    if features.autoOpenCrate then return end
    features.autoOpenCrate = true
    Notify("📦 Auto Crate", "ON")
    
    spawn(function()
        while features.autoOpenCrate do
            if remotes.crate then
                pcall(function() SafeFireServer(remotes.crate) end)
            end
            wait(CONFIG.CrateDelay)
        end
    end)
end

local function startAutoTotem()
    if features.autoTotem then return end
    features.autoTotem = true
    Notify("🗿 Auto Totem", "ON")
    
    spawn(function()
        while features.autoTotem do
            if remotes.totem then
                pcall(function() SafeFireServer(remotes.totem) end)
            end
            wait(60)
        end
    end)
end

-- ============================================
-- CHARACTER FEATURES
-- ============================================
local function startAntiAFK()
    if features.antiAFK then return end
    features.antiAFK = true
    Notify("⏰ Anti-AFK", "ON")
    
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
    if features.antiDrown then return end
    features.antiDrown = true
    Notify("🌊 Anti-Drown", "ON")
    
    runService.RenderStepped:Connect(function()
        if features.antiDrown and player.Character then
            local humanoid = GetHumanoid()
            if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- ============================================
-- MOVEMENT
-- ============================================
local function toggleFly()
    features.flyEnabled = not features.flyEnabled
    local char = player.Character
    
    if char and GetHumanoid() then
        if features.flyEnabled then
            GetHumanoid().PlatformStand = true
            Notify("🛸 Fly", "ON")
            
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
            Notify("❌ Fly", "OFF")
        end
    end
end

local function toggleNoclip()
    features.noclipEnabled = not features.noclipEnabled
    
    if features.noclipEnabled then
        Notify("👻 Noclip", "ON")
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
        Notify("❌ Noclip", "OFF")
    end
end

local function toggleSpeedHack()
    features.speedHack = not features.speedHack
    
    if features.speedHack then
        Notify("⚡ Speed Hack", "ON")
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
        Notify("❌ Speed Hack", "OFF")
    end
end

-- ============================================
-- VISUAL
-- ============================================
local function enableESP()
    if features.espEnabled then return end
    features.espEnabled = true
    Notify("👁️ ESP", "ON")
    
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character then
            local highlight = Instance.new("Highlight")
            highlight.Adornee = v.Character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.3
            highlight.Parent = v.Character
        end
    end
end

local function toggleFPSBoost()
    features.fpsBoost = not features.fpsBoost
    
    if features.fpsBoost then
        Notify("🚀 FPS Boost", "ON")
        lighting.GlobalShadows = false
        lighting.Technology = Enum.Technology.Legacy
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") then v.Material = Enum.Material.Plastic end
        end
        settings().Rendering.QualityLevel = 1
    else
        Notify("❌ FPS Boost", "OFF")
        lighting.GlobalShadows = true
        lighting.Technology = Enum.Technology.ShadowMap
        settings().Rendering.QualityLevel = 3
    end
end

-- ============================================
-- TELEPORT
-- ============================================
local islands = {
    ["Spawn"] = Vector3.new(0, 5, 0),
    ["Coral Island"] = Vector3.new(100, 5, 50),
    ["Deep Sea"] = Vector3.new(500, 5, 500),
    ["Frozen Fjord"] = Vector3.new(-300, 5, -300),
}

local function teleportTo(pos)
    local root = GetRootPart()
    if root then
        root.CFrame = CFrame.new(pos)
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        Notify("📍 Teleport", "Success!")
    end
end

-- ============================================
-- KEYBINDS (PALING PENTING)
-- ============================================
print("⌨️ Setting up keybinds...")

userInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        if features.autoFish then stopAutoFish() else startAutoFish() end
    elseif input.KeyCode == Enum.KeyCode.F2 then
        teleportTo(Vector3.new(0, 5, 0))
    elseif input.KeyCode == Enum.KeyCode.F3 then
        if features.autoOpenCrate then 
            features.autoOpenCrate = false 
            Notify("📦 Crate", "OFF")
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
            Notify("👁️ ESP", "OFF")
        else 
            enableESP() 
        end
    elseif input.KeyCode == Enum.KeyCode.F7 then
        if features.autoSell then stopAutoSell() else startAutoSell() end
    elseif input.KeyCode == Enum.KeyCode.F8 then
        toggleNoclip()
    elseif input.KeyCode == Enum.KeyCode.F9 then
        toggleFPSBoost()
    elseif input.KeyCode == Enum.KeyCode.F10 then
        if features.autoEnchant then 
            features.autoEnchant = false
            Notify("✨ Enchant", "OFF")
        else 
            startAutoEnchant() 
        end
    end
end)

-- ============================================
-- INITIALIZATION
-- ============================================
print("✅ All systems initialized!")
Notify("🎣 ULTIMATE FISH-IT v5.0", "Script Loaded! Press F1-F10 for hotkeys", 5)

print("========================================")
print("✅ ULTIMATE FISH-IT v5.0 - READY")
print("========================================")
print("🎮 HOTKEYS:")
print("F1 = Toggle Auto Fishing")
print("F2 = TP Spawn")
print("F3 = Toggle Crate")
print("F4 = Toggle Fly")
print("F5 = Toggle Speed")
print("F6 = Toggle ESP")
print("F7 = Toggle Sell")
print("F8 = Toggle Noclip")
print("F9 = Toggle FPS Boost")
print("F10 = Toggle Enchant")
print("========================================")
print("📡 Remotes Found: " .. #detectedRemotes)
for i, remote in pairs(detectedRemotes) do
    if i <= 10 then
        print("  " .. i .. ". " .. remote)
    end
end
print("========================================")
