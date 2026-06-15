--[[
    ███████╗███████╗ █████╗ ██╗     
    ██╔════╝██╔════╝██╔══██╗██║     
    █████╗  █████╗  ███████║██║     
    ██╔══╝  ██╔══╝  ██╔══██║██║     
    ██║     ██║     ██║  ██║███████╗
    ╚═╝     ╚═╝     ╚═╝  ╚═╝╚══════╝

    FCAL HUB - Client Sided
    Version: 1.0.6
--]]

-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ESP_Objects = {}
local LocalPlayer = Players.LocalPlayer
_G.AutoCP = false
_G.CPDelay = 1.0 -- Jeda antar CP agar tidak di-kick anti-cheat
-- Config
local Config = {
    WalkSpeedDefault = 16,
    JumpPowerDefault = 50,
    GravityDefault = 196,
    Theme = "Midnight",
    FlySpeed = 100,
    FlySpeedDefault = 100,
}

-- Load Modal UI
local Modal = loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()
-- ADVANCED ANTI-KICK BYPASS
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then
        return nil -- Memblokir perintah Kick dari game
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)
-- Create Window
local Window = Modal:CreateWindow({
    Title = "FCAL HUB",
    SubTitle = "v1.0.6 | Client Sided",
    Size = UDim2.fromOffset(500, 420),
    MinimumSize = Vector2.new(350, 300),
    Transparency = 0,
    Icon = "rbxassetid://68073547",
})

Window:SetTheme(Config.Theme)

-- UI Element References (for syncing)
local UIElements = {
    WalkSpeedSlider = nil,
    WalkSpeedInput = nil,
    JumpPowerSlider = nil,
    JumpPowerInput = nil,
    GravitySlider = nil,
    GravityInput = nil,
    FlySpeedSlider = nil,
    FlySpeedInput = nil,
}
local function ClearESP(player)
    if ESP_Objects[player] then
        for _, obj in pairs(ESP_Objects[player]) do
            obj.Visible = false
            obj:Remove()
        end
        ESP_Objects[player] = nil
    end
end

-- Fungsi Utama Drawing ESP
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                local rootPart = character.HumanoidRootPart
                local humanoid = character.Humanoid
                local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
                
                -- Jika fitur aktif dan pemain terlihat di layar
                if onScreen then
                    -- Buat objek Drawing jika belum ada
                    if not ESP_Objects[player] then
                        ESP_Objects[player] = {
                            Box = Drawing.new("Square"),
                            Line = Drawing.new("Line")
                        }
                    end

                    local color = GetESPColor(player)
                    local objects = ESP_Objects[player]

                    -- 1. LOGIKA BOX ESP (SQUARE)
                    if _G.BoxESP then
                        -- Menentukan ukuran box berdasarkan jarak
                        local sizeX = 2000 / pos.Z
                        local sizeY = 3000 / pos.Z
                        
                        objects.Box.Visible = true
                        objects.Box.Color = color
                        objects.Box.Thickness = 1
                        objects.Box.Filled = false
                        objects.Box.Size = Vector2.new(sizeX, sizeY)
                        objects.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                    else
                        objects.Box.Visible = false
                    end

                    -- 2. LOGIKA LINE ESP (TRACERS)
                    if _G.LineESP then
                        objects.Line.Visible = true
                        objects.Line.Color = color
                        objects.Line.Thickness = 1
                        objects.Line.From = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y) -- Dari tengah bawah layar
                        objects.Line.To = Vector2.new(pos.X, pos.Y)
                    else
                        objects.Line.Visible = false
                    end
                else
                    -- Jika tidak di layar, sembunyikan
                    if ESP_Objects[player] then
                        ESP_Objects[player].Box.Visible = false
                        ESP_Objects[player].Line.Visible = false
                    end
                end
            else
                ClearESP(player)
            end
        end
    end
end

-- Jalankan Loop ESP
RunService.RenderStepped:Connect(function()
    if _G.BoxESP or _G.LineESP then
        UpdateESP()
    else
        -- Jika semua mati, bersihkan semua objek
        for player, _ in pairs(ESP_Objects) do
            ClearESP(player)
        end
    end
end)

-- Bersihkan jika pemain keluar
Players.PlayerRemoving:Connect(ClearESP)

-- Helpers
local function Notify(title, desc, typ)
    Window:Notify({Title = title, Description = desc, Duration = 3, Type = typ or "Info"})
end

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetPlayerByName(name)
    name = name:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name then
            return p
        end
    end
    return nil
end

-- Update UI Elements (Sync sliders and inputs)
local function UpdateWalkSpeedUI(value)
    if UIElements.WalkSpeedSlider then
        pcall(function() UIElements.WalkSpeedSlider:Set(value) end)
    end
    if UIElements.WalkSpeedInput then
        pcall(function() UIElements.WalkSpeedInput:Set(tostring(value)) end)
    end
end

local function UpdateJumpPowerUI(value)
    if UIElements.JumpPowerSlider then
        pcall(function() UIElements.JumpPowerSlider:Set(value) end)
    end
    if UIElements.JumpPowerInput then
        pcall(function() UIElements.JumpPowerInput:Set(tostring(value)) end)
    end
end

local function UpdateGravityUI(value)
    if UIElements.GravitySlider then
        pcall(function() UIElements.GravitySlider:Set(value) end)
    end
    if UIElements.GravityInput then
        pcall(function() UIElements.GravityInput:Set(tostring(value)) end)
    end
end

local function UpdateFlySpeedUI(value)
    if UIElements.FlySpeedSlider then
        pcall(function() UIElements.FlySpeedSlider:Set(value) end)
    end
    if UIElements.FlySpeedInput then
        pcall(function() UIElements.FlySpeedInput:Set(tostring(value)) end)
    end
end

-- Role Detection
local function GetPlayerRole(player)
    local inGame = false
    local gameGui = LocalPlayer:FindFirstChild("PlayerGui")
    if gameGui then
        for _, gui in pairs(gameGui:GetChildren()) do
            if gui.Name:lower():find("game") or gui.Name:lower():find("match") 
                or gui.Name:lower():find("survive") or gui.Name:lower():find("ingame") then
                if gui.Enabled then inGame = true break end
            end
        end
    end
    if not inGame then
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj.Name:lower():find("generator") or obj.Name:lower():find("gate") 
                or obj.Name:lower():find("survivor") or obj.Name:lower():find("killer") then
                inGame = true break
            end
        end
    end
    if not inGame then return "Neutral" end
    local character = player.Character
    if not character then return "Neutral" end
    if player:GetAttribute("Role") then
        local role = player:GetAttribute("Role")
        if type(role) == "string" then
            if role:lower():find("killer") then return "Killer" end
            if role:lower():find("survivor") or role:lower():find("survive") then return "Survivor" end
        end
    end
    if player:GetAttribute("IsKiller") then return "Killer" end
    if player:GetAttribute("IsSurvivor") then return "Survivor" end
    if character:GetAttribute("Role") then
        local role = character:GetAttribute("Role")
        if type(role) == "string" then
            if role:lower():find("killer") then return "Killer" end
            if role:lower():find("survivor") or role:lower():find("survive") then return "Survivor" end
        end
    end
    if character:GetAttribute("IsKiller") then return "Killer" end
    if character:GetAttribute("IsSurvivor") then return "Survivor" end
    local roleValue = character:FindFirstChild("Role")
    if roleValue and roleValue:IsA("StringValue") then
        local role = roleValue.Value:lower()
        if role:find("killer") then return "Killer" end
        if role:find("survivor") or role:find("survive") then return "Survivor" end
    end
    local isKillerValue = character:FindFirstChild("IsKiller")
    if isKillerValue and isKillerValue:IsA("BoolValue") and isKillerValue.Value then return "Killer" end
    local isSurvivorValue = character:FindFirstChild("IsSurvivor")
    if isSurvivorValue and isSurvivorValue:IsA("BoolValue") and isSurvivorValue.Value then return "Survivor" end
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("killer") then return "Killer" end
        if teamName:find("survivor") or teamName:find("survive") then return "Survivor" end
        local teamColor = player.TeamColor
        if teamColor == BrickColor.new("Really red") then return "Killer" end
        if teamColor == BrickColor.new("Lime green") or teamColor == BrickColor.new("Bright green") then return "Survivor" end
    end
    local charName = character.Name:lower()
    if charName:find("killer") then return "Killer" end
    if charName:find("survivor") then return "Survivor" end
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") then
            local toolName = item.Name:lower()
            if toolName:find("knife") or toolName:find("weapon") or toolName:find("killer") then return "Killer" end
        end
    end
    return "Survivor"
end

local function GetESPColor(player)
    local role = GetPlayerRole(player)
    if role == "Killer" then return Color3.fromRGB(255, 0, 0)
    elseif role == "Survivor" then return Color3.fromRGB(0, 255, 0)
    else return Color3.fromRGB(255, 255, 255) end
end

-- Generator Detection - STRICT version
local function IsGenerator(obj)
    if not obj then return false end
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return false end
    
    local name = obj.Name:lower()
    
    -- EXCLUDE: Player characters, NPCs, tools, GUI elements
    if name:find("player") or name:find("character") or name:find("npc") 
        or name:find("killer") or name:find("survivor") or name:find("humanoid") then
        return false
    end
    
    -- Check if it's actually a player character (has Humanoid)
    if obj:IsA("Model") then
        if obj:FindFirstChildOfClass("Humanoid") then return false end
        -- Also check if it's in Players folder
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character == obj then return false end
        end
    end
    
    -- ONLY match specific generator patterns
    local isGen = false
    
    -- Direct generator names
    if name:find("generator") then isGen = true end
    if name:find("gen%d") or name:find("gen_%d") or name:find("gen %d") then isGen = true end
    if name == "gen" then isGen = true end
    
    -- Forsaken specific (common patterns)
    if name:find("fusebox") or name:find("fuse_box") or name:find("fuse box") then isGen = true end
    if name:find("powerbox") or name:find("power_box") or name:find("power box") then isGen = true end
    if name:find("switchbox") or name:find("switch_box") then isGen = true end
    if name:find("lever") and not name:find("player") then isGen = true end
    
    return isGen
end

-- Generator Status Detection
local function IsGeneratorCompleted(gen)
    local genName = gen.Name:lower()
    
    -- Check attributes
    if gen:GetAttribute("Completed") == true then return true end
    if gen:GetAttribute("IsCompleted") == true then return true end
    if gen:GetAttribute("Finished") == true then return true end
    if gen:GetAttribute("Powered") == true then return true end
    if gen:GetAttribute("Done") == true then return true end
    
    -- Progress check
    local progress = gen:GetAttribute("Progress")
    if progress and (progress >= 1 or progress >= 100) then return true end
    
    -- Check children for completion
    for _, child in pairs(gen:GetChildren()) do
        local childName = child.Name:lower()
        
        if child:IsA("BoolValue") then
            if (childName:find("complet") or childName:find("finish") or childName:find("done")) and child.Value then 
                return true 
            end
        end
        
        if child:IsA("NumberValue") or child:IsA("IntValue") then
            if childName:find("progress") and (child.Value >= 100 or child.Value >= 1) then
                return true
            end
        end
    end
    
    return false
end

local function GetGeneratorProgress(gen)
    local progress = gen:GetAttribute("Progress")
    if progress then
        if progress <= 1 then return progress * 100 end
        return progress
    end
    
    for _, child in pairs(gen:GetChildren()) do
        if child.Name:lower():find("progress") then
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local val = child.Value
                if val <= 1 then return val * 100 end
                return val
            end
        end
    end
    
    return 0
end

-- ESP System
local ESPConnections = {}
local ESPHighlights = {}
local ESPLabels = {}
local GenHighlights = {}
local GenUpdateConnection = nil

local function CreateESPForPlayer(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character then return end
    
    -- Clean up existing
    if ESPHighlights[player] then
        if ESPHighlights[player].Parent then ESPHighlights[player]:Destroy() end
    end
    if ESPLabels[player] then
        if ESPLabels[player].Parent then ESPLabels[player]:Destroy() end
    end
    
    local color = GetESPColor(player)
    local role = GetPlayerRole(player)
    
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Player_" .. player.Name
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.Adornee = character
    hl.Parent = character
    ESPHighlights[player] = hl
    
    local head = character:FindFirstChild("Head")
    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_PlayerLabel_" .. player.Name
        billboard.Size = UDim2.new(0, 150, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = head
        billboard.AlwaysOnTop = true
        billboard.Parent = game.CoreGui
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = color
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Text = player.Name .. " [" .. role .. "]"
        label.Parent = billboard
        
        ESPLabels[player] = billboard
    end
end

local function RemoveESPForPlayer(player)
    if ESPHighlights[player] then
        if ESPHighlights[player].Parent then ESPHighlights[player]:Destroy() end
        ESPHighlights[player] = nil
    end
    if ESPLabels[player] then
        if ESPLabels[player].Parent then ESPLabels[player]:Destroy() end
        ESPLabels[player] = nil
    end
end

local function UpdateESPForPlayer(player)
    if not _G.ESP then return end
    if player == LocalPlayer then return end
    local character = player.Character
    if not character then return end
    
    local color = GetESPColor(player)
    local role = GetPlayerRole(player)
    
    if ESPHighlights[player] and ESPHighlights[player].Parent then
        ESPHighlights[player].FillColor = color
        ESPHighlights[player].Adornee = character
    end
    
    if ESPLabels[player] and ESPLabels[player].Parent then
        local label = ESPLabels[player]:FindFirstChild("TextLabel")
        if label then
            label.TextColor3 = color
            label.Text = player.Name .. " [" .. role .. "]"
        end
        local head = character:FindFirstChild("Head")
        if head then ESPLabels[player].Adornee = head end
    end
end

-- Generator ESP System
local function CreateGeneratorESP(gen)
    -- Skip if already tracked
    if GenHighlights[gen] then return end
    
    local isCompleted = IsGeneratorCompleted(gen)
    local progress = GetGeneratorProgress(gen)
    
    local fillColor, outlineColor, textColor
    if isCompleted then
        fillColor = Color3.fromRGB(0, 255, 100)
        outlineColor = Color3.fromRGB(150, 255, 150)
        textColor = Color3.fromRGB(0, 255, 100)
    else
        fillColor = Color3.fromRGB(255, 170, 0)
        outlineColor = Color3.fromRGB(255, 220, 100)
        textColor = Color3.fromRGB(255, 170, 0)
    end
    
    -- Create highlight
    local hl = Instance.new("Highlight")
    hl.Name = "GenESP_Highlight"
    hl.FillColor = fillColor
    hl.OutlineColor = outlineColor
    hl.FillTransparency = 0.5
    hl.Adornee = gen
    hl.Parent = gen
    
    -- Create label (only one)
    local billboard = nil
    local primaryPart = gen:IsA("Model") and gen.PrimaryPart 
        or (gen:IsA("BasePart") and gen or gen:FindFirstChildWhichIsA("BasePart"))
    
    if primaryPart then
        billboard = Instance.new("BillboardGui")
        billboard.Name = "GenESP_Label"
        billboard.Size = UDim2.new(0, 120, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 5, 0)
        billboard.Adornee = primaryPart
        billboard.AlwaysOnTop = true
        billboard.Parent = game.CoreGui
        
        local label = Instance.new("TextLabel")
        label.Name = "GenLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = textColor
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Text = isCompleted and "✓ COMPLETE" or ("⚡ " .. math.floor(progress) .. "%")
        label.Parent = billboard
    end
    
    -- Store reference
    GenHighlights[gen] = {
        Highlight = hl, 
        Label = billboard, 
        LastCompleted = isCompleted, 
        LastProgress = progress
    }
end
local TweenService = game:GetService("TweenService")
local function UpdateGeneratorESP()
    if not _G.GenESP then return end
    
    for gen, data in pairs(GenHighlights) do
        if gen and gen.Parent then
            local isCompleted = IsGeneratorCompleted(gen)
            local progress = GetGeneratorProgress(gen)
            
            -- Update if state changed
            if isCompleted ~= data.LastCompleted then
                data.LastCompleted = isCompleted
                
                local fillColor, outlineColor, textColor
                if isCompleted then
                    fillColor = Color3.fromRGB(0, 255, 100)
                    outlineColor = Color3.fromRGB(150, 255, 150)
                    textColor = Color3.fromRGB(0, 255, 100)
                else
                    fillColor = Color3.fromRGB(255, 170, 0)
                    outlineColor = Color3.fromRGB(255, 220, 100)
                    textColor = Color3.fromRGB(255, 170, 0)
                end
                
                if data.Highlight and data.Highlight.Parent then
                    data.Highlight.FillColor = fillColor
                    data.Highlight.OutlineColor = outlineColor
                end
                
                if data.Label and data.Label.Parent then
                    local label = data.Label:FindFirstChild("GenLabel")
                    if label then
                        label.TextColor3 = textColor
                        label.Text = isCompleted and "✓ COMPLETE" or ("⚡ " .. math.floor(progress) .. "%")
                    end
                end
            end
            
            -- Update progress
            if not isCompleted and progress ~= data.LastProgress then
                data.LastProgress = progress
                if data.Label and data.Label.Parent then
                    local label = data.Label:FindFirstChild("GenLabel")
                    if label then
                        label.Text = "⚡ " .. math.floor(progress) .. "%"
                    end
                end
            end
        else
            -- Clean up removed generators
            if data.Highlight then data.Highlight:Destroy() end
            if data.Label then data.Label:Destroy() end
            GenHighlights[gen] = nil
        end
    end
end

local function RemoveAllGeneratorESP()
    for gen, data in pairs(GenHighlights) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Label then data.Label:Destroy() end
    end
    GenHighlights = {}
end

-- Find all generators
local function FindAllGenerators()
    local generators = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if IsGenerator(obj) then
            table.insert(generators, obj)
        end
    end
    
    return generators
end

-- Tabs
local MainTab = Window:AddTab("Main")
local PlayerTab = Window:AddTab("Player")
local GameTab = Window:AddTab("Game")
local ServerTab = Window:AddTab("Server")
local SettingsTab = Window:AddTab("Settings")

-- MAIN TAB
MainTab:New("Title")({ Title = "🛠️ Quick Actions" })

-- Tambahkan di MainTab
MainTab:New("Button")({
    Title = "Get Gravity Gun",
    Description = "Tool untuk menarik dan membawa objek di map",
    Callback = function()
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "🧲 Gravity Gun"
        tool.Parent = LocalPlayer.Backpack
        
        local mouse = LocalPlayer:GetMouse()
        local target = nil
        local connection = nil
        
        tool.Activated:Connect(function()
            target = mouse.Target
            if target and not target.Anchored then
                connection = RunService.RenderStepped:Connect(function()
                    if target and tool.Parent == LocalPlayer.Character then
                        target.Velocity = (LocalPlayer.Character.Head.CFrame * CFrame.new(0,0,-10).p - target.Position) * 10
                    end
                end)
            end
        end)
        
        tool.Deactivated:Connect(function()
            if connection then connection:Disconnect() end
            target = nil
        end)
    end,
})

MainTab:New("Button")({
    Title = "Reset Character",
    Description = "Respawn your character",
    Callback = function()
        LocalPlayer:LoadCharacter()
        Notify("Success", "Character reset!", "Success")
    end,
})

MainTab:New("Button")({
    Title = "Refresh Movement",
    Description = "Reset WalkSpeed, JumpPower & Gravity to defaults",
    Callback = function()
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = Config.WalkSpeedDefault
            hum.JumpPower = Config.JumpPowerDefault
        end
        Workspace.Gravity = Config.GravityDefault
        
        UpdateWalkSpeedUI(Config.WalkSpeedDefault)
        UpdateJumpPowerUI(Config.JumpPowerDefault)
        UpdateGravityUI(Config.GravityDefault)
        
        Notify("Reset", "Movement & gravity refreshed!", "Success")
    end,
})

MainTab:New("Title")({ Title = "🎯 Teleport" })

-- Tambahkan di MainTab
MainTab:New("Toggle")({
    Title = "Tap to Teleport",
    Description = "Ketuk lokasi di layar untuk pindah (Mobile Friendly)",
    DefaultValue = false,
    Callback = function(v)
        _G.TapTP = v
    end,
})

-- Handler Touch untuk Mobile
UserInputService.TouchTapInWorld:Connect(function(position, processed)
    if _G.TapTP and not processed then
        local root = GetRootPart()
        if root then
            -- Membuat raycast dari sentuhan jari ke dunia game
            local camera = Workspace.CurrentCamera
            local ray = camera:ViewportPointToRay(position.X, position.Y)
            local targetPos = ray.Origin + ray.Direction * 1000
            
            -- Cek apakah mengenai tanah
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            
            if result then
                root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
                Notify("TP Success", "Teleported to touched location", "Success")
            end
        end
    end
end)

local function GetAllPlayers()
    local names = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        -- Jangan masukkan nama kita sendiri ke dalam daftar teleport
        if p ~= LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

MainTab:New("Title")({ Title = "🚀 Quick Player Teleport" })

local SelectedTarget = ""

-- 1. Create Dropdown
local PlayerDropdown = MainTab:New("Dropdown")({
    Title = "Pilih Pemain",
    Description = "Pilih target teleportasi dari daftar",
    Options = GetAllPlayers(),
    Default = "",
    Callback = function(v)
        SelectedTarget = v
        Notify("Target Dipilih", "Target: " .. v, "Info")
    end,
})

-- 2. Button Refresh Daftar (Penting jika ada orang baru masuk)
MainTab:New("Button")({
    Title = "🔄 Refresh Daftar Pemain",
    Description = "Klik jika ada pemain baru yang masuk server",
    Callback = function()
        local currentPlayers = GetAllPlayers()
        PlayerDropdown:Refresh(currentPlayers)
        Notify("Updated", "Daftar pemain telah diperbarui!", "Success")
    end,
})

-- 3. Tombol Eksekusi Teleport
MainTab:New("Button")({
    Title = "Teleport Sekarang",
    Description = "Pindah ke posisi pemain yang dipilih",
    Callback = function()
        if SelectedTarget == "" or SelectedTarget == nil then
            Notify("Warning", "Silakan pilih pemain dari daftar dulu!", "Warning")
            return
        end

        local target = game.Players:FindFirstChild(SelectedTarget)
        if target and target.Character then
            local myRoot = GetRootPart()
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            
            if myRoot and targetRoot then
                -- Teleport ke belakang pemain target agar tidak menabrak
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
                Notify("Success", "Teleport ke " .. target.Name .. " Berhasil!", "Success")
            end
        else
            Notify("Error", "Pemain tidak ditemukan atau sudah keluar!", "Error")
        end
    end,
})

MainTab:New("Button")({
    Title = "Bring Player",
    Description = "Bring target to you (visual)",
    Callback = function()
        if TargetName == "" then Notify("Warning", "Enter a player name!", "Warning") return end
        local target = GetPlayerByName(TargetName)
        if target and target.Character then
            local myRoot = GetRootPart()
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if myRoot and tRoot then
                tRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
                Notify("Success", "Brought " .. target.Name, "Success")
            end
        else
            Notify("Error", "Player not found!", "Error")
        end
    end,
})
-- Tambahkan di PlayerTab
PlayerTab:New("Title")({ Title = "🎭 Copy Player (Local)" })

-- Helper Functions (Taruh di bagian atas script atau dalam Tab)
local function GetAllPlayerNames()
    local names = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then
            table.insert(names, p.Name)
        end
    end
    return names
end

local function GetNearestPlayer()
    local target = nil
    local dist = math.huge
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                target = p
            end
        end
    end
    return target
end

-- Variabel Penampung
local SelectedAutoPlayer = ""

PlayerTab:New("Title")({ Title = "👤 Smart Identity Stealer" })

-- 1. PILIH NAMA OTOMATIS (Dropdown)
local PlayerSelector = PlayerTab:New("Dropdown")({
    Title = "Pilih Nama Pemain",
    Description = "Nama otomatis terdaftar di sini",
    Options = GetAllPlayerNames(),
    Default = "",
    Callback = function(v)
        SelectedAutoPlayer = v
        Notify("Target Terpilih", "Target: " .. v, "Info")
    end,
})

-- Tombol Refresh Daftar Nama
PlayerTab:New("Button")({
    Title = "🔄 Refresh Daftar Nama",
    Description = "Klik jika ada pemain baru masuk",
    Callback = function()
        PlayerSelector:Refresh(GetAllPlayerNames())
        Notify("Updated", "Daftar pemain diperbarui!", "Success")
    end,
})

-- 2. COPY PEMAIN TERDEKAT (Paling Otomatis)
PlayerTab:New("Button")({
    Title = "🎭 Copy Pemain Terdekat",
    Description = "Otomatis meniru orang di sampingmu",
    Callback = function()
        local target = GetNearestPlayer()
        if target then
            SelectedAutoPlayer = target.Name
            -- Jalankan Fungsi Copy (Sama seperti tombol di bawah)
            ExecuteIdentityCopy(target)
        else
            Notify("Error", "Tidak ada pemain di sekitar!", "Warning")
        end
    end,
})

-- Fungsi Eksekusi (Agar bisa dipanggil berulang)
-- FUNGSI PERBAIKAN IDENTITY STEALER (AVATAR + NAME FIX)
function ExecuteIdentityCopy(target)
    local myChar = game.Players.LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myChar or not target.Character then return end

    -- 1. Bersihkan Karakter (Hapus baju/topi lama)
    for _, v in pairs(myChar:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") then
            v:Destroy()
        end
    end

    -- 2. Terapkan Avatar Baru
    pcall(function()
        local desc = game.Players:GetHumanoidDescriptionFromUserId(target.UserId)
        myHum:ApplyDescription(desc)
    end)

    -- 3. FIX NAMA DOUBLE (Sembunyikan nama asli Roblox)
    myHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None -- Matikan nama asli
    
    -- 4. Bersihkan Tag Curian Lama
    for _, obj in pairs(myChar:GetDescendants()) do
        if obj.Name == "StealedIdent" then obj:Destroy() end
    end

    -- 5. Copy Tag Nama/Badge dari Target
    for _, obj in pairs(target.Character:GetDescendants()) do
        if obj:IsA("BillboardGui") then
            local clone = obj:Clone()
            clone.Name = "StealedIdent"
            clone.Adornee = myChar:FindFirstChild("Head")
            clone.Parent = myChar:FindFirstChild("Head")
            clone.Enabled = true
        end
    end
    Notify("Success", "Berhasil meniru: " .. target.DisplayName, "Success")
end

-- Tombol Terapkan untuk Dropdown
PlayerTab:New("Button")({
    Title = "✨ Terapkan dari Dropdown",
    Description = "Copy pemain yang dipilih dari daftar di atas",
    Callback = function()
        local target = game.Players:FindFirstChild(SelectedAutoPlayer)
        if target then
            ExecuteIdentityCopy(target)
        else
            Notify("Error", "Pilih pemain dulu!", "Warning")
        end
    end,
})

PlayerTab:New("Button")({
    Title = "🔄 Reset Identity",
    Description = "Kembali ke wujud asli",
    Callback = function()
        local myHum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        pcall(function()
            local desc = game.Players:GetHumanoidDescriptionFromUserId(game.Players.LocalPlayer.UserId)
            myHum:ApplyDescription(desc)
            myHum.DisplayName = game.Players.LocalPlayer.DisplayName
        end)
        for _, obj in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if obj.Name == "StealedBadge" then obj:Destroy() end
        end
        Notify("Identity", "Kembali normal.", "Info")
    end,
}) 
-- PLAYER TAB
PlayerTab:New("Title")({ Title = "🏃 Movement" })

-- Tambahkan di PlayerTab
PlayerTab:New("Toggle")({
    Title = "Air Walk (Jesus Mode)",
    Description = "Menciptakan lantai tak terlihat di bawah kakimu",
    DefaultValue = false,
    Callback = function(v)
        _G.AirWalk = v
        local plat = Instance.new("Part")
        plat.Size = Vector3.new(10, 1, 10)
        plat.Anchored = true
        plat.Transparency = 1
        plat.Parent = Workspace
        
        spawn(function()
            while _G.AirWalk do
                task.wait()
                local root = GetRootPart()
                if root then
                    plat.CFrame = root.CFrame * CFrame.new(0, -3.5, 0)
                    plat.CanCollide = true
                end
            end
            plat:Destroy()
        end)
    end,
})

-- Tambahkan di PlayerTab
PlayerTab:New("Toggle")({
    Title = "Anti-Ragdoll / No-Stun",
    Description = "Mencegah karakter jatuh tersungkur atau kaku",
    DefaultValue = false,
    Callback = function(v)
        _G.AntiRagdoll = v
        spawn(function()
            while _G.AntiRagdoll do
                task.wait(0.1)
                local hum = GetHumanoid()
                if hum then
                    if hum.PlatformStand then hum.PlatformStand = false end
                    if hum.Sit then hum.Sit = false end
                end
            end
        end)
    end,
})

local currentWalkSpeed = Config.WalkSpeedDefault
UIElements.WalkSpeedSlider = PlayerTab:New("Slider")({
    Title = "WalkSpeed",
    Description = "Adjust walking speed (Default: 16)",
    Default = Config.WalkSpeedDefault,
    Minimum = 1,
    Maximum = 200,
    DecimalCount = 0,
    Callback = function(v)
        currentWalkSpeed = v
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = v end
        if UIElements.WalkSpeedInput then
            pcall(function() UIElements.WalkSpeedInput:Set(tostring(v)) end)
        end
    end,
})

UIElements.WalkSpeedInput = PlayerTab:New("Input")({
    Title = "WalkSpeed (Custom Value)",
    Description = "Type any value (no limits)",
    Placeholder = "16",
    Callback = function(v)
        local num = tonumber(v)
        if num then
            currentWalkSpeed = math.clamp(num, 1, 200)
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = currentWalkSpeed end
            if UIElements.WalkSpeedSlider then
                pcall(function() UIElements.WalkSpeedSlider:Set(currentWalkSpeed) end)
            end
        end
    end,
})

local currentJumpPower = Config.JumpPowerDefault
UIElements.JumpPowerSlider = PlayerTab:New("Slider")({
    Title = "Jump Power",
    Description = "Adjust jump power (Default: 50)",
    Default = Config.JumpPowerDefault,
    Minimum = 0,
    Maximum = 300,
    DecimalCount = 0,
    Callback = function(v)
        currentJumpPower = v
        local hum = GetHumanoid()
        if hum then hum.JumpPower = v end
        if UIElements.JumpPowerInput then
            pcall(function() UIElements.JumpPowerInput:Set(tostring(v)) end)
        end
    end,
})

UIElements.JumpPowerInput = PlayerTab:New("Input")({
    Title = "Jump Power (Custom Value)",
    Description = "Type any value (no limits)",
    Placeholder = "50",
    Callback = function(v)
        local num = tonumber(v)
        if num then
            currentJumpPower = math.clamp(num, 0, 300)
            local hum = GetHumanoid()
            if hum then hum.JumpPower = currentJumpPower end
            if UIElements.JumpPowerSlider then
                pcall(function() UIElements.JumpPowerSlider:Set(currentJumpPower) end)
            end
        end
    end,
})

local currentGravity = Config.GravityDefault
UIElements.GravitySlider = PlayerTab:New("Slider")({
    Title = "Gravity",
    Description = "Adjust workspace gravity (Default: 196)",
    Default = Config.GravityDefault,
    Minimum = 0,
    Maximum = 500,
    DecimalCount = 0,
    Callback = function(v)
        currentGravity = v
        Workspace.Gravity = v
        if UIElements.GravityInput then
            pcall(function() UIElements.GravityInput:Set(tostring(v)) end)
        end
    end,
})

UIElements.GravityInput = PlayerTab:New("Input")({
    Title = "Gravity (Custom Value)",
    Description = "Type any value (no limits)",
    Placeholder = "196",
    Callback = function(v)
        local num = tonumber(v)
        if num then
            currentGravity = math.clamp(num, 0, 500)
            Workspace.Gravity = currentGravity
            if UIElements.GravitySlider then
                pcall(function() UIElements.GravitySlider:Set(currentGravity) end)
            end
        end
    end,
})

PlayerTab:New("Title")({ Title = "⚡ Toggles" })

-- Tambahkan di PlayerTab
PlayerTab:New("Toggle")({
    Title = "Anti-Void",
    Description = "Munculkan lantai jika jatuh dari map",
    DefaultValue = false,
    Callback = function(v)
        _G.AntiVoid = v
        spawn(function()
            local plate = Instance.new("Part", Workspace)
            plate.Size = Vector3.new(100, 1, 100)
            plate.Anchored = true
            plate.Transparency = 1 -- Tidak terlihat
            plate.CanCollide = false
            
            while _G.AntiVoid do
                task.wait(0.1)
                local root = GetRootPart()
                if root then
                    -- Jika posisi Y karakter di bawah -50 (jatuh)
                    if root.Position.Y < -50 then
                        plate.CFrame = CFrame.new(root.Position.X, -50, root.Position.Z)
                        plate.CanCollide = true
                    else
                        plate.CanCollide = false
                    end
                end
            end
            plate:Destroy()
        end)
    end,
})

PlayerTab:New("Toggle")({
    Title = "Infinite Jump",
    Description = "Jump in the air",
    DefaultValue = false,
    Callback = function(v)
        if v then
            _G.InfJump = true
            _G.InfJumpCon = UserInputService.JumpRequest:Connect(function()
                if _G.InfJump then
                    local hum = GetHumanoid()
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
            Notify("Enabled", "Infinite Jump ON", "Success")
        else
            _G.InfJump = false
            if _G.InfJumpCon then _G.InfJumpCon:Disconnect() end
            Notify("Disabled", "Infinite Jump OFF", "Info")
        end
    end,
})

-- Tambahkan di PlayerTab
PlayerTab:New("Toggle")({
    Title = "Anti-Freeze & Anti-Stun",
    Description = "Tetap bisa bergerak meskipun terkena efek freeze/stun",
    DefaultValue = false,
    Callback = function(v)
        _G.AntiFreeze = v
        spawn(function()
            while _G.AntiFreeze do
                task.wait(0.1)
                local char = LocalPlayer.Character
                local hum = GetHumanoid()
                local root = GetRootPart()
                
                if char and hum and root then
                    -- Mencegah karakter dipaksa diam (Anchored)
                    if root.Anchored then
                        root.Anchored = false
                    end
                    
                    -- Mencegah status kaku (PlatformStand)
                    if hum.PlatformStand then
                        hum.PlatformStand = false
                    end
                    
                    -- Mencegah status duduk paksa (sering dipakai untuk stun)
                    if hum.Sit then
                        hum.Sit = false
                    end
                end
            end
        end)
    end,
})

PlayerTab:New("Toggle")({
    Title = "NoClip",
    Description = "Walk through walls",
    DefaultValue = false,
    Callback = function(v)
        if v then
            _G.NC = true
            _G.NCCon = RunService.Stepped:Connect(function()
                if _G.NC then
                    local char = LocalPlayer.Character
                    if char then
                        for _, p in pairs(char:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end
            end)
            Notify("Enabled", "NoClip ON", "Success")
        else
            _G.NC = false
            if _G.NCCon then _G.NCCon:Disconnect() end
            Notify("Disabled", "NoClip OFF", "Info")
        end
    end,
})

PlayerTab:New("Title")({ Title = "✈️ Fly Settings" })

local currentFlySpeed = Config.FlySpeedDefault
UIElements.FlySpeedSlider = PlayerTab:New("Slider")({
    Title = "Fly Speed",
    Description = "Set fly movement speed (Default: 100)",
    Default = Config.FlySpeedDefault,
    Minimum = 1,
    Maximum = 500,
    DecimalCount = 0,
    Callback = function(v)
        currentFlySpeed = v
        Config.FlySpeed = v
        if UIElements.FlySpeedInput then
            pcall(function() UIElements.FlySpeedInput:Set(tostring(v)) end)
        end
    end,
})

UIElements.FlySpeedInput = PlayerTab:New("Input")({
    Title = "Fly Speed (Custom Value)",
    Description = "Type any value (no limits)",
    Placeholder = "100",
    Callback = function(v)
        local num = tonumber(v)
        if num then
            currentFlySpeed = math.clamp(num, 1, 500)
            Config.FlySpeed = currentFlySpeed
            if UIElements.FlySpeedSlider then
                pcall(function() UIElements.FlySpeedSlider:Set(currentFlySpeed) end)
            end
        end
    end,
})

PlayerTab:New("Button")({
    Title = "Reset Fly Speed",
    Description = "Reset fly speed to default (100)",
    Callback = function()
        Config.FlySpeed = Config.FlySpeedDefault
        currentFlySpeed = Config.FlySpeedDefault
        UpdateFlySpeedUI(Config.FlySpeedDefault)
        Notify("Reset", "Fly speed reset to " .. Config.FlySpeedDefault, "Success")
    end,
})

PlayerTab:New("Toggle")({
    Title = "Fly [DETECTED AFTER FEW SECONDS!]",
    Description = "Terbang sesuai arah kamera (W=Maju, Space=Naik, Ctrl=Turun)",
    DefaultValue = false,
    Callback = function(v)
        if v then
            _G.Fly = true
            local root = GetRootPart()
            if not root then return end

            -- Buat BodyVelocity agar karakter melayang
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Name = "FlyVel"
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.Velocity = Vector3.new(0, 0, 0)
            bodyVel.Parent = root

            -- Buat BodyGyro agar karakter tidak jatuh terguling
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.Name = "FlyGyro"
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.P = 9e4
            bodyGyro.Parent = root

            _G.FlyCon = RunService.RenderStepped:Connect(function()
                if _G.Fly and root and root.Parent then
                    local cam = Workspace.CurrentCamera
                    local hum = GetHumanoid()
                    local moveDir = Vector3.new(0,0,0)

                    -- LOGIKA BARU: Menggunakan LookVector Kamera
                    -- Ini memastikan karakter terbang ke mana pun kamera menghadap
                    if hum and hum.MoveDirection.Magnitude > 0 then
                        -- Ambil arah input (W,A,S,D) dan kalikan dengan kecepatan
                        moveDir = hum.MoveDirection * Config.FlySpeed
                    end

                    -- Tambahan: Terbang Naik (Space) atau Turun (LeftControl)
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveDir = moveDir + Vector3.new(0, Config.FlySpeed, 0)
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        moveDir = moveDir + Vector3.new(0, -Config.FlySpeed, 0)
                    end

                    -- Terapkan kecepatan
                    bodyVel.Velocity = moveDir
                    
                    -- Karakter selalu menghadap ke arah kamera
                    bodyGyro.CFrame = cam.CFrame
                end
            end)
            Notify("Enabled", "Fly Aktif! Gunakan W,A,S,D + Space/Ctrl", "Success")
        else
            -- Matikan Fly
            _G.Fly = false
            if _G.FlyCon then _G.FlyCon:Disconnect() end
            local root = GetRootPart()
            if root then
                local bv = root:FindFirstChild("FlyVel")
                local bg = root:FindFirstChild("FlyGyro")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
            Notify("Disabled", "Fly Mati", "Info")
        end
    end,
})

-- GAME TAB
GameTab:New("Title")({ Title = "🎭 Visual ESP Fixed" })

GameTab:New("Toggle")({
    Title = "ESP Box (2D)",
    Description = "Kotak garis di sekeliling pemain",
    DefaultValue = false,
    Callback = function(v) _G.BoxESP = v end,
})

GameTab:New("Toggle")({
    Title = "ESP Tracers (Line)",
    Description = "Garis dari bawah layar ke pemain",
    DefaultValue = false,
    Callback = function(v) _G.LineESP = v end,
})

-- Bagian Health (Tetap menggunakan BillboardGui karena paling stabil di Mobile)
GameTab:New("Toggle")({
    Title = "ESP Health Bar",
    Description = "Bar nyawa di atas kepala",
    DefaultValue = false,
    Callback = function(v)
        _G.HealthESP = v
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("HealthBarGui") then
                    p.Character.Head.HealthBarGui:Destroy()
                end
            end
        end
    end,
})

-- Jalankan Health Bar secara terpisah (RenderStepped khusus Health)
RunService.RenderStepped:Connect(function()
    if _G.HealthESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    local gui = head:FindFirstChild("HealthBarGui")
                    if not gui then
                        local bgui = Instance.new("BillboardGui", head)
                        bgui.Name = "HealthBarGui"
                        bgui.Size = UDim2.new(4, 0, 0.5, 0)
                        bgui.StudsOffset = Vector3.new(0, 2, 0)
                        bgui.AlwaysOnTop = true
                        local back = Instance.new("Frame", bgui)
                        back.Size = UDim2.new(1, 0, 1, 0)
                        back.BackgroundColor3 = Color3.new(0, 0, 0)
                        local bar = Instance.new("Frame", back)
                        bar.Name = "Bar"
                        bar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                        bar.BackgroundColor3 = Color3.new(0, 1, 0)
                    else
                        gui.Frame.Bar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                        gui.Frame.Bar.BackgroundColor3 = Color3.new(1 - (humanoid.Health/humanoid.MaxHealth), humanoid.Health/humanoid.MaxHealth, 0)
                    end
                end
            end
        end
    end
end)


GameTab:New("Title")({ Title = "🏔️ Mountain Ordered Auto-CP" })


-- VERSI MOUNTAIN-AWARE DENGAN NOTIFIKASI JUMLAH CP PER GUNUNG
-- VERSI ULTIMATE AUTO CP (ANTI-STUCK)
GameTab:New("Toggle")({
    Title = "Start Auto All CP (Master Fix)",
    Description = "Teleport cerdas yang mencari CP selanjutnya secara otomatis",
    DefaultValue = false,
    Callback = function(v)
        _G.AutoCP = v
        
        if v then
            task.spawn(function()
                -- Simpan nomor CP terakhir agar tidak bolak-balik
                local lastCPNumber = 0
                
                while _G.AutoCP do
                    local root = GetRootPart()
                    if not root then task.wait(1) continue end
                    
                    -- 1. SCAN SELURUH WORKSPACE UNTUK CP TERDEKAT
                    local allCPs = {}
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then
                            local name = obj.Name:lower()
                            -- Cari angka di nama objek
                            local num = tonumber(obj.Name:match("%d+"))
                            
                            -- Kriteria Checkpoint (CP, Stage, Level, atau Angka murni)
                            if (name:find("cp") or name:find("stage") or name:find("point") or name:find("level") or obj:IsA("SpawnLocation")) and num then
                                -- Hanya ambil CP yang nomornya LEBIH BESAR dari yang terakhir kita ambil
                                if num > lastCPNumber then
                                    table.insert(allCPs, {Part = obj, Num = num})
                                end
                            end
                        end
                    end
                    
                    -- 2. URUTKAN CP DARI NOMOR TERKECIL
                    table.sort(allCPs, function(a, b) return a.Num < b.Num end)
                    
                    -- 3. EKSEKUSI TELEPORT KE CP BERIKUTNYA
                    if #allCPs > 0 then
                        local nextCP = allCPs[1] -- Ambil CP nomor terkecil yang tersedia
                        
                        Notify("Auto CP", "Menuju CP Nomor: " .. nextCP.Num, "Info")
                        
                        -- Teleport sedikit di atas CP
                        root.CFrame = nextCP.Part.CFrame * CFrame.new(0, 3, 0)
                        
                        -- TEKNIK "LEG TOUCH": Turunkan karakter perlahan sampai menyentuh tanah
                        task.wait(0.3)
                        root.CFrame = nextCP.Part.CFrame * CFrame.new(0, 1.2, 0)
                        
                        -- TUNGGU SERVER MENCATAT PROGRESS (WAJIB JEDA)
                        -- Gunakan minimal 2 detik agar tidak di-reset oleh Anti-Cheat
                        task.wait(_G.CPDelay or 2)
                        
                        -- Update nomor terakhir yang berhasil
                        lastCPNumber = nextCP.Num
                    else
                        -- Jika tidak ada CP lagi dengan nomor lebih tinggi
                        Notify("Selesai", "Tidak ditemukan CP baru. Mencoba scan ulang...", "Warning")
                        task.wait(3)
                        -- Jika masih tidak ada, mungkin memang sudah habis atau harus pindah gunung
                    end
                end
            end)
        end
    end,
})



GameTab:New("Toggle")({
    Title = "Start Auto All CP (STEALTH MODE)",
    Description = "Meluncur halus ke CP agar tidak terkena Anti-Cheat",
    DefaultValue = false,
    Callback = function(v)
        _G.AutoCP = v
        
        if v then
            task.spawn(function()
                local lastNum = 0
                while _G.AutoCP do
                    local root = GetRootPart()
                    if not root then task.wait(1) continue end
                    
                    -- Cari CP selanjutnya
                    local allCPs = {}
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then
                            local num = tonumber(obj.Name:match("%d+"))
                            if num and num > lastNum then
                                table.insert(allCPs, {Part = obj, Num = num})
                            end
                        end
                    end
                    table.sort(allCPs, function(a, b) return a.Num < b.Num end)

                    if #allCPs > 0 then
                        local nextCP = allCPs[1]
                        Notify("Stealth CP", "Meluncur ke Stage: " .. nextCP.Num, "Info")

                        -- LOGIKA STEALTH: Jangan Teleport, tapi Meluncur (Tween)
                        -- Jarak tempuh / kecepatan = durasi (Misal kecepatan 100 studs per detik)
                        local distance = (root.Position - nextCP.Part.Position).Magnitude
                        local duration = distance / 150 -- Kamu bisa ubah 150 ke 100 kalau masih kena kick
                        
                        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
                        local tween = TweenService:Create(root, tweenInfo, {CFrame = nextCP.Part.CFrame * CFrame.new(0, 3, 0)})
                        
                        tween:Play()
                        tween.Completed:Wait() -- Tunggu sampai sampai di lokasi

                        -- Jeda Acak agar terlihat manusiawi (Sangat penting!)
                        local randomDelay = _G.CPDelay + (math.random(1, 10) / 10)
                        task.wait(randomDelay)
                        
                        lastNum = nextCP.Num
                    else
                        Notify("Selesai", "Semua CP terambil atau tidak ada CP baru.", "Success")
                        _G.AutoCP = false
                    end
                end
            end)
        end
    end,
})

GameTab:New("Button")({
    Title = "TP to Top of Mountain",
    Description = "Langsung ke puncak gunung tertinggi",
    Callback = function()
        local highestPart = nil
        local maxWait = -99999
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Position.Y > maxWait then
                -- Pastikan itu bukan langit atau part jauh, tapi bagian dari map
                if obj.Size.Y > 5 and obj.CanCollide then
                    maxWait = obj.Position.Y
                    highestPart = obj
                end
            end
        end
        
        if highestPart then
            GetRootPart().CFrame = highestPart.CFrame + Vector3.new(0, 10, 0)
            Notify("Teleport", "Berhasil ke Puncak Gunung!", "Success")
        end
    end,
})
GameTab:New("Title")({ Title = "👁️ Visuals" })

-- Tambahkan di GameTab
-- Tambahkan di GameTab

-- Tambahkan di GameTab (Visuals)
GameTab:New("Toggle")({
    Title = "Headlight (God Light)",
    Description = "Lampu sorot super terang di kepalamu",
    DefaultValue = false,
    Callback = function(v)
        local head = LocalPlayer.Character:FindFirstChild("Head")
        if head then
            local light = head:FindFirstChild("GodLight") or Instance.new("SpotLight", head)
            light.Name = "GodLight"
            light.Range = 150
            light.Brightness = 5
            light.Enabled = v
        end
    end,
})

-- Tambahkan di Visuals atau Settings
GameTab:New("Toggle")({
    Title = "Freecam (Ghost View)",
    Description = "Lepaskan kamera untuk keliling map",
    DefaultValue = false,
    Callback = function(v)
        local cam = workspace.CurrentCamera
        if v then
            _G.OldSubject = cam.CameraSubject
            cam.CameraType = Enum.CameraType.Scriptable
            Notify("Freecam", "Gunakan WASD & Q/E untuk terbang", "Info")
            _G.FreecamLoop = RunService.RenderStepped:Connect(function()
                -- Logika pergerakan kamera (Sederhana)
                local move = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then cam.CFrame *= CFrame.new(0,0,-1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then cam.CFrame *= CFrame.new(0,0,1) end
            end)
        else
            if _G.FreecamLoop then _G.FreecamLoop:Disconnect() end
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = _G.OldSubject
        end
    end,
})
-- Tambahkan di GameTab (Visuals)
GameTab:New("Toggle")({
    Title = "X-Ray Mode",
    Description = "Melihat menembus semua tembok",
    DefaultValue = false,
    Callback = function(v)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
                if v then
                    if not obj:GetAttribute("OldTrans") then
                        obj:SetAttribute("OldTrans", obj.Transparency)
                    end
                    obj.Transparency = 0.5
                else
                    obj.Transparency = obj:GetAttribute("OldTrans") or 0
                end
            end
        end
    end,
})

-- Tambahkan di GameTab
GameTab:New("Toggle")({
    Title = "Auto Skill Check (Mobile)",
    Description = "Otomatis menekan tombol sukses (Space/Button)",
    DefaultValue = false,
    Callback = function(v)
        _G.AutoSkillMobile = v
        spawn(function()
            while _G.AutoSkillMobile do
                task.wait(0.1)
                -- Simulasi menekan tombol Space untuk skill check
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.05)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end
        end)
    end,
})

GameTab:New("Toggle")({
    Title = "ESP Players",
    Description = "Survivors=Green, Killers=Red, Lobby=White",
    DefaultValue = false,
    Callback = function(v)
        if v then
            _G.ESP = true
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    p.CharacterAdded:Connect(function(char)
                        if _G.ESP then task.wait(0.5) CreateESPForPlayer(p) end
                    end)
                    if p.Character then CreateESPForPlayer(p) end
                end
            end
            local playerAddedConn = Players.PlayerAdded:Connect(function(p)
                p.CharacterAdded:Connect(function()
                    if _G.ESP then task.wait(0.5) CreateESPForPlayer(p) end
                end)
            end)
            table.insert(ESPConnections, playerAddedConn)
            local updateConn = RunService.Heartbeat:Connect(function()
                if _G.ESP then
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then UpdateESPForPlayer(p) end
                    end
                end
            end)
            table.insert(ESPConnections, updateConn)
            Notify("Enabled", "ESP ON - Colors by role!", "Success")
        else
            _G.ESP = false
            for _, conn in pairs(ESPConnections) do if conn then conn:Disconnect() end end
            ESPConnections = {}
            for _, p in pairs(Players:GetPlayers()) do RemoveESPForPlayer(p) end
            Notify("Disabled", "ESP OFF", "Info")
        end
    end,
})

GameTab:New("Toggle")({
    Title = "Fullbright",
    Description = "Brighter environment",
    DefaultValue = false,
    Callback = function(v)
        if v then
            _G.OldBright = Lighting.Brightness
            _G.OldTime = Lighting.ClockTime
            _G.OldFog = Lighting.FogEnd
            _G.OldShadows = Lighting.GlobalShadows
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Notify("Enabled", "Fullbright ON", "Success")
        else
            Lighting.Brightness = _G.OldBright or 1
            Lighting.ClockTime = _G.OldTime or 14
            Lighting.FogEnd = _G.OldFog or 100000
            Lighting.GlobalShadows = _G.OldShadows or true
            Notify("Disabled", "Fullbright OFF", "Info")
        end
    end,
})

-- Tambahkan di GameTab
GameTab:New("Toggle")({
    Title = "Killer Proximity Warning",
    Description = "Muncul pesan jika Killer mendekat (Jarak < 50 Studs)",
    DefaultValue = false,
    Callback = function(v)
        _G.KillerWarn = v
        spawn(function()
            while _G.KillerWarn do
                task.wait(0.5)
                for _, p in pairs(game.Players:GetPlayers()) do
                    if GetPlayerRole(p) == "Killer" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local myRoot = GetRootPart()
                        if myRoot then
                            local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                            if dist < 50 then
                                Notify("⚠️ AWAS!", "Killer mendekat! Jarak: " .. math.floor(dist) .. " studs", "Warning")
                                task.wait(2) -- Agar tidak spam notifikasi
                            end
                        end
                    end
                end
            end
        end)
    end,
})

-- Tambahkan di PlayerTab
GameTab:New("Toggle")({
    Title = "Auto Wiggle",
    Description = "Otomatis meronta saat digendong Killer",
    DefaultValue = false,
    Callback = function(v)
        _G.Wiggle = v
        spawn(function()
            while _G.Wiggle do
                task.wait(0.05)
                -- Simulasi tekan A dan D bergantian
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.A, false, game)
                task.wait(0.05)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.A, false, game)
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.D, false, game)
                task.wait(0.05)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.D, false, game)
            end
        end)
    end,
})

-- Tambahkan di GameTab
local hbSize = 2
GameTab:New("Slider")({
    Title = "Hitbox Expander",
    Description = "Memperbesar ukuran tubuh pemain lain (Default 2)",
    Default = 2,
    Minimum = 2,
    Maximum = 20,
    Callback = function(v)
        hbSize = v
    end,
})

GameTab:New("Toggle")({
    Title = "Enable Hitbox",
    Description = "Aktifkan pembesar ukuran tubuh lawan",
    DefaultValue = false,
    Callback = function(v)
        _G.Hitbox = v
        spawn(function()
            while _G.Hitbox do
                task.wait(1)
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        p.Character.HumanoidRootPart.Size = Vector3.new(hbSize, hbSize, hbSize)
                        p.Character.HumanoidRootPart.Transparency = 0.7
                        p.Character.HumanoidRootPart.Color = Color3.new(1, 0, 0)
                        p.Character.HumanoidRootPart.CanCollide = false
                    end
                end
            end
        end)
    end,
})

GameTab:New("Button")({
    Title = "Debug: Print All Objects",
    Description = "Print workspace objects to console (F9)",
    Callback = function()
        print("=== FCAL HUB - Workspace Objects ===")
        
        local counted = {}
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local name = obj.Name
                if not counted[name] then
                    counted[name] = 0
                end
                counted[name] = counted[name] + 1
            end
        end
        
        for name, count in pairs(counted) do
            print(name .. " (x" .. count .. ")")
        end
        
        Notify("Debug", "Check console (F9) for object list!", "Info")
    end,
})

GameTab:New("Title")({ Title = "🎯 Find Objects" })

GameTab:New("Button")({
    Title = "Find Generators",
    Description = "Highlight generators (Static)",
    Callback = function()
        local generators = FindAllGenerators()
        local c = 0
        local completed = 0
        
        for _, gen in pairs(generators) do
            local isComplete = IsGeneratorCompleted(gen)
            local hl = Instance.new("Highlight")
            
            if isComplete then
                hl.FillColor = Color3.fromRGB(0, 255, 100)
                completed = completed + 1
            else
                hl.FillColor = Color3.fromRGB(255, 170, 0)
            end
            
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.Adornee = gen
            hl.Parent = gen
            c = c + 1
        end
        
        Notify("Found", c .. " generators (" .. completed .. " done, " .. (c - completed) .. " left)", "Success")
    end,
})

GameTab:New("Button")({
    Title = "Find Exit Gates",
    Description = "Highlight exit gates",
    Callback = function()
        local c = 0
        for _, o in pairs(Workspace:GetDescendants()) do
            if (o.Name:lower():find("gate") or o.Name:lower():find("exit")) and (o:IsA("Model") or o:IsA("BasePart")) then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(0, 255, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5
                hl.Adornee = o
                hl.Parent = o
                c = c + 1
            end
        end
        Notify("Found", c .. " exit gates highlighted!", "Success")
    end,
})

GameTab:New("Button")({
    Title = "Clear Highlights",
    Description = "Remove all highlights",
    Callback = function()
        local count = 0
        for _, o in pairs(Workspace:GetDescendants()) do
            if o:IsA("Highlight") then 
                o:Destroy() 
                count = count + 1
            end
        end
        -- Also clear from CoreGui
        for _, o in pairs(game.CoreGui:GetChildren()) do
            if o.Name:find("ESP_") or o.Name:find("GenESP_") then
                o:Destroy()
            end
        end
        -- Clear tracking tables
        ESPHighlights = {}
        ESPLabels = {}
        GenHighlights = {}
        
        Notify("Cleared", count .. " highlights removed!", "Info")
    end,
})
-- TABS & TITLES
ServerTab:New("Title")({ Title = "🛡️ Self-Protection & Security" })

-- 1. FIXED ANTI-KICK (Melindungi Anda dari Kick otomatis oleh Script Game)
ServerTab:New("Toggle")({
    Title = "Anti-Kick Protection",
    Description = "Mencegah script game (Anti-Cheat) menendangmu secara otomatis",
    DefaultValue = false,
    Callback = function(v)
        _G.AntiKick = v
        if v then
            -- Menggunakan hookmetamethod agar lebih sulit dideteksi game
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if _G.AntiKick and self == LocalPlayer and method == "Kick" then
                    Notify("Security", "Game mencoba menendangmu! (Kick diblokir)", "Warning")
                    return nil -- Gagalkan perintah kick
                end
                return oldNamecall(self, ...)
            end)
            Notify("Anti-Kick", "Perlindungan aktif!", "Success")
        end
    end,
})

-- 2. ADMIN JOIN DETECTOR (Otomatis Kick diri sendiri jika Admin masuk)
ServerTab:New("Toggle")({
    Title = "Admin Join Detector",
    Description = "Otomatis keluar jika Moderator/Admin masuk ke server",
    DefaultValue = false,
    Callback = function(v)
        _G.AdminDetect = v
        if v then
            Notify("Security", "Scanning Moderator aktif...", "Info")
            Players.PlayerAdded:Connect(function(player)
                if _G.AdminDetect then
                    -- Cek berdasarkan Rank (biasanya di atas 200 adalah Admin/Dev)
                    if player:GetRankInGroup(game.CreatorId) >= 200 or player.AccountAge < 1 then
                        LocalPlayer:Kick("FCAL HUB: Admin terdeteksi (" .. player.Name .. "). Keluar demi keamanan.")
                    end
                end
            end)
        end
    end,
})

-- 3. IMPROVED SELF-KICK (Tombol Keluar Darurat)
ServerTab:New("Button")({
    Title = "Manual Emergency Kick",
    Description = "Keluar dari server secara instan jika dalam bahaya",
    Callback = function()
        LocalPlayer:Kick("FCAL HUB: Sesi diakhiri secara manual oleh pengguna.")
    end,
})

-- 4. SERVER HOP (Pindah Server jika merasa tidak aman)
ServerTab:New("Button")({
    Title = "Instant Server Hop",
    Description = "Pindah ke server lain secepat mungkin",
    Callback = function()
        local servers = {}
        local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
        for i,v in pairs(game:GetService("HttpService"):JSONDecode(res).data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
        else
            Notify("Error", "Tidak menemukan server lain!", "Error")
        end
    end,
})

ServerTab:New("Button")({
    Title = "Attempt Remote Kick Scan",
    Description = "Mencoba mencari celah untuk kick orang (Eksperimental)",
    Callback = function()
        Notify("Scanning", "Mencari Remote Event yang tidak aman...", "Info")
        local found = false
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("kick") or obj.Name:lower():find("ban")) then
                print("Ditemukan Remote Potensial: " .. obj:GetFullName())
                found = true
            end
        end
        
        if found then
            Notify("Warning", "Ditemukan celah potensial! Cek Console (F9)", "Success")
        else
            Notify("Safe", "Tidak ditemukan celah kick sederhana.", "Info")
        end
    end,
})

ServerTab:New("Toggle")({
    Title = "Anti-Kick (Hanya Client)",
    Description = "Mencegah script game lokal menendangmu (Tidak mempan jika Admin yang kick)",
    DefaultValue = false,
    Callback = function(v)
        _G.AntiKick = v
        if v then
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            local old = mt.__namecall
            
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if _G.AntiKick and method == "Kick" then
                    Notify("Blocked!", "Game mencoba menendangmu, tapi digagalkan.", "Warning")
                    return nil
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end
    end,
})

-- SERVER TAB
ServerTab:New("Title")({ Title = "🌐 Server Info" })

-- Tambahkan di ServerTab

-- Tambahkan di ServerTab
ServerTab:New("Toggle")({
    Title = "Enable Chat Logger",
    Description = "Cetak semua chat pemain ke Console (F9)",
    DefaultValue = false,
    Callback = function(v)
        _G.ChatLog = v
        if v then
            Notify("Chat Logger", "Logger Aktif. Tekan F9 untuk melihat.", "Info")
            for _, player in pairs(game.Players:GetPlayers()) do
                player.Chatted:Connect(function(msg)
                    if _G.ChatLog then
                        print("[" .. player.Name .. "]: " .. msg)
                    end
                end)
            end
        end
    end,
})

ServerTab:New("Button")({
    Title = "Copy Job ID",
    Description = "Copy server JobId",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            Notify("Copied", "Job ID copied!", "Success")
        else
            Notify("Job ID", game.JobId, "Info")
        end
    end,
})

-- Tambahkan di ServerTab
local msg = "FCAL HUB ON TOP!"
ServerTab:New("Input")({
    Title = "Custom Chat Message",
    Description = "Ketik pesan yang ingin di-spam",
    Placeholder = "Ketik di sini...",
    Callback = function(v) msg = v end,
})

ServerTab:New("Toggle")({
    Title = "Auto Chat Spammer",
    Description = "Kirim pesan otomatis setiap 5 detik",
    DefaultValue = false,
    Callback = function(v)
        _G.Spam = v
        spawn(function()
            while _G.Spam do
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
                task.wait(5)
            end
        end)
    end,
})

ServerTab:New("Button")({
    Title = "Copy Place ID",
    Description = "Copy game PlaceId",
    Callback = function()
        if setclipboard then
            setclipboard(tostring(game.PlaceId))
            Notify("Copied", "Place ID copied!", "Success")
        else
            Notify("Place ID", tostring(game.PlaceId), "Info")
        end
    end,
})

ServerTab:New("Title")({ Title = "🚪 Actions" })

ServerTab:New("Button")({
    Title = "Rejoin",
    Description = "Rejoin current server",
    Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end,
})

ServerTab:New("Button")({
    Title = "Server Hop",
    Description = "Join a different server",
    Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end,
})

ServerTab:New("Title")({ Title = "👁️ Spectate" })

local SpecTarget = ""
local names = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(names, p.Name) end
end

ServerTab:New("Dropdown")({
    Title = "Select Player",
    Description = "Choose player to spectate",
    Options = #names > 0 and names or {"No Players"},
    Default = "",
    Callback = function(v) SpecTarget = v end,
})

ServerTab:New("Button")({
    Title = "Spectate",
    Description = "Watch selected player",
    Callback = function()
        if SpecTarget ~= "" then
            local t = GetPlayerByName(SpecTarget)
            if t and t.Character then
                Workspace.CurrentCamera.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid") or t.Character
                Notify("Spectating", "Now watching " .. t.Name, "Info")
            end
        else
            Notify("Warning", "Select a player first!", "Warning")
        end
    end,
})

ServerTab:New("Button")({
    Title = "Stop Spectating",
    Description = "Return to your character",
    Callback = function()
        if LocalPlayer.Character then
            Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or LocalPlayer.Character
            Notify("Stopped", "Returned to your view", "Info")
        end
    end,
})

-- Tambahkan di SettingsTab
SettingsTab:New("Toggle")({
    Title = "Streamer Mode",
    Description = "Sembunyikan namamu di seluruh UI agar aman",
    DefaultValue = false,
    Callback = function(v)
        _G.Streamer = v
        if v then
            Window:SetTitle("SECRET HUB")
            Window:SetSubTitle("User: Anonymous")
        else
            Window:SetTitle("FCAL HUB")
            Window:SetSubTitle("v1.0.6 | Client Sided")
        end
    end,
})

-- Tambahkan di SettingsTab
SettingsTab:New("Button")({
    Title = "Fake Name (Anti-Report)",
    Description = "Ganti namamu jadi 'Anonymous' (Hanya di layar kamu)",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.DisplayName = "Anonymous_User"
            Notify("Stealth", "Nama disamarkan!", "Success")
        end
    end,
})

-- SETTINGS TAB
SettingsTab:New("Title")({ Title = "🎨 Theme" })

SettingsTab:New("Dropdown")({
    Title = "Select Theme",
    Description = "Change UI theme",
    Options = {"Dark", "Light", "Midnight", "Rose", "Emerald"},
    Default = Config.Theme,
    Callback = function(v)
        Window:SetTheme(v)
        Notify("Theme", "Changed to " .. v, "Success")
    end,
})

SettingsTab:New("Title")({ Title = "⌨️ Keybind" })

local ToggleKey = "RightControl"
SettingsTab:New("Keybind")({
    Title = "Toggle UI",
    Description = "Key to hide/show",
    DefaultKeybind = ToggleKey,
    Callback = function(k) ToggleKey = k end,
})

SettingsTab:New("Title")({ Title = "❌ Exit" })

SettingsTab:New("Button")({
    Title = "Destroy UI",
    Description = "Close FCAL HUB",
    Callback = function()
        _G.InfJump = false; if _G.InfJumpCon then _G.InfJumpCon:Disconnect() end
        _G.NC = false; if _G.NCCon then _G.NCCon:Disconnect() end
        _G.Fly = false; if _G.FlyCon then _G.FlyCon:Disconnect() end
        _G.ESP = false; _G.GenESP = false
        for _, conn in pairs(ESPConnections) do if conn then conn:Disconnect() end end
        for _, p in pairs(Players:GetPlayers()) do RemoveESPForPlayer(p) end
        RemoveAllGeneratorESP()
        Window:Destroy()
    end,
})

-- Keybind Handler
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if Modal:IsCorrectInput(input, ToggleKey) then
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        if gui then
            local m = gui:FindFirstChild("Modal")
            if m then m.Enabled = not m.Enabled end
        end
    end
end)

-- Init
Notify("FCAL HUB", "Loaded successfully! v1.0.6", "Success")
print("FCAL HUB v1.0.6 - Loaded!")