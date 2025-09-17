-- ✅ Fattan Hub - Auto Teleport CP pakai Vector3 + Auto Respawn (Fix Tidak Mati di Awal)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Daftar koordinat CP (Vector3)
local checkpoints = {
Vector3(-715, 176, 412)
2. Vector3(-928, 167, 100)
3. Vector3(-1237, 151, -55)
4. Vector3(-1357, 165, -824)
5. Vector3(-1315, 228, -993)
6. Vector3(-1363, 373, -1488)
7. Vector3(-1323, 257, -2251)
8. Vector3(-1239, 223, -2652)
9. Vector3(-1243, 470, -3392) -- Summit
}

local running = false
local waitAfterRespawn = 3

-- Teleport
local function tpTo(pos)
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
end

-- Respawn (hanya dipakai di Summit)
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

            -- Teleport ke CP
            tpTo(pos)
            statusLabel.Text = "⏳ Menuju CP " .. i
            task.wait(3)

            -- Kalau sudah di Summit → respawn + ulang
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
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FattanHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "🏆 Fattan Hub"
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 215, 0)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -10, 0, 25)
status.Position = UDim2.new(0, 5, 0, 35)
status.BackgroundTransparency = 1
status.Text = "Status: Idle"
status.TextScaled = true
status.TextColor3 = Color3.fromRGB(255,255,255)

local startBtn = Instance.new("TextButton", frame)
startBtn.Size = UDim2.new(0.5, -5, 0, 40)
startBtn.Position = UDim2.new(0, 5, 1, -45)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
startBtn.Text = "START"
startBtn.TextScaled = true
startBtn.TextColor3 = Color3.new(1,1,1)

local stopBtn = Instance.new("TextButton", frame)
stopBtn.Size = UDim2.new(0.5, -5, 0, 40)
stopBtn.Position = UDim2.new(0.5, 0, 1, -45)
stopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
stopBtn.Text = "STOP"
stopBtn.TextScaled = true
stopBtn.TextColor3 = Color3.new(1,1,1)

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
