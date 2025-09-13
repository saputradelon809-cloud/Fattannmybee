-- 🏔️ AUTO SUMMIT PRO V18 - Manual Save CP Lebih Jelas
-- ✅ Noclip / Anti AFK / Auto Play / Manual CP / Saved CP + Manual Save CP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- Respawn
local function bindCharacter(newChar)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
end
player.CharacterAdded:Connect(bindCharacter)

-- Status
local status = {noclip=false, antiAfk=false, autoPlay=false}

-- Noclip
RunService.Stepped:Connect(function()
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not status.noclip or part.Name=="HumanoidRootPart"
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

-- Checkpoints
local function getGameCheckpoints()
    local cps = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(obj.Name:lower(),"cp") then
            table.insert(cps,obj)
        end
    end
    table.sort(cps,function(a,b) return a.Position.Y < b.Position.Y end)
    return cps
end

-- Move + touch + save
local savedCPs = {}
local function moveToCP(cp)
    root.CFrame = cp.CFrame + Vector3.new(0,3,0)
    task.wait(0.2)
end

local function touchPart(cp)
    moveToCP(cp)
    firetouchinterest(root, cp, 0)
    task.wait(0.3)
    firetouchinterest(root, cp, 1)
    task.wait(0.5)
    saveCP(cp)
end

-- Save CP
local savedFrame = Instance.new("ScrollingFrame")
savedFrame.Size = UDim2.new(1,-10,0,150)
savedFrame.Position = UDim2.new(0,5,0,200)
savedFrame.BackgroundTransparency = 0.5
savedFrame.CanvasSize = UDim2.new(0,0,2,0)
savedFrame.ScrollBarThickness = 6

function saveCP(cp)
    if not table.find(savedCPs,cp) then
        table.insert(savedCPs,cp)
        -- Buat tombol CP di Saved GUI
        local index = #savedCPs
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-10,0,28)
        btn.Position = UDim2.new(0,5,0,(index-1)*32)
        btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.Text = "Saved CP "..index
        btn.Parent = savedFrame

        -- Lampu indikator hijau/merah
        local lamp = Instance.new("Frame")
        lamp.Size = UDim2.new(0,16,0,16)
        lamp.Position = UDim2.new(1,-20,0.5,-8)
        lamp.BackgroundColor3 = Color3.fromRGB(0,200,0)
        lamp.Parent = btn

        btn.MouseButton1Click:Connect(function()
            moveToCP(cp)
            firetouchinterest(root, cp, 0)
            task.wait(0.3)
            firetouchinterest(root, cp, 1)
        end)
    end
end

-- Auto Play semua CP
local function playAllCP()
    status.autoPlay = true
    local cps = getGameCheckpoints()
    for _,cp in ipairs(cps) do
        if not status.autoPlay then break end
        touchPart(cp)
        task.wait(4)
    end
end

local function stopAutoPlay()
    status.autoPlay = false
end

-- Next CP
local function playNextCP()
    local cps = getGameCheckpoints()
    local currentPos = root.Position
    for _,cp in ipairs(cps) do
        if (cp.Position-currentPos).Magnitude>10 then
            touchPart(cp)
            task.wait(4)
            break
        end
    end
end

local function playOneCP(cp)
    touchPart(cp)
    task.wait(4)
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoSummitGui"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,280,0,460)
frame.Position = UDim2.new(0.35,0,0.25,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.Text = "🏔️ Auto Summit PRO V18"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame

local scrolling = Instance.new("ScrollingFrame")
scrolling.Size = UDim2.new(1,-10,1,-40)
scrolling.Position = UDim2.new(0,5,0,35)
scrolling.CanvasSize = UDim2.new(0,0,6,0)
scrolling.BackgroundTransparency = 1
scrolling.ScrollBarThickness = 6
scrolling.Parent = frame

savedFrame.Parent = frame

local function makeToggle(text,order,stateTable,key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8,-10,0,28)
    btn.Position = UDim2.new(0,5,0,(order-1)*32)
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = scrolling

    local lamp = Instance.new("Frame")
    lamp.Size = UDim2.new(0,20,0,20)
    lamp.Position = UDim2.new(1,-30,0.5,-10)
    lamp.BackgroundColor3 = Color3.fromRGB(200,0,0)
    lamp.Parent = btn

    btn.MouseButton1Click:Connect(function()
        stateTable[key] = not stateTable[key]
        lamp.BackgroundColor3 = stateTable[key] and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    end)
end

local function makeButton(text,order,callback,parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-10,0,28)
    btn.Position = UDim2.new(0,5,0,(order-1)*32)
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = parent or scrolling
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Tombol utama
makeToggle("🚪 Noclip",1,status,"noclip")
makeToggle("🕹️ Anti AFK",2,status,"antiAfk")
makeButton("▶️ Auto Play Semua CP",3,playAllCP)
makeButton("⏹️ Stop Auto Play",4,stopAutoPlay)
makeButton("⏭️ Next CP (1x)",5,playNextCP)
makeButton("💾 Save Current CP",6,function()
    local cps = getGameCheckpoints()
    local closest=nil
    local minDist = math.huge
    for _,cp in ipairs(cps) do
        local dist = (cp.Position-root.Position).Magnitude
        if dist<minDist then
            minDist=dist
            closest=cp
        end
    end
    if closest then
        saveCP(closest)
        print("✅ CP disimpan: "..closest.Name)
    else
        warn("⚠️ Tidak ada CP terdekat untuk disimpan")
    end
end)

-- Manual CP list
local cps = getGameCheckpoints()
local yOffset = 7
for i,cp in ipairs(cps) do
    makeButton("▶️ CP"..i,yOffset+i,function()
        playOneCP(cp)
    end)
end
