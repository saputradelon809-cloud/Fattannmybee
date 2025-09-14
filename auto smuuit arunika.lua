--// Arunika CP Tool (Final v15)
-- Auto Detect CP + Smooth Descend + Persistent GUI + Auto Resume

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local humanoid, hrp
local stopFlag = false

-- ===== Global CP Progress =====
_G.currentCP = _G.currentCP or 0

-- ===== Character Setup =====
local function setupChar(char)
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")

    humanoid.Died:Connect(function()
        stopFlag = true
        player:LoadCharacter()
    end)
end
if player.Character then setupChar(player.Character) end
player.CharacterAdded:Connect(function(char)
    setupChar(char)
    if not stopFlag then
        task.delay(3, function()
            naturalRun()
        end)
    end
end)

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

-- ===== CP Detector =====
local function getCheckpoints()
    local found = {}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("cp") then
            table.insert(found, obj)
        end
    end
    table.sort(found, function(a,b)
        local na = tonumber(a.Name:match("%d+")) or 0
        local nb = tonumber(b.Name:match("%d+")) or 0
        return na < nb
    end)
    return found
end

local checkpoints = getCheckpoints()

-- ===== Notifikasi =====
local function notify(msg)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Arunika CP Tool",
            Text = msg,
            Duration = 3
        })
    end)
end

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

-- Cek & hindari player lain
local function avoidPlayers()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local otherHRP = plr.Character.HumanoidRootPart
            if (otherHRP.Position - hrp.Position).Magnitude < 6 then
                tweenTo(hrp.Position + Vector3.new(0,15,0), 0.8)
                task.wait(0.5)
                return true
            end
        end
    end
    return false
end

-- Turun smooth slow motion
local function smoothDescend(targetPos)
    if not hrp then return end

    local currentY = hrp.Position.Y
    local targetY = targetPos.Y
    local heightDiff = currentY - targetY
    if heightDiff <= 0 then return end

    local duration = math.clamp(heightDiff/20, 2, 6)
    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
        {CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))}
    )
    tween:Play()
    tween.Completed:Wait()

    walkTo(targetPos)
    for i=1,3 do
        humanoid.Jump = true
        task.wait(0.4)
    end
end

-- Proses CP
local function goToCP(cpObj, index)
    if not hrp or not cpObj then return end
    local cpPos = cpObj.Position
    local startPos = hrp.Position

    -- 1. Naik tinggi dulu
    local upHeight = math.max(40, cpPos.Y - startPos.Y + 20)
    tweenTo(startPos + Vector3.new(0,upHeight,0), 2)
    task.wait(0.5)

    -- 2. Geser horizontal ke atas CP
    tweenTo(Vector3.new(cpPos.X, startPos.Y+upHeight, cpPos.Z), 2.5)
    task.wait(0.5)

    -- 3. Turun pelan smooth
    smoothDescend(cpPos)

    -- 4. Update CP
    _G.currentCP = index
    notify("✅ "..cpObj.Name.." diambil")

    -- 5. Naik sedikit lagi (biar natural)
    tweenTo(cpPos + Vector3.new(0,30,0), 1.5)
    task.wait(0.5)
end

-- Loop Natural Run
function naturalRun()
    notify("▶️ Mulai Auto Loop (lanjut dari CP"..(_G.currentCP+1)..")")
    while not stopFlag do
        checkpoints = getCheckpoints() -- refresh CP kalau ada update di map
        for i = _G.currentCP + 1, #checkpoints do
            if stopFlag then break end
            goToCP(checkpoints[i], i)
            task.wait(math.random(2,4))
        end
        if not stopFlag then
            notify("🔄 Respawn ulang")
            _G.currentCP = 0
            player:LoadCharacter()
            task.wait(5)
        end
    end
    notify("⏹️ Auto Loop dihentikan")
end

-- ===== GUI =====
if CoreGui:FindFirstChild("ArunikaCPGui") then
    CoreGui.ArunikaCPGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ArunikaCPGui"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0.4, -90)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,28)
title.Text = "Arunika CP Tool v15"
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
btn2.Text = "Auto Natural Loop"
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
    checkpoints = getCheckpoints()
    for i,cp in ipairs(checkpoints) do
        if stopFlag then break end
        fastTP(cp.Position)
        _G.currentCP = i
        notify("✅ "..cp.Name.." (TP Cepat)")
        task.wait(1)
    end
end)

btn2.MouseButton1Click:Connect(function()
    stopFlag = false
    naturalRun()
end)

btnStop.MouseButton1Click:Connect(function()
    stopFlag = true
end)
