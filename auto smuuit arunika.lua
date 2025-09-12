-- 🔥 AUTO SUMMIT PRO V9 🔥
-- ✅ Save CP permanen (workspace.AutoCheckpoints)
-- ✅ Bisa beri nama CP manual
-- ✅ Delete CP langsung dari GUI
-- ✅ Respawn Safe (fitur tetap aktif setelah respawn)
-- ✅ Auto Play berurutan / Play manual
-- ✅ GUI draggable + tombol lampu merah/hijau

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- ==================================================
-- 🔄 Update root setiap respawn
local function bindCharacter(newChar)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
    print("⚡ Character respawned, root updated!")
end
player.CharacterAdded:Connect(bindCharacter)

-- 📂 Folder CP utama
local mainFolder = workspace:FindFirstChild("AutoCheckpoints")
if not mainFolder then
    mainFolder = Instance.new("Folder")
    mainFolder.Name = "AutoCheckpoints"
    mainFolder.Parent = workspace
end

-- 🔄 Status
local status = {
    noclip = false,
    antiAfk = false,
    autoPlay = false
}

-- ==================================================
-- 🚪 NOCLIP
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
local vu = game:GetService("VirtualUser")
player.Idled:Connect(function()
    if status.antiAfk then
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- ==================================================
-- ➕ SIMPAN CP
local function createCheckpoint(cpName, position)
    if not mainFolder:FindFirstChild(cpName) then
        local cp = Instance.new("Part")
        cp.Name = cpName
        cp.Anchored = true
        cp.CanCollide = true
        cp.Size = Vector3.new(4,1,4)
        cp.Position = position
        cp.Color = Color3.fromRGB(255, 200, 0)
        cp.TopSurface = Enum.SurfaceType.Smooth
        cp.BottomSurface = Enum.SurfaceType.Smooth
        cp.Parent = mainFolder
        print("✅ CP disimpan:", cpName)
    else
        print("⚠️ CP sudah ada dengan nama itu!")
    end
end

-- ❌ DELETE CP
local function deleteCheckpoint(cpName)
    local cp = mainFolder:FindFirstChild(cpName)
    if cp then
        cp:Destroy()
        print("🗑️ CP dihapus:", cpName)
    else
        print("⚠️ Tidak ada CP dengan nama:", cpName)
    end
end

-- ==================================================
-- 🚩 AUTO PLAY SEMUA CP
local function playAllCP()
    status.autoPlay = true
    local cps = mainFolder:GetChildren()
    table.sort(cps, function(a,b) return a.Name < b.Name end)

    for _, cp in ipairs(cps) do
        if not status.autoPlay then break end
        if not root or not root.Parent then
            character = player.Character or player.CharacterAdded:Wait()
            root = character:WaitForChild("HumanoidRootPart")
        end
        root.CFrame = cp.CFrame + Vector3.new(0,5,0)
        task.wait(2)
    end
end

-- ==================================================
-- 🖼️ GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AutoSummitGui"

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 450)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = ScreenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "🔥 Auto Summit PRO V9"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

-- 🔘 Toggle button + lampu indikator
local function makeToggle(name, yPos, key, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Parent = frame

    local lamp = Instance.new("Frame")
    lamp.Size = UDim2.new(0, 20, 0, 20)
    lamp.Position = UDim2.new(0, 240, 0, yPos+5)
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

-- Tombol utama
makeToggle("Noclip", 40, "noclip")
makeToggle("Anti AFK", 80, "antiAfk")
makeToggle("Auto Play All CP", 120, "autoPlay", function(state)
    if state then playAllCP() end
end)

-- 📂 List CP manual play/delete
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 0, 230)
scroll.Position = UDim2.new(0, 10, 0, 160)
scroll.BackgroundColor3 = Color3.fromRGB(50,50,50)
scroll.ScrollBarThickness = 6
scroll.Parent = frame

local function refreshCPList()
    scroll:ClearAllChildren()
    local y = 0
    for _, cp in ipairs(mainFolder:GetChildren()) do
        local playBtn = Instance.new("TextButton")
        playBtn.Size = UDim2.new(0.7, -5, 0, 30)
        playBtn.Position = UDim2.new(0, 5, 0, y)
        playBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
        playBtn.Text = "▶️ "..cp.Name
        playBtn.TextColor3 = Color3.fromRGB(255,255,255)
        playBtn.Font = Enum.Font.SourceSans
        playBtn.TextSize = 14
        playBtn.Parent = scroll
        playBtn.MouseButton1Click:Connect(function()
            if root then
                root.CFrame = cp.CFrame + Vector3.new(0,5,0)
            end
        end)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.3, -5, 0, 30)
        delBtn.Position = UDim2.new(0.7, 5, 0, y)
        delBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
        delBtn.Text = "🗑️"
        delBtn.TextColor3 = Color3.fromRGB(255,255,255)
        delBtn.Font = Enum.Font.SourceSansBold
        delBtn.TextSize = 14
        delBtn.Parent = scroll
        delBtn.MouseButton1Click:Connect(function()
            deleteCheckpoint(cp.Name)
            refreshCPList()
        end)

        y = y + 35
    end
    scroll.CanvasSize = UDim2.new(0,0,0,y)
end

refreshCPList()

-- Input box + Save CP
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0, 220, 0, 30)
textBox.Position = UDim2.new(0, 10, 0, 400)
textBox.BackgroundColor3 = Color3.fromRGB(70,70,70)
textBox.Text = "Nama_CP"
textBox.TextColor3 = Color3.fromRGB(255,255,255)
textBox.Font = Enum.Font.SourceSans
textBox.TextSize = 14
textBox.Parent = frame

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0, 90, 0, 30)
saveBtn.Position = UDim2.new(0, 240, 0, 400)
saveBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)
saveBtn.Text = "💾 Save"
saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
saveBtn.Font = Enum.Font.SourceSansBold
saveBtn.TextSize = 14
saveBtn.Parent = frame

saveBtn.MouseButton1Click:Connect(function()
    local name = textBox.Text ~= "" and textBox.Text or ("CP_"..tostring(#mainFolder:GetChildren()+1))
    createCheckpoint(name, root.Position)
    refreshCPList()
end)
