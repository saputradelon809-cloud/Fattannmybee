-- // =================== XIAAANHUB (By !TXT) ===================
-- No loading screen. One file. All features.

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

-- // Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

-- // Utils
local function notify(t, m, d)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title=t or "XIAAANHUB", Text=m or "", Duration=d or 3})
    end)
end

------------------------------------------------------------
-- ===================== TAB 1 : SCRIPT =====================
------------------------------------------------------------
local ScriptTab = Window:CreateTab("SCRIPT", 4483362458)

-- ✈️ Fly (draggable mini GUI, speed 1–1000, body stiff)
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

-- 👀 ESP Player
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

-- 💀 God Mode
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

-- 🏃 Walk Speed & 🦘 Jump Power
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

-- 👑 Admin Title
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

-- 🔄 Rejoin
ScriptTab:CreateButton({
    Name = "🔄 Rejoin",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

-- 🛡️ Anti AFK
ScriptTab:CreateToggle({
    Name = "🛡️ Anti AFK",
    CurrentValue = false,
    Callback = function(state)
        if state then
            getgenv().AntiAfk = true
            LocalPlayer.Idled:Connect(function()
                if getgenv().AntiAfk then
                    VirtualUser:Button2Down(Vector2.new(0,0),Workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0),Workspace.CurrentCamera.CFrame)
                end
            end)
        else
            getgenv().AntiAfk = false
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

-- 🦖 Avatar Size
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

-- 📹 CCTV Player
local cam = Workspace.CurrentCamera
local plist2, selectedCCTV = {}, nil
for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(plist2,p.Name) end end
local dropCCTV = TxtTab:CreateDropdown({
    Name="Pilih Player untuk CCTV",
    Options=plist2, CurrentOption={}, MultipleOptions=false, Flag="CCTVList",
    Callback=function(o) selectedCCTV=o[1] end
})
TxtTab:CreateButton({
    Name="📹 CCTV ON",
    Callback=function()
        if selectedCCTV then
            local t=Players:FindFirstChild(selectedCCTV)
            if t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
                cam.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid")
                notify("CCTV","Mengamati "..t.Name,3)
            end
        end
    end
})
TxtTab:CreateButton({
    Name="⏹ CCTV OFF",
    Callback=function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then cam.CameraSubject = hum end
        notify("CCTV","Kembali ke kamera normal",3)
    end
})

-- 📜 Load Infinite Yield
TxtTab:CreateButton({
    Name = "📜 Load Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        notify("XIAAANHUB","✅ Infinite Yield berhasil dijalankan!",4)
    end
})

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
                        notify("MOUNT BAYI","📍 Spot "..i.." Selesai",2)
                        task.wait(3)
                    end
                    if autoBayi then
                        notify("MOUNT BAYI","🔄 Respawn & Ulangi lagi",4)
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
                        notify("PASRAH","📍 Spot "..i.." Selesai",2)
                        task.wait(3)
                    end
                    if autoPasrah then
                        notify("PASRAH","🔄 Respawn & Ulangi lagi",4)
                        respawnPlayer()
                        LocalPlayer.CharacterAdded:Wait()
                        task.wait(2)
                    end
                end
            end)
        end
    end
})

-- 🔹 MOUNT CIKCOK
local cikcokSpots = {
    Vector3.new(-365,182,-495),
    Vector3.new(-595,344,-863),
    Vector3.new(-1028,528,-747),
    Vector3.new(-1368,508,-866),
    Vector3.new(-1356,504,-1120),
    Vector3.new(-1325,512,-1869),
    Vector3.new(-1118,519,-2312),
    Vector3.new(-1093,516,-1816),
    Vector3.new(-1042,817,-1559),
    Vector3.new(-900,1100,-1507),
    Vector3.new(-622,1112,-1566),
    Vector3.new(-389,1132,-1293),
    Vector3.new(-283,1256,-1787),
    Vector3.new(-482,1288,-2171),
    Vector3.new(-374,1368,-2202),
    Vector3.new(-141,1596,-2143),
}
local autoCikcok = false
AutoTab:CreateToggle({
    Name="🚀 Auto Route MOUNT CIKCOK (Loop)",
    CurrentValue=false,
    Callback=function(state)
        autoCikcok=state
        if state then
            task.spawn(function()
                while autoCikcok do
                    for i,spot in ipairs(cikcokSpots) do
                        if not autoCikcok then break end
                        tpTo(spot)
                        notify("MOUNT CIKCOK","📍 Spot "..i.." Selesai",2)
                        task.wait(3)
                    end
                    if autoCikcok then
                        notify("MOUNT CIKCOK","🔄 Respawn & Ulangi lagi",4)
                        respawnPlayer()
                        LocalPlayer.CharacterAdded:Wait()
                        task.wait(2)
                    end
                end
            end)
        end
    end
})

-- 🔹 GUNUNG PAMALI
local pamaliSpots = {
    Vector3.new(-91,449,651),
    Vector3.new(532,470,730),
    Vector3.new(767,360,389),
    Vector3.new(873,464,31),
    Vector3.new(-279,358,-98),
    Vector3.new(-335,460,-173),
    Vector3.new(-293,478,-337),
    Vector3.new(-295,619,-407),
    Vector3.new(-299,603,-555),
    Vector3.new(-546,744,-413),
    Vector3.new(-1416,627,-303),
    Vector3.new(-1925,570,-126),
    Vector3.new(-2208,674,-193),
    Vector3.new(-2527,775,-360),
    Vector3.new(-2691,784,-382),
    Vector3.new(-2892,776,-84),
    Vector3.new(-2948,800,257),
    Vector3.new(-3004,806,491),
    Vector3.new(-2717,786,474),
    Vector3.new(-2785,778,682),
}
local autoPamali = false
AutoTab:CreateToggle({
    Name="🚀 Auto Route GUNUNG PAMALI (Loop)",
    CurrentValue=false,
    Callback=function(state)
        autoPamali = state
        if state then
            task.spawn(function()
                while autoPamali do
                    for i,spot in ipairs(pamaliSpots) do
                        if not autoPamali then break end
                        tpTo(spot)
                        notify("GUNUNG PAMALI","📍 Spot "..i.." Selesai",2)
                        task.wait(3)
                    end
                    if autoPamali then
                        notify("GUNUNG PAMALI","🔄 Respawn & Ulangi lagi",4)
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
notify("XIAAANHUB","✅ SC BY !TXT SUKSES",5)
task.delay(6,function()
    notify("XIAAANHUB","❤️ SEMANGAT!! DI SETIAP PERTEMUAN PASTI ADA PERPISAHAN",6)
end)
