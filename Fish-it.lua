-- ============================================
-- FISH IT MEGA - FIX MENU TIDAK MUNCUL
-- VERSION: 4.1 | CUSTOM GUI | ANTI DETECTION
-- ============================================

-- ============================================
-- ANTI DETECTION SYSTEM
-- ============================================
local function antiDetection()
    pcall(function()
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                if name:find("anti") or name:find("cheat") or name:find("exploit") or
                   name:find("detect") or name:find("kick") or name:find("ban") or
                   name:find("moderat") or name:find("report") then
                    obj:Destroy()
                end
            end
        end
    end)
    
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            local old = mt.__namecall
            mt.__namecall = function(self, ...)
                local args = {...}
                if args[2] == "FireServer" and self.Name and self.Name:lower():find("anti") then
                    return nil
                end
                return old(self, ...)
            end
        end
    end)
    
    pcall(function()
        getrawmetatable = function() return nil end
        checkcaller = function() return false end
        debug = nil
    end)
end

antiDetection()

-- ============================================
-- SERVICES
-- ============================================
local player = game:GetService("Players").LocalPlayer
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
-- RANDOM DELAY
-- ============================================
local function randomDelay(min, max)
    return math.random(min * 10, max * 10) / 10
end

local function waitRandom(min, max)
    wait(randomDelay(min or 0.5, max or 2))
end

-- ============================================
-- SAFE FIRE REMOTE
-- ============================================
local function safeFireRemote(remote, ...)
    if not remote then return false end
    if not remote.Parent then return false end
    
    local success = pcall(function()
        if remote.InvokeServer then
            remote:InvokeServer(...)
        else
            remote:FireServer(...)
        end
    end)
    return success
end

-- ============================================
-- FIND REMOTE
-- ============================================
local function findRemoteSafe(namePattern)
    for _, obj in pairs(replicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find(namePattern:lower()) then
            local name = obj.Name:lower()
            if not name:find("anti") and not name:find("detect") and
               not name:find("kick") and not name:find("ban") then
                return obj
            end
        end
    end
    return nil
end

local remotes = {
    fish = findRemoteSafe("Fishing") or findRemoteSafe("Cast"),
    reel = findRemoteSafe("Reel") or findRemoteSafe("Catch"),
    sell = findRemoteSafe("Sell") or findRemoteSafe("Shop"),
    enchant = findRemoteSafe("Enchant"),
    crate = findRemoteSafe("Crate") or findRemoteSafe("OpenCrate"),
    equipSkin = findRemoteSafe("Equip") or findRemoteSafe("Skin"),
    buy = findRemoteSafe("Buy"),
    trade = findRemoteSafe("Trade"),
    acceptTrade = findRemoteSafe("Accept"),
    totem = findRemoteSafe("Totem"),
    weather = findRemoteSafe("Weather"),
    quest = findRemoteSafe("Quest"),
    artifact = findRemoteSafe("Artifact"),
    event = findRemoteSafe("Event"),
}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================
local function GetHumanoid()
    return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

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
    autoHeal = false,
    fpsBoost = false,
}

local fishMode = "Stable"
local sellFilter = "All"
local flySpeed = 100

-- ============================================
-- SEMUA FUNGSI FITUR (SINGKAT)
-- ============================================
local function toggleAutoFish()
    features.autoFish = not features.autoFish
    if features.autoFish then
        spawn(function()
            while features.autoFish do
                local delay = randomDelay(1.5, 4.5)
                pcall(function()
                    if remotes.fish then safeFireRemote(remotes.fish) end
                    wait(fishMode == "Instant" and randomDelay(0.1, 0.3) or randomDelay(1, 3))
                    if remotes.reel then safeFireRemote(remotes.reel) end
                end)
                wait(delay)
            end
        end)
    end
end

local function toggleAutoSell()
    features.autoSell = not features.autoSell
    if features.autoSell then
        spawn(function()
            while features.autoSell do
                wait(randomDelay(3, 8))
                pcall(function() if remotes.sell then safeFireRemote(remotes.sell, sellFilter) end end)
            end
        end)
    end
end

local function toggleAutoEnchant()
    features.autoEnchant = not features.autoEnchant
    if features.autoEnchant then
        spawn(function()
            while features.autoEnchant do
                wait(randomDelay(5, 15))
                pcall(function() if remotes.enchant then safeFireRemote(remotes.enchant) end end)
            end
        end)
    end
end

local function toggleAutoOpenCrate()
    features.autoOpenCrate = not features.autoOpenCrate
    if features.autoOpenCrate then
        spawn(function()
            while features.autoOpenCrate do
                wait(randomDelay(2, 5))
                pcall(function() if remotes.crate then safeFireRemote(remotes.crate) end end)
            end
        end)
    end
end

local function toggleAutoEquipSkin()
    features.autoEquipSkin = not features.autoEquipSkin
    if features.autoEquipSkin then
        spawn(function()
            while features.autoEquipSkin do
                wait(randomDelay(10, 30))
                pcall(function() if remotes.equipSkin then safeFireRemote(remotes.equipSkin, "best") end end)
            end
        end)
    end
end

local function toggleAutoBuy()
    features.autoBuy = not features.autoBuy
    if features.autoBuy then
        spawn(function()
            while features.autoBuy do
                wait(randomDelay(10, 20))
                pcall(function() if remotes.buy then safeFireRemote(remotes.buy, "best") end end)
                wait(randomDelay(3, 8))
                pcall(function() if remotes.buy then safeFireRemote(remotes.buy, "bait") end end)
                wait(randomDelay(5, 15))
            end
        end)
    end
end

local function toggleAutoTrade()
    features.autoTrade = not features.autoTrade
    if features.autoTrade then
        spawn(function()
            while features.autoTrade do
                wait(randomDelay(20, 60))
                pcall(function() if remotes.trade then safeFireRemote(remotes.trade) end end)
            end
        end)
    end
end

local function toggleAutoAcceptTrade()
    features.autoAcceptTrade = not features.autoAcceptTrade
    if features.autoAcceptTrade and remotes.acceptTrade then
        remotes.acceptTrade.OnClientEvent:Connect(function()
            if features.autoAcceptTrade then
                wait(randomDelay(0.5, 2))
                safeFireRemote(remotes.acceptTrade)
            end
        end)
    end
end

local function toggleAutoTotem()
    features.autoTotem = not features.autoTotem
    if features.autoTotem then
        spawn(function()
            while features.autoTotem do
                wait(randomDelay(45, 90))
                pcall(function() if remotes.totem then safeFireRemote(remotes.totem) end end)
            end
        end)
    end
end

local function toggleAutoWeather()
    features.autoWeather = not features.autoWeather
    if features.autoWeather then
        spawn(function()
            local idx = 1
            local types = {"Storm", "Cloudy", "Wind", "Snow"}
            while features.autoWeather do
                wait(randomDelay(45, 90))
                pcall(function()
                    if remotes.weather then
                        safeFireRemote(remotes.weather, types[idx])
                        idx = idx % #types + 1
                    end
                end)
            end
        end)
    end
end

local function toggleAutoQuest()
    features.autoQuest = not features.autoQuest
    if features.autoQuest then
        spawn(function()
            local types = {"DeepSea", "AuraKid", "ElementJungle"}
            while features.autoQuest do
                for _, quest in pairs(types) do
                    wait(randomDelay(2, 5))
                    pcall(function() if remotes.quest then safeFireRemote(remotes.quest, quest) end end)
                end
                wait(randomDelay(8, 20))
            end
        end)
    end
end

local function toggleAutoArtifact()
    features.autoArtifact = not features.autoArtifact
    if features.autoArtifact then
        spawn(function()
            while features.autoArtifact do
                wait(randomDelay(3, 8))
                pcall(function() if remotes.artifact then safeFireRemote(remotes.artifact) end end)
            end
        end)
    end
end

local function toggleAutoEvent()
    features.autoEvent = not features.autoEvent
    if features.autoEvent then
        spawn(function()
            while features.autoEvent do
                wait(randomDelay(20, 45))
                pcall(function() if remotes.event then safeFireRemote(remotes.event) end end)
            end
        end)
    end
end

local function toggleAutoRejoin()
    features.autoRejoin = not features.autoRejoin
    if features.autoRejoin then
        player.OnTeleport:Connect(function()
            if features.autoRejoin then
                wait(randomDelay(3, 8))
                teleportService:Teleport(game.PlaceId)
            end
        end)
    end
end

local function toggleAutoServerHop()
    features.autoServerHop = not features.autoServerHop
    if features.autoServerHop then
        spawn(function()
            while features.autoServerHop do
                wait(randomDelay(240, 360))
                teleportService:Teleport(game.PlaceId)
            end
        end)
    end
end

local function toggleAntiAFK()
    features.antiAFK = not features.antiAFK
    if features.antiAFK then
        runService.RenderStepped:Connect(function()
            if features.antiAFK and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:Move(Vector3.new(0, 0, 0), true)
                virtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                wait(0.05)
                virtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end)
    end
end

local function toggleAntiDrown()
    features.antiDrown = not features.antiDrown
    if features.antiDrown then
        runService.RenderStepped:Connect(function()
            if features.antiDrown and player.Character and player.Character:FindFirstChild("Humanoid") then
                local hum = player.Character.Humanoid
                if hum:GetState() == Enum.HumanoidStateType.Swimming then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

local function toggleAutoHeal()
    features.autoHeal = not features.autoHeal
    if features.autoHeal then
        spawn(function()
            while features.autoHeal do
                local hum = player.Character and player.Character:FindFirstChild("Humanoid")
                if hum and hum.Health < hum.MaxHealth * 0.4 then
                    for _, item in pairs(player.Backpack:GetChildren()) do
                        if item:IsA("Tool") and (item.Name:lower():find("heal") or item.Name:lower():find("pot")) then
                            pcall(function()
                                hum:EquipTool(item)
                                wait(randomDelay(0.3, 0.8))
                                virtualInput:SendKeyEvent(true, Enum.KeyCode.ButtonR1, false, game)
                                wait(randomDelay(0.1, 0.3))
                                virtualInput:SendKeyEvent(false, Enum.KeyCode.ButtonR1, false, game)
                            end)
                            break
                        end
                    end
                end
                wait(randomDelay(1, 3))
            end
        end)
    end
end

local espHighlights = {}
local function toggleESP()
    features.espEnabled = not features.espEnabled
    if features.espEnabled then
        for _, v in pairs(players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hl = Instance.new("Highlight")
                hl.Adornee = v.Character
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.FillTransparency = 0.3
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Parent = v.Character
                table.insert(espHighlights, hl)
            end
        end
    else
        for _, obj in pairs(espHighlights) do
            pcall(function() obj:Destroy() end)
        end
        espHighlights = {}
    end
end

local flyConnection = nil
local function toggleFly()
    features.flyEnabled = not features.flyEnabled
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        if features.flyEnabled then
            humanoid.PlatformStand = true
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
            if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
        end
    end
end

local noclipConnection = nil
local function toggleNoclip()
    features.noclipEnabled = not features.noclipEnabled
    if features.noclipEnabled then
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
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
    end
end

local speedConnection = nil
local function toggleSpeedHack()
    features.speedHack = not features.speedHack
    if features.speedHack then
        speedConnection = runService.RenderStepped:Connect(function()
            if features.speedHack and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 50
                player.Character.Humanoid.JumpPower = 100
            end
        end)
    else
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            player.Character.Humanoid.JumpPower = 50
        end
    end
end

local function toggleFPSBoost()
    features.fpsBoost = not features.fpsBoost
    if features.fpsBoost then
        lighting.GlobalShadows = false
        lighting.Technology = Enum.Technology.Legacy
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") then v.Material = Enum.Material.Plastic end
            if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
        settings().Rendering.QualityLevel = 1
    else
        lighting.GlobalShadows = true
        lighting.Technology = Enum.Technology.ShadowMap
        settings().Rendering.QualityLevel = 3
    end
end

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
    end
end

-- ============================================
-- CREATE GUI (CUSTOM - PASTI MUNCUL)
-- ============================================
local gui = nil

local function createGUI()
    if gui then
        gui:Destroy()
        gui = nil
        return
    end
    
    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FishItMEGA"
    screenGui.Parent = coreGui
    screenGui.ResetOnSpawn = false
    
    -- Main Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 520)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(60, 60, 100)
    frame.Parent = screenGui
    
    -- Draggable
    local dragging = false
    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    userInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundTransparency = 1
    title.Text = " FISH IT MEGA"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
    closeBtn.Text = ""
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        gui = nil
    end)
    
    -- Scroll Frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -35)
    scroll.Position = UDim2.new(0, 0, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, 850)
    scroll.ScrollBarThickness = 4
    scroll.Parent = frame
    
    -- Helper untuk membuat tombol
    local function makeBtn(text, y, callback, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 26)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 60)
        btn.BackgroundTransparency = 0.2
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(60, 60, 90)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.Parent = scroll
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local function makeLabel(text, y)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 0, 22)
        lbl.Position = UDim2.new(0, 5, 0, y)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
        lbl.TextScaled = true
        lbl.Font = Enum.Font.GothamBold
        lbl.Parent = scroll
        return lbl
    end
    
    -- BUILT GUI
    local y = 5
    
    -- Automation Section
    makeLabel("===  AUTOMATION ===", y)
    y = y + 27
    
    makeBtn(" Auto Fishing: OFF", y, function()
        toggleAutoFish()
        btn.text = " Auto Fishing: " .. (features.autoFish and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Open Crate: OFF", y, function()
        toggleAutoOpenCrate()
        btn.text = " Auto Open Crate: " .. (features.autoOpenCrate and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Sell: OFF", y, function()
        toggleAutoSell()
        btn.text = " Auto Sell: " .. (features.autoSell and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Enchant: OFF", y, function()
        toggleAutoEnchant()
        btn.text = " Auto Enchant: " .. (features.autoEnchant and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Equip Skin: OFF", y, function()
        toggleAutoEquipSkin()
        btn.text = " Auto Equip Skin: " .. (features.autoEquipSkin and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Buy: OFF", y, function()
        toggleAutoBuy()
        btn.text = " Auto Buy: " .. (features.autoBuy and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Trade: OFF", y, function()
        toggleAutoTrade()
        btn.text = " Auto Trade: " .. (features.autoTrade and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Accept Trade: OFF", y, function()
        toggleAutoAcceptTrade()
        btn.text = " Auto Accept Trade: " .. (features.autoAcceptTrade and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Totem: OFF", y, function()
        toggleAutoTotem()
        btn.text = " Auto Totem: " .. (features.autoTotem and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Weather: OFF", y, function()
        toggleAutoWeather()
        btn.text = " Auto Weather: " .. (features.autoWeather and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Quest: OFF", y, function()
        toggleAutoQuest()
        btn.text = " Auto Quest: " .. (features.autoQuest and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Artifact: OFF", y, function()
        toggleAutoArtifact()
        btn.text = " Auto Artifact: " .. (features.autoArtifact and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Event: OFF", y, function()
        toggleAutoEvent()
        btn.text = " Auto Event: " .. (features.autoEvent and "ON" or "OFF")
    end)
    y = y + 30
    
    -- Utilities Section
    makeLabel("===  UTILITIES ===", y)
    y = y + 27
    
    makeBtn(" Anti-AFK: OFF", y, function()
        toggleAntiAFK()
        btn.text = " Anti-AFK: " .. (features.antiAFK and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Anti-Drown: OFF", y, function()
        toggleAntiDrown()
        btn.text = " Anti-Drown: " .. (features.antiDrown and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Heal: OFF", y, function()
        toggleAutoHeal()
        btn.text = " Auto Heal: " .. (features.autoHeal and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" ESP: OFF", y, function()
        toggleESP()
        btn.text = " ESP: " .. (features.espEnabled and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Fly: OFF", y, function()
        toggleFly()
        btn.text = " Fly: " .. (features.flyEnabled and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Noclip: OFF", y, function()
        toggleNoclip()
        btn.text = " Noclip: " .. (features.noclipEnabled and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Speed Hack: OFF", y, function()
        toggleSpeedHack()
        btn.text = " Speed Hack: " .. (features.speedHack and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" FPS Boost: OFF", y, function()
        toggleFPSBoost()
        btn.text = " FPS Boost: " .. (features.fpsBoost and "ON" or "OFF")
    end)
    y = y + 30
    
    -- Teleport Section
    makeLabel("===  TELEPORT ===", y)
    y = y + 27
    
    for name, pos in pairs(islands) do
        makeBtn(" " .. name, y, function()
            teleportTo(pos)
        end, Color3.fromRGB(30, 60, 30))
        y = y + 30
    end
    
    -- Server Section
    makeLabel("===  SERVER ===", y)
    y = y + 27
    
    makeBtn(" Auto Rejoin: OFF", y, function()
        toggleAutoRejoin()
        btn.text = " Auto Rejoin: " .. (features.autoRejoin and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Auto Server Hop: OFF", y, function()
        toggleAutoServerHop()
        btn.text = " Auto Server Hop: " .. (features.autoServerHop and "ON" or "OFF")
    end)
    y = y + 30
    
    makeBtn(" Server Hop Now", y, function()
        teleportService:Teleport(game.PlaceId)
    end, Color3.fromRGB(60, 30, 30))
    y = y + 30
    
    -- Reset
    makeBtn(" Reset All Features", y, function()
        for name, _ in pairs(features) do
            features[name] = false
        end
        if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
        toggleESP()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
            player.Character.Humanoid.JumpPower = 50
            player.Character.Humanoid.PlatformStand = false
        end
    end, Color3.fromRGB(80, 20, 20))
    y = y + 30
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 20)
    gui = screenGui
    
    print(" GUI Created Successfully!")
end

-- ============================================
-- KEYBINDS
-- ============================================
userInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        toggleAutoFish()
    elseif input.KeyCode == Enum.KeyCode.F2 then
        teleportTo(Vector3.new(0, 5, 0))
    elseif input.KeyCode == Enum.KeyCode.F3 then
        toggleAutoOpenCrate()
    elseif input.KeyCode == Enum.KeyCode.F4 then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.F5 then
        toggleSpeedHack()
    elseif input.KeyCode == Enum.KeyCode.F6 then
        toggleESP()
    elseif input.KeyCode == Enum.KeyCode.F7 then
        createGUI()
    end
end)

-- ============================================
-- CHARACTER ADDED
-- ============================================
player.CharacterAdded:Connect(function(char)
    wait(1)
    if features.speedHack then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 50
            hum.JumpPower = 100
        end
    end
    if features.flyEnabled then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = true
        end
    end
end)

-- ============================================
-- START
-- ============================================
createGUI()

print("========================================")
print(" FISH IT MEGA v4.1 - FIXED MENU")
print("========================================")
print(" ALL FEATURES WITH SAFE MODE")
print(" ANTI DETECTION ACTIVE")
print("========================================")
print(" SHORTCUTS:")
print("F1 = Auto Fishing")
print("F2 = Teleport to Spawn")
print("F3 = Auto Open Crate")
print("F4 = Fly")
print("F5 = Speed Hack")
print("F6 = ESP")
print("F7 = Toggle GUI")
print("========================================")
print(" GUI PASTI MUNCUL!")