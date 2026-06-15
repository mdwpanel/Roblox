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

-- Load Library dari kode yang kamu berikan
-- (Pastikan script library-nya sudah ter-load sebelum menjalankan ini)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/4LynxX/Libb/refs/heads/main/Lib2.lua"))()

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

-- Global Variables
_G.AutoCP = false
_G.CPDelay = 1.0
_G.InfJump = false
_G.NC = false
_G.TapTP = false

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

-- [[ WINDOW CREATION ]]
local Window = Library:Window({
    Title = "FCAL HUB",
    Footer = "v1.0.6 | Client Sided"
})

-- [[ TABS ]]
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
    Title = "Reset Character",
    Callback = function() LocalPlayer:LoadCharacter() end
})

QuickSection:AddButton({
    Title = "Refresh Movement",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        Workspace.Gravity = 196
        Library:MakeNotify({ Title = "Success", Content = "Movement Refreshed!" })
    end
})

local TpSection = MainTab:AddSection("🎯 Teleport")

TpSection:AddToggle({
    Title = "Tap to Teleport",
    Default = false,
    Callback = function(v) _G.TapTP = v end
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

MoveSection:AddToggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v) _G.InfJump = v end
})

MoveSection:AddToggle({
    Title = "NoClip (Tembus Tembok)",
    Default = false,
    Callback = function(v) _G.NC = v end
})

local IdentitySection = PlayerTab:AddSection("🎭 Identity Stealer")

local SelectedPlayer = ""
local PlayerDropdown = IdentitySection:AddDropdown({
    Title = "Pilih Pemain",
    Options = (function()
        local t = {}
        for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(t, p.Name) end end
        return t
    end)(),
    Callback = function(v) SelectedPlayer = v end
})

IdentitySection:AddButton({
    Title = "Terapkan Identity",
    Callback = function()
        local target = Players:FindFirstChild(SelectedPlayer)
        if target and target.Character then
            pcall(function()
                local desc = Players:GetHumanoidDescriptionFromUserId(target.UserId)
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ApplyDescription(desc)
            end)
        end
    end
})

-- ==========================================
-- GAME TAB
-- ==========================================
local FarmSection = GameTab:AddSection("🏔️ Auto Farming CP")

FarmSection:AddToggle({
    Title = "Master Auto CP",
    Default = false,
    Callback = function(v)
        _G.AutoCP = v
        if v then
            task.spawn(function()
                local lastNum = 0
                while _G.AutoCP do
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local allCPs = {}
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        local num = tonumber(obj.Name:match("%d+"))
                        if num and num > lastNum and (obj.Name:lower():find("cp") or obj:IsA("SpawnLocation")) then
                            table.insert(allCPs, {Part = obj, Num = num})
                        end
                    end
                    table.sort(allCPs, function(a,b) return a.Num < b.Num end)
                    if #allCPs > 0 then
                        root.CFrame = allCPs[1].Part.CFrame * CFrame.new(0,3,0)
                        lastNum = allCPs[1].Num
                        task.wait(_G.CPDelay)
                    else task.wait(1) end
                end
            end)
        end
    end
})

FarmSection:AddInput({
    Title = "CP Delay",
    Default = 1.0,
    Callback = function(v) _G.CPDelay = tonumber(v) or 1.0 end
})

-- ==========================================
-- SERVER TAB
-- ==========================================
local ProtectSection = ServerTab:AddSection("🛡️ Protection")

ProtectSection:AddToggle({
    Title = "Anti-Kick Protection",
    Default = false,
    Callback = function(v) _G.AntiKick = v end
})

ProtectSection:AddButton({
    Title = "Server Hop",
    Callback = function()
        local servers = {}
        local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
        for i,v in pairs(game:GetService("HttpService"):JSONDecode(res).data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then table.insert(servers, v.id) end
        end
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    end
})

-- ==========================================
-- LOOPS & LOGIC
-- ==========================================
RunService.Stepped:Connect(function()
    if _G.NC and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if _G.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

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

-- Initialize Library
Library:Initialize()
Library:MakeNotify({
    Title = "FCAL HUB",
    Description = "Script Loaded Successfully!",
    Delay = 5
})
