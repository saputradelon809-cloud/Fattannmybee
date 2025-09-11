-- FATTAN HUB FINAL
-- Password: fattanhubGG

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

------------------------------------------------
-- Helper
------------------------------------------------
local function safeChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

------------------------------------------------
-- LOGIN UI
------------------------------------------------
local function createLogin(onSuccess)
    local loginGui = Instance.new("ScreenGui", CoreGui)
    loginGui.Name = "FattanLogin"

    local frame = Instance.new("Frame", loginGui)
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,36)
    title.Text = "🔒 FattanHub Login"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.new(1,1,1)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.8,0,0,32)
    box.Position = UDim2.new(0.1,0,0,50)
    box.PlaceholderText = "Masukkan password..."
    box.Text = ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 16
    box.TextColor3 = Color3.new(1,1,1)
    box.BackgroundColor3 = Color3.fromRGB(40,40,40)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.5,0,0,32)
    btn.Position = UDim2.new(0.25,0,0,100)
    btn.Text = "Login"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)

    local correct = "fattanhubGG"
    local function tryLogin()
        if box.Text == correct then
            loginGui:Destroy()
            onSuccess()
        else
            box.Text = ""
            btn.Text = "❌ Salah!"
            task.delay(1,function() btn.Text="Login" end)
        end
    end
    btn.MouseButton1Click:Connect(tryLogin)
    box.FocusLost:Connect(function(enter) if enter then tryLogin() end end)
end

------------------------------------------------
-- MAIN GUI
------------------------------------------------
local function initMain()
    -- Loading
    local loading = Instance.new("ScreenGui", CoreGui)
    local lf = Instance.new("Frame", loading)
    lf.Size = UDim2.new(1,0,1,0)
    lf.BackgroundColor3 = Color3.fromRGB(10,40,90)
    local lbl = Instance.new("TextLabel", lf)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.Text = "FATTAN HUB"
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 36
    lbl.TextColor3 = Color3.new(1,1,1)
    task.wait(1)
    loading:Destroy()

    -- GUI
    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "FattanHub"

    local main = Instance.new("Frame", screenGui)
    main.Size = UDim2.new(0, 260, 0, 400)
    main.Position = UDim2.new(0.35,0,0.2,0)
    main.BackgroundColor3 = Color3.fromRGB(8,44,110)
    main.Active = true
    main.Draggable = true

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,0,0,36)
    title.BackgroundColor3 = Color3.fromRGB(4,110,200)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Color3.new(1,1,1)
    if LocalPlayer.Name == "FATTANMYBEE" then
        title.Text = "OWNER 👑👑"
    else
        title.Text = "MEMBER 👑"
    end

    -- tombol Up/Down
    local upBtn = Instance.new("TextButton", main)
    upBtn.Size = UDim2.new(0.5,-4,0,30)
    upBtn.Position = UDim2.new(0,2,0,40)
    upBtn.Text = "Up (Ringkas)"
    upBtn.Font = Enum.Font.SourceSansBold
    upBtn.TextSize = 16
    upBtn.BackgroundColor3 = Color3.fromRGB(40,120,40)

    local downBtn = Instance.new("TextButton", main)
    downBtn.Size = UDim2.new(0.5,-4,0,30)
    downBtn.Position = UDim2.new(0.5,2,0,40)
    downBtn.Text = "Down (Lengkap)"
    downBtn.Font = Enum.Font.SourceSansBold
    downBtn.TextSize = 16
    downBtn.BackgroundColor3 = Color3.fromRGB(160,40,40)

    -- Container tombol
    local list = Instance.new("ScrollingFrame", main)
    list.Size = UDim2.new(1,-10,1,-80)
    list.Position = UDim2.new(0,5,0,80)
    list.BackgroundTransparency = 1
    list.ScrollBarThickness = 4
    local layout = Instance.new("UIListLayout", list)
    layout.Padding = UDim.new(0,4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    ------------------------------------------------
    -- Tombol helper
    ------------------------------------------------
    local function createButton(txt,callback)
        local b = Instance.new("TextButton", list)
        b.Size = UDim2.new(1,-6,0,32)
        b.Text = txt
        b.Font = Enum.Font.SourceSansBold
        b.TextSize = 16
        b.BackgroundColor3 = Color3.fromRGB(40,100,180)
        b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(function() pcall(callback) end)
        return b
    end

    ------------------------------------------------
    -- Semua Fitur
    ------------------------------------------------
    -- Fly
    local flying=false
    local bv,bg,conn
    local flySpeed=80
    local upHold,downHold=false,false
    local vSpeed=60
    local function startFly()
        if flying then return end
        flying=true
        local ch=safeChar()
        local hrp=ch:WaitForChild("HumanoidRootPart")
        local hum=ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand=true end
        bv=Instance.new("BodyVelocity",hrp)
        bv.MaxForce=Vector3.new(9e9,9e9,9e9)
        bv.Velocity=Vector3.zero
        bg=Instance.new("BodyGyro",hrp)
        bg.MaxTorque=Vector3.new(9e9,9e9,9e9)
        bg.CFrame=hrp.CFrame
        conn=RunService.Heartbeat:Connect(function()
            if not flying then return end
            local move=hum.MoveDirection
            local vx,vy,vz=0,0,0
            if move.Magnitude>0 then
                local v=move.Unit*flySpeed
                vx,vy,vz=v.X,v.Y,v.Z
            end
            if upHold then vy=vSpeed elseif downHold then vy=-vSpeed end
            bv.Velocity=Vector3.new(vx,vy,vz)
            bg.CFrame=hrp.CFrame
        end)
    end
    local function stopFly()
        flying=false
        if conn then conn:Disconnect() end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        local hum=safeChar():FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand=false end
    end
    createButton("Fly (Toggle)",function() if flying then stopFly() else startFly() end end)

    -- ESP
    local esp=false
    local function addESP(p)
        if not p.Character then return end
        if p.Character:FindFirstChild("FattanESP") then return end
        local h=p.Character:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local hl=Instance.new("Highlight",p.Character)
        hl.Name="FattanESP"
        hl.FillColor=Color3.fromRGB(0,255,255)
    end
    local function remESP(p)
        if p.Character and p.Character:FindFirstChild("FattanESP") then
            p.Character.FattanESP:Destroy()
        end
    end
    createButton("ESP Toggle",function()
        esp=not esp
        for _,pl in pairs(Players:GetPlayers()) do
            if pl~=LocalPlayer then
                if esp then addESP(pl) else remESP(pl) end
            end
        end
    end)
    Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5) if esp then addESP(p) end end) end)

    -- Teleport + Freeze
    local selected=nil
    createButton("Pilih Player Random",function()
        for _,p in pairs(Players:GetPlayers()) do
            if p~=LocalPlayer then selected=p break end
        end
    end)
    createButton("Teleport ke Selected",function()
        if selected and selected.Character and selected.Character:FindFirstChild("HumanoidRootPart") then
            local hrp=safeChar():WaitForChild("HumanoidRootPart")
            hrp.CFrame=selected.Character.HumanoidRootPart.CFrame+Vector3.new(2,0,0)
        end
    end)
    createButton("Freeze Selected",function()
        if not selected or not selected.Character then return end
        local hum=selected.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed=0 hum.JumpPower=0
            task.delay(5,function() hum.WalkSpeed=16 hum.JumpPower=50 end)
        end
    end)

    -- Rope
    local rope={}
    createButton("Tarik Tali Selected",function()
        if not selected or rope[selected] then return end
        local me=safeChar():FindFirstChild("HumanoidRootPart")
        local tar=selected.Character and selected.Character:FindFirstChild("HumanoidRootPart")
        if not me or not tar then return end
        local att1=Instance.new("Attachment",me)
        local att2=Instance.new("Attachment",tar)
        local bm=Instance.new("Beam",me)
        bm.Attachment0=att1 bm.Attachment1=att2
        bm.Width0=0.2 bm.Width1=0.2
        bm.Color=ColorSequence.new(Color3.new(1,0,0))
        local conn=RunService.RenderStepped:Connect(function()
            if (tar.Position-me.Position).Magnitude>6 then
                tar.CFrame=tar.CFrame:Lerp(CFrame.new(me.Position),0.1)
            end
        end)
        rope[selected]={bm,att1,att2,conn}
    end)
    createButton("Stop Rope",function()
        if selected and rope[selected] then
            for _,v in pairs(rope[selected]) do
                if typeof(v)=="RBXScriptConnection" then v:Disconnect()
                elseif typeof(v)=="Instance" and v.Parent then v:Destroy() end
            end
            rope[selected]=nil
        end
    end)

    -- Delete Parts
    local scanning=false
    createButton("Scan Parts",function()
        scanning=not scanning
        if scanning then
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v.Anchored then v.Color=Color3.new(1,0,0) end
            end
        else
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.Color=Color3.fromRGB(255,255,255) end
            end
        end
    end)

    -- WalkFling Invisible
    local fling=false
    local flingConn,flingPart,flingBV
    local function startFling()
        if fling then return end
        fling=true
        local hrp=safeChar():WaitForChild("HumanoidRootPart")
        flingPart=Instance.new("Part",workspace)
        flingPart.Size=Vector3.new(20,20,20)
        flingPart.Transparency=1
        local weld=Instance.new("WeldConstraint",flingPart)
        weld.Part0=flingPart weld.Part1=hrp
        flingBV=Instance.new("BodyVelocity",flingPart)
        flingBV.MaxForce=Vector3.new(1e9,1e9,1e9)
        flingConn=RunService.Heartbeat:Connect(function()
            flingBV.Velocity=hrp.CFrame.LookVector*160
        end)
    end
    local function stopFling()
        fling=false
        if flingConn then flingConn:Disconnect() end
        if flingPart then flingPart:Destroy() end
    end
    createButton("WalkFling Toggle",function() if fling then stopFling() else startFling() end end)

    -- Speed & Jump
    local run=16
    local jump=50
    createButton("Run +",function() run=run+5 local h=safeChar():FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=run end end)
    createButton("Jump +",function() jump=jump+10 local h=safeChar():FindFirstChildOfClass("Humanoid") if h then h.JumpPower=jump end end)
    createButton("Reset Speed/Jump",function() run=16 jump=50 local h=safeChar():FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=run h.JumpPower=jump end end)

    ------------------------------------------------
    -- Mode Ringkas/Lengkap
    ------------------------------------------------
    local function setMode(ringkas)
        for _,b in pairs(list:GetChildren()) do
            if b:IsA("TextButton") then
                if ringkas then
                    b.Visible = (b.Text=="Fly (Toggle)" or b.Text=="ESP Toggle" or b.Text=="Teleport ke Selected")
                else
                    b.Visible = true
                end
            end
        end
    end
    setMode(true)
    upBtn.MouseButton1Click:Connect(function() setMode(true) end)
    downBtn.MouseButton1Click:Connect(function() setMode(false) end)
end

-- Jalankan
createLogin(initMain)
