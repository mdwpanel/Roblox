--[[
    FCAL HUB - LYNX GUI EDITION
    Version: 3.0.0 | ULTIMATE OPTIMIZED
    Dengan ESP Ringan, Anti-Admin & Troll Features
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
local ESP_Highlights = {}
local ESPLabels = {}
local ToggleKey = Enum.KeyCode.RightControl
local msg = "FCAL HUB ON TOP!"
local SpecTarget = ""
local SkinData = {}
local ActiveSkin = nil
local IsSkinActive = false
local SkinParts = {}

-- ==========================================
-- ANTI-KICK BYPASS (SUPERIOR)
-- ==========================================
local mt = getrawmetatable(game) 
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then 
        return nil 
    end
    if method == "Destroy" and self == game then 
        return nil 
    end
    return oldNamecall(self, ...)
end)

-- Block Remote Events yang mencurigakan
local oldFireServer = nil
local oldInvokeServer = nil

pcall(function()
    local oldMeta = getrawmetatable(game)
    local oldIndex = oldMeta.__index
    
    oldMeta.__index = newcclosure(function(self, key)
        if key == "FireServer" and self:IsA("RemoteEvent") then
            return function(_, ...)
                local args = {...}
                -- Block kick/ban remotes
                if type(args[1]) == "string" and (
                    args[1]:lower():find("kick") or 
                    args[1]:lower():find("ban") or 
                    args[1]:lower():find("kill") or
                    args[1]:lower():find("freeze") or
                    args[1]:lower():find("stun")
                ) then
                    return nil
                end
                return oldFireServer and oldFireServer(self, ...) or oldNamecall(self, ...)
            end
        end
        return oldIndex(self, key)
    end)
end)

setreadonly(mt, true)

-- ==========================================
-- ANTI-ADMIN DETECTION & PROTECTION
-- ==========================================
local AdminPlayers = {}
local AdminTools = {}

-- Detect admin tools
function DetectAdminTools()
    AdminTools = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            local name = obj.Name:lower()
            if name:find("admin") or name:find("mod") or name:find("staff") or 
               name:find("kick") or name:find("ban") or name:find("freeze") or
               name:find("god") or name:find("power") then
                table.insert(AdminTools, obj)
            end
        end
    end
    return #AdminTools
end

-- Detect admin players
function DetectAdmins()
    AdminPlayers = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Cek tag
            if player:GetAttribute("Admin") or player:GetAttribute("Mod") or 
               player:GetAttribute("Staff") or player:GetAttribute("Owner") then
                table.insert(AdminPlayers, player)
            end
            -- Cek team
            if player.Team and (player.Team.Name:lower():find("admin") or 
                player.Team.Name:lower():find("mod")) then
                table.insert(AdminPlayers, player)
            end
            -- Cek character tag
            if player.Character then
                if player.Character:FindFirstChild("AdminTag") or 
                   player.Character:FindFirstChild("ModTag") then
                    table.insert(AdminPlayers, player)
                end
            end
        end
    end
    return AdminPlayers
end

-- ANTI-FREEZE / ANTI-STUN (Admin proof)
local function AntiAdminFreeze()
    task.spawn(function()
        while true do
            task.wait(0.05)
            if LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if hum then
                    -- Reset semua status freeze/stun
                    if hum.PlatformStand then hum.PlatformStand = false end
                    if hum.Sit then hum.Sit = false end
                    hum.AutoRotate = true
                end
                
                if root then
                    -- Unanchor jika di-anchor
                    if root.Anchored then root.Anchored = false end
                    -- Reset velocity jika terlalu tinggi (bisa dari fling admin)
                    if root.AssemblyLinearVelocity.Magnitude > 1000 then
                        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                end
                
                -- Unfreeze semua part
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Anchored and part ~= root then
                        part.Anchored = false
                    end
                end
            end
        end
    end)
end

-- Anti-Ragdoll
local function AntiRagdoll()
    task.spawn(function()
        while true do
            task.wait(0.1)
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.PlatformStand then
                hum.PlatformStand = false
            end
        end
    end)
end

-- Anti-Teleport (admin teleport block)
local function AntiAdminTeleport()
    local lastPos = Vector3.new(0, 0, 0)
    local positionHistory = {}
    
    task.spawn(function()
        while true do
            task.wait(0.2)
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local currentPos = root.Position
                table.insert(positionHistory, currentPos)
                if #positionHistory > 10 then table.remove(positionHistory, 1) end
                
                -- Deteksi teleport paksa (perubahan posisi mendadak)
                if #positionHistory >= 2 then
                    local lastPos = positionHistory[#positionHistory - 1]
                    local dist = (currentPos - lastPos).Magnitude
                    
                    -- Jika teleport lebih dari 200 studs dan bukan dari player sendiri
                    if dist > 200 and not _G.TapTP and not _G.AutoCPAll then
                        -- Cek apakah ada admin yang mencoba teleport
                        for _, admin in pairs(AdminPlayers) do
                            if admin.Character then
                                local adminRoot = admin.Character:FindFirstChild("HumanoidRootPart")
                                if adminRoot and (adminRoot.Position - lastPos).Magnitude < 50 then
                                    -- Kembalikan ke posisi sebelumnya
                                    root.CFrame = CFrame.new(lastPos)
                                    Library:MakeNotify({
                                        Title = "🛡️ Anti-Admin",
                                        Content = "Admin " .. admin.Name .. " mencoba teleport Anda!",
                                        Duration = 2
                                    })
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Start protection
AntiAdminFreeze()
AntiRagdoll()
AntiAdminTeleport()

-- ==========================================
-- ADMIN TROLL FEATURES
-- ==========================================
function IsAdmin(player)
    for _, admin in pairs(AdminPlayers) do
        if admin.Name == player.Name then return true end
    end
    return false
end

function GetAdminTarget()
    if #AdminPlayers == 0 then
        Library:MakeNotify({ Title = "⚠️ Error", Content = "Tidak ada admin terdeteksi!", Duration = 3 })
        return nil
    end
    
    -- Prioritaskan yang paling dekat
    local closest = nil
    local minDist = math.huge
    local myRoot = GetRootPart()
    
    if myRoot then
        for _, admin in pairs(AdminPlayers) do
            if admin.Character then
                local root = admin.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = admin
                    end
                end
            end
        end
    end
    
    return closest or AdminPlayers[1]
end

-- ==========================================
-- TROLL ADMIN SECTION (NEW)
-- ==========================================
local function GetTrollTarget()
    if #AdminPlayers == 0 then
        Library:MakeNotify({ Title = "⚠️ Error", Content = "Tidak ada admin terdeteksi!", Duration = 3 })
        return nil
    end
    
    local target = GetAdminTarget()
    if not target then
        Library:MakeNotify({ Title = "⚠️ Error", Content = "Tidak ada admin valid!", Duration = 3 })
        return nil
    end
    
    if not target.Character then
        Library:MakeNotify({ Title = "⚠️ Error", Content = "Admin tidak memiliki karakter!", Duration = 3 })
        return nil
    end
    
    return target
end

-- ==========================================
-- WINDOW CREATION
-- ==========================================
local Window = Library:Window({
    Title = "FCAL HUB",
    Footer = "v3.0.0 | Anti-Admin Edition"
})

-- ==========================================
-- HELPER FUNCTIONS (OPTIMIZED)
-- ==========================================

function ClearESP()
    for _, hl in pairs(ESP_Highlights) do
        pcall(function() hl:Destroy() end)
    end
    ESP_Highlights = {}
end

function ClearManualHighlights()
    for _, hl in pairs(ManualHighlights) do
        pcall(function() hl:Destroy() end)
    end
    ManualHighlights = {}
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
    if IsAdmin(player) then return Color3.fromRGB(255, 0, 255) end -- Admin warna ungu
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

-- ==========================================
-- OPTIMIZED ESP (LIGHTWEIGHT)
-- ==========================================
function CreateESPForPlayer(player)
    if player == LocalPlayer or not player.Character then return end
    
    if not ESP_Highlights[player] then
        local highlight = Instance.new("Highlight")
        highlight.Name = "MDW_ESP"
        highlight.Adornee = player.Character
        highlight.FillColor = GetESPColor(player)
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.OutlineTransparency = 0.2
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = player.Character
        ESP_Highlights[player] = highlight
    end
end

function RemoveESPForPlayer(player)
    if ESP_Highlights[player] then
        pcall(function() ESP_Highlights[player]:Destroy() end)
        ESP_Highlights[player] = nil
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
}

function CreatePremiumSkin(character)
    if not character then return end
    
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
    
    local skinData = Instance.new("StringValue")
    skinData.Name = "SkinData"
    skinData.Value = HttpService:JSONEncode({
        Name = ActiveSkin.Name,
        Color = ActiveSkin.Color,
        Type = ActiveSkin.Type,
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
local AntiAdminTab = Window:AddTab({ Name = "🛡️ Anti-Admin", Icon = "shield" })
local TrollTab = Window:AddTab({ Name = "🎭 Troll", Icon = "skull" })

-- ==========================================
-- MAIN TAB - QUICK ACTIONS
-- ==========================================
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

-- ==========================================
-- FLY SECTION
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
-- TAB AUTO CP
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
    Title = "Auto CP All Mountain",
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
-- GAME TAB - VISUAL ESP (LIGHTWEIGHT)
-- ==========================================
local VisualSection = GameTab:AddSection("👁️ Visual ESP & Tracking")

VisualSection:AddToggle({
    Title = "ESP Players (Highlight)",
    Description = "Highlight pemain dengan warna (Ringan)",
    Default = false,
    Callback = function(v)
        _G.ESP = v
        if v then
            -- Deteksi admin
            DetectAdmins()
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then 
                    CreateESPForPlayer(p) 
                end
            end
            
            if not _G.PlayerAddedConn then
                _G.PlayerAddedConn = Players.PlayerAdded:Connect(function(p)
                    p.CharacterAdded:Connect(function()
                        if _G.ESP then 
                            task.wait(0.5) 
                            CreateESPForPlayer(p) 
                            DetectAdmins()
                        end
                    end)
                end)
            end
            
            -- Update admin detection periodically
            if not _G.AdminDetectLoop then
                _G.AdminDetectLoop = task.spawn(function()
                    while _G.ESP do
                        task.wait(5)
                        DetectAdmins()
                        -- Update ESP colors for admins
                        for _, p in pairs(Players:GetPlayers()) do
                            if ESP_Highlights[p] and IsAdmin(p) then
                                ESP_Highlights[p].FillColor = Color3.fromRGB(255, 0, 255)
                            end
                        end
                    end
                end)
            end
            
            Library:MakeNotify({ Title = "ESP ON", Content = "Admin terdeteksi: " .. #AdminPlayers .. " orang" })
        else
            if _G.PlayerAddedConn then 
                _G.PlayerAddedConn:Disconnect() 
                _G.PlayerAddedConn = nil 
            end
            if _G.AdminDetectLoop then
                _G.AdminDetectLoop = nil
            end
            ClearESP()
            Library:MakeNotify({ Title = "ESP OFF", Content = "ESP dimatikan" })
        end
    end
})

VisualSection:AddToggle({
    Title = "Deteksi Admin Auto",
    Description = "Deteksi dan tandai admin di server",
    Default = false,
    Callback = function(v)
        _G.AdminDetect = v
        if v then
            task.spawn(function()
                while _G.AdminDetect do
                    task.wait(3)
                    local admins = DetectAdmins()
                    if #admins > 0 then
                        local names = {}
                        for _, a in pairs(admins) do
                            table.insert(names, a.Name)
                        end
                        Library:MakeNotify({
                            Title = "🛡️ Admin Terdeteksi",
                            Content = table.concat(names, ", "),
                            Duration = 3
                        })
                    end
                end
            end)
            Library:MakeNotify({ Title = "Admin Detect", Content = "Aktif!" })
        else
            Library:MakeNotify({ Title = "Admin Detect", Content = "Mati!" })
        end
    end
})

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
    Title = "Clear All Highlights",
    Callback = function()
        ClearManualHighlights()
        ClearESP()
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
        ActiveSkin = PremiumSkins[1]
        Library:MakeNotify({ Title = "Skin", Content = "Skin dihapus!" })
    end
})

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

-- 3. ANTI AFK
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

-- 4. SPEED HACK
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

-- 5. JUMP HACK
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

-- 6. AUTO COLLECT
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

-- 7. SERVER INFO
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
                "Players: %d/%d\nPing: %dms\nAdmin: %d\nServer: %s\nTime: %s",
                #players,
                maxPlayers,
                math.floor(ping * 1000),
                #AdminPlayers,
                game.JobId or "Unknown",
                os.date("%H:%M:%S")
            ),
            Duration = 8
        })
    end
})

-- 8. REJOIN
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

-- 9. RESET LOBBY (Visual)
UniversalSection:AddButton({
    Title = "🔄 Reset Lobby (Visual)",
    Description = "Reset semua efek visual di lobby",
    Callback = function()
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

-- 10. AUTO FARM (Universal)
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
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                                local hum = obj:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 and obj ~= LocalPlayer.Character then
                                    local root = obj:FindFirstChild("HumanoidRootPart")
                                    local myRoot = GetRootPart()
                                    if root and myRoot then
                                        local dist = (myRoot.Position - root.Position).Magnitude
                                        if dist < 50 then
                                            myRoot.CFrame = root.CFrame * CFrame.new(0, 3, 3)
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

-- 11. AIMBOT (Simple)
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
-- ANTI-ADMIN TAB
-- ==========================================
local AntiAdminSection = AntiAdminTab:AddSection("🛡️ Anti-Admin Protection")

AntiAdminSection:AddButton({
    Title = "🔍 Scan Admin Sekarang",
    Description = "Deteksi admin di server",
    Callback = function()
        DetectAdmins()
        DetectAdminTools()
        if #AdminPlayers > 0 then
            local names = {}
            for _, a in pairs(AdminPlayers) do
                table.insert(names, a.Name)
            end
            Library:MakeNotify({
                Title = "🛡️ Admin Terdeteksi",
                Content = table.concat(names, ", "),
                Duration = 5
            })
        else
            Library:MakeNotify({
                Title = "✅ Aman",
                Content = "Tidak ada admin terdeteksi",
                Duration = 3
            })
        end
    end
})

AntiAdminSection:AddToggle({
    Title = "🛡️ Anti-Kick Total",
    Description = "Mencegah admin mengkick Anda",
    Default = true,
    Callback = function(v)
        _G.AntiKick = v
        Library:MakeNotify({ Title = "Anti-Kick", Content = v and "Aktif!" or "Mati!" })
    end
})

AntiAdminSection:AddToggle({
    Title = "🛡️ Anti-Freeze/Stun",
    Description = "Mencegah admin membekukan Anda",
    Default = true,
    Callback = function(v)
        _G.AntiFreeze = v
        Library:MakeNotify({ Title = "Anti-Freeze", Content = v and "Aktif!" or "Mati!" })
    end
})

AntiAdminSection:AddToggle({
    Title = "🛡️ Anti-Teleport",
    Description = "Mencegah admin teleport Anda",
    Default = true,
    Callback = function(v)
        _G.AntiAdminTP = v
        Library:MakeNotify({ Title = "Anti-Teleport", Content = v and "Aktif!" or "Mati!" })
    end
})

AntiAdminSection:AddToggle({
    Title = "🛡️ Anti-Ragdoll",
    Description = "Mencegah admin membuat Anda ragdoll",
    Default = true,
    Callback = function(v)
        _G.AntiRagdoll = v
        Library:MakeNotify({ Title = "Anti-Ragdoll", Content = v and "Aktif!" or "Mati!" })
    end
})

-- ==========================================
-- TROLL TAB - JAHILI ADMIN & PLAYER
-- ==========================================

-- Troll Admin Section
local TrollAdminSection = TrollTab:AddSection("👑 Jahili Admin")

TrollAdminSection:AddButton({
    Title = "💥 Fling Admin Terdekat",
    Description = "Lempar admin terdekat ke langit",
    Callback = function()
        local target = GetAdminTarget()
        if not target then return end
        
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        root.AssemblyLinearVelocity = Vector3.new(
            math.random(-200, 200),
            math.random(400, 800),
            math.random(-200, 200)
        )
        
        Library:MakeNotify({ 
            Title = "💥 FLING!", 
            Content = "Admin " .. target.Name .. " terbang!", 
            Duration = 3 
        })
    end
})

TrollAdminSection:AddButton({
    Title = "🔒 Kurung Admin",
    Description = "Kurung admin di dalam kandang",
    Callback = function()
        local target = GetAdminTarget()
        if not target then return end
        
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local pos = root.Position
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
            p.BrickColor = BrickColor.new("Bright red")
            p.Transparency = 0.3
            p.Material = Enum.Material.Glass
            p.Parent = workspace
            table.insert(parts, p)
        end
        
        local roof = Instance.new("Part")
        roof.Size = Vector3.new(13, 1, 13)
        roof.Position = pos + Vector3.new(0, 6, 0)
        roof.Anchored = true
        roof.BrickColor = BrickColor.new("Bright red")
        roof.Transparency = 0.3
        roof.Material = Enum.Material.Glass
        roof.Parent = workspace
        table.insert(parts, roof)
        
        Library:MakeNotify({ 
            Title = "🔒 KURUNG!", 
            Content = "Admin " .. target.Name .. " dikurung!", 
            Duration = 3 
        })
        
        task.wait(10)
        for _, p in pairs(parts) do
            pcall(function() p:Destroy() end)
        end
    end
})

TrollAdminSection:AddButton({
    Title = "🌀 Zona Gravitasi Admin",
    Description = "Buat zona gravitasi tinggi di sekitar admin",
    Callback = function()
        local target = GetAdminTarget()
        if not target then return end
        
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local pos = root.Position
        
        for i = 1, 20 do
            local zone = Instance.new("Part")
            zone.Shape = Enum.PartType.Ball
            zone.Size = Vector3.new(5, 5, 5)
            zone.Position = pos + Vector3.new(
                math.random(-15, 15),
                math.random(5, 20),
                math.random(-15, 15)
            )
            zone.BrickColor = BrickColor.new("Bright purple")
            zone.Transparency = 0.6
            zone.Anchored = true
            zone.CanCollide = false
            zone.Parent = workspace
            
            local gravity = Instance.new("BodyForce")
            gravity.Force = Vector3.new(0, -2000, 0)
            gravity.Parent = zone
        end
        
        Library:MakeNotify({ 
            Title = "🌀 GRAVITASI!", 
            Content = "Zona gravitasi di sekitar " .. target.Name, 
            Duration = 3 
        })
        
        task.wait(5)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BodyForce") and obj.Force.Y < 0 then
                pcall(function() obj.Parent:Destroy() end)
            end
        end
    end
})

TrollAdminSection:AddButton({
    Title = "🕶️ Butakan Admin",
    Description = "Buat layar admin menjadi hitam",
    Callback = function()
        local target = GetAdminTarget()
        if not target then return end
        
        local gui = Instance.new("ScreenGui")
        gui.Name = "BlindEffect"
        gui.Parent = target.PlayerGui
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        frame.BackgroundTransparency = 0
        frame.Parent = gui
        
        Library:MakeNotify({ 
            Title = "🕶️ BUTA!", 
            Content = "Admin " .. target.Name .. " dibutakan!", 
            Duration = 3 
        })
        
        task.wait(4)
        pcall(function() gui:Destroy() end)
    end
})

TrollAdminSection:AddButton({
    Title = "🔄 Loop Teleport Admin",
    Description = "Teleport admin bolak-balik",
    Callback = function()
        local target = GetAdminTarget()
        if not target then return end
        
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local pos1 = root.Position
        local pos2 = pos1 + Vector3.new(math.random(-30, 30), 5, math.random(-30, 30))
        
        for i = 1, 10 do
            if i % 2 == 0 then
                root.CFrame = CFrame.new(pos1)
            else
                root.CFrame = CFrame.new(pos2)
            end
            task.wait(0.3)
        end
        
        Library:MakeNotify({ 
            Title = "🔄 LOOP!", 
            Content = "Admin " .. target.Name .. " di-loop!", 
            Duration = 3 
        })
    end
})

TrollAdminSection:AddButton({
    Title = "💀 Kill Admin (Visual)",
    Description = "Jatuhkan admin ke dalam void",
    Callback = function()
        local target = GetAdminTarget()
        if not target then return end
        
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        root.CFrame = root.CFrame + Vector3.new(0, -200, 0)
        
        Library:MakeNotify({ 
            Title = "💀 KILL!", 
            Content = "Admin " .. target.Name .. " dijatuhkan!", 
            Duration = 3 
        })
    end
})

TrollAdminSection:AddButton({
    Title = "🔊 Spam Sound Admin",
    Description = "Putar suara berisik di admin",
    Callback = function()
        local target = GetAdminTarget()
        if not target then return end
        
        for i = 1, 5 do
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://138526029"
            sound.Volume = 10
            sound.Parent = target.Character and target.Character.Head or workspace
            sound:Play()
            task.wait(0.3)
            pcall(function() sound:Destroy() end)
        end
        
        Library:MakeNotify({ 
            Title = "🔊 SPAM!", 
            Content = "Sound diputar di " .. target.Name, 
            Duration = 3 
        })
    end
})

-- Troll Player Section
local TrollPlayerSection = TrollTab:AddSection("🎭 Jahili Player Lain")

TrollPlayerSection:AddButton({
    Title = "💨 Dorong dari Tebing",
    Callback = function()
        if SelectedTarget == "" or SelectedTarget == "Tidak ada pemain" then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Pilih pemain dulu!" })
            return 
        end
        
        local target = Players:FindFirstChild(SelectedTarget)
        if not target or not target.Character then return end
        
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local dir = root.CFrame.LookVector * -150
        root.AssemblyLinearVelocity = Vector3.new(dir.X, 50, dir.Z)
        
        Library:MakeNotify({ 
            Title = "💨 DORONG!", 
            Content = target.Name .. " didorong!", 
            Duration = 3 
        })
    end
})

TrollPlayerSection:AddButton({
    Title = "🚀 Fling Player",
    Callback = function()
        if SelectedTarget == "" or SelectedTarget == "Tidak ada pemain" then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Pilih pemain dulu!" })
            return 
        end
        
        local target = Players:FindFirstChild(SelectedTarget)
        if not target or not target.Character then return end
        
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        root.AssemblyLinearVelocity = Vector3.new(
            math.random(-200, 200),
            math.random(300, 600),
            math.random(-200, 200)
        )
        
        Library:MakeNotify({ 
            Title = "🚀 FLING!", 
            Content = target.Name .. " terbang!", 
            Duration = 3 
        })
    end
})

TrollPlayerSection:AddButton({
    Title = "🔒 Kandang Player",
    Callback = function()
        if SelectedTarget == "" or SelectedTarget == "Tidak ada pemain" then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Pilih pemain dulu!" })
            return 
        end
        
        local target = Players:FindFirstChild(SelectedTarget)
        if not target or not target.Character then return end
        
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local pos = root.Position
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
            p.Transparency = 0.3
            p.Material = Enum.Material.Glass
            p.Parent = workspace
            table.insert(parts, p)
        end
        
        local roof = Instance.new("Part")
        roof.Size = Vector3.new(13, 1, 13)
        roof.Position = pos + Vector3.new(0, 6, 0)
        roof.Anchored = true
        roof.BrickColor = BrickColor.new("Bright blue")
        roof.Transparency = 0.3
        roof.Material = Enum.Material.Glass
        roof.Parent = workspace
        table.insert(parts, roof)
        
        Library:MakeNotify({ 
            Title = "🔒 KANDANG!", 
            Content = target.Name .. " dikurung!", 
            Duration = 3 
        })
        
        task.wait(8)
        for _, p in pairs(parts) do
            pcall(function() p:Destroy() end)
        end
    end
})

TrollPlayerSection:AddButton({
    Title = "❄️ Lantai Licin",
    Callback = function()
        if SelectedTarget == "" or SelectedTarget == "Tidak ada pemain" then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Pilih pemain dulu!" })
            return 
        end
        
        local target = Players:FindFirstChild(SelectedTarget)
        if not target or not target.Character then return end
        
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local pos = root.Position
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
        
        Library:MakeNotify({ 
            Title = "❄️ LICIN!", 
            Content = "Lantai es di sekitar " .. target.Name, 
            Duration = 3 
        })
        
        task.wait(5)
        for _, ice in pairs(ices) do
            pcall(function() ice:Destroy() end)
        end
    end
})

TrollPlayerSection:AddButton({
    Title = "👥 Clone Player",
    Callback = function()
        if SelectedTarget == "" or SelectedTarget == "Tidak ada pemain" then 
            Library:MakeNotify({ Title = "⚠️ Error", Content = "Pilih pemain dulu!" })
            return 
        end
        
        local target = Players:FindFirstChild(SelectedTarget)
        if not target or not target.Character then return end
        
        local clone = target.Character:Clone()
        clone.Parent = workspace
        clone:SetPrimaryPartCFrame(target.Character:GetPivot() + Vector3.new(10, 0, 10))
        clone.Name = "Clone_of_" .. target.Name
        
        Library:MakeNotify({ 
            Title = "👥 CLONE!", 
            Content = "Clone " .. target.Name .. " muncul!", 
            Duration = 3 
        })
        
        task.wait(8)
        pcall(function() clone:Destroy() end)
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
        ClearESP()
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
        _G.AntiRagdoll = false
        _G.AntiVoid = false
        _G.AntiFreeze = false
        _G.Wiggle = false
        _G.Headlight = false
        _G.XRay = false
        _G.Fullbright = false
        _G.Freecam = false
        _G.Spam = false
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
        _G.AntiKick = false
        _G.AntiAdminTP = false
        
        ToggleWallHack(false)
        ClearManualHighlights()
        ClearESP()
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
                            DetectAdmins()
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and p.Character then CreateESPForPlayer(p) end
                            end
                            Library:MakeNotify({ Title = "ESP", Content = "ESP ON!" })
                        else
                            ClearESP()
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

-- Start admin detection
DetectAdmins()

Library:MakeNotify({ 
    Title = "FCAL HUB v3.0.0", 
    Content = "Anti-Admin Edition Loaded!\nDengan Premium Skins & Troll Features", 
    Duration = 5 
})

Players.PlayerAdded:Connect(function()
    task.wait(1)
    UpdateDropdown()
    DetectAdmins()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(1)
    UpdateDropdown()
    DetectAdmins()
end)

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

print("FCAL HUB v3.0.0 - Anti-Admin Edition Loaded!")