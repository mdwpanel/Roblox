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
-- ================= SECTION: QUICK ACTIONS =================
local QuickSection = MainTab:AddSection("🛠️ Quick Actions")
 
QuickSection:AddButton({
    Title = "Get Gravity Gun",
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
                connection = game:GetService("RunService").RenderStepped:Connect(function()
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
        
        Library:MakeNotify({ Title = "Success", Content = "Gravity Gun added to Backpack!" })
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
        Library:MakeNotify({ Title = "Success", Content = "Movement & Gravity Refreshed!" })
    end
})

-- ================= SECTION: TELEPORT =================
local TpSection = MainTab:AddSection("🎯 Teleport")

TpSection:AddToggle({
    Title = "Tap to Teleport",
    Default = false,
    Callback = function(v) 
        _G.TapTP = v 
    end
})

-- ================= SECTION: PLAYER TELEPORT =================
local PlayerTpSection = MainTab:AddSection("🚀 Quick Player Teleport")

local SelectedTarget = ""

local PlayerDropdown = PlayerTpSection:AddDropdown({
    Title = "Pilih Pemain",
    Values = GetAllPlayers(), -- Pastikan fungsi ini tersedia
    Default = "",
    Callback = function(v)
        SelectedTarget = v
    end
})

PlayerTpSection:AddButton({
    Title = "🔄 Refresh Daftar Pemain",
    Callback = function()
        local currentPlayers = GetAllPlayers()
        PlayerDropdown:SetValues(currentPlayers) -- Menggunakan SetValues sesuai standar library baru
        Library:MakeNotify({ Title = "Updated", Content = "Daftar pemain telah diperbarui!" })
    end
})

PlayerTpSection:AddButton({
    Title = "Teleport Ke Target",
    Callback = function()
        if SelectedTarget == "" then 
            Library:MakeNotify({ Title = "Warning", Content = "Pilih pemain dulu!" }) 
            return 
        end

        local target = game.Players:FindFirstChild(SelectedTarget)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                myRoot.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                Library:MakeNotify({ Title = "Success", Content = "Teleport Berhasil!" })
            end
        else
            Library:MakeNotify({ Title = "Error", Content = "Pemain tidak ditemukan!" })
        end
    end
})

PlayerTpSection:AddButton({
    Title = "Bring Player (Visual)",
    Callback = function()
        if SelectedTarget == "" then 
            Library:MakeNotify({ Title = "Warning", Content = "Pilih pemain dulu!" }) 
            return 
        end

        local target = game.Players:FindFirstChild(SelectedTarget)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                target.Character.HumanoidRootPart.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
                Library:MakeNotify({ Title = "Success", Content = "Player Brought!" })
            end
        end
    end
})

-- ==========================================
-- PLAYER TAB
-- ==========================================
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

MoveSection:AddToggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v) _G.InfJump = v end
})

MoveSection:AddToggle({
    Title = "NoClip (Tembus Tembok)",
    Default = false,
    Callback = function(v) _G.NC = v end
})

local IdentitySection = PlayerTab:AddSection("🎭 Identity Stealer")

local SelectedPlayer = ""
local PlayerDropdown = IdentitySection:AddDropdown({
    Title = "Pilih Pemain",
    Options = (function()
        local t = {}
        for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(t, p.Name) end end
        return t
    end)(),
    Callback = function(v) SelectedPlayer = v end
})

IdentitySection:AddButton({
    Title = "Terapkan Identity",
    Callback = function()
        local target = Players:FindFirstChild(SelectedPlayer)
        if target and target.Character then
            pcall(function()
                local desc = Players:GetHumanoidDescriptionFromUserId(target.UserId)
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ApplyDescription(desc)
            end)
        end
    end
})

-- ==========================================
-- GAME TAB
-- ==========================================
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
                    local allCPs = {}
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        local num = tonumber(obj.Name:match("%d+"))
                        if num and num > lastNum and (obj.Name:lower():find("cp") or obj:IsA("SpawnLocation")) then
                            table.insert(allCPs, {Part = obj, Num = num})
                        end
                    end
                    table.sort(allCPs, function(a,b) return a.Num < b.Num end)
                    if #allCPs > 0 then
                        root.CFrame = allCPs[1].Part.CFrame * CFrame.new(0,3,0)
                        lastNum = allCPs[1].Num
                        task.wait(_G.CPDelay)
                    else task.wait(1) end
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

-- ==========================================
-- SERVER TAB
-- ==========================================
local ProtectSection = ServerTab:AddSection("🛡️ Protection")

ProtectSection:AddToggle({
    Title = "Anti-Kick Protection",
    Default = false,
    Callback = function(v) _G.AntiKick = v end
})

ProtectSection:AddButton({
    Title = "Server Hop",
    Callback = function()
        local servers = {}
        local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
        for i,v in pairs(game:GetService("HttpService"):JSONDecode(res).data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then table.insert(servers, v.id) end
        end
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    end
})

-- ==========================================
-- LOOPS & LOGIC
-- ==========================================
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
