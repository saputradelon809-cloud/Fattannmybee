-- 🌀 FATTAN HUB FINAL STABLE (ALL-IN-ONE GUI) 🌀
-- Password: fattanhubGG
-- Owner check: FATTANMYBEE = OWNER 👑👑, selain itu MEMBER 👑

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ============ LOGIN ============
local function createLogin(onSuccess)
    local loginGui = Instance.new("ScreenGui", CoreGui)
    loginGui.Name = "FattanLogin"
    loginGui.ResetOnSpawn = false

    local frame = Instance.new("Frame", loginGui)
    frame.Size = UDim2.new(0, 280, 0, 150)
    frame.Position = UDim2.new(0.5, -140, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.AnchorPoint = Vector2.new(0.5,0.5)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,36)
    title.BackgroundTransparency = 1
    title.Text = "🔒 FattanHub Login"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.new(1,1,1)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.84,0,0,32)
    box.Position = UDim2.new(0.08,0,0,52)
    box.PlaceholderText = "Masukkan password..."
    box.Text = ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 16
    box.TextColor3 = Color3.new(1,1,1)
    box.BackgroundColor3 = Color3.fromRGB(35,35,35)

    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1,0,0,22)
    status.Position = UDim2.new(0,0,0,92)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.Font = Enum.Font.SourceSans
    status.TextSize = 14
    status.TextColor3 = Color3.fromRGB(200,200,200)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.5,0,0,32)
    btn.Position = UDim2.new(0.25,0,0,114)
    btn.Text = "Login"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)

    local correctPassword = "fattanhubGG"
    local function tryLogin()
        if box.Text == correctPassword then
            loginGui:Destroy()
            pcall(onSuccess)
        else
            box.Text = ""
            status.Text = "❌ Password salah!"
            task.delay(1.5, function() status.Text = "" end)
        end
    end
    btn.MouseButton1Click:Connect(tryLogin)
    box.FocusLost:Connect(function(enter) if enter then tryLogin() end end)
end

-- ============ MAIN GUI ============
local function initMain()
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "FattanHub"
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 240, 0, 320)
    main.Position = UDim2.new(0.3,0,0.25,0)
    main.BackgroundColor3 = Color3.fromRGB(15,40,90)
    main.Active = true
    main.Draggable = true

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,0,0,34)
    title.BackgroundColor3 = Color3.fromRGB(4,110,200)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.new(1,1,1)
    if LocalPlayer.Name == "FATTANMYBEE" then
        title.Text = "OWNER 👑👑 FattanHub"
    else
        title.Text = "MEMBER 👑 FattanHub"
    end

    local list = Instance.new("UIListLayout", main)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0,5)

    local function createButton(text, func)
        local b = Instance.new("TextButton", main)
        b.Size = UDim2.new(1,-10,0,28)
        b.BackgroundColor3 = Color3.fromRGB(10,95,180)
        b.Text = text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.TextColor3 = Color3.new(1,1,1)
        b.MouseButton1Click:Connect(func)
        return b
    end

    -- MODE SWITCH
    local compact = true
    local btnUpDown = createButton("▼ Lengkap", function()
        compact = not compact
        if compact then
            btnUpDown.Text = "▼ Lengkap"
        else
            btnUpDown.Text = "▲ Ringkas"
        end
        for _,c in ipairs(main:GetChildren()) do
            if c:IsA("TextButton") and c ~= btnUpDown then
                c.Visible = not compact or (c.Text == "Fly" or c.Text == "ESP" or c.Text == "Teleport")
            end
        end
    end)

    -- ========== FLY ==========
    local flying=false; local bv; local bg; local conn
    local speed=80; local upHold=false; local downHold=false
    local function startFly()
        if flying then return end
        flying=true
        local hrp=getChar():WaitForChild("HumanoidRootPart")
        bv=Instance.new("BodyVelocity",hrp)
        bv.MaxForce=Vector3.new(9e9,9e9,9e9)
        bg=Instance.new("BodyGyro",hrp)
        bg.MaxTorque=Vector3.new(9e9,9e9,9e9)
        conn=RunService.Heartbeat:Connect(function()
            if not flying then return end
            local hum=getChar():FindFirstChildOfClass("Humanoid")
            local move=hum.MoveDirection*speed
            local y=0;if upHold then y=60 elseif downHold then y=-60 end
            bv.Velocity=Vector3.new(move.X,y,move.Z)
            bg.CFrame=hrp.CFrame
        end)
    end
    local function stopFly()
        flying=false;if conn then conn:Disconnect() end
        if bv then bv:Destroy() end;if bg then bg:Destroy() end
    end
    createButton("Fly", function() if flying then stopFly() else startFly() end end)
    createButton("Fly Up", function() upHold=not upHold end)
    createButton("Fly Down", function() downHold=not downHold end)
    createButton("Speed +", function() speed=speed+10 end)
    createButton("Speed -", function() speed=math.max(10,speed-10) end)

    -- ========== ESP ==========
    local espOn=false
    local function toggleESP()
        espOn=not espOn
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer then
                if espOn then
                    if p.Character and not p.Character:FindFirstChild("FattanESP") then
                        local h=Instance.new("Highlight",p.Character);h.Name="FattanESP";h.FillColor=Color3.fromRGB(0,255,255)
                        local head=p.Character:FindFirstChild("Head")
                        if head and not head:FindFirstChild("FattanName") then
                            local g=Instance.new("BillboardGui",head);g.Name="FattanName";g.Size=UDim2.new(0,100,0,20);g.StudsOffset=Vector3.new(0,2,0);g.AlwaysOnTop=true
                            local l=Instance.new("TextLabel",g);l.Size=UDim2.new(1,0,1,0);l.BackgroundTransparency=1;l.Text=p.Name;l.TextSize=14;l.TextColor3=Color3.new(1,1,1)
                        end
                    end
                else
                    if p.Character then
                        local h=p.Character:FindFirstChild("FattanESP");if h then h:Destroy() end
                        local head=p.Character:FindFirstChild("Head");if head and head:FindFirstChild("FattanName") then head.FattanName:Destroy() end
                    end
                end
            end
        end
    end
    createButton("ESP", toggleESP)

    -- ========== TELEPORT ==========
    local selected
    createButton("Teleport", function()
        if selected then
            local p=Players:FindFirstChild(selected)
            if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                getChar().HumanoidRootPart.CFrame=p.Character.HumanoidRootPart.CFrame+Vector3.new(2,0,0)
            end
        end
    end)

    -- ========== FREEZE ==========
    local frozen={}
    createButton("Freeze Player", function()
        if not selected then return end
        local p=Players:FindFirstChild(selected);if not p or not p.Character then return end
        local hum=p.Character:FindFirstChildOfClass("Humanoid");if not hum then return end
        if frozen[p] then
            hum.WalkSpeed=16;hum.JumpPower=50;frozen[p]=nil
        else
            hum.WalkSpeed=0;hum.JumpPower=0;frozen[p]=true
        end
    end)

    -- ========== ROPE ==========
    local ropeActive={}
    createButton("Rope", function()
        if not selected then return end
        local p=Players:FindFirstChild(selected)
        if ropeActive[p] then ropeActive[p]:Destroy();ropeActive[p]=nil
        else
            if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local att1=Instance.new("Attachment",getChar().HumanoidRootPart)
                local att2=Instance.new("Attachment",p.Character.HumanoidRootPart)
                local beam=Instance.new("Beam",att1)
                beam.Attachment0=att1;beam.Attachment1=att2;beam.Width0=0.2;beam.Width1=0.2
                ropeActive[p]=beam
            end
        end
    end)

    -- ========== WALKFLING ==========
    local flingOn=false;local flingConn
    createButton("WalkFling", function()
        if flingOn then flingOn=false;if flingConn then flingConn:Disconnect() end
        else
            flingOn=true
            flingConn=RunService.Heartbeat:Connect(function()
                local hrp=getChar():FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Velocity=hrp.CFrame.LookVector*200 end
            end)
        end
    end)

    -- ========== NOCLIP ==========
    local noclip=false
    createButton("Noclip", function()
        noclip=not noclip
        RunService.Stepped:Connect(function()
            if noclip then
                for _,v in pairs(getChar():GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide=false end
                end
            end
        end)
    end)

    -- ========== GOD MODE ==========
    local god=false
    createButton("God Mode", function()
        god=not god;if god then getChar():WaitForChild("Humanoid").Health=math.huge end
    end)

    -- ========== SPEED / JUMP ==========
    local runspeed=16;jump=50
    createButton("Run +", function() runspeed=runspeed+5;getChar():FindFirstChildOfClass("Humanoid").WalkSpeed=runspeed end)
    createButton("Run -", function() runspeed=math.max(0,runspeed-5);getChar():FindFirstChildOfClass("Humanoid").WalkSpeed=runspeed end)
    createButton("Jump +", function() jump=jump+5;local h=getChar():FindFirstChildOfClass("Humanoid");h.UseJumpPower=true;h.JumpPower=jump end)
    createButton("Jump -", function() jump=math.max(0,jump-5);local h=getChar():FindFirstChildOfClass("Humanoid");h.UseJumpPower=true;h.JumpPower=jump end)

end

-- Run
createLogin(initMain)
