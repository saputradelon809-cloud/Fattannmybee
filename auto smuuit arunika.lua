-- Arunika CP Tool v26 (Anti Detect + Slow Fall)
-- Semua fitur: Auto CP, Slow Teleport, Respawn, Rejoin, Anti AFK, Anti Kursi

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local hrp

-- Safe HRP fetch
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart",10)
end
hrp = getHRP()

-- Anti AFK
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Anti kursi (hindari duduk otomatis)
RunService.Stepped:Connect(function()
    if hrp and hrp.Parent:FindFirstChildOfClass("Humanoid") then
        hrp.Parent:FindFirstChildOfClass("Humanoid").Sit = false
    end
end)

-- CP data
local checkpoints = {
    Vector3.new(135,144,-175),
    Vector3.new(326,92,-434),
    Vector3.new(476,172,-940),
    Vector3.new(930,136,-627),
    Vector3.new(923,104,280),
    Vector3.new(257,328,699),
}
local currentCP = 1
local autoFarm = false

-- Smooth & Natural Move (anti detect + slow fall)
local function moveTo(targetPos)
    hrp = getHRP()
    if not hrp then return end

    -- 1. Naik pelan
    local upGoal = {CFrame = CFrame.new(hrp.Position + Vector3.new(0, math.random(60,90), 0))}
    TweenService:Create(hrp, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), upGoal):Play()
    task.wait(2.6)

    -- 2. Gerak horizontal
    local horizGoal = {CFrame = CFrame.new(Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))}
    TweenService:Create(hrp, TweenInfo.new(math.random(3,4), Enum.EasingStyle.Linear), horizGoal):Play()
    task.wait(3.5)

    -- 3. Turun super pelan (slow fall)
    local downGoal = {CFrame = CFrame.new(targetPos + Vector3.new(0,7,0))}
    TweenService:Create(hrp, TweenInfo.new(5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), downGoal):Play()
    task.wait(5.2)

    -- 4. Muter2 + lompat (biar kelihatan player manual ambil CP)
    for j=1,4 do
        local offset = Vector3.new(math.sin(tick()*3+j),0,math.cos(tick()*3+j))*2
        hrp.CFrame = CFrame.new(targetPos+offset)
        hrp.Velocity = Vector3.new(0,20,0)
        task.wait(1 + math.random()*0.4)
    end
end

-- Go to CP
local function goToCP(i)
    if not checkpoints[i] then return end
    currentCP = i
    moveTo(checkpoints[i])
    if i == #checkpoints then
        task.wait(2)
        player:LoadCharacter() -- auto respawn setelah CP6
    end
end

-- Auto mode
local function autoCP()
    while autoFarm do
        goToCP(currentCP)
        currentCP += 1
        if currentCP > #checkpoints then
            currentCP = 1
        end
        task.wait(3)
    end
end

-- GUI (Delta friendly)
local gui = Instance.new("ScreenGui")
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,350)
frame.Position = UDim2.new(0.05,0,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true

local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0,5)

local function makeButton(txt, func)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-10,0,35)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.MouseButton1Click:Connect(func)
end

makeButton("Toggle Auto CP", function()
    autoFarm = not autoFarm
    if autoFarm then
        task.spawn(autoCP)
    end
end)

for i=1,#checkpoints do
    makeButton("Go to CP"..i, function() goToCP(i) end)
end

-- Auto rejoin kalau ke-kick
player.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Failed then
        TeleportService:Teleport(game.PlaceId, player)
    end
end)
