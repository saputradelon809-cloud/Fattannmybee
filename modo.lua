-- FATTAN HUB - FINAL ALL IN ONE (password + tap-fly + rope3D + invisible-fling + mobile tweaks)
-- Password: fattanhubGG
-- Paste to executor / LocalScript (must be allowed to create CoreGui elements)

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

-- Helper: safe get character
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ===========
-- Login UI
-- ===========
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

-- ===========
-- Main script (wrapped in function to call after login)
-- ===========
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

    -- ---------- Main GUI (smaller for mobile) ----------
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FattanHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 260, 0, 420) -- slightly bigger but still mobile-friendly
    mainFrame.Position = UDim2.new(0.35,0,0.18,0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(8, 44, 110)
    mainFrame.Active = true
    mainFrame.Draggable = true

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,36)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundColor3 = Color3.fromRGB(4, 110, 200)
    title.Text = "FATTAN HUB"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 0

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

    -- references for features that exist in original big file
    -- We'll implement/replace and keep names similar to your original structure.

    -- ---------- helper get char ----------
    local function safeChar()
        return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    end

    -- keep mouse reference
    local mouse = LocalPlayer:GetMouse()

    -- ============================
    -- Fly (Tap-to-move for mobile & PC; speed adjustable 1..1000)
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

    createButton("Fly (Tap Mode) - Toggle", function()
        if flying then
            -- stop fly
            flying = false
            if flyConn then flyConn:Disconnect(); flyConn = nil end
            if flyBV and flyBV.Parent then flyBV:Destroy() end
            if flyBG and flyBG.Parent then flyBG:Destroy() end
            flyBV, flyBG = nil, nil
            -- restore humanoid
            local ch = safeChar()
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum.PlatformStand = false end) end
        else
            -- start fly
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

            -- helper: get world point from input (supports mouse.Hit and touch)
            local lastTouchPos = nil
            local function getWorldPoint()
                -- prefer lastTouchPos (for mobile touch)
                if lastTouchPos then
                    -- convert screen point to world via Camera
                    local unitRay = Camera:ScreenPointToRay(lastTouchPos.X, lastTouchPos.Y)
                    local ray = Ray.new(unitRay.Origin, unitRay.Direction * 9999)
                    local part, pos = Workspace:FindPartOnRay(ray, safeChar(), false, true)
                    if pos then return pos end
                    return unitRay.Origin + unitRay.Direction * 50
                end
                if mouse and mouse.Hit then
                    return mouse.Hit.p
                end
                return nil
            end

            -- touch handling for mobile: update lastTouchPos when touch begins
            local touchConn
            touchConn = UserInputService.TouchStarted:Connect(function(t)
                lastTouchPos = Vector2.new(t.Position.X, t.Position.Y)
                -- clear after short time so continuous follow not forced unless tapped repeatedly
                task.delay(0.25, function() lastTouchPos = nil end)
            end)

            flyConn = RunService.Heartbeat:Connect(function()
                if not flying then return end
                local hrp = safeChar():FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local target = getWorldPoint()
                if not target then
                    flyBV.Velocity = Vector3.zero
                    return
                end
                local dir = target - hrp.Position
                local dist = dir.Magnitude
                if dist > 1.2 then
                    local v = dir.Unit * flySpeed
                    flyBV.Velocity = Vector3.new(v.X, v.Y, v.Z)
                else
                    flyBV.Velocity = Vector3.zero
                end
                -- orient horizontally toward target (so character faces travel)
                flyBG.CFrame = CFrame.new(hrp.Position, Vector3.new(target.X, hrp.Position.Y, target.Z))
            end)

            -- cleanup on stop: disconnect touchConn when fly stops
            spawn(function()
                while flying do task.wait(0.5) end
                if touchConn then touchConn:Disconnect(); touchConn = nil end
            end)
        end
    end)

    -- ============================
    -- ESP (small name)
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
    -- Player List (teleport/freeze/selected for rope)
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
    -- Pull Selected (Elastic Rope 3D) - added to menu
    -- ============================
    createButton("Tarik Tali (3D)", function()
        if not selected then return end
        local targetPlayer = Players:FindFirstChild(selected)
        if not targetPlayer then return end
        local tchar = targetPlayer.Character
        local mychar = safeChar()
        if not tchar or not mychar then return end
        local thrp = tchar:FindFirstChild("HumanoidRootPart")
        local myhrp = mychar:FindFirstChild("HumanoidRootPart")
        if not thrp or not myhrp then return end

        -- safety: avoid stacking
        if thrp:FindFirstChild("FattanElasticRope_Att2") then return end

        local att1 = Instance.new("Attachment", myhrp)
        att1.Name = "FattanElasticRope_Att1"
        local att2 = Instance.new("Attachment", thrp)
        att2.Name = "FattanElasticRope_Att2"

        local spring = Instance.new("SpringConstraint", myhrp)
        spring.Name = "FattanElasticRope_Spring"
        spring.Attachment0 = att1
        spring.Attachment1 = att2
        spring.FreeLength = (myhrp.Position - thrp.Position).Magnitude
        spring.Stiffness = 220
        spring.Damping = 6
        spring.Parent = myhrp

        local ropeBeam = Instance.new("Beam", myhrp)
        ropeBeam.Name = "FattanElasticRope_Beam"
        ropeBeam.Attachment0 = att1
        ropeBeam.Attachment1 = att2
        ropeBeam.FaceCamera = false
        ropeBeam.Width0 = 0.18
        ropeBeam.Width1 = 0.18
        ropeBeam.Texture = ""
        ropeBeam.TextureMode = Enum.TextureMode.Stretch
        ropeBeam.Segments = 10
        ropeBeam.Transparency = NumberSequence.new(0)
        ropeBeam.Color = ColorSequence.new(Color3.fromRGB(139,69,19))
        ropeBeam.Parent = myhrp

        ropeBeam.CurveSize0 = math.clamp((myhrp.Position - thrp.Position).Magnitude / 30, 0, 1.5)
        ropeBeam.CurveSize1 = ropeBeam.CurveSize0 * 0.6

        local beamConn
        beamConn = RunService.Heartbeat:Connect(function()
            if not att1.Parent or not att2.Parent or not spring.Parent then
                if beamConn then beamConn:Disconnect(); beamConn = nil end
                return
            end
            local dist = (att1.WorldPosition - att2.WorldPosition).Magnitude
            local curve = math.clamp(1.5 - (dist/60), 0, 1.5)
            ropeBeam.CurveSize0 = curve
            ropeBeam.CurveSize1 = curve * 0.6
        end)

        local function clean()
            pcall(function()
                if beamConn then beamConn:Disconnect(); beamConn = nil end
                if ropeBeam and ropeBeam.Parent then ropeBeam:Destroy() end
                if spring and spring.Parent then spring:Destroy() end
                if att1 and att1.Parent then att1:Destroy() end
                if att2 and att2.Parent then att2:Destroy() end
            end)
        end

        task.delay(12, function() clean() end)

        local conRem
        conRem = targetPlayer.CharacterRemoving:Connect(function()
            clean()
            if conRem then conRem:Disconnect(); conRem=nil end
        end)
    end)

    -- ============================
    -- Delete Parts (scan, click confirm, restore) and confirm GUI moved to left-middle
    -- ============================
    local scanning = false
    local original = {}
    local detectors = {}
    local pending = nil

    local confirmGui = Instance.new("ScreenGui", CoreGui)
    confirmGui.Name = "FattanConfirm"; confirmGui.ResetOnSpawn = false; confirmGui.Enabled = false

    local confFrame = Instance.new("Frame", confirmGui)
    confFrame.Size = UDim2.new(0,220,0,110)
    confFrame.Position = UDim2.new(0, 10, 0.5, -55) -- left-middle
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

    -- ============================
    -- WalkFling (Invisible Block, does not spin character)
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

        -- weld so it follows HRP
        local weld = Instance.new("WeldConstraint", flingPart)
        weld.Part0 = flingPart
        weld.Part1 = hrp

        flingBV = Instance.new("BodyVelocity", flingPart)
        flingBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flingBV.Velocity = Vector3.zero

        flingConn = RunService.Heartbeat:Connect(function()
            if not flingOn or not hrp.Parent or not flingPart.Parent then return end
            local forward = hrp.CFrame.LookVector
            flingBV.Velocity = forward * 160 -- adjust power here
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

    -- ensure re-enable on respawn if toggle was on
    LocalPlayer.CharacterAdded:Connect(function()
        if flingOn then task.wait(0.8); pcall(startFlingInvisible) end
    end)

    -- ============================
    -- Run & Jump controls (kept from original, adjusted UI sizing)
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
    -- Owner Crown small
    -- ============================
    local function createOwnerCrown()
        local char = LocalPlayer.Character
        if not char then return end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if not head then return end
        if head:FindFirstChild("FattanOwner") then return end
        local bg = Instance.new("BillboardGui", head); bg.Name = "FattanOwner"; bg.Size = UDim2.new(0,110,0,30); bg.StudsOffset = Vector3.new(0,3,0); bg.AlwaysOnTop = true
        local img = Instance.new("ImageLabel", bg); img.Size = UDim2.new(0,28,0,28); img.Position = UDim2.new(0,4,0,0); img.BackgroundTransparency = 1
        pcall(function() img.Image = "rbxassetid://6031068426" end)
        local lbl = Instance.new("TextLabel", bg); lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.Text = " OWNER"; lbl.Font = Enum.Font.GothamBlack; lbl.TextColor3 = Color3.fromRGB(255,215,0); lbl.TextScaled = true; lbl.TextStrokeTransparency = 0.2
    end
    if LocalPlayer.Character then pcall(createOwnerCrown) end
    LocalPlayer.CharacterAdded:Connect(function() task.wait(0.7); pcall(createOwnerCrown) end)

    -- ============================
    -- Contact
    -- ============================
    local contact = Instance.new("TextLabel", mainFrame)
    contact.Size = UDim2.new(1,-12,0,28); contact.BackgroundTransparency = 1; contact.Position = UDim2.new(0,6,1,-34)
    contact.Text = "Contact: FattanHub v3.0"; contact.Font = Enum.Font.SourceSansBold; contact.TextSize = 12; contact.TextColor3 = Color3.new(0.88,0.88,0.88)

    -- Final cleanup note
    -- If you want to completely remove GUI from CoreGui: CoreGui:FindFirstChild("FattanHub"):Destroy()
end

-- Run: show login first, then init main on correct password
createLogin(initMain)
