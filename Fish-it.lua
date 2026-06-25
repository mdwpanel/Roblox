-- ============================================
-- SCRIPT FISH IT - VERSION FOR DELTA EXECUTOR
-- MENGGUNAKAN UI DELTA NATIVE
-- ============================================

-- Services
local player = game:GetService("Players").LocalPlayer
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local teleportService = game:GetService("TeleportService")
local lighting = game:GetService("Lighting")
local virtualInput = game:GetService("VirtualInputManager")

-- ============================================
-- KONFIGURASI
-- ============================================
local CONFIG = {
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

local function Notify(title, desc)
    if game:GetService("StarterGui"):FindFirstChild("DeltaNotify") then
        -- Delta notification system
    end
    print(string.format("[%s] %s", title, desc))
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

-- ============================================
-- UI MENU DENGAN DELTA NATIVE
-- ============================================
local Window = {}

-- Buat UI sederhana
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishItUI"
screenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
title.Text = " FISH IT MEGA"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Scroll Frame untuk konten
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -40)
scrollFrame.Position = UDim2.new(0, 0, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
scrollFrame.ScrollBarThickness = 5
scrollFrame.Parent = mainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 5)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = scrollFrame

-- ============================================
-- FUNGSI BUAT UI ELEMEN
-- ============================================
local function createToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.5
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 1, -5)
    toggleBtn.Position = UDim2.new(0.8, 0, 0, 2.5)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.TextSize = 12
    toggleBtn.Parent = frame
    
    local state = false
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 80)
        callback(state)
    end)
    
    return toggleBtn
end

local function createDropdown(parent, text, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.5
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.4, 0, 1, -5)
    dropdown.Position = UDim2.new(0.55, 0, 0, 2.5)
    dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    dropdown.Text = options[1] or "Select"
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 12
    dropdown.Parent = frame
    
    local index = 1
    dropdown.MouseButton1Click:Connect(function()
        index = index % #options + 1
        dropdown.Text = options[index]
        callback(options[index])
    end)
    
    return dropdown
end

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = parent
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ============================================
-- 1. AUTO FISHING
-- ============================================
local fishThread = nil

local function startAutoFish()
    if features.autoFish then return end
    features.autoFish = true
    Notify("Auto Fishing", "ON (" .. fishMode .. " Mode)")
    
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
        
        if fishMode == "Instant" then
            safeFire(remotes.reel)
        elseif fishMode == "Extreme" then
            wait(0.3)
            safeFire(remotes.reel)
        elseif fishMode == "Blatant" then
            wait(0.8)
            safeFire(remotes.reel)
        else
            wait(CONFIG.FishDelay)
            safeFire(remotes.reel)
        end
        wait(0.5)
    end)
end

local function stopAutoFish()
    features.autoFish = false
    if fishThread then
        pcall(function() fishThread:Disconnect() end)
        fishThread = nil
    end
    Notify("Auto Fishing", "OFF")
end

-- ============================================
-- 2. AUTO SELL
-- ============================================
local sellThread = nil

local function startAutoSell()
    if features.autoSell then return end
    features.autoSell = true
    Notify("Auto Sell", "ON (" .. sellFilter .. ")")
    
    sellThread = runService.Heartbeat:Connect(function()
        if not features.autoSell then 
            sellThread:Disconnect()
            sellThread = nil
            return 
        end
        
        if remotes.sell then
            safeFire(remotes.sell, sellFilter)
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
    Notify("Auto Sell", "OFF")
end

-- ============================================
-- 3. AUTO ENCHANT
-- ============================================
local enchantThread = nil

local function startAutoEnchant()
    if features.autoEnchant then return end
    features.autoEnchant = true
    Notify("Auto Enchant", "ON")
    
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
    Notify("Auto Enchant", "OFF")
end

-- ============================================
-- 4. AUTO OPEN CRATE
-- ============================================
local crateThread = nil

local function startAutoOpenCrate()
    if features.autoOpenCrate then return end
    features.autoOpenCrate = true
    Notify("Auto Open Crate", "ON")
    
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
    Notify("Auto Open Crate", "OFF")
end

-- ============================================
-- 5. ANTI-AFK
-- ============================================
local antiAFKConnection = nil

local function startAntiAFK()
    if features.antiAFK then return end
    features.antiAFK = true
    Notify("Anti-AFK", "ON")
    
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
        end)
    end)
end

-- ============================================
-- 6. FLY
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
            Notify("Fly", "ON")
            
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
            end)
        else
            humanoid.PlatformStand = false
            Notify("Fly", "OFF")
        end
    end
end

-- ============================================
-- 7. SPEED HACK
-- ============================================
local speedConnection = nil

local function toggleSpeedHack()
    features.speedHack = not features.speedHack
    
    if speedConnection then
        pcall(function() speedConnection:Disconnect() end)
        speedConnection = nil
    end
    
    if features.speedHack then
        Notify("Speed Hack", "ON")
        
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
        Notify("Speed Hack", "OFF")
    end
end

-- ============================================
-- 8. TELEPORT
-- ============================================
local function teleportTo(pos)
    pcall(function()
        local root = GetRootPart()
        if root then
            root.CFrame = CFrame.new(pos)
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            Notify("Teleport", "Ke " .. tostring(pos))
        end
    end)
end

-- ============================================
-- 9. RESET ALL
-- ============================================
local function resetAll()
    stopAutoFish()
    stopAutoSell()
    stopAutoEnchant()
    stopAutoOpenCrate()
    
    features.antiAFK = false
    if antiAFKConnection then
        pcall(function() antiAFKConnection:Disconnect() end)
        antiAFKConnection = nil
    end
    
    if features.flyEnabled then toggleFly() end
    if features.speedHack then toggleSpeedHack() end
    
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            player.Character.Humanoid.JumpPower = 50
            player.Character.Humanoid.PlatformStand = false
        end
    end)
    
    Notify("Reset", "All features disabled")
end

-- ============================================
-- BUILD UI
-- ============================================
-- Auto Section
createToggle(scrollFrame, " Auto Fishing", function(v)
    if v then startAutoFish() else stopAutoFish() end
end)

createDropdown(scrollFrame, "Fishing Mode", {"Stable", "Blatant", "Extreme", "Instant"}, function(v)
    fishMode = v
    if features.autoFish then
        stopAutoFish()
        wait(0.5)
        startAutoFish()
    end
end)

createToggle(scrollFrame, " Auto Sell", function(v)
    if v then startAutoSell() else stopAutoSell() end
end)

createDropdown(scrollFrame, "Sell Filter", {"All", "Legendary", "Epic", "Rare", "Common"}, function(v)
    sellFilter = v
    if features.autoSell then
        stopAutoSell()
        wait(0.5)
        startAutoSell()
    end
end)

createToggle(scrollFrame, " Auto Enchant", function(v)
    if v then startAutoEnchant() else stopAutoEnchant() end
end)

createToggle(scrollFrame, " Auto Open Crate", function(v)
    if v then startAutoOpenCrate() else stopAutoOpenCrate() end
end)

-- Utility Section
local utilLabel = Instance.new("TextLabel")
utilLabel.Size = UDim2.new(1, -10, 0, 30)
utilLabel.Text = " UTILITIES"
utilLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
utilLabel.BackgroundTransparency = 1
utilLabel.Font = Enum.Font.GothamBold
utilLabel.TextSize = 16
utilLabel.TextXAlignment = Enum.TextXAlignment.Left
utilLabel.Parent = scrollFrame

createToggle(scrollFrame, " Anti-AFK", function(v)
    if v then startAntiAFK() else features.antiAFK = false end
end)

createToggle(scrollFrame, " Fly", function(v)
    if v then
        if not features.flyEnabled then toggleFly() end
    else
        if features.flyEnabled then toggleFly() end
    end
end)

createToggle(scrollFrame, " Speed Hack", function(v)
    if v then
        if not features.speedHack then toggleSpeedHack() end
    else
        if features.speedHack then toggleSpeedHack() end
    end
end)

-- Teleport Section
local tpLabel = Instance.new("TextLabel")
tpLabel.Size = UDim2.new(1, -10, 0, 30)
tpLabel.Text = " TELEPORT"
tpLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
tpLabel.BackgroundTransparency = 1
tpLabel.Font = Enum.Font.GothamBold
tpLabel.TextSize = 16
tpLabel.TextXAlignment = Enum.TextXAlignment.Left
tpLabel.Parent = scrollFrame

local islands = {
    "Spawn",
    "Coral Island", 
    "Mermaid Lagoon",
    "Retro Island",
    "Event Island"
}

local islandPositions = {
    Vector3.new(0, 5, 0),
    Vector3.new(100, 5, 50),
    Vector3.new(-80, 5, 120),
    Vector3.new(200, 5, -100),
    Vector3.new(50, 5, -150)
}

for i, name in pairs(islands) do
    createButton(scrollFrame, " " .. name, function()
        teleportTo(islandPositions[i])
    end)
end

-- Control Section
local controlLabel = Instance.new("TextLabel")
controlLabel.Size = UDim2.new(1, -10, 0, 30)
controlLabel.Text = " CONTROLS"
controlLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
controlLabel.BackgroundTransparency = 1
controlLabel.Font = Enum.Font.GothamBold
controlLabel.TextSize = 16
controlLabel.TextXAlignment = Enum.TextXAlignment.Left
controlLabel.Parent = scrollFrame

createButton(scrollFrame, " Reset All Features", resetAll)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Text = ""
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Drag functionality
local dragging = false
local dragStart = nil
local startPos = nil

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

userInput.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

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
    elseif input.KeyCode == Enum.KeyCode.F7 then
        if features.autoSell then stopAutoSell() else startAutoSell() end
    elseif input.KeyCode == Enum.KeyCode.F8 then
        if features.autoEnchant then stopAutoEnchant() else startAutoEnchant() end
    end
end)

-- ============================================
-- START
-- ============================================
print("========================================")
print(" FISH IT MEGA - DELTA VERSION")
print("========================================")
print(" Script Loaded Successfully!")
print(" UI Menu telah muncul di layar")
print(" Shortcut:")
print("F1 = Toggle Auto Fishing")
print("F2 = Teleport to Default Spot")
print("F3 = Toggle Auto Open Crate")
print("F4 = Toggle Fly")
print("F5 = Toggle Speed Hack")
print("F7 = Toggle Auto Sell")
print("F8 = Toggle Auto Enchant")
print("========================================")

Notify(" FISH IT MEGA", "Loaded Successfully!")