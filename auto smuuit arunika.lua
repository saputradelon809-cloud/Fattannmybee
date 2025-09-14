--// Arunika CP Tool (Final v7)
-- GUI + Auto TP Cepat + Auto Natural
-- Auto Respawn + Auto Rejoin + Anti-Kursi + Anti-Player + Stop Button

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local humanoid, hrp
local stopFlag = false

-- ===== Character Setup =====
local function setupChar(char)
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")

    -- Auto respawn
    humanoid.Died:Connect(function()
        stopFlag = true
        player:LoadCharacter()
    end)
end
if player.Character then setupChar(player.Character) end
player.CharacterAdded:Connect(setupChar)

-- ===== Auto Rejoin =====
player.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Failed then
        TeleportService:Teleport(game.PlaceId, player)
    end
end)

game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(obj)
    if obj.Name == "ErrorPrompt" then
        TeleportService:Teleport(game.PlaceId, player)
    end
end)

-- ===== Checkpoints =====
local checkpoints = {
    Vector3.new(135,144,-175),  -- CP 1
    Vector3.new(326,92,-434),   -- CP 2
    Vector3.new(476,172,-940),  -- CP 3
    Vector3.new(930,136,-627),  -- CP 4
    Vector3.new(923,104,280),   -- CP 5
    Vector3.new(257,328,699),   -- CP 6
}

-- ===== Helpers =====
local function tweenTo(pos, duration)
    if hrp then
        local tween = TweenService:Create(
            hrp,
            TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {CFrame = CFrame.new(pos)}
        )
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

-- Cari posisi aman (tidak dekat kursi)
local function safePosAround(cpPos, radius)
    local try = 0
    while try < 10 do
        try += 1
        local angle = math.rad(math.random(0,360))
        local offset = Vector3.new(math.cos(angle)*radius, 0, math.sin(angle)*radius)
        local testPos = cpPos + offset

        local nearSeat = false
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Seat") or v:IsA("VehicleSeat") then
                if (v.Position - testPos).Magnitude < 5 then
                    nearSeat = true
                    break
                end
            end
        end

        if not nearSeat then
            return testPos
        end
    end
    return cpPos + Vector3.new(radius,0,0) -- fallback
end

-- Cek & hindari player lain
local function avoidPlayers()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local otherHRP = plr.Character.HumanoidRootPart
            if (otherHRP.Position - hrp.Position).Magnitude < 6 then
                -- Naik ke atas untuk menghindar
                tweenTo(hrp.Position + Vector3.new(0,15,0), 0.8)
                task.wait(0.5)
                return true
            end
        end
    end
    return false
end

-- Natural Process (terbang antar CP + hindari kursi + player)
local function processNatural(pos)
    if not hrp then return end
    local startPos = hrp.Position

    -- 1. Naik ke atas
    tweenTo(startPos + Vector3.new(0,30,0), 1.5)
    task.wait(0.5)
    avoidPlayers()

    -- 2. Terbang horizontal di atas CP
    tweenTo(Vector3.new(pos.X, startPos.Y+30, pos.Z), 2)
    task.wait(0.5)
    avoidPlayers()

    -- 3. Turun perlahan ke CP
    tweenTo(pos + Vector3.new(0, 3, 0), 1.5)
    task.wait(0.5)
    avoidPlayers()

    -- 4. Muter di sekitar CP (hindari kursi + player)
    for i=1,3 do
        if stopFlag then return end
        local safe = safePosAround(pos, 5)
        walkTo(safe)
        avoidPlayers()
    end

    -- 5. Masuk ke CP
    walkTo(pos)

    -- 6. Loncat2 beberapa detik sambil cek player
    local t0 = tick()
    while tick() - t0 < 3 do
        if stopFlag then return end
        humanoid.Jump = true
        avoidPlayers()
        task.wait(0.5)
    end
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "ArunikaCPGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0.4, -90)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,28)
title.Text = "Arunika CP Tool"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)

local btn1 = Instance.new("TextButton", frame)
btn1.Size = UDim2.new(1,-20,0,32)
btn1.Position = UDim2.new(0,10,0,40)
btn1.Text = "Auto TP Cepat"
btn1.Font = Enum.Font.Gotham
btn1.TextSize = 14
btn1.BackgroundColor3 = Color3.fromRGB(70,70,70)
btn1.TextColor3 = Color3.fromRGB(255,255,255)

local btn2 = Instance.new("TextButton", frame)
btn2.Size = UDim2.new(1,-20,0,32)
btn2.Position = UDim2.new(0,10,0,80)
btn2.Text = "Auto Natural"
btn2.Font = Enum.Font.Gotham
btn2.TextSize = 14
btn2.BackgroundColor3 = Color3.fromRGB(70,70,70)
btn2.TextColor3 = Color3.fromRGB(255,255,255)

local btnStop = Instance.new("TextButton", frame)
btnStop.Size = UDim2.new(1,-20,0,32)
btnStop.Position = UDim2.new(0,10,0,130)
btnStop.Text = "STOP"
btnStop.Font = Enum.Font.GothamBold
btnStop.TextSize = 14
btnStop.BackgroundColor3 = Color3.fromRGB(180,50,50)
btnStop.TextColor3 = Color3.fromRGB(255,255,255)

-- ===== Actions =====
btn1.MouseButton1Click:Connect(function()
    stopFlag = false
    for _,pos in ipairs(checkpoints) do
        if stopFlag then break end
        fastTP(pos)
        task.wait(1)
    end
end)

btn2.MouseButton1Click:Connect(function()
    stopFlag = false
    for _,pos in ipairs(checkpoints) do
        if stopFlag then break end
        processNatural(pos)
        task.wait(math.random(2,4))
    end
end)

btnStop.MouseButton1Click:Connect(function()
    stopFlag = true
end)
