-- [[ AUTHOR INFORMATION ]]
-- FCAL HUB - LYNX GUI EDITION
-- Version: 1.0.6 | Library: LynxGUI (Custom)

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

local ESP_Objects = {}
local LocalPlayer = Players.LocalPlayer

-- Global Variables
_G.AutoCP = false
_G.CPDelay = 1.0
_G.InfJump = false
_G.NC = false
_G.TapTP = false
_G.GenESP = false
_G.GateESP = false

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
                
                if onScreen then
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
                        objects.Line.From = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y)
                        objects.Line.To = Vector2.new(pos.X, pos.Y)
                    else
                        objects.Line.Visible = false
                    end
                else
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
        for player, _ in pairs(ESP_Objects) do
            ClearESP(player)
        end
    end
end)

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

-- Generator Detection
local function IsGenerator(obj)
    if not obj then return false end
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return false end
    local name = obj.Name:lower()
    if name:find("player") or name:find("character") or name:find("npc") or name:find("killer") or name:find("survivor") or name:find("humanoid") then
        return false
    end
    if obj:IsA("Model") then
        if obj:FindFirstChildOfClass("Humanoid") then return false end
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character == obj then return false end
        end
    end
    local isGen = false
    if name:find("generator") or name:find("gen%d") or name:find("gen_%d") or name:find("gen %d") or name == "gen" then isGen = true end
    if name:find("fusebox") or name:find("fuse_box") or name:find("fuse box") or name:find("powerbox") or name:find("power_box") or name:find("power box") then isGen = true end
    if name:find("switchbox") or name:find("switch_box") or (name:find("lever") and not name:find("player")) then isGen = true end
    return isGen
end

local function IsGeneratorCompleted(gen)
    if gen:GetAttribute("Completed") == true or gen:GetAttribute("IsCompleted") == true or gen:GetAttribute("Finished") == true or gen:GetAttribute("Powered") == true or gen:GetAttribute("Done") == true then return true end
    local progress = gen:GetAttribute("Progress")
    if progress and (progress >= 1 or progress >= 100) then return true end
    for _, child in pairs(gen:GetChildren()) do
        local childName = child.Name:lower()
        if child:IsA("BoolValue") and (childName:find("complet") or childName:find("finish") or childName:find("done")) and child.Value then return true end
        if (child:IsA("NumberValue") or child:IsA("IntValue")) and childName:find("progress") and (child.Value >= 100 or child.Value >= 1) then return true end
    end
    return false
end

local function GetGeneratorProgress(gen)
    local progress = gen:GetAttribute("Progress")
    if progress then return progress <= 1 and progress * 100 or progress end
    for _, child in pairs(gen:GetChildren()) do
        if child.Name:lower():find("progress") and (child:IsA("NumberValue") or child:IsA("IntValue")) then
            return child.Value <= 1 and child.Value * 100 or child.Value
        end
    end
    return 0
end

-- ESP System Variables
local ESPConnections = {}
local ESPHighlights = {}
local ESPLabels = {}
local GenHighlights = {}
local GateHighlights = {}

local function CreateESPForPlayer(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character then return end
    
    if ESPHighlights[player] and ESPHighlights[player].Parent then ESPHighlights[player]:Destroy() end
    if ESPLabels[player] and ESPLabels[player].Parent then ESPLabels[player]:Destroy() end
    
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
    if ESPHighlights[player] then if ESPHighlights[player].Parent then ESPHighlights[player]:Destroy() end ESPHighlights[player] = nil end
    if ESPLabels[player] then if ESPLabels[player].Parent then ESPLabels[player]:Destroy() end ESPLabels[player] = nil end
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

local function CreateGeneratorESP(gen)
    if GenHighlights[gen] then return end
    local isCompleted = IsGeneratorCompleted(gen)
    local progress = GetGeneratorProgress(gen)
    
    local fillColor, outlineColor, textColor
    if isCompleted then
        fillColor, outlineColor, textColor = Color3.fromRGB(0, 255, 100), Color3.fromRGB(150, 255, 150), Color3.fromRGB(0, 255, 100)
    else
        fillColor, outlineColor, textColor = Color3.fromRGB(255, 170, 0), Color3.fromRGB(255, 220, 100), Color3.fromRGB(255, 170, 0)
    end
    
    local hl = Instance.new("Highlight")
    hl.Name = "GenESP_Highlight"
    hl.FillColor = fillColor
    hl.OutlineColor = outlineColor
    hl.FillTransparency = 0.5
    hl.Adornee = gen
    hl.Parent = gen
    
    local billboard = nil
    local primaryPart = gen:IsA("Model") and gen.PrimaryPart or (gen:IsA("BasePart") and gen or gen:FindFirstChildWhichIsA("BasePart"))
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
    GenHighlights[gen] = {Highlight = hl, Label = billboard, LastCompleted = isCompleted, LastProgress = progress}
end

local function UpdateGeneratorESP()
    if not _G.GenESP then return end
    for gen, data in pairs(GenHighlights) do
        if gen and gen.Parent then
            local isCompleted = IsGeneratorCompleted(gen)
            local progress = GetGeneratorProgress(gen)
            if isCompleted ~= data.LastCompleted then
                data.LastCompleted = isCompleted
                local fillColor, outlineColor, textColor = isCompleted and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 170, 0), isCompleted and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 220, 100), isCompleted and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 170, 0)
                if data.Highlight and data.Highlight.Parent then data.Highlight.FillColor, data.Highlight.OutlineColor = fillColor, outlineColor end
                if data.Label and data.Label.Parent then
                    local label = data.Label:FindFirstChild("GenLabel")
                    if label then label.TextColor3, label.Text = textColor, isCompleted and "✓ COMPLETE" or ("⚡ " .. math.floor(progress) .. "%") end
                end
            end
            if not isCompleted and progress ~= data.LastProgress and data.Label and data.Label.Parent then
                local label = data.Label:FindFirstChild("GenLabel")
                if label then label.Text = "⚡ " .. math.floor(progress) .. "%" end
            end
        else
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

local function FindAllGenerators()
    local generators = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if IsGenerator(obj) then table.insert(generators, obj) end
    end
    return generators
end

-- [[ TABS INITIALIZATION (FIXED ICON CRASH)]]
local MainTab = Window:AddTab({ Name = "Main", Title = "Main", Icon = "home" })
local PlayerTab = Window:AddTab({ Name = "Player", Title = "Player", Icon = "user" })
local GameTab = Window:AddTab({ Name = "Game", Title = "Game", Icon = "gamepad" })
local ServerTab = Window:AddTab({ Name = "Server", Title = "Server", Icon = "server" })
local SettingsTab = Window:AddTab({ Name = "Settings", Title = "Settings", Icon = "settings" })

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
    Callback = function(v) _G.TapTP = v end
})

local QuickTpSection = MainTab:AddSection("🚀 Quick Player Teleport")
local SelectedTarget = ""

local PlayerDropdown = QuickTpSection:AddDropdown({
    Title = "Pilih Pemain",
    Default = "",
    Callback = function(v) SelectedTarget = v end
})

local function RefreshPlayerList()
    PlayerDropdown:Clear()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then PlayerDropdown:Add(player.Name) end
    end
end

QuickTpSection:AddButton({ Title = "🔄 Refresh Daftar Pemain", Callback = RefreshPlayerList })

QuickTpSection:AddButton({
    Title = "Teleport Sekarang",
    Callback = function()
        local target = Players:FindFirstChild(SelectedTarget)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
})

QuickTpSection:AddButton({
    Title = "Bring Player",
    Description = "Bring target to you (visual)",
    Callback = function()
        if SelectedTarget == "" or SelectedTarget == "No Players" then 
            Library:MakeNotify({ Title = "Warning", Content = "Pilih pemain dari daftar terlebih dahulu!" }) 
            return 
        end
        local target = GetPlayerByName(SelectedTarget)
        if target and target.Character then
            local myRoot = GetRootPart()
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if myRoot and tRoot then
                tRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
                Library:MakeNotify({ Title = "Success", Content = "Membawa " .. target.Name })
            end
        else
            Library:MakeNotify({ Title = "Error", Content = "Pemain tidak ditemukan!" })
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
    Callback = function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end end
})

MoveSection:AddInput({
    Title = "Jump Power",
    Default = 50,
    Callback = function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = tonumber(v) or 50 end end
})

MoveSection:AddInput({
    Title = "Gravity",
    Default = 196,
    Callback = function(v) Workspace.Gravity = tonumber(v) or 196 end
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

MoveSection:AddToggle({
    Title = "Air Walk (Jesus Mode)",
    Default = false,
    Callback = function(v)
        _G.AirWalk = v
        if v then
            local plat = Instance.new("Part")
            plat.Size = Vector3.new(10, 1, 10)
            plat.Value = true
            plat.Anchored = true
            plat.Transparency = 1
            plat.Parent = Workspace
            task.spawn(function()
                while _G.AirWalk do
                    task.wait()
                    local root = GetRootPart()
                    if root then plat.CFrame = root.CFrame * CFrame.new(0, -3.5, 0) plat.CanCollide = true end
                end
                plat:Destroy()
            end)
        end
    end
})

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
                    if hum then if hum.PlatformStand then hum.PlatformStand = false end if hum.Sit then hum.Sit = false end end
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
                        if root.Position.Y < -50 then plate.CFrame = CFrame.new(root.Position.X, -50, root.Position.Z) plate.CanCollide = true else plate.CanCollide = false end
                    end
                end
                plate:Destroy()
            end)
        end
    end
})

local FlySection = PlayerTab:AddSection("✈️ Fly Settings")

FlySection:AddInput({ Title = "Fly Speed", Default = 100, Callback = function(v) Config.FlySpeed = tonumber(v) or 100 end })

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
                    if hum and hum.MoveDirection.Magnitude > 0 then moveDir = hum.MoveDirection * speed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, speed, 0)
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir + Vector3.new(0, -speed, 0) end
                    bodyVel.Velocity = moveDir
                    bodyGyro.CFrame = cam.CFrame
                end
            end)
        else
            if _G.FlyCon then _G.FlyCon:Disconnect() _G.FlyCon = nil end
            local root = GetRootPart()
            if root then
                local bv = root:FindFirstChild("FlyVel")
                local bg = root:FindFirstChild("FlyGyro")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
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
                        root.CFrame = nextCP.Part.CFrame * CFrame.new(0,3,0)
                        task.wait(0.3)
                        root.CFrame = nextCP.Part.CFrame * CFrame.new(0,1.2,0)
                        lastNum = nextCP.Num
                        task.wait(_G.CPDelay or 1.0)
                    else task.wait(3) end
                end
            end)
        end
    end
})

FarmSection:AddInput({ Title = "CP Delay", Default = 1.0, Callback = function(v) _G.CPDelay = tonumber(v) or 1.0 end })

local VisualSection = GameTab:AddSection("🎭 Visual ESP & Tracking")

VisualSection:AddToggle({ Title = "ESP Box (2D)", Default = false, Callback = function(v) _G.BoxESP = v end })
VisualSection:AddToggle({ Title = "ESP Tracers (Line)", Default = false, Callback = function(v) _G.LineESP = v end })

VisualSection:AddToggle({
    Title = "ESP Players (Highlight)",
    Default = false,
    Callback = function(v)
        if v then
            _G.ESP = true
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then CreateESPForPlayer(p) end
            end
            local updateConn = RunService.Heartbeat:Connect(function()
                if _G.ESP then for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then UpdateESPForPlayer(p) end end end
            end)
            table.insert(ESPConnections, updateConn)
        else
            _G.ESP = false
            for _, p in pairs(Players:GetPlayers()) do RemoveESPForPlayer(p) end
        end
    end
})

-- [[ FIX SAKLAR ON/OFF ESP BENDA MERAH & KOTAK PUTIH ]]
VisualSection:AddToggle({
    Title = "ESP Generators (Anti Stuck)",
    Default = false,
    Callback = function(v)
        _G.GenESP = v
        if v then
            task.spawn(function()
                while _G.GenESP do
                    local gens = FindAllGenerators()
                    for _, gen in pairs(gens) do CreateGeneratorESP(gen) end
                    UpdateGeneratorESP()
                    task.wait(1)
                end
            end)
        else
            RemoveAllGeneratorESP()
        end
    end
})

VisualSection:AddToggle({
    Title = "ESP Exit Gates",
    Default = false,
    Callback = function(v)
        _G.GateESP = v
        if v then
            task.spawn(function()
                while _G.GateESP do
                    for _, o in pairs(Workspace:GetDescendants()) do
                        if (o.Name:lower():find("gate") or o.Name:lower():find("exit")) and (o:IsA("Model") or o:IsA("BasePart")) then
                            if not GateHighlights[o] then
                                local hl = Instance.new("Highlight")
                                hl.FillColor = Color3.fromRGB(0, 255, 0)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.5
                                hl.Adornee = o
                                hl.Parent = o
                                GateHighlights[o] = hl
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        else
            for o, hl in pairs(GateHighlights) do if hl and hl.Parent then hl:Destroy() end end
            GateHighlights = {}
        end
    end
})

VisualSection:AddButton({
    Title = "Clear All Highlights Manual",
    Callback = function()
        for _, o in pairs(Workspace:GetDescendants()) do if o:IsA("Highlight") then o:Destroy() end end
        for _, o in pairs(game.CoreGui:GetChildren()) do if o.Name:find("ESP_") or o.Name:find("GenESP_") then o:Destroy() end end
        ESPHighlights, ESPLabels, GenHighlights, GateHighlights = {}, {}, {}, {}
    end
})

-- =================================================================
-- SERVER TAB (FIXED & WORKING NOW)
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
                if _G.AntiKick and self == LocalPlayer and method == "Kick" then return nil end
                return oldNamecall(self, ...)
            end)
        end
    end
})

ProtectSection:AddButton({ Title = "Manual Emergency Kick", Callback = function() LocalPlayer:Kick("FCAL HUB Emergency.") end })

local InfoSection = ServerTab:AddSection("🌐 Server Info")
local msg = "FCAL HUB ON TOP!"

InfoSection:AddInput({ Title = "Custom Chat Message", Default = "FCAL HUB ON TOP!", Callback = function(v) msg = v end })

InfoSection:AddToggle({
    Title = "Auto Chat Spammer",
    Default = false,
    Callback = function(v)
        _G.Spam = v
        if v then
            task.spawn(function()
                while _G.Spam do
                    local chatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                    if chatEvent then chatEvent:FireServer(msg, "All") end
                    task.wait(5)
                end
            end)
        end
    end
})

local ActionsSection = ServerTab:AddSection("🚪 Actions")
ActionsSection:AddButton({ Title = "Rejoin Server", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end })

-- ==========================================
-- SETTINGS TAB (FIXED & WORKING NOW)
-- ==========================================
local pengaturanSection = SettingsTab:AddSection("🛡️ Protection")

pengaturanSection:AddToggle({
    Title = "Streamer Mode",
    Description = "Sembunyikan namamu di seluruh UI agar aman",
    Default = false, -- FIXED: Sebelumnya DefaultValue (Salah)
    Callback = function(v)
        if v then Window:SetTitle("SECRET HUB") Window:SetSubTitle("User: Anonymous")
        else Window:SetTitle("MDW") Window:SetSubTitle("v1.0.6 | Client Sided") end
    end
})

local themeSection = SettingsTab:AddSection("🎨 Theme")
local ThemeDropdown = themeSection:AddDropdown({
    Title = "Select Theme",
    Default = "Midnight",
    Callback = function(v) Window:SetTheme(v) end
})
ThemeDropdown:Add("Dark")
ThemeDropdown:Add("Light")
ThemeDropdown:Add("Midnight")

local exitSection = SettingsTab:AddSection("❌ Exit")
exitSection:AddButton({
    Title = "Destroy UI",
    Callback = function()
        _G.InfJump = false
        _G.NC = false
        _G.Fly = false
        _G.ESP = false
        _G.GenESP = false
        RemoveAllGeneratorESP()
        for o, hl in pairs(GateHighlights) do if hl and hl.Parent then hl:Destroy() end end
        for _, p in pairs(Players:GetPlayers()) do RemoveESPForPlayer(p) end
        Window:Destroy()
    end
})

-- [[ GLOBAL LOOPS & CONNECTIONS ]]
RunService.Stepped:Connect(function()
    if _G.NC and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if _G.InfJump then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

UserInputService.TouchTapInWorld:Connect(function(position, processed)
    if _G.TapTP and not processed then
        local root = GetRootPart()
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
