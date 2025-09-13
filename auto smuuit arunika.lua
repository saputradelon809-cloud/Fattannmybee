-- FATTANHUB - FULL DETAILED (single-file)
-- Features:
--  - Login (optional) (password = "fattanhubGG")
--  - Main GUI: Sidebar tabs (Movement, ESP, Teleport, Tools, Settings)
--  - Movement: WalkSpeed / JumpPower (manual input + +/-), Fly (toggle, up/down), hotkeys
--  - ESP: persistent highlight/name tags, auto-updates on join/respawn
--  - Teleport: player list + input + teleport button
--  - Tools: Scan Parts (highlight), Delete Part (click confirm), Delete All, Restore, Rope (3D visual pull), Freeze selected, WalkFling (invisible block), Stop All Ropes
--  - Confirm modal and Notifications integrated into GUI
--  - Saves some settings to local files if executor supports writefile/readfile (safe)
--  - Comments included for clarity; variables names clear for easy edits

-- ====== CONFIG ======
local CORRECT_PASSWORD = "fattanhubGG"          -- change if needed
local LOGO_ASSET = "rbxassetid://6031068426"    -- change to your decal if you want

-- ====== SERVICES ======
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Fallback for GUI parent (CoreGui preferred; fallback PlayerGui)
local function getGuiParent()
    local ok, cg = pcall(function() return CoreGui end)
    if ok and cg then
        -- test if we can parent to CoreGui
        local worked = pcall(function()
            local t = Instance.new("ScreenGui")
            t.Parent = cg
            t:Destroy()
        end)
        if worked then return cg end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local GUI_PARENT = getGuiParent()

-- Executor capabilities
local HAS_WRITEFILE = type(writefile) == "function"
local HAS_READFILE = type(readfile) == "function"
local SETTINGS_PATH = "FattanHub_settings.json"

-- Safe save/load
local function saveSettings(tbl)
    if not HAS_WRITEFILE then return end
    pcall(function()
        writefile(SETTINGS_PATH, HttpService:JSONEncode(tbl))
    end)
end
local function loadSettings()
    if not HAS_READFILE then return nil end
    local ok, content = pcall(function() return readfile(SETTINGS_PATH) end)
    if not ok or not content then return nil end
    local ok2, tbl = pcall(function() return HttpService:JSONDecode(content) end)
    if ok2 and type(tbl) == "table" then return tbl end
    return nil
end

-- Default settings
local SETTINGS = {
    walkSpeed = 16,
    jumpPower = 50,
    esp = false,
    flySpeed = 80,
    flingPower = 160,
}

do
    local loaded = loadSettings()
    if loaded then
        for k,v in pairs(loaded) do SETTINGS[k] = v end
    end
end

-- ====== UTIL HELPERS ======
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            pcall(function() obj[k] = v end)
        end
    end
    return obj
end

local function clamp(n, a, b) return math.max(a, math.min(b, n)) end
local function safeChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- Notification helper (small popup on GUI)
local function notify(parent, text, timeSec)
    timeSec = timeSec or 2
    local notif = new("Frame", {Size = UDim2.new(0,300,0,36), BackgroundColor3 = Color3.fromRGB(32,32,36), Parent = parent})
    local corner = new("UICorner", {Parent = notif, CornerRadius = UDim.new(0,8)})
    notif.Position = UDim2.new(0.5, -150, 0.02, 0)
    local lbl = new("TextLabel", {Parent = notif, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = text, Font = Enum.Font.Gotham, TextColor3 = Color3.new(1,1,1), TextSize = 15})
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.Position = UDim2.new(0.5, 0, 0.02, 0)
    notif.ClipsDescendants = true
    notif.ZIndex = 50
    -- fade in/out
    notif.BackgroundTransparency = 1
    lbl.TextTransparency = 1
    TweenService:Create(notif, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
    TweenService:Create(lbl, TweenInfo.new(0.18), {TextTransparency = 0}):Play()
    delay(timeSec, function()
        TweenService:Create(notif, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
        TweenService:Create(lbl, TweenInfo.new(0.18), {TextTransparency = 1}):Play()
        delay(0.25, function() pcall(function() notif:Destroy() end) end)
    end)
end

-- ====== REMOVE OLD GUI (safe) ======
pcall(function()
    local prev = GUI_PARENT:FindFirstChild("FattanHub_MainGui")
    if prev then prev:Destroy() end
end)

-- ====== BUILD GUI ======
local ScreenGui = new("ScreenGui", {Name = "FattanHub_MainGui", ResetOnSpawn = false, Parent = GUI_PARENT})

-- Main container
local MainFrame = new("Frame", {Parent = ScreenGui, Name = "MainFrame", Size = UDim2.new(0, 620, 0, 460), Position = UDim2.new(0.5, -310, 0.5, -230), BackgroundColor3 = Color3.fromRGB(18,18,20), BorderSizePixel = 0})
new("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 12)})
new("UIStroke", {Parent = MainFrame, Thickness = 1, Transparency = 0.8})

-- Header
local Header = new("Frame", {Parent = MainFrame, Size = UDim2.new(1,0,0,44), BackgroundColor3 = Color3.fromRGB(5, 80, 160)})
new("UICorner", {Parent = Header, CornerRadius = UDim.new(0, 10)})
local Title = new("TextLabel", {Parent = Header, Size = UDim2.new(0.6,0,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, Text = "FattanHub", Font = Enum.Font.GothamBlack, TextSize = 20, TextColor3 = Color3.fromRGB(245,245,245), TextXAlignment = Enum.TextXAlignment.Left})
local Ver = new("TextLabel", {Parent = Header, Size = UDim2.new(0.4,-24,1,0), Position = UDim2.new(0.6,12,0,0), BackgroundTransparency = 1, Text = "v3.0", Font = Enum.Font.SourceSansSemibold, TextSize = 14, TextColor3 = Color3.fromRGB(230,230,230), TextXAlignment = Enum.TextXAlignment.Right})
-- Minimize/Close
local CloseBtn = new("TextButton", {Parent = Header, Size = UDim2.new(0,38,0,26), Position = UDim2.new(1,-46,0,8), Text = "X", Font = Enum.Font.GothamBold, TextSize = 16, BackgroundColor3 = Color3.fromRGB(200,50,50), TextColor3 = Color3.new(1,1,1)})
new("UICorner", {Parent = CloseBtn, CornerRadius = UDim.new(0,6)})
local MinBtn = new("TextButton", {Parent = Header, Size = UDim2.new(0,38,0,26), Position = UDim2.new(1,-92,0,8), Text = "—", Font = Enum.Font.GothamBold, TextSize = 16, BackgroundColor3 = Color3.fromRGB(200,180,60), TextColor3 = Color3.new(1,1,1)})
new("UICorner", {Parent = MinBtn, CornerRadius = UDim.new(0,6)})

-- Minimize icon (small)
local MiniIcon = new("ImageButton", {Parent = ScreenGui, Name = "MiniIcon", Size = UDim2.new(0,56,0,56), Position = UDim2.new(0.02,0,0.78,0), BackgroundColor3 = Color3.fromRGB(8,44,110), AutoButtonColor = true, Visible = false, Image = LOGO_ASSET})
new("UICorner", {Parent = MiniIcon, CornerRadius = UDim.new(1,0)})

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniIcon.Visible = true
end)
MiniIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MiniIcon.Visible = false
end)
CloseBtn.MouseButton1Click:Connect(function() pcall(function() ScreenGui:Destroy() end) end)

-- Layout: sidebar + content area
local SideBar = new("Frame", {Parent = MainFrame, Size = UDim2.new(0,160,1,-64), Position = UDim2.new(0,12,0,52), BackgroundTransparency = 1})
local Content = new("Frame", {Parent = MainFrame, Size = UDim2.new(1,-196,1,-64), Position = UDim2.new(0,188,0,52), BackgroundTransparency = 1})

new("UIListLayout", {Parent = SideBar, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})
new("UIPadding", {Parent = SideBar, PaddingTop = UDim.new(0,6), PaddingLeft = UDim.new(0,6)})

-- Create sidebar button factory
local function makeSideBtn(text)
    local b = new("TextButton", {Parent = SideBar, Size = UDim2.new(1,-12,0,36), BackgroundColor3 = Color3.fromRGB(26,30,36), Text = text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextColor3 = Color3.fromRGB(230,230,230)})
    new("UICorner", {Parent = b, CornerRadius = UDim.new(0,8)})
    return b
end

-- Tabs
local tabs = {}
local pages = {}

local tabNames = {"Movement","ESP","Teleport","Tools","Settings"}
for i,name in ipairs(tabNames) do
    local btn = makeSideBtn(name)
    local page = new("Frame", {Parent = Content, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false})
    pages[name] = page
    tabs[name] = btn
    btn.MouseButton1Click:Connect(function()
        for k,v in pairs(pages) do v.Visible = false end
        page.Visible = true
    end)
end
pages["Movement"].Visible = true

-- ===== Movement Page =====
local M = pages["Movement"]
new("UIPadding", {Parent = M, PaddingTop = UDim.new(0,6), PaddingLeft = UDim.new(0,6)})
local mvLayout = new("UIListLayout", {Parent = M, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})

-- WalkSpeed row
local walkFrame = new("Frame", {Parent = M, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
local walkLbl = new("TextLabel", {Parent = walkFrame, Size = UDim2.new(0.5,0,1,0), BackgroundTransparency = 1, Text = "Walk Speed", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1)})
local walkMinus = new("TextButton", {Parent = walkFrame, Size = UDim2.new(0,36,0,28), Position = UDim2.new(0.62,0,0,4), Text = "−", Font = Enum.Font.GothamBold, TextSize = 18, BackgroundColor3 = Color3.fromRGB(160,40,40)})
local walkInput = new("TextBox", {Parent = walkFrame, Size = UDim2.new(0,84,0,28), Position = UDim2.new(0.73,0,0,4), BackgroundColor3 = Color3.fromRGB(12,30,60), TextColor3 = Color3.new(1,1,1), Text = tostring(SETTINGS.walkSpeed), Font = Enum.Font.GothamSemibold, TextSize = 14})
local walkPlus = new("TextButton", {Parent = walkFrame, Size = UDim2.new(0,36,0,28), Position = UDim2.new(0.92,0,0,4), Text = "+", Font = Enum.Font.GothamBold, TextSize = 18, BackgroundColor3 = Color3.fromRGB(40,120,40)})
new("UICorner", {Parent = walkMinus, CornerRadius = UDim.new(0,6)})
new("UICorner", {Parent = walkPlus, CornerRadius = UDim.new(0,6)})
new("UICorner", {Parent = walkInput, CornerRadius = UDim.new(0,6)})

local function setWalkSpeed(val)
    val = tonumber(val)
    if not val then return end
    val = clamp(math.floor(val),1,1000)
    SETTINGS.walkSpeed = val
    walkInput.Text = tostring(val)
    local ch = LocalPlayer.Character
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.WalkSpeed = val end) end
    end
    saveSettings(SETTINGS)
    notify(MainFrame, "WalkSpeed set to "..tostring(val), 1.6)
end

walkMinus.MouseButton1Click:Connect(function() setWalkSpeed(SETTINGS.walkSpeed - 1) end)
walkPlus.MouseButton1Click:Connect(function() setWalkSpeed(SETTINGS.walkSpeed + 1) end)
walkInput.FocusLost:Connect(function(enter) if enter then setWalkSpeed(walkInput.Text) end end)

-- Jump row
local jumpFrame = new("Frame", {Parent = M, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
local jumpLbl = new("TextLabel", {Parent = jumpFrame, Size = UDim2.new(0.5,0,1,0), BackgroundTransparency = 1, Text = "Jump Power", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1,1,1)})
local jumpMinus = new("TextButton", {Parent = jumpFrame, Size = UDim2.new(0,36,0,28), Position = UDim2.new(0.62,0,0,4), Text = "−", Font = Enum.Font.GothamBold, TextSize = 18, BackgroundColor3 = Color3.fromRGB(160,40,40)})
local jumpInput = new("TextBox", {Parent = jumpFrame, Size = UDim2.new(0,84,0,28), Position = UDim2.new(0.73,0,0,4), BackgroundColor3 = Color3.fromRGB(12,30,60), TextColor3 = Color3.new(1,1,1), Text = tostring(SETTINGS.jumpPower), Font = Enum.Font.GothamSemibold, TextSize = 14})
local jumpPlus = new("TextButton", {Parent = jumpFrame, Size = UDim2.new(0,36,0,28), Position = UDim2.new(0.92,0,0,4), Text = "+", Font = Enum.Font.GothamBold, TextSize = 18, BackgroundColor3 = Color3.fromRGB(40,120,40)})
new("UICorner", {Parent = jumpMinus, CornerRadius = UDim.new(0,6)})
new("UICorner", {Parent = jumpPlus, CornerRadius = UDim.new(0,6)})
new("UICorner", {Parent = jumpInput, CornerRadius = UDim.new(0,6)})

local function setJumpPower(val)
    val = tonumber(val)
    if not val then return end
    val = clamp(math.floor(val),1,500)
    SETTINGS.jumpPower = val
    jumpInput.Text = tostring(val)
    local ch = LocalPlayer.Character
    if ch then
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.UseJumpPower = true; hum.JumpPower = val end) end
    end
    saveSettings(SETTINGS)
    notify(MainFrame, "JumpPower set to "..tostring(val), 1.6)
end

jumpMinus.MouseButton1Click:Connect(function() setJumpPower(SETTINGS.jumpPower - 1) end)
jumpPlus.MouseButton1Click:Connect(function() setJumpPower(SETTINGS.jumpPower + 1) end)
jumpInput.FocusLost:Connect(function(enter) if enter then setJumpPower(jumpInput.Text) end end)

-- Fly controls (toggle + up/down keys E/Q)
local flyToggleBtn = new("TextButton", {Parent = M, Size = UDim2.new(0, 200, 0, 34), Text = "Toggle Fly", BackgroundColor3 = Color3.fromRGB(40,110,200), Font = Enum.Font.GothamSemibold})
new("UICorner", {Parent = flyToggleBtn, CornerRadius = UDim.new(0,8)})
local flyActive = false
local flyBV, flyBG, flyConn = nil, nil, nil
local flyUp, flyDown = false, false

flyToggleBtn.MouseButton1Click:Connect(function()
    if flyActive then
        flyActive = false
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        if flyBV then flyBV:Destroy(); flyBV=nil end
        if flyBG then flyBG:Destroy(); flyBG=nil end
        notify(MainFrame, "Fly disabled", 1.2)
    else
        local ch = safeChar()
        local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then notify(MainFrame, "No character found", 1.2); return end
        flyActive = true
        flyBV = new("BodyVelocity", {Parent = hrp, MaxForce = Vector3.new(9e9,9e9,9e9), P = 1250, Velocity = Vector3.zero})
        flyBG = new("BodyGyro", {Parent = hrp, MaxTorque = Vector3.new(9e9,9e9,9e9), P = 5000, CFrame = hrp.CFrame})
        flyConn = RunService.Heartbeat:Connect(function()
            if not flyActive then return end
            local ch = safeChar()
            local hrp2 = ch:FindFirstChild("HumanoidRootPart")
            local hum = ch:FindFirstChildOfClass("Humanoid")
            if not hrp2 or not hum then return end
            local moveDir = hum.MoveDirection
            local vx,vy,vz = 0,0,0
            if moveDir.Magnitude > 0 then
                local v = moveDir.Unit * SETTINGS.flySpeed
                vx,vy,vz = v.X, v.Y, v.Z
            end
            if flyUp then vy = SETTINGS.flySpeed end
            if flyDown then vy = -SETTINGS.flySpeed end
            if flyBV then flyBV.Velocity = Vector3.new(vx, vy, vz) end
            if flyBG and hrp2 then flyBG.CFrame = hrp2.CFrame end
        end)
        notify(MainFrame, "Fly enabled (E/Q: up/down)", 2)
    end
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.E then flyUp = true end
    if inp.KeyCode == Enum.KeyCode.Q then flyDown = true end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.KeyCode == Enum.KeyCode.E then flyUp = false end
    if inp.KeyCode == Enum.KeyCode.Q then flyDown = false end
end)

-- ===== ESP Page =====
local ESP = pages["ESP"]
new("UIPadding", {Parent = ESP, PaddingTop = UDim.new(0,6), PaddingLeft = UDim.new(0,6)})
local espToggle = new("TextButton", {Parent = ESP, Size = UDim2.new(0,160,0,36), Text = "Toggle ESP", BackgroundColor3 = Color3.fromRGB(40,110,200), Font = Enum.Font.GothamSemibold})
new("UICorner", {Parent = espToggle, CornerRadius = UDim.new(0,8)})
local espEnabled = SETTINGS.esp
local espObjects = {} -- player -> {highlight,billboard}

local function makeNameTag(player)
    if not player.Character then return end
    local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
    if not head then return end
    if head:FindFirstChild("FattanNameTag") then return end
    local bg = new("BillboardGui", {Parent = head, Name = "FattanNameTag", Size = UDim2.new(0,120,0,28), StudsOffset = Vector3.new(0,2.6,0), AlwaysOnTop = true})
    local lbl = new("TextLabel", {Parent = bg, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = player.Name, Font = Enum.Font.GothamBold, TextSize = 14})
    if player.TeamColor == LocalPlayer.TeamColor then lbl.TextColor3 = Color3.fromRGB(0,255,0) else lbl.TextColor3 = Color3.fromRGB(255,0,0) end
    espObjects[player] = espObjects[player] or {}
    espObjects[player].billboard = bg
end

local function removeNameTag(player)
    if player.Character then
        local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
        if head and head:FindFirstChild("FattanNameTag") then head.FattanNameTag:Destroy() end
    end
    if espObjects[player] and espObjects[player].highlight then
        pcall(function() espObjects[player].highlight:Destroy() end)
    end
    espObjects[player] = nil
end

local function enableESP()
    espEnabled = true
    SETTINGS.esp = true
    saveSettings(SETTINGS)
    for _,pl in pairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            if pl.Character then
                -- Highlight
                if not pl.Character:FindFirstChildWhichIsA("Highlight") then
                    local h = new("Highlight")
                    h.Parent = pl.Character
                    h.Name = "FattanESPHighlight"
                    if pl.TeamColor == LocalPlayer.TeamColor then h.FillColor = Color3.fromRGB(0,255,0) else h.FillColor = Color3.fromRGB(255,0,0) end
                    h.OutlineColor = Color3.new(0,0,0)
                    espObjects[pl] = espObjects[pl] or {}
                    espObjects[pl].highlight = h
                end
                pcall(makeNameTag, pl)
            end
        end
    end
    notify(MainFrame, "ESP enabled", 1.2)
end

local function disableESP()
    espEnabled = false
    SETTINGS.esp = false
    saveSettings(SETTINGS)
    for _,pl in pairs(Players:GetPlayers()) do
        if pl.Character then
            -- remove highlight(s)
            for _,obj in pairs(pl.Character:GetChildren()) do
                if obj:IsA("Highlight") and obj.Name == "FattanESPHighlight" then pcall(function() obj:Destroy() end) end
            end
            removeNameTag(pl)
        end
    end
    notify(MainFrame, "ESP disabled", 1.2)
end

espToggle.MouseButton1Click:Connect(function()
    if espEnabled then disableESP() else enableESP() end
end)

-- auto-update on join/respawn
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if espEnabled and p ~= LocalPlayer then
            task.wait(0.12)
            pcall(function() enableESP() end)
        end
    end)
end)
Players.PlayerRemoving:Connect(function(p)
    removeNameTag(p)
end)

-- ====== Teleport Page ======
local TP = pages["Teleport"]
new("UIPadding", {Parent = TP, PaddingTop = UDim.new(0,6), PaddingLeft = UDim.new(0,6)})
local tpLabel = new("TextLabel", {Parent = TP, Size = UDim2.new(0,280,0,24), Text = "Teleport to player:", BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamSemibold})
local tpBox = new("TextBox", {Parent = TP, Size = UDim2.new(0,220,0,28), Position = UDim2.new(0,0,0,30), PlaceholderText = "Player name", Text = ""})
local tpBtn = new("TextButton", {Parent = TP, Size = UDim2.new(0,120,0,30), Position = UDim2.new(0,0,0,66), Text = "Teleport", BackgroundColor3 = Color3.fromRGB(40,110,200), TextColor3 = Color3.new(1,1,1)})
new("UICorner", {Parent = tpBtn, CornerRadius = UDim.new(0,6)})

-- Create player list (scroll)
local playerList = new("ScrollingFrame", {Parent = TP, Size = UDim2.new(0,260,0,160), Position = UDim2.new(0,240,0,30), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 6})
local playerListLayout = new("UIListLayout", {Parent = playerList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6)})

local selectedPlayer = nil
local function refreshPlayerList()
    for _,c in pairs(playerList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _,p in ipairs(Players:GetPlayers()) do
        local btn = new("TextButton", {Parent = playerList, Size = UDim2.new(1,-12,0,28), Text = p.Name, BackgroundColor3 = Color3.fromRGB(20,70,140), TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamSemibold})
        new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
        btn.MouseButton1Click:Connect(function()
            selectedPlayer = p.Name
            tpBox.Text = p.Name
            btn.BackgroundColor3 = Color3.fromRGB(120,150,200)
            task.delay(0.2, function() if btn and btn.Parent then btn.BackgroundColor3 = Color3.fromRGB(20,70,140) end end)
        end)
    end
    playerList.CanvasSize = UDim2.new(0,0,0,playerListLayout.AbsoluteContentSize.Y + 8)
end
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

tpBtn.MouseButton1Click:Connect(function()
    local name = tpBox.Text
    if name == "" then notify(MainFrame, "Enter player name", 1.2); return end
    local target = Players:FindFirstChild(name)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = safeChar():FindFirstChild("HumanoidRootPart")
        pcall(function() if hrp then hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0) end end)
        notify(MainFrame, "Teleported to "..name, 1.2)
    else
        notify(MainFrame, "Player not found / no character", 1.6)
    end
end)

-- ====== Tools Page ======
local Tools = pages["Tools"]
new("UIPadding", {Parent = Tools, PaddingTop = UDim.new(0,6), PaddingLeft = UDim.new(0,6)})
local toolsLayout = new("UIListLayout", {Parent = Tools, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,8)})

-- Player selection for rope/freeze etc
local selectionLabel = new("TextLabel", {Parent = Tools, Text = "Selected Player:", BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamSemibold})
local selectedText = new("TextLabel", {Parent = Tools, Text = "None", BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(200,200,200)})
local selChooseFrame = new("Frame", {Parent = Tools, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
local selChoose = new("TextBox", {Parent = selChooseFrame, Size = UDim2.new(0,220,0,28), PlaceholderText = "Type player name / or click from list"})
local selRefresh = new("TextButton", {Parent = selChooseFrame, Size = UDim2.new(0,80,0,28), Position = UDim2.new(0,230,0,0), Text = "Refresh"})
new("UICorner", {Parent = selRefresh, CornerRadius = UDim.new(0,6)})
selChooseFrame.Parent = Tools

local toolsPlayerList = new("ScrollingFrame", {Parent = Tools, Size = UDim2.new(1,-12,0,120), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 6})
local toolsListLayout = new("UIListLayout", {Parent = toolsPlayerList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,6)})

local function refreshToolsPlayerList()
    for _,c in pairs(toolsPlayerList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = new("TextButton", {Parent = toolsPlayerList, Size = UDim2.new(1,-12,0,28), Text = p.Name, BackgroundColor3 = Color3.fromRGB(20,70,140), TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamSemibold})
            new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,6)})
            btn.MouseButton1Click:Connect(function()
                selChoose.Text = p.Name
                selectedText.Text = p.Name
            end)
        end
    end
    toolsPlayerList.CanvasSize = UDim2.new(0,0,0,toolsListLayout.AbsoluteContentSize.Y + 8)
end
selRefresh.MouseButton1Click:Connect(refreshToolsPlayerList)
Players.PlayerAdded:Connect(refreshToolsPlayerList)
Players.PlayerRemoving:Connect(refreshToolsPlayerList)
refreshToolsPlayerList()

-- Confirm modal (inside Tools)
local confirmModal = new("Frame", {Parent = Tools, Size = UDim2.new(0,320,0,120), Position = UDim2.new(0.5,-160,0.5,-60), BackgroundColor3 = Color3.fromRGB(24,24,24), Visible = false})
new("UICorner", {Parent = confirmModal, CornerRadius = UDim.new(0,8)})
local confirmLabel = new("TextLabel", {Parent = confirmModal, Size = UDim2.new(1,0,0,50), BackgroundTransparency = 1, Text = "Are you sure?", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.new(1,1,1)})
local confirmYes = new("TextButton", {Parent = confirmModal, Size = UDim2.new(0.5,0,0,46), Position = UDim2.new(0,0,0.6,0), Text = "Yes", BackgroundColor3 = Color3.fromRGB(0,150,0)})
local confirmNo = new("TextButton", {Parent = confirmModal, Size = UDim2.new(0.5,0,0,46), Position = UDim2.new(0.5,0,0.6,0), Text = "No", BackgroundColor3 = Color3.fromRGB(150,0,0)})
new("UICorner", {Parent = confirmYes, CornerRadius = UDim.new(0,8)})
new("UICorner", {Parent = confirmNo, CornerRadius = UDim.new(0,8)})

local pendingPart = nil

-- Scan Parts: highlight all BaseParts (color + ClickDetector)
local scanning = false
local originalParts = {} -- [part] = {color, material}
local detectors = {}     -- [part] = clickdetector

local function startScan()
    if scanning then return end
    scanning = true
    for _,v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            if not originalParts[v] then
                originalParts[v] = {Color = v.Color, Material = v.Material}
            end
            pcall(function() v.Color = Color3.fromRGB(255,100,100); v.Material = Enum.Material.Neon end)
            if not v:FindFirstChildOfClass("ClickDetector") then
                local cd = new("ClickDetector", {Parent = v})
                cd.MaxActivationDistance = 100
                detectors[v] = cd
                cd.MouseClick:Connect(function(player)
                    if player == LocalPlayer and scanning and not pendingPart then
                        pendingPart = v
                        pcall(function() v.Color = Color3.fromRGB(255,255,0) end)
                        confirmLabel.Text = "Delete this part?"
                        confirmModal.Visible = true
                    end
                end)
            else
                detectors[v] = v:FindFirstChildOfClass("ClickDetector")
            end
        end
    end
    notify(MainFrame, "Scan started", 1.2)
end

local function stopScan()
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
    confirmModal.Visible = false
    notify(MainFrame, "Scan stopped & restored", 1.2)
end

-- Buttons in Tools
local scanBtn = new("TextButton", {Parent = Tools, Size = UDim2.new(0,220,0,36), Text = "Scan Parts (Toggle)", BackgroundColor3 = Color3.fromRGB(40,110,200)})
new("UICorner", {Parent = scanBtn, CornerRadius = UDim.new(0,8)})
scanBtn.MouseButton1Click:Connect(function()
    if not scanning then startScan() else stopScan() end
end)

local deleteAllBtn = new("TextButton", {Parent = Tools, Size = UDim2.new(0,220,0,36), Text = "Delete All Parts", BackgroundColor3 = Color3.fromRGB(160,40,40)})
new("UICorner", {Parent = deleteAllBtn, CornerRadius = UDim.new(0,8)})
deleteAllBtn.MouseButton1Click:Connect(function()
    confirmLabel.Text = "Delete ALL parts? (Except HRP)"
    pendingPart = "DELETE_ALL"
    confirmModal.Visible = true
end)

local restoreBtn = new("TextButton", {Parent = Tools, Size = UDim2.new(0,220,0,36), Text = "Restore Parts (Stop Scan)", BackgroundColor3 = Color3.fromRGB(80,80,80)})
new("UICorner", {Parent = restoreBtn, CornerRadius = UDim.new(0,8)})
restoreBtn.MouseButton1Click:Connect(function() stopScan() end)

local freezeBtn = new("TextButton", {Parent = Tools, Size = UDim2.new(0,220,0,36), Text = "Freeze Selected (10s)", BackgroundColor3 = Color3.fromRGB(40,120,180)})
new("UICorner", {Parent = freezeBtn, CornerRadius = UDim.new(0,8)})
freezeBtn.MouseButton1Click:Connect(function()
    local name = selChoose.Text
    if name == "" then notify(MainFrame, "Select player first", 1.4); return end
    local target = Players:FindFirstChild(name)
    if not target or not target.Character then notify(MainFrame, "Player not valid", 1.4); return end
    local thrp = target.Character:FindFirstChild("HumanoidRootPart"); local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if thrp and hum then
        local ice = new("Part", {Parent = Workspace, Name = "Fattan_Ice_"..target.Name, Size = Vector3.new(6,8,6), Anchored = true, CanCollide = false, Color = Color3.fromRGB(160,220,255), Material = Enum.Material.Ice, CFrame = thrp.CFrame, Transparency = 0.15})
        local weld = new("WeldConstraint", {Parent = ice}); weld.Part0 = ice; weld.Part1 = thrp
        pcall(function() hum.WalkSpeed = 0; hum.JumpPower = 0; hum.PlatformStand = true end)
        notify(MainFrame, "Frozen "..target.Name.." for 10s", 1.6)
        task.delay(10, function()
            pcall(function()
                if ice and ice.Parent then ice:Destroy() end
                if hum and hum.Parent then hum.WalkSpeed = 16; hum.JumpPower = 50; hum.PlatformStand = false end
            end)
        end)
    end
end)

-- Rope: visual pull (client-side)
local activeRopes = {} -- [player] = {att1, att2, beam, conn}
local ropeBtn = new("TextButton", {Parent = Tools, Size = UDim2.new(0,220,0,36), Text = "Tarik Tali (3D) - Toggle", BackgroundColor3 = Color3.fromRGB(40,120,60)})
new("UICorner", {Parent = ropeBtn, CornerRadius = UDim.new(0,8)})
ropeBtn.MouseButton1Click:Connect(function()
    local name = selChoose.Text
    if name == "" then notify(MainFrame, "Select player first", 1.4); return end
    local target = Players:FindFirstChild(name)
    if not target or not target.Character then notify(MainFrame, "Player not valid", 1.4); return end
    if activeRopes[target] then
        -- cleanup
        pcall(function()
            if activeRopes[target].conn then activeRopes[target].conn:Disconnect() end
            if activeRopes[target].beam and activeRopes[target].beam.Parent then activeRopes[target].beam:Destroy() end
            if activeRopes[target].att1 and activeRopes[target].att1.Parent then activeRopes[target].att1:Destroy() end
            if activeRopes[target].att2 and activeRopes[target].att2.Parent then activeRopes[target].att2:Destroy() end
        end)
        activeRopes[target] = nil
        notify(MainFrame, "Rope removed for "..name, 1.4)
        return
    end
    local mychar = safeChar()
    local myhrp = mychar:FindFirstChild("HumanoidRootPart")
    local thrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not myhrp or not thrp then notify(MainFrame, "HRP missing", 1.4); return end
    local att1 = new("Attachment", myhrp); att1.Name = "FattanElasticRope_Att1"
    local att2 = new("Attachment", thrp); att2.Name = "FattanElasticRope_Att2"
    local beam = new("Beam", {Parent = myhrp, Name = "FattanElasticRope_Beam", Attachment0 = att1, Attachment1 = att2, Width0 = 0.18, Width1 = 0.18, Segments = 12, FaceCamera = false})
    beam.Color = ColorSequence.new(Color3.fromRGB(139,69,19))
    beam.TextureMode = Enum.TextureMode.Stretch
    beam.CurveSize0 = clamp((myhrp.Position - thrp.Position).Magnitude / 30, 0, 1.5)
    beam.CurveSize1 = beam.CurveSize0 * 0.6
    local pulling = true
    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        if not pulling then return end
        if not att1.Parent or not att2.Parent then
            if conn then conn:Disconnect(); conn = nil end
            return
        end
        local dist = (att1.WorldPosition - att2.WorldPosition).Magnitude
        local curve = clamp(1.5 - (dist/60), 0, 1.5)
        beam.CurveSize0 = curve
        beam.CurveSize1 = curve * 0.6
        if thrp.Parent and myhrp.Parent then
            local dir = myhrp.Position - thrp.Position
            local d = dir.Magnitude
            local minDist = 6
            if d > minDist then
                local targetPos = myhrp.Position - dir.Unit * minDist
                thrp.CFrame = thrp.CFrame:Lerp(CFrame.new(targetPos, targetPos + thrp.CFrame.LookVector), 0.15)
            end
        end
    end)
    activeRopes[target] = {att1 = att1, att2 = att2, beam = beam, conn = conn}
    notify(MainFrame, "Rope active to "..name, 1.4)
end)

-- Stop all ropes
local stopRopesBtn = new("TextButton", {Parent = Tools, Size = UDim2.new(0,220,0,36), Text = "Stop All Ropes", BackgroundColor3 = Color3.fromRGB(120,80,160)})
new("UICorner", {Parent = stopRopesBtn, CornerRadius = UDim.new(0,8)})
stopRopesBtn.MouseButton1Click:Connect(function()
    for pl,data in pairs(activeRopes) do
        pcall(function()
            if data.conn then data.conn:Disconnect() end
            if data.beam and data.beam.Parent then data.beam:Destroy() end
            if data.att1 and data.att1.Parent then data.att1:Destroy() end
            if data.att2 and data.att2.Parent then data.att2:Destroy() end
        end)
        activeRopes[pl] = nil
    end
    notify(MainFrame, "All ropes stopped", 1.2)
end)

-- WalkFling (invisible block attached to HRP)
local walkFlingOn = false
local walkFlingConn, walkFlingPart, walkFlingBV = nil, nil, nil
local walkFlingBtn = new("TextButton", {Parent = Tools, Size = UDim2.new(0,220,0,36), Text = "WalkFling (Toggle)", BackgroundColor3 = Color3.fromRGB(200,140,20)})
new("UICorner", {Parent = walkFlingBtn, CornerRadius = UDim.new(0,8)})
walkFlingBtn.MouseButton1Click:Connect(function()
    if walkFlingOn then
        walkFlingOn = false
        if walkFlingConn then walkFlingConn:Disconnect(); walkFlingConn=nil end
        if walkFlingBV and walkFlingBV.Parent then walkFlingBV:Destroy() end
        if walkFlingPart and walkFlingPart.Parent then walkFlingPart:Destroy() end
        notify(MainFrame, "WalkFling stopped", 1.2)
    else
        walkFlingOn = true
        local ch = safeChar(); local hrp = ch:FindFirstChild("HumanoidRootPart")
        if not hrp then notify(MainFrame, "No HRP", 1.2); return end
        walkFlingPart = new("Part", {Parent = Workspace, Name = "FattanFlingBlock", Size = Vector3.new(20,20,20), Transparency = 1, Anchored = false, CanCollide = true, Massless = true})
        local weld = new("WeldConstraint", {Parent = walkFlingPart}); weld.Part0 = walkFlingPart; weld.Part1 = hrp
        walkFlingBV = new("BodyVelocity", {Parent = walkFlingPart, MaxForce = Vector3.new(1e9,1e9,1e9), Velocity = Vector3.zero})
        walkFlingConn = RunService.Heartbeat:Connect(function()
            if not walkFlingOn or not hrp.Parent or not walkFlingPart.Parent then return end
            local forward = hrp.CFrame.LookVector
            walkFlingBV.Velocity = forward * SETTINGS.flingPower
        end)
        notify(MainFrame, "WalkFling started", 1.2)
    end
end)

-- Delete selected part (confirm modal usage)
confirmYes.MouseButton1Click:Connect(function()
    if pendingPart == "DELETE_ALL" then
        -- delete all baseparts except HRP
        for _,v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                pcall(function() v:Destroy() end)
            end
        end
        notify(MainFrame, "Deleted all parts", 1.2)
    elseif typeof(pendingPart) == "Instance" and pendingPart.Parent then
        pcall(function() pendingPart:Destroy() end)
        notify(MainFrame, "Part deleted", 1.2)
    end
    pendingPart = nil
    confirmModal.Visible = false
end)
confirmNo.MouseButton1Click:Connect(function()
    if typeof(pendingPart) == "Instance" and pendingPart.Parent and pendingPart._fattan_original then
        local d = pendingPart._fattan_original
        pcall(function() pendingPart.Color = d.Color; pendingPart.Material = d.Material end)
        pendingPart._fattan_original = nil
    end
    pendingPart = nil
    confirmModal.Visible = false
end)

-- Restore parts button behavior (stopScan does restore)
-- handled earlier in stopScan()

-- ===== Settings Page =====
local SettingsPage = pages["Settings"]
new("UIPadding", {Parent = SettingsPage, PaddingTop = UDim.new(0,6), PaddingLeft = UDim.new(0,6)})
local settingsLabel = new("TextLabel", {Parent = SettingsPage, Text = "Settings", BackgroundTransparency = 1, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 16})
local saveBtn = new("TextButton", {Parent = SettingsPage, Text = "Save Settings Now", Size = UDim2.new(0,220,0,36), BackgroundColor3 = Color3.fromRGB(60,120,200)})
new("UICorner", {Parent = saveBtn, CornerRadius = UDim.new(0,8)})
saveBtn.MouseButton1Click:Connect(function()
    saveSettings(SETTINGS)
    notify(MainFrame, "Settings saved", 1.2)
end)

-- ===== Misc helpers and cleanup on unload =====
-- Provide function to completely cleanup GUI and active objects
local function cleanupAll()
    -- disable fly
    if flyConn then flyConn:Disconnect(); flyConn=nil end
    if flyBV then pcall(function() flyBV:Destroy() end) end
    if flyBG then pcall(function() flyBG:Destroy() end) end
    -- disable walkfling
    if walkFlingConn then walkFlingConn:Disconnect(); walkFlingConn=nil end
    if walkFlingPart and walkFlingPart.Parent then walkFlingPart:Destroy() end
    -- stop ropes
    for pl,data in pairs(activeRopes) do
        pcall(function()
            if data.conn then data.conn:Disconnect() end
            if data.beam and data.beam.Parent then data.beam:Destroy() end
            if data.att1 and data.att1.Parent then data.att1:Destroy() end
            if data.att2 and data.att2.Parent then data.att2:Destroy() end
        end)
        activeRopes[pl] = nil
    end
    -- stop scanning
    if scanning then stopScan() end
    -- remove ESP
    disableESP()
    -- destroy GUI
    pcall(function() if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end end)
end

-- Close button should call cleanup
CloseBtn.MouseButton1Click:Connect(cleanupAll)

-- Safety: cleanup when player leaves / script disabled
LocalPlayer.AncestryChanged:Connect(function(_, parent)
    if not parent then cleanupAll() end
end)

-- ===== Finish init =====
notify(MainFrame, "FattanHub ready", 1.6)

-- End of script
