-- ============================================
-- ULTIMATE FISH-IT v7.0 - MOBILE EDITION
-- FOR ANDROID ROBLOX EXECUTORS
-- ============================================

print("\n" .. string.rep("=", 50))
print("🎣 ULTIMATE FISH-IT v7.0 MOBILE LOADING...")
print(string.rep("=", 50) .. "\n")

-- ============================================
-- MOBILE UI SETUP
-- ============================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("✅ Creating mobile interface...")

-- ============================================
-- CREATE MAIN GUI
-- ============================================
local screenSize = playerGui.Parent:FindFirstChild("ScreenSize")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishItMobileUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ============================================
-- REMOTE DETECTION
-- ============================================
local remotes = {}
local foundRemotes = 0

local function findRemotes()
    local function scan(folder, depth)
        if depth > 4 then return end
        for _, obj in pairs(folder:GetChildren()) do
            pcall(function()
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    foundRemotes = foundRemotes + 1
                    local name = obj.Name:lower()
                    
                    if name:find("fish") then remotes.fish = obj end
                    if name:find("reel") or name:find("catch") then remotes.reel = obj end
                    if name:find("sell") then remotes.sell = obj end
                    if name:find("enchant") then remotes.enchant = obj end
                    if name:find("crate") then remotes.crate = obj end
                    if name:find("equip") or name:find("skin") then remotes.equipSkin = obj end
                    if name:find("totem") then remotes.totem = obj end
                    if name:find("quest") then remotes.quest = obj end
                end
            end)
        end
    end
    scan(ReplicatedStorage, 0)
end

findRemotes()
print("✅ Found " .. foundRemotes .. " remotes")

-- ============================================
-- STATE MANAGEMENT
-- ============================================
local state = {
    autoFish = false,
    autoSell = false,
    autoEnchant = false,
    autoCrate = false,
    autoTotem = false,
    antiAFK = false,
    antiDrown = false,
    flyMode = false,
    noclipMode = false,
    speedMode = false,
    espMode = false,
    fpsMode = false,
}

local config = {
    fishMode = "Legit",
    sellFilter = "All",
    flySpeed = 100,
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function getHumanoid()
    if player.Character then
        return player.Character:FindFirstChildOfClass("Humanoid")
    end
end

local function getRootPart()
    if player.Character then
        return player.Character:FindFirstChild("HumanoidRootPart")
    end
end

local function fireRemote(remote, ...)
    if remote then
        pcall(function() remote:FireServer(...) end)
    end
end

-- ============================================
-- FEATURE FUNCTIONS
-- ============================================
local fishLoop = nil

local function toggleAutoFish()
    state.autoFish = not state.autoFish
    
    if state.autoFish then
        if fishLoop then pcall(function() fishLoop:Disconnect() end) end
        
        fishLoop = RunService.Heartbeat:Connect(function()
            if not state.autoFish then
                if fishLoop then pcall(function() fishLoop:Disconnect() end) end
                fishLoop = nil
                return
            end
            
            if not player.Character then return end
            if not getHumanoid() then return end
            
            if remotes.equipSkin then
                pcall(function() fireRemote(remotes.equipSkin, 1) end)
            end
            
            if remotes.fish then
                pcall(function() fireRemote(remotes.fish) end)
            end
            
            local delay_time = config.fishMode == "Instant" and 0.3 or 
                              config.fishMode == "Blatant" and 0.8 or 1.5
            wait(delay_time)
            
            if remotes.reel then
                pcall(function() fireRemote(remotes.reel) end)
            end
        end)
    else
        if fishLoop then
            pcall(function() fishLoop:Disconnect() end)
            fishLoop = nil
        end
    end
end

local function toggleAutoSell()
    state.autoSell = not state.autoSell
    
    if state.autoSell then
        spawn(function()
            while state.autoSell do
                if remotes.sell then
                    pcall(function()
                        remotes.sell:InvokeServer()
                        fireRemote(remotes.sell, config.sellFilter)
                    end)
                end
                wait(2)
            end
        end)
    end
end

local function toggleAutoEnchant()
    state.autoEnchant = not state.autoEnchant
    
    if state.autoEnchant then
        spawn(function()
            while state.autoEnchant do
                if remotes.enchant then
                    pcall(function() fireRemote(remotes.enchant) end)
                end
                wait(2)
            end
        end)
    end
end

local function toggleAutoCrate()
    state.autoCrate = not state.autoCrate
    
    if state.autoCrate then
        spawn(function()
            while state.autoCrate do
                if remotes.crate then
                    pcall(function() fireRemote(remotes.crate) end)
                end
                wait(1.5)
            end
        end)
    end
end

local function toggleAutoTotem()
    state.autoTotem = not state.autoTotem
    
    if state.autoTotem then
        spawn(function()
            while state.autoTotem do
                if remotes.totem then
                    pcall(function() fireRemote(remotes.totem) end)
                end
                wait(60)
            end
        end)
    end
end

local function toggleAntiAFK()
    state.antiAFK = not state.antiAFK
    
    if state.antiAFK then
        RunService.RenderStepped:Connect(function()
            if state.antiAFK and player.Character then
                local humanoid = getHumanoid()
                if humanoid then
                    humanoid:Move(Vector3.new(0, 0, 0), true)
                end
            end
        end)
    end
end

local function toggleAntiDrown()
    state.antiDrown = not state.antiDrown
    
    if state.antiDrown then
        RunService.RenderStepped:Connect(function()
            if state.antiDrown and player.Character then
                local humanoid = getHumanoid()
                if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

local function toggleFly()
    state.flyMode = not state.flyMode
    local char = player.Character
    
    if state.flyMode then
        if char and getHumanoid() then
            getHumanoid().PlatformStand = true
            
            RunService.RenderStepped:Connect(function()
                if not state.flyMode then return end
                
                local root = getRootPart()
                if not root then return end
                
                local moveVec = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVec = moveVec + game.Workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVec = moveVec - game.Workspace.CurrentCamera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVec = moveVec - game.Workspace.CurrentCamera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVec = moveVec + game.Workspace.CurrentCamera.CFrame.RightVector
                end
                
                local yVel = 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    yVel = config.flySpeed
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    yVel = -config.flySpeed
                end
                
                if moveVec.Magnitude > 0 then
                    root.AssemblyLinearVelocity = moveVec.Unit * config.flySpeed + Vector3.new(0, yVel, 0)
                else
                    root.AssemblyLinearVelocity = Vector3.new(0, yVel, 0)
                end
            end)
        end
    else
        if char and getHumanoid() then
            getHumanoid().PlatformStand = false
        end
    end
end

local function toggleNoclip()
    state.noclipMode = not state.noclipMode
    
    if state.noclipMode then
        RunService.RenderStepped:Connect(function()
            if state.noclipMode and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

local function toggleSpeed()
    state.speedMode = not state.speedMode
    
    if state.speedMode then
        RunService.RenderStepped:Connect(function()
            if state.speedMode and getHumanoid() then
                getHumanoid().WalkSpeed = 100
                getHumanoid().JumpPower = 200
            end
        end)
    else
        if getHumanoid() then
            getHumanoid().WalkSpeed = 16
            getHumanoid().JumpPower = 50
        end
    end
end

local function toggleESP()
    state.espMode = not state.espMode
    
    if state.espMode then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= player and v.Character then
                pcall(function()
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = v.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.3
                    highlight.Parent = v.Character
                end)
            end
        end
    end
end

local function toggleFPSBoost()
    state.fpsMode = not state.fpsMode
    
    if state.fpsMode then
        pcall(function()
            local lighting = game:GetService("Lighting")
            lighting.GlobalShadows = false
            lighting.Technology = Enum.Technology.Legacy
            settings().Rendering.QualityLevel = 1
        end)
    else
        pcall(function()
            local lighting = game:GetService("Lighting")
            lighting.GlobalShadows = true
            lighting.Technology = Enum.Technology.ShadowMap
            settings().Rendering.QualityLevel = 3
        end)
    end
end

local function teleport(pos)
    local root = getRootPart()
    if root then
        root.CFrame = CFrame.new(pos)
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end

-- ============================================
-- CREATE BUTTONS
-- ============================================
local buttonConfigs = {
    -- Row 1 - Fishing
    {name = "🎣 FISH", func = toggleAutoFish, state = "autoFish", row = 1, col = 1},
    {name = "💰 SELL", func = toggleAutoSell, state = "autoSell", row = 1, col = 2},
    {name = "✨ ENCH", func = toggleAutoEnchant, state = "autoEnchant", row = 1, col = 3},
    
    -- Row 2 - Upgrades
    {name = "📦 CRAT", func = toggleAutoCrate, state = "autoCrate", row = 2, col = 1},
    {name = "🗿 TEM", func = toggleAutoTotem, state = "autoTotem", row = 2, col = 2},
    {name = "⏰ AFK", func = toggleAntiAFK, state = "antiAFK", row = 2, col = 3},
    
    -- Row 3 - Movement
    {name = "🛸 FLY", func = toggleFly, state = "flyMode", row = 3, col = 1},
    {name = "👻 CLIP", func = toggleNoclip, state = "noclipMode", row = 3, col = 2},
    {name = "⚡ SPD", func = toggleSpeed, state = "speedMode", row = 3, col = 3},
    
    -- Row 4 - Visual
    {name = "👁️ ESP", func = toggleESP, state = "espMode", row = 4, col = 1},
    {name = "🌊 DWN", func = toggleAntiDrown, state = "antiDrown", row = 4, col = 2},
    {name = "🚀 FPS", func = toggleFPSBoost, state = "fpsMode", row = 4, col = 3},
}

local buttons = {}

local function createButton(config)
    local button = Instance.new("TextButton")
    button.Name = config.name
    button.Text = config.name
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Position calculation
    local padding = 5
    local buttonSize = 50
    local startX = padding
    local startY = padding + 30 -- Leave room for title
    
    local x = startX + (config.col - 1) * (buttonSize + padding)
    local y = startY + (config.row - 1) * (buttonSize + padding)
    
    button.Position = UDim2.new(0, x, 0, y)
    button.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BorderColor3 = Color3.fromRGB(100, 100, 100)
    button.BorderSizePixel = 2
    button.Parent = screenGui
    
    -- Click handler
    button.MouseButton1Click:Connect(function()
        config.func()
        
        -- Update button color
        if state[config.state] then
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
    end)
    
    -- Update color every frame
    RunService.RenderStepped:Connect(function()
        if state[config.state] then
            button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            button.BorderColor3 = Color3.fromRGB(0, 200, 0)
        else
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            button.BorderColor3 = Color3.fromRGB(100, 100, 100)
        end
    end)
    
    return button
end

-- Create all buttons
for _, config in pairs(buttonConfigs) do
    table.insert(buttons, createButton(config))
end

print("✅ Created " .. #buttons .. " buttons")

-- ============================================
-- CREATE TITLE BAR
-- ============================================
local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Text = "🎣 FISH-IT v7.0 MOBILE"
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 14
titleBar.TextColor3 = Color3.fromRGB(0, 255, 0)
titleBar.Position = UDim2.new(0, 5, 0, 5)
titleBar.Size = UDim2.new(0, 170, 0, 20)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderColor3 = Color3.fromRGB(0, 255, 0)
titleBar.BorderSizePixel = 2
titleBar.Parent = screenGui

-- ============================================
-- CREATE MAIN PANEL BACKGROUND
-- ============================================
local panelBg = Instance.new("Frame")
panelBg.Name = "PanelBackground"
panelBg.Position = UDim2.new(0, 0, 0, 0)
panelBg.Size = UDim2.new(0, 180, 0, 225)
panelBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panelBg.BorderColor3 = Color3.fromRGB(100, 100, 100)
panelBg.BorderSizePixel = 2
panelBg.Parent = screenGui
panelBg.ZIndex = 0

-- Move title and buttons above background
titleBar.ZIndex = 1
for _, btn in pairs(buttons) do
    btn.ZIndex = 1
end

-- ============================================
-- CREATE TELEPORT PANEL
-- ============================================
local tpPanel = Instance.new("Frame")
tpPanel.Name = "TPPanel"
tpPanel.Position = UDim2.new(0, 0, 0, 230)
tpPanel.Size = UDim2.new(0, 180, 0, 70)
tpPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tpPanel.BorderColor3 = Color3.fromRGB(100, 100, 100)
tpPanel.BorderSizePixel = 2
tpPanel.Parent = screenGui

local tpLabel = Instance.new("TextLabel")
tpLabel.Text = "📍 TELEPORT"
tpLabel.Font = Enum.Font.GothamBold
tpLabel.TextSize = 12
tpLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
tpLabel.Position = UDim2.new(0, 5, 0, 2)
tpLabel.Size = UDim2.new(0, 170, 0, 15)
tpLabel.BackgroundTransparency = 1
tpLabel.Parent = tpPanel

local tpLocations = {
    {name = "Spawn", pos = Vector3.new(0, 5, 0)},
    {name = "Coral", pos = Vector3.new(100, 5, 50)},
    {name = "Deep Sea", pos = Vector3.new(500, 5, 500)},
    {name = "Frozen", pos = Vector3.new(-300, 5, -300)},
}

for i, loc in pairs(tpLocations) do
    local tpBtn = Instance.new("TextButton")
    tpBtn.Name = loc.name
    tpBtn.Text = loc.name
    tpBtn.Font = Enum.Font.Gotham
    tpBtn.TextSize = 10
    tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tpBtn.Position = UDim2.new(0, 5 + (i-1) * 44, 0, 18)
    tpBtn.Size = UDim2.new(0, 40, 0, 25)
    tpBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
    tpBtn.BorderColor3 = Color3.fromRGB(0, 200, 255)
    tpBtn.BorderSizePixel = 1
    tpBtn.Parent = tpPanel
    
    tpBtn.MouseButton1Click:Connect(function()
        teleport(loc.pos)
    end)
end

local modeLbl = Instance.new("TextLabel")
modeLbl.Name = "ModeLabel"
modeLbl.Text = "Mode: " .. config.fishMode
modeLbl.Font = Enum.Font.Gotham
modeLbl.TextSize = 9
modeLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
modeLbl.Position = UDim2.new(0, 5, 0, 45)
modeLbl.Size = UDim2.new(0, 170, 0, 12)
modeLbl.BackgroundTransparency = 1
modeLbl.Parent = tpPanel

-- ============================================
-- FINAL SETUP
-- ============================================
print("✅ Mobile UI created successfully!")
print("✅ Tap buttons to toggle features")
print("✅ Green = ON, Gray = OFF\n")

print(string.rep("=", 50))
print("✅ ULTIMATE FISH-IT v7.0 MOBILE READY!")
print(string.rep("=", 50) .. "\n")
