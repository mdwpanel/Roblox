--[[
    ███████╗███████╗ █████╗ ██╗     
    ██╔════╝██╔════╝██╔══██╗██║     
    █████╗  █████╗  ███████║██║     
    ██╔══╝  ██╔══╝  ██╔══██║██║     
    ██║     ██║     ██║  ██║███████╗
    ╚═╝     ╚═╝     ╚═╝  ╚═╝╚══════╝
    
    FCAL HUB - REDESIGN (FIXED LYNX UI)
--]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/4LynxX/Libb/refs/heads/main/Lib2.lua"))()

-- Variabel & Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

_G.AutoCP = false
_G.CPDelay = 1.0

-- Inisialisasi Window Utama (LynX Style)
-- Argument: Title, SubTitle, IconID
local Window = Library:CreateWindow("FCAL HUB", "v1.0.6 | Client Sided", "rbxassetid://16335111162")

-- [[ TAB SAMPING ]]
-- Argument: Nama Tab, IconID
local MainTab = Window:AddTab("Main", "rbxassetid://10734950309")
local PlayerTab = Window:AddTab("Player", "rbxassetid://10747373176")
local GameTab = Window:AddTab("Game", "rbxassetid://10723343321")
local ServerTab = Window:AddTab("Server", "rbxassetid://10734981358")
local SettingsTab = Window:AddTab("Settings", "rbxassetid://10734950020")

-- ====================================================================
-- MAIN TAB
-- ====================================================================
MainTab:AddSection("🛠️ Quick Actions")

MainTab:AddButton("Reset Character", function()
    LocalPlayer:LoadCharacter()
end)

MainTab:AddButton("Refresh Movement", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
    Workspace.Gravity = 196
    Library:Notification("FCAL HUB", "Movement & Gravity Resetted!", 3)
end)

MainTab:AddSection("🎯 Teleport")

MainTab:AddToggle("Tap to Teleport", function(v)
    _G.TapTP = v
end)

-- Handle Tap TP Logic
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

-- ====================================================================
-- PLAYER TAB
-- ====================================================================
PlayerTab:AddSection("🎭 Identity Stealer")

local SelectedPlayer = ""
PlayerTab:AddDropdown("Pilih Pemain", {"Select Player"}, function(v)
    SelectedPlayer = v
end)

PlayerTab:AddButton("🔄 Refresh Daftar Pemain", function()
    local pList = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pList, p.Name) end
    end
    -- Library ini biasanya update dropdown via pemanggilan ulang atau variabel
end)

PlayerTab:AddButton("🎭 Terapkan Identity", function()
    local target = Players:FindFirstChild(SelectedPlayer)
    if target and target.Character then
        local myChar = LocalPlayer.Character
        for _, v in pairs(myChar:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") then v:Destroy() end
        end
        pcall(function()
            local desc = Players:GetHumanoidDescriptionFromUserId(target.UserId)
            myChar:FindFirstChildOfClass("Humanoid"):ApplyDescription(desc)
        end)
    end
end)

PlayerTab:AddSection("🏃 Movement")

PlayerTab:AddSlider("WalkSpeed", 16, 250, 16, function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

PlayerTab:AddSlider("Jump Power", 50, 350, 50, function(v)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end)

PlayerTab:AddToggle("Infinite Jump", function(v)
    _G.InfJump = v
end)

PlayerTab:AddToggle("NoClip", function(v)
    _G.NC = v
end)

-- ====================================================================
-- GAME TAB
-- ====================================================================
GameTab:AddSection("🏔️ Auto Farming CP")

GameTab:AddToggle("Start Auto All CP (Master Fix)", function(v)
    _G.AutoCP = v
    if v then
        task.spawn(function()
            local lastCP = 0
            while _G.AutoCP do
                task.wait(0.1)
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                
                local allCPs = {}
                for _, obj in pairs(Workspace:GetDescendants()) do
                    local num = tonumber(obj.Name:match("%d+"))
                    if num and num > lastCP and (obj.Name:lower():find("cp") or obj:IsA("SpawnLocation")) then
                        table.insert(allCPs, {Part = obj, Num = num})
                    end
                end
                table.sort(allCPs, function(a,b) return a.Num < b.Num end)
                
                if #allCPs > 0 then
                    root.CFrame = allCPs[1].Part.CFrame * CFrame.new(0,3,0)
                    lastCP = allCPs[1].Num
                    task.wait(_G.CPDelay)
                end
            end
        end)
    end
end)

GameTab:AddSection("🎭 Visual ESP")

GameTab:AddToggle("ESP Box (2D)", function(v) _G.BoxESP = v end)
GameTab:AddToggle("ESP Tracers", function(v) _G.LineESP = v end)

-- ====================================================================
-- SERVER TAB
-- ====================================================================
ServerTab:AddSection("🛡️ Protection")

ServerTab:AddToggle("Anti-Kick Protection", function(v)
    _G.AntiKick = v
end)

ServerTab:AddButton("Server Hop", function()
    local servers = {}
    local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
    for i,v in pairs(game:GetService("HttpService"):JSONDecode(res).data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then table.insert(servers, v.id) end
    end
    TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
end)

-- ====================================================================
-- SETTINGS TAB
-- ====================================================================
SettingsTab:AddSection("⚙️ Settings")

SettingsTab:AddToggle("Streamer Mode", function(v)
    -- Logic ganti nama hub
end)

SettingsTab:AddButton("Destroy UI", function()
    -- Library ini biasanya punya fungsi Destroy sendiri
    game:GetService("CoreGui"):FindFirstChild("Lucid"):Destroy()
end)

-- Initial Notifications
Library:Notification("FCAL HUB", "Successfully Loaded! Tampilan diperbaiki.", 5)
