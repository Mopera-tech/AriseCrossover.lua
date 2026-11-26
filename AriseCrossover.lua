-- Arise Crossover Hub | Real Executor | Arquiteto Update (Nov 2026)

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RS           = game:GetService("ReplicatedStorage")
local TS           = game:GetService("TeleportService")
local Http         = game:GetService("HttpService")
local lp           = Players.LocalPlayer
local gui          = lp:WaitForChild("PlayerGui")

-- ══════════════════════════════════════
--  STATE
-- ══════════════════════════════════════
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
    E=Color3.fromRGB(160,160,160),D=Color3.fromRGB(80,200,80),C=Color3.fromRGB(80,140,255),
    B=Color3.fromRGB(180,80,255),A=Color3.fromRGB(255,200,40),S=Color3.fromRGB(255,120,30),
    SS=Color3.fromRGB(255,60,60),G=Color3.fromRGB(40,220,255),GM=Color3.fromRGB(40,255,180),
    N=Color3.fromRGB(200,40,255),["N+"]=Color3.fromRGB(220,80,255),HSR=Color3.fromRGB(255,170,30),
    ["HSR+"]=Color3.fromRGB(255,190,60),UGM=Color3.fromRGB(60,160,255),MR=Color3.fromRGB(255,60,120),
    ["MR+"]=Color3.fromRGB(255,80,140),GR=Color3.fromRGB(255,210,60),["GR+"]=Color3.fromRGB(255,225,90),
    GL=Color3.fromRGB(160,255,160),["GL+"]=Color3.fromRGB(180,255,200),
}

-- ══════════════════════════════════════
--  UTILS
-- ══════════════════════════════════════
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

local function findPromptByKW(kws)
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local a=v.ActionText:lower()
            local n=v.Parent and v.Parent.Name:lower() or ""
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
        local mob=getNearestMob()
        if not mob then break end
        local mhrp=mob:FindFirstChild("HumanoidRootPart")
        if mhrp then
            safeTP(mhrp.Position)
            local mhum=mob:FindFirstChild("Humanoid")
            local t1=tick()
            while mhum and mhum.Health>0 and tick()-t1<15 do
                local hrp=getHRP()
                if hrp and mhrp and (hrp.Position-mhrp.Position).Magnitude>8 then
                    safeTP(mhrp.Position)
                end
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

-- ══════════════════════════════════════
--  LOOPS
-- ══════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.1)
        if not S.AutoFarm then continue end
        local mob=getNearestMob()
        if not mob then continue end
        local mhrp=mob:FindFirstChild("HumanoidRootPart")
        if not mhrp then continue end
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
    local c=getChar()
    if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
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
            local pr=findPromptByKW(kws)
            if pr then
                local pp=pr.Parent
                local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
                if pos then safeTP(pos); task.wait(0.3) end
                firePrompt(pr); task.wait(2)
                for _=1,60 do
                    if not S[flagKey] then break end
                    killMobs(50,flagKey); task.wait(0.5)
                    local adv=findPromptByKW({"next","advance","continue","exit","door","portal","enter","pass","open","sala","porta","proximo"})
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

dungLoop("AutoDungeon",   {"dungeon","entrar","enter dungeon","sala"})
dungLoop("AutoInfernal",  {"infernal","castle","castelo infernal"})
dungLoop("AutoBloodmoon", {"bloodmoon","manor","blood moon"})
dungLoop("AutoEclipse",   {"eclipse","court","eclipse court"})
dungLoop("AutoArquiteto", {"arquiteto","architect","heavenly","detritos","debris"})

-- bloodmoon countess
task.spawn(function()
    while true do
        task.wait(0.5)
        if not S.AutoBloodmoon then continue end
        local countess=findByName({"countess","vilao","monster_boss","boss_main"})
        if countess then
            local cHum=countess:FindFirstChildOfClass("Humanoid")
            if cHum and cHum.Health>0 then
                local hide=findPromptByKW({"hide","esconder","coffin","caixao","closet","armario","chest"})
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

-- ══════════════════════════════════════
--  CORES
-- ══════════════════════════════════════
local C={
    bg       = Color3.fromRGB(8,8,10),
    panel    = Color3.fromRGB(12,12,16),
    card     = Color3.fromRGB(16,16,22),
    cardHov  = Color3.fromRGB(21,21,29),
    accent   = Color3.fromRGB(100,218,158),
    accentDk = Color3.fromRGB(24,62,44),
    text     = Color3.fromRGB(220,220,230),
    textDim  = Color3.fromRGB(88,88,108),
    border   = Color3.fromRGB(28,28,40),
    borderLt = Color3.fromRGB(44,44,58),
    red      = Color3.fromRGB(215,52,52),
    white    = Color3.fromRGB(255,255,255),
    tabHL    = Color3.fromRGB(16,16,22),
}

-- ══════════════════════════════════════
--  GUI SETUP
-- ══════════════════════════════════════
if gui:FindFirstChild("AriseHub") then gui:FindFirstChild("AriseHub"):Destroy() end

local sg=Instance.new("ScreenGui")
sg.Name="AriseHub"; sg.ResetOnSpawn=false
sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.Parent=gui

-- janela principal
local win=Instance.new("Frame",sg)
win.Name="Window"; win.AnchorPoint=Vector2.new(0.5,0.5)
win.Size=UDim2.new(0,780,0,520); win.Position=UDim2.new(0.5,0,0.5,0)
win.BackgroundColor3=C.bg; win.BorderSizePixel=0
win.Visible=true
Instance.new("UICorner",win).CornerRadius=UDim.new(0,12)
local wStroke=Instance.new("UIStroke",win); wStroke.Color=C.border; wStroke.Thickness=1

-- faixa topo
local topAccent=Instance.new("Frame",win)
topAccent.Size=UDim2.new(1,0,0,2); topAccent.BackgroundColor3=C.accent; topAccent.BorderSizePixel=0
Instance.new("UICorner",topAccent).CornerRadius=UDim.new(0,12)
local topAccentFix=Instance.new("Frame",win)
topAccentFix.Size=UDim2.new(1,0,0,2); topAccentFix.Position=UDim2.new(0,0,0,1)
topAccentFix.BackgroundColor3=C.accent; topAccentFix.BorderSizePixel=0

-- TOPBAR
local topbar=Instance.new("Frame",win)
topbar.Size=UDim2.new(1,0,0,46); topbar.Position=UDim2.new(0,0,0,2)
topbar.BackgroundColor3=C.panel; topbar.BorderSizePixel=0
local topFix=Instance.new("Frame",win)
topFix.Size=UDim2.new(1,0,0,8); topFix.Position=UDim2.new(0,0,0,38)
topFix.BackgroundColor3=C.panel; topFix.BorderSizePixel=0

local dot=Instance.new("Frame",topbar)
dot.Size=UDim2.new(0,8,0,8); dot.Position=UDim2.new(0,16,0.5,-4)
dot.BackgroundColor3=C.accent; dot.BorderSizePixel=0
Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

local titleLbl=Instance.new("TextLabel",topbar)
titleLbl.Size=UDim2.new(0,120,1,0); titleLbl.Position=UDim2.new(0,30,0,0)
titleLbl.BackgroundTransparency=1; titleLbl.Text="Arise Hub"
titleLbl.TextColor3=C.text; titleLbl.TextSize=15
titleLbl.Font=Enum.Font.GothamBold; titleLbl.TextXAlignment=Enum.TextXAlignment.Left

local subLbl=Instance.new("TextLabel",topbar)
subLbl.Size=UDim2.new(0,280,1,0); subLbl.Position=UDim2.new(0,145,0,0)
subLbl.BackgroundTransparency=1; subLbl.Text="Real Executor  ·  Arquiteto Update"
subLbl.TextColor3=C.textDim; subLbl.TextSize=11
subLbl.Font=Enum.Font.Gotham; subLbl.TextXAlignment=Enum.TextXAlignment.Left

local topSep=Instance.new("Frame",win)
topSep.Size=UDim2.new(1,0,0,1); topSep.Position=UDim2.new(0,0,0,48)
topSep.BackgroundColor3=C.border; topSep.BorderSizePixel=0

-- botões topo
local function topBtn(sym,col,px,cb)
    local b=Instance.new("TextButton",topbar)
    b.Size=UDim2.new(0,26,0,26); b.Position=UDim2.new(1,px,0.5,-13)
    b.BackgroundColor3=col; b.Text=sym; b.TextColor3=C.white
    b.TextSize=12; b.Font=Enum.Font.GothamBold; b.BorderSizePixel=0; b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
    b.MouseButton1Click:Connect(cb); return b
end

local minimized=false
topBtn("x",C.red,-10,function()
    TweenService:Create(win,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{
        Size=UDim2.new(0,780,0,0),BackgroundTransparency=1
    }):Play()
    task.wait(0.22); win.Visible=false
    win.Size=UDim2.new(0,780,0,520); win.BackgroundTransparency=0
end)
topBtn("−",C.border,-42,function()
    minimized=not minimized
    local targetH=minimized and 48 or 520
    TweenService:Create(win,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{
        Size=UDim2.new(0,780,0,targetH)
    }):Play()
end)

-- drag
local dragging,dragStart,startPos
topbar.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=inp.Position; startPos=win.Position
    end
end)
UIS.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
        local d=inp.Position-dragStart
        win.Position=UDim2.new(0,win.Position.X.Offset+d.X,0,win.Position.Y.Offset+d.Y)
        dragStart=inp.Position
    end
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

-- ══════════════════════════════════════
--  BODY
-- ══════════════════════════════════════
local body=Instance.new("Frame",win)
body.Size=UDim2.new(1,0,1,-49); body.Position=UDim2.new(0,0,0,49)
body.BackgroundTransparency=1; body.BorderSizePixel=0
body.ClipsDescendants=true

-- ══════════════════════════════════════
--  SIDEBAR
-- ══════════════════════════════════════
local sidebar=Instance.new("Frame",body)
sidebar.Size=UDim2.new(0,56,1,0); sidebar.BackgroundColor3=C.panel; sidebar.BorderSizePixel=0
local sdiv=Instance.new("Frame",body)
sdiv.Size=UDim2.new(0,1,1,0); sdiv.Position=UDim2.new(0,56,0,0)
sdiv.BackgroundColor3=C.border; sdiv.BorderSizePixel=0

local sideList=Instance.new("UIListLayout",sidebar)
sideList.SortOrder=Enum.SortOrder.LayoutOrder; sideList.Padding=UDim.new(0,2)
local sPad=Instance.new("UIPadding",sidebar)
sPad.PaddingTop=UDim.new(0,8); sPad.PaddingLeft=UDim.new(0,4); sPad.PaddingRight=UDim.new(0,4)

-- ══════════════════════════════════════
--  PAGES (dashboard + tabs)
-- ══════════════════════════════════════
local pageContainer=Instance.new("Frame",body)
pageContainer.Size=UDim2.new(1,-57,1,0); pageContainer.Position=UDim2.new(0,57,0,0)
pageContainer.BackgroundTransparency=1; pageContainer.BorderSizePixel=0
pageContainer.ClipsDescendants=true

local currentPage=nil

local function animatePage(frame,show)
    if show then
        frame.Visible=true
        frame.Position=UDim2.new(0.05,0,0,0)
        frame.BackgroundTransparency=1
        TweenService:Create(frame,TweenInfo.new(0.22,Enum.EasingStyle.Quint),{
            Position=UDim2.new(0,0,0,0),BackgroundTransparency=0
        }):Play()
    else
        TweenService:Create(frame,TweenInfo.new(0.18,Enum.EasingStyle.Quint),{
            Position=UDim2.new(-0.05,0,0,0),BackgroundTransparency=1
        }):Play()
        task.delay(0.2,function() frame.Visible=false; frame.Position=UDim2.new(0,0,0,0); frame.BackgroundTransparency=0 end)
    end
end

local function switchPage(frame)
    if currentPage and currentPage~=frame then animatePage(currentPage,false) end
    currentPage=frame
    animatePage(frame,true)
end

-- ══════════════════════════════════════
--  DASHBOARD PAGE
-- ══════════════════════════════════════
local dashPage=Instance.new("Frame",pageContainer)
dashPage.Size=UDim2.new(1,0,1,0); dashPage.BackgroundColor3=C.bg; dashPage.BorderSizePixel=0

local pad=Instance.new("UIPadding",dashPage)
pad.PaddingLeft=UDim.new(0,20); pad.PaddingRight=UDim.new(0,20); pad.PaddingTop=UDim.new(0,20)

-- Avatar card
local avatarCard=Instance.new("Frame",dashPage)
avatarCard.Size=UDim2.new(1,0,0,100)
avatarCard.BackgroundColor3=C.card; avatarCard.BorderSizePixel=0
Instance.new("UICorner",avatarCard).CornerRadius=UDim.new(0,10)
local avStroke=Instance.new("UIStroke",avatarCard); avStroke.Color=C.border; avStroke.Thickness=1

-- avatar image
local avatarImg=Instance.new("ImageLabel",avatarCard)
avatarImg.Size=UDim2.new(0,66,0,66); avatarImg.Position=UDim2.new(0,16,0.5,-33)
avatarImg.BackgroundColor3=C.border; avatarImg.BorderSizePixel=0
Instance.new("UICorner",avatarImg).CornerRadius=UDim.new(1,0)
avatarImg.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..lp.UserId.."&width=150&height=150&format=png"

local nameLbl2=Instance.new("TextLabel",avatarCard)
nameLbl2.Size=UDim2.new(0.6,0,0,28); nameLbl2.Position=UDim2.new(0,96,0,24)
nameLbl2.BackgroundTransparency=1; nameLbl2.Text=lp.DisplayName
nameLbl2.TextColor3=C.text; nameLbl2.TextSize=16
nameLbl2.Font=Enum.Font.GothamBold; nameLbl2.TextXAlignment=Enum.TextXAlignment.Left

local userLbl=Instance.new("TextLabel",avatarCard)
userLbl.Size=UDim2.new(0.6,0,0,20); userLbl.Position=UDim2.new(0,96,0,50)
userLbl.BackgroundTransparency=1; userLbl.Text="@"..lp.Name
userLbl.TextColor3=C.textDim; userLbl.TextSize=12
userLbl.Font=Enum.Font.Gotham; userLbl.TextXAlignment=Enum.TextXAlignment.Left

local tagLbl=Instance.new("TextLabel",avatarCard)
tagLbl.Size=UDim2.new(0,120,0,22); tagLbl.Position=UDim2.new(1,-136,0,16)
tagLbl.BackgroundColor3=C.accentDk; tagLbl.BorderSizePixel=0
tagLbl.Text="Real Executor"; tagLbl.TextColor3=C.accent
tagLbl.TextSize=11; tagLbl.Font=Enum.Font.GothamBold
tagLbl.TextXAlignment=Enum.TextXAlignment.Center
Instance.new("UICorner",tagLbl).CornerRadius=UDim.new(0,6)

local gameLbl=Instance.new("TextLabel",avatarCard)
gameLbl.Size=UDim2.new(0,180,0,20); gameLbl.Position=UDim2.new(1,-196,1,-30)
gameLbl.BackgroundTransparency=1
gameLbl.Text="Arise Crossover  ·  Arquiteto Update"
gameLbl.TextColor3=C.textDim; gameLbl.TextSize=10
gameLbl.Font=Enum.Font.Gotham; gameLbl.TextXAlignment=Enum.TextXAlignment.Right

-- stats rápidos
local function makeStatCard(parent,label,value,color,pos)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(0.47,0,0,64); f.Position=pos
    f.BackgroundColor3=C.card; f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
    Instance.new("UIStroke",f).Color=C.border
    local dot2=Instance.new("Frame",f)
    dot2.Size=UDim2.new(0,4,0.4,0); dot2.Position=UDim2.new(0,0,0.3,0)
    dot2.BackgroundColor3=color; dot2.BorderSizePixel=0
    Instance.new("UICorner",dot2).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",f)
    lbl.Size=UDim2.new(1,-16,0,20); lbl.Position=UDim2.new(0,12,0,8)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=C.textDim; lbl.TextSize=11; lbl.Font=Enum.Font.Gotham
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    local val=Instance.new("TextLabel",f)
    val.Size=UDim2.new(1,-16,0,26); val.Position=UDim2.new(0,12,0,28)
    val.BackgroundTransparency=1; val.Text=value
    val.TextColor3=color; val.TextSize=18; val.Font=Enum.Font.GothamBold
    val.TextXAlignment=Enum.TextXAlignment.Left
    return val
end

makeStatCard(dashPage,"Level",tostring(lp:GetAttribute("Level") or "—"),C.accent,UDim2.new(0,0,0,116))
makeStatCard(dashPage,"Rank",S.TargetRank,Color3.fromRGB(255,180,40),UDim2.new(0.53,0,0,116))

-- info hub card
local infoCard=Instance.new("Frame",dashPage)
infoCard.Size=UDim2.new(1,0,0,70); infoCard.Position=UDim2.new(0,0,0,196)
infoCard.BackgroundColor3=C.card; infoCard.BorderSizePixel=0
Instance.new("UICorner",infoCard).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",infoCard).Color=C.border

local infoTitle=Instance.new("TextLabel",infoCard)
infoTitle.Size=UDim2.new(1,0,0,24); infoTitle.Position=UDim2.new(0,16,0,10)
infoTitle.BackgroundTransparency=1; infoTitle.Text="Arise Hub  ·  Nov 2026"
infoTitle.TextColor3=C.text; infoTitle.TextSize=13; infoTitle.Font=Enum.Font.GothamBold
infoTitle.TextXAlignment=Enum.TextXAlignment.Left

local infoSub=Instance.new("TextLabel",infoCard)
infoSub.Size=UDim2.new(1,0,0,20); infoSub.Position=UDim2.new(0,16,0,34)
infoSub.BackgroundTransparency=1; infoSub.Text="Use RShift para abrir/fechar  ·  Clique em Macros para começar"
infoSub.TextColor3=C.textDim; infoSub.TextSize=11; infoSub.Font=Enum.Font.Gotham
infoSub.TextXAlignment=Enum.TextXAlignment.Left

-- ══════════════════════════════════════
--  MACROS PAGE
-- ══════════════════════════════════════
local macrosPage=Instance.new("Frame",pageContainer)
macrosPage.Size=UDim2.new(1,0,1,0); macrosPage.BackgroundColor3=C.bg
macrosPage.BorderSizePixel=0; macrosPage.Visible=false

-- sub-sidebar de tabs dentro dos macros
local tabSidebar=Instance.new("Frame",macrosPage)
tabSidebar.Size=UDim2.new(0,110,1,0); tabSidebar.BackgroundColor3=C.panel; tabSidebar.BorderSizePixel=0
local tabSideList=Instance.new("UIListLayout",tabSidebar)
tabSideList.SortOrder=Enum.SortOrder.LayoutOrder; tabSideList.Padding=UDim.new(0,2)
local tsPad=Instance.new("UIPadding",tabSidebar)
tsPad.PaddingTop=UDim.new(0,8); tsPad.PaddingLeft=UDim.new(0,4); tsPad.PaddingRight=UDim.new(0,4)

local tabDiv=Instance.new("Frame",macrosPage)
tabDiv.Size=UDim2.new(0,1,1,0); tabDiv.Position=UDim2.new(0,110,0,0)
tabDiv.BackgroundColor3=C.border; tabDiv.BorderSizePixel=0

local tabContent=Instance.new("Frame",macrosPage)
tabContent.Size=UDim2.new(1,-111,1,0); tabContent.Position=UDim2.new(0,111,0,0)
tabContent.BackgroundTransparency=1; tabContent.BorderSizePixel=0; tabContent.ClipsDescendants=true

-- ══════════════════════════════════════
--  HELPERS DE COMPONENTE
-- ══════════════════════════════════════
local tabs2={};local tabBtns2={};local currentTab=nil

local function makeScroll(parent)
    local s=Instance.new("ScrollingFrame",parent)
    s.Size=UDim2.new(1,0,1,0); s.BackgroundTransparency=1; s.BorderSizePixel=0
    s.ScrollBarThickness=3; s.ScrollBarImageColor3=C.borderLt
    s.CanvasSize=UDim2.new(0,0,0,0); s.AutomaticCanvasSize=Enum.AutomaticSize.Y; s.Visible=false
    local pad=Instance.new("UIPadding",s)
    pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,12)
    pad.PaddingTop=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,12)
    local layout=Instance.new("UIListLayout",s)
    layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,6)
    return s
end

local function secLabel(parent,text,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,28); f.BackgroundTransparency=1; f.LayoutOrder=order or 0
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
    l.Text=text:upper(); l.TextColor3=C.accent; l.TextSize=10
    l.Font=Enum.Font.GothamBold; l.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",f)
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=C.accentDk; line.BorderSizePixel=0
    return f
end

local function makeToggle(parent,label,key,order)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,0,0,38); row.BackgroundColor3=C.card; row.BorderSizePixel=0; row.LayoutOrder=order or 0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local stroke=Instance.new("UIStroke",row); stroke.Color=C.border; stroke.Thickness=1
    local bar=Instance.new("Frame",row)
    bar.Size=UDim2.new(0,3,0.5,0); bar.Position=UDim2.new(0,0,0.25,0)
    bar.BackgroundColor3=C.textDim; bar.BorderSizePixel=0
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-58,1,0); lbl.Position=UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C.text
    lbl.TextSize=13; lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local pill=Instance.new("Frame",row)
    pill.Size=UDim2.new(0,40,0,20); pill.Position=UDim2.new(1,-50,0.5,-10)
    pill.BackgroundColor3=Color3.fromRGB(24,24,34); pill.BorderSizePixel=0
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill)
    knob.Size=UDim2.new(0,14,0,14); knob.Position=UDim2.new(0,3,0.5,-7)
    knob.BackgroundColor3=Color3.fromRGB(100,100,120); knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local function refresh()
        local on=S[key]
        TweenService:Create(pill,TweenInfo.new(0.18),{BackgroundColor3=on and C.accentDk or Color3.fromRGB(24,24,34)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.18),{
            Position=on and UDim2.new(0,23,0.5,-7) or UDim2.new(0,3,0.5,-7),
            BackgroundColor3=on and C.accent or Color3.fromRGB(100,100,120)
        }):Play()
        TweenService:Create(bar,TweenInfo.new(0.18),{BackgroundColor3=on and C.accent or C.textDim}):Play()
        stroke.Color=on and C.accentDk or C.border
    end
    row.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then S[key]=not S[key]; refresh() end
    end)
    refresh(); return row
end

local function makeButton(parent,label,cb,order,txtCol)
    local btn=Instance.new("TextButton",parent)
    btn.Size=UDim2.new(1,0,0,38); btn.BackgroundColor3=C.card
    btn.Text=label; btn.TextColor3=txtCol or C.text; btn.TextSize=13
    btn.Font=Enum.Font.Gotham; btn.BorderSizePixel=0; btn.AutoButtonColor=false; btn.LayoutOrder=order or 0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    local stroke=Instance.new("UIStroke",btn); stroke.Color=C.border; stroke.Thickness=1
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.cardHov}):Play(); stroke.Color=C.borderLt end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play(); stroke.Color=C.border end)
    btn.MouseButton1Down:Connect(function() TweenService:Create(btn,TweenInfo.new(0.06),{BackgroundColor3=C.accentDk}):Play() end)
    btn.MouseButton1Up:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.cardHov}):Play(); pcall(cb) end)
    return btn
end

local function makeSlider(parent,label,minV,maxV,key,order)
    local wrap=Instance.new("Frame",parent)
    wrap.Size=UDim2.new(1,0,0,54); wrap.BackgroundColor3=C.card; wrap.BorderSizePixel=0; wrap.LayoutOrder=order or 0
    Instance.new("UICorner",wrap).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",wrap).Color=C.border
    local lbl=Instance.new("TextLabel",wrap)
    lbl.Size=UDim2.new(0.6,0,0,24); lbl.Position=UDim2.new(0,14,0,6)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C.text; lbl.TextSize=13
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left
    local valLbl=Instance.new("TextLabel",wrap)
    valLbl.Size=UDim2.new(0.35,-14,0,24); valLbl.Position=UDim2.new(0.63,0,0,6)
    valLbl.BackgroundTransparency=1; valLbl.Text=tostring(S[key]); valLbl.TextColor3=C.accent
    valLbl.TextSize=13; valLbl.Font=Enum.Font.GothamBold; valLbl.TextXAlignment=Enum.TextXAlignment.Right
    local track=Instance.new("Frame",wrap)
    track.Size=UDim2.new(1,-28,0,6); track.Position=UDim2.new(0,14,0,38)
    track.BackgroundColor3=Color3.fromRGB(18,18,28); track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local pct=(S[key]-minV)/(maxV-minV)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=C.accent; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local thumb=Instance.new("Frame",track)
    thumb.Size=UDim2.new(0,14,0,14); thumb.Position=UDim2.new(pct,-7,0.5,-7)
    thumb.BackgroundColor3=C.white; thumb.BorderSizePixel=0; thumb.ZIndex=3
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local ds=false
    local function update(x)
        local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local val=math.floor(minV+rel*(maxV-minV))
        S[key]=val; valLbl.Text=tostring(val)
        fill.Size=UDim2.new(rel,0,1,0); thumb.Position=UDim2.new(rel,-7,0.5,-7)
    end
    track.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then ds=true; update(inp.Position.X) end end)
    UIS.InputChanged:Connect(function(inp) if ds and inp.UserInputType==Enum.UserInputType.MouseMovement then update(inp.Position.X) end end)
    UIS.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then ds=false end end)
    return wrap
end

local function switchTab(name)
    for n,s in pairs(tabs2) do
        if n==name then
            if currentTab~=name then
                s.Visible=true
                s.Position=UDim2.new(0.04,0,0,0)
                TweenService:Create(s,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{Position=UDim2.new(0,0,0,0)}):Play()
            end
        else
            if s.Visible then
                TweenService:Create(s,TweenInfo.new(0.15,Enum.EasingStyle.Quint),{Position=UDim2.new(-0.04,0,0,0)}):Play()
                task.delay(0.16,function() s.Visible=false; s.Position=UDim2.new(0,0,0,0) end)
            end
        end
    end
    for n,t in pairs(tabBtns2) do
        local on=(n==name)
        TweenService:Create(t.btn,TweenInfo.new(0.15),{BackgroundColor3=on and C.tabHL or C.panel}):Play()
        t.lbl.TextColor3=on and C.text or C.textDim
        t.bar.Visible=on
    end
    currentTab=name
end

local function addTab(name,icon,order)
    local scroll=makeScroll(tabContent)
    tabs2[name]=scroll

    local btn=Instance.new("TextButton",tabSidebar)
    btn.Size=UDim2.new(1,0,0,52); btn.BackgroundColor3=C.panel; btn.BorderSizePixel=0
    btn.AutoButtonColor=false; btn.LayoutOrder=order or 0; btn.Text=""
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)

    local icoLbl=Instance.new("TextLabel",btn)
    icoLbl.Size=UDim2.new(1,0,0,26); icoLbl.Position=UDim2.new(0,0,0,6)
    icoLbl.BackgroundTransparency=1; icoLbl.Text=icon; icoLbl.TextSize=18
    icoLbl.Font=Enum.Font.GothamBold; icoLbl.TextColor3=C.textDim; icoLbl.TextXAlignment=Enum.TextXAlignment.Center

    local nLbl=Instance.new("TextLabel",btn)
    nLbl.Size=UDim2.new(1,0,0,14); nLbl.Position=UDim2.new(0,0,0,32)
    nLbl.BackgroundTransparency=1; nLbl.Text=name; nLbl.TextSize=9
    nLbl.Font=Enum.Font.GothamBold; nLbl.TextColor3=C.textDim; nLbl.TextXAlignment=Enum.TextXAlignment.Center

    local bar=Instance.new("Frame",btn)
    bar.Size=UDim2.new(0,3,0.5,0); bar.Position=UDim2.new(0,0,0.25,0)
    bar.BackgroundColor3=C.accent; bar.BorderSizePixel=0; bar.Visible=false
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)

    tabBtns2[name]={btn=btn,lbl=nLbl,bar=bar}
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    return scroll
end

-- ══════════════════════════════════════
--  POPULAR MACROS TABS
-- ══════════════════════════════════════
local farm=addTab("Farm","⚔",1)
secLabel(farm,"Combate",1)
makeToggle(farm,"Auto Farm","AutoFarm",2)
makeToggle(farm,"Auto Arise","AutoArise",3)
makeToggle(farm,"Auto Sell","AutoSell",4)
secLabel(farm,"Automação",5)
makeToggle(farm,"Auto Enchant","AutoEnchant",6)
makeToggle(farm,"Auto Infuse","AutoInfuse",7)
makeToggle(farm,"Coletar AFK","AutoCollectAFK",8)
makeToggle(farm,"Anti-AFK","AntiAFK",9)

local dung=addTab("Dungeon","🏰",2)
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
    local p=findPromptByKW({"dungeon","entrar","enter"}); if p then
        local pp=p.Parent; local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos); task.wait(0.3) end; firePrompt(p) end
end,10)
makeButton(dung,"→  Infernal Castle",function()
    local p=findPromptByKW({"infernal","castle"}); if p then
        local pp=p.Parent; local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos); task.wait(0.3) end; firePrompt(p) end
end,11)
makeButton(dung,"→  Bloodmoon Manor",function()
    local p=findPromptByKW({"bloodmoon","manor","blood"}); if p then
        local pp=p.Parent; local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos); task.wait(0.3) end; firePrompt(p) end
end,12)
makeButton(dung,"→  Eclipse Court",function()
    local p=findPromptByKW({"eclipse","court"}); if p then
        local pp=p.Parent; local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos); task.wait(0.3) end; firePrompt(p) end
end,13)
makeButton(dung,"→  Heavenly Castle",function()
    local p=findPromptByKW({"heavenly","arquiteto"}); if p then
        local pp=p.Parent; local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos); task.wait(0.3) end; firePrompt(p) end
end,14)
secLabel(dung,"Rank Alvo",15)
local selRankLbl=Instance.new("TextLabel",dung)
selRankLbl.Size=UDim2.new(1,0,0,22); selRankLbl.BackgroundTransparency=1
selRankLbl.Text="Selecionado:  "..S.TargetRank; selRankLbl.TextColor3=C.accent
selRankLbl.TextSize=12; selRankLbl.Font=Enum.Font.GothamBold
selRankLbl.TextXAlignment=Enum.TextXAlignment.Left; selRankLbl.LayoutOrder=16
local rankWrap=Instance.new("Frame",dung)
rankWrap.Size=UDim2.new(1,0,0,170); rankWrap.BackgroundColor3=C.card; rankWrap.BorderSizePixel=0; rankWrap.LayoutOrder=17
Instance.new("UICorner",rankWrap).CornerRadius=UDim.new(0,8); Instance.new("UIStroke",rankWrap).Color=C.border
local rankSF=Instance.new("ScrollingFrame",rankWrap)
rankSF.Size=UDim2.new(1,-8,1,-8); rankSF.Position=UDim2.new(0,4,0,4)
rankSF.BackgroundTransparency=1; rankSF.BorderSizePixel=0; rankSF.ScrollBarThickness=3
rankSF.ScrollBarImageColor3=C.borderLt; rankSF.CanvasSize=UDim2.new(0,0,0,0); rankSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
local rankGrid=Instance.new("UIGridLayout",rankSF)
rankGrid.CellSize=UDim2.new(0.25,-4,0,32); rankGrid.CellPadding=UDim2.new(0,4,0,4); rankGrid.SortOrder=Enum.SortOrder.LayoutOrder
local rPad=Instance.new("UIPadding",rankSF); rPad.PaddingLeft=UDim.new(0,4); rPad.PaddingTop=UDim.new(0,4)
local rankCells={}
for i,rank in ipairs(RANKS) do
    local cell=Instance.new("TextButton",rankSF)
    cell.BackgroundColor3=Color3.fromRGB(13,13,20); cell.BorderSizePixel=0
    cell.Text=rank; cell.TextColor3=RANK_COLORS[rank] or C.text
    cell.TextSize=11; cell.Font=Enum.Font.GothamBold; cell.LayoutOrder=i; cell.AutoButtonColor=false
    Instance.new("UICorner",cell).CornerRadius=UDim.new(0,6)
    local cs=Instance.new("UIStroke",cell); cs.Color=C.border; cs.Thickness=1
    rankCells[rank]={cell=cell,stroke=cs}
    cell.MouseButton1Click:Connect(function()
        S.TargetRank=rank; selRankLbl.Text="Selecionado:  "..rank
        for _,rc in pairs(rankCells) do rc.cell.BackgroundColor3=Color3.fromRGB(13,13,20); rc.stroke.Color=C.border end
        cell.BackgroundColor3=C.accentDk; cs.Color=C.accent
    end)
end

local raid=addTab("Raid","☠",3)
secLabel(raid,"Raids",1)
makeToggle(raid,"Auto Raid","AutoRaid",2)
secLabel(raid,"Eventos",3)
makeButton(raid,"→  Nightmare Kamish",function()
    local p=findPromptByKW({"kamish","nightmare","worldboss"}); if p then
        local pp=p.Parent; local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos); task.wait(0.2) end; firePrompt(p) end
end,4)
makeButton(raid,"→  Pumpkin King",function()
    local p=findPromptByKW({"pumpkin","king"}); if p then
        local pp=p.Parent; local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos); task.wait(0.2) end; firePrompt(p) end
end,5)
makeButton(raid,"→  Trick or Treat",function()
    local p=findPromptByKW({"trick","treat","halloween"}); if p then
        local pp=p.Parent; local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position))
        if pos then safeTP(pos); task.wait(0.2) end; firePrompt(p) end
end,6)

local tp=addTab("Teleport","📍",4)
secLabel(tp,"Rápido",1)
makeButton(tp,"→  Mob mais próximo",function()
    local mob=getNearestMob(); if mob then local mhrp=mob:FindFirstChild("HumanoidRootPart"); if mhrp then safeTP(mhrp.Position) end end
end,2)
makeButton(tp,"→  Rank Up NPC",function()
    local p=findPromptByKW({"rank","rankup","upgrade rank"}); if p then
        local pp=p.Parent; local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position)); if pos then safeTP(pos) end end
end,3)
makeButton(tp,"→  Shadow Upgrader",function()
    local p=findPromptByKW({"shadow","upgrade shadow"}); if p then
        local pp=p.Parent; local pos=pp and (pp:IsA("BasePart") and pp.Position or (pp.PrimaryPart and pp.PrimaryPart.Position)); if pos then safeTP(pos) end end
end,4)
makeButton(tp,"→  Arquiteto Boss",function()
    local part=findByName({"arquiteto","architect"}); if part then
        local pos=part:IsA("BasePart") and part.Position or part:GetPivot().Position; safeTP(pos) end
end,5)
secLabel(tp,"Ilhas",6)
local islands={
    {"Solo City",{"solocity","solo"}},{"Leveling City",{"levelingcity","leveling"}},
    {"Grass Village",{"grassvillage","grass"}},{"Brum Island",{"brum"}},
    {"Mori Town",{"mori"}},{"Ghoul Island",{"ghoul"}},{"XZ City",{"xzcity","xz"}},
    {"Ilha 30",{"island30","ilha30"}},{"Blood Moonwoods",{"moonwoods","bloodmoonwoods"}},
    {"Eclipse Paradise",{"paradise"}},{"Abismo de Detritos",{"detritos","debris","abismo"}},
}
for i,isl in ipairs(islands) do
    makeButton(tp,"→  "..isl[1],function()
        local part=findByName(isl[2]); if part then
            local pos=part:IsA("BasePart") and part.Position or part:GetPivot().Position; safeTP(pos) end
    end,6+i)
end

local misc=addTab("Misc","🛠",5)
secLabel(misc,"Movimento",1)
makeToggle(misc,"Noclip","Noclip",2); makeToggle(misc,"Speed Hack","SpeedHack",3)
makeSlider(misc,"Velocidade",16,300,"SpeedValue",4)
secLabel(misc,"Utilitários",5)
makeButton(misc,"Rejoin Server",function() TS:Teleport(game.PlaceId,lp) end,6)
makeButton(misc,"Print Remotes",function()
    for _,v in ipairs(RS:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then print("[Remote]",v:GetFullName()) end
    end
end,7)
makeButton(misc,"Print Prompts",function()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then print("[Prompt]",v.Parent.Name,"|",v.ActionText,"|",v:GetFullName()) end
    end
end,8)

local cfg=addTab("Config","⚙",6)
secLabel(cfg,"Keybind",1)
local keyBtn=makeButton(cfg,"Tecla: RightShift",function() end,2)
local listening=false
keyBtn.MouseButton1Up:Connect(function()
    listening=true; keyBtn.Text="Pressione uma tecla..."; keyBtn.TextColor3=C.accent
end)
secLabel(cfg,"Auto Execute",3)
local aeStatus=Instance.new("TextLabel",cfg)
aeStatus.Size=UDim2.new(1,0,0,24); aeStatus.BackgroundTransparency=1
aeStatus.TextSize=12; aeStatus.Font=Enum.Font.Gotham
aeStatus.TextXAlignment=Enum.TextXAlignment.Left; aeStatus.LayoutOrder=4
local AE_PATH="autoexec/AriseCrossover.lua"
local SCRIPT_URL="https://raw.githubusercontent.com/Mopera-tech/AriseCrossover.lua/refs/heads/main/AriseCrossover.lua"
local function checkAE()
    local ok,res=pcall(function() return isfile(AE_PATH) end)
    if ok and res then aeStatus.Text="  ● Status: ATIVO"; aeStatus.TextColor3=C.accent
    else aeStatus.Text="  ● Status: INATIVO"; aeStatus.TextColor3=C.red end
end
checkAE()
makeButton(cfg,"Ativar Auto Execute",function()
    pcall(function()
        if not isfolder("autoexec") then makefolder("autoexec") end
        writefile(AE_PATH,'loadstring(game:HttpGet("'..SCRIPT_URL..'"))()')
    end); checkAE()
end,5,C.accent)
makeButton(cfg,"Desativar Auto Execute",function()
    pcall(function() if isfile(AE_PATH) then delfile(AE_PATH) end end); checkAE()
end,6,C.red)

-- ══════════════════════════════════════
--  SIDEBAR NAV BUTTONS
-- ══════════════════════════════════════
local navBtns={}
local function navBtn(icon,label,order,cb)
    local btn=Instance.new("TextButton",sidebar)
    btn.Size=UDim2.new(1,0,0,52); btn.BackgroundColor3=C.panel; btn.BorderSizePixel=0
    btn.AutoButtonColor=false; btn.LayoutOrder=order; btn.Text=""
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    local icoL=Instance.new("TextLabel",btn)
    icoL.Size=UDim2.new(1,0,0,26); icoL.Position=UDim2.new(0,0,0,6)
    icoL.BackgroundTransparency=1; icoL.Text=icon; icoL.TextSize=20
    icoL.Font=Enum.Font.GothamBold; icoL.TextColor3=C.textDim; icoL.TextXAlignment=Enum.TextXAlignment.Center
    local nL=Instance.new("TextLabel",btn)
    nL.Size=UDim2.new(1,0,0,14); nL.Position=UDim2.new(0,0,0,32)
    nL.BackgroundTransparency=1; nL.Text=label; nL.TextSize=9
    nL.Font=Enum.Font.GothamBold; nL.TextColor3=C.textDim; nL.TextXAlignment=Enum.TextXAlignment.Center
    local selBar=Instance.new("Frame",btn)
    selBar.Size=UDim2.new(0,3,0.5,0); selBar.Position=UDim2.new(0,0,0.25,0)
    selBar.BackgroundColor3=C.accent; selBar.BorderSizePixel=0; selBar.Visible=false
    Instance.new("UICorner",selBar).CornerRadius=UDim.new(1,0)
    table.insert(navBtns,{btn=btn,ico=icoL,lbl=nL,bar=selBar})
    btn.MouseButton1Click:Connect(function()
        for _,nb in ipairs(navBtns) do
            local on=(nb.btn==btn)
            TweenService:Create(nb.btn,TweenInfo.new(0.15),{BackgroundColor3=on and C.tabHL or C.panel}):Play()
            nb.ico.TextColor3=on and C.accent or C.textDim
            nb.lbl.TextColor3=on and C.text or C.textDim
            nb.bar.Visible=on
        end
        cb()
    end)
    return btn
end

local dashBtn=navBtn("🏠","Home",1,function() switchPage(dashPage) end)
local macrosBtn=navBtn("⚡","Macros",2,function()
    switchPage(macrosPage)
    if not currentTab then switchTab("Farm") end
end)

-- activa home por default
do
    local nb=navBtns[1]
    nb.btn.BackgroundColor3=C.tabHL; nb.ico.TextColor3=C.accent; nb.lbl.TextColor3=C.text; nb.bar.Visible=true
end
currentPage=dashPage; dashPage.Visible=true

-- ══════════════════════════════════════
--  KEYBIND + OPEN/CLOSE ANIMADO
-- ══════════════════════════════════════
UIS.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if listening and inp.UserInputType==Enum.UserInputType.Keyboard then
        S.OpenKey=inp.KeyCode; keyBtn.Text="Tecla: "..inp.KeyCode.Name
        keyBtn.TextColor3=C.text; listening=false; return
    end
    if inp.KeyCode==S.OpenKey then
        if win.Visible then
            TweenService:Create(win,TweenInfo.new(0.2,Enum.EasingStyle.Quint),{
                Size=UDim2.new(0,780,0,0)
            }):Play()
            task.delay(0.22,function() win.Visible=false; win.Size=UDim2.new(0,780,0,520) end)
        else
            win.Visible=true
            win.Size=UDim2.new(0,780,0,0)
            TweenService:Create(win,TweenInfo.new(0.25,Enum.EasingStyle.Quint),{
                Size=UDim2.new(0,780,0,520)
            }):Play()
        end
    end
end)

print("[Arise Hub] Carregado | "..S.OpenKey.Name.." para abrir/fechar")
