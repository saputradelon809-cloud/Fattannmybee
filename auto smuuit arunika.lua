-- 🏔️ AUTO SUMMIT PRO V13 🏔️
-- by ChatGPT
-- 🚀 AutoPlay | NextCP | ManualCP | Noclip | AntiAFK
-- ✅ Support Checkpoint Asli Arunika (bunyi + save)

-- ==================================================
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- ==================================================
-- Update root tiap respawn
local function bindCharacter(newChar)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
end
player.CharacterAdded:Connect(bindCharacter)

-- ==================================================
-- Status
local status = {
    noclip = false,
    antiAfk = false,
    autoPlay = false
}

-- ==================================================
-- Noclip
RunService.Stepped:Connect(function()
    if status.noclip and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Anti AFK
player.Idled:Connect(function()
    if status.antiAfk then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- ==================================================
-- Ambil semua checkpoint asli
local function getGameCheckpoints()
    local cps = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(obj.Name:lower(), "cp") then
            table.insert(cps, obj)
        end
    end
    table.sort(cps, function(a,b) return a.Position.Y < b.Position.Y end)
    return cps
end

-- Tween teleport
local function tweenTo(targetCFrame, duration)
    if not root or not root.Parent then
        character = player.Character or player.CharacterAdded:Wait()
        root = character:WaitForChild("HumanoidRootPart")
    end
    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- ==================================================
-- Auto Play Semua CP
local function playAllCP()
    status.autoPlay = true
    local cps = getGameCheckpoints()
    for _, cp in ipairs(cps) do
        if not status.autoPlay then break end
        tweenTo(cp.CFrame + Vector3.new(0,3,0), 2)
        task.wait(4) -- biar bunyi + save checkpoint
    end
end

-- Stop Auto Play
local function stopAutoPlay()
    status.autoPlay = false
end

-- Next CP sekali
local function playNextCP()
    local cps = getGameCheckpoints()
    local currentPos = root.Position
    local nextCP = nil
    for _, cp in ipairs(cps) do
        local dist = (cp.Position - currentPos).Magnitude
        if dist > 10 then
            nextCP = cp
            break
        end
    end
    if nextCP then
        tweenTo(nextCP.CFrame + Vector3.new(0,3,0), 2)
        task.wait(4)
    else
        warn("⚠️ Tidak ada CP berikutnya")
    end
end

-- Manual CP
local function playOneCP(cp)
    tweenTo(cp.CFrame + Vector3.new(0,3,0), 2)
    task.wait(4)
end

-- ==================================================
-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoSummitGui"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 380)
frame.Position = UDim2.new(0.35, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "🏔️ Auto Summit PRO V13"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame

local scrolling = Instance.new("ScrollingFrame")
scrolling.Size = UDim2.new(1, -10, 1, -40)
scrolling.Position = UDim2.new(0, 5, 0, 35)
scrolling.CanvasSize = UDim2.new(0, 0, 6, 0)
scrolling.BackgroundTransparency = 1
scrolling.ScrollBarThickness = 6
scrolling.Parent = frame

-- Toggle dengan lampu
local function makeToggle(text, order, stateTable, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, -10, 0, 28)
    btn.Position = UDim2.new(0, 5, 0, (order-1)*32)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = scrolling

    local lamp = Instance.new("Frame")
    lamp.Size = UDim2.new(0,20,0,20)
    lamp.Position = UDim2.new(1, -30, 0.5, -10)
    lamp.BackgroundColor3 = Color3.fromRGB(200,0,0)
    lamp.Parent = btn

    btn.MouseButton1Click:Connect(function()
        stateTable[key] = not stateTable[key]
        lamp.BackgroundColor3 = stateTable[key] and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    end)
end

-- Tombol biasa
local function makeButton(text, order, callback, parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.Position = UDim2.new(0, 5, 0, (order-1)*32)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = parent or scrolling
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ==================================================
-- Tambah tombol utama
makeToggle("🚪 Noclip", 1, status, "noclip")
makeToggle("🕹️ Anti AFK", 2, status, "antiAfk")
makeButton("▶️ Auto Play Semua CP", 3, playAllCP)
makeButton("⏹️ Stop Auto Play", 4, stopAutoPlay)
makeButton("⏭️ Next CP (1x)", 5, playNextCP)

-- Manual CP list
local cps = getGameCheckpoints()
local yOffset = 6
for i, cp in ipairs(cps) do
    makeButton("▶️ CP"..i, yOffset+i, function()
        playOneCP(cp)
    end)
end
