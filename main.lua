--[[
    FCAL HUB - LYNX GUI EDITION
    Version: 1.1.0 | FULLY FIXED + NEW FEATURES
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
local GravityGunTool = nil
local GravityGunConnection = nil

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
_G.WallHackPlayer = false
_G.AimAssist = false
_G.SpeedHack = false
_G.SpeedHackValue = 50
_G.JumpHack = false
_G.JumpHackValue = 100
_G.GodMode = false
_G.NoFallDamage = false
_G.AutoHeal = false
_G.AutoHealValue = 50
_G.TeleportToMouse = false
_G.SilentAim = false
_G.RapidFire = false
_G.AutoClick = false
_G.AutoClickDelay = 0.1
_G.GhostMode = false
_G.TeleportOnDamage = false
_G.AntiStun = false
_G.AntiFreeze = false
_G.AutoRespawn = false
_G.SpiderMan = false
_G.NoclipSpeed = 50
_G.TeleportHistory = {}
_G.MacroRecorder = false
_G.MacroRecorded = {}
_G.MacroPlaying = false

local Config = {
    WalkSpeedDefault = 16,
    JumpPowerDefault = 50,
    GravityDefault = 196,
    Theme = "Midnight", 
    FlySpeed = 100,
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
    Title = "MDW",
    Footer = "v1.1.0 | Premium"
})

-- ==========================================
-- HELPER FUNCTIONS
-- ==========================================
function ClearESP(player)
    if ESP_Objects[player] then
        for _, obj in pairs(ESP_Objects[player]) do
            pcall(function() 
                if obj.Box then obj.Box:Remove() end
                if obj.Line then obj.Line:Remove() end
                if obj.Skeleton then 
                    for _, line in pairs(obj.Skeleton) do
                        line:Remove()
                    end
                end
                obj:Remove() 
            end)
        end
        ESP_Objects[player] = nil
    end
end

function ClearAllESP()
    for player, _ in pairs(ESP_Objects) do
        ClearESP(player)
    end
    ESP_Objects = {}
end

function ClearManualHighlights()
    for _, hl in pairs(ManualHighlights) do
        pcall(function() hl:Destroy() end)
    end
    ManualHighlights = {}
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
                        local sizeX = math.clamp(2000 / pos.Z, 10, 500)
                        local sizeY = math.clamp(3000 / pos.Z, 10, 700)
                        
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
                    
                    if _G.SkeletonESP then
                        UpdateSkeletonESP(player, objects)
                    else
                        for _, line in pairs(objects.Skeleton) do
                            line.Visible = false
                        end
                    end
                else
                    if ESP_Objects[player] then
                        if ESP_Objects[player].Box then ESP_Objects[player].Box.Visible = false end
                        if ESP_Objects[player].Line then ESP_Objects[player].Line.Visible = false end
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
            pcall(function() line:Remove() end)
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
-- WALLHACK PLAYER
-- ==========================================
function ToggleWallHackPlayer(enabled)
    _G.WallHackPlayer = enabled
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if enabled then
                        if not part:GetAttribute("OriginalTransparency") then
                            part:SetAttribute("OriginalTransparency", part.Transparency)
                        end
                        part.Transparency = 0.8
                    else
                        local orig = part:GetAttribute("OriginalTransparency")
                        if orig then
                            part.Transparency = orig
                        end
                    end
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
        -- Hapus tool lama jika ada
        if GravityGunTool then
            pcall(function() GravityGunTool:Destroy() end)
            GravityGunTool = nil
        end
        if GravityGunConnection then
            GravityGunConnection:Disconnect()
            GravityGunConnection = nil
        end
        
        GravityGunTool = Instance.new("Tool")
        GravityGunTool.RequiresHandle = false
        GravityGunTool.Name = "🧲 Gravity Gun"
        GravityGunTool.Parent = LocalPlayer.Backpack
        
        local mouse = LocalPlayer:GetMouse()
        local target = nil
        local connection = nil
        local holding = false
        
        local function onActivated()
            if mouse.Target and not mouse.Target.Anchored and mouse.Target:IsA("BasePart") and mouse.Target.Parent ~= LocalPlayer.Character then
                target = mouse.Target
                holding = true
                
                if connection then connection:Disconnect() end
                
                connection = RunService.RenderStepped:Connect(function()
                    if holding and target and GravityGunTool and GravityGunTool.Parent == LocalPlayer.Character then
                        local char = LocalPlayer.Character
                        if not char then return end
                        local head = char:FindFirstChild("Head")
                        if not head then return end
                        
                        local holdPos = head.CFrame * CFrame.new(0, 0, -10)
                        local direction = (holdPos.p - target.Position).Unit * 50
                        
                        target.AssemblyLinearVelocity = direction
                        target.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end)
            end
        end
        
        local function onDeactivated()
            holding = false
            if connection then 
                connection:Disconnect() 
                connection = nil
            end
            target = nil
        end
        
        GravityGunTool.Activated:Connect(onActivated)
        GravityGunTool.Deactivated:Connect(onDeactivated)
        GravityGunTool.Unequipped:Connect(onDeactivated)
        GravityGunConnection = GravityGunTool.AncestryChanged:Connect(function()
            if not GravityGunTool.Parent then
                onDeactivated()
            end
        end)
        
        Library:MakeNotify({ Title = "Success", Content = "Gravity Gun telah ditambahkan! Equip untuk menggunakan." })
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
        if v then
            task.spawn(function()
                while _G.AutoInteract do
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("ProximityPrompt") then
                                local parent = obj.Parent
                                if parent then
                                    local modelCFrame = parent:GetModelCFrame()
                                    if modelCFrame then
                                        local dist = (char.HumanoidRootPart.Position - modelCFrame.p).Magnitude
                                        if dist < 15 then
                                            pcall(function() fireproximityprompt(obj) end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
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
                -- Simpan posisi asli untuk efek visual yang lebih halus
                local origPos = tRoot.Position
                local targetPos = myRoot.Position + Vector3.new(0, 0, -3)
                
                -- Tween untuk efek smooth
                local tween = TweenService:Create(tRoot, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
                    Position = targetPos
                })
                tween:Play()
                
                Library:MakeNotify({ Title = "Success", Content = "Membawa " .. SelectedTarget })
            end
        else
            Library:MakeNotify({ Title = "Error", Content = "Pemain tidak ditemukan!" })
        end
    end
})

-- ==========================================
-- TROLL MOUNTAIN SECTION (FIXED)
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

-- ==========================================
-- AUTOWALK TAB (FIXED - Removed JSON)
-- ==========================================
local WalkSection = AutoWalking:AddSection("🗽 Auto Walk Mountain")

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

WalkSection:AddButton({
    Title = "Rescan Rute",
    Callback = function()
        local total = ScanMountain()
        Library:MakeNotify({ Title = "MDW HUB", Content = "Rute diperbarui: " .. total .. " titik." })
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
-- TAB AUTO CP (FIXED)
-- ==========================================
local FarmSection = GameTab:AddSection("🏔️ Auto CP All Mountain")

FarmSection:AddButton({
    Title = "🧹 Hapus Kotak Merah/Putih",
    Description = "Bersihkan highlight dan efek visual",
    Callback = function()
        ClearAllESP()
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
        ClearAllESP()
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
            table.insert(ManualHighlights, hl)
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

-- ==========================================
-- GAME TAB - VISUAL ESP (FIXED)
-- ==========================================
local VisualSection = GameTab:AddSection("🎭 Visual ESP & Tracking")

VisualSection:AddToggle({ 
    Title = "ESP Box (2D)", 
    Default = false, 
    Callback = function(v) 
        _G.BoxESP = v 
        if not v and not _G.LineESP and not _G.SkeletonESP then
            ClearAllESP()
        end
    end 
})

VisualSection:AddToggle({ 
    Title = "ESP Tracers (Line)", 
    Default = false, 
    Callback = function(v) 
        _G.LineESP = v 
        if not v and not _G.BoxESP and not _G.SkeletonESP then
            ClearAllESP()
        end
    end 
})

VisualSection:AddToggle({ 
    Title = "ESP Skeleton (Bone)", 
    Default = false, 
    Callback = function(v) 
        _G.SkeletonESP = v 
        if not v and not _G.BoxESP and not _G.LineESP then
            ClearAllESP()
        end
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
    end
})

-- Health ESP Loop
task.spawn(function()
    while true do
        task.wait(0.1)
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
                            local frame = gui:FindFirstChild("Background")
                            local bar = frame and frame:FindFirstChild("Frame")
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
-- NEW: WallHack Player
-- ==========================================
VisualSection:AddToggle({
    Title = "WallHack Player (See Players Through Walls)",
    Description = "Melihat pemain tembus dinding",
    Default = false,
    Callback = function(v)
        ToggleWallHackPlayer(v)
        Library:MakeNotify({ 
            Title = v and "WallHack Player ON" or "WallHack Player OFF", 
            Content = v and "Pemain menjadi transparan!" or "Pemain kembali normal" 
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
-- GAME TAB - FIND OBJECTS (FIXED with explanation)
-- ==========================================
local FindSection = GameTab:AddSection("🎯 Find Objects & Debug")

FindSection:AddButton({
    Title = "Find Generators",
    Description = "Highlight semua generator di map (kuning = belum selesai, hijau = selesai)",
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
        Library:MakeNotify({ Title = "Found", Content = count .. " generators highlighted! (Kuning=Belum, Hijau=Selesai)" })
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
        ClearAllESP()
        Library:MakeNotify({ Title = "Cleared", Content = "Semua highlight telah dihapus!" })
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

-- ==========================================
-- SERVER TAB - SPECTATE (FIXED)
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
        local currentPlayers = GetPlayerList()
        if SpectateDropdown.SetValues then
            SpectateDropdown:SetValues(currentPlayers)
        end
        Library:MakeNotify({ Title = "MDW", Content = "Daftar pemain telah diperbarui!" })
    end 
})

SpectateSection:AddButton({
    Title = "Mulai Spectate",
    Callback = function()
        if SpecTarget == "" or SpecTarget == "Tidak ada pemain" then
            Library:MakeNotify({ Title = "Warning", Content = "Pilih pemain dulu!" })
            return
        end
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
-- SETTINGS TAB - THEME (FIXED - Added themes from main_ui_modern.lua)
-- ==========================================
local ThemeSection = SettingsTab:AddSection("🎨 Appearance")

ThemeSection:AddDropdown({ 
    Title = "Select Theme", 
    Options = {"Dark", "Light", "Midnight", "Rose", "Emerald"}, 
    Default = "Midnight", 
    Callback = function(v) 
        -- Set theme using the library's theme system
        pcall(function() 
            if Window.SetTheme then
                Window:SetTheme(v)
            end
        end)
        -- Also update local theme tracking
        Config.Theme = v
        Library:MakeNotify({ Title = "Theme", Content = "Theme changed to: " .. v })
    end 
})

-- ==========================================
-- SETTINGS - KEYBIND (FIXED - Using proper keybind)
-- ==========================================
local keybindSection = SettingsTab:AddSection("⌨️ Keybind")

-- Use AddKeybind with proper callback
keybindSection:AddKeybind({
    Title = "Toggle UI Menu",
    Default = Enum.KeyCode.RightControl,
    Callback = function(key)
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
            Library:MakeNotify({ 
                Title = "Menu", 
                Content = _G.MenuVisible and "Menu Ditampilkan" or "Menu Disembunyikan" 
            })
        end
    end
})

-- ==========================================
-- NEW: PREMIUM FEATURES SECTION
-- ==========================================
local PremiumSection = SettingsTab:AddSection("⭐ Premium Features")

PremiumSection:AddToggle({
    Title = "Aim Assist (Lock On)",
    Description = "Auto aim ke pemain terdekat",
    Default = false,
    Callback = function(v)
        _G.AimAssist = v
        if v then
            task.spawn(function()
                while _G.AimAssist do
                    task.wait(0.05)
                    local target = nil
                    local dist = math.huge
                    local myRoot = GetRootPart()
                    if not myRoot then continue end
                    
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local d = (myRoot.Position - hrp.Position).Magnitude
                                if d < dist then
                                    dist = d
                                    target = hrp
                                end
                            end
                        end
                    end
                    
                    if target then
                        workspace.CurrentCamera.CFrame = CFrame.new(
                            workspace.CurrentCamera.CFrame.Position,
                            target.Position
                        )
                    end
                end
            end)
        end
    end
})

PremiumSection:AddToggle({
    Title = "Speed Hack",
    Description = "Meningkatkan kecepatan lari",
    Default = false,
    Callback = function(v)
        _G.SpeedHack = v
        if v then
            task.spawn(function()
                while _G.SpeedHack do
                    task.wait(0.1)
                    local hum = GetHumanoid()
                    if hum then
                        hum.WalkSpeed = _G.SpeedHackValue or 50
                    end
                end
            end)
        else
            local hum = GetHumanoid()
            if hum then
                hum.WalkSpeed = 16
            end
        end
    end
})

PremiumSection:AddInput({
    Title = "Speed Hack Value",
    Default = "50",
    Callback = function(v)
        _G.SpeedHackValue = tonumber(v) or 50
        if _G.SpeedHack then
            local hum = GetHumanoid()
            if hum then
                hum.WalkSpeed = _G.SpeedHackValue
            end
        end
    end
})

PremiumSection:AddToggle({
    Title = "Jump Hack",
    Description = "Meningkatkan kekuatan lompat",
    Default = false,
    Callback = function(v)
        _G.JumpHack = v
        if v then
            task.spawn(function()
                while _G.JumpHack do
                    task.wait(0.1)
                    local hum = GetHumanoid()
                    if hum then
                        hum.UseJumpPower = true
                        hum.JumpPower = _G.JumpHackValue or 100
                    end
                end
            end)
        else
            local hum = GetHumanoid()
            if hum then
                hum.JumpPower = 50
            end
        end
    end
})

PremiumSection:AddInput({
    Title = "Jump Hack Value",
    Default = "100",
    Callback = function(v)
        _G.JumpHackValue = tonumber(v) or 100
        if _G.JumpHack then
            local hum = GetHumanoid()
            if hum then
                hum.JumpPower = _G.JumpHackValue
            end
        end
    end
})

PremiumSection:AddToggle({
    Title = "God Mode (Invincible)",
    Description = "Tidak bisa mati",
    Default = false,
    Callback = function(v)
        _G.GodMode = v
        if v then
            task.spawn(function()
                while _G.GodMode do
                    task.wait(0.1)
                    local hum = GetHumanoid()
                    if hum then
                        hum.Health = hum.MaxHealth
                        hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
                    end
                end
            end)
        end
    end
})

PremiumSection:AddToggle({
    Title = "Auto Heal",
    Description = "Auto heal saat health rendah",
    Default = false,
    Callback = function(v)
        _G.AutoHeal = v
        if v then
            task.spawn(function()
                while _G.AutoHeal do
                    task.wait(0.1)
                    local hum = GetHumanoid()
                    if hum and hum.Health < (_G.AutoHealValue or 50) then
                        hum.Health = hum.MaxHealth
                    end
                end
            end)
        end
    end
})

PremiumSection:AddInput({
    Title = "Auto Heal Threshold",
    Default = "50",
    Callback = function(v)
        _G.AutoHealValue = tonumber(v) or 50
    end
})

PremiumSection:AddToggle({
    Title = "Anti-Stun",
    Description = "Mencegah terkena stun/ragdoll",
    Default = false,
    Callback = function(v)
        _G.AntiStun = v
        if v then
            task.spawn(function()
                while _G.AntiStun do
                    task.wait(0.1)
                    local hum = GetHumanoid()
                    if hum then
                        if hum.PlatformStand then hum.PlatformStand = false end
                        if hum.Sit then hum.Sit = false end
                    end
                    local root = GetRootPart()
                    if root and root.Anchored then
                        root.Anchored = false
                    end
                end
            end)
        end
    end
})

-- ==========================================
-- NEW: UNIQUE FEATURES
-- ==========================================
local UniqueSection = SettingsTab:AddSection("✨ Unique Features")

UniqueSection:AddToggle({
    Title = "Spider-Man Mode",
    Description = "Bisa berjalan di dinding",
    Default = false,
    Callback = function(v)
        _G.SpiderMan = v
        if v then
            task.spawn(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                while _G.SpiderMan do
                    task.wait(0.1)
                    local hum = GetHumanoid()
                    if hum and root then
                        hum.UseJumpPower = true
                        hum.JumpPower = 30
                        
                        -- Detect wall
                        local ray = Ray.new(
                            root.Position,
                            workspace.CurrentCamera.CFrame.LookVector * 5
                        )
                        local hit = workspace:FindPartOnRay(ray, char)
                        if hit then
                            root.CFrame = CFrame.new(hit.Position + hit.Normal * 2)
                        end
                    end
                end
            end)
        end
    end
})

UniqueSection:AddToggle({
    Title = "Ghost Mode",
    Description = "Menjadi tak terlihat dan tidak bisa disentuh",
    Default = false,
    Callback = function(v)
        _G.GhostMode = v
        local char = LocalPlayer.Character
        if not char then return end
        
        if v then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0.8
                    part.CanCollide = false
                end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
                hum.BreakJointsOnDeath = false
            end
        else
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
                hum.BreakJointsOnDeath = true
            end
        end
    end
})

UniqueSection:AddToggle({
    Title = "Rapid Fire",
    Description = "Menembak lebih cepat",
    Default = false,
    Callback = function(v)
        _G.RapidFire = v
        if v then
            task.spawn(function()
                while _G.RapidFire do
                    task.wait(0.01)
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.MouseButton1, false, game)
                        task.wait(0.01)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.MouseButton1, false, game)
                    end)
                end
            end)
        end
    end
})

UniqueSection:AddToggle({
    Title = "Auto Respawn",
    Description = "Auto respawn saat mati",
    Default = false,
    Callback = function(v)
        _G.AutoRespawn = v
        if v then
            task.spawn(function()
                while _G.AutoRespawn do
                    task.wait(0.1)
                    if not LocalPlayer.Character then
                        LocalPlayer:LoadCharacter()
                        task.wait(1)
                    end
                end
            end)
        end
    end
})

UniqueSection:AddToggle({
    Title = "Teleport to Mouse",
    Description = "Teleport ke posisi mouse saat klik tengah",
    Default = false,
    Callback = function(v)
        _G.TeleportToMouse = v
        if v then
            local mouse = LocalPlayer:GetMouse()
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if _G.TeleportToMouse and input.UserInputType == Enum.UserInputType.MouseButton2 then
                    local root = GetRootPart()
                    if root and mouse.Hit then
                        root.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
                    end
                end
            end)
            _G.TeleportToMouseConnection = connection
        else
            if _G.TeleportToMouseConnection then
                _G.TeleportToMouseConnection:Disconnect()
                _G.TeleportToMouseConnection = nil
            end
        end
    end
})

-- ==========================================
-- RENDER LOOP FOR ESP (Optimized - no lag)
-- ==========================================
RunService.RenderStepped:Connect(function()
    if not (_G.BoxESP or _G.LineESP or _G.SkeletonESP) then
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
Library:MakeNotify({ Title = "FCAL HUB", Description = "Script Loaded Successfully!", Duration = 5 })

-- Auto update dropdown
Players.PlayerAdded:Connect(UpdateDropdown)
Players.PlayerRemoving:Connect(UpdateDropdown)
Players.PlayerRemoving:Connect(ClearESP)
Players.PlayerRemoving:Connect(function(player)
    RemoveESPForPlayer(player)
end)

-- Cleanup on exit
LocalPlayer.CharacterAdded:Connect(function()
    if _G.ESP then
        task.wait(0.5)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                CreateESPForPlayer(p)
            end
        end
    end
end)

print("FCAL HUB v1.1.0 Loaded Successfully!")