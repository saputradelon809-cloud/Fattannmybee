-- // FATTAN HUB - FINAL BUILD
-- Dengan update: WalkFling kotak besar, Run & Jump textbox min 500,
-- Fly diam di udara, Owner Crown + Trophy muter, Tarik tali karet,
-- Tombol X (close) dan -/+ (resize GUI)

if game.CoreGui:FindFirstChild("FattanHub") then
    game.CoreGui.FattanHub:Destroy()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function getChar(plr)
    plr = plr or LocalPlayer
    return plr.Character or plr.CharacterAdded:Wait()
end

-- GUI utama
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FattanHub"

local mainFrame = Instance.new("Frame", gui)
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 240, 0, 420)
mainFrame.Position = UDim2.new(0.5,-120,0.5,-210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20,40,80)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -60, 0, 36)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "FATTAN HUB"
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

-- [NEW] Tombol X dan +/- (resize)
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0,28,0,28)
closeBtn.Position = UDim2.new(1,-34,0,4)
closeBtn.BackgroundColor3 = Color3.fromRGB(150,40,40)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local resizeMinus = Instance.new("TextButton", mainFrame)
resizeMinus.Text = "−"
resizeMinus.Size = UDim2.new(0,28,0,28)
resizeMinus.Position = UDim2.new(1,-66,0,4)
resizeMinus.BackgroundColor3 = Color3.fromRGB(60,60,120)
resizeMinus.TextColor3 = Color3.new(1,1,1)
resizeMinus.Font = Enum.Font.SourceSansBold
resizeMinus.TextSize = 18

local resizePlus = Instance.new("TextButton", mainFrame)
resizePlus.Text = "+"
resizePlus.Size = UDim2.new(0,28,0,28)
resizePlus.Position = UDim2.new(1,-98,0,4)
resizePlus.BackgroundColor3 = Color3.fromRGB(60,120,60)
resizePlus.TextColor3 = Color3.new(1,1,1)
resizePlus.Font = Enum.Font.SourceSansBold
resizePlus.TextSize = 18

local scaleFactor = 1
resizeMinus.MouseButton1Click:Connect(function()
    scaleFactor = math.max(0.5, scaleFactor - 0.1)
    mainFrame.Size = UDim2.new(0, 240*scaleFactor, 0, 420*scaleFactor)
end)
resizePlus.MouseButton1Click:Connect(function()
    scaleFactor = math.min(2, scaleFactor + 0.1)
    mainFrame.Size = UDim2.new(0, 240*scaleFactor, 0, 420*scaleFactor)
end)

local content = Instance.new("ScrollingFrame", mainFrame)
content.Position = UDim2.new(0,6,0,40)
content.Size = UDim2.new(1,-12,1,-46)
content.CanvasSize = UDim2.new(0,0,0,0)
content.ScrollBarThickness = 4
content.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", content)
layout.Padding = UDim.new(0,6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function createButton(txt, func)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(1,-12,0,32)
    b.BackgroundColor3 = Color3.fromRGB(30,60,120)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 15
    b.Text = txt
    b.MouseButton1Click:Connect(func)
    return b
end

-- [NEW] Fly system diperbaiki
do
    local flying = false
    local flyConn
    local flyBV, flyBG
    local flySpeed = 60
    local moveVec = Vector3.zero
    local up=false; local down=false

    local function startFly()
        local char = getChar()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        flying = true

        flyBV = Instance.new("BodyVelocity", hrp)
        flyBV.Velocity = Vector3.zero
        flyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
        flyBV.P = 1250

        flyBG = Instance.new("BodyGyro", hrp)
        flyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
        flyBG.P = 5000
        flyBG.CFrame = hrp.CFrame

        flyConn = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if up then move += Vector3.new(0,1,0) end
            if down then move -= Vector3.new(0,1,0) end

            if move.Magnitude < 0.09 then
                flyBV.Velocity = Vector3.zero -- diam di udara [NEW]
            else
                flyBV.Velocity = move.Unit * flySpeed
            end
            flyBG.CFrame = cam.CFrame
        end)
    end

    local function stopFly()
        flying = false
        if flyConn then flyConn:Disconnect() flyConn=nil end
        if flyBV then flyBV:Destroy() flyBV=nil end
        if flyBG then flyBG:Destroy() flyBG=nil end
    end

    createButton("Fly (Toggle)", function()
        if flying then stopFly() else startFly() end
    end)

    -- tombol mobile up/down
    local upBtn = Instance.new("TextButton", gui)
    upBtn.Text = "↑"
    upBtn.Size = UDim2.new(0,60,0,60)
    upBtn.Position = UDim2.new(0.85,0,0.7,0)
    upBtn.BackgroundColor3 = Color3.fromRGB(40,120,40)
    upBtn.TextColor3 = Color3.new(1,1,1)
    upBtn.Font = Enum.Font.SourceSansBold
    upBtn.TextSize = 30

    local downBtn = Instance.new("TextButton", gui)
    downBtn.Text = "↓"
    downBtn.Size = UDim2.new(0,60,0,60)
    downBtn.Position = UDim2.new(0.85,0,0.8,0)
    downBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)
    downBtn.TextColor3 = Color3.new(1,1,1)
    downBtn.Font = Enum.Font.SourceSansBold
    downBtn.TextSize = 30

    upBtn.MouseButton1Down:Connect(function() up=true end)
    upBtn.MouseButton1Up:Connect(function() up=false end)
    downBtn.MouseButton1Down:Connect(function() down=true end)
    downBtn.MouseButton1Up:Connect(function() down=false end)
end

-- [NEW] WalkFling kotak besar
do
    local flingOn=false
    local flingConn, flingBox, flingBAV

    local function startFling()
        local char = getChar()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        flingBox = Instance.new("Part", workspace)
        flingBox.Size = Vector3.new(20,20,20)
        flingBox.Transparency = 1
        flingBox.CanCollide = false
        flingBox.Anchored = false
        flingBox.Massless = true

        local weld = Instance.new("WeldConstraint", flingBox)
        weld.Part0 = flingBox
        weld.Part1 = hrp

        flingBAV = Instance.new("BodyAngularVelocity", flingBox)
        flingBAV.AngularVelocity = Vector3.new(0,999999,0)
        flingBAV.MaxTorque = Vector3.new(9e9,9e9,9e9)

        flingConn = RunService.Heartbeat:Connect(function()
            if flingOn and hrp then
                hrp.Velocity = hrp.CFrame.LookVector*60
            end
        end)
    end

    local function stopFling()
        if flingConn then flingConn:Disconnect() flingConn=nil end
        if flingBAV then flingBAV:Destroy() flingBAV=nil end
        if flingBox then flingBox:Destroy() flingBox=nil end
    end

    createButton("WalkFling (Toggle)", function()
        flingOn = not flingOn
        if flingOn then startFling() else stopFling() end
    end)
end

-- [NEW] Run & Jump dengan textbox min 500
do
    local runVal = 500
    local jumpVal = 500

    local function makeRow(label, init, applyFunc)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1,-12,0,36)
        frame.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.35,0,1,0)
        lbl.Position = UDim2.new(0,6,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.new(1,1,1)

        local minus = Instance.new("TextButton", frame)
        minus.Size = UDim2.new(0,28,0,28)
        minus.Position = UDim2.new(0.52,0,0,4)
        minus.Text = "−"
        minus.BackgroundColor3 = Color3.fromRGB(160,40,40)
        minus.TextColor3 = Color3.new(1,1,1)

        local valBox = Instance.new("TextBox", frame)
        valBox.Size = UDim2.new(0,64,0,28)
        valBox.Position = UDim2.new(0.65,0,0,4)
        valBox.BackgroundColor3 = Color3.fromRGB(12,30,80)
        valBox.TextColor3 = Color3.new(1,1,1)
        valBox.Font = Enum.Font.SourceSansBold
        valBox.Text = tostring(init)
        valBox.ClearTextOnFocus = false

        local plus = Instance.new("TextButton", frame)
        plus.Size = UDim2.new(0,28,0,28)
        plus.Position = UDim2.new(0.88,0,0,4)
        plus.Text = "+"
        plus.BackgroundColor3 = Color3.fromRGB(40,120,40)
        plus.TextColor3 = Color3.new(1,1,1)

        return valBox, minus, plus
    end

    local runBox, runMinus, runPlus = makeRow("Run Speed", runVal)
    runMinus.MouseButton1Click:Connect(function()
        runVal = math.max(500, runVal-50)
        runBox.Text = runVal
        pcall(function() getChar():FindFirstChildOfClass("Humanoid").WalkSpeed=runVal end)
    end)
    runPlus.MouseButton1Click:Connect(function()
        runVal = runVal+50
        runBox.Text = runVal
        pcall(function() getChar():FindFirstChildOfClass("Humanoid").WalkSpeed=runVal end)
    end)
    runBox.FocusLost:Connect(function(enter)
        if enter then
            local v=tonumber(runBox.Text)
            if v then
                runVal=math.max(500,v)
                runBox.Text=runVal
                pcall(function() getChar():FindFirstChildOfClass("Humanoid").WalkSpeed=runVal end)
            else runBox.Text=runVal end
        end
    end)

    local jumpBox, jumpMinus, jumpPlus = makeRow("Jump Power", jumpVal)
    jumpMinus.MouseButton1Click:Connect(function()
        jumpVal = math.max(500, jumpVal-50)
        jumpBox.Text=jumpVal
        pcall(function() local h=getChar():FindFirstChildOfClass("Humanoid"); h.UseJumpPower=true; h.JumpPower=jumpVal end)
    end)
    jumpPlus.MouseButton1Click:Connect(function()
        jumpVal = jumpVal+50
        jumpBox.Text=jumpVal
        pcall(function() local h=getChar():FindFirstChildOfClass("Humanoid"); h.UseJumpPower=true; h.JumpPower=jumpVal end)
    end)
    jumpBox.FocusLost:Connect(function(enter)
        if enter then
            local v=tonumber(jumpBox.Text)
            if v then
                jumpVal=math.max(500,v)
                jumpBox.Text=jumpVal
                pcall(function() local h=getChar():FindFirstChildOfClass("Humanoid"); h.UseJumpPower=true; h.JumpPower=jumpVal end)
            else jumpBox.Text=jumpVal end
        end
    end)

    createButton("Reset Speed & Jump", function()
        runVal=500;jumpVal=500
        runBox.Text=runVal;jumpBox.Text=jumpVal
        pcall(function() local h=getChar():FindFirstChildOfClass("Humanoid"); h.WalkSpeed=runVal; h.UseJumpPower=true; h.JumpPower=jumpVal end)
    end)
end

-- [NEW] Owner Crown + Trophy muter
local function createOwnerCrown()
    local char=getChar()
    local head=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head or head:FindFirstChild("FattanOwner") then return end

    local bg=Instance.new("BillboardGui",head)
    bg.Name="FattanOwner"
    bg.Size=UDim2.new(0,120,0,30)
    bg.StudsOffset=Vector3.new(0,3,0)
    bg.AlwaysOnTop=true

    local crown=Instance.new("ImageLabel",bg)
    crown.Size=UDim2.new(0,28,0,28)
    crown.Position=UDim2.new(0,4,0,0)
    crown.BackgroundTransparency=1
    crown.Image="rbxassetid://6031068426"

    local lbl=Instance.new("TextLabel",bg)
    lbl.Size=UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency=1
    lbl.Text="  OWNER"
    lbl.Font=Enum.Font.GothamBlack
    lbl.TextColor3=Color3.fromRGB(255,215,0)
    lbl.TextScaled=true
    lbl.TextStrokeTransparency=0.2

    -- trophy 3D muter
    local trophy=Instance.new("Part",workspace)
    trophy.Size=Vector3.new(1,1,1)
    trophy.Anchored=false
    trophy.CanCollide=false
    trophy.Massless=true
    trophy.Transparency=1

    local mesh=Instance.new("SpecialMesh",trophy)
    mesh.MeshId="rbxassetid://72524338"
    mesh.Scale=Vector3.new(2,2,2)

    local attHead=Instance.new("Attachment",head)
    attHead.Position=Vector3.new(0,4,0)
    local attT=Instance.new("Attachment",trophy)

    local align=Instance.new("AlignPosition",trophy)
    align.Attachment0=attT
    align.Attachment1=attHead
    align.Responsiveness=200

    local bav=Instance.new("BodyAngularVelocity",trophy)
    bav.AngularVelocity=Vector3.new(0,5,0)
    bav.MaxTorque=Vector3.new(0,math.huge,0)
end

createOwnerCrown()
LocalPlayer.CharacterAdded:Connect(function() task.wait(1); createOwnerCrown() end)

-- [NEW] Tarik Player dengan tali karet
createButton("Pull Selected (Elastic)", function()
    if not _G.SelectedPlayer then return end
    local char=getChar()
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local target=_G.SelectedPlayer.Character and _G.SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not(hrp and target) then return end

    local att1=Instance.new("Attachment",hrp)
    local att2=Instance.new("Attachment",target)

    local spring=Instance.new("SpringConstraint",hrp)
    spring.Attachment0=att1
    spring.Attachment1=att2
    spring.Visible=true
    spring.Thickness=0.3
    spring.Color=BrickColor.new("Really red")
    spring.Coils=3
    spring.Damping=5
    spring.Stiffness=200
    spring.FreeLength=(hrp.Position-target.Position).Magnitude
end)

-- Player List
do
    local frame=Instance.new("Frame",content)
    frame.Size=UDim2.new(1,-12,0,100)
    frame.BackgroundColor3=Color3.fromRGB(25,50,100)

    local list=Instance.new("ScrollingFrame",frame)
    list.Size=UDim2.new(1,0,1,0)
    list.CanvasSize=UDim2.new(0,0,0,0)
    list.ScrollBarThickness=4
    list.BackgroundTransparency=1

    local ll=Instance.new("UIListLayout",list)
    ll.SortOrder=Enum.SortOrder.LayoutOrder

    local function refresh()
        for _,v in pairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _,plr in pairs(Players:GetPlayers()) do
            if plr~=LocalPlayer then
                local btn=Instance.new("TextButton",list)
                btn.Size=UDim2.new(1,-8,0,24)
                btn.BackgroundColor3=Color3.fromRGB(40,80,160)
                btn.TextColor3=Color3.new(1,1,1)
                btn.Text=plr.Name
                btn.MouseButton1Click:Connect(function()
                    _G.SelectedPlayer=plr
                end)
            end
        end
    end
    refresh()
    Players.PlayerAdded:Connect(refresh)
    Players.PlayerRemoving:Connect(refresh)
end
