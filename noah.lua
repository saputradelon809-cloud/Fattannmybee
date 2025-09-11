-- // FATTAN HUB SCRIPT (All In One)
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Loading Screen
local LoadingGui = Instance.new("ScreenGui", CoreGui)
LoadingGui.Name = "FattanLoading"

local LoadingFrame = Instance.new("Frame", LoadingGui)
LoadingFrame.Size = UDim2.new(1,0,1,0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0,40,100)

local LoadingText = Instance.new("TextLabel", LoadingFrame)
LoadingText.Size = UDim2.new(1,0,1,0)
LoadingText.Text = "FATTANHUBSCRIPT"
LoadingText.TextColor3 = Color3.fromRGB(255,255,255)
LoadingText.Font = Enum.Font.SourceSansBold
LoadingText.TextSize = 40
LoadingText.BackgroundTransparency = 1

task.wait(2)
TweenService:Create(LoadingFrame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
TweenService:Create(LoadingText, TweenInfo.new(1), {TextTransparency = 1}):Play()
task.wait(1)
LoadingGui:Destroy()

-- Main GUI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "FattanHub"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0,40,100)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundColor3 = Color3.fromRGB(0,120,200)
Title.Text = "FATTAN HUB SCRIPT"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.Padding = UDim.new(0,5)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createButton(text, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(0,80,160)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- // Fly Mobile + Speed Control
local flying = false
local flySpeed = 60
local bv, bg
local upHeld, downHeld = false, false

local upButton = Instance.new("TextButton", ScreenGui)
upButton.Size = UDim2.new(0, 100, 0, 40)
upButton.Position = UDim2.new(0, 10, 1, -140)
upButton.Text = "⬆️ UP"
upButton.BackgroundColor3 = Color3.fromRGB(0,150,0)
upButton.TextColor3 = Color3.new(1,1,1)
upButton.Visible = false

local downButton = Instance.new("TextButton", ScreenGui)
downButton.Size = UDim2.new(0, 100, 0, 40)
downButton.Position = UDim2.new(0, 10, 1, -95)
downButton.Text = "⬇️ DOWN"
downButton.BackgroundColor3 = Color3.fromRGB(150,0,0)
downButton.TextColor3 = Color3.new(1,1,1)
downButton.Visible = false

local minusButton = Instance.new("TextButton", ScreenGui)
minusButton.Size = UDim2.new(0,40,0,40)
minusButton.Position = UDim2.new(1,-120,1,-95)
minusButton.Text = "➖"
minusButton.BackgroundColor3 = Color3.fromRGB(80,0,0)
minusButton.TextColor3 = Color3.new(1,1,1)
minusButton.Visible = false

local plusButton = Instance.new("TextButton", ScreenGui)
plusButton.Size = UDim2.new(0,40,0,40)
plusButton.Position = UDim2.new(1,-70,1,-95)
plusButton.Text = "➕"
plusButton.BackgroundColor3 = Color3.fromRGB(0,80,0)
plusButton.TextColor3 = Color3.new(1,1,1)
plusButton.Visible = false

local speedLabel = Instance.new("TextLabel", ScreenGui)
speedLabel.Size = UDim2.new(0,60,0,40)
speedLabel.Position = UDim2.new(1,-180,1,-95)
speedLabel.Text = tostring(flySpeed)
speedLabel.BackgroundColor3 = Color3.fromRGB(0,0,80)
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Visible = false

upButton.MouseButton1Down:Connect(function() upHeld = true end)
upButton.MouseButton1Up:Connect(function() upHeld = false end)
downButton.MouseButton1Down:Connect(function() downHeld = true end)
downButton.MouseButton1Up:Connect(function() downHeld = false end)

minusButton.MouseButton1Click:Connect(function()
    flySpeed = math.max(1, flySpeed - 5)
    speedLabel.Text = tostring(flySpeed)
end)
plusButton.MouseButton1Click:Connect(function()
    flySpeed = math.min(100, flySpeed + 5)
    speedLabel.Text = tostring(flySpeed)
end)

createButton("Fly (Toggle)", function()
    local plr = Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    flying = not flying
    if flying then
        bv = Instance.new("BodyVelocity", hrp)
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bv.Velocity = Vector3.zero

        bg = Instance.new("BodyGyro", hrp)
        bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
        bg.P = 10000
        bg.CFrame = hrp.CFrame

        upButton.Visible = true
        downButton.Visible = true
        minusButton.Visible = true
        plusButton.Visible = true
        speedLabel.Visible = true

        RunService.RenderStepped:Connect(function()
            if flying and bv and bg then
                local cam = workspace.CurrentCamera
                bg.CFrame = cam.CFrame
                local move = Vector3.zero

                if UserInputService.TouchEnabled then
                    move = char:FindFirstChild("Humanoid").MoveDirection
                else
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move + Vector3.new(0,-1,0) end
                end

                if upHeld then move = move + Vector3.new(0,1,0) end
                if downHeld then move = move + Vector3.new(0,-1,0) end
                bv.Velocity = move * flySpeed
            end
        end)
    else
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        upButton.Visible = false
        downButton.Visible = false
        minusButton.Visible = false
        plusButton.Visible = false
        speedLabel.Visible = false
    end
end)

-- ESP Player
local espEnabled = false
createButton("ESP Player (Toggle)", function()
    espEnabled = not espEnabled
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if espEnabled then
                local highlight = Instance.new("Highlight", p.Character)
                highlight.Name = "FattanESP"
                highlight.FillColor = Color3.fromRGB(0,255,255)
                highlight.OutlineColor = Color3.fromRGB(0,0,0)

                if not p.Character:FindFirstChild("NameTagESP") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "NameTagESP"
                    billboard.Size = UDim2.new(0,200,0,50)
                    billboard.StudsOffset = Vector3.new(0,3,0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")

                    local label = Instance.new("TextLabel", billboard)
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.Text = p.Name
                    label.TextColor3 = Color3.new(1,1,1)
                    label.Font = Enum.Font.GothamBold
                    label.TextScaled = true
                    label.TextStrokeTransparency = 0
                    label.TextStrokeColor3 = Color3.new(0,0,0)
                end
            else
                if p.Character:FindFirstChild("FattanESP") then p.Character.FattanESP:Destroy() end
                if p.Character:FindFirstChild("NameTagESP") then p.Character.NameTagESP:Destroy() end
            end
        end
    end
end)

-- Player Selector
local PlayerFrame = Instance.new("Frame", MainFrame)
PlayerFrame.Size = UDim2.new(1,-10,0,150)
PlayerFrame.BackgroundColor3 = Color3.fromRGB(20,20,50)

local PlayerList = Instance.new("ScrollingFrame", PlayerFrame)
PlayerList.Size = UDim2.new(1,0,1,0)
PlayerList.CanvasSize = UDim2.new(0,0,0,0)
PlayerList.ScrollBarThickness = 6

local UIListLayout2 = Instance.new("UIListLayout", PlayerList)
UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder

local selectedPlayer = nil
local function refreshPlayerList()
    for _, c in pairs(PlayerList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer then
            local btn = Instance.new("TextButton", PlayerList)
            btn.Size = UDim2.new(1,-5,0,30)
            btn.BackgroundColor3 = Color3.fromRGB(0,60,120)
            btn.Text = p.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.MouseButton1Click:Connect(function() selectedPlayer = p.Name end)
        end
    end
    PlayerList.CanvasSize = UDim2.new(0,0,0,UIListLayout2.AbsoluteContentSize.Y)
end
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

createButton("Teleport ke Player (Selected)", function()
    if selectedPlayer then
        local plr = Players.LocalPlayer
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character:WaitForChild("HumanoidRootPart").CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
        end
    end
end)

createButton("Freeze Player Visual (Selected)", function()
    if selectedPlayer then
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local ice = Instance.new("Part", workspace)
            ice.Size = Vector3.new(6,8,6)
            ice.Anchored = true
            ice.CanCollide = false
            ice.Color = Color3.fromRGB(150,220,255)
            ice.Material = Enum.Material.Ice
            ice.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
end)

createButton("Tarik Player (Selected)", function()
    if selectedPlayer then
        local plr = Players.LocalPlayer
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local attachment1 = Instance.new("Attachment", plr.Character.HumanoidRootPart)
            local attachment2 = Instance.new("Attachment", target.Character.HumanoidRootPart)
            local rope = Instance.new("RopeConstraint", plr.Character.HumanoidRootPart)
            rope.Attachment0 = attachment1
            rope.Attachment1 = attachment2
            rope.Length = 10
        end
    end
end)

-- WalkSpeed
createButton("WalkSpeed 50", function()
    local hum = Players.LocalPlayer.Character:WaitForChild("Humanoid")
    hum.WalkSpeed = 50
end)

-- Delete Part Scan + Confirm
local scanning = false
local originalColors = {}
local pendingDelete = nil

local confirmGui = Instance.new("ScreenGui", CoreGui)
confirmGui.Name = "ConfirmDeleteGui"
confirmGui.Enabled = false

local confirmFrame = Instance.new("Frame", confirmGui)
confirmFrame.Size = UDim2.new(0,200,0,100)
confirmFrame.Position = UDim2.new(0.5,-100,0.8,0)
confirmFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local confirmText = Instance.new("TextLabel", confirmFrame)
confirmText.Size = UDim2.new(1,0,0.5,0)
confirmText.Text = "Hapus Part ini?"
confirmText.TextColor3 = Color3.new(1,1,1)
confirmText.BackgroundTransparency = 1
confirmText.Font = Enum.Font.GothamBold
confirmText.TextScaled = true

local yesBtn = Instance.new("TextButton", confirmFrame)
yesBtn.Size = UDim2.new(0.5,0,0.5,0)
yesBtn.Position = UDim2.new(0,0,0.5,0)
yesBtn.Text = "✅ Ya"
yesBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
yesBtn.TextColor3 = Color3.new(1,1,1)

local noBtn = Instance.new("TextButton", confirmFrame)
noBtn.Size = UDim2.new(0.5,0,0.5,0)
noBtn.Position = UDim2.new(0.5,0,0.5,0)
noBtn.Text = "❌ Tidak"
noBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
noBtn.TextColor3 = Color3.new(1,1,1)

yesBtn.MouseButton1Click:Connect(function()
    if pendingDelete then
        pendingDelete:Destroy()
        originalColors[pendingDelete] = nil
        pendingDelete = nil
    end
    confirmGui.Enabled = false
end)

noBtn.MouseButton1Click:Connect(function()
    if pendingDelete and pendingDelete.Parent then
        pendingDelete.Color = originalColors[pendingDelete] or Color3.fromRGB(255,255,255)
        pendingDelete.Material = Enum.Material.Plastic
    end
    pendingDelete = nil
    confirmGui.Enabled = false
end)

createButton("Scan Parts (Toggle)", function()
    scanning = not scanning
    if scanning then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                originalColors[v] = v.Color
                v.Color = Color3.fromRGB(255,0,0)
                v.Material = Enum.Material.Neon
                local click = v:FindFirstChildOfClass("ClickDetector") or Instance.new("ClickDetector", v)
                click.MaxActivationDistance = 100
                click.MouseClick:Connect(function(player)
                    if player == Players.LocalPlayer and scanning and not pendingDelete then
                        pendingDelete = v
                        v.Color = Color3.fromRGB(255,255,0)
                        confirmGui.Enabled = true
                    end
                end)
            end
        end
    else
        for part, col in pairs(originalColors) do
            if part and part.Parent then
                part.Color = col
                part.Material = Enum.Material.Plastic
                if part:FindFirstChildOfClass("ClickDetector") then part:FindFirstChildOfClass("ClickDetector"):Destroy() end
            end
        end
        originalColors = {}
    end
end)

createButton("Delete All Parts", function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v:Destroy() end
    end
end)

createButton("Restore Normal Parts", function()
    for part, col in pairs(originalColors) do
        if part and part.Parent then
            part.Color = col
            part.Material = Enum.Material.Plastic
            if part:FindFirstChildOfClass("ClickDetector") then part:FindFirstChildOfClass("ClickDetector"):Destroy() end
        end
    end
    originalColors = {}
    scanning = false
end)

-- Admin Logo Elegan
local AdminText = Instance.new("TextLabel", ScreenGui)
AdminText.Size = UDim2.new(0,250,0,60)
AdminText.Position = UDim2.new(0.5,-125,0,10)
AdminText.Text = "OWNER"
AdminText.TextColor3 = Color3.fromRGB(255,215,0)
AdminText.Font = Enum.Font.GothamBlack
AdminText.TextScaled = true
AdminText.TextStrokeTransparency = 0
AdminText.TextStrokeColor3 = Color3.new(0,0,0)
AdminText.BackgroundTransparency = 1

-- Contact Info
local Contact = Instance.new("TextLabel", MainFrame)
Contact.Size = UDim2.new(1,-10,0,30)
Contact.Text = "Contact: FattanHub v1.0"
Contact.TextColor3 = Color3.new(1,1,1)
Contact.BackgroundTransparency = 1
Contact.Font = Enum.Font.SourceSansBold
Contact.TextSize = 14
