-- Arise Crossover Hub | Real Executor | Arquiteto Update (Nov

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RS           = game:GetService("ReplicatedStorage")
local TS           = game:GetService("TeleportService")
local lp           = Players.LocalPlayer
local gui          = lp:WaitForChild("PlayerGui")

-- ══════════════════════════════════════
--  STATE
-- ══════════════════════════════════════
local S = {
    AutoFarm        = false,
    AutoArise       = false,
    AutoSell        = false,
    AntiAFK         = false,
    AutoDungeon     = false,
    AutoRankUp      = false,
    AutoInfernal    = false,
    AutoBloodmoon   = false,
    AutoEclipse     = false,
    AutoArquiteto   = false,
    AutoRaid        = false,
    Noclip          = false,
    SpeedHack       = false,
    SpeedValue      = 32,
    AutoEnchant     = false,
    AutoInfuse      = false,
    AutoCollectAFK  = false,
    TargetRank      = "S",
    OpenKey         = Enum.KeyCode.RightShift,
}

local RANKS = {
    "E","D","C","B","A","S","SS","G","GM",
    "N","N+","HSR","HSR+","UGM","MR","MR+","GR","GR+","GL","GL+"
}

local RANK_COLORS = {
    E=Color3.fromRGB(160,160,160), D=Color3.fromRGB(80,200,80),
    C=Color3.fromRGB(80,140,255), B=Color3.fromRGB(180,80,255),
    A=Color3.fromRGB(255,200,40), S=Color3.fromRGB(255,120,30),
    SS=Color3.fromRGB(255,60,60), G=Color3.fromRGB(40,220,255),
    GM=Color3.fromRGB(40,255,180), N=Color3.fromRGB(200,40,255),
    ["N+"]=Color3.fromRGB(220,80,255), HSR=Color3.fromRGB(255,170,30),
    ["HSR+"]=Color3.fromRGB(255,190,60), UGM=Color3.fromRGB(60,160,255),
    MR=Color3.fromRGB(255,60,120), ["MR+"]=Color3.fromRGB(255,80,140),
    GR=Color3.fromRGB(255,210,60), ["GR+"]=Color3.fromRGB(255,225,90),
    GL=Color3.fromRGB(160,255,160), ["GL+"]=Color3.fromRGB(180,255,200),
}

-- ══════════════════════════════════════
--  UTILS
-- ══════════════════════════════════════
local function getChar() return lp.Character end
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
    hrp.CFrame = CFrame.new(pos + Vector3.new(math.random(-1,1), 1, math.random(-1,1)))
    task.wait(0.1)
end

-- encontra todos os mobs vivos no workspace
local function getAllMobs()
    local mobs = {}
    local char = getChar()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= char then
            local mhrp = v:FindFirstChild("HumanoidRootPart")
            local mhum = v:FindFirstChildOfClass("Humanoid")
            if mhrp and mhum and mhum.Health > 0 then
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

-- encontra qualquer ProximityPrompt pelo ActionText ou nome do parent
local function findPromptByKeywords(keywords)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local action = v.ActionText:lower()
            local pname  = v.Parent and v.Parent.Name:lower() or ""
            for _, kw in ipairs(keywords) do
                kw = kw:lower()
                if action:find(kw) or pname:find(kw) then
                    return v
                end
            end
        end
    end
end

-- encontra uma BasePart/Model pelo nome
local function findByName(keywords)
    for _, v in ipairs(workspace:GetDescendants()) do
        local n = v.Name:lower()
        for _, kw in ipairs(keywords) do
            if n:find(kw:lower()) then return v end
        end
    end
end

local function firePrompt(prompt)
    if not prompt then return end
    pcall(function() fireproximityprompt(prompt) end)
end

-- TP no mob e espera o auto click do jogo matar
local function killMobs(timeoutSec, flagKey)
    local t0 = tick()
    while tick() - t0 < (timeoutSec or 90) do
        if flagKey and not S[flagKey] then break end
        local mob = getNearestMob()
        if not mob then break end
        local mhrp = mob:FindFirstChild("HumanoidRootPart")
        if mhrp then
            safeTP(mhrp.Position)
            local mhum = mob:FindFirstChild("Humanoid")
            local t1 = tick()
            while mhum and mhum.Health > 0 and tick() - t1 < 15 do
                -- re-TP se o mob fugiu
                if mhrp and (getHRP().Position - mhrp.Position).Magnitude > 8 then
                    safeTP(mhrp.Position)
                end
                task.wait(0.08)
            end
            if S.AutoArise and mhum and mhum.Health <= 0 then
                pcall(function()
                    for _, v in ipairs(RS:GetDescendants()) do
                        if v:IsA("RemoteEvent") and
                           (v.Name:lower():find("arise") or v.Name:lower():find("awaken")) then
                            v:FireServer(mob)
                            break
                        end
                    end
                end)
                task.wait(0.2)
            end
        end
        task.wait(0.05)
    end
end

-- ══════════════════════════════════════
--  AUTO FARM LOOP
-- ══════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.1)
        if S.AutoFarm then
            local mob = getNearestMob()
            if mob then
                local mhrp = mob:FindFirstChild("HumanoidRootPart")
                if mhrp then
                    safeTP(mhrp.Position)
                    local mhum = mob:FindFirstChild("Humanoid")
                    local t1 = tick()
                    while mhum and mhum.Health > 0 and tick() - t1 < 15 do
                        if mhrp and (getHRP().Position - mhrp.Position).Magnitude > 8 then
                            safeTP(mhrp.Position)
                        end
                        task.wait(0.08)
                    end
                    if S.AutoArise and mhum and mhum.Health <= 0 then
                        pcall(function()
                            for _, v in ipairs(RS:GetDescendants()) do
                                if v:IsA("RemoteEvent") and
                                   (v.Name:lower():find("arise") or v.Name:lower():find("awaken")) then
                                    v:FireServer(mob); break
                                end
                            end
                        end)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end)

-- ══════════════════════════════════════
--  AUTO SELL / ENCHANT / INFUSE / AFK
-- ══════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(5)
        if S.AutoSell then
            pcall(function()
                for _, v in ipairs(RS:GetDescendants()) do
                    if v:IsA("RemoteEvent") and
                       (v.Name:lower():find("sell") or v.Name:lower():find("vender")) then
                        v:FireServer(); break
                    end
                end
            end)
        end
        if S.AutoCollectAFK then
            pcall(function()
                for _, v in ipairs(RS:GetDescendants()) do
                    if v:IsA("RemoteEvent") and
                       (v.Name:lower():find("claim") or v.Name:lower():find("collect") or v.Name:lower():find("afk")) then
                        v:FireServer(); break
                    end
                end
            end)
        end
        if S.AutoEnchant then
            pcall(function()
                for _, v in ipairs(RS:GetDescendants()) do
                    if v:IsA("RemoteEvent") and v.Name:lower():find("enchant") then
                        v:FireServer(); break
                    end
                end
            end)
        end
        if S.AutoInfuse then
            pcall(function()
                for _, v in ipairs(RS:GetDescendants()) do
                    if v:IsA("RemoteEvent") and v.Name:lower():find("infus") then
                        v:FireServer(); break
                    end
                end
            end)
        end
    end
end)

-- ══════════════════════════════════════
--  ANTI-AFK
-- ══════════════════════════════════════
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

-- ══════════════════════════════════════
--  NOCLIP
-- ══════════════════════════════════════
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

-- ══════════════════════════════════════
--  SPEED (só age quando ligado)
-- ══════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if S.SpeedHack then
        local hum = getHum()
        if hum then hum.WalkSpeed = S.SpeedValue end
    end
end)

-- ══════════════════════════════════════
--  DUNGEON LOOP GENÉRICO
-- ══════════════════════════════════════
local function runDungeonLoop(flagKey, entryKeywords)
    task.spawn(function()
        while true do
            task.wait(1)
            if not S[flagKey] then continue end

            -- entra pela porta/prompt de entrada
            local entryPrompt = findPromptByKeywords(entryKeywords)
            if not entryPrompt then
                -- tenta achar pelo nome da part
                local part = findByName(entryKeywords)
                if part then
                    local pos = part:IsA("BasePart") and part.Position or part:GetPivot().Position
                    safeTP(pos)
                    task.wait(0.5)
                    entryPrompt = findPromptByKeywords(entryKeywords)
                    if entryPrompt then firePrompt(entryPrompt) end
                end
            else
                local pp = entryPrompt.Parent
                local pos = pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
                if pos then safeTP(pos) end
                task.wait(0.3)
                firePrompt(entryPrompt)
            end

            task.wait(2)

            -- loop de salas
            for _ = 1, 60 do
                if not S[flagKey] then break end
                killMobs(50, flagKey)
                task.wait(0.5)
                -- tenta avançar de sala
                local advPrompt = findPromptByKeywords({
                    "next","advance","continue","proceed",
                    "exit","door","portal","enter","pass",
                    "open","go","sala","proximo","porta"
                })
                if advPrompt then
                    local ap = advPrompt.Parent
                    local pos = ap and (ap:IsA("BasePart") and ap.Position or (ap.PrimaryPart and ap.PrimaryPart.Position))
                    if pos then safeTP(pos); task.wait(0.2) end
                    firePrompt(advPrompt)
                end
                task.wait(2.5)
            end
        end
    end)
end

runDungeonLoop("AutoDungeon",   {"dungeon","enter dungeon","entrar","sala"})
runDungeonLoop("AutoInfernal",  {"infernal","castle","castelo"})
runDungeonLoop("AutoBloodmoon", {"bloodmoon","manor","blood"})
runDungeonLoop("AutoEclipse",   {"eclipse","court"})
runDungeonLoop("AutoArquiteto", {"arquiteto","architect","heavenly","debris","detritos"})

-- ══════════════════════════════════════
--  BLOODMOON: ESCONDER DA COUNTESS
-- ══════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.5)
        if not S.AutoBloodmoon then continue end
        -- detecta countess pelo nome do model
        local countess = findByName({"countess","vilao","monster_boss","boss"})
        if countess then
            local cHum = countess:FindFirstChildOfClass("Humanoid")
            if cHum and cHum.Health > 0 then
                -- procura esconderijo (coffin ou closet) mais próximo
                local hide = findPromptByKeywords({
                    "hide","esconder","coffin","caixao","closet","armario","chest"
                })
                if hide then
                    local hp = hide.Parent
                    local pos = hp and (hp:IsA("BasePart") and hp.Position or (hp.PrimaryPart and hp.PrimaryPart.Position))
                    if pos then safeTP(pos); task.wait(0.2) end
                    firePrompt(hide) -- segura F automaticamente
                    task.wait(10)   -- espera countess ir embora
                end
            end
        end
    end
end)

-- ══════════════════════════════════════
--  UI CORES
-- ══════════════════════════════════════
local C = {
    bg       = Color3.fromRGB(7,7,9),
    panel    = Color3.fromRGB(11,11,15),
    item     = Color3.fromRGB(15,15,21),
    itemHov  = Color3.fromRGB(21,21,29),
    accent   = Color3.fromRGB(96,214,154),
    accentDk = Color3.fromRGB(25,65,45),
    text     = Color3.fromRGB(218,218,228),
    textDim  = Color3.fromRGB(85,85,105),
    border   = Color3.fromRGB(28,28,40),
    borderLt = Color3.fromRGB(44,44,58),
    red      = Color3.fromRGB(215,52,52),
    white    = Color3.fromRGB(255,255,255),
    tabSel   = Color3.fromRGB(15,15,21),
    tabDim   = Color3.fromRGB(7,7,9),
    gold     = Color3.fromRGB(255,196,56),
}

-- ══════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════
-- remove UI antiga se existir
if gui:FindFirstChild("AriseHub") then
    gui:FindFirstChild("AriseHub"):Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name           = "AriseHub"
sg.ResetOnSpawn   = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent         = gui

local win = Instance.new("Frame", sg)
win.Name              = "Window"
win.Size              = UDim2.new(0, 800, 0, 540)
win.Position          = UDim2.new(0.5, -400, 0.5, -270)
win.BackgroundColor3  = C.bg
win.BorderSizePixel   = 0
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)
local wStroke = Instance.new("UIStroke", win)
wStroke.Color = C.border; wStroke.Thickness = 1

-- faixa de cor topo
local accentBar = Instance.new("Frame", win)
accentBar.Size            = UDim2.new(1, 0, 0, 2)
accentBar.BackgroundColor3 = C.accent
accentBar.BorderSizePixel = 0
Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 10)
-- fix canto inferior da barra
local accentFix = Instance.new("Frame", win)
accentFix.Size            = UDim2.new(1, 0, 0, 1)
accentFix.Position        = UDim2.new(0, 0, 0, 1)
accentFix.BackgroundColor3 = C.accent
accentFix.BorderSizePixel = 0

-- topbar
local top = Instance.new("Frame", win)
top.Size             = UDim2.new(1, 0, 0, 44)
top.Position         = UDim2.new(0, 0, 0, 2)
top.BackgroundColor3 = C.panel
top.BorderSizePixel  = 0
local topFix = Instance.new("Frame", win)
topFix.Size             = UDim2.new(1, 0, 0, 10)
topFix.Position         = UDim2.new(0, 0, 0, 36)
topFix.BackgroundColor3 = C.panel
topFix.BorderSizePixel  = 0

-- dot verde
local dot = Instance.new("Frame", top)
dot.Size             = UDim2.new(0, 8, 0, 8)
dot.Position         = UDim2.new(0, 16, 0.5, -4)
dot.BackgroundColor3 = C.accent
dot.BorderSizePixel  = 0
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

local titleLbl = Instance.new("TextLabel", top)
titleLbl.Size               = UDim2.new(0, 160, 1, 0)
titleLbl.Position           = UDim2.new(0, 32, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = "Arise Hub"
titleLbl.TextColor3         = C.text
titleLbl.TextSize           = 15
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left

local subLbl = Instance.new("TextLabel", top)
subLbl.Size               = UDim2.new(0, 300, 1, 0)
subLbl.Position           = UDim2.new(0, 130, 0, 0)
subLbl.BackgroundTransparency = 1
subLbl.Text               = "Real Executor  ·  Arquiteto Update"
subLbl.TextColor3         = C.textDim
subLbl.TextSize           = 11
subLbl.Font               = Enum.Font.Gotham
subLbl.TextXAlignment     = Enum.TextXAlignment.Left

-- separador topo
local topSep = Instance.new("Frame", win)
topSep.Size             = UDim2.new(1, 0, 0, 1)
topSep.Position         = UDim2.new(0, 0, 0, 46)
topSep.BackgroundColor3 = C.border
topSep.BorderSizePixel  = 0

local function makeTopBtn(sym, col, px, cb)
    local b = Instance.new("TextButton", top)
    b.Size             = UDim2.new(0, 26, 0, 26)
    b.Position         = UDim2.new(1, px, 0.5, -13)
    b.BackgroundColor3 = col
    b.Text             = sym
    b.TextColor3       = C.white
    b.TextSize         = 12
    b.Font             = Enum.Font.GothamBold
    b.BorderSizePixel  = 0
    b.AutoButtonColor  = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    b.MouseButton1Click:Connect(cb)
    return b
end

local minimized = false
makeTopBtn("x", C.red, -10, function() win.Visible = false end)
makeTopBtn("−", C.border, -42, function()
    minimized = not minimized
    win.Size = minimized and UDim2.new(0, 800, 0, 46) or UDim2.new(0, 800, 0, 540)
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
        win.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- sidebar
local sidebar = Instance.new("Frame", win)
sidebar.Size             = UDim2.new(0, 118, 1, -47)
sidebar.Position         = UDim2.new(0, 0, 0, 47)
sidebar.BackgroundColor3 = C.panel
sidebar.BorderSizePixel  = 0
local sidePadFix = Instance.new("Frame", sidebar)
sidePadFix.Size             = UDim2.new(0, 10, 1, 0)
sidePadFix.Position         = UDim2.new(1, -10, 0, 0)
sidePadFix.BackgroundColor3 = C.panel
sidePadFix.BorderSizePixel  = 0
local sideList = Instance.new("UIListLayout", sidebar)
sideList.SortOrder = Enum.SortOrder.LayoutOrder

local sideDiv = Instance.new("Frame", win)
sideDiv.Size             = UDim2.new(0, 1, 1, -47)
sideDiv.Position         = UDim2.new(0, 118, 0, 47)
sideDiv.BackgroundColor3 = C.border
sideDiv.BorderSizePixel  = 0

local contentArea = Instance.new("Frame", win)
contentArea.Size             = UDim2.new(1, -119, 1, -47)
contentArea.Position         = UDim2.new(0, 119, 0, 47)
contentArea.BackgroundColor3 = C.bg
contentArea.BorderSizePixel  = 0
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 8)

-- ══════════════════════════════════════
--  COMPONENTES
-- ══════════════════════════════════════
local tabs    = {}
local tabBtns = {}

local TAB_DATA = {
    Farm     = "⚔",
    Dungeon  = "🏰",
    Raid     = "💀",
    Teleport = "📍",
    Misc     = "🛠",
    Config   = "⚙",
}

local function makeScroll(parent)
    local s = Instance.new("ScrollingFrame", parent)
    s.Size                   = UDim2.new(1, 0, 1, 0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel        = 0
    s.ScrollBarThickness     = 3
    s.ScrollBarImageColor3   = C.borderLt
    s.CanvasSize             = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    s.Visible                = false
    local pad = Instance.new("UIPadding", s)
    pad.PaddingLeft   = UDim.new(0, 12)
    pad.PaddingRight  = UDim.new(0, 12)
    pad.PaddingTop    = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 12)
    local layout = Instance.new("UIListLayout", s)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding   = UDim.new(0, 6)
    return s
end

local function secLabel(parent, text, order)
    local f = Instance.new("Frame", parent)
    f.Size                   = UDim2.new(1, 0, 0, 28)
    f.BackgroundTransparency = 1
    f.LayoutOrder            = order or 0
    local l = Instance.new("TextLabel", f)
    l.Size                   = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text                   = text:upper()
    l.TextColor3             = C.accent
    l.TextSize               = 10
    l.Font                   = Enum.Font.GothamBold
    l.TextXAlignment         = Enum.TextXAlignment.Left
    local line = Instance.new("Frame", f)
    line.Size             = UDim2.new(1, 0, 0, 1)
    line.Position         = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = C.accentDk
    line.BorderSizePixel  = 0
    return f
end

local function makeToggle(parent, label, key, order)
    local row = Instance.new("Frame", parent)
    row.Size             = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = C.item
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order or 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", row)
    stroke.Color = C.border; stroke.Thickness = 1

    local bar = Instance.new("Frame", row)
    bar.Size             = UDim2.new(0, 3, 0.55, 0)
    bar.Position         = UDim2.new(0, 0, 0.225, 0)
    bar.BackgroundColor3 = C.textDim
    bar.BorderSizePixel  = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size               = UDim2.new(1, -58, 1, 0)
    lbl.Position           = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = C.text
    lbl.TextSize           = 13
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left

    local pill = Instance.new("Frame", row)
    pill.Size             = UDim2.new(0, 40, 0, 20)
    pill.Position         = UDim2.new(1, -50, 0.5, -10)
    pill.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    pill.BorderSizePixel  = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(110, 110, 130)
    knob.BorderSizePixel  = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function refresh()
        local on = S[key]
        TweenService:Create(pill, TweenInfo.new(0.18), {
            BackgroundColor3 = on and C.accentDk or Color3.fromRGB(26, 26, 36)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.18), {
            Position         = on and UDim2.new(0, 23, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
            BackgroundColor3 = on and C.accent or Color3.fromRGB(110, 110, 130)
        }):Play()
        TweenService:Create(bar, TweenInfo.new(0.18), {
            BackgroundColor3 = on and C.accent or C.textDim
        }):Play()
        stroke.Color = on and C.accentDk or C.border
    end

    row.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            S[key] = not S[key]; refresh()
        end
    end)
    refresh()
    return row
end

local function makeButton(parent, label, cb, order, txtColor)
    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = C.item
    btn.Text             = label
    btn.TextColor3       = txtColor or C.text
    btn.TextSize         = 13
    btn.Font             = Enum.Font.Gotham
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = order or 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = C.border; stroke.Thickness = 1

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C.itemHov}):Play()
        stroke.Color = C.borderLt
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = C.item}):Play()
        stroke.Color = C.border
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
    wrap.Size             = UDim2.new(1, 0, 0, 54)
    wrap.BackgroundColor3 = C.item
    wrap.BorderSizePixel  = 0
    wrap.LayoutOrder      = order or 0
    Instance.new("UICorner", wrap).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", wrap).Color = C.border

    local lbl = Instance.new("TextLabel", wrap)
    lbl.Size               = UDim2.new(0.6, 0, 0, 24)
    lbl.Position           = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text               = label
    lbl.TextColor3         = C.text
    lbl.TextSize           = 13
    lbl.Font               = Enum.Font.Gotham
    lbl.TextXAlignment     = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", wrap)
    valLbl.Size               = UDim2.new(0.35, -14, 0, 24)
    valLbl.Position           = UDim2.new(0.63, 0, 0, 6)
    valLbl.BackgroundTransparency = 1
    valLbl.Text               = tostring(S[key])
    valLbl.TextColor3         = C.accent
    valLbl.TextSize           = 13
    valLbl.Font               = Enum.Font.GothamBold
    valLbl.TextXAlignment     = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", wrap)
    track.Size             = UDim2.new(1, -28, 0, 6)
    track.Position         = UDim2.new(0, 14, 0, 38)
    track.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    track.BorderSizePixel  = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local pct = (S[key] - minV) / (maxV - minV)
    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = C.accent
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", track)
    thumb.Size             = UDim2.new(0, 14, 0, 14)
    thumb.Position         = UDim2.new(pct, -7, 0.5, -7)
    thumb.BackgroundColor3 = C.white
    thumb.BorderSizePixel  = 0
    thumb.ZIndex           = 3
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local ds = false
    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minV + rel * (maxV - minV))
        S[key] = val
        valLbl.Text  = tostring(val)
        fill.Size     = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -7, 0.5, -7)
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

local function addTab(name, order)
    local scroll = makeScroll(contentArea)
    tabs[name] = scroll

    local btn = Instance.new("TextButton", sidebar)
    btn.Size             = UDim2.new(1, 0, 0, 64)
    btn.BackgroundColor3 = C.tabDim
    btn.BorderSizePixel  = 0
    btn.AutoButtonColor  = false
    btn.LayoutOrder      = order or 0

    local iconLbl = Instance.new("TextLabel", btn)
    iconLbl.Size               = UDim2.new(1, 0, 0, 30)
    iconLbl.Position           = UDim2.new(0, 0, 0, 10)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text               = TAB_DATA[name] or "•"
    iconLbl.TextSize           = 20
    iconLbl.Font               = Enum.Font.GothamBold
    iconLbl.TextColor3         = C.textDim
    iconLbl.TextXAlignment     = Enum.TextXAlignment.Center

    local nameLbl = Instance.new("TextLabel", btn)
    nameLbl.Size               = UDim2.new(1, 0, 0, 14)
    nameLbl.Position           = UDim2.new(0, 0, 0, 40)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text               = name
    nameLbl.TextSize           = 10
    nameLbl.Font               = Enum.Font.GothamBold
    nameLbl.TextColor3         = C.textDim
    nameLbl.TextXAlignment     = Enum.TextXAlignment.Center

    local selLine = Instance.new("Frame", btn)
    selLine.Size             = UDim2.new(0, 3, 0.5, 0)
    selLine.Position         = UDim2.new(0, 0, 0.25, 0)
    selLine.BackgroundColor3 = C.accent
    selLine.BorderSizePixel  = 0
    selLine.Visible          = false
    Instance.new("UICorner", selLine).CornerRadius = UDim.new(1, 0)

    tabBtns[name] = {btn = btn, icon = iconLbl, namelbl = nameLbl, selLine = selLine}

    btn.MouseButton1Click:Connect(function()
        for n, s in pairs(tabs) do s.Visible = (n == name) end
        for n, t in pairs(tabBtns) do
            local on = (n == name)
            TweenService:Create(t.btn, TweenInfo.new(0.15), {
                BackgroundColor3 = on and C.tabSel or C.tabDim
            }):Play()
            t.icon.TextColor3   = on and C.accent  or C.textDim
            t.namelbl.TextColor3 = on and C.text   or C.textDim
            t.selLine.Visible    = on
        end
    end)

    return scroll
end

-- ══════════════════════════════════════
--  POPULAR TABS
-- ══════════════════════════════════════

-- FARM
local farm = addTab("Farm", 1)
secLabel(farm, "Combate", 1)
makeToggle(farm, "Auto Farm",    "AutoFarm",   2)
makeToggle(farm, "Auto Arise",   "AutoArise",  3)
makeToggle(farm, "Auto Sell",    "AutoSell",   4)
secLabel(farm, "Automação", 5)
makeToggle(farm, "Auto Enchant", "AutoEnchant",6)
makeToggle(farm, "Auto Infuse",  "AutoInfuse", 7)
makeToggle(farm, "Coletar AFK",  "AutoCollectAFK", 8)
makeToggle(farm, "Anti-AFK",     "AntiAFK",    9)

-- DUNGEON
local dung = addTab("Dungeon", 2)
secLabel(dung, "Masmorras", 1)
makeToggle(dung, "Auto Dungeon",          "AutoDungeon",  2)
makeToggle(dung, "Auto Rank Up",          "AutoRankUp",   3)
makeToggle(dung, "Auto Infernal Castle",  "AutoInfernal", 4)
secLabel(dung, "Night of Monarchs", 5)
makeToggle(dung, "Auto Bloodmoon Manor",  "AutoBloodmoon",6)
makeToggle(dung, "Auto Eclipse Court",    "AutoEclipse",  7)
makeToggle(dung, "Auto Arquiteto",        "AutoArquiteto",8)
secLabel(dung, "Ações Rápidas", 9)
makeButton(dung, "→  Entrar na Dungeon", function()
    local p = findPromptByKeywords({"dungeon","entrar","enter"})
    if p then
        local pp = p.Parent
        if pp then
            local pos = pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position)
            if pos then safeTP(pos); task.wait(0.3) end
        end
        firePrompt(p)
    end
end, 10)
makeButton(dung, "→  Infernal Castle", function()
    local p = findPromptByKeywords({"infernal","castle"})
    if p then
        local pp = p.Parent
        if pp then
            local pos = pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position)
            if pos then safeTP(pos); task.wait(0.3) end
        end
        firePrompt(p)
    end
end, 11)
makeButton(dung, "→  Bloodmoon Manor", function()
    local p = findPromptByKeywords({"bloodmoon","manor","blood"})
    if p then
        local pp = p.Parent
        if pp then
            local pos = pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position)
            if pos then safeTP(pos); task.wait(0.3) end
        end
        firePrompt(p)
    end
end, 12)
makeButton(dung, "→  Eclipse Court", function()
    local p = findPromptByKeywords({"eclipse","court"})
    if p then
        local pp = p.Parent
        if pp then
            local pos = pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position)
            if pos then safeTP(pos); task.wait(0.3) end
        end
        firePrompt(p)
    end
end, 13)
makeButton(dung, "→  Heavenly Castle", function()
    local p = findPromptByKeywords({"heavenly","heavenlycastle","arquiteto"})
    if p then
        local pp = p.Parent
        if pp then
            local pos = pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position)
            if pos then safeTP(pos); task.wait(0.3) end
        end
        firePrompt(p)
    end
end, 14)

-- rank alvo
secLabel(dung, "Rank Alvo", 15)
local selRankLbl = Instance.new("TextLabel", dung)
selRankLbl.Size               = UDim2.new(1, 0, 0, 22)
selRankLbl.BackgroundTransparency = 1
selRankLbl.Text               = "Selecionado:  " .. S.TargetRank
selRankLbl.TextColor3         = C.accent
selRankLbl.TextSize           = 12
selRankLbl.Font               = Enum.Font.GothamBold
selRankLbl.TextXAlignment     = Enum.TextXAlignment.Left
selRankLbl.LayoutOrder        = 16

local rankWrap = Instance.new("Frame", dung)
rankWrap.Size             = UDim2.new(1, 0, 0, 180)
rankWrap.BackgroundColor3 = C.item
rankWrap.BorderSizePixel  = 0
rankWrap.LayoutOrder      = 17
Instance.new("UICorner", rankWrap).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", rankWrap).Color = C.border

local rankSF = Instance.new("ScrollingFrame", rankWrap)
rankSF.Size                   = UDim2.new(1, -8, 1, -8)
rankSF.Position               = UDim2.new(0, 4, 0, 4)
rankSF.BackgroundTransparency = 1
rankSF.BorderSizePixel        = 0
rankSF.ScrollBarThickness     = 3
rankSF.ScrollBarImageColor3   = C.borderLt
rankSF.CanvasSize             = UDim2.new(0, 0, 0, 0)
rankSF.AutomaticCanvasSize    = Enum.AutomaticSize.Y

local rankGrid = Instance.new("UIGridLayout", rankSF)
rankGrid.CellSize    = UDim2.new(0.25, -4, 0, 32)
rankGrid.CellPadding = UDim2.new(0, 4, 0, 4)
rankGrid.SortOrder   = Enum.SortOrder.LayoutOrder
local rankPad = Instance.new("UIPadding", rankSF)
rankPad.PaddingLeft = UDim.new(0, 4); rankPad.PaddingTop = UDim.new(0, 4)

local rankCells = {}
for i, rank in ipairs(RANKS) do
    local cell = Instance.new("TextButton", rankSF)
    cell.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
    cell.BorderSizePixel  = 0
    cell.Text             = rank
    cell.TextColor3       = RANK_COLORS[rank] or C.text
    cell.TextSize         = 11
    cell.Font             = Enum.Font.GothamBold
    cell.LayoutOrder      = i
    cell.AutoButtonColor  = false
    Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 6)
    local cs = Instance.new("UIStroke", cell); cs.Color = C.border; cs.Thickness = 1
    rankCells[rank] = {cell = cell, stroke = cs}
    cell.MouseButton1Click:Connect(function()
        S.TargetRank = rank
        selRankLbl.Text = "Selecionado:  " .. rank
        for _, rc in pairs(rankCells) do
            rc.cell.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
            rc.stroke.Color = C.border
        end
        cell.BackgroundColor3 = C.accentDk
        cs.Color = C.accent
    end)
end

-- RAID
local raid = addTab("Raid", 3)
secLabel(raid, "Raids", 1)
makeToggle(raid, "Auto Raid", "AutoRaid", 2)
secLabel(raid, "Eventos", 3)
makeButton(raid, "→  Nightmare Kamish", function()
    local p = findPromptByKeywords({"kamish","nightmare","worldboss"})
    if p then
        local pp = p.Parent
        local pos = pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos) end; firePrompt(p)
    end
end, 4)
makeButton(raid, "→  Pumpkin King", function()
    local p = findPromptByKeywords({"pumpkin","king"})
    if p then
        local pp = p.Parent
        local pos = pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos) end; firePrompt(p)
    end
end, 5)
makeButton(raid, "→  Trick or Treat Gate", function()
    local p = findPromptByKeywords({"trick","treat","halloween"})
    if p then
        local pp = p.Parent
        local pos = pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos) end; firePrompt(p)
    end
end, 6)

-- TELEPORT
local tp = addTab("Teleport", 4)
secLabel(tp, "Rápido", 1)
makeButton(tp, "→  Mob mais próximo", function()
    local mob = getNearestMob()
    if mob then
        local mhrp = mob:FindFirstChild("HumanoidRootPart")
        if mhrp then safeTP(mhrp.Position) end
    end
end, 2)
makeButton(tp, "→  Rank Up NPC", function()
    local p = findPromptByKeywords({"rank","rankup","upgrade rank"})
    if p then
        local pp = p.Parent
        local pos = pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos) end
    end
end, 3)
makeButton(tp, "→  Shadow Upgrader", function()
    local p = findPromptByKeywords({"shadow","upgrade shadow"})
    if p then
        local pp = p.Parent
        local pos = pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos) end
    end
end, 4)
makeButton(tp, "→  Arquiteto Boss", function()
    local part = findByName({"arquiteto","architect"})
    if part then
        local pos = part:IsA("BasePart") and part.Position or part:GetPivot().Position
        safeTP(pos)
    end
end, 5)
secLabel(tp, "Ilhas", 6)
local islands = {
    {"Solo City",          {"solocity","solo city","solo"}},
    {"Leveling City",      {"levelingcity","leveling city","leveling"}},
    {"Grass Village",      {"grassvillage","grass village","grass"}},
    {"Brum Island",        {"brum"}},
    {"Mori Town",          {"mori"}},
    {"Ghoul Island",       {"ghoul"}},
    {"XZ City",            {"xzcity","xz city","xz"}},
    {"Ilha 30",            {"island30","ilha30"}},
    {"Blood Moonwoods",    {"moonwoods","bloodmoonwoods"}},
    {"Eclipse Paradise",   {"paradise","eclipse island"}},
    {"Abismo de Detritos", {"detritos","debris","abismo"}},
}
for i, isl in ipairs(islands) do
    makeButton(tp, "→  " .. isl[1], function()
        local part = findByName(isl[2])
        if part then
            local pos = part:IsA("BasePart") and part.Position or part:GetPivot().Position
            safeTP(pos)
        end
    end, 6 + i)
end

-- MISC
local misc = addTab("Misc", 5)
secLabel(misc, "Movimento", 1)
makeToggle(misc, "Noclip",     "Noclip",    2)
makeToggle(misc, "Speed Hack", "SpeedHack", 3)
makeSlider(misc, "Velocidade", 16, 300, "SpeedValue", 4)
secLabel(misc, "Utilitários", 5)
makeButton(misc, "Rejoin Server", function()
    TS:Teleport(game.PlaceId, lp)
end, 6)
makeButton(misc, "Print Remotes (Console)", function()
    for _, v in ipairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            print("[Remote]", v:GetFullName())
        end
    end
    print("[Done] Remotes printados no console")
end, 7)
makeButton(misc, "Print Prompts (Console)", function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            print("[Prompt]", v.Parent.Name, "|", v.ActionText, "|", v:GetFullName())
        end
    end
    print("[Done] Prompts printados no console")
end, 8)
makeButton(misc, "Copy UserID", function()
    pcall(function() setclipboard(tostring(lp.UserId)) end)
end, 9)

-- CONFIG
local cfg = addTab("Config", 6)
secLabel(cfg, "Keybind", 1)
local keyBtn = makeButton(cfg, "Tecla: RightShift", function() end, 2)
local listening = false
keyBtn.MouseButton1Up:Connect(function()
    listening = true
    keyBtn.Text      = "Pressione uma tecla..."
    keyBtn.TextColor3 = C.accent
end)

secLabel(cfg, "Auto Execute", 3)
local aeStatus = Instance.new("TextLabel", cfg)
aeStatus.Size                   = UDim2.new(1, 0, 0, 24)
aeStatus.BackgroundTransparency = 1
aeStatus.TextSize               = 12
aeStatus.Font                   = Enum.Font.Gotham
aeStatus.TextXAlignment         = Enum.TextXAlignment.Left
aeStatus.LayoutOrder            = 4

local AE_PATH    = "autoexec/AriseCrossover.lua"
local SCRIPT_URL = "https://raw.githubusercontent.com/Mopera-tech/AriseCrossover.lua/refs/heads/main/AriseCrossover.lua"

local function checkAE()
    local ok, res = pcall(function() return isfile(AE_PATH) end)
    if ok and res then
        aeStatus.Text       = "  ● Status: ATIVO"
        aeStatus.TextColor3 = C.accent
    else
        aeStatus.Text       = "  ● Status: INATIVO"
        aeStatus.TextColor3 = C.red
    end
end
checkAE()

makeButton(cfg, "Ativar Auto Execute", function()
    pcall(function()
        if not isfolder("autoexec") then makefolder("autoexec") end
        local line = "loadstring(game:HttpGet(" .. '"' .. SCRIPT_URL .. '"' .. "))()"
        writefile(AE_PATH, line)
    end)
    checkAE()
end, 5, C.accent)

makeButton(cfg, "Desativar Auto Execute", function()
    pcall(function()
        if isfile(AE_PATH) then delfile(AE_PATH) end
    end)
    checkAE()
end, 6, C.red)

secLabel(cfg, "Sobre", 7)
local infoLbl = Instance.new("TextLabel", cfg)
infoLbl.Size                   = UDim2.new(1, 0, 0, 55)
infoLbl.BackgroundTransparency = 1
infoLbl.Text                   = "Arise Hub\nArquiteto Update  ·  Nov 2026\nReal Executor"
infoLbl.TextColor3             = C.textDim
infoLbl.TextSize               = 12
infoLbl.Font                   = Enum.Font.Gotham
infoLbl.TextXAlignment         = Enum.TextXAlignment.Left
infoLbl.TextWrapped            = true
infoLbl.LayoutOrder            = 8

-- ══════════════════════════════════════
--  KEYBIND LISTENER
-- ══════════════════════════════════════
UIS.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
        S.OpenKey         = inp.KeyCode
        keyBtn.Text       = "Tecla: " .. inp.KeyCode.Name
        keyBtn.TextColor3 = C.text
        listening         = false
        return
    end
    if inp.KeyCode == S.OpenKey then
        win.Visible = not win.Visible
    end
end)

-- ══════════════════════════════════════
--  ABRE FARM POR PADRÃO
-- ══════════════════════════════════════
for n, s in pairs(tabs) do s.Visible = (n == "Farm") end
for n, t in pairs(tabBtns) do
    local on = (n == "Farm")
    t.btn.BackgroundColor3  = on and C.tabSel or C.tabDim
    t.icon.TextColor3       = on and C.accent  or C.textDim
    t.namelbl.TextColor3    = on and C.text    or C.textDim
    t.selLine.Visible       = on
end

print("[Arise Hub] Carregado | " .. S.OpenKey.Name .. " para abrir/fechar")
