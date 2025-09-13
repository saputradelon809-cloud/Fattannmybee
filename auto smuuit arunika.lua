-- Full Map Control GUI (LocalScript)
-- Tampil seperti "Script Loader" (judul + stacked long buttons + X)
-- Gabungan fitur: Fly, ESP, Player List (teleport/freeze/rope), Scan/Delete parts, WalkFling, Run/Jump adjust, Warp, Shiftlock, dll.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Cleanup old GUI
local OLD = playerGui:FindFirstChild("MapControlGUI_v2")
if OLD then OLD:Destroy() end

-- Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MapControlGUI_v2"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Style colors (you bisa adjust)
local bgColor = Color3.fromRGB(20,20,24)
local titleColor = Color3.fromRGB(38,44,58)
local btnColor = Color3.fromRGB(43,50,63)
local btnHover = Color3.fromRGB(60,68,90)
local accent = Color3.fromRGB(255,255,255)

-- MAIN FRAME (mirip screenshot)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 320)
mainFrame.Position = UDim2.new(0.06, 0, 0.22, 0)
mainFrame.BackgroundColor3 = bgColor
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 10)

-- Title bar
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = titleColor
titleBar.BorderSizePixel = 0
local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -44, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Script Loader"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextColor3 = accent
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close button (red X)
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 34, 0, 28)
closeBtn.Position = UDim2.new(1, -40, 0.5, -14)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
closeBtn.BorderSizePixel = 0
local closeCorner = Instance.new("UICorner", closeBtn); closeCorner.CornerRadius = UDim.new(0,6)

closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Make mainFrame draggable (custom)
do
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        mainFrame.Position = newPos
    end
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Utility: create stacked long buttons like screenshot
local function makeLongButton(text, order, parent, callback)
    local marginTop = 52
    local spacing = 42
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 36)
    btn.Position = UDim2.new(0, 12, 0, marginTop + (order * spacing))
    btn.BackgroundColor3 = btnColor
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextSize = 14
    btn.TextColor3 = accent
    btn.Parent = parent
    local corner = Instance.new("UICorner", btn); corner.CornerRadius = UDim.new(0,6)

    -- hover effect
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = btnHover
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = btnColor
    end)

    if callback then
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
    end
    return btn
end

-- ======================================================
-- Start : Feature implementations (adapted from long script)
-- ======================================================

-- Helper: safe char and humanoid root part
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end
local function getHumanoid()
    local ch = LocalPlayer.Character
    if ch then return ch:FindFirstChildOfClass("Humanoid") end
end

-- ---------- Fly (joystick-like) ----------
local flying = false
local flyBV, flyBG, flyConn
local flySpeed = 80
local upHold, downHold = false, false
local verticalSpeed = 60

local function startFly()
    if flying then return end
    flying = true
    local ch = getCharacter()
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
        local char = getCharacter()
        local hrp2 = char:FindFirstChild("HumanoidRootPart")
        local hum2 = char:FindFirstChildOfClass("Humanoid")
        if not hrp2 or not hum2 then return end
        local moveDir = hum2.MoveDirection
        local vx, vy, vz = 0, 0, 0
        if moveDir.Magnitude > 0 then
            local v = moveDir.Unit * flySpeed
            vx, vy, vz = v.X, v.Y, v.Z
        end
        if upHold then vy = verticalSpeed elseif downHold then vy = -verticalSpeed end
        flyBV.Velocity = Vector3.new(vx, vy, vz)
        flyBG.CFrame = hrp2.CFrame
    end)
end

local function stopFly()
    if not flying then return end
    flying = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV and flyBV.Parent then flyBV:Destroy() end
    if flyBG and flyBG.Parent then flyBG:Destroy() end
    flyBV, flyBG = nil, nil
    local ch = getCharacter(); local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.PlatformStand = false end) end
end

-- Up/Down hold detection (keyboard)
UserInputService.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.E then upHold = true end
    if i.KeyCode == Enum.KeyCode.Q then downHold = true end
end)
UserInputService.InputEnded:Connect(function(i, gpe)
    if i.KeyCode == Enum.KeyCode.E then upHold = false end
    if i.KeyCode == Enum.KeyCode.Q then downHold = false end
end)

-- ---------- ESP (simple highlight + name tag) ----------
local espEnabled = false
local function addESPToPlayer(p)
    if not p.Character then return end
    if p == LocalPlayer then return end
    if p.Character:FindFirstChild("MapESP_Tag") then return end
    local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local bg = Instance.new("BillboardGui", head)
    bg.Name = "MapESP_Tag"
    bg.Size = UDim2.new(0,120,0,28)
    bg.AlwaysOnTop = true
    bg.StudsOffset = Vector3.new(0,2.6,0)
    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Text = p.Name
end

local function removeESPFromPlayer(p)
    if p.Character then
        local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
        if head and head:FindFirstChild("MapESP_Tag") then head.MapESP_Tag:Destroy() end
        if p.Character:FindFirstChild("MapHighlight") then p.Character.MapHighlight:Destroy() end
    end
end

-- ---------- Player list UI (for selecting target) ----------
local selectedPlayerName = nil
local function refreshPlayerList()
    -- implemented below as separate UI area
end

-- ---------- Player rope (visual pull) ----------
local activeRopes = {} -- map player -> data

local function cleanRopeForPlayer(target)
    if not target then return end
    local d = activeRopes[target]
    if d then
        pcall(function() if d.conn then d.conn:Disconnect() end end)
        pcall(function() if d.beam and d.beam.Parent then d.beam:Destroy() end end)
        pcall(function() if d.att1 and d.att1.Parent then d.att1:Destroy() end end)
        pcall(function() if d.att2 and d.att2.Parent then d.att2:Destroy() end end)
        activeRopes[target] = nil
    end
end

-- ---------- Scan & Delete parts (client-side UI confirm) ----------
local scanning = false
local scannedOriginals = {} -- part -> {Color, Material}
local scannedDetectors = {}

-- confirm GUI (small)
local confirmGui = Instance.new("ScreenGui")
confirmGui.Name = "MapConfirmGui"
confirmGui.Parent = playerGui
confirmGui.Enabled = false
local confFrame = Instance.new("Frame", confirmGui)
confFrame.Size = UDim2.new(0,220,0,100)
confFrame.Position = UDim2.new(0.02,0,0.5,-50)
confFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
confFrame.BorderSizePixel = 0
local confCorner = Instance.new("UICorner", confFrame); confCorner.CornerRadius = UDim.new(0,8)
local confLabel = Instance.new("TextLabel", confFrame)
confLabel.Size = UDim2.new(1,0,0,48); confLabel.Position = UDim2.new(0,0,0,6)
confLabel.BackgroundTransparency = 1; confLabel.Text = "Hapus part ini?"; confLabel.Font = Enum.Font.GothamBold; confLabel.TextSize = 16; confLabel.TextColor3 = Color3.new(1,1,1)
local yesBtn = Instance.new("TextButton", confFrame)
yesBtn.Size = UDim2.new(0.5, -4, 0, 36); yesBtn.Position = UDim2.new(0, 6, 0, 52)
yesBtn.Text = "Ya"; yesBtn.Font = Enum.Font.Gotham; yesBtn.TextSize = 14; yesBtn.BackgroundColor3 = Color3.fromRGB(0,150,0); yesBtn.TextColor3 = Color3.new(1,1,1)
local noBtn = Instance.new("TextButton", confFrame)
noBtn.Size = UDim2.new(0.5, -4, 0, 36); noBtn.Position = UDim2.new(0.5, 2, 0, 52)
noBtn.Text = "Tidak"; noBtn.Font = Enum.Font.Gotham; noBtn.TextSize = 14; noBtn.BackgroundColor3 = Color3.fromRGB(150,0,0); noBtn.TextColor3 = Color3.new(1,1,1)

local pendingPart = nil
yesBtn.MouseButton1Click:Connect(function()
    if pendingPart and pendingPart.Parent then
        pcall(function() pendingPart:Destroy() end)
    end
    pendingPart = nil
    confirmGui.Enabled = false
end)
noBtn.MouseButton1Click:Connect(function()
    if pendingPart and pendingPart.Parent and scannedOriginals[pendingPart] then
        local d = scannedOriginals[pendingPart]
        pcall(function() pendingPart.Color = d.Color; pendingPart.Material = d.Material end)
    end
    pendingPart = nil
    confirmGui.Enabled = false
end)

-- scan parts: highlight & add ClickDetector for client-side selection
local function startScanParts()
    if scanning then return end
    scanning = true
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            if not scannedOriginals[v] then
                scannedOriginals[v] = {Color = v.Color, Material = v.Material}
            end
            pcall(function() v.Color = Color3.fromRGB(255,100,100); v.Material = Enum.Material.Neon end)
            local cd = v:FindFirstChildOfClass("ClickDetector")
            if not cd then
                cd = Instance.new("ClickDetector", v)
                cd.MaxActivationDistance = 100
                scannedDetectors[v] = cd
                cd.MouseClick:Connect(function(clicker)
                    if clicker == LocalPlayer and scanning and not pendingPart then
                        pendingPart = v
                        pcall(function() v.Color = Color3.fromRGB(255,255,0) end)
                        confirmGui.Enabled = true
                    end
                end)
            else
                scannedDetectors[v] = cd
            end
        end
    end
end
local function stopScanParts()
    scanning = false
    for part, orig in pairs(scannedOriginals) do
        if part and part.Parent then
            pcall(function() part.Color = orig.Color; part.Material = orig.Material end)
        end
        local cd = scannedDetectors[part]
        if cd and cd.Parent then pcall(function() cd:Destroy() end) end
    end
    scannedOriginals = {}
    scannedDetectors = {}
    pendingPart = nil
    confirmGui.Enabled = false
end

-- ---------- WalkFling (invisible block that follows local HRP) ----------
local flingOn = false
local flingPart, flingBV, flingConn
local function startFling()
    if flingOn then return end
    flingOn = true
    local ch = getCharacter()
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    flingPart = Instance.new("Part")
    flingPart.Name = "MapFlingBlock"
    flingPart.Size = Vector3.new(18,18,18)
    flingPart.Transparency = 1
    flingPart.Anchored = false
    flingPart.CanCollide = true
    flingPart.Massless = true
    flingPart.Parent = workspace

    local weld = Instance.new("WeldConstraint", flingPart)
    weld.Part0 = flingPart
    weld.Part1 = hrp

    flingBV = Instance.new("BodyVelocity", flingPart)
    flingBV.MaxForce = Vector3.new(1e9,1e9,1e9)
    flingBV.Velocity = Vector3.zero

    flingConn = RunService.Heartbeat:Connect(function()
        if not flingOn or not hrp.Parent or not flingPart.Parent then return end
        local forward = hrp.CFrame.LookVector
        flingBV.Velocity = forward * 160
    end)
end
local function stopFling()
    flingOn = false
    if flingConn then flingConn:Disconnect(); flingConn = nil end
    pcall(function() if flingBV and flingBV.Parent then flingBV:Destroy() end end)
    pcall(function() if flingPart and flingPart.Parent then flingPart:Destroy() end end)
    flingBV, flingPart = nil, nil
end

-- ---------- Run & Jump controls ----------
local runSpeed = 16
local jumpPower = 50

local function applyRunJump()
    pcall(function()
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = runSpeed
            hum.UseJumpPower = true
            hum.JumpPower = jumpPower
        end
    end)
end

-- ---------- ESP / highlight toggle helper connections ----------
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if espEnabled then
            pcall(addESPToPlayer, p)
        end
    end)
end)

-- ---------- Player list frame (inside GUI) ----------
local listFrame = Instance.new("Frame", mainFrame)
listFrame.Size = UDim2.new(1, -20, 0, 110)
listFrame.Position = UDim2.new(0, 10, 1, -140)
listFrame.BackgroundColor3 = Color3.fromRGB(12,18,30)
listFrame.BorderSizePixel = 0
local listCorner = Instance.new("UICorner", listFrame); listCorner.CornerRadius = UDim.new(0,6)
local scroll = Instance.new("ScrollingFrame", listFrame)
scroll.Size = UDim2.new(1, -8, 1, -8)
scroll.Position = UDim2.new(0, 4, 0, 4)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
local uiList = Instance.new("UIListLayout", scroll); uiList.SortOrder = Enum.SortOrder.LayoutOrder; uiList.Padding = UDim.new(0,6)

local function updatePlayerButtons()
    -- clear
    for _,child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for i,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -8, 0, 28)
            b.BackgroundColor3 = Color3.fromRGB(30,60,100)
            b.Text = p.Name
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            b.TextColor3 = Color3.new(1,1,1)
            b.Parent = scroll
            b.AutoButtonColor = true
            b.MouseButton1Click:Connect(function()
                selectedPlayerName = p.Name
                -- visual feedback
                b.BackgroundColor3 = Color3.fromRGB(70,110,160)
                task.delay(0.25, function() if b and b.Parent then b.BackgroundColor3 = Color3.fromRGB(30,60,100) end end)
            end)
        end
    end
    scroll.CanvasSize = UDim2.new(0,0,0, uiList.AbsoluteContentSize.Y + 8)
end
Players.PlayerAdded:Connect(updatePlayerButtons)
Players.PlayerRemoving:Connect(updatePlayerButtons)
updatePlayerButtons()

-- ======================================================
-- Buttons (the long stacked ones) - order matches screenshot
-- ======================================================

-- ADMIN -> open small admin panel (example: fly speed, run/jump quick controls)
makeLongButton("ADMIN", 0, mainFrame, function()
    -- create a small popup for admin quick controls (toggleable)
    local existing = screenGui:FindFirstChild("AdminPopup")
    if existing then existing:Destroy(); return end
    local pop = Instance.new("Frame", screenGui)
    pop.Name = "AdminPopup"
    pop.Size = UDim2.new(0,260,0,180)
    pop.Position = UDim2.new(0.5, -130, 0.12, 0)
    pop.BackgroundColor3 = Color3.fromRGB(18,18,22)
    local c = Instance.new("UICorner", pop); c.CornerRadius = UDim.new(0,10)

    -- title
    local t = Instance.new("TextLabel", pop)
    t.Size = UDim2.new(1, -12, 0, 28); t.Position = UDim2.new(0,6,0,6)
    t.BackgroundTransparency = 1; t.Text = "Admin Quick"; t.Font = Enum.Font.GothamBold; t.TextSize = 16; t.TextColor3 = Color3.new(1,1,1)

    -- Fly toggle
    local flyBtn = Instance.new("TextButton", pop)
    flyBtn.Size = UDim2.new(0.45, -8, 0, 34); flyBtn.Position = UDim2.new(0,6,0,44)
    flyBtn.Text = flying and "Stop Fly" or "Start Fly"; flyBtn.Font = Enum.Font.Gotham; flyBtn.TextSize = 14; flyBtn.BackgroundColor3 = Color3.fromRGB(40,90,160); flyBtn.TextColor3 = Color3.new(1,1,1)
    local flyCorner = Instance.new("UICorner", flyBtn); flyCorner.CornerRadius = UDim.new(0,6)
    flyBtn.MouseButton1Click:Connect(function()
        if flying then stopFly(); flyBtn.Text = "Start Fly" else startFly(); flyBtn.Text = "Stop Fly" end
    end)

    -- Apply Run/Jump quick controls
    local runBox = Instance.new("TextBox", pop)
    runBox.Size = UDim2.new(0.45, -8, 0, 28); runBox.Position = UDim2.new(0.5, 2, 0, 44)
    runBox.Text = tostring(runSpeed); runBox.Font = Enum.Font.Gotham; runBox.TextSize = 14; runBox.BackgroundColor3 = Color3.fromRGB(12,30,50); runBox.TextColor3 = Color3.new(1,1,1)
    local runLbl = Instance.new("TextLabel", pop); runLbl.Size = UDim2.new(0.45, -8, 0, 20); runLbl.Position = UDim2.new(0,6,0,82); runLbl.BackgroundTransparency = 1; runLbl.Text = "Run Speed"; runLbl.Font = Enum.Font.Gotham; runLbl.TextSize = 12; runLbl.TextColor3 = Color3.new(1,1,1)

    local jumpBox = Instance.new("TextBox", pop)
    jumpBox.Size = UDim2.new(0.45, -8, 0, 28); jumpBox.Position = UDim2.new(0.5, 2, 0, 82)
    jumpBox.Text = tostring(jumpPower); jumpBox.Font = Enum.Font.Gotham; jumpBox.TextSize = 14; jumpBox.BackgroundColor3 = Color3.fromRGB(12,30,50); jumpBox.TextColor3 = Color3.new(1,1,1)
    local jumpLbl = Instance.new("TextLabel", pop); jumpLbl.Size = UDim2.new(0.45, -8, 0, 20); jumpLbl.Position = UDim2.new(0,6,0,118); jumpLbl.BackgroundTransparency = 1; jumpLbl.Text = "Jump Power"; jumpLbl.Font = Enum.Font.Gotham; jumpLbl.TextSize = 12; jumpLbl.TextColor3 = Color3.new(1,1,1)

    local applyBtn = Instance.new("TextButton", pop)
    applyBtn.Size = UDim2.new(1, -12, 0, 30); applyBtn.Position = UDim2.new(0,6,1,-40)
    applyBtn.Text = "Apply"; applyBtn.Font = Enum.Font.Gotham; applyBtn.TextSize = 14; applyBtn.BackgroundColor3 = Color3.fromRGB(40,120,80); applyBtn.TextColor3 = Color3.new(1,1,1)
    local applyCorner = Instance.new("UICorner", applyBtn); applyCorner.CornerRadius = UDim.new(0,6)

    applyBtn.MouseButton1Click:Connect(function()
        local rv = tonumber(runBox.Text) or runSpeed
        local jv = tonumber(jumpBox.Text) or jumpPower
        runSpeed = math.clamp(math.floor(rv), 1, 200)
        jumpPower = math.clamp(math.floor(jv), 1, 200)
        applyRunJump()
    end)
end)

-- WARP -> teleport player to a part named WarpPoint1 (edit names as needed)
makeLongButton("WARP", 1, mainFrame, function()
    local warpName = "WarpPoint1" -- change sesuai nama part di workspace
    local warp = workspace:FindFirstChild(warpName)
    if warp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = warp.CFrame + Vector3.new(0,3,0)
    else
        -- try to find folder "Warps" with first child
        local warpsFolder = workspace:FindFirstChild("Warps")
        if warpsFolder and #warpsFolder:GetChildren() > 0 then
            local first = warpsFolder:GetChildren()[1]
            if first:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = first.CFrame + Vector3.new(0,3,0)
            end
        end
    end
end)

-- FLING -> here repurposed to trigger a map effect: spawn a visible "shock" part in front
makeLongButton("FLING", 2, mainFrame, function()
    local ch = getCharacter()
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local p = Instance.new("Part", workspace)
    p.Size = Vector3.new(6,1,6)
    p.Anchored = true
    p.CFrame = hrp.CFrame * CFrame.new(0, -3, -10)
    p.Color = Color3.fromRGB(255,120,40)
    p.Material = Enum.Material.Neon
    p.Name = "MapShockEffect"
    game:GetService("Debris"):AddItem(p, 3)
end)

-- FLING PART -> spawn a decorative part at player's position (map-safe)
makeLongButton("FLING PART", 3, mainFrame, function()
    local ch = getCharacter()
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local part = Instance.new("Part", workspace)
    part.Size = Vector3.new(3,3,3)
    part.Position = hrp.Position + Vector3.new(0, 3, 0)
    part.Anchored = false
    part.BrickColor = BrickColor.Random()
    part.Name = "MapSpawnedPart"
    part.CanCollide = true
    part.Material = Enum.Material.SmoothPlastic
    -- auto remove after 25s
    game:GetService("Debris"):AddItem(part, 25)
end)

-- SHIFTLOCK -> toggle player's DevEnableMouseLock (client)
makeLongButton("SHIFTLOCK", 4, mainFrame, function()
    LocalPlayer.DevEnableMouseLock = not LocalPlayer.DevEnableMouseLock
    -- feedback
    local cur = LocalPlayer.DevEnableMouseLock and "ON" or "OFF"
    -- small toast
    local t = Instance.new("TextLabel", screenGui)
    t.Size = UDim2.new(0,160,0,28)
    t.Position = UDim2.new(0.5, -80, 0.05, 0)
    t.BackgroundColor3 = Color3.fromRGB(20,20,30)
    t.TextColor3 = Color3.new(1,1,1)
    t.Text = "ShiftLock: "..cur
    t.Font = Enum.Font.GothamBold; t.TextSize = 14
    local tc = Instance.new("UICorner", t); tc.CornerRadius = UDim.new(0,6)
    task.delay(1.6, function() pcall(function() t:Destroy() end) end)
end)

-- ADDITIONAL control buttons below (scan, delete, snap actions)
makeLongButton("Scan Parts (Toggle)", 5, mainFrame, function()
    if not scanning then startScanParts() else stopScanParts() end
end)

makeLongButton("Delete All Map Parts", 6, mainFrame, function()
    -- WARNING: client-side destroy only in workspace; use responsibly
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            pcall(function() v:Destroy() end)
        end
    end
    scannedOriginals = {}
end)

makeLongButton("WalkFling (Toggle)", 7, mainFrame, function()
    if flingOn then stopFling() else startFling() end
end)

-- Small toggle for ESP (placed near bottom-left)
local espToggle = Instance.new("TextButton", mainFrame)
espToggle.Size = UDim2.new(0.44, -8, 0, 28)
espToggle.Position = UDim2.new(0, 12, 1, -42)
espToggle.Text = "ESP: Off"
espToggle.Font = Enum.Font.Gotham
espToggle.TextSize = 13
espToggle.BackgroundColor3 = Color3.fromRGB(45,45,60)
espToggle.TextColor3 = Color3.new(1,1,1)
local espCorner = Instance.new("UICorner", espToggle); espCorner.CornerRadius = UDim.new(0,6)
espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggle.Text = espEnabled and "ESP: On" or "ESP: Off"
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if espEnabled then
                pcall(addESPToPlayer,p)
                if p.Character and not p.Character:FindFirstChild("MapHighlight") then
                    local hl = Instance.new("Highlight", p.Character)
                    hl.Name = "MapHighlight"
                    hl.FillTransparency = 0.6
                    hl.FillColor = Color3.fromRGB(0,255,255)
                    hl.OutlineTransparency = 0.7
                end
            else
                pcall(removeESPFromPlayer,p)
            end
        end
    end
end)

-- Teleport to selected player (uses player list selection)
makeLongButton("Teleport to Selected", 8, mainFrame, function()
    if not selectedPlayerName then return end
    local t = Players:FindFirstChild(selectedPlayerName)
    if not t or not t.Character or not t.Character:FindFirstChild("HumanoidRootPart") then return end
    local mych = getCharacter()
    if mych and mych:FindFirstChild("HumanoidRootPart") then
        mych.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
    end
end)

-- Freeze selected (10s) - affects humanoid properties client-sided for other player's character only if accessible
makeLongButton("Freeze Selected (10s)", 9, mainFrame, function()
    if not selectedPlayerName then return end
    local target = Players:FindFirstChild(selectedPlayerName)
    if not target or not target.Character then return end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local ice = Instance.new("Part", workspace)
    ice.Name = "MapFreeze_"..target.Name
    ice.Size = Vector3.new(6,8,6)
    ice.Anchored = true
    ice.CanCollide = false
    ice.Color = Color3.fromRGB(160,220,255)
    ice.Material = Enum.Material.Ice
    ice.CFrame = hrp.CFrame
    ice.Transparency = 0.15

    local weld = Instance.new("WeldConstraint", ice)
    weld.Part0 = ice; weld.Part1 = hrp

    pcall(function()
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hum.PlatformStand = true
    end)

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

-- Rope toggle (pull visual) for selected
makeLongButton("Tarik Tali (3D) - Toggle", 10, mainFrame, function()
    if not selectedPlayerName then return end
    local targetPlayer = Players:FindFirstChild(selectedPlayerName)
    if not targetPlayer then return end
    if activeRopes[targetPlayer] then
        cleanRopeForPlayer(targetPlayer); return
    end
    local tchar = targetPlayer.Character
    local mychar = getCharacter()
    if not tchar or not mychar then return end
    local thrp = tchar:FindFirstChild("HumanoidRootPart")
    local myhrp = mychar:FindFirstChild("HumanoidRootPart")
    if not thrp or not myhrp then return end
    if thrp:FindFirstChild("MapElasticRope_Att2") then return end

    local att1 = Instance.new("Attachment", myhrp); att1.Name = "MapElasticRope_Att1"
    local att2 = Instance.new("Attachment", thrp); att2.Name = "MapElasticRope_Att2"
    local ropeBeam = Instance.new("Beam", myhrp)
    ropeBeam.Name = "MapElasticRope_Beam"
    ropeBeam.Attachment0 = att1; ropeBeam.Attachment1 = att2
    ropeBeam.FaceCamera = false; ropeBeam.Width0 = 0.18; ropeBeam.Width1 = 0.18
    ropeBeam.Segments = 15; ropeBeam.Transparency = NumberSequence.new(0)
    ropeBeam.Color = ColorSequence.new(Color3.fromRGB(139,69,19))
    ropeBeam.Parent = myhrp

    ropeBeam.CurveSize0 = math.clamp((myhrp.Position - thrp.Position).Magnitude / 30, 0, 1.5)
    ropeBeam.CurveSize1 = ropeBeam.CurveSize0 * 0.6

    local minDistance = 6
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not att1.Parent or not att2.Parent or not ropeBeam.Parent then
            if conn then conn:Disconnect(); conn = nil end
            return
        end
        local dist = (att1.WorldPosition - att2.WorldPosition).Magnitude
        local curve = math.clamp(1.5 - (dist/60), 0, 1.5)
        ropeBeam.CurveSize0 = curve; ropeBeam.CurveSize1 = curve * 0.6
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

    activeRopes[targetPlayer] = {att1 = att1, att2 = att2, beam = ropeBeam, conn = conn}
    -- cleanup on leave
    local leaveCon
    leaveCon = targetPlayer.CharacterRemoving:Connect(function()
        cleanRopeForPlayer(targetPlayer)
        if leaveCon then leaveCon:Disconnect(); leaveCon = nil end
    end)
end)

-- STOP ALL ROPES button
makeLongButton("Stop All Ropes", 11, mainFrame, function()
    for p,_ in pairs(activeRopes) do cleanRopeForPlayer(p) end
end)

-- Toggle Fly Speed quick adjust (small UI)
local flySpeedUp = Instance.new("TextButton", mainFrame)
flySpeedUp.Size = UDim2.new(0.28, -8, 0, 28); flySpeedUp.Position = UDim2.new(0.02, 8, 1, -80)
flySpeedUp.Text = "F+"
flySpeedUp.Font = Enum.Font.Gotham; flySpeedUp.TextSize = 14; flySpeedUp.BackgroundColor3 = Color3.fromRGB(40,80,140)
flySpeedUp.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", flySpeedUp).CornerRadius = UDim.new(0,6)
flySpeedUp.MouseButton1Click:Connect(function() flySpeed = math.min(1000, flySpeed + 10) end)

local flySpeedDown = Instance.new("TextButton", mainFrame)
flySpeedDown.Size = UDim2.new(0.28, -8, 0, 28); flySpeedDown.Position = UDim2.new(0.34, 0, 1, -80)
flySpeedDown.Text = "F-"
flySpeedDown.Font = Enum.Font.Gotham; flySpeedDown.TextSize = 14; flySpeedDown.BackgroundColor3 = Color3.fromRGB(140,40,40)
flySpeedDown.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", flySpeedDown).CornerRadius = UDim.new(0,6)
flySpeedDown.MouseButton1Click:Connect(function() flySpeed = math.max(1, flySpeed - 10) end)

local flyToggleBtn = Instance.new("TextButton", mainFrame)
flyToggleBtn.Size = UDim2.new(0.36, -8, 0, 28); flyToggleBtn.Position = UDim2.new(0.66, 0, 1, -80)
flyToggleBtn.Text = "Fly"
flyToggleBtn.Font = Enum.Font.Gotham; flyToggleBtn.TextSize = 14; flyToggleBtn.BackgroundColor3 = Color3.fromRGB(50,120,80)
Instance.new("UICorner", flyToggleBtn).CornerRadius = UDim.new(0,6)
flyToggleBtn.MouseButton1Click:Connect(function()
    if flying then stopFly(); flyToggleBtn.Text = "Fly" else startFly(); flyToggleBtn.Text = "Stop" end
end)

-- Ensure apply run/jump on respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.7)
    applyRunJump()
    -- re-apply fling if needed
    if flingOn then task.wait(0.6); pcall(startFling) end
end)

-- cleanup on leaving
Players.PlayerRemoving:Connect(function(p)
    activeRopes[p] = nil
end)

-- End of script: optional helpful hint
local hint = Instance.new("TextLabel", screenGui)
hint.Size = UDim2.new(0, 260, 0, 24)
hint.Position = UDim2.new(0.5, -130, 0.01, 0)
hint.BackgroundTransparency = 1
hint.Text = "Map Control GUI - for your map only"
hint.TextColor3 = Color3.fromRGB(200,200,200)
hint.Font = Enum.Font.Gotham; hint.TextSize = 12
task.delay(2.4, function() if hint and hint.Parent then hint:Destroy() end end)

-- Finished
print("MapControlGUI_v2 loaded")
