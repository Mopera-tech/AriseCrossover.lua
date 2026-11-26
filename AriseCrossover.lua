-- Arise Crossover Hub | Real Executor | Arquiteto Update (Nov 2026)

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RS           = game:GetService("ReplicatedStorage")
local TS           = game:GetService("TeleportService")
local lp           = Players.LocalPlayer
local gui          = lp:WaitForChild("PlayerGui")

local S = {
    AutoFarm=false, AutoArise=false, AutoSell=false, AntiAFK=false,
    AutoDungeon=false, AutoRankUp=false, AutoInfernal=false,
    AutoBloodmoon=false, AutoEclipse=false, AutoArquiteto=false,
    AutoRaid=false, Noclip=false, SpeedHack=false, SpeedValue=32,
    AutoEnchant=false, AutoInfuse=false, AutoCollectAFK=false,
    TargetRank="S", OpenKey=Enum.KeyCode.RightShift,
}

local RANKS = {"E","D","C","B","A","S","SS","G","GM","N","N+","HSR","HSR+","UGM","MR","MR+","GR","GR+","GL","GL+"}
local RANK_COLORS = {
    E=Color3.fromRGB(160,160,160), D=Color3.fromRGB(80,200,80), C=Color3.fromRGB(80,140,255),
    B=Color3.fromRGB(180,80,255), A=Color3.fromRGB(255,200,40), S=Color3.fromRGB(255,120,30),
    SS=Color3.fromRGB(255,60,60), G=Color3.fromRGB(40,220,255), GM=Color3.fromRGB(40,255,180),
    N=Color3.fromRGB(200,40,255), ["N+"]=Color3.fromRGB(220,80,255), HSR=Color3.fromRGB(255,170,30),
    ["HSR+"]=Color3.fromRGB(255,190,60), UGM=Color3.fromRGB(60,160,255), MR=Color3.fromRGB(255,60,120),
    ["MR+"]=Color3.fromRGB(255,80,140), GR=Color3.fromRGB(255,210,60), ["GR+"]=Color3.fromRGB(255,225,90),
    GL=Color3.fromRGB(160,255,160), ["GL+"]=Color3.fromRGB(180,255,200),
}

-- ══ UTILS ══════════════════════════════
local function getChar() return lp.Character end
local function getHRP() local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=getChar(); return c and c:FindFirstChild("Humanoid") end

local function safeTP(pos)
    local hrp=getHRP(); if not hrp then return end
    hrp.CFrame=CFrame.new(pos+Vector3.new(math.random(-1,1),1,math.random(-1,1)))
    task.wait(0.1)
end

local function getAllMobs()
    local mobs,char={},getChar()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v~=char then
            local mhrp=v:FindFirstChild("HumanoidRootPart")
            local mhum=v:FindFirstChildOfClass("Humanoid")
            if mhrp and mhum and mhum.Health>0 then
                local isP=false
                for _,p in ipairs(Players:GetPlayers()) do if p.Character==v then isP=true;break end end
                if not isP then table.insert(mobs,v) end
            end
        end
    end
    return mobs
end

local function getNearestMob()
    local hrp=getHRP(); if not hrp then return nil end
    local best,bd=nil,math.huge
    for _,mob in ipairs(getAllMobs()) do
        local mhrp=mob:FindFirstChild("HumanoidRootPart")
        if mhrp then
            local d=(hrp.Position-mhrp.Position).Magnitude
            if d<bd then best,bd=mob,d end
        end
    end
    return best
end

local function findPromptKW(kws)
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local a=v.ActionText:lower()
            local n=(v.Parent and v.Parent.Name or ""):lower()
            for _,kw in ipairs(kws) do
                if a:find(kw:lower()) or n:find(kw:lower()) then return v end
            end
        end
    end
end

local function findByName(kws)
    for _,v in ipairs(workspace:GetDescendants()) do
        local n=v.Name:lower()
        for _,kw in ipairs(kws) do if n:find(kw:lower()) then return v end end
    end
end

local function firePrompt(pr)
    if pr then pcall(function() fireproximityprompt(pr) end) end
end

local function scanRemote(kws)
    for _,v in ipairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            local n=v.Name:lower()
            for _,kw in ipairs(kws) do if n:find(kw:lower()) then return v end end
        end
    end
end

local function killMobs(timeout,flagKey)
    local t0=tick()
    while tick()-t0<(timeout or 90) do
        if flagKey and not S[flagKey] then break end
        local mob=getNearestMob(); if not mob then break end
        local mhrp=mob:FindFirstChild("HumanoidRootPart")
        if mhrp then
            safeTP(mhrp.Position)
            local mhum=mob:FindFirstChild("Humanoid")
            local t1=tick()
            while mhum and mhum.Health>0 and tick()-t1<15 do
                local hrp=getHRP()
                if hrp and (hrp.Position-mhrp.Position).Magnitude>8 then safeTP(mhrp.Position) end
                task.wait(0.08)
            end
            if S.AutoArise and mhum and mhum.Health<=0 then
                local ar=scanRemote({"arise","awaken"})
                if ar then pcall(function() ar:FireServer(mob) end) end
                task.wait(0.2)
            end
        end
        task.wait(0.05)
    end
end

-- ══ LOOPS ══════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.1)
        if not S.AutoFarm then continue end
        local mob=getNearestMob(); if not mob then continue end
        local mhrp=mob:FindFirstChild("HumanoidRootPart"); if not mhrp then continue end
        safeTP(mhrp.Position)
        local mhum=mob:FindFirstChild("Humanoid")
        local t1=tick()
        while mhum and mhum.Health>0 and tick()-t1<15 do
            local hrp=getHRP()
            if hrp and (hrp.Position-mhrp.Position).Magnitude>8 then safeTP(mhrp.Position) end
            task.wait(0.08)
        end
        if S.AutoArise and mhum and mhum.Health<=0 then
            local ar=scanRemote({"arise","awaken"})
            if ar then pcall(function() ar:FireServer(mob) end) end
            task.wait(0.2)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(5)
        if S.AutoSell then local r=scanRemote({"sell","vender"}); if r then pcall(function() r:FireServer() end) end end
        if S.AutoCollectAFK then local r=scanRemote({"claim","collect","afk"}); if r then pcall(function() r:FireServer() end) end end
        if S.AutoEnchant then local r=scanRemote({"enchant"}); if r then pcall(function() r:FireServer() end) end end
        if S.AutoInfuse then local r=scanRemote({"infus"}); if r then pcall(function() r:FireServer() end) end end
    end
end)

task.spawn(function()
    while true do
        task.wait(55)
        if not S.AntiAFK then continue end
        pcall(function()
            local vu=Instance.new("VirtualUser"); vu.Parent=game
            vu:CaptureController(); vu:ClickButton2(Vector2.new()); vu:Destroy()
        end)
    end
end)

RunService.Stepped:Connect(function()
    if not S.Noclip then return end
    local c=getChar(); if not c then return end
    for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
end)

RunService.Heartbeat:Connect(function()
    if not S.SpeedHack then return end
    local hum=getHum(); if hum then hum.WalkSpeed=S.SpeedValue end
end)

local function dungLoop(flagKey,kws)
    task.spawn(function()
        while true do
            task.wait(1)
            if not S[flagKey] then continue end
            local pr=findPromptKW(kws)
            if pr then
                local pp=pr.Parent
                local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
                if pos then safeTP(pos); task.wait(0.3) end
                firePrompt(pr); task.wait(2)
                for _=1,60 do
                    if not S[flagKey] then break end
                    killMobs(50,flagKey); task.wait(0.5)
                    local adv=findPromptKW({"next","advance","continue","exit","door","portal","enter","pass","open","sala","porta","proximo"})
                    if adv then
                        local ap=adv.Parent
                        local apos=ap and (ap:IsA("BasePart") and ap.Position or (ap.PrimaryPart and ap.PrimaryPart.Position))
                        if apos then safeTP(apos); task.wait(0.2) end
                        firePrompt(adv)
                    end
                    task.wait(2.5)
                end
            end
        end
    end)
end

dungLoop("AutoDungeon",   {"dungeon","entrar","enter dungeon"})
dungLoop("AutoInfernal",  {"infernal","castle","castelo"})
dungLoop("AutoBloodmoon", {"bloodmoon","manor","blood moon"})
dungLoop("AutoEclipse",   {"eclipse","court"})
dungLoop("AutoArquiteto", {"arquiteto","architect","heavenly","detritos"})

task.spawn(function()
    while true do
        task.wait(0.5)
        if not S.AutoBloodmoon then continue end
        local countess=findByName({"countess","vilao","monster_boss","boss_main"})
        if countess then
            local cHum=countess:FindFirstChildOfClass("Humanoid")
            if cHum and cHum.Health>0 then
                local hide=findPromptKW({"hide","esconder","coffin","caixao","closet","armario"})
                if hide then
                    local hp=hide.Parent
                    local pos=hp and (hp:IsA("BasePart") and hp.Position or (hp.PrimaryPart and hp.PrimaryPart.Position))
                    if pos then safeTP(pos); task.wait(0.2) end
                    firePrompt(hide); task.wait(10)
                end
            end
        end
    end
end)

-- ══ CORES PRETO E BRANCO ═══════════════
local C = {
    bg       = Color3.fromRGB(10, 10, 10),
    panel    = Color3.fromRGB(16, 16, 16),
    item     = Color3.fromRGB(22, 22, 22),
    itemHov  = Color3.fromRGB(30, 30, 30),
    accent   = Color3.fromRGB(255, 255, 255),
    accentDk = Color3.fromRGB(40, 40, 40),
    text     = Color3.fromRGB(240, 240, 240),
    textDim  = Color3.fromRGB(100, 100, 100),
    border   = Color3.fromRGB(32, 32, 32),
    borderLt = Color3.fromRGB(55, 55, 55),
    red      = Color3.fromRGB(220, 55, 55),
    white    = Color3.fromRGB(255, 255, 255),
    tabSel   = Color3.fromRGB(22, 22, 22),
    tabDim   = Color3.fromRGB(10, 10, 10),
    green    = Color3.fromRGB(80, 220, 120),
}

-- ══ GUI ════════════════════════════════
if gui:FindFirstChild("AriseHub") then gui:FindFirstChild("AriseHub"):Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "AriseHub"; sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; sg.Parent = gui

local win = Instance.new("Frame", sg)
win.Name = "Window"
win.Size = UDim2.new(0, 760, 0, 500)
win.Position = UDim2.new(0.5, -380, 0.5, -250)
win.BackgroundColor3 = C.bg
win.BorderSizePixel = 0
win.ClipsDescendants = true
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
local wStroke = Instance.new("UIStroke", win)
wStroke.Color = C.border; wStroke.Thickness = 1

-- faixa branca topo (1px)
local topLine = Instance.new("Frame", win)
topLine.Size = UDim2.new(1, 0, 0, 1)
topLine.BackgroundColor3 = C.borderLt
topLine.BorderSizePixel = 0

-- topbar dentro da janela
local topbar = Instance.new("Frame", win)
topbar.Size = UDim2.new(1, 0, 0, 44)
topbar.Position = UDim2.new(0, 0, 0, 1)
topbar.BackgroundColor3 = C.panel
topbar.BorderSizePixel = 0

-- dot status
local dot = Instance.new("Frame", topbar)
dot.Size = UDim2.new(0, 7, 0, 7)
dot.Position = UDim2.new(0, 14, 0.5, -3)
dot.BackgroundColor3 = C.green
dot.BorderSizePixel = 0
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

local titleLbl = Instance.new("TextLabel", topbar)
titleLbl.Size = UDim2.new(0, 100, 1, 0)
titleLbl.Position = UDim2.new(0, 28, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Arise Hub"
titleLbl.TextColor3 = C.text
titleLbl.TextSize = 14
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left

local subLbl = Instance.new("TextLabel", topbar)
subLbl.Size = UDim2.new(0, 260, 1, 0)
subLbl.Position = UDim2.new(0, 128, 0, 0)
subLbl.BackgroundTransparency = 1
subLbl.Text = "Real Executor  ·  Arquiteto Update"
subLbl.TextColor3 = C.textDim
subLbl.TextSize = 11
subLbl.Font = Enum.Font.Gotham
subLbl.TextXAlignment = Enum.TextXAlignment.Left

-- separador topbar
local topSep = Instance.new("Frame", win)
topSep.Size = UDim2.new(1, 0, 0, 1)
topSep.Position = UDim2.new(0, 0, 0, 45)
topSep.BackgroundColor3 = C.border
topSep.BorderSizePixel = 0

-- botões fechar/minimizar DENTRO da topbar
local function mkTopBtn(sym, col, px, cb)
    local b = Instance.new("TextButton", topbar)
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = UDim2.new(1, px, 0.5, -14)
    b.BackgroundColor3 = col
    b.Text = sym
    b.TextColor3 = C.white
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = col == C.red and Color3.fromRGB(255,80,80) or C.borderLt}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = col}):Play()
    end)
    b.MouseButton1Click:Connect(cb)
    return b
end

local minimized = false
mkTopBtn("✕", C.red, -10, function()
    TweenService:Create(win, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 760, 0, 0)
    }):Play()
    task.delay(0.22, function()
        win.Visible = false
        win.Size = UDim2.new(0, 760, 0, 500)
    end)
end)
mkTopBtn("−", C.border, -44, function()
    minimized = not minimized
    TweenService:Create(win, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
        Size = minimized and UDim2.new(0, 760, 0, 46) or UDim2.new(0, 760, 0, 500)
    }):Play()
end)

-- drag suave
local dragging, dragStart, winStart
topbar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = inp.Position
        winStart = win.Position
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragStart
        win.Position = UDim2.new(
            winStart.X.Scale, winStart.X.Offset + d.X,
            winStart.Y.Scale, winStart.Y.Offset + d.Y
        )
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- body
local body = Instance.new("Frame", win)
body.Size = UDim2.new(1, 0, 1, -46)
body.Position = UDim2.new(0, 0, 0, 46)
body.BackgroundTransparency = 1
body.BorderSizePixel = 0
body.ClipsDescendants = true

-- sidebar
local sidebar = Instance.new("Frame", body)
sidebar.Size = UDim2.new(0, 54, 1, 0)
sidebar.BackgroundColor3 = C.panel
sidebar.BorderSizePixel = 0
local sideList = Instance.new("UIListLayout", sidebar)
sideList.SortOrder = Enum.SortOrder.LayoutOrder
sideList.Padding = UDim.new(0, 2)
local sPad = Instance.new("UIPadding", sidebar)
sPad.PaddingTop = UDim.new(0, 10)
sPad.PaddingLeft = UDim.new(0, 5)
sPad.PaddingRight = UDim.new(0, 5)

local sideDiv = Instance.new("Frame", body)
sideDiv.Size = UDim2.new(0, 1, 1, 0)
sideDiv.Position = UDim2.new(0, 54, 0, 0)
sideDiv.BackgroundColor3 = C.border
sideDiv.BorderSizePixel = 0

-- content
local contentArea = Instance.new("Frame", body)
contentArea.Size = UDim2.new(1, -55, 1, 0)
contentArea.Position = UDim2.new(0, 55, 0, 0)
contentArea.BackgroundColor3 = C.bg
contentArea.BorderSizePixel = 0
contentArea.ClipsDescendants = true

-- ══ TAB SYSTEM ═════════════════════════
local tabs, tabBtns = {}, {}
local currentTab = nil

local TAB_INFO = {
    Farm     = {icon="⚔", order=1},
    Dungeon  = {icon="⬡", order=2},
    Raid     = {icon="◈", order=3},
    Teleport = {icon="⊕", order=4},
    Misc     = {icon="≡", order=5},
    Config   = {icon="◎", order=6},
}

local function makeScroll(parent)
    local s = Instance.new("ScrollingFrame", parent)
    s.Size = UDim2.new(1, 0, 1, 0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 2
    s.ScrollBarImageColor3 = C.borderLt
    s.CanvasSize = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.Visible = false
    local pad = Instance.new("UIPadding", s)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    pad.PaddingTop = UDim.new(0, 14)
    pad.PaddingBottom = UDim.new(0, 14)
    local layout = Instance.new("UIListLayout", s)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    return s
end

local function secLabel(parent, text, order)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundTransparency = 1
    f.LayoutOrder = order or 0
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text:upper()
    l.TextColor3 = C.textDim
    l.TextSize = 9
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    local line = Instance.new("Frame", f)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = C.border
    line.BorderSizePixel = 0
    return f
end

local function makeToggle(parent, label, key, order)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = C.item
    row.BorderSizePixel = 0
    row.LayoutOrder = order or 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", row)
    stroke.Color = C.border; stroke.Thickness = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -56, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.text
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local pill = Instance.new("Frame", row)
    pill.Size = UDim2.new(0, 36, 0, 18)
    pill.Position = UDim2.new(1, -46, 0.5, -9)
    pill.BackgroundColor3 = C.accentDk
    pill.BorderSizePixel = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = C.textDim
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function refresh()
        local on = S[key]
        TweenService:Create(pill, TweenInfo.new(0.15), {
            BackgroundColor3 = on and C.accent or C.accentDk
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = on and UDim2.new(0, 21, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
            BackgroundColor3 = on and C.bg or C.textDim
        }):Play()
        lbl.TextColor3 = on and C.text or C.textDim
        stroke.Color = on and C.borderLt or C.border
    end

    row.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            S[key] = not S[key]; refresh()
        end
    end)
    refresh()
    return row
end

local function makeButton(parent, label, cb, order, txtCol)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = C.item
    btn.Text = label
    btn.TextColor3 = txtCol or C.textDim
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.LayoutOrder = order or 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = C.border; stroke.Thickness = 1

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C.itemHov}):Play()
        stroke.Color = C.borderLt
        btn.TextColor3 = C.text
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C.item}):Play()
        stroke.Color = C.border
        btn.TextColor3 = txtCol or C.textDim
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.06), {BackgroundColor3 = C.accentDk}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C.itemHov}):Play()
        pcall(cb)
    end)
    return btn
end

local function makeSlider(parent, label, minV, maxV, key, order)
    local wrap = Instance.new("Frame", parent)
    wrap.Size = UDim2.new(1, 0, 0, 52)
    wrap.BackgroundColor3 = C.item
    wrap.BorderSizePixel = 0
    wrap.LayoutOrder = order or 0
    Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", wrap).Color = C.border

    local lbl = Instance.new("TextLabel", wrap)
    lbl.Size = UDim2.new(0.6, 0, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.TextColor3 = C.text
    lbl.TextSize = 13; lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", wrap)
    valLbl.Size = UDim2.new(0.35, -12, 0, 22)
    valLbl.Position = UDim2.new(0.63, 0, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(S[key]); valLbl.TextColor3 = C.text
    valLbl.TextSize = 13; valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", wrap)
    track.Size = UDim2.new(1, -24, 0, 4)
    track.Position = UDim2.new(0, 12, 0, 36)
    track.BackgroundColor3 = C.accentDk
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local pct = (S[key] - minV) / (maxV - minV)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.Position = UDim2.new(pct, -6, 0.5, -6)
    thumb.BackgroundColor3 = C.white
    thumb.BorderSizePixel = 0; thumb.ZIndex = 3
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local ds = false
    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minV + rel * (maxV - minV))
        S[key] = val; valLbl.Text = tostring(val)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -6, 0.5, -6)
    end
    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then ds = true; update(inp.Position.X) end
    end)
    UIS.InputChanged:Connect(function(inp)
        if ds and inp.UserInputType == Enum.UserInputType.MouseMovement then update(inp.Position.X) end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then ds = false end
    end)
    return wrap
end

local function switchTab(name)
    for n, s in pairs(tabs) do
        if n == name then
            s.Visible = true
            s.Position = UDim2.new(0.03, 0, 0, 0)
            TweenService:Create(s, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
                Position = UDim2.new(0, 0, 0, 0)
            }):Play()
        else
            if s.Visible then
                local sc = s
                TweenService:Create(sc, TweenInfo.new(0.14, Enum.EasingStyle.Quint), {
                    Position = UDim2.new(-0.03, 0, 0, 0)
                }):Play()
                task.delay(0.15, function()
                    sc.Visible = false
                    sc.Position = UDim2.new(0, 0, 0, 0)
                end)
            end
        end
    end
    for n, t in pairs(tabBtns) do
        local on = (n == name)
        TweenService:Create(t.btn, TweenInfo.new(0.15), {
            BackgroundColor3 = on and C.tabSel or C.tabDim
        }):Play()
        t.ico.TextColor3 = on and C.text or C.textDim
        t.bar.Visible = on
    end
    currentTab = name
end

local function addTab(name)
    local info = TAB_INFO[name]
    local scroll = makeScroll(contentArea)
    tabs[name] = scroll

    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.BackgroundColor3 = C.tabDim
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.LayoutOrder = info.order
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local ico = Instance.new("TextLabel", btn)
    ico.Size = UDim2.new(1, 0, 0, 22)
    ico.Position = UDim2.new(0, 0, 0, 7)
    ico.BackgroundTransparency = 1
    ico.Text = info.icon
    ico.TextSize = 16
    ico.Font = Enum.Font.GothamBold
    ico.TextColor3 = C.textDim
    ico.TextXAlignment = Enum.TextXAlignment.Center

    local nLbl = Instance.new("TextLabel", btn)
    nLbl.Size = UDim2.new(1, 0, 0, 12)
    nLbl.Position = UDim2.new(0, 0, 0, 29)
    nLbl.BackgroundTransparency = 1
    nLbl.Text = name
    nLbl.TextSize = 8
    nLbl.Font = Enum.Font.GothamBold
    nLbl.TextColor3 = C.textDim
    nLbl.TextXAlignment = Enum.TextXAlignment.Center

    local bar = Instance.new("Frame", btn)
    bar.Size = UDim2.new(0, 2, 0.5, 0)
    bar.Position = UDim2.new(0, 0, 0.25, 0)
    bar.BackgroundColor3 = C.white
    bar.BorderSizePixel = 0
    bar.Visible = false
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    tabBtns[name] = {btn = btn, ico = ico, bar = bar}
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    return scroll
end

-- ══ POPULAR TABS ═══════════════════════
local farm = addTab("Farm")
secLabel(farm, "Combate", 1)
makeToggle(farm, "Auto Farm",    "AutoFarm",  2)
makeToggle(farm, "Auto Arise",   "AutoArise", 3)
makeToggle(farm, "Auto Sell",    "AutoSell",  4)
secLabel(farm, "Automação", 5)
makeToggle(farm, "Auto Enchant", "AutoEnchant",   6)
makeToggle(farm, "Auto Infuse",  "AutoInfuse",    7)
makeToggle(farm, "Coletar AFK",  "AutoCollectAFK",8)
makeToggle(farm, "Anti-AFK",     "AntiAFK",       9)

local dung = addTab("Dungeon")
secLabel(dung, "Masmorras", 1)
makeToggle(dung, "Auto Dungeon",         "AutoDungeon",  2)
makeToggle(dung, "Auto Rank Up",         "AutoRankUp",   3)
makeToggle(dung, "Auto Infernal Castle", "AutoInfernal", 4)
secLabel(dung, "Night of Monarchs", 5)
makeToggle(dung, "Auto Bloodmoon Manor", "AutoBloodmoon",6)
makeToggle(dung, "Auto Eclipse Court",   "AutoEclipse",  7)
makeToggle(dung, "Auto Arquiteto",       "AutoArquiteto",8)
secLabel(dung, "Ações Rápidas", 9)
local function tpPrompt(kws)
    local p=findPromptKW(kws); if not p then return end
    local pp=p.Parent; local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
    if pos then safeTP(pos); task.wait(0.3) end; firePrompt(p)
end
makeButton(dung,"Entrar na Dungeon",   function() tpPrompt({"dungeon","entrar","enter"}) end, 10)
makeButton(dung,"Infernal Castle",     function() tpPrompt({"infernal","castle"}) end,        11)
makeButton(dung,"Bloodmoon Manor",     function() tpPrompt({"bloodmoon","manor","blood"}) end,12)
makeButton(dung,"Eclipse Court",       function() tpPrompt({"eclipse","court"}) end,          13)
makeButton(dung,"Heavenly Castle",     function() tpPrompt({"heavenly","arquiteto"}) end,     14)
secLabel(dung, "Rank Alvo", 15)
local selRankLbl = Instance.new("TextLabel", dung)
selRankLbl.Size = UDim2.new(1, 0, 0, 20)
selRankLbl.BackgroundTransparency = 1
selRankLbl.Text = "Selecionado:  " .. S.TargetRank
selRankLbl.TextColor3 = C.text; selRankLbl.TextSize = 12
selRankLbl.Font = Enum.Font.GothamBold
selRankLbl.TextXAlignment = Enum.TextXAlignment.Left
selRankLbl.LayoutOrder = 16

local rankWrap = Instance.new("Frame", dung)
rankWrap.Size = UDim2.new(1, 0, 0, 160)
rankWrap.BackgroundColor3 = C.item
rankWrap.BorderSizePixel = 0; rankWrap.LayoutOrder = 17
Instance.new("UICorner", rankWrap).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", rankWrap).Color = C.border

local rankSF = Instance.new("ScrollingFrame", rankWrap)
rankSF.Size = UDim2.new(1, -8, 1, -8); rankSF.Position = UDim2.new(0, 4, 0, 4)
rankSF.BackgroundTransparency = 1; rankSF.BorderSizePixel = 0
rankSF.ScrollBarThickness = 2; rankSF.ScrollBarImageColor3 = C.borderLt
rankSF.CanvasSize = UDim2.new(0, 0, 0, 0); rankSF.AutomaticCanvasSize = Enum.AutomaticSize.Y

local rankGrid = Instance.new("UIGridLayout", rankSF)
rankGrid.CellSize = UDim2.new(0.25, -4, 0, 28)
rankGrid.CellPadding = UDim2.new(0, 4, 0, 4)
rankGrid.SortOrder = Enum.SortOrder.LayoutOrder
local rPad = Instance.new("UIPadding", rankSF); rPad.PaddingLeft = UDim.new(0, 4); rPad.PaddingTop = UDim.new(0, 4)

local rankCells = {}
for i, rank in ipairs(RANKS) do
    local cell = Instance.new("TextButton", rankSF)
    cell.BackgroundColor3 = C.item; cell.BorderSizePixel = 0
    cell.Text = rank; cell.TextColor3 = RANK_COLORS[rank] or C.text
    cell.TextSize = 11; cell.Font = Enum.Font.GothamBold
    cell.LayoutOrder = i; cell.AutoButtonColor = false
    Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 4)
    local cs = Instance.new("UIStroke", cell); cs.Color = C.border; cs.Thickness = 1
    rankCells[rank] = {cell = cell, stroke = cs}
    cell.MouseButton1Click:Connect(function()
        S.TargetRank = rank; selRankLbl.Text = "Selecionado:  " .. rank
        for _, rc in pairs(rankCells) do rc.cell.BackgroundColor3 = C.item; rc.stroke.Color = C.border end
        cell.BackgroundColor3 = C.accentDk; cs.Color = C.borderLt
    end)
end

local raid = addTab("Raid")
secLabel(raid, "Raids", 1)
makeToggle(raid, "Auto Raid", "AutoRaid", 2)
secLabel(raid, "Eventos", 3)
makeButton(raid, "Nightmare Kamish",  function() tpPrompt({"kamish","nightmare","worldboss"}) end, 4)
makeButton(raid, "Pumpkin King",      function() tpPrompt({"pumpkin","king"}) end,                 5)
makeButton(raid, "Trick or Treat",    function() tpPrompt({"trick","treat","halloween"}) end,      6)

local tp = addTab("Teleport")
secLabel(tp, "Rápido", 1)
makeButton(tp, "Mob mais próximo", function()
    local mob = getNearestMob(); if not mob then return end
    local mhrp = mob:FindFirstChild("HumanoidRootPart"); if mhrp then safeTP(mhrp.Position) end
end, 2)
makeButton(tp, "Rank Up NPC",    function() tpPrompt({"rank","rankup","upgrade rank"}) end, 3)
makeButton(tp, "Shadow Upgrader",function() tpPrompt({"shadow","upgrade shadow"}) end,      4)
makeButton(tp, "Arquiteto Boss", function()
    local part = findByName({"arquiteto","architect"}); if part then
        safeTP(part:IsA("BasePart") and part.Position or part:GetPivot().Position) end
end, 5)
secLabel(tp, "Ilhas", 6)
local islands = {
    {"Solo City",          {"solocity","solo"}},
    {"Leveling City",      {"levelingcity","leveling"}},
    {"Grass Village",      {"grassvillage","grass"}},
    {"Brum Island",        {"brum"}},
    {"Mori Town",          {"mori"}},
    {"Ghoul Island",       {"ghoul"}},
    {"XZ City",            {"xzcity","xz"}},
    {"Ilha 30",            {"island30","ilha30"}},
    {"Blood Moonwoods",    {"moonwoods","bloodmoonwoods"}},
    {"Eclipse Paradise",   {"paradise"}},
    {"Abismo de Detritos", {"detritos","debris","abismo"}},
}
for i, isl in ipairs(islands) do
    makeButton(tp, isl[1], function()
        local part = findByName(isl[2]); if part then
            safeTP(part:IsA("BasePart") and part.Position or part:GetPivot().Position) end
    end, 6 + i)
end

local misc = addTab("Misc")
secLabel(misc, "Movimento", 1)
makeToggle(misc, "Noclip",     "Noclip",    2)
makeToggle(misc, "Speed Hack", "SpeedHack", 3)
makeSlider(misc, "Velocidade", 16, 300, "SpeedValue", 4)
secLabel(misc, "Utilitários", 5)
makeButton(misc, "Rejoin Server",  function() TS:Teleport(game.PlaceId, lp) end, 6)
makeButton(misc, "Print Remotes",  function()
    for _,v in ipairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then print("[Remote]",v:GetFullName()) end
    end
end, 7)
makeButton(misc, "Print Prompts",  function()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then print("[Prompt]",v.Parent.Name,"|",v.ActionText,"|",v:GetFullName()) end
    end
end, 8)

local cfg = addTab("Config")
secLabel(cfg, "Keybind", 1)
local keyBtn = makeButton(cfg, "Tecla: RightShift", function() end, 2)
local listening = false
keyBtn.MouseButton1Up:Connect(function()
    listening = true; keyBtn.Text = "Pressione uma tecla..."; keyBtn.TextColor3 = C.text
end)

secLabel(cfg, "Auto Execute", 3)
local aeStatus = Instance.new("TextLabel", cfg)
aeStatus.Size = UDim2.new(1, 0, 0, 22); aeStatus.BackgroundTransparency = 1
aeStatus.TextSize = 12; aeStatus.Font = Enum.Font.Gotham
aeStatus.TextXAlignment = Enum.TextXAlignment.Left; aeStatus.LayoutOrder = 4

local AE_PATH = "autoexec/AriseCrossover.lua"
local SCRIPT_URL = "https://raw.githubusercontent.com/Mopera-tech/AriseCrossover.lua/refs/heads/main/AriseCrossover.lua"

local function checkAE()
    local ok, res = pcall(function() return isfile(AE_PATH) end)
    if ok and res then aeStatus.Text = "  Status: ATIVO"; aeStatus.TextColor3 = C.green
    else aeStatus.Text = "  Status: INATIVO"; aeStatus.TextColor3 = C.red end
end
checkAE()

makeButton(cfg, "Ativar Auto Execute", function()
    pcall(function()
        if not isfolder("autoexec") then makefolder("autoexec") end
        writefile(AE_PATH, 'loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()')
    end); checkAE()
end, 5, C.green)

makeButton(cfg, "Desativar Auto Execute", function()
    pcall(function() if isfile(AE_PATH) then delfile(AE_PATH) end end); checkAE()
end, 6, C.red)

-- ══ KEYBIND ════════════════════════════
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
        S.OpenKey = inp.KeyCode
        keyBtn.Text = "Tecla: " .. inp.KeyCode.Name
        keyBtn.TextColor3 = C.textDim
        listening = false
        return
    end
    if inp.KeyCode == S.OpenKey then
        if win.Visible then
            TweenService:Create(win, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0, 760, 0, 0)
            }):Play()
            task.delay(0.22, function()
                win.Visible = false
                win.Size = UDim2.new(0, 760, 0, 500)
            end)
        else
            win.Visible = true
            win.Size = UDim2.new(0, 760, 0, 0)
            TweenService:Create(win, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0, 760, 0, 500)
            }):Play()
        end
    end
end)

-- abre na primeira tab
switchTab("Farm")

print("[Arise Hub] Carregado | " .. S.OpenKey.Name .. " para abrir/fechar")
