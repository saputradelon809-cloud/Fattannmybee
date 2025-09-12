-- 🔥 AUTO SUMMIT PRO V12 🔥
-- ✅ Save / Delete / Rename CP
-- ✅ Export / Import CP
-- ✅ AutoPlay TweenService (smooth, anti-detect)
-- ✅ Manual Play CP Tween
-- ✅ Respawn Safe
-- ✅ GUI compact (300x280, draggable)
-- ✅ Toggle features ON/OFF + indikator lampu

-- ==================================================
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- ==================================================
-- 🔄 Update root setiap respawn
local function bindCharacter(newChar)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
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
    end
end

-- ❌ DELETE CP
local function deleteLastCheckpoint()
    local cps = mainFolder:GetChildren()
    if #cps > 0 then
        cps[#cps]:Destroy()
    end
end

-- ==================================================
-- 🚩 MOVE PLAYER pakai TweenService
local function tweenTo(targetCFrame, duration)
    if not root or not root.Parent then
        character = player.Character or player.CharacterAdded:Wait()
        root = character:WaitForChild("HumanoidRootPart")
    end
    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- 🚩 AUTO PLAY SEMUA CP
local function playAllCP()
    status.autoPlay = true
    local cps = mainFolder:GetChildren()
    table.sort(cps, function(a,b) return a.Name < b.Name end)

    for _, cp in ipairs(cps) do
        if not status.autoPlay then break end
        local target = cp.CFrame + Vector3.new(0,5,0)
        tweenTo(target, 2)
        task.wait(0.5 + math.random()) -- delay random biar natural
    end
end

-- 🚩 PLAY MANUAL CP
local function playOneCP(cp)
    local target = cp.CFrame + Vector3.new(0,5,0)
    tweenTo(target, 2)
end

-- ==================================================
-- 📤 EXPORT CP
local function exportCheckpoints()
    local data = {}
    for _, cp in ipairs(mainFolder:GetChildren()) do
        table.insert(data, {name = cp.Name, pos = {cp.Position.X, cp.Position.Y, cp.Position.Z}})
    end
    local str = "return "..HttpService:JSONEncode(data)
    if setclipboard then
        setclipboard(str)
        print("✅ Data CP disalin ke clipboard!")
    else
        print("⚠️ Executor kamu tidak support setclipboard")
    end
end

-- 📥 IMPORT CP
local function importCheckpoints(url)
    local success, data = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and type(data) == "table" then
        for _, cpData in ipairs(data) do
            createCheckpoint(cpData.name, Vector3.new(cpData.pos[1], cpData.pos[2], cpData.pos[3]))
        end
        print("✅ CP diimport dari link!")
    else
        warn("⚠️ Gagal import CP")
    end
end

-- ==================================================
-- GUI COMPACT
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoSummitGui"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 280)
frame.Position = UDim2.new(0.35, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "🏔️ Auto Summit PRO V12"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame

local scrolling = Instance.new("ScrollingFrame")
scrolling.Size = UDim2.new(1, -10, 1, -40)
scrolling.Position = UDim2.new(0, 5, 0, 35)
scrolling.CanvasSize = UDim2.new(0, 0, 3, 0)
scrolling.BackgroundTransparency = 1
scrolling.ScrollBarThickness = 6
scrolling.Parent = frame

-- Fungsi buat tombol toggle + lampu
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

-- Fungsi buat tombol biasa
local function makeButton(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.Position = UDim2.new(0, 5, 0, (order-1)*32)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = scrolling
    btn.MouseButton1Click:Connect(callback)
end

-- ==================================================
-- Tambah tombol2
makeToggle("🚪 Noclip", 1, status, "noclip")
makeToggle("🕹️ Anti AFK", 2, status, "antiAfk")
makeButton("➕ Save CP", 3, function()
    createCheckpoint("CP"..tostring(#mainFolder:GetChildren()+1), root.Position)
end)
makeButton("🗑️ Delete CP terakhir", 4, function()
    deleteLastCheckpoint()
end)
makeButton("▶️ Auto Play Semua CP", 5, function()
    playAllCP()
end)
makeButton("⏹️ Stop Auto Play", 6, function()
    status.autoPlay = false
end)
makeButton("📤 Export CP", 7, function()
    exportCheckpoints()
end)
makeButton("📥 Import CP (isi link di console)", 8, function()
    local url = "PASTE_LINK_GITHUB_DISINI"
    importCheckpoints(url)
end)
