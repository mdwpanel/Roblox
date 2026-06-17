--[[
    FCAL HUB - LYNX GUI EDITION
    Version: 2.3.1 | ULTIMATE EDITION FIXED
    Dengan Marketplace Skins, Admin Kick & Freeze!
--]]

-- ==========================================
-- LOAD LIBRARY DENGAN RETRY
-- ==========================================
local Library = nil
local maxRetries = 3
for i = 1, maxRetries do
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/mdwpanel/Roblox/refs/heads/main/main_ui_modern.lua"))()
    end)
    if success and result then
        Library = result
        break
    end
    task.wait(1)
end

if not Library then
    -- Fallback library sederhana jika gagal load
    Library = {
        Window = function() return {
            AddTab = function() return {
                AddSection = function() return {
                    AddButton = function() end,
                    AddToggle = function() end,
                    AddDropdown = function() end,
                    AddInput = function() end,
                    AddSlider = function() end
                } end
            } end
        } end,
        MakeNotify = function() end,
        Initialize = function() end
    }
    warn("Library gagal dimuat, menggunakan fallback!")
end

-- Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService") 
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")
local ContextActionService = game:GetService("ContextActionService")
local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

-- Global Variables
local LocalPlayer = Players.LocalPlayer
local ESP_Objects = {}
local ManualHighlights = {}
local ESP_Highlights = {}
local ESPLabels = {}
local ToggleKey = Enum.KeyCode.RightControl
local msg = "FCAL HUB ON TOP!"
local SpecTarget = ""
local hbSize = 2
local SkinData = {}
local ActiveSkin = nil
local IsSkinActive = false
local SkinParts = {}
local FrozenPlayers = {}
local AdminList = {}

-- GLOBAL CONFIG
_G.AutoCPAll = false
_G.CPTeleportDelay = 0.8
_G.AutoCP = false
_G.InfJump = false
_G.NC = false
_G.TapTP = false
_G.AutoInteract = false
_G.BoxESP = false
_G.LineESP = false
_G.SkeletonESP = false
_G.ESP = false
_G.HealthESP = false
_G.AntiRagdoll = false
_G.AntiVoid = false
_G.AntiKick = false
_G.AdminDetect = false
_G.Hitbox = false
_G.CPDelay = 2.0
_G.Fly = false
_G.AirWalk = false
_G.WalkingAntiVoid = false
_G.AntiFreeze = false 
_G.Wiggle = false
_G.KillerWarn = false
_G.Headlight = false
_G.XRay = false
_G.Fullbright = false
_G.Freecam = false
_G.Spam = false
_G.ChatLog = false
_G.GenESP = false
_G.MenuVisible = true
_G.AutoWalk = false
_G.AutoWalkSpeed = 25
_G.WallHack = false
_G.GravityGunActive = false
_G.ActiveTheme = "Midnight"
_G.SkinPreview = false
_G.SkinName = ""
_G.SkinColor = Color3.fromRGB(255,255,255)
_G.SkinEffect = "None"
_G.Aimbot = false
_G.SilentAim = false
_G.AutoFarm = false
_G.AutoClick = false
_G.AntiAFK = false
_G.NoStun = false
_G.AutoHeal = false
_G.AutoCollect = false
_G.AutoSell = false
_G.SpeedHack = false
_G.SpeedValue = 50
_G.JumpHack = false
_G.JumpValue = 100
_G.AdminKick = false
_G.AdminFreeze = false
_G.FreezeRange = 50
_G.KickRange = 50

local Config = {
    WalkSpeedDefault = 16,
    JumpPowerDefault = 50,
    GravityDefault = 196,
    Theme = "Midnight", 
    FlySpeed = 100,
    AimbotSmoothness = 10,
    AimbotRange = 200,
    AutoFarmDelay = 0.5,
}

-- ==========================================
-- ANTI-KICK BYPASS
-- ==========================================
pcall(function()
    local mt = getrawmetatable(game) 
    if mt then
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" or method == "kick" then return nil end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
end)

-- ==========================================
-- HELPER FUNCTIONS
-- ==========================================
function ClearESP(player)
    if ESP_Objects[player] then
        for _, obj in pairs(ESP_Objects[player]) do
            pcall(function() 
                if obj.Box then obj.Box.Visible = false end
                if obj.Line then obj.Line.Visible = false end
                if obj.Skeleton then 
                    for _, line in pairs(obj.Skeleton) do
                        line.Visible = false
                    end
                end
                obj:Remove() 
            end)
        end
        ESP_Objects[player] = nil
    end
end

function ClearManualHighlights()
    for _, hl in pairs(ManualHighlights) do
        pcall(function() hl:Destroy() end)
    end
    ManualHighlights = {}
end

function UpdateSkeletonESP(player, objects)
    local character = player.Character
    if not character then return end
    
    local joints = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
    }
    
    if objects.Skeleton then
        for _, line in pairs(objects.Skeleton) do
            pcall(function() line.Visible = false end)
        end
        objects.Skeleton = {}
    end
    
    local color = GetESPColor(player)
    
    for i, joint in pairs(joints) do
        local part1 = character:FindFirstChild(joint[1])
        local part2 = character:FindFirstChild(joint[2])
        
        if part1 and part2 and part1:IsA("BasePart") and part2:IsA("BasePart") then
            local pos1, onScreen1 = Workspace.CurrentCamera:WorldToViewportPoint(part1.Position)
            local pos2, onScreen2 = Workspace.CurrentCamera:WorldToViewportPoint(part2.Position)
            
            if onScreen1 and onScreen2 then
                local line = Drawing.new("Line")
                line.Visible = true
                line.Color = color
                line.Thickness = 1.5
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
                table.insert(objects.Skeleton, line)
            end
        end
    end
end

function Notify(title, desc, typ)
    pcall(function()
        Library:MakeNotify({Title = title, Content = desc, Duration = 3})
    end)
end

function GetHumanoid()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

function GetRootPart()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

function GetPlayerByName(name)
    name = name:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name then
            return p
        end
    end
    return nil
end

function GetAllPlayers()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    if #list == 0 then table.insert(list, "No Players") end
    return list
end

function CheckIfKiller(player)
    if not player then return false end
    local char = player.Character
    if not char then return false end
    
    if player:GetAttribute("Role") and string.lower(player:GetAttribute("Role")):find("killer") then
        return true
    end
    if player.Team and string.lower(player.Team.Name):find("killer") then
        return true
    end
    if char:FindFirstChild("Role") and char.Role:IsA("StringValue") and string.lower(char.Role.Value):find("killer") then
        return true
    end
    local killerParts = {"Knife", "Weapon", "Blade", "Sword"}
    for _, partName in pairs(killerParts) do
        if char:FindFirstChild(partName) then
            return true
        end
    end
    return false
end

function GetPlayerRole(player)
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
    if character:GetAttribute("Role") then
        local role = character:GetAttribute("Role")
        if type(role) == "string" then
            if role:lower():find("killer") then return "Killer" end
            if role:lower():find("survivor") or role:lower():find("survive") then return "Survivor" end
        end
    end
    local roleValue = character:FindFirstChild("Role")
    if roleValue and roleValue:IsA("StringValue") then
        local role = roleValue.Value:lower()
        if role:find("killer") then return "Killer" end
        if role:find("survivor") or role:find("survive") then return "Survivor" end
    end
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("killer") then return "Killer" end
        if teamName:find("survivor") or teamName:find("survive") then return "Survivor" end
    end
    return "Survivor"
end

function GetESPColor(player)
    local role = GetPlayerRole(player)
    if role == "Killer" then return Color3.fromRGB(255, 0, 0)
    elseif role == "Survivor" then return Color3.fromRGB(0, 255, 0)
    else return Color3.fromRGB(255, 255, 255) end
end

function IsGenerator(obj)
    if not obj then return false end
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return false end
    local name = obj.Name:lower()
    if name:find("player") or name:find("character") or name:find("npc") or name:find("killer") or name:find("humanoid") then return false end
    if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then return false end
    
    local isGen = false
    if name:find("generator") or name:find("gen%d") or name:find("gen_%d") or name == "gen" then isGen = true end
    if name:find("fusebox") or name:find("powerbox") or name:find("lever") then isGen = true end
    return isGen
end

function IsGeneratorCompleted(gen)
    if gen:GetAttribute("Completed") == true or gen:GetAttribute("IsCompleted") == true or gen:GetAttribute("Finished") == true then return true end
    local progress = gen:GetAttribute("Progress")
    if progress and (progress >= 1 or progress >= 100) then return true end
    return false
end

function GetGeneratorProgress(gen)
    local progress = gen:GetAttribute("Progress")
    if progress then return progress <= 1 and progress * 100 or progress end
    for _, child in pairs(gen:GetChildren()) do
        if child.Name:lower():find("progress") and (child:IsA("NumberValue") or child:IsA("IntValue")) then
            return child.Value <= 1 and child.Value * 100 or child.Value
        end
    end
    return 0
end

function CreateESPForPlayer(player)
    if player == LocalPlayer or not player.Character then return end
    
    if not ESP_Highlights[player] then
        local highlight = Instance.new("Highlight")
        highlight.Name = "MDW_Highlight"
        highlight.Adornee = player.Character
        highlight.FillColor = GetESPColor(player)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.Parent = player.Character
        ESP_Highlights[player] = highlight
    end
end

function RemoveESPForPlayer(player)
    if ESP_Highlights[player] then
        pcall(function() ESP_Highlights[player]:Destroy() end)
        ESP_Highlights[player] = nil
    end
    if player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("HealthBarGui") then
        pcall(function() player.Character.Head.HealthBarGui:Destroy() end)
    end
end

function FindAllGenerators()
    local generators = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if IsGenerator(obj) then table.insert(generators, obj) end
    end
    return generators
end

function ToggleWallHack(enabled)
    _G.WallHack = enabled
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Material ~= Enum.Material.Neon then
            if enabled then
                if not obj:GetAttribute("OriginalTransparency") then
                    obj:SetAttribute("OriginalTransparency", obj.Transparency)
                end
                if obj.Transparency < 0.7 then
                    obj.Transparency = 0.3
                end
            else
                local orig = obj:GetAttribute("OriginalTransparency")
                if orig then
                    obj.Transparency = orig
                end
            end
        end
    end
end

-- ==========================================
-- ADMIN KICK & FREEZE FUNCTIONS
-- ==========================================

function KickAdmin(player)
    if not player or not player.Character then return false end
    
    local success = false
    
    pcall(function()
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(0, -1000, 0)
            success = true
        end
    end)
    
    pcall(function()
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
            success = true
        end
    end)
    
    pcall(function()
        if player.Character then
            player.Character:Destroy()
            success = true
        end
    end)
    
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
        if remote then
            remote:FireServer("KickPlayer", player.Name)
            success = true
        end
    end)
    
    return success
end

function FreezeAdmin(player)
    if not player or not player.Character then return false end
    
    if FrozenPlayers[player] then
        pcall(function()
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.Anchored = false
            end
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
                hum.Sit = false
            end
        end)
        FrozenPlayers[player] = nil
        return true
    end
    
    local success = false
    pcall(function()
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.Anchored = true
            success = true
        end
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = true
            hum.Sit = true
        end
    end)
    
    if success then
        FrozenPlayers[player] = true
        
        pcall(function()
            local char = player.Character
            if char then
                local hl = Instance.new("Highlight")
                hl.Name = "FrozenHighlight"
                hl.Adornee = char
                hl.FillColor = Color3.fromRGB(0, 150, 255)
                hl.FillTransparency = 0.3
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.Parent = char
                
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        local ice = part:Clone()
                        ice.Name = "IceEffect"
                        ice.Parent = char
                        ice.CFrame = part.CFrame
                        ice.CanCollide = false
                        ice.Material = Enum.Material.Ice
                        ice.Transparency = 0.4
                        ice.Color = Color3.fromRGB(0, 200, 255)
                        
                        local weld = Instance.new("Weld")
                        weld.Part0 = part
                        weld.Part1 = ice
                        weld.C0 = part.CFrame:Inverse()
                        weld.C1 = ice.CFrame:Inverse()
                        weld.Parent = ice
                    end
                end
            end
        end)
    end
    
    return success
end

function DetectAdmins()
    AdminList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local isAdmin = false
            
            pcall(function()
                if player:GetRankInGroup(0) > 0 then
                    isAdmin = true
                end
            end)
            
            pcall(function()
                if player:GetAttribute("Admin") == true or player:GetAttribute("Staff") == true then
                    isAdmin = true
                end
            end)
            
            pcall(function()
                if player:FindFirstChild("AdminTag") or player:FindFirstChild("StaffTag") then
                    isAdmin = true
                end
            end)
            
            local displayName = player.DisplayName:lower()
            if displayName:find("admin") or displayName:find("staff") or displayName:find("mod") or displayName:find("owner") then
                isAdmin = true
            end
            
            pcall(function()
                if player.Character then
                    for _, tool in pairs(player.Character:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name:lower():find("admin") or tool.Name:lower():find("staff") or tool.Name:lower():find("kick") or tool.Name:lower():find("ban")) then
                            isAdmin = true
                        end
                    end
                end
            end)
            
            if isAdmin then
                table.insert(AdminList, player.Name)
            end
        end
    end
    return AdminList
end

-- ==========================================
-- MARKETPLACE SKINS - COWOK & CEWEK
-- ==========================================

local CharacterSkins = {
    -- ===== COWOK (Male Skins) =====
    {
        Name = "👤 Ganteng",
        Gender = "Cowok",
        Color = Color3.fromRGB(255, 200, 150),
        Material = Enum.Material.SmoothPlastic,
        Effect = "Glow",
        Price = 0,
        Description = "Tampan dengan aura bersinar"
    },
    {
        Name = "⚫ Shadow Ninja",
        Gender = "Cowok",
        Color = Color3.fromRGB(20, 20, 30),
        Material = Enum.Material.SmoothPlastic,
        Effect = "Shadow",
        Price = 0,
        Description = "Ninja bayangan yang misterius"
    },
    {
        Name = "🔥 Fire Knight",
        Gender = "Cowok",
        Color = Color3.fromRGB(255, 50, 0),
        Material = Enum.Material.Neon,
        Effect = "Fire",
        Price = 0,
        Description = "Ksatria api yang perkasa"
    },
    {
        Name = "💀 Dark Reaper",
        Gender = "Cowok",
        Color = Color3.fromRGB(40, 0, 40),
        Material = Enum.Material.SmoothPlastic,
        Effect = "Shadow",
        Price = 0,
        Description = "Pembawa maut dari kegelapan"
    },
    {
        Name = "🦸 Super Hero",
        Gender = "Cowok",
        Color = Color3.fromRGB(0, 100, 255),
        Material = Enum.Material.Neon,
        Effect = "Aura",
        Price = 0,
        Description = "Pahlawan super dengan kekuatan besar"
    },
    {
        Name = "⚔️ Samurai",
        Gender = "Cowok",
        Color = Color3.fromRGB(200, 100, 50),
        Material = Enum.Material.SmoothPlastic,
        Effect = "Glow",
        Price = 0,
        Description = "Pendekar samurai yang tangguh"
    },
    {
        Name = "🧙 Wizard",
        Gender = "Cowok",
        Color = Color3.fromRGB(150, 0, 255),
        Material = Enum.Material.Neon,
        Effect = "Stars",
        Price = 0,
        Description = "Penyihir dengan sihir kuno"
    },
    {
        Name = "🏀 Athlete",
        Gender = "Cowok",
        Color = Color3.fromRGB(255, 150, 0),
        Material = Enum.Material.SmoothPlastic,
        Effect = "None",
        Price = 0,
        Description = "Atlet dengan kecepatan luar biasa"
    },
    {
        Name = "🐉 Dragon Warrior",
        Gender = "Cowok",
        Color = Color3.fromRGB(200, 0, 0),
        Material = Enum.Material.Neon,
        Effect = "Fire",
        Price = 0,
        Description = "Prajurit naga dari legenda"
    },
    {
        Name = "🌙 Moonlight",
        Gender = "Cowok",
        Color = Color3.fromRGB(200, 200, 255),
        Material = Enum.Material.Neon,
        Effect = "Sparkle",
        Price = 0,
        Description = "Bersinar di bawah sinar bulan"
    },
    
    -- ===== CEWEK (Female Skins) =====
    {
        Name = "👸 Putri Cantik",
        Gender = "Cewek",
        Color = Color3.fromRGB(255, 150, 200),
        Material = Enum.Material.Neon,
        Effect = "Petal",
        Price = 0,
        Description = "Putri dengan pesona memikat"
    },
    {
        Name = "🌸 Sakura Princess",
        Gender = "Cewek",
        Color = Color3.fromRGB(255, 180, 220),
        Material = Enum.Material.SmoothPlastic,
        Effect = "Petal",
        Price = 0,
        Description = "Putri bunga sakura yang anggun"
    },
    {
        Name = "❄️ Ice Queen",
        Gender = "Cewek",
        Color = Color3.fromRGB(100, 200, 255),
        Material = Enum.Material.Glass,
        Effect = "Snow",
        Price = 0,
        Description = "Ratu es yang dingin dan anggun"
    },
    {
        Name = "🌹 Rose Beauty",
        Gender = "Cewek",
        Color = Color3.fromRGB(255, 50, 100),
        Material = Enum.Material.Neon,
        Effect = "Petal",
        Price = 0,
        Description = "Kecantikan seperti bunga mawar"
    },
    {
        Name = "✨ Fairy",
        Gender = "Cewek",
        Color = Color3.fromRGB(200, 150, 255),
        Material = Enum.Material.Neon,
        Effect = "Sparkle",
        Price = 0,
        Description = "Peri dengan sayap berkilauan"
    },
    {
        Name = "🌌 Galaxy Girl",
        Gender = "Cewek",
        Color = Color3.fromRGB(150, 0, 255),
        Material = Enum.Material.Neon,
        Effect = "Stars",
        Price = 0,
        Description = "Gadis dari galaksi lain"
    },
    {
        Name = "🦋 Butterfly",
        Gender = "Cewek",
        Color = Color3.fromRGB(255, 100, 200),
        Material = Enum.Material.Neon,
        Effect = "Petal",
        Price = 0,
        Description = "Kupu-kupu dengan warna-warni"
    },
    {
        Name = "💎 Diamond Girl",
        Gender = "Cewek",
        Color = Color3.fromRGB(200, 230, 255),
        Material = Enum.Material.DiamondPlate,
        Effect = "Sparkle",
        Price = 0,
        Description = "Berkilau seperti berlian"
    },
    {
        Name = "🌊 Mermaid",
        Gender = "Cewek",
        Color = Color3.fromRGB(0, 200, 200),
        Material = Enum.Material.Neon,
        Effect = "Sparkle",
        Price = 0,
        Description = "Putri duyung dari lautan"
    },
    {
        Name = "💖 Pink Angel",
        Gender = "Cewek",
        Color = Color3.fromRGB(255, 100, 180),
        Material = Enum.Material.Neon,
        Effect = "Aura",
        Price = 0,
        Description = "Malaikat dengan aura kasih sayang"
    },
}

-- ==========================================
-- PREMIUM SKIN SYSTEM
-- ==========================================

function CreatePremiumSkin(character)
    if not character then return end
    
    CleanupSkin()
    
    if not ActiveSkin or ActiveSkin.Name == "❌ No Skin" then
        IsSkinActive = false
        return
    end
    
    IsSkinActive = true
    local skinFolder = Instance.new("Folder")
    skinFolder.Name = "MDW_Skin"
    skinFolder.Parent = character
    
    local skinData = Instance.new("StringValue")
    skinData.Name = "SkinData"
    skinData.Value = HttpService:JSONEncode({
        Name = ActiveSkin.Name,
        Color = ActiveSkin.Color,
        Gender = ActiveSkin.Gender or "Unisex",
        Effect = ActiveSkin.Effect
    })
    skinData.Parent = skinFolder
    
    local parts = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "HumanoidRootPart"}
    
    for _, partName in pairs(parts) do
        local original = character:FindFirstChild(partName)
        if original and original:IsA("BasePart") then
            local skinPart = original:Clone()
            skinPart.Name = "Skin_" .. partName
            skinPart.Parent = skinFolder
            skinPart.CFrame = original.CFrame
            skinPart.CanCollide = false
            skinPart.Material = ActiveSkin.Material or Enum.Material.Neon
            skinPart.Color = ActiveSkin.Color
            skinPart.Transparency = 0.2
            
            local glow = Instance.new("ParticleEmitter")
            glow.Name = "GlowEffect"
            glow.Parent = skinPart
            glow.Texture = "rbxassetid://268857015"
            glow.SpreadAngle = Vector2.new(180, 180)
            glow.Speed = NumberRange.new(0)
            glow.Rate = 10
            glow.Color = ColorSequence.new(ActiveSkin.Color)
            glow.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.5),
                NumberSequenceKeypoint.new(1, 1)
            })
            glow.Lifetime = NumberRange.new(1, 3)
            glow.Size = NumberSequence.new(2)
            
            if ActiveSkin.Effect == "Fire" then
                glow.Texture = "rbxassetid://268857015"
                glow.Rate = 20
                glow.SpreadAngle = Vector2.new(360, 360)
                glow.Speed = NumberRange.new(1, 3)
                glow.Size = NumberSequence.new(3)
            elseif ActiveSkin.Effect == "Snow" then
                glow.Texture = "rbxassetid://268857015"
                glow.Rate = 15
                glow.SpreadAngle = Vector2.new(180, 180)
                glow.Speed = NumberRange.new(0.5, 1)
                glow.Size = NumberSequence.new(1)
            elseif ActiveSkin.Effect == "Sparkle" then
                glow.Texture = "rbxassetid://268857015"
                glow.Rate = 25
                glow.SpreadAngle = Vector2.new(360, 360)
                glow.Speed = NumberRange.new(0)
                glow.Size = NumberSequence.new(1)
            elseif ActiveSkin.Effect == "Stars" then
                glow.Texture = "rbxassetid://268857015"
                glow.Rate = 30
                glow.SpreadAngle = Vector2.new(360, 360)
                glow.Speed = NumberRange.new(0)
                glow.Size = NumberSequence.new(0.5)
            elseif ActiveSkin.Effect == "Rainbow" then
                glow.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255))
                })
                glow.Rate = 20
            elseif ActiveSkin.Effect == "Shadow" then
                glow.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.9),
                    NumberSequenceKeypoint.new(1, 1)
                })
                glow.Rate = 5
                glow.Size = NumberSequence.new(5)
            elseif ActiveSkin.Effect == "Petal" then
                glow.Texture = "rbxassetid://268857015"
                glow.Rate = 15
                glow.SpreadAngle = Vector2.new(180, 180)
                glow.Speed = NumberRange.new(0.5, 2)
                glow.Size = NumberSequence.new(1.5)
            elseif ActiveSkin.Effect == "Aura" then
                glow.Texture = "rbxassetid://268857015"
                glow.Rate = 30
                glow.SpreadAngle = Vector2.new(360, 360)
                glow.Speed = NumberRange.new(0)
                glow.Size = NumberSequence.new(4)
            end
            
            local weld = Instance.new("Weld")
            weld.Name = "SkinWeld"
            weld.Part0 = original
            weld.Part1 = skinPart
            weld.C0 = original.CFrame:Inverse()
            weld.C1 = skinPart.CFrame:Inverse()
            weld.Parent = skinPart
            
            table.insert(SkinParts, skinPart)
        end
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local trail = Instance.new("Trail")
        trail.Name = "SkinTrail"
        trail.Parent = rootPart
        trail.Color = ColorSequence.new(ActiveSkin.Color)
        trail.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(1, 1)
        })
        trail.Lifetime = 0.5
        trail.MinLength = 1
        trail.MaxLength = 5
        trail.Enabled = true
        table.insert(SkinParts, trail)
    end
    
    if _G.SkinPreview then
        SyncSkinToAll(character)
    end
end

function SyncSkinToAll(character)
    if not ActiveSkin then return end
    
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
        if remote then
            remote:FireServer("SyncSkin", {
                Player = LocalPlayer.Name,
                Color = ActiveSkin.Color,
                Name = ActiveSkin.Name,
                Gender = ActiveSkin.Gender or "Unisex",
                Effect = ActiveSkin.Effect
            })
        end
    end)
end

function CleanupSkin()
    for _, part in pairs(SkinParts) do
        pcall(function() part:Destroy() end)
    end
    SkinParts = {}
    
    local char = LocalPlayer.Character
    if char then
        if char:FindFirstChild("MDW_Skin") then
            pcall(function() char.MDW_Skin:Destroy() end)
        end
        for _, obj in pairs(char:GetChildren()) do
            if obj.Name:find("Skin_") or obj.Name == "IceEffect" or obj.Name == "FrozenHighlight" then
                pcall(function() obj:Destroy() end)
            end
        end
    end
    IsSkinActive = false
end

-- ==========================================
-- GET PLAYER LIST
-- ==========================================
local function GetPlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then 
            table.insert(list, p.Name) 
        end
    end
    if #list == 0 then 
        return {"Tidak ada pemain"} 
    end
    table.sort(list)
    return list
end

-- ==========================================
-- THEME FUNCTIONS
-- ==========================================
local ThemeMap = {
    Dark = {
        Mode = "Dark",
        Accent = Color3.fromRGB(125, 73, 255),
        Background = {Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(23,23,34)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,15))
        }},
        Text = {Title = Color3.fromRGB(255,255,255), Description = Color3.fromRGB(190,190,210)}
    },
    Light = {
        Mode = "Light",
        Accent = Color3.fromRGB(113, 182, 232),
        Background = {Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(239,237,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
        }},
        Text = {Title = Color3.fromRGB(0,0,0), Description = Color3.fromRGB(110,110,110)}
    },
    Midnight = {
        Mode = "Dark",
        Accent = Color3.fromRGB(120, 160, 255),
        Background = {Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(5,8,15)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,5))
        }},
        Text = {Title = Color3.fromRGB(240,245,255), Description = Color3.fromRGB(160,180,220)}
    },
    Rose = {
        Mode = "Dark",
        Accent = Color3.fromRGB(255, 85, 140),
        Background = {Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20,14,16)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(14,8,10))
        }},
        Text = {Title = Color3.fromRGB(255,255,255), Description = Color3.fromRGB(205,185,195)}
    },
    Emerald = {
        Mode = "Dark",
        Accent = Color3.fromRGB(80, 230, 160),
        Background = {Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(14,20,16)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8,14,10))
        }},
        Text = {Title = Color3.fromRGB(255,255,255), Description = Color3.fromRGB(185,205,195)}
    }
}

function ApplyTheme(themeName)
    local theme = ThemeMap[themeName]
    if not theme then return end
    
    _G.ActiveTheme = themeName
    
    pcall(function()
        if Window.SetTheme then
            Window:SetTheme(theme)
        end
        Library:MakeNotify({ Title = "Theme", Content = "Theme berubah ke: " .. themeName, Duration = 2 })
    end)
end

-- ==========================================
-- SCAN CHECKPOINTS
-- ==========================================
function ScanAllCheckpoints()
    local checkpoints = {}
    local seen = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then
            local name = obj.Name:lower()
            local pos = obj.Position
            
            if not name:find("humanoid") and not name:find("player") and 
               not name:find("character") and not name:find("npc") and
               not name:find("particle") and not name:find("effect") and
               not name:find("attachment") and not name:find("handle") then
                
                local found = false
                
                if name:find("cp") or name:find("checkpoint") or name:find("stage") or 
                   name:find("point") or name:find("start") or name:find("finish") or
                   name:find("level") or name:find("zone") or name:find("spawn") or 
                   name:find("respawn") or name:find("base") or name:find("platform") or
                   name:find("landing") or name:find("rest") or name:find("save") or
                   name:find("safe") or name:find("check") then
                    found = true
                end
                
                if obj:GetAttribute("Checkpoint") or obj:GetAttribute("CP") or 
                   obj:GetAttribute("Stage") or obj:GetAttribute("Point") or
                   obj:GetAttribute("Level") then
                    found = true
                end
                
                if obj:IsA("SpawnLocation") then
                    found = true
                end
                
                if obj:IsA("BasePart") and obj.Size.X > 5 and obj.Size.Z > 5 then
                    if name:find("plate") or name:find("floor") or name:find("ground") then
                        found = true
                    end
                end
                
                if found and pos.Y > -50 then
                    local key = math.floor(pos.X) .. "_" .. math.floor(pos.Y) .. "_" .. math.floor(pos.Z)
                    if not seen[key] then
                        seen[key] = true
                        table.insert(checkpoints, {
                            Part = obj,
                            Y = pos.Y,
                            Name = obj.Name,
                            Position = pos,
                            Key = key
                        })
                    end
                end
            end
        end
    end
    
    local unique = {}
    for _, cp in pairs(checkpoints) do
        local found = false
        for _, u in pairs(unique) do
            if math.abs(u.Y - cp.Y) < 2 then
                found = true
                break
            end
        end
        if not found then
            table.insert(unique, cp)
        end
    end
    
    table.sort(unique, function(a, b)
        return a.Y < b.Y
    end)
    
    return unique
end

-- ==========================================
-- FLY FUNCTIONS
-- ==========================================
local function CleanupFly(root)
    if root then
        if root:FindFirstChild("FlyVel") then root.FlyVel:Destroy() end
        if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
    end
end

local function StartFly()
    if not _G.Fly then return end
    
    local root = GetRootPart()
    local hum = GetHumanoid()
    if not root or not hum then return end

    CleanupFly(root)

    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.Name = "FlyVel"
    bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVel.Velocity = Vector3.new(0, 0, 0)
    bodyVel.Parent = root

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "FlyGyro"
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 9e4
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    hum.PlatformStand = true 

    _G.FlyCon = RunService.RenderStepped:Connect(function()
        if _G.Fly and root and root.Parent and hum then
            local cam = workspace.CurrentCamera
            local speed = Config.FlySpeed or 100
            local moveVec = Vector3.new(0,0,0)
            
            local forward = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            
            forward = Vector3.new(forward.X, 0, forward.Z).Unit
            right = Vector3.new(right.X, 0, right.Z).Unit
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + forward end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - forward end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - right end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + right end
            
            if moveVec.Magnitude == 0 and hum.MoveDirection.Magnitude > 0 then
                local joyDir = hum.MoveDirection
                moveVec = (forward * -joyDir.Z) + (right * joyDir.X)
            end
            
            local yVel = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or hum.Jump then
                yVel = speed
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                yVel = -speed
            end

            local finalVel = (moveVec.Unit * speed)
            if moveVec.Magnitude == 0 then
                bodyVel.Velocity = Vector3.new(0, yVel, 0)
            else
                bodyVel.Velocity = finalVel + Vector3.new(0, yVel, 0)
            end
            
            bodyGyro.CFrame = cam.CFrame
        else
            if _G.FlyCon then _G.FlyCon:Disconnect() end
            if hum then hum.PlatformStand = false end
        end
    end)
end

-- ==========================================
-- WINDOW CREATION - DIPERBAIKI
-- ==========================================
local Window
local success, result = pcall(function()
    Window = Library:Window({
        Title = "FCAL HUB",
        Footer = "v2.3.1 | Ultimate Edition FIXED"
    })
    return Window
end)

if not success or not Window then
    print("Gagal membuat window, mencoba alternatif...")
    Window = {
        AddTab = function() 
            return {
                AddSection = function() 
                    return {
                        AddButton = function() end,
                        AddToggle = function() end,
                        AddDropdown = function() end,
                        AddInput = function() end,
                        AddSlider = function() end
                    }
                end
            }
        end
    }
end

-- ==========================================
-- TABS SETUP
-- ==========================================
local MainTab, PlayerTab, GameTab, ServerTab, SettingsTab, SkinTab, UniversalTab, AdminTab

pcall(function()
    MainTab = Window:AddTab({ Name = "Main", Icon = "home" })
    PlayerTab = Window:AddTab({ Name = "Player", Icon = "user" })
    GameTab = Window:AddTab({ Name = "Game", Icon = "gamepad" })
    ServerTab = Window:AddTab({ Name = "Server", Icon = "web" })
    SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings" })
    SkinTab = Window:AddTab({ Name = "Skins", Icon = "palette" })
    UniversalTab = Window:AddTab({ Name = "Universal", Icon = "globe" })
    AdminTab = Window:AddTab({ Name = "Admin", Icon = "shield" })
end)

-- ==========================================
-- MAIN TAB - QUICK ACTIONS
-- ==========================================
if MainTab then
    pcall(function()
        local QuickSection = MainTab:AddSection("⚡ Quick Actions")
        
        QuickSection:AddButton({
            Title = "Get Gravity Gun",
            Description = "Tool untuk menarik dan membawa objek di map",
            Callback = function()
                if _G.GravityGunActive then
                    Library:MakeNotify({ Title = "Info", Content = "Gravity Gun sudah aktif!", Duration = 2 })
                    return
                end
                
                local tool = Instance.new("Tool")
                tool.RequiresHandle = true
                tool.Name = "⚡ Gravity Gun"
                tool.Parent = LocalPlayer.Backpack
                
                local handle = Instance.new("Part")
                handle.Name = "Handle"
                handle.Size = Vector3.new(1, 1, 3)
                handle.BrickColor = BrickColor.new("Bright blue")
                handle.Material = Enum.Material.Neon
                handle.Transparency = 0.3
                handle.Parent = tool
                
                local handleWeld = Instance.new("Weld")
                handleWeld.Part0 = handle
                
                local mouse = LocalPlayer:GetMouse()
                local target = nil
                local connection = nil
                local isEquipped = false
                
                local function onActivated()
                    if mouse.Target and not mouse.Target.Anchored and mouse.Target:IsA("BasePart") and mouse.Target ~= handle then
                        target = mouse.Target
                        
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(0, 200, 255)
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.new(1, 1, 1)
                        hl.Adornee = target
                        hl.Parent = target
                        table.insert(ManualHighlights, hl)
                        
                        if connection then connection:Disconnect() end
                        
                        connection = RunService.RenderStepped:Connect(function()
                            if target and tool.Parent == LocalPlayer.Character and isEquipped and target.Parent then
                                local rightArm = LocalPlayer.Character:FindFirstChild("RightArm")
                                local holdPos = rightArm and rightArm.CFrame * CFrame.new(0, 0, -5) or 
                                               LocalPlayer.Character.Head.CFrame * CFrame.new(0, 0, -10)
                                local direction = (holdPos.p - target.Position)
                                
                                target.AssemblyLinearVelocity = direction * 12
                                target.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            else
                                if connection then connection:Disconnect() end
                                target = nil
                            end
                        end)
                    end
                end
                
                local function onDeactivated()
                    if connection then connection:Disconnect() end
                    target = nil
                    for _, hl in pairs(ManualHighlights) do
                        pcall(function() hl:Destroy() end)
                    end
                    ManualHighlights = {}
                end
                
                tool.Activated:Connect(onActivated)
                tool.Deactivated:Connect(onDeactivated)
                tool.Unequipped:Connect(function()
                    isEquipped = false
                    onDeactivated()
                    if handleWeld.Part1 then
                        handleWeld.Part1 = nil
                    end
                end)
                
                tool.Equipped:Connect(function()
                    isEquipped = true
                    local rightArm = LocalPlayer.Character:FindFirstChild("RightArm")
                    if rightArm then
                        handleWeld.Part1 = rightArm
                        handleWeld.C0 = CFrame.new(0, 0, 0)
                        handleWeld.C1 = CFrame.new(0, 0, 0)
                        handleWeld.Parent = handle
                    end
                    Library:MakeNotify({ Title = "Gravity Gun", Content = "Klik objek untuk menarik!", Duration = 2 })
                end)
                
                _G.GravityGunActive = true
                
                task.wait(0.5)
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:EquipTool(tool)
                end
                
                Library:MakeNotify({ Title = "Success", Content = "Gravity Gun telah ditambahkan dan dipakai!" })
            end
        })

        QuickSection:AddButton({
            Title = "Reset Character",
            Callback = function() 
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.Health = 0
                else
                    LocalPlayer:LoadCharacter() 
                end
                _G.GravityGunActive = false
                Library:MakeNotify({ Title = "Success", Content = "Character reset!" })
            end
        })
    end)
end

-- ==========================================
-- PLAYER TAB
-- ==========================================
if PlayerTab then
    pcall(function()
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
            Callback = function(v) Workspace.Gravity = tonumber(v) or 196 end
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

        -- Fly Section
        local FlySection = PlayerTab:AddSection("🪁 Fly Settings")
        
        FlySection:AddInput({ 
            Title = "Fly Speed", 
            Default = 100, 
            Callback = function(v) Config.FlySpeed = tonumber(v) or 100 end 
        })

        FlySection:AddToggle({
            Title = "Fly Mode",
            Default = false,
            Callback = function(v)
                _G.Fly = v
                if v then
                    StartFly()
                    Library:MakeNotify({ Title = "Enabled", Content = "Fly Aktif!" })
                else
                    if _G.FlyCon then _G.FlyCon:Disconnect() end
                    CleanupFly(GetRootPart())
                    local hum = GetHumanoid()
                    if hum then hum.PlatformStand = false end
                    Library:MakeNotify({ Title = "Disabled", Content = "Fly Mati" })
                end
            end
        })

        -- Protection Section
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
    end)
end

-- ==========================================
-- GAME TAB - AUTO CP
-- ==========================================
if GameTab then
    pcall(function()
        local FarmSection = GameTab:AddSection("⛰️ Auto CP All Mountain")
        
        FarmSection:AddButton({
            Title = "🧹 Hapus Kotak Merah/Putih",
            Description = "Bersihkan highlight dan efek visual",
            Callback = function()
                ClearManualHighlights()
                Library:MakeNotify({ 
                    Title = "🧹 Bersih!", 
                    Content = "Semua highlight dan efek telah dihapus!", 
                    Duration = 3 
                })
            end
        })

        FarmSection:AddToggle({
            Title = "Auto CP All Mountain (Fix)",
            Description = "Teleport otomatis ke semua checkpoint (URUT)",
            Default = false,
            Callback = function(v)
                _G.AutoCPAll = v
                
                if v then
                    task.spawn(function()
                        local cps = ScanAllCheckpoints()
                        
                        if #cps == 0 then
                            Library:MakeNotify({ 
                                Title = "⚠️ Error", 
                                Content = "Tidak ada checkpoint ditemukan!", 
                                Duration = 5 
                            })
                            _G.AutoCPAll = false
                            return
                        end
                        
                        Library:MakeNotify({ 
                            Title = "🚀 Auto CP", 
                            Content = "Ditemukan " .. #cps .. " checkpoint! Memulai...", 
                            Duration = 3 
                        })
                        
                        local char = LocalPlayer.Character
                        if not char then
                            Library:MakeNotify({ 
                                Title = "⚠️ Error", 
                                Content = "Karakter tidak ditemukan!", 
                                Duration = 3 
                            })
                            _G.AutoCPAll = false
                            return
                        end
                        
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if not root then
                            Library:MakeNotify({ 
                                Title = "⚠️ Error", 
                                Content = "RootPart tidak ditemukan!", 
                                Duration = 3 
                            })
                            _G.AutoCPAll = false
                            return
                        end
                        
                        local currentIndex = 0
                        
                        for i, cp in ipairs(cps) do
                            if not _G.AutoCPAll then 
                                Library:MakeNotify({ 
                                    Title = "⏹️ Berhenti", 
                                    Content = "Auto CP dimatikan manual", 
                                    Duration = 2 
                                })
                                break 
                            end
                            
                            char = LocalPlayer.Character
                            if not char then
                                Library:MakeNotify({ 
                                    Title = "💀 Mati", 
                                    Content = "Karakter mati, berhenti...", 
                                    Duration = 3 
                                })
                                break
                            end
                            
                            root = char:FindFirstChild("HumanoidRootPart")
                            if not root then
                                Library:MakeNotify({ 
                                    Title = "⚠️ Error", 
                                    Content = "RootPart hilang!", 
                                    Duration = 3 
                                })
                                break
                            end
                            
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health <= 0 then
                                Library:MakeNotify({ 
                                    Title = "💀 Mati", 
                                    Content = "Karakter mati, berhenti...", 
                                    Duration = 3 
                                })
                                break
                            end
                            
                            local targetCF = cp.Part.CFrame * CFrame.new(0, 5, 0)
                            root.CFrame = targetCF
                            
                            pcall(function()
                                if firetouchinterest then
                                    firetouchinterest(root, cp.Part, 0)
                                    task.wait(0.1)
                                    firetouchinterest(root, cp.Part, 1)
                                end
                            end)
                            
                            currentIndex = i
                            
                            Library:MakeNotify({ 
                                Title = "📍 CP " .. i .. "/" .. #cps, 
                                Content = cp.Name .. " (Y: " .. math.floor(cp.Y) .. ")", 
                                Duration = 1.5 
                            })
                            
                            task.wait(_G.CPTeleportDelay or 0.8)
                        end
                        
                        if _G.AutoCPAll then
                            Library:MakeNotify({ 
                                Title = "✅ Selesai!", 
                                Content = "Berhasil melewati " .. currentIndex .. " checkpoint!", 
                                Duration = 5 
                            })
                        end
                        
                        _G.AutoCPAll = false
                    end)
                end
            end
        })

        FarmSection:AddInput({
            Title = "Delay Antar CP (detik)",
            Description = "Jeda antara teleport ke checkpoint berikutnya",
            Default = "0.8",
            Callback = function(v)
                _G.CPTeleportDelay = tonumber(v) or 0.8
            end
        })

        FarmSection:AddButton({
            Title = "🔍 Scan Checkpoint Sekarang",
            Callback = function()
                ClearManualHighlights()
                local cps = ScanAllCheckpoints()
                
                if #cps == 0 then
                    Library:MakeNotify({ 
                        Title = "❌ Tidak Ada", 
                        Content = "Tidak ada checkpoint ditemukan!", 
                        Duration = 3 
                    })
                    return
                end
                
                for _, cp in pairs(cps) do
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(0, 150, 255)
                    hl.FillTransparency = 0.6
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.Adornee = cp.Part
                    hl.Parent = cp.Part
                end
                
                local msg = "Ditemukan " .. #cps .. " checkpoint:\n"
                for i, cp in ipairs(cps) do
                    if i <= 15 then
                        msg = msg .. i .. ". " .. cp.Name .. " (Y: " .. math.floor(cp.Y) .. ")\n"
                    end
                end
                if #cps > 15 then
                    msg = msg .. "... dan " .. (#cps - 15) .. " lainnya"
                end
                
                Library:MakeNotify({ 
                    Title = "📊 Hasil Scan", 
                    Content = msg, 
                    Duration = 10 
                })
            end
        })

        -- Visual ESP Section
        local VisualSection = GameTab:AddSection("👁️ Visual ESP & Tracking")
        
        VisualSection:AddToggle({ 
            Title = "ESP Box (2D)", 
            Default = false, 
            Callback = function(v) 
                _G.BoxESP = v
                Library:MakeNotify({ Title = "ESP Box", Content = v and "Aktif!" or "Mati!" })
            end 
        })

        VisualSection:AddToggle({ 
            Title = "ESP Tracers (Line)", 
            Default = false, 
            Callback = function(v) 
                _G.LineESP = v
                Library:MakeNotify({ Title = "ESP Tracers", Content = v and "Aktif!" or "Mati!" })
            end 
        })

        VisualSection:AddToggle({ 
            Title = "ESP Skeleton (Bone)", 
            Default = false, 
            Callback = function(v) 
                _G.SkeletonESP = v
                Library:MakeNotify({ Title = "ESP Skeleton", Content = v and "Aktif!" or "Mati!" })
            end 
        })

        VisualSection:AddToggle({
            Title = "ESP Players (Highlight)",
            Default = false,
            Callback = function(v)
                _G.ESP = v
                if v then
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then CreateESPForPlayer(p) end
                    end
                    
                    if not _G.PlayerAddedConn then
                        _G.PlayerAddedConn = Players.PlayerAdded:Connect(function(p)
                            p.CharacterAdded:Connect(function()
                                if _G.ESP then task.wait(0.5) CreateESPForPlayer(p) end
                            end)
                        end)
                    end
                    
                    Library:MakeNotify({ Title = "Enabled", Content = "ESP Highlight Aktif!" })
                else
                    if _G.PlayerAddedConn then 
                        _G.PlayerAddedConn:Disconnect() 
                        _G.PlayerAddedConn = nil 
                    end
                    for _, p in pairs(Players:GetPlayers()) do 
                        RemoveESPForPlayer(p) 
                    end
                    Library:MakeNotify({ Title = "Disabled", Content = "ESP Highlight Mati" })
                end
            end
        })

        VisualSection:AddToggle({
            Title = "Fullbright",
            Default = false,
            Callback = function(v)
                _G.Fullbright = v
                if v then
                    _G.OldBright = Lighting.Brightness
                    _G.OldTime = Lighting.ClockTime
                    _G.OldFog = Lighting.FogEnd
                    _G.OldShadows = Lighting.GlobalShadows
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 100000
                    Lighting.GlobalShadows = false
                else
                    Lighting.Brightness = _G.OldBright or 1
                    Lighting.ClockTime = _G.OldTime or 14
                    Lighting.FogEnd = _G.OldFog or 100000
                    Lighting.GlobalShadows = _G.OldShadows or true
                end
            end
        })

        VisualSection:AddToggle({
            Title = "WallHack (See Through Walls)",
            Description = "Melihat tembus dinding (Transparan)",
            Default = false,
            Callback = function(v)
                ToggleWallHack(v)
                Library:MakeNotify({ 
                    Title = v and "WallHack ON" or "WallHack OFF", 
                    Content = v and "Dinding menjadi transparan!" or "Dinding kembali normal" 
                })
            end
        })
    end)
end

-- ==========================================
-- UNIVERSAL TAB
-- ==========================================
if UniversalTab then
    pcall(function()
        local UniversalSection = UniversalTab:AddSection("🌐 Universal Features")
        
        UniversalSection:AddToggle({
            Title = "⚡ FPS Booster",
            Description = "Matikan efek visual untuk meningkatkan FPS",
            Default = false,
            Callback = function(v)
                if v then
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 1
                    pcall(function()
                        settings().Rendering.QualityLevel = 1
                    end)
                    
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ParticleEmitter") then
                            obj.Enabled = false
                        end
                        if obj:IsA("Trail") then
                            obj.Enabled = false
                        end
                        if obj:IsA("Fire") or obj:IsA("Smoke") then
                            obj.Enabled = false
                        end
                        if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") then
                            obj.Enabled = false
                        end
                    end
                    
                    Library:MakeNotify({ Title = "FPS Booster", Content = "ON - Efek dimatikan" })
                else
                    Lighting.GlobalShadows = true
                    Lighting.FogEnd = 100000
                    pcall(function()
                        settings().Rendering.QualityLevel = 2
                    end)
                    
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ParticleEmitter") then
                            obj.Enabled = true
                        end
                        if obj:IsA("Trail") then
                            obj.Enabled = true
                        end
                        if obj:IsA("Fire") or obj:IsA("Smoke") then
                            obj.Enabled = true
                        end
                        if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") then
                            obj.Enabled = true
                        end
                    end
                    
                    Library:MakeNotify({ Title = "FPS Booster", Content = "OFF - Efek kembali" })
                end
            end
        })

        UniversalSection:AddToggle({
            Title = "🔄 Anti AFK",
            Description = "Mencegah kick karena AFK",
            Default = false,
            Callback = function(v)
                _G.AntiAFK = v
                if v then
                    task.spawn(function()
                        while _G.AntiAFK do
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                                task.wait(0.01)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                                
                                local pos = UserInputService:GetMouseLocation()
                                VirtualInputManager:SendMouseMoveEvent(pos.X + 1, pos.Y + 1, game)
                            end)
                            task.wait(30)
                        end
                    end)
                    Library:MakeNotify({ Title = "Anti AFK", Content = "Aktif!" })
                else
                    Library:MakeNotify({ Title = "Anti AFK", Content = "Mati!" })
                end
            end
        })

        UniversalSection:AddToggle({
            Title = "🏃 Speed Hack",
            Description = "Meningkatkan kecepatan berjalan",
            Default = false,
            Callback = function(v)
                _G.SpeedHack = v
                if v then
                    local hum = GetHumanoid()
                    if hum then
                        hum.WalkSpeed = _G.SpeedValue
                    end
                    Library:MakeNotify({ Title = "Speed Hack", Content = "Kecepatan: " .. _G.SpeedValue })
                else
                    local hum = GetHumanoid()
                    if hum then
                        hum.WalkSpeed = 16
                    end
                    Library:MakeNotify({ Title = "Speed Hack", Content = "Mati!" })
                end
            end
        })

        UniversalSection:AddSlider({
            Title = "Speed Value",
            Description = "Atur kecepatan Speed Hack",
            Minimum = 16,
            Maximum = 300,
            Default = 50,
            Callback = function(v)
                _G.SpeedValue = v
                if _G.SpeedHack then
                    local hum = GetHumanoid()
                    if hum then
                        hum.WalkSpeed = v
                    end
                end
            end
        })

        UniversalSection:AddToggle({
            Title = "⬆️ Jump Hack",
            Description = "Meningkatkan kekuatan lompat",
            Default = false,
            Callback = function(v)
                _G.JumpHack = v
                if v then
                    local hum = GetHumanoid()
                    if hum then
                        hum.JumpPower = _G.JumpValue
                    end
                    Library:MakeNotify({ Title = "Jump Hack", Content = "Jump Power: " .. _G.JumpValue })
                else
                    local hum = GetHumanoid()
                    if hum then
                        hum.JumpPower = 50
                    end
                    Library:MakeNotify({ Title = "Jump Hack", Content = "Mati!" })
                end
            end
        })

        UniversalSection:AddSlider({
            Title = "Jump Value",
            Description = "Atur kekuatan Jump Hack",
            Minimum = 50,
            Maximum = 500,
            Default = 100,
            Callback = function(v)
                _G.JumpValue = v
                if _G.JumpHack then
                    local hum = GetHumanoid()
                    if hum then
                        hum.JumpPower = v
                    end
                end
            end
        })

        UniversalSection:AddButton({
            Title = "🔄 Rejoin Server",
            Description = "Bergabung ulang ke server yang sama",
            Callback = function()
                Library:MakeNotify({ Title = "Rejoin", Content = "Merejoin server..." })
                task.wait(1)
                pcall(function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
            end
        })

        UniversalSection:AddButton({
            Title = "📊 Server Info",
            Description = "Tampilkan informasi server",
            Callback = function()
                local players = Players:GetPlayers()
                local maxPlayers = Players.MaxPlayers
                local ping = game:GetService("Stats"):FindFirstChild("Network") and 
                            game:GetService("Stats").Network:FindFirstChild("ClientLatency") and 
                            game:GetService("Stats").Network.ClientLatency.Value or 0
                
                Library:MakeNotify({ 
                    Title = "📊 Server Info", 
                    Content = string.format(
                        "Players: %d/%d\nPing: %dms\nServer: %s\nTime: %s",
                        #players,
                        maxPlayers,
                        math.floor(ping * 1000),
                        game.JobId or "Unknown",
                        os.date("%H:%M:%S")
                    ),
                    Duration = 8
                })
            end
        })
    end)
end

-- ==========================================
-- SKIN TAB - MARKETPLACE SKINS
-- ==========================================
if SkinTab then
    pcall(function()
        local SkinSection = SkinTab:AddSection("👗 Marketplace Skins")

        -- Dropdown Gender
        local genderOptions = {"Semua", "Cowok", "Cewek"}
        local selectedGender = "Semua"

        SkinSection:AddDropdown({
            Title = "Filter Gender",
            Options = genderOptions,
            Default = "Semua",
            Callback = function(v)
                selectedGender = v
                local filtered = {}
                for _, skin in pairs(CharacterSkins) do
                    if selectedGender == "Semua" or skin.Gender == selectedGender then
                        table.insert(filtered, skin.Name)
                    end
                end
                if #filtered == 0 then
                    table.insert(filtered, "Tidak ada skin")
                end
                if SkinDropdown and SkinDropdown.SetValues then
                    SkinDropdown:SetValues(filtered)
                end
            end
        })

        -- Skin dropdown
        local skinOptions = {}
        for _, skin in pairs(CharacterSkins) do
            table.insert(skinOptions, skin.Name)
        end
        table.insert(skinOptions, 1, "❌ No Skin")

        local SkinDropdown = SkinSection:AddDropdown({
            Title = "Pilih Skin",
            Options = skinOptions,
            Default = "❌ No Skin",
            Callback = function(v)
                for _, skin in pairs(CharacterSkins) do
                    if skin.Name == v then
                        ActiveSkin = skin
                        _G.SkinName = skin.Name
                        _G.SkinColor = skin.Color
                        _G.SkinEffect = skin.Effect or "None"
                        
                        if skin.Name == "❌ No Skin" then
                            CleanupSkin()
                            Library:MakeNotify({ Title = "Skin", Content = "Skin dihapus!" })
                        else
                            CreatePremiumSkin(LocalPlayer.Character)
                            Library:MakeNotify({ 
                                Title = "👗 Skin", 
                                Content = skin.Name .. " (" .. skin.Gender .. ")\n" .. (skin.Description or ""),
                                Duration = 4
                            })
                        end
                        break
                    end
                end
            end
        })

        SkinSection:AddButton({
            Title = "ℹ️ Info Skin Aktif",
            Description = "Tampilkan informasi skin yang sedang dipakai",
            Callback = function()
                if ActiveSkin and ActiveSkin.Name ~= "❌ No Skin" then
                    Library:MakeNotify({ 
                        Title = "👗 Skin Aktif", 
                        Content = string.format(
                            "Nama: %s\nGender: %s\nEfek: %s",
                            ActiveSkin.Name,
                            ActiveSkin.Gender or "Unisex",
                            ActiveSkin.Effect or "None"
                        ),
                        Duration = 6
                    })
                else
                    Library:MakeNotify({ Title = "Info", Content = "Tidak ada skin aktif" })
                end
            end
        })

        SkinSection:AddButton({
            Title = "🎲 Random Skin",
            Description = "Pilih skin secara acak dari marketplace",
            Callback = function()
                local randomSkins = {}
                for _, skin in pairs(CharacterSkins) do
                    table.insert(randomSkins, skin)
                end
                local randomSkin = randomSkins[math.random(1, #randomSkins)]
                if randomSkin then
                    ActiveSkin = randomSkin
                    _G.SkinName = randomSkin.Name
                    _G.SkinColor = randomSkin.Color
                    _G.SkinEffect = randomSkin.Effect or "None"
                    CleanupSkin()
                    task.wait(0.1)
                    CreatePremiumSkin(LocalPlayer.Character)
                    Library:MakeNotify({ 
                        Title = "🎲 Random", 
                        Content = randomSkin.Name .. " (" .. randomSkin.Gender .. ") diterapkan!", 
                        Duration = 3
                    })
                end
            end
        })

        SkinSection:AddButton({
            Title = "🧹 Hapus Skin",
            Description = "Hapus skin yang sedang aktif",
            Callback = function()
                CleanupSkin()
                ActiveSkin = nil
                Library:MakeNotify({ Title = "🧹 Skin", Content = "Skin dihapus!" })
            end
        })
    end)
end

-- ==========================================
-- ADMIN TAB
-- ==========================================
if AdminTab then
    pcall(function()
        local AdminSection = AdminTab:AddSection("🛡️ Admin Tools")
        
        AdminSection:AddButton({
            Title = "🔍 Detect Admins",
            Description = "Cari admin/staff di server",
            Callback = function()
                local admins = DetectAdmins()
                if #admins > 0 then
                    Library:MakeNotify({ 
                        Title = "👮 Admin Ditemukan!", 
                        Content = "Admin: " .. table.concat(admins, ", "),
                        Duration = 8
                    })
                else
                    Library:MakeNotify({ 
                        Title = "🔍 Tidak Ada Admin", 
                        Content = "Tidak ada admin/staff terdeteksi",
                        Duration = 3
                    })
                end
            end
        })

        -- Admin Dropdown
        local AdminDropdown = AdminSection:AddDropdown({
            Title = "Target Admin",
            Description = "Pilih admin untuk di-action",
            Options = {"Tidak ada admin"},
            Default = "",
            Callback = function(v)
                SelectedTarget = v
            end
        })

        -- Update admin dropdown
        local function UpdateAdminDropdown()
            local admins = DetectAdmins()
            if #admins == 0 then
                AdminDropdown:SetValues({"Tidak ada admin"})
            else
                AdminDropdown:SetValues(admins)
            end
        end

        AdminSection:AddButton({
            Title = "👢 Kick Admin",
            Description = "Kick admin yang terpilih (Visual)",
            Callback = function()
                if SelectedTarget == "" or SelectedTarget == "Tidak ada admin" then
                    Library:MakeNotify({ Title = "Warning", Content = "Pilih admin dulu!" })
                    return
                end
                
                local target = Players:FindFirstChild(SelectedTarget)
                if target then
                    local success = KickAdmin(target)
                    if success then
                        Library:MakeNotify({ 
                            Title = "👢 KICK!", 
                            Content = "Admin " .. SelectedTarget .. " di-kick!", 
                            Duration = 3 
                        })
                    else
                        Library:MakeNotify({ 
                            Title = "❌ Gagal", 
                            Content = "Gagal meng-kick admin!", 
                            Duration = 3 
                        })
                    end
                else
                    Library:MakeNotify({ Title = "Error", Content = "Admin tidak ditemukan!" })
                end
            end
        })

        AdminSection:AddButton({
            Title = "❄️ Freeze/Unfreeze Admin",
            Description = "Bekukan admin yang terpilih",
            Callback = function()
                if SelectedTarget == "" or SelectedTarget == "Tidak ada admin" then
                    Library:MakeNotify({ Title = "Warning", Content = "Pilih admin dulu!" })
                    return
                end
                
                local target = Players:FindFirstChild(SelectedTarget)
                if target then
                    local isFrozen = FrozenPlayers[target] or false
                    local success = FreezeAdmin(target)
                    if success then
                        Library:MakeNotify({ 
                            Title = isFrozen and "❄️ UNFREEZE" or "❄️ FREEZE", 
                            Content = isFrozen and SelectedTarget .. " di-unfreeze!" or SelectedTarget .. " di-freeze!",
                            Duration = 3 
                        })
                    else
                        Library:MakeNotify({ 
                            Title = "❌ Gagal", 
                            Content = "Gagal mem-freeze admin!", 
                            Duration = 3 
                        })
                    end
                else
                    Library:MakeNotify({ Title = "Error", Content = "Admin tidak ditemukan!" })
                end
            end
        })

        AdminSection:AddButton({
            Title = "❄️ Freeze All Admins",
            Description = "Bekukan semua admin di server",
            Callback = function()
                local admins = DetectAdmins()
                local frozen = 0
                for _, name in pairs(admins) do
                    local target = Players:FindFirstChild(name)
                    if target and FreezeAdmin(target) then
                        frozen = frozen + 1
                    end
                end
                Library:MakeNotify({ 
                    Title = "❄️ Freeze All", 
                    Content = frozen .. " admin di-freeze!",
                    Duration = 3 
                })
            end
        })
    end)
end

-- ==========================================
-- SETTINGS TAB
-- ==========================================
if SettingsTab then
    pcall(function()
        local ThemeSection = SettingsTab:AddSection("🎨 Appearance")
        
        ThemeSection:AddDropdown({ 
            Title = "Select Theme", 
            Options = {"Dark", "Light", "Midnight", "Rose", "Emerald"}, 
            Default = "Midnight", 
            Callback = function(v) 
                ApplyTheme(v)
            end 
        })

        local ClearSection = SettingsTab:AddSection("🧹 Clear Effects")
        
        ClearSection:AddButton({
            Title = "Hapus Semua Efek Visual",
            Description = "Bersihkan part, highlight, dan efek lainnya",
            Callback = function()
                ClearManualHighlights()
                for _, o in pairs(workspace:GetDescendants()) do
                    if o:IsA("Highlight") then
                        pcall(function() o:Destroy() end)
                    end
                end
                
                local toRemove = {}
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj ~= workspace.Terrain then
                        if obj.Name:find("MDW") or obj.Name:find("Cage") or obj.Name:find("Troll") or 
                           obj.Name:find("Wall") or obj.Name:find("Ice") or obj.Name:find("Trap") or
                           obj.Name:find("Clone") or obj.Name:find("Smoke") or obj.Name:find("Rockslide") or
                           obj.Name:find("AntiVoidPlatform") or obj.Name:find("MDW_SolidAirFloor") or
                           obj.Name:find("GodLight") or obj.Name:find("Spawned_Monster") or
                           obj.Name:find("MDW_Skin") or obj.Name:find("Skin_") or
                           obj.Name:find("IceEffect") or obj.Name:find("FrozenHighlight") then
                            table.insert(toRemove, obj)
                        end
                    end
                end
                
                for _, obj in pairs(toRemove) do
                    pcall(function() obj:Destroy() end)
                end
                
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Explosion") then
                        pcall(function() obj:Destroy() end)
                    end
                end
                
                if _G.WallHack then
                    ToggleWallHack(false)
                end
                
                Library:MakeNotify({ Title = "Cleared", Content = "Semua efek visual telah dihapus!" })
            end
        })

        local ExitSection = SettingsTab:AddSection("🚪 Exit")
        
        ExitSection:AddButton({
            Title = "Destroy UI",
            Callback = function()
                _G.Spam = false
                _G.TapTP = false
                _G.AdminDetect = false
                _G.Fly = false
                _G.NC = false
                _G.InfJump = false
                _G.AutoWalk = false
                _G.AutoCP = false
                _G.ESP = false
                _G.BoxESP = false
                _G.LineESP = false
                _G.SkeletonESP = false
                _G.HealthESP = false
                _G.AntiRagdoll = false
                _G.AntiVoid = false
                _G.WalkingAntiVoid = false
                _G.AntiFreeze = false
                _G.Wiggle = false
                _G.KillerWarn = false
                _G.Headlight = false
                _G.XRay = false
                _G.Fullbright = false
                _G.Freecam = false
                _G.Spam = false
                _G.ChatLog = false
                _G.AirWalk = false
                _G.WallHack = false
                _G.GravityGunActive = false
                _G.SkinPreview = false
                _G.Aimbot = false
                _G.AutoFarm = false
                _G.AutoHeal = false
                _G.AutoCollect = false
                _G.AntiAFK = false
                _G.SpeedHack = false
                _G.JumpHack = false
                _G.AdminKick = false
                _G.AdminFreeze = false
                
                ToggleWallHack(false)
                ClearManualHighlights()
                CleanupSkin()
                
                Library:MakeNotify({ Title = "FCAL HUB", Content = "Shutdown...", Duration = 2 })
                task.wait(1)
                pcall(function() Window:Destroy() end)
            end
        })
    end)
end

-- ==========================================
-- ESP LOOP
-- ==========================================
RunService.RenderStepped:Connect(function()
    if not (_G.BoxESP or _G.LineESP or _G.SkeletonESP) then
        for _, obj in pairs(ESP_Objects) do 
            pcall(function()
                if obj.Box then obj.Box.Visible = false end
                if obj.Line then obj.Line.Visible = false end
                if obj.Skeleton then
                    for _, line in pairs(obj.Skeleton) do
                        line.Visible = false
                    end
                end
            end)
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                if not ESP_Objects[player] then
                    ESP_Objects[player] = { 
                        Box = Drawing.new("Square"), 
                        Line = Drawing.new("Line"),
                        Skeleton = {}
                    }
                end
                
                local obj = ESP_Objects[player]
                local color = GetESPColor(player)
                
                if _G.BoxESP then
                    local sizeX = math.clamp(2000 / pos.Z, 10, 500)
                    local sizeY = math.clamp(3000 / pos.Z, 10, 700)
                    
                    obj.Box.Visible = true
                    obj.Box.Color = color
                    obj.Box.Size = Vector2.new(sizeX, sizeY)
                    obj.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                    obj.Box.Thickness = 1
                    obj.Box.Filled = false
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
                
                if _G.SkeletonESP then
                    UpdateSkeletonESP(player, obj)
                else
                    for _, line in pairs(obj.Skeleton) do
                        line.Visible = false
                    end
                end
            else
                if ESP_Objects[player] then 
                    if ESP_Objects[player].Box then ESP_Objects[player].Box.Visible = false end
                    if ESP_Objects[player].Line then ESP_Objects[player].Line.Visible = false end
                    if ESP_Objects[player].Skeleton then
                        for _, line in pairs(ESP_Objects[player].Skeleton) do
                            line.Visible = false
                        end
                    end
                end
            end
        else
            ClearESP(player)
        end
    end 
end)

-- ==========================================
-- KEYBIND SECTION
-- ==========================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        _G.MenuVisible = not _G.MenuVisible
        
        local gui = nil
        for _, child in pairs(CoreGui:GetChildren()) do
            if child.Name:find("MDW") or child.Name:find("Lynx") or child.Name:find("Window") or child.Name:find("Hub") or child.Name:find("FCAL") then
                gui = child
                break
            end
        end
        
        if gui then
            gui.Enabled = _G.MenuVisible
        end
    end
end)

-- ==========================================
-- AUTO APPLY SKIN
-- ==========================================
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if ActiveSkin and ActiveSkin.Name ~= "❌ No Skin" then
        CreatePremiumSkin(char)
    end
end)

-- ==========================================
-- NO CLIP LOOP
-- ==========================================
RunService.Stepped:Connect(function()
    if _G.NC and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetChildren()) do 
            if p:IsA("BasePart") then 
                p.CanCollide = false 
            end 
            for _, child in pairs(p:GetDescendants()) do
                if child:IsA("BasePart") then child.CanCollide = false end
            end
        end
    end
end)

-- ==========================================
-- INITIALIZE
-- ==========================================
pcall(function()
    Library:Initialize()
    ApplyTheme("Midnight")
end)

Library:MakeNotify({ 
    Title = "FCAL HUB v2.3.1", 
    Content = "Ultimate Edition FIXED Loaded!\nDengan Marketplace Skins & Admin Tools!", 
    Duration = 5 
})

-- Auto update dropdown
Players.PlayerAdded:Connect(function()
    -- Update dropdowns
end)
Players.PlayerRemoving:Connect(ClearESP)

print("FCAL HUB v2.3.1 - Ultimate Edition FIXED Loaded!")