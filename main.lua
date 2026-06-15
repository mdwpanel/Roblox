--[[
    ███████╗███████╗ █████╗ ██╗     
    ██╔════╝██╔════╝██╔══██╗██║     
    █████╗  █████╗  ███████║██║     
    ██╔══╝  ██╔══╝  ██╔══██║██║     
    ██║     ██║     ██║  ██║███████╗
    ╚═╝     ╚═╝     ╚═╝  ╚═╝╚══════╝
    
    FCAL HUB - LYNX GUI EDITION
    Version: 1.0.6 | Library: LynxGUI (Custom)
--]]

-- Load Library dari kode yang kamu berikan
-- (Pastikan script library-nya sudah ter-load sebelum menjalankan ini)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/4LynxX/Libb/refs/heads/main/Lib2.lua"))()

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
-- Global Variables
_G.AutoCP = false
_G.CPDelay = 1.0
_G.InfJump = false
_G.NC = false
_G.TapTP = false

local Config = {
    WalkSpeedDefault = 16,
    JumpPowerDefault = 50,
    GravityDefault = 196,
    Theme = "Midnight",
    FlySpeed = 100,
    FlySpeedDefault = 100,
}
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

-- [[ WINDOW CREATION ]]
local Window = Library:Window({
    Title = "MDW",
    Footer = "v1.0.6 | Client Sided"
})

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

-- [[ TABS ]]
local MainTab = Window:AddTab({ Name = "Main", Icon = "home" })
local PlayerTab = Window:AddTab({ Name = "Player", Icon = "user" })
local GameTab = Window:AddTab({ Name = "Game", Icon = "gamepad" })
local ServerTab = Window:AddTab({ Name = "Server", Icon = "web" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings" })

-- ==========================================
-- MAIN TAB
-- ==========================================
local QuickSection = MainTab:AddSection("🛠️ Quick Actions")

QuickSection:AddButton({
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
    end
})

QuickSection:AddButton({
    Title = "Reset Character",
    Callback = function() 
        LocalPlayer:LoadCharacter() 
        Library:MakeNotify({ Title = "Success", Content = "Character reset!" })
    end
})

QuickSection:AddButton({
    Title = "Refresh Movement",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        Workspace.Gravity = 196
        Library:MakeNotify({ Title = "Success", Content = "Movement Refreshed!" })
    end
})

local TpSection = MainTab:AddSection("🎯 Teleport")

TpSection:AddToggle({
    Title = "Tap to Teleport",
    Description = "Ketuk lokasi di layar untuk pindah (Mobile Friendly)",
    Default = false,
    Callback = function(v) 
        _G.TapTP = v 
    end
})

local QuickTpSection = MainTab:AddSection("🚀 Quick Player Teleport")

local SelectedTarget = ""

local PlayerDropdown = QuickTpSection:AddDropdown({
    Title = "Pilih Pemain",
    Description = "Pilih target teleportasi dari daftar",
    Options = GetAllPlayers(),
    Default = "",
    Callback = function(v)
        SelectedTarget = v
        Library:MakeNotify({ Title = "Info", Content = "Target: " .. v })
    end
})

QuickTpSection:AddButton({
    Title = "🔄 Refresh Daftar Pemain",
    Description = "Klik jika ada pemain baru yang masuk server",
    Callback = function()
        local currentPlayers = GetAllPlayers()
        PlayerDropdown:Refresh(currentPlayers)
        Library:MakeNotify({ Title = "Success", Content = "Daftar pemain telah diperbarui!" })
    end
})

QuickTpSection:AddButton({
    Title = "Teleport Sekarang",
    Description = "Pindah ke posisi pemain yang dipilih",
    Callback = function()
        if SelectedTarget == "" or SelectedTarget == nil then
            Library:MakeNotify({ Title = "Warning", Content = "Silakan pilih pemain dari daftar dulu!" })
            return
        end

        local target = game.Players:FindFirstChild(SelectedTarget)
        if target and target.Character then
            local myRoot = GetRootPart()
            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
            
            if myRoot and targetRoot then
                -- Teleport ke belakang pemain target agar tidak menabrak
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
                Library:MakeNotify({ Title = "Success", Content = "Teleport ke " .. target.Name .. " Berhasil!" })
            end
        else
            Library:MakeNotify({ Title = "Error", Content = "Pemain tidak ditemukan atau sudah keluar!" })
        end
    end
})

QuickTpSection:AddButton({
    Title = "Bring Player",
    Description = "Bring target to you (visual)",
    Callback = function()
        if TargetName == "" then 
            Library:MakeNotify({ Title = "Warning", Content = "Enter a player name!" }) 
            return 
        end
        
        local target = GetPlayerByName(TargetName)
        if target and target.Character then
            local myRoot = GetRootPart()
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if myRoot and tRoot then
                tRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
                Library:MakeNotify({ Title = "Success", Content = "Brought " .. target.Name })
            end
        else
            Library:MakeNotify({ Title = "Error", Content = "Player not found!" })
        end
    end
}) 
-- ==========================================
-- PLAYER TAB
-- ==========================================
-- =================================================================
-- 🏃 MOVEMENT SETTINGS SECTION
-- =================================================================
local MoveSection = PlayerTab:AddSection("🏃 Movement Settings")

MoveSection:AddInput({
    Title = "WalkSpeed",
    Default = 16,
    Callback = function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) or 16
        end
    end
})

MoveSection:AddInput({
    Title = "Jump Power",
    Default = 50,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) or 50
        end
    end
})

MoveSection:AddInput({
    Title = "Gravity",
    Default = 196,
    Callback = function(v)
        Workspace.Gravity = tonumber(v) or 196
    end
})

MoveSection:AddToggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v) 
        _G.InfJump = v
        if v then
            if not _G.InfJumpCon then
                _G.InfJumpCon = UserInputService.JumpRequest:Connect(function()
                    if _G.InfJump then
                        local hum = GetHumanoid()
                        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                    end
                end)
            end
            Library:MakeNotify({ Title = "Enabled", Content = "Infinite Jump ON" })
        else
            if _G.InfJumpCon then _G.InfJumpCon:Disconnect() _G.InfJumpCon = nil end
            Library:MakeNotify({ Title = "Disabled", Content = "Infinite Jump OFF" })
        end
    end
})

MoveSection:AddToggle({
    Title = "NoClip (Tembus Tembok)",
    Default = false,
    Callback = function(v) 
        _G.NC = v
        if v then
            if not _G.NCCon then
                _G.NCCon = RunService.Stepped:Connect(function()
                    if _G.NC and LocalPlayer.Character then
                        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end)
            end
            Library:MakeNotify({ Title = "Enabled", Content = "NoClip ON" })
        else
            if _G.NCCon then _G.NCCon:Disconnect() _G.NCCon = nil end
            Library:MakeNotify({ Title = "Disabled", Content = "NoClip OFF" })
        end
    end
})

MoveSection:AddToggle({
    Title = "Air Walk (Jesus Mode)",
    Default = false,
    Callback = function(v)
        _G.AirWalk = v
        if v then
            local plat = Instance.new("Part")
            plat.Size = Vector3.new(10, 1, 10)
            plat.Anchored = true
            plat.Transparency = 1
            plat.Parent = Workspace
            
            task.spawn(function()
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
        end
    end
})

-- =================================================================
-- 🛡️ PROTECTION SETTINGS SECTION
-- =================================================================
local AntiSection = PlayerTab:AddSection("🛡️ Protection Settings")

AntiSection:AddToggle({
    Title = "Anti-Ragdoll / No-Stun",
    Default = false,
    Callback = function(v)
        _G.AntiRagdoll = v
        if v then
            task.spawn(function()
                while _G.AntiRagdoll do
                    task.wait(0.1)
                    local hum = GetHumanoid()
                    if hum then
                        if hum.PlatformStand then hum.PlatformStand = false end
                        if hum.Sit then hum.Sit = false end
                    end
                end
            end)
        end
    end
})

AntiSection:AddToggle({
    Title = "Anti-Void",
    Default = false,
    Callback = function(v)
        _G.AntiVoid = v
        if v then
            task.spawn(function()
                local plate = Instance.new("Part", Workspace)
                plate.Size = Vector3.new(100, 1, 100)
                plate.Anchored = true
                plate.Transparency = 1
                plate.CanCollide = false
                
                while _G.AntiVoid do
                    task.wait(0.1)
                    local root = GetRootPart()
                    if root then
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
        end
    end
})

AntiSection:AddToggle({
    Title = "Anti-Freeze & Anti-Stun",
    Default = false,
    Callback = function(v)
        _G.AntiFreeze = v
        if v then
            task.spawn(function()
                while _G.AntiFreeze do
                    task.wait(0.1)
                    local char = LocalPlayer.Character
                    local hum = GetHumanoid()
                    local root = GetRootPart()
                    
                    if char and hum and root then
                        if root.Anchored then root.Anchored = false end
                        if hum.PlatformStand then hum.PlatformStand = false end
                        if hum.Sit then hum.Sit = false end
                    end
                end
            end)
        end
    end
})

-- =================================================================
-- ✈️ FLY SETTINGS SECTION
-- =================================================================
local FlySection = PlayerTab:AddSection("✈️ Fly Settings")

FlySection:AddInput({
    Title = "Fly Speed",
    Default = 100,
    Callback = function(v)
        Config.FlySpeed = tonumber(v) or 100
    end
})

FlySection:AddToggle({
    Title = "Fly [DETECTED AFTER FEW SECONDS!]",
    Default = false,
    Callback = function(v)
        _G.Fly = v
        if v then
            local root = GetRootPart()
            if not root then return end

            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Name = "FlyVel"
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.Velocity = Vector3.new(0, 0, 0)
            bodyVel.Parent = root

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
                    local speed = Config.FlySpeed or 100

                    if hum and hum.MoveDirection.Magnitude > 0 then
                        moveDir = hum.MoveDirection * speed
                    end

                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveDir = moveDir + Vector3.new(0, speed, 0)
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        moveDir = moveDir + Vector3.new(0, -speed, 0)
                    end

                    bodyVel.Velocity = moveDir
                    bodyGyro.CFrame = cam.CFrame
                end
            end)
            Library:MakeNotify({ Title = "Enabled", Content = "Fly Aktif! Gunakan W,A,S,D + Space/Ctrl" })
        else
            if _G.FlyCon then _G.FlyCon:Disconnect() _G.FlyCon = nil end
            local root = GetRootPart()
            if root then
                local bv = root:FindFirstChild("FlyVel")
                local bg = root:FindFirstChild("FlyGyro")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
            Library:MakeNotify({ Title = "Disabled", Content = "Fly Mati" })
        end
    end
})
-- ==========================================
-- GAME TAB
-- ==========================================
-- =================================================================
-- 🏔️ AUTO FARMING CP SECTION
-- =================================================================
local FarmSection = GameTab:AddSection("🏔️ Auto Farming CP")

FarmSection:AddToggle({
    Title = "Master Auto CP",
    Default = false,
    Callback = function(v)
        _G.AutoCP = v
        if v then
            task.spawn(function()
                local lastNum = 0
                while _G.AutoCP do
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not root then task.wait(1) continue end
                    
                    local allCPs = {}
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        local num = tonumber(obj.Name:match("%d+"))
                        if num and num > lastNum and (obj.Name:lower():find("cp") or obj.Name:lower():find("stage") or obj.Name:lower():find("point") or obj.Name:lower():find("level") or obj:IsA("SpawnLocation")) then
                            table.insert(allCPs, {Part = obj, Num = num})
                        end
                    end
                    
                    table.sort(allCPs, function(a,b) return a.Num < b.Num end)
                    
                    if #allCPs > 0 then
                        local nextCP = allCPs[1]
                        Library:MakeNotify({ Title = "Auto CP", Content = "Menuju CP Nomor: " .. nextCP.Num })
                        
                        root.CFrame = nextCP.Part.CFrame * CFrame.new(0,3,0)
                        task.wait(0.3)
                        root.CFrame = nextCP.Part.CFrame * CFrame.new(0,1.2,0) -- Leg Touch
                        
                        lastNum = nextCP.Num
                        task.wait(_G.CPDelay or 1.0)
                    else 
                        Library:MakeNotify({ Title = "Selesai", Content = "Tidak ditemukan CP baru. Scan ulang..." })
                        task.wait(3) 
                    end
                end
            end)
        end
    end
})

FarmSection:AddToggle({
    Title = "Master Auto CP (STEALTH MODE)",
    Default = false,
    Callback = function(v)
        _G.AutoCP = v
        if v then
            task.spawn(function()
                local lastNum = 0
                while _G.AutoCP do
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not root then task.wait(1) continue end
                    
                    local allCPs = {}
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        local num = tonumber(obj.Name:match("%d+"))
                        if num and num > lastNum then
                            table.insert(allCPs, {Part = obj, Num = num})
                        end
                    end
                    
                    table.sort(allCPs, function(a, b) return a.Num < b.Num end)

                    if #allCPs > 0 then
                        local nextCP = allCPs[1]
                        Library:MakeNotify({ Title = "Stealth CP", Content = "Meluncur ke Stage: " .. nextCP.Num })

                        local distance = (root.Position - nextCP.Part.Position).Magnitude
                        local duration = distance / 150 
                        
                        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
                        local tween = TweenService:Create(root, tweenInfo, {CFrame = nextCP.Part.CFrame * CFrame.new(0, 3, 0)})
                        
                        tween:Play()
                        tween.Completed:Wait()

                        local randomDelay = (_G.CPDelay or 1.0) + (math.random(1, 10) / 10)
                        task.wait(randomDelay)
                        
                        lastNum = nextCP.Num
                    else
                        Library:MakeNotify({ Title = "Selesai", Content = "Semua CP terambil atau tidak ada CP baru." })
                        _G.AutoCP = false
                    end
                end
            end)
        end
    end
})

FarmSection:AddInput({
    Title = "CP Delay",
    Default = 1.0,
    Callback = function(v) _G.CPDelay = tonumber(v) or 1.0 end
})

FarmSection:AddButton({
    Title = "TP to Top of Mountain",
    Callback = function()
        local highestPart = nil
        local maxWait = -99999
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Position.Y > maxWait then
                if obj.Size.Y > 5 and obj.CanCollide then
                    maxWait = obj.Position.Y
                    highestPart = obj
                end
            end
        end
        
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if highestPart and root then
            root.CFrame = highestPart.CFrame + Vector3.new(0, 10, 0)
            Library:MakeNotify({ Title = "Teleport", Content = "Berhasil ke Puncak Gunung!" })
        end
    end
})


-- =================================================================
-- 🎭 VISUAL ESP & TRACKING SECTION
-- =================================================================
local VisualSection = GameTab:AddSection("🎭 Visual ESP & Tracking")

VisualSection:AddToggle({
    Title = "ESP Box (2D)",
    Default = false,
    Callback = function(v) _G.BoxESP = v end
})

VisualSection:AddToggle({
    Title = "ESP Tracers (Line)",
    Default = false,
    Callback = function(v) _G.LineESP = v end
})

VisualSection:AddToggle({
    Title = "ESP Health Bar",
    Default = false,
    Callback = function(v)
        _G.HealthESP = v
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("HealthBarGui") then
                    p.Character.Head.HealthBarGui:Destroy()
                end
            end
        end
    end
})

-- Loop RenderStepped untuk Health Bar tetap berjalan secara mandiri
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

VisualSection:AddToggle({
    Title = "ESP Players",
    Default = false,
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
            Library:MakeNotify({ Title = "Enabled", Content = "ESP ON - Colors by role!" })
        else
            _G.ESP = false
            for _, conn in pairs(ESPConnections) do if conn then conn:Disconnect() end end
            ESPConnections = {}
            for _, p in pairs(Players:GetPlayers()) do RemoveESPForPlayer(p) end
            Library:MakeNotify({ Title = "Disabled", Content = "ESP OFF" })
        end
    end
})

VisualSection:AddToggle({
    Title = "Headlight (God Light)",
    Default = false,
    Callback = function(v)
        local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
        if head then
            local light = head:FindFirstChild("GodLight") or Instance.new("SpotLight", head)
            light.Name = "GodLight"
            light.Range = 150
            light.Brightness = 5
            light.Enabled = v
        end
    end
})

VisualSection:AddToggle({
    Title = "Freecam (Ghost View)",
    Default = false,
    Callback = function(v)
        local cam = workspace.CurrentCamera
        if v then
            _G.OldSubject = cam.CameraSubject
            cam.CameraType = Enum.CameraType.Scriptable
            Library:MakeNotify({ Title = "Freecam", Content = "Gunakan WASD & Q/E untuk terbang" })
            _G.FreecamLoop = RunService.RenderStepped:Connect(function()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then cam.CFrame *= CFrame.new(0,0,-1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then cam.CFrame *= CFrame.new(0,0,1) end
            end)
        else
            if _G.FreecamLoop then _G.FreecamLoop:Disconnect() end
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = _G.OldSubject
        end
    end
})

VisualSection:AddToggle({
    Title = "X-Ray Mode",
    Default = false,
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
    end
})

VisualSection:AddToggle({
    Title = "Fullbright",
    Default = false,
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
            Library:MakeNotify({ Title = "Enabled", Content = "Fullbright ON" })
        else
            Lighting.Brightness = _G.OldBright or 1
            Lighting.ClockTime = _G.OldTime or 14
            Lighting.FogEnd = _G.OldFog or 100000
            Lighting.GlobalShadows = _G.OldShadows or true
            Library:MakeNotify({ Title = "Disabled", Content = "Fullbright OFF" })
        end
    end
})


-- =================================================================
-- 🎮 GAMEPLAY UTILITIES SECTION
-- =================================================================
local UtilSection = GameTab:AddSection("🎮 Gameplay Utilities")

UtilSection:AddToggle({
    Title = "Auto Skill Check (Mobile)",
    Default = false,
    Callback = function(v)
        _G.AutoSkillMobile = v
        if v then
            task.spawn(function()
                while _G.AutoSkillMobile do
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end
            end)
        end
    end
})

UtilSection:AddToggle({
    Title = "Killer Proximity Warning",
    Default = false,
    Callback = function(v)
        _G.KillerWarn = v
        if v then
            task.spawn(function()
                while _G.KillerWarn do
                    task.wait(0.5)
                    for _, p in pairs(game.Players:GetPlayers()) do
                        if GetPlayerRole(p) == "Killer" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if myRoot then
                                local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                                if dist < 50 then
                                    Library:MakeNotify({ Title = "⚠️ AWAS!", Content = "Killer mendekat! Jarak: " .. math.floor(dist) .. " studs" })
                                    task.wait(2)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
})

UtilSection:AddToggle({
    Title = "Auto Wiggle",
    Default = false,
    Callback = function(v)
        _G.Wiggle = v
        if v then
            task.spawn(function()
                while _G.Wiggle do
                    task.wait(0.05)
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.A, false, game)
                    task.wait(0.05)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.A, false, game)
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.D, false, game)
                    task.wait(0.05)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.D, false, game)
                end
            end)
        end
    end
})

local hbSize = 2
UtilSection:AddSlider({
    Title = "Hitbox Expander",
    Default = 2,
    Minimum = 2,
    Maximum = 20,
    Callback = function(v) hbSize = v end
})

UtilSection:AddToggle({
    Title = "Enable Hitbox",
    Default = false,
    Callback = function(v)
        _G.Hitbox = v
        if v then
            task.spawn(function()
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
        end
    end
})


-- =================================================================
-- 🎯 FIND OBJECTS & DEBUG SECTION
-- =================================================================
local FindSection = GameTab:AddSection("🎯 Find Objects & Debug")

FindSection:AddButton({
    Title = "Find Generators",
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
        Library:MakeNotify({ Title = "Found", Content = c .. " generators (" .. completed .. " done, " .. (c - completed) .. " left)" })
    end
})

FindSection:AddButton({
    Title = "Find Exit Gates",
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
        Library:MakeNotify({ Title = "Found", Content = c .. " exit gates highlighted!" })
    end
})

FindSection:AddButton({
    Title = "Clear Highlights",
    Callback = function()
        local count = 0
        for _, o in pairs(Workspace:GetDescendants()) do
            if o:IsA("Highlight") then 
                o:Destroy() 
                count = count + 1
            end
        end
        for _, o in pairs(game.CoreGui:GetChildren()) do
            if o.Name:find("ESP_") or o.Name:find("GenESP_") then
                o:Destroy()
            end
        end
        ESPHighlights = {}
        ESPLabels = {}
        GenHighlights = {}
        Library:MakeNotify({ Title = "Cleared", Content = count .. " highlights removed!" })
    end
})

FindSection:AddButton({
    Title = "Debug: Print All Objects",
    Callback = function()
        print("=== FCAL HUB - Workspace Objects ===")
        local counted = {}
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local name = obj.Name
                if not counted[name] then counted[name] = 0 end
                counted[name] = counted[name] + 1
            end
        end
        for name, count in pairs(counted) do
            print(name .. " (x" .. count .. ")")
        end
        Library:MakeNotify({ Title = "Debug", Content = "Check console (F9) for object list!" })
    end
})

-- =================================================================
-- 🛡️ SELF-PROTECTION & SECURITY SECTION
-- =================================================================
local ProtectSection = ServerTab:AddSection("🛡️ Self-Protection & Security")

ProtectSection:AddToggle({
    Title = "Anti-Kick Protection",
    Default = false,
    Callback = function(v)
        _G.AntiKick = v
        if v then
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if _G.AntiKick and self == LocalPlayer and method == "Kick" then
                    Library:MakeNotify({ Title = "Security", Content = "Game mencoba menendangmu! (Kick diblokir)" })
                    return nil
                end
                return oldNamecall(self, ...)
            end)
            Library:MakeNotify({ Title = "Anti-Kick", Content = "Perlindungan aktif!" })
        end
    end
})

ProtectSection:AddToggle({
    Title = "Admin Join Detector",
    Default = false,
    Callback = function(v)
        _G.AdminDetect = v
        if v then
            Library:MakeNotify({ Title = "Security", Content = "Scanning Moderator aktif..." })
            Players.PlayerAdded:Connect(function(player)
                if _G.AdminDetect then
                    if player:GetRankInGroup(game.CreatorId) >= 200 or player.AccountAge < 1 then
                        LocalPlayer:Kick("FCAL HUB: Admin terdeteksi (" .. player.Name .. "). Keluar demi keamanan.")
                    end
                end
            end)
        end
    end
})

ProtectSection:AddToggle({
    Title = "Anti-Kick (Hanya Client)",
    Default = false,
    Callback = function(v)
        _G.AntiKick = v
        if v then
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            local old = mt.__namecall
            
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if _G.AntiKick and method == "Kick" then
                    Library:MakeNotify({ Title = "Blocked!", Content = "Game mencoba menendangmu, tapi digagalkan." })
                    return nil
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end
    end
})

ProtectSection:AddButton({
    Title = "Manual Emergency Kick",
    Callback = function()
        LocalPlayer:Kick("FCAL HUB: Sesi diakhiri secara manual oleh pengguna.")
    end
})

ProtectSection:AddButton({
    Title = "Instant Server Hop",
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
            Library:MakeNotify({ Title = "Error", Content = "Tidak menemukan server lain!" })
        end
    end
})

ProtectSection:AddButton({
    Title = "Attempt Remote Kick Scan",
    Callback = function()
        Library:MakeNotify({ Title = "Scanning", Content = "Mencari Remote Event yang tidak aman..." })
        local found = false
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("kick") or obj.Name:lower():find("ban")) then
                print("Ditemukan Remote Potensial: " .. obj:GetFullName())
                found = true
            end
        end
        
        if found then
            Library:MakeNotify({ Title = "Warning", Content = "Ditemukan celah potensial! Cek Console (F9)" })
        else
            Library:MakeNotify({ Title = "Safe", Content = "Tidak ditemukan celah kick sederhana." })
        end
    end
})


-- =================================================================
-- 🌐 SERVER INFO SECTION
-- =================================================================
local InfoSection = ServerTab:AddSection("🌐 Server Info")

local msg = "FCAL HUB ON TOP!"
InfoSection:AddInput({
    Title = "Custom Chat Message",
    Default = "FCAL HUB ON TOP!",
    Callback = function(v) msg = v end
})

InfoSection:AddToggle({
    Title = "Auto Chat Spammer",
    Default = false,
    Callback = function(v)
        _G.Spam = v
        if v then
            task.spawn(function()
                while _G.Spam do
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
                    task.wait(5)
                end
            end)
        end
    end
})

InfoSection:AddToggle({
    Title = "Enable Chat Logger",
    Default = false,
    Callback = function(v)
        _G.ChatLog = v
        if v then
            Library:MakeNotify({ Title = "Chat Logger", Content = "Logger Aktif. Tekan F9 untuk melihat." })
            for _, player in pairs(game.Players:GetPlayers()) do
                player.Chatted:Connect(function(msg)
                    if _G.ChatLog then
                        print("[" .. player.Name .. "]: " .. msg)
                    end
                end)
            end
        end
    end
})

InfoSection:AddButton({
    Title = "Copy Job ID",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            Library:MakeNotify({ Title = "Copied", Content = "Job ID copied!" })
        else
            Library:MakeNotify({ Title = "Job ID", Content = game.JobId })
        end
    end
})

InfoSection:AddButton({
    Title = "Copy Place ID",
    Callback = function()
        if setclipboard then
            setclipboard(tostring(game.PlaceId))
            Library:MakeNotify({ Title = "Copied", Content = "Place ID copied!" })
        else
            Library:MakeNotify({ Title = "Place ID", Content = tostring(game.PlaceId) })
        end
    end
})


-- =================================================================
-- 🚪 ACTIONS SECTION
-- =================================================================
local ActionsSection = ServerTab:AddSection("🚪 Actions")

ActionsSection:AddButton({
    Title = "Rejoin",
    Callback = function() 
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) 
    end
})

ActionsSection:AddButton({
    Title = "Server Hop",
    Callback = function() 
        TeleportService:Teleport(game.PlaceId, LocalPlayer) 
    end
})


-- =================================================================
-- 👁️ SPECTATE SECTION
-- =================================================================
local SpectateSection = ServerTab:AddSection("👁️ Spectate")

local SpecTarget = ""
local names = {}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(names, p.Name) end
end

SpectateSection:AddDropdown({
    Title = "Select Player",
    Options = #names > 0 and names or {"No Players"},
    Default = "",
    Callback = function(v) SpecTarget = v end
})

SpectateSection:AddButton({
    Title = "Spectate",
    Callback = function()
        if SpecTarget ~= "" and SpecTarget ~= "No Players" then
            local t = GetPlayerByName(SpecTarget)
            if t and t.Character then
                Workspace.CurrentCamera.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid") or t.Character
                Library:MakeNotify({ Title = "Spectating", Content = "Now watching " .. t.Name })
            end
        else
            Library:MakeNotify({ Title = "Warning", Content = "Select a player first!" })
        end
    end
})

SpectateSection:AddButton({
    Title = "Stop Spectating",
    Callback = function()
        if LocalPlayer.Character then
            Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or LocalPlayer.Character
            Library:MakeNotify({ Title = "Stopped", Content = "Returned to your view" })
        end
    end
})

-- ==========================================
-- LOOPS & LOGIC
-- ==========================================
-- =================================================================
-- 🛡️ PROTECTION SECTION
-- =================================================================
local pengaturanSection = SettingsTab:AddSection("🛡️ Protection")

pengaturanSection:AddToggle({
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
    end
})

pengaturanSection:AddButton({
    Title = "Fake Name (Anti-Report)",
    Description = "Ganti namamu jadi 'Anonymous' (Hanya di layar kamu)",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.DisplayName = "Anonymous_User"
            Notify("Stealth", "Nama disamarkan!", "Success")
        end
    end
})


-- =================================================================
-- 🎨 THEME SECTION
-- =================================================================
local themeSection = SettingsTab:AddSection("🎨 Theme")

themeSection:AddDropdown({
    Title = "Select Theme",
    Description = "Change UI theme",
    Options = {"Dark", "Light", "Midnight", "Rose", "Emerald"},
    Default = Config.Theme,
    Callback = function(v)
        Window:SetTheme(v)
        Notify("Theme", "Changed to " .. v, "Success")
    end
})


-- =================================================================
-- ⌨️ KEYBIND SECTION
-- =================================================================
local keybindSection = SettingsTab:AddSection("⌨️ Keybind")

local ToggleKey = "RightControl"
keybindSection:AddKeybind({
    Title = "Toggle UI",
    Description = "Key to hide/show",
    DefaultKeybind = ToggleKey,
    Callback = function(k) 
        ToggleKey = k 
    end
})


-- =================================================================
-- ❌ EXIT SECTION
-- =================================================================
local exitSection = SettingsTab:AddSection("❌ Exit")

exitSection:AddButton({
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
    end
})

RunService.Stepped:Connect(function()
    if _G.NC and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if _G.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

UserInputService.TouchTapInWorld:Connect(function(position, processed)
    if _G.TapTP and not processed then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local camera = Workspace.CurrentCamera
            local ray = camera:ViewportPointToRay(position.X, position.Y)
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
            if result then root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0)) end
        end
    end
end)

-- Initialize Library
Library:Initialize()
Library:MakeNotify({
    Title = "FCAL HUB",
    Description = "Script Loaded Successfully!",
    Delay = 5
})