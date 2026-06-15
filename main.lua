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
    Title = "Reset Character",
    Description = "Respawn your character",
    Callback = function()
        LocalPlayer:LoadCharacter()
        Notify("Success", "Character reset!", "Success")
    end
})

QuickSection:AddButton({
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
    end
})

local TpSection = MainTab:AddSection("🎯 Teleport")

TpSection:AddToggle({
    Title = "Tap to Teleport",
    Description = "Ketuk lokasi di layar untuk pindah (Mobile Friendly)",
    DefaultValue = false,
    Callback = function(v)
        _G.TapTP = v
    end
})

local TeleSection = MainTab:AddSection("🎯 Teleport")
local SelectedTarget = ""
TeleSection:AddToggle({
    Title = "Pilih Pemain",
    Description = "Pilih target teleportasi dari daftar",
    Options = GetAllPlayers(),
    Default = "",
    Callback = function(v)
        SelectedTarget = v
        Notify("Target Dipilih", "Target: " .. v, "Info")
    end
})

TeleSection:AddToggle({
    Title = "🔄 Refresh Daftar Pemain",
    Description = "Klik jika ada pemain baru yang masuk server",
    Callback = function()
        local currentPlayers = GetAllPlayers()
        PlayerDropdown:Refresh(currentPlayers)
        Notify("Updated", "Daftar pemain telah diperbarui!", "Success")
    end
})

TeleSection:AddToggle({
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
    end
})

TeleSection:AddToggle({
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
    end
})
-- ==========================================
-- PLAYER TAB
-- ==========================================
-- ==========================================
-- IDENTITY STEALER SECTION
-- ==========================================
local IdentitySection = PlayerTab:AddSection("👤 Smart Identity Stealer")

local PlayerSelector = IdentitySection:AddDropdown("PlayerSelector", {
    Title = "Pilih Nama Pemain",
    Description = "Nama otomatis terdaftar di sini",
    Values = GetAllPlayerNames(),
    Default = "",
    Callback = function(v)
        SelectedAutoPlayer = v
        Notify("Target Terpilih", "Target: " .. v, "Info")
    end
})

IdentitySection:AddButton({
    Title = "🔄 Refresh Daftar Nama",
    Description = "Update list pemain terbaru",
    Callback = function()
        PlayerSelector:SetValues(GetAllPlayerNames())
        Notify("Updated", "Daftar pemain diperbarui!", "Success")
    end
})

IdentitySection:AddButton({
    Title = "🎭 Copy Pemain Terdekat",
    Callback = function()
        local target = GetNearestPlayer()
        if target then
            SelectedAutoPlayer = target.Name
            ExecuteIdentityCopy(target)
        else
            Notify("Error", "Tidak ada pemain di sekitar!", "Warning")
        end
    end
})

IdentitySection:AddButton({
    Title = "✨ Terapkan dari Dropdown",
    Callback = function()
        local target = game.Players:FindFirstChild(SelectedAutoPlayer)
        if target then
            ExecuteIdentityCopy(target)
        else
            Notify("Error", "Pilih pemain dulu!", "Warning")
        end
    end
})

IdentitySection:AddButton({
    Title = "🔄 Reset Identity",
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
    end
})

-- ==========================================
-- MOVEMENT SETTINGS SECTION
-- ==========================================
local MoveSection = PlayerTab:AddSection("🏃 Movement Settings")

MoveSection:AddSlider("WalkSpeedSlider", {
    Title = "Walk Speed",
    Description = "Kecepatan jalan",
    Default = 16,
    Min = 1,
    Max = 250,
    Rounding = 0,
    Callback = function(v)
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = v end
    end
})

MoveSection:AddSlider("JumpPowerSlider", {
    Title = "Jump Power",
    Description = "Kekuatan loncatan",
    Default = 50,
    Min = 0,
    Max = 300,
    Rounding = 0,
    Callback = function(v)
        local hum = GetHumanoid()
        if hum then hum.JumpPower = v end
    end
})

MoveSection:AddSlider("GravitySlider", {
    Title = "Gravity",
    Description = "Gravitasi dunia",
    Default = 196,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        Workspace.Gravity = v
    end
})

-- ==========================================
-- TOGGLES SECTION
-- ==========================================
local ToggleSection = PlayerTab:AddSection("⚡ Toggles & Cheats")

ToggleSection:AddToggle("AirWalk", {
    Title = "Air Walk (Fly Mode)",
    Default = false,
    Callback = function(v)
        _G.AirWalk = v
        if v then
            local plat = Instance.new("Part")
            plat.Name = "AirWalkPart"
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
        end
    end
})

ToggleSection:AddToggle("InfJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v)
        _G.InfJump = v
    end
})

ToggleSection:AddToggle("NoClip", {
    Title = "NoClip (Tembus Tembok)",
    Default = false,
    Callback = function(v)
        _G.NC = v
    end
})

ToggleSection:AddToggle("AntiVoid", {
    Title = "Anti-Void",
    Default = false,
    Callback = function(v)
        _G.AntiVoid = v
        if v then
            spawn(function()
                local plate = Instance.new("Part", Workspace)
                plate.Size = Vector3.new(100, 1, 100)
                plate.Anchored = true
                plate.Transparency = 1
                while _G.AntiVoid do
                    task.wait(0.1)
                    local root = GetRootPart()
                    if root and root.Position.Y < -50 then
                        plate.CFrame = CFrame.new(root.Position.X, -50, root.Position.Z)
                        plate.CanCollide = true
                    else
                        plate.CanCollide = false
                    end
                end
                plate:Destroy()
            end)
        end
    end
})

ToggleSection:AddToggle("AntiRagdoll", {
    Title = "Anti-Ragdoll / Stun",
    Default = false,
    Callback = function(v)
        _G.AntiRagdoll = v
    end
})

-- ==========================================
-- FLY SETTINGS SECTION
-- ==========================================
local FlySection = PlayerTab:AddSection("✈️ Fly Settings")

FlySection:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Default = 100,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        Config.FlySpeed = v
    end
})

FlySection:AddToggle("FlyToggle", {
    Title = "Enable Fly",
    Description = "W,A,S,D + Space/Ctrl",
    Default = false,
    Callback = function(v)
        _G.Fly = v
        if v then
            local root = GetRootPart()
            if not root then return end

            local bodyVel = Instance.new("BodyVelocity", root)
            bodyVel.Name = "FlyVel"
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            
            local bodyGyro = Instance.new("BodyGyro", root)
            bodyGyro.Name = "FlyGyro"
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

            spawn(function()
                while _G.Fly do
                    local cam = Workspace.CurrentCamera
                    local hum = GetHumanoid()
                    local moveDir = Vector3.new(0,0,0)

                    if hum and hum.MoveDirection.Magnitude > 0 then
                        moveDir = hum.MoveDirection * (Config.FlySpeed or 100)
                    end

                    if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                        moveDir = moveDir + Vector3.new(0, (Config.FlySpeed or 100), 0)
                    elseif game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
                        moveDir = moveDir + Vector3.new(0, -(Config.FlySpeed or 100), 0)
                    end

                    bodyVel.Velocity = moveDir
                    bodyGyro.CFrame = cam.CFrame
                    task.wait()
                end
                bodyVel:Destroy()
                bodyGyro:Destroy()
            end)
        end
    end
})
-- ==========================================
-- GAME TAB
-- ==========================================
local VisualSection = GameTab:AddSection("🎭 Visual ESP")

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

-- Logic Health Bar (Running in background)
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
                        local bar = gui.Frame.Bar
                        bar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                        bar.BackgroundColor3 = Color3.fromHSV(humanoid.Health/humanoid.MaxHealth * 0.3, 1, 1)
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- AUTO FARMING SECTION
-- ==========================================
local FarmSection = GameTab:AddSection("🏔️ Auto Farming CP")

_G.CPDelay = 1.0 -- Default Delay

FarmSection:AddInput({
    Title = "CP Delay (Detik)",
    Default = "1.0",
    Callback = function(v) _G.CPDelay = tonumber(v) or 1.0 end
})

FarmSection:AddToggle({
    Title = "Master Auto CP (Teleport)",
    Default = false,
    Callback = function(v)
        _G.AutoCP = v
        if v then
            task.spawn(function()
                local lastCPNumber = 0
                while _G.AutoCP do
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not root then task.wait(1) continue end
                    
                    local allCPs = {}
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        local num = tonumber(obj.Name:match("%d+"))
                        if num and num > lastCPNumber and (obj.Name:lower():find("cp") or obj.Name:lower():find("stage") or obj:IsA("SpawnLocation")) then
                            table.insert(allCPs, {Part = obj, Num = num})
                        end
                    end
                    table.sort(allCPs, function(a, b) return a.Num < b.Num end)
                    
                    if #allCPs > 0 then
                        local nextCP = allCPs[1]
                        Notify("Auto CP", "Menuju CP: " .. nextCP.Num, "Info")
                        root.CFrame = nextCP.Part.CFrame * CFrame.new(0, 3, 0)
                        task.wait(0.3)
                        root.CFrame = nextCP.Part.CFrame * CFrame.new(0, 1.2, 0)
                        task.wait(_G.CPDelay)
                        lastCPNumber = nextCP.Num
                    else
                        task.wait(1)
                    end
                end
            end)
        end
    end
})

FarmSection:AddToggle({
    Title = "Stealth Auto CP (Tween)",
    Default = false,
    Callback = function(v)
        _G.StealthCP = v
        if v then
            task.spawn(function()
                local lastNum = 0
                while _G.StealthCP do
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
                        local dist = (root.Position - nextCP.Part.Position).Magnitude
                        local duration = dist / 150
                        
                        local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = nextCP.Part.CFrame * CFrame.new(0, 3, 0)})
                        tween:Play()
                        tween.Completed:Wait()
                        
                        task.wait(_G.CPDelay)
                        lastNum = nextCP.Num
                    else
                        task.wait(1)
                    end
                end
            end)
        end
    end
})

FarmSection:AddButton({
    Title = "TP ke Puncak Gunung",
    Callback = function()
        local highestPart = nil
        local maxWait = -99999
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Position.Y > maxWait and obj.Size.Y > 5 and obj.CanCollide then
                maxWait = obj.Position.Y
                highestPart = obj
            end
        end
        if highestPart then
            LocalPlayer.Character.HumanoidRootPart.CFrame = highestPart.CFrame + Vector3.new(0, 10, 0)
        end
    end
})

-- ==========================================
-- WORLD VISUALS SECTION
-- ==========================================
local WorldSection = GameTab:AddSection("👁️ World Visuals")

WorldSection:AddToggle({
    Title = "Headlight (God Light)",
    Default = false,
    Callback = function(v)
        local head = LocalPlayer.Character:FindFirstChild("Head")
        if head then
            local light = head:FindFirstChild("GodLight") or Instance.new("SpotLight", head)
            light.Name = "GodLight"
            light.Range = 150
            light.Brightness = 5
            light.Enabled = v
        end
    end
})

WorldSection:AddToggle({
    Title = "Freecam",
    Default = false,
    Callback = function(v)
        local cam = workspace.CurrentCamera
        if v then
            _G.OldSubject = cam.CameraSubject
            cam.CameraType = Enum.CameraType.Scriptable
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

WorldSection:AddToggle({
    Title = "X-Ray Mode",
    Default = false,
    Callback = function(v)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Parent:FindFirstChild("Humanoid") then
                if v then
                    if not obj:GetAttribute("OldTrans") then obj:SetAttribute("OldTrans", obj.Transparency) end
                    obj.Transparency = 0.5
                else
                    obj.Transparency = obj:GetAttribute("OldTrans") or 0
                end
            end
        end
    end
})

WorldSection:AddToggle({
    Title = "Fullbright",
    Default = false,
    Callback = function(v)
        if v then
            _G.OldBright = Lighting.Brightness
            _G.OldTime = Lighting.ClockTime
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = _G.OldBright or 1
            Lighting.ClockTime = _G.OldTime or 14
            Lighting.GlobalShadows = true
        end
    end
})

-- ==========================================
-- GAMEPLAY HELPERS SECTION
-- ==========================================
local HelperSection = GameTab:AddSection("⚙️ Gameplay Helpers")

HelperSection:AddToggle({
    Title = "Auto Skill Check",
    Default = false,
    Callback = function(v)
        _G.AutoSkillMobile = v
        task.spawn(function()
            while _G.AutoSkillMobile do
                task.wait(0.1)
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.05)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end
        end)
    end
})

HelperSection:AddToggle({
    Title = "Auto Wiggle",
    Default = false,
    Callback = function(v)
        _G.Wiggle = v
        task.spawn(function()
            while _G.Wiggle do
                task.wait(0.05)
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, Enum.KeyCode.A, false, game)
                vim:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, Enum.KeyCode.D, false, game)
            end
        end)
    end
})

HelperSection:AddToggle({
    Title = "Killer Proximity Warning",
    Default = false,
    Callback = function(v)
        _G.KillerWarn = v
        task.spawn(function()
            while _G.KillerWarn do
                task.wait(0.5)
                for _, p in pairs(Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        -- Ganti logic GetPlayerRole sesuai game anda
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 50 and p ~= LocalPlayer then
                            Notify("⚠️ PERINGATAN", "Pemain mendekat: " .. p.Name, "Warning")
                            task.wait(2)
                        end
                    end
                end
            end
        end)
    end
})

-- ==========================================
-- HITBOX SECTION
-- ==========================================
local HitboxSection = GameTab:AddSection("🎯 Hitbox & Player")

local hbSize = 2
HitboxSection:AddSlider("HitboxSlider", {
    Title = "Hitbox Size",
    Default = 2, Min = 2, Max = 20, Rounding = 0,
    Callback = function(v) hbSize = v end
})

HitboxSection:AddToggle({
    Title = "Enable Hitbox",
    Default = false,
    Callback = function(v)
        _G.Hitbox = v
        task.spawn(function()
            while _G.Hitbox do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = p.Character.HumanoidRootPart
                        hrp.Size = Vector3.new(hbSize, hbSize, hbSize)
                        hrp.Transparency = 0.7
                        hrp.CanCollide = false
                    end
                end
                task.wait(1)
            end
        end)
    end
})

-- ==========================================
-- FIND OBJECTS SECTION
-- ==========================================
local ObjectSection = GameTab:AddSection("🔍 Find Objects")

ObjectSection:AddButton({
    Title = "Cari Generators",
    Callback = function()
        for _, o in pairs(Workspace:GetDescendants()) do
            if o.Name:lower():find("generator") then
                local hl = Instance.new("Highlight", o)
                hl.FillColor = Color3.fromRGB(255, 170, 0)
            end
        end
    end
})

ObjectSection:AddButton({
    Title = "Cari Exit Gates",
    Callback = function()
        for _, o in pairs(Workspace:GetDescendants()) do
            if o.Name:lower():find("gate") or o.Name:lower():find("exit") then
                local hl = Instance.new("Highlight", o)
                hl.FillColor = Color3.fromRGB(0, 255, 0)
            end
        end
    end
})

ObjectSection:AddButton({
    Title = "Hapus Semua Highlight",
    Callback = function()
        for _, o in pairs(Workspace:GetDescendants()) do
            if o:IsA("Highlight") then o:Destroy() end
        end
    end
})

ObjectSection:AddButton({
    Title = "Debug: Print All Objects",
    Callback = function()
        print("--- Object List ---")
        for _, o in pairs(Workspace:GetChildren()) do print(o.Name) end
    end
})

-- ==========================================
-- SERVER TAB
-- ==========================================
-- ==========================================
-- SERVER TAB - PROTECTION SECTION
-- ==========================================
local ProtectSection = ServerTab:AddSection("🛡️ Self-Protection & Security")

ProtectSection:AddToggle("AntiKick", {
    Title = "Anti-Kick Protection",
    Description = "Mencegah script game menendangmu otomatis",
    Default = false,
    Callback = function(v)
        _G.AntiKick = v
        if v then
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if _G.AntiKick and self == game.Players.LocalPlayer and method == "Kick" then
                    Notify("Security", "Kick diblokir!", "Warning")
                    return nil
                end
                return oldNamecall(self, ...)
            end)
        end
    end
})

ProtectSection:AddToggle("AdminDetect", {
    Title = "Admin Join Detector",
    Description = "Otomatis Keluar jika Admin masuk",
    Default = false,
    Callback = function(v)
        _G.AdminDetect = v
        game.Players.PlayerAdded:Connect(function(player)
            if _G.AdminDetect then
                if player:GetRankInGroup(game.CreatorId) >= 200 or player.AccountAge < 1 then
                    game.Players.LocalPlayer:Kick("Admin terdeteksi: " .. player.Name)
                end
            end
        end)
    end
})

ProtectSection:AddButton({
    Title = "Manual Emergency Kick",
    Callback = function() game.Players.LocalPlayer:Kick("Manual Exit") end
})

ProtectSection:AddButton({
    Title = "Scan Remote Kick",
    Callback = function()
        local found = false
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("kick") or obj.Name:lower():find("ban")) then
                print("Remote Ditemukan: " .. obj:GetFullName())
                found = true
            end
        end
        Notify("Scan", found and "Cek Console (F9)" or "Tidak ada celah", "Info")
    end
})

-- ==========================================
-- SERVER TAB - UTILITY SECTION
-- ==========================================
local ServerInfo = ServerTab:AddSection("🌐 Server & Chat")

ServerInfo:AddToggle("ChatLogger", {
    Title = "Enable Chat Logger",
    Default = false,
    Callback = function(v)
        _G.ChatLog = v
        for _, player in pairs(game.Players:GetPlayers()) do
            player.Chatted:Connect(function(msg)
                if _G.ChatLog then print("[" .. player.Name .. "]: " .. msg) end
            end)
        end
    end
})

local spamMsg = "FCAL HUB ON TOP!"
ServerInfo:AddInput("SpamInput", {
    Title = "Custom Chat Message",
    Default = spamMsg,
    Placeholder = "Ketik pesan...",
    Callback = function(v) spamMsg = v end
})

ServerInfo:AddToggle("AutoSpam", {
    Title = "Auto Chat Spammer",
    Default = false,
    Callback = function(v)
        _G.Spam = v
        task.spawn(function()
            while _G.Spam do
                local event = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                if event then event.SayMessageRequest:FireServer(spamMsg, "All") end
                task.wait(5)
            end
        end)
    end
})

ServerInfo:AddButton({
    Title = "Copy Job ID",
    Callback = function() setclipboard(game.JobId) Notify("Success", "Job ID copied!", "Success") end
})

ServerInfo:AddButton({
    Title = "Copy Place ID",
    Callback = function() setclipboard(tostring(game.PlaceId)) Notify("Success", "Place ID copied!", "Success") end
})

-- ==========================================
-- SERVER TAB - SPECTATE & ACTIONS
-- ==========================================
local ActionSection = ServerTab:AddSection("👁️ Actions & Spectate")

ActionSection:AddButton({
    Title = "Rejoin Server",
    Callback = function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId) end
})

ActionSection:AddButton({
    Title = "Instant Server Hop",
    Callback = function()
        local servers = {}
        local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
        for i,v in pairs(game:GetService("HttpService"):JSONDecode(res).data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then table.insert(servers, v.id) end
        end
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    end
})

local SpecTarget = ""
local PlayerList = ActionSection:AddDropdown("SpecDropdown", {
    Title = "Pilih Pemain",
    Values = {},
    Default = "",
    Callback = function(v) SpecTarget = v end
})

-- Fungsi Update List Pemain
local function UpdatePlayers()
    local names = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then table.insert(names, p.Name) end
    end
    PlayerList:SetValues(names)
end
UpdatePlayers()

ActionSection:AddButton({
    Title = "Spectate",
    Callback = function()
        local t = game.Players:FindFirstChild(SpecTarget)
        if t and t.Character then
            workspace.CurrentCamera.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid")
        end
    end
})

ActionSection:AddButton({
    Title = "Stop Spectating",
    Callback = function()
        workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
})

-- ==========================================
-- SETTINGS TAB - STEALTH & THEME
-- ==========================================
local SettingsSection = SettingsTab:AddSection("⚙️ Settings & Theme")

SettingsSection:AddToggle("StreamerMode", {
    Title = "Streamer Mode",
    Description = "Sembunyikan nama di UI",
    Default = false,
    Callback = function(v)
        if v then Window:SetTitle("SECRET HUB") else Window:SetTitle("FCAL HUB") end
    end
})

SettingsSection:AddButton({
    Title = "Fake Name (Anonymous)",
    Callback = function()
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.DisplayName = "Anonymous_User"
        end
    end
})

SettingsSection:AddDropdown("ThemeDropdown", {
    Title = "Select Theme",
    Values = {"Dark", "Light", "Midnight", "Rose", "Emerald"},
    Default = "Dark",
    Callback = function(v) Window:SetTheme(v) end
})

SettingsSection:AddButton({
    Title = "Destroy UI",
    Callback = function()
        _G.InfJump = false; _G.NC = false; _G.Fly = false; _G.ESP = false
        Window:Destroy()
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