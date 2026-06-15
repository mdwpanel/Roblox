--[[
    ███████╗███████╗ █████╗ ██╗     
    ██╔════╝██╔════╝██╔══██╗██║     
    █████╗  █████╗  ███████║██║     
    ██╔══╝  ██╔══╝  ██╔══██║██║     
    ██║     ██║     ██║  ██║███████╗
    ╚═╝     ╚═╝     ╚═╝  ╚═╝╚══════╝
    
    FCAL HUB - LYNX GUI EDITION (FIXED COMPLETE)
    Version: 1.0.6 | Library: LynxGUI (Custom)
--]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/4LynxX/Libb/refs/heads/main/Lib2.lua"))()

-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Trackers & Globals
local LocalPlayer = Players.LocalPlayer
local ESP_Objects = {}
local ManualHighlights = {}
local ESPHighlights = {}
local ESPLabels = {}

_G.AutoCP = false
_G.InfJump = false
_G.NC = false
_G.TapTP = false
_G.BoxESP = false
_G.LineESP = false
_G.ESP = false
_G.HealthESP = false
_G.AntiRagdoll = false
_G.AntiVoid = false
_G.AntiKick = false
_G.AdminDetect = false

-- [[ ANTI-KICK BYPASS ]]
local mt = getrawmetatable(game) 
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then return nil end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ==========================================
-- MAIN WINDOW CREATION (LynxGUI Style)
-- ==========================================
local Window = Library:CreateWindow("FCAL HUB", "LYNX GUI", "Cyan")

local MainTab = Window:CreateTab("Main")
local PlayerTab = Window:CreateTab("Player")
local GameTab = Window:CreateTab("Game")
local ServerTab = Window:CreateTab("Server")
local SettingsTab = Window:CreateTab("Settings")

-- ==========================================
-- HELPER FUNCTIONS (ESP & Utilities)
-- ==========================================
local function ClearESP(player)
    if ESP_Objects[player] then
        for _, obj in pairs(ESP_Objects[player]) do
            obj.Visible = false
            obj:Remove()
        end
        ESP_Objects[player] = nil
    end
end

local function ClearManualHighlights()
    for _, obj in pairs(ManualHighlights) do
        if obj then obj:Destroy() end
    end
    ManualHighlights = {}
end

local function GetPlayerRole(player)
    if player:GetAttribute("Role") then return tostring(player:GetAttribute("Role")) end
    if player.Team then return player.Team.Name end
    return "Survivor"
end

local function GetESPColor(player)
    local role = GetPlayerRole(player):lower()
    if role:find("killer") or role:find("hunter") then return Color3.fromRGB(255, 0, 0) end
    if role:find("survivor") then return Color3.fromRGB(0, 255, 0) end
    return Color3.fromRGB(255, 255, 255)
end

local function CreateESPForPlayer(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    
    local character = player.Character
    local color = GetESPColor(player)
    
    -- Highlight
    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.Adornee = character
    hl.Parent = character
    ESPHighlights[player] = hl
    
    -- Name Tag
    local head = character:FindFirstChild("Head")
    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 150, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.Parent = game.CoreGui
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = color
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Text = player.Name .. " [" .. GetPlayerRole(player) .. "]"
        label.Parent = billboard
        ESPLabels[player] = billboard
    end
end

local function RemoveESPForPlayer(player)
    if ESPHighlights[player] then pcall(function() ESPHighlights[player]:Destroy() end) ESPHighlights[player] = nil end
    if ESPLabels[player] then pcall(function() ESPLabels[player]:Destroy() end) ESPLabels[player] = nil end
end

-- ==========================================
-- MAIN TAB ELEMENTS
-- ==========================================
MainTab:CreateButton("Reset Character", function()
    if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
end)

MainTab:CreateButton("Refresh Movement (Fix Bug)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
    Workspace.Gravity = 196
end)

MainTab:CreateToggle("Tap to Teleport (Click Map)", function(state)
    _G.TapTP = state
end)

MainTab:CreateButton("TP to Random Player", function()
    local allPlayers = Players:GetPlayers()
    local randomPlayer = allPlayers[math.random(1, #allPlayers)]
    if randomPlayer ~= LocalPlayer and randomPlayer.Character and randomPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame
    end
end)

-- ==========================================
-- PLAYER TAB ELEMENTS
-- ==========================================
PlayerTab:CreateSlider("WalkSpeed Mod", 16, 250, 16, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

PlayerTab:CreateSlider("Jump Power Mod", 50, 500, 50, function(value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = value
    end
end)

PlayerTab:CreateSlider("Map Gravity", 0, 400, 196, function(value)
    Workspace.Gravity = value
end)

PlayerTab:CreateToggle("Infinite Jump", function(state)
    _G.InfJump = state
end)

PlayerTab:CreateToggle("NoClip (Tembus Tembok)", function(state)
    _G.NC = state
end)

PlayerTab:CreateToggle("Anti-Ragdoll / No-Stun", function(state)
    _G.AntiRagdoll = state
    if state then
        task.spawn(function()
            while _G.AntiRagdoll do
                task.wait(0.1)
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    if hum.PlatformStand then hum.PlatformStand = false end
                    if hum.Sit then hum.Sit = false end
                end
            end
        end)
    end
end)

PlayerTab:CreateToggle("Anti-Void (Jatuh Terbawah)", function(state)
    _G.AntiVoid = state
    if state then
        task.spawn(function()
            while _G.AntiVoid do
                task.wait(0.2)
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root and root.Position.Y < -50 then
                    root.CFrame = CFrame.new(root.Position.X, 10, root.Position.Z)
                end
            end
        end)
    end
end)

-- ==========================================
-- GAME TAB ELEMENTS
-- ==========================================
GameTab:CreateToggle("Master Auto CP / Stage", function(state)
    _G.AutoCP = state
    if state then
        task.spawn(function()
            local lastNum = 0
            while _G.AutoCP do
                task.wait(1.0)
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local targetPart = nil
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        local num = tonumber(obj.Name:match("%d+"))
                        if num and num > lastNum and (obj.Name:lower():find("cp") or obj.Name:lower():find("stage") or obj:IsA("SpawnLocation")) then
                            targetPart = obj
                            lastNum = num
                            break
                        end
                    end
                    if targetPart then
                        root.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                    end
                end
            end
        end)
    end
end)

GameTab:CreateToggle("ESP Box 2D", function(state) _G.BoxESP = state end)
GameTab:CreateToggle("ESP Lines Tracer", function(state) _G.LineESP = state end)

GameTab:CreateToggle("ESP Player Highlights", function(state)
    _G.ESP = state
    if state then
        for _, p in pairs(Players:GetPlayers()) do CreateESPForPlayer(p) end
    else
        for _, p in pairs(Players:GetPlayers()) do RemoveESPForPlayer(p) end
    end
end)

GameTab:CreateToggle("Fullbright (Anti Gelap)", function(state)
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = true
    end
end)

GameTab:CreateButton("Find & Highlight Generators", function()
    ClearManualHighlights()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("generator") or obj.Name:lower():find("computer")) then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(255, 170, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Adornee = obj
            hl.Parent = obj
            table.insert(ManualHighlights, hl)
        end
    end
end)

GameTab:CreateButton("Find & Highlight Exit Gates", function()
    ClearManualHighlights()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("gate") or obj.Name:lower():find("exit")) then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(0, 255, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Adornee = obj
            hl.Parent = obj
            table.insert(ManualHighlights, hl)
        end
    end
end)

GameTab:CreateButton("Clear All Highlights", function()
    ClearManualHighlights()
    for _, p in pairs(Players:GetPlayers()) do RemoveESPForPlayer(p) end
end)

-- ==========================================
-- SERVER TAB ELEMENTS (SEKARANG DIJAMIN MUNCUL)
-- ==========================================
ServerTab:CreateToggle("Anti-Kick Protection", function(state)
    _G.AntiKick = state
end)

ServerTab:CreateToggle("Admin Join Detector", function(state)
    _G.AdminDetect = state
    if state then
        Players.PlayerAdded:Connect(function(player)
            if _G.AdminDetect and player.AccountAge < 1 then
                LocalPlayer:Kick("FCAL HUB: Potensi Admin/Alt Terdeteksi.")
            end
        end)
    end
end)

ServerTab:CreateButton("Instant Rejoin Server", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

ServerTab:CreateButton("Server Hop (Pindah Server)", function()
    local servers = {}
    local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
    for _, v in pairs(game:GetService("HttpService"):JSONDecode(res).data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then table.insert(servers, v.id) end
    end
    if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)]) end
end)

ServerTab:CreateButton("Copy Job ID Server", function()
    if setclipboard then setclipboard(game.JobId) end
end)

-- ==========================================
-- SETTINGS TAB ELEMENTS (SEKARANG DIJAMIN MUNCUL)
-- ==========================================
SettingsTab:CreateButton("Fake Name (Anti-Report)", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.DisplayName = "Anonymous_User"
    end
end)

SettingsTab:CreateButton("Destroy UI / Unload Hub", function()
    _G.AutoCP = false
    _G.InfJump = false
    _G.NC = false
    _G.TapTP = false
    _G.BoxESP = false
    _G.LineESP = false
    _G.ESP = false
    ClearManualHighlights()
    for _, p in pairs(Players:GetPlayers()) do RemoveESPForPlayer(p) end
    for _, obj in pairs(ESP_Objects) do if obj.Box then obj.Box:Remove() end if obj.Line then obj.Line:Remove() end end
    Window:Destroy()
end)

-- ==========================================
-- PERSISTENT RUNSERVICE LOOPS
-- ==========================================
RunService.Stepped:Connect(function()
    if _G.NC and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do 
            if p:IsA("BasePart") then p.CanCollide = false end 
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

UserInputService.TouchTapInWorld:Connect(function(position, processed)
    if _G.TapTP and not processed and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local camera = Workspace.CurrentCamera
            local ray = camera:ViewportPointToRay(position.X, position.Y)
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
            if result then root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0)) end
        end
    end
end)

-- 2D Box & Line Drawing Loop
RunService.RenderStepped:Connect(function()
    if not (_G.BoxESP or _G.LineESP) then
        for _, obj in pairs(ESP_Objects) do obj.Box.Visible = false obj.Line.Visible = false end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                if not ESP_Objects[player] then
                    ESP_Objects[player] = { Box = Drawing.new("Square"), Line = Drawing.new("Line") }
                end
                
                local obj = ESP_Objects[player]
                local color = GetESPColor(player)
                
                if _G.BoxESP then
                    local sizeX = 2000 / pos.Z
                    local sizeY = 3000 / pos.Z
                    obj.Box.Visible = true
                    obj.Box.Color = color
                    obj.Box.Size = Vector2.new(sizeX, sizeY)
                    obj.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                    obj.Box.Thickness = 1
                else
                    obj.Box.Visible = false
                end
                
                if _G.LineESP then
                    obj.Line.Visible = true
                    obj.Line.Color = color
                    obj.Line.From = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y)
                    obj.Line.To = Vector2.new(pos.X, pos.Y)
                    obj.Line.Thickness = 1
                else
                    obj.Line.Visible = false
                end
            else
                if ESP_Objects[player] then ESP_Objects[player].Box.Visible = false ESP_Objects[player].Line.Visible = false end
            end
        else
            ClearESP(player)
        end
    end
end)

Players.PlayerRemoving:Connect(ClearESP)
