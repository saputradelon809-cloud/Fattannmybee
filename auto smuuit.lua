-- AutoSummitDelta_Teleport.lua
-- Auto Summit teleport cepat + draggable GUI (Delta Ready)

local player = game.Players.LocalPlayer

-- === SETTINGS ===
local checkpoints = {
    Vector3.new(528, 153, -181), -- CP1
    Vector3.new(719, 113, 233),  -- CP2
    Vector3.new(736, 121, 585),  -- CP3
    Vector3.new(768, 299, 731),  -- CP4
    Vector3.new(892, 329, 1072), -- CP5
    Vector3.new(1523, 345, 1085),-- CP6
    Vector3.new(1473, 421, 500), -- CP7
    Vector3.new(1509, 421, 56),  -- CP8
    Vector3.new(2149, 621, 187)  -- CP9 Summit
}
local delayPerCP = 2 -- detik antar teleport
local autoLoop = false

-- === CORE ===
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function teleportTo(pos)
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

local function runAutoSummit()
    for i, pos in ipairs(checkpoints) do
        if not autoLoop then break end
        teleportTo(pos)
        task.wait(delayPerCP)
        if i == #checkpoints then
            player.Character:BreakJoints() -- respawn summit
        end
    end
end

-- auto jalan setiap respawn kalau loop aktif
player.CharacterAdded:Connect(function()
    if autoLoop then
        task.wait(2)
        runAutoSummit()
    end
end)

-- === GUI ===
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "SummitTPGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 100)
frame.Position = UDim2.new(0.7, 0, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true -- 🔥 bisa geser dengan touch / mouse

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1, -10, 0, 40)
autoBtn.Position = UDim2.new(0, 5, 0, 5)
autoBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
autoBtn.TextColor3 = Color3.new(1, 1, 1)
autoBtn.TextScaled = true
autoBtn.Text = "▶ Auto Summit"
autoBtn.MouseButton1Click:Connect(function()
    autoLoop = true
    runAutoSummit()
    autoLoop = false
end)

local loopBtn = Instance.new("TextButton", frame)
loopBtn.Size = UDim2.new(1, -10, 0, 40)
loopBtn.Position = UDim2.new(0, 5, 0, 50)
loopBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
loopBtn.TextColor3 = Color3.new(1, 1, 1)
loopBtn.TextScaled = true
loopBtn.Text = "🔁 Auto Loop: OFF"
loopBtn.MouseButton1Click:Connect(function()
    autoLoop = not autoLoop
    loopBtn.Text = autoLoop and "🔁 Auto Loop: ON" or "🔁 Auto Loop: OFF"
    if autoLoop then
        runAutoSummit()
    end
end)

print("[AutoSummitDelta] Auto teleport cepat aktif + GUI draggable.")
