-- ╔══════════════════════════════════════════════════════╗
-- ║           ARISE CROSSOVER HUB — REAL EXECUTOR        ║
-- ║      Atualizado até: Arquiteto Update (Nov 2026)     ║
-- ╚══════════════════════════════════════════════════════╝

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local TweenService= game:GetService("TweenService")
local UIS         = game:GetService("UserInputService")
local RS          = game:GetService("ReplicatedStorage")
local lp          = Players.LocalPlayer
local gui         = lp:WaitForChild("PlayerGui")

local S = {
    AutoFarm=false, AutoArise=false, AutoSell=false, AntiAFK=false,
    AutoDungeon=false, AutoRankUp=false, AutoInfernal=false,
    AutoBloodmoon=false, AutoEclipse=false, AutoArquiteto=false,
    AutoRaid=false, AutoHalloween=false, AutoTrickOrTreat=false,
    Noclip=false, SpeedHack=false, SpeedValue=32,
    AutoEnchant=false, AutoInfuse=false, AutoCollectAFK=false,
    TargetRank="S", OpenKey=Enum.KeyCode.RightShift,
}

local RANKS = {"E","D","C","B","A","S","SS","G","GM","N","N+","HSR","HSR+","UGM","MR","MR+","GR","GR+","GL","GL+"}

local RANK_COLORS = {
    E=Color3.fromRGB(150,150,150), D=Color3.fromRGB(100,180,100),
    C=Color3.fromRGB(100,160,220), B=Color3.fromRGB(160,100,220),
    A=Color3.fromRGB(220,180,60),  S=Color3.fromRGB(220,120,40),
    SS=Color3.fromRGB(220,60,60),  G=Color3.fromRGB(80,200,220),
    GM=Color3.fromRGB(60,220,180), N=Color3.fromRGB(180,60,220),
    ["N+"]=Color3.fromRGB(200,80,240), HSR=Color3.fromRGB(240,160,40),
    ["HSR+"]=Color3.fromRGB(255,180,60), UGM=Color3.fromRGB(80,160,255),
    MR=Color3.fromRGB(255,80,120), ["MR+"]=Color3.fromRGB(255,100,140),
    GR=Color3.fromRGB(255,200,80), ["GR+"]=Color3.fromRGB(255,215,100),
    GL=Color3.fromRGB(180,255,180), ["GL+"]=Color3.fromRGB(200,255,200),
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
    for _,fname in ipairs({"Enemies","Mobs","NPCs","Monsters"}) do
        local f=workspace:FindFirstChild(fname)
        if f then
            for _,m in ipairs(f:GetChildren()) do
                local mhrp=m:FindFirstChild("HumanoidRootPart")
                local mhum=m:FindFirstChild("Humanoid")
                if mhrp and mhum and mhum.Health>0 then table.insert(mobs,m) end
            end
        end
    end
    if #mobs==0 then
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") then
                local mhrp=v:FindFirstChild("HumanoidRootPart")
                local mhum=v:FindFirstChild("Humanoid")
                if mhrp and mhum and mhum.Health>0 and v~=getChar() then
                    local isP=false
                    for _,p in ipairs(Players:GetPlayers()) do if p.Character==v then isP=true;break end end
                    if not isP then table.insert(mobs,v) end
                end
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

local function fireRemote(name,...)
    for _,v in ipairs(RS:GetDescendants()) do
        if v.Name==name and v:IsA("RemoteEvent") then
            pcall(function() v:FireServer(...) end); return true
        end
    end
end

local function findPart(keywords)
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Model") then
            local n=v.Name:lower()
            for _,kw in ipairs(keywords) do if n:find(kw:lower()) then return v end end
        end
    end
end

local function firePrompt(part)
    if not part then return end
    local pr=part:FindFirstChildOfClass("ProximityPrompt")
        or (part.Parent and part.Parent:FindFirstChildOfClass("ProximityPrompt"))
    if pr then pcall(function() fireproximityprompt(pr) end) end
end

local function killMobs(timeout)
    timeout=timeout or 60
    local t0=tick()
    while tick()-t0<timeout do
        if not S.AutoDungeon and not S.AutoFarm then break end
        local mob=getNearestMob()
        if not mob then break end
        local mhrp=mob:FindFirstChild("HumanoidRootPart")
        if mhrp then
            safeTP(mhrp.Position)
            local mhum=mob:FindFirstChild("Humanoid")
            local t1=tick()
            while mhum and mhum.Health>0 and tick()-t1<10 do task.wait(0.05) end
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
                    while mhum and mhum.Health>0 and tick()-t1<10 do task.wait(0.05) end
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

task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoDungeon then
            local gate=findPart({"dungeongate","dungeon_gate","gate","portal"})
            if gate then
                safeTP(gate.Position or gate:GetPivot().Position)
                task.wait(0.5); firePrompt(gate); task.wait(2)
                for _=1,15 do
                    if not S.AutoDungeon then break end
                    killMobs(50); task.wait(0.5)
                    local adv=findPart({"nextroom","advance","continue","exit","door"})
                    if adv then safeTP(adv.Position or adv:GetPivot().Position); firePrompt(adv) end
                    task.wait(2)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoInfernal then
            local inf=findPart({"infernalcastle","infernal","castle"})
            if inf then safeTP(inf.Position or inf:GetPivot().Position); task.wait(0.5); firePrompt(inf); task.wait(2); killMobs(90) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoBloodmoon then
            local m=findPart({"bloodmoon","manor"})
            if m then safeTP(m.Position or m:GetPivot().Position); task.wait(0.5); firePrompt(m); task.wait(2); killMobs(90) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoEclipse then
            local e=findPart({"eclipsecourt","eclipse","court"})
            if e then safeTP(e.Position or e:GetPivot().Position); task.wait(0.5); firePrompt(e); task.wait(2); killMobs(120) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if S.AutoArquiteto then
            local a=findPart({"arquiteto","architect","heavenly","detritos"})
            if a then safeTP(a.Position or a:GetPivot().Position); task.wait(0.5); firePrompt(a); task.wait(2); killMobs(120) end
        end
    end
end)

-- CORES
local C={
    bg=Color3.fromRGB(6,6,8), sidebar=Color3.fromRGB(9,9,12),
    item=Color3.fromRGB(15,15,20), accent=Color3.fromRGB(90,210,140),
    accentDim=Color3.fromRGB(40,80,60), text=Color3.fromRGB(215,215,225),
    textDim=Color3.fromRGB(100,100,120), border=Color3.fromRGB(28,28,38),
    red=Color3.fromRGB(200,50,50), white=Color3.fromRGB(255,255,255),
    tabSel=Color3.fromRGB(18,18,26), tabDim=Color3.fromRGB(9,9,12),
}

-- GUI
local sg=Instance.new("ScreenGui")
sg.Name="AriseHub"; sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=gui

local win=Instance.new("Frame",sg)
win.Name="Window"; win.Size=UDim2.new(0,620,0,460)
win.Position=UDim2.new(0.5,-310,0.5,-230)
win.BackgroundColor3=C.bg; win.BorderSizePixel=0; win.Active=true
Instance.new("UICorner",win).CornerRadius=UDim.new(0,10)
local wStroke=Instance.new("UIStroke",win); wStroke.Color=C.border; wStroke.Thickness=1

local top=Instance.new("Frame",win)
top.Size=UDim2.new(1,0,0,38); top.BackgroundColor3=C.sidebar; top.BorderSizePixel=0
Instance.new("UICorner",top).CornerRadius=UDim.new(0,10)
local topFix=Instance.new("Frame",top)
topFix.Size=UDim2.new(1,0,0,10); topFix.Position=UDim2.new(0,0,1,-10)
topFix.BackgroundColor3=C.sidebar; topFix.BorderSizePixel=0

local topTitle=Instance.new("TextLabel",top)
topTitle.Size=UDim2.new(1,-80,1,0); topTitle.Position=UDim2.new(0,14,0,0)
topTitle.BackgroundTransparency=1; topTitle.Text="Arise Hub  |  Real"
topTitle.TextColor3=C.text; topTitle.TextSize=14
topTitle.Font=Enum.Font.GothamBold; topTitle.TextXAlignment=Enum.TextXAlignment.Left

local function topBtn(sym,col,px,cb)
    local b=Instance.new("TextButton",top)
    b.Size=UDim2.new(0,24,0,24); b.Position=UDim2.new(1,px,0.5,-12)
    b.BackgroundColor3=col; b.Text=sym; b.TextColor3=C.white
    b.TextSize=11; b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
    b.MouseButton1Click:Connect(cb); return b
end
topBtn("x",C.red,-8,function() win.Visible=false end)
topBtn("-",C.border,-36,function()
    win.Size=win.Size==UDim2.new(0,620,0,460) and UDim2.new(0,620,0,38) or UDim2.new(0,620,0,460)
end)

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
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

local sidebar=Instance.new("Frame",win)
sidebar.Size=UDim2.new(0,110,1,-38); sidebar.Position=UDim2.new(0,0,0,38)
sidebar.BackgroundColor3=C.sidebar; sidebar.BorderSizePixel=0
local sideList=Instance.new("UIListLayout",sidebar); sideList.SortOrder=Enum.SortOrder.LayoutOrder

local divider=Instance.new("Frame",win)
divider.Size=UDim2.new(0,1,1,-38); divider.Position=UDim2.new(0,110,0,38)
divider.BackgroundColor3=C.border; divider.BorderSizePixel=0

local contentArea=Instance.new("Frame",win)
contentArea.Size=UDim2.new(1,-111,1,-38); contentArea.Position=UDim2.new(0,111,0,38)
contentArea.BackgroundColor3=C.bg; contentArea.BorderSizePixel=0

local tabs,tabBtns={},{}

local function makeScroll(parent)
    local s=Instance.new("ScrollingFrame",parent)
    s.Size=UDim2.new(1,0,1,0); s.BackgroundTransparency=1
    s.BorderSizePixel=0; s.ScrollBarThickness=3
    s.ScrollBarImageColor3=C.border; s.CanvasSize=UDim2.new(0,0,0,0)
    s.AutomaticCanvasSize=Enum.AutomaticSize.Y; s.Visible=false
    local pad=Instance.new("UIPadding",s)
    pad.PaddingLeft=UDim.new(0,10); pad.PaddingRight=UDim.new(0,10); pad.PaddingTop=UDim.new(0,10)
    local layout=Instance.new("UIListLayout",s)
    layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,5)
    return s
end

local function secLabel(parent,text,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,22); f.BackgroundTransparency=1; f.LayoutOrder=order or 0
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
    l.Text="  "..text:upper(); l.TextColor3=C.accentDim
    l.TextSize=10; l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",f)
    line.Size=UDim2.new(1,-10,0,1); line.Position=UDim2.new(0,5,1,-1)
    line.BackgroundColor3=C.border; line.BorderSizePixel=0
    return f
end

local function makeToggle(parent,label,key,order)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,34); row.BackgroundColor3=C.item
    row.BorderSizePixel=0; row.LayoutOrder=order or 0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local stroke=Instance.new("UIStroke",row); stroke.Color=C.border; stroke.Thickness=1
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-54,1,0); lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C.text
    lbl.TextSize=13; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local pill=Instance.new("Frame",row)
    pill.Size=UDim2.new(0,38,0,20); pill.Position=UDim2.new(1,-48,0.5,-10)
    pill.BackgroundColor3=Color3.fromRGB(30,30,38); pill.BorderSizePixel=0
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill)
    knob.Size=UDim2.new(0,14,0,14); knob.Position=UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3=Color3.fromRGB(140,140,160); knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local function refresh()
        local on=S[key]
        TweenService:Create(pill,TweenInfo.new(0.15),{BackgroundColor3=on and C.accent or Color3.fromRGB(30,30,38)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.15),{
            Position=on and UDim2.new(0,21,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3=on and C.white or Color3.fromRGB(140,140,160)
        }):Play()
        stroke.Color=S[key] and C.accentDim or C.border
    end
    row.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then S[key]=not S[key]; refresh() end
    end)
    refresh(); return row
end

local function makeButton(parent,label,cb,order)
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(1,0,0,34); btn.BackgroundColor3=C.item
    btn.Text=label; btn.TextColor3=C.text; btn.TextSize=13
    btn.Font=Enum.Font.Gotham; btn.BorderSizePixel=0
    btn.AutoButtonColor=false; btn.LayoutOrder=order or 0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)
    local stroke=Instance.new("UIStroke",btn); stroke.Color=C.border; stroke.Thickness=1
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(22,22,30)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.item}):Play() end)
    btn.MouseButton1Click:Connect(function() pcall(cb) end)
    return btn
end

local function makeSlider(parent,label,min,max,key,order)
    local wrap=Instance.new("Frame",parent)
    wrap.Size=UDim2.new(1,0,0,46); wrap.BackgroundColor3=C.item
    wrap.BorderSizePixel=0; wrap.LayoutOrder=order or 0
    Instance.new("UICorner",wrap).CornerRadius=UDim.new(0,7)
    Instance.new("UIStroke",wrap).Color=C.border
    local lbl=Instance.new("TextLabel",wrap)
    lbl.Size=UDim2.new(0.6,0,0,20); lbl.Position=UDim2.new(0,12,0,4)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C.text
    lbl.TextSize=12; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local valLbl=Instance.new("TextLabel",wrap)
    valLbl.Size=UDim2.new(0.35,0,0,20); valLbl.Position=UDim2.new(0.63,0,0,4)
    valLbl.BackgroundTransparency=1; valLbl.Text=tostring(S[key])
    valLbl.TextColor3=C.accent; valLbl.TextSize=12
    valLbl.Font=Enum.Font.GothamBold; valLbl.TextXAlignment=Enum.TextXAlignment.Right
    local track=Instance.new("Frame",wrap)
    track.Size=UDim2.new(1,-24,0,6); track.Position=UDim2.new(0,12,0,30)
    track.BackgroundColor3=Color3.fromRGB(25,25,35); track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local pct=(S[key]-min)/(max-min)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=C.accent; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local ds=false
    local function update(x)
        local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local val=math.floor(min+rel*(max-min))
        S[key]=val; valLbl.Text=tostring(val); fill.Size=UDim2.new(rel,0,1,0)
    end
    track.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then ds=true; update(inp.Position.X) end end)
    UIS.InputChanged:Connect(function(inp) if ds and inp.UserInputType==Enum.UserInputType.MouseMovement then update(inp.Position.X) end end)
    UIS.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then ds=false end end)
    return wrap
end

local function addTab(name,icon,order)
    local scroll=makeScroll(contentArea)
    tabs[name]=scroll
    local btn=Instance.new("TextButton",sidebar)
    btn.Size=UDim2.new(1,0,0,55); btn.BackgroundColor3=C.tabDim
    btn.BorderSizePixel=0; btn.Text=icon.."\n"..name
    btn.TextColor3=C.textDim; btn.TextSize=10
    btn.Font=Enum.Font.GothamBold; btn.AutoButtonColor=false; btn.LayoutOrder=order or 0
    tabBtns[name]=btn
    btn.MouseButton1Click:Connect(function()
        for n,s in pairs(tabs) do s.Visible=(n==name) end
        for n,b in pairs(tabBtns) do
            TweenService:Create(b,TweenInfo.new(0.12),{
                BackgroundColor3=n==name and C.tabSel or C.tabDim,
                TextColor3=n==name and C.text or C.textDim,
            }):Play()
        end
    end)
    return scroll
end

-- TABS
local farm=addTab("Farm","[F]",1)
secLabel(farm,"Combate",1)
makeToggle(farm,"Auto Farm","AutoFarm",2)
makeToggle(farm,"Auto Arise","AutoArise",3)
makeToggle(farm,"Auto Sell","AutoSell",4)
secLabel(farm,"Automacao",5)
makeToggle(farm,"Auto Enchant","AutoEnchant",6)
makeToggle(farm,"Auto Infuse","AutoInfuse",7)
makeToggle(farm,"Coletar AFK","AutoCollectAFK",8)
makeToggle(farm,"Anti-AFK","AntiAFK",9)

local dung=addTab("Dungeon","[D]",2)
secLabel(dung,"Masmorras",1)
makeToggle(dung,"Auto Dungeon","AutoDungeon",2)
makeToggle(dung,"Auto Rank Up","AutoRankUp",3)
makeToggle(dung,"Auto Infernal Castle","AutoInfernal",4)
secLabel(dung,"Night of Monarchs",5)
makeToggle(dung,"Auto Bloodmoon Manor","AutoBloodmoon",6)
makeToggle(dung,"Auto Eclipse Court","AutoEclipse",7)
makeToggle(dung,"Auto Arquiteto","AutoArquiteto",8)
secLabel(dung,"Acoes Rapidas",9)
makeButton(dung,"-> Entrar na Dungeon",function()
    local g=findPart({"dungeongate","gate","portal"})
    if g then safeTP(g.Position or g:GetPivot().Position); firePrompt(g) end
end,10)
makeButton(dung,"-> Infernal Castle",function()
    local g=findPart({"infernal","castle"})
    if g then safeTP(g.Position or g:GetPivot().Position); firePrompt(g) end
end,11)
makeButton(dung,"-> Bloodmoon Manor",function()
    local g=findPart({"bloodmoon","manor"})
    if g then safeTP(g.Position or g:GetPivot().Position); firePrompt(g) end
end,12)
makeButton(dung,"-> Eclipse Court",function()
    local g=findPart({"eclipse","court"})
    if g then safeTP(g.Position or g:GetPivot().Position); firePrompt(g) end
end,13)
makeButton(dung,"-> Heavenly Castle",function()
    local g=findPart({"heavenly","castle","heavenlycastle"})
    if g then safeTP(g.Position or g:GetPivot().Position); firePrompt(g) end
end,14)

-- tabela de ranks
secLabel(dung,"Rank Alvo",15)
local rankFrame=Instance.new("Frame",dung)
rankFrame.Size=UDim2.new(1,0,0,200); rankFrame.BackgroundColor3=Color3.fromRGB(11,11,15)
rankFrame.BorderSizePixel=0; rankFrame.LayoutOrder=16
Instance.new("UICorner",rankFrame).CornerRadius=UDim.new(0,7)
Instance.new("UIStroke",rankFrame).Color=C.border

local rankScroll=Instance.new("ScrollingFrame",rankFrame)
rankScroll.Size=UDim2.new(1,0,1,0); rankScroll.BackgroundTransparency=1
rankScroll.BorderSizePixel=0; rankScroll.ScrollBarThickness=3
rankScroll.ScrollBarImageColor3=C.border; rankScroll.CanvasSize=UDim2.new(0,0,0,0)
rankScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y

local rankGrid=Instance.new("UIGridLayout",rankScroll)
rankGrid.CellSize=UDim2.new(0.5,-6,0,30); rankGrid.CellPadding=UDim2.new(0,4,0,4)
rankGrid.SortOrder=Enum.SortOrder.LayoutOrder
local rankPad=Instance.new("UIPadding",rankScroll)
rankPad.PaddingLeft=UDim.new(0,6); rankPad.PaddingRight=UDim.new(0,6); rankPad.PaddingTop=UDim.new(0,6)

for i,rank in ipairs(RANKS) do
    local cell=Instance.new("TextButton",rankScroll)
    cell.BackgroundColor3=Color3.fromRGB(18,18,26); cell.BorderSizePixel=0
    cell.Text=rank; cell.TextColor3=RANK_COLORS[rank] or C.text
    cell.TextSize=12; cell.Font=Enum.Font.GothamBold
    cell.LayoutOrder=i; cell.AutoButtonColor=false
    Instance.new("UICorner",cell).CornerRadius=UDim.new(0,5)
    cell.MouseButton1Click:Connect(function()
        S.TargetRank=rank
        for _,c in ipairs(rankScroll:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundColor3=c.Text==rank and Color3.fromRGB(30,30,50) or Color3.fromRGB(18,18,26)
            end
        end
    end)
end

local raid=addTab("Raid","[R]",3)
secLabel(raid,"Raids",1)
makeToggle(raid,"Auto Raid","AutoRaid",2)
makeToggle(raid,"Trick or Treat Gate","AutoTrickOrTreat",3)
makeToggle(raid,"Halloween Raid","AutoHalloween",4)
makeButton(raid,"-> Nightmare Kamish",function()
    local g=findPart({"kamish","nightmare","worldboss"})
    if g then safeTP(g.Position or g:GetPivot().Position) end
end,5)
makeButton(raid,"-> Pumpkin King",function()
    local g=findPart({"pumpkin","pumpkinking"})
    if g then safeTP(g.Position or g:GetPivot().Position) end
end,6)

local tp=addTab("Teleport","[T]",4)
secLabel(tp,"Mobs e NPCs",1)
makeButton(tp,"-> Mob mais proximo",function()
    local mob=getNearestMob()
    if mob then local mhrp=mob:FindFirstChild("HumanoidRootPart"); if mhrp then safeTP(mhrp.Position) end end
end,2)
makeButton(tp,"-> Rank Up NPC",function()
    local g=findPart({"rankup","rank_up","ranknpc"}); if g then safeTP(g.Position or g:GetPivot().Position) end
end,3)
makeButton(tp,"-> Shadow Upgrader",function()
    local g=findPart({"shadowupgrader","shadow_upgrader"}); if g then safeTP(g.Position or g:GetPivot().Position) end
end,4)
makeButton(tp,"-> Arquiteto Boss",function()
    local g=findPart({"arquiteto","architect"}); if g then safeTP(g.Position or g:GetPivot().Position) end
end,5)
secLabel(tp,"Ilhas",6)
local islands={
    {"Solo City",{"solocity","solo"}},
    {"Leveling City",{"levelingcity","leveling"}},
    {"Grass Village",{"grass","village"}},
    {"Brum Island",{"brum"}},
    {"Mori Town",{"mori"}},
    {"Ghoul Island",{"ghoul"}},
    {"XZ City",{"xzcity","xz"}},
    {"Ilha 30",{"island30","ilha30"}},
    {"Blood Moonwoods",{"moonwoods","bloodmoon"}},
    {"Eclipse Paradise",{"paradise","eclipse"}},
    {"Abismo de Detritos",{"detritos","debris","abismo"}},
}
for i,isl in ipairs(islands) do
    makeButton(tp,"-> "..isl[1],function()
        local g=findPart(isl[2])
        if g then safeTP(g:IsA("BasePart") and g.Position or g:GetPivot().Position) end
    end,6+i)
end

local misc=addTab("Misc","[M]",5)
secLabel(misc,"Movimento",1)
makeToggle(misc,"Noclip","Noclip",2)
makeToggle(misc,"Speed Hack","SpeedHack",3)
makeSlider(misc,"Velocidade",16,300,"SpeedValue",4)
secLabel(misc,"Utilitarios",5)
makeButton(misc,"Rejoin Server",function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,lp)
end,6)
makeButton(misc,"Print Remotes",function()
    for _,v in ipairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then print("[Remote]",v:GetFullName()) end
    end
end,7)

local cfg=addTab("Config","[C]",6)
secLabel(cfg,"Keybind",1)
local keyBtn=makeButton(cfg,"Tecla: RightShift",function() end,2)
local listening=false
keyBtn.MouseButton1Click:Connect(function()
    listening=true; keyBtn.Text="Pressione uma tecla..."; keyBtn.TextColor3=C.accent
end)
UIS.InputBegan:Connect(function(inp)
    if listening and inp.UserInputType==Enum.UserInputType.Keyboard then
        S.OpenKey=inp.KeyCode
        keyBtn.Text="Tecla: "..inp.KeyCode.Name
        keyBtn.TextColor3=C.text; listening=false
    end
end)
secLabel(cfg,"Auto Execute",3)
local aeStatus=Instance.new("TextLabel",cfg)
aeStatus.Size=UDim2.new(1,0,0,24); aeStatus.BackgroundTransparency=1
aeStatus.TextSize=11; aeStatus.Font=Enum.Font.Gotham
aeStatus.TextXAlignment=Enum.TextXAlignment.Left; aeStatus.LayoutOrder=4
local AE_PATH="autoexec/AriseCrossover.lua"
local SCRIPT_URL="https://raw.githubusercontent.com/Mopera-tech/AriseCrossover.lua/refs/heads/main/AriseCrossover.lua"
local function checkAE()
    local ok=pcall(function() return isfile(AE_PATH) end)
    if ok and isfile(AE_PATH) then
        aeStatus.Text="  Ativo"; aeStatus.TextColor3=C.accent
    else
        aeStatus.Text="  Inativo"; aeStatus.TextColor3=C.red
    end
end
checkAE()
makeButton(cfg,"Ativar Auto Execute",function()
    pcall(function()
        if not isfolder("autoexec") then makefolder("autoexec") end
        writefile(AE_PATH,'loadstring(game:HttpGet("'..SCRIPT_URL..'"))()')
    end)
    checkAE()
end,5)
makeButton(cfg,"Desativar Auto Execute",function()
    pcall(function() if isfile(AE_PATH) then delfile(AE_PATH) end end)
    checkAE()
end,6)
secLabel(cfg,"Info",7)
local info=Instance.new("TextLabel",cfg)
info.Size=UDim2.new(1,0,0,40); info.BackgroundTransparency=1
info.Text="Arise Hub | Arquiteto Update (Nov 2026) | Real"
info.TextColor3=C.textDim; info.TextSize=11; info.Font=Enum.Font.Gotham
info.TextXAlignment=Enum.TextXAlignment.Left; info.TextWrapped=true; info.LayoutOrder=8

tabBtns["Farm"]:MouseButton1Click()

UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==S.OpenKey then win.Visible=not win.Visible end
end)

print("[Arise Hub] Carregado | "..S.OpenKey.Name.." para abrir/fechar")
