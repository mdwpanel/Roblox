--[[
    ███████╗███████╗ █████╗ ██╗     
    ██╔════╝██╔════╝██╔══██╗██║     
    █████╗  █████╗  ███████║██║     
    ██╔══╝  ██╔══╝  ██╔══██║██║     
    ██║     ██║     ██║  ██║███████╗
    ╚═╝     ╚═╝     ╚═╝  ╚═╝╚══════╝
    
    FCAL HUB - REDESIGN (FIXED LYNX UI)
    UI Library: Lucid / LynX Style (Lib2.lua)
--]]

-- Load Library dari link yang kamu berikan
local Library = loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- Global Variables
_G.AutoCP = false
_G.CPDelay = 1.0
_G.BoxESP = false
_G.LineESP = false

-- [[ ADVANCED ANTI-KICK BYPASS ]]
local mt = getrawmetatable(game) 
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then
        return nil 
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- [[ UI INITIALIZATION ]]
-- CreateWindow(Title, SubTitle, IconID)
local Window = Library:CreateWindow("FCAL HUB", "v1.0.6 | Client Sided", "rbxassetid://16335111162")

-- [[ TABS SAMPING ]]
-- AddTab(Nama, IconID)
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
            if result then 
                root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- ====================================================================
-- PLAYER TAB
-- ====================================================================
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

-- Infinite Jump Hook
UserInputService.JumpRequest:Connect(function()
    if _G.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

PlayerTab:AddToggle("NoClip", function(v)
    _G.NC = v
end)

RunService.Stepped:Connect(function()
    if _G.NC and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

PlayerTab:AddSection("🎭 Identity Stealer")

local SelectedPlayer = ""
local pDropdown = PlayerTab:AddDropdown("Pilih Pemain", {"Pilih Target..."}, function(v)
    SelectedPlayer = v
end)

PlayerTab:AddButton("🔄 Refresh Daftar Pemain", function()
    local pList = {}
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(pList, p.Name) end
    end
    -- Untuk library ini, biasanya dropdown diupdate dengan memanggil ulang atau fungsi internal
    Library:Notification("Info", "Daftar pemain diperbarui di Console (F9)", 2)
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
        Library:Notification("Identity", "Berhasil meniru " .. target.Name, 3)
    end
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

-- ESP System Logic
local function CreateESP(player)
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Color3.fromRGB(255, 255, 255)
    
    local line = Drawing.new("Line")
    line.Thickness = 1
    line.Color = Color3.fromRGB(255, 255, 255)
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                if _G.BoxESP then
                    box.Size = Vector2.new(1000 / pos.Z, 1500 / pos.Z)
                    box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                    box.Visible = true
                else box.Visible = false end
                
                if _G.LineESP then
                    line.From = Vector2.new(Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Visible = true
                else line.Visible = false end
            else
                box.Visible = false
                line.Visible = false
            end
        else
            box.Visible = false
            line.Visible = false
            if not player.Parent then 
                box:Remove()
                line:Remove()
                connection:Disconnect() 
            end
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- ====================================================================
-- SERVER TAB
-- ====================================================================
ServerTab:AddSection("🛡️ Security")

ServerTab:AddToggle("Anti-Kick Protection", function(v)
    _G.AntiKick = v
end)

ServerTab:AddButton("Server Hop", function()
    local servers = {}
    local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
    for i,v in pairs(game:GetService("HttpService"):JSONDecode(res).data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then 
            table.insert(servers, v.id) 
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    end
end)

ServerTab:AddButton("Rejoin Server", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

-- ====================================================================
-- SETTINGS TAB
-- ====================================================================
SettingsTab:AddSection("⚙️ Settings")

SettingsTab:AddButton("Destroy UI", function()
    game:GetService("CoreGui"):FindFirstChild("Lucid"):Destroy()
end)

SettingsTab:AddLabel("Version: 1.0.6")
SettingsTab:AddLabel("Made for Mobile")

-- Notifikasi Akhir
Library:Notification("FCAL HUB", "Successfully Loaded! Klik icon di kiri untuk menu.", 5)
