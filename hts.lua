-- ✅ Fattan Hub - Auto Teleport CP + Respawn (Gold Bubble Edition, Fast 2s)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- 🔄 Daftar koordinat CP
local checkpoints = {
    Vector3.new(161, 326, 373),
    Vector3.new(400, 394, 281),
    Vector3.new(663, 517, 85),
    Vector3.new(453, 734, -141),
    Vector3.new(50, 858, -332),
    Vector3.new(-308, 858, -160),
    Vector3.new(-438, 1070, 219) -- Summit
}

local running = false
local waitAfterRespawn = 3
local delayPerCP = 2 -- ⚡ delay per CP jadi 2 detik

-- Teleport
local function tpTo(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
end

-- Respawn
local function respawn()
    if player.Character then
        player.Character:BreakJoints()
    end
end

-- Auto TP loop
local function autoTP(statusLabel)
    while running do
        for i, pos in ipairs(checkpoints) do
            if not running then break end
            tpTo(pos)
            statusLabel.Text = "⏳ Menuju CP " .. i
            task.wait(delayPerCP)

            if i == #checkpoints and running then
                statusLabel.Text = "🏆 Summit Tercapai! Respawn..."
                respawn()
                player.CharacterAdded:Wait()
                task.wait(waitAfterRespawn)
            end
        end
    end
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FattanHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 150)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 20, 5)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = frame

-- Bubble effect
task.spawn(function()
    while gui.Parent do
        local bubble = Instance.new("Frame")
        bubble.Size = UDim2.new(0, math.random(15, 35), 0, math.random(15, 35))
        bubble.Position = UDim2.new(math.random(), 0, 1, 0)
        bubble.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        bubble.BackgroundTransparency = 0.6
        bubble.BorderSizePixel = 0
        bubble.ZIndex = -1
        local bubbleCorner = Instance.new("UICorner")
        bubbleCorner.CornerRadius = UDim.new(1, 0)
        bubbleCorner.Parent = bubble
        bubble.Parent = frame

        game:GetService("TweenService"):Create(
            bubble,
            TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            {Position = UDim2.new(bubble.Position.X.Scale, 0, -0.2, 0), BackgroundTransparency = 1}
        ):Play()

        game:GetService("Debris"):AddItem(bubble, 4)
        task.wait(math.random(1,3))
    end
end)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 40)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundColor3 = Color3.fromRGB(50, 35, 5)
title.Text = "🏆 Fattan Hub"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = title

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 0, 25)
status.Position = UDim2.new(0, 5, 0, 50)
status.BackgroundTransparency = 1
status.Text = "Status: Idle"
status.TextScaled = true
status.TextColor3 = Color3.fromRGB(255, 255, 200)
status.Font = Enum.Font.SourceSansBold
status.Parent = frame

-- START
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.5, -10, 0, 40)
startBtn.Position = UDim2.new(0, 5, 1, -45)
startBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
startBtn.Text = "START"
startBtn.TextScaled = true
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.SourceSansBold
startBtn.Parent = frame

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 12)
startCorner.Parent = startBtn

-- STOP
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.5, -10, 0, 40)
stopBtn.Position = UDim2.new(0.5, 5, 1, -45)
stopBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
stopBtn.Text = "STOP"
stopBtn.TextScaled = true
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Font = Enum.Font.SourceSansBold
stopBtn.Parent = frame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 12)
stopCorner.Parent = stopBtn

-- Logic tombol
startBtn.MouseButton1Click:Connect(function()
    if not running then
        running = true
        status.Text = "▶️ Running..."
        task.spawn(function() autoTP(status) end)
    end
end)

stopBtn.MouseButton1Click:Connect(function()
    running = false
    status.Text = "⏹️ Stopped"
end)
