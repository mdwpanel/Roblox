--[[
    FCAL HUB - LYNX GUI EDITION (FIXED - NO DETECTION)
    Version: 1.0.9 | FULL FEATURES + TROLL MOUNTAIN + ESP IMPROVED + GOD MODE
    FIX: Removed getrawmetatable Anti-Kick (penyebab error 267)
    ADDED: God Mode (Kebal Serangan)
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

-- ==========================================
-- ⚠️ ANTI-KICK TELAH DIHAPUS (PENYEBAB ERROR 267)
-- ==========================================

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
_G.AntiKick = false  -- FIX: Default false
_G.AdminDetect = false
_G.Hitbox = false
_G.CPDelay = 2.0
_G.Fly = false
_G.AirWalk = false
_G.AutoWalkJSON = false
_G.WalkingAntiVoid = false
_G.AntiFreeze = false 
_G.Wiggle = false
_G.KillerWarn = false
_G.AutoSkillMobile = false
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
_G.GodMode = false  -- NEW: God Mode

local Config = {
    WalkSpeedDefault = 16,
    JumpPowerDefault = 50,
    GravityDefault = 196,
    Theme = "Midnight", 
    FlySpeed = 100,
}

-- ==========================================
-- WINDOW CREATION
-- ==========================================
local Window = Library:Window({
    Title = "MDW",
    Footer = "v1.0.9 | Client Sided"
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

function ClearAllHighlights()
    ClearManualHighlights()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") then
            pcall(function() obj:Destroy() end)
        end
    end
end

function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                local rootPart = character.HumanoidRootPart
                local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    if not ESP_Objects[player] then
                        ESP_Objects[player] = {
                            Box = Drawing.new("Square"),
                            Line = Drawing.new("Line"),
                            Skeleton = {}
                        }
                    end

                    local color = GetESPColor(player)
                    local objects = ESP_Objects[player]

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

                    if _G.LineESP then
                        objects.Line.Visible = true
                        objects.Line.Color = color
                        objects.Line.Thickness = 1
                        objects.Line.From = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y)
                        objects.Line.To = Vector2.new(pos.X, pos.Y)
                    else
                        objects.Line.Visible = false
                    end
                    
                    -- Skeleton ESP
                    if _G.SkeletonESP then
                        UpdateSkeletonESP(player, objects)
                    else
                        for _, line in pairs(objects.Skeleton) do
                            line.Visible = false
                        end
                    end
                else
                    if ESP_Objects[player] then
                        ESP_Objects[player].Box.Visible = false
                        ESP_Objects[player].Line.Visible = false
                        for _, line in pairs(ESP_Objects[player].Skeleton) do
                            line.Visible = false
                        end
                    end
                end
            else
                ClearESP(player)
            end
        end
    end
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

-- ==========================================
-- WALLHACK FUNCTION
-- ==========================================
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

local MountPrankActive = false
local ShieldTools = {"Shield", "Perisai", "Protector", "PrankShield"}

-- Fungsi untuk mencari dan mengaktifkan shield
local function FindAndUseShield()
    local char = LocalPlayer.Character
    if not char then return false end
    
    -- Cek di tangan
    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool then
        for _, name in pairs(ShieldTools) do
            if currentTool.Name:find(name) then
                return true -- Sudah memegang shield
            end
        end
    end
    
    -- Cari di backpack
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, name in pairs(ShieldTools) do
                if tool.Name:find(name) then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:EquipTool(tool)
                        task.wait(0.3)
                        -- Aktifkan shield (asumsi klik kanan atau tombol tertentu)
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.ButtonR1, false, game)
                            task.wait(0.1)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.ButtonR1, false, game)
                        end)
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Fungsi untuk menonaktifkan script prank yang mencurigakan
local function DisablePrankScripts()
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("LocalScript") then
            local name = obj.Name:lower()
            if name:find("prank") or name:find("effect") or name:find("trap") or 
               name:find("stun") or name:find("push") or name:find("launch") then
                pcall(function()
                    obj.Disabled = true
                    print("Disabled script:", obj.Name)
                end)
            end
        end
        
        -- Nonaktifkan juga beberapa objek yang mencurigakan
        if obj:IsA("ObjectValue") or obj:IsA("StringValue") then
            local name = obj.Name:lower()
            if name:find("prank") or name:find("effect") or name:find("status") then
                pcall(function()
                    obj:Destroy()
                    print("Removed value:", obj.Name)
                end)
            end
        end
    end
end

-- Fungsi untuk memonitor dan memblokir RemoteEvent prank
local function BlockPrankRemotes()
    local blocked = 0
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("prank") or name:find("effect") or name:find("trap") or 
               name:find("stun") or name:find("push") or name:find("launch") or
               name:find("damage") or name:find("kill") then
                
                -- Coba blokir dengan menimpa fungsi
                pcall(function()
                    if obj:IsA("RemoteEvent") then
                        local oldFire = obj.FireServer
                        obj.FireServer = function(...)
                            if MountPrankActive then
                                print("Blocked prank remote:", obj.Name)
                                return
                            end
                            return oldFire(obj, ...)
                        end
                    end
                    blocked = blocked + 1
                end)
            end
        end
    end
    
    print("Blocked " .. blocked .. " remote events")
end

-- Fungsi utama Mount Prank Protection
local function EnableMountPrankProtection()
    MountPrankActive = true
    
    task.spawn(function()
        while MountPrankActive do
            task.wait(0.5)
            
            -- 1. Cari dan aktifkan shield
            FindAndUseShield()
            
            -- 2. Nonaktifkan script prank
            DisablePrankScripts()
            
            -- 3. Cegah ragdoll dan stun
            local hum = GetHumanoid()
            if hum then
                if hum.PlatformStand then hum.PlatformStand = false end
                if hum.Sit then hum.Sit = false end
                -- Cegah state physics (ragdoll)
                pcall(function()
                    if hum:GetState() == Enum.HumanoidStateType.Physics then
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end)
            end
            
            -- 4. Cegah parts terlempar
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part:IsA("Part") then
                        pcall(function()
                            if part:FindFirstChild("BodyVelocity") then
                                part.BodyVelocity:Destroy()
                            end
                            if part:FindFirstChild("BodyForce") then
                                part.BodyForce:Destroy()
                            end
                            -- Reset posisi jika terlalu jauh
                            local root = GetRootPart()
                            if root and part ~= root and (part.Position - root.Position).Magnitude > 20 then
                                part.CFrame = root.CFrame * CFrame.new(0, -2, 0)
                            end
                        end)
                    end
                end
            end
        end
    end)
    
    -- Block remote events sekali saja
    task.wait(2)
    BlockPrankRemotes()
    
    Library:MakeNotify({ 
        Title = "🛡️ Mount Prank Protection", 
        Content = "Perlindungan untuk Mount Prank diaktifkan!", 
        Duration = 3 
    })
end
local MountPrankWeapons = {}
local CoinMultiplier = 1
local AutoCollectCoins = false
local SpawnAllWeapons = false
local CoinHackActive = false
local CoinValuesFound = {}
local RemoteHackActive = false
local OriginalCoinValue = 1600 -- Nilai asli coin Anda

local function HackPurchaseRemotes()
    local remotes = {}
    
    -- Cari semua RemoteEvent dan RemoteFunction
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            -- Cari yang berhubungan dengan pembelian
            if name:find("purchase") or name:find("buy") or name:find("shop") or 
               name:find("coin") or name:find("money") or name:find("spend") or
               name:find("pay") or name:find("cost") or name:find("skill") or
               name:find("upgrade") or name:find("prank") then
                table.insert(remotes, obj)
                print("Found remote:", obj.Name)
            end
        end
    end
    
    -- Modifikasi setiap remote
    for _, remote in pairs(remotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                -- Simpan fungsi asli
                local oldFire = remote.FireServer
                
                -- Override FireServer
                remote.FireServer = function(self, ...)
                    local args = {...}
                    print("Remote fired:", remote.Name, "with args:", args)
                    
                    -- Cek apakah argumen mengandung coin
                    for i, arg in pairs(args) do
                        if type(arg) == "number" and arg > 0 then
                            -- Ubah nilai coin menjadi 0 atau kecil
                            args[i] = 0
                            print("Modified argument:", i, "from", arg, "to 0")
                        end
                        if type(arg) == "string" and arg:find("coin") then
                            -- Ubah string yang berisi coin
                            args[i] = arg:gsub("%d+", "0")
                            print("Modified string:", i, "to", args[i])
                        end
                    end
                    
                    -- Panggil fungsi asli dengan argumen yang dimodifikasi
                    return oldFire(self, unpack(args))
                end
                print("Hacked remote:", remote.Name)
            end
            
            if remote:IsA("RemoteFunction") then
                -- Simpan fungsi asli
                local oldInvoke = remote.InvokeServer
                
                -- Override InvokeServer
                remote.InvokeServer = function(self, ...)
                    local args = {...}
                    print("Remote invoked:", remote.Name, "with args:", args)
                    
                    -- Cek apakah argumen mengandung coin
                    for i, arg in pairs(args) do
                        if type(arg) == "number" and arg > 0 then
                            args[i] = 0
                            print("Modified argument:", i, "from", arg, "to 0")
                        end
                    end
                    
                    -- Panggil fungsi asli
                    return oldInvoke(self, unpack(args))
                end
                print("Hacked remote function:", remote.Name)
            end
        end)
    end
    
    return #remotes
end

-- Fungsi untuk memodifikasi request pembelian
local function HookPurchaseRequests()
    -- Cari semua fungsi yang berhubungan dengan pembelian
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            pcall(function()
                -- Coba cari fungsi di script
                local env = getfenv(obj)
                if env then
                    -- Cari fungsi yang mungkin digunakan untuk pembelian
                    for name, func in pairs(env) do
                        if type(func) == "function" then
                            local nameLower = name:lower()
                            if nameLower:find("purchase") or nameLower:find("buy") or 
                               nameLower:find("spend") or nameLower:find("pay") or
                               nameLower:find("cost") or nameLower:find("coin") then
                                -- Override fungsi
                                local oldFunc = func
                                env[name] = function(...)
                                    print("Hooked function:", name)
                                    local args = {...}
                                    -- Modifikasi argumen
                                    for i, arg in pairs(args) do
                                        if type(arg) == "number" and arg > 0 then
                                            args[i] = 0
                                        end
                                    end
                                    return oldFunc(unpack(args))
                                end
                                print("Hooked function:", name)
                            end
                        end
                    end
                end
            end)
        end
    end
end

-- Fungsi untuk memonitor dan memblokir error "Coin tidak cukup!"
local function BlockCoinError()
    -- Cari semua GUI yang menampilkan error
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local text = obj.Text or ""
            if text:find("Coin tidak cukup") or text:find("not enough") then
                -- Sembunyikan error
                pcall(function()
                    obj.Visible = false
                    obj.Text = ""
                    print("Blocked coin error:", obj.Name)
                end)
            end
        end
    end
end

-- Fungsi utama untuk hack pembelian
local function HackPurchases()
    local total = 0
    
    -- 1. Hack RemoteEvent
    local count1 = HackPurchaseRemotes()
    total = total + count1
    
    -- 2. Hook fungsi pembelian
    HookPurchaseRequests()
    
    -- 3. Block error
    BlockCoinError()
    
    -- 4. Monitor dan block error terus-menerus
    task.spawn(function()
        while true do
            task.wait(1)
            BlockCoinError()
        end
    end)
    
    print("Purchase hack selesai! Modified:", total, "remotes")
    return total
end

local function FindAllCoinValuesAggressive()
    local allValues = {}
    local searchPaths = {
        LocalPlayer,
        LocalPlayer.Character,
        LocalPlayer.PlayerGui,
        LocalPlayer.Backpack,
        workspace,
        game:GetService("ReplicatedStorage"),
        game:GetService("ServerStorage"),
        game:GetService("Lighting"),
        game:GetService("SoundService")
    }
    
    for _, path in pairs(searchPaths) do
        if path then
            for _, obj in pairs(path:GetDescendants()) do
                -- Cari semua NumberValue dan IntValue
                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                    local name = obj.Name:lower()
                    -- Cek apakah ini nilai coin (case insensitive)
                    if name:find("coin") or name:find("money") or name:find("gold") or 
                       name:find("currency") or name:find("point") or name:find("gem") or
                       name:find("cash") or name:find("score") or name:find("token") or
                       name:find("credit") or name:find("wallet") or name:find("balance") or
                       name:find("fund") or name:find("diamond") or name:find("crystal") or
                       name:find("soul") or name:find("shard") or name:find("emerald") or
                       name:find("ruby") or name:find("sapphire") or name:find("coin") then
                        table.insert(allValues, obj)
                        CoinValuesFound[obj] = true
                    end
                end
                
                -- Cari juga StringValue yang mungkin berisi angka coin
                if obj:IsA("StringValue") then
                    local name = obj.Name:lower()
                    if name:find("coin") or name:find("money") or name:find("gold") or 
                       name:find("currency") or name:find("point") or name:find("gem") or
                       name:find("cash") or name:find("score") or name:find("token") then
                        if tonumber(obj.Value) then
                            table.insert(allValues, obj)
                            CoinValuesFound[obj] = true
                        end
                    end
                end
                
                -- Cari Attribute yang mungkin berisi coin
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local attrs = obj:GetAttributes()
                    for attrName, attrValue in pairs(attrs) do
                        local name = attrName:lower()
                        if name:find("coin") or name:find("money") or name:find("gold") or 
                           name:find("currency") or name:find("point") or name:find("gem") or
                           name:find("cash") or name:find("score") or name:find("token") then
                            if type(attrValue) == "number" then
                                table.insert(allValues, {Object = obj, Attribute = attrName, Value = attrValue})
                                CoinValuesFound[obj] = true
                            end
                        end
                    end
                end
            end
        end
    end
    
    return allValues
end

-- Fungsi untuk memodifikasi SEMUA nilai coin dengan berbagai metode
local function HackAllCoins()
    local values = FindAllCoinValuesAggressive()
    local modified = 0
    
    for _, value in pairs(values) do
        pcall(function()
            -- Jika ini adalah NumberValue atau IntValue
            if value:IsA("NumberValue") or value:IsA("IntValue") then
                local oldValue = value.Value
                value.Value = 999999999
                modified = modified + 1
                print("Modified NumberValue:", value.Name, "from", oldValue, "to", value.Value)
                
                -- Hook untuk mencegah perubahan kembali
                value:GetPropertyChangedSignal("Value"):Connect(function()
                    if value.Value < 999999999 then
                        value.Value = 999999999
                        print("Value auto-corrected:", value.Name)
                    end
                end)
            end
            
            -- Jika ini adalah StringValue dengan angka
            if value:IsA("StringValue") then
                local oldValue = value.Value
                if tonumber(oldValue) then
                    value.Value = "999999999"
                    modified = modified + 1
                    print("Modified StringValue:", value.Name, "from", oldValue, "to", value.Value)
                end
            end
            
            -- Jika ini adalah Attribute
            if type(value) == "table" and value.Object and value.Attribute then
                local obj = value.Object
                local attr = value.Attribute
                local oldValue = obj:GetAttribute(attr)
                obj:SetAttribute(attr, 999999999)
                modified = modified + 1
                print("Modified Attribute:", attr, "on", obj.Name, "from", oldValue, "to", 999999999)
            end
        end)
    end
    
    return modified
end

-- Fungsi untuk mencari dan memodifikasi UI yang menampilkan coin
local function HackCoinUI()
    local modified = 0
    
    -- Cari semua TextLabel, TextButton, Frame yang mungkin menampilkan coin
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local text = obj.Text or ""
            -- Cek apakah teksnya mengandung angka yang mirip coin
            local num = tonumber(text:match("%d+"))
            if num and num > 0 then
                local parent = obj.Parent
                local parentName = parent and parent.Name:lower() or ""
                local objName = obj.Name:lower()
                
                -- Cek apakah ini UI coin
                if parentName:find("coin") or parentName:find("money") or parentName:find("gold") or
                   parentName:find("currency") or parentName:find("point") or parentName:find("gem") or
                   objName:find("coin") or objName:find("money") or objName:find("gold") or
                   objName:find("currency") or objName:find("point") or objName:find("gem") then
                    
                    -- Ubah teks menjadi 999999999
                    obj.Text = "999999999"
                    modified = modified + 1
                    print("Modified UI text:", obj.Name, "->", obj.Text)
                    
                    -- Hook untuk mencegah perubahan UI
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        obj:GetPropertyChangedSignal("Text"):Connect(function()
                            if obj.Text ~= "999999999" and tonumber(obj.Text) then
                                obj.Text = "999999999"
                                print("UI text auto-corrected:", obj.Name)
                            end
                        end)
                    end
                end
            end
        end
    end
    
    return modified
end

-- Fungsi untuk mencari dan memodifikasi remote event coin
local function HackCoinRemotes()
    local modified = 0
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("coin") or name:find("money") or name:find("gold") or 
               name:find("currency") or name:find("point") or name:find("gem") or
               name:find("cash") or name:find("score") or name:find("token") then
                
                pcall(function()
                    if obj:IsA("RemoteEvent") then
                        -- Coba blokir atau modifikasi
                        local oldFire = obj.FireServer
                        obj.FireServer = function(...)
                            print("Coin remote blocked:", obj.Name)
                            return
                        end
                        modified = modified + 1
                        print("Blocked remote:", obj.Name)
                    end
                end)
            end
        end
    end
    
    return modified
end

-- Fungsi utama untuk hack coin (EXTREME)
local function ExtremeCoinHack()
    local totalModified = 0
    
    -- 1. Hack semua nilai coin
    local count1 = HackAllCoins()
    totalModified = totalModified + count1
    
    -- 2. Hack UI coin
    local count2 = HackCoinUI()
    totalModified = totalModified + count2
    
    -- 3. Hack remote coin
    local count3 = HackCoinRemotes()
    totalModified = totalModified + count3
    
    -- 4. Aktifkan background monitor yang sangat agresif
    if not CoinHackActive then
        CoinHackActive = true
        task.spawn(function()
            while CoinHackActive do
                task.wait(0.5) -- Cek setiap 0.5 detik
                
                -- Cek semua nilai lagi
                local values = FindAllCoinValuesAggressive()
                for _, value in pairs(values) do
                    pcall(function()
                        if value:IsA("NumberValue") or value:IsA("IntValue") then
                            if value.Value < 999999999 then
                                value.Value = 999999999
                                print("Value forced to max:", value.Name)
                            end
                        end
                        if value:IsA("StringValue") then
                            if tonumber(value.Value) and tonumber(value.Value) < 999999999 then
                                value.Value = "999999999"
                                print("StringValue forced to max:", value.Name)
                            end
                        end
                        if type(value) == "table" and value.Object and value.Attribute then
                            if value.Object:GetAttribute(value.Attribute) < 999999999 then
                                value.Object:SetAttribute(value.Attribute, 999999999)
                                print("Attribute forced to max:", value.Attribute)
                            end
                        end
                    end)
                end
                
                -- Cek UI lagi
                for _, obj in pairs(game:GetDescendants()) do
                    if (obj:IsA("TextLabel") or obj:IsA("TextButton")) then
                        local text = obj.Text or ""
                        local num = tonumber(text:match("%d+"))
                        if num and num > 0 and num < 999999999 then
                            local parent = obj.Parent
                            local parentName = parent and parent.Name:lower() or ""
                            local objName = obj.Name:lower()
                            if parentName:find("coin") or parentName:find("money") or parentName:find("gold") or
                               parentName:find("currency") or parentName:find("point") or parentName:find("gem") or
                               objName:find("coin") or objName:find("money") or objName:find("gold") or
                               objName:find("currency") or objName:find("point") or objName:find("gem") then
                                obj.Text = "999999999"
                                print("UI text forced:", obj.Name)
                            end
                        end
                    end
                end
            end
        end)
    end
    
    return totalModified
end

local function CreateDebugUI()
    -- Cek apakah sudah ada
    if game:GetService("CoreGui"):FindFirstChild("DebugUI") then
        return game:GetService("CoreGui"):FindFirstChild("DebugUI")
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DebugUI"
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ResetOnSpawn = false
    
    -- Background untuk debug
    local bg = Instance.new("Frame")
    bg.Name = "Background"
    bg.Size = UDim2.new(0, 400, 0, 300)
    bg.Position = UDim2.new(0, 10, 0, 100)
    bg.BackgroundColor3 = Color3.new(0, 0, 0)
    bg.BackgroundTransparency = 0.3
    bg.BorderSizePixel = 1
    bg.BorderColor3 = Color3.new(1, 1, 1)
    bg.Parent = screenGui
    
    -- Text label untuk output
    local text = Instance.new("TextLabel")
    text.Name = "Output"
    text.Size = UDim2.new(1, -10, 1, -10)
    text.Position = UDim2.new(0, 5, 0, 5)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(0, 1, 0)
    text.TextSize = 14
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.Font = Enum.Font.Code
    text.Text = "Debug Console Started..."
    text.Parent = bg
    
    -- Tombol close
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.new(1, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Text = "X"
    closeBtn.TextSize = 18
    closeBtn.Parent = bg
    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
    end)
    
    -- Tombol toggle untuk menampilkan/menyembunyikan
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Size = UDim2.new(0, 40, 0, 40)
    toggleBtn.Position = UDim2.new(0, 10, 0, 50)
    toggleBtn.BackgroundColor3 = Color3.new(0, 0.5, 0)
    toggleBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleBtn.Text = "📊"
    toggleBtn.TextSize = 24
    toggleBtn.Parent = screenGui
    toggleBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = not screenGui.Enabled
    end)
    
    return screenGui
end

-- Fungsi untuk menambahkan log ke layar
local function AddLog(message)
    local debugUI = CreateDebugUI()
    local text = debugUI:FindFirstChild("Background") and debugUI.Background:FindFirstChild("Output")
    if text then
        local currentText = text.Text
        local lines = {}
        for line in currentText:gmatch("[^\r\n]+") do
            table.insert(lines, line)
        end
        table.insert(lines, message)
        if #lines > 20 then
            table.remove(lines, 1)
        end
        text.Text = table.concat(lines, "\n")
    end
end

-- Timpa print agar muncul di layar juga
local oldPrint = print
print = function(...)
    local args = {...}
    local msg = ""
    for i, v in ipairs(args) do
        msg = msg .. tostring(v) .. " "
    end
    oldPrint(msg)
    AddLog(msg)
end

-- ==========================================
-- MODIFIKASI COIN HACK UNTUK ANDROID
-- ==========================================

-- Fungsi untuk menampilkan hasil hack di layar
local function ShowHackResult(message, success)
    local debugUI = CreateDebugUI()
    debugUI.Enabled = true
    
    -- Tambahkan notifikasi popup
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 60)
    notif.Position = UDim2.new(0.5, -150, 0, 50)
    notif.BackgroundColor3 = success and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
    notif.BackgroundTransparency = 0.2
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.TextSize = 16
    notif.Text = message
    notif.TextWrapped = true
    notif.Font = Enum.Font.SourceSansBold
    notif.Parent = debugUI
    notif.ZIndex = 10
    
    -- Hapus setelah 5 detik
    task.delay(5, function()
        pcall(function() notif:Destroy() end)
    end)
end

-- Fungsi untuk mencari coin dan menampilkan hasilnya di layar
local function FindCoinsAndShow()
    AddLog("=== MENCARI NILAI COIN ===")
    local values = FindAllCoinValuesAggressive()
    local count = 0
    
    for _, value in pairs(values) do
        if value:IsA("NumberValue") or value:IsA("IntValue") then
            AddLog("📊 " .. value.Name .. " = " .. value.Value)
            count = count + 1
        elseif value:IsA("StringValue") then
            AddLog("📊 " .. value.Name .. " = " .. value.Value)
            count = count + 1
        elseif type(value) == "table" and value.Object and value.Attribute then
            AddLog("📊 " .. value.Attribute .. " = " .. value.Object:GetAttribute(value.Attribute))
            count = count + 1
        end
    end
    
    AddLog("=== TOTAL: " .. count .. " nilai coin ditemukan ===")
    ShowHackResult("🔍 Ditemukan " .. count .. " nilai coin! Lihat debug window (📊)", true)
    return count
end

-- Fungsi untuk hack coin dan tampilkan hasil
local function HackCoinsAndShow()
    AddLog("=== MULAI HACK COIN ===")
    local count = ExtremeCoinHack()
    AddLog("=== HACK SELESAI! Modified: " .. count .. " nilai ===")
    
    if count > 0 then
        ShowHackResult("💎 BERHASIL! " .. count .. " nilai coin dimodifikasi!", true)
    else
        ShowHackResult("❌ GAGAL! Tidak ada nilai coin ditemukan!", false)
    end
    
    -- Tampilkan hasil setelah hack
    task.wait(1)
    FindCoinsAndShow()
end
-- Fungsi untuk mencari semua senjata di map
local function FindAllWeapons()
    local weapons = {}
    local found = {}
    
    -- Cari di workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") or (obj:IsA("Model") and obj:FindFirstChildOfClass("Tool")) then
            local tool = obj:IsA("Tool") and obj or obj:FindFirstChildOfClass("Tool")
            if tool then
                local name = tool.Name:lower()
                -- Filter senjata yang valid
                if not name:find("humanoid") and not name:find("character") and 
                   not name:find("npc") and not name:find("dummy") then
                    table.insert(weapons, {
                        Tool = tool,
                        Name = tool.Name,
                        Position = tool:IsA("Tool") and tool.Parent and tool.Parent:IsA("BasePart") and tool.Parent.Position or nil
                    })
                    found[tool.Name] = true
                end
            end
        end
        
        -- Cari juga parts yang mungkin berisi senjata
        if obj:IsA("BasePart") and obj:FindFirstChild("Tool") then
            local tool = obj:FindFirstChild("Tool")
            if tool and not found[tool.Name] then
                table.insert(weapons, {
                    Tool = tool,
                    Name = tool.Name,
                    Position = obj.Position
                })
                found[tool.Name] = true
            end
        end
    end
    
    -- Cari di ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Tool") then
            local name = obj.Name:lower()
            if not found[obj.Name] and not name:find("humanoid") then
                table.insert(weapons, {
                    Tool = obj,
                    Name = obj.Name,
                    Position = nil
                })
                found[obj.Name] = true
            end
        end
    end
    
    return weapons
end

-- Fungsi untuk mendapatkan semua senjata
local function GetAllWeapons()
    local weapons = FindAllWeapons()
    local count = 0
    
    for _, data in pairs(weapons) do
        local tool = data.Tool
        if tool and tool:IsA("Tool") then
            -- Clone tool ke backpack
            local newTool = tool:Clone()
            newTool.Parent = LocalPlayer.Backpack
            count = count + 1
            MountPrankWeapons[newTool.Name] = newTool
            
            print("Weapon added:", newTool.Name)
        end
    end
    
    return count
end

-- Fungsi untuk mencari coin di map
local function FindAllCoins()
    local coins = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = obj.Name:lower()
            if name:find("coin") or name:find("money") or name:find("gold") or 
               name:find("currency") or name:find("point") or name:find("gem") then
                table.insert(coins, obj)
            end
        end
    end
    
    return coins
end

-- Fungsi untuk auto collect coin
local function AutoCollectCoinsLoop()
    while AutoCollectCoins do
        task.wait(0.3)
        
        local root = GetRootPart()
        if not root then continue end
        
        local coins = FindAllCoins()
        local collected = 0
        
        for _, coin in pairs(coins) do
            pcall(function()
                -- Teleport ke coin untuk collect
                local pos = coin:IsA("BasePart") and coin.Position or 
                           (coin:IsA("Model") and coin:GetPivot().Position)
                
                if pos then
                    local dist = (root.Position - pos).Magnitude
                    if dist < 50 then
                        -- Coba collect dengan proximity prompt jika ada
                        local prompt = coin:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt then
                            fireproximityprompt(prompt)
                            collected = collected + 1
                        end
                        
                        -- Coba dengan touch
                        local touchPart = coin:IsA("BasePart") and coin or 
                                        coin:FindFirstChildWhichIsA("BasePart")
                        if touchPart then
                            firetouchinterest(root, touchPart, 0)
                            task.wait(0.05)
                            firetouchinterest(root, touchPart, 1)
                            collected = collected + 1
                        end
                    end
                end
            end)
        end
        
        if collected > 0 then
            -- print("Collected", collected, "coins")
        end
    end
end

-- Fungsi untuk memodifikasi nilai coin (unlimited)
local function MakeCoinsUnlimited()
    -- Cari dan modifikasi nilai coin
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("StringValue") then
            local name = obj.Name:lower()
            if name:find("coin") or name:find("money") or name:find("gold") or 
               name:find("currency") or name:find("point") or name:find("gem") or
               name:find("cash") or name:find("score") then
                pcall(function()
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        obj.Value = 999999999
                        print("Modified coin value:", obj.Name, "-> 999999999")
                    end
                end)
            end
        end
        
        -- Cari juga di player stats
        if obj:IsA("Folder") and obj.Name:lower():find("stat") then
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("NumberValue") or child:IsA("IntValue") then
                    local name = child.Name:lower()
                    if name:find("coin") or name:find("money") or name:find("gold") or 
                       name:find("point") then
                        pcall(function()
                            child.Value = 999999999
                            print("Modified stat coin:", child.Name)
                        end)
                    end
                end
            end
        end
        
        -- Modifikasi leaderstats
        if obj.Name == "leaderstats" and obj:IsA("Folder") then
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("NumberValue") or child:IsA("IntValue") then
                    local name = child.Name:lower()
                    if name:find("coin") or name:find("money") or name:find("gold") or 
                       name:find("currency") or name:find("point") or name:find("cash") then
                        pcall(function()
                            child.Value = 999999999
                            print("Modified leaderstats:", child.Name)
                        end)
                    end
                end
            end
        end
    end
    
    -- Modifikasi juga di player
    for _, child in pairs(LocalPlayer:GetChildren()) do
        if child:IsA("NumberValue") or child:IsA("IntValue") then
            local name = child.Name:lower()
            if name:find("coin") or name:find("money") or name:find("gold") or 
               name:find("currency") or name:find("point") then
                pcall(function()
                    child.Value = 999999999
                    print("Modified player value:", child.Name)
                end)
            end
        end
    end
end

-- Fungsi untuk spawn semua senjata ke player
local function SpawnAllWeaponsToPlayer()
    local weapons = FindAllWeapons()
    local count = 0
    
    for _, data in pairs(weapons) do
        local tool = data.Tool
        if tool and tool:IsA("Tool") then
            -- Cek apakah sudah ada di backpack
            local exists = false
            for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                if item.Name == tool.Name then
                    exists = true
                    break
                end
            end
            
            if not exists then
                local newTool = tool:Clone()
                newTool.Parent = LocalPlayer.Backpack
                count = count + 1
                MountPrankWeapons[newTool.Name] = newTool
            end
        end
    end
    
    return count
end


-- ==========================================
-- TABS SETUP
-- ==========================================
local MainTab = Window:AddTab({ Name = "Main", Icon = "home" })
local AutoWalking = Window:AddTab({ Name = "AutoWalk", Icon = "player" })
local PlayerTab = Window:AddTab({ Name = "Player", Icon = "user" })
local GameTab = Window:AddTab({ Name = "Game", Icon = "gamepad" })
local ServerTab = Window:AddTab({ Name = "Server", Icon = "web" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings" })

-- ==========================================
-- MAIN TAB - QUICK ACTIONS
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
            if mouse.Target and not mouse.Target.Anchored and mouse.Target:IsA("BasePart") then
                target = mouse.Target
                
                if connection then connection:Disconnect() end
                
                connection = RunService.RenderStepped:Connect(function()
                    if target and tool.Parent == LocalPlayer.Character then
                        local holdPos = LocalPlayer.Character.Head.CFrame * CFrame.new(0, 0, -10).p
                        local direction = (holdPos - target.Position)
                        
                        target.AssemblyLinearVelocity = direction * 15
                        target.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    else
                        if connection then connection:Disconnect() end
                    end
                end)
            end
        end)
        
        tool.Deactivated:Connect(function()
            if connection then connection:Disconnect() end
            target = nil
        end)
        
        tool.Unequipped:Connect(function()
            if connection then connection:Disconnect() end
            target = nil
        end)
        
        Library:MakeNotify({ Title = "Success", Content = "Gravity Gun telah ditambahkan ke Backpack!" })
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
        Library:MakeNotify({ Title = "Success", Content = "Character reset!" })
    end
})

QuickSection:AddButton({
    Title = "Refresh Movement",
    Callback = function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.UseJumpPower = true
        end
        workspace.Gravity = 196
        Library:MakeNotify({ Title = "Success", Content = "Movement Refreshed!" })
    end
})

-- ==========================================
-- PLAYER TELEPORT
-- ==========================================
local QuickTpSection = MainTab:AddSection("🚀 Quick Player Teleport")
local SelectedTarget = ""

QuickTpSection:AddToggle({
    Title = "Auto Pick Up / Interact",
    Description = "Otomatis ambil item/oksigen terdekat",
    Default = false,
    Callback = function(v)
        _G.AutoInteract = v
        task.spawn(function()
            while _G.AutoInteract do
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Parent:GetModelCFrame().p).Magnitude
                        if dist < 15 then
                            pcall(function() fireproximityprompt(obj) end)
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
})

local TpSection = MainTab:AddSection("🎯 Teleport")

TpSection:AddToggle({
    Title = "Click TP (PC/Mobile)",
    Description = "Klik/Sentuh layar untuk teleport instan",
    Default = false,
    Callback = function(v) _G.TapTP = v end
})

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
                task.wait(0.5)
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
    Description = "Membawa target ke posisi Anda (Hanya terlihat di Anda)",
    Callback = function()
        if SelectedTarget == "" then 
            Library:MakeNotify({ Title = "Warning", Content = "Pilih pemain dulu!" }) 
            return 
        end
        local target = Players:FindFirstChild(SelectedTarget)
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if target and target.Character and myRoot then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                tRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
                Library:MakeNotify({ Title = "Success", Content = "Membawa " .. SelectedTarget })
            end
        else
            Library:MakeNotify({ Title = "Error", Content = "Pemain tidak ditemukan!" })
        end
    end
})

-- ==========================================
-- TROLL MOUNTAIN SECTION
-- ==========================================
local TrollSection = MainTab:AddSection("👿 Troll Mountain")

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
            Library:MakeNotify({ Title = "❌ Error", Content = "Target tidak punya HRP!", Duration = 3 })
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
            Library:MakeNotify({ Title = "❌ Error", Content = "Target tidak punya HRP!", Duration = 3 })
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
    Title = "🧱 Kandang Target",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "❌ Error", Content = "Target tidak punya HRP!", Duration = 3 })
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
        
        Library:MakeNotify({ Title = "🧱 KANDANG!", Content = target.Name .. " dikurung!", Duration = 3 })
        
        task.wait(5)
        for _, p in pairs(parts) do
            pcall(function() p:Destroy() end)
        end
    end
})

TrollSection:AddButton({
    Title = "🧊 Lantai Licin",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "❌ Error", Content = "Target tidak punya HRP!", Duration = 3 })
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
        
        Library:MakeNotify({ Title = "🧊 LICIN!", Content = "Lantai es di sekitar " .. target.Name, Duration = 3 })
        
        task.wait(5)
        for _, ice in pairs(ices) do
            pcall(function() ice:Destroy() end)
        end
    end
})

TrollSection:AddButton({
    Title = "🪨 Longsor Batu",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "❌ Error", Content = "Target tidak punya HRP!", Duration = 3 })
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
        
        Library:MakeNotify({ Title = "🪨 LONGSOR!", Content = "Batu menimpa " .. target.Name, Duration = 3 })
        
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
            Library:MakeNotify({ Title = "❌ Error", Content = "Target tidak punya HRP!", Duration = 3 })
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
            Library:MakeNotify({ Title = "❌ Error", Content = "Tidak ada checkpoint ditemukan!", Duration = 3 })
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
            Library:MakeNotify({ Title = "❌ Error", Content = "Target tidak punya HRP!", Duration = 3 })
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
            Library:MakeNotify({ Title = "❌ Error", Content = "Target tidak punya HRP!", Duration = 3 })
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
    Title = "🌍 Zona Gravitasi",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then 
            Library:MakeNotify({ Title = "❌ Error", Content = "Target tidak punya HRP!", Duration = 3 })
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
        
        Library:MakeNotify({ Title = "🌍 GRAVITASI!", Content = target.Name .. " ditarik ke bawah!", Duration = 3 })
        
        task.wait(4)
        pcall(function()
            zone:Destroy()
            gravity:Destroy()
        end)
    end
})

TrollSection:AddButton({
    Title = "👁️ Butakan Target",
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
        
        Library:MakeNotify({ Title = "👁️ BUTA!", Content = target.Name .. " dibutakan!", Duration = 3 })
        
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
            Library:MakeNotify({ Title = "❌ Error", Content = "Target tidak punya HRP!", Duration = 3 })
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
-- AUTOWALK TAB
-- ==========================================
local WalkSection = AutoWalking:AddSection("🗽 Auto Walk Mountain")

local jsonMatcha = [[
[
    {"position":{"x":-27.625, "y":188.38, "z":-503.16}, "walkSpeed":52, "states":"Running"},
    {"position":{"x":-27.512, "y":188.38, "z":-502.30}, "walkSpeed":52, "states":"Running"},
    {"position":{"x":-9448.06, "y":1788.38, "z":-2132.23}, "walkSpeed":52, "states":"Running"}
}
]]

local waypoints = {}

local function loadWaypoints()
    local success, result = pcall(function()
        return HttpService:JSONDecode(jsonMatcha)
    end)
    if success then
        waypoints = result
        return #waypoints
    else
        warn("Gagal membaca data JSON Waypoints!")
        return 0
    end
end

local MountainRoute = {}
_G.AutoWalkSpeed = 25 
_G.AutoWalk = false

local function GetHum() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end
local function GetRoot() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end

local function ScanMountain()
    MountainRoute = {}
    local allParts = workspace:GetDescendants()
    for i, obj in pairs(allParts) do
        if i % 500 == 0 then task.wait() end
        
        if obj:IsA("SpawnLocation") or (obj:IsA("BasePart") and (
            obj.Name:lower():find("cp") or 
            obj.Name:lower():find("stage") or 
            obj.Name:lower():find("camp") or 
            obj.Name:lower():find("point")
        )) then
            table.insert(MountainRoute, {Part = obj, Y = obj.Position.Y})
        end
    end
    table.sort(MountainRoute, function(a, b) return a.Y < b.Y end)
    return #MountainRoute
end

WalkSection:AddToggle({
    Title = "Start Auto Walk (Smooth Mode)",
    Description = "Jalan halus menembus rintangan ke puncak",
    Default = false,
    Callback = function(v)
        _G.AutoWalk = v
        if v then
            task.spawn(function()
                local total = ScanMountain()
                Library:MakeNotify({ Title = "MDW HUB", Content = "Mulai mendaki! Menghindari rintangan..." })

                while _G.AutoWalk do
                    local root = GetRoot()
                    local hum = GetHum()
                    if not root or not hum then task.wait(1) continue end

                    local targetData = nil
                    for _, data in pairs(MountainRoute) do
                        if data.Y > root.Position.Y + 5 then 
                            targetData = data
                            break
                        end
                    end

                    if targetData then
                        local targetPart = targetData.Part
                        local distance = (root.Position - targetPart.Position).Magnitude
                        local duration = distance / (_G.AutoWalkSpeed or 25)

                        hum.PlatformStand = true
                        
                        local ncLoop = RunService.Stepped:Connect(function()
                            if LocalPlayer.Character then
                                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                                    if p:IsA("BasePart") then p.CanCollide = false end
                                end
                            end
                        end)

                        local targetCFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3, 0)) 
                        local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                            CFrame = targetCFrame * CFrame.Angles(0, math.rad(root.Orientation.Y), 0)
                        })
                        
                        tween:Play()

                        local reached = false
                        local finished = tween.Completed:Connect(function() reached = true end)

                        repeat 
                            task.wait(0.1)
                            if not _G.AutoWalk or hum.Health <= 0 then 
                                tween:Cancel()
                                reached = true 
                            end
                        until reached

                        finished:Disconnect()
                        ncLoop:Disconnect()
                        hum.PlatformStand = false

                        if firetouchinterest and _G.AutoWalk then
                            pcall(function()
                                firetouchinterest(root, targetPart, 0)
                                task.wait(0.1)
                                firetouchinterest(root, targetPart, 1)
                            end)
                        end
                    else
                        Library:MakeNotify({ Title = "Selesai", Content = "Sudah sampai di puncak!" })
                        _G.AutoWalk = false
                        break
                    end
                    task.wait(0.1)
                end
                
                local h = GetHum()
                if h then h.PlatformStand = false end
            end)
        end
    end
})

WalkSection:AddInput({
    Title = "WalkSpeed Hack",
    Description = "Semakin tinggi angkanya, semakin cepat larinya.",
    Min = 16,
    Max = 300,
    Default = 16,
    Callback = function(value)
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = value
        end
    end
})

WalkSection:AddInput({
    Title = "JumpPower Hack",
    Description = "Semakin tinggi angkanya, semakin tinggi lompatannya.",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(value)
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.UseJumpPower = true
            character.Humanoid.JumpPower = value
        end
    end
})

WalkSection:AddButton({
    Title = "Rescan Rute",
    Callback = function()
        local total = ScanMountain()
        Library:MakeNotify({ Title = "MDW HUB", Content = "Rute diperbarui: " .. total .. " titik." })
    end
})

WalkSection:AddToggle({
    Title = "Start Matcha Autowalk (JSON)",
    Description = "Berjalan mengikuti koordinat dari file JSON",
    Default = false,
    Callback = function(v)
        _G.AutoWalkJSON = v
        
        if v then
            task.spawn(function()
                local total = loadWaypoints()
                if total == 0 then 
                    Library:MakeNotify({ Title = "Error", Content = "Data Waypoint Kosong!" })
                    return 
                end

                Library:MakeNotify({ Title = "MDW HUB", Content = "Memulai Autowalk: " .. total .. " Titik." })

                local ncLoop = RunService.Stepped:Connect(function()
                    if _G.AutoWalkJSON and LocalPlayer.Character then
                        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end)

                local char = LocalPlayer.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")

                if hum then hum.PlatformStand = true end

                for i, data in ipairs(waypoints) do
                    if not _G.AutoWalkJSON or hum.Health <= 0 then break end

                    local targetPos = Vector3.new(data.position.x, data.position.y + 3, data.position.z)
                    local speed = data.walkSpeed or 25
                    
                    local distance = (root.Position - targetPos).Magnitude
                    local duration = distance / speed

                    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                        CFrame = CFrame.new(targetPos)
                    })
                    
                    tween:Play()

                    local reached = false
                    local finished = tween.Completed:Connect(function() reached = true end)

                    repeat 
                        task.wait(0.1)
                        if not _G.AutoWalkJSON then tween:Cancel() reached = true end
                    until reached

                    finished:Disconnect()
                    print("Sampai di waypoint ke-" .. i)
                end

                if ncLoop then ncLoop:Disconnect() end
                if hum then hum.PlatformStand = false end
                _G.AutoWalkJSON = false
                Library:MakeNotify({ Title = "Selesai", Content = "Karakter sampai di tujuan akhir." })
            end)
        end
    end
})

WalkSection:AddButton({
    Title = "Reload JSON Data",
    Callback = function()
        local count = loadWaypoints()
        Library:MakeNotify({ Title = "Success", Content = "Data diupdate: " .. count .. " koordinat." })
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


local WeaponSection = PlayerTab:AddSection("⚔️ Weapons & Coins")

WeaponSection:AddButton({
    Title = "🔫 Get All Weapons",
    Description = "Dapatkan semua senjata yang ada di map",
    Callback = function()
        local count = GetAllWeapons()
        Library:MakeNotify({ 
            Title = "✅ Weapons Added", 
            Content = "Berhasil mendapatkan " .. count .. " senjata!", 
            Duration = 3 
        })
    end
})

WeaponSection:AddButton({
    Title = "🔄 Spawn All Weapons (Every 5s)",
    Description = "Spawn semua senjata secara otomatis setiap 5 detik",
    Callback = function()
        SpawnAllWeapons = not SpawnAllWeapons
        
        if SpawnAllWeapons then
            task.spawn(function()
                while SpawnAllWeapons do
                    local count = SpawnAllWeaponsToPlayer()
                    if count > 0 then
                        print("Spawned", count, "weapons")
                    end
                    task.wait(5)
                end
            end)
            Library:MakeNotify({ 
                Title = "🔄 Auto Spawn ON", 
                Content = "Senjata akan spawn otomatis setiap 5 detik", 
                Duration = 3 
            })
        else
            Library:MakeNotify({ 
                Title = "🔄 Auto Spawn OFF", 
                Content = "Auto spawn senjata dimatikan", 
                Duration = 2 
            })
        end
    end
})
WeaponSection:AddButton({
    Title = "🛒 HACK PURCHASE (BELI GRATIS)",
    Description = "Hack sistem pembelian agar bisa beli apapun gratis",
    Callback = function()
        local count = HackPurchases()
        Library:MakeNotify({ 
            Title = "🛒 PURCHASE HACK!", 
            Content = "Berhasil memodifikasi " .. count .. " remote! Coba beli sekarang!", 
            Duration = 4 
        })
        AddLog("=== PURCHASE HACK ACTIVATED! Modified: " .. count .. " remotes ===")
    end
})

WeaponSection:AddButton({
    Title = "🔄 FORCE PURCHASE (COBA BELI)",
    Description = "Coba beli item dengan paksa",
    Callback = function()
        -- Coba trigger pembelian secara paksa
        pcall(function()
            -- Cari semua tombol beli
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local name = obj.Name:lower()
                    if name:find("buy") or name:find("purchase") or name:find("shop") or
                       name:find("beli") or name:find("coin") then
                        -- Simulate click
                        obj:Click()
                        print("Clicked button:", obj.Name)
                        task.wait(0.5)
                    end
                end
                -- Cari juga ProximityPrompt
                if obj:IsA("ProximityPrompt") then
                    local name = obj.Name:lower()
                    if name:find("buy") or name:find("purchase") or name:find("shop") or
                       name:find("beli") then
                        fireproximityprompt(obj)
                        print("Fired prompt:", obj.Name)
                        task.wait(0.5)
                    end
                end
            end
        end)
        Library:MakeNotify({ 
            Title = "🔄 FORCE PURCHASE", 
            Content = "Mencoba membeli item... Cek apakah berhasil!", 
            Duration = 3 
        })
    end
})


WeaponSection:AddButton({
    Title = "📱 FIND COINS (TAMPILKAN DI LAYAR)",
    Description = "Cari semua nilai coin dan tampilkan di layar",
    Callback = function()
        FindCoinsAndShow()
    end
})

WeaponSection:AddButton({
    Title = "💎 EXTREME HACK + TAMPILKAN HASIL",
    Description = "Hack coin dan tampilkan hasilnya di layar",
    Callback = function()
        HackCoinsAndShow()
    end
})

WeaponSection:AddButton({
    Title = "📊 Toggle Debug Window",
    Description = "Tampilkan/sembunyikan jendela debug",
    Callback = function()
        local debugUI = game:GetService("CoreGui"):FindFirstChild("DebugUI")
        if debugUI then
            debugUI.Enabled = not debugUI.Enabled
            Library:MakeNotify({ 
                Title = "📊 Debug Window", 
                Content = debugUI.Enabled and "Ditampilkan" or "Disembunyikan", 
                Duration = 2 
            })
        else
            CreateDebugUI()
            Library:MakeNotify({ 
                Title = "📊 Debug Window", 
                Content = "Debug window dibuat!", 
                Duration = 2 
            })
        end
    end
})

WeaponSection:AddButton({
    Title = "💎 EXTREME COIN HACK (ALL METHODS)",
    Description = "Gunakan SEMUA metode untuk hack coin (100% work)",
    Callback = function()
        local count = ExtremeCoinHack()
        Library:MakeNotify({ 
            Title = "💎 EXTREME COIN HACK!", 
            Content = "Berhasil memodifikasi " .. count .. " nilai coin! Cek coin Anda sekarang!", 
            Duration = 5 
        })
        
        -- Cek ulang setelah 2 detik
        task.wait(2)
        local values = FindAllCoinValuesAggressive()
        local finalCount = 0
        for _, v in pairs(values) do
            if v:IsA("NumberValue") or v:IsA("IntValue") then
                if v.Value >= 999999999 then
                    finalCount = finalCount + 1
                end
            end
        end
        Library:MakeNotify({ 
            Title = "✅ Hasil Akhir", 
            Content = "Total nilai coin yang aktif: " .. finalCount, 
            Duration = 4 
        })
    end
})

-- Tombol untuk debug
WeaponSection:AddButton({
    Title = "🔍 DEBUG: Cari Semua Nilai Coin",
    Description = "Tampilkan semua nilai coin di console",
    Callback = function()
        local values = FindAllCoinValuesAggressive()
        print("=== SEMUA NILAI COIN DITEMUKAN ===")
        local count = 0
        for _, value in pairs(values) do
            if value:IsA("NumberValue") or value:IsA("IntValue") then
                print("NumberValue:", value.Name, "=", value.Value, "(Parent:", value.Parent and value.Parent.Name or "nil", ")")
                count = count + 1
            elseif value:IsA("StringValue") then
                print("StringValue:", value.Name, "=", value.Value)
                count = count + 1
            elseif type(value) == "table" and value.Object and value.Attribute then
                print("Attribute:", value.Attribute, "=", value.Object:GetAttribute(value.Attribute), "on", value.Object.Name)
                count = count + 1
            end
        end
        print("=== TOTAL:", count, "nilai coin ditemukan ===")
        Library:MakeNotify({ 
            Title = "🔍 Debug", 
            Content = "Semua nilai coin ditampilkan di console (F9)! Total: " .. count, 
            Duration = 5 
        })
    end
})

-- Tombol untuk stop coin hack
WeaponSection:AddButton({
    Title = "⏹️ Stop Coin Hack",
    Description = "Matikan semua proses hack coin",
    Callback = function()
        CoinHackActive = false
        Library:MakeNotify({ 
            Title = "⏹️ Stopped", 
            Content = "Coin hack dimatikan", 
            Duration = 2 
        })
    end
})


WeaponSection:AddButton({
    Title = "🪙 Make Coins Unlimited",
    Description = "Modifikasi nilai coin menjadi 999999999",
    Callback = function()
        MakeCoinsUnlimited()
        Library:MakeNotify({ 
            Title = "🪙 Unlimited Coins!", 
            Content = "Nilai coin telah dimodifikasi menjadi maksimal!", 
            Duration = 3 
        })
    end
})

WeaponSection:AddToggle({
    Title = "🪙 Auto Collect Coins",
    Description = "Otomatis mengumpulkan coin di sekitar",
    Default = false,
    Callback = function(v)
        AutoCollectCoins = v
        if v then
            task.spawn(AutoCollectCoinsLoop)
            Library:MakeNotify({ 
                Title = "🪙 Auto Collect ON", 
                Content = "Mengumpulkan coin secara otomatis", 
                Duration = 2 
            })
        else
            Library:MakeNotify({ 
                Title = "🪙 Auto Collect OFF", 
                Content = "Auto collect dimatikan", 
                Duration = 2 
            })
        end
    end
})

WeaponSection:AddButton({
    Title = "💰 Find All Coins",
    Description = "Highlight semua coin di map",
    Callback = function()
        ClearManualHighlights()
        local coins = FindAllCoins()
        local count = 0
        
        for _, coin in pairs(coins) do
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(255, 215, 0) -- Gold color
            hl.FillTransparency = 0.4
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.Adornee = coin
            hl.Parent = coin
            table.insert(ManualHighlights, hl)
            count = count + 1
        end
        
        Library:MakeNotify({ 
            Title = "💰 Found " .. count .. " Coins", 
            Content = "Semua coin telah di-highlight", 
            Duration = 3 
        })
    end
})

WeaponSection:AddButton({
    Title = "🗑️ Clear All Highlighted",
    Callback = function()
        ClearManualHighlights()
        Library:MakeNotify({ 
            Title = "✅ Cleared", 
            Content = "Semua highlight telah dihapus", 
            Duration = 2 
        })
    end
})
task.spawn(function()
    task.wait(6) -- Tunggu setelah coin hack
    print("🛒 Memulai Purchase Hack...")
    local count = HackPurchases()
    print("🛒 Purchase Hack selesai! Modified:", count, "remotes")
    AddLog("=== PURCHASE HACK AUTO-STARTED! Modified: " .. count .. " remotes ===")
end)

print("🛒 Purchase hack aktif! Coba beli item sekarang!")
task.spawn(function()
    task.wait(3) -- Tunggu 3 detik setelah script load
    print("🪙 Memulai Extreme Coin Hack...")
    local count = ExtremeCoinHack()
    print("🪙 Coin hack selesai! Modified:", count, "values")
end)

-- Jalankan ulang saat karakter spawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    if CoinHackActive then
        print("🪙 Re-applying coin hack...")
        local count = HackAllCoins()
        print("🪙 Re-applied:", count, "values")
    end
end)

task.spawn(function()
    task.wait(5) -- Tunggu UI siap
    print("🪙 Memulai Extreme Coin Hack untuk Android...")
    AddLog("=== AUTO HACK STARTED ===")
    local count = ExtremeCoinHack()
    AddLog("=== AUTO HACK DONE! Modified: " .. count .. " values ===")
    
    if count > 0 then
        ShowHackResult("💎 AUTO HACK! " .. count .. " nilai coin dimodifikasi!", true)
    else
        ShowHackResult("⚠️ AUTO HACK: Tidak ada nilai coin ditemukan", false)
    end
end)

print("📱 Android mode aktif! Gunakan tombol 📊 untuk debug window")

-- Event untuk re-apply unlimited coins saat value berubah
local function MonitorCoinValues()
    while true do
        task.wait(2)
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                local name = obj.Name:lower()
                if name:find("coin") or name:find("money") or name:find("gold") or 
                   name:find("currency") or name:find("point") or name:find("cash") then
                    if obj.Value < 999999999 then
                        pcall(function()
                            obj.Value = 999999999
                        end)
                    end
                end
            end
        end
    end
end

local MountPrankSection = PlayerTab:AddSection("🏔️ Mount Prank Protection")

MountPrankSection:AddToggle({
    Title = "🛡️ Anti-Prank Mode (Mount Prank)",
    Description = "Perlindungan khusus untuk game Mount Prank",
    Default = false,
    Callback = function(v)
        if v then
            EnableMountPrankProtection()
        else
            MountPrankActive = false
            Library:MakeNotify({ 
                Title = "🛡️ Mount Prank Protection", 
                Content = "Perlindungan dimatikan", 
                Duration = 2 
            })
        end
    end
})

MountPrankSection:AddButton({
    Title = "🔍 Scan & Block Prank Remotes",
    Callback = function()
        BlockPrankRemotes()
        Library:MakeNotify({ 
            Title = "🔍 Scan Selesai", 
            Content = "Remote event prank telah diblokir", 
            Duration = 2 
        })
    end
})

MountPrankSection:AddButton({
    Title = "🛡️ Force Equip Shield",
    Callback = function()
        if FindAndUseShield() then
            Library:MakeNotify({ 
                Title = "✅ Sukses", 
                Content = "Shield ditemukan dan diaktifkan!", 
                Duration = 2 
            })
        else
            Library:MakeNotify({ 
                Title = "❌ Gagal", 
                Content = "Tidak menemukan shield di inventory!", 
                Duration = 2 
            })
        end
    end
})

-- Event untuk mengaktifkan ulang perlindungan saat respawn
local function OnCharacterAdded(char)
    task.wait(1)
    if MountPrankActive then
        FindAndUseShield()
        DisablePrankScripts()
        
        -- Aktifkan kembali God Mode jika aktif
        if _G.GodMode then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
                hum.BreakJointsOnDeath = false
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

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
-- GOD MODE (KEBAL SERANGAN) - NEW FEATURE
-- ==========================================
AntiSection:AddToggle({
    Title = "🛡️ God Mode (Kebal Serangan)",
    Description = "Tidak akan mati terkena serangan apapun",
    Default = false,
    Callback = function(v)
        _G.GodMode = v
        if v then
            task.spawn(function()
                while _G.GodMode do
                    task.wait(0.1)
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        -- Set health ke max setiap saat
                        hum.Health = hum.MaxHealth
                        -- Cegah ragdoll
                        if hum.PlatformStand then hum.PlatformStand = false end
                        if hum.Sit then hum.Sit = false end
                        -- Cegah stun/freeze
                        pcall(function()
                            if hum:GetState() == Enum.HumanoidStateType.Physics then
                                hum:ChangeState(Enum.HumanoidStateType.Running)
                            end
                        end)
                        -- Reset break joints jika ada
                        if hum.BreakJointsOnDeath then
                            hum.BreakJointsOnDeath = false
                        end
                    end
                    
                    -- Cegah parts terlepas
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part:IsA("Part") then
                                pcall(function()
                                    if part:FindFirstChild("BodyVelocity") then
                                        part.BodyVelocity:Destroy()
                                    end
                                    if part:FindFirstChild("BodyForce") then
                                        part.BodyForce:Destroy()
                                    end
                                end)
                            end
                        end
                    end
                end
            end)
            Library:MakeNotify({ Title = "🛡️ God Mode", Content = "Kamu sekarang kebal terhadap segala serangan!" })
        else
            Library:MakeNotify({ Title = "🛡️ God Mode", Content = "Fitur kebal dimatikan" })
        end
    end
})

-- Event untuk auto-heal saat karakter spawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if _G.GodMode then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth
            hum.BreakJointsOnDeath = false
        end
    end
end)

-- Humanoid state changed untuk cegah mati
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Died:Connect(function()
            if _G.GodMode then
                task.wait(0.1)
                local newChar = LocalPlayer.Character
                local newHum = newChar and newChar:FindFirstChildOfClass("Humanoid")
                if newHum then
                    newHum.Health = newHum.MaxHealth
                    newHum.BreakJointsOnDeath = false
                end
            end
        end)
    end
end)

-- ==========================================
-- FLY SECTION
-- ==========================================
local FlySection = PlayerTab:AddSection("✈️ Fly Settings")

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
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
            
            if moveVec.Magnitude == 0 and hum.MoveDirection.Magnitude > 0 then
                local joyDir = hum.MoveDirection
                moveVec = (cam.CFrame.LookVector * -joyDir.Z) + (cam.CFrame.RightVector * joyDir.X)
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
local FarmSection = GameTab:AddSection("🏔️ Auto CP All Mountain")

FarmSection:AddButton({
    Title = "🧹 Hapus Kotak Merah/Putih",
    Description = "Bersihkan highlight dan efek visual",
    Callback = function()
        ClearAllHighlights()
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
                    Title = "🏔️ Auto CP", 
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
                        Title = "✅ CP " .. i .. "/" .. #cps, 
                        Content = cp.Name .. " (Y: " .. math.floor(cp.Y) .. ")", 
                        Duration = 1.5 
                    })
                    
                    task.wait(_G.CPTeleportDelay or 0.8)
                end
                
                if _G.AutoCPAll then
                    Library:MakeNotify({ 
                        Title = "🏆 Selesai!", 
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
        ClearAllHighlights()
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
            Title = "🔍 Hasil Scan", 
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

FarmSection:AddButton({
    Title = "🔢 TP ke CP Nomor Tertentu",
    Callback = function()
        local cps = ScanAllCheckpoints()
        
        if #cps == 0 then
            Library:MakeNotify({ 
                Title = "❌ Error", 
                Content = "Tidak ada checkpoint!", 
                Duration = 3 
            })
            return
        end
        
        print("=== DAFTAR CHECKPOINT ===")
        for i, cp in ipairs(cps) do
            print(i .. ". " .. cp.Name .. " (Y: " .. math.floor(cp.Y) .. ")")
        end
        print("============================")
        print("Ketik: /tp [nomor] di chat")
        print("Contoh: /tp 5")
        
        Library:MakeNotify({ 
            Title = "📝 Instruksi", 
            Content = "Cek console (F9) untuk daftar. Ketik /tp [nomor] di chat", 
            Duration = 5 
        })
        
        local connection
        connection = Players:GetPlayers()[1].Chatted:Connect(function(msg)
            if msg:lower():sub(1, 4) == "/tp " then
                local num = tonumber(msg:match("%d+"))
                if num and num >= 1 and num <= #cps then
                    local target = cps[num]
                    local root = GetRootPart()
                    if root then
                        root.CFrame = target.Part.CFrame * CFrame.new(0, 5, 0)
                        Library:MakeNotify({ 
                            Title = "✅ TP!", 
                            Content = "Ke " .. target.Name, 
                            Duration = 3 
                        })
                    end
                else
                    Library:MakeNotify({ 
                        Title = "❌ Error", 
                        Content = "Nomor tidak valid! (1-" .. #cps .. ")", 
                        Duration = 3 
                    })
                end
                connection:Disconnect()
            end
        end)
    end
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
            Library:MakeNotify({ Title = "Teleport", Content = "Berhasil ke Puncak!" })
        end
    end
})

-- ==========================================
-- GAME TAB - VISUAL ESP
-- ==========================================
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
    Title = "ESP Skeleton (Bone)", 
    Default = false, 
    Callback = function(v) _G.SkeletonESP = v end 
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
local UtilSection = GameTab:AddSection("🎣 Gameplay Utilities")

UtilSection:AddToggle({
    Title = "Auto Skill Check (Mobile)",
    Default = false,
    Callback = function(v)
        _G.AutoSkillMobile = v
        if v then
            task.spawn(function()
                while _G.AutoSkillMobile do
                    task.wait(0.1)
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    end)
                end
            end)
        end
    end
})

UtilSection:AddToggle({
    Title = "Killer Proximity Warning",
    Description = "Notifikasi jika Killer mendekat (50 studs)",
    Default = false,
    Callback = function(v)
        _G.KillerWarn = v
        if v then
            task.spawn(function()
                local lastWarn = 0
                while _G.KillerWarn do
                    task.wait(0.5)
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and CheckIfKiller(p) then
                            local char = p.Character
                            local myChar = LocalPlayer.Character
                            if char and myChar and char:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("HumanoidRootPart") then
                                local dist = (myChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                                
                                if dist < 50 and tick() - lastWarn > 3 then
                                    Library:MakeNotify({ 
                                        Title = "⚠️ PERINGATAN!", 
                                        Content = "Killer: " .. p.Name .. " Mendekat! (" .. math.floor(dist) .. " studs)"
                                    })
                                    lastWarn = tick()
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
            Library:MakeNotify({ Title = "Enabled", Content = "Auto Wiggle Aktif" })
        else
            Library:MakeNotify({ Title = "Disabled", Content = "Auto Wiggle Mati" })
        end
    end
})

-- ==========================================
-- GAME TAB - FIND OBJECTS
-- ==========================================
local FindSection = GameTab:AddSection("🎯 Find Objects & Debug")

FindSection:AddButton({
    Title = "Find Generators",
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
        Library:MakeNotify({ Title = "Found", Content = count .. " generators highlighted!" })
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

FindSection:AddButton({
    Title = "Debug: Print All Objects",
    Callback = function()
        print("=== Workspace Object List ===")
        local counted = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                counted[obj.Name] = (counted[obj.Name] or 0) + 1
            end
        end
        for name, count in pairs(counted) do 
            print(name .. " [x" .. count .. "]") 
        end
        Library:MakeNotify({ Title = "Debug", Content = "Daftar objek dikirim ke Console (F9)" })
    end
})

-- ==========================================
-- SERVER TAB - CHAT
-- ==========================================
local ChatSection = ServerTab:AddSection("🌟 Chat Otomatis")

ChatSection:AddInput({ 
    Title = "Custom Chat Message", 
    Default = "IKY!", 
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
                        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All") 
                    end)
                    pcall(function() 
                        TextChatService.TextChannels.RBXGeneral:SendAsync(msg) 
                    end)
                    task.wait(5)
                end
            end)
        end
    end
})

ChatSection:AddToggle({
    Title = "Enable Chat Logger",
    Default = false,
    Callback = function(v)
        _G.ChatLog = v
    end
})

-- ==========================================
-- SERVER TAB - PROTECTION (ANTI-KICK DIHAPUS)
-- ==========================================
local ProtectSection = ServerTab:AddSection("🛡️ Self-Protection & Security")

ProtectSection:AddToggle({
    Title = "Admin Join Detector",
    Default = false,
    Callback = function(v)
        _G.AdminDetect = v
    end
})

Players.PlayerAdded:Connect(function(player)
    if _G.AdminDetect then
        if player:GetRankInGroup(0) > 10 or player.AccountAge < 2 then
            Library:MakeNotify({ 
                Title = "⚠️ WARNING", 
                Content = "Admin/Pemain Baru Masuk: " .. player.Name
            })
        end
    end
end)

ProtectSection:AddButton({ 
    Title = "Manual Emergency Kick", 
    Callback = function() LocalPlayer:Kick("FCAL HUB End.") end 
})

ProtectSection:AddButton({
    Title = "Instant Server Hop",
    Callback = function()
        local servers = {}
        local success, res = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
        end)
        
        if success then
            local data = HttpService:JSONDecode(res).data
            for _, v in pairs(data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
            else
                Library:MakeNotify({ Title = "Error", Content = "Tidak ada server tersedia." })
            end
        end
    end
})

-- ==========================================
-- SERVER TAB - ACTIONS
-- ==========================================
local ActionsSection = ServerTab:AddSection("🔪 Actions")

ActionsSection:AddButton({ 
    Title = "Rejoin", 
    Callback = function() 
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) 
    end 
})

ActionsSection:AddButton({ 
    Title = "Server Hop (Default)", 
    Callback = function() 
        TeleportService:Teleport(game.PlaceId, LocalPlayer) 
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
            Workspace.CurrentCamera.CameraSubject = h 
            Library:MakeNotify({ Title = "Stopped", Content = "Kembali ke karakter sendiri." })
        end 
    end 
})

-- ==========================================
-- SETTINGS TAB
-- ==========================================
local pengaturanSection = SettingsTab:AddSection("🛡️ Protection")

pengaturanSection:AddToggle({
    Title = "Streamer Mode",
    Description = "Menyamarkan tampilan menu",
    Default = false,
    Callback = function(v)
        if v then
            Library:MakeNotify({ Title = "Streamer Mode", Content = "Mode Penyamaran Aktif" })
        end
    end
})

pengaturanSection:AddButton({
    Title = "Fake Name (Anti-Screenshot)",
    Callback = function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.DisplayName = "Anonymous_User"
            Library:MakeNotify({ Title = "Success", Content = "Display Name diubah (Hanya kamu yang lihat)" })
        end
    end
})

-- ==========================================
-- SETTINGS - THEME
-- ==========================================
local ThemeSection = SettingsTab:AddSection("🎨 Appearance")

ThemeSection:AddDropdown({ 
    Title = "Select Theme", 
    Options = {"Dark", "Light", "Midnight", "Rose", "Emerald"}, 
    Default = "Midnight", 
    Callback = function(v) 
        pcall(function() Window:SetTheme(v) end)
    end 
})

-- ==========================================
-- SETTINGS - KEYBIND
-- ==========================================
local keybindSection = SettingsTab:AddSection("⌨️ Keybind")

keybindSection:AddKeybind({
    Title = "Toggle UI Menu",
    Default = Enum.KeyCode.RightControl,
    Callback = function()
        _G.MenuVisible = not _G.MenuVisible
        
        local gui = nil
        
        for _, child in pairs(CoreGui:GetChildren()) do
            if child.Name:find("MDW") or child.Name:find("Lynx") or child.Name:find("Window") or child.Name:find("Hub") then
                gui = child
                break
            end
        end
        
        if not gui then
            for _, child in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                if child.Name:find("MDW") or child.Name:find("Lynx") or child.Name:find("Window") or child.Name:find("Hub") then
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

keybindSection:AddButton({
    Title = "Show/Hide Menu",
    Callback = function()
        _G.MenuVisible = not _G.MenuVisible
        local gui = nil
        
        for _, child in pairs(CoreGui:GetChildren()) do
            if child.Name:find("MDW") or child.Name:find("Lynx") or child.Name:find("Window") or child.Name:find("Hub") then
                gui = child
                break
            end
        end
        
        if not gui then
            for _, child in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                if child.Name:find("MDW") or child.Name:find("Lynx") or child.Name:find("Window") or child.Name:find("Hub") then
                    gui = child
                    break
                end
            end
        end
        
        if gui then
            gui.Enabled = _G.MenuVisible
        end
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
                   obj.Name:find("GodLight") or obj.Name:find("Spawned_Monster") then
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
local ExitSection = SettingsTab:AddSection("❌ Exit")

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
        _G.AutoSkillMobile = false
        _G.Headlight = false
        _G.XRay = false
        _G.Fullbright = false
        _G.Freecam = false
        _G.Spam = false
        _G.ChatLog = false
        _G.AirWalk = false
        _G.AutoWalkJSON = false
        _G.WallHack = false
        _G.GodMode = false
        
        ToggleWallHack(false)
        
        ClearManualHighlights()
        
        Library:MakeNotify({ Title = "MDW HUB", Content = "Shutdown...", Duration = 2 })
        task.wait(1)
        Window:Destroy()
    end
})
local oldDestroyCallback = ExitSection.AddButton.Callback

local oldDestroy = ExitSection.AddButton.Callback

-- ==========================================
-- RENDER LOOP FOR ESP
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

-- Click TP
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if _G.TapTP and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local root = GetRootPart()
        if root then  
            local mouse = LocalPlayer:GetMouse()
            local targetPos = mouse.Hit.p
            root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        end
    end
end)

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
 
-- ==========================================
-- INITIALIZE
-- ==========================================
Library:Initialize()
Library:MakeNotify({ Title = "FCAL HUB", Content = "Script Loaded Successfully! (Anti-Kick Removed + God Mode Added)", Duration = 5 })

-- Auto update dropdown
Players.PlayerAdded:Connect(UpdateDropdown)
Players.PlayerRemoving:Connect(UpdateDropdown)
Players.PlayerRemoving:Connect(ClearESP)