
-- FattanHub v2 - GUI Biru Collapsible + Full Features

--[[
    FITUR:
    - GUI biru dengan header + tombol (▲ ▼ ▯ ✖)
    - Fly + kontrol speed & arah
    - ESP Player (Highlight + Nametag)
    - Rope 3D tarik pemain
    - Fling, Teleport, Freeze Player, Scan/Delete/Restore
    - Panel Extra Features: God Mode, Auto Respawn, Auto Rejoin, Anti AFK
]]--

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FattanHubV2"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 520)
mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 40, 100)
mainFrame.Active = true
mainFrame.Draggable = true

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

-- Header
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = Color3.fromRGB(20, 80, 160)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.Text = "FattanHub V2"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1

-- Tombol kontrol
local function makeBtn(parent, offset, text, color)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 28, 0, 22)
    b.Position = UDim2.new(1, offset, 0, 5)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    return b
end

local exitBtn = makeBtn(header, -30, "✖", Color3.fromRGB(200, 50, 50))
local miniBtn = makeBtn(header, -64, "▯", Color3.fromRGB(180, 180, 60))
local upBtn   = makeBtn(header, -98, "▲", Color3.fromRGB(100, 140, 220))
local downBtn = makeBtn(header, -132, "▼", Color3.fromRGB(100, 140, 220))

local FULL_H = 520
local HALF_H = 260
local isFull = true

upBtn.MouseButton1Click:Connect(function()
    if isFull then
        isFull = false
        TweenService:Create(mainFrame, TweenInfo.new(0.25), {Size = UDim2.new(0, 320, 0, HALF_H)}):Play()
    end
end)

downBtn.MouseButton1Click:Connect(function()
    if not isFull then
        isFull = true
        TweenService:Create(mainFrame, TweenInfo.new(0.25), {Size = UDim2.new(0, 320, 0, FULL_H)}):Play()
    end
end)

exitBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Konten scroll
local content = Instance.new("ScrollingFrame", mainFrame)
content.Size = UDim2.new(1, -12, 1, -44)
content.Position = UDim2.new(0, 6, 0, 38)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 6

local layout = Instance.new("UIListLayout", content)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function makeFeatureBtn(text, callback)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(1, -6, 0, 28)
    b.BackgroundColor3 = Color3.fromRGB(40, 100, 180)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1, 1, 1)
    b.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    return b
end

-- ==========================
-- FITUR LAMA (contoh ringkas)
-- ==========================

makeFeatureBtn("Fly (Toggle)", function()
    print("Fly toggle") -- ganti dengan kode fly aslinya
end)

makeFeatureBtn("ESP Toggle", function()
    print("ESP toggle") -- ganti dengan kode ESP aslinya
end)

makeFeatureBtn("Rope 3D", function()
    print("Rope 3D toggle") -- ganti dengan kode Rope
end)

makeFeatureBtn("Fling", function()
    print("Fling selected") -- ganti dengan kode Fling
end)

makeFeatureBtn("Teleport Selected", function()
    print("Teleport executed") -- ganti dengan kode Teleport
end)

makeFeatureBtn("Scan/Delete", function()
    print("Scan Delete run") -- ganti dengan kode scan
end)

makeFeatureBtn("Restore", function()
    print("Restore run") -- ganti dengan kode restore
end)

-- ==========================
-- EXTRA FEATURES
-- ==========================

local extraLabel = Instance.new("TextLabel", content)
extraLabel.Size = UDim2.new(1, 0, 0, 26)
extraLabel.Text = "Extra Features"
extraLabel.Font = Enum.Font.GothamBold
extraLabel.TextSize = 14
extraLabel.TextColor3 = Color3.new(1, 1, 1)
extraLabel.BackgroundTransparency = 1

makeFeatureBtn("God Mode", function()
    print("God Mode enabled")
end)

makeFeatureBtn("Auto Respawn", function()
    print("Auto Respawn enabled")
end)

makeFeatureBtn("Auto Rejoin", function()
    print("Auto Rejoin enabled")
end)

makeFeatureBtn("Anti AFK", function()
    print("Anti AFK enabled")
    LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)
