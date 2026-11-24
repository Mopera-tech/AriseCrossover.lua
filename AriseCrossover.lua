-- Arise Crossover Hub | Real Executor
-- Arquiteto Update (Nov 2026)

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local TweenService= game:GetService("TweenService")
local UIS         = game:GetService("UserInputService")
local RS          = game:GetService("ReplicatedStorage")
local TS          = game:GetService("TeleportService")
local lp          = Players.LocalPlayer
local gui         = lp:WaitForChild("PlayerGui")

-- STATE
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

-- UTILS
local function getChar() return lp.Character end
local function getHRP() local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=getChar(); return c and c:FindFirstChild("Humanoid") end

local function safeTP(pos)
    local hrp=getHRP(); if not hrp then return end
    hrp.CFrame=CFrame.new(pos+Vector3.new(math.random(-2,2),2,math.random(-2,2)))
    task.wait(0.08)
end

local function getAllMobs()
    local mobs={}
    local hrp=getHRP(); if not hrp then return mobs end
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v~=getChar() then
            local mhrp=v:FindFirstChild("HumanoidRootPart")
            local mhum=v:FindFirstChild("Humanoid")
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

local function fireRemote(name,arg1,arg2)
    for _,v in ipairs(RS:GetDescendants()) do
        if v.Name==name and v:IsA("RemoteEvent") then
            pcall(function() v:FireServer(arg1,arg2) end); return true
        end
    end
end

local function findPart(keywords)
    for _,v in ipairs(workspace:GetDescendants()) do
        local n=v.Name:lower()
        for _,kw in ipairs(keywords) do if n:find(kw:lower()) then return v end end
    end
end

local function firePrompt(part)
    if not part then return end
    local function tryPrompt(p)
        local pr=p:FindFirstChildOfClass("ProximityPrompt")
        if pr then pcall(function() fireproximityprompt(pr) end); return true end
    end
    if not tryPrompt(part) and part.Parent then tryPrompt(part.Parent) end
end

local function killMobs(timeout,activeFlag)
    timeout=timeout or 60
    local t0=tick()
    while tick()-t0<timeout do
        if not S[activeFlag] then break end
        local mob=getNearestMob()
        if not mob then break end
        local mhrp=mob:FindFirstChild("HumanoidRootPart")
        if mhrp then
            safeTP(mhrp.Position)
            local mhum=mob:FindFirstChild("Humanoid")
            local t1=tick()
            while mhum and mhum.Health>0 and tick()-t1<12 do task.wait(0.05) end
            if S.AutoArise and mhum and mhum.Health<=0 then
                pcall(function() fireRemote("Arise",mob) end)
                task.wait(0.2)
            end
        end
        task.wait(0.05)
    end
end

-- LOOPS
task.spawn(function()
    while true do
        task.wait(0.1)
        if S.AutoFarm then
            local mob=getNearestMob()
            if mob then
                local mhrp=mob:FindFirstChild("HumanoidRootPart")
                if mhrp then
                    safeTP(mhrp.Position)
                    local mhum=mob:FindFirstChild("Humanoid")
                    local t1=tick()
                    while mhum and mhum.Health>0 and tick()-t1<12 do task.wait(0.05) end
                    if S.AutoArise and mhum and mhum.Health<=0 then
                        pcall(function() fireRemote("Arise",mob) end)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(5)
        if S.AutoSell then pcall(function() fireRemote("SellAll") end) end
        if S.AutoCollectAFK then pcall(function() fireRemote("ClaimAll") end) end
        if S.AutoEnchant then pcall(function() fireRemote("AutoEnchant") end) end
        if S.AutoInfuse then pcall(function() fireRemote("AutoInfuse") end) end
    end
end)

task.spawn(function()
    while true do
        task.wait(55)
        if S.AntiAFK then
            pcall(function()
                local vu=Instance.new("VirtualUser")
                vu.Parent=game; vu:CaptureController()
                vu:ClickButton2(Vector2.new()); vu:Destroy()
            end)
        end
    end
end)

RunService.Stepped:Connect(function()
    if S.Noclip then
        local c=getChar()
        if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
    end
end)

RunService.Heartbeat:Connect(function()
    local hum=getHum()
    if hum then hum.WalkSpeed=S.SpeedHack and S.SpeedValue or 16 end
end)

local function dungeonLoop(flag,keywords)
    task.spawn(function()
        while true do
            task.wait(1)
            if S[flag] then
                local gate=findPart(keywords)
                if gate then
                    local pos=gate:IsA("BasePart") and gate.Position or gate:GetPivot().Position
                    safeTP(pos); task.wait(0.5); firePrompt(gate); task.wait(2)
                    for _=1,20 do
                        if not S[flag] then break end
                        killMobs(50,flag); task.wait(0.5)
                        local adv=findPart({"nextroom","advance","continue","exit","door","portal"})
                        if adv then
                            local ap=adv:IsA("BasePart") and adv.Position or adv:GetPivot().Position
                            safeTP(ap); firePrompt(adv)
                        end
                        task.wait(2)
                    end
                end
            end
        end
    end)
end

dungeonLoop("AutoDungeon",   {"dungeongate","dungeon_gate","gate"})
dungeonLoop("AutoInfernal",  {"infernalcastle","infernal","castle"})
dungeonLoop("AutoBloodmoon", {"bloodmoon","manor","bloodmoonwoods"})
dungeonLoop("AutoEclipse",   {"eclipsecourt","eclipse","court"})
dungeonLoop("AutoArquiteto", {"arquiteto","architect","heavenly","detritos"})

-- ══════════════════════════════════════════════════════
-- UI
-- ══════════════════════════════════════════════════════
local C={
    bg       = Color3.fromRGB(8,8,10),
    panel    = Color3.fromRGB(12,12,16),
    item     = Color3.fromRGB(16,16,22),
    itemHov  = Color3.fromRGB(22,22,30),
    accent   = Color3.fromRGB(100,220,160),
    accentDk = Color3.fromRGB(30,70,50),
    accent2  = Color3.fromRGB(80,160,255),
    text     = Color3.fromRGB(220,220,230),
    textDim  = Color3.fromRGB(90,90,110),
    border   = Color3.fromRGB(30,30,42),
    borderLt = Color3.fromRGB(45,45,60),
    red      = Color3.fromRGB(220,55,55),
    white    = Color3.fromRGB(255,255,255),
    tabSel   = Color3.fromRGB(16,16,22),
    tabDim   = Color3.fromRGB(8,8,10),
}

local sg=Instance.new("ScreenGui")
sg.Name="AriseHub"; sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=gui

-- sombra
local shadow=Instance.new("Frame",sg)
shadow.Size=UDim2.new(0,796,0,536); shadow.Position=UDim2.new(0.5,-394,0.5,-260)
shadow.BackgroundColor3=Color3.fromRGB(0,0,0); shadow.BackgroundTransparency=0.6
shadow.BorderSizePixel=0
Instance.new("UICorner",shadow).CornerRadius=UDim.new(0,12)

local win=Instance.new("Frame",sg)
win.Name="Window"; win.Size=UDim2.new(0,780,0,520)
win.Position=UDim2.new(0.5,-390,0.5,-258)
win.BackgroundColor3=C.bg; win.BorderSizePixel=0
Instance.new("UICorner",win).CornerRadius=UDim.new(0,10)
local wStroke=Instance.new("UIStroke",win); wStroke.Color=C.border; wStroke.Thickness=1

-- faixa de cor no topo (decorativa)
local accent_bar=Instance.new("Frame",win)
accent_bar.Size=UDim2.new(1,0,0,2)
accent_bar.BackgroundColor3=C.accent; accent_bar.BorderSizePixel=0
Instance.new("UICorner",accent_bar).CornerRadius=UDim.new(0,10)

-- topbar
local top=Instance.new("Frame",win)
top.Size=UDim2.new(1,0,0,42); top.BackgroundColor3=C.panel; top.BorderSizePixel=0
Instance.new("UICorner",top).CornerRadius=UDim.new(0,10)
local topFix=Instance.new("Frame",top)
topFix.Size=UDim2.new(1,0,0,12); topFix.Position=UDim2.new(0,0,1,-12)
topFix.BackgroundColor3=C.panel; topFix.BorderSizePixel=0

-- dot decorativo
local dot=Instance.new("Frame",top)
dot.Size=UDim2.new(0,8,0,8); dot.Position=UDim2.new(0,14,0.5,-4)
dot.BackgroundColor3=C.accent; dot.BorderSizePixel=0
Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

local topTitle=Instance.new("TextLabel",top)
topTitle.Size=UDim2.new(1,-120,1,0); topTitle.Position=UDim2.new(0,30,0,0)
topTitle.BackgroundTransparency=1; topTitle.Text="Arise Hub"
topTitle.TextColor3=C.text; topTitle.TextSize=15
topTitle.Font=Enum.Font.GothamBold; topTitle.TextXAlignment=Enum.TextXAlignment.Left

local topSub=Instance.new("TextLabel",top)
topSub.Size=UDim2.new(0.5,0,1,0); topSub.Position=UDim2.new(0,110,0,0)
topSub.BackgroundTransparency=1; topSub.Text="Real Executor  •  Arquiteto Update"
topSub.TextColor3=C.textDim; topSub.TextSize=11
topSub.Font=Enum.Font.Gotham; topSub.TextXAlignment=Enum.TextXAlignment.Left

local function topBtn(sym,col,px,cb)
    local b=Instance.new("TextButton",top)
    b.Size=UDim2.new(0,26,0,26); b.Position=UDim2.new(1,px,0.5,-13)
    b.BackgroundColor3=col; b.Text=sym; b.TextColor3=C.white
    b.TextSize=12; b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
    b.MouseButton1Click:Connect(cb); return b
end
topBtn("x",C.red,-10,function() win.Visible=false end)
topBtn("-",C.border,-42,function()
    local full=UDim2.new(0,780,0,520)
    local mini=UDim2.new(0,780,0,42)
    win.Size=win.Size==full and mini or full
    shadow.Size=win.Size==full and UDim2.new(0,796,0,536) or UDim2.new(0,796,0,58)
end)

-- drag
local dragging,dragStart,startPos
top.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=inp.Position; startPos=win.Position
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
        local d=inp.Position-dragStart
        win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        shadow.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X-8,startPos.Y.Scale,startPos.Y.Offset+d.Y+2)
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

-- sidebar
local sidebar=Instance.new("Frame",win)
sidebar.Size=UDim2.new(0,120,1,-42); sidebar.Position=UDim2.new(0,0,0,42)
sidebar.BackgroundColor3=C.panel; sidebar.BorderSizePixel=0
local sideFix=Instance.new("Frame",sidebar)
sideFix.Size=UDim2.new(0,10,1,0); sideFix.Position=UDim2.new(1,-10,0,0)
sideFix.BackgroundColor3=C.panel; sideFix.BorderSizePixel=0
local sideList=Instance.new("UIListLayout",sidebar); sideList.SortOrder=Enum.SortOrder.LayoutOrder

-- separador lateral
local divider=Instance.new("Frame",win)
divider.Size=UDim2.new(0,1,1,-42); divider.Position=UDim2.new(0,120,0,42)
divider.BackgroundColor3=C.border; divider.BorderSizePixel=0

-- content
local contentArea=Instance.new("Frame",win)
contentArea.Size=UDim2.new(1,-121,1,-42); contentArea.Position=UDim2.new(0,121,0,42)
contentArea.BackgroundColor3=C.bg; contentArea.BorderSizePixel=0

local tabs,tabBtns={},{}
local TAB_ICONS={Farm="⚔",Dungeon="🏰",Raid="💀",Teleport="📍",Misc="🛠",Config="⚙"}

local function makeScroll(parent)
    local s=Instance.new("ScrollingFrame",parent)
    s.Size=UDim2.new(1,0,1,0); s.BackgroundTransparency=1
    s.BorderSizePixel=0; s.ScrollBarThickness=3
    s.ScrollBarImageColor3=C.borderLt; s.CanvasSize=UDim2.new(0,0,0,0)
    s.AutomaticCanvasSize=Enum.AutomaticSize.Y; s.Visible=false
    local pad=Instance.new("UIPadding",s)
    pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12); pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,12)
    local layout=Instance.new("UIListLayout",s)
    layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,6)
    return s
end

local function secLabel(parent,text,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.LayoutOrder=order or 0
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
    l.Text=text:upper(); l.TextColor3=C.accent
    l.TextSize=10; l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",f)
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=C.accentDk; line.BorderSizePixel=0
    return f
end

local function makeToggle(parent,label,key,order)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,36); row.BackgroundColor3=C.item
    row.BorderSizePixel=0; row.LayoutOrder=order or 0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local stroke=Instance.new("UIStroke",row); stroke.Color=C.border; stroke.Thickness=1

    -- indicador lateral
    local indicator=Instance.new("Frame",row)
    indicator.Size=UDim2.new(0,3,0.6,0); indicator.Position=UDim2.new(0,0,0.2,0)
    indicator.BackgroundColor3=C.textDim; indicator.BorderSizePixel=0
    Instance.new("UICorner",indicator).CornerRadius=UDim.new(1,0)

    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-58,1,0); lbl.Position=UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C.text
    lbl.TextSize=13; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left

    local pill=Instance.new("Frame",row)
    pill.Size=UDim2.new(0,40,0,20); pill.Position=UDim2.new(1,-50,0.5,-10)
    pill.BackgroundColor3=Color3.fromRGB(28,28,36); pill.BorderSizePixel=0
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame",pill)
    knob.Size=UDim2.new(0,14,0,14); knob.Position=UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3=Color3.fromRGB(120,120,140); knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local function refresh()
        local on=S[key]
        TweenService:Create(pill,TweenInfo.new(0.18),{BackgroundColor3=on and C.accentDk or Color3.fromRGB(28,28,36)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.18),{
            Position=on and UDim2.new(0,23,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3=on and C.accent or Color3.fromRGB(120,120,140)
        }):Play()
        TweenService:Create(indicator,TweenInfo.new(0.18),{BackgroundColor3=on and C.accent or C.textDim}):Play()
        stroke.Color=on and C.accentDk or C.border
    end
    row.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then S[key]=not S[key]; refresh() end
    end)
    refresh(); return row
end

local function makeButton(parent,label,cb,order,color)
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(1,0,0,36); btn.BackgroundColor3=C.item
    btn.Text=label; btn.TextColor3=color or C.text; btn.TextSize=13
    btn.Font=Enum.Font.Gotham; btn.BorderSizePixel=0
    btn.AutoButtonColor=false; btn.LayoutOrder=order or 0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    local stroke=Instance.new("UIStroke",btn); stroke.Color=C.border; stroke.Thickness=1
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.itemHov}):Play()
        stroke.Color=C.borderLt
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.item}):Play()
        stroke.Color=C.border
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.05),{BackgroundColor3=C.accentDk}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.itemHov}):Play()
        pcall(cb)
    end)
    return btn
end

local function makeSlider(parent,label,min,max,key,order)
    local wrap=Instance.new("Frame",parent)
    wrap.Size=UDim2.new(1,0,0,52); wrap.BackgroundColor3=C.item
    wrap.BorderSizePixel=0; wrap.LayoutOrder=order or 0
    Instance.new("UICorner",wrap).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",wrap).Color=C.border

    local lbl=Instance.new("TextLabel",wrap)
    lbl.Size=UDim2.new(0.6,0,0,22); lbl.Position=UDim2.new(0,12,0,6)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C.text
    lbl.TextSize=13; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left

    local valLbl=Instance.new("TextLabel",wrap)
    valLbl.Size=UDim2.new(0.35,0,0,22); valLbl.Position=UDim2.new(0.63,-12,0,6)
    valLbl.BackgroundTransparency=1; valLbl.Text=tostring(S[key])
    valLbl.TextColor3=C.accent; valLbl.TextSize=13
    valLbl.Font=Enum.Font.GothamBold; valLbl.TextXAlignment=Enum.TextXAlignment.Right

    local track=Instance.new("Frame",wrap)
    track.Size=UDim2.new(1,-24,0,6); track.Position=UDim2.new(0,12,0,34)
    track.BackgroundColor3=Color3.fromRGB(22,22,30); track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local pct=(S[key]-min)/(max-min)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=C.accent; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local thumb=Instance.new("Frame",track)
    thumb.Size=UDim2.new(0,12,0,12); thumb.Position=UDim2.new(pct,0,0.5,-6)
    thumb.BackgroundColor3=C.white; thumb.BorderSizePixel=0; thumb.ZIndex=3
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)

    local ds=false
    local function update(x)
        local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local val=math.floor(min+rel*(max-min))
        S[key]=val; valLbl.Text=tostring(val)
        fill.Size=UDim2.new(rel,0,1,0)
        thumb.Position=UDim2.new(rel,-6,0.5,-6)
    end
    track.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then ds=true; update(inp.Position.X) end end)
    UIS.InputChanged:Connect(function(inp) if ds and inp.UserInputType==Enum.UserInputType.MouseMovement then update(inp.Position.X) end end)
    UIS.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then ds=false end end)
    return wrap
end

local function addTab(name,order)
    local scroll=makeScroll(contentArea)
    tabs[name]=scroll

    local btn=Instance.new("TextButton",sidebar)
    btn.Size=UDim2.new(1,0,0,62); btn.BackgroundColor3=C.tabDim
    btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.LayoutOrder=order or 0

    -- layout interno do botão
    local icon=Instance.new("TextLabel",btn)
    icon.Size=UDim2.new(1,0,0,28); icon.Position=UDim2.new(0,0,0,8)
    icon.BackgroundTransparency=1; icon.Text=TAB_ICONS[name] or "•"
    icon.TextSize=18; icon.Font=Enum.Font.GothamBold
    icon.TextColor3=C.textDim; icon.TextXAlignment=Enum.TextXAlignment.Center

    local namelbl=Instance.new("TextLabel",btn)
    namelbl.Size=UDim2.new(1,0,0,16); namelbl.Position=UDim2.new(0,0,0,36)
    namelbl.BackgroundTransparency=1; namelbl.Text=name
    namelbl.TextSize=10; namelbl.Font=Enum.Font.GothamBold
    namelbl.TextColor3=C.textDim; namelbl.TextXAlignment=Enum.TextXAlignment.Center

    -- linha de seleção
    local selLine=Instance.new("Frame",btn)
    selLine.Size=UDim2.new(0,3,0.5,0); selLine.Position=UDim2.new(0,0,0.25,0)
    selLine.BackgroundColor3=C.accent; selLine.BorderSizePixel=0; selLine.Visible=false
    Instance.new("UICorner",selLine).CornerRadius=UDim.new(1,0)

    tabBtns[name]={btn=btn,icon=icon,namelbl=namelbl,selLine=selLine}

    btn.MouseButton1Click:Connect(function()
        for n,s in pairs(tabs) do s.Visible=(n==name) end
        for n,t in pairs(tabBtns) do
            local on=(n==name)
            TweenService:Create(t.btn,TweenInfo.new(0.15),{BackgroundColor3=on and C.tabSel or C.tabDim}):Play()
            t.icon.TextColor3=on and C.accent or C.textDim
            t.namelbl.TextColor3=on and C.text or C.textDim
            t.selLine.Visible=on
        end
    end)
    return scroll
end

-- ═══════════════════════════════
-- TABS
-- ═══════════════════════════════

-- FARM
local farm=addTab("Farm",1)
secLabel(farm,"Combate",1)
makeToggle(farm,"Auto Farm","AutoFarm",2)
makeToggle(farm,"Auto Arise","AutoArise",3)
makeToggle(farm,"Auto Sell","AutoSell",4)
secLabel(farm,"Automação",5)
makeToggle(farm,"Auto Enchant","AutoEnchant",6)
makeToggle(farm,"Auto Infuse","AutoInfuse",7)
makeToggle(farm,"Coletar AFK","AutoCollectAFK",8)
makeToggle(farm,"Anti-AFK","AntiAFK",9)

-- DUNGEON
local dung=addTab("Dungeon",2)
secLabel(dung,"Masmorras",1)
makeToggle(dung,"Auto Dungeon","AutoDungeon",2)
makeToggle(dung,"Auto Rank Up","AutoRankUp",3)
makeToggle(dung,"Auto Infernal Castle","AutoInfernal",4)
secLabel(dung,"Night of Monarchs",5)
makeToggle(dung,"Auto Bloodmoon Manor","AutoBloodmoon",6)
makeToggle(dung,"Auto Eclipse Court","AutoEclipse",7)
makeToggle(dung,"Auto Arquiteto","AutoArquiteto",8)
secLabel(dung,"Ações Rápidas",9)
makeButton(dung,"→  Entrar na Dungeon",function()
    local g=findPart({"dungeongate","gate","portal"})
    if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position); firePrompt(g) end
end,10)
makeButton(dung,"→  Infernal Castle",function()
    local g=findPart({"infernal","castle"})
    if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position); firePrompt(g) end
end,11)
makeButton(dung,"→  Bloodmoon Manor",function()
    local g=findPart({"bloodmoon","manor"})
    if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position); firePrompt(g) end
end,12)
makeButton(dung,"→  Eclipse Court",function()
    local g=findPart({"eclipse","court"})
    if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position); firePrompt(g) end
end,13)
makeButton(dung,"→  Heavenly Castle",function()
    local g=findPart({"heavenly","heavenlycastle"})
    if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position); firePrompt(g) end
end,14)

-- tabela de ranks
secLabel(dung,"Rank Alvo",15)
local selectedRankLabel=Instance.new("TextLabel",dung)
selectedRankLabel.Size=UDim2.new(1,0,0,22); selectedRankLabel.BackgroundTransparency=1
selectedRankLabel.Text="Selecionado: "..S.TargetRank; selectedRankLabel.TextColor3=C.accent
selectedRankLabel.TextSize=12; selectedRankLabel.Font=Enum.Font.GothamBold
selectedRankLabel.TextXAlignment=Enum.TextXAlignment.Left; selectedRankLabel.LayoutOrder=16

local rankWrap=Instance.new("Frame",dung)
rankWrap.Size=UDim2.new(1,0,0,170); rankWrap.BackgroundColor3=C.item
rankWrap.BorderSizePixel=0; rankWrap.LayoutOrder=17
Instance.new("UICorner",rankWrap).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",rankWrap).Color=C.border

local rankScroll=Instance.new("ScrollingFrame",rankWrap)
rankScroll.Size=UDim2.new(1,-8,1,-8); rankScroll.Position=UDim2.new(0,4,0,4)
rankScroll.BackgroundTransparency=1; rankScroll.BorderSizePixel=0
rankScroll.ScrollBarThickness=3; rankScroll.ScrollBarImageColor3=C.borderLt
rankScroll.CanvasSize=UDim2.new(0,0,0,0); rankScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y

local rankGrid=Instance.new("UIGridLayout",rankScroll)
rankGrid.CellSize=UDim2.new(0.25,-4,0,32); rankGrid.CellPadding=UDim2.new(0,4,0,4)
rankGrid.SortOrder=Enum.SortOrder.LayoutOrder
local rankPad=Instance.new("UIPadding",rankScroll); rankPad.PaddingLeft=UDim.new(0,4); rankPad.PaddingTop=UDim.new(0,4)

local rankCells={}
for i,rank in ipairs(RANKS) do
    local cell=Instance.new("TextButton",rankScroll)
    cell.BackgroundColor3=Color3.fromRGB(14,14,20); cell.BorderSizePixel=0
    cell.Text=rank; cell.TextColor3=RANK_COLORS[rank] or C.text
    cell.TextSize=11; cell.Font=Enum.Font.GothamBold
    cell.LayoutOrder=i; cell.AutoButtonColor=false
    Instance.new("UICorner",cell).CornerRadius=UDim.new(0,6)
    local cs=Instance.new("UIStroke",cell); cs.Color=C.border; cs.Thickness=1
    rankCells[rank]={cell=cell,stroke=cs}
    cell.MouseButton1Click:Connect(function()
        S.TargetRank=rank
        selectedRankLabel.Text="Selecionado: "..rank
        for _,rc in pairs(rankCells) do
            rc.cell.BackgroundColor3=Color3.fromRGB(14,14,20); rc.stroke.Color=C.border
        end
        cell.BackgroundColor3=C.accentDk; cs.Color=C.accent
    end)
end

-- RAID
local raid=addTab("Raid",3)
secLabel(raid,"Raids",1)
makeToggle(raid,"Auto Raid","AutoRaid",2)
secLabel(raid,"Eventos",3)
makeButton(raid,"→  Nightmare Kamish",function()
    local g=findPart({"kamish","nightmare","worldboss"})
    if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position) end
end,4)
makeButton(raid,"→  Pumpkin King",function()
    local g=findPart({"pumpkin","pumpkinking"})
    if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position) end
end,5)
makeButton(raid,"→  Trick or Treat Gate",function()
    local g=findPart({"trick","treatortreat","halloween"})
    if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position); firePrompt(g) end
end,6)

-- TELEPORT
local tp=addTab("Teleport",4)
secLabel(tp,"Rápido",1)
makeButton(tp,"→  Mob mais próximo",function()
    local mob=getNearestMob()
    if mob then local mhrp=mob:FindFirstChild("HumanoidRootPart"); if mhrp then safeTP(mhrp.Position) end end
end,2)
makeButton(tp,"→  Rank Up NPC",function()
    local g=findPart({"rankup","rank_up","ranknpc"}); if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position) end
end,3)
makeButton(tp,"→  Shadow Upgrader",function()
    local g=findPart({"shadowupgrader","shadow_upgrader","shadow"}); if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position) end
end,4)
makeButton(tp,"→  Arquiteto Boss",function()
    local g=findPart({"arquiteto","architect"}); if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position) end
end,5)
secLabel(tp,"Ilhas",6)
local islands={
    {"Solo City",{"solocity","solo"}}, {"Leveling City",{"levelingcity","leveling"}},
    {"Grass Village",{"grass","village"}}, {"Brum Island",{"brum"}},
    {"Mori Town",{"mori"}}, {"Ghoul Island",{"ghoul"}},
    {"XZ City",{"xzcity","xz"}}, {"Ilha 30",{"island30","ilha30"}},
    {"Blood Moonwoods",{"moonwoods","bloodmoon"}},
    {"Eclipse Paradise",{"paradise","eclipse"}},
    {"Abismo de Detritos",{"detritos","debris","abismo"}},
}
for i,isl in ipairs(islands) do
    makeButton(tp,"→  "..isl[1],function()
        local g=findPart(isl[2])
        if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position) end
    end,6+i)
end

-- MISC
local misc=addTab("Misc",5)
secLabel(misc,"Movimento",1)
makeToggle(misc,"Noclip","Noclip",2)
makeToggle(misc,"Speed Hack","SpeedHack",3)
makeSlider(misc,"Velocidade",16,300,"SpeedValue",4)
secLabel(misc,"Utilitários",5)
makeButton(misc,"Rejoin Server",function()
    TS:Teleport(game.PlaceId,lp)
end,6)
makeButton(misc,"Print Remotes",function()
    for _,v in ipairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then print("[Remote]",v:GetFullName()) end
    end
end,7)
makeButton(misc,"Copy UserID",function()
    pcall(function() setclipboard(tostring(lp.UserId)) end)
end,8)

-- CONFIG
local cfg=addTab("Config",6)
secLabel(cfg,"Keybind",1)
local keyBtn=makeButton(cfg,"Tecla: RightShift",function() end,2)
local listening=false
keyBtn.MouseButton1Up:Connect(function()
    listening=true; keyBtn.Text="Pressione uma tecla..."; keyBtn.TextColor3=C.accent
end)
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if listening and inp.UserInputType==Enum.UserInputType.Keyboard then
        S.OpenKey=inp.KeyCode
        keyBtn.Text="Tecla: "..inp.KeyCode.Name
        keyBtn.TextColor3=C.text; listening=false
    end
    if not listening and inp.KeyCode==S.OpenKey then win.Visible=not win.Visible end
end)
secLabel(cfg,"Auto Execute",3)
local aeStatus=Instance.new("TextLabel",cfg)
aeStatus.Size=UDim2.new(1,0,0,22); aeStatus.BackgroundTransparency=1
aeStatus.TextSize=12; aeStatus.Font=Enum.Font.Gotham
aeStatus.TextXAlignment=Enum.TextXAlignment.Left; aeStatus.LayoutOrder=4
local AE_PATH="autoexec/AriseCrossover.lua"
local SCRIPT_URL="https://raw.githubusercontent.com/Mopera-tech/AriseCrossover.lua/refs/heads/main/AriseCrossover.lua"
local function checkAE()
    local ok,res=pcall(function() return isfile(AE_PATH) end)
    if ok and res then
        aeStatus.Text="  ● Auto Execute: ATIVO"; aeStatus.TextColor3=C.accent
    else
        aeStatus.Text="  ● Auto Execute: INATIVO"; aeStatus.TextColor3=C.red
    end
end
checkAE()
makeButton(cfg,"Ativar Auto Execute",function()
    pcall(function()
        if not isfolder("autoexec") then makefolder("autoexec") end
        writefile(AE_PATH,'loadstring(game:HttpGet("'..SCRIPT_URL..'"))()')
    end)
    checkAE()
end,5,C.accent)
makeButton(cfg,"Desativar Auto Execute",function()
    pcall(function() if isfile(AE_PATH) then delfile(AE_PATH) end end)
    checkAE()
end,6,C.red)
secLabel(cfg,"Sobre",7)
local infoLbl=Instance.new("TextLabel",cfg)
infoLbl.Size=UDim2.new(1,0,0,50); infoLbl.BackgroundTransparency=1
infoLbl.Text="Arise Hub\nArquiteto Update  •  Nov 2026\nReal Executor"
infoLbl.TextColor3=C.textDim; infoLbl.TextSize=12; infoLbl.Font=Enum.Font.Gotham
infoLbl.TextXAlignment=Enum.TextXAlignment.Left; infoLbl.TextWrapped=true; infoLbl.LayoutOrder=8

-- abre Farm
for n,s in pairs(tabs) do s.Visible=(n=="Farm") end
for n,t in pairs(tabBtns) do
    local on=(n=="Farm")
    t.btn.BackgroundColor3=on and C.tabSel or C.tabDim
    t.icon.TextColor3=on and C.accent or C.textDim
    t.namelbl.TextColor3=on and C.text or C.textDim
    t.selLine.Visible=on
end

print("[Arise Hub] Carregado | "..S.OpenKey.Name.." para abrir/fechar")
