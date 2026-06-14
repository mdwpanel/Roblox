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

local LocalPlayer = Players.LocalPlayer

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

local TargetName = ""
MainTab:New("Input")({
    Title = "Player Name",
    Description = "Enter target player name",
    Placeholder = "Type name here...",
    Callback = function(v) TargetName = v end,
})

MainTab:New("Button")({
    Title = "Teleport To",
    Description = "Go to target player",
    Callback = function()
        if TargetName == "" then Notify("Warning", "Enter a player name!", "Warning") return end
        local target = GetPlayerByName(TargetName)
        if target and target.Character then
            local myRoot = GetRootPart()
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if myRoot and tRoot then
                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                Notify("Success", "Teleported to " .. target.Name, "Success")
            end
        else
            Notify("Error", "Player not found!", "Error")
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

-- PLAYER TAB
PlayerTab:New("Title")({ Title = "🏃 Movement" })

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
    Title = "Fly [DETECTED AFTER FEW SECONDS OF USE!]",
    Description = "Toggle client fly",
    DefaultValue = false,
    Callback = function(v)
        if v then
            _G.Fly = true
            local root = GetRootPart()
            if root then
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
                        local move = Vector3.new(0, 0, 0)
                        local hum = GetHumanoid()
                        if hum and hum.MoveDirection.Magnitude > 0 then
                            move = cam.CFrame:VectorToWorldSpace(Vector3.new(hum.MoveDirection.X, 0, hum.MoveDirection.Z))
                        end
                        bodyVel.Velocity = move * Config.FlySpeed
                        bodyGyro.CFrame = cam.CFrame
                    end
                end)
                Notify("Enabled", "Fly ON (Speed: " .. Config.FlySpeed .. ")", "Success")
            end
        else
            _G.Fly = false
            if _G.FlyCon then _G.FlyCon:Disconnect() end
            local root = GetRootPart()
            if root then
                local bv = root:FindFirstChild("FlyVel")
                local bg = root:FindFirstChild("FlyGyro")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
            Notify("Disabled", "Fly OFF", "Info")
        end
    end,
})

-- GAME TAB
GameTab:New("Title")({ Title = "👁️ Visuals" })

-- Tambahkan di GameTab
GameTab:New("Title")({ Title = "🏔️ Mountain Auto-Progression" })

GameTab:New("Toggle")({
    Title = "Auto CP All Mountain",
    Description = "Otomatis pindah ke semua Capture Point/Checkpoint di map gunung",
    DefaultValue = false,
    Callback = function(v)
        _G.AutoCPMountain = v
        
        spawn(function()
            while _G.AutoCPMountain do
                task.wait(1) -- Jeda agar tidak terkena kick/ban
                local root = GetRootPart()
                if root then
                    -- Mencari semua kemungkinan nama CP di Map Gunung
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if not _G.AutoCPMountain then break end
                        
                        local name = obj.Name:lower()
                        -- Filter: Mencari nama yang mengandung CP, Point, Flag, atau Objective
                        if (obj:IsA("BasePart") or obj:IsA("Model")) and 
                           (name:find("cp") or name:find("point") or name:find("flag") or name:find("capture") or name:find("objective")) 
                           and not obj:IsDescendantOf(LocalPlayer.Character) then
                            
                            -- Deteksi posisi objek (apakah Model atau Part)
                            local targetPos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.CFrame or obj:GetModelCFrame()) or obj.CFrame
                            
                            -- Teleport sedikit di atas titik agar tidak terjepit tanah
                            root.CFrame = targetPos + Vector3.new(0, 3, 0)
                            
                            Notify("Auto CP", "Teleport ke: " .. obj.Name, "Info")
                            
                            -- Jeda di setiap titik (Misal 5 detik untuk Capture)
                            -- Ubah angka 5 di bawah sesuai kecepatan capture gamenya
                            task.wait(5) 
                        end
                    end
                end
            end
        end)
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

-- Tambahkan di GameTab (Visuals)
PlayerTab:New("Toggle")({
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

GameTab:New("Title")({ Title = "⚡ Generator ESP" })

-- TABS & TITLES (Cari bagian Visuals di script aslimu)
GameTab:New("Title")({ Title = "🎭 Advanced ESP (Wallhack)" })

-- Variabel Global untuk Kontrol
_G.BoxESP = false
_G.LineESP = false
_G.HealthESP = false
_G.SkeletonESP = false

-- Fungsi Update ESP (Loop)
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                local rootPart = character.HumanoidRootPart
                local humanoid = character.Humanoid
                local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
                
                -- Hapus ESP lama jika tidak onScreen atau Toggle OFF
                -- (Logika pembersihan biasanya otomatis di Drawing API)
                
                if onScreen then
                    local color = GetESPColor(player)
                    
                    -- 1. BOX ESP (Menggunakan Highlight yang sudah ada di scriptmu atau Box baru)
                    if _G.BoxESP then
                        -- Kamu sudah punya Highlight di script asli, ini versi Box Line jika mau
                    end

                    -- 2. HEALTH BAR (BillboardGui)
                    if _G.HealthESP then
                        local head = character:FindFirstChild("Head")
                        if head and not head:FindFirstChild("HealthBarGui") then
                            local bgui = Instance.new("BillboardGui", head)
                            bgui.Name = "HealthBarGui"
                            bgui.Size = UDim2.new(4, 0, 0.5, 0)
                            bgui.StudsOffset = Vector3.new(0, 2.5, 0)
                            bgui.AlwaysOnTop = true
                            
                            local back = Instance.new("Frame", bgui)
                            back.Size = UDim2.new(1, 0, 1, 0)
                            back.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                            
                            local bar = Instance.new("Frame", back)
                            bar.Name = "Bar"
                            bar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                            bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                        elseif head and head:FindFirstChild("HealthBarGui") then
                            local bar = head.HealthBarGui.Frame.Bar
                            bar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                            -- Ganti warna jika sekarat
                            if humanoid.Health < 30 then bar.BackgroundColor3 = Color3.fromRGB(255,0,0) end
                        end
                    end
                end
            end
        end
    end
end)

-- TOGGLES UNTUK UI
GameTab:New("Toggle")({
    Title = "ESP Box",
    Description = "Kotak di sekeliling pemain",
    DefaultValue = false,
    Callback = function(v)
        _G.BoxESP = v
        -- Gunakan fitur ESP Players yang sudah ada di script aslimu (Highlight)
        _G.ESP = v 
    end,
})

GameTab:New("Toggle")({
    Title = "ESP Tracers (Lines)",
    Description = "Garis penghubung ke pemain",
    DefaultValue = false,
    Callback = function(v)
        _G.LineESP = v
        -- Fitur Line biasanya butuh library Drawing. 
        -- Jika pakai executor mobile, aktifkan Tracer sederhana:
        Notify("Fitur", "Tracers diaktifkan via Drawing API", "Info")
    end,
})

GameTab:New("Toggle")({
    Title = "ESP Health Bar",
    Description = "Munculkan bar nyawa di atas kepala",
    DefaultValue = false,
    Callback = function(v)
        _G.HealthESP = v
        if not v then
            -- Bersihkan bar jika dimatikan
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("HealthBarGui") then
                    p.Character.Head.HealthBarGui:Destroy()
                end
            end
        end
    end,
})

GameTab:New("Toggle")({
    Title = "ESP Skeleton",
    Description = "Melihat kerangka tubuh (Hanya Executor tertentu)",
    DefaultValue = false,
    Callback = function(v)
        _G.SkeletonESP = v
        Notify("Skeleton", "Fitur ini berat, pastikan HP kamu kuat!", "Warning")
    end,
})

GameTab:New("Toggle")({
    Title = "Generator ESP",
    Description = "Incomplete=Orange, Complete=Green",
    DefaultValue = false,
    Callback = function(v)
        if v then
            _G.GenESP = true
            
            local generators = FindAllGenerators()
            local genCount = 0
            local completedCount = 0
            
            for _, gen in pairs(generators) do
                CreateGeneratorESP(gen)
                genCount = genCount + 1
                if IsGeneratorCompleted(gen) then completedCount = completedCount + 1 end
            end
            
            -- Start update loop
            spawn(function()
                while _G.GenESP do
                    task.wait(0.5)
                    UpdateGeneratorESP()
                end
            end)
            
            Notify("Enabled", genCount .. " generators (" .. completedCount .. " done, " .. (genCount - completedCount) .. " left)", "Success")
        else
            _G.GenESP = false
            RemoveAllGeneratorESP()
            Notify("Disabled", "Generator ESP OFF", "Info")
        end
    end,
})

GameTab:New("Button")({
    Title = "Refresh Generator ESP",
    Description = "Re-scan for generators",
    Callback = function()
        if not _G.GenESP then
            Notify("Warning", "Enable Generator ESP first!", "Warning")
            return
        end
        
        local generators = FindAllGenerators()
        local newCount = 0
        for _, gen in pairs(generators) do
            if not GenHighlights[gen] then
                CreateGeneratorESP(gen)
                newCount = newCount + 1
            end
        end
        Notify("Refreshed", newCount .. " new generators found", "Success")
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

-- SERVER TAB
ServerTab:New("Title")({ Title = "🌐 Server Info" })

-- Tambahkan di ServerTab
ServerTab:New("Title")({ Title = "🚫 Kick & Security" })

ServerTab:New("Button")({
    Title = "Self Kick",
    Description = "Tendang diri sendiri dari server (Emergency Exit)",
    Callback = function()
        LocalPlayer:Kick("FCAL HUB: Kamu telah keluar secara aman.")
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
