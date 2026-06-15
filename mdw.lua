-- [[ FCAL HUB - LYNX STYLE REDESIGN ]] --
-- UI Library: Lucid/LynX Version

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/4LynxX/Libb/refs/heads/main/Lib2.lua"))()

-- Inisialisasi Window Utama
local Window = Library:CreateWindow({
    Name = "FCAL HUB",
    SubName = "v1.0.6 | Client Sided",
    Logo = "rbxassetid://16335111162", -- Kamu bisa ganti ID iconnya
    LoadingText = "Sabar, lagi loading..."
})

-- Services & Variabel Penting dari Script Asli Kamu
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
_G.AutoCP = false
_G.CPDelay = 1.0

-- [[ SEKSI MENU SAMPING (TABS) ]]
local MainTab = Window:CreateTab("Main")
local PlayerTab = Window:CreateTab("Player")
local GameTab = Window:CreateTab("Game")
local ServerTab = Window:CreateTab("Server")
local SettingsTab = Window:CreateTab("Settings")

-- ==========================================
-- MAIN TAB (Quick Actions)
-- ==========================================
MainTab:CreateSection("🛠️ Quick Actions")

MainTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        LocalPlayer:LoadCharacter()
    end
})

MainTab:CreateButton({
    Name = "Refresh Movement",
    Callback = function()
        -- Logika reset walkspeed/gravity kamu
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        Workspace.Gravity = 196
    end
})

MainTab:CreateSection("🎯 Teleport")

MainTab:CreateToggle({
    Name = "Tap to Teleport",
    Default = false,
    Callback = function(v)
        _G.TapTP = v
    end
})

-- ==========================================
-- PLAYER TAB (Movement & Identity)
-- ==========================================
PlayerTab:CreateSection("🏃 Movement")

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(v)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(v) _G.InfJump = v end
})

PlayerTab:CreateToggle({
    Name = "NoClip (Tembus Tembok)",
    Default = false,
    Callback = function(v) _G.NC = v end
})

PlayerTab:CreateSection("🎭 Identity Stealer")

PlayerTab:CreateButton({
    Name = "Copy Pemain Terdekat",
    Callback = function()
        -- Masukkan logika ExecuteIdentityCopy dari script asalmu di sini
    end
})

-- ==========================================
-- GAME TAB (Auto CP & ESP)
-- ==========================================
GameTab:CreateSection("🏔️ Auto farming CP")

GameTab:CreateToggle({
    Name = "Start Auto All CP (Master Fix)",
    Default = false,
    Callback = function(v)
        _G.AutoCP = v
        -- Logika perulangan Auto CP dimasukkan di sini
    end
})

GameTab:CreateToggle({
    Name = "Stealth Mode CP",
    Default = false,
    Callback = function(v) _G.StealthCP = v end
})

GameTab:CreateSection("🎭 Visual ESP")

GameTab:CreateToggle({
    Name = "ESP Box (2D)",
    Default = false,
    Callback = function(v) _G.BoxESP = v end
})

GameTab:CreateToggle({
    Name = "ESP Tracers (Line)",
    Default = false,
    Callback = function(v) _G.LineESP = v end
})

-- ==========================================
-- SERVER TAB (Security)
-- ==========================================
ServerTab:CreateSection("🛡️ Self-Protection")

ServerTab:CreateToggle({
    Name = "Anti-Kick Protection",
    Default = false,
    Callback = function(v)
        _G.AntiKick = v
        -- Gunakan logic hookmetamethod __namecall yang ada di script aslimu
    end
})

ServerTab:CreateButton({
    Name = "Instant Server Hop",
    Callback = function()
        -- Logika pindah server
    end
})

-- ==========================================
-- SETTINGS TAB
-- ==========================================
SettingsTab:CreateSection("⚙️ Settings")

SettingsTab:CreateToggle({
    Name = "Streamer Mode",
    Default = false,
    Callback = function(v)
        if v then
            Window:UpdateName("SECRET HUB")
        else
            Window:UpdateName("FCAL HUB")
        end
    end
})

SettingsTab:CreateKeybind({
    Name = "Toggle Menu",
    Default = Enum.KeyCode.RightControl,
    Callback = function()
        -- Fungsi untuk menyembunyikan/menampilkan UI
    end
})

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Library:Destroy()
    end
})

-- [[ NOTIFIKASI SUKSES ]]
Library:Notify({
    Title = "FCAL HUB",
    Content = "Script Loaded with LynX UI Style!",
    Duration = 5
})
