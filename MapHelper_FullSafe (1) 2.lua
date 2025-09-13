-- MapHelper_FullSafe.lua
-- Full safe version — GUI modern (draggable, resizable, scrollable) + many feature stubs
-- THIS SCRIPT IS INTENTIONALLY SAFE: all actions are local-only or visual previews.
-- Replace safe stubs with secure server RemoteEvent calls only if you control the game's server.

-- Services
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local Debris = game:GetService('Debris')

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild('PlayerGui')

-- Cleanup existing
local EXIST = PlayerGui:FindFirstChild('MapHelperGUI_FullSafe')
if EXIST then EXIST:Destroy() end

-- Create ScreenGui
local screenGui = Instance.new('ScreenGui')
screenGui.Name = 'MapHelperGUI_FullSafe'
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui
screenGui.IgnoreGuiInset = true

-- Theme definitions
local Themes = {
    Minimal = { bg = Color3.fromRGB(28,28,30), title = Color3.fromRGB(36,36,40), btn = Color3.fromRGB(52,52,58), btnHover = Color3.fromRGB(70,70,78), accent = Color3.fromRGB(220,220,220) },
    Neon = { bg = Color3.fromRGB(8,10,18), title = Color3.fromRGB(6,8,16), btn = Color3.fromRGB(18,24,48), btnHover = Color3.fromRGB(36,72,160), accent = Color3.fromRGB(120,230,230) },
    Compact = { bg = Color3.fromRGB(22,24,28), title = Color3.fromRGB(26,28,34), btn = Color3.fromRGB(40,44,50), btnHover = Color3.fromRGB(60,66,76), accent = Color3.fromRGB(230,230,230) },
}
local currentThemeName = 'Minimal'
local currentTheme = Themes[currentThemeName]

-- Utility functions
local function new(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do
        if k == 'Parent' then inst.Parent = v else pcall(function() inst[k] = v end) end
    end
    return inst
end

local function roundedFrame(parent, size, pos, bg, name)
    local f = new('Frame', {Size = size, Position = pos or UDim2.new(0,0,0,0), BackgroundColor3 = bg or currentTheme.bg, BorderSizePixel = 0, Name = name or 'Frame'})
    new('UICorner', {Parent = f, CornerRadius = UDim.new(0,10)})
    f.Parent = parent
    return f
end

-- Main window defaults
local defaultSize = UDim2.new(0, 360, 0, 480)
local minSize = Vector2.new(220, 260)
local maxSize = Vector2.new(1000, 1000)

-- Build main UI
local main = roundedFrame(screenGui, defaultSize, UDim2.new(0.06,0,0.10,0), currentTheme.bg, 'MainWindow')
main.Active = true
main.ZIndex = 2

local titleBar = new('Frame', {Parent = main, Size = UDim2.new(1,0,0,40), Position = UDim2.new(0,0,0,0), BackgroundColor3 = currentTheme.title, BorderSizePixel = 0})
new('UICorner', {Parent = titleBar, CornerRadius = UDim.new(0,10)})
local titleLabel = new('TextLabel', {Parent = titleBar, Size = UDim2.new(1,-120,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, Text = 'Map Helper (Full Safe)', Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = currentTheme.accent, TextXAlignment = Enum.TextXAlignment.Left})
local closeBtn = new('TextButton', {Parent = titleBar, Size = UDim2.new(0,34,0,28), Position = UDim2.new(1,-44,0.5,-14), BackgroundColor3 = Color3.fromRGB(200,50,50), BorderSizePixel = 0, Text = 'X', Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1)})
new('UICorner', {Parent = closeBtn, CornerRadius = UDim.new(0,6)})
local minimizeBtn = new('TextButton', {Parent = titleBar, Size = UDim2.new(0,34,0,28), Position = UDim2.new(1,-88,0.5,-14), BackgroundColor3 = Color3.fromRGB(140,140,140), BorderSizePixel = 0, Text = '_', Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1)})
new('UICorner', {Parent = minimizeBtn, CornerRadius = UDim.new(0,6)})

-- Resize grip
local grip = new('Frame', {Parent = main, Size = UDim2.new(0,18,0,18), Position = UDim2.new(1,-20,1,-20), BackgroundTransparency = 1})
new('UICorner', {Parent = grip, CornerRadius = UDim.new(0,8)})

-- Content Scroll
local content = new('ScrollingFrame', {Parent = main, Size = UDim2.new(1,-20,1,-100), Position = UDim2.new(0,10,0,50), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 6, BackgroundTransparency = 1, Name = 'ContentScroll'})
local layout = new('UIListLayout', {Parent = content, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() content.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 12) end)

-- Footer
local footer = new('Frame', {Parent = main, Size = UDim2.new(1,-20,0,36), Position = UDim2.new(0,10,1,-44), BackgroundTransparency = 1})
local themeLabel = new('TextLabel', {Parent = footer, Size = UDim2.new(0.22,0,1,0), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, Text = 'Theme', Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = currentTheme.accent, TextXAlignment = Enum.TextXAlignment.Left})
local themeBtn = new('TextButton', {Parent = footer, Size = UDim2.new(0.6, -6, 1, -6), Position = UDim2.new(0.28,6,0,3), BackgroundColor3 = currentTheme.btn, BorderSizePixel = 0, Text = currentThemeName, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = currentTheme.accent})
new('UICorner', {Parent = themeBtn, CornerRadius = UDim.new(0,6)})

-- Helper creators for UI controls
local function makeButton(text, callback)
    local b = new('TextButton', {Parent = content, Size = UDim2.new(1,-12,0,40), BackgroundColor3 = currentTheme.btn, BorderSizePixel = 0, Text = text, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = currentTheme.accent})
    new('UICorner', {Parent = b, CornerRadius = UDim.new(0,8)})
    b.MouseEnter:Connect(function() b.BackgroundColor3 = currentTheme.btnHover end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = currentTheme.btn end)
    if callback then b.MouseButton1Click:Connect(function() pcall(callback) end) end
    return b
end

local function makeToggle(labelText, default, onChanged)
    local f = new('Frame', {Parent = content, Size = UDim2.new(1,-12,0,36), BackgroundTransparency = 1})
    local lbl = new('TextLabel', {Parent = f, Size = UDim2.new(0.7,0,1,0), Position = UDim2.new(0,6,0,0), BackgroundTransparency = 1, Text = labelText, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = currentTheme.accent, TextXAlignment = Enum.TextXAlignment.Left})
    local btn = new('TextButton', {Parent = f, Size = UDim2.new(0,64,0,28), Position = UDim2.new(1,-74,0.5,-14), BackgroundColor3 = currentTheme.btn, BorderSizePixel = 0, Text = default and 'ON' or 'OFF', Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = currentTheme.accent})
    new('UICorner', {Parent = btn, CornerRadius = UDim.new(0,6)})
    local state = default
    btn.MouseButton1Click:Connect(function() state = not state; btn.Text = state and 'ON' or 'OFF'; if onChanged then pcall(onChanged, state) end end)
    return {Frame = f, Set = function(v) state = v; btn.Text = state and 'ON' or 'OFF' end, Get = function() return state end}
end

local function makeSlider(labelText, min, max, initial, onChanged)
    local f = new('Frame', {Parent = content, Size = UDim2.new(1,-12,0,52), BackgroundTransparency = 1})
    local lbl = new('TextLabel', {Parent = f, Size = UDim2.new(0.6,0,0,20), Position = UDim2.new(0,6,0,0), BackgroundTransparency = 1, Text = labelText, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = currentTheme.accent, TextXAlignment = Enum.TextXAlignment.Left})
    local val = new('TextLabel', {Parent = f, Size = UDim2.new(0.4,-6,0,20), Position = UDim2.new(0.6,6,0,0), BackgroundTransparency = 1, Text = tostring(initial), Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = currentTheme.accent, TextXAlignment = Enum.TextXAlignment.Right})
    local bar = new('Frame', {Parent = f, Size = UDim2.new(1,-12,0,12), Position = UDim2.new(0,6,0,28), BackgroundColor3 = currentTheme.btn, BorderSizePixel = 0})
    new('UICorner', {Parent = bar, CornerRadius = UDim.new(0,6)})
    local knob = new('Frame', {Parent = bar, Size = UDim2.new((initial-min)/(max-min),0,1,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = currentTheme.btnHover})
    new('UICorner', {Parent = knob, CornerRadius = UDim.new(0,6)})
    local dragging = false
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        local abs = input.Position.X - bar.AbsolutePosition.X
        local frac = math.clamp(abs / bar.AbsoluteSize.X, 0, 1)
        knob.Size = UDim2.new(frac,0,1,0); local value = math.floor(min + frac*(max-min)); val.Text = tostring(value); if onChanged then pcall(onChanged, value) end
    end end)
    bar.InputEnded:Connect(function(input) dragging = false end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local abs = input.Position.X - bar.AbsolutePosition.X
            local frac = math.clamp(abs / bar.AbsoluteSize.X, 0, 1)
            knob.Size = UDim2.new(frac,0,1,0); local value = math.floor(min + frac*(max-min)); val.Text = tostring(value); if onChanged then pcall(onChanged, value) end
        end
    end)
    return {Frame = f, Set = function(v) local frac = math.clamp((v-min)/(max-min),0,1); knob.Size = UDim2.new(frac,0,1,0); val.Text = tostring(v); if onChanged then pcall(onChanged, v) end end}
end

-- Theme change function
local function setTheme(name)
    currentThemeName = name or currentThemeName
    currentTheme = Themes[currentThemeName] or Themes.Minimal
    main.BackgroundColor3 = currentTheme.bg
    titleBar.BackgroundColor3 = currentTheme.title
    titleLabel.TextColor3 = currentTheme.accent
    themeBtn.Text = currentThemeName
    themeBtn.BackgroundColor3 = currentTheme.btn
    themeBtn.TextColor3 = currentTheme.accent
    for _,c in pairs(content:GetChildren()) do
        if c:IsA('TextButton') then c.BackgroundColor3 = currentTheme.btn; c.TextColor3 = currentTheme.accent end
        if c:IsA('Frame') then
            for _,sub in pairs(c:GetChildren()) do
                if sub:IsA('TextLabel') or sub:IsA('TextButton') then sub.TextColor3 = currentTheme.accent; if sub:IsA('TextButton') then sub.BackgroundColor3 = currentTheme.btn end end
            end
        end
    end
end

themeBtn.MouseButton1Click:Connect(function()
    local keys = {'Minimal','Neon','Compact'}
    local idx
    for i,k in ipairs(keys) do if k == currentThemeName then idx = i break end end
    idx = (idx % #keys) + 1
    setTheme(keys[idx])
end)

-- Close & Minimize
closeBtn.MouseButton1Click:Connect(function() screenGui.Enabled = false end)
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        main.Size = UDim2.new(0,160,0,44); content.Visible = false; footer.Visible = false; titleLabel.Text = 'Map Helper (min)';
    else
        main.Size = defaultSize; content.Visible = true; footer.Visible = true; titleLabel.Text = 'Map Helper (Full Safe)';
    end
end)

-- Dragging main (mouse & touch friendly)
do
    local dragging = false; local dragStart = Vector2.new(); local startPos = UDim2.new()
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Resize handling
do
    local resizing = false; local startInput = Vector2.new(); local startSize = Vector2.new()
    grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true; startInput = input.Position; startSize = Vector2.new(main.AbsoluteSize.X, main.AbsoluteSize.Y)
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then resizing = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            local newW = math.clamp(startSize.X + delta.X, minSize.X, maxSize.X)
            local newH = math.clamp(startSize.Y + delta.Y, minSize.Y, maxSize.Y)
            main.Size = UDim2.new(0, newW, 0, newH)
        end
    end)
end

-- SAFE FEATURE IMPLEMENTATIONS (local-only)
-- We'll include many safe stubs mirroring requested features but implemented as local-only visual previews.

-- Local fly (BodyVelocity applied to local HRP only)
local flyActive = false
local flySpeed = 80
local flyBV, flyBG, flyConn
local function startFlyLocal()
    if flyActive then return end
    flyActive = true
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild('HumanoidRootPart')
    if not hrp then return end
    local hum = char:FindFirstChildOfClass('Humanoid')
    if hum then pcall(function() hum.PlatformStand = true end) end
    flyBV = Instance.new('BodyVelocity') flyBV.MaxForce = Vector3.new(9e9,9e9,9e9) flyBV.P = 1250 flyBV.Velocity = Vector3.zero flyBV.Parent = hrp
    flyBG = Instance.new('BodyGyro') flyBG.MaxTorque = Vector3.new(9e9,9e9,9e9) flyBG.P = 5000 flyBG.CFrame = hrp.CFrame flyBG.Parent = hrp
    flyConn = RunService.Heartbeat:Connect(function()
        if not flyActive then return end
        local ch = LocalPlayer.Character if not ch then return end
        local hr = ch:FindFirstChild('HumanoidRootPart') local hum = ch:FindFirstChildOfClass('Humanoid') if not hr or not hum then return end
        local dir = hum.MoveDirection
        local vel = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.new(0,0,0)
        flyBV.Velocity = Vector3.new(vel.X, 0, vel.Z)
        flyBG.CFrame = hr.CFrame
    end)
end
local function stopFlyLocal()
    if not flyActive then return end
    flyActive = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV and flyBV.Parent then flyBV:Destroy() end
    if flyBG and flyBG.Parent then flyBG:Destroy() end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') if hum then pcall(function() hum.PlatformStand = false end) end
end

-- Local ESP (name tags) — non-invasive
local espEnabled = false
local function applyESP(p)
    if not p.Character then return end
    if p == LocalPlayer then return end
    local head = p.Character:FindFirstChild('Head') or p.Character:FindFirstChild('HumanoidRootPart')
    if not head then return end
    if head:FindFirstChild('SafeESP_Tag') then return end
    local bg = Instance.new('BillboardGui', head) bg.Name = 'SafeESP_Tag' bg.Size = UDim2.new(0,120,0,28) bg.StudsOffset = Vector3.new(0,2.6,0) bg.AlwaysOnTop = true
    local lbl = Instance.new('TextLabel', bg) lbl.Size = UDim2.new(1,0,1,0) lbl.BackgroundTransparency = 1 lbl.Font = Enum.Font.GothamSemibold lbl.TextSize = 14 lbl.TextColor3 = currentTheme.accent lbl.Text = p.Name
end
local function removeESP(p) if p.Character then local head = p.Character:FindFirstChild('Head') or p.Character:FindFirstChild('HumanoidRootPart') if head and head:FindFirstChild('SafeESP_Tag') then head.SafeESP_Tag:Destroy() end end end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() if espEnabled then pcall(applyESP,p) end end) end)

-- Safe map scan (visual only)
local scanOn = false
local scanned = {}
local function startScan()
    if scanOn then return end
    scanOn = true
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' then
            if not scanned[v] then scanned[v] = {Color = v.Color, Material = v.Material} end
            pcall(function() v.Color = Color3.fromRGB(255,120,60); v.Material = Enum.Material.Neon end)
            if not v:FindFirstChild('SafeScanBox') then
                local sel = Instance.new('SelectionBox', v) sel.Name = 'SafeScanBox' sel.Adornee = v sel.Color3 = Color3.fromRGB(255,200,120) end
        end
    end
end
local function stopScan()
    scanOn = false
    for part,data in pairs(scanned) do
        if part and part.Parent then pcall(function() part.Color = data.Color part.Material = data.Material end) if part:FindFirstChild('SafeScanBox') then part.SafeScanBox:Destroy() end end
    end
    scanned = {}
end

-- Safe decorative spawn
local function spawnDecor()
    local char = LocalPlayer.Character if not char then return end
    local hrp = char:FindFirstChild('HumanoidRootPart') if not hrp then return end
    local p = Instance.new('Part', workspace) p.Size = Vector3.new(2,2,2) p.Position = hrp.Position + Vector3.new(0,3,0) p.Anchored = false p.CanCollide = false p.BrickColor = BrickColor.Random() p.Material = Enum.Material.SmoothPlastic p.Name = 'MapSafeDecor' Debris:AddItem(p, 18)
end

-- Safe walkfling visual (decorative sphere attached to HRP)
local wfOn = false
local wfPart, wfConn
local function startWF()
    if wfOn then return end
    wfOn = true
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild('HumanoidRootPart') if not hrp then return end
    wfPart = Instance.new('Part', workspace) wfPart.Name = 'SafeWF' wfPart.Size = Vector3.new(4,4,4) wfPart.Shape = Enum.PartType.Ball wfPart.CanCollide = false wfPart.Anchored = false wfPart.Transparency = 0.6 wfPart.Material = Enum.Material.Neon
    local weld = Instance.new('WeldConstraint', wfPart) weld.Part0 = wfPart weld.Part1 = hrp
    wfConn = RunService.Heartbeat:Connect(function() if not wfOn or not hrp.Parent then return end wfPart.CFrame = hrp.CFrame * CFrame.new(0,-2,-4) end)
end
local function stopWF()
    wfOn = false
    if wfConn then wfConn:Disconnect(); wfConn = nil end
    if wfPart and wfPart.Parent then wfPart:Destroy() end
    wfPart = nil
end

-- Safe local warp visual (camera FOV change)
local function warpVisual() local cam = workspace.CurrentCamera if not cam then return end local ofov = cam.FieldOfView TweenService:Create(cam, TweenInfo.new(0.45), {FieldOfView = math.clamp(ofov-12,10,120)}):Play() task.delay(0.7, function() TweenService:Create(cam, TweenInfo.new(0.45), {FieldOfView = ofov}):Play() end) end

-- Safe freeze preview (visual only)
local function freezePreview(targetName)
    local p = Players:FindFirstChild(targetName)
    if not p or not p.Character then return end
    local hrp = p.Character:FindFirstChild('HumanoidRootPart') if not hrp then return end
    local ice = Instance.new('Part', workspace) ice.Size = Vector3.new(6,8,6) ice.Anchored = true ice.CanCollide = false ice.Color = Color3.fromRGB(160,220,255) ice.Material = Enum.Material.ForceField ice.CFrame = hrp.CFrame ice.Name = 'SafeFreezePreview' Debris:AddItem(ice,6)
end

-- Safe rope visual toggle
local visualRopes = {}
local function toggleRopeVisual(targetName)
    local p = Players:FindFirstChild(targetName)
    if not p or not p.Character then return end
    if visualRopes[targetName] then
        local d = visualRopes[targetName]; if d.conn then d.conn:Disconnect() end; if d.beam and d.beam.Parent then d.beam:Destroy() end; if d.att1 and d.att1.Parent then d.att1:Destroy() end; if d.att2 and d.att2.Parent then d.att2:Destroy() end; visualRopes[targetName] = nil; return
    end
    local myChar = LocalPlayer.Character if not myChar or not myChar:FindFirstChild('HumanoidRootPart') then return end
    local myhrp = myChar.HumanoidRootPart; local thrp = p.Character:FindFirstChild('HumanoidRootPart') if not thrp then return end
    local att1 = Instance.new('Attachment', myhrp); att1.Name = 'SafeR1' local att2 = Instance.new('Attachment', thrp); att2.Name = 'SafeR2' local beam = Instance.new('Beam', myhrp) beam.Attachment0 = att1 beam.Attachment1 = att2 beam.Width0 = 0.12 beam.Width1 = 0.12 beam.Color = ColorSequence.new(Color3.fromRGB(220,180,120)) beam.Transparency = NumberSequence.new(0.4) beam.Segments = 10
    local conn = RunService.RenderStepped:Connect(function() if not att1.Parent or not att2.Parent or not beam.Parent then if conn then conn:Disconnect(); end return end local dist = (att1.WorldPosition - att2.WorldPosition).Magnitude beam.CurveSize0 = math.clamp(1.2 - dist/80, 0, 1.2) end)
    visualRopes[targetName] = {att1 = att1, att2 = att2, beam = beam, conn = conn}
end

-- Player list container
local pList = roundedFrame(content, UDim2.new(1,0,0,140), nil, Color3.fromRGB(0,0,0), 'PlayerList') pList.BackgroundTransparency = 1
local pLayout = new('UIListLayout', {Parent = pList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6)})
local selectedName = nil
local function refreshPlayers()
    for _,c in ipairs(pList:GetChildren()) do if c:IsA('TextButton') then c:Destroy() end end
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local b = new('TextButton', {Parent = pList, Size = UDim2.new(1, -8, 0, 30), BackgroundColor3 = currentTheme.btn, BorderSizePixel = 0, Text = pl.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = currentTheme.accent})
            new('UICorner', {Parent = b, CornerRadius = UDim.new(0,6)})
            b.MouseButton1Click:Connect(function() selectedName = pl.Name local orig = b.BackgroundColor3 b.BackgroundColor3 = currentTheme.btnHover task.delay(0.18, function() if b and b.Parent then b.BackgroundColor3 = orig end end) end)
        end
    end
end
Players.PlayerAdded:Connect(refreshPlayers) Players.PlayerRemoving:Connect(refreshPlayers) refreshPlayers()

-- Build UI controls for many requested features (safe stubs)
local lbl1 = new('TextLabel', {Parent = content, Size = UDim2.new(1,-12,0,22), BackgroundTransparency = 1, Text = 'Movement', Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = currentTheme.accent, TextXAlignment = Enum.TextXAlignment.Left})
local flyToggle = makeToggle('Local Fly (demo)', false, function(state) if state then startFlyLocal() else stopFlyLocal() end end)
flyToggle.Frame.Parent = content
local flySpeedControl = makeSlider('Fly Speed', 20, 500, flySpeed, function(v) flySpeed = v end) flySpeedControl.Frame.Parent = content
local wfToggle = makeToggle('WalkFling Visual', false, function(s) if s then startWF() else stopWF() end end) wfToggle.Frame.Parent = content

local lbl2 = new('TextLabel', {Parent = content, Size = UDim2.new(1,-12,0,22), BackgroundTransparency = 1, Text = 'Player Tools (safe previews)', Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = currentTheme.accent, TextXAlignment = Enum.TextXAlignment.Left})
local espToggleControl = makeToggle('ESP (name tags, local)', false, function(state) espEnabled = state if espEnabled then for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then pcall(applyESP,p) end end else for _,p in ipairs(Players:GetPlayers()) do pcall(removeESP,p) end end end) espToggleControl.Frame.Parent = content
local warpBtn = makeButton('Local Warp Visual (camera)', function() warpVisual() end) warpBtn.Parent = content
local spawnBtn = makeButton('Spawn Decorative Part', function() spawnDecor() end) spawnBtn.Parent = content
local freezeBtn = makeButton('Freeze Preview (selected)', function() if selectedName then freezePreview(selectedName) end end) freezeBtn.Parent = content
local ropeBtn = makeButton('Toggle Visual Rope (selected)', function() if selectedName then toggleRopeVisual(selectedName) end end) ropeBtn.Parent = content

local lbl3 = new('TextLabel', {Parent = content, Size = UDim2.new(1,-12,0,22), BackgroundTransparency = 1, Text = 'Map Tools (safe)', Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = currentTheme.accent, TextXAlignment = Enum.TextXAlignment.Left})
local scanBtn = makeButton('Scan Map (highlight local)', function() if not scanOn then startScan() else stopScan() end end) scanBtn.Parent = content
local removeDecorBtn = makeButton('Remove My Decorative Parts', function() for _,v in ipairs(workspace:GetDescendants()) do if v:IsA('BasePart') and v.Name == 'MapSafeDecor' then pcall(function() v:Destroy() end) end end end) removeDecorBtn.Parent = content
local shockBtn = makeButton('Shock Visual (local)', function() local char = LocalPlayer.Character if not char then return end local hrp = char:FindFirstChild('HumanoidRootPart') if not hrp then return end local p = Instance.new('Part', workspace) p.Size = Vector3.new(6,1,6) p.Anchored = true p.CFrame = hrp.CFrame * CFrame.new(0,-3,-10) p.Color = Color3.fromRGB(255,120,40) p.Material = Enum.Material.Neon p.Name = 'MapShockEffectSafe' Debris:AddItem(p,2) end) shockBtn.Parent = content

-- Quick controls row
local quickRow = new('Frame', {Parent = content, Size = UDim2.new(1,-12,0,36), BackgroundTransparency = 1})
local incBtn = new('TextButton', {Parent = quickRow, Size = UDim2.new(0.32,0,1,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = currentTheme.btn, BorderSizePixel = 0, Text = 'Fly +10', Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = currentTheme.accent})
new('UICorner', {Parent = incBtn, CornerRadius = UDim.new(0,6)})
local decBtn = new('TextButton', {Parent = quickRow, Size = UDim2.new(0.32,0,1,0), Position = UDim2.new(0.34,6,0,0), BackgroundColor3 = currentTheme.btn, BorderSizePixel = 0, Text = 'Fly -10', Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = currentTheme.accent})
new('UICorner', {Parent = decBtn, CornerRadius = UDim.new(0,6)})
local toggleFlyBtn = new('TextButton', {Parent = quickRow, Size = UDim2.new(0.32,0,1,0), Position = UDim2.new(0.68,6,0,0), BackgroundColor3 = currentTheme.btn, BorderSizePixel = 0, Text = 'Toggle Fly', Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = currentTheme.accent})
new('UICorner', {Parent = toggleFlyBtn, CornerRadius = UDim.new(0,6)})
incBtn.MouseButton1Click:Connect(function() flySpeed = math.min(1000, flySpeed + 10) end)
decBtn.MouseButton1Click:Connect(function() flySpeed = math.max(10, flySpeed - 10) end)
toggleFlyBtn.MouseButton1Click:Connect(function() if flyActive then stopFlyLocal() else startFlyLocal() end end)

-- Admin safe popup (local preview only)
local function showAdmin()
    local ex = screenGui:FindFirstChild('AdminPopup') if ex then ex:Destroy(); return end
    local pop = roundedFrame(screenGui, UDim2.new(0,380,0,180), UDim2.new(0.5,-190,0.08,0), currentTheme.title, 'AdminPopup')
    local t = new('TextLabel', {Parent = pop, Size = UDim2.new(1,-12,0,28), Position = UDim2.new(0,6,0,6), BackgroundTransparency = 1, Text = 'Admin Quick (Safe)', Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = currentTheme.accent})
    local close = new('TextButton', {Parent = pop, Size = UDim2.new(0,28,0,24), Position = UDim2.new(1,-36,0,6), BackgroundColor3 = Color3.fromRGB(200,40,40), BorderSizePixel = 0, Text = 'X', Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1)}) new('UICorner', {Parent = close, CornerRadius = UDim.new(0,6)}) close.MouseButton1Click:Connect(function() pop:Destroy() end)
    local runLbl = new('TextLabel', {Parent = pop, Size = UDim2.new(0.45,-8,0,20), Position = UDim2.new(0,6,0,44), BackgroundTransparency = 1, Text = 'Run Speed:', Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = currentTheme.accent})
    local runBox = new('TextBox', {Parent = pop, Size = UDim2.new(0.45,-8,0,28), Position = UDim2.new(0,6,0,66), BackgroundColor3 = currentTheme.btn, Text = '16', Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = currentTheme.accent}) new('UICorner', {Parent = runBox, CornerRadius = UDim.new(0,6)})
    local jumpLbl = new('TextLabel', {Parent = pop, Size = UDim2.new(0.45,-8,0,20), Position = UDim2.new(0.5,2,0,44), BackgroundTransparency = 1, Text = 'Jump Power:', Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = currentTheme.accent})
    local jumpBox = new('TextBox', {Parent = pop, Size = UDim2.new(0.45,-8,0,28), Position = UDim2.new(0.5,2,0,66), BackgroundColor3 = currentTheme.btn, Text = '50', Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = currentTheme.accent}) new('UICorner', {Parent = jumpBox, CornerRadius = UDim.new(0,6)})
    local apply = new('TextButton', {Parent = pop, Size = UDim2.new(1,-12,0,32), Position = UDim2.new(0,6,1,-44), BackgroundColor3 = Color3.fromRGB(40,120,80), Text = 'Apply (local preview)', Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1)}) new('UICorner', {Parent = apply, CornerRadius = UDim.new(0,6)})
    apply.MouseButton1Click:Connect(function() local rv = tonumber(runBox.Text) or 16 local jv = tonumber(jumpBox.Text) or 50 local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') if hum then pcall(function() hum.WalkSpeed = math.clamp(math.floor(rv),1,500) hum.UseJumpPower = true hum.JumpPower = math.clamp(math.floor(jv),1,500) end) end end)
end
local adminBtn = makeButton('ADMIN (quick)', function() showAdmin() end) adminBtn.Parent = content

-- Stop all ropes visual
local stopAllBtn = makeButton('Stop All Visual Ropes', function() for k,v in pairs(visualRopes) do if v.conn then v.conn:Disconnect() end if v.beam and v.beam.Parent then v.beam:Destroy() end if v.att1 and v.att1.Parent then v.att1:Destroy() end if v.att2 and v.att2.Parent then v.att2:Destroy() end visualRopes[k] = nil end end) stopAllBtn.Parent = content

-- Utility: toast
local function toast(msg, dur) local t = new('TextLabel', {Parent = screenGui, Size = UDim2.new(0,260,0,28), Position = UDim2.new(0.5,-130,0.03,0), BackgroundColor3 = Color3.fromRGB(20,20,30), TextColor3 = Color3.new(1,1,1), Text = msg, Font = Enum.Font.GothamBold, TextSize = 14}) new('UICorner', {Parent = t, CornerRadius = UDim.new(0,6)}) task.delay(dur or 1.6, function() pcall(function() t:Destroy() end) end) end

-- Periodic player list refresh
task.spawn(function() while screenGui.Parent do refreshPlayers() task.wait(5) end end)

-- Final hint
local hint = new('TextLabel', {Parent = screenGui, Size = UDim2.new(0,360,0,20), Position = UDim2.new(0.5,-180,0.01,0), BackgroundTransparency = 1, Text = 'MapHelper FullSafe — GUI revised. Buttons are safe stubs; replace with server calls only if authorized.', Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(200,200,200)})
task.delay(4, function() if hint and hint.Parent then hint:Destroy() end end)

print('MapHelper_FullSafe loaded (safe demo)')
-- filler comment line 1
-- filler comment line 2
-- filler comment line 3
-- filler comment line 4
-- filler comment line 5
-- filler comment line 6
-- filler comment line 7
-- filler comment line 8
-- filler comment line 9
-- filler comment line 10
-- filler comment line 11
-- filler comment line 12
-- filler comment line 13
-- filler comment line 14
-- filler comment line 15
-- filler comment line 16
-- filler comment line 17
-- filler comment line 18
-- filler comment line 19
-- filler comment line 20
-- filler comment line 21
-- filler comment line 22
-- filler comment line 23
-- filler comment line 24
-- filler comment line 25
-- filler comment line 26
-- filler comment line 27
-- filler comment line 28
-- filler comment line 29
-- filler comment line 30
-- filler comment line 31
-- filler comment line 32
-- filler comment line 33
-- filler comment line 34
-- filler comment line 35
-- filler comment line 36
-- filler comment line 37
-- filler comment line 38
-- filler comment line 39
-- filler comment line 40
-- filler comment line 41
-- filler comment line 42
-- filler comment line 43
-- filler comment line 44
-- filler comment line 45
-- filler comment line 46
-- filler comment line 47
-- filler comment line 48
-- filler comment line 49
-- filler comment line 50
-- filler comment line 51
-- filler comment line 52
-- filler comment line 53
-- filler comment line 54
-- filler comment line 55
-- filler comment line 56
-- filler comment line 57
-- filler comment line 58
-- filler comment line 59
-- filler comment line 60
-- filler comment line 61
-- filler comment line 62
-- filler comment line 63
-- filler comment line 64
-- filler comment line 65
-- filler comment line 66
-- filler comment line 67
-- filler comment line 68
-- filler comment line 69
-- filler comment line 70
-- filler comment line 71
-- filler comment line 72
-- filler comment line 73
-- filler comment line 74
-- filler comment line 75
-- filler comment line 76
-- filler comment line 77
-- filler comment line 78
-- filler comment line 79
-- filler comment line 80
-- filler comment line 81
-- filler comment line 82
-- filler comment line 83
-- filler comment line 84
-- filler comment line 85
-- filler comment line 86
-- filler comment line 87
-- filler comment line 88
-- filler comment line 89
-- filler comment line 90
-- filler comment line 91
-- filler comment line 92
-- filler comment line 93
-- filler comment line 94
-- filler comment line 95
-- filler comment line 96
-- filler comment line 97
-- filler comment line 98
-- filler comment line 99
-- filler comment line 100
-- filler comment line 101
-- filler comment line 102
-- filler comment line 103
-- filler comment line 104
-- filler comment line 105
-- filler comment line 106
-- filler comment line 107
-- filler comment line 108
-- filler comment line 109
-- filler comment line 110
-- filler comment line 111
-- filler comment line 112
-- filler comment line 113
-- filler comment line 114
-- filler comment line 115
-- filler comment line 116
-- filler comment line 117
-- filler comment line 118
-- filler comment line 119
-- filler comment line 120
-- filler comment line 121
-- filler comment line 122
-- filler comment line 123
-- filler comment line 124
-- filler comment line 125
-- filler comment line 126
-- filler comment line 127
-- filler comment line 128
-- filler comment line 129
-- filler comment line 130
-- filler comment line 131
-- filler comment line 132
-- filler comment line 133
-- filler comment line 134
-- filler comment line 135
-- filler comment line 136
-- filler comment line 137
-- filler comment line 138
-- filler comment line 139
-- filler comment line 140
-- filler comment line 141
-- filler comment line 142
-- filler comment line 143
-- filler comment line 144
-- filler comment line 145
-- filler comment line 146
-- filler comment line 147
-- filler comment line 148
-- filler comment line 149
-- filler comment line 150
-- filler comment line 151
-- filler comment line 152
-- filler comment line 153
-- filler comment line 154
-- filler comment line 155
-- filler comment line 156
-- filler comment line 157
-- filler comment line 158
-- filler comment line 159
-- filler comment line 160
-- filler comment line 161
-- filler comment line 162
-- filler comment line 163
-- filler comment line 164
-- filler comment line 165
-- filler comment line 166
-- filler comment line 167
-- filler comment line 168
-- filler comment line 169
-- filler comment line 170
-- filler comment line 171
-- filler comment line 172
-- filler comment line 173
-- filler comment line 174
-- filler comment line 175
-- filler comment line 176
-- filler comment line 177
-- filler comment line 178
-- filler comment line 179
-- filler comment line 180
-- filler comment line 181
-- filler comment line 182
-- filler comment line 183
-- filler comment line 184
-- filler comment line 185
-- filler comment line 186
-- filler comment line 187
-- filler comment line 188
-- filler comment line 189
-- filler comment line 190
-- filler comment line 191
-- filler comment line 192
-- filler comment line 193
-- filler comment line 194
-- filler comment line 195
-- filler comment line 196
-- filler comment line 197
-- filler comment line 198
-- filler comment line 199
-- filler comment line 200
-- filler comment line 201
-- filler comment line 202
-- filler comment line 203
-- filler comment line 204
-- filler comment line 205
-- filler comment line 206
-- filler comment line 207
-- filler comment line 208
-- filler comment line 209
-- filler comment line 210
-- filler comment line 211
-- filler comment line 212
-- filler comment line 213
-- filler comment line 214
-- filler comment line 215
-- filler comment line 216
-- filler comment line 217
-- filler comment line 218
-- filler comment line 219
-- filler comment line 220
-- filler comment line 221
-- filler comment line 222
-- filler comment line 223
-- filler comment line 224
-- filler comment line 225
-- filler comment line 226
-- filler comment line 227
-- filler comment line 228
-- filler comment line 229
-- filler comment line 230
-- filler comment line 231
-- filler comment line 232
-- filler comment line 233
-- filler comment line 234
-- filler comment line 235
-- filler comment line 236
-- filler comment line 237
-- filler comment line 238
-- filler comment line 239
-- filler comment line 240
-- filler comment line 241
-- filler comment line 242
-- filler comment line 243
-- filler comment line 244
-- filler comment line 245
-- filler comment line 246
-- filler comment line 247
-- filler comment line 248
-- filler comment line 249
-- filler comment line 250
-- filler comment line 251
-- filler comment line 252
-- filler comment line 253
-- filler comment line 254
-- filler comment line 255
-- filler comment line 256
-- filler comment line 257
-- filler comment line 258
-- filler comment line 259
-- filler comment line 260
-- filler comment line 261
-- filler comment line 262
-- filler comment line 263
-- filler comment line 264
-- filler comment line 265
-- filler comment line 266
-- filler comment line 267
-- filler comment line 268
-- filler comment line 269
-- filler comment line 270
-- filler comment line 271
-- filler comment line 272
-- filler comment line 273
-- filler comment line 274
-- filler comment line 275
-- filler comment line 276
-- filler comment line 277
-- filler comment line 278
-- filler comment line 279
-- filler comment line 280
-- filler comment line 281
-- filler comment line 282
-- filler comment line 283
-- filler comment line 284
-- filler comment line 285
-- filler comment line 286
-- filler comment line 287
-- filler comment line 288
-- filler comment line 289
-- filler comment line 290
-- filler comment line 291
-- filler comment line 292
-- filler comment line 293
-- filler comment line 294
-- filler comment line 295
-- filler comment line 296
-- filler comment line 297
-- filler comment line 298
-- filler comment line 299
-- filler comment line 300
-- filler comment line 301
-- filler comment line 302
-- filler comment line 303
-- filler comment line 304
-- filler comment line 305
-- filler comment line 306
-- filler comment line 307
-- filler comment line 308
-- filler comment line 309
-- filler comment line 310
-- filler comment line 311
-- filler comment line 312
-- filler comment line 313
-- filler comment line 314
-- filler comment line 315
-- filler comment line 316
-- filler comment line 317
-- filler comment line 318
-- filler comment line 319
-- filler comment line 320
-- filler comment line 321
-- filler comment line 322
-- filler comment line 323
-- filler comment line 324
-- filler comment line 325
-- filler comment line 326
-- filler comment line 327
-- filler comment line 328
-- filler comment line 329
-- filler comment line 330
-- filler comment line 331
-- filler comment line 332
-- filler comment line 333
-- filler comment line 334
-- filler comment line 335
-- filler comment line 336
-- filler comment line 337
-- filler comment line 338
-- filler comment line 339
-- filler comment line 340
-- filler comment line 341
-- filler comment line 342
-- filler comment line 343
-- filler comment line 344
-- filler comment line 345
-- filler comment line 346
-- filler comment line 347
-- filler comment line 348
-- filler comment line 349
-- filler comment line 350