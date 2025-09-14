--// Arunika CP Tool (Auto Respawn + Loop Aman)
-- Fitur:
-- 1. Jalan CP 1-6 otomatis
-- 2. Auto respawn setelah selesai
-- 3. Lanjut otomatis setelah respawn (tidak macet)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local humanoid, hrp

-- Daftar CP
local checkpoints = {
    Vector3.new(135,144,-175),
    Vector3.new(326,92,-434),
    Vector3.new(476,172,-940),
    Vector3.new(930,136,-627),
    Vector3.new(923,104,280),
    Vector3.new(257,328,699),
}

-- State
local runningMode = nil -- "fast" / "natural"
local stopFlag = false

-- ===== Character =====
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end
player.CharacterAdded:Connect(function()
    getChar()
    -- kalau sedang running, restart loop sesuai mode
    if runningMode == "fast" then
        task.spawn(runFastLoop)
    elseif runningMode == "natural" then
        task.spawn(runNaturalLoop)
    end
end)
getChar()

-- ===== Helpers =====
local function tweenTo(pos, duration)
    if hrp then
        local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.new(pos)})
        tween:Play()
        tween.Completed:Wait()
    end
end

local function walkTo(pos)
    if humanoid then
        humanoid:MoveTo(pos)
        humanoid.MoveToFinished:Wait()
    end
end

local function fastTP(pos)
    if hrp then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
    end
end

local function processNatural(pos)
    if not hrp then return end
    -- 1. Fly atas CP
    tweenTo(pos + Vector3.new(0, 15, 0), 1.5)
    task.wait(math.random(1,2))
    -- 2. Turun
    tweenTo(pos + Vector3.new(0, 3, 0), 1.2)
    task.wait(0.5)
    -- 3. Muter-muter
    local radius = 4
    for i=1,3 do
        local angle = math.rad(i*120)
        local offset = Vector3.new(math.cos(angle)*radius, 0, math.sin(angle)*radius)
        walkTo(pos + offset)
    end
    -- 4. Masuk CP
    walkTo(pos)
    -- 5. Loncat-loncat
    local t0 = tick()
    while tick() - t0 < 3 do
        humanoid.Jump = true
        task.wait(0.5)
    end
end

-- ===== Respawn =====
local function autoRespawn()
    if humanoid then
        humanoid.Health = 0
    end
end

-- ===== Loops =====
function runFastLoop()
    stopFlag = false
    while not stopFlag do
        for _,pos in ipairs(checkpoints) do
            if stopFlag then break end
            fastTP(pos)
            task.wait(1)
        end
        -- kalau udah habis CP → respawn otomatis
        if not stopFlag then
            autoRespawn()
            task.wait(5) -- tunggu respawn
        end
    end
end

function runNaturalLoop()
    stopFlag = false
    while not stopFlag do
        for _,pos in ipairs(checkpoints) do
            if stopFlag then break end
            processNatural(pos)
            task.wait(math.random(2,4))
        end
        -- kalau udah habis CP → respawn otomatis
        if not stopFlag then
            autoRespawn()
            task.wait(5) -- tunggu respawn
        end
    end
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "CPGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0.4, -90)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,28)
title.Text = "Arunika CP Tool (AutoRespawn)"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)

local btn1 = Instance.new("TextButton", frame)
btn1.Size = UDim2.new(1,-20,0,32)
btn1.Position = UDim2.new(0,10,0,40)
btn1.Text = "Start Fast Loop"
btn1.Font = Enum.Font.Gotham
btn1.TextSize = 14
btn1.BackgroundColor3 = Color3.fromRGB(70,70,70)
btn1.TextColor3 = Color3.fromRGB(255,255,255)

local btn2 = Instance.new("TextButton", frame)
btn2.Size = UDim2.new(1,-20,0,32)
btn2.Position = UDim2.new(0,10,0,80)
btn2.Text = "Start Natural Loop"
btn2.Font = Enum.Font.Gotham
btn2.TextSize = 14
btn2.BackgroundColor3 = Color3.fromRGB(70,70,70)
btn2.TextColor3 = Color3.fromRGB(255,255,255)

local stopBtn = Instance.new("TextButton", frame)
stopBtn.Size = UDim2.new(1,-20,0,32)
stopBtn.Position = UDim2.new(0,10,0,130)
stopBtn.Text = "STOP"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14
stopBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)
stopBtn.TextColor3 = Color3.fromRGB(255,255,255)

-- ===== Button Actions =====
btn1.MouseButton1Click:Connect(function()
    runningMode = "fast"
    task.spawn(runFastLoop)
end)

btn2.MouseButton1Click:Connect(function()
    runningMode = "natural"
    task.spawn(runNaturalLoop)
end)

stopBtn.MouseButton1Click:Connect(function()
    stopFlag = true
    runningMode = nil
end)
