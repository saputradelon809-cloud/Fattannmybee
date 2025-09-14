-- Arunika CP Tool v22 (Full) - Upload this file as "arunika_cp_tool_v22.lua"
-- All-in-one: fixed CP coords, smooth up->fly->descend, auto-respawn after CP6,
-- auto-rejoin on kick/disconnect/teleport fail, anti-AFK, anti-seat, avoid players,
-- GUI (manual CP, auto once, infinite loop), speed control, notifications.

-- ===== Services =====
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
if not player then return end

-- ===== State =====
local hrp, humanoid
local stopFlag = false
local autoLoop = false
local speedFactor = 1.0
local loopCount = 0

-- ===== Fixed Checkpoints (user-provided) =====
local checkpoints = {
    {name="CP1", pos=Vector3.new(135,144,-175)},
    {name="CP2", pos=Vector3.new(326,92,-434)},
    {name="CP3", pos=Vector3.new(476,172,-940)},
    {name="CP4", pos=Vector3.new(930,136,-627)},
    {name="CP5", pos=Vector3.new(923,104,280)},
    {name="CP6", pos=Vector3.new(257,328,699)},
}

-- ===== Utilities =====
local function safeNotify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Arunika CP Tool",
            Text = tostring(text),
            Duration = 3
        })
    end)
end

local function safeTeleportJoin()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

-- ===== Character Setup =====
local function setupChar(char)
    if not char then return end
    task.spawn(function()
        humanoid = char:WaitForChild("Humanoid", 5)
        hrp = char:WaitForChild("HumanoidRootPart", 5)

        if humanoid then
            -- anti-sit
            humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
                if humanoid and humanoid.Sit then
                    pcall(function() humanoid.Sit = false end)
                end
            end)

            -- if died: stop and respawn
            humanoid.Died:Connect(function()
                stopFlag = true
                autoLoop = false
                safeNotify("Kamu mati — respawn otomatis.")
                task.wait(2)
                pcall(function() player:LoadCharacter() end)
            end)
        end
    end)
end

if player.Character then setupChar(player.Character) end
player.CharacterAdded:Connect(setupChar)

-- ===== Auto rejoin on teleport fail / error prompt / disconnect =====
player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        safeNotify("Teleport gagal — mencoba rejoin...")
        safeTeleportJoin()
    end
end)

-- watch CoreGui for error prompts (attempt best-effort)
CoreGui.DescendantAdded:Connect(function(obj)
    -- best-effort detection: many prompt types are Frame/TextLabel names; check text content if possible
    pcall(function()
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local txt = tostring(obj.Text):lower()
            if txt:find("disconnected") or txt:find("kicked") or txt:find("teleport failed") or txt:find("error") then
                safeNotify("Prompt terdeteksi: "..obj.Text.." — mencoba rejoin...")
                safeTeleportJoin()
            end
        elseif obj.Name == "ErrorPrompt" then
            safeNotify("ErrorPrompt muncul — mencoba rejoin...")
            safeTeleportJoin()
        end
    end)
end)

-- ===== Anti-AFK =====
pcall(function()
    local vu = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

-- ===== Movement helpers =====
local function waitForHRP(timeout)
    local t = 0
    while (not hrp) and t < (timeout or 5) do
        task.wait(0.2)
        t = t + 0.2
    end
    return hrp ~= nil
end

-- small upward dodge to avoid collisions with players
local function avoidPlayers()
    if not hrp then return false end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local otherHRP = plr.Character.HumanoidRootPart
            local d = (otherHRP.Position - hrp.Position).Magnitude
            if d < 8 then
                pcall(function() hrp.CFrame = hrp.CFrame + Vector3.new(0, 10, 0) end)
                task.wait(0.18)
                return true
            end
        end
    end
    return false
end

-- Smooth safe move: rise vertical -> move horizontal above target -> smooth slow descent -> final micro-walk & jump
local function smoothTo(targetVector3)
    if not waitForHRP(5) then
        safeNotify("HRP belum siap.")
        return
    end

    local start = hrp.Position
    -- ensure we go high above obstacles: dynamic up height
    local upHeight = math.max(80, (targetVector3.Y - start.Y) + 60)
    local top = start + Vector3.new(0, upHeight, 0)

    -- step 1: rise vertically (many small steps)
    local roundsRise = math.clamp(math.floor(upHeight / 3), 18, 80)
    for i = 1, roundsRise do
        if stopFlag then return end
        local t = i / roundsRise
        local pos = start:Lerp(top, t)
        pcall(function() hrp.CFrame = CFrame.new(pos) end)
        task.wait((0.018) / speedFactor)
    end

    task.wait(0.06)

    -- step 2: horizontal translate above target
    local aboveTarget = Vector3.new(targetVector3.X, top.Y, targetVector3.Z)
    local from = hrp.Position
    local roundsHoriz = math.clamp(math.floor((from - aboveTarget).Magnitude / 2) + 20, 20, 120)
    for i = 1, roundsHoriz do
        if stopFlag then return end
        local t = i / roundsHoriz
        local pos = from:Lerp(aboveTarget, t)
        pcall(function() hrp.CFrame = CFrame.new(pos) end)
        task.wait((0.018) / speedFactor)
    end

    task.wait(0.06)

    -- step 3: smooth slow descent to slightly above target (5 studs)
    local descStart = hrp.Position
    local descTarget = targetVector3 + Vector3.new(0, 5, 0)
    local heightDiff = descStart.Y - descTarget.Y
    local duration = math.clamp(heightDiff / 25, 1.4, 6) / math.max(0.5, speedFactor)
    local roundsDesc = math.max(18, math.floor(duration * 28))
    for i = 1, roundsDesc do
        if stopFlag then return end
        local t = i / roundsDesc
        local pos = descStart:Lerp(descTarget, t)
        pcall(function() hrp.CFrame = CFrame.new(pos) end)
        task.wait(duration / roundsDesc)
    end

    task.wait(0.05)

    -- final micro-walk to precise spot (small adjustment)
    pcall(function() hrp.CFrame = CFrame.new(targetVector3 + Vector3.new(0, 2, 0)) end)
    task.wait(0.06)

    -- final small jumps to make sure checkpoint triggers
    if humanoid then
        for j = 1, 3 do
            if stopFlag then break end
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
            task.wait(0.42 / math.max(0.5, speedFactor))
        end
    end
end

-- high-level go to CP entry
local function goToCP(cp)
    if not cp or not cp.pos then return end
    if not waitForHRP(4) then
        safeNotify("HRP belum siap, tunggu sebentar...")
        return
    end
    avoidPlayers()
    smoothTo(cp.pos)
    safeNotify("✅ "..tostring(cp.name).." diambil")
end

-- ===== Runners =====
local function runOnce()
    stopFlag = false
    for i,cp in ipairs(checkpoints) do
        if stopFlag then break end
        safeNotify("➡️ "..cp.name)
        goToCP(cp)
        task.wait(0.9 / math.max(0.5, speedFactor))
        avoidPlayers()
    end
    if not stopFlag then
        -- auto respawn after finishing CP6
        safeNotify("✅ Semua CP selesai — respawn otomatis")
        task.wait(0.6)
        pcall(function() player:LoadCharacter() end)
    end
end

local function runInfiniteLoop()
    stopFlag = false
    autoLoop = true
    loopCount = 0
    while autoLoop do
        loopCount = loopCount + 1
        safeNotify("🔁 Memulai loop ke-"..tostring(loopCount))
        for i,cp in ipairs(checkpoints) do
            if stopFlag or not autoLoop then break end
            safeNotify("➡️ "..cp.name.." (Loop "..loopCount..")")
            goToCP(cp)
            task.wait(0.9 / math.max(0.5, speedFactor))
            avoidPlayers()
        end
        if autoLoop and not stopFlag then
            safeNotify("🔄 Respawn ulang (loop)")
            pcall(function() player:LoadCharacter() end)
            task.wait(4 / math.max(0.5, speedFactor))
        end
    end
end

-- ===== GUI (complete panel) =====
if CoreGui:FindFirstChild("ArunikaCPv22") then
    CoreGui.ArunikaCPv22:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ArunikaCPv22"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 560)
frame.Position = UDim2.new(0, 10, 0, 40)
frame.BackgroundColor3 = Color3.fromRGB(26,26,26)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,36)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Text = "🌸 Arunika CP Tool v22 (Full)"
title.TextColor3 = Color3.fromRGB(255,255,255)

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1,-20,0,64)
info.Position = UDim2.new(0,10,0,40)
info.BackgroundTransparency = 1
info.Font = Enum.Font.SourceSans
info.TextSize = 13
info.TextWrapped = true
info.TextColor3 = Color3.fromRGB(200,200,200)
info.Text = "Status: Idle\nHRP: -\nLoop: 0\nSpeed: x1.00"

local y = 110
for i,cp in ipairs(checkpoints) do
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1,-20,0,36)
    btn.Position = UDim2.new(0,10,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = cp.name.."  "..string.format("(%d, %d, %d)", cp.pos.X, cp.pos.Y, cp.pos.Z)
    y = y + 44

    btn.MouseButton1Click:Connect(function()
        stopFlag = false
        autoLoop = false
        info.Text = "Status: Going to "..cp.name.."\nHRP: "..(hrp and tostring(hrp.Position) or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
        task.spawn(function()
            goToCP(cp)
            info.Text = "Status: Idle\nHRP: "..(hrp and ("["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]") or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
        end)
    end)
end

-- Auto once button
local autoOnce = Instance.new("TextButton", frame)
autoOnce.Size = UDim2.new(1,-20,0,40)
autoOnce.Position = UDim2.new(0,10,0,y)
autoOnce.BackgroundColor3 = Color3.fromRGB(70,110,70)
autoOnce.Font = Enum.Font.GothamBold
autoOnce.TextSize = 14
autoOnce.TextColor3 = Color3.fromRGB(255,255,255)
autoOnce.Text = "▶️ Auto CP 1→6 (Once)"
y = y + 50

autoOnce.MouseButton1Click:Connect(function()
    stopFlag = false
    autoLoop = false
    info.Text = "Status: Auto Once running..."
    task.spawn(function()
        runOnce()
        info.Text = "Status: Idle\nHRP: "..(hrp and ("["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]") or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    end)
end)

-- Auto infinite loop button
local autoInfinite = Instance.new("TextButton", frame)
autoInfinite.Size = UDim2.new(1,-20,0,40)
autoInfinite.Position = UDim2.new(0,10,0,y)
autoInfinite.BackgroundColor3 = Color3.fromRGB(110,90,40)
autoInfinite.Font = Enum.Font.GothamBold
autoInfinite.TextSize = 14
autoInfinite.TextColor3 = Color3.fromRGB(255,255,255)
autoInfinite.Text = "♻️ Auto CP Infinite"
y = y + 50

autoInfinite.MouseButton1Click:Connect(function()
    stopFlag = false
    autoLoop = true
    info.Text = "Status: Auto Loop running..."
    task.spawn(function()
        runInfiniteLoop()
    end)
end)

-- Speed controls
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Size = UDim2.new(1,-20,0,28)
speedLabel.Position = UDim2.new(0,10,0,y)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.TextColor3 = Color3.fromRGB(230,230,230)
speedLabel.Text = "Speed: x"..string.format("%.2f", speedFactor)
y = y + 34

local speedUp = Instance.new("TextButton", frame)
speedUp.Size = UDim2.new(0.48,-12,0,36)
speedUp.Position = UDim2.new(0,10,0,y)
speedUp.BackgroundColor3 = Color3.fromRGB(40,120,40)
speedUp.Font = Enum.Font.Gotham
speedUp.TextSize = 13
speedUp.TextColor3 = Color3.fromRGB(255,255,255)
speedUp.Text = "Speed +"

local speedDown = Instance.new("TextButton", frame)
speedDown.Size = UDim2.new(0.48,-12,0,36)
speedDown.Position = UDim2.new(0.52,10,0,y)
speedDown.BackgroundColor3 = Color3.fromRGB(120,40,40)
speedDown.Font = Enum.Font.Gotham
speedDown.TextSize = 13
speedDown.TextColor3 = Color3.fromRGB(255,255,255)
speedDown.Text = "Speed -"
y = y + 50

speedUp.MouseButton1Click:Connect(function()
    speedFactor = math.clamp(speedFactor + 0.25, 0.5, 5)
    speedLabel.Text = "Speed: x"..string.format("%.2f", speedFactor)
    info.Text = "Status: Idle\nHRP: "..(hrp and ("["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]") or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    safeNotify("Speed set to x"..string.format("%.2f", speedFactor))
end)

speedDown.MouseButton1Click:Connect(function()
    speedFactor = math.clamp(speedFactor - 0.25, 0.5, 5)
    speedLabel.Text = "Speed: x"..string.format("%.2f", speedFactor)
    info.Text = "Status: Idle\nHRP: "..(hrp and ("["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]") or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    safeNotify("Speed set to x"..string.format("%.2f", speedFactor))
end)

-- Stop + Rejoin
local stopBtn = Instance.new("TextButton", frame)
stopBtn.Size = UDim2.new(1,-20,0,40)
stopBtn.Position = UDim2.new(0,10,0,y)
stopBtn.BackgroundColor3 = Color3.fromRGB(100,30,30)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 14
stopBtn.TextColor3 = Color3.fromRGB(255,255,255)
stopBtn.Text = "⏹️ STOP"
y = y + 48

stopBtn.MouseButton1Click:Connect(function()
    stopFlag = true
    autoLoop = false
    info.Text = "Status: Stopped by user\nHRP: "..(hrp and tostring(hrp.Position) or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    safeNotify("Stopped")
end)

local rejoinBtn = Instance.new("TextButton", frame)
rejoinBtn.Size = UDim2.new(1,-20,0,36)
rejoinBtn.Position = UDim2.new(0,10,0,y)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(40,80,120)
rejoinBtn.Font = Enum.Font.Gotham
rejoinBtn.TextSize = 14
rejoinBtn.TextColor3 = Color3.fromRGB(255,255,255)
rejoinBtn.Text = "🔄 Rejoin"
y = y + 44

rejoinBtn.MouseButton1Click:Connect(function()
    safeNotify("Rejoining...")
    safeTeleportJoin()
end)

-- little status updater
task.spawn(function()
    while true do
        if info and info.Parent then
            local hrpstr = hrp and ("["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]") or "-"
            info.Text = "Status: "..(autoLoop and "AutoLoop" or "Idle").."\nHRP: "..hrpstr.."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
        end
        task.wait(0.8)
    end
end)

safeNotify("Arunika CP Tool v22 siap — GUI muncul.")
