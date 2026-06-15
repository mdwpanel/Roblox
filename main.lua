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

-- Load Library
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

-- Variables & Config
local LocalPlayer = Players.LocalPlayer
local ESP_Objects = {}
local ESPHighlights = {}
local ESPLabels = {}
local GenHighlights = {}
local ESPConnections = {}

_G.AutoCP = false
_G.CPDelay = 1.0
_G.InfJump = false
_G.NC = false
_G.TapTP = false
_G.BoxESP = false
_G.LineESP = false
_G.HealthESP = false
_G.Fly = false

local Config = {
    WalkSpeedDefault = 16,
    JumpPowerDefault = 50,
    GravityDefault = 196,
    FlySpeed = 100,
}

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

-- [[ HELPER FUNCTIONS ]]
local function Notify(title, desc, typ)
    Library:MakeNotify({Title = title, Description = desc, Delay = 3})
end

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetAllPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    return names
end

local function GetPlayerRole(player)
    -- Logic role detection (Survivor/Killer)
    if player:GetAttribute("Role") == "Killer" or player.TeamColor == BrickColor.new("Really red") then
        return "Killer"
    end
    return "Survivor"
end

local function GetESPColor(player)
    local role = GetPlayerRole(player)
    if role == "Killer" then return Color3.fromRGB(255, 0, 0) end
    if role == "Survivor" then return Color3.fromRGB(0, 255, 0) end
    return Color3.fromRGB(255, 255, 255)
end

-- [[ IDENTITY STEALER LOGIC ]]
local function ExecuteIdentityCopy(target)
    local myChar = LocalPlayer.Character
    local myHum = GetHumanoid()
    if not myChar or not target.Character then return end

    for _, v in pairs(myChar:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") then v:Destroy() end
    end

    pcall(function()
        local desc = Players:GetHumanoidDescriptionFromUserId(target.UserId)
        myHum:ApplyDescription(desc)
    end)
    
    myHum.DisplayName = target.DisplayName
    Notify("Success", "Berhasil meniru: " .. target.DisplayName)
end

-- [[ WINDOW CREATION ]]
local Window = Library:Window({
    Title = "FCAL HUB",
    Footer = "v1.0.6 | Client Sided"
})

-- TABS
local MainTab = Window:AddTab({ Name = "Main", Icon = "home" })
local PlayerTab = Window:AddTab({ Name = "Player", Icon = "user" })
local GameTab = Window:AddTab({ Name = "Game", Icon = "gamepad" })
local ServerTab = Window:AddTab({ Name = "Server", Icon = "web" })
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "settings" })

-- ==========================================
-- MAIN TAB
-- ==========================================
local QuickActions = MainTab:AddSection("🛠️ Quick Actions")

QuickActions:AddButton({
    Title = "Reset Character",
    Callback = function() LocalPlayer:LoadCharacter() end
})

QuickActions:AddButton({
    Title = "Refresh Movement",
    Callback = function()
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        Workspace.Gravity = 196
        Notify("Reset", "Movement kembali normal")
    end
})

local TeleportSection = MainTab:AddSection("🎯 Teleportation")

TeleportSection:AddToggle("TapTP", {
    Title = "Tap to Teleport",
    Default = false,
    Callback = function(v) _G.TapTP = v end
})

local SelectedTPTarget = ""
local PlayerDropdown = TeleportSection:AddDropdown("TPPlayer", {
    Title = "Pilih Pemain",
    Values = GetAllPlayerNames(),
    Callback = function(v) SelectedTPTarget = v end
})

TeleportSection:AddButton({
    Title = "Teleport Sekarang",
    Callback = function()
        local target = Players:FindFirstChild(SelectedTPTarget)
        if target and target.Character then
            local root = GetRootPart()
            root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end
})

-- ==========================================
-- PLAYER TAB
-- ==========================================
local IdentitySection = PlayerTab:AddSection("👤 Identity Stealer")

local SelectedAutoPlayer = ""
local IdentityDropdown = IdentitySection:AddDropdown("IDPemain", {
    Title = "Pilih Target",
    Values = GetAllPlayerNames(),
    Callback = function(v) SelectedAutoPlayer = v end
})

IdentitySection:AddButton({
    Title = "Terapkan Identitas",
    Callback = function()
        local target = Players:FindFirstChild(SelectedAutoPlayer)
        if target then ExecuteIdentityCopy(target) end
    end
})

IdentitySection:AddButton({
    Title = "Reset Identitas",
    Callback = function()
        local hum = GetHumanoid()
        local desc = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
        hum:ApplyDescription(desc)
    end
})

local MoveSection = PlayerTab:AddSection("🏃 Movement")

MoveSection:AddSlider("WS", { Title = "Walk Speed", Default = 16, Min = 16, Max = 250, Callback = function(v)
    local hum = GetHumanoid()
    if hum then hum.WalkSpeed = v end
end})

MoveSection:AddSlider("JP", { Title = "Jump Power", Default = 50, Min = 50, Max = 500, Callback = function(v)
    local hum = GetHumanoid()
    if hum then hum.JumpPower = v end
end})

MoveSection:AddToggle("InfJump", { Title = "Infinite Jump", Callback = function(v) _G.InfJump = v end })
MoveSection:AddToggle("Noclip", { Title = "NoClip", Callback = function(v) _G.NC = v end })

local FlySection = PlayerTab:AddSection("✈️ Fly Settings")

FlySection:AddSlider("FlySpeed", { Title = "Fly Speed", Default = 100, Min = 10, Max = 500, Callback = function(v) Config.FlySpeed = v end })
FlySection:AddToggle("Fly", { Title = "Enable Fly", Callback = function(v)
    _G.Fly = v
    if v then
        local root = GetRootPart()
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "FlyVel"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        local bg = Instance.new("BodyGyro", root)
        bg.Name = "FlyGyro"; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)

        task.spawn(function()
            while _G.Fly do
                local moveDir = GetHumanoid().MoveDirection * Config.FlySpeed
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, Config.FlySpeed, 0)
                elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir + Vector3.new(0, -Config.FlySpeed, 0) end
                bv.Velocity = moveDir
                bg.CFrame = Workspace.CurrentCamera.CFrame
                task.wait()
            end
            bv:Destroy(); bg:Destroy()
        end)
    end
end})

-- ==========================================
-- GAME TAB
-- ==========================================
local VisualSection = GameTab:AddSection("🎭 Visuals (ESP)")

VisualSection:AddToggle("BoxESP", { Title = "Box ESP", Callback = function(v) _G.BoxESP = v end })
VisualSection:AddToggle("LineESP", { Title = "Tracer Line", Callback = function(v) _G.LineESP = v end })
VisualSection:AddToggle("HealthESP", { Title = "Health Bar", Callback = function(v) _G.HealthESP = v end })

local FarmSection = GameTab:AddSection("🏔️ Auto Farm CP")

FarmSection:AddInput("CPDelay", { Title = "Delay CP (Detik)", Default = "1.0", Callback = function(v) _G.CPDelay = tonumber(v) or 1.0 end })

FarmSection:AddToggle("AutoCP", { Title = "Start Auto CP", Callback = function(v)
    _G.AutoCP = v
    if v then
        task.spawn(function()
            local lastNum = 0
            while _G.AutoCP do
                local allCPs = {}
                for _, obj in pairs(Workspace:GetDescendants()) do
                    local num = tonumber(obj.Name:match("%d+"))
                    if num and num > lastNum and (obj.Name:lower():find("cp") or obj:IsA("SpawnLocation")) then
                        table.insert(allCPs, {Part = obj, Num = num})
                    end
                end
                table.sort(allCPs, function(a, b) return a.Num < b.Num end)
                
                if #allCPs > 0 then
                    local target = allCPs[1]
                    GetRootPart().CFrame = target.Part.CFrame * CFrame.new(0, 3, 0)
                    task.wait(_G.CPDelay)
                    lastNum = target.Num
                end
                task.wait(0.5)
            end
        end)
    end
end})

-- ==========================================
-- SERVER TAB
-- ==========================================
local Protection = ServerTab:AddSection("🛡️ Protection")

Protection:AddToggle("AntiKick", { Title = "Anti-Kick Bypass", Callback = function(v) _G.AntiKick = v end })
Protection:AddButton({ Title = "Server Hop", Callback = function()
    local servers = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
    local decoded = game:GetService("HttpService"):JSONDecode(servers)
    for _, s in pairs(decoded.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
            break
        end
    end
end})

-- ==========================================
-- SETTINGS TAB
-- ==========================================
local Settings = SettingsTab:AddSection("⚙️ UI Settings")

Settings:AddDropdown("Theme", {
    Title = "Ganti Tema",
    Values = {"Dark", "Light", "Midnight", "Rose", "Emerald"},
    Callback = function(v) Window:SetTheme(v) end
})

Settings:AddButton({
    Title = "Destroy UI",
    Callback = function() 
        _G.AutoCP = false; _G.ESP = false; _G.Fly = false
        Window:Destroy() 
    end
})

-- [[ MAIN LOOPS ]]

-- Noclip & InfJump Loop
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

-- Drawing ESP Loop
RunService.RenderStepped:Connect(function()
    if _G.BoxESP or _G.LineESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(root.Position)
                
                if not ESP_Objects[player] then
                    ESP_Objects[player] = {
                        Box = Drawing.new("Square"),
                        Line = Drawing.new("Line")
                    }
                end
                
                local obj = ESP_Objects[player]
                local color = GetESPColor(player)

                if onScreen then
                    if _G.BoxESP then
                        local sizeX = 2000 / pos.Z
                        local sizeY = 3000 / pos.Z
                        obj.Box.Visible = true
                        obj.Box.Color = color
                        obj.Box.Size = Vector2.new(sizeX, sizeY)
                        obj.Box.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                    else obj.Box.Visible = false end

                    if _G.LineESP then
                        obj.Line.Visible = true
                        obj.Line.Color = color
                        obj.Line.From = Vector2.new(Workspace.CurrentCamera.ViewportSize.X/2, Workspace.CurrentCamera.ViewportSize.Y)
                        obj.Line.To = Vector2.new(pos.X, pos.Y)
                    else obj.Line.Visible = false end
                else
                    obj.Box.Visible = false
                    obj.Line.Visible = false
                end
            end
        end
    end
end)

-- Tap TP Handler
UserInputService.TouchTapInWorld:Connect(function(position, processed)
    if _G.TapTP and not processed then
        local ray = Workspace.CurrentCamera:ViewportPointToRay(position.X, position.Y)
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
        if result then
            GetRootPart().CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        end
    end
end)

-- Initialize
Library:Initialize()
Notify("FCAL HUB", "Script Loaded Successfully!")
