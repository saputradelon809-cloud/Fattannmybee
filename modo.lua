-- FATTAN HUB - FINAL ALL IN ONE (small GUI + fixes)
-- Sudah termasuk: WalkFling blok besar, Fly Cursor, Rope 3D Elastic
-- Ukuran GUI lebih kecil

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

-- ---------- Loading ----------
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "FattanLoading"
loadingGui.ResetOnSpawn = false
loadingGui.Parent = CoreGui

local loadFrame = Instance.new("Frame", loadingGui)
loadFrame.Size = UDim2.new(1,0,1,0)
loadFrame.BackgroundColor3 = Color3.fromRGB(6, 36, 90)

local loadLabel = Instance.new("TextLabel", loadFrame)
loadLabel.Size = UDim2.new(1,0,1,0)
loadLabel.BackgroundTransparency = 1
loadLabel.Text = "FATTAN HUB"
loadLabel.Font = Enum.Font.GothamBold
loadLabel.TextSize = 36
loadLabel.TextColor3 = Color3.new(1,1,1)

task.wait(1.2)
TweenService:Create(loadFrame, TweenInfo.new(0.9), {BackgroundTransparency = 1}):Play()
TweenService:Create(loadLabel, TweenInfo.new(0.9), {TextTransparency = 1}):Play()
task.wait(0.9)
loadingGui:Destroy()

-- ---------- Main GUI ----------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FattanHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 380) -- GUI lebih kecil
mainFrame.Position = UDim2.new(0.4,0,0.22,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(8, 44, 110)
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1,0,0,28)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundColor3 = Color3.fromRGB(4, 110, 200)
title.Text = "🏆 FATTAN HUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)

local listLayout = Instance.new("UIListLayout", mainFrame)
listLayout.Padding = UDim.new(0,5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createButton(text, callback)
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(1,-10,0,28)
    btn.BackgroundColor3 = Color3.fromRGB(10,95,180)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextSize = 13
    btn.TextColor3 = Color3.new(1,1,1)
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    return btn
end

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ==========================================
-- 🟤 WalkFling (blok besar tak terlihat)
-- ==========================================
local flingOn = false
local flingConn = nil
local flingPart = nil

local function startFling()
    if flingOn then return end
    flingOn = true
    local hrp = getChar():WaitForChild("HumanoidRootPart")

    flingPart = Instance.new("Part")
    flingPart.Anchored = false
    flingPart.CanCollide = true
    flingPart.Transparency = 1
    flingPart.Size = Vector3.new(20,20,20)
    flingPart.Massless = true
    flingPart.Parent = workspace

    local weld = Instance.new("WeldConstraint", flingPart)
    weld.Part0 = flingPart
    weld.Part1 = hrp

    flingConn = RunService.Heartbeat:Connect(function()
        flingPart.RotVelocity = Vector3.new(0,200,0) -- muter blok, bukan karakter
    end)
end

local function stopFling()
    flingOn = false
    if flingConn then flingConn:Disconnect() flingConn = nil end
    if flingPart then flingPart:Destroy() flingPart = nil end
end

createButton("WalkFling (Toggle)", function()
    if flingOn then stopFling() else startFling() end
end)

-- ==========================================
-- 🟤 Fly (Cursor Based)
-- ==========================================
local flying = false
local flyConn
local flySpeed = 80

local function startFly()
    if flying then return end
    flying = true

    local hrp = getChar():WaitForChild("HumanoidRootPart")
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    bv.Velocity = Vector3.zero

    local bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bg.CFrame = hrp.CFrame

    flyConn = RunService.Heartbeat:Connect(function()
        if not flying then return end
        if not Mouse.Hit then return end
        local target = Mouse.Hit.p
        local dir = (target - hrp.Position)
        if dir.Magnitude > 2 then
            bv.Velocity = dir.Unit * flySpeed
        else
            bv.Velocity = Vector3.zero
        end
        bg.CFrame = CFrame.new(hrp.Position, target)
    end)
end

local function stopFly()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    local hrp = getChar():FindFirstChild("HumanoidRootPart")
    if hrp then
        for _,v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                v:Destroy()
            end
        end
    end
end

createButton("Fly (Cursor)", function()
    if flying then stopFly() else startFly() end
end)

-- ==========================================
-- 🟤 Rope Pull (Elastic 3D Brown)
-- ==========================================
local selected = nil -- contoh: set player target dari menu scan/delete (belum ditambah di sini)

createButton("Pull Selected (Rope)", function()
    if not selected then return end
    local targetPlayer = Players:FindFirstChild(selected)
    if not targetPlayer then return end
    local tchar = targetPlayer.Character
    local mychar = getChar()
    if not tchar or not mychar then return end
    local thrp = tchar:FindFirstChild("HumanoidRootPart")
    local myhrp = mychar:FindFirstChild("HumanoidRootPart")
    if not thrp or not myhrp then return end

    if thrp:FindFirstChild("FattanElasticRope_Att2") then return end

    local att1 = Instance.new("Attachment", myhrp)
    att1.Name = "FattanElasticRope_Att1"
    local att2 = Instance.new("Attachment", thrp)
    att2.Name = "FattanElasticRope_Att2"

    local spring = Instance.new("SpringConstraint", myhrp)
    spring.Attachment0 = att1
    spring.Attachment1 = att2
    spring.FreeLength = (myhrp.Position - thrp.Position).Magnitude
    spring.Stiffness = 220
    spring.Damping = 6

    local ropeBeam = Instance.new("Beam", myhrp)
    ropeBeam.Attachment0 = att1
    ropeBeam.Attachment1 = att2
    ropeBeam.Width0 = 0.18
    ropeBeam.Width1 = 0.18
    ropeBeam.Segments = 10
    ropeBeam.Color = ColorSequence.new(Color3.fromRGB(139,69,19)) -- coklat

    local beamConn
    beamConn = RunService.Heartbeat:Connect(function()
        if not att1.Parent or not att2.Parent or not spring.Parent then
            if beamConn then beamConn:Disconnect() end
            return
        end
        local dist = (att1.WorldPosition - att2.WorldPosition).Magnitude
        local curve = math.clamp(1.5 - (dist/60), 0, 1.5)
        ropeBeam.CurveSize0 = curve
        ropeBeam.CurveSize1 = curve * 0.6
    end)

    task.delay(12, function()
        if beamConn then beamConn:Disconnect() end
        att1:Destroy()
        att2:Destroy()
        spring:Destroy()
        ropeBeam:Destroy()
    end)
end)
