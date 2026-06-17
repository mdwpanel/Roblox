--[[
    FCAL HUB - LYNX GUI EDITION
    Version: 1.0.8 | FULL FEATURES + TROLL MOUNTAIN
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
    Footer = "v1.0.8 | Client Sided"
})

-- ==========================================
-- HELPER FUNCTIONS
-- ==========================================
function ClearESP(player)
    if ESP_Objects[player] then
        for _, obj in pairs(ESP_Objects[player]) do
            pcall(function() obj.Visible = false end)
            pcall(function() obj:Remove() end)
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
                            Line = Drawing.new("Line")
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
-- TROLL MOUNTAIN SECTION (FITUR JAHIL)
-- ==========================================
-- ==========================================
-- TROLL MOUNTAIN SECTION - SIMPLIFIED & FIXED
-- ==========================================

-- PASTIKAN VARIABLE INI ADA
local SelectedTarget = "" -- Ini harus sama dengan yang di dropdown

-- FUNGSI UNTUK MENDAPATKAN TARGET
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

-- BUAT SECTION TROLL
local TrollSection = MainTab:AddSection("👿 Troll Mountain")
 
-- ==========================================
-- FITUR 1: DORONG DARI TEBING
-- ==========================================
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
        
        -- DORONG
        local dir = hrp.CFrame.LookVector * -100
        hrp.AssemblyLinearVelocity = Vector3.new(dir.X, 30, dir.Z)
        
        -- EFEK LEDAKAN
        local boom = Instance.new("Explosion")
        boom.Position = hrp.Position
        boom.BlastRadius = 5
        boom.BlastPressure = 0
        boom.Parent = workspace
        
        Library:MakeNotify({ Title = "💨 DORONG!", Content = target.Name .. " didorong!", Duration = 3 })
    end
})

-- ==========================================
-- FITUR 2: FLING TARGET
-- ==========================================
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
        
        -- FLING
        hrp.AssemblyLinearVelocity = Vector3.new(
            math.random(-150, 150),
            math.random(300, 500),
            math.random(-150, 150)
        )
        
        -- EFEK
        local boom = Instance.new("Explosion")
        boom.Position = hrp.Position
        boom.BlastRadius = 5
        boom.BlastPressure = 0
        boom.Parent = workspace
        
        Library:MakeNotify({ Title = "🚀 FLING!", Content = target.Name .. " terbang!", Duration = 3 })
    end
})

-- ==========================================
-- FITUR 3: KANDANG
-- ==========================================
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
        
        -- DINDING
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
        
        -- ATAP
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
        
        -- HAPUS SETELAH 5 DETIK
        task.wait(5)
        for _, p in pairs(parts) do
            pcall(function() p:Destroy() end)
        end
    end
})

-- ==========================================
-- FITUR 4: LANTAI LICIN
-- ==========================================
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
                
                -- LICIN
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
-- FITUR 5: LONGSOR BATU
-- ==========================================
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
            
            -- JATUH CEPAT
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

-- ==========================================
-- FITUR 6: TELEPORT BALIK
-- ==========================================
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
        
        -- CARI CHECKPOINT PALING RENDAH
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

-- ==========================================
-- FITUR 7: GEMPA BUMI
-- ==========================================
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

-- ==========================================
-- FITUR 8: CLONE TARGET
-- ==========================================
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
        
        -- CLONE
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

-- ==========================================
-- FITUR 9: ZONA GRAVITASI
-- ==========================================
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
        
        -- ZONA UNGU
        local zone = Instance.new("Part")
        zone.Shape = Enum.PartType.Ball
        zone.Size = Vector3.new(30, 30, 30)
        zone.Position = pos
        zone.BrickColor = BrickColor.new("Bright purple")
        zone.Transparency = 0.5
        zone.Anchored = true
        zone.CanCollide = false
        zone.Parent = workspace
        
        -- TARIK KE BAWAH
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

-- ==========================================
-- FITUR 10: BUTAKAN TARGET
-- ==========================================
TrollSection:AddButton({
    Title = "👁️ Butakan Target",
    Callback = function()
        local target = GetTrollTarget()
        if not target then return end
        
        -- BUAT GUI DI LAYAR TARGET
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

-- ==========================================
-- FITUR 11: TEMBOK DI DEPAN
-- ==========================================
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
]
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
    
    -- Cari semua objek di workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then
            local name = obj.Name:lower()
            local pos = obj.Position
            local found = false
            
            -- SKIP objek yang jelas bukan checkpoint
            if name:find("humanoid") or name:find("player") or 
               name:find("character") or name:find("npc") or
               name:find("particle") or name:find("effect") or
               name:find("attachment") or name:find("handle") then
                -- Skip
            else
                -- CEK NAMA CHECKPOINT (LEBIH BANYAK VARIASI)
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
                
                -- CEK ATRIBUT
                if obj:GetAttribute("Checkpoint") or 
                   obj:GetAttribute("CP") or 
                   obj:GetAttribute("Stage") or
                   obj:GetAttribute("Point") or
                   obj:GetAttribute("Level") then
                    found = true
                end
                
                -- CEK SPAWN LOCATION (biasanya checkpoint)
                if obj:IsA("SpawnLocation") then
                    found = true
                end
                
                -- CEK UKURAN (checkpoint biasanya lebih besar)
                if obj:IsA("BasePart") and obj.Size.X > 5 and obj.Size.Z > 5 then
                    -- Cek apakah ini checkpoint
                    if name:find("plate") or name:find("floor") or name:find("ground") then
                        found = true
                    end
                end
            end
            
            if found and pos.Y > -50 then
                -- Ambil nomor dari nama
                local num = tonumber(obj.Name:match("%d+")) or 0
                
                -- Cegah duplikat
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
    
    -- HAPUS DUPLIKAT
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
    
    -- URUTKAN BERDASARKAN KETINGGIAN
    table.sort(unique, function(a, b)
        return a.Y < b.Y
    end)
    
    return unique
end

-- ==========================================
-- TAB AUTO CP
-- ==========================================
local FarmSection = GameTab:AddSection("🏔️ Auto CP All Mountain")

-- TOMBOL HAPUS KOTAK MERAH/PUTIH
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

-- AUTO CP
FarmSection:AddToggle({
    Title = "Auto CP All Mountain (Fix)",
    Description = "Teleport otomatis ke semua checkpoint (URUT)",
    Default = false,
    Callback = function(v)
        _G.AutoCPAll = v
        
        if v then
            task.spawn(function()
                -- SCAN CHECKPOINT
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
                
                -- LOOP KE SEMUA CHECKPOINT
                for i, cp in ipairs(cps) do
                    if not _G.AutoCPAll then 
                        Library:MakeNotify({ 
                            Title = "⏹️ Berhenti", 
                            Content = "Auto CP dimatikan manual", 
                            Duration = 2 
                        })
                        break 
                    end
                    
                    -- Update karakter
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
                    
                    -- Cek humanoid
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health <= 0 then
                        Library:MakeNotify({ 
                            Title = "💀 Mati", 
                            Content = "Karakter mati, berhenti...", 
                            Duration = 3 
                        })
                        break
                    end
                    
                    -- TELEPORT KE CHECKPOINT
                    local targetCF = cp.Part.CFrame * CFrame.new(0, 5, 0)
                    root.CFrame = targetCF
                    
                    -- Simulasi sentuh
                    pcall(function()
                        if firetouchinterest then
                            firetouchinterest(root, cp.Part, 0)
                            task.wait(0.1)
                            firetouchinterest(root, cp.Part, 1)
                        end
                    end)
                    
                    currentIndex = i
                    
                    -- NOTIFIKASI
                    Library:MakeNotify({ 
                        Title = "✅ CP " .. i .. "/" .. #cps, 
                        Content = cp.Name .. " (Y: " .. math.floor(cp.Y) .. ")", 
                        Duration = 1.5 
                    })
                    
                    -- DELAY
                    task.wait(_G.CPTeleportDelay or 0.8)
                end
                
                -- SELESAI
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

-- DELAY SETTINGS
FarmSection:AddInput({
    Title = "Delay Antar CP (detik)",
    Description = "Jeda antara teleport ke checkpoint berikutnya",
    Default = "0.8",
    Callback = function(v)
        _G.CPTeleportDelay = tonumber(v) or 0.8
    end
})

-- ==========================================
-- SCAN & INFO
-- ==========================================
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
        
        -- HIGHLIGHT SEMUA CHECKPOINT (BIRU)
        for _, cp in pairs(cps) do
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(0, 150, 255)
            hl.FillTransparency = 0.6
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.Adornee = cp.Part
            hl.Parent = cp.Part
        end
        
        -- TAMPILKAN DAFTAR
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

-- ==========================================
-- TP MANUAL
-- ==========================================
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
        
        -- Cari CP berikutnya
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
            -- Cari yang tertinggi
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
-- TP KE CP NOMOR TERTENTU
-- ==========================================
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
        
        -- Tampilkan di console
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
        
        -- Listener chat
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

-- Tombol khusus untuk membersihkan
FarmSection:AddButton({
    Title = "🧹 Hapus Kotak Merah/Putih",
    Callback = function()
        ClearAllHighlights()
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
-- SERVER TAB - PROTECTION
-- ==========================================
local ProtectSection = ServerTab:AddSection("🛡️ Self-Protection & Security")

ProtectSection:AddToggle({
    Title = "Anti-Kick Protection",
    Description = "Mendeteksi upaya kick (Notifikasi saja)",
    Default = false,
    Callback = function(v)
        _G.AntiKick = v
    end
})

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
        
        ClearManualHighlights()
        
        Library:MakeNotify({ Title = "MDW HUB", Content = "Shutdown...", Duration = 2 })
        task.wait(1)
        Window:Destroy()
    end
})

-- ==========================================
-- RENDER LOOP FOR ESP
-- ==========================================
RunService.RenderStepped:Connect(function()
    if not (_G.BoxESP or _G.LineESP) then
        for _, obj in pairs(ESP_Objects) do 
            pcall(function()
                obj.Box.Visible = false 
                obj.Line.Visible = false 
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
                        Line = Drawing.new("Line") 
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