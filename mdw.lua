--[[
    ███████╗███████╗ █████╗ ██╗     
    ██╔════╝██╔════╝██╔══██╗██║     
    █████╗  █████╗  ███████║██║     
    ██╔══╝  ██╔══╝  ██╔══██║██║     
    ██║     ██║     ██║  ██║███████╗
    ╚═╝     ╚═╝     ╚═╝  ╚═╝╚══════╝
    
    FCAL HUB - WIND UI EDITION
    Version: 1.0.6 | UI: WindUI (Modern)
--]]

-- [[ LOADING WINDUI ]]
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- [[ SERVICES ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
_G.AutoCP = false
_G.CPDelay = 1.0
_G.InfJump = false
_G.NC = false
_G.TapTP = false
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

-- [[ WINDOW CREATION ]]
local Window = WindUI:CreateWindow({
	Title = "FCAL HUB",
	Folder = "FCALHUB_Configs",
	Icon = "solar:palet-2-bold", -- Ikon palet warna
	NewElements = true,
	HideSearchBar = false, -- Fitur pencarian aktif
	OpenButton = {
		Enabled = true,
		Draggable = true,
		OnlyMobile = true, -- Tombol buka hanya di mobile
		Title = "FCAL",
	},
})

-- [[ HELPER FUNCTIONS ]]
local function GetRoot() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
local function GetHum() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end

-- [[ TAB: MAIN ]]
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "solar:home-2-bold",
    Border = true,
})

local QuickActionSection = MainTab:Section({ Title = "🛠️ Quick Actions" })

QuickActionSection:Button({
    Title = "Reset Character",
    Callback = function() LocalPlayer:LoadCharacter() end
})

QuickActionSection:Button({
    Title = "Refresh Movement",
    Callback = function()
        local hum = GetHum()
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
        Workspace.Gravity = 196
        WindUI:Notify({ Title = "Success", Content = "Movement Refreshed!" })
    end
})

local TeleportSection = MainTab:Section({ Title = "🎯 Teleport" })

TeleportSection:Toggle({
    Title = "Tap to Teleport",
    Value = false,
    Callback = function(v) _G.TapTP = v end
})

-- Handle Tap TP Logic
UserInputService.TouchTapInWorld:Connect(function(position, processed)
    if _G.TapTP and not processed then
        local root = GetRoot()
        if root then
            local camera = Workspace.CurrentCamera
            local ray = camera:ViewportPointToRay(position.X, position.Y)
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
            if result then root.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0)) end
        end
    end
end)

-- [[ TAB: PLAYER ]]
local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "solar:user-bold",
    Border = true,
})

local MovementSection = PlayerTab:Section({ Title = "🏃 Movement Settings" })

MovementSection:Slider({
    Title = "WalkSpeed",
    Value = { Min = 16, Max = 250, Default = 16 },
    Callback = function(v) if GetHum() then GetHum().WalkSpeed = v end end
})

MovementSection:Slider({
    Title = "Jump Power",
    Value = { Min = 50, Max = 350, Default = 50 },
    Callback = function(v) if GetHum() then GetHum().JumpPower = v end end
})

MovementSection:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(v) _G.InfJump = v end
})

MovementSection:Toggle({
    Title = "NoClip (Tembus Tembok)",
    Value = false,
    Callback = function(v) _G.NC = v end
})

-- Identity Stealer
local IdentitySection = PlayerTab:Section({ Title = "🎭 Identity Stealer" })

local SelectedPlayerIdentity = ""
IdentitySection:Dropdown({
    Title = "Select Player",
    Values = (function()
        local t = {}
        for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(t, p.Name) end end
        return t
    end)(),
    Callback = function(v) SelectedPlayerIdentity = v end
})

IdentitySection:Button({
    Title = "Apply Identity",
    Callback = function()
        local target = Players:FindFirstChild(SelectedPlayerIdentity)
        if target and target.Character then
            local myChar = LocalPlayer.Character
            for _, v in pairs(myChar:GetChildren()) do
                if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") then v:Destroy() end
            end
            pcall(function()
                local desc = Players:GetHumanoidDescriptionFromUserId(target.UserId)
                myChar:FindFirstChildOfClass("Humanoid"):ApplyDescription(desc)
            end)
            WindUI:Notify({ Title = "Success", Content = "Identity Applied!" })
        end
    end
})

-- [[ TAB: GAME ]]
local GameTab = Window:Tab({
    Title = "Game",
    Icon = "solar:gamepad-bold",
    Border = true,
})

local FarmSection = GameTab:Section({ Title = "🏔️ Auto Farming CP" })

FarmSection:Toggle({
    Title = "Master Auto CP",
    Desc = "Smartly teleports to next Checkpoint",
    Value = false,
    Callback = function(v)
        _G.AutoCP = v
        if v then
            task.spawn(function()
                local lastCPNum = 0
                while _G.AutoCP do
                    local root = GetRoot()
                    local allCPs = {}
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        local num = tonumber(obj.Name:match("%d+"))
                        if num and num > lastCPNum and (obj.Name:lower():find("cp") or obj:IsA("SpawnLocation")) then
                            table.insert(allCPs, {Part = obj, Num = num})
                        end
                    end
                    table.sort(allCPs, function(a,b) return a.Num < b.Num end)
                    if #allCPs > 0 then
                        root.CFrame = allCPs[1].Part.CFrame * CFrame.new(0,3,0)
                        lastCPNum = allCPs[1].Num
                        task.wait(_G.CPDelay)
                    else task.wait(1) end
                end
            end)
        end
    end
})

FarmSection:Slider({
    Title = "CP Delay",
    Value = { Min = 0.1, Max = 5, Default = 1 },
    Callback = function(v) _G.CPDelay = v end
})

local ESPSection = GameTab:Section({ Title = "🎭 Visual ESP" })

ESPSection:Toggle({ Title = "Box ESP", Callback = function(v) _G.BoxESP = v end })
ESPSection:Toggle({ Title = "Tracer ESP", Callback = function(v) _G.LineESP = v end })

-- [[ TAB: SERVER ]]
local ServerTab = Window:Tab({
    Title = "Server",
    Icon = "solar:server-bold",
    Border = true,
})

ServerTab:Button({
    Title = "Server Hop",
    Callback = function()
        local servers = {}
        local res = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100")
        for i,v in pairs(HttpService:JSONDecode(res).data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then table.insert(servers, v.id) end
        end
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    end
})

ServerTab:Button({
    Title = "Rejoin",
    Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end
})

-- [[ TAB: SETTINGS ]]
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "solar:settings-bold",
    Border = true,
})

SettingsTab:Keybind({
    Title = "Toggle UI Key",
    Value = "RightControl",
    Callback = function(v) Window:SetToggleKey(Enum.KeyCode[v]) end
})

SettingsTab:Button({
    Title = "Destroy UI",
    Color = Color3.fromHex("#ff4830"),
    Callback = function() Window:Destroy() end
})

-- [[ LOOPS ]]
RunService.Stepped:Connect(function()
    if _G.NC and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and GetHum() then GetHum():ChangeState(Enum.HumanoidStateType.Jumping) end
end)

WindUI:Notify({
    Title = "FCAL HUB Loaded",
    Content = "Welcome back, " .. LocalPlayer.DisplayName,
    Duration = 5
})
