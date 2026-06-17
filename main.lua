--[[
    FCAL HUB - LYNX GUI EDITION
    Version: 2.2.0 | ULTIMATE EDITION
    Dengan Skin System Premium & Universal Features
--]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mdwpanel/Roblox/refs/heads/main/main_ui_modern.lua"))()

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

_G.AutoCPAll = false
_G.CPTeleportDelay = 0.8
_G.CPScanDelay = 1.0
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
-- WINDOW CREATION
-- ==========================================
local Window = Library:Window({
    Title = "FCAL HUB",
    Footer = "v2.2.0 | Ultimate Edition"
})

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
    Library:MakeNotify({Title = title, Content = desc, Duration = 3})
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
-- PREMIUM SKIN SYSTEM
-- ==========================================

-- Daftar skin premium
local PremiumSkins = {
    {
        Name = "❌ No Skin",
        Color = Color3.fromRGB(255,255,255),
        Type = "None",
        Material = Enum.Material.SmoothPlastic,
        Effect = "None",
        Price = 0
    },
    {
        Name = "🔥 Golden God",
        Color = Color3.fromRGB(255, 215, 0),
        Type = "Gold",
        Material = Enum.Material.Neon,
        Effect = "Glow",
        Price = 0,
        Description = "Berkilau seperti emas murni"
    },
    {
        Name = "🌑 Shadow Reaper",
        Color = Color3.fromRGB(30, 30, 40),
        Type = "Dark",
        Material = Enum.Material.SmoothPlastic,
        Effect = "Smoke",
        Price = 0,
        Description = "Kegelapan yang bergerak"
    },
    {
        Name = "💎 Crystal Blue",
        Color = Color3.fromRGB(0, 150, 255),
        Type = "Crystal",
        Material = Enum.Material.Glass,
        Effect = "Sparkle",
        Price = 0,
        Description = "Seperti kristal biru yang berkilau"
    },
    {
        Name = "🔥 Inferno",
        Color = Color3.fromRGB(255, 50, 0),
        Type = "Fire",
        Material = Enum.Material.Neon,
        Effect = "Fire",
        Price = 0,
        Description = "Api yang membara di tubuhmu"
    },
    {
        Name = "❄️ Frost",
        Color = Color3.fromRGB(100, 200, 255),
        Type = "Ice",
        Material = Enum.Material.Glass,
        Effect = "Snow",
        Price = 0,
        Description = "Dingin seperti es abadi"
    },
    {
        Name = "🌌 Galaxy",
        Color = Color3.fromRGB(150, 0, 255),
        Type = "Galaxy",
        Material = Enum.Material.Neon,
        Effect = "Stars",
        Price = 0,
        Description = "Bawa galaksi ke dalam dirimu"
    },
    {
        Name = "💚 Emerald",
        Color = Color3.fromRGB(0, 255, 100),
        Type = "Emerald",
        Material = Enum.Material.Neon,
        Effect = "Glow",
        Price = 0,
        Description = "Hijau zamrud yang memukau"
    },
    {
        Name = "❤️ Ruby",
        Color = Color3.fromRGB(255, 0, 50),
        Type = "Ruby",
        Material = Enum.Material.Neon,
        Effect = "Glow",
        Price = 0,
        Description = "Merah delima yang berapi-api"
    },
    {
        Name = "🌈 Rainbow",
        Color = Color3.fromRGB(255, 0, 255),
        Type = "Rainbow",
        Material = Enum.Material.Neon,
        Effect = "Rainbow",
        Price = 0,
        Description = "Pelangi bergerak di tubuhmu"
    },
    {
        Name = "⚡ Storm",
        Color = Color3.fromRGB(200, 200, 255),
        Type = "Storm",
        Material = Enum.Material.Neon,
        Effect = "Lightning",
        Price = 0,
        Description = "Listrik mengalir di tubuhmu"
    },
    {
        Name = "🪐 Void",
        Color = Color3.fromRGB(20, 0, 40),
        Type = "Void",
        Material = Enum.Material.SmoothPlastic,
        Effect = "Shadow",
        Price = 0,
        Description = "Kegelapan total yang menyerap cahaya"
    },
    {
        Name = "🌸 Cherry Blossom",
        Color = Color3.fromRGB(255, 150, 200),
        Type = "Sakura",
        Material = Enum.Material.Neon,
        Effect = "Petal",
        Price = 0,
        Description = "Bunga sakura yang bermekaran"
    },
    {
        Name = "🏆 Champion",
        Color = Color3.fromRGB(255, 200, 50),
        Type = "Champion",
        Material = Enum.Material.Neon,
        Effect = "Aura",
        Price = 0,
        Description = "Aura kemenangan yang bersinar"
    },
    {
        Name = "🧊 Diamond",
        Color = Color3.fromRGB(200, 230, 255),
        Type = "Diamond",
        Material = Enum.Material.DiamondPlate,
        Effect = "Sparkle",
        Price = 0,
        Description = "Berlian paling langka dan berharga"
    },
}

function CreatePremiumSkin(character)
    if not character then return end
    
    -- Hapus skin lama
    if character:FindFirstChild("MDW_Skin") then
        character.MDW_Skin:Destroy()
    end
    
    if not ActiveSkin or ActiveSkin.Type == "None" then
        IsSkinActive = false
        return
    end
    
    IsSkinActive = true
    local skinFolder = Instance.new("Folder")
    skinFolder.Name = "MDW_Skin"
    skinFolder.Parent = character
    
    -- Simpan data skin
    local skinData = Instance.new("StringValue")
    skinData.Name = "SkinData"
    skinData.Value = HttpService:JSONEncode({
        Name = ActiveSkin.Name,
        Color = ActiveSkin.Color,
        Type = ActiveSkin.Type,
        Effect = ActiveSkin.Effect
    })
    skinData.Parent = skinFolder
    
    -- Buat efek untuk setiap bagian tubuh
    local parts = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "HumanoidRootPart"}
    
    for _, partName in pairs(parts) do
        local original = character:FindFirstChild(partName)
        if original and original:IsA("BasePart") then
            -- Buat part baru sebagai skin
            local skinPart = original:Clone()
            skinPart.Name = "Skin_" .. partName
            skinPart.Parent = skinFolder
            skinPart.CFrame = original.CFrame
            skinPart.CanCollide = false
            skinPart.Material = ActiveSkin.Material or Enum.Material.Neon
            skinPart.Color = ActiveSkin.Color
            skinPart.Transparency = 0.2
            
            -- Tambahkan efek glow
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
            
            -- Efek khusus berdasarkan tipe
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
            elseif ActiveSkin.Effect == "Lightning" then
                glow.Texture = "rbxassetid://268857015"
                glow.Rate = 40
                glow.SpreadAngle = Vector2.new(360, 360)
                glow.Speed = NumberRange.new(5, 10)
                glow.Size = NumberSequence.new(4)
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
            
            -- Pasang attachment ke original
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
    
    -- Tambahkan trail effect
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
    
    -- Kirim skin ke semua player
    if _G.SkinPreview then
        SyncSkinToAll(character)
    end
end

function SyncSkinToAll(character)
    if not ActiveSkin or ActiveSkin.Type == "None" then return end
    
    -- Kirim melalui RemoteEvent
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
        if remote then
            remote:FireServer("SyncSkin", {
                Player = LocalPlayer.Name,
                Color = ActiveSkin.Color,
                Name = ActiveSkin.Name,
                Type = ActiveSkin.Type,
                Effect = ActiveSkin.Effect
            })
        end
    end)
    
    -- Kirim melalui RemoteFunction
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("RemoteFunction")
        if remote then
            remote:InvokeServer("SyncSkin", {
                Player = LocalPlayer.Name,
                Color = ActiveSkin.Color,
                Name = ActiveSkin.Name,
                Type = ActiveSkin.Type
            })
        end
    end)
    
    -- Kirim melalui BindableEvent
    pcall(function()
        local bindable = ReplicatedStorage:FindFirstChild("BindableEvent")
        if bindable then
            bindable:Fire({
                Player = LocalPlayer.Name,
                Color = ActiveSkin.Color,
                Name = ActiveSkin.Name,
                Type = ActiveSkin.Type
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
    if char and char:FindFirstChild("MDW_Skin") then
        pcall(function() char.MDW_Skin:Destroy() end)
    end
    IsSkinActive = false
end

-- Auto apply skin
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if ActiveSkin and ActiveSkin.Type ~= "None" then
        CreatePremiumSkin(char)
    end
end)

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
-- TABS SETUP
-- ==========================================
local MainTab = Window:AddTab({ Name = "Main", Icon = "home" })
local PlayerTab = Window:AddTab({ Name = "Player", Icon = "user" })
local GameTab = Window:AddTab({ Name = "Game", Icon = "gamepad" })
local ServerTab = Window:AddTab({ Name = "Server", Icon = "web" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings" })
local SkinTab = Window:AddTab({ Name = "Skins", Icon = "palette" })
local UniversalTab = Window:AddTab({ Name = "Universal", Icon = "globe" })

-- ==========================================
-- MAIN TAB - QUICK ACTIONS
-- ==========================================
local QuickSection = MainTab:AddSection("⚡ Quick Actions")

-- GRAVITY GUN - FIXED
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

-- ==========================================
-- PLAYER TELEPORT
-- ==========================================
local QuickTpSection = MainTab:AddSection("📌 Quick Player Teleport")
local SelectedTarget = ""

QuickTpSection:AddToggle({
    Title = "Auto Pick Up / Interact",
    Description = "Otomatis ambil item/oksigen terdekat",
    Default = false,
    Callback = function(v)
        _G.AutoInteract = v
        if v then
            task.spawn(function()
                while _G.AutoInteract do
                    pcall(function()
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("ProximityPrompt") then
                                local root = GetRootPart()
                                if root and obj.Parent then
                                    local dist = (root.Position - obj.Parent:GetPivot().Position).Magnitude
                                    if dist < 15 and obj.Enabled then
                                        fireproximityprompt(obj)
                                        task.wait(0.1)
                                    end
                                end
                            end
                        end
                        
                        local root = GetRootPart()
                        if root then
                            for _, obj in pairs(workspace:GetDescendants()) do
                                if obj:IsA("BasePart") and obj.Parent and not obj.Parent:IsA("Character") then
                                    local dist = (root.Position - obj.Position).Magnitude
                                    if dist < 8 and (obj.Name:lower():find("tool") or obj.Name:lower():find("item")) then
                                        firetouchinterest(root, obj, 0)
                                        task.wait(0.05)
                                        firetouchinterest(root, obj, 1)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
            Library:MakeNotify({ Title = "Auto Interact", Content = "Aktif!" })
        else
            Library:MakeNotify({ Title = "Auto Interact", Content = "Mati!" })
        end
    end
})

local TpSection = MainTab:AddSection("🚀 Teleport")

TpSection:AddToggle({
    Title = "Click TP (PC/Mobile)",
    Description = "Klik/Sentuh layar untuk teleport instan",
    Default = false,
    Callback = function(v) 
        _G.TapTP = v
        Library:MakeNotify({ Title = "Click TP", Content = v and "Aktif!" or "Mati!" })
    end
})

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if _G.TapTP and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local root = GetRootPart()
        if root then  
            local mouse = LocalPlayer:GetMouse()
            if mouse and mouse.Hit then
                local targetPos = mouse.Hit.p
                if targetPos then
                    if targetPos.Y > -50 then
                        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                    end
                end
            end
        end
    end
end)

local PlayerDropdown = QuickTpSection:AddDropdown({
    Title = "Pilih Pemain",
    Description = "Cari atau pilih nama pemain",
    Options = GetPlayerList(),
    Default = "",
    Callback = function(v) 
        SelectedTarget = v 
    end
})

local function UpdateDropdown()
    local currentPlayers = GetPlayerList()
    if PlayerDropdown.SetValues then
        PlayerDropdown:SetValues(currentPlayers)
    elseif PlayerDropdown.Refresh then
        PlayerDropdown:Refresh(currentPlayers, true)
    end
end

QuickTpSection:AddButton({ 
    Title = "🔄 Refresh Daftar Pemain", 
    Callback = function()
        UpdateDropdown()
        Library:MakeNotify({ Title = "MDW", Content = "Daftar pemain telah diperbarui!" })
    end 
})

QuickTpSection:AddButton({
    Title = "Teleport Sekarang",
    Callback = function()
        if SelectedTarget == "" or SelectedTarget == "Tidak ada pemain" then 
            Library:MakeNotify({ Title = "Warning", Content = "Pilih pemain dulu!" })
            return 
        end
        
        local target = Players:FindFirstChild(SelectedTarget)
        local targetChar = (target and target.Character) or workspace:FindFirstChild(SelectedTarget)
        
        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local myHRP = myChar.HumanoidRootPart
                local targetHRP = targetChar.HumanoidRootPart
                
                myHRP.Anchored = true
                pcall(function() LocalPlayer.ReplicationFocus = targetHRP end)
                myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
                task.wait(0.3)
                myHRP.Anchored = false
                
                Library:MakeNotify({ Title = "Success", Content = "Berhasil ke " .. SelectedTarget })
            end
        else
            Library:MakeNotify({ Title = "Error", Content = "Gagal! Player terlalu jauh." })
        end
    end
})

QuickTpSection:AddButton({
    Title = "Bring Player (Visual)",
    Description = "Membawa target ke posisi Anda",
    Callback = function()
        if SelectedTarget == "" or SelectedTarget == "Tidak ada pemain" then 
            Library:MakeNotify({ Title = "Warning", Content = "Pilih pemain dulu!" }) 
            return 
        end
        local target = Players:FindFirstChild(SelectedTarget)
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if target and target.Character and myRoot then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                local origPos = tRoot.Position
                tRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
                
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(0, 255, 255)
                hl.FillTransparency = 0.5
                hl.Adornee = target.Character
                hl.Parent = target.Character
                table.insert(ManualHighlights, hl)
                
                Library:MakeNotify({ Title = "Success", Content = "Membawa " .. SelectedTarget })
                
                task.wait(3)
                if tRoot.Parent then
                    tRoot.CFrame = CFrame.new(origPos)
                end
            end
        else
            Library:MakeNotify({ Title = "Error", Content = "Pemain tidak ditemukan!" })
        end
    end
})

-- ==========================================
-- TROLL MOUNTAIN SECTION
-- ==========================================
local TrollSection = MainTab:AddSection("🎭 Troll Mountain")

local function GetTrollTarget()
    if SelectedTarget == "" or SelectedTarget == "Tidak ada pemain" then 
        Library:MakeNotify({ Title = "⚠️ Error", Content = "Pilih pemain dulu di dropdown!", Duration = 3 })
        return nil
    end
    
    local target = game.Players:FindFirstChild(SelectedTarget)
    if not target then
        Library:MakeNotify({ Title = "⚠️ Error", Content = "Pemain '" .. SelectedTarget .. "' tidak ditemukan!", Duration = 3 })
        return nil
    end
    
    if not target.Character then
        Library:MakeNotify({ Title = "⚠️ Error", Content = "Pemain tidak memiliki karakter!", Duration = 3 })
        return nil
    end
    
    return target
end

TrollSection:AddButton({
    Title = "💨 Dorong dari Tebing",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Target tidak punya HRP!", Duration = 3 })
            return 
        end
        
        local dir = hrp.CFrame.LookVector * -100
        hrp.AssemblyLinearVelocity = Vector3.new(dir.X, 30, dir.Z)
        
        local boom = Instance.new("Explosion")
        boom.Position = hrp.Position
        boom.BlastRadius = 5
        boom.BlastPressure = 0
        boom.Parent = workspace
        
        Library:MakeNotify({ Title = "💨 DORONG!", Content = target.Name .. " didorong!", Duration = 3 })
    end
})

TrollSection:AddButton({
    Title = "🚀 Fling Target",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Target tidak punya HRP!", Duration = 3 })
            return 
        end
        
        hrp.AssemblyLinearVelocity = Vector3.new(
            math.random(-150, 150),
            math.random(300, 500),
            math.random(-150, 150)
        )
        
        local boom = Instance.new("Explosion")
        boom.Position = hrp.Position
        boom.BlastRadius = 5
        boom.BlastPressure = 0
        boom.Parent = workspace
        
        Library:MakeNotify({ Title = "🚀 FLING!", Content = target.Name .. " terbang!", Duration = 3 })
    end
})

TrollSection:AddButton({
    Title = "🔒 Kandang Target",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Target tidak punya HRP!", Duration = 3 })
            return 
        end
        
        local pos = hrp.Position
        local parts = {}
        
        local dinding = {
            {Vector3.new(12, 6, 1), Vector3.new(0, 0, 6)},
            {Vector3.new(12, 6, 1), Vector3.new(0, 0, -6)},
            {Vector3.new(1, 6, 12), Vector3.new(6, 0, 0)},
            {Vector3.new(1, 6, 12), Vector3.new(-6, 0, 0)},
        }
        
        for _, data in pairs(dinding) do
            local p = Instance.new("Part")
            p.Size = data[1]
            p.Position = pos + data[2]
            p.Anchored = true
            p.BrickColor = BrickColor.new("Bright blue")
            p.Transparency = 0.4
            p.Material = Enum.Material.Glass
            p.Parent = workspace
            table.insert(parts, p)
        end
        
        local roof = Instance.new("Part")
        roof.Size = Vector3.new(13, 1, 13)
        roof.Position = pos + Vector3.new(0, 6, 0)
        roof.Anchored = true
        roof.BrickColor = BrickColor.new("Bright blue")
        roof.Transparency = 0.4
        roof.Material = Enum.Material.Glass
        roof.Parent = workspace
        table.insert(parts, roof)
        
        Library:MakeNotify({ Title = "🔒 KANDANG!", Content = target.Name .. " dikurung!", Duration = 3 })
        
        task.wait(5)
        for _, p in pairs(parts) do
            pcall(function() p:Destroy() end)
        end
    end
})

TrollSection:AddButton({
    Title = "❄️ Lantai Licin",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Target tidak punya HRP!", Duration = 3 })
            return 
        end
        
        local pos = hrp.Position
        local ices = {}
        
        for x = -4, 4 do
            for z = -4, 4 do
                local ice = Instance.new("Part")
                ice.Size = Vector3.new(4, 0.5, 4)
                ice.Position = pos + Vector3.new(x * 4, -3, z * 4)
                ice.BrickColor = BrickColor.new("Bright blue")
                ice.Material = Enum.Material.Ice
                ice.Transparency = 0.3
                ice.Anchored = true
                ice.CanCollide = true
                ice.Parent = workspace
                
                ice.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0.3, 0, 0)
                
                table.insert(ices, ice)
            end
        end
        
        Library:MakeNotify({ Title = "❄️ LICIN!", Content = "Lantai es di sekitar " .. target.Name, Duration = 3 })
        
        task.wait(5)
        for _, ice in pairs(ices) do
            pcall(function() ice:Destroy() end)
        end
    end
})

TrollSection:AddButton({
    Title = "⛰️ Longsor Batu",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Target tidak punya HRP!", Duration = 3 })
            return 
        end
        
        local pos = hrp.Position
        local rocks = {}
        
        for i = 1, 20 do
            local rock = Instance.new("Part")
            rock.Size = Vector3.new(
                math.random(2, 5),
                math.random(2, 5),
                math.random(2, 5)
            )
            rock.Position = pos + Vector3.new(
                math.random(-40, 40),
                50 + math.random(0, 30),
                math.random(-40, 40)
            )
            rock.BrickColor = BrickColor.new("Medium stone grey")
            rock.Material = Enum.Material.Rock
            rock.Anchored = false
            rock.Parent = workspace
            
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, -80, 0)
            bv.MaxForce = Vector3.new(0, math.huge, 0)
            bv.Parent = rock
            
            table.insert(rocks, rock)
        end
        
        Library:MakeNotify({ Title = "⛰️ LONGSOR!", Content = "Batu menimpa " .. target.Name, Duration = 3 })
        
        task.wait(6)
        for _, rock in pairs(rocks) do
            pcall(function() rock:Destroy() end)
        end
    end
})

TrollSection:AddButton({
    Title = "🔄 Teleport Balik ke Awal",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Target tidak punya HRP!", Duration = 3 })
            return 
        end
        
        local lowest = nil
        local lowY = math.huge
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") or (obj:IsA("BasePart") and 
                (obj.Name:lower():find("cp") or obj.Name:lower():find("checkpoint") or 
                 obj.Name:lower():find("stage") or obj.Name:lower():find("start"))) then
                if obj.Position.Y < lowY then
                    lowY = obj.Position.Y
                    lowest = obj
                end
            end
        end
        
        if lowest then
            hrp.CFrame = lowest.CFrame * CFrame.new(0, 5, 0)
            
            local boom = Instance.new("Explosion")
            boom.Position = hrp.Position
            boom.BlastRadius = 5
            boom.BlastPressure = 0
            boom.Parent = workspace
            
            Library:MakeNotify({ Title = "🔄 KEMBALI!", Content = target.Name .. " ke awal!", Duration = 3 })
        else
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Tidak ada checkpoint ditemukan!", Duration = 3 })
        end
    end
})

TrollSection:AddButton({
    Title = "🌍 Gempa Bumi",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Target tidak punya HRP!", Duration = 3 })
            return 
        end
        
        for i = 1, 15 do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local pRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    if pRoot then
                        local shake = Vector3.new(
                            math.random(-3, 3),
                            math.random(1, 5),
                            math.random(-3, 3)
                        )
                        pcall(function()
                            pRoot.CFrame = pRoot.CFrame + shake
                            task.wait(0.02)
                            pRoot.CFrame = pRoot.CFrame - shake
                        end)
                    end
                end
            end
            task.wait(0.05)
        end
        
        Library:MakeNotify({ Title = "🌍 GEMPA!", Content = "Semua player terguncang!", Duration = 3 })
    end
})

TrollSection:AddButton({
    Title = "👥 Clone Target",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Target tidak punya HRP!", Duration = 3 })
            return 
        end
        
        local clone = target.Character:Clone()
        clone.Parent = workspace
        clone:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(10, 0, 10))
        clone.Name = "Clone_of_" .. target.Name
        
        local hum = clone:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.DisplayName = "Clone " .. target.Name
        end
        
        Library:MakeNotify({ Title = "👥 CLONE!", Content = "Clone " .. target.Name .. " muncul!", Duration = 3 })
        
        task.wait(8)
        pcall(function() clone:Destroy() end)
    end
})

TrollSection:AddButton({
    Title = "🌀 Zona Gravitasi",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Target tidak punya HRP!", Duration = 3 })
            return 
        end
        
        local pos = hrp.Position
        
        local zone = Instance.new("Part")
        zone.Shape = Enum.PartType.Ball
        zone.Size = Vector3.new(30, 30, 30)
        zone.Position = pos
        zone.BrickColor = BrickColor.new("Bright purple")
        zone.Transparency = 0.5
        zone.Anchored = true
        zone.CanCollide = false
        zone.Parent = workspace
        
        local gravity = Instance.new("BodyForce")
        gravity.Force = Vector3.new(0, -5000, 0)
        gravity.Parent = hrp
        
        Library:MakeNotify({ Title = "🌀 GRAVITASI!", Content = target.Name .. " ditarik ke bawah!", Duration = 3 })
        
        task.wait(4)
        pcall(function()
            zone:Destroy()
            gravity:Destroy()
        end)
    end
})

TrollSection:AddButton({
    Title = "🕶️ Butakan Target",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local gui = Instance.new("ScreenGui")
        gui.Name = "BlindEffect"
        gui.Parent = target.PlayerGui
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        frame.BackgroundTransparency = 0
        frame.Parent = gui
        
        Library:MakeNotify({ Title = "🕶️ BUTA!", Content = target.Name .. " dibutakan!", Duration = 3 })
        
        task.wait(4)
        pcall(function() gui:Destroy() end)
    end
})

TrollSection:AddButton({
    Title = "🧱 Tembok Depan",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Target tidak punya HRP!", Duration = 3 })
            return 
        end
        
        local pos = hrp.Position
        local look = hrp.CFrame.LookVector
        
        local wall = Instance.new("Part")
        wall.Size = Vector3.new(20, 10, 2)
        wall.Position = pos + (look * 10) + Vector3.new(0, 3, 0)
        wall.BrickColor = BrickColor.new("Bright red")
        wall.Transparency = 0.4
        wall.Anchored = true
        wall.CanCollide = true
        wall.Parent = workspace
        
        Library:MakeNotify({ Title = "🧱 TEMBOK!", Content = "Tembok di depan " .. target.Name, Duration = 3 })
        
        task.wait(4)
        pcall(function() wall:Destroy() end)
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

local AirPlatform = nil
local LockedY = 0

MoveSection:AddToggle({
    Title = "Real Air Walk (Solid Floor)",
    Description = "Berjalan di lantai padat (Ketinggian Terkunci)",
    Default = false,
    Callback = function(v)
        _G.AirWalk = v
        
        if v then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root then
                LockedY = root.Position.Y - 3.45 
                
                AirPlatform = Instance.new("Part")
                AirPlatform.Name = "MDW_SolidAirFloor"
                AirPlatform.Size = Vector3.new(10, 1, 10)
                AirPlatform.Transparency = 1
                AirPlatform.Anchored = true
                AirPlatform.CanCollide = true
                AirPlatform.Parent = workspace
                
                task.spawn(function()
                    while _G.AirWalk do
                        local currentRoot = char and char:FindFirstChild("HumanoidRootPart")
                        if currentRoot and AirPlatform then
                            AirPlatform.CFrame = CFrame.new(currentRoot.Position.X, LockedY, currentRoot.Position.Z)
                        end
                        task.wait()
                    end
                end)
                
                Library:MakeNotify({ Title = "Air Walk", Content = "Ketinggian dikunci. Anda bisa berjalan sekarang!" })
            end
        else
            if AirPlatform then
                AirPlatform:Destroy()
                AirPlatform = nil
            end
            Library:MakeNotify({ Title = "Air Walk", Content = "Fitur Dimatikan." })
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
                    if hum then
                        if hum.PlatformStand then hum.PlatformStand = false end
                        if hum.Sit then hum.Sit = false end
                    end
                end
            end)
        end
    end
})

local VoidPart = Instance.new("Part")
VoidPart.Name = "AntiVoidPlatform"
VoidPart.Size = Vector3.new(20, 1, 20)
VoidPart.Transparency = 1
VoidPart.Anchored = true
VoidPart.CanCollide = false

AntiSection:AddToggle({
    Title = "Walking Anti-Void (Air Walk)",
    Description = "Berjalan di udara saat berada di jurang",
    Default = false,
    Callback = function(v)
        _G.WalkingAntiVoid = v
        
        if v then
            task.spawn(function()
                local safeHeight = 0
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then safeHeight = root.Position.Y - 3.5 end

                while _G.WalkingAntiVoid do
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if hrp then
                        if hrp.Position.Y < (safeHeight - 5) then
                            VoidPart.Parent = workspace
                            VoidPart.CanCollide = true
                            VoidPart.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z)
                        else
                            VoidPart.CanCollide = false
                            VoidPart.Parent = nil
                        end
                    end
                    task.wait()
                end
                VoidPart:Destroy()
            end)
            Library:MakeNotify({ Title = "Anti-Void", Content = "Mode Berjalan di Udara Aktif!" })
        else
            VoidPart.Parent = nil
            Library:MakeNotify({ Title = "Anti-Void", Content = "Mode Berjalan di Udara Mati" })
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

-- ==========================================
-- FLY SECTION - FIXED
-- ==========================================
local FlySection = PlayerTab:AddSection("🪁 Fly Settings")

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

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if _G.Fly then StartFly() end
end)

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

-- ==========================================
-- GAME TAB - AUTO CP
-- ==========================================
local function ScanAllCheckpoints()
    local checkpoints = {}
    local seen = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then
            local name = obj.Name:lower()
            local pos = obj.Position
            local found = false
            
            if name:find("humanoid") or name:find("player") or 
               name:find("character") or name:find("npc") or
               name:find("particle") or name:find("effect") or
               name:find("attachment") or name:find("handle") then
                -- Skip
            else
                if name:find("cp") or 
                   name:find("checkpoint") or 
                   name:find("stage") or 
                   name:find("point") or 
                   name:find("start") or 
                   name:find("finish") or
                   name:find("level") or 
                   name:find("zone") or
                   name:find("spawn") or 
                   name:find("respawn") or
                   name:find("base") or
                   name:find("platform") or
                   name:find("landing") or
                   name:find("rest") or
                   name:find("save") or
                   name:find("safe") or
                   name:find("check") then
                    found = true
                end
                
                if obj:GetAttribute("Checkpoint") or 
                   obj:GetAttribute("CP") or 
                   obj:GetAttribute("Stage") or
                   obj:GetAttribute("Point") or
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
            end
            
            if found and pos.Y > -50 then
                local num = tonumber(obj.Name:match("%d+")) or 0
                
                local key = math.floor(pos.X) .. "_" .. math.floor(pos.Y) .. "_" .. math.floor(pos.Z)
                if not seen[key] then
                    seen[key] = true
                    table.insert(checkpoints, {
                        Part = obj,
                        Y = pos.Y,
                        Number = num,
                        Name = obj.Name,
                        Position = pos,
                        Key = key
                    })
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
-- TAB AUTO CP - FIXED
-- ==========================================
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

FarmSection:AddButton({
    Title = "⬆️ TP ke CP Berikutnya",
    Callback = function()
        local cps = ScanAllCheckpoints()
        local root = GetRootPart()
        
        if not root or #cps == 0 then
            Library:MakeNotify({ 
                Title = "❌ Error", 
                Content = "Tidak ada checkpoint!", 
                Duration = 2 
            })
            return
        end
        
        local nextCP = nil
        local currentY = root.Position.Y
        
        for _, cp in pairs(cps) do
            if cp.Y > currentY + 2 then
                nextCP = cp
                break
            end
        end
        
        if nextCP then
            root.CFrame = nextCP.Part.CFrame * CFrame.new(0, 5, 0)
            Library:MakeNotify({ 
                Title = "⬆️ Naik!", 
                Content = "Ke " .. nextCP.Name, 
                Duration = 2 
            })
        else
            local highest = cps[#cps]
            if highest then
                root.CFrame = highest.Part.CFrame * CFrame.new(0, 5, 0)
                Library:MakeNotify({ 
                    Title = "🏔️ Puncak!", 
                    Content = "Sudah di puncak!", 
                    Duration = 2 
                })
            end
        end
    end
})

FarmSection:AddButton({
    Title = "🏔️ TP ke Puncak",
    Callback = function()
        local cps = ScanAllCheckpoints()
        
        if #cps == 0 then
            Library:MakeNotify({ 
                Title = "❌ Error", 
                Content = "Tidak ada checkpoint ditemukan!", 
                Duration = 3 
            })
            return
        end
        
        local highest = cps[#cps]
        local root = GetRootPart()
        
        if root and highest then
            root.CFrame = highest.Part.CFrame * CFrame.new(0, 5, 0)
            Library:MakeNotify({ 
                Title = "🏔️ Puncak!", 
                Content = "TP ke " .. highest.Name, 
                Duration = 3 
            })
        end
    end
})

-- ==========================================
-- GAME TAB - VISUAL ESP
-- ==========================================
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
    Title = "ESP Health Bar",
    Default = false,
    Callback = function(v)
        _G.HealthESP = v
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("HealthBarGui") then
                    pcall(function() p.Character.Head.HealthBarGui:Destroy() end)
                end
            end
        end
        Library:MakeNotify({ Title = "Health ESP", Content = v and "Aktif!" or "Mati!" })
    end
})

RunService.RenderStepped:Connect(function()
    if _G.HealthESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local humanoid = player.Character:FindFirstChild("Humanoid")
                
                if humanoid and humanoid.Health > 0 then
                    local gui = head:FindFirstChild("HealthBarGui")
                    if not gui then
                        local bgui = Instance.new("BillboardGui", head)
                        bgui.Name = "HealthBarGui"
                        bgui.Size = UDim2.new(3, 0, 0.4, 0)
                        bgui.StudsOffset = Vector3.new(0, 2, 0)
                        bgui.AlwaysOnTop = true
                        
                        local back = Instance.new("Frame", bgui)
                        back.Name = "Background"
                        back.Size = UDim2.new(1, 0, 1, 0)
                        back.BackgroundColor3 = Color3.new(0, 0, 0)
                        back.BorderSizePixel = 0
                        
                        local bar = Instance.new("Frame", back)
                        bar.Name = "Frame"
                        bar.BorderSizePixel = 0
                        bar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                        bar.BackgroundColor3 = Color3.new(0, 1, 0)
                    else
                        local frame = gui:FindFirstChild("Frame")
                        local bar = frame and frame:FindFirstChild("Bar")
                        if bar then
                            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                            bar.Size = UDim2.new(healthPercent, 0, 1, 0)
                            bar.BackgroundColor3 = Color3.fromHSV(healthPercent * 0.3, 1, 1) 
                        end
                    end
                elseif gui then
                    pcall(function() gui:Destroy() end)
                end
            end
        end
    end
end)

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

VisualSection:AddToggle({
    Title = "Headlight (God Light)",
    Default = false,
    Callback = function(v)
        _G.Headlight = v
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
        _G.Freecam = v
        local cam = workspace.CurrentCamera
        if v then
            _G.OldSubject = cam.CameraSubject
            cam.CameraType = Enum.CameraType.Scriptable
            _G.FreecamLoop = RunService.RenderStepped:Connect(function()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then cam.CFrame *= CFrame.new(0,0,-1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then cam.CFrame *= CFrame.new(0,0,1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then cam.CFrame *= CFrame.new(-1,0,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then cam.CFrame *= CFrame.new(1,0,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then cam.CFrame *= CFrame.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then cam.CFrame *= CFrame.new(0,-1,0) end
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
        _G.XRay = v
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

-- ==========================================
-- GAME TAB - UTILITIES
-- ==========================================
local UtilSection = GameTab:AddSection("⚙️ Gameplay Utilities")

UtilSection:AddToggle({
    Title = "Auto Wiggle (Anti Grab)",
    Description = "Spam A & D otomatis saat ditangkap",
    Default = false,
    Callback = function(v)
        _G.Wiggle = v
        if v then
            task.spawn(function()
                while _G.Wiggle do
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.A, false, game)
                        
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                    end)
                    task.wait(0.05)
                end
            end)
            Library:MakeNotify({ Title = "Auto Wiggle", Content = "Aktif!" })
        else
            Library:MakeNotify({ Title = "Auto Wiggle", Content = "Mati!" })
        end
    end
})

-- ==========================================
-- GAME TAB - FIND OBJECTS
-- ==========================================
local FindSection = GameTab:AddSection("🔍 Find Objects")

FindSection:AddButton({
    Title = "Find Generators",
    Description = "Cari generator di map (untuk game yang ada generator)",
    Callback = function()
        ClearManualHighlights()
        local generators = FindAllGenerators() 
        local count = 0
        
        for _, gen in pairs(generators) do
            local hl = Instance.new("Highlight")
            if IsGeneratorCompleted(gen) then
                hl.FillColor = Color3.fromRGB(0, 255, 100)
            else
                hl.FillColor = Color3.fromRGB(255, 170, 0)
            end
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.FillTransparency = 0.5
            hl.Adornee = gen
            hl.Parent = gen
            table.insert(ManualHighlights, hl)
            count = count + 1
        end
        Library:MakeNotify({ 
            Title = "Found", 
            Content = count .. " generator ditemukan! Hijau=siap, Orange=belum", 
            Duration = 5 
        })
    end
})

FindSection:AddButton({
    Title = "Find Exit Gates",
    Callback = function()
        ClearManualHighlights()
        local count = 0
        for _, o in pairs(workspace:GetDescendants()) do
            if (o.Name:lower():find("gate") or o.Name:lower():find("exit")) and (o:IsA("Model") or o:IsA("BasePart")) then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(0, 255, 255)
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.FillTransparency = 0.5
                hl.Adornee = o
                hl.Parent = o
                table.insert(ManualHighlights, hl)
                count = count + 1
            end
        end
        Library:MakeNotify({ Title = "Found", Content = count .. " objects highlighted!" })
    end
})

FindSection:AddButton({
    Title = "Clear All Highlights",
    Callback = function()
        ClearManualHighlights()
        for _, o in pairs(workspace:GetDescendants()) do
            if o:IsA("Highlight") then
                pcall(function() o:Destroy() end)
            end
        end
        Library:MakeNotify({ Title = "Cleared", Content = "Semua highlight telah dihapus!" })
    end
})

-- ==========================================
-- SERVER TAB - SPECTATE
-- ==========================================
local SpectateSection = ServerTab:AddSection("👁️ Spectate")

local SpectateDropdown = SpectateSection:AddDropdown({ 
    Title = "Pilih Pemain",
    Options = GetPlayerList(),
    Callback = function(v) SpecTarget = v end 
})

SpectateSection:AddButton({ 
    Title = "🔄 Refresh Daftar Pemain", 
    Callback = function()
        UpdateDropdown()
        Library:MakeNotify({ Title = "MDW", Content = "Daftar pemain telah diperbarui!" })
    end 
})

SpectateSection:AddButton({
    Title = "Mulai Spectate",
    Callback = function()
        local t = Players:FindFirstChild(SpecTarget)
        if t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
            _G.OriginalCameraSubject = Workspace.CurrentCamera.CameraSubject
            Workspace.CurrentCamera.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid")
            Library:MakeNotify({ Title = "Spectating", Content = "Menonton: " .. SpecTarget })
        else
            Library:MakeNotify({ Title = "Error", Content = "Pemain tidak ditemukan!" })
        end
    end
})
 
SpectateSection:AddButton({ 
    Title = "Stop Spectating", 
    Callback = function() 
        local h = GetHumanoid() 
        if h then 
            Workspace.CurrentCamera.CameraSubject = _G.OriginalCameraSubject or h
            Library:MakeNotify({ Title = "Stopped", Content = "Kembali ke karakter sendiri." })
        end 
    end 
})

-- ==========================================
-- SERVER TAB - CHAT
-- ==========================================
local ChatSection = ServerTab:AddSection("💬 Chat Otomatis")

ChatSection:AddInput({ 
    Title = "Custom Chat Message", 
    Default = "FCAL HUB ON TOP!", 
    Callback = function(v) msg = v end 
})

ChatSection:AddToggle({
    Title = "Auto Chat Spammer",
    Default = false,
    Callback = function(v)
        _G.Spam = v
        if v then
            task.spawn(function()
                while _G.Spam do
                    pcall(function() 
                        local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                        if chat and chat:FindFirstChild("SayMessageRequest") then
                            chat.SayMessageRequest:FireServer(msg, "All")
                        end
                    end)
                    pcall(function() 
                        local channel = TextChatService:FindFirstChild("TextChannels")
                        if channel and channel:FindFirstChild("RBXGeneral") then
                            channel.RBXGeneral:SendAsync(msg)
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end
})

-- ==========================================
-- SETTINGS TAB - THEME
-- ==========================================
local ThemeSection = SettingsTab:AddSection("🎨 Appearance")

ThemeSection:AddDropdown({ 
    Title = "Select Theme", 
    Options = {"Dark", "Light", "Midnight", "Rose", "Emerald"}, 
    Default = "Midnight", 
    Callback = function(v) 
        ApplyTheme(v)
    end 
})

-- ==========================================
-- SETTINGS - KEYBIND
-- ==========================================
local keybindSection = SettingsTab:AddSection("⌨️ Keybind")

keybindSection:AddButton({
    Title = "Toggle UI Menu (Right Control)",
    Description = "Tekan Right Control untuk hide/show menu",
    Callback = function()
        _G.MenuVisible = not _G.MenuVisible
        
        local gui = nil
        
        for _, child in pairs(CoreGui:GetChildren()) do
            if child.Name:find("MDW") or child.Name:find("Lynx") or child.Name:find("Window") or child.Name:find("Hub") or child.Name:find("FCAL") then
                gui = child
                break
            end
        end
        
        if not gui then
            for _, child in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                if child.Name:find("MDW") or child.Name:find("Lynx") or child.Name:find("Window") or child.Name:find("Hub") or child.Name:find("FCAL") then
                    gui = child
                    break
                end
            end
        end
        
        if gui then
            gui.Enabled = _G.MenuVisible
            Library:MakeNotify({ 
                Title = "Menu", 
                Content = _G.MenuVisible and "Menu Ditampilkan" or "Menu Disembunyikan" 
            })
        else
            pcall(function()
                Window.Visible = _G.MenuVisible
            end)
        end
    end
})

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
-- SKIN TAB - PREMIUM
-- ==========================================
local SkinSection = SkinTab:AddSection("🎨 Premium Skins")

-- Dropdown untuk skin
local skinOptions = {}
for _, skin in pairs(PremiumSkins) do
    table.insert(skinOptions, skin.Name)
end

local SkinDropdown = SkinSection:AddDropdown({
    Title = "Pilih Skin Premium",
    Options = skinOptions,
    Default = "❌ No Skin",
    Callback = function(v)
        for _, skin in pairs(PremiumSkins) do
            if skin.Name == v then
                ActiveSkin = skin
                _G.SkinName = skin.Name
                _G.SkinColor = skin.Color
                _G.SkinEffect = skin.Effect or "None"
                
                if skin.Type == "None" then
                    CleanupSkin()
                    Library:MakeNotify({ Title = "Skin", Content = "Skin dihapus!" })
                else
                    CreatePremiumSkin(LocalPlayer.Character)
                    Library:MakeNotify({ 
                        Title = "Skin", 
                        Content = "Skin " .. skin.Name .. " diterapkan!\n" .. (skin.Description or ""),
                        Duration = 4
                    })
                end
                break
            end
        end
    end
})

SkinSection:AddToggle({
    Title = "Tampilkan Skin ke Player Lain",
    Description = "Kirim data skin ke semua player di server",
    Default = false,
    Callback = function(v)
        _G.SkinPreview = v
        if v and ActiveSkin and ActiveSkin.Type ~= "None" then
            SyncSkinToAll(LocalPlayer.Character)
            Library:MakeNotify({ 
                Title = "Sync", 
                Content = "Mengirim skin ke semua player..." 
            })
        end
    end
})

SkinSection:AddButton({
    Title = "🔄 Refresh Skin",
    Description = "Terapkan ulang skin saat ini",
    Callback = function()
        if ActiveSkin and ActiveSkin.Type ~= "None" then
            CleanupSkin()
            task.wait(0.1)
            CreatePremiumSkin(LocalPlayer.Character)
            Library:MakeNotify({ Title = "Refresh", Content = "Skin direfresh!" })
        end
    end
})

SkinSection:AddButton({
    Title = "🎲 Random Skin",
    Description = "Pilih skin secara acak",
    Callback = function()
        local randomSkins = {}
        for _, skin in pairs(PremiumSkins) do
            if skin.Type ~= "None" then
                table.insert(randomSkins, skin)
            end
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
                Title = "🎲 Random Skin", 
                Content = "Skin " .. randomSkin.Name .. " diterapkan!", 
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
        ActiveSkin = PremiumSkins[1] -- No Skin
        Library:MakeNotify({ Title = "Skin", Content = "Skin dihapus!" })
    end
})

-- Auto apply skin saat character spawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if ActiveSkin and ActiveSkin.Type ~= "None" then
        CreatePremiumSkin(char)
    end
end)

-- ==========================================
-- UNIVERSAL TAB - FEATURES LENGKAP
-- ==========================================

local UniversalSection = UniversalTab:AddSection("🌐 Universal Features")

-- 1. FPS BOOSTER
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

-- 2. CAMERA ZOOM
UniversalSection:AddSlider({
    Title = "📷 Camera Zoom Extender",
    Description = "Perbesar jarak kamera maksimal",
    Minimum = 1,
    Maximum = 500,
    Default = 50,
    Callback = function(v)
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then
                cam.MaxZoomDistance = v
                Library:MakeNotify({ Title = "Zoom", Content = "Jarak max: " .. v })
            end
        end)
    end
})

-- 3. HIGHLIGHT ALL PLAYERS
UniversalSection:AddToggle({
    Title = "✨ Highlight All Players",
    Description = "Highlight semua player di server",
    Default = false,
    Callback = function(v)
        if v then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = Instance.new("Highlight")
                    hl.Name = "UniversalHighlight"
                    hl.Adornee = p.Character
                    hl.FillColor = Color3.fromRGB(0, 200, 255)
                    hl.FillTransparency = 0.3
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.Parent = p.Character
                end
            end
            Library:MakeNotify({ Title = "Highlight", Content = "Semua player di-highlight!" })
        else
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Highlight") and obj.Name == "UniversalHighlight" then
                    pcall(function() obj:Destroy() end)
                end
            end
            Library:MakeNotify({ Title = "Highlight", Content = "Highlight dimatikan" })
        end
    end
})

-- 4. TELEPORT TO SPAWN
UniversalSection:AddButton({
    Title = "🏠 Teleport to Spawn",
    Description = "Teleport ke spawn point terdekat",
    Callback = function()
        local spawns = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") then
                table.insert(spawns, obj)
            end
        end
        
        if #spawns > 0 then
            local nearest = nil
            local minDist = math.huge
            local root = GetRootPart()
            
            if root then
                for _, spawn in pairs(spawns) do
                    local dist = (root.Position - spawn.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = spawn
                    end
                end
            end
            
            if nearest then
                root.CFrame = nearest.CFrame * CFrame.new(0, 5, 0)
                Library:MakeNotify({ Title = "Spawn", Content = "Teleport ke spawn!" })
            end
        else
            Library:MakeNotify({ Title = "Spawn", Content = "Tidak ada spawn location!" })
        end
    end
})

-- 5. KILL ALL
UniversalSection:AddButton({
    Title = "💀 Kill All (Visual)",
    Description = "Menjatuhkan semua player (efek visual)",
    Callback = function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = root.CFrame + Vector3.new(0, -100, 0)
                    Library:MakeNotify({ Title = "Kill", Content = p.Name .. " dijatuhkan!" })
                end
            end
        end
    end
})

-- 6. AUTO HEAL
UniversalSection:AddToggle({
    Title = "💚 Auto Heal",
    Description = "Otomatis menyembuhkan saat health rendah",
    Default = false,
    Callback = function(v)
        _G.AutoHeal = v
        if v then
            task.spawn(function()
                while _G.AutoHeal do
                    local hum = GetHumanoid()
                    if hum and hum.Health < 30 then
                        -- Cari item penyembuh di sekitar
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("Tool") and obj.Name:lower():find("heal") or obj.Name:lower():find("med") or obj.Name:lower():find("pot") then
                                local root = GetRootPart()
                                if root then
                                    local dist = (root.Position - obj.Parent:GetPivot().Position).Magnitude
                                    if dist < 10 then
                                        firetouchinterest(root, obj, 0)
                                        task.wait(0.05)
                                        firetouchinterest(root, obj, 1)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
            Library:MakeNotify({ Title = "Auto Heal", Content = "Aktif!" })
        else
            Library:MakeNotify({ Title = "Auto Heal", Content = "Mati!" })
        end
    end
})

-- 7. ANTI AFK
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
                        -- Kirim input palsu
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                        task.wait(0.01)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                        
                        -- Gerakkan mouse sedikit
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

-- 8. SPEED HACK
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

-- 9. JUMP HACK
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

-- 10. AUTO COLLECT
UniversalSection:AddToggle({
    Title = "📦 Auto Collect",
    Description = "Otomatis mengumpulkan item di sekitar",
    Default = false,
    Callback = function(v)
        _G.AutoCollect = v
        if v then
            task.spawn(function()
                while _G.AutoCollect do
                    local root = GetRootPart()
                    if root then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and obj.Parent and not obj.Parent:IsA("Character") then
                                local dist = (root.Position - obj.Position).Magnitude
                                if dist < 10 then
                                    -- Coba collect
                                    firetouchinterest(root, obj, 0)
                                    task.wait(0.05)
                                    firetouchinterest(root, obj, 1)
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
            Library:MakeNotify({ Title = "Auto Collect", Content = "Aktif!" })
        else
            Library:MakeNotify({ Title = "Auto Collect", Content = "Mati!" })
        end
    end
})

-- 11. SERVER INFO
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

-- 12. REJOIN
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

-- 13. RESET LOBBY (Visual)
UniversalSection:AddButton({
    Title = "🔄 Reset Lobby (Visual)",
    Description = "Reset semua efek visual di lobby",
    Callback = function()
        -- Hapus semua efek
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj ~= workspace.Terrain then
                if obj.Name:find("MDW") or obj.Name:find("Cage") or obj.Name:find("Troll") or 
                   obj.Name:find("Wall") or obj.Name:find("Ice") or obj.Name:find("Trap") or
                   obj.Name:find("Clone") or obj.Name:find("MDW_Skin") or obj.Name:find("Skin_") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
        Library:MakeNotify({ Title = "Reset", Content = "Lobby direset!" })
    end
})

-- 14. AUTO FARM (Universal)
UniversalSection:AddToggle({
    Title = "🌾 Auto Farm",
    Description = "Auto farm untuk berbagai game",
    Default = false,
    Callback = function(v)
        _G.AutoFarm = v
        if v then
            task.spawn(function()
                while _G.AutoFarm do
                    pcall(function()
                        -- Cari NPC/musuh di sekitar
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                                local hum = obj:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 and obj ~= LocalPlayer.Character then
                                    local root = obj:FindFirstChild("HumanoidRootPart")
                                    local myRoot = GetRootPart()
                                    if root and myRoot then
                                        local dist = (myRoot.Position - root.Position).Magnitude
                                        if dist < 50 then
                                            -- Teleport ke target
                                            myRoot.CFrame = root.CFrame * CFrame.new(0, 3, 3)
                                            -- Attack
                                            VirtualInputManager:SendMouseButtonEvent(1, true, game)
                                            task.wait(0.1)
                                            VirtualInputManager:SendMouseButtonEvent(1, false, game)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(_G.AutoFarmDelay or 0.5)
                end
            end)
            Library:MakeNotify({ Title = "Auto Farm", Content = "Aktif!" })
        else
            Library:MakeNotify({ Title = "Auto Farm", Content = "Mati!" })
        end
    end
})

UniversalSection:AddSlider({
    Title = "Auto Farm Delay",
    Description = "Jeda antar aksi Auto Farm",
    Minimum = 0.1,
    Maximum = 2,
    Default = 0.5,
    Callback = function(v)
        _G.AutoFarmDelay = v
    end
})

-- 15. AIMBOT (Simple)
UniversalSection:AddToggle({
    Title = "🎯 Aimbot",
    Description = "Auto aim ke player terdekat",
    Default = false,
    Callback = function(v)
        _G.Aimbot = v
        if v then
            task.spawn(function()
                while _G.Aimbot do
                    local closest = nil
                    local minDist = Config.AimbotRange or 200
                    local myRoot = GetRootPart()
                    
                    if myRoot then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character then
                                local root = p.Character:FindFirstChild("HumanoidRootPart")
                                if root then
                                    local dist = (myRoot.Position - root.Position).Magnitude
                                    if dist < minDist then
                                        minDist = dist
                                        closest = root
                                    end
                                end
                            end
                        end
                    end
                    
                    if closest then
                        -- Arahkan kamera ke target
                        local cam = workspace.CurrentCamera
                        local targetPos = closest.Position + Vector3.new(0, 1.5, 0)
                        local lookAt = CFrame.lookAt(cam.CFrame.p, targetPos)
                        cam.CFrame = cam.CFrame:Lerp(lookAt, 0.5)
                    end
                    
                    task.wait(0.05)
                end
            end)
            Library:MakeNotify({ Title = "Aimbot", Content = "Aktif!" })
        else
            Library:MakeNotify({ Title = "Aimbot", Content = "Mati!" })
        end
    end
})

UniversalSection:AddSlider({
    Title = "Aimbot Range",
    Description = "Jarak maksimal aimbot",
    Minimum = 50,
    Maximum = 500,
    Default = 200,
    Callback = function(v)
        Config.AimbotRange = v
    end
})

-- ==========================================
-- SETTINGS - CLEAR EFFECTS
-- ==========================================
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
                   obj.Name:find("MDW_Skin") or obj.Name:find("Skin_") then
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

-- ==========================================
-- SETTINGS - EXIT
-- ==========================================
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
        
        ToggleWallHack(false)
        ClearManualHighlights()
        CleanupSkin()
        
        Library:MakeNotify({ Title = "FCAL HUB", Content = "Shutdown...", Duration = 2 })
        task.wait(1)
        Window:Destroy()
    end
})

-- ==========================================
-- KEYBIND SECTION - QUICK KEYBINDS
-- ==========================================
local KeybindSection = SettingsTab:AddSection("⌨️ Quick Keybinds")

KeybindSection:AddButton({
    Title = "Set Fly Toggle Key",
    Description = "Tekan tombol untuk toggle Fly",
    Callback = function()
        Library:MakeNotify({ Title = "Keybind", Content = "Tekan tombol untuk Fly toggle..." })
        local keyConn
        keyConn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyConn:Disconnect()
                local key = input.KeyCode
                _G.FlyKey = key
                
                if _G.FlyKeyConn then _G.FlyKeyConn:Disconnect() end
                _G.FlyKeyConn = UserInputService.InputBegan:Connect(function(input2, processed2)
                    if processed2 then return end
                    if input2.KeyCode == _G.FlyKey then
                        _G.Fly = not _G.Fly
                        if _G.Fly then
                            StartFly()
                            Library:MakeNotify({ Title = "Fly", Content = "Fly ON!" })
                        else
                            if _G.FlyCon then _G.FlyCon:Disconnect() end
                            CleanupFly(GetRootPart())
                            local hum = GetHumanoid()
                            if hum then hum.PlatformStand = false end
                            Library:MakeNotify({ Title = "Fly", Content = "Fly OFF!" })
                        end
                    end
                end)
                
                Library:MakeNotify({ Title = "Keybind", Content = "Fly toggle: " .. tostring(key) })
            end
        end)
    end
})

KeybindSection:AddButton({
    Title = "Set ESP Toggle Key",
    Description = "Tekan tombol untuk toggle ESP",
    Callback = function()
        Library:MakeNotify({ Title = "Keybind", Content = "Tekan tombol untuk ESP toggle..." })
        local keyConn
        keyConn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyConn:Disconnect()
                local key = input.KeyCode
                _G.ESPKey = key
                
                if _G.ESPKeyConn then _G.ESPKeyConn:Disconnect() end
                _G.ESPKeyConn = UserInputService.InputBegan:Connect(function(input2, processed2)
                    if processed2 then return end
                    if input2.KeyCode == _G.ESPKey then
                        _G.ESP = not _G.ESP
                        if _G.ESP then
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and p.Character then CreateESPForPlayer(p) end
                            end
                            Library:MakeNotify({ Title = "ESP", Content = "ESP ON!" })
                        else
                            for _, p in pairs(Players:GetPlayers()) do 
                                RemoveESPForPlayer(p) 
                            end
                            Library:MakeNotify({ Title = "ESP", Content = "ESP OFF!" })
                        end
                    end
                end)
                
                Library:MakeNotify({ Title = "Keybind", Content = "ESP toggle: " .. tostring(key) })
            end
        end)
    end
})

KeybindSection:AddButton({
    Title = "Set NoClip Toggle Key",
    Description = "Tekan tombol untuk toggle NoClip",
    Callback = function()
        Library:MakeNotify({ Title = "Keybind", Content = "Tekan tombol untuk NoClip toggle..." })
        local keyConn
        keyConn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                keyConn:Disconnect()
                local key = input.KeyCode
                _G.NCKey = key
                
                if _G.NCKeyConn then _G.NCKeyConn:Disconnect() end
                _G.NCKeyConn = UserInputService.InputBegan:Connect(function(input2, processed2)
                    if processed2 then return end
                    if input2.KeyCode == _G.NCKey then
                        _G.NC = not _G.NC
                        Library:MakeNotify({ Title = "NoClip", Content = _G.NC and "ON!" or "OFF!" })
                    end
                end)
                
                Library:MakeNotify({ Title = "Keybind", Content = "NoClip toggle: " .. tostring(key) })
            end
        end)
    end
})

-- ==========================================
-- INITIALIZE
-- ==========================================
Library:Initialize()
ApplyTheme("Midnight")

Library:MakeNotify({ 
    Title = "FCAL HUB v2.2.0", 
    Content = "Ultimate Edition Loaded!\nDengan Premium Skins & Universal Features", 
    Duration = 5 
})

-- Auto update dropdown
Players.PlayerAdded:Connect(UpdateDropdown)
Players.PlayerRemoving:Connect(UpdateDropdown)
Players.PlayerRemoving:Connect(ClearESP)

-- NoClip Loop
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

print("FCAL HUB v2.2.0 - Ultimate Edition Loaded!")