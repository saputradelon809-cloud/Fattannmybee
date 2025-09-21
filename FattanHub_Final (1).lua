-- ✅ IZZHUB👑 AutoExec Version
-- Simpan file ini di folder autoexec executor kamu
-- GUI & fungsi otomatis muncul setiap kali join/rejoin

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

-- 📍 Koordinat (base → summit)
local checkpoints = {
    Vector3.new(626, 1800, 3432),   -- Base
    Vector3.new(798, 2151, 3916)    -- Summit
}

local running = false
local delayPerCP = 2
local waitAfterSummit = 3

-- Cek apakah ini hasil rejoin & perlu auto-run
local teleportData = TeleportService:GetLocalPlayerTeleportData()
if teleportData and teleportData.AutoRun then
    running = true
end

-- 🔄 Teleport ke posisi
local function tpTo(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
end

-- 🔁 Loop auto teleport
local function autoTP(statusLabel)
    while running do
        for i, pos in ipairs(checkpoints) do
            if not running then break end
            tpTo(pos)
            statusLabel.Text = "⏳ Menuju CP " .. i
            task.wait(delayPerCP)
            if i == #checkpoints and running then
                statusLabel.Text = "🏔️ Summit Tercapai! Rejoin..."
                task.wait(waitAfterSummit)
                -- Rejoin + kirim AutoRun biar langsung start lagi
                TeleportService:Teleport(game.PlaceId, player, {AutoRun = true})
            end
        end
    end
end

-- 🎨 GUI
local gui = Instance.new("ScreenGui")
gui.Name = "IZZHUB👑"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

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

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 40)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundColor3 = Color3.fromRGB(50, 35, 5)
title.Text = " IZZHUB👑"
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

-- START button
local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.5, -10, 0, 40)
startBtn.Position = UDim2.new(0, 5, 1, -45)
startBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
startBtn.Text = "START"
startBtn.TextScaled = true
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Font = Enum.Font.SourceSansBold
startBtn.Parent = frame
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 12)

-- STOP button
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.5, -10, 0, 40)
stopBtn.Position = UDim2.new(0.5, 5, 1, -45)
stopBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
stopBtn.Text = "STOP"
stopBtn.TextScaled = true
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Font = Enum.Font.SourceSansBold
stopBtn.Parent = frame
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 12)

-- Tombol logic
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

-- 🔥 Auto start kalau rejoin dengan AutoRun
if running then
    status.Text = "▶️ Auto Running..."
    task.spawn(function() autoTP(status) end)
end
