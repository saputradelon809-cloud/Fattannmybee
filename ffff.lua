--========================================================
-- FATTAN HUB - FINAL GOLD UI (All-in-one, compact UI)
-- Password: fattanhubGG
-- Paste to LocalScript in your map (must be allowed to create CoreGui elements)
-- NOTE: Replace logoAsset with your uploaded Roblox decal asset id, e.g. "rbxassetid://1234567890"
--========================================================

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Ganti ini dengan asset logo milikmu
local logoAsset = "rbxassetid://6031068426"

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

-- Helper: safe get character
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ==============================
-- CONFIG & STATE
-- ==============================
local correctPassword = "fattanhubGG"

-- feature state
local flying = false
local flyBV, flyBG, flyConn
local flySpeed = 80
local upHold, downHold = false, false
local verticalSpeed = 60

local espEnabled = false
local flingOn = false
local flingConn, flingPart, flingBV

local scanning = false
local originalParts = {}
local detectors = {}
local pendingPart = nil

local activeRope = {} -- stores ropes per-target
local selectedPlayerName = nil

-- ==============================
-- SAFE HELPERS
-- ==============================
local function safeChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ==============================
-- GUI: compact gold theme (login + main + fly panel + confirm)
-- ==============================
local function createCompactGUIs(onInitMain)
    -- Clear existing
    pcall(function() if CoreGui:FindFirstChild("FattanLogin") then CoreGui.FattanLogin:Destroy() end end)
    pcall(function() if CoreGui:FindFirstChild("FattanLoading") then CoreGui.FattanLoading:Destroy() end end)
    pcall(function() if CoreGui:FindFirstChild("FattanHub") then CoreGui.FattanHub:Destroy() end end)
    pcall(function() if CoreGui:FindFirstChild("FattanConfirm") then CoreGui.FattanConfirm:Destroy() end end)
    pcall(function() if CoreGui:FindFirstChild("FattanFlyPanel") then CoreGui.FattanFlyPanel:Destroy() end end)

    -- LOGIN GUI
    local loginGui = Instance.new("ScreenGui", CoreGui)
    loginGui.Name = "FattanLogin"
    loginGui.ResetOnSpawn = false

    local frame = Instance.new("Frame", loginGui)
    frame.Size = UDim2.new(0, 260, 0, 120)
    frame.Position = UDim2.new(0.5, -130, 0.5, -60)
    frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -12, 0, 30)
    title.Position = UDim2.new(0,6,0,6)
    title.BackgroundTransparency = 1
    title.Text = "🔒 FattanHub"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(212,175,55)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.88, 0, 0, 28)
    box.Position = UDim2.new(0.06, 0, 0, 44)
    box.PlaceholderText = "Masukkan password..."
    box.BackgroundColor3 = Color3.fromRGB(24,24,24)
    box.TextColor3 = Color3.new(1,1,1)
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1, -12, 0, 18)
    status.Position = UDim2.new(0,6,0,76)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.Font = Enum.Font.SourceSans
    status.TextSize = 14
    status.TextColor3 = Color3.fromRGB(200,200,200)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.5, 0, 0, 28)
    btn.Position = UDim2.new(0.25, 0, 0, 92)
    btn.Text = "Login"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(212,175,55)
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local function tryLogin()
        local v = tostring(box.Text or "")
        if v == correctPassword then
            loginGui:Destroy()
            pcall(onInitMain)
        else
            box.Text = ""
            status.Text = "❌ Password salah!"
            task.delay(1.2, function() if status and status.Parent then status.Text = "" end end)
        end
    end
    btn.MouseButton1Click:Connect(tryLogin)
    box.FocusLost:Connect(function(enter) if enter then tryLogin() end end)

    -- Minimal Loading (used by initMain)
    local loadingGui = Instance.new("ScreenGui", CoreGui)
    loadingGui.Name = "FattanLoading"
    loadingGui.ResetOnSpawn = false
    loadingGui.Enabled = false

    local loadFrame = Instance.new("Frame", loadingGui)
    loadFrame.Size = UDim2.new(0,180,0,60)
    loadFrame.Position = UDim2.new(0.5,-90,0.45,-30)
    loadFrame.BackgroundColor3 = Color3.fromRGB(12,12,12)
    Instance.new("UICorner", loadFrame).CornerRadius = UDim.new(0,10)

    local loadLabel = Instance.new("TextLabel", loadFrame)
    loadLabel.Size = UDim2.new(1,0,1,0)
    loadLabel.BackgroundTransparency = 1
    loadLabel.Text = "FATTAN HUB"
    loadLabel.Font = Enum.Font.GothamBold
    loadLabel.TextSize = 22
    loadLabel.TextColor3 = Color3.fromRGB(212,175,55)

    -- Confirm GUI (left-middle) for deleting parts
    local confirmGui = Instance.new("ScreenGui", CoreGui)
    confirmGui.Name = "FattanConfirm"
    confirmGui.ResetOnSpawn = false
    confirmGui.Enabled = false

    local confFrame = Instance.new("Frame", confirmGui)
    confFrame.Size = UDim2.new(0,220,0,110)
    confFrame.Position = UDim2.new(0, 10, 0.5, -55)
    confFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
    Instance.new("UICorner", confFrame).CornerRadius = UDim.new(0,8)

    local confLabel = Instance.new("TextLabel", confFrame)
    confLabel.Size = UDim2.new(1,0,0,50)
    confLabel.BackgroundTransparency = 1
    confLabel.Text = "Hapus part ini?"
    confLabel.Font = Enum.Font.GothamBold
    confLabel.TextSize = 16
    confLabel.TextColor3 = Color3.new(1,1,1)

    local yes = Instance.new("TextButton", confFrame)
    yes.Size = UDim2.new(0.5,0,0,50); yes.Position = UDim2.new(0,0,0.45,0)
    yes.Text = "Ya"; yes.BackgroundColor3 = Color3.fromRGB(0,150,0)
    Instance.new("UICorner", yes).CornerRadius = UDim.new(0,6)

    local no = Instance.new("TextButton", confFrame)
    no.Size = UDim2.new(0.5,0,0,50); no.Position = UDim2.new(0.5,0,0.45,0)
    no.Text = "Tidak"; no.BackgroundColor3 = Color3.fromRGB(150,0,0)
    Instance.new("UICorner", no).CornerRadius = UDim.new(0,6)

    yes.MouseButton1Click:Connect(function()
        if pendingPart and pendingPart.Parent then
            pcall(function() pendingPart:Destroy() end)
            originalParts[pendingPart] = nil
        end
        pendingPart = nil
        confirmGui.Enabled = false
    end)
    no.MouseButton1Click:Connect(function()
        if pendingPart and pendingPart.Parent then
            local d = originalParts[pendingPart]
            if d then
                pcall(function() pendingPart.Color = d.Color; pendingPart.Material = d.Material end)
            end
        end
        pendingPart = nil
        confirmGui.Enabled = false
    end)

    -- return references (if caller wants)
    return {
        loginGui = loginGui,
        loadingGui = loadingGui,
        confirmGui = confirmGui,
    }
end

-- ==============================
-- FEATURE IMPLEMENTATIONS (from original script)
-- ==============================

-- FLY (Joystick Mode)
local function startFly()
    if flying then return end
    flying = true
    local ch = safeChar()
    local hrp = ch:FindFirstChild("HumanoidRootPart") or ch:WaitForChild("HumanoidRootPart")
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.PlatformStand = true end) end

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
    flyBV.P = 1250
    flyBV.Velocity = Vector3.new(0,0,0)
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
        if upHold then vy = verticalSpeed elseif downHold then vy = -verticalSpeed end
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

-- ESP name + highlight
local function addNameTag(p)
    if not p or not p.Character then return end
    local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
    if not head then return end
    if head:FindFirstChild("FattanName") then return end
    local bg = Instance.new("BillboardGui", head)
    bg.Name = "FattanName"
    bg.Size = UDim2.new(0,110,0,20)
    bg.StudsOffset = Vector3.new(0,2.6,0)
    bg.AlwaysOnTop = true
    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.Text = p.Name; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 14
    lbl.TextColor3 = Color3.new(1,1,1); lbl.TextStrokeTransparency = 0.4; lbl.TextStrokeColor3 = Color3.new(0,0,0)
end

local function removeNameTag(p)
    if not p or not p.Character then return end
    local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
    if head and head:FindFirstChild("FattanName") then head.FattanName:Destroy() end
    if p.Character:FindFirstChild("FattanESP") then p.Character.FattanESP:Destroy() end
end

-- WALKFLING (invisible block that follows HRP)
local function startFlingInvisible()
    if flingOn then return end
    flingOn = true
    local char = safeChar()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flingPart = Instance.new("Part")
    flingPart.Name = "FattanFlingBlock"
    flingPart.Size = Vector3.new(20,20,20)
    flingPart.Transparency = 1
    flingPart.Anchored = false
    flingPart.CanCollide = true
    flingPart.Massless = true
    flingPart.Parent = workspace

    local weld = Instance.new("WeldConstraint", flingPart)
    weld.Part0 = flingPart; weld.Part1 = hrp

    flingBV = Instance.new("BodyVelocity", flingPart)
    flingBV.MaxForce = Vector3.new(1e9,1e9,1e9)
    flingBV.Velocity = Vector3.new(0,0,0)

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

-- SCAN / DELETE logic for parts
local function startScan(confirmGui)
    scanning = true
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            if not originalParts[v] then
                originalParts[v] = {Color = v.Color, Material = v.Material}
            end
            pcall(function() v.Color = Color3.fromRGB(255,100,100); v.Material = Enum.Material.Neon end)
            if not v:FindFirstChildOfClass("ClickDetector") then
                local cd = Instance.new("ClickDetector", v)
                cd.MaxActivationDistance = 100
                detectors[v] = cd
                cd.MouseClick:Connect(function(player)
                    if player == LocalPlayer and scanning and not pendingPart then
                        pendingPart = v
                        pcall(function() v.Color = Color3.fromRGB(255,255,0) end)
                        if confirmGui then confirmGui.Enabled = true end
                    end
                end)
            else
                detectors[v] = v:FindFirstChildOfClass("ClickDetector")
            end
        end
    end
end

local function stopScan(confirmGui)
    scanning = false
    for part,data in pairs(originalParts) do
        if part and part.Parent then
            pcall(function() part.Color = data.Color; part.Material = data.Material end)
        end
        local cd = detectors[part]
        if cd and cd.Parent then pcall(function() cd:Destroy() end) end
        detectors[part] = nil
    end
    originalParts = {}
    pendingPart = nil
    if confirmGui then confirmGui.Enabled = false end
end

-- PLAYER LIST helpers (teleport, freeze)
local function teleportToSelected()
    if not selectedPlayerName then return end
    local target = Players:FindFirstChild(selectedPlayerName)
    if not target then return end
    local tchar = target.Character
    if not tchar or not tchar:FindFirstChild("HumanoidRootPart") then return end
    local mychar = safeChar()
    local hrp = mychar:WaitForChild("HumanoidRootPart")
    hrp.CFrame = tchar.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
end

local function freezeSelected()
    if not selectedPlayerName then return end
    local target = Players:FindFirstChild(selectedPlayerName)
    if not target then return end
    local tchar = target.Character
    if not tchar then return end
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
end

-- ROPE (visual elastic pull)
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

local function toggleRopeForSelected()
    if not selectedPlayerName then return end
    local targetPlayer = Players:FindFirstChild(selectedPlayerName)
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

    local att1 = Instance.new("Attachment", myhrp); att1.Name = "FattanElasticRope_Att1"
    local att2 = Instance.new("Attachment", thrp); att2.Name = "FattanElasticRope_Att2"

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
        att1 = att1, att2 = att2, beam = ropeBeam, conn = rsConn, pulling = true, minDistance = minDistance
    }

    local charRemCon
    charRemCon = targetPlayer.CharacterRemoving:Connect(function()
        cleanRopeForPlayer(targetPlayer)
        if charRemCon then charRemCon:Disconnect(); charRemCon=nil end
    end)
end

-- Owner crown (small)
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

-- ensure crown on spawn
if LocalPlayer.Character then pcall(createOwnerCrown) end
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.7); pcall(createOwnerCrown) end)

-- ==============================
-- BUILD & INIT MAIN (wiring GUI to functions)
-- ==============================
local function initMain()
    -- tiny loading animation
    local loadingGui = CoreGui:FindFirstChild("FattanLoading")
    if loadingGui then loadingGui.Enabled = true end
    task.wait(0.8)
    if loadingGui then loadingGui.Enabled = false end

    -- Create main HUD (compact gold) - replicate structure but connect to our functions
    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "FattanHub"

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 180, 0, 140)
    mainFrame.Position = UDim2.new(0.02,0,0.12,0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(14,14,14)
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,10)

    local title = Instance.new("Frame", mainFrame)
    title.Name = "TitleBar"
    title.Size = UDim2.new(1,0,0,32)
    title.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Instance.new("UICorner", title).CornerRadius = UDim.new(0,8)

    local titleLabel = Instance.new("TextLabel", title)
    titleLabel.Size = UDim2.new(1, -56, 1, 0)
    titleLabel.Position = UDim2.new(0, 8, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "FATTAN HUB"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = Color3.fromRGB(212,175,55)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local exitBtn = Instance.new("TextButton", title)
    exitBtn.Size = UDim2.new(0,24,0,20)
    exitBtn.Position = UDim2.new(1, -28, 0, 6)
    exitBtn.Text = "✕"
    exitBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    exitBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0,6)
    exitBtn.MouseButton1Click:Connect(function() pcall(function() screenGui:Destroy() end) end)

    local minBtn = Instance.new("TextButton", title)
    minBtn.Size = UDim2.new(0,24,0,20)
    minBtn.Position = UDim2.new(1, -56, 0, 6)
    minBtn.Text = "▁"
    minBtn.BackgroundColor3 = Color3.fromRGB(212,175,55)
    minBtn.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,6)

    local content = Instance.new("ScrollingFrame", mainFrame)
    content.Name = "Content"
    content.Size = UDim2.new(1, -8, 1, -40)
    content.Position = UDim2.new(0,4,0,36)
    content.BackgroundTransparency = 1
    content.CanvasSize = UDim2.new(0,0,0,0)
    content.ScrollBarThickness = 6
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0,6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function compactButton(txt, cb)
        local b = Instance.new("TextButton", content)
        b.Size = UDim2.new(0.92, 0, 0, 28)
        b.BackgroundColor3 = Color3.fromRGB(212,175,55)
        b.Text = txt
        b.Font = Enum.Font.SourceSansBold
        b.TextSize = 13
        b.TextColor3 = Color3.fromRGB(0,0,0)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        b.MouseButton1Click:Connect(function() pcall(cb) end)
        return b
    end

    -- Player list container (compact)
    local playerFrame = Instance.new("Frame", content)
    playerFrame.Size = UDim2.new(1,0,0,120)
    playerFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
    Instance.new("UICorner", playerFrame).CornerRadius = UDim.new(0,6)
    local scroll = Instance.new("ScrollingFrame", playerFrame)
    scroll.Size = UDim2.new(1,0,1,0); scroll.CanvasSize = UDim2.new(0,0,0,0); scroll.ScrollBarThickness = 6
    local plLayout = Instance.new("UIListLayout", scroll); plLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function refreshPlayersInUI()
        for _,c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local b = Instance.new("TextButton", scroll)
                b.Size = UDim2.new(1,-8,0,26); b.Position = UDim2.new(0,4,0,0)
                b.BackgroundColor3 = Color3.fromRGB(40,40,40); b.Text = p.Name; b.Font = Enum.Font.SourceSansBold; b.TextSize = 14
                b.AutoButtonColor = true
                b.MouseButton1Click:Connect(function()
                    selectedPlayerName = p.Name
                    local old = b.BackgroundColor3; b.BackgroundColor3 = Color3.fromRGB(120,150,200)
                    task.delay(0.22, function() if b and b.Parent then b.BackgroundColor3 = old end end)
                end)
            end
        end
        scroll.CanvasSize = UDim2.new(0,0,0,plLayout.AbsoluteContentSize.Y)
    end
    Players.PlayerAdded:Connect(refreshPlayersInUI); Players.PlayerRemoving:Connect(refreshPlayersInUI)
    refreshPlayersInUI()

    -- Buttons wired to functions
    compactButton("Fly Toggle", function() if flying then stopFly() else startFly() end end)
    compactButton("Up (Hold)", function() end).MouseButton1Down:Connect(function() upHold = true end)
    compactButton("Up (Release)", function() end).MouseButton1Click:Connect(function() upHold = false end)
    compactButton("ESP Toggle", function()
        espEnabled = not espEnabled
        for _,p in pairs(Players:GetPlayers()) do
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
    compactButton("Teleport to Selected", teleportToSelected)
    compactButton("Freeze Selected (10s)", freezeSelected)
    compactButton("Tarik Tali (3D) - Toggle", toggleRopeForSelected)
    compactButton("Stop All Ropes", function() for pl,_ in pairs(activeRope) do cleanRopeForPlayer(pl) end end)
    compactButton("WalkFling (Toggle)", function() if flingOn then stopFlingInvisible() else startFlingInvisible() end end)
    compactButton("Scan Parts (Toggle)", function()
        local confirmGui = CoreGui:FindFirstChild("FattanConfirm")
        if not scanning then startScan(confirmGui) else stopScan(confirmGui) end
    end)
    compactButton("Delete All Parts", function()
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                pcall(function() v:Destroy() end)
            end
        end
        originalParts = {}
    end)

    -- Run & Jump rows (compact)
    local runVal = 16
    local jumpVal = 50
    local function makeRow(labelText, initial)
        local frame = Instance.new("Frame", content)
        frame.Size = UDim2.new(1,0,0,36)
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
        plus.Size = UDim2.new(0,36,0,28); plus.Position = UDim2.new(0.92,0,0,4); plus.Text = "+"
        plus.Font = Enum.Font.SourceSansBold; plus.TextSize = 18; plus.BackgroundColor3 = Color3.fromRGB(40,120,40)
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
    compactButton("Apply Run Speed Now", function() pcall(function() local hum = safeChar():FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = runVal end end) end)

    local jumpFrame, jumpMinus, jumpLabel, jumpPlus = makeRow("Jump Power", jumpVal)
    jumpMinus.MouseButton1Click:Connect(function()
        jumpVal = math.max(1, jumpVal - 1); jumpLabel.Text = tostring(jumpVal)
        pcall(function() local hum = safeChar():FindFirstChildOfClass("Humanoid"); if hum then hum.UseJumpPower = true; hum.JumpPower = jumpVal end end)
    end)
    jumpPlus.MouseButton1Click:Connect(function()
        jumpVal = math.min(100, jumpVal + 1); jumpLabel.Text = tostring(jumpVal)
        pcall(function() local hum = safeChar():FindFirstChildOfClass("Humanoid"); if hum then hum.UseJumpPower = true; hum.JumpPower = jumpVal end end)
    end)
    compactButton("Apply Jump Now", function() pcall(function() local hum = safeChar():FindFirstChildOfClass("Humanoid"); if hum then hum.UseJumpPower = true; hum.JumpPower = jumpVal end end) end)
    compactButton("Reset Speed & Jump", function()
        runVal = 16; jumpVal = 50; runLabel.Text = tostring(runVal); jumpLabel.Text = tostring(jumpVal)
        pcall(function() local hum = safeChar():FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = runVal; hum.UseJumpPower = true; hum.JumpPower = jumpVal end end)
    end)

    -- owner crown footer
    local footer = Instance.new("TextLabel", mainFrame)
    footer.Size = UDim2.new(1, -8, 0, 18)
    footer.Position = UDim2.new(0,4,1, -22)
    footer.BackgroundTransparency = 1
    footer.Text = "FattanHub • v3.0"
    footer.Font = Enum.Font.SourceSansSemibold
    footer.TextSize = 12
    footer.TextColor3 = Color3.fromRGB(200,200,200)
    footer.TextXAlignment = Enum.TextXAlignment.Left

    -- Fly panel (compact)
    local flyPanel = Instance.new("Frame", screenGui)
    flyPanel.Name = "FattanFlyPanel"
    flyPanel.Size = UDim2.new(0,150,0,100)
    flyPanel.Position = UDim2.new(0.02,0,0.65,0)
    flyPanel.BackgroundColor3 = Color3.fromRGB(18,18,18)
    Instance.new("UICorner", flyPanel).CornerRadius = UDim.new(0,8)

    local fpTitle = Instance.new("TextLabel", flyPanel)
    fpTitle.Size = UDim2.new(1,0,0,26)
    fpTitle.BackgroundColor3 = Color3.fromRGB(14,14,14)
    fpTitle.Text = "Fly"
    fpTitle.Font = Enum.Font.GothamBold
    fpTitle.TextColor3 = Color3.fromRGB(212,175,55)
    fpTitle.TextSize = 14

    local fpToggleSmall = Instance.new("TextButton", flyPanel)
    fpToggleSmall.Size = UDim2.new(0.9,0,0,26)
    fpToggleSmall.Position = UDim2.new(0.05,0,0,34)
    fpToggleSmall.Text = "Toggle"
    fpToggleSmall.Font = Enum.Font.SourceSansBold
    fpToggleSmall.TextSize = 13
    fpToggleSmall.BackgroundColor3 = Color3.fromRGB(212,175,55)
    fpToggleSmall.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", fpToggleSmall).CornerRadius = UDim.new(0,6)
    fpToggleSmall.MouseButton1Click:Connect(function() if flying then stopFly() else startFly() end end)

    -- Minimize icon
    local miniIcon = Instance.new("ImageButton", screenGui)
    miniIcon.Name = "FattanMiniIcon"
    miniIcon.Size = UDim2.new(0,44,0,44)
    miniIcon.Position = UDim2.new(0.02,0,0.75,0)
    miniIcon.BackgroundColor3 = Color3.fromRGB(8,8,8)
    miniIcon.Image = logoAsset
    miniIcon.Visible = false
    Instance.new("UICorner", miniIcon).CornerRadius = UDim.new(0,22)

    local minimized = false
    local function minimize()
        mainFrame.Visible = false; miniIcon.Visible = true; minimized = true
    end
    local function restore()
        mainFrame.Visible = true; miniIcon.Visible = false; minimized = false
    end
    minBtn.MouseButton1Click:Connect(minimize)
    miniIcon.MouseButton1Click:Connect(restore)

    -- Make draggable helpers
    local function makeDraggable(frame, handle)
        local dragging = false; local dragStart; local startPos
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        local conn = UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        frame.AncestryChanged:Connect(function() if not frame:IsDescendantOf(game) then conn:Disconnect() end end)
    end
    makeDraggable(mainFrame, title)
    makeDraggable(flyPanel, fpTitle)

    -- Ensure fling auto-start on respawn if it was on
    LocalPlayer.CharacterAdded:Connect(function()
        if flingOn then task.wait(0.8); pcall(startFlingInvisible) end
        task.wait(0.7); pcall(createOwnerCrown)
    end)
end

-- ==============================
-- LAUNCH: create GUIs and init main on login
-- ==============================
local refs = createCompactGUIs(initMain)

-- Done — everything in one file.
-- Reminder: gunakan script ini di mapmu sendiri / LocalScript. Jangan disalahgunakan.
