
-- FATTAN HUB - MERGED (Gabungan script pertama + kedua)
-- Full commented version (Login + Loading + Main GUI + Features)
-- Password: fattanhubGG
-- NOTE: Replace logoAsset with your uploaded Roblox decal asset id, e.g. "rbxassetid://1234567890"

-- Services
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

-- If LocalPlayer not ready (rare), wait
if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

-- Ganti dengan asset logo kamu (opsional)
local logoAsset = "rbxassetid://6031068426" -- ubah sesuai asset id mu

-- Safe character getter
local function safeChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ====================================================
-- LOGIN UI (dari script kedua, dipakai sebagai entry)
-- ====================================================
local function createLogin(onSuccess)
    local loginGui = Instance.new("ScreenGui")
    loginGui.Name = "FattanLogin"
    loginGui.ResetOnSpawn = false
    loginGui.Parent = CoreGui

    local frame = Instance.new("Frame", loginGui)
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0.5,0.5)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,36)
    title.Position = UDim2.new(0,0,0,6)
    title.BackgroundTransparency = 1
    title.Text = "🔒 FattanHub Login"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255,255,255)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.84,0,0,32)
    box.Position = UDim2.new(0.08,0,0,52)
    box.PlaceholderText = "Masukkan password..."
    box.Text = ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 16
    box.TextColor3 = Color3.fromRGB(1,1,1)
    box.BackgroundColor3 = Color3.fromRGB(35,35,35)
    box.ClearTextOnFocus = false
    box.TextEditable = true
    box.ClipsDescendants = true
    box.TextXAlignment = Enum.TextXAlignment.Center

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
        local v = tostring(box.Text or "")
        if v == correctPassword then
            loginGui:Destroy()
            pcall(onSuccess)
        else
            box.Text = ""
            status.Text = "❌ Password salah!"
            task.delay(1.4, function() if status and status.Parent then status.Text = "" end end)
        end
    end

    btn.MouseButton1Click:Connect(tryLogin)
    box.FocusLost:Connect(function(enter)
        if enter then tryLogin() end
    end)
end

-- ====================================================
-- MAIN (dari script kedua) + tambahan fitur dari pertama
-- ====================================================
local function initMain()
    -- ---------- Loading ----------
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "FattanLoading"
    loadingGui.ResetOnSpawn = false
    loadingGui.Parent = CoreGui

    local loadFrame = Instance.new("Frame", loadingGui)
    loadFrame.Size = UDim2.new(1,0,1,0)
    loadFrame.BackgroundColor3 = Color3.fromRGB(6, 36, 90)

    local loadLabel = Instance.new("TextLabel", loadFrame)
    loadLabel.Size = UDim2.new(1,0,1,0)
    loadLabel.BackgroundTransparency = 1
    loadLabel.Text = "FATTAN HUB"
    loadLabel.Font = Enum.Font.GothamBold
    loadLabel.TextSize = 36
    loadLabel.TextColor3 = Color3.new(1,1,1)

    task.wait(0.9)
    TweenService:Create(loadFrame, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
    TweenService:Create(loadLabel, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
    task.wait(0.8)
    loadingGui:Destroy()

-- 🌟 Main GUI
local mainGui = Instance.new("ScreenGui", player.PlayerGui)
mainGui.Enabled = false
local mainFrame = Instance.new("Frame", mainGui)
mainFrame.Size = UDim2.new(0.35, 0, 0.45, 0) -- compact
mainFrame.Position = UDim2.new(0.325, 0, 0.25, 0) -- center
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)
local stroke2 = Instance.new("UIStroke", mainFrame)
stroke2.Thickness = 2
stroke2.Color = Color3.fromRGB(0,170,255)

local uiList = Instance.new("UIListLayout", mainFrame)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0,6)


    -- minimize and exit buttons (top-right)
    local exitBtn = Instance.new("TextButton", mainFrame)
    exitBtn.Size = UDim2.new(0,26,0,22)
    exitBtn.Position = UDim2.new(1,-30,0,6)
    exitBtn.AnchorPoint = Vector2.new(0,0)
    exitBtn.Text = "X"
    exitBtn.Font = Enum.Font.SourceSansBold
    exitBtn.TextSize = 18
    exitBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    exitBtn.TextColor3 = Color3.new(1,1,1)

    local minBtn = Instance.new("TextButton", mainFrame)
    minBtn.Size = UDim2.new(0,26,0,22)
    minBtn.Position = UDim2.new(1,-62,0,6)
    minBtn.AnchorPoint = Vector2.new(0,0)
    minBtn.Text = "—"
    minBtn.Font = Enum.Font.SourceSansBold
    minBtn.TextSize = 18
    minBtn.BackgroundColor3 = Color3.fromRGB(180,180,60)
    minBtn.TextColor3 = Color3.new(1,1,1)

    -- create minimize icon (circular) hidden by default
    local miniIcon = Instance.new("ImageButton", screenGui)
    miniIcon.Name = "FattanMiniIcon"
    miniIcon.Size = UDim2.new(0,54,0,54)
    miniIcon.Position = UDim2.new(0.02,0,0.75,0)
    miniIcon.BackgroundColor3 = Color3.fromRGB(8,44,110)
    miniIcon.AutoButtonColor = true
    miniIcon.Visible = false
    miniIcon.Image = logoAsset
    miniIcon.ImageRectOffset = Vector2.new(0,0)

    -- minimize behavior
    minBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        miniIcon.Visible = true
    end)
    -- restore behavior
    miniIcon.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        miniIcon.Visible = false
    end)

    -- exit behavior
    exitBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if screenGui and screenGui.Parent then screenGui:Destroy() end
        end)
    end)

    local listLayout = Instance.new("UIListLayout", mainFrame)
    listLayout.Padding = UDim.new(0,6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function createButton(text, callback)
        local btn = Instance.new("TextButton", mainFrame)
        btn.Size = UDim2.new(1,-12,0,30)
        btn.BackgroundColor3 = Color3.fromRGB(10,95,180)
        btn.Text = text
        btn.Font = Enum.Font.SourceSansSemibold
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1,1,1)
        btn.AutoButtonColor = true
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
        return btn
    end

    -- Keep mouse reference
    local mouse = LocalPlayer:GetMouse()

    -- ============================
    -- FLY (Joystick + Up/Down panel) - dari script kedua
    -- ============================
    local flying = false
    local flyBV, flyBG, flyConn
    local flySpeed = 80 -- default
    -- UI controls for fly speed
    local flyRow = Instance.new("Frame", mainFrame)
    flyRow.Size = UDim2.new(1,-12,0,34)
    flyRow.BackgroundTransparency = 1
    local flyLabel = Instance.new("TextLabel", flyRow)
    flyLabel.Size = UDim2.new(0.45,0,1,0); flyLabel.Position = UDim2.new(0,6,0,0)
    flyLabel.BackgroundTransparency = 1; flyLabel.Text = "Fly Speed"; flyLabel.Font = Enum.Font.SourceSansBold; flyLabel.TextSize = 14; flyLabel.TextColor3 = Color3.new(1,1,1)
    local flyMinus = Instance.new("TextButton", flyRow)
    flyMinus.Size = UDim2.new(0,36,0,26); flyMinus.Position = UDim2.new(0.58,0,0,4); flyMinus.Text = "−"; flyMinus.Font = Enum.Font.SourceSansBold; flyMinus.TextSize = 18; flyMinus.BackgroundColor3 = Color3.fromRGB(160,40,40)
    local flyValue = Instance.new("TextBox", flyRow)
    flyValue.Size = UDim2.new(0,84,0,26); flyValue.Position = UDim2.new(0.72,0,0,4); flyValue.BackgroundColor3 = Color3.fromRGB(12,30,80); flyValue.TextColor3 = Color3.new(1,1,1); flyValue.Font = Enum.Font.SourceSansBold; flyValue.TextSize = 14; flyValue.Text = tostring(flySpeed)
    local flyPlus = Instance.new("TextButton", flyRow)
    flyPlus.Size = UDim2.new(0,36,0,26); flyPlus.Position = UDim2.new(0.92,0,0,4); flyPlus.Text = "+"; flyPlus.Font = Enum.Font.SourceSansBold; flyPlus.TextSize = 18; flyPlus.BackgroundColor3 = Color3.fromRGB(40,120,40)

    local function setFlySpeed(v)
        local num = tonumber(v) or flySpeed
        num = math.clamp(math.floor(num), 1, 1000)
        flySpeed = num
        flyValue.Text = tostring(flySpeed)
    end

    flyMinus.MouseButton1Click:Connect(function()
        setFlySpeed(flySpeed - 10)
    end)
    flyPlus.MouseButton1Click:Connect(function()
        setFlySpeed(flySpeed + 10)
    end)
    flyValue.FocusLost:Connect(function(enter)
        setFlySpeed(flyValue.Text)
    end)

    -- Fly control panel (draggable)
    local flyPanel = Instance.new("Frame")
    flyPanel.Name = "FlyPanel"
    flyPanel.Size = UDim2.new(0,180,0,140)
    flyPanel.Position = UDim2.new(0.02, 0, 0.65, 0)
    flyPanel.BackgroundColor3 = Color3.fromRGB(12, 40, 90)
    flyPanel.Active = true
    flyPanel.Draggable = true
    flyPanel.Parent = screenGui

    local fpTitle = Instance.new("TextLabel", flyPanel)
    fpTitle.Size = UDim2.new(1,0,0,26)
    fpTitle.Position = UDim2.new(0,0,0,0)
    fpTitle.BackgroundColor3 = Color3.fromRGB(6, 90, 170)
    fpTitle.Text = "Fly Control"
    fpTitle.Font = Enum.Font.GothamBold
    fpTitle.TextSize = 14
    fpTitle.TextColor3 = Color3.new(1,1,1)

    local fpToggle = Instance.new("TextButton", flyPanel)
    fpToggle.Size = UDim2.new(0.9,0,0,28)
    fpToggle.Position = UDim2.new(0.05,0,0,34)
    fpToggle.Text = "Toggle Fly"
    fpToggle.Font = Enum.Font.SourceSansBold
    fpToggle.TextSize = 14
    fpToggle.BackgroundColor3 = Color3.fromRGB(40,100,180)
    fpToggle.TextColor3 = Color3.new(1,1,1)

    local upBtn = Instance.new("TextButton", flyPanel)
    upBtn.Size = UDim2.new(0.4,0,0,28)
    upBtn.Position = UDim2.new(0.05,0,0,70)
    upBtn.Text = "Up"
    upBtn.Font = Enum.Font.SourceSansBold
    upBtn.TextSize = 14
    upBtn.BackgroundColor3 = Color3.fromRGB(40,180,100)
    upBtn.TextColor3 = Color3.new(1,1,1)

    local downBtn = Instance.new("TextButton", flyPanel)
    downBtn.Size = UDim2.new(0.4,0,0,28)
    downBtn.Position = UDim2.new(0.55,0,0,70)
    downBtn.Text = "Down"
    downBtn.Font = Enum.Font.SourceSansBold
    downBtn.TextSize = 14
    downBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
    downBtn.TextColor3 = Color3.new(1,1,1)

    local spLbl = Instance.new("TextLabel", flyPanel)
    spLbl.Size = UDim2.new(0.9,0,0,20)
    spLbl.Position = UDim2.new(0.05,0,0,104)
    spLbl.BackgroundTransparency = 1
    spLbl.Text = "Speed: "..tostring(flySpeed)
    spLbl.Font = Enum.Font.SourceSans
    spLbl.TextSize = 14
    spLbl.TextColor3 = Color3.new(1,1,1)

    flyValue.Changed:Connect(function()
        spLbl.Text = "Speed: "..tostring(flySpeed)
    end)

    local upHold = false
    local downHold = false
    local verticalSpeed = 60

    upBtn.MouseButton1Down:Connect(function() upHold = true end)
    upBtn.MouseButton1Up:Connect(function() upHold = false end)
    downBtn.MouseButton1Down:Connect(function() downHold = true end)
    downBtn.MouseButton1Up:Connect(function() downHold = false end)

    local function startFly()
        if flying then return end
        flying = true
        local ch = safeChar()
        local hrp = ch:WaitForChild("HumanoidRootPart")
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.PlatformStand = true end) end

        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
        flyBV.P = 1250
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = hrp

        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
        flyBG.P = 5000
        flyBG.CFrame = hrp.CFrame
        flyBG.Parent = hrp

        flyConn = RunService.Heartbeat:Connect(function()
            if not flying then return end
            local hrp = safeChar():FindFirstChild("HumanoidRootPart")
            local hum = safeChar():FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            local moveDir = hum.MoveDirection
            local vx, vy, vz = 0, 0, 0
            if moveDir.Magnitude > 0 then
                local v = moveDir.Unit * flySpeed
                vx, vy, vz = v.X, v.Y, v.Z
            end
            if upHold then
                vy = verticalSpeed
            elseif downHold then
                vy = -verticalSpeed
            end
            flyBV.Velocity = Vector3.new(vx, vy, vz)
            flyBG.CFrame = hrp.CFrame
        end)
    end

    local function stopFly()
        if not flying then return end
        flying = false
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        if flyBV and flyBV.Parent then flyBV:Destroy() end
        if flyBG and flyBG.Parent then flyBG:Destroy() end
        flyBV, flyBG = nil, nil
        local ch = safeChar()
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.PlatformStand = false end) end
    end

    fpToggle.MouseButton1Click:Connect(function()
        if flying then stopFly() else startFly() end
    end)

    createButton("Fly (Joystick Mode) - Toggle", function()
        if flying then stopFly() else startFly() end
    end)

    -- ============================
    -- ESP (Highlight + NameTag)
    -- ============================
    local espEnabled = false
    local function addNameTag(p)
        if not p.Character then return end
        local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart"); if not head then return end
        if head:FindFirstChild("FattanName") then return end
        local bg = Instance.new("BillboardGui", head)
        bg.Name = "FattanName"; bg.Size = UDim2.new(0,110,0,20); bg.StudsOffset = Vector3.new(0,2.6,0); bg.AlwaysOnTop = true
        local lbl = Instance.new("TextLabel", bg)
        lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
        lbl.Text = p.Name; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14
        lbl.TextColor3 = Color3.new(1,1,1); lbl.TextStrokeTransparency = 0.4; lbl.TextStrokeColor3 = Color3.new(0,0,0)
    end
    local function removeNameTag(p)
        if p.Character then
            local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            if head and head:FindFirstChild("FattanName") then head.FattanName:Destroy() end
            if p.Character:FindFirstChild("FattanESP") then p.Character.FattanESP:Destroy() end
        end
    end
    createButton("ESP Player (Toggle)", function()
        espEnabled = not espEnabled
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if espEnabled then
                    if p.Character and not p.Character:FindFirstChild("FattanESP") then
                        local highlight = Instance.new("Highlight", p.Character); highlight.Name = "FattanESP"
                        highlight.FillColor = Color3.fromRGB(0,255,255); highlight.OutlineColor = Color3.new(0,0,0)
                    end
                    pcall(addNameTag, p)
                else
                    pcall(removeNameTag, p)
                end
            end
        end
    end)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function() task.wait(0.15); if espEnabled then pcall(addNameTag,p) end end)
    end)
    Players.PlayerRemoving:Connect(function(p) pcall(removeNameTag,p) end)

    -- ============================
    -- Player List (Teleport / Freeze / Select for rope)
    -- ============================
    local playerFrame = Instance.new("Frame", mainFrame)
    playerFrame.Size = UDim2.new(1,-12,0,120)
    playerFrame.BackgroundColor3 = Color3.fromRGB(8,28,70)

    local scroll = Instance.new("ScrollingFrame", playerFrame)
    scroll.Size = UDim2.new(1,0,1,0); scroll.CanvasSize = UDim2.new(0,0,0,0); scroll.ScrollBarThickness = 6
    local plLayout = Instance.new("UIListLayout", scroll); plLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local selected = nil
    local function refreshPlayers()
        for _,c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local b = Instance.new("TextButton", scroll)
                b.Size = UDim2.new(1,-8,0,26); b.Position = UDim2.new(0,4,0,0)
                b.BackgroundColor3 = Color3.fromRGB(6,80,150); b.Text = p.Name; b.Font = Enum.Font.SourceSansBold; b.TextSize = 14
                b.AutoButtonColor = true
                b.MouseButton1Click:Connect(function()
                    selected = p.Name
                    local old = b.BackgroundColor3; b.BackgroundColor3 = Color3.fromRGB(120,150,200)
                    task.delay(0.22, function() if b and b.Parent then b.BackgroundColor3 = old end end)
                end)
            end
        end
        scroll.CanvasSize = UDim2.new(0,0,0,plLayout.AbsoluteContentSize.Y)
    end
    Players.PlayerAdded:Connect(refreshPlayers); Players.PlayerRemoving:Connect(refreshPlayers)
    refreshPlayers()

    createButton("Teleport to Selected", function()
        if not selected then return end
        local target = Players:FindFirstChild(selected); if not target then return end
        local tchar = target.Character; if not tchar or not tchar:FindFirstChild("HumanoidRootPart") then return end
        local mychar = safeChar(); local hrp = mychar:WaitForChild("HumanoidRootPart")
        hrp.CFrame = tchar.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
    end)

    -- Freeze selected (10s)
    createButton("Freeze Selected (10s)", function()
        if not selected then return end
        local target = Players:FindFirstChild(selected); if not target then return end
        local tchar = target.Character; if not tchar then return end
        local hrp = tchar:FindFirstChild("HumanoidRootPart"); local hum = tchar:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        local ice = Instance.new("Part", workspace)
        ice.Name = "Fattan_Ice_" .. (target.Name or "unk")
        ice.Size = Vector3.new(6,8,6)
        ice.Anchored = true
        ice.CanCollide = false
        ice.Color = Color3.fromRGB(160,220,255)
        ice.Material = Enum.Material.Ice
        ice.CFrame = hrp.CFrame
        ice.Transparency = 0.15

        local weld = Instance.new("WeldConstraint", ice)
        weld.Part0 = ice; weld.Part1 = hrp

        if hum then
            pcall(function()
                hum.WalkSpeed = 0
                hum.JumpPower = 0
                hum.PlatformStand = true
            end)
        end

        task.delay(10, function()
            pcall(function()
                if ice and ice.Parent then ice:Destroy() end
                if hum and hum.Parent then
                    hum.WalkSpeed = 16
                    hum.JumpPower = 50
                    hum.PlatformStand = false
                end
            end)
        end)
    end)

    -- ============================
    -- Elastic Rope (visual pull) - Toggle
    -- ============================
    local activeRope = {}

    local function cleanRopeForPlayer(player)
        if not player then return end
        local data = activeRope[player]
        if data then
            pcall(function()
                if data.conn then data.conn:Disconnect(); data.conn = nil end
                if data.beam and data.beam.Parent then data.beam:Destroy() end
                if data.att1 and data.att1.Parent then data.att1:Destroy() end
                if data.att2 and data.att2.Parent then data.att2:Destroy() end
                activeRope[player] = nil
            end)
        end
    end

    createButton("Tarik Tali (3D) - Toggle", function()
        if not selected then return end
        local targetPlayer = Players:FindFirstChild(selected)
        if not targetPlayer then return end

        if activeRope[targetPlayer] then
            cleanRopeForPlayer(targetPlayer)
            return
        end

        local tchar = targetPlayer.Character
        local mychar = safeChar()
        if not tchar or not mychar then return end
        local thrp = tchar:FindFirstChild("HumanoidRootPart")
        local myhrp = mychar:FindFirstChild("HumanoidRootPart")
        if not thrp or not myhrp then return end

        if thrp:FindFirstChild("FattanElasticRope_Att2") then return end

        local att1 = Instance.new("Attachment", myhrp)
        att1.Name = "FattanElasticRope_Att1"
        local att2 = Instance.new("Attachment", thrp)
        att2.Name = "FattanElasticRope_Att2"

        local ropeBeam = Instance.new("Beam", myhrp)
        ropeBeam.Name = "FattanElasticRope_Beam"
        ropeBeam.Attachment0 = att1
        ropeBeam.Attachment1 = att2
        ropeBeam.FaceCamera = false
        ropeBeam.Width0 = 0.18
        ropeBeam.Width1 = 0.18
        ropeBeam.Texture = ""
        ropeBeam.TextureMode = Enum.TextureMode.Stretch
        ropeBeam.Segments = 15
        ropeBeam.Transparency = NumberSequence.new(0)
        ropeBeam.Color = ColorSequence.new(Color3.fromRGB(139,69,19))
        ropeBeam.Parent = myhrp

        ropeBeam.CurveSize0 = math.clamp((myhrp.Position - thrp.Position).Magnitude / 30, 0, 1.5)
        ropeBeam.CurveSize1 = ropeBeam.CurveSize0 * 0.6

        local minDistance = 6
        local pulling = true
        local rsConn
        rsConn = RunService.RenderStepped:Connect(function(dt)
            if not pulling then return end
            if not att1.Parent or not att2.Parent or not ropeBeam.Parent then
                if rsConn then rsConn:Disconnect(); rsConn = nil end
                return
            end

            local dist = (att1.WorldPosition - att2.WorldPosition).Magnitude
            local curve = math.clamp(1.5 - (dist/60), 0, 1.5)
            ropeBeam.CurveSize0 = curve
            ropeBeam.CurveSize1 = curve * 0.6

            if thrp.Parent and myhrp.Parent then
                local dir = myhrp.Position - thrp.Position
                local d = dir.Magnitude
                if d > minDistance then
                    local targetPos = myhrp.Position - dir.Unit * minDistance
                    local newCFrame = thrp.CFrame:Lerp(CFrame.new(targetPos, targetPos + thrp.CFrame.LookVector), 0.15)
                    thrp.CFrame = newCFrame
                end
            end
        end)

        activeRope[targetPlayer] = {
            att1 = att1,
            att2 = att2,
            beam = ropeBeam,
            conn = rsConn,
            pulling = true,
            minDistance = minDistance,
        }

        local charRemCon
        charRemCon = targetPlayer.CharacterRemoving:Connect(function()
            cleanRopeForPlayer(targetPlayer)
            if charRemCon then charRemCon:Disconnect(); charRemCon=nil end
        end)
    end)

    createButton("Stop All Ropes", function()
        for pl,_ in pairs(activeRope) do
            cleanRopeForPlayer(pl)
        end
    end)

    -- ============================
    -- Delete Parts (scan, click confirm, restore)
    -- ============================
    local scanning = false
    local original = {}
    local detectors = {}
    local pending = nil

    local confirmGui = Instance.new("ScreenGui", CoreGui)
    confirmGui.Name = "FattanConfirm"; confirmGui.ResetOnSpawn = false; confirmGui.Enabled = false

    local confFrame = Instance.new("Frame", confirmGui)
    confFrame.Size = UDim2.new(0,220,0,110)
    confFrame.Position = UDim2.new(0, 10, 0.5, -55)
    confFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)

    local confLabel = Instance.new("TextLabel", confFrame)
    confLabel.Size = UDim2.new(1,0,0,50); confLabel.BackgroundTransparency = 1
    confLabel.Text = "Hapus part ini?"; confLabel.Font = Enum.Font.GothamBold; confLabel.TextSize = 16; confLabel.TextColor3 = Color3.new(1,1,1)

    local yes = Instance.new("TextButton", confFrame)
    yes.Size = UDim2.new(0.5,0,0,50); yes.Position = UDim2.new(0,0,0.45,0); yes.Text = "Ya"; yes.BackgroundColor3 = Color3.fromRGB(0,150,0)
    local no = Instance.new("TextButton", confFrame)
    no.Size = UDim2.new(0.5,0,0,50); no.Position = UDim2.new(0.5,0,0.45,0); no.Text = "Tidak"; no.BackgroundColor3 = Color3.fromRGB(150,0,0)

    yes.MouseButton1Click:Connect(function()
        if pending and pending.Parent then
            pcall(function() pending:Destroy() end)
            original[pending] = nil
        end
        pending = nil
        confirmGui.Enabled = false
    end)
    no.MouseButton1Click:Connect(function()
        if pending and pending.Parent then
            local d = original[pending]
            if d then
                pcall(function() pending.Color = d.Color; pending.Material = d.Material end)
            end
        end
        pending = nil
        confirmGui.Enabled = false
    end)

    local function startScan()
        scanning = true
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                if not original[v] then
                    original[v] = {Color = v.Color, Material = v.Material}
                end
                pcall(function() v.Color = Color3.fromRGB(255,100,100); v.Material = Enum.Material.Neon end)
                if not v:FindFirstChildOfClass("ClickDetector") then
                    local cd = Instance.new("ClickDetector", v)
                    cd.MaxActivationDistance = 100
                    detectors[v] = cd
                    cd.MouseClick:Connect(function(player)
                        if player == LocalPlayer and scanning and not pending then
                            pending = v
                            pcall(function() v.Color = Color3.fromRGB(255,255,0) end)
                            confirmGui.Enabled = true
                        end
                    end)
                else
                    detectors[v] = v:FindFirstChildOfClass("ClickDetector")
                end
            end
        end
    end

    local function stopScan()
        scanning = false
        for part,data in pairs(original) do
            if part and part.Parent then
                pcall(function() part.Color = data.Color; part.Material = data.Material end)
            end
            local cd = detectors[part]
            if cd and cd.Parent then pcall(function() cd:Destroy() end) end
            detectors[part] = nil
        end
        original = {}
        pending = nil
        confirmGui.Enabled = false
    end

    createButton("Scan Parts (Toggle)", function()
        if not scanning then startScan() else stopScan() end
    end)
    createButton("Delete All Parts", function()
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                pcall(function() v:Destroy() end)
            end
        end
        original = {}
    end)
createButton("Restore Parts", function() stopScan() end)
    
--=========================================================
-- 🔄 Extra Features
--=========================================================
createCategory("Extra")

-- 🚪 Noclip
local noclipEnabled = false
createBtn("🚪 Noclip: OFF", function(btn)
    noclipEnabled = not noclipEnabled
    btn.Text = noclipEnabled and "🚪 Noclip: ON" or "🚪 Noclip: OFF"
end)
game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 💀 Auto Respawn
local autoRespawnEnabled = false
createBtn("💀 Auto Respawn: OFF", function(btn)
    autoRespawnEnabled = not autoRespawnEnabled
    btn.Text = autoRespawnEnabled and "💀 Auto Respawn: ON" or "💀 Auto Respawn: OFF"

    if autoRespawnEnabled then
        player.CharacterAdded:Connect(function(char)
            char:WaitForChild("Humanoid").Died:Connect(function()
                if autoRespawnEnabled then
                    task.wait(2)
                    player:LoadCharacter()
                end
            end)
        end)
    end
end)

-- 🔁 Auto Rejoin
local autoRejoinEnabled = false
createBtn("🔁 Auto Rejoin: OFF", function(btn)
    autoRejoinEnabled = not autoRejoinEnabled
    btn.Text = autoRejoinEnabled and "🔁 Auto Rejoin: ON" or "🔁 Auto Rejoin: OFF"

    if autoRejoinEnabled then
        player.OnTeleport:Connect(function(State)
            if State == Enum.TeleportState.Failed and autoRejoinEnabled then
                task.wait(2)
                game:GetService("TeleportService"):Teleport(game.PlaceId, player)
            end
        end)
    end
end)

    -- ============================
    -- WalkFling (Invisible Block)
    -- ============================
    local flingOn = false
    local flingConn = nil
    local flingPart = nil
    local flingBV = nil

    local function startFlingInvisible()
        if flingOn then return end
        flingOn = true
        local char = safeChar(); local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

        flingPart = Instance.new("Part")
        flingPart.Name = "FattanFlingBlock"
        flingPart.Size = Vector3.new(20, 20, 20)
        flingPart.Transparency = 1
        flingPart.Anchored = false
        flingPart.CanCollide = true
        flingPart.Massless = true
        flingPart.Parent = workspace

        local weld = Instance.new("WeldConstraint", flingPart)
        weld.Part0 = flingPart
        weld.Part1 = hrp

        flingBV = Instance.new("BodyVelocity", flingPart)
        flingBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flingBV.Velocity = Vector3.zero

        flingConn = RunService.Heartbeat:Connect(function()
            if not flingOn or not hrp.Parent or not flingPart.Parent then return end
            local forward = hrp.CFrame.LookVector
            flingBV.Velocity = forward * 160
        end)
    end

    local function stopFlingInvisible()
        flingOn = false
        if flingConn then flingConn:Disconnect(); flingConn = nil end
        if flingBV and flingBV.Parent then pcall(function() flingBV:Destroy() end) end
        if flingPart and flingPart.Parent then pcall(function() flingPart:Destroy() end) end
        flingBV, flingPart = nil, nil
    end

    createButton("WalkFling (Toggle)", function()
        if flingOn then stopFlingInvisible() else startFlingInvisible() end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        if flingOn then task.wait(0.8); pcall(startFlingInvisible) end
    end)

    -- ============================
    -- Run & Jump controls (UI rows)
    -- ============================
    local runVal = 16
    local jumpVal = 50

    local function makeRow(labelText, initial)
        local frame = Instance.new("Frame", mainFrame)
        frame.Size = UDim2.new(1,-12,0,36)
        frame.BackgroundTransparency = 1
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(0.5,0,1,0); lbl.Position = UDim2.new(0,6,0,0)
        lbl.BackgroundTransparency = 1; lbl.Text = labelText; lbl.Font = Enum.Font.SourceSansBold; lbl.TextSize = 14; lbl.TextColor3 = Color3.new(1,1,1)
        local minus = Instance.new("TextButton", frame)
        minus.Size = UDim2.new(0,36,0,28); minus.Position = UDim2.new(0.62,0,0,4); minus.Text = "−"
        minus.Font = Enum.Font.SourceSansBold; minus.TextSize = 18; minus.BackgroundColor3 = Color3.fromRGB(160,40,40)
        local valLbl = Instance.new("TextLabel", frame)
        valLbl.Size = UDim2.new(0,64,0,28); valLbl.Position = UDim2.new(0.73,0,0,4); valLbl.BackgroundColor3 = Color3.fromRGB(12,30,80); valLbl.TextColor3 = Color3.new(1,1,1); valLbl.Font = Enum.Font.SourceSansBold; valLbl.TextSize = 14
        local plus = Instance.new("TextButton", frame)
        plus.Size = UDim2.new(0,36,0,28); plus.Position = UDim2.new(0.92,0,0,4); plus.Text = "+"; plus.Font = Enum.Font.SourceSansBold; plus.TextSize = 18; plus.BackgroundColor3 = Color3.fromRGB(40,120,40)
        valLbl.Text = tostring(initial)
        return frame, minus, valLbl, plus
    end

    local runFrame, runMinus, runLabel, runPlus = makeRow("Run Speed", runVal)
    runMinus.MouseButton1Click:Connect(function()
        runVal = math.max(1, runVal - 1); runLabel.Text = tostring(runVal)
        pcall(function() local hum = safeChar():FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = runVal end end)
    end)
    runPlus.MouseButton1Click:Connect(function()
        runVal = math.min(100, runVal + 1); runLabel.Text = tostring(runVal)
        pcall(function() local hum = safeChar():FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = runVal end end)
    end)
    createButton("Apply Run Speed Now", function() pcall(function() local hum = safeChar():FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = runVal end end) end)

    local jumpFrame, jumpMinus, jumpLabel, jumpPlus = makeRow("Jump Power", jumpVal)
    jumpMinus.MouseButton1Click:Connect(function()
        jumpVal = math.max(1, jumpVal - 1); jumpLabel.Text = tostring(jumpVal)
        pcall(function() local hum = safeChar():FindFirstChildOfClass("Humanoid"); if hum then hum.UseJumpPower = true; hum.JumpPower = jumpVal end end)
    end)
    jumpPlus.MouseButton1Click:Connect(function()
        jumpVal = math.min(100, jumpVal + 1); jumpLabel.Text = tostring(jumpVal)
        pcall(function() local hum = safeChar():FindFirstChildOfClass("Humanoid"); if hum then hum.UseJumpPower = true; hum.JumpPower = jumpVal end end)
    end)
    createButton("Apply Jump Now", function() pcall(function() local hum = safeChar():FindFirstChildOfClass("Humanoid"); if hum then hum.UseJumpPower = true; hum.JumpPower = jumpVal end end) end)

    createButton("Reset Speed & Jump", function()
        runVal = 16; jumpVal = 50; runLabel.Text = tostring(runVal); jumpLabel.Text = tostring(jumpVal)
        pcall(function() local hum = safeChar():FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = runVal; hum.UseJumpPower = true; hum.JumpPower = jumpVal end end)
    end)

    -- ============================
    -- Owner Crown
    -- ============================
    local function createOwnerCrown()
        local char = LocalPlayer.Character
        if not char then return end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not head then return end
        if head:FindFirstChild("FattanOwner") then return end
        local bg = Instance.new("BillboardGui", head); bg.Name = "FattanOwner"; bg.Size = UDim2.new(0,110,0,30); bg.StudsOffset = Vector3.new(0,3,0); bg.AlwaysOnTop = true
        local img = Instance.new("ImageLabel", bg); img.Size = UDim2.new(0,28,0,28); img.Position = UDim2.new(0,4,0,0); img.BackgroundTransparency = 1
        pcall(function() img.Image = logoAsset end)
        local lbl = Instance.new("TextLabel", bg); lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.Text = " OWNER"; lbl.Font = Enum.Font.GothamBlack; lbl.TextColor3 = Color3.fromRGB(255,215,0); lbl.TextScaled = true; lbl.TextStrokeTransparency = 0.2
    end
    if LocalPlayer.Character then pcall(createOwnerCrown) end
    LocalPlayer.CharacterAdded:Connect(function() task.wait(0.7); pcall(createOwnerCrown) end)

    -- ============================
    -- Contact Label
    -- ============================
    local contact = Instance.new("TextLabel", mainFrame)
    contact.Size = UDim2.new(1,-12,0,28); contact.BackgroundTransparency = 1; contact.Position = UDim2.new(0,6,1,-34)
    contact.Text = "Contact: FattanHub v3.0"; contact.Font = Enum.Font.SourceSansBold; contact.TextSize = 12; contact.TextColor3 = Color3.new(0.88,0.88,0.88)

    -- ====================================================
    -- Tambahan dari script pertama: Noclip, Auto-Respawn, Auto-Rejoin, Anti-AFK
    -- ====================================================
    -- Noclip
    local noclipEnabled = false
    createButton("🚪 Noclip: OFF", function(btn)
        noclipEnabled = not noclipEnabled
        btn.Text = noclipEnabled and "🚪 Noclip: ON" or "🚪 Noclip: OFF"
    end)
    RunService.Stepped:Connect(function()
        if noclipEnabled and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end)

    -- Auto Respawn (client-side attempt: tries to call LoadCharacter, but best used on server)
    LocalPlayer.CharacterAdded:Connect(function(char)
        -- In original first script, they tried to reconnect to respawn; we keep a client-side attempt:
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function()
            -- client cannot reliably force respawn on server; we attempt to call LoadCharacter
            pcall(function() LocalPlayer:LoadCharacter() end)
        end)
    end)

    -- Auto Rejoin behavior (best-effort client side)
    LocalPlayer.OnTeleport:Connect(function(State)
        if State == Enum.TeleportState.Failed then
            task.wait(2)
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end
    end)
    -- PlayerRemoving rejoin attempt (client cannot do much but we keep best-effort)
    game.Players.PlayerRemoving:Connect(function(leaver)
        if leaver == LocalPlayer then
            task.wait(2)
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end
    end)

    -- Anti-AFK (VirtualUser)
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end)

    -- Final cleanup note: to remove GUI entirely -> CoreGui:FindFirstChild("FattanHub"):Destroy()
end

-- Run: show login first, then init main on correct password
createLogin(initMain)
