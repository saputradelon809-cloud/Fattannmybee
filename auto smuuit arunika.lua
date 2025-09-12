--[[ 
🔥 AUTO SUMMIT GUI SYSTEM V6 🔥 (Fix tombol aktif)
================================================
Fitur:
✅ Save CP ke folder (CP1, CP2, dst)
✅ List folder CP tampil di GUI
✅ Play CP satu-satu (manual)
✅ Auto Play semua CP berurutan
✅ Tombol On/Off untuk Noclip & AntiAFK (lampu indikator berfungsi)
✅ GUI draggable/geser
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- ==================================================
-- 📂 FOLDER UTAMA AUTO CP
-- ==================================================
local mainFolder = workspace:FindFirstChild("AutoCheckpoints")
if not mainFolder then
    mainFolder = Instance.new("Folder")
    mainFolder.Name = "AutoCheckpoints"
    mainFolder.Parent = workspace
end

-- ==================================================
-- 🔄 STATUS FITUR
-- ==================================================
local status = {
    noclip = false,
    antiAfk = false,
    autoPlay = false
}

-- ==================================================
-- ➕ SIMPAN CP KE SUB-FOLDER
-- ==================================================
local function createCheckpoint(folderName, position)
    local folder = mainFolder:FindFirstChild(folderName)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = folderName
        folder.Parent = mainFolder
    end

    local cpName = "Point_" .. tostring(#folder:GetChildren() + 1)
    local cp = Instance.new("Part")
    cp.Name = cpName
    cp.Anchored = true
    cp.CanCollide = true
    cp.Size = Vector3.new(4,1,4)
    cp.Position = position
    cp.Color = Color3.fromRGB(255, 200, 0)
    cp.TopSurface = Enum.SurfaceType.Smooth
    cp.BottomSurface = Enum.SurfaceType.Smooth
    cp.Parent = folder

    print("✅ CP disimpan di", folderName, ":", cpName, position)
end

-- ==================================================
-- 🚪 NOCLIP TANPA BODYVELOCITY
-- ==================================================
RunService.Stepped:Connect(function()
    if status.noclip and character then
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
    if status.antiAfk then
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- ==================================================
-- 🚩 AUTO PLAY CP
-- ==================================================
local function playAllCP()
    status.autoPlay = true
    local folders = mainFolder:GetChildren()
    table.sort(folders, function(a,b) return a.Name < b.Name end)

    for _, folder in ipairs(folders) do
        if not status.autoPlay then break end
        local cps = folder:GetChildren()
        table.sort(cps, function(a,b) return a.Name < b.Name end)
        for _, cp in ipairs(cps) do
            if not status.autoPlay then break end
            root.CFrame = cp.CFrame + Vector3.new(0,5,0)
            task.wait(2)
        end
    end
end

-- ==================================================
-- 🖼️ GUI
-- ==================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AutoSummitGui"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true -- biar bisa digeser
frame.Parent = ScreenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "🔥 Auto Summit Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

-- 🔘 tombol toggle dengan lampu indikator
local function makeToggle(name, yPos, key, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = frame

    local lamp = Instance.new("Frame")
    lamp.Size = UDim2.new(0, 20, 0, 20)
    lamp.Position = UDim2.new(0, 220, 0, yPos+5)
    lamp.BackgroundColor3 = Color3.fromRGB(200,0,0)
    lamp.Parent = frame

    btn.MouseButton1Click:Connect(function()
        status[key] = not status[key]
        if status[key] then
            lamp.BackgroundColor3 = Color3.fromRGB(0,200,0)
            if callback then callback(true) end
        else
            lamp.BackgroundColor3 = Color3.fromRGB(200,0,0)
            if callback then callback(false) end
        end
    end)
end

-- tombol toggle
makeToggle("Noclip", 40, "noclip")
makeToggle("Anti AFK", 80, "antiAfk")
makeToggle("Auto Play All CP", 120, "autoPlay", function(state)
    if state then
        playAllCP()
    end
end)

-- 📂 List CP manual play
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 0, 180)
scroll.Position = UDim2.new(0, 10, 0, 160)
scroll.BackgroundColor3 = Color3.fromRGB(50,50,50)
scroll.ScrollBarThickness = 6
scroll.Parent = frame

local function refreshCPList()
    scroll:ClearAllChildren()
    local y = 0
    for _, folder in ipairs(mainFolder:GetChildren()) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
        btn.Text = "Play "..folder.Name
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.Parent = scroll
        btn.MouseButton1Click:Connect(function()
            local cps = folder:GetChildren()
            table.sort(cps, function(a,b) return a.Name < b.Name end)
            for _, cp in ipairs(cps) do
                root.CFrame = cp.CFrame + Vector3.new(0,5,0)
                task.wait(2)
            end
        end)
        y = y + 35
    end
    scroll.CanvasSize = UDim2.new(0,0,0,y)
end

refreshCPList()

-- tombol Save CP
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0, 280, 0, 30)
saveBtn.Position = UDim2.new(0, 10, 0, 310)
saveBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
saveBtn.Text = "💾 Save CP ke Folder Baru (CP_X)"
saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
saveBtn.Font = Enum.Font.SourceSansBold
saveBtn.TextSize = 14
saveBtn.Parent = frame

saveBtn.MouseButton1Click:Connect(function()
    local folderName = "CP"..tostring(#mainFolder:GetChildren() + 1)
    createCheckpoint(folderName, root.Position)
    refreshCPList()
end)
