-- ND || HUB v2.0.1 — Fixed Mobile + Updated Pill
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
local settings = {theme = "NeonBlue", guiSize = isMobile and 2 or 1, animations = true, nametag = false, menuOpen = false}

local themes = {
    NeonBlue = {
        Main = Color3.fromRGB(8, 12, 25), TopBar = Color3.fromRGB(5, 8, 18),
        Accent = Color3.fromRGB(0, 200, 255), Accent2 = Color3.fromRGB(100, 100, 255),
        Button = Color3.fromRGB(12, 18, 35), ButtonText = Color3.fromRGB(180, 220, 255),
        ToggleBg = Color3.fromRGB(18, 25, 45), Text = Color3.fromRGB(150, 200, 240),
        TabBg = Color3.fromRGB(6, 10, 20), NametagAccent = Color3.fromRGB(0, 200, 255),
        NametagName = Color3.fromRGB(255, 255, 255), Gradient1 = Color3.fromRGB(0, 180, 255),
        Gradient2 = Color3.fromRGB(100, 60, 255), MenuBg = Color3.fromRGB(5, 8, 20),
    },
    NeonPurple = {
        Main = Color3.fromRGB(15, 8, 25), TopBar = Color3.fromRGB(10, 5, 18),
        Accent = Color3.fromRGB(180, 60, 255), Accent2 = Color3.fromRGB(255, 60, 200),
        Button = Color3.fromRGB(22, 12, 35), ButtonText = Color3.fromRGB(220, 180, 255),
        ToggleBg = Color3.fromRGB(30, 15, 45), Text = Color3.fromRGB(200, 150, 245),
        TabBg = Color3.fromRGB(12, 6, 20), NametagAccent = Color3.fromRGB(180, 60, 255),
        NametagName = Color3.fromRGB(255, 255, 255), Gradient1 = Color3.fromRGB(180, 60, 255),
        Gradient2 = Color3.fromRGB(255, 60, 200), MenuBg = Color3.fromRGB(10, 5, 20),
    },
    NeonGreen = {
        Main = Color3.fromRGB(5, 20, 10), TopBar = Color3.fromRGB(3, 15, 6),
        Accent = Color3.fromRGB(30, 255, 80), Accent2 = Color3.fromRGB(60, 255, 200),
        Button = Color3.fromRGB(8, 28, 14), ButtonText = Color3.fromRGB(160, 255, 180),
        ToggleBg = Color3.fromRGB(12, 35, 18), Text = Color3.fromRGB(140, 240, 160),
        TabBg = Color3.fromRGB(4, 14, 8), NametagAccent = Color3.fromRGB(30, 255, 80),
        NametagName = Color3.fromRGB(255, 255, 255), Gradient1 = Color3.fromRGB(30, 255, 80),
        Gradient2 = Color3.fromRGB(60, 255, 200), MenuBg = Color3.fromRGB(3, 15, 6),
    },
    NeonRed = {
        Main = Color3.fromRGB(25, 8, 8), TopBar = Color3.fromRGB(18, 4, 4),
        Accent = Color3.fromRGB(255, 40, 40), Accent2 = Color3.fromRGB(255, 100, 40),
        Button = Color3.fromRGB(35, 12, 12), ButtonText = Color3.fromRGB(255, 180, 180),
        ToggleBg = Color3.fromRGB(50, 14, 14), Text = Color3.fromRGB(255, 140, 140),
        TabBg = Color3.fromRGB(16, 6, 6), NametagAccent = Color3.fromRGB(255, 40, 40),
        NametagName = Color3.fromRGB(255, 255, 255), Gradient1 = Color3.fromRGB(255, 40, 40),
        Gradient2 = Color3.fromRGB(255, 100, 40), MenuBg = Color3.fromRGB(18, 4, 4),
    },
    NeonGold = {
        Main = Color3.fromRGB(20, 15, 5), TopBar = Color3.fromRGB(15, 10, 2),
        Accent = Color3.fromRGB(255, 200, 30), Accent2 = Color3.fromRGB(255, 150, 20),
        Button = Color3.fromRGB(30, 22, 8), ButtonText = Color3.fromRGB(255, 240, 180),
        ToggleBg = Color3.fromRGB(40, 30, 10), Text = Color3.fromRGB(240, 220, 150),
        TabBg = Color3.fromRGB(15, 10, 4), NametagAccent = Color3.fromRGB(255, 200, 30),
        NametagName = Color3.fromRGB(255, 255, 255), Gradient1 = Color3.fromRGB(255, 200, 30),
        Gradient2 = Color3.fromRGB(255, 150, 20), MenuBg = Color3.fromRGB(15, 10, 2),
    },
}
local currentTheme = themes[settings.theme]
local guiSizes = {0.85, 1, 1.2}
local guiMul = guiSizes[settings.guiSize] or 1

local gui = Instance.new("ScreenGui")
gui.Name = "NDHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = game.CoreGui

spawn(function()
    pcall(function() setclipboard("discord.gg/8ycCx8PQb") end)
    StarterGui:SetCore("SendNotification", {Title="ND || HUB v2.0.1",Text="discord.gg/8ycCx8PQb — Copied!",Duration=8})
end)

-- Status bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(0, 190, 0, 24)
statusBar.Position = UDim2.new(1, -200, 0, isMobile and 52 or 8)
statusBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statusBar.BackgroundTransparency = 0.35
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 1000
statusBar.Parent = gui
local statusCorner = Instance.new("UICorner"); statusCorner.CornerRadius = UDim.new(0, 8); statusCorner.Parent = statusBar
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -8, 1, 0); statusText.Position = UDim2.new(0, 4, 0, 0)
statusText.BackgroundTransparency = 1; statusText.Text = "ND HUB | -- FPS | -- ms"
statusText.TextColor3 = Color3.fromRGB(255, 255, 255); statusText.TextSize = 10
statusText.Font = Enum.Font.SourceSansBold; statusText.TextXAlignment = Enum.TextXAlignment.Center; statusText.Parent = statusBar
spawn(function()
    while gui and gui.Parent do
        local ping = math.floor(Stats.PerformanceStats.Ping:GetValue() * 1000)
        local fps = math.floor(1 / RunService.Heartbeat:Wait())
        local placeName = "Unknown"
        pcall(function() placeName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
        if #placeName > 12 then placeName = placeName:sub(1, 12) .. ".." end
        statusText.Text = "ND HUB | " .. fps .. " FPS | " .. ping .. "ms | " .. placeName
        wait(0.5)
    end
end)

-- ==================== MOBILE PILL (Fixed) ====================
local main = nil
local guiVisible = false
local introDone = false

local function showGUI()
    if not main then return end
    guiVisible = true
    main.Visible = true
    local baseW = math.floor((isMobile and 370 or 360) * guiMul)
    local baseH = math.floor((isMobile and 540 or 510) * guiMul)
    main.Size = UDim2.new(0, baseW, 0, 0)
    main.Position = UDim2.new(0.5, -baseW/2, 0.5, 0)
    main.BackgroundTransparency = 1
    TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, baseW, 0, baseH),
        Position = UDim2.new(0.5, -baseW/2, 0.5, -baseH/2),
        BackgroundTransparency = 0,
    }):Play()
end

local function hideGUI()
    if not main then return end; guiVisible = false
    if settings.menuOpen then toggleMenu() end
    local baseW = math.floor((isMobile and 370 or 360) * guiMul)
    TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, baseW, 0, 0),
        Position = UDim2.new(0.5, -baseW/2, 0.5, 0),
        BackgroundTransparency = 1,
    }):Play()
    task.delay(0.35, function() main.Visible = false end)
end

if isMobile then
    local pill = Instance.new("TextButton")
    pill.Size = UDim2.new(0, 180, 0, 40)
    pill.Position = UDim2.new(0.5, -90, 0, 6)
    pill.BackgroundColor3 = Color3.fromRGB(5, 8, 18)
    pill.BorderSizePixel = 0
    pill.Text = "ND || HUB v2.0"
    pill.TextColor3 = currentTheme.Accent2
    pill.TextSize = 15
    pill.Font = Enum.Font.SourceSansBold
    pill.ZIndex = 1000
    pill.AutoButtonColor = false
    pill.Active = true
    pill.Selectable = true
    pill.Parent = gui
    
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1, 0); c.Parent = pill
    local s = Instance.new("UIStroke"); s.Color = currentTheme.Accent; s.Thickness = 1.5; s.Parent = pill
    local pg = Instance.new("UIGradient")
    pg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, currentTheme.Gradient1),
        ColorSequenceKeypoint.new(1, currentTheme.Gradient2),
    })
    pg.Rotation = 90
    pg.Parent = pill
    
    pill.MouseButton1Click:Connect(function()
        if main then
            if guiVisible then hideGUI() else showGUI() end
        end
    end)
end

-- Intro
local introFrame = Instance.new("Frame")
introFrame.Size = UDim2.new(0, 80, 0, 80)
introFrame.Position = UDim2.new(0.5, -40, 0.5, -40)
introFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
introFrame.BorderSizePixel = 0
introFrame.BackgroundTransparency = 0
introFrame.ZIndex = 9999
introFrame.Parent = gui

local introCorner = Instance.new("UICorner"); introCorner.CornerRadius = UDim.new(0, 14); introCorner.Parent = introFrame
local introStroke = Instance.new("UIStroke"); introStroke.Color = currentTheme.Accent; introStroke.Thickness = 2; introStroke.Parent = introFrame
local introText = Instance.new("TextLabel")
introText.Size = UDim2.new(1, 0, 1, 0); introText.BackgroundTransparency = 1
introText.Text = "ND"; introText.TextColor3 = Color3.fromRGB(255, 255, 255)
introText.TextSize = 34; introText.Font = Enum.Font.SourceSansBold; introText.Parent = introFrame

spawn(function()
    wait(0.5)
    TweenService:Create(introFrame, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 90, 0, 90), Position = UDim2.new(0.5, -45, 0.5, -45),
    }):Play()
    wait(1.2)
    TweenService:Create(introFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 280, 0, 70), Position = UDim2.new(0.5, -140, 0.5, -35),
    }):Play()
    introText.Text = "ND || HUB"; introText.TextSize = 26
    wait(1.0)
    TweenService:Create(introFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(introStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
    TweenService:Create(introText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    wait(0.5)
    introFrame:Destroy()
    introDone = true
    showGUI()
end)

-- Discord popup
spawn(function()
    repeat wait(0.1) until introDone
    wait(0.5)
    local s = Instance.new("Frame"); s.Size=UDim2.new(0,320,0,150); s.Position=UDim2.new(0.5,-160,0.5,-75)
    s.BackgroundColor3=Color3.fromRGB(0,0,0); s.BackgroundTransparency=1; s.BorderSizePixel=0; s.ZIndex=9999; s.Parent=gui
    local sc=Instance.new("UICorner"); sc.CornerRadius=UDim.new(0,12); sc.Parent=s
    local st=Instance.new("UIStroke"); st.Color=currentTheme.Accent; st.Thickness=2; st.Transparency=1; st.Parent=s
    local t1=Instance.new("TextLabel"); t1.Size=UDim2.new(1,0,0,28); t1.Position=UDim2.new(0,0,0,20); t1.BackgroundTransparency=1
    t1.Text="ND || HUB v2.0.1"; t1.TextColor3=currentTheme.Accent2; t1.TextSize=22; t1.Font=Enum.Font.SourceSansBold; t1.TextTransparency=1; t1.Parent=s
    local t2=Instance.new("TextLabel"); t2.Size=UDim2.new(1,0,0,20); t2.Position=UDim2.new(0,0,0,50); t2.BackgroundTransparency=1
    t2.Text="Copied to clipboard!"; t2.TextColor3=Color3.fromRGB(180,180,180); t2.TextSize=13; t2.Font=Enum.Font.SourceSans; t2.TextTransparency=1; t2.Parent=s
    local t3=Instance.new("TextLabel"); t3.Size=UDim2.new(1,0,0,28); t3.Position=UDim2.new(0,0,0,72); t3.BackgroundTransparency=1
    t3.Text="discord.gg/8ycCx8PQb"; t3.TextColor3=currentTheme.Accent; t3.TextSize=15; t3.Font=Enum.Font.SourceSansBold; t3.TextTransparency=1; t3.Parent=s
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,160,0,34); btn.Position=UDim2.new(0.5,-80,0,108)
    btn.BackgroundColor3=currentTheme.Accent; btn.BackgroundTransparency=1; btn.BorderSizePixel=0
    btn.Text="OK"; btn.TextColor3=Color3.fromRGB(0,0,0); btn.TextSize=13; btn.Font=Enum.Font.SourceSansBold; btn.AutoButtonColor=false; btn.TextTransparency=1; btn.Parent=s
    local bc=Instance.new("UICorner"); bc.CornerRadius=UDim.new(0,8); bc.Parent=btn
    TweenService:Create(s,TweenInfo.new(0.4),{BackgroundTransparency=0.1}):Play()
    TweenService:Create(st,TweenInfo.new(0.4),{Transparency=0}):Play()
    TweenService:Create(t1,TweenInfo.new(0.4),{TextTransparency=0}):Play()
    TweenService:Create(t2,TweenInfo.new(0.4),{TextTransparency=0}):Play()
    TweenService:Create(t3,TweenInfo.new(0.4),{TextTransparency=0}):Play()
    TweenService:Create(btn,TweenInfo.new(0.4),{BackgroundTransparency=0,TextTransparency=0}):Play()
    local done=false
    btn.MouseButton1Click:Connect(function()
        if done then return end; done=true
        TweenService:Create(s,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        TweenService:Create(st,TweenInfo.new(0.3),{Transparency=1}):Play()
        TweenService:Create(t1,TweenInfo.new(0.3),{TextTransparency=1}):Play()
        TweenService:Create(t2,TweenInfo.new(0.3),{TextTransparency=1}):Play()
        TweenService:Create(t3,TweenInfo.new(0.3),{TextTransparency=1}):Play()
        TweenService:Create(btn,TweenInfo.new(0.3),{BackgroundTransparency=1,TextTransparency=1}):Play()
        task.delay(0.3,function() s:Destroy() end)
    end)
end)

-- Main GUI
local baseW = math.floor((isMobile and 370 or 360) * guiMul)
local baseH = math.floor((isMobile and 540 or 510) * guiMul)

main = Instance.new("Frame")
main.Size = UDim2.new(0, baseW, 0, baseH)
main.Position = UDim2.new(0.5, -baseW/2, 0.5, -baseH/2)
main.BackgroundColor3 = currentTheme.Main
main.BorderSizePixel = 0
main.Active = true; main.Draggable = true; main.Visible = false; main.ZIndex = 100
main.ClipsDescendants = true; main.Parent = gui

local ms = Instance.new("UIStroke"); ms.Color = currentTheme.Accent; ms.Thickness = 1; ms.Parent = main
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 12); mc.Parent = main

-- Top bar
local topH = math.floor((isMobile and 42 or 34) * guiMul)
local topBar = Instance.new("Frame"); topBar.Size = UDim2.new(1, 0, 0, topH)
topBar.BackgroundColor3 = currentTheme.TopBar; topBar.BorderSizePixel = 0; topBar.Parent = main
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 12); tc.Parent = topBar
local tbc = Instance.new("Frame"); tbc.Size = UDim2.new(1, 0, 0, 12); tbc.Position = UDim2.new(0, 0, 1, -12)
tbc.BackgroundColor3 = currentTheme.TopBar; tbc.BorderSizePixel = 0; tbc.Parent = topBar

-- Hamburger button (FIXED)
local hamburgerBtn = Instance.new("TextButton")
hamburgerBtn.Size = UDim2.new(0, 32, 0, 32)
hamburgerBtn.Position = UDim2.new(0, 8, 0.5, -16)
hamburgerBtn.BackgroundColor3 = currentTheme.Button
hamburgerBtn.BorderSizePixel = 0
hamburgerBtn.Text = "☰"
hamburgerBtn.TextColor3 = currentTheme.Accent2
hamburgerBtn.TextSize = 18
hamburgerBtn.Font = Enum.Font.SourceSansBold
hamburgerBtn.AutoButtonColor = false
hamburgerBtn.Active = true
hamburgerBtn.Selectable = true
hamburgerBtn.ZIndex = 10
hamburgerBtn.Parent = topBar
local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0, 6); hc.Parent = hamburgerBtn

local luaIcon = Instance.new("ImageLabel")
luaIcon.Size = UDim2.new(0, 22, 0, 22); luaIcon.Position = UDim2.new(0, 46, 0.5, -11)
luaIcon.BackgroundTransparency = 1; luaIcon.Image = "rbxassetid://14473753935"; luaIcon.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 180, 1, 0); title.Position = UDim2.new(0, 72, 0, 0)
title.BackgroundTransparency = 1; title.Text = "ND || HUB v2.0.1"
title.TextColor3 = currentTheme.Accent2; title.TextSize = math.floor((isMobile and 14 or 12) * guiMul)
title.Font = Enum.Font.SourceSansBold; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28); closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
closeBtn.BackgroundColor3 = currentTheme.Button; closeBtn.BorderSizePixel = 0
closeBtn.Text = "−"; closeBtn.TextColor3 = currentTheme.Accent2; closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.SourceSansBold; closeBtn.AutoButtonColor = false; closeBtn.Active = true; closeBtn.Selectable = true; closeBtn.Parent = topBar
local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 6); cc.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function() hideGUI() end)

-- Side menu
local sideMenu = Instance.new("Frame")
sideMenu.Size = UDim2.new(0, 200, 0, baseH - topH)
sideMenu.Position = UDim2.new(0, -210, 0, topH)
sideMenu.BackgroundColor3 = currentTheme.MenuBg
sideMenu.BorderSizePixel = 0
sideMenu.ZIndex = 90
sideMenu.Visible = true
sideMenu.Parent = main
local smc = Instance.new("UICorner"); smc.CornerRadius = UDim.new(0, 8); smc.Parent = sideMenu
local sms = Instance.new("UIStroke"); sms.Color = currentTheme.Accent; sms.Thickness = 1; sms.Parent = sideMenu

-- Player info
local playerInfoFrame = Instance.new("Frame")
playerInfoFrame.Size = UDim2.new(1, -16, 0, 120); playerInfoFrame.Position = UDim2.new(0, 8, 0, 10)
playerInfoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0); playerInfoFrame.BackgroundTransparency = 0.5
playerInfoFrame.BorderSizePixel = 0; playerInfoFrame.Parent = sideMenu
local pifc = Instance.new("UICorner"); pifc.CornerRadius = UDim.new(0, 6); pifc.Parent = playerInfoFrame
local pifs = Instance.new("UIStroke"); pifs.Color = currentTheme.Accent; pifs.Thickness = 1; pifs.Parent = playerInfoFrame

local playerIcon = Instance.new("ImageLabel")
playerIcon.Size = UDim2.new(0, 40, 0, 40); playerIcon.Position = UDim2.new(0.5, -20, 0, 8)
playerIcon.BackgroundTransparency = 1; playerIcon.Image = "rbxassetid://14473753935"; playerIcon.Parent = playerInfoFrame

local playerName = Instance.new("TextLabel")
playerName.Size = UDim2.new(1, -16, 0, 18); playerName.Position = UDim2.new(0, 8, 0, 52)
playerName.BackgroundTransparency = 1; playerName.Text = LocalPlayer.DisplayName
playerName.TextColor3 = Color3.fromRGB(255, 255, 255); playerName.TextSize = 13
playerName.Font = Enum.Font.SourceSansBold; playerName.TextXAlignment = Enum.TextXAlignment.Center; playerName.Parent = playerInfoFrame

local playerUserId = Instance.new("TextLabel")
playerUserId.Size = UDim2.new(1, -16, 0, 14); playerUserId.Position = UDim2.new(0, 8, 0, 70)
playerUserId.BackgroundTransparency = 1; playerUserId.Text = "@" .. LocalPlayer.Name
playerUserId.TextColor3 = Color3.fromRGB(150, 150, 150); playerUserId.TextSize = 10
playerUserId.Font = Enum.Font.SourceSans; playerUserId.TextXAlignment = Enum.TextXAlignment.Center; playerUserId.Parent = playerInfoFrame

local playerDevice = Instance.new("TextLabel")
playerDevice.Size = UDim2.new(1, -16, 0, 14); playerDevice.Position = UDim2.new(0, 8, 0, 86)
playerDevice.BackgroundTransparency = 1; playerDevice.Text = "📱 " .. (isMobile and "Mobile" or "PC")
playerDevice.TextColor3 = currentTheme.Accent2; playerDevice.TextSize = 10
playerDevice.Font = Enum.Font.SourceSansBold; playerDevice.TextXAlignment = Enum.TextXAlignment.Center; playerDevice.Parent = playerInfoFrame

local playerExecutor = Instance.new("TextLabel")
playerExecutor.Size = UDim2.new(1, -16, 0, 14); playerExecutor.Position = UDim2.new(0, 8, 0, 102)
playerExecutor.BackgroundTransparency = 1; playerExecutor.Text = "⚡ Executor"
playerExecutor.TextColor3 = currentTheme.Accent; playerExecutor.TextSize = 9
playerExecutor.Font = Enum.Font.SourceSansBold; playerExecutor.TextXAlignment = Enum.TextXAlignment.Center; playerExecutor.Parent = playerInfoFrame

-- Menu tabs
local menuTabNames = {"FLY", "AIM", "ESP", "MM2", "FUN", "SET"}
local menuTabBtns = {}
local menuY = 140

for i, name in pairs(menuTabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 34); btn.Position = UDim2.new(0, 12, 0, menuY + (i-1)*38)
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0); btn.BackgroundTransparency = 0.5; btn.BorderSizePixel = 0
    btn.Text = name; btn.TextColor3 = currentTheme.Text; btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold; btn.AutoButtonColor = false; btn.Active = true; btn.Selectable = true; btn.Parent = sideMenu
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 18); bc.Parent = btn
    local bs = Instance.new("UIStroke"); bs.Color = currentTheme.Accent; bs.Thickness = 1; bs.Parent = btn
    btn.MouseButton1Click:Connect(function()
        switchTab(i)
        toggleMenu()
        for _, b in pairs(menuTabBtns) do b.TextColor3 = currentTheme.Text end
        btn.TextColor3 = currentTheme.Accent2
    end)
    table.insert(menuTabBtns, btn)
end

function toggleMenu()
    settings.menuOpen = not settings.menuOpen
    if settings.menuOpen then
        TweenService:Create(sideMenu, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, topH)
        }):Play()
    else
        TweenService:Create(sideMenu, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0, -210, 0, topH)
        }):Play()
    end
end

hamburgerBtn.MouseButton1Click:Connect(toggleMenu)

-- Content
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, 0, 1, -(topH + 2))
contentArea.Position = UDim2.new(0, 0, 0, topH + 2)
contentArea.BackgroundTransparency = 1
contentArea.Parent = main

local tabNames = {"FLY", "AIM", "ESP", "MM2", "FUN", "SET"}
local pages = {}
local currentTab = 1

for i = 1, #tabNames do
    local p = Instance.new("Frame"); p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1; p.Visible = (i == 1); p.Parent = contentArea; pages[i] = p
end

function switchTab(newIndex)
    local oldIndex = currentTab
    if oldIndex == newIndex then return end
    local direction = (newIndex > oldIndex) and 1 or -1
    for idx, p in pairs(pages) do
        if p.Visible then
            if settings.animations then
                TweenService:Create(p, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Position = UDim2.new(0, -30 * direction, 0, 0)
                }):Play()
            end
            task.delay(0.1, function() p.Visible = false; p.Position = UDim2.new(0, 0, 0, 0) end)
        end
    end
    pages[newIndex].Visible = true
    pages[newIndex].Position = UDim2.new(0, 30 * direction, 0, 0)
    if settings.animations then
        TweenService:Create(pages[newIndex], TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    else
        pages[newIndex].Position = UDim2.new(0, 0, 0, 0)
    end
    currentTab = newIndex
end

local function makeScroller(parent)
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1, 0, 1, 0); sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = math.floor((isMobile and 6 or 3) * guiMul)
    sc.ScrollBarImageColor3 = currentTheme.Accent
    sc.CanvasSize = UDim2.new(0, 0, 0, 1500); sc.ScrollingDirection = Enum.ScrollingDirection.Y
    sc.Parent = parent; return sc
end

local scrollers = {}
for i = 1, #tabNames do scrollers[i] = makeScroller(pages[i]) end

local btnH = math.floor((isMobile and 38 or 30) * guiMul)
local lblH = math.floor((isMobile and 20 or 16) * guiMul)
local txtSize = math.floor((isMobile and 13 or 11) * guiMul)
local smallTxt = math.floor((isMobile and 11 or 9) * guiMul)
local gap = math.floor((isMobile and 7 or 5) * guiMul)

function notify(msg)
    spawn(function()
        for _, v in pairs(main:GetChildren()) do if v.Name == "Notif" then v:Destroy() end end
        local n = Instance.new("TextLabel"); n.Name = "Notif"
        n.Size = UDim2.new(0, 200, 0, math.floor(22 * guiMul))
        n.Position = UDim2.new(0.5, -100, 0, -36)
        n.BackgroundColor3 = currentTheme.TopBar; n.BorderSizePixel = 0
        n.Text = msg; n.TextColor3 = currentTheme.Accent2
        n.TextSize = math.floor(10 * guiMul); n.Font = Enum.Font.SourceSansBold; n.Parent = main; n.ZIndex = 10
        local nc = Instance.new("UICorner"); nc.CornerRadius = UDim.new(0, 5); nc.Parent = n
        local ns = Instance.new("UIStroke"); ns.Color = currentTheme.Accent; ns.Thickness = 1; ns.Parent = n
        if settings.animations then
            n.BackgroundTransparency = 1; n.TextTransparency = 1
            TweenService:Create(n, TweenInfo.new(0.15), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
            wait(1.8)
            TweenService:Create(n, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            wait(0.2)
        else wait(2) end
        n:Destroy()
    end)
end

local function addSection(sc, text, y)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1, -16, 0, lblH+4); f.Position = UDim2.new(0, 8, 0, y)
    f.BackgroundTransparency = 1; f.Parent = sc
    local l = Instance.new("Frame"); l.Size = UDim2.new(0, 3, 0, lblH); l.Position = UDim2.new(0, 0, 0, 2)
    l.BackgroundColor3 = currentTheme.Accent; l.BorderSizePixel = 0; l.Parent = f
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1, -10, 0, lblH); t.Position = UDim2.new(0, 8, 0, 2)
    t.BackgroundTransparency = 1; t.Text = text; t.TextColor3 = currentTheme.Text
    t.TextSize = smallTxt; t.Font = Enum.Font.SourceSansBold; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = f
end

local function addToggle(sc, text, y, callback)
    local state = false
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, btnH); container.Position = UDim2.new(0, 8, 0, y)
    container.BackgroundColor3 = currentTheme.Button; container.BorderSizePixel = 0
    container.Active = true; container.Parent = sc
    local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0, 6); cr.Parent = container
    local cs = Instance.new("UIStroke"); cs.Color = currentTheme.Accent; cs.Thickness = 1; cs.Transparency = 0.5; cs.Parent = container
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 160, 1, 0); label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1; label.Text = text .. ": OFF"; label.TextColor3 = currentTheme.ButtonText
    label.TextSize = txtSize; label.Font = Enum.Font.SourceSansBold; label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16); dot.Position = UDim2.new(1, -24, 0.5, -8)
    dot.BackgroundColor3 = currentTheme.Accent; dot.BorderSizePixel = 0; dot.Parent = container
    local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1, 0); dc.Parent = dot
    local function setToggle(on)
        state = on
        if on then
            label.Text = text .. ": ON"; dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
            container.BackgroundColor3 = currentTheme.Accent; label.TextColor3 = Color3.fromRGB(0,0,0); cs.Transparency = 0
        else
            label.Text = text .. ": OFF"; dot.BackgroundColor3 = currentTheme.Accent
            container.BackgroundColor3 = currentTheme.Button; label.TextColor3 = currentTheme.ButtonText; cs.Transparency = 0.5
        end
    end
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setToggle(not state); callback(state)
        end
    end)
end

local function addSlider(sc, text, min, max, default, y, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, lblH); lbl.Position = UDim2.new(0, 8, 0, y)
    lbl.BackgroundTransparency = 1; lbl.Text = text .. ": " .. default
    lbl.TextColor3 = currentTheme.Text; lbl.TextSize = smallTxt; lbl.Font = Enum.Font.SourceSans; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sc
    local barBg = Instance.new("Frame"); barBg.Size = UDim2.new(1, -16, 0, 28); barBg.Position = UDim2.new(0, 8, 0, y+lblH+2)
    barBg.BackgroundTransparency = 1; barBg.Parent = sc
    local bar = Instance.new("Frame"); bar.Size = UDim2.new(1, 0, 0, 5); bar.Position = UDim2.new(0, 0, 0, 11)
    bar.BackgroundColor3 = currentTheme.ToggleBg; bar.BorderSizePixel = 0; bar.Parent = barBg
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1,0); bc.Parent = bar
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = currentTheme.Accent; fill.BorderSizePixel = 0; fill.Parent = bar
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1,0); fc.Parent = fill
    local dragging = false; local sd = false
    local function update(inputX)
        local relX = math.clamp(inputX - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
        local pos = relX / bar.AbsoluteSize.X; local val = math.floor(min + (max-min)*pos + 0.5)
        fill.Size = UDim2.new(pos, 0, 1, 0); lbl.Text = text .. ": " .. val; callback(val)
    end
    bar.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not sd then
            dragging = true; sd = true; update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false; sd = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
end

local function addButton(sc, text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, btnH); btn.Position = UDim2.new(0, 8, 0, y)
    btn.BackgroundColor3 = currentTheme.Button; btn.BorderSizePixel = 0
    btn.Text = text; btn.TextColor3 = currentTheme.ButtonText
    btn.TextSize = txtSize; btn.Font = Enum.Font.SourceSansBold
    btn.AutoButtonColor = false; btn.Active = true; btn.Selectable = true; btn.Parent = sc
    local cr = Instance.new("UICorner"); cr.CornerRadius = UDim.new(0, 6); cr.Parent = btn
    local cs = Instance.new("UIStroke"); cs.Color = currentTheme.Accent; cs.Thickness = 1; cs.Transparency = 0.5; cs.Parent = btn
    if settings.animations then
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = currentTheme.Accent, TextColor3 = Color3.fromRGB(0,0,0)}):Play()
            TweenService:Create(cs, TweenInfo.new(0.1), {Transparency = 0}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = currentTheme.Button, TextColor3 = currentTheme.ButtonText}):Play()
            TweenService:Create(cs, TweenInfo.new(0.1), {Transparency = 0.5}):Play()
        end)
    end
    btn.MouseButton1Click:Connect(callback); return btn
end

-- ==================== ALL FUNCTIONS ====================
local flyEnabled, flySpeed = false, 50
local flyBodyGyro, flyBodyVelocity, flyConnection = nil, nil, nil
local function flyCleanup() if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end; if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end; if flyConnection then flyConnection:Disconnect(); flyConnection = nil end end
local function flyAttach(root) flyCleanup(); if not root then return end; flyBodyGyro = Instance.new("BodyGyro"); flyBodyGyro.MaxTorque = Vector3.new(400000,400000,400000); flyBodyGyro.P=15000; flyBodyGyro.D=500; flyBodyGyro.CFrame=root.CFrame; flyBodyGyro.Parent=root; flyBodyVelocity = Instance.new("BodyVelocity"); flyBodyVelocity.MaxForce=Vector3.new(400000,400000,400000); flyBodyVelocity.Velocity=Vector3.zero; flyBodyVelocity.P=1000; flyBodyVelocity.Parent=root end
local smoothVel = Vector3.zero
local function flyStart() local char=LocalPlayer.Character; if not char then notify("No character!"); return end; local root=char:FindFirstChild("HumanoidRootPart"); if not root then notify("No root!"); return end; smoothVel=Vector3.zero; flyAttach(root); flyConnection=RunService.Heartbeat:Connect(function() if not flyEnabled then return end; local char=LocalPlayer.Character; if not char then return end; local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end; if flyBodyVelocity and flyBodyVelocity.Parent~=root then flyAttach(root) end; local cam=Workspace.CurrentCamera; if not cam then return end; local dir=Vector3.zero; if not isMobile then if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=cam.CFrame.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=cam.CFrame.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=cam.CFrame.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=cam.CFrame.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.yAxis end; if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.yAxis end else local hum=char:FindFirstChild("Humanoid"); if hum and hum.MoveDirection.Magnitude>0 then local md=hum.MoveDirection; if md.Z>0.1 then dir+=cam.CFrame.LookVector*md.Z elseif md.Z<-0.1 then dir+=cam.CFrame.LookVector*md.Z end; if md.X>0.1 then dir+=cam.CFrame.RightVector*md.X elseif md.X<-0.1 then dir+=cam.CFrame.RightVector*md.X end end; if UserInputService:IsKeyDown(Enum.KeyCode.ButtonR2) then dir+=Vector3.yAxis end; if UserInputService:IsKeyDown(Enum.KeyCode.ButtonL2) then dir-=Vector3.yAxis end end; local tv=dir.Magnitude>0 and dir.Unit*flySpeed or Vector3.zero; smoothVel=smoothVel:Lerp(tv,0.15); if flyBodyVelocity then flyBodyVelocity.Velocity=smoothVel end; if flyBodyGyro then flyBodyGyro.CFrame=CFrame.new(root.Position,root.Position+cam.CFrame.LookVector) end end); notify("Fly ON") end
local function flyStop() flyEnabled=false; smoothVel=Vector3.zero; flyCleanup(); notify("Fly OFF") end
LocalPlayer.CharacterAdded:Connect(function(char) if flyEnabled then task.wait(0.5); local root=char:FindFirstChild("HumanoidRootPart"); if root then smoothVel=Vector3.zero; flyAttach(root) end end end)

local speedEnabled, speedVal, speedConnection = false, 50, nil
local function speedStart() if speedConnection then speedConnection:Disconnect() end; speedConnection=RunService.Heartbeat:Connect(function() if not speedEnabled then return end; pcall(function() local char=LocalPlayer.Character; if char then local hum=char:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed=speedVal end end end) end); pcall(function() local char=LocalPlayer.Character; if char then local hum=char:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed=speedVal end end end) end
local function speedStop() if speedConnection then speedConnection:Disconnect(); speedConnection=nil end; pcall(function() local char=LocalPlayer.Character; if char then local hum=char:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed=16 end end end) end

local spinEnabled, spinSpeed = false, 30; local spinConnection, spinBody = nil, nil
local function spinStart() if spinConnection then spinConnection:Disconnect() end; spinConnection=RunService.Heartbeat:Connect(function() if not spinEnabled then return end; pcall(function() local char=LocalPlayer.Character; if char then local root=char:FindFirstChild("HumanoidRootPart"); if root then if not spinBody or spinBody.Parent~=root then if spinBody then spinBody:Destroy() end; spinBody=Instance.new("BodyAngularVelocity"); spinBody.MaxTorque=Vector3.new(9e9,9e9,9e9); spinBody.Parent=root end; spinBody.AngularVelocity=Vector3.new(0,spinSpeed,0) end end end) end); notify("Spin ON") end
local function spinStop() spinEnabled=false; if spinConnection then spinConnection:Disconnect(); spinConnection=nil end; if spinBody then spinBody:Destroy(); spinBody=nil end; notify("Spin OFF") end

local flingEnabled, flingPower = false, 200; local flingConnection = nil
local function doFling() pcall(function() local char=LocalPlayer.Character; if char then local root=char:FindFirstChild("HumanoidRootPart"); if root then root.Velocity=Vector3.new(math.random(-flingPower,flingPower),flingPower,math.random(-flingPower,flingPower)) end end end) end
local function flingStart() if flingConnection then flingConnection:Disconnect() end; flingConnection=RunService.Heartbeat:Connect(function() if not flingEnabled then return end; doFling() end); notify("Fling ON") end
local function flingStop() flingEnabled=false; if flingConnection then flingConnection:Disconnect(); flingConnection=nil end; notify("Fling OFF") end

local aimbotEnabled, aimbotFov, aimbotSmooth, aimbotWallCheck = false, 200, 5, true; local aimbotConnection, aimbotCircle = nil, nil
local function aimbotCleanup() if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection=nil end; if aimbotCircle then aimbotCircle:Destroy(); aimbotCircle=nil end end
local function aimbotUpdateCircle() if not aimbotCircle then return end; local cam=Workspace.CurrentCamera; if not cam then return end; local size=cam.ViewportSize; aimbotCircle.Size=UDim2.new(0,aimbotFov*2,0,aimbotFov*2); aimbotCircle.Position=UDim2.new(0,size.X/2-aimbotFov,0,size.Y/2-aimbotFov) end
local function isVisible(part) if not aimbotWallCheck then return true end; local cam=Workspace.CurrentCamera; if not cam then return true end; local origin=cam.CFrame.Position; local dir=(part.Position-origin); local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Blacklist; local char=LocalPlayer.Character; rp.FilterDescendantsInstances=char and {char} or {}; local result=Workspace:Raycast(origin,dir.Unit*dir.Magnitude,rp); if result and result.Instance then return result.Instance:IsDescendantOf(part.Parent) end; return true end
local function aimbotGetTarget() local cam=Workspace.CurrentCamera; if not cam then return nil end; local size=cam.ViewportSize; local center=Vector2.new(size.X/2,size.Y/2); local best,bestDist=nil,aimbotFov; for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then local head=p.Character:FindFirstChild("Head"); local hum=p.Character:FindFirstChild("Humanoid"); if head and hum and hum.Health>0 then if aimbotWallCheck and not isVisible(head) then continue end; local sp,onScreen=cam:WorldToViewportPoint(head.Position); if not onScreen then continue end; local dist=(Vector2.new(sp.X,sp.Y)-center).Magnitude; if dist<bestDist then bestDist=dist; best=head end end end end; return best end
local function aimbotStart() aimbotCleanup(); aimbotCircle=Instance.new("Frame"); aimbotCircle.BackgroundTransparency=1; aimbotCircle.ZIndex=999; aimbotCircle.Parent=gui; local stroke=Instance.new("UIStroke"); stroke.Color=Color3.fromRGB(255,255,255); stroke.Thickness=1; stroke.Transparency=0.5; stroke.Parent=aimbotCircle; local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(1,0); corner.Parent=aimbotCircle; aimbotUpdateCircle(); local cam=Workspace.CurrentCamera; if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(aimbotUpdateCircle) end; aimbotConnection=RunService.Heartbeat:Connect(function() if not aimbotEnabled then return end; if not UserInputService:IsMouseButtonPressed(1) then return end; local head=aimbotGetTarget(); if head then local cam=Workspace.CurrentCamera; if cam then cam.CFrame=cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position,head.Position),aimbotSmooth/100) end end end); notify("Aimbot ON") end
local function aimbotStop() aimbotCleanup(); notify("Aimbot OFF") end

local espEnabled, espColor = false, Color3.fromRGB(255,255,255); local espHighlights = {}
local function espCleanup() for _,h in pairs(espHighlights) do pcall(function() h:Destroy() end) end; espHighlights={} end
local function espUpdateColors() for _,h in pairs(espHighlights) do if h and h.Parent then h.FillColor=espColor; h.OutlineColor=espColor end end end
local function espAddHighlight(part) if not part:IsA("BasePart") then return end; local h=Instance.new("Highlight"); h.FillColor=espColor; h.FillTransparency=0.8; h.OutlineColor=espColor; h.OutlineTransparency=0; h.Adornee=part; h.Parent=part; table.insert(espHighlights,h) end
local function espAddPlayer(player) local function onChar(char) for _,p in pairs(char:GetDescendants()) do espAddHighlight(p) end; char.DescendantAdded:Connect(function(p) espAddHighlight(p) end) end; if player.Character then onChar(player.Character) end; player.CharacterAdded:Connect(onChar) end
local function espStart() espCleanup(); for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then espAddPlayer(p) end end; Players.PlayerAdded:Connect(function(p) if espEnabled then espAddPlayer(p) end end); notify("ESP ON") end
local function espStop() espCleanup(); notify("ESP OFF") end

local mm2espEnabled=false; local mm2espObjects={}; local mm2espUpdate=nil; local playerRoles={}
local function detectMM2Role(player) local char=player.Character; if not char then return playerRoles[player] or "Innocent" end; local foundRole=nil; for _,t in pairs(char:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("knife") or t.Name:lower():find("blade")) then foundRole="Murderer" break end end; if not foundRole then local bp=player:FindFirstChild("Backpack"); if bp then for _,t in pairs(bp:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("knife") or t.Name:lower():find("blade")) then foundRole="Murderer" break end end end end; if not foundRole then for _,t in pairs(char:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("sheriff") then foundRole="Sheriff" break end end end; if not foundRole then for _,t in pairs(char:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("gun") or t.Name:lower():find("pistol")) then foundRole="Hero" break end end end; if foundRole then playerRoles[player]=foundRole; return foundRole end; return playerRoles[player] or "Innocent" end
local function getRoleColor(role) if role=="Murderer" then return Color3.fromRGB(255,0,0) elseif role=="Sheriff" then return Color3.fromRGB(0,100,255) elseif role=="Hero" then return Color3.fromRGB(255,255,0) else return Color3.fromRGB(0,255,0) end end
local function mm2espCleanup() for _,d in pairs(mm2espObjects) do for _,h in pairs(d.Highlights) do pcall(function() h:Destroy() end) end end; mm2espObjects={}; if mm2espUpdate then mm2espUpdate:Disconnect(); mm2espUpdate=nil end; playerRoles={} end
local function mm2espAdd(player) local data={Player=player,Highlights={}}; local function addH(part,col) if not part:IsA("BasePart") then return end; local h=Instance.new("Highlight"); h.FillColor=col; h.FillTransparency=0.7; h.OutlineColor=col; h.OutlineTransparency=0; h.Adornee=part; h.Parent=part; table.insert(data.Highlights,h) end; local function updateAll() local col=getRoleColor(detectMM2Role(player)); for _,h in pairs(data.Highlights) do if h and h.Parent then h.FillColor=col; h.OutlineColor=col end end end; local function onChar(char) local col=getRoleColor(detectMM2Role(player)); for _,p in pairs(char:GetDescendants()) do addH(p,col) end; char.DescendantAdded:Connect(function(p) addH(p,getRoleColor(detectMM2Role(player))); updateAll() end) end; if player.Character then onChar(player.Character) end; player.CharacterAdded:Connect(onChar); table.insert(mm2espObjects,data) end
local function mm2espUpdateColors() for _,d in pairs(mm2espObjects) do local col=getRoleColor(detectMM2Role(d.Player)); for _,h in pairs(d.Highlights) do if h and h.Parent then h.FillColor=col; h.OutlineColor=col end end end end
local function mm2espStart() mm2espCleanup(); for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then mm2espAdd(p) end end; Players.PlayerAdded:Connect(function(p) if mm2espEnabled then mm2espAdd(p) end end); mm2espUpdate=RunService.Heartbeat:Connect(function() if not mm2espEnabled then return end; pcall(mm2espUpdateColors) end); notify("MM2 ESP ON") end
local function mm2espStop() mm2espCleanup(); notify("MM2 ESP OFF") end

local silentAimEnabled=false; local silentAimConnection=nil
local function getMurderer() for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then for _,t in pairs(p.Character:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("knife") or t.Name:lower():find("blade")) then return p end end end end; return nil end
local function silentAimStart() if silentAimConnection then silentAimConnection:Disconnect() end; silentAimConnection=RunService.Heartbeat:Connect(function() if not silentAimEnabled then return end; local murderer=getMurderer(); if murderer and murderer.Character then local head=murderer.Character:FindFirstChild("Head"); local char=LocalPlayer.Character; if head and char then local tool=char:FindFirstChildOfClass("Tool"); if tool and (tool.Name:lower():find("gun") or tool.Name:lower():find("pistol")) then local cam=Workspace.CurrentCamera; if cam then cam.CFrame=CFrame.new(cam.CFrame.Position,head.Position) end end end end end); notify("Silent Aim ON") end
local function silentAimStop() silentAimEnabled=false; if silentAimConnection then silentAimConnection:Disconnect(); silentAimConnection=nil end; notify("Silent Aim OFF") end

local autoThrowEnabled=false; local autoThrowConnection=nil
local function getNearestVisiblePlayer() local char=LocalPlayer.Character; if not char then return nil end; local root=char:FindFirstChild("HumanoidRootPart"); if not root then return nil end; local nearest,nearestDist=nil,100; for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then local targetRoot=p.Character:FindFirstChild("HumanoidRootPart"); local hum=p.Character:FindFirstChild("Humanoid"); if targetRoot and hum and hum.Health>0 then local dist=(targetRoot.Position-root.Position).Magnitude; if dist<nearestDist then local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Blacklist; rp.FilterDescendantsInstances={char}; local result=Workspace:Raycast(root.Position,(targetRoot.Position-root.Position).Unit*dist,rp); if not result then nearestDist=dist; nearest=p end end end end end; return nearest end
local function autoThrowStart() if autoThrowConnection then autoThrowConnection:Disconnect() end; autoThrowConnection=RunService.Heartbeat:Connect(function() if not autoThrowEnabled then return end; pcall(function() local char=LocalPlayer.Character; if char then local tool=char:FindFirstChildOfClass("Tool"); if tool and (tool.Name:lower():find("knife") or tool.Name:lower():find("blade")) then local target=getNearestVisiblePlayer(); if target and target.Character then local root=target.Character:FindFirstChild("HumanoidRootPart"); if root then local cam=Workspace.CurrentCamera; if cam then cam.CFrame=CFrame.new(cam.CFrame.Position,root.Position) end; if (char.HumanoidRootPart.Position-root.Position).Magnitude<50 then tool:Activate() end end end end end end) end); notify("Auto Throw ON") end
local function autoThrowStop() autoThrowEnabled=false; if autoThrowConnection then autoThrowConnection:Disconnect(); autoThrowConnection=nil end; notify("Auto Throw OFF") end

local function flingMurderer() local murderer=getMurderer(); if murderer and murderer.Character then local root=murderer.Character:FindFirstChild("HumanoidRootPart"); if root then root.Velocity=Vector3.new(math.random(-500,500),800,math.random(-500,500)); notify("Murderer flung!") end else notify("Murderer not found!") end end
local function flingSheriff() local sheriff=nil; for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then for _,t in pairs(p.Character:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("sheriff") then sheriff=p break end end end end; if sheriff and sheriff.Character then local root=sheriff.Character:FindFirstChild("HumanoidRootPart"); if root then root.Velocity=Vector3.new(math.random(-500,500),800,math.random(-500,500)); notify("Sheriff flung!") end else notify("Sheriff not found!") end end

local coinFarmEnabled=false; local coinFarmConnection=nil
local function collectCoins() pcall(function() local char=LocalPlayer.Character; if char then for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("gem")) then v.CFrame=char.HumanoidRootPart.CFrame end end end end) end
local function coinFarmStart() if coinFarmConnection then coinFarmConnection:Disconnect() end; coinFarmConnection=RunService.Heartbeat:Connect(function() if not coinFarmEnabled then return end; collectCoins() end); notify("Coin Farm ON") end
local function coinFarmStop() coinFarmEnabled=false; if coinFarmConnection then coinFarmConnection:Disconnect(); coinFarmConnection=nil end; notify("Coin Farm OFF") end

local function quickChat(msg) pcall(function() local ts=game:GetService("TextChatService"); if ts.TextChannels then local ch=ts.TextChannels.RBXGeneral; if ch then ch:SendAsync(msg) end end end); pcall(function() local dc=ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents"); if dc then local sm=dc:FindFirstChild("SayMessageRequest"); if sm then sm:FireServer(msg,"All") end end end) end

local nametagEnabled = false; local nametagBill = nil; local nametagConnection = nil
local function markAsNDUser() pcall(function() local char=LocalPlayer.Character; if char then local folder=char:FindFirstChild("ND_Marker") or Instance.new("Folder"); folder.Name="ND_Marker"; folder.Parent=char end end) end
local function isNDUser(player) if player==LocalPlayer then return true end; pcall(function() if player.Character and player.Character:FindFirstChild("ND_Marker") then return true end end); return false end
local function createNametag()
    if nametagBill then nametagBill:Destroy() end
    pcall(function()
        local char=LocalPlayer.Character; if char then local head=char:FindFirstChild("Head"); if head then
            nametagBill=Instance.new("BillboardGui"); nametagBill.Size=UDim2.new(0,220,0,55); nametagBill.StudsOffset=Vector3.new(0,3.2,0); nametagBill.AlwaysOnTop=true; nametagBill.Parent=head
            local bg=Instance.new("Frame"); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(0,0,0); bg.BackgroundTransparency=0.55; bg.BorderSizePixel=0; bg.Parent=nametagBill
            local bgCorner=Instance.new("UICorner"); bgCorner.CornerRadius=UDim.new(0,8); bgCorner.Parent=bg
            local bgStroke=Instance.new("UIStroke"); bgStroke.Color=currentTheme.NametagAccent; bgStroke.Thickness=1.5; bgStroke.Parent=bg
            local icon=Instance.new("ImageLabel"); icon.Size=UDim2.new(0,20,0,20); icon.Position=UDim2.new(0,8,0,6); icon.BackgroundTransparency=1; icon.Image="rbxassetid://14473753935"; icon.Parent=bg
            local name=Instance.new("TextLabel"); name.Size=UDim2.new(1,-80,0,22); name.Position=UDim2.new(0,32,0,5); name.BackgroundTransparency=1; name.Text=LocalPlayer.DisplayName; name.TextColor3=currentTheme.NametagName; name.TextSize=15; name.Font=Enum.Font.SourceSansBold; name.TextXAlignment=Enum.TextXAlignment.Left; name.Parent=bg
            local verified=Instance.new("ImageLabel"); verified.Size=UDim2.new(0,18,0,18); verified.Position=UDim2.new(0,name.Position.X.Offset+name.TextBounds.X+4,0,7); verified.BackgroundTransparency=1; verified.Image="rbxassetid://14473753935"; verified.Parent=bg
            name:GetPropertyChangedSignal("TextBounds"):Connect(function() verified.Position=UDim2.new(0,name.Position.X.Offset+name.TextBounds.X+4,0,7) end)
            local badge=Instance.new("Frame"); badge.Size=UDim2.new(0,70,0,16); badge.Position=UDim2.new(1,-78,0,6); badge.BackgroundColor3=Color3.fromRGB(255,180,30); badge.BackgroundTransparency=0.2; badge.BorderSizePixel=0; badge.Parent=bg
            local badgeCorner=Instance.new("UICorner"); badgeCorner.CornerRadius=UDim.new(0,8); badgeCorner.Parent=badge
            local badgeStroke=Instance.new("UIStroke"); badgeStroke.Color=Color3.fromRGB(255,200,50); badgeStroke.Thickness=1; badgeStroke.Parent=badge
            local badgeText=Instance.new("TextLabel"); badgeText.Size=UDim2.new(1,0,1,0); badgeText.BackgroundTransparency=1; badgeText.Text="CREATOR"; badgeText.TextColor3=Color3.fromRGB(0,0,0); badgeText.TextSize=9; badgeText.Font=Enum.Font.SourceSansBold; badgeText.Parent=badge
            local tag=Instance.new("TextLabel"); tag.Size=UDim2.new(1,-10,0,14); tag.Position=UDim2.new(0,5,0,30); tag.BackgroundTransparency=1; tag.Text="ND || HUB USER"; tag.TextColor3=currentTheme.NametagAccent; tag.TextSize=9; tag.Font=Enum.Font.SourceSansBold; tag.TextXAlignment=Enum.TextXAlignment.Center; tag.Parent=bg
        end end
    end)
end
local function highlightOtherNDUsers() for _,player in pairs(Players:GetPlayers()) do if player~=LocalPlayer and isNDUser(player) and player.Character then local head=player.Character:FindFirstChild("Head"); if head and not head:FindFirstChild("ND_FriendTag") then local bill=Instance.new("BillboardGui"); bill.Name="ND_FriendTag"; bill.Size=UDim2.new(0,130,0,24); bill.StudsOffset=Vector3.new(0,2.5,0); bill.AlwaysOnTop=true; bill.Parent=head; local bg=Instance.new("Frame"); bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(0,0,0); bg.BackgroundTransparency=0.5; bg.BorderSizePixel=0; bg.Parent=bill; local bgc=Instance.new("UICorner"); bgc.CornerRadius=UDim.new(0,4); bgc.Parent=bg; local bgs=Instance.new("UIStroke"); bgs.Color=currentTheme.NametagAccent; bgs.Thickness=1; bgs.Parent=bg; local txt=Instance.new("TextLabel"); txt.Size=UDim2.new(1,0,1,0); txt.BackgroundTransparency=1; txt.Text="⚡ ND USER"; txt.TextColor3=currentTheme.NametagAccent; txt.TextSize=10; txt.Font=Enum.Font.SourceSansBold; txt.Parent=bg end end end end
local function startNametag() nametagEnabled=true; markAsNDUser(); createNametag(); if nametagConnection then nametagConnection:Disconnect() end; nametagConnection=RunService.Heartbeat:Connect(function() if not nametagEnabled then return end; markAsNDUser(); highlightOtherNDUsers() end); LocalPlayer.CharacterAdded:Connect(function() if nametagEnabled then task.wait(0.3); markAsNDUser(); createNametag() end end); notify("Nametag ON") end
local function stopNametag() nametagEnabled=false; if nametagBill then nametagBill:Destroy(); nametagBill=nil end; if nametagConnection then nametagConnection:Disconnect(); nametagConnection=nil end; notify("Nametag OFF") end

function shutdown()
    flyEnabled=false; speedEnabled=false; spinEnabled=false; flingEnabled=false; aimbotEnabled=false; espEnabled=false
    mm2espEnabled=false; silentAimEnabled=false; autoThrowEnabled=false; coinFarmEnabled=false; nametagEnabled=false
    smoothVel=Vector3.zero; flyCleanup(); speedStop(); spinStop(); flingStop(); aimbotCleanup(); espCleanup()
    mm2espCleanup(); silentAimStop(); autoThrowStop(); coinFarmStop(); stopNametag()
    pcall(function() local char=LocalPlayer.Character; if char then local hum=char:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed=16 end end end)
end

if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then if guiVisible then hideGUI() else showGUI() end end
    end)
end

-- ==================== BUILD UI ====================
local y = 5
addSection(scrollers[1], "FLIGHT", y); y=y+lblH+6
addToggle(scrollers[1], "Fly", y, function(s) flyEnabled=s; if s then flyStart() else flyStop() end end); y=y+btnH+gap
addSlider(scrollers[1], "Fly Speed", 10, 1000, 50, y, function(v) flySpeed=v end); y=y+28+gap
addSection(scrollers[1], "SPEED", y); y=y+lblH+6
addToggle(scrollers[1], "Speed Boost", y, function(s) speedEnabled=s; if s then speedStart() else speedStop() end end); y=y+btnH+gap
addSlider(scrollers[1], "Walk Speed", 16, 1000, 50, y, function(v) speedVal=v; if speedEnabled then pcall(function() local char=LocalPlayer.Character; if char then local hum=char:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed=v end end end) end end); y=y+28+15; scrollers[1].CanvasSize=UDim2.new(0,0,0,y)

y=5; addSection(scrollers[2], "AIMBOT", y); y=y+lblH+6
addToggle(scrollers[2], "Aimbot", y, function(s) aimbotEnabled=s; if s then aimbotStart() else aimbotStop() end end); y=y+btnH+gap
addSlider(scrollers[2], "FOV", 50, 360, 200, y, function(v) aimbotFov=v; aimbotUpdateCircle() end); y=y+28+gap
addSlider(scrollers[2], "Smoothness", 1, 30, 5, y, function(v) aimbotSmooth=v end); y=y+28+gap
addToggle(scrollers[2], "Wall Check", y, function(s) aimbotWallCheck=s end); y=y+btnH+15; scrollers[2].CanvasSize=UDim2.new(0,0,0,y)

y=5; addSection(scrollers[3], "PLAYER ESP", y); y=y+lblH+6
addToggle(scrollers[3], "ESP", y, function(s) espEnabled=s; if s then espStart() else espStop() end end); y=y+btnH+gap
addSection(scrollers[3], "ESP COLOR", y); y=y+lblH+6
local espColors={{"White",Color3.fromRGB(255,255,255)},{"Red",Color3.fromRGB(255,80,80)},{"Blue",Color3.fromRGB(80,140,255)},{"Green",Color3.fromRGB(80,255,120)},{"Purple",Color3.fromRGB(180,80,255)},{"Yellow",Color3.fromRGB(255,255,80)}}
for idx,cd in pairs(espColors) do local cb=Instance.new("TextButton"); cb.Size=UDim2.new(0.3,-5,0,btnH); cb.Position=UDim2.new(0.02+((idx-1)%3)*0.33,0,0,y+math.floor((idx-1)/3)*(btnH+gap)); cb.BackgroundColor3=cd[2]==espColor and cd[2] or currentTheme.Button; cb.BorderSizePixel=0; cb.Text=cd[1]; cb.TextColor3=cd[2]==espColor and Color3.fromRGB(0,0,0) or cd[2]; cb.TextSize=smallTxt; cb.Font=Enum.Font.SourceSansBold; cb.AutoButtonColor=false; cb.Active=true; cb.Selectable=true; cb.Parent=scrollers[3]; local cbc=Instance.new("UICorner"); cbc.CornerRadius=UDim.new(0,4); cbc.Parent=cb; cb.MouseButton1Click:Connect(function() espColor=cd[2]; espUpdateColors(); for _,b in pairs(scrollers[3]:GetChildren()) do if b:IsA("TextButton") then for _,ec in pairs(espColors) do if b.Text==ec[1] then b.BackgroundColor3=currentTheme.Button; b.TextColor3=ec[2] end end end end; cb.BackgroundColor3=cd[2]; cb.TextColor3=Color3.fromRGB(0,0,0) end) end
y=y+btnH*2+gap*2+15; scrollers[3].CanvasSize=UDim2.new(0,0,0,y)

y=5; addSection(scrollers[4], "MM2 ESP", y); y=y+lblH+6
addToggle(scrollers[4], "MM2 ESP", y, function(s) mm2espEnabled=s; if s then mm2espStart() else mm2espStop() end end); y=y+btnH+gap
addSection(scrollers[4], "SILENT AIM", y); y=y+lblH+6
addToggle(scrollers[4], "Silent Aim (Sheriff)", y, function(s) silentAimEnabled=s; if s then silentAimStart() else silentAimStop() end end); y=y+btnH+gap
addToggle(scrollers[4], "Auto Throw (Murderer)", y, function(s) autoThrowEnabled=s; if s then autoThrowStart() else autoThrowStop() end end); y=y+btnH+gap
addSection(scrollers[4], "FLING", y); y=y+lblH+6
addButton(scrollers[4], "Fling Murderer", y, flingMurderer); y=y+btnH+gap
addButton(scrollers[4], "Fling Sheriff", y, flingSheriff); y=y+btnH+gap
addSection(scrollers[4], "FARM", y); y=y+lblH+6
addToggle(scrollers[4], "Auto Coin Farm", y, function(s) coinFarmEnabled=s; if s then coinFarmStart() else coinFarmStop() end end); y=y+btnH+gap
addSection(scrollers[4], "CHAT", y); y=y+lblH+6
addButton(scrollers[4], "GG", y, function() quickChat("GG") end); y=y+btnH+gap
addButton(scrollers[4], "GGS", y, function() quickChat("GGS") end); y=y+btnH+gap
addButton(scrollers[4], "Good Luck!", y, function() quickChat("Good Luck!") end); y=y+btnH+15; scrollers[4].CanvasSize=UDim2.new(0,0,0,y)

y=5; addSection(scrollers[5], "SPIN", y); y=y+lblH+6
addToggle(scrollers[5], "Spin", y, function(s) spinEnabled=s; if s then spinStart() else spinStop() end end); y=y+btnH+gap
addSlider(scrollers[5], "Spin Speed", 5, 200, 30, y, function(v) spinSpeed=v end); y=y+28+gap
addSection(scrollers[5], "FLING", y); y=y+lblH+6
addToggle(scrollers[5], "Fling", y, function(s) flingEnabled=s; if s then flingStart() else flingStop() end end); y=y+btnH+gap
addSlider(scrollers[5], "Fling Power", 50, 1000, 200, y, function(v) flingPower=v end); y=y+28+gap
addSection(scrollers[5], "NAMETAG", y); y=y+lblH+6
addToggle(scrollers[5], "Nametag", y, function(s) if s then startNametag() else stopNametag() end end); y=y+btnH+15; scrollers[5].CanvasSize=UDim2.new(0,0,0,y)

y=5; addSection(scrollers[6], "THEME", y); y=y+lblH+6
for name,_ in pairs(themes) do addButton(scrollers[6], name, y, function() settings.theme=name; currentTheme=themes[name]; main.BackgroundColor3=currentTheme.Main; ms.Color=currentTheme.Accent; topBar.BackgroundColor3=currentTheme.TopBar; tbc.BackgroundColor3=currentTheme.TopBar; title.TextColor3=currentTheme.Accent2; closeBtn.TextColor3=currentTheme.Accent2; for _,b in pairs(menuTabBtns) do b.TextColor3=currentTheme.Text; local bs=b:FindFirstChildOfClass("UIStroke"); if bs then bs.Color=currentTheme.Accent end end; if nametagBill then createNametag() end; notify("Theme: "..name) end); y=y+btnH+gap end
addSection(scrollers[6], "GUI SIZE", y); y=y+lblH+6
addButton(scrollers[6], "Small", y, function() settings.guiSize=1; guiMul=0.85; main.Size=UDim2.new(0,math.floor((isMobile and 370 or 360)*0.85),0,math.floor((isMobile and 540 or 510)*0.85)); notify("GUI: Small") end); y=y+btnH+gap
addButton(scrollers[6], "Medium", y, function() settings.guiSize=2; guiMul=1; main.Size=UDim2.new(0,isMobile and 370 or 360,0,isMobile and 540 or 510); notify("GUI: Medium") end); y=y+btnH+gap
addButton(scrollers[6], "Large", y, function() settings.guiSize=3; guiMul=1.2; main.Size=UDim2.new(0,math.floor((isMobile and 370 or 360)*1.2),0,math.floor((isMobile and 540 or 510)*1.2)); notify("GUI: Large") end); y=y+btnH+gap
addSection(scrollers[6], "INFO", y); y=y+lblH+6
local info=Instance.new("TextLabel"); info.Size=UDim2.new(1,-16,0,60); info.Position=UDim2.new(0,8,0,y); info.BackgroundTransparency=1; info.Text="ND || HUB v2.0.1\nby N3ST_Dev\n\ndiscord.gg/8ycCx8PQb"; info.TextColor3=currentTheme.Text; info.TextSize=smallTxt; info.Font=Enum.Font.SourceSansBold; info.TextXAlignment=Enum.TextXAlignment.Left; info.TextWrapped=true; info.Parent=scrollers[6]; y=y+70; scrollers[6].CanvasSize=UDim2.new(0,0,0,y)

notify("ND || HUB v2.0.1 ready!"        WindUI:Notify({
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
