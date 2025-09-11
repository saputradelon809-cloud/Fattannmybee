-- FATTAN HUB - FINAL ALL IN ONE (stable + fixes)
-- Paste this into your executor / .lua file
-- Note: This script assumes it's run in a LocalScript / executor that can create CoreGui elements.

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

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

task.wait(1.2)
TweenService:Create(loadFrame, TweenInfo.new(0.9), {BackgroundTransparency = 1}):Play()
TweenService:Create(loadLabel, TweenInfo.new(0.9), {TextTransparency = 1}):Play()
task.wait(0.9)
loadingGui:Destroy()

-- ---------- Main GUI ----------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FattanHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 460)
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
    btn.Size = UDim2.new(1,-12,0,32)
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

-- helper: get character safely
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ---------- Fly (stable, respawn-safe) ----------
local flying = false
local flySpeed = 60
local flyBV, flyBG
local flyConn -- RenderStepped connection
local upHold, downHold = false, false

-- Mobile UI for fly controls
local upBtn = Instance.new("TextButton", screenGui)
upBtn.Size = UDim2.new(0,72,0,32); upBtn.Position = UDim2.new(0,10,1,-140)
upBtn.Text = "UP"; upBtn.BackgroundColor3 = Color3.fromRGB(0,155,0); upBtn.Visible = false

local downBtn = Instance.new("TextButton", screenGui)
downBtn.Size = UDim2.new(0,72,0,32); downBtn.Position = UDim2.new(0,10,1,-100)
downBtn.Text = "DOWN"; downBtn.BackgroundColor3 = Color3.fromRGB(155,0,0); downBtn.Visible = false

local flyMinus = Instance.new("TextButton", screenGui)
flyMinus.Size = UDim2.new(0,36,0,32); flyMinus.Position = UDim2.new(1,-150,1,-100)
flyMinus.Text = "−"; flyMinus.Visible = false

local flyPlus = Instance.new("TextButton", screenGui)
flyPlus.Size = UDim2.new(0,36,0,32); flyPlus.Position = UDim2.new(1,-100,1,-100)
flyPlus.Text = "+"; flyPlus.Visible = false

local flyValLabel = Instance.new("TextLabel", screenGui)
flyValLabel.Size = UDim2.new(0,60,0,32); flyValLabel.Position = UDim2.new(1,-220,1,-100)
flyValLabel.Text = tostring(flySpeed); flyValLabel.BackgroundColor3 = Color3.fromRGB(8,20,70); flyValLabel.TextColor3 = Color3.new(1,1,1); flyValLabel.Visible = false

upBtn.MouseButton1Down:Connect(function() upHold = true end)
upBtn.MouseButton1Up:Connect(function() upHold = false end)
downBtn.MouseButton1Down:Connect(function() downHold = true end)
downBtn.MouseButton1Up:Connect(function() downHold = false end)

flyMinus.MouseButton1Click:Connect(function()
    flySpeed = math.max(1, flySpeed - 5)
    flyValLabel.Text = tostring(flySpeed)
end)
flyPlus.MouseButton1Click:Connect(function()
    flySpeed = math.min(100, flySpeed + 5)
    flyValLabel.Text = tostring(flySpeed)
end)

local function cleanupFly()
    if flyConn then pcall(function() flyConn:Disconnect() end) end
    flyConn = nil
    if flyBV and flyBV.Parent then pcall(function() flyBV:Destroy() end) end
    flyBV = nil
    if flyBG and flyBG.Parent then pcall(function() flyBG:Destroy() end) end
    flyBG = nil
end

local function ensureFlyParts(hrp)
    if not flyBV or not flyBV.Parent then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
        flyBV.Parent = hrp
        flyBV.Velocity = Vector3.zero
    end
    if not flyBG or not flyBG.Parent then
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
        flyBG.P = 10000
        flyBG.Parent = hrp
    end
end

local function startFly()
    local ok, char = pcall(getChar)
    if not ok or not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.PlatformStand = true end) end
    cleanupFly()
    ensureFlyParts(hrp)

    -- RenderStepped loop
    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not hrp or not hrp.Parent then return end
        if not flyBV or not flyBV.Parent or not flyBG or not flyBG.Parent then
            ensureFlyParts(hrp)
        end
        local cam = workspace.CurrentCamera
        if cam and flyBG then flyBG.CFrame = cam.CFrame end

        local move = Vector3.zero
        pcall(function()
            if UserInputService.TouchEnabled then
                local h = char:FindFirstChildOfClass("Humanoid")
                if h then
                    local md = h.MoveDirection
                    if md and md.Magnitude > 0 then move = move + md end
                end
            else
                if cam then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move + Vector3.new(0,-1,0) end
                end
            end
            if upHold then move = move + Vector3.new(0,1,0) end
            if downHold then move = move + Vector3.new(0,-1,0) end
        end)
        -- fallback tiny down so not stuck
        if move.Magnitude < 0.09 then
            flyBV.Velocity = Vector3.new(0, -0.1, 0) * flySpeed
        else
            flyBV.Velocity = move.Unit * flySpeed
        end
    end)
end

local function stopFly()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.PlatformStand = false end) end
    end
    cleanupFly()
end

createButton("Fly (Toggle)", function()
    flying = not flying
    if flying then
        startFly()
        upBtn.Visible = true; downBtn.Visible = true; flyMinus.Visible = true; flyPlus.Visible = true; flyValLabel.Visible = true
    else
        stopFly()
        upBtn.Visible = false; downBtn.Visible = false; flyMinus.Visible = false; flyPlus.Visible = false; flyValLabel.Visible = false
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if flying then
        task.wait(0.8)
        pcall(startFly)
    else
        pcall(cleanupFly)
    end
end)

-- ---------- ESP (small name) ----------
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

-- ---------- Player List (teleport/freeze/tarik) ----------
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
    local mychar = getChar(); local hrp = mychar:WaitForChild("HumanoidRootPart")
    hrp.CFrame = tchar.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
end)

-- Freeze selected: immobilize & put in ice box
createButton("Freeze Selected (10s)", function()
    if not selected then return end
    local target = Players:FindFirstChild(selected); if not target then return end
    local tchar = target.Character; if not tchar then return end
    local hrp = tchar:FindFirstChild("HumanoidRootPart"); local hum = tchar:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- create ice part and weld
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

    -- immobilize
    if hum then
        pcall(function()
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum.PlatformStand = true
        end)
    end

    -- auto unfreeze after 10 sec
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

createButton("Pull Selected (Rope)", function()
    if not selected then return end
    local target = Players:FindFirstChild(selected); if not target then return end
    local tchar = target.Character; if not tchar then return end
    local thrp = tchar:FindFirstChild("HumanoidRootPart")
    local mychar = getChar()
    local myhrp = mychar:FindFirstChild("HumanoidRootPart")
    if not thrp or not myhrp then return end

    local att1 = Instance.new("Attachment", myhrp)
    local att2 = Instance.new("Attachment", thrp)
    local rope = Instance.new("RopeConstraint", myhrp)
    rope.Attachment0 = att1; rope.Attachment1 = att2; rope.Length = 8

    task.delay(12, function()
        pcall(function() rope:Destroy() end)
        pcall(function() if att1 and att1.Parent then att1:Destroy() end if att2 and att2.Parent then att2:Destroy() end end)
    end)
end)

-- ---------- Delete Parts (scan, click confirm, restore) ----------
local scanning = false
local original = {}
local detectors = {}
local pending = nil

local confirmGui = Instance.new("ScreenGui", CoreGui)
confirmGui.Name = "FattanConfirm"; confirmGui.ResetOnSpawn = false; confirmGui.Enabled = false

local confFrame = Instance.new("Frame", confirmGui)
confFrame.Size = UDim2.new(0,220,0,110); confFrame.Position = UDim2.new(0.5,-110,0.78,0)
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

-- ---------- WalkFling (toggle) ----------
local flingOn = false
local flingConn = nil
local flingBAV = nil

local function startFling()
    local char = getChar(); local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    flingBAV = Instance.new("BodyAngularVelocity", hrp); flingBAV.AngularVelocity = Vector3.new(0,9e5,0); flingBAV.MaxTorque = Vector3.new(9e9,9e9,9e9)
    flingConn = RunService.Heartbeat:Connect(function()
        if not flingOn or not hrp.Parent then return end
        -- push forward & fling nearby unanchored parts
        hrp.Velocity = hrp.CFrame.LookVector * 80
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Anchored and obj ~= hrp and (obj.Position - hrp.Position).Magnitude < 6 then
                pcall(function() obj.Velocity = (obj.Position - hrp.Position).Unit * 120 end)
            end
        end
    end)
end

local function stopFling()
    if flingConn then flingConn:Disconnect() flingConn = nil end
    if flingBAV and flingBAV.Parent then pcall(function() flingBAV:Destroy() end) end
    flingBAV = nil
end

createButton("WalkFling (Toggle)", function()
    flingOn = not flingOn
    if flingOn then startFling() else stopFling() end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if flingOn then task.wait(0.8); pcall(startFling) end
end)

-- ---------- Run & Jump controls (1..100 with +/- UI rows) ----------
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

-- Run row
local runFrame, runMinus, runLabel, runPlus = makeRow("Run Speed", runVal)
runMinus.MouseButton1Click:Connect(function()
    runVal = math.max(1, runVal - 1); runLabel.Text = tostring(runVal)
    pcall(function() local hum = getChar():FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = runVal end end)
end)
runPlus.MouseButton1Click:Connect(function()
    runVal = math.min(100, runVal + 1); runLabel.Text = tostring(runVal)
    pcall(function() local hum = getChar():FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = runVal end end)
end)
createButton("Apply Run Speed Now", function() pcall(function() local hum = getChar():FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = runVal end end) end)

-- Jump row
local jumpFrame, jumpMinus, jumpLabel, jumpPlus = makeRow("Jump Power", jumpVal)
jumpMinus.MouseButton1Click:Connect(function()
    jumpVal = math.max(1, jumpVal - 1); jumpLabel.Text = tostring(jumpVal)
    pcall(function() local hum = getChar():FindFirstChildOfClass("Humanoid"); if hum then hum.UseJumpPower = true; hum.JumpPower = jumpVal end end)
end)
jumpPlus.MouseButton1Click:Connect(function()
    jumpVal = math.min(100, jumpVal + 1); jumpLabel.Text = tostring(jumpVal)
    pcall(function() local hum = getChar():FindFirstChildOfClass("Humanoid"); if hum then hum.UseJumpPower = true; hum.JumpPower = jumpVal end end)
end)
createButton("Apply Jump Now", function() pcall(function() local hum = getChar():FindFirstChildOfClass("Humanoid"); if hum then hum.UseJumpPower = true; hum.JumpPower = jumpVal end end) end)

createButton("Reset Speed & Jump", function()
    runVal = 16; jumpVal = 50; runLabel.Text = tostring(runVal); jumpLabel.Text = tostring(jumpVal)
    pcall(function() local hum = getChar():FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = runVal; hum.UseJumpPower = true; hum.JumpPower = jumpVal end end)
end)

-- ---------- Owner Crown small ----------
local function createOwnerCrown()
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end
    if head:FindFirstChild("FattanOwner") then return end
    local bg = Instance.new("BillboardGui", head); bg.Name = "FattanOwner"; bg.Size = UDim2.new(0,110,0,30); bg.StudsOffset = Vector3.new(0,3,0); bg.AlwaysOnTop = true
    local img = Instance.new("ImageLabel", bg); img.Size = UDim2.new(0,28,0,28); img.Position = UDim2.new(0,4,0,0); img.BackgroundTransparency = 1
    -- use an asset id for crown (example), if unavailable will show blank
    pcall(function() img.Image = "rbxassetid://6031068426" end)
    local lbl = Instance.new("TextLabel", bg); lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.Text = " OWNER"; lbl.Font = Enum.Font.GothamBlack; lbl.TextColor3 = Color3.fromRGB(255,215,0); lbl.TextScaled = true; lbl.TextStrokeTransparency = 0.2
end
if LocalPlayer.Character then pcall(createOwnerCrown) end
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.7); pcall(createOwnerCrown) end)

-- ---------- Contact ----------
local contact = Instance.new("TextLabel", mainFrame)
contact.Size = UDim2.new(1,-12,0,28); contact.BackgroundTransparency = 1; contact.Position = UDim2.new(0,6,1,-34)
contact.Text = "Contact: FattanHub v3.0"; contact.Font = Enum.Font.SourceSansBold; contact.TextSize = 12; contact.TextColor3 = Color3.new(0.88,0.88,0.88)

-- Final cleanup on script end: ensure creators objects don't linger badly (optional)
-- You can add extra cleanup code here if desired.

-- End of script
