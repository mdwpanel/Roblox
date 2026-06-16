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

-- Global Variables (Didefinisikan di awal agar tidak error)
local LocalPlayer = Players.LocalPlayer
local ESP_Objects = {}
local ManualHighlights = {}
local ESPHighlights = {}
local ESPLabels = {}
local ToggleKey = Enum.KeyCode.RightControl
local msg = "FCAL HUB ON TOP!"
local SpecTarget = ""
local hbSize = 2

_G.AutoCP = false
_G.InfJump = false
_G.NC = false
_G.TapTP = false
_G.BoxESP = false
_G.LineESP = false
_G.ESP = false
_G.HealthESP = false
_G.AntiRagdoll = false
_G.AntiVoid = false
_G.AntiKick = false
_G.AdminDetect = false
_G.Hitbox = false

local Config = {
    WalkSpeedDefault = 16,
    JumpPowerDefault = 50,
    GravityDefault = 196,
    Theme = "Midnight", 
    FlySpeed = 100,
}

-- ==========================================
-- FORWARD DECLARATIONS (Mencegah Error Nil Function)
-- ==========================================
local ClearESP, UpdateESP, Notify, GetHumanoid, GetRootPart, GetPlayerByName
local GetAllPlayers, UpdateWalkSpeedUI, UpdateJumpPowerUI, UpdateGravityUI, UpdateFlySpeedUI
local GetPlayerRole, GetESPColor, IsGenerator, IsGeneratorCompleted, GetGeneratorProgress
local CreateESPForPlayer, RemoveESPForPlayer, UpdateESPForPlayer, CreateGeneratorESP
local UpdateGeneratorESP, RemoveAllGeneratorESP, FindAllGenerators, ClearManualHighlights

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

-- ==========================================
-- HELPER FUNCTIONS & ESP CORE LOGIC
-- ==========================================
function ClearESP(player)
    if ESP_Objects[player] then
        for _, obj in pairs(ESP_Objects[player]) do
            obj.Visible = false
            obj:Remove()
        end
        ESP_Objects[player] = nil
    end
end

local function ClearManualHighlights()
    for _, hl in pairs(ManualHighlights) do
        if hl then hl:Destroy() end
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

RunService.RenderStepped:Connect(function()
    if _G.BoxESP or _G.LineESP then
        UpdateESP()
    else
        for player, _ in pairs(ESP_Objects) do ClearESP(player) end
    end
end)

Players.PlayerRemoving:Connect(ClearESP)

local function Notify(title, desc, typ)
    Library:MakeNotify({Title = title, Content = desc, Duration = 3})
end

local function GetHumanoid()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
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

local ESPConnections = {}
local ESPHighlights = {}
local ESPLabels = {}
local GenHighlights = {}
local CachedCPs = {}

local function ScanMapForCPs()
    CachedCPs = {} -- Reset cache
    local count = 0
    
    -- Kita scan map hanya SEKALI saat tombol ditekan
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then
            local name = obj.Name:lower()
            local num = tonumber(obj.Name:match("%d+"))
            
            -- Kriteria pencarian universal
            if num and (name:find("cp") or name:find("stage") or name:find("point") or name:find("level") or obj:IsA("SpawnLocation")) then
                table.insert(CachedCPs, {Part = obj, Num = num})
                count = count + 1
            end
        end
    end
    
    -- Urutkan berdasarkan angka
    table.sort(CachedCPs, function(a, b) return a.Num < b.Num end)
    return count
end
local function CreateESPForPlayer(player)
    if player == LocalPlayer or not player.Character then return end
    
    -- 1. Highlight ESP (3D)
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

local function RemoveESPForPlayer(player)
    if ESP_Highlights[player] then
        ESP_Highlights[player]:Destroy()
        ESP_Highlights[player] = nil
    end
    if player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("HealthBarGui") then
        player.Character.Head.HealthBarGui:Destroy()
    end
end

function UpdateESPForPlayer(player)
    if not _G.ESP or player == LocalPlayer then return end
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
    end
end

function CreateGeneratorESP(gen)
    if GenHighlights[gen] then return end
    local isCompleted = IsGeneratorCompleted(gen)
    local progress = GetGeneratorProgress(gen)
    
    local fillColor = isCompleted and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 170, 0)
    local hl = Instance.new("Highlight")
    hl.FillColor = fillColor
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.Adornee = gen
    hl.Parent = gen
    
    local primaryPart = gen:IsA("Model") and gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart")
    local billboard
    if primaryPart then
        billboard = Instance.new("BillboardGui", game.CoreGui)
        billboard.Size = UDim2.new(0, 120, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 5, 0)
        billboard.Adornee = primaryPart
        billboard.AlwaysOnTop = true
        
        local label = Instance.new("TextLabel", billboard)
        label.Name = "GenLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = fillColor
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Text = isCompleted and "✓ COMPLETE" or ("⚡ " .. math.floor(progress) .. "%")
    end
    GenHighlights[gen] = {Highlight = hl, Label = billboard, LastCompleted = isCompleted, LastProgress = progress}
end

function UpdateGeneratorESP()
    if not _G.GenESP then return end
    for gen, data in pairs(GenHighlights) do
        if gen and gen.Parent then
            local isCompleted = IsGeneratorCompleted(gen)
            local progress = GetGeneratorProgress(gen)
            if isCompleted ~= data.LastCompleted or progress ~= data.LastProgress then
                data.LastCompleted = isCompleted
                data.LastProgress = progress
                if data.Highlight then data.Highlight.FillColor = isCompleted and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 170, 0) end
                if data.Label and data.Label:FindFirstChild("GenLabel") then
                    data.Label.GenLabel.Text = isCompleted and "✓ COMPLETE" or ("⚡ " .. math.floor(progress) .. "%")
                    data.Label.GenLabel.TextColor3 = isCompleted and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 170, 0)
                end
            end
        else
            if data.Highlight then data.Highlight:Destroy() end
            if data.Label then data.Label:Destroy() end
            GenHighlights[gen] = nil
        end
    end
end

function RemoveAllGeneratorESP()
    for gen, data in pairs(GenHighlights) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Label then data.Label:Destroy() end
    end
    GenHighlights = {}
end

function FindAllGenerators()
    local generators = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if IsGenerator(obj) then table.insert(generators, obj) end
    end
    return generators
end

local function SafeRefreshDropdown(dropdown, list)
    if dropdown and dropdown.Clear then
        dropdown:Clear()
        for _, item in pairs(list) do
            dropdown:Add(item)
        end
    end
end

local MountainPaths = {}

local function ScanUniversalCPs()
    MountainPaths = {}
    local count = 0
    
    -- Ambil semua objek yang berpotensi jadi Checkpoint
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Kriteria 1: Semua SpawnLocation (Standar Roblox untuk Checkpoint)
        -- Kriteria 2: Part yang punya nama mengandung kata kunci umum
        if obj:IsA("SpawnLocation") or (obj:IsA("BasePart") and (
            obj.Name:lower():find("checkpoint") or 
            obj.Name:lower():find("stage") or 
            obj.Name:lower():find("camp") or 
            obj.Name:lower():find("flag") or
            obj.Name:lower():find("point")
        )) then
            table.insert(MountainPaths, obj)
            count = count + 1
        end
    end

    -- LOGIKA UTAMA: Urutkan berdasarkan Ketinggian (Y Axis)
    -- Ini yang membuat script bisa jalan di semua map gunung
    table.sort(MountainPaths, function(a, b)
        return a.Position.Y < b.Position.Y
    end)
    
    return count
end

-- ==========================================
-- USER INTERFACE TABS SETUP
-- ==========================================
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
    Title = "Get Gravity Gun",
    Description = "Tool untuk menarik dan membawa objek di map",
    Callback = function()
        -- Pastikan Services didefinisikan
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer
        
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "🧲 Gravity Gun"
        tool.Parent = LocalPlayer.Backpack
        
        local mouse = LocalPlayer:GetMouse()
        local target = nil
        local connection = nil
        
        tool.Activated:Connect(function()
            -- Cek apakah target valid (bukan tanah/baseplate dan tidak di-anchor)
            if mouse.Target and not mouse.Target.Anchored and mouse.Target:IsA("BasePart") then
                target = mouse.Target
                
                -- Putus koneksi lama jika ada untuk menghindari tumpukan loop
                if connection then connection:Disconnect() end
                
                connection = RunService.RenderStepped:Connect(function()
                    if target and tool.Parent == LocalPlayer.Character then
                        -- Titik tujuan (10 kancing di depan kepala pemain)
                        local holdPos = LocalPlayer.Character.Head.CFrame * CFrame.new(0, 0, -10).p
                        local direction = (holdPos - target.Position)
                        
                        -- Gunakan AssemblyLinearVelocity agar lebih responsif di mesin fisik baru Roblox
                        target.AssemblyLinearVelocity = direction * 15
                        
                        -- Menghilangkan rotasi berlebih agar objek tidak berputar gila
                        target.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    else
                        if connection then connection:Disconnect() end
                    end
                end)
            end
        end)
        
        -- Berhenti saat klik dilepas
        tool.Deactivated:Connect(function()
            if connection then connection:Disconnect() end
            target = nil
        end)
        
        -- Berhenti saat tool disimpan/dilepas
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
            LocalPlayer.Character.Humanoid.Health = 0 -- Cara paling aman reset
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

-- [[ TELEPORT ]]
local TpSection = MainTab:AddSection("🎯 Teleport")

TpSection:AddToggle({
    Title = "Tap to Teleport",
    Description = "Klik di layar untuk pindah posisi",
    Default = false,
    Callback = function(v) _G.TapTP = v end
})

-- [[ PLAYER TELEPORT ]]
local QuickTpSection = MainTab:AddSection("🚀 Quick Player Teleport")

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
                        -- Cek jarak agar tidak mengambil barang yang terlalu jauh
                        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Parent:GetModelCFrame().p).Magnitude
                        if dist < 15 then
                            fireproximityprompt(obj)
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
})

local SelectedTarget = ""

-- Fungsi mendapatkan list pemain yang valid
local function GetPlayerList()
    local list = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then 
            table.insert(list, p.Name) 
        end
    end
    
    -- Jika server sepi, berikan teks bantuan agar tidak kosong total
    if #list == 0 then 
        return {"Tidak ada pemain"} 
    end
    
    table.sort(list) -- Urutkan nama sesuai abjad agar rapi
    return list
end

-- Membuat Dropdown
local PlayerDropdown = QuickTpSection:AddDropdown({
    Title = "Pilih Pemain",
    Description = "Cari atau pilih nama pemain",
    Options = GetPlayerList(), -- Di Redz Library biasanya menggunakan 'Options'
    Default = "",
    Callback = function(v) 
        SelectedTarget = v 
    end
})

-- Fungsi Update Dropdown (Untuk Refresh)
local function UpdateDropdown()
    local currentPlayers = GetPlayerList()
    -- Library Redz/Lucid biasanya menggunakan SetValues atau Refresh
    if PlayerDropdown.SetValues then
        PlayerDropdown:SetValues(currentPlayers)
    elseif PlayerDropdown.Refresh then
        PlayerDropdown:Refresh(currentPlayers, true)
    end
end

-- Tombol Refresh Manual
QuickTpSection:AddButton({ 
    Title = "🔄 Refresh Daftar Pemain", 
    Callback = function()
        UpdateDropdown()
        Library:MakeNotify({ Title = "MDW", Content = "Daftar pemain telah diperbarui!" })
    end 
})

-- Tombol Teleport
QuickTpSection:AddButton({
    Title = "Teleport Sekarang",
    Callback = function()
        if SelectedTarget == "" or SelectedTarget == "Tidak ada pemain" then 
            Library:MakeNotify({ Title = "Warning", Content = "Pilih pemain dulu!" })
            return 
        end
        
        local target = game.Players:FindFirstChild(SelectedTarget)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myChar = game.Players.LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                -- Teleport ke posisi target
                myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                Library:MakeNotify({ Title = "Success", Content = "Berhasil ke " .. SelectedTarget })
            end
        else
            Library:MakeNotify({ Title = "Error", Content = "Pemain tidak ditemukan/sudah keluar!" })
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

MoveSection:AddToggle({
    Title = "Real Air Walk",
    Description = "Berjalan di udara seperti di lantai padat",
    Default = false,
    Callback = function(v)
        _G.AirWalk = v
        
        if v then
            -- Buat lantai transparan baru
            AirPlatform = Instance.new("Part")
            AirPlatform.Name = "MDW_AirFloor"
            AirPlatform.Size = Vector3.new(6, 1, 6) -- Ukuran lantai di bawah kaki
            AirPlatform.Transparency = 1 -- 1 = Tidak terlihat, 0.5 jika ingin sedikit terlihat
            AirPlatform.Anchored = true
            AirPlatform.CanCollide = true
            AirPlatform.Parent = workspace
            
            task.spawn(function()
                while _G.AirWalk do
                    local char = game.Players.LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    
                    if root and hum then
                        -- Lantai selalu berada tepat di bawah kaki (3.5 studs di bawah root)
                        -- Kita hanya mengambil posisi X dan Z dari pemain, 
                        -- sedangkan Y (tinggi) mengikuti posisi kaki agar bisa naik/turun jika melompat
                        local targetPos = root.Position + Vector3.new(0, -3.5, 0)
                        
                        -- Jika Anda ingin mengunci ketinggian (tetap datar), gunakan ini:
                        -- AirPlatform.CFrame = CFrame.new(root.Position.X, targetHeight, root.Position.Z)
                        
                        -- Versi dinamis (mengikuti kaki saat melompat/jalan):
                        AirPlatform.CFrame = CFrame.new(targetPos)
                        
                        -- Agar tidak terpeleset, kita buat rotasi lantai tetap datar
                        AirPlatform.Rotation = Vector3.new(0, 0, 0)
                    end
                    task.wait() -- Update sangat cepat (60fps) agar tidak tembus
                end
                
                -- Hapus lantai saat dimatikan
                if AirPlatform then
                    AirPlatform:Destroy()
                    AirPlatform = nil
                end
            end)
            
            Library:MakeNotify({ Title = "Air Walk", Content = "Aktif! Sekarang Anda bisa berjalan di langit.", Time = 3 })
        else
            -- Matikan fitur
            if AirPlatform then
                AirPlatform:Destroy()
                AirPlatform = nil
            end
            Library:MakeNotify({ Title = "Air Walk", Content = "Dimatikan.", Time = 3 })
        end
    end
})

MoveSection:AddToggle({
    Title = "Air Walk (Jesus Mode)",
    Default = false,
    Callback = function(v)
        _G.AirWalk = v
        if v then
            local plat = Instance.new("Part")
            plat.Size = Vector3.new(10, 1, 10)
            plat.Value = "AirWalkPlatform"
            plat.Anchored = true
            plat.Transparency = 1
            plat.Parent = Workspace
            
            task.spawn(function()
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


-- Variabel Platform
local VoidPart = Instance.new("Part")
VoidPart.Name = "AntiVoidPlatform"
VoidPart.Size = Vector3.new(20, 1, 20) -- Ukuran lantai transparan
VoidPart.Transparency = 1 -- 1 = Tidak terlihat
VoidPart.Anchored = true
VoidPart.CanCollide = false -- Default mati agar tidak mengganggu jalan biasa

AntiSection:AddToggle({
    Title = "Walking Anti-Void (Air Walk)",
    Description = "Berjalan di udara saat berada di jurang",
    Default = false,
    Callback = function(v)
        _G.WalkingAntiVoid = v
        
        if v then
            task.spawn(function()
                -- Simpan tinggi awal saat menyalakan (ketinggian aman)
                local safeHeight = 0
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then safeHeight = root.Position.Y - 3.5 end

                while _G.WalkingAntiVoid do
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if hrp then
                        -- Jika karakter jatuh di bawah ketinggian aman
                        if hrp.Position.Y < (safeHeight - 5) then
                            VoidPart.Parent = workspace
                            VoidPart.CanCollide = true
                            -- Posisi lantai mengikuti X dan Z pemain, tapi Y (tinggi) tetap di batas aman
                            VoidPart.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z)
                        else
                            -- Jika sedang di daratan biasa, matikan tabrakan lantai agar tidak bug
                            VoidPart.CanCollide = false
                            VoidPart.Parent = nil
                        end
                    end
                    task.wait() -- Update sangat cepat agar tidak tembus
                end
                VoidPart:Destroy() -- Hapus jika toggle dimatikan
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

local FlySection = PlayerTab:AddSection("✈️ Fly Settings")

-- Inisialisasi variabel jika belum ada
if not Config then Config = {} end
Config.FlySpeed = 100

FlySection:AddInput({ 
    Title = "Fly Speed", 
    Default = 100, 
    Callback = function(v) 
        Config.FlySpeed = tonumber(v) or 100 
    end 
})

FlySection:AddToggle({
    Title = "Fly Mode",
    Description = "Bisa naik pake tombol lompat (PC/Mobile)",
    Default = false,
    Callback = function(v)
        _G.Fly = v
        local root = GetRootPart()
        local hum = GetHumanoid()
        
        if v then
            if not root or not hum then return end

            -- Hapus gaya lama jika ada
            if root:FindFirstChild("FlyVel") then root.FlyVel:Destroy() end
            if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end

            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.Name = "FlyVel"
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.Velocity = Vector3.new(0, 0.1, 0)
            bodyVel.Parent = root

            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.Name = "FlyGyro"
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro.P = 9e4
            bodyGyro.CFrame = root.CFrame
            bodyGyro.Parent = root

            _G.FlyCon = RunService.RenderStepped:Connect(function()
                if _G.Fly and root and root.Parent and hum then
                    local cam = workspace.CurrentCamera
                    local speed = Config.FlySpeed or 100
                    local moveDir = hum.MoveDirection * speed
                    
                    -- LOGIKA NAIK (Mendukung Mobile & PC)
                    -- hum.Jump akan bernilai true saat tombol lompat ditekan di layar HP
                    local isJumping = UserInputService:IsKeyDown(Enum.KeyCode.Space) or hum.Jump
                    local isLowering = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
                    
                    local verticalVelocity = 0
                    if isJumping then
                        verticalVelocity = speed
                    elseif isLowering then
                        verticalVelocity = -speed
                    end

                    bodyVel.Velocity = Vector3.new(moveDir.X, verticalVelocity, moveDir.Z)
                    bodyGyro.CFrame = cam.CFrame
                else
                    -- Jika toggle dimatikan atau karakter mati, putus koneksi
                    if _G.FlyCon then _G.FlyCon:Disconnect() end
                end
            end)
            Library:MakeNotify({ Title = "Enabled", Content = "Terbang Aktif! Gunakan tombol lompat untuk naik." })
        else
            -- MATIKAN FLY
            if _G.FlyCon then _G.FlyCon:Disconnect() _G.FlyCon = nil end
            if root then
                if root:FindFirstChild("FlyVel") then root.FlyVel:Destroy() end
                if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
            end
            Library:MakeNotify({ Title = "Disabled", Content = "Fly Dimatikan" })
        end
    end
})

-- ==========================================
-- GAME TAB
-- ==========================================
local FarmSection = GameTab:AddSection("🏔️ Auto Farming CP")

-- Fungsi untuk mendapatkan Stage saat ini dari Leaderstats
local function GetCurrentStage()
    local ls = game.Players.LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        local st = ls:FindFirstChild("Stage") or ls:FindFirstChild("Checkpoint") or ls:FindFirstChild("Level")
        return st and st.Value or 0
    end
    return 0
end

-- Fungsi untuk mencari Part Checkpoint berdasarkan angka
local function FindNextCP(targetNum)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then
            -- Cari angka di nama objek
            local num = tonumber(obj.Name:match("%d+"))
            if num == targetNum then
                -- Validasi tambahan jika nama mengandung kata kunci umum
                local n = obj.Name:lower()
                if n:find("cp") or n:find("stage") or n:find("point") or obj:IsA("SpawnLocation") then
                    return obj
                end
            end
        end
    end
    return nil
end

FarmSection:AddToggle({
    Title = "Master Auto CP (Universal)",
    Description = "Bekerja berdasarkan ketinggian gunung (Semua Map)",
    Default = false,
    Callback = function(v)
        _G.AutoCP = v
        if v then
            task.spawn(function()
                Library:MakeNotify({ Title = "Scanning...", Content = "Menganalisa jalur gunung..." })
                local total = ScanUniversalCPs()
                Library:MakeNotify({ Title = "Success", Content = "Jalur ditemukan! Memulai pendakian..." })

                while _G.AutoCP do
                    local char = game.Players.LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if root then
                        -- Ambil progres saat ini dari Leaderstats (jika ada)
                        local currentIdx = 0
                        local ls = game.Players.LocalPlayer:FindFirstChild("leaderstats")
                        if ls then
                            local st = ls:FindFirstChild("Checkpoint") or ls:FindFirstChild("Stage") or ls:FindFirstChild("Level")
                            currentIdx = st and st.Value or 0
                        end

                        -- Target adalah checkpoint ke (currentIdx + 1) di daftar yang sudah diurutkan
                        local targetPart = MountainPaths[currentIdx + 1]
                        
                        -- Jika tidak ketemu berdasarkan index leaderstats, 
                        -- cari CP terdekat yang posisinya lebih tinggi dari kita
                        if not targetPart then
                            for _, part in pairs(MountainPaths) do
                                if part.Position.Y > root.Position.Y + 5 then
                                    targetPart = part
                                    break
                                end
                            end
                        end

                        if targetPart then
                            -- Teleportasi
                            root.CFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
                            
                            -- Paksa sistem game mendeteksi sentuhan
                            if firetouchinterest then
                                firetouchinterest(root, targetPart, 0)
                                task.wait(0.1)
                                firetouchinterest(root, targetPart, 1)
                            end
                            
                            -- Tunggu sebentar agar server memproses
                            task.wait(_G.CPDelay or 2.0)
                        else
                            Library:MakeNotify({ Title = "Selesai", Content = "Sudah mencapai puncak atau jalur habis." })
                            _G.AutoCP = false
                            break
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

FarmSection:AddInput({ Title = "Delay Pendakian", Default = 2.0, Callback = function(v) _G.CPDelay = tonumber(v) or 2.0 end })

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
            Library:MakeNotify({ Title = "Teleport", Content = "Berhasil ke Puncak Gunung!" })
        end
    end
})

local VisualSection = GameTab:AddSection("🎭 Visual ESP & Tracking")

VisualSection:AddToggle({ Title = "ESP Box (2D)", Default = false, Callback = function(v) _G.BoxESP = v end })
VisualSection:AddToggle({ Title = "ESP Tracers (Line)", Default = false, Callback = function(v) _G.LineESP = v end })

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

-- RenderStepped untuk Health Bar agar Update secara Real-time
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
                        bgui.Size = UDim2.new(3, 0, 0.4, 0) -- Ukuran disesuaikan
                        bgui.StudsOffset = Vector3.new(0, 2, 0)
                        bgui.AlwaysOnTop = true
                        
                        local back = Instance.new("Frame", bgui)
                        back.Name = "Background"
                        back.Size = UDim2.new(1, 0, 1, 0)
                        back.BackgroundColor3 = Color3.new(0, 0, 0)
                        back.BorderSizePixel = 0
                        
                        local bar = Instance.new("Frame", back)
                        back.Name = "Frame" -- Sesuai dengan pengecekan di bawah
                        bar.Name = "Bar"
                        bar.BorderSizePixel = 0
                        bar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                        bar.BackgroundColor3 = Color3.new(0, 1, 0)
                    else
                        local frame = gui:FindFirstChild("Frame")
                        local bar = frame and frame:FindFirstChild("Bar")
                        if bar then
                            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                            bar.Size = UDim2.new(healthPercent, 0, 1, 0)
                            -- Warna transisi Hijau ke Merah
                            bar.BackgroundColor3 = Color3.fromHSV(healthPercent * 0.3, 1, 1) 
                        end
                    end
                elseif gui then
                    gui:Destroy() -- Hapus jika mati
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
            -- Buat ESP untuk yang sudah ada di server
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then CreateESPForPlayer(p) end
            end
            
            -- Koneksi jika ada pemain baru masuk
            if not _G.PlayerAddedConn then
                _G.PlayerAddedConn = Players.PlayerAdded:Connect(function(p)
                    p.CharacterAdded:Connect(function()
                        if _G.ESP then task.wait(0.5) CreateESPForPlayer(p) end
                    end)
                end)
            end
            
            Library:MakeNotify({ Title = "Enabled", Content = "ESP Highlight Aktif!" })
        else
            -- Cleanup
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

VisualSection:AddToggle({
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

VisualSection:AddToggle({
    Title = "Fullbright",
    Default = false,
    Callback = function(v)
        if v then
            _G.OldBright = Lighting.Brightness; _G.OldTime = Lighting.ClockTime
            _G.OldFog = Lighting.FogEnd; _G.OldShadows = Lighting.GlobalShadows
            Lighting.Brightness = 2; Lighting.ClockTime = 14
            Lighting.FogEnd = 100000; Lighting.GlobalShadows = false
        else
            Lighting.Brightness = _G.OldBright or 1; Lighting.ClockTime = _G.OldTime or 14
            Lighting.FogEnd = _G.OldFog or 100000; Lighting.GlobalShadows = _G.OldShadows or true
        end
    end
})

local UtilSection = GameTab:AddSection("🎮 Gameplay Utilities")

UtilSection:AddToggle({
    Title = "Auto Skill Check (Mobile)",
    Default = false,
    Callback = function(v)
        _G.AutoSkillMobile = v
        if v then
            task.spawn(function()
                while _G.AutoSkillMobile do
                    task.wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Space, false, game)
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
                        -- Menggunakan fungsi deteksi yang lebih kuat
                        if p ~= LocalPlayer and (CheckIfKiller(p)) then
                            local char = p.Character
                            local myChar = LocalPlayer.Character
                            if char and myChar and char:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("HumanoidRootPart") then
                                local dist = (myChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                                
                                -- Beri peringatan jika jarak < 50 dan cooldown 3 detik (agar tidak spam)
                                if dist < 50 and tick() - lastWarn > 3 then
                                    Library:MakeNotify({ 
                                        Title = "⚠️ PERINGATAN!", 
                                        Content = "Killer: " .. p.Name .. " Mendekat! (" .. math.floor(dist) .. " studs)",
                                        Time = 3
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
                    -- Gunakan VirtualInputManager untuk mensimulasikan pencetan keyboard
                    VIM:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.A, false, game)
                    
                    VIM:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.D, false, game)
                    
                    task.wait(0.05) -- Beri sedikit jeda agar tidak lag
                end
            end)
            Library:MakeNotify({ Title = "Enabled", Content = "Auto Wiggle Aktif" })
        else
            Library:MakeNotify({ Title = "Disabled", Content = "Auto Wiggle Mati" })
        end
    end
})



-- ================= SECTION: FIND OBJECTS =================
local FindSection = GameTab:AddSection("🎯 Find Objects & Debug")

FindSection:AddButton({
    Title = "Find Generators",
    Callback = function()
        ClearManualHighlights()
        -- Pastikan fungsi IsGenerator dan FindAllGenerators sudah ada di script utama Anda
        local generators = FindAllGenerators() 
        local count = 0
        
        for _, gen in pairs(generators) do
            local hl = Instance.new("Highlight")
            -- Cek jika generator sudah selesai (Gunakan fungsi check Anda)
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
        -- Menghapus sisa highlight liar lainnya
        for _, o in pairs(workspace:GetDescendants()) do
            if o:IsA("Highlight") and (o.Name == "GenESP_Highlight" or o.Parent:IsA("Model")) then
                o:Destroy()
            end
        end
        Library:MakeNotify({ Title = "Cleared", Content = "Semua sinar telah dihapus!" })
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

-- =================================================================
-- 🛡️ SELF-PROTECTION & SECURITY SECTION (KINI BERHASIL TAMPIL)
-- =================================================================
local ChatSection = ServerTab:AddSection("🌐 Chat Otomatis")

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
                    -- Mendukung sistem chat lama dan baru (TextChatService)
                    pcall(function() 
                        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All") 
                    end)
                    pcall(function() 
                        game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg) 
                    end)
                    task.wait(5) -- Delay agar tidak terkena mute
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

local ProtectSection = ServerTab:AddSection("🛡️ Self-Protection & Security")

ProtectSection:AddToggle({
    Title = "Anti-Kick Protection",
    Description = "Mendeteksi upaya kick (Bukan bypass total)",
    Default = false,
    Callback = function(v)
        _G.AntiKick = v
        -- Catatan: Bypass kick total memerlukan hookmetamethod yang sering terdeteksi.
        -- Ini hanya memberikan notifikasi keamanan.
    end
})

-- LOGIC: Admin Join Detector
ProtectSection:AddToggle({
    Title = "Admin Join Detector",
    Default = false,
    Callback = function(v)
        _G.AdminDetect = v
    end
})

-- LOGIC: Admin Detector
Players.PlayerAdded:Connect(function(player)
    if _G.AdminDetect then
        -- Cek rank (0 adalah ID Group, ganti jika perlu)
        if player:GetRankInGroup(0) > 10 or player.AccountAge < 2 then
            Library:MakeNotify({ 
                Title = "⚠️ WARNING", 
                Content = "Admin/Pemain Baru Masuk: " .. player.Name, 
                Time = 10 
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

-- ================= SECTION: ACTIONS =================
local ActionsSection = ServerTab:AddSection("🚪 Actions")

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

-- ================= SECTION: SPECTATE =================
local SpectateSection = ServerTab:AddSection("👁️ Spectate")

local SpectateDropdown = SpectateSection:AddDropdown({ 
    Title = "Select Player", 
    Default = "", 
    Options = {}, 
    Callback = function(v) SpecTarget = v end 
})

SpectateSection:AddButton({
    Title = "Refresh Daftar Pemain",
    Callback = function()
        local list = {}
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LocalPlayer then table.insert(list, p.Name) end 
        end
        SafeRefreshDropdown(SpectateDropdown, list)
    end
})

SpectateSection:AddButton({
    Title = "Mulai Spectate",
    Callback = function()
        local t = Players:FindFirstChild(SpecTarget)
        if t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
            Workspace.CurrentCamera.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid")
            Library:MakeNotify({ Title = "Spectating", Content = "Menonton: " .. SpecTarget })
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
-- 5. SETTINGS TAB (FIXED RENDERING & CRASH BYPASS)
-- ==========================================
local pengaturanSection = SettingsTab:AddSection("🛡️ Protection")

pengaturanSection:AddToggle({
    Title = "Streamer Mode",
    Description = "Menyamarkan tampilan menu",
    Default = false,
    Callback = function(v)
        -- RedzLib biasanya tidak mendukung ganti Title secara instan, 
        -- tapi kita bisa memberikan notifikasi sebagai tanda aktif.
        if v then
            Library:MakeNotify({ Title = "Streamer Mode", Content = "Mode Penyamaran Aktif", Time = 3 })
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
            Library:MakeNotify({ Title = "Success", Content = "Display Name diubah (Hanya kamu yang lihat)", Time = 3 })
        end
    end
})

-- ================= SECTION: THEME =================
local ThemeSection = SettingsTab:AddSection("🎨 Appearance")

-- Catatan: Ganti tema secara dinamis jarang didukung RedzLib V5 secara bawaan.
-- Fungsi ini hanya contoh jika library-mu mendukung SetTheme.
ThemeSection:AddDropdown({ 
    Title = "Select Theme", 
    Options = {"Dark", "Light", "Midnight", "Rose", "Emerald"}, 
    Default = "Midnight", 
    Callback = function(v) 
        pcall(function() Window:SetTheme(v) end)
    end 
})

-- ================= SECTION: KEYBIND =================
local keybindSection = SettingsTab:AddSection("⌨️ Keybind")

-- Format standar RedzLib V5 untuk Keybind
keybindSection:AddKeybind({
    Title = "Toggle UI Menu",
    Default = Enum.KeyCode.RightControl, -- Ganti sesuai keinginan
    Callback = function()
        -- Logika menyembunyikan/memunculkan UI
        local gui = game.CoreGui:FindFirstChild("MDW HUB") or game.Players.LocalPlayer.PlayerGui:FindFirstChild("MDW HUB")
        if gui then
            gui.Enabled = not gui.Enabled
        end
    end
})

-- ================= SECTION: EXIT =================
local ExitSection = SettingsTab:AddSection("❌ Exit")

ExitSection:AddButton({
    Title = "Destroy UI",
    Callback = function()
        _G.Spam = false
        _G.TapTP = false
        _G.AdminDetect = false
        Library:MakeNotify({ Title = "MDW HUB", Content = "Shutdown...", Time = 2 })
        task.wait(1)
        Window:Destroy()
    end
})
-- Interaction Tap Teleport


-- ==========================================
-- PERSISTENT REPETITIVE LOOPS
-- ==========================================
-- [[ NOCLIP OPTIMIZED ]]
RunService.Stepped:Connect(function()
    if _G.NC and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetChildren()) do 
            if p:IsA("BasePart") then 
                p.CanCollide = false 
            end 
            -- Juga cek bagian di dalam Model (seperti kaki/tangan)
            for _, child in pairs(p:GetDescendants()) do
                if child:IsA("BasePart") then child.CanCollide = false end
            end
        end
    end
end)

-- [[ INF JUMP - SUDAH OKE ]]
UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- [[ TAP TO TELEPORT (PC & MOBILE SUPPORT) ]]
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end -- Jangan aktif jika sedang mengetik di chat
    
    if _G.TapTP and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local mouse = LocalPlayer:GetMouse()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Teleport ke posisi klik
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
        end
    end
end)

-- [[ 2D ESP DRAWING LOOP OPTIMIZED ]]
RunService.RenderStepped:Connect(function()
    if not (_G.BoxESP or _G.LineESP) then
        for _, obj in pairs(ESP_Objects) do 
            obj.Box.Visible = false 
            obj.Line.Visible = false 
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                -- Inisialisasi Drawing jika belum ada
                if not ESP_Objects[player] then
                    ESP_Objects[player] = { 
                        Box = Drawing.new("Square"), 
                        Line = Drawing.new("Line") 
                    }
                end
                
                local obj = ESP_Objects[player]
                local color = GetESPColor(player)
                
                if _G.BoxESP then
                    -- Ukuran kotak berdasarkan jarak (Z)
                    local sizeX = math.clamp(2000 / pos.Z, 10, 500)
                    local sizeY = math.clamp(3000 / pos.Z, 10, 700)
                    
                    obj.Box.Visible = true
                    obj.Box.Color = color
                    obj.Box.Size = Vector2.new(sizeX, sizeY)
                    obj.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                    obj.Box.Thickness = 1
                    obj.Box.Filled = false -- Pastikan tidak menutupi layar
                    obj.Box.Transparency = 1
                else
                    obj.Box.Visible = false
                end
                
                if _G.LineESP then
                    obj.Line.Visible = true
                    obj.Line.Color = color
                    obj.Line.From = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y)
                    obj.Line.To = Vector2.new(pos.X, pos.Y)
                    obj.Line.Thickness = 1
                    obj.Line.Transparency = 1
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
game.Players.PlayerAdded:Connect(UpdateDropdown)
game.Players.PlayerRemoving:Connect(UpdateDropdown)
Players.PlayerRemoving:Connect(ClearESP)
-- Initialize Library
Library:Initialize()
Library:MakeNotify({ Title = "FCAL HUB", Description = "Script Loaded Successfully!", Delay = 5 })