-- // FATTAN HUB SCRIPT (Complete All-In-One)
-- Author: assembled per user's requests
-- Features: Loading, compact GUI, Fly (mobile + speed), ESP with small nametag, Player selector,
-- Scan & Delete parts with confirm, WalkFling, adjustable WalkSpeed and JumpPower, Owner crown, Contact

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Safety: wait for player if script runs early
if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

-- ---------------- Loading Screen ----------------
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "FattanLoading"
LoadingGui.ResetOnSpawn = false
LoadingGui.Parent = CoreGui

local LoadingFrame = Instance.new("Frame", LoadingGui)
LoadingFrame.Size = UDim2.new(1,0,1,0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0,40,100)

local LoadingText = Instance.new("TextLabel", LoadingFrame)
LoadingText.Size = UDim2.new(1,0,1,0)
LoadingText.Text = "FATTAN HUB"
LoadingText.TextColor3 = Color3.fromRGB(255,255,255)
LoadingText.Font = Enum.Font.SourceSansBold
LoadingText.TextSize = 36
LoadingText.BackgroundTransparency = 1

task.wait(1.6)
TweenService:Create(LoadingFrame, TweenInfo.new(0.9), {BackgroundTransparency = 1}):Play()
TweenService:Create(LoadingText, TweenInfo.new(0.9), {TextTransparency = 1}):Play()
task.wait(0.9)
LoadingGui:Destroy()

-- ---------------- Main GUI ----------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FattanHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 420) -- compact but roomy
MainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0,40,100)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,35)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundColor3 = Color3.fromRGB(0,120,200)
Title.Text = "FATTAN HUB SCRIPT"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.Padding = UDim.new(0,4)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createButton(text, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(0,80,160)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    return btn
end

-- small helper: wait for character safely
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ---------------- FLY (mobile-safe, respawn-safe) ----------------
local flying = false
local flySpeed = 60
local fly_bv, fly_bg
local fly_conn -- RunService connection
local fly_upHeld, fly_downHeld = false, false

-- Mobile control buttons (attached to ScreenGui)
local upButton = Instance.new("TextButton", ScreenGui)
upButton.Size = UDim2.new(0, 80, 0, 30)
upButton.Position = UDim2.new(0, 10, 1, -120)
upButton.Text = "⬆️"
upButton.BackgroundColor3 = Color3.fromRGB(0,150,0)
upButton.TextColor3 = Color3.new(1,1,1)
upButton.Visible = false
upButton.AutoButtonColor = true

local downButton = Instance.new("TextButton", ScreenGui)
downButton.Size = UDim2.new(0, 80, 0, 30)
downButton.Position = UDim2.new(0, 10, 1, -85)
downButton.Text = "⬇️"
downButton.BackgroundColor3 = Color3.fromRGB(150,0,0)
downButton.TextColor3 = Color3.new(1,1,1)
downButton.Visible = false
downButton.AutoButtonColor = true

local minusFly = Instance.new("TextButton", ScreenGui)
minusFly.Size = UDim2.new(0,30,0,30)
minusFly.Position = UDim2.new(1,-100,1,-85)
minusFly.Text = "➖"
minusFly.BackgroundColor3 = Color3.fromRGB(80,0,0)
minusFly.TextColor3 = Color3.new(1,1,1)
minusFly.Visible = false
minusFly.AutoButtonColor = true

local plusFly = Instance.new("TextButton", ScreenGui)
plusFly.Size = UDim2.new(0,30,0,30)
plusFly.Position = UDim2.new(1,-65,1,-85)
plusFly.Text = "➕"
plusFly.BackgroundColor3 = Color3.fromRGB(0,80,0)
plusFly.TextColor3 = Color3.new(1,1,1)
plusFly.Visible = false
plusFly.AutoButtonColor = true

local flyLabel = Instance.new("TextLabel", ScreenGui)
flyLabel.Size = UDim2.new(0,50,0,30)
flyLabel.Position = UDim2.new(1,-150,1,-85)
flyLabel.Text = tostring(flySpeed)
flyLabel.BackgroundColor3 = Color3.fromRGB(0,0,80)
flyLabel.TextColor3 = Color3.new(1,1,1)
flyLabel.Visible = false

-- input holds
upButton.MouseButton1Down:Connect(function() fly_upHeld = true end)
upButton.MouseButton1Up:Connect(function() fly_upHeld = false end)
downButton.MouseButton1Down:Connect(function() fly_downHeld = true end)
downButton.MouseButton1Up:Connect(function() fly_downHeld = false end)

minusFly.MouseButton1Click:Connect(function()
    flySpeed = math.max(1, flySpeed - 5)
    flyLabel.Text = tostring(flySpeed)
end)
plusFly.MouseButton1Click:Connect(function()
    flySpeed = math.min(100, flySpeed + 5)
    flyLabel.Text = tostring(flySpeed)
end)

local function cleanupFlyObjects()
    if fly_bv and fly_bv.Parent then fly_bv:Destroy() end
    fly_bv = nil
    if fly_bg and fly_bg.Parent then fly_bg:Destroy() end
    fly_bg = nil
    if fly_conn then fly_conn:Disconnect() end
    fly_conn = nil
end

local function startFly()
    local char = getCharacter()
    local hrp = char:WaitForChild("HumanoidRootPart")
    cleanupFlyObjects()

    fly_bv = Instance.new("BodyVelocity")
    fly_bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    fly_bv.Velocity = Vector3.zero
    fly_bv.Parent = hrp

    fly_bg = Instance.new("BodyGyro")
    fly_bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    fly_bg.P = 10000
    fly_bg.CFrame = hrp.CFrame
    fly_bg.Parent = hrp

    fly_conn = RunService.RenderStepped:Connect(function()
        if not flying or not fly_bv or not fly_bg or not hrp.Parent then return end
        local cam = workspace.CurrentCamera
        if cam then
            fly_bg.CFrame = cam.CFrame
        end
        local move = Vector3.zero

        if UserInputService.TouchEnabled then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local md = hum.MoveDirection
                if md and md.Magnitude > 0 then
                    move = move + md
                end
            end
        else
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
        end

        if fly_upHeld then move = move + Vector3.new(0,1,0) end
        if fly_downHeld then move = move + Vector3.new(0,-1,0) end

        -- fallback small downward so player won't stuck midair
        if move.Magnitude < 0.09 then
            move = Vector3.new(0, -0.1, 0)
        end

        fly_bv.Velocity = move.Unit * flySpeed
    end)
end

local function stopFly()
    cleanupFlyObjects()
end

-- toggle button
createButton("Fly (Toggle)", function()
    flying = not flying
    if flying then
        startFly()
        upButton.Visible = true
        downButton.Visible = true
        minusFly.Visible = true
        plusFly.Visible = true
        flyLabel.Visible = true
    else
        stopFly()
        upButton.Visible = false
        downButton.Visible = false
        minusFly.Visible = false
        plusFly.Visible = false
        flyLabel.Visible = false
    end
end)

-- respawn-safe: reapply fly if toggled when character respawns
LocalPlayer.CharacterAdded:Connect(function(char)
    if flying then
        task.wait(0.8)
        pcall(startFly)
    else
        -- ensure no stray BV/BG left
        pcall(cleanupFlyObjects)
    end
end)

-- ---------------- ESP (with small nametag) ----------------
local espEnabled = false
local esp_connections = {} -- to track added displays per player

local function createNameTagForPlayer(p)
    if not p.Character then return end
    local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
    if not head then return end
    if head:FindFirstChild("Fattan_NameTag") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Fattan_NameTag"
    billboard.Size = UDim2.new(0,100,0,20)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = p.Name
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextStrokeTransparency = 0.4
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.RichText = false
end

local function removeNameTagForPlayer(p)
    if p.Character then
        local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
        if head and head:FindFirstChild("Fattan_NameTag") then
            head.Fattan_NameTag:Destroy()
        end
        if p.Character:FindFirstChild("FattanESP") then
            p.Character.FattanESP:Destroy()
        end
    end
end

local function updateESPStateForPlayer(p)
    if not p.Character then return end
    if espEnabled and p ~= LocalPlayer then
        -- highlight
        if not p.Character:FindFirstChild("FattanESP") then
            local highlight = Instance.new("Highlight", p.Character)
            highlight.Name = "FattanESP"
            highlight.FillColor = Color3.fromRGB(0,255,255)
            highlight.OutlineColor = Color3.fromRGB(0,0,0)
        end
        createNameTagForPlayer(p)
    else
        removeNameTagForPlayer(p)
    end
end

-- toggle ESP button
createButton("ESP Player (Toggle)", function()
    espEnabled = not espEnabled
    for _, p in pairs(Players:GetPlayers()) do
        updateESPStateForPlayer(p)
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        -- slight delay so Head exists
        task.wait(0.2)
        updateESPStateForPlayer(p)
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    removeNameTagForPlayer(p)
end)

-- ---------------- Player Selector (list + actions) ----------------
local PlayerFrame = Instance.new("Frame", MainFrame)
PlayerFrame.Size = UDim2.new(1,-10,0,120)
PlayerFrame.BackgroundColor3 = Color3.fromRGB(20,20,50)

local PlayerList = Instance.new("ScrollingFrame", PlayerFrame)
PlayerList.Size = UDim2.new(1,0,1,0)
PlayerList.CanvasSize = UDim2.new(0,0,0,0)
PlayerList.ScrollBarThickness = 6

local PlayerListLayout = Instance.new("UIListLayout", PlayerList)
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local selectedPlayer = nil

local function refreshPlayerList()
    -- clear previous buttons
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton", PlayerList)
            btn.Size = UDim2.new(1,-6,0,26)
            btn.Position = UDim2.new(0,3,0,0)
            btn.BackgroundColor3 = Color3.fromRGB(0,60,120)
            btn.Text = p.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.SourceSansBold
            btn.TextSize = 14
            btn.AutoButtonColor = true
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = p.Name
                -- visual feedback: briefly change button color
                local old = btn.BackgroundColor3
                btn.BackgroundColor3 = Color3.fromRGB(100,150,200)
                task.delay(0.25, function() if btn and btn.Parent then btn.BackgroundColor3 = old end end)
            end)
        end
    end
    PlayerList.CanvasSize = UDim2.new(0,0,0,PlayerListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

-- teleport selected
createButton("Teleport ke Player (Selected)", function()
    if not selectedPlayer then return end
    local target = Players:FindFirstChild(selectedPlayer)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local myChar = getCharacter()
        local hrp = myChar:WaitForChild("HumanoidRootPart")
        hrp.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
    end
end)

-- freeze visual selected
createButton("Freeze Player Visual (Selected)", function()
    if not selectedPlayer then return end
    local target = Players:FindFirstChild(selectedPlayer)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local ice = Instance.new("Part", workspace)
        ice.Size = Vector3.new(6,8,6)
        ice.Anchored = true
        ice.CanCollide = false
        ice.Color = Color3.fromRGB(150,220,255)
        ice.Material = Enum.Material.Ice
        ice.CFrame = target.Character.HumanoidRootPart.CFrame
        -- auto remove after some time (visual only)
        task.delay(8, function() if ice and ice.Parent then ice:Destroy() end end)
    end
end)

-- tarik player (rope)
createButton("Tarik Player (Selected)", function()
    if not selectedPlayer then return end
    local target = Players:FindFirstChild(selectedPlayer)
    local myChar = getCharacter()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and myChar and myChar:FindFirstChild("HumanoidRootPart") then
        local attachment1 = Instance.new("Attachment", myChar.HumanoidRootPart)
        local attachment2 = Instance.new("Attachment", target.Character.HumanoidRootPart)
        local rope = Instance.new("RopeConstraint")
        rope.Attachment0 = attachment1
        rope.Attachment1 = attachment2
        rope.Length = 10
        rope.Parent = myChar.HumanoidRootPart
        -- cleanup after 12 seconds
        task.delay(12, function()
            if rope and rope.Parent then rope:Destroy() end
            if attachment1 and attachment1.Parent then attachment1:Destroy() end
            if attachment2 and attachment2.Parent then attachment2:Destroy() end
        end)
    end
end)

-- ---------------- Delete Parts (Scan, click -> confirm, restore) ----------------
local scanning = false
local original_colors = {} -- part -> {Color, Material}
local clickDetectors = {} -- part -> clickDetector
local pendingDelete = nil

-- confirm GUI
local ConfirmGui = Instance.new("ScreenGui", CoreGui)
ConfirmGui.Name = "FattanConfirmGui"
ConfirmGui.ResetOnSpawn = false
ConfirmGui.Enabled = false

local ConfirmFrame = Instance.new("Frame", ConfirmGui)
ConfirmFrame.Size = UDim2.new(0,220,0,110)
ConfirmFrame.Position = UDim2.new(0.5,-110,0.78,0)
ConfirmFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
ConfirmFrame.BorderSizePixel = 0
ConfirmFrame.Visible = true

local ConfirmText = Instance.new("TextLabel", ConfirmFrame)
ConfirmText.Size = UDim2.new(1,0,0,50)
ConfirmText.Position = UDim2.new(0,0,0,0)
ConfirmText.BackgroundTransparency = 1
ConfirmText.Text = "Hapus Part ini?"
ConfirmText.TextColor3 = Color3.new(1,1,1)
ConfirmText.Font = Enum.Font.GothamBold
ConfirmText.TextSize = 18

local YesBtn = Instance.new("TextButton", ConfirmFrame)
YesBtn.Size = UDim2.new(0.5,0,0,50)
YesBtn.Position = UDim2.new(0,0,0.45,0)
YesBtn.Text = "✅ Ya"
YesBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
YesBtn.TextColor3 = Color3.new(1,1,1)

local NoBtn = Instance.new("TextButton", ConfirmFrame)
NoBtn.Size = UDim2.new(0.5,0,0,50)
NoBtn.Position = UDim2.new(0.5,0,0.45,0)
NoBtn.Text = "❌ Tidak"
NoBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
NoBtn.TextColor3 = Color3.new(1,1,1)

YesBtn.MouseButton1Click:Connect(function()
    if pendingDelete and pendingDelete.Parent then
        -- destroy selected part
        pendingDelete:Destroy()
    end
    pendingDelete = nil
    ConfirmGui.Enabled = false
end)

NoBtn.MouseButton1Click:Connect(function()
    if pendingDelete and pendingDelete.Parent then
        local orig = original_colors[pendingDelete]
        if orig then
            pendingDelete.Color = orig.Color
            pendingDelete.Material = orig.Material
        end
    end
    pendingDelete = nil
    ConfirmGui.Enabled = false
end)

local function startScanParts()
    scanning = true
    -- collect and change parts
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            if not original_colors[v] then
                original_colors[v] = {Color = v.Color, Material = v.Material}
            end
            -- highlight
            pcall(function()
                v.Color = Color3.fromRGB(255, 90, 90)
                v.Material = Enum.Material.Neon
            end)
            -- add click detector
            if not v:FindFirstChildOfClass("ClickDetector") then
                local cd = Instance.new("ClickDetector")
                cd.MaxActivationDistance = 100
                cd.Parent = v
                clickDetectors[v] = cd
                cd.MouseClick:Connect(function(player)
                    if player == LocalPlayer and scanning and pendingDelete == nil then
                        pendingDelete = v
                        -- mark selected
                        v.Color = Color3.fromRGB(255,255,0)
                        ConfirmGui.Enabled = true
                    end
                end)
            else
                clickDetectors[v] = v:FindFirstChildOfClass("ClickDetector")
            end
        end
    end
end

local function stopScanAndRestore()
    scanning = false
    for part, data in pairs(original_colors) do
        if part and part.Parent then
            pcall(function()
                part.Color = data.Color
                part.Material = data.Material
            end)
        end
        -- remove click detectors we added
        local cd = clickDetectors[part]
        if cd and cd.Parent then
            pcall(function() cd:Destroy() end)
        end
        clickDetectors[part] = nil
    end
    original_colors = {}
    pendingDelete = nil
    ConfirmGui.Enabled = false
end

createButton("Scan Parts (Toggle)", function()
    if not scanning then
        startScanParts()
    else
        stopScanAndRestore()
    end
end)

createButton("Delete All Parts", function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            pcall(function() v:Destroy() end)
        end
    end
    original_colors = {}
end)

createButton("Restore Normal Parts", function()
    stopScanAndRestore()
end)

-- ---------------- WalkSpeed & SuperJump controls (with +/- 1..100) ----------------
local runSpeed = 16
local jumpPower = 50

-- UI single-line frames generator (so they occupy consistent space in MainFrame)
local function makeSettingRow(labelText)
    local frame = Instance.new("Frame", MainFrame)
    frame.Size = UDim2.new(1, -10, 0, 34)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0,6,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local minus = Instance.new("TextButton", frame)
    minus.Size = UDim2.new(0,36,0,28)
    minus.Position = UDim2.new(0.62,0,0,3)
    minus.Text = "−"
    minus.Font = Enum.Font.SourceSansBold
    minus.TextSize = 18
    minus.BackgroundColor3 = Color3.fromRGB(160,40,40)
    minus.TextColor3 = Color3.new(1,1,1)

    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0,64,0,28)
    valueLabel.Position = UDim2.new(0.73,0,0,3)
    valueLabel.BackgroundColor3 = Color3.fromRGB(20,20,80)
    valueLabel.TextColor3 = Color3.new(1,1,1)
    valueLabel.Font = Enum.Font.SourceSansBold
    valueLabel.TextSize = 14
    valueLabel.Text = "0"

    local plus = Instance.new("TextButton", frame)
    plus.Size = UDim2.new(0,36,0,28)
    plus.Position = UDim2.new(0.92,0,0,3)
    plus.Text = "+"
    plus.Font = Enum.Font.SourceSansBold
    plus.TextSize = 18
    plus.BackgroundColor3 = Color3.fromRGB(40,120,40)
    plus.TextColor3 = Color3.new(1,1,1)

    return frame, minus, valueLabel, plus
end

-- Run speed row
local runFrame, runMinus, runValueLabel, runPlus = makeSettingRow("Run Speed")
runValueLabel.Text = tostring(runSpeed)
runMinus.MouseButton1Click:Connect(function()
    runSpeed = math.max(1, runSpeed - 1)
    runValueLabel.Text = tostring(runSpeed)
    local hum = getCharacter():FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = runSpeed end
end)
runPlus.MouseButton1Click:Connect(function()
    runSpeed = math.min(100, runSpeed + 1)
    runValueLabel.Text = tostring(runSpeed)
    local hum = getCharacter():FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = runSpeed end
end)
-- button to set current walk speed (convenience)
createButton("Apply Run Speed Now", function()
    local hum = getCharacter():FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = runSpeed end
end)

-- Jump power row
local jumpFrame, jumpMinus, jumpValueLabel, jumpPlus = makeSettingRow("Jump Power")
jumpValueLabel.Text = tostring(jumpPower)
jumpMinus.MouseButton1Click:Connect(function()
    jumpPower = math.max(1, jumpPower - 1)
    jumpValueLabel.Text = tostring(jumpPower)
    local hum = getCharacter():FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true hum.JumpPower = jumpPower end
end)
jumpPlus.MouseButton1Click:Connect(function()
    jumpPower = math.min(100, jumpPower + 1)
    jumpValueLabel.Text = tostring(jumpPower)
    local hum = getCharacter():FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true hum.JumpPower = jumpPower end
end)
createButton("Apply Jump Now", function()
    local hum = getCharacter():FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true hum.JumpPower = jumpPower end
end)

-- Reset speed/jump
createButton("Reset Speed & Jump", function()
    runSpeed = 16
    jumpPower = 50
    runValueLabel.Text = tostring(runSpeed)
    jumpValueLabel.Text = tostring(jumpPower)
    local hum = getCharacter():FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = runSpeed
        hum.UseJumpPower = true
        hum.JumpPower = jumpPower
    end
end)

-- ---------------- WalkFling (Toggle safe) ----------------
local flingEnabled = false
local fling_conn = nil
local fling_bav = nil

local function startWalkFling()
    local char = getCharacter()
    local hrp = char:WaitForChild("HumanoidRootPart")
    -- create angular velocity so we spin
    fling_bav = Instance.new("BodyAngularVelocity")
    fling_bav.Name = "FattanFling"
    fling_bav.AngularVelocity = Vector3.new(0, 9e5, 0)
    fling_bav.MaxTorque = Vector3.new(9e9,9e9,9e9)
    fling_bav.Parent = hrp

    -- maintain forward momentum and fling nearby unanchored parts
    fling_conn = RunService.Heartbeat:Connect(function()
        if not flingEnabled or not hrp.Parent then return end
        -- forward push to potentially collide
        hrp.Velocity = hrp.CFrame.LookVector * 80
        -- fling nearby unanchored parts
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj.Anchored and obj.Parent ~= hrp and (obj.Position - hrp.Position).Magnitude < 6 then
                -- apply strong velocity away from hrp
                local dir = (obj.Position - hrp.Position)
                if dir.Magnitude > 0 then
                    pcall(function()
                        obj.Velocity = dir.Unit * 120
                    end)
                end
            end
        end
    end)
end

local function stopWalkFling()
    if fling_conn then fling_conn:Disconnect() fling_conn = nil end
    if fling_bav and fling_bav.Parent then fling_bav:Destroy() end
    fling_bav = nil
end

createButton("WalkFling (Toggle)", function()
    flingEnabled = not flingEnabled
    if flingEnabled then
        startWalkFling()
    else
        stopWalkFling()
    end
end)

-- ensure cleanup on respawn
LocalPlayer.CharacterAdded:Connect(function()
    if not flingEnabled then
        stopWalkFling()
    else
        task.wait(0.8)
        if flingEnabled then startWalkFling() end
    end
end)

-- ---------------- Owner Logo (small + crown) ----------------
-- attach small billboard to local player's head
local function createOwnerBillboard()
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end
    if head:FindFirstChild("FattanOwnerBillboard") then return end

    local bg = Instance.new("BillboardGui")
    bg.Name = "FattanOwnerBillboard"
    bg.Size = UDim2.new(0,110,0,36)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    bg.Parent = head

    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "👑 OWNER"
    lbl.TextColor3 = Color3.fromRGB(255,215,0)
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextScaled = true
    lbl.TextStrokeTransparency = 0.2
    lbl.TextStrokeColor3 = Color3.new(0,0,0)
end

-- create owner billboard when character exists
if LocalPlayer.Character then
    pcall(createOwnerBillboard)
end
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.6)
    pcall(createOwnerBillboard)
end)

-- ---------------- Contact Info ----------------
local Contact = Instance.new("TextLabel", MainFrame)
Contact.Size = UDim2.new(1,-10,0,24)
Contact.BackgroundTransparency = 1
Contact.Position = UDim2.new(0,5,1,-30)
Contact.Text = "Contact: FattanHub v2.0"
Contact.TextColor3 = Color3.fromRGB(220,220,220)
Contact.Font = Enum.Font.SourceSansBold
Contact.TextSize = 12
Contact.TextXAlignment = Enum.TextXAlignment.Left

-- ---------------- Finalization ----------------
-- Ensure some initial humanoid defaults (if character present)
pcall(function()
    local char = getCharacter()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = runSpeed or 16
        hum.UseJumpPower = true
        hum.JumpPower = jumpPower or 50
    end
end)

-- End of script
