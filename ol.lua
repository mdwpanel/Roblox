-- Script taken from https://xenoscripts.com website --

-- ============================================================
--  kAaMs Hub  |  LocalScript → StarterPlayerScripts
--  Requires FlingHandler Script in ServerScriptService
--  Updated: Added Blink Dash, Auto-Dodge, Punch Force,
--           Name Tag Changer, Server Stats Panel
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting         = game:GetService("Lighting")

local ME = Players.LocalPlayer
local function getChar() return ME.Character end
local function getHRP()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- ── Palette ───────────────────────────────────────────────────────────
local C = {
    bg       = Color3.fromRGB(22,22,32),   sidebar  = Color3.fromRGB(15,15,22),
    card     = Color3.fromRGB(30,30,44),   border   = Color3.fromRGB(48,48,68),
    accent   = Color3.fromRGB(99,102,241), green    = Color3.fromRGB(34,197,94),
    orange   = Color3.fromRGB(234,88,12),  red      = Color3.fromRGB(210,50,50),
    yellow   = Color3.fromRGB(234,179,8),  text     = Color3.fromRGB(220,220,232),
    sub      = Color3.fromRGB(130,130,155),pill_off = Color3.fromRGB(50,50,72),
    row      = Color3.fromRGB(26,26,38),   row_sel  = Color3.fromRGB(40,38,72),
    teal     = Color3.fromRGB(20,184,166), pink     = Color3.fromRGB(236,72,153),
    purple   = Color3.fromRGB(168,85,247),
}

local TW = TweenInfo.new(0.14, Enum.EasingStyle.Quad)

local function mkCorner(p,r) local o=Instance.new("UICorner"); o.CornerRadius=UDim.new(0,r or 8); o.Parent=p end
local function mkStroke(p,col,th) local o=Instance.new("UIStroke"); o.Color=col or C.border; o.Thickness=th or 1; o.Parent=p end
local function mkFrame(p,props) local f=Instance.new("Frame"); f.BorderSizePixel=0; for k,v in pairs(props) do f[k]=v end; f.Parent=p; return f end
local function mkLabel(p,props) local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.TextXAlignment=Enum.TextXAlignment.Left; l.Font=Enum.Font.GothamBold; for k,v in pairs(props) do l[k]=v end; l.Parent=p; return l end
local function mkBtn(p,props) local b=Instance.new("TextButton"); b.BorderSizePixel=0; b.Font=Enum.Font.GothamBold; for k,v in pairs(props) do b[k]=v end; b.Parent=p; return b end

local old=ME.PlayerGui:FindFirstChild("kAaMsHub"); if old then old:Destroy() end

-- ══════════════════════════════════════════════════════════════════════
--  WINDOW
-- ══════════════════════════════════════════════════════════════════════
local SG=Instance.new("ScreenGui"); SG.Name="kAaMsHub"; SG.ResetOnSpawn=false
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=ME.PlayerGui

-- ══════════════════════════════════════════════════════════════════════
--  LOADING SCREEN  (3 seconds — compact centered card)
-- ══════════════════════════════════════════════════════════════════════
-- Dim backdrop
local LOAD_BG=mkFrame(SG,{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0.45})

-- Compact card  (280 × 160, dead-center)
local LOAD=mkFrame(SG,{Size=UDim2.new(0,280,0,160),Position=UDim2.new(0.5,-140,0.5,-80),
    BackgroundColor3=Color3.fromRGB(18,18,28)})
mkCorner(LOAD,12); mkStroke(LOAD,C.accent,1.2)

-- Icon + title row
mkLabel(LOAD,{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,16,0,16),
    Text="⚡",TextSize=22,TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Center})
mkLabel(LOAD,{Size=UDim2.new(1,-56,0,18),Position=UDim2.new(0,50,0,18),
    Text="kAaMs Hub",TextSize=15,TextColor3=C.text})
mkLabel(LOAD,{Size=UDim2.new(1,-56,0,14),Position=UDim2.new(0,50,0,37),
    Text="by kAaM",TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.sub})

-- Thin divider
mkFrame(LOAD,{Size=UDim2.new(1,-24,0,1),Position=UDim2.new(0,12,0,62),BackgroundColor3=C.border})

-- Status text
local loadStatus=mkLabel(LOAD,{Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,72),
    Text="Initializing...",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub})

-- Progress bar track
local barTrack=mkFrame(LOAD,{Size=UDim2.new(1,-24,0,5),Position=UDim2.new(0,12,0,94),
    BackgroundColor3=Color3.fromRGB(32,32,50)}); mkCorner(barTrack,3)
local barFill=mkFrame(barTrack,{Size=UDim2.new(0,0,1,0),BackgroundColor3=C.accent}); mkCorner(barFill,3)

-- Percent label (right-aligned inside bar area)
local pctLbl=mkLabel(LOAD,{Size=UDim2.new(1,-24,0,13),Position=UDim2.new(0,12,0,103),
    Text="0%",TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Right})

-- Version bottom-right corner
mkLabel(LOAD,{Size=UDim2.new(1,-12,0,12),Position=UDim2.new(0,0,1,-18),
    Text="v2.0  •  Multi-Target Fling",TextSize=9,Font=Enum.Font.Gotham,
    TextColor3=Color3.fromRGB(55,55,75),TextXAlignment=Enum.TextXAlignment.Center})

-- Run the 3-second loading sequence
local loadMessages={"Initializing...","Loading features...","Building UI...","Applying themes...","Almost ready..."}
local LOAD_TIME=3
task.spawn(function()
    local start=tick()
    local msgIdx=1
    while true do
        local elapsed=tick()-start
        local pct=math.clamp(elapsed/LOAD_TIME,0,1)
        TweenService:Create(barFill,TweenInfo.new(0.08),{Size=UDim2.new(pct,0,1,0)}):Play()
        pctLbl.Text=math.floor(pct*100).."%"
        local expectedMsg=math.clamp(math.ceil(pct*#loadMessages),1,#loadMessages)
        if expectedMsg~=msgIdx then
            msgIdx=expectedMsg
            loadStatus.Text=loadMessages[msgIdx]
        end
        if pct>=1 then break end
        task.wait(0.05)
    end
    task.wait(0.15)
    -- Fade out card + backdrop
    TweenService:Create(LOAD,TweenInfo.new(0.35,Enum.EasingStyle.Quad),{BackgroundTransparency=1}):Play()
    TweenService:Create(LOAD_BG,TweenInfo.new(0.35),{BackgroundTransparency=1}):Play()
    for _,d in ipairs(LOAD:GetDescendants()) do
        if d:IsA("TextLabel") then TweenService:Create(d,TweenInfo.new(0.25),{TextTransparency=1}):Play()
        elseif d:IsA("Frame") then TweenService:Create(d,TweenInfo.new(0.25),{BackgroundTransparency=1}):Play() end
    end
    task.wait(0.4)
    LOAD:Destroy(); LOAD_BG:Destroy()
    -- Pop the hub open automatically
    WIN.Visible=true
    WIN.Size=UDim2.new(0,548,0,436)
    WIN.Position=UDim2.new(0.5,-274,0.5,-218)
    TweenService:Create(WIN,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,580,0,460),Position=UDim2.new(0.5,-290,0.5,-230)}):Play()
end)

-- ══════════════════════════════════════════════════════════════════════
--  WINDOW  (hidden until loading screen finishes)
-- ══════════════════════════════════════════════════════════════════════
local WIN=mkFrame(SG,{Size=UDim2.new(0,580,0,460),Position=UDim2.new(0.5,-290,0.5,-230),
    BackgroundColor3=C.bg,Active=true,Draggable=true,Visible=false})
mkCorner(WIN,14); mkStroke(WIN,C.border,1.2)

-- ── KEYBIND HINT (bottom-right, always visible) ───────────────────────
do
    local hint = mkFrame(SG, {
        Size            = UDim2.new(0, 230, 0, 32),
        Position        = UDim2.new(1, -240, 1, -44),
        BackgroundColor3 = Color3.fromRGB(15, 15, 22),
        BackgroundTransparency = 0.25,
    })
    mkCorner(hint, 8)
    mkStroke(hint, C.border, 1)

    local badge = mkFrame(hint, {
        Size             = UDim2.new(0, 22, 0, 22),
        Position         = UDim2.new(0, 7, 0.5, -11),
        BackgroundColor3 = C.accent,
    })
    mkCorner(badge, 5)
    mkLabel(badge, {
        Size             = UDim2.new(1, 0, 1, 0),
        Text             = "5",
        TextSize         = 12,
        TextColor3       = Color3.new(1, 1, 1),
        TextXAlignment   = Enum.TextXAlignment.Center,
    })

    mkLabel(hint, {
        Size       = UDim2.new(1, -38, 1, 0),
        Position   = UDim2.new(0, 35, 0, 0),
        Text       = "Press  5  to show / hide the hub",
        TextSize   = 11,
        Font       = Enum.Font.Gotham,
        TextColor3 = C.sub,
    })

    task.delay(6, function()
        for i = 1, 20 do
            task.wait(0.05)
            hint.BackgroundTransparency = 0.25 + (i / 20) * 0.75
            for _, child in ipairs(hint:GetDescendants()) do
                if child:IsA("TextLabel") then
                    child.TextTransparency = i / 20
                elseif child:IsA("Frame") then
                    child.BackgroundTransparency = i / 20
                elseif child:IsA("UIStroke") then
                    child.Transparency = i / 20
                end
            end
        end
        hint:Destroy()
    end)
end

local SB=mkFrame(WIN,{Size=UDim2.new(0,148,1,0),BackgroundColor3=C.sidebar})
mkCorner(SB,14)
mkFrame(SB,{Size=UDim2.new(0,14,1,0),Position=UDim2.new(1,-14,0,0),BackgroundColor3=C.sidebar})
mkLabel(SB,{Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,12),Text="⚡",TextSize=24,TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Center})
mkLabel(SB,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,44),Text="kAaMs hub",TextSize=12,TextColor3=C.text,TextXAlignment=Enum.TextXAlignment.Center})
mkFrame(SB,{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,0,68),BackgroundColor3=C.border})

local TAB_LIST=mkFrame(SB,{Size=UDim2.new(1,0,1,-80),Position=UDim2.new(0,0,0,76),BackgroundTransparency=1})
do
    local ul=Instance.new("UIListLayout"); ul.SortOrder=Enum.SortOrder.LayoutOrder; ul.Padding=UDim.new(0,4); ul.Parent=TAB_LIST
    local up=Instance.new("UIPadding"); up.PaddingLeft=UDim.new(0,8); up.PaddingRight=UDim.new(0,8); up.PaddingTop=UDim.new(0,4); up.Parent=TAB_LIST
end
mkLabel(SB,{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,1,-22),Text="[ 5 ]  Toggle",TextSize=10,TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Center})

local CONTENT=mkFrame(WIN,{Size=UDim2.new(1,-156,1,-8),Position=UDim2.new(0,152,0,4),BackgroundTransparency=1})
local PAGE_TITLE=mkLabel(CONTENT,{Size=UDim2.new(1,-44,0,44),Text="Movement",TextSize=16,TextColor3=C.text})
local CLOSE=mkBtn(CONTENT,{Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,-30,0,9),BackgroundColor3=C.red,Text="✕",TextColor3=C.text,TextSize=12})
mkCorner(CLOSE,6); CLOSE.MouseButton1Click:Connect(function() WIN.Visible=false end)

local SCROLL=Instance.new("ScrollingFrame")
SCROLL.Size=UDim2.new(1,0,1,-48); SCROLL.Position=UDim2.new(0,0,0,48)
SCROLL.BackgroundTransparency=1; SCROLL.BorderSizePixel=0
SCROLL.ScrollBarThickness=3; SCROLL.ScrollBarImageColor3=C.accent
SCROLL.CanvasSize=UDim2.new(0,0,0,0); SCROLL.AutomaticCanvasSize=Enum.AutomaticSize.Y
SCROLL.Parent=CONTENT
do
    local ul=Instance.new("UIListLayout"); ul.SortOrder=Enum.SortOrder.LayoutOrder; ul.Padding=UDim.new(0,8); ul.Parent=SCROLL
    local up=Instance.new("UIPadding"); up.PaddingLeft=UDim.new(0,4); up.PaddingRight=UDim.new(0,10); up.PaddingTop=UDim.new(0,4); up.Parent=SCROLL
end

-- ══════════════════════════════════════════════════════════════════════
--  TAB SYSTEM
-- ══════════════════════════════════════════════════════════════════════
local tabData={}; local tabCount=0
local function makeTab(icon,name)
    tabCount+=1; local order=tabCount
    local btn=mkBtn(TAB_LIST,{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.sidebar,Text="",LayoutOrder=order}); mkCorner(btn,8)
    local ic=mkLabel(btn,{Size=UDim2.new(0,22,1,0),Position=UDim2.new(0,8,0,0),Text=icon,TextSize=13,TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Center})
    local lb=mkLabel(btn,{Size=UDim2.new(1,-34,1,0),Position=UDim2.new(0,32,0,0),Text=name,TextSize=11,TextColor3=C.sub})
    local bar=mkFrame(btn,{Size=UDim2.new(0,3,0.6,0),Position=UDim2.new(0,0,0.2,0),BackgroundColor3=C.accent,Visible=false}); mkCorner(bar,2)
    local page=mkFrame(SCROLL,{Name=name.."Page",Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Visible=false,LayoutOrder=order})
    do local ul=Instance.new("UIListLayout"); ul.SortOrder=Enum.SortOrder.LayoutOrder; ul.Padding=UDim.new(0,8); ul.Parent=page end
    tabData[name]={btn=btn,ic=ic,lb=lb,bar=bar,page=page}
    local function activate()
        for _,d in pairs(tabData) do d.page.Visible=false; d.bar.Visible=false; d.btn.BackgroundColor3=C.sidebar; d.ic.TextColor3=C.sub; d.lb.TextColor3=C.sub end
        page.Visible=true; bar.Visible=true; btn.BackgroundColor3=Color3.fromRGB(28,28,42)
        ic.TextColor3=C.accent; lb.TextColor3=C.text; PAGE_TITLE.Text=name; SCROLL.CanvasPosition=Vector2.zero
    end
    btn.MouseButton1Click:Connect(activate)
    if order==1 then activate() end
    return page
end

-- ══════════════════════════════════════════════════════════════════════
--  ELEMENT FACTORIES
-- ══════════════════════════════════════════════════════════════════════
local elemOrd=0
local function card(page,h)
    elemOrd+=1
    local f=mkFrame(page,{Size=UDim2.new(1,0,0,h),BackgroundColor3=C.card,LayoutOrder=elemOrd})
    mkCorner(f,10); mkStroke(f,C.border); return f
end

local function makeToggle(page,name,sub,cb)
    local f=card(page,56)
    mkLabel(f,{Size=UDim2.new(1,-70,0,20),Position=UDim2.new(0,14,0,10),Text=name,TextSize=13,TextColor3=C.text})
    mkLabel(f,{Size=UDim2.new(1,-70,0,16),Position=UDim2.new(0,14,0,30),Text=sub,TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub})
    local pill=mkBtn(f,{Size=UDim2.new(0,44,0,24),Position=UDim2.new(1,-58,0.5,-12),BackgroundColor3=C.pill_off,Text=""}); mkCorner(pill,12)
    local knob=mkFrame(pill,{Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.new(1,1,1)}); mkCorner(knob,9)
    local on=false
    pill.MouseButton1Click:Connect(function()
        on=not on
        TweenService:Create(pill,TW,{BackgroundColor3=on and C.accent or C.pill_off}):Play()
        TweenService:Create(knob,TW,{Position=on and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}):Play()
        cb(on)
    end)
end

local function makeSlider(page,name,mn,mx,def,cb)
    local f=card(page,64)
    mkLabel(f,{Size=UDim2.new(1,-70,0,18),Position=UDim2.new(0,14,0,10),Text=name,TextSize=13,TextColor3=C.text})
    local vl=mkLabel(f,{Size=UDim2.new(0,52,0,18),Position=UDim2.new(1,-62,0,10),Text=tostring(def),TextSize=13,TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Right})
    local track=mkFrame(f,{Size=UDim2.new(1,-28,0,6),Position=UDim2.new(0,14,0,42),BackgroundColor3=C.pill_off}); mkCorner(track,3)
    local fill=mkFrame(track,{Size=UDim2.new((def-mn)/(mx-mn),0,1,0),BackgroundColor3=C.accent}); mkCorner(fill,3)
    local sk=mkBtn(track,{Size=UDim2.new(0,16,0,16),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new((def-mn)/(mx-mn),0,0.5,0),BackgroundColor3=Color3.new(1,1,1),Text="",ZIndex=5}); mkCorner(sk,8)
    local drag=false
    sk.MouseButton1Down:Connect(function() drag=true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag or i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local r=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local v=math.floor(mn+r*(mx-mn)); fill.Size=UDim2.new(r,0,1,0); sk.Position=UDim2.new(r,0,0.5,0); vl.Text=tostring(v); cb(v)
    end)
end

local function makeButton(page,label,color,cb)
    local f=card(page,48); mkStroke(f,color,1)
    local b=mkBtn(f,{Size=UDim2.new(1,-20,0,32),Position=UDim2.new(0,10,0.5,-16),BackgroundColor3=color,Text=label,TextColor3=Color3.new(1,1,1),TextSize=13}); mkCorner(b,8)
    b.MouseButton1Click:Connect(function()
        cb()
        TweenService:Create(b,TW,{BackgroundColor3=C.green}):Play()
        task.delay(0.4,function() TweenService:Create(b,TW,{BackgroundColor3=color}):Play() end)
    end)
    return b
end

-- ── TEXT INPUT FACTORY ─────────────────────────────────────────────────
local function makeInput(page, label, placeholder, cb)
    local f = card(page, 72)
    mkLabel(f, {Size=UDim2.new(1,-70,0,18), Position=UDim2.new(0,14,0,8), Text=label, TextSize=13, TextColor3=C.text})
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1,-28,0,28)
    box.Position = UDim2.new(0,14,0,34)
    box.BackgroundColor3 = C.pill_off
    box.BorderSizePixel = 0
    box.TextColor3 = C.text
    box.PlaceholderColor3 = C.sub
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextSize = 12
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = f
    mkCorner(box, 6)
    box.FocusLost:Connect(function()
        cb(box.Text)
    end)
    return box
end

local function makePlayerList(parent,height,onSelect)
    local stCard=card(parent,34)
    local stLbl=mkLabel(stCard,{Size=UDim2.new(1,-18,1,0),Position=UDim2.new(0,10,0,0),Text="👆  Select a player below",TextSize=11,TextColor3=C.sub})
    local lhCard=card(parent,34)
    mkLabel(lhCard,{Size=UDim2.new(1,-72,1,0),Position=UDim2.new(0,12,0,0),Text="🎮  Players in Lobby",TextSize=12,TextColor3=C.text})
    local refBtn=mkBtn(lhCard,{Size=UDim2.new(0,60,0,22),Position=UDim2.new(1,-64,0.5,-11),BackgroundColor3=C.accent,Text="↺  Refresh",TextColor3=C.text,TextSize=10}); mkCorner(refBtn,6)
    elemOrd+=1
    local outer=mkFrame(parent,{Size=UDim2.new(1,0,0,height),BackgroundColor3=Color3.fromRGB(18,18,28),LayoutOrder=elemOrd,ClipsDescendants=true})
    mkCorner(outer,10); mkStroke(outer,C.border)
    local sf=Instance.new("ScrollingFrame"); sf.Size=UDim2.new(1,0,1,0); sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollBarThickness=5; sf.ScrollBarImageColor3=C.accent; sf.CanvasSize=UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize=Enum.AutomaticSize.Y; sf.ScrollingDirection=Enum.ScrollingDirection.Y; sf.Parent=outer
    do
        local ul=Instance.new("UIListLayout"); ul.SortOrder=Enum.SortOrder.LayoutOrder; ul.Padding=UDim.new(0,4); ul.Parent=sf
        local up=Instance.new("UIPadding"); up.PaddingLeft=UDim.new(0,6); up.PaddingRight=UDim.new(0,10); up.PaddingTop=UDim.new(0,6); up.PaddingBottom=UDim.new(0,6); up.Parent=sf
    end
    local pBtns={}; local selected=nil
    local function setStatus(txt,col) stLbl.Text=txt; stLbl.TextColor3=col or C.sub end
    local function buildList()
        for _,c in ipairs(sf:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end
        pBtns={}; selected=nil; setStatus("👆  Select a player below",C.sub)
        local others={}; for _,p in ipairs(Players:GetPlayers()) do if p~=ME then table.insert(others,p) end end
        if #others==0 then
            local ef=mkFrame(sf,{Size=UDim2.new(1,0,0,50),BackgroundColor3=Color3.fromRGB(24,24,36)}); mkCorner(ef,8)
            mkLabel(ef,{Size=UDim2.new(1,0,1,0),Text="😔  No other players in server",TextSize=12,Font=Enum.Font.Gotham,TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Center}); return
        end
        for i,p in ipairs(others) do
            local row=mkFrame(sf,{Size=UDim2.new(1,0,0,44),BackgroundColor3=C.row,LayoutOrder=i}); mkCorner(row,8)
            local av=mkFrame(row,{Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,7,0.5,-15),BackgroundColor3=C.accent}); mkCorner(av,15)
            mkLabel(av,{Size=UDim2.new(1,0,1,0),Text=string.upper(string.sub(p.Name,1,1)),TextSize=14,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Center})
            mkLabel(row,{Size=UDim2.new(1,-110,0,18),Position=UDim2.new(0,45,0,5),Text=p.Name,TextSize=12,TextColor3=C.text})
            mkLabel(row,{Size=UDim2.new(1,-110,0,14),Position=UDim2.new(0,45,0,24),Text=(p.DisplayName~=p.Name) and p.DisplayName or "Roblox Player",TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.sub})
            local sb=mkBtn(row,{Size=UDim2.new(0,54,0,26),Position=UDim2.new(1,-58,0.5,-13),BackgroundColor3=Color3.fromRGB(38,38,58),Text="Select",TextColor3=C.text,TextSize=11}); mkCorner(sb,6)
            pBtns[p]={row=row,btn=sb,av=av}
            sb.MouseButton1Click:Connect(function()
                for _,d in pairs(pBtns) do d.row.BackgroundColor3=C.row; d.btn.BackgroundColor3=Color3.fromRGB(38,38,58); d.btn.Text="Select"; d.btn.TextColor3=C.text; d.av.BackgroundColor3=C.accent end
                selected=p; row.BackgroundColor3=C.row_sel; sb.BackgroundColor3=C.accent; sb.Text="✓"; sb.TextColor3=Color3.new(1,1,1); av.BackgroundColor3=C.orange
                onSelect(p,setStatus)
            end)
        end
        TweenService:Create(refBtn,TW,{BackgroundColor3=C.green}):Play()
        task.delay(0.4,function() TweenService:Create(refBtn,TW,{BackgroundColor3=C.accent}):Play() end)
    end
    refBtn.MouseButton1Click:Connect(buildList)
    Players.PlayerAdded:Connect(function() task.wait(0.6); buildList() end)
    Players.PlayerRemoving:Connect(function() task.wait(0.15); buildList() end)
    buildList()
    return sf,buildList,setStatus,function() return selected end
end

-- ══════════════════════════════════════════════════════════════════════
--  FEATURE STATE
-- ══════════════════════════════════════════════════════════════════════
local fly=false; local flySpeed=50; local bv,bg2
local nc=false; local infJump=false; local god=false
local espOn=false; local espHL={}
local floatOn=false; local floatBV=nil
local spinOn=false; local spinConn=nil
local rainbowOn=false; local rainbowConn=nil
local trailOn=false; local trailObj=nil
local invisOn=false
local followOn=false; local followTarget=nil; local followConn=nil
local spectateOn=false; local spectateTarget=nil
local origCamType=nil
-- new movement
local swimAirOn=false;  local swimBV=nil
local jetpackOn=false;  local jetpackBV=nil
local heroLandOn=false; local heroLastY=0; local heroWasAir=false
-- new visuals
local fullbrightOn=false
local origAmbient; local origOutAmbient; local origBrightness
local crosshairOn=false; local crosshairFrame=nil
local coordsOn=false;   local coordsLabel=nil
local fpsOn=false;      local fpsLabel=nil

-- ── NEW FEATURE STATE ─────────────────────────────────────────────────
-- Multi-Target Fling
local flingTargets={}       -- name → player
local flingCheckboxUI={}    -- name → {row, check}
local flingActive=false
local flingStatusText="Select targets below"
local flingStatusLbl=nil    -- set after UI is built

-- Blink Dash
local blinkOn=false; local blinkCooldown=false; local blinkDist=40
-- Auto-Dodge
local autoDodgeOn=false; local autoDodgeTouched=nil; local dodgeCooldown=false
-- Punch Force Multiplier
local punchForceOn=false; local punchForceAmt=25; local punchConns={}
-- Name Tag Changer
local nameTagOn=false; local nameTagGui=nil; local nameTagText="★ "..ME.Name
-- Server Stats
local scriptStartTime=os.time()
local statsUpdateConns={}

-- ── AIM ASSIST STATE ─────────────────────────────────────────────────
local aimOn          = false
local afkOn          = false
local chatSpamConn   = nil
local aimFOV         = 25
local aimSmooth      = 8
local aimDist        = 150
local aimHead        = true
local aimHoldOnly    = true
local aimLockedTarget = nil

-- ── FLY ───────────────────────────────────────────────────────────────
local function startFly()
    local hrp=getHRP(); local hum=getHum(); if not hrp or not hum then return end
    fly=true; hum.PlatformStand=true
    if hrp:FindFirstChild("_bv") then hrp:FindFirstChild("_bv"):Destroy() end
    if hrp:FindFirstChild("_bg") then hrp:FindFirstChild("_bg"):Destroy() end
    bv=Instance.new("BodyVelocity"); bv.Name="_bv"; bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=Vector3.zero; bv.Parent=hrp
    bg2=Instance.new("BodyGyro"); bg2.Name="_bg"; bg2.MaxTorque=Vector3.new(1e5,1e5,1e5); bg2.P=1e4; bg2.Parent=hrp
end
local function stopFly()
    fly=false; local hum=getHum(); if hum then hum.PlatformStand=false end
    if bv and bv.Parent then bv:Destroy() end; if bg2 and bg2.Parent then bg2:Destroy() end; bv=nil; bg2=nil
end

-- ── ESP ───────────────────────────────────────────────────────────────
local function addESP(p)
    if p==ME then return end; local ch=p.Character; if not ch or espHL[p] then return end
    local h=Instance.new("Highlight"); h.FillColor=C.accent; h.OutlineColor=Color3.new(1,1,1)
    h.FillTransparency=0.35; h.OutlineTransparency=0; h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Adornee=ch; h.Parent=ch
    local bb=Instance.new("BillboardGui"); bb.Name="ESPbb"; bb.Size=UDim2.new(0,110,0,28); bb.StudsOffset=Vector3.new(0,3.8,0); bb.AlwaysOnTop=true
    bb.Adornee=ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChildWhichIsA("BasePart"); bb.Parent=ch
    local nl=Instance.new("TextLabel"); nl.Size=UDim2.new(1,0,1,0); nl.BackgroundTransparency=1
    nl.Text="⬥ "..p.Name; nl.TextColor3=Color3.new(1,1,1); nl.TextSize=13; nl.Font=Enum.Font.GothamBold; nl.TextStrokeTransparency=0; nl.Parent=bb
    espHL[p]=h
end
local function remESP(p)
    if espHL[p] then espHL[p]:Destroy(); espHL[p]=nil end
    local ch=p.Character; if ch then local b=ch:FindFirstChild("ESPbb"); if b then b:Destroy() end end
end
local function clearESP() for p in pairs(espHL) do remESP(p) end end
local function refreshESP() if not espOn then clearESP(); return end; for _,p in ipairs(Players:GetPlayers()) do addESP(p) end end
Players.PlayerAdded:Connect(function(p) if espOn then p.CharacterAdded:Connect(function() task.wait(0.5); addESP(p) end) end end)
Players.PlayerRemoving:Connect(remESP)

-- ── FLOAT ─────────────────────────────────────────────────────────────
local function startFloat()
    local hrp=getHRP(); if not hrp then return end
    if hrp:FindFirstChild("_floatBV") then hrp:FindFirstChild("_floatBV"):Destroy() end
    floatBV=Instance.new("BodyVelocity"); floatBV.Name="_floatBV"
    floatBV.MaxForce=Vector3.new(0,1e4,0); floatBV.Velocity=Vector3.new(0,8,0); floatBV.Parent=hrp
    local hum=getHum(); if hum then hum.PlatformStand=false end
end
local function stopFloat()
    if floatBV and floatBV.Parent then floatBV:Destroy() end; floatBV=nil
end

-- ── SPIN ──────────────────────────────────────────────────────────────
local function startSpin()
    spinOn=true
    spinConn=RunService.Heartbeat:Connect(function()
        local hrp=getHRP(); if not hrp then return end
        hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(8),0)
    end)
end
local function stopSpin()
    spinOn=false; if spinConn then spinConn:Disconnect(); spinConn=nil end
end

-- ── RAINBOW ───────────────────────────────────────────────────────────
local rainbowHue=0
local function startRainbow()
    rainbowOn=true
    rainbowConn=RunService.Heartbeat:Connect(function()
        local ch=getChar(); if not ch then return end
        rainbowHue=(rainbowHue+0.5)%360
        local col=Color3.fromHSV(rainbowHue/360,1,1)
        for _,p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Color=col end
        end
    end)
end
local function stopRainbow()
    rainbowOn=false; if rainbowConn then rainbowConn:Disconnect(); rainbowConn=nil end
    local ch=getChar(); if not ch then return end
    for _,p in ipairs(ch:GetDescendants()) do
        if p:IsA("BasePart") then p.Color=Color3.fromRGB(163,162,165) end
    end
end

-- ── TRAIL ─────────────────────────────────────────────────────────────
local function startTrail()
    local hrp=getHRP(); if not hrp then return end
    if hrp:FindFirstChild("_trail") then hrp:FindFirstChild("_trail"):Destroy() end
    local a0=Instance.new("Attachment"); a0.Position=Vector3.new(0,1,0); a0.Parent=hrp
    local a1=Instance.new("Attachment"); a1.Position=Vector3.new(0,-1,0); a1.Parent=hrp
    trailObj=Instance.new("Trail"); trailObj.Name="_trail"
    trailObj.Attachment0=a0; trailObj.Attachment1=a1
    trailObj.Lifetime=0.6; trailObj.MinLength=0
    trailObj.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),
        ColorSequenceKeypoint.new(0.5,Color3.fromHSV(0.5,1,1)),
        ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1)),
    })
    trailObj.Parent=hrp; trailOn=true
end
local function stopTrail()
    trailOn=false
    local hrp=getHRP(); if not hrp then return end
    local t=hrp:FindFirstChild("_trail"); if t then t:Destroy() end
    for _,a in ipairs(hrp:GetChildren()) do if a:IsA("Attachment") then a:Destroy() end end
end

-- ── INVISIBLE ─────────────────────────────────────────────────────────
local function setInvis(on)
    invisOn=on
    local ch=getChar(); if not ch then return end
    for _,p in ipairs(ch:GetDescendants()) do
        if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.LocalTransparencyModifier=on and 1 or 0 end
        if p:IsA("Decal") then p.Transparency=on and 1 or 0 end
    end
end

-- ── RESIZE ────────────────────────────────────────────────────────────
local function resizeChar(scale)
    local ch=getChar(); if not ch then return end
    local hum=getHum(); if not hum then return end
    local function setScale(name,val)
        local s=hum:FindFirstChild(name)
        if s and s:IsA("NumberValue") then s.Value=val end
    end
    setScale("BodyDepthScale",scale); setScale("BodyHeightScale",scale)
    setScale("BodyWidthScale",scale); setScale("HeadScale",scale)
end

-- ── FOLLOW ────────────────────────────────────────────────────────────
local function startFollow(target)
    followTarget=target; followOn=true
    if followConn then followConn:Disconnect() end
    followConn=RunService.Heartbeat:Connect(function()
        if not followOn then return end
        local hrp=getHRP(); if not hrp then return end
        local tch=followTarget and followTarget.Character
        local thrp=tch and tch:FindFirstChild("HumanoidRootPart")
        if not thrp then return end
        local hum=getHum(); if not hum then return end
        local dist=(thrp.Position-hrp.Position).Magnitude
        if dist>4 then hum:MoveTo(thrp.Position) end
    end)
end
local function stopFollow()
    followOn=false; followTarget=nil
    if followConn then followConn:Disconnect(); followConn=nil end
end

-- ── SPECTATE ──────────────────────────────────────────────────────────
local function startSpectate(target)
    spectateTarget=target; spectateOn=true
    local cam=workspace.CurrentCamera
    origCamType=cam.CameraType
    cam.CameraType=Enum.CameraType.Scriptable
    RunService.RenderStepped:Connect(function()
        if not spectateOn then return end
        local tch=spectateTarget and spectateTarget.Character
        local thrp=tch and tch:FindFirstChild("HumanoidRootPart")
        if thrp then cam.CFrame=CFrame.new(thrp.Position+Vector3.new(0,6,-12),thrp.Position) end
    end)
end
local function stopSpectate()
    spectateOn=false; spectateTarget=nil
    local cam=workspace.CurrentCamera
    if origCamType then cam.CameraType=origCamType end
end

-- ══════════════════════════════════════════════════════════════════════
--  NEW FEATURE LOGIC
-- ══════════════════════════════════════════════════════════════════════

-- ── BLINK DASH ────────────────────────────────────────────────────────
-- Press Q to blink forward in the camera direction
local function doBlink()
    if not blinkOn or blinkCooldown then return end
    local hrp=getHRP(); if not hrp then return end
    local cam=workspace.CurrentCamera
    local look=cam.CFrame.LookVector
    local dashDir=Vector3.new(look.X,0,look.Z)
    if dashDir.Magnitude>0 then dashDir=dashDir.Unit end
    hrp.CFrame=hrp.CFrame + dashDir * blinkDist
    -- Flash effect: brief neon glow on character
    task.spawn(function()
        local ch=getChar(); if not ch then return end
        for _,p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                local orig=p.Material
                p.Material=Enum.Material.Neon
                task.delay(0.12,function() if p and p.Parent then p.Material=orig end end)
            end
        end
    end)
    blinkCooldown=true
    task.delay(0.8,function() blinkCooldown=false end)
end

-- ── AUTO-DODGE ────────────────────────────────────────────────────────
local function startAutoDodge()
    autoDodgeOn=true
    local ch=getChar(); if not ch then return end
    if autoDodgeTouched then autoDodgeTouched:Disconnect() end
    autoDodgeTouched=ch.PrimaryPart and ch.PrimaryPart.Touched:Connect(function(hit)
        if not autoDodgeOn or dodgeCooldown then return end
        if hit:IsDescendantOf(ch) then return end
        -- Only dodge projectiles/characters, not the floor
        local isEnemy=false
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=ME and p.Character and hit:IsDescendantOf(p.Character) then isEnemy=true; break end
        end
        if not isEnemy and hit.Velocity.Magnitude < 10 then return end
        dodgeCooldown=true
        local hum=getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        local hrp=getHRP()
        if hrp then
            local dir=(hrp.Position-hit.Position)
            dir=Vector3.new(dir.X,0,dir.Z)
            if dir.Magnitude>0 then dir=dir.Unit end
            local pushBV=Instance.new("BodyVelocity")
            pushBV.Velocity=dir*35
            pushBV.MaxForce=Vector3.new(1e4,1e4,1e4)
            pushBV.P=1e4
            pushBV.Parent=hrp
            task.delay(0.2,function() if pushBV.Parent then pushBV:Destroy() end end)
        end
        task.delay(0.6,function() dodgeCooldown=false end)
    end)
end
local function stopAutoDodge()
    autoDodgeOn=false
    if autoDodgeTouched then autoDodgeTouched:Disconnect(); autoDodgeTouched=nil end
    dodgeCooldown=false
end

-- ── PUNCH FORCE MULTIPLIER ────────────────────────────────────────────
local function cleanPunchConns()
    for _,c in ipairs(punchConns) do c:Disconnect() end
    punchConns={}
end
local function startPunchForce()
    punchForceOn=true
    cleanPunchConns()
    local ch=getChar(); if not ch then return end
    for _,part in ipairs(ch:GetDescendants()) do
        if part:IsA("BasePart") then
            local conn=part.Touched:Connect(function(hit)
                if not punchForceOn then return end
                local hitChar=nil
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=ME and p.Character and hit:IsDescendantOf(p.Character) then
                        hitChar=p.Character; break
                    end
                end
                if not hitChar then return end
                local thrp=hitChar:FindFirstChild("HumanoidRootPart"); if not thrp then return end
                local myHRP=getHRP(); if not myHRP then return end
                local pushDir=(thrp.Position-myHRP.Position)
                pushDir=Vector3.new(pushDir.X,0,pushDir.Z)
                if pushDir.Magnitude>0 then pushDir=pushDir.Unit end
                local launchVel=(pushDir+Vector3.new(0,0.6,0)).Unit*(punchForceAmt*6)
                local bvPunch=Instance.new("BodyVelocity")
                bvPunch.Velocity=launchVel
                bvPunch.MaxForce=Vector3.new(1e5,1e5,1e5)
                bvPunch.P=1e5
                bvPunch.Parent=thrp
                task.delay(0.25,function() if bvPunch.Parent then bvPunch:Destroy() end end)
            end)
            table.insert(punchConns,conn)
        end
    end
end
local function stopPunchForce()
    punchForceOn=false
    cleanPunchConns()
end

-- ══════════════════════════════════════════════════════════════════════
--  MULTI-TARGET FLING  (SkidFling mechanism by zqyDSUWX / K1LAS1K)
-- ══════════════════════════════════════════════════════════════════════
local flingOldPos = nil
local flingOrigFPDH = workspace.FallenPartsDestroyHeight

local function updateFlingStatus()
    if not flingStatusLbl then return end
    local count=0; for _ in pairs(flingTargets) do count+=1 end
    if flingActive then
        flingStatusLbl.Text="🔴  Flinging "..count.." target(s)..."
        flingStatusLbl.TextColor3=C.red
    else
        flingStatusLbl.Text="⚪  "..count.." target(s) selected"
        flingStatusLbl.TextColor3=C.sub
    end
end

local function SkidFling(targetPlayer)
    local ch=getChar()
    local hum=getHum()
    local hrp=getHRP()
    local tch=targetPlayer.Character
    if not tch or not ch or not hum or not hrp then return end

    local tHum=tch:FindFirstChildOfClass("Humanoid")
    local tHRP=tHum and tHum.RootPart
    local tHead=tch:FindFirstChild("Head")
    local acc=tch:FindFirstChildOfClass("Accessory")
    local handle=acc and acc:FindFirstChild("Handle")

    -- Save our position before flinging
    if hrp.Velocity.Magnitude < 50 then
        flingOldPos=hrp.CFrame
    end

    -- Skip if target is sitting
    if tHum and tHum.Sit then return end

    -- Point camera at target so it looks like we're aiming
    if tHead then
        workspace.CurrentCamera.CameraSubject=tHead
    elseif handle then
        workspace.CurrentCamera.CameraSubject=handle
    elseif tHum then
        workspace.CurrentCamera.CameraSubject=tHum
    end

    local targetBasePart=tHRP or tHead or handle
    if not targetBasePart then return end

    -- Core position+velocity setter
    local function FPos(base, pos, ang)
        hrp.CFrame=CFrame.new(base.Position)*pos*ang
        ch:SetPrimaryPartCFrame(CFrame.new(base.Position)*pos*ang)
        hrp.Velocity=Vector3.new(9e7, 9e7*10, 9e7)
        hrp.RotVelocity=Vector3.new(9e8, 9e8, 9e8)
    end

    -- Rapid oscillation loop around target to build up fling force
    local function SFBasePart(base)
        local timeLimit=2
        local startTime=tick()
        local angle=0
        repeat
            if hrp and tHum then
                if base.Velocity.Magnitude < 50 then
                    angle+=100
                    local md=tHum.MoveDirection*(base.Velocity.Magnitude/1.25)
                    FPos(base, CFrame.new(0,1.5,0)+md, CFrame.Angles(math.rad(angle),0,0)); task.wait()
                    FPos(base, CFrame.new(0,-1.5,0)+md, CFrame.Angles(math.rad(angle),0,0)); task.wait()
                    FPos(base, CFrame.new(0,1.5,0)+md, CFrame.Angles(math.rad(angle),0,0)); task.wait()
                    FPos(base, CFrame.new(0,-1.5,0)+md, CFrame.Angles(math.rad(angle),0,0)); task.wait()
                    FPos(base, CFrame.new(0,1.5,0)+tHum.MoveDirection, CFrame.Angles(math.rad(angle),0,0)); task.wait()
                    FPos(base, CFrame.new(0,-1.5,0)+tHum.MoveDirection, CFrame.Angles(math.rad(angle),0,0)); task.wait()
                else
                    FPos(base, CFrame.new(0,1.5,tHum.WalkSpeed), CFrame.Angles(math.rad(90),0,0)); task.wait()
                    FPos(base, CFrame.new(0,-1.5,-tHum.WalkSpeed), CFrame.Angles(0,0,0)); task.wait()
                    FPos(base, CFrame.new(0,1.5,tHum.WalkSpeed), CFrame.Angles(math.rad(90),0,0)); task.wait()
                    FPos(base, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0)); task.wait()
                    FPos(base, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)); task.wait()
                    FPos(base, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0)); task.wait()
                    FPos(base, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)); task.wait()
                end
            end
        until startTime+timeLimit < tick() or not flingActive
    end

    -- Disable fallen-parts boundary so we don't get destroyed
    workspace.FallenPartsDestroyHeight=0/0

    -- Anchor our velocity so we don't drift
    local bvFling=Instance.new("BodyVelocity")
    bvFling.Parent=hrp
    bvFling.Velocity=Vector3.zero
    bvFling.MaxForce=Vector3.new(9e9,9e9,9e9)

    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
    SFBasePart(targetBasePart)
    bvFling:Destroy()
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
    workspace.CurrentCamera.CameraSubject=hum

    -- Snap back to where we were before the fling
    if flingOldPos then
        local safePos=flingOldPos*CFrame.new(0,0.5,0)
        local attempts=0
        repeat
            hrp.CFrame=safePos
            ch:SetPrimaryPartCFrame(safePos)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            for _,part in ipairs(ch:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Velocity=Vector3.zero
                    part.RotVelocity=Vector3.zero
                end
            end
            task.wait()
            attempts+=1
        until (hrp.Position-flingOldPos.p).Magnitude<25 or attempts>30
        workspace.FallenPartsDestroyHeight=flingOrigFPDH
    end
end

local function startFlingLoop()
    if flingActive then return end
    local count=0; for _ in pairs(flingTargets) do count+=1 end
    if count==0 then
        if flingStatusLbl then
            flingStatusLbl.Text="⚠️  Select at least one target!"
            flingStatusLbl.TextColor3=C.yellow
            task.delay(2,updateFlingStatus)
        end
        return
    end
    flingActive=true
    updateFlingStatus()
    task.spawn(function()
        while flingActive do
            -- Validate targets (remove players who left)
            local valid={}
            for name,p in pairs(flingTargets) do
                if p and p.Parent then
                    table.insert(valid,p)
                else
                    flingTargets[name]=nil
                    local ui=flingCheckboxUI[name]
                    if ui then
                        ui.check.Text=""; ui.check.BackgroundColor3=Color3.fromRGB(50,50,70)
                        ui.row.BackgroundColor3=C.row
                    end
                    flingCheckboxUI[name]=nil
                end
            end
            for _,p in ipairs(valid) do
                if flingActive then SkidFling(p); task.wait(0.1)
                else break end
            end
            updateFlingStatus()
            task.wait(0.5)
        end
    end)
end

local function stopFlingLoop()
    flingActive=false
    workspace.FallenPartsDestroyHeight=flingOrigFPDH
    updateFlingStatus()
end

-- ── NAME TAG CHANGER ──────────────────────────────────────────────────
local function applyNameTag()
    local ch=getChar(); if not ch then return end
    local hrp=ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local existing=hrp:FindFirstChild("kAaMsNameTag")
    if existing then existing:Destroy() end
    if not nameTagOn then return end
    local bb=Instance.new("BillboardGui")
    bb.Name="kAaMsNameTag"
    bb.Size=UDim2.new(0,220,0,36)
    bb.StudsOffset=Vector3.new(0,3.2,0)
    bb.AlwaysOnTop=false
    bb.Adornee=hrp
    bb.Parent=hrp
    nameTagGui=bb
    local bg=mkFrame(bb,{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=Color3.fromRGB(15,15,25),
        BackgroundTransparency=0.2,
    })
    mkCorner(bg,6)
    mkStroke(bg,C.accent,1.5)
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency=1
    lbl.Text=nameTagText
    lbl.TextColor3=Color3.new(1,1,1)
    lbl.TextSize=14
    lbl.Font=Enum.Font.GothamBold
    lbl.TextStrokeTransparency=0.4
    lbl.TextStrokeColor3=C.accent
    lbl.TextXAlignment=Enum.TextXAlignment.Center
    lbl.Parent=bg
end
local function removeNameTag()
    local ch=getChar(); if not ch then return end
    local hrp=ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local existing=hrp:FindFirstChild("kAaMsNameTag")
    if existing then existing:Destroy() end
    nameTagGui=nil
end

-- ── AIM ASSIST HELPERS ────────────────────────────────────────────────
local function aimIsValid(player)
    if player==ME then return false end
    if ME.Team~=nil and player.Team==ME.Team then return false end
    local ch=player.Character; if not ch then return false end
    local hum=ch:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return false end
    return ch:FindFirstChild("HumanoidRootPart")~=nil
end

local function aimFindTarget()
    local localChar=getChar()
    if not localChar then aimLockedTarget=nil; return nil end
    local cam=workspace.CurrentCamera
    local camPos=cam.CFrame.Position
    local camLook=cam.CFrame.LookVector
    if aimLockedTarget and aimLockedTarget.Parent then
        local owner=Players:GetPlayerFromCharacter(aimLockedTarget.Parent)
        if owner and aimIsValid(owner) then
            local dist=(aimLockedTarget.Position-camPos).Magnitude
            if dist<=aimDist then return aimLockedTarget end
        end
    end
    aimLockedTarget=nil
    local bestPart=nil; local bestDist=aimDist
    for _,player in ipairs(Players:GetPlayers()) do
        if aimIsValid(player) then
            local ch=player.Character
            local part=aimHead and (ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")) or ch:FindFirstChild("HumanoidRootPart")
            if part then
                local toTarget=part.Position-camPos
                local dist=toTarget.Magnitude
                if dist<=aimDist then
                    local angle=math.deg(math.acos(math.clamp(camLook:Dot(toTarget.Unit),-1,1)))
                    if angle<=aimFOV and dist<bestDist then
                        local params=RaycastParams.new()
                        params.FilterDescendantsInstances={localChar,ch}
                        params.FilterType=Enum.RaycastFilterType.Exclude
                        if not workspace:Raycast(camPos,toTarget.Unit*dist,params) then
                            bestDist=dist; bestPart=part
                        end
                    end
                end
            end
        end
    end
    aimLockedTarget=bestPart
    return bestPart
end

-- ══════════════════════════════════════════════════════════════════════
--  BUILD TABS
-- ══════════════════════════════════════════════════════════════════════
local movPage      = makeTab("🏃","Movement")
local visPage      = makeTab("👁","Visuals")
local funPage      = makeTab("💥","Fun")
local cosPage      = makeTab("🌈","Cosmetics")
local worldPage    = makeTab("🌍","World")
local tpPage       = makeTab("🌀","Teleport")
local aimPage      = makeTab("🎯","Aim Assist")
local statsPage    = makeTab("📊","Stats")
local settingsPage = makeTab("⚙️","Settings")

-- ── MOVEMENT ──────────────────────────────────────────────────────────
makeToggle(movPage,"Fly","Soar freely through the air",function(on) if on then startFly() else stopFly() end end)
makeSlider(movPage,"Fly Speed",1,200,50,function(v) flySpeed=v end)
makeToggle(movPage,"Noclip","Walk through walls",function(on) nc=on end)
makeSlider(movPage,"Walk Speed",1,150,16,function(v) local h=getHum(); if h then h.WalkSpeed=v end end)
makeSlider(movPage,"Jump Power",1,300,50,function(v) local h=getHum(); if h then h.JumpPower=v end end)
makeToggle(movPage,"Infinite Jump","Jump again mid-air",function(on) infJump=on end)
makeToggle(movPage,"Float","Slowly rise into the air like a balloon",function(on) if on then startFloat() else stopFloat() end end)
makeToggle(movPage,"Spin","Spin your character around",function(on) if on then startSpin() else stopSpin() end end)
makeToggle(movPage,"Swim in Air","Float and move freely in all directions like underwater",function(on)
    swimAirOn=on
    local hrp=getHRP(); if not hrp then return end
    if on then
        local bv2=Instance.new("BodyVelocity"); bv2.Name="kAaMsSwimBV"
        bv2.Velocity=Vector3.zero; bv2.MaxForce=Vector3.new(1e4,1e4,1e4); bv2.P=500
        bv2.Parent=hrp; swimBV=bv2
        local h=getHum(); if h then h.PlatformStand=true end
    else
        if swimBV and swimBV.Parent then swimBV:Destroy() end; swimBV=nil
        local h=getHum(); if h then h.PlatformStand=false end
    end
end)
makeToggle(movPage,"Jetpack","Hold Space to boost upward with force",function(on)
    jetpackOn=on
    if not on then
        if jetpackBV and jetpackBV.Parent then jetpackBV:Destroy() end; jetpackBV=nil
    end
end)
makeToggle(movPage,"Superhero Landing","Slam effects when you hit the ground at speed",function(on) heroLandOn=on end)

-- ── BLINK DASH (NEW) ──────────────────────────────────────────────────
do
    local blinkHdr=card(movPage,50); mkStroke(blinkHdr,C.purple,1.5)
    mkLabel(blinkHdr,{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,14,0,6),Text="⚡  Blink Dash",TextSize=14,TextColor3=C.purple})
    mkLabel(blinkHdr,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,14,0,28),Text="Press  Q  to dash forward instantly",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub})
    makeToggle(movPage,"Enable Blink Dash","Activate Q-key teleport dash",function(on) blinkOn=on end)
    makeSlider(movPage,"Blink Distance",10,120,40,function(v) blinkDist=v end)
end

-- ── AUTO-DODGE (NEW) ──────────────────────────────────────────────────
makeToggle(movPage,"Auto-Dodge","Auto jump+pushback when hit by a player",function(on)
    if on then startAutoDodge() else stopAutoDodge() end
end)

-- ── VISUALS ───────────────────────────────────────────────────────────
makeToggle(visPage,"ESP","See all players through walls",function(on) espOn=on; refreshESP() end)
makeToggle(visPage,"God Mode","Health stays at max",function(on) god=on end)
makeToggle(visPage,"Invisible","Make your character invisible",function(on) setInvis(on) end)
makeToggle(visPage,"Fullbright","Everything is fully lit, no darkness anywhere",function(on)
    fullbrightOn=on
    if on then
        origAmbient=Lighting.Ambient; origOutAmbient=Lighting.OutdoorAmbient; origBrightness=Lighting.Brightness
        Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1); Lighting.Brightness=2
    else
        if origAmbient then Lighting.Ambient=origAmbient; Lighting.OutdoorAmbient=origOutAmbient; Lighting.Brightness=origBrightness end
    end
end)
makeToggle(visPage,"Crosshair","Draw a custom crosshair on screen",function(on)
    crosshairOn=on
    if on and not crosshairFrame then
        crosshairFrame=Instance.new("Frame"); crosshairFrame.Name="kAaMsCrosshair"
        crosshairFrame.Size=UDim2.new(0,40,0,40); crosshairFrame.Position=UDim2.new(0.5,-20,0.5,-20)
        crosshairFrame.BackgroundTransparency=1; crosshairFrame.ZIndex=10; crosshairFrame.Parent=SG
        local h=Instance.new("Frame"); h.Size=UDim2.new(0,30,0,2); h.Position=UDim2.new(0.5,-15,0.5,-1)
        h.BackgroundColor3=Color3.new(1,1,1); h.BorderSizePixel=0; h.ZIndex=10; h.Parent=crosshairFrame
        local v=Instance.new("Frame"); v.Size=UDim2.new(0,2,0,30); v.Position=UDim2.new(0.5,-1,0.5,-15)
        v.BackgroundColor3=Color3.new(1,1,1); v.BorderSizePixel=0; v.ZIndex=10; v.Parent=crosshairFrame
        local dot=Instance.new("Frame"); dot.Size=UDim2.new(0,4,0,4); dot.Position=UDim2.new(0.5,-2,0.5,-2)
        dot.BackgroundColor3=C.accent; dot.BorderSizePixel=0; dot.ZIndex=11; dot.Parent=crosshairFrame
        local ins=Instance.new("UICorner"); ins.CornerRadius=UDim.new(1,0); ins.Parent=dot
    elseif not on and crosshairFrame then
        crosshairFrame:Destroy(); crosshairFrame=nil
    end
end)
makeToggle(visPage,"Coordinates","Live X Y Z position readout",function(on)
    coordsOn=on
    if on and not coordsLabel then
        coordsLabel=Instance.new("TextLabel"); coordsLabel.Name="kAaMsCoords"
        coordsLabel.Size=UDim2.new(0,220,0,22); coordsLabel.Position=UDim2.new(0,8,1,-60)
        coordsLabel.BackgroundColor3=Color3.fromRGB(12,12,20); coordsLabel.BackgroundTransparency=0.3
        coordsLabel.TextColor3=C.accent; coordsLabel.TextSize=12; coordsLabel.Font=Enum.Font.Code
        coordsLabel.Text="X: 0  Y: 0  Z: 0"; coordsLabel.BorderSizePixel=0; coordsLabel.ZIndex=10
        coordsLabel.Parent=SG; mkCorner(coordsLabel,5)
    elseif not on and coordsLabel then
        coordsLabel:Destroy(); coordsLabel=nil
    end
end)
makeToggle(visPage,"FPS / Ping","Show FPS and ping in the corner",function(on)
    fpsOn=on
    if on and not fpsLabel then
        fpsLabel=Instance.new("TextLabel"); fpsLabel.Name="kAaMsFPS"
        fpsLabel.Size=UDim2.new(0,160,0,22); fpsLabel.Position=UDim2.new(0,8,1,-34)
        fpsLabel.BackgroundColor3=Color3.fromRGB(12,12,20); fpsLabel.BackgroundTransparency=0.3
        fpsLabel.TextColor3=C.green; fpsLabel.TextSize=12; fpsLabel.Font=Enum.Font.Code
        fpsLabel.Text="FPS: --  Ping: --ms"; fpsLabel.BorderSizePixel=0; fpsLabel.ZIndex=10
        fpsLabel.Parent=SG; mkCorner(fpsLabel,5)
    elseif not on and fpsLabel then
        fpsLabel:Destroy(); fpsLabel=nil
    end
end)

-- ── COSMETICS ─────────────────────────────────────────────────────────
makeToggle(cosPage,"Rainbow Character","Cycle through all colours",function(on) if on then startRainbow() else stopRainbow() end end)
makeToggle(cosPage,"Rainbow Trail","Leave a rainbow trail behind you",function(on) if on then startTrail() else stopTrail() end end)

do -- Size control
    local sizeCard=card(cosPage,64)
    mkLabel(sizeCard,{Size=UDim2.new(1,-70,0,18),Position=UDim2.new(0,14,0,10),Text="Character Size",TextSize=13,TextColor3=C.text})
    local vl=mkLabel(sizeCard,{Size=UDim2.new(0,52,0,18),Position=UDim2.new(1,-62,0,10),Text="1.0",TextSize=13,TextColor3=C.accent,TextXAlignment=Enum.TextXAlignment.Right})
    local track=mkFrame(sizeCard,{Size=UDim2.new(1,-28,0,6),Position=UDim2.new(0,14,0,42),BackgroundColor3=C.pill_off}); mkCorner(track,3)
    local fill=mkFrame(track,{Size=UDim2.new(0.25,0,1,0),BackgroundColor3=C.purple}); mkCorner(fill,3)
    local sk=mkBtn(track,{Size=UDim2.new(0,16,0,16),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.25,0,0.5,0),BackgroundColor3=Color3.new(1,1,1),Text="",ZIndex=5}); mkCorner(sk,8)
    local drag=false
    sk.MouseButton1Down:Connect(function() drag=true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag or i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local r=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local v=math.floor((0.25+r*2.75)*10)/10
        fill.Size=UDim2.new(r,0,1,0); sk.Position=UDim2.new(r,0,0.5,0)
        vl.Text=tostring(v); resizeChar(v)
    end)
    makeButton(cosPage,"Reset Size",C.sub,function() resizeChar(1) end)
end

-- ── NAME TAG CHANGER (NEW) ────────────────────────────────────────────
do
    local ntHdr=card(cosPage,50); mkStroke(ntHdr,C.orange,1.5)
    mkLabel(ntHdr,{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,14,0,6),Text="🏷️  Name Tag Changer",TextSize=14,TextColor3=C.orange})
    mkLabel(ntHdr,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,14,0,28),Text="Show a custom floating tag above your head",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub})
    makeToggle(cosPage,"Enable Name Tag","Toggle your custom tag on/off",function(on)
        nameTagOn=on
        if on then applyNameTag() else removeNameTag() end
    end)
    makeInput(cosPage,"Tag Text","Enter your tag here...",function(text)
        if text=="" then return end
        nameTagText=text
        if nameTagOn then applyNameTag() end
    end)
    makeButton(cosPage,"Reset to Default",C.sub,function()
        nameTagText="★ "..ME.Name
        if nameTagOn then applyNameTag() end
    end)
end

-- ── FUN / FOLLOW & SPECTATE ───────────────────────────────────────────
do
    -- ══════════════════════════════════════════════════════════════════
    --  MULTI-TARGET FLING SECTION
    -- ══════════════════════════════════════════════════════════════════
    local flHdr=card(funPage,50); mkStroke(flHdr,C.red,2)
    mkLabel(flHdr,{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,14,0,6),Text="🚀  Multi-Target Fling",TextSize=14,TextColor3=C.red})
    mkLabel(flHdr,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,14,0,28),Text="Launch multiple players into the sky",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub})

    -- Status card
    local flStatusCard=card(funPage,36)
    flingStatusLbl=mkLabel(flStatusCard,{Size=UDim2.new(1,-18,1,0),Position=UDim2.new(0,10,0,0),Text="⚪  Select targets below",TextSize=11,TextColor3=C.sub})

    -- Player checkbox list
    local flListHdr=card(funPage,34)
    mkLabel(flListHdr,{Size=UDim2.new(1,-90,1,0),Position=UDim2.new(0,12,0,0),Text="🎮  Choose Targets",TextSize=12,TextColor3=C.text})
    local flRefBtn=mkBtn(flListHdr,{Size=UDim2.new(0,70,0,22),Position=UDim2.new(1,-74,0.5,-11),BackgroundColor3=C.accent,Text="↺  Refresh",TextColor3=C.text,TextSize=10}); mkCorner(flRefBtn,6)

    elemOrd+=1
    local flOuter=mkFrame(funPage,{Size=UDim2.new(1,0,0,160),BackgroundColor3=Color3.fromRGB(18,18,28),LayoutOrder=elemOrd,ClipsDescendants=true})
    mkCorner(flOuter,10); mkStroke(flOuter,C.border)
    local flSF=Instance.new("ScrollingFrame"); flSF.Size=UDim2.new(1,0,1,0); flSF.BackgroundTransparency=1; flSF.BorderSizePixel=0
    flSF.ScrollBarThickness=5; flSF.ScrollBarImageColor3=C.red; flSF.CanvasSize=UDim2.new(0,0,0,0)
    flSF.AutomaticCanvasSize=Enum.AutomaticSize.Y; flSF.ScrollingDirection=Enum.ScrollingDirection.Y; flSF.Parent=flOuter
    do
        local ul=Instance.new("UIListLayout"); ul.SortOrder=Enum.SortOrder.LayoutOrder; ul.Padding=UDim.new(0,4); ul.Parent=flSF
        local up=Instance.new("UIPadding"); up.PaddingLeft=UDim.new(0,6); up.PaddingRight=UDim.new(0,10); up.PaddingTop=UDim.new(0,6); up.PaddingBottom=UDim.new(0,6); up.Parent=flSF
    end

    local function buildFlingList()
        for _,c in ipairs(flSF:GetChildren()) do
            if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
        end
        flingCheckboxUI={}
        local others={}
        for _,p in ipairs(Players:GetPlayers()) do if p~=ME then table.insert(others,p) end end
        if #others==0 then
            mkLabel(flSF,{Size=UDim2.new(1,0,0,44),Text="😔  No other players in server",TextSize=12,Font=Enum.Font.Gotham,TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Center})
            return
        end
        for i,p in ipairs(others) do
            local row=mkFrame(flSF,{Size=UDim2.new(1,0,0,40),BackgroundColor3=C.row,LayoutOrder=i}); mkCorner(row,8)
            -- Checkbox button
            local chkBox=mkBtn(row,{Size=UDim2.new(0,26,0,26),Position=UDim2.new(0,8,0.5,-13),
                BackgroundColor3=Color3.fromRGB(50,50,70),Text="",ZIndex=3}); mkCorner(chkBox,6)
            mkStroke(chkBox,C.border,1)
            local chkMark=mkLabel(chkBox,{Size=UDim2.new(1,0,1,0),Text="",TextSize=16,
                TextColor3=C.red,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4})
            -- Avatar
            local av=mkFrame(row,{Size=UDim2.new(0,26,0,26),Position=UDim2.new(0,42,0.5,-13),BackgroundColor3=C.accent}); mkCorner(av,13)
            mkLabel(av,{Size=UDim2.new(1,0,1,0),Text=string.upper(string.sub(p.Name,1,1)),TextSize=13,TextColor3=Color3.new(1,1,1),TextXAlignment=Enum.TextXAlignment.Center})
            -- Name
            mkLabel(row,{Size=UDim2.new(1,-120,0,20),Position=UDim2.new(0,76,0.5,-10),Text=p.Name,TextSize=12,TextColor3=C.text})
            -- Restore check state if target was already selected
            if flingTargets[p.Name] then
                chkMark.Text="✓"; chkBox.BackgroundColor3=C.red
                row.BackgroundColor3=Color3.fromRGB(44,22,22)
            end
            flingCheckboxUI[p.Name]={row=row, check=chkMark, box=chkBox}
            -- Toggle on click (whole row clickable)
            local clickArea=mkBtn(row,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5})
            clickArea.MouseButton1Click:Connect(function()
                if flingTargets[p.Name] then
                    flingTargets[p.Name]=nil
                    chkMark.Text=""; chkBox.BackgroundColor3=Color3.fromRGB(50,50,70)
                    row.BackgroundColor3=C.row
                else
                    flingTargets[p.Name]=p
                    chkMark.Text="✓"; chkBox.BackgroundColor3=C.red
                    row.BackgroundColor3=Color3.fromRGB(44,22,22)
                end
                updateFlingStatus()
            end)
        end
        TweenService:Create(flRefBtn,TW,{BackgroundColor3=C.green}):Play()
        task.delay(0.4,function() TweenService:Create(flRefBtn,TW,{BackgroundColor3=C.accent}):Play() end)
        updateFlingStatus()
    end
    flRefBtn.MouseButton1Click:Connect(buildFlingList)
    Players.PlayerAdded:Connect(function() task.wait(0.6); buildFlingList() end)
    Players.PlayerRemoving:Connect(function(p)
        if flingTargets[p.Name] then flingTargets[p.Name]=nil end
        task.wait(0.15); buildFlingList()
    end)
    buildFlingList()

    -- Select All / Deselect All
    local flSelCard=card(funPage,40); mkStroke(flSelCard,C.border,1)
    local flSelAll=mkBtn(flSelCard,{Size=UDim2.new(0.48,-5,0,26),Position=UDim2.new(0,10,0.5,-13),
        BackgroundColor3=Color3.fromRGB(45,45,65),Text="✓  Select All",TextColor3=C.text,TextSize=11}); mkCorner(flSelAll,6)
    local flDeselAll=mkBtn(flSelCard,{Size=UDim2.new(0.48,-5,0,26),Position=UDim2.new(0.52,0,0.5,-13),
        BackgroundColor3=Color3.fromRGB(45,45,65),Text="✕  Deselect All",TextColor3=C.text,TextSize=11}); mkCorner(flDeselAll,6)
    flSelAll.MouseButton1Click:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=ME then
                flingTargets[p.Name]=p
                local ui=flingCheckboxUI[p.Name]
                if ui then ui.check.Text="✓"; ui.box.BackgroundColor3=C.red; ui.row.BackgroundColor3=Color3.fromRGB(44,22,22) end
            end
        end
        updateFlingStatus()
    end)
    flDeselAll.MouseButton1Click:Connect(function()
        for name in pairs(flingTargets) do
            flingTargets[name]=nil
            local ui=flingCheckboxUI[name]
            if ui then ui.check.Text=""; ui.box.BackgroundColor3=Color3.fromRGB(50,50,70); ui.row.BackgroundColor3=C.row end
        end
        updateFlingStatus()
    end)

    -- Start / Stop buttons
    local flBtnCard=card(funPage,52); mkStroke(flBtnCard,C.red,1.5)
    local flStartBtn=mkBtn(flBtnCard,{Size=UDim2.new(0.5,-8,0,36),Position=UDim2.new(0,8,0.5,-18),
        BackgroundColor3=C.red,Text="🚀  START FLING",TextColor3=Color3.new(1,1,1),TextSize=12}); mkCorner(flStartBtn,8)
    local flStopBtn=mkBtn(flBtnCard,{Size=UDim2.new(0.5,-8,0,36),Position=UDim2.new(0.5,0,0.5,-18),
        BackgroundColor3=C.pill_off,Text="■  STOP",TextColor3=Color3.new(1,1,1),TextSize=12}); mkCorner(flStopBtn,8)
    flStartBtn.MouseButton1Click:Connect(function()
        startFlingLoop()
        TweenService:Create(flStartBtn,TW,{BackgroundColor3=C.orange}):Play()
        task.delay(0.4,function() TweenService:Create(flStartBtn,TW,{BackgroundColor3=C.red}):Play() end)
    end)
    flStopBtn.MouseButton1Click:Connect(function()
        stopFlingLoop()
        TweenService:Create(flStopBtn,TW,{BackgroundColor3=C.red}):Play()
        task.delay(0.4,function() TweenService:Create(flStopBtn,TW,{BackgroundColor3=C.pill_off}):Play() end)
    end)

    -- ── Punch Force Multiplier (NEW) ──────────────────────────────────
    local pfHdr=card(funPage,50); mkStroke(pfHdr,C.red,1.5)
    mkLabel(pfHdr,{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,14,0,6),Text="🥊  Punch Force Multiplier",TextSize=14,TextColor3=C.red})
    mkLabel(pfHdr,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,14,0,28),Text="Send players flying when you touch them",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub})
    makeToggle(funPage,"Enable Punch Force","Blast nearby players on contact",function(on)
        if on then startPunchForce() else stopPunchForce() end
    end)
    makeSlider(funPage,"Launch Power",5,80,25,function(v) punchForceAmt=v end)

    -- Follow player
    local followHdr=card(funPage,50); mkStroke(followHdr,C.pink,1)
    mkLabel(followHdr,{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,14,0,6),Text="🚶  Follow Player",TextSize=14,TextColor3=C.pink})
    mkLabel(followHdr,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,14,0,28),Text="Auto-walk toward a selected player",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub})
    local followTarget2=nil
    local _,_,setFollowS,getFollowS=makePlayerList(funPage,140,function(p,ss) followTarget2=p; ss("✅  Will follow: "..p.Name,C.pink) end)
    do
        local fc=card(funPage,48); mkStroke(fc,C.pink,1)
        local startFollowBtn=mkBtn(fc,{Size=UDim2.new(0.48,-5,0,32),Position=UDim2.new(0,10,0.5,-16),BackgroundColor3=C.pink,Text="▶  Start Follow",TextColor3=Color3.new(1,1,1),TextSize=12}); mkCorner(startFollowBtn,8)
        local stopFollowBtn=mkBtn(fc,{Size=UDim2.new(0.48,-5,0,32),Position=UDim2.new(0.52,0,0.5,-16),BackgroundColor3=C.pill_off,Text="■  Stop",TextColor3=Color3.new(1,1,1),TextSize=12}); mkCorner(stopFollowBtn,8)
        startFollowBtn.MouseButton1Click:Connect(function()
            local t=getFollowS(); if not t then setFollowS("⚠️  Select a player first!",C.yellow); return end
            startFollow(t); setFollowS("🚶  Following "..t.Name.."...",C.pink)
            TweenService:Create(startFollowBtn,TW,{BackgroundColor3=C.green}):Play()
            task.delay(0.4,function() TweenService:Create(startFollowBtn,TW,{BackgroundColor3=C.pink}):Play() end)
        end)
        stopFollowBtn.MouseButton1Click:Connect(function()
            stopFollow(); setFollowS("⛔  Stopped following",C.sub)
            TweenService:Create(stopFollowBtn,TW,{BackgroundColor3=C.red}):Play()
            task.delay(0.4,function() TweenService:Create(stopFollowBtn,TW,{BackgroundColor3=C.pill_off}):Play() end)
        end)
    end

    -- Spectate
    local specHdr=card(funPage,50); mkStroke(specHdr,C.teal,1)
    mkLabel(specHdr,{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,14,0,6),Text="📷  Spectate Player",TextSize=14,TextColor3=C.teal})
    mkLabel(specHdr,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,14,0,28),Text="Lock your camera to another player",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub})
    local _,_,setSpecS,getSpecS=makePlayerList(funPage,140,function(p,ss) ss("✅  Will spectate: "..p.Name,C.teal) end)
    do
        local sc=card(funPage,48); mkStroke(sc,C.teal,1)
        local startSpecBtn=mkBtn(sc,{Size=UDim2.new(0.48,-5,0,32),Position=UDim2.new(0,10,0.5,-16),BackgroundColor3=C.teal,Text="📷  Spectate",TextColor3=Color3.new(1,1,1),TextSize=12}); mkCorner(startSpecBtn,8)
        local stopSpecBtn=mkBtn(sc,{Size=UDim2.new(0.48,-5,0,32),Position=UDim2.new(0.52,0,0.5,-16),BackgroundColor3=C.pill_off,Text="■  Stop",TextColor3=Color3.new(1,1,1),TextSize=12}); mkCorner(stopSpecBtn,8)
        startSpecBtn.MouseButton1Click:Connect(function()
            local t=getSpecS(); if not t then setSpecS("⚠️  Select a player first!",C.yellow); return end
            startSpectate(t); setSpecS("📷  Spectating "..t.Name.."...",C.teal)
            TweenService:Create(startSpecBtn,TW,{BackgroundColor3=C.green}):Play()
            task.delay(0.4,function() TweenService:Create(startSpecBtn,TW,{BackgroundColor3=C.teal}):Play() end)
        end)
        stopSpecBtn.MouseButton1Click:Connect(function()
            stopSpectate(); setSpecS("⛔  Stopped spectating",C.sub)
        end)
    end
end

-- ── WORLD ─────────────────────────────────────────────────────────────
do
    makeSlider(worldPage,"Time of Day",0,24,12,function(v) Lighting.TimeOfDay=string.format("%02d:00:00",v) end)
    makeSlider(worldPage,"Gravity",0,200,196,function(v) workspace.Gravity=v end)
    makeToggle(worldPage,"Thick Fog","Add dense fog to the world",function(on)
        Lighting.FogEnd=on and 100 or 100000
        Lighting.FogStart=on and 0 or 0
        Lighting.FogColor=Color3.fromRGB(200,200,200)
    end)
    makeSlider(worldPage,"Brightness",0,10,2,function(v) Lighting.Brightness=v end)
    makeToggle(worldPage,"Freeze NPCs","Anchor all NPC models in the world",function(on)
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local isPlayer=false
                for _,p in ipairs(Players:GetPlayers()) do
                    if p.Character and obj:IsDescendantOf(p.Character) then isPlayer=true; break end
                end
                if not isPlayer then obj.Anchored=on end
            end
        end
    end)
end

-- ── TELEPORT ──────────────────────────────────────────────────────────
do
    local hdr=card(tpPage,50); mkStroke(hdr,C.teal,1)
    mkLabel(hdr,{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,14,0,6),Text="🌀  Teleport",TextSize=14,TextColor3=C.teal})
    mkLabel(hdr,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,14,0,28),Text="Teleport to players or saved waypoints",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub})

    local tpTarget=nil
    local _,_,setTPS,getTPS=makePlayerList(tpPage,150,function(p,ss) tpTarget=p; ss("✅  Will teleport to: "..p.Name,C.teal) end)
    local tpCard=card(tpPage,48); mkStroke(tpCard,C.teal,1)
    local tpBtn=mkBtn(tpCard,{Size=UDim2.new(1,-20,0,32),Position=UDim2.new(0,10,0.5,-16),BackgroundColor3=C.teal,Text="🌀  Teleport to Player",TextColor3=Color3.new(1,1,1),TextSize=13}); mkCorner(tpBtn,8)
    tpBtn.MouseButton1Click:Connect(function()
        local t=getTPS(); if not t then setTPS("⚠️  Select a player first!",C.yellow); return end
        local tch=t.Character; if not tch then setTPS("⚠️  Player has no character!",C.yellow); return end
        local thrp=tch:FindFirstChild("HumanoidRootPart"); if not thrp then return end
        local myHRP=getHRP(); if not myHRP then return end
        myHRP.CFrame=CFrame.new(thrp.Position+thrp.CFrame.LookVector*-3+Vector3.new(0,0.5,0))
        setTPS("✅  Teleported to "..t.Name.."!",C.green)
        TweenService:Create(tpBtn,TW,{BackgroundColor3=C.green}):Play()
        task.delay(0.4,function() TweenService:Create(tpBtn,TW,{BackgroundColor3=C.teal}):Play() end)
    end)

    elemOrd+=1
    local wpHdr=mkFrame(tpPage,{Size=UDim2.new(1,0,0,34),BackgroundColor3=C.card,LayoutOrder=elemOrd}); mkCorner(wpHdr,10); mkStroke(wpHdr,C.border)
    mkLabel(wpHdr,{Size=UDim2.new(1,-136,1,0),Position=UDim2.new(0,12,0,0),Text="📍  Waypoints",TextSize=12,TextColor3=C.text})
    local saveBtn=mkBtn(wpHdr,{Size=UDim2.new(0,78,0,22),Position=UDim2.new(1,-134,0.5,-11),BackgroundColor3=C.green,Text="+ Save Here",TextColor3=Color3.new(1,1,1),TextSize=10}); mkCorner(saveBtn,6)
    local clrBtn=mkBtn(wpHdr,{Size=UDim2.new(0,46,0,22),Position=UDim2.new(1,-50,0.5,-11),BackgroundColor3=C.red,Text="Clear",TextColor3=Color3.new(1,1,1),TextSize=10}); mkCorner(clrBtn,6)

    elemOrd+=1
    local wpOuter=mkFrame(tpPage,{Size=UDim2.new(1,0,0,160),BackgroundColor3=Color3.fromRGB(18,18,28),LayoutOrder=elemOrd,ClipsDescendants=true}); mkCorner(wpOuter,10); mkStroke(wpOuter,C.border)
    local wpSF=Instance.new("ScrollingFrame"); wpSF.Size=UDim2.new(1,0,1,0); wpSF.BackgroundTransparency=1; wpSF.BorderSizePixel=0
    wpSF.ScrollBarThickness=5; wpSF.ScrollBarImageColor3=C.teal; wpSF.CanvasSize=UDim2.new(0,0,0,0)
    wpSF.AutomaticCanvasSize=Enum.AutomaticSize.Y; wpSF.ScrollingDirection=Enum.ScrollingDirection.Y; wpSF.Parent=wpOuter
    do
        local ul=Instance.new("UIListLayout"); ul.SortOrder=Enum.SortOrder.LayoutOrder; ul.Padding=UDim.new(0,4); ul.Parent=wpSF
        local up=Instance.new("UIPadding"); up.PaddingLeft=UDim.new(0,6); up.PaddingRight=UDim.new(0,10); up.PaddingTop=UDim.new(0,6); up.PaddingBottom=UDim.new(0,6); up.Parent=wpSF
    end
    local waypoints={}; local wpCount=0
    local function rebuildWP()
        for _,c in ipairs(wpSF:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end
        if #waypoints==0 then
            mkLabel(wpSF,{Size=UDim2.new(1,0,0,44),Text="No waypoints yet — press '+ Save Here'",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub,TextXAlignment=Enum.TextXAlignment.Center})
            return
        end
        for i,wp in ipairs(waypoints) do
            local row=mkFrame(wpSF,{Size=UDim2.new(1,0,0,40),BackgroundColor3=C.row,LayoutOrder=i}); mkCorner(row,8)
            local ic=mkFrame(row,{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,6,0.5,-14),BackgroundColor3=C.teal}); mkCorner(ic,14)
            mkLabel(ic,{Size=UDim2.new(1,0,1,0),Text="📍",TextSize=13,TextXAlignment=Enum.TextXAlignment.Center})
            mkLabel(row,{Size=UDim2.new(1,-134,0,18),Position=UDim2.new(0,42,0,4),Text=wp.name,TextSize=12,TextColor3=C.text})
            mkLabel(row,{Size=UDim2.new(1,-134,0,14),Position=UDim2.new(0,42,0,22),Text=string.format("%.0f, %.0f, %.0f",wp.pos.X,wp.pos.Y,wp.pos.Z),TextSize=10,Font=Enum.Font.Gotham,TextColor3=C.sub})
            local goBtn=mkBtn(row,{Size=UDim2.new(0,36,0,24),Position=UDim2.new(1,-82,0.5,-12),BackgroundColor3=C.teal,Text="Go",TextColor3=Color3.new(1,1,1),TextSize=11}); mkCorner(goBtn,6)
            goBtn.MouseButton1Click:Connect(function()
                local hrp=getHRP(); if not hrp then return end
                hrp.CFrame=CFrame.new(wp.pos+Vector3.new(0,0.5,0))
                TweenService:Create(goBtn,TW,{BackgroundColor3=C.green}):Play()
                task.delay(0.4,function() TweenService:Create(goBtn,TW,{BackgroundColor3=C.teal}):Play() end)
            end)
            local delBtn=mkBtn(row,{Size=UDim2.new(0,36,0,24),Position=UDim2.new(1,-40,0.5,-12),BackgroundColor3=Color3.fromRGB(80,0,0),Text="✕",TextColor3=Color3.new(1,1,1),TextSize=11}); mkCorner(delBtn,6)
            delBtn.MouseButton1Click:Connect(function()
                table.remove(waypoints,i); rebuildWP()
            end)
        end
    end
    rebuildWP()
    saveBtn.MouseButton1Click:Connect(function()
        local hrp=getHRP(); if not hrp then return end
        wpCount+=1; table.insert(waypoints,{name="Waypoint "..wpCount,pos=hrp.Position})
        rebuildWP()
        TweenService:Create(saveBtn,TW,{BackgroundColor3=C.accent}):Play()
        task.delay(0.4,function() TweenService:Create(saveBtn,TW,{BackgroundColor3=C.green}):Play() end)
    end)
    clrBtn.MouseButton1Click:Connect(function()
        waypoints={}; wpCount=0; rebuildWP()
        TweenService:Create(clrBtn,TW,{BackgroundColor3=C.orange}):Play()
        task.delay(0.4,function() TweenService:Create(clrBtn,TW,{BackgroundColor3=C.red}):Play() end)
    end)
end

-- ── AIM ASSIST ────────────────────────────────────────────────────────
do
    local function aimToggleRow(page,name,sub,cb)
        makeToggle(page,name,sub,cb)
    end
    local aimHdr=card(aimPage,50); mkStroke(aimHdr,C.yellow,1)
    mkLabel(aimHdr,{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,14,0,6),Text="🎯  Aim Assist",TextSize=14,TextColor3=C.yellow})
    mkLabel(aimHdr,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,14,0,28),Text="Auto-pull camera toward nearest enemy",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub})
    aimToggleRow(aimPage,"Enable Aim Assist","Auto-pull camera toward nearest enemy",function(on) aimOn=on end)
    aimToggleRow(aimPage,"Hold RMB Only","Only active while right-click is held",function(on) aimHoldOnly=on end)
    aimToggleRow(aimPage,"Aim at Head","Target head instead of body center",function(on) aimHead=on end)
    makeSlider(aimPage,"FOV Cone",5,90,25,function(v) aimFOV=v end)
    makeSlider(aimPage,"Smoothness",1,20,8,function(v) aimSmooth=v end)
    makeSlider(aimPage,"Max Distance",20,500,150,function(v) aimDist=v end)
end

-- ══════════════════════════════════════════════════════════════════════
--  SERVER STATS TAB (NEW)
-- ══════════════════════════════════════════════════════════════════════
do
    local statHdr=card(statsPage,50); mkStroke(statHdr,C.accent,1.5)
    mkLabel(statHdr,{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,14,0,6),Text="📊  Server Stats",TextSize=14,TextColor3=C.accent})
    mkLabel(statHdr,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,14,0,28),Text="Live information about this server session",TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub})

    -- Helper to make a live stat row
    local statRows={}
    local function makeStatRow(icon, label, initVal, color)
        local f=card(statsPage,52)
        local iconLbl=mkLabel(f,{Size=UDim2.new(0,28,1,0),Position=UDim2.new(0,10,0,0),Text=icon,TextSize=16,TextColor3=color or C.accent,TextXAlignment=Enum.TextXAlignment.Center})
        mkLabel(f,{Size=UDim2.new(0.5,0,0,18),Position=UDim2.new(0,42,0,8),Text=label,TextSize=11,Font=Enum.Font.Gotham,TextColor3=C.sub})
        local valLbl=mkLabel(f,{Size=UDim2.new(1,-52,0,20),Position=UDim2.new(0,42,0,26),Text=initVal,TextSize=14,TextColor3=color or C.text})
        table.insert(statRows,{lbl=valLbl})
        return valLbl
    end

    local playerCountLbl  = makeStatRow("👥","Players in Server","--",C.green)
    local serverUptimeLbl = makeStatRow("⏱️","Server Uptime","--",C.yellow)
    local pingLbl         = makeStatRow("📡","Your Ping","--",C.teal)
    local fpsStatLbl      = makeStatRow("🖥️","Your FPS","--",C.purple)
    local placeIdLbl      = makeStatRow("🎮","Place ID",tostring(game.PlaceId),C.accent)
    local jobIdLbl        = makeStatRow("🔑","Server Job ID",string.sub(game.JobId,1,16).."...",C.sub)

    -- Refresh button
    local refreshCard=card(statsPage,48); mkStroke(refreshCard,C.accent,1)
    local refreshStatsBtn=mkBtn(refreshCard,{Size=UDim2.new(1,-20,0,32),Position=UDim2.new(0,10,0.5,-16),BackgroundColor3=C.accent,Text="↺  Refresh Stats",TextColor3=Color3.new(1,1,1),TextSize=13}); mkCorner(refreshStatsBtn,8)

    local statsFpsCount=0; local statsFpsClock=0; local statsFpsVal=0

    local function updateStats()
        -- Players
        playerCountLbl.Text=tostring(#Players:GetPlayers()).." / "..tostring(game.Players.MaxPlayers)
        -- Uptime
        local elapsed=os.time()-scriptStartTime
        local mins=math.floor(elapsed/60); local secs=elapsed%60
        serverUptimeLbl.Text=string.format("%dm %02ds",mins,secs)
        -- Ping
        local ping=math.floor(ME:GetNetworkPing()*1000)
        pingLbl.Text=ping.."ms"
        pingLbl.TextColor3 = ping<80 and C.green or (ping<180 and C.yellow or C.red)
        -- FPS
        fpsStatLbl.Text=tostring(statsFpsVal).." FPS"
        fpsStatLbl.TextColor3 = statsFpsVal>=50 and C.green or (statsFpsVal>=30 and C.yellow or C.red)
    end

    -- Fast FPS counter for stats tab
    RunService.Heartbeat:Connect(function(dt)
        statsFpsCount+=1; statsFpsClock+=dt
        if statsFpsClock>=0.5 then
            statsFpsVal=math.floor(statsFpsCount/statsFpsClock)
            statsFpsCount=0; statsFpsClock=0
        end
    end)

    -- Auto-update every second
    RunService.Heartbeat:Connect(function()
        -- throttle to ~1 per second using os.clock
    end)
    task.spawn(function()
        while SG.Parent do
            updateStats()
            task.wait(1)
        end
    end)

    refreshStatsBtn.MouseButton1Click:Connect(function()
        updateStats()
        TweenService:Create(refreshStatsBtn,TW,{BackgroundColor3=C.green}):Play()
        task.delay(0.4,function() TweenService:Create(refreshStatsBtn,TW,{BackgroundColor3=C.accent}):Play() end)
    end)
end

-- ── SETTINGS (Anti-AFK etc.) ──────────────────────────────────────────
makeToggle(settingsPage,"Anti-AFK","Prevent being kicked for inactivity",function(on) afkOn=on end)

-- ══════════════════════════════════════════════════════════════════════
--  MAIN HEARTBEAT LOOP
-- ══════════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    -- ── Fly ──
    if fly and bv and bv.Parent then
        local cam=workspace.CurrentCamera; local d=Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then d+=cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then d-=cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then d-=cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then d+=cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then d+=Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then d-=Vector3.yAxis end
        bv.Velocity=(d.Magnitude>0 and d.Unit or Vector3.zero)*flySpeed
        bg2.CFrame=cam.CFrame
    end

    -- ── Noclip ──
    if nc then local ch=getChar(); if ch then for _,p in ipairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end
    if god then local h=getHum(); if h then h.Health=h.MaxHealth end end

    if espOn then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=ME then
                if p.Character and not espHL[p] then addESP(p)
                elseif not p.Character and espHL[p] then remESP(p) end
            end
        end
    end
    if invisOn then
        local ch=getChar(); if ch then
            for _,p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.LocalTransparencyModifier=1 end
            end
        end
    end

    -- ── Swim in Air ──
    if swimAirOn then
        local hrp=getHRP()
        if hrp and swimBV and swimBV.Parent then
            local cam=workspace.CurrentCamera; local d=Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then d+=cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then d-=cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then d-=cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then d+=cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then d+=Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then d-=Vector3.yAxis end
            local target=(d.Magnitude>0 and d.Unit or Vector3.zero)*20
            swimBV.Velocity=swimBV.Velocity:Lerp(target,0.08)
        end
    end

    -- ── Jetpack ──
    if jetpackOn and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local hrp=getHRP()
        if hrp then
            if not jetpackBV or not jetpackBV.Parent then
                jetpackBV=Instance.new("BodyVelocity"); jetpackBV.Name="kAaMsJetBV"
                jetpackBV.MaxForce=Vector3.new(0,1e5,0); jetpackBV.P=5000; jetpackBV.Parent=hrp
            end
            jetpackBV.Velocity=Vector3.new(0,math.min((jetpackBV.Velocity.Y or 0)+2,80),0)
        end
    elseif jetpackOn then
        if jetpackBV and jetpackBV.Parent then jetpackBV:Destroy(); jetpackBV=nil end
    end

    -- ── Superhero Landing ──
    if heroLandOn then
        local hrp=getHRP()
        if hrp then
            local velY=hrp.Velocity.Y
            local inAir=math.abs(velY)>1
            if heroWasAir and not inAir and heroLastY<-30 then
                task.spawn(function()
                    for i=1,6 do
                        local ring=Instance.new("Part"); ring.Shape=Enum.PartType.Cylinder
                        ring.Size=Vector3.new(0.3,i*4,i*4); ring.CFrame=CFrame.new(hrp.Position)*CFrame.Angles(0,0,math.pi/2)
                        ring.Anchored=true; ring.CanCollide=false; ring.CastShadow=false
                        ring.BrickColor=BrickColor.new("White"); ring.Material=Enum.Material.Neon
                        ring.Parent=workspace
                        task.delay(0.4,function() if ring.Parent then ring:Destroy() end end)
                    end
                    local cam=workspace.CurrentCamera
                    for _=1,8 do
                        cam.CFrame=cam.CFrame*CFrame.new(math.random(-1,1)*0.3,math.random(-1,1)*0.3,0)
                        task.wait(0.04)
                    end
                end)
            end
            heroWasAir=inAir; heroLastY=velY
        end
    end

    -- ── Coordinates HUD ──
    if coordsOn and coordsLabel and coordsLabel.Parent then
        local hrp=getHRP()
        if hrp then
            local p=hrp.Position
            coordsLabel.Text=string.format("X: %.1f  Y: %.1f  Z: %.1f",p.X,p.Y,p.Z)
        end
    end
end)

-- ── FPS + PING LOOP ──────────────────────────────────────────────────
local fpsCounter=0; local fpsClock=0
RunService.Heartbeat:Connect(function(dt)
    fpsCounter+=1; fpsClock+=dt
    if fpsClock>=0.5 then
        if fpsOn and fpsLabel and fpsLabel.Parent then
            local fps=math.floor(fpsCounter/fpsClock)
            local ping=math.floor(ME:GetNetworkPing()*1000)
            fpsLabel.Text=string.format("FPS: %d  Ping: %dms",fps,ping)
            fpsLabel.TextColor3=fps>=50 and C.green or (fps>=30 and C.yellow or C.red)
        end
        fpsCounter=0; fpsClock=0
    end
end)

-- ── ANTI-AFK LOOP ─────────────────────────────────────────────────────
task.spawn(function()
    while true do
        task.wait(270)
        if afkOn then
            local hum=getHum()
            if hum then
                hum:Move(Vector3.new(0.5,0,0),false)
                task.wait(0.15)
                hum:Move(Vector3.new(-0.5,0,0),false)
                task.wait(0.15)
                hum:Move(Vector3.new(0,0,0),false)
            end
        end
    end
end)

-- ── AIM ASSIST LOOP ───────────────────────────────────────────────────
RunService:BindToRenderStep("kAaMsAimAssist",Enum.RenderPriority.Camera.Value+1,function()
    if not aimOn then aimLockedTarget=nil; return end
    if aimHoldOnly and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        aimLockedTarget=nil; return
    end
    local target=aimFindTarget()
    if not target then return end
    local cam=workspace.CurrentCamera
    local camPos=cam.CFrame.Position
    local toTarget=(target.Position-camPos).Unit
    local lockedCF=CFrame.lookAt(camPos,camPos+toTarget)
    local factor=math.clamp(aimSmooth/20,0.05,1)
    cam.CFrame=cam.CFrame:Lerp(lockedCF,factor)
end)

-- ══════════════════════════════════════════════════════════════════════
--  INPUT HANDLER
-- ══════════════════════════════════════════════════════════════════════
UserInputService.JumpRequest:Connect(function()
    if infJump then local h=getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

UserInputService.InputBegan:Connect(function(inp,gp)
    if gp then return end
    -- Hub toggle
    if inp.KeyCode==Enum.KeyCode.Five then WIN.Visible=not WIN.Visible end
    -- Blink Dash (Q key)
    if inp.KeyCode==Enum.KeyCode.Q then doBlink() end
end)

-- ══════════════════════════════════════════════════════════════════════
--  CHARACTER RESPAWN CLEANUP
-- ══════════════════════════════════════════════════════════════════════
ME.CharacterAdded:Connect(function(ch)
    fly=false; bv=nil; bg2=nil; floatOn=false; floatBV=nil
    spinOn=false; rainbowOn=false; trailOn=false; invisOn=false
    blinkCooldown=false; dodgeCooldown=false
    if spinConn then spinConn:Disconnect(); spinConn=nil end
    if rainbowConn then rainbowConn:Disconnect(); rainbowConn=nil end
    -- Re-hook auto-dodge on new character
    if autoDodgeOn then
        task.wait(0.5)
        startAutoDodge()
    end
    -- Re-hook punch force on new character
    if punchForceOn then
        task.wait(0.5)
        cleanPunchConns()
        startPunchForce()
    end
    -- Re-apply name tag on new character
    if nameTagOn then
        task.wait(0.5)
        applyNameTag()
    end
    local h=ch:WaitForChild("Humanoid",5); if h then h.PlatformStand=false end
end)