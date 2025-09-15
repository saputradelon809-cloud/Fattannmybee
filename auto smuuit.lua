-- AutoSummitDelta_Teleport.lua
-- Auto Summit urut CP1 → CP9 (respawn balik CP1) + indikator CP aktif
-- GUI: FATTAN HUB

local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

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
local currentCP = 0 -- indikator CP aktif

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
        currentCP = i
        cpLabel.Text = "📍 CP: " .. tostring(i) .. "/" .. tostring(#checkpoints)
        teleportTo(pos)
        task.wait(delayPerCP)
        if i == #checkpoints then
            cpLabel.Text = "✅ Summit! Respawn..."
            task.wait(1)
            player.Character:BreakJoints() -- respawn summit
            task.wait(3) -- delay biar respawn selesai
        end
    end
end

-- auto jalan setelah respawn
player.CharacterAdded:Connect(function()
    if autoLoop then
        task.wait(2)
        runAutoSummit()
    end
end)

-- === GUI ===
local gui = Instance.new("ScreenGui")
gui.Name = "SummitTPGUI"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 120)
frame.Position = UDim2.new(0.7, 0, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

-- draggable manual
local dragging, dragInput, dragStart, startPos
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Label FATTAN HUB
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -10, 0, 25)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextScaled = true
title.Text = "🔥 FATTAN HUB 🔥"

-- tombol Auto Loop
local loopBtn = Instance.new("TextButton", frame)
loopBtn.Size = UDim2.new(1, -10, 0, 40)
loopBtn.Position = UDim2.new(0, 5, 0, 35)
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

-- label indikator CP
cpLabel = Instance.new("TextLabel", frame)
cpLabel.Size = UDim2.new(1, -10, 0, 30)
cpLabel.Position = UDim2.new(0, 5, 0, 80)
cpLabel.BackgroundTransparency = 1
cpLabel.TextColor3 = Color3.new(1, 1, 1)
cpLabel.TextScaled = true
cpLabel.Text = "📍 CP: 0/" .. tostring(#checkpoints)

print("[AutoSummitDelta] ✅ Auto teleport urut + GUI draggable + indikator CP + FATTAN HUB.")
