-- ╔══════════════════════════════════════════════════════╗
-- ║           ARISE CROSSOVER HUB — REAL EXECUTOR        ║
-- ║      Atualizado até: Arquiteto Update (Nov 2026)     ║
-- ╚══════════════════════════════════════════════════════╝

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local UIS            = game:GetService("UserInputService")
local RS             = game:GetService("ReplicatedStorage")
local lp             = Players.LocalPlayer
local gui            = lp:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════════
--  ESTADO GLOBAL
-- ══════════════════════════════════════════════════════
local S = {
    -- Farm
    AutoFarm        = false,
    AutoArise       = false,
    AutoSell        = false,
    AntiAFK         = false,
    -- Dungeon
    AutoDungeon     = false,
    AutoRankUp      = false,
    AutoInfernal    = false,
    AutoBloodmoon   = false,
    AutoEclipse     = false,
    AutoArquiteto   = false,
    TargetRank      = "S",
    -- Raid
    AutoRaid        = false,
    AutoHalloween   = false,
    AutoTrickOrTreat= false,
    -- Misc
    Noclip          = false,
    SpeedHack       = false,
    SpeedValue      = 32,
    InfLoop         = false,
    AutoEnchant     = false,
    AutoInfuse      = false,
    AutoClaimExp    = false,
    AutoCollectAFK  = false,
    OpenKey         = Enum.KeyCode.RightShift,
}

local RANKS = {
    "E","D","C","B","A","S","SS",
    "G","GM","N","N+",
    "HSR","HSR+","UGM",
    "MR","MR+","GR","GR+","GL","GL+"
}

-- ══════════════════════════════════════════════════════
--  UTILIDADES
-- ══════════════════════════════════════════════════════
local function getChar()
    return lp.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChild("Humanoid")
end

local function safeTP(pos)
    local hrp = getHRP()
    if not hrp then return end
    local offset = Vector3.new(math.random(-2,2), 2, math.random(-2,2))
    hrp.CFrame = CFrame.new(pos + offset)
    task.wait(0.08)
end

-- scan geral de mobs em todo workspace
local function getAllMobs()
    local mobs = {}
    local MOB_FOLDERS = {"Enemies","Mobs","NPCs","Monsters","Gates","Enemies_Folder"}
    -- tenta pastas conhecidas primeiro
    for _, fname in ipairs(MOB_FOLDERS) do
        local f = workspace:FindFirstChild(fname)
        if f then
            for _, m in ipairs(f:GetChildren()) do
                local mhrp = m:FindFirstChild("HumanoidRootPart")
                local mhum = m:FindFirstChild("Humanoid")
                if mhrp and mhum and mhum.Health > 0 then
                    table.insert(mobs, m)
                end
            end
        end
    end
    -- fallback: scan completo
    if #mobs == 0 then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") then
                local mhrp = v:FindFirstChild("HumanoidRootPart")
                local mhum = v:FindFirstChild("Humanoid")
                if mhrp and mhum and mhum.Health > 0 and v ~= getChar() then
                    -- filtra players
                    local isPlayer = false
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.Character == v then isPlayer = true; break end
                    end
                    if not isPlayer then
                        table.insert(mobs, v)
                    end
                end
            end
        end
    end
    return mobs
end

local function getNearestMob()
    local hrp = getHRP()
    if not hrp then return nil end
    local best, bd = nil, math.huge
    for _, mob in ipairs(getAllMobs()) do
        local mhrp = mob:FindFirstChild("HumanoidRootPart")
        if mhrp then
            local d = (hrp.Position - mhrp.Position).Magnitude
            if d < bd then best, bd = mob, d end
        end
    end
    return best
end

-- fire remote por nome (scan em todo RS)
local function fireRemote(name, ...)
    for _, v in ipairs(RS:GetDescendants()) do
        if v.Name == name and v:IsA("RemoteEvent") then
            pcall(function() v:FireServer(...) end)
            return true
        end
    end
    return false
end

local function findPart(keywords)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local n = v.Name:lower()
            for _, kw in ipairs(keywords) do
                if n:find(kw:lower()) then return v end
            end
        end
    end
end

local function firePrompt(part)
    if not part then return end
    local pr = part:FindFirstChildOfClass("ProximityPrompt")
        or part.Parent and part.Parent:FindFirstChildOfClass("ProximityPrompt")
    if pr then
        pcall(function() fireproximityprompt(pr) end)
        return true
    end
end

local function killMobs(timeout)
    timeout = timeout or 60
    local t0 = tick()
    while tick() - t0 < timeout do
        if not S.AutoDungeon and not S.AutoFarm then break end
        local mob = getNearestMob()
        if not mob then break end
        local mhrp = mob:FindFirstChild("HumanoidRootPart")
        if mhrp then
            safeTP(mhrp.Position)
            pcall(function()
                fireRemote("Attack", mob)
                fireRemote("DamageEnemy", mob)
                fireRemote("Hit", mob)
            end)
            task.wait(0.3)
            local mhum = mob:FindFirstChild("Humanoid")
            if S.AutoArise and mhum and mhum.Health <= 0 then
                pcall(function() fireRemote("Arise", mob) end)
                task.wait(0.25)
            end
        end
        task.wait(0.05)
    end
end

-- ══════════════════════════════════════════════════════
--  LOOPS DE AUTOMAÇÃO
-- ══════════════════════════════════════════════════════

-- Auto Farm
task.spawn(function()
    while true do
        task.wait(0.1)
        if S.AutoFarm then
            local mob = getNearestMob()
            if mob then
                local mhrp = mob:FindFirstChild("HumanoidRootPart")
                if mhrp then
                    safeTP(mhrp.Position)
                    pcall(function()
                        fireRemote("Attack", mob)
                        fireRemote("DamageEnemy", mob)
                        fireRemote("Hit", mob)
                    end)
                    task.wait(0.3)
                    local mhum = mob:FindFirstChild("Humanoid")
                    if S.AutoArise and mhum and mhum.Health <= 0 then
                        pcall(function() fireRemote("Arise", mob) end)
                        task.wait(0.25)
                    end
                end
            end
        end
    end
end)

-- Auto Sell
task.spawn(function()
    while true do
        task.wait(5)
        if S.AutoSell then
            pcall(function()
                fireRemote("SellAll")
                fireRemote("AutoSell")
                fireRemote("Sell")
            end)
        end
        if S.AutoCollectAFK then
            pcall(function()
                fireRemote("ClaimAFK")
                fireRemote("CollectAFK")
                fireRemote("ClaimAll")
            end)
        end
        if S.AutoEnchant then
            pcall(function()
                fireRemote("AutoEnchant")
                fireRemote("Enchant")
            end)
        end
        if S.AutoInfuse then
            pcall(function()
                fireRemote("AutoInfuse")
                fireRemote("Infuse")
            end)
        end
    end
end)

-- Anti-AFK
task.spawn(function()
    while true do
        task.wait(55)
        if S.AntiAFK then
            pcall(function()
                local vu = Instance.new("VirtualUser")
                vu.Parent = game
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
                vu:Destroy()
            end)
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if S.Noclip then
        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- Speed
RunService.Heartbeat:Connect(function()
    local hum = getHum()
    if hum then
        hum.WalkSpeed = S.SpeedHack and S.SpeedValue or 16
    end
end)

-- Auto Dungeon loop
task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoDungeon then
            -- localiza gate
            local gate = findPart({"dungeongate","dungeon_gate","gate","portal","dungeon"})
            if gate then
                safeTP(gate.Position)
                task.wait(0.5)
                firePrompt(gate)
                task.wait(2)
                for room = 1, 15 do
                    if not S.AutoDungeon then break end
                    killMobs(50)
                    task.wait(0.5)
                    local adv = findPart({"nextroom","nextgate","advance","continue","exit","door"})
                    if adv then
                        safeTP(adv.Position)
                        firePrompt(adv)
                    end
                    task.wait(2)
                end
            end
        end
    end
end)

-- Auto Infernal Castle
task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoInfernal then
            local inf = findPart({"infernalcastle","infernal_castle","infernal","castle"})
            if inf then
                safeTP(inf.Position)
                task.wait(0.5)
                firePrompt(inf)
                task.wait(2)
                killMobs(90)
            end
        end
    end
end)

-- Auto Bloodmoon Manor
task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoBloodmoon then
            local manor = findPart({"bloodmoon","manor","bloodmoonwoods"})
            if manor then
                safeTP(manor.Position)
                task.wait(0.5)
                firePrompt(manor)
                task.wait(2)
                killMobs(90)
                -- coleta selos de sangue
                pcall(function() fireRemote("CollectBloodSeal") end)
            end
        end
    end
end)

-- Auto Eclipse Court Raid
task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoEclipse then
            local eclipse = findPart({"eclipsecourt","eclipse_court","eclipse","court"})
            if eclipse then
                safeTP(eclipse.Position)
                task.wait(0.5)
                firePrompt(eclipse)
                task.wait(2)
                killMobs(120)
            end
        end
    end
end)

-- Auto Arquiteto Dungeon
task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoArquiteto then
            local arq = findPart({"arquiteto","architect","heavenlycastle","heavenly","detritos","debris"})
            if arq then
                safeTP(arq.Position)
                task.wait(0.5)
                firePrompt(arq)
                task.wait(2)
                killMobs(120)
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════
--  CONSTANTES DE COR
-- ══════════════════════════════════════════════════════
local C = {
    bg       = Color3.fromRGB(6,6,8),
    sidebar  = Color3.fromRGB(9,9,12),
    panel    = Color3.fromRGB(11,11,15),
    item     = Color3.fromRGB(15,15,20),
    accent   = Color3.fromRGB(90,210,140),
    accentDim= Color3.fromRGB(40,80,60),
    text     = Color3.fromRGB(215,215,225),
    textDim  = Color3.fromRGB(100,100,120),
    border   = Color3.fromRGB(28,28,38),
    red      = Color3.fromRGB(200,50,50),
    white    = Color3.fromRGB(255,255,255),
    tabSel   = Color3.fromRGB(18,18,26),
    tabDim   = Color3.fromRGB(9,9,12),
}

-- ══════════════════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name           = "AriseHub"
sg.ResetOnSpawn   = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = gui

-- janela
local win = Instance.new("Frame", sg)
win.Name              = "Window"
win.Size              = UDim2.new(0, 620, 0, 460)
win.Position          = UDim2.new(0.5,-310,0.5,-230)
win.BackgroundColor3  = C.bg
win.BorderSizePixel   = 0
win.Active            = true
Instance.new("UICorner",win).CornerRadius = UDim.new(0,10)
local wStroke = Instance.new("UIStroke",win)
wStroke.Color = C.border; wStroke.Thickness = 1

-- topbar
local top = Instance.new("Frame",win)
top.Size            = UDim2.new(1,0,0,38)
top.BackgroundColor3= C.sidebar
top.BorderSizePixel = 0
Instance.new("UICorner",top).CornerRadius = UDim.new(0,10)

local topFix = Instance.new("Frame",top)
topFix.Size             = UDim2.new(1,0,0,10)
topFix.Position         = UDim2.new(0,0,1,-10)
topFix.BackgroundColor3 = C.sidebar
topFix.BorderSizePixel  = 0

local topTitle = Instance.new("TextLabel",top)
topTitle.Size               = UDim2.new(1,-80,1,0)
topTitle.Position           = UDim2.new(0,14,0,0)
topTitle.BackgroundTransparency = 1
topTitle.Text               = "⚔  Arise Hub  ·  Real Executor"
topTitle.TextColor3         = C.text
topTitle.TextSize           = 14
topTitle.Font               = Enum.Font.GothamBold
topTitle.TextXAlignment     = Enum.TextXAlignment.Left

local function makeTopBtn(symbol, color, posX, cb)
    local b = Instance.new("TextButton",top)
    b.Size             = UDim2.new(0,24,0,24)
    b.Position         = UDim2.new(1,posX,0.5,-12)
    b.BackgroundColor3 = color
    b.Text             = symbol
    b.TextColor3       = C.white
    b.TextSize         = 11
    b.Font             = Enum.Font.GothamBold
    b.BorderSizePixel  = 0
    Instance.new("UICorner",b).CornerRadius = UDim.new(1,0)
    b.MouseButton1Click:Connect(cb)
    return b
end
makeTopBtn("✕", C.red,     -8,  function() win.Visible = false end)
makeTopBtn("−", C.border,  -36, function()
    win.Size = win.Size == UDim2.new(0,620,0,460)
        and UDim2.new(0,620,0,38)
        or  UDim2.new(0,620,0,460)
end)

-- drag
local dragging, dragStart, startPos
top.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = inp.Position; startPos = win.Position
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragStart
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                  startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- sidebar
local sidebar = Instance.new("Frame",win)
sidebar.Size             = UDim2.new(0,110,1,-38)
sidebar.Position         = UDim2.new(0,0,0,38)
sidebar.BackgroundColor3 = C.sidebar
sidebar.BorderSizePixel  = 0
local sideList = Instance.new("UIListLayout",sidebar)
sideList.SortOrder = Enum.SortOrder.LayoutOrder

local sideDivider = Instance.new("Frame",win)
sideDivider.Size             = UDim2.new(0,1,1,-38)
sideDivider.Position         = UDim2.new(0,110,0,38)
sideDivider.BackgroundColor3 = C.border
sideDivider.BorderSizePixel  = 0

-- content area
local contentArea = Instance.new("Frame",win)
contentArea.Size             = UDim2.new(1,-111,1,-38)
contentArea.Position         = UDim2.new(0,111,0,38)
contentArea.BackgroundColor3 = C.bg
contentArea.BorderSizePixel  = 0
Instance.new("UICorner",contentArea).CornerRadius = UDim.new(0,8)

-- ══════════════════════════════════════════════════════
--  HELPERS DE COMPONENTE
-- ══════════════════════════════════════════════════════
local tabs    = {}
local tabBtns = {}

local function makeScroll(parent)
    local s = Instance.new("ScrollingFrame",parent)
    s.Size                   = UDim2.new(1,0,1,0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel        = 0
    s.ScrollBarThickness     = 3
    s.ScrollBarImageColor3   = C.border
    s.CanvasSize             = UDim2.new(0,0,0,0)
    s.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    s.Visible                = false
    local pad = Instance.new("UIPadding",s)
    pad.PaddingLeft  = UDim.new(0,10)
    pad.PaddingRight = UDim.new(0,10)
    pad.PaddingTop   = UDim.new(0,10)
    local layout = Instance.new("UIListLayout",s)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding   = UDim.new(0,5)
    return s
end

local function sectionLabel(parent, text, order)
    local f = Instance.new("Frame",parent)
    f.Size             = UDim2.new(1,0,0,22)
    f.BackgroundTransparency = 1
    f.LayoutOrder      = order or 0
    local l = Instance.new("TextLabel",f)
    l.Size               = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.Text               = "  "..text:upper()
    l.TextColor3         = C.accentDim
    l.TextSize           = 10
    l.Font               = Enum.Font.GothamBold
    l.TextXAlignment     = Enum.TextXAlignment.Left
    -- linha
    local line = Instance.new("Frame",f)
    line.Size             = UDim2.new(1,-10,0,1)
    line.Position         = UDim2.new(0,5,1,-1)
    line.BackgroundColor3 = C.border
    line.BorderSizePixel  = 0
    return f
end

local function makeToggle(parent, label, key, order)
    local row = Instance.new("Frame",parent)
    row.Size             = UDim2.new(1,0,0,34)
    row.BackgroundColor3 = C.item
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order or 0
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,7)
    local stroke = Instance.new("UIStroke",row)
    stroke.Color = C.border; stroke.Thickness = 1

    local lbl = Instance.new("TextLabel",row)
    lbl.Size               = UDim2.new(1,-54,1,0)
    lbl.Position           = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = C.text
    lbl.TextSize           = 13
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left

    local pill = Instance.new("Frame",row)
    pill.Size             = UDim2.new(0,38,0,20)
    pill.Position         = UDim2.new(1,-48,0.5,-10)
    pill.BackgroundColor3 = Color3.fromRGB(30,30,38)
    pill.BorderSizePixel  = 0
    Instance.new("UICorner",pill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame",pill)
    knob.Size             = UDim2.new(0,14,0,14)
    knob.Position         = UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3 = Color3.fromRGB(140,140,160)
    knob.BorderSizePixel  = 0
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

    local function refresh()
        local on = S[key]
        TweenService:Create(pill,TweenInfo.new(0.15),{
            BackgroundColor3 = on and C.accent or Color3.fromRGB(30,30,38)
        }):Play()
        TweenService:Create(knob,TweenInfo.new(0.15),{
            Position         = on and UDim2.new(0,21,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3 = on and C.white or Color3.fromRGB(140,140,160)
        }):Play()
        stroke.Color = S[key] and C.accentDim or C.border
    end

    row.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            S[key] = not S[key]; refresh()
        end
    end)
    refresh()
    return row
end

local function makeButton(parent, label, cb, order)
    local btn = Instance.new("TextButton",parent)
    btn.Size             = UDim2.new(1,0,0,34)
    btn.BackgroundColor3 = C.item
    btn.Text             = label
    btn.TextColor3       = C.text
    btn.TextSize         = 13
    btn.Font             = Enum.Font.Gotham
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = order or 0
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,7)
    local stroke = Instance.new("UIStroke",btn)
    stroke.Color = C.border; stroke.Thickness = 1
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,30)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.item}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        pcall(cb)
    end)
    return btn
end

local function makeDropdown(parent, label, options, stateKey, order)
    local wrap = Instance.new("Frame",parent)
    wrap.Size             = UDim2.new(1,0,0,34)
    wrap.BackgroundColor3 = C.item
    wrap.BorderSizePixel  = 0
    wrap.LayoutOrder      = order or 0
    Instance.new("UICorner",wrap).CornerRadius = UDim.new(0,7)
    Instance.new("UIStroke",wrap).Color = C.border

    local lbl = Instance.new("TextLabel",wrap)
    lbl.Size               = UDim2.new(0.55,0,1,0)
    lbl.Position           = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = C.text
    lbl.TextSize           = 13
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left

    local idx = table.find(options, S[stateKey]) or 1
    local sel = Instance.new("TextButton",wrap)
    sel.Size             = UDim2.new(0.42,0,0,24)
    sel.Position         = UDim2.new(0.57,0,0.5,-12)
    sel.BackgroundColor3 = Color3.fromRGB(18,18,26)
    sel.Text             = options[idx]
    sel.TextColor3       = C.accent
    sel.TextSize         = 12
    sel.Font             = Enum.Font.GothamBold
    sel.BorderSizePixel  = 0
    Instance.new("UICorner",sel).CornerRadius = UDim.new(0,5)

    sel.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        sel.Text = options[idx]
        S[stateKey] = options[idx]
    end)
    return wrap
end

local function makeSlider(parent, label, min, max, stateKey, order)
    local wrap = Instance.new("Frame",parent)
    wrap.Size             = UDim2.new(1,0,0,46)
    wrap.BackgroundColor3 = C.item
    wrap.BorderSizePixel  = 0
    wrap.LayoutOrder      = order or 0
    Instance.new("UICorner",wrap).CornerRadius = UDim.new(0,7)
    Instance.new("UIStroke",wrap).Color = C.border

    local lbl = Instance.new("TextLabel",wrap)
    lbl.Size               = UDim2.new(0.6,0,0,20)
    lbl.Position           = UDim2.new(0,12,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = C.text
    lbl.TextSize           = 12
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel",wrap)
    valLbl.Size               = UDim2.new(0.35,0,0,20)
    valLbl.Position           = UDim2.new(0.63,0,0,4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text               = tostring(S[stateKey])
    valLbl.TextColor3         = C.accent
    valLbl.TextSize           = 12
    valLbl.Font               = Enum.Font.GothamBold
    valLbl.TextXAlignment     = Enum.TextXAlignment.Right

    local track = Instance.new("Frame",wrap)
    track.Size             = UDim2.new(1,-24,0,6)
    track.Position         = UDim2.new(0,12,0,30)
    track.BackgroundColor3 = Color3.fromRGB(25,25,35)
    track.BorderSizePixel  = 0
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)

    local pct = (S[stateKey]-min)/(max-min)
    local fill = Instance.new("Frame",track)
    fill.Size             = UDim2.new(pct,0,1,0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel  = 0
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

    local draggingSlider = false
    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local val = math.floor(min + rel*(max-min))
        S[stateKey] = val
        valLbl.Text = tostring(val)
        fill.Size = UDim2.new(rel,0,1,0)
    end
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true; update(inp.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
            update(inp.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
    end)
    return wrap
end

-- ══════════════════════════════════════════════════════
--  TAB BUILDER
-- ══════════════════════════════════════════════════════
local function addTab(name, icon, order)
    local scroll = makeScroll(contentArea)
    tabs[name] = scroll

    local btn = Instance.new("TextButton",sidebar)
    btn.Size             = UDim2.new(1,0,0,55)
    btn.BackgroundColor3 = C.tabDim
    btn.BorderSizePixel  = 0
    btn.Text             = icon.."\n"..name
    btn.TextColor3       = C.textDim
    btn.TextSize         = 10
    btn.Font             = Enum.Font.GothamBold
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = order or 0
    tabBtns[name] = btn

    btn.MouseButton1Click:Connect(function()
        for n,s in pairs(tabs) do s.Visible = (n==name) end
        for n,b in pairs(tabBtns) do
            TweenService:Create(b,TweenInfo.new(0.12),{
                BackgroundColor3 = n==name and C.tabSel or C.tabDim,
                TextColor3       = n==name and C.text   or C.textDim,
            }):Play()
        end
    end)
    return scroll
end

-- ══════════════════════════════════════════════════════
--  POPULAR TABS
-- ══════════════════════════════════════════════════════

-- ── FARM ──
local farm = addTab("Farm","🗡",1)
sectionLabel(farm,"Combate",1)
makeToggle(farm,"Auto Farm",          "AutoFarm",   2)
makeToggle(farm,"Auto Arise",         "AutoArise",  3)
makeToggle(farm,"Auto Sell",          "AutoSell",   4)
sectionLabel(farm,"Automação",5)
makeToggle(farm,"Auto Enchant",       "AutoEnchant",6)
makeToggle(farm,"Auto Infuse",        "AutoInfuse", 7)
makeToggle(farm,"Coletar AFK",        "AutoCollectAFK",8)
makeToggle(farm,"Anti-AFK",           "AntiAFK",    9)

-- ── DUNGEON ──
local dung = addTab("Dungeon","🔮",2)
sectionLabel(dung,"Masmorras",1)
makeToggle(dung,"Auto Dungeon",           "AutoDungeon",   2)
makeToggle(dung,"Auto Rank Up",           "AutoRankUp",    3)
makeToggle(dung,"Auto Infernal Castle",   "AutoInfernal",  4)
sectionLabel(dung,"Eventos Night of Monarchs",5)
makeToggle(dung,"Auto Bloodmoon Manor",   "AutoBloodmoon", 6)
makeToggle(dung,"Auto Eclipse Court",     "AutoEclipse",   7)
makeToggle(dung,"Auto Arquiteto",         "AutoArquiteto", 8)
sectionLabel(dung,"Rank Alvo",9)
makeDropdown(dung,"Rank →",RANKS,"TargetRank",10)
sectionLabel(dung,"Ações Rápidas",11)
makeButton(dung,"→ Entrar na Dungeon",function()
    local g = findPart({"dungeongate","gate","portal"})
    if g then safeTP(g.Position); firePrompt(g) end
end,12)
makeButton(dung,"→ Infernal Castle",function()
    local g = findPart({"infernal","castle"})
    if g then safeTP(g.Position); firePrompt(g) end
end,13)
makeButton(dung,"→ Bloodmoon Manor",function()
    local g = findPart({"bloodmoon","manor"})
    if g then safeTP(g.Position); firePrompt(g) end
end,14)
makeButton(dung,"→ Eclipse Court",function()
    local g = findPart({"eclipse","court"})
    if g then safeTP(g.Position); firePrompt(g) end
end,15)
makeButton(dung,"→ Heavenly Castle",function()
    local g = findPart({"heavenly","castle","heavenlycastle"})
    if g then safeTP(g.Position); firePrompt(g) end
end,16)

-- ── RAID ──
local raid = addTab("Raid","☠",3)
sectionLabel(raid,"Raids",1)
makeToggle(raid,"Auto Raid",          "AutoRaid",        2)
makeToggle(raid,"Trick or Treat Gate","AutoTrickOrTreat",3)
makeToggle(raid,"Halloween Raid",     "AutoHalloween",   4)
sectionLabel(raid,"Ações",5)
makeButton(raid,"→ Raid Principal",function()
    local g = findPart({"raid","raidgate","raidportal"})
    if g then safeTP(g.Position); firePrompt(g) end
end,6)
makeButton(raid,"→ Nightmare Kamish",function()
    local g = findPart({"kamish","nightmare","worldboss"})
    if g then safeTP(g.Position) end
end,7)
makeButton(raid,"→ Pumpkin King",function()
    local g = findPart({"pumpkin","pumpkinking"})
    if g then safeTP(g.Position) end
end,8)

-- ── TELEPORT ──
local tp = addTab("Teleport","📍",4)
sectionLabel(tp,"Mobs & Dungeons",1)
makeButton(tp,"→ Mob mais próximo",function()
    local mob = getNearestMob()
    if mob then
        local mhrp = mob:FindFirstChild("HumanoidRootPart")
        if mhrp then safeTP(mhrp.Position) end
    end
end,2)
makeButton(tp,"→ Dungeon Gate",function()
    local g = findPart({"dungeongate","gate"})
    if g then safeTP(g.Position) end
end,3)
makeButton(tp,"→ Rank Up NPC",function()
    local g = findPart({"rankup","rank_up","ranknpc"})
    if g then safeTP(g.Position) end
end,4)
makeButton(tp,"→ Shadow Upgrader",function()
    local g = findPart({"shadowupgrader","shadow_upgrader"})
    if g then safeTP(g.Position) end
end,5)
makeButton(tp,"→ Arquiteto Boss",function()
    local g = findPart({"arquiteto","architect"})
    if g then safeTP(g.Position) end
end,6)
sectionLabel(tp,"Ilhas",7)
local islands = {
    {"Solo City",         {"solocity","solo_city","solo city"}},
    {"Leveling City",     {"levelingcity","leveling_city"}},
    {"Grass Village",     {"grass","village","grassvillage"}},
    {"Brum Island",       {"brum","brumisland"}},
    {"Mori Town",         {"mori","moritown"}},
    {"Ghoul Island",      {"ghoul","ghoulistland"}},
    {"XZ City",           {"xz","xzcity"}},
    {"Ilha 30",           {"ilha30","island30"}},
    {"Blood Moonwoods",   {"moonwoods","bloodmoon","manor"}},
    {"Eclipse Paradise",  {"paradise","eclipse","eclipseisland"}},
    {"Abismo de Detritos",{"detritos","debris","abismo","island33"}},
}
for i, isl in ipairs(islands) do
    makeButton(tp,"→ "..isl[1],function()
        local g = findPart(isl[2])
        if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position) end
    end, 7+i)
end

-- ── MISC ──
local misc = addTab("Misc","🛠",5)
sectionLabel(misc,"Movimento",1)
makeToggle(misc,"Noclip",    "Noclip",    2)
makeToggle(misc,"Speed Hack","SpeedHack", 3)
makeSlider(misc,"Velocidade",16,300,"SpeedValue",4)
sectionLabel(misc,"Utilitários",5)
makeButton(misc,"Rejoin Server",function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,lp)
end,6)
makeButton(misc,"Copy Player ID",function()
    setclipboard(tostring(lp.UserId))
end,7)
makeButton(misc,"Print Remotes",function()
    for _,v in ipairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            print("[Remote]", v:GetFullName())
        end
    end
end,8)

-- ── SETTINGS ──
local set = addTab("Config","⚙",6)
sectionLabel(set,"Keybind",1)
local keyBtn = makeButton(set,"Tecla: RightShift",function() end,2)
local listening = false
keyBtn.MouseButton1Click:Connect(function()
    listening = true
    keyBtn.Text = "Pressione uma tecla..."
    keyBtn.TextColor3 = C.accent
end)
UIS.InputBegan:Connect(function(inp)
    if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
        S.OpenKey = inp.KeyCode
        keyBtn.Text = "Tecla: "..tostring(inp.KeyCode.Name)
        keyBtn.TextColor3 = C.text
        listening = false
    end
end)
sectionLabel(set,"Info",3)
local info = Instance.new("TextLabel",set)
info.Size               = UDim2.new(1,0,0,60)
info.BackgroundTransparency = 1
info.Text               = "Arise Hub\nAtualizado até: Arquiteto Update (Nov 2026)\nExecutor: Real"
info.TextColor3         = C.textDim
info.TextSize           = 11
info.Font               = Enum.Font.Gotham
info.TextXAlignment     = Enum.TextXAlignment.Left
info.TextWrapped        = true
info.LayoutOrder        = 4

-- abre na primeira tab
tabBtns["Farm"]:MouseButton1Click()

-- ══════════════════════════════════════════════════════
--  TOGGLE GLOBAL
-- ══════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode == S.OpenKey then
        win.Visible = not win.Visible
    end
end)


-- ══════════════════════════════════════════════════════
--  AUTO EXECUTE
-- ══════════════════════════════════════════════════════
local AUTO_EXEC_PATH = "autoexec/AriseCrossover.lua"
local SCRIPT_URL = "https://raw.githubusercontent.com/Mopera-tech/AriseCrossover.lua/refs/heads/main/AriseCrossover.lua"

sectionLabel(set,"Auto Execute",5)
local aeStatus = Instance.new("TextLabel", set)
aeStatus.Size               = UDim2.new(1,0,0,24)
aeStatus.BackgroundTransparency = 1
aeStatus.TextSize           = 11
aeStatus.Font               = Enum.Font.Gotham
aeStatus.TextXAlignment     = Enum.TextXAlignment.Left
aeStatus.LayoutOrder        = 6

local function checkAE()
    local ok = pcall(function() return isfile(AUTO_EXEC_PATH) end)
    if ok and isfile(AUTO_EXEC_PATH) then
        aeStatus.Text      = "  ✔ Auto Execute: ATIVO"
        aeStatus.TextColor3 = C.accent
    else
        aeStatus.Text      = "  ✖ Auto Execute: INATIVO"
        aeStatus.TextColor3 = C.red
    end
end
checkAE()

makeButton(set,"Ativar Auto Execute", function()
    local ok, err = pcall(function()
        if not isfolder("autoexec") then makefolder("autoexec") end
        local scriptContent = 'loadstring(game:HttpGet("'..SCRIPT_URL..'"  ))()' 
        writefile(AUTO_EXEC_PATH, scriptContent)
    end)
    checkAE()
end, 7)

makeButton(set,"Desativar Auto Execute", function()
    pcall(function()
        if isfile(AUTO_EXEC_PATH) then delfile(AUTO_EXEC_PATH) end
    end)
    checkAE()
end, 8)


print("[Arise Hub] Carregado | "..tostring(S.OpenKey.Name).." pra abrir/fechar")
