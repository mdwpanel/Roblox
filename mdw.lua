--[[
    ███████╗███████╗ █████╗ ██╗     
    ██╔════╝██╔════╝██╔══██╗██║     
    █████╗  █████╗  ███████║██║     
    ██╔══╝  ██╔══╝  ██╔══██║██║     
    ██║     ██║     ██║  ██║███████╗
    ╚═╝     ╚═╝     ╚═╝  ╚═╝╚══════╝
    FCAL HUB - Client Sided | Version: 1.0.6
--]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local ESP_Objects = {}
_G.AutoCP = false
_G.CPDelay = 1.0

-- Config
local Config = {
    WalkSpeedDefault = 16,
    JumpPowerDefault = 50,
    GravityDefault = 196,
    Theme = "Midnight",
    FlySpeed = 100,
}

-- Load Library
local Modal = loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()

-- ADVANCED ANTI-KICK BYPASS
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then return nil end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Functions & Helpers
local function Notify(title, desc, typ)
    -- Kadang library menggunakan Window:Notify atau Modal:Notify
    pcall(function() Modal:Notify({Title = title, Description = desc, Type = typ or "Info", Duration = 3}) end)
end

local function GetHumanoid()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- Identity Stealer Logic
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
    Notify("Success", "Meniru: " .. target.DisplayName, "Success")
end

-- Create Window
local Window = Modal:CreateWindow({
    Title = "FCAL HUB",
    SubTitle = "v1.0.6 | Client Sided",
    Size = UDim2.fromOffset(500, 420),
    Theme = Config.Theme,
    Icon = "rbxassetid://68073547",
})

-- TABS
local MainTab = Window:AddTab("Main", "rbxassetid://4483345998")
local PlayerTab = Window:AddTab("Player", "rbxassetid://4483345998")
local GameTab = Window:AddTab("Game", "rbxassetid://4483345998")
local ServerTab = Window:AddTab("Server", "rbxassetid://4483345998")

-- MAIN TAB ELEMENTS
MainTab:AddLabel("🛠️ Quick Actions")

MainTab:AddButton({
    Title = "Get Gravity Gun",
    Description = "Tool penarik objek",
    Callback = function()
        local tool = Instance.new("Tool")
        tool.RequiresHandle = false
        tool.Name = "🧲 Gravity Gun"
        tool.Parent = LocalPlayer.Backpack
        Notify("Tool Added", "Gravity Gun ada di tas!", "Success")
    end
})

MainTab:AddButton({
    Title = "Reset Character",
    Callback = function() LocalPlayer.Character:BreakJoints() end
})

MainTab:AddToggle({
    Title = "Tap to Teleport",
    Description = "Ketuk layar untuk pindah posisi",
    Default = false,
    Callback = function(v) _G.TapTP = v end
})

-- PLAYER TAB ELEMENTS
PlayerTab:AddLabel("🏃 Movement")

PlayerTab:AddSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 300,
    Default = 16,
    Callback = function(v) 
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = v end 
    end
})

PlayerTab:AddSlider({
    Title = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(v) 
        local hum = GetHumanoid()
        if hum then hum.JumpPower = v end 
    end
})

PlayerTab:AddToggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v)
        _G.InfJump = v
        UserInputService.JumpRequest:Connect(function()
            if _G.InfJump then GetHumanoid():ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
})

PlayerTab:AddToggle({
    Title = "Noclip",
    Default = false,
    Callback = function(v)
        _G.NC = v
        RunService.Stepped:Connect(function()
            if _G.NC and LocalPlayer.Character then
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end
})

-- GAME TAB ELEMENTS (Auto CP & Visuals)
GameTab:AddLabel("🏔️ Auto Farm / Obby")

GameTab:AddToggle({
    Title = "Auto All CP (Master)",
    Description = "Teleport otomatis ke checkpoint obby",
    Default = false,
    Callback = function(v)
        _G.AutoCP = v
        task.spawn(function()
            local lastNum = 0
            while _G.AutoCP do
                task.wait(_G.CPDelay)
                local root = GetRootPart()
                local found = false
                for _, obj in pairs(workspace:GetDescendants()) do
                    local num = tonumber(obj.Name:match("%d+"))
                    if num and num > lastNum and (obj.Name:lower():find("cp") or obj:IsA("SpawnLocation")) then
                        root.CFrame = obj.CFrame * CFrame.new(0, 3, 0)
                        lastNum = num
                        found = true
                        break
                    end
                end
                if not found then task.wait(1) end
            end
        end)
    end
})

GameTab:AddLabel("👁️ Visuals")

GameTab:AddToggle({
    Title = "Fullbright",
    Callback = function(v)
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end
})

-- SERVER TAB ELEMENTS
ServerTab:AddButton({
    Title = "Server Hop",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

ServerTab:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

-- Touch TP Handler (Mobile)
UserInputService.TouchTapInWorld:Connect(function(position, processed)
    if _G.TapTP and not processed then
        local root = GetRootPart()
        local camera = Workspace.CurrentCamera
        local ray = camera:ViewportPointToRay(position.X, position.Y)
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
        if result and root then
            root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        end
    end
end)

-- Initialize
Notify("FCAL HUB", "Loaded v1.0.6", "Success")
