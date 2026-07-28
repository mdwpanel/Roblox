-- =====================================================
-- LYNX HUB / DELTA EXECUTOR MOBILE SCRIPT
-- Features: Infinite Jump, Enable Sprint, Fly, No Clip
-- Platform: Delta Executor (Android / iOS / PC)
-- UI Theme: Lynx Dark Orange (WindUI Compatible)
-- =====================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Load WindUI Library safely
local WindUI = nil
do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if ok and res then
        WindUI = res
    else
        warn("[Lynx Hub] Gagal load WindUI, mencoba fallback...")
        pcall(function()
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
        end)
    end
end

if not WindUI then
    warn("[Lynx Hub] WindUI tidak dapat dimuat!")
    return
end

-- State Variables
local playerState = {
    enableSprint = false,
    sprintSpeed = 50,
    infiniteJump = true,
    enableFly = false,
    flySpeed = 100,
    noClip = false
}

local defaultWalkSpeed = 16
local defaultJumpPower = 50

-- Feature Connections
local infiniteJumpConnection = nil
local sprintConnection = nil
local noClipConnection = nil
local flyConnection = nil
local flyBodyVel = nil
local flyBodyGyro = nil

-- 1. INFINITE JUMP IMPLEMENTATION
local function toggleInfiniteJump(state)
    playerState.infiniteJump = state
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end

    if state then
        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if playerState.infiniteJump then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
        WindUI:Notify({
            Title = "Infinite Jump",
            Content = "Infinite Jump: AKTIF (Tekan Lompat Berulang)",
            Duration = 2
        })
    else
        WindUI:Notify({
            Title = "Infinite Jump",
            Content = "Infinite Jump: MATI",
            Duration = 2
        })
    end
end

-- 2. SPRINT / SPEED IMPLEMENTATION
local function toggleSprint(state)
    playerState.enableSprint = state
    if sprintConnection then
        sprintConnection:Disconnect()
        sprintConnection = nil
    end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if state then
        if hum then defaultWalkSpeed = hum.WalkSpeed end
        sprintConnection = RunService.RenderStepped:Connect(function()
            if playerState.enableSprint then
                local c = LocalPlayer.Character
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if h then
                    h.WalkSpeed = playerState.sprintSpeed
                end
            end
        end)
        WindUI:Notify({
            Title = "Sprint Speed",
            Content = "Sprint Speed Aktif: " .. tostring(playerState.sprintSpeed) .. " stud/s",
            Duration = 2
        })
    else
        if hum then
            hum.WalkSpeed = defaultWalkSpeed
        end
        WindUI:Notify({
            Title = "Sprint Speed",
            Content = "Sprint Speed: MATI",
            Duration = 2
        })
    end
end

-- 3. FLY IMPLEMENTATION
local function stopFlying()
    if flyBodyVel then
        pcall(function() flyBodyVel:Destroy() end)
        flyBodyVel = nil
    end
    if flyBodyGyro then
        pcall(function() flyBodyGyro:Destroy() end)
        flyBodyGyro = nil
    end
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
    end
end

local function toggleFly(state)
    playerState.enableFly = state
    stopFlying()

    if state then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not hrp or not hum then
            WindUI:Notify({ Title = "Fly Error", Content = "Karakter tidak ditemukan!", Duration = 2 })
            return
        end

        hum.PlatformStand = true

        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.Name = "LynxFlyVel"
        flyBodyVel.MaxForce = Vector3.new(1, 1, 1) * 9e9
        flyBodyVel.Velocity = Vector3.zero
        flyBodyVel.Parent = hrp

        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.Name = "LynxFlyGyro"
        flyBodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 9e9
        flyBodyGyro.CFrame = hrp.CFrame
        flyBodyGyro.Parent = hrp

        flyConnection = RunService.RenderStepped:Connect(function()
            if not playerState.enableFly or not char or not char.Parent or hum.Health <= 0 then
                stopFlying()
                return
            end

            local camera = Workspace.CurrentCamera
            local moveDirection = hum.MoveDirection

            if moveDirection.Magnitude > 0 then
                local flyDir = camera.CFrame:VectorToWorldSpace(camera.CFrame:VectorToObjectSpace(CFrame.new(Vector3.zero, camera.CFrame.LookVector)).Rotation * moveDirection)
                flyBodyVel.Velocity = flyDir * playerState.flySpeed
            else
                flyBodyVel.Velocity = Vector3.zero
            end

            flyBodyGyro.CFrame = camera.CFrame
        end)

        WindUI:Notify({
            Title = "Fly Feature",
            Content = "Fly: AKTIF | Kecepatan: " .. tostring(playerState.flySpeed),
            Duration = 2
        })
    else
        WindUI:Notify({
            Title = "Fly Feature",
            Content = "Fly: MATI",
            Duration = 2
        })
    end
end

-- 4. NO CLIP IMPLEMENTATION
local function toggleNoClip(state)
    playerState.noClip = state
    if noClipConnection then
        noClipConnection:Disconnect()
        noClipConnection = nil
    end

    if state then
        noClipConnection = RunService.Stepped:Connect(function()
            if playerState.noClip then
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
        WindUI:Notify({ Title = "No Clip", Content = "No Clip: AKTIF", Duration = 2 })
    else
        WindUI:Notify({ Title = "No Clip", Content = "No Clip: MATI", Duration = 2 })
    end
end

-- CREATE LYNX HUB GUI
local Window = WindUI:CreateWindow({
    Title = "Lynx 🪐 Fish It",
    Icon = "compass",
    Author = "discord.gg/lynxx",
    Folder = "LynxHubDelta",
    Size = UDim2.fromOffset(560, 380),
    Transparent = true,
    Theme = "Dark",
})

-- Create Left Tabs
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- Player Features Section under Settings
SettingsTab:Section({ Title = "Player Features", Icon = "user-check" })

SettingsTab:Toggle({
    Title = "Enable Sprint",
    Desc = "Meningkatkan kecepatan jalan karakter",
    Value = playerState.enableSprint,
    Callback = function(val)
        toggleSprint(val)
    end
})

SettingsTab:Input({
    Title = "Sprint Speed",
    Desc = "Masukkan nilai kecepatan sprint (default: 50)",
    Value = tostring(playerState.sprintSpeed),
    Placeholder = "50",
    Callback = function(text)
        local num = tonumber(text)
        if num and num > 0 then
            playerState.sprintSpeed = num
            if playerState.enableSprint then
                toggleSprint(true)
            end
        end
    end
})

SettingsTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Bisa melompat terus-menerus di udara tanpa batas",
    Value = playerState.infiniteJump,
    Callback = function(val)
        toggleInfiniteJump(val)
    end
})

SettingsTab:Toggle({
    Title = "Enable Fly",
    Desc = "Terbang di udara menggunakan kontrol analog/kamera mobile",
    Value = playerState.enableFly,
    Callback = function(val)
        toggleFly(val)
    end
})

SettingsTab:Input({
    Title = "Fly Speed",
    Desc = "Kecepatan terbang (default: 100)",
    Value = tostring(playerState.flySpeed),
    Placeholder = "100",
    Callback = function(text)
        local num = tonumber(text)
        if num and num > 0 then
            playerState.flySpeed = num
            if playerState.enableFly then
                toggleFly(true)
            end
        end
    end
})

SettingsTab:Toggle({
    Title = "No Clip",
    Desc = "Menembus tembok dan rintangan",
    Value = playerState.noClip,
    Callback = function(val)
        toggleNoClip(val)
    end
})

-- Auto initialize defaults if configured
if playerState.infiniteJump then
    toggleInfiniteJump(true)
end

WindUI:Notify({
    Title = "Lynx Hub Loaded",
    Content = "Fitur Player (Infinite Jump, Speed, Fly) Siap Digunakan!",
    Duration = 3
})
