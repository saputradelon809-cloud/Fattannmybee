--[[ 
🔥 AUTO SUMMIT GUI SYSTEM 🔥
===========================================
Fitur:
✅ Auto Summit per CP
✅ Noclip tanpa BodyVelocity
✅ Anti AFK
✅ GUI rapi + tombol ON/OFF
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- ==================================================
-- 📂 BUAT FOLDER AUTO CP
-- ==================================================
local cpsFolder = workspace:FindFirstChild("AutoCheckpoints")
if not cpsFolder then
    cpsFolder = Instance.new("Folder")
    cpsFolder.Name = "AutoCheckpoints"
    cpsFolder.Parent = workspace
end

-- ==================================================
-- ➕ FUNGSI TAMBAH CP
-- ==================================================
local function createCheckpoint(name, position)
    if not cpsFolder:FindFirstChild(name) then
        local cp = Instance.new("Part")
        cp.Name = name
        cp.Anchored = true
        cp.CanCollide = true
        cp.Size = Vector3.new(4,1,4)
        cp.Position = position
        cp.Color = Color3.fromRGB(255, 200, 0)
        cp.TopSurface = Enum.SurfaceType.Smooth
        cp.BottomSurface = Enum.SurfaceType.Smooth
        cp.Parent = cpsFolder
    end
end

-- contoh CP (edit sesuai mapmu)
createCheckpoint("CP1", Vector3.new(0, 10, 0))
createCheckpoint("CP2", Vector3.new(50, 50, 0))
createCheckpoint("CP3", Vector3.new(100, 100, 0))
createCheckpoint("Summit", Vector3.new(150, 150, 0))

-- ==================================================
-- 🔄 FITUR STATUS
-- ==================================================
local noclipEnabled = false
local antiAfkEnabled = false
local autoSummitEnabled = false

-- ==================================================
-- 🚪 NOCLIP TANPA BODYVELOCITY
-- ==================================================
RunService.Stepped:Connect(function()
    if noclipEnabled and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- ==================================================
-- 🕹️ ANTI AFK
-- ==================================================
local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    if antiAfkEnabled then
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- ==================================================
-- 🚩 AUTO SUMMIT
-- ==================================================
local function autoSummit()
    local cps = cpsFolder:GetChildren()
    table.sort(cps, function(a, b) return a.Name < b.Name end)

    for _, cp in ipairs(cps) do
        if not autoSummitEnabled then break end
        task.wait(2)
        root.CFrame = cp.CFrame + Vector3.new(0, 5, 0)
    end
end

-- ==================================================
-- 🖼️ GUI
-- ==================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AutoSummitGui"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 180)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = ScreenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "🔥 Auto Summit Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

-- tombol generator
local function makeButton(name, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = frame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- tombol noclip
makeButton("Toggle Noclip", 40, function()
    noclipEnabled = not noclipEnabled
    print("Noclip:", noclipEnabled)
end)

-- tombol anti afk
makeButton("Toggle Anti AFK", 80, function()
    antiAfkEnabled = not antiAfkEnabled
    print("Anti AFK:", antiAfkEnabled)
end)

-- tombol auto summit
makeButton("Start Auto Summit", 120, function()
    if not autoSummitEnabled then
        autoSummitEnabled = true
        autoSummit()
    else
        autoSummitEnabled = false
    end
    print("Auto Summit:", autoSummitEnabled)
end)
