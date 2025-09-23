-- // =================== LOADING CUSTOM ===================
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "XIAAANHUB_Loading"
LoadingGui.ResetOnSpawn = false
LoadingGui.IgnoreGuiInset = true
LoadingGui.Parent = CoreGui

local Frame = Instance.new("Frame", LoadingGui)
Frame.Size = UDim2.new(0, 360, 0, 190)
Frame.Position = UDim2.new(0.5, -180, 0.5, -95)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
local UIC = Instance.new("UICorner", Frame)
UIC.CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", Frame)
stroke.Thickness, stroke.Color = 2, Color3.fromRGB(255, 215, 0)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Position = UDim2.new(0,0,0,8)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 30
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Text = "⚡ XIAAANHUB ⚡"

local Sub = Instance.new("TextLabel", Frame)
Sub.Size = UDim2.new(1,0,0,38)
Sub.Position = UDim2.new(0,0,0,64)
Sub.BackgroundTransparency = 1
Sub.Font = Enum.Font.SourceSans
Sub.TextSize = 20
Sub.TextColor3 = Color3.fromRGB(200, 200, 200)
Sub.Text = "Loading... Please wait"

local BarBg = Instance.new("Frame", Frame)
BarBg.Size = UDim2.new(0.85, 0, 0, 15)
BarBg.Position = UDim2.new(0.075,0,0.75,0)
BarBg.BackgroundColor3 = Color3.fromRGB(40,40,40)
BarBg.BorderSizePixel = 0
local UIC2 = Instance.new("UICorner", BarBg)
UIC2.CornerRadius = UDim.new(0,8)

local Bar = Instance.new("Frame", BarBg)
Bar.Size = UDim2.new(0,0,1,0)
Bar.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
local UIC3 = Instance.new("UICorner", Bar)
UIC3.CornerRadius = UDim.new(0,8)

task.spawn(function()
    for i=1,100 do
        Bar.Size = UDim2.new(i/100,0,1,0)
        Sub.Text = "Loading... "..i.."%"
        task.wait(0.02)
    end
    LoadingGui:Destroy()
end)

-- // =================== MAIN UI ===================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "XIAAANHUB || By !TXT",
    LoadingTitle = "XIAAANHUB",
    LoadingSubtitle = "By !TXT",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "XIAAANHUB",
       FileName = "XiaanHubConfig"
    },
    KeySystem = false
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

------------------------------------------------------------
-- ===================== TAB 1 : SCRIPT =====================
------------------------------------------------------------
local ScriptTab = Window:CreateTab("SCRIPT", 4483362458)

-- ========== ✈️ Fly (speed 1–1000, draggable mini GUI, body stiff) ==========
local flying, flySpeed, flyUp, flyDown = false, 60, false, false
local FlyGui, BodyVel, BodyGyro, flyConn

local function stopFly()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn=nil end
    if BodyVel then BodyVel:Destroy() BodyVel=nil end
    if BodyGyro then BodyGyro:Destroy() BodyGyro=nil end
    if FlyGui then FlyGui:Destroy() FlyGui=nil end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

local function startFly()
    if flying then return end
    flying = true
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    BodyVel = Instance.new("BodyVelocity", hrp)
    BodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
    BodyVel.Velocity = Vector3.zero

    BodyGyro = Instance.new("BodyGyro", hrp)
    BodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    BodyGyro.P = 1e5
    BodyGyro.CFrame = hrp.CFrame

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end

    -- Mini Fly Controller
    FlyGui = Instance.new("ScreenGui")
    FlyGui.Name = "FlyController"
    FlyGui.ResetOnSpawn = false
    FlyGui.Parent = CoreGui

    local Frame = Instance.new("Frame", FlyGui)
    Frame.Size = UDim2.new(0, 180, 0, 160)
    Frame.Position = UDim2.new(0.82,-90,0.6,-80)
    Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Frame.Active = true
    Frame.Draggable = true
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", Frame)
    stroke.Thickness, stroke.Color = 2, Color3.fromRGB(255,215,0)

    local Grid = Instance.new("UIGridLayout", Frame)
    Grid.CellSize = UDim2.new(0,55,0,50)
    Grid.CellPadding = UDim2.new(0,3,0,3)
    Grid.FillDirectionMaxCells = 3
    Grid.HorizontalAlignment, Grid.VerticalAlignment = Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center

    local speedLabel
    local function makeBtn(txt,color,cb)
        local b = Instance.new("TextButton", Frame)
        b.Text, b.Font, b.TextSize, b.TextColor3, b.BackgroundColor3 = txt, Enum.Font.SourceSansBold, 16, Color3.new(1,1,1), color
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        if cb then b.MouseButton1Click:Connect(cb) end
        return b
    end
    local function makeHoldBtn(txt,color,onDown,onUp)
        local b = makeBtn(txt,color)
        b.MouseButton1Down:Connect(function() if onDown then onDown() end end)
        b.MouseButton1Up:Connect(function() if onUp then onUp() end end)
        b.MouseLeave:Connect(function() if onUp then onUp() end end)
        return b
    end

    makeBtn("X", Color3.fromRGB(200,50,50), function() stopFly() end)
    makeBtn("FLY", Color3.fromRGB(230,200,50), function() if flying then stopFly() else startFly() end end)
    makeBtn("⏹", Color3.fromRGB(150,150,150), function() flyUp, flyDown = false,false end)

    makeHoldBtn("⬆", Color3.fromRGB(100,200,100), function() flyUp=true flyDown=false end, function() flyUp=false end)
    speedLabel = makeBtn(tostring(flySpeed), Color3.fromRGB(200,100,50))
    makeHoldBtn("⬇", Color3.fromRGB(200,200,100), function() flyDown=true flyUp=false end, function() flyDown=false end)

    makeBtn("-", Color3.fromRGB(80,80,200), function() flySpeed = math.clamp(flySpeed-10,1,1000) speedLabel.Text=tostring(flySpeed) end)
    makeBtn("+", Color3.fromRGB(80,80,200), function() flySpeed = math.clamp(flySpeed+10,1,1000) speedLabel.Text=tostring(flySpeed) end)

    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not hrp then return end
        local hum2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local moveDir = hum2 and hum2.MoveDirection or Vector3.zero
        if flyUp then moveDir = moveDir + Vector3.new(0,1,0) end
        if flyDown then moveDir = moveDir - Vector3.new(0,1,0) end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        BodyVel.Velocity = moveDir * flySpeed
        BodyGyro.CFrame = Workspace.CurrentCamera.CFrame
    end)
end

ScriptTab:CreateToggle({
    Name="✈️ Fly",
    CurrentValue=false,
    Callback=function(s) if s then startFly() else stopFly() end end
})

-- ========== 👀 ESP Player ==========
local ESPs, ESPEnabled = {}, false
local function createESP(plr)
    if not plr.Character or ESPs[plr] then return end
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local billboard = Instance.new("BillboardGui", CoreGui)
    billboard.Size, billboard.Adornee, billboard.AlwaysOnTop, billboard.StudsOffset = UDim2.new(0,150,0,50), hrp, true, Vector3.new(0,2,0)
    local label = Instance.new("TextLabel", billboard)
    label.Size, label.BackgroundTransparency, label.TextColor3, label.TextStrokeTransparency, label.TextScaled, label.Font, label.Text =
        UDim2.new(1,0,1,0), 1, Color3.new(1,1,1), 0, true, Enum.Font.SourceSansBold, plr.Name
    local hl = Instance.new("Highlight", plr.Character)
    hl.FillColor, hl.OutlineColor, hl.FillTransparency, hl.OutlineTransparency = Color3.fromRGB(0,170,255), Color3.fromRGB(0,170,255), 0.5, 0.5
    ESPs[plr] = {billboard=billboard, highlight=hl}
end
local function removeESP(plr)
    if ESPs[plr] then
        if ESPs[plr].billboard then ESPs[plr].billboard:Destroy() end
        if ESPs[plr].highlight then ESPs[plr].highlight:Destroy() end
        ESPs[plr] = nil
    end
end
ScriptTab:CreateToggle({
    Name="👀 ESP Player",
    CurrentValue=false,
    Callback=function(s) ESPEnabled=s if not s then for p,_ in pairs(ESPs) do removeESP(p) end end end
})
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then createESP(p) end end
    end
end)
Players.PlayerRemoving:Connect(removeESP)

-- ========== 💀 God Mode ==========
ScriptTab:CreateToggle({
    Name="💀 God Mode",
    CurrentValue=false,
    Callback=function(s)
        local c=LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then
            local h=c:FindFirstChildOfClass("Humanoid")
            if s then
                h.MaxHealth=math.huge
                h.Health=h.MaxHealth
                h:GetPropertyChangedSignal("Health"):Connect(function()
                    if h.Health < h.MaxHealth then h.Health = h.MaxHealth end
                end)
            else
                h.MaxHealth=100
                if h.Health>100 then h.Health=100 end
            end
        end
    end
})

-- ========== 🏃 Walk Speed & 🦘 Jump Power ==========
ScriptTab:CreateSlider({
    Name="🏃 Walk Speed",
    Range={16,300}, Increment=1, CurrentValue=16,
    Callback=function(v) local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=v end end
})
ScriptTab:CreateSlider({
    Name="🦘 Jump Power",
    Range={50,500}, Increment=5, CurrentValue=50,
    Callback=function(v) local h=LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h.JumpPower=v end end
})

-- ========== 👑 Admin Title ==========
ScriptTab:CreateToggle({
    Name="👑 ADMIN 👑",
    CurrentValue=false,
    Callback=function(s)
        local c=LocalPlayer.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            local ex=CoreGui:FindFirstChild("AdminBillboard")
            if s and not ex then
                local b=Instance.new("BillboardGui",CoreGui)
                b.Name="AdminBillboard"
                b.Size=UDim2.new(0,120,0,25)
                b.Adornee=c.HumanoidRootPart
                b.AlwaysOnTop=true
                b.StudsOffset=Vector3.new(0,4.5,0)
                local l=Instance.new("TextLabel",b)
                l.Size=UDim2.new(1,0,1,0)
                l.BackgroundTransparency=1
                l.TextColor3=Color3.fromRGB(255,215,0)
                l.TextStrokeTransparency=0
                l.TextScaled=true
                l.Font=Enum.Font.SourceSansBold
                l.Text="👑ADMIN👑"
            else
                if ex then ex:Destroy() end
            end
        end
    end
})

------------------------------------------------------------
-- ===================== TAB 2 : TXT =====================
------------------------------------------------------------
local TxtTab = Window:CreateTab("TXT", 4483362458)

-- ⚡ Teleport ke Player
local plist, selected = {}, nil
for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(plist,p.Name) end end
local drop = TxtTab:CreateDropdown({
    Name="Pilih Player untuk TP",
    Options=plist, CurrentOption={}, MultipleOptions=false,
    Flag="TPPlayerList",
    Callback=function(o) selected=o[1] end
})
TxtTab:CreateButton({
    Name="⚡ Teleport ke Player",
    Callback=function()
        if selected then
            local t=Players:FindFirstChild(selected)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame=t.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3) end
            end
        end
    end
})
Players.PlayerAdded:Connect(function(p) if p~=LocalPlayer then table.insert(plist,p.Name) drop:SetOptions(plist) end end)
Players.PlayerRemoving:Connect(function(p) for i,n in ipairs(plist) do if n==p.Name then table.remove(plist,i) break end end drop:SetOptions(plist) end)

-- 🚪 Noclip
local noclipConn
TxtTab:CreateToggle({
    Name="🚪 Noclip",
    CurrentValue=false,
    Callback=function(s)
        local c=LocalPlayer.Character
        if s then
            noclipConn=RunService.Stepped:Connect(function()
                c=LocalPlayer.Character
                if c then for _,pr in ipairs(c:GetDescendants()) do if pr:IsA("BasePart") then pr.CanCollide=false end end end
            end)
        else
            if noclipConn then noclipConn:Disconnect() noclipConn=nil end
            if c then for _,pr in ipairs(c:GetDescendants()) do if pr:IsA("BasePart") then pr.CanCollide=true end end end
        end
    end
})

-- 🙈 Hide Name
TxtTab:CreateToggle({
    Name="🙈 Hide Name",
    CurrentValue=false,
    Callback=function(s)
        local c=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local h=c:FindFirstChildOfClass("Humanoid")
        local head=c:FindFirstChild("Head")
        if s then
            if h then h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
            if head then for _,g in ipairs(head:GetChildren()) do if g:IsA("BillboardGui") then g.Enabled=false end end end
        else
            if h then h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.Viewer end
            if head then for _,g in ipairs(head:GetChildren()) do if g:IsA("BillboardGui") then g.Enabled=true end end end
        end
    end
})

-- 🦖 Avatar Size (toggle + slider 1–50)
local avatarConn, sizeVal= nil,1
local function applyScale(char,val)
    local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end
    for _,prop in ipairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale","HeadScale"}) do
        local sc=hum:FindFirstChild(prop) if sc and sc:IsA("NumberValue") then sc.Value=val end
    end
end
local scaleEnabled=false
TxtTab:CreateToggle({
    Name="🦖 Avatar Scale ON/OFF",
    CurrentValue=false,
    Callback=function(state)
        scaleEnabled=state
        if not state then
            local c=LocalPlayer.Character if c then applyScale(c,1) end
            if avatarConn then avatarConn:Disconnect() avatarConn=nil end
        else
            if avatarConn then avatarConn:Disconnect() end
            avatarConn=RunService.Stepped:Connect(function()
                local c=LocalPlayer.Character
                if c then applyScale(c,sizeVal) end
            end)
        end
    end
})
TxtTab:CreateSlider({
    Name="Size (1–50)",
    Range={1,50}, Increment=1, CurrentValue=1,
    Callback=function(v)
        sizeVal=v
        if scaleEnabled then
            local c=LocalPlayer.Character
            if c then applyScale(c,sizeVal) end
        end
    end
})
LocalPlayer.CharacterAdded:Connect(function(c) task.wait(1) if scaleEnabled then applyScale(c,sizeVal) else applyScale(c,1) end end)

-- 🦘 Infinite Jump
local infJumpEnabled=false
TxtTab:CreateToggle({
    Name="🦘 Infinite Jump",
    CurrentValue=false,
    Callback=function(state) infJumpEnabled=state end
})
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char=LocalPlayer.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

------------------------------------------------------------
-- ===================== TAB 3 : AUTO SUMMIT =====================
------------------------------------------------------------
local AutoTab = Window:CreateTab("AUTO SUMMIT", 4483362458)

local function tpTo(pos)
    local c=LocalPlayer.Character
    local hrp=c and c:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame=CFrame.new(pos) end
end
local function respawnPlayer() LocalPlayer.Character:BreakJoints() end

-- 🔹 MOUNT BAYI
local bayiSpots={
    Vector3.new(-366,63,48),
    Vector3.new(-728,114,94),
    Vector3.new(-852,108,-35),
    Vector3.new(-1407,250,1502),
    Vector3.new(-1408,400,1617)
}
local autoBayi=false
AutoTab:CreateToggle({
    Name="🚀 Auto Route MOUNT BAYI (Loop)",
    CurrentValue=false,
    Callback=function(state)
        autoBayi=state
        if state then
            task.spawn(function()
                while autoBayi do
                    for i,spot in ipairs(bayiSpots) do
                        if not autoBayi then break end
                        tpTo(spot)
                        pcall(function()
                            StarterGui:SetCore("SendNotification",{Title="MOUNT BAYI",Text="📍 Spot "..i.." Selesai",Duration=2})
                        end)
                        task.wait(3)
                    end
                    if autoBayi then
                        pcall(function()
                            StarterGui:SetCore("SendNotification",{Title="MOUNT BAYI",Text="🔄 Respawn & Ulangi lagi",Duration=4})
                        end)
                        respawnPlayer()
                        LocalPlayer.CharacterAdded:Wait()
                        task.wait(2)
                    end
                end
            end)
        end
    end
})

-- 🔹 PASRAH
local pasrahSpots={
    Vector3.new(-472,121,-363),
    Vector3.new(-16,115,-350),
    Vector3.new(42,133,-594),
    Vector3.new(-73,421,-939),
    Vector3.new(-168,478,-566),
    Vector3.new(-548,613,-13),
    Vector3.new(-1111,750,29),
    Vector3.new(-1069,854,-670),
    Vector3.new(-1010,910,-1113),
    Vector3.new(-739,986,-1638),
    Vector3.new(-187,1481,-2108),
    Vector3.new(65,1700,-1724)
}
local autoPasrah=false
AutoTab:CreateToggle({
    Name="🚀 Auto Route PASRAH (Loop)",
    CurrentValue=false,
    Callback=function(state)
        autoPasrah=state
        if state then
            task.spawn(function()
                while autoPasrah do
                    for i,spot in ipairs(pasrahSpots) do
                        if not autoPasrah then break end
                        tpTo(spot)
                        pcall(function()
                            StarterGui:SetCore("SendNotification",{Title="PASRAH",Text="📍 Spot "..i.." Selesai",Duration=2})
                        end)
                        task.wait(3)
                    end
                    if autoPasrah then
                        pcall(function()
                            StarterGui:SetCore("SendNotification",{Title="PASRAH",Text="🔄 Respawn & Ulangi lagi",Duration=4})
                        end)
                        respawnPlayer()
                        LocalPlayer.CharacterAdded:Wait()
                        task.wait(2)
                    end
                end
            end)
        end
    end
})

------------------------------------------------------------
-- ===================== NOTIFICATIONS =====================
------------------------------------------------------------
pcall(function()
    StarterGui:SetCore("SendNotification",{Title="XIAAANHUB",Text="✅ SC BY !TXT SUKSES",Duration=5,Icon="rbxassetid://7733749446"})
    task.delay(6,function()
        StarterGui:SetCore("SendNotification",{Title="XIAAANHUB",Text="❤️ SEMANGAT!! DI SETIAP PERTEMUAN PASTI ADA PERPISAHAN",Duration=6,Icon="rbxassetid://6034509993"})
    end)
end)
