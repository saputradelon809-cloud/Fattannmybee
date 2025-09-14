-- ============================================================================
-- Arunika CP Tool v24 (Super Long, Full) - upload as arunika_cp_tool_v24.lua
-- Fitur:
--  • Fixed CP coords (dari user)
--  • Manual TP per CP
--  • Auto Once (CP1->CP6)
--  • Auto Infinite Loop (respawn setelah CP6)
--  • Naik dulu -> geser -> TURUN PELAN (parachute/slow-fall)
--  • Delay & muter2 + lompat pelan di sekitar CP (biar ter-detect)
--  • Auto respawn setelah CP6
--  • Auto rejoin jika teleport gagal / muncul error prompt / disconnect
--  • Anti-AFK, Anti-Seat, Avoid players
--  • Speed control (GUI)
--  • GUI rapi + status, notifikasi
-- ============================================================================

-- ===========================
-- SERVICES & BASIC SETUP
-- ===========================
local Players         = game:GetService("Players")
local CoreGui         = game:GetService("CoreGui")
local StarterGui      = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local RunService      = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then
    warn("[ArunikaCP v24] LocalPlayer not found. Run in Local environment.")
    return
end

-- ===========================
-- GLOBAL STATE / CONFIG
-- ===========================
local hrp            = nil      -- HumanoidRootPart reference
local humanoid       = nil      -- Humanoid reference
local stopFlag       = false    -- stop all actions
local autoLoop       = false    -- whether infinite loop is on
local loopCount      = 0        -- number of loops completed
local speedFactor    = 1.0      -- controls speed: 0.5 .. 5.0
local preferSlowDescent = true  -- if true use slow descent (parachute)
local circleRadius   = 3        -- radius to circle around CP when "muter2"
local circleSteps    = 12       -- number of steps when circling

-- ===========================
-- CHECKPOINTS (fixed coords)
-- ===========================
local checkpoints = {
    { name = "CP1", pos = Vector3.new(135,144,-175) },
    { name = "CP2", pos = Vector3.new(326,92,-434)  },
    { name = "CP3", pos = Vector3.new(476,172,-940) },
    { name = "CP4", pos = Vector3.new(930,136,-627) },
    { name = "CP5", pos = Vector3.new(923,104,280)  },
    { name = "CP6", pos = Vector3.new(257,328,699)  },
}

-- ===========================
-- SAFE UTILITIES
-- ===========================
local function safeNotify(txt)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Arunika CP Tool",
            Text = tostring(txt),
            Duration = 3
        })
    end)
end

local function safeRejoin()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

local function dbg(...) pcall(function() print("[ArunikaCP v24]", ...) end) end

-- ===========================
-- CHARACTER SETUP & HOOKS
-- ===========================
local function setupCharacter(character)
    if not character then return end
    -- small delay to allow components to be present
    humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 6)
    hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 6)

    if humanoid then
        -- anti-sit: segera balik berdiri kalau ter-sit
        humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
            if humanoid and humanoid.Sit then
                pcall(function() humanoid.Sit = false end)
            end
        end)

        -- on death: set flags and respawn
        humanoid.Died:Connect(function()
            stopFlag = true
            autoLoop = false
            safeNotify("Kamu mati — respawn otomatis.")
            dbg("Humanoid died -> respawning")
            task.wait(2)
            pcall(function() player:LoadCharacter() end)
        end)
    else
        dbg("Humanoid not found on setupCharacter")
    end
end

-- initial setup if character exists already
if player.Character then
    setupCharacter(player.Character)
end
-- whenever character respawns, re-setup
player.CharacterAdded:Connect(function(char)
    -- slight delay to ensure parts exist
    task.delay(0.08, function()
        setupCharacter(char)
    end)
end)

-- ===========================
-- AUTO-REJOIN / PROMPT WATCH
-- ===========================
player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        safeNotify("Teleport gagal — mencoba rejoin...")
        dbg("Teleport failed -> rejoin")
        safeRejoin()
    end
end)

-- Watch core GUI for error-like text to attempt rejoin (best-effort)
CoreGui.DescendantAdded:Connect(function(obj)
    pcall(function()
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local txt = tostring(obj.Text):lower()
            if txt:find("disconnected") or txt:find("kicked") or txt:find("teleport failed") or txt:find("error") then
                safeNotify("Prompt terdeteksi -> rejoin...")
                dbg("Detected possible error prompt:", obj.Text)
                safeRejoin()
            end
        elseif obj.Name == "ErrorPrompt" then
            safeNotify("ErrorPrompt muncul -> rejoin...")
            dbg("ErrorPrompt object detected")
            safeRejoin()
        end
    end)
end)

-- ===========================
-- ANTI-AFK
-- ===========================
pcall(function()
    local vu = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

-- ===========================
-- HELPER: ensure hrp exists
-- ===========================
local function waitForHRP(timeout)
    timeout = timeout or 5
    local t = 0
    while not hrp and t < timeout do
        task.wait(0.2)
        t = t + 0.2
    end
    return hrp ~= nil
end

-- ===========================
-- HELPER: avoid players (small upward dodge)
-- ===========================
local function avoidPlayers()
    if not hrp then return false end
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= player and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            local other = pl.Character.HumanoidRootPart
            if (other.Position - hrp.Position).Magnitude < 8 then
                -- quick upward nudge to avoid collision
                pcall(function() hrp.CFrame = hrp.CFrame + Vector3.new(0, 10, 0) end)
                task.wait(0.18)
                dbg("Avoided player:", pl.Name)
                return true
            end
        end
    end
    return false
end

-- ===========================
-- MOVEMENT CORE: slow descent + circle + small jumps
-- ===========================
-- This is the main movement routine. It does:
-- 1) vertical rise to a high altitude (safe above obstacles)
-- 2) horizontal translation while at altitude
-- 3) SLOW descent ("parachute" mode) — long multi-step interpolation
-- 4) small delay before taking CP
-- 5) circle around CP with small slow jumps to ensure trigger
--
-- All waits are scaled by speedFactor (lower -> slower overall movement)
-- ===========================
local function slowDescentSteps(descStart, descTarget, steps)
    -- steps: number of interpolation steps (e.g., 60)
    for i = 1, steps do
        if stopFlag then return end
        local t = i / steps
        local pos = descStart:Lerp(descTarget, t)
        pcall(function() hrp.CFrame = CFrame.new(pos) end)
        -- slow down: larger wait for "very slow" feel
        -- scale by speedFactor so user can tune
        task.wait((0.035) / math.max(0.25, speedFactor))
    end
end

local function performCircleAndJumps(cpPos, circleRadiusLocal, circleStepsLocal)
    -- small pause before circling
    task.wait(0.6 / math.max(0.25, speedFactor))

    -- circle around CP using polar offsets
    for step = 1, circleStepsLocal do
        if stopFlag then return end
        local ang = (step / circleStepsLocal) * math.pi * 2
        local offset = Vector3.new(math.cos(ang) * circleRadiusLocal, 0, math.sin(ang) * circleRadiusLocal)
        local target = cpPos + offset + Vector3.new(0, 2, 0) -- slightly above ground
        pcall(function() hrp.CFrame = CFrame.new(target) end)
        -- tiny wait to feel like walking small circle
        task.wait(0.28 / math.max(0.25, speedFactor))
    end

    -- small slow jumps: do gentle jumps so checkpoint triggers
    for j = 1, 3 do
        if stopFlag then return end
        if humanoid then
            -- use ChangeState to trigger jumping animation & physics
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
        else
            -- fallback: small upward CFrame bump
            pcall(function() hrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0) end)
        end
        task.wait(0.45 / math.max(0.25, speedFactor))
    end
end

local function moveToCheckpointSlow(cpEntry)
    if not cpEntry or not cpEntry.pos then return end
    if not waitForHRP(6) then
        safeNotify("HRP belum siap — coba lagi sebentar")
        return
    end

    -- preliminary avoid players
    avoidPlayers()

    -- -------------- Phase A: vertical rise --------------
    local startPos = hrp.Position
    local upRequired = math.max(100, (cpEntry.pos.Y - startPos.Y) + 80) -- ensure very high to clear cliffs
    local topPos = startPos + Vector3.new(0, upRequired, 0)

    local riseSteps = math.clamp(math.floor(upRequired / 3), 30, 120)
    for i = 1, riseSteps do
        if stopFlag then return end
        local t = i / riseSteps
        local pos = startPos:Lerp(topPos, t)
        pcall(function() hrp.CFrame = CFrame.new(pos) end)
        task.wait((0.02) / math.max(0.25, speedFactor))
    end

    task.wait(0.06)

    -- -------------- Phase B: horizontal translate above CP --------------
    local aboveTarget = Vector3.new(cpEntry.pos.X, topPos.Y, cpEntry.pos.Z)
    local fromPos = hrp.Position
    local horizDist = (fromPos - aboveTarget).Magnitude
    local horizSteps = math.clamp(math.floor(horizDist / 2) + 30, 30, 160)
    for i = 1, horizSteps do
        if stopFlag then return end
        local t = i / horizSteps
        local pos = fromPos:Lerp(aboveTarget, t)
        pcall(function() hrp.CFrame = CFrame.new(pos) end)
        task.wait((0.02) / math.max(0.25, speedFactor))
    end

    task.wait(0.05)

    -- -------------- Phase C: SLOW descent to just above CP --------------
    -- Use many steps to create "parachute" slow-fall effect (avoid fall damage)
    local descStart = hrp.Position
    local descTarget = cpEntry.pos + Vector3.new(0, 4, 0) -- stop a bit above
    local descSteps = 60  -- **very slow** descent (can be tuned)
    slowDescentSteps(descStart, descTarget, descSteps)

    -- final micro-adjust to precise spot
    pcall(function() hrp.CFrame = CFrame.new(cpEntry.pos + Vector3.new(0, 2, 0)) end)
    task.wait(0.06 / math.max(0.25, speedFactor))

    -- -------------- Phase D: Delay and circle + jumps to force trigger --------------
    -- small "settle" delay (human-like)
    task.wait(0.9 / math.max(0.25, speedFactor))

    -- circle & small jumps
    performCircleAndJumps(cpEntry.pos, circleRadius, circleSteps)

    -- short final delay
    task.wait(0.5 / math.max(0.25, speedFactor))

    safeNotify("✅ "..tostring(cpEntry.name).." terambil")
end

-- ===========================
-- RUNNERS: single and loop
-- ===========================
local function runAllOnce()
    stopFlag = false
    for i, cp in ipairs(checkpoints) do
        if stopFlag then break end
        safeNotify("➡️ Menuju "..cp.name.." ("..i.."/"..#checkpoints..")")
        dbg("RunOnce -> going to", cp.name)
        moveToCheckpointSlow(cp)
        task.wait(0.9 / math.max(0.25, speedFactor))
        avoidPlayers()
    end

    if not stopFlag then
        safeNotify("🎉 Semua CP selesai — respawn otomatis")
        dbg("RunOnce finished; respawning")
        task.wait(0.9)
        pcall(function() player:LoadCharacter() end)
    end
end

local function runInfinite()
    stopFlag = false
    autoLoop = true
    loopCount = 0
    while autoLoop do
        loopCount = loopCount + 1
        safeNotify("🔁 Mulai loop ke-"..tostring(loopCount))
        dbg("runInfinite -> loop", loopCount)
        for i, cp in ipairs(checkpoints) do
            if stopFlag or (not autoLoop) then break end
            safeNotify("➡️ "..cp.name.." (Loop "..loopCount..")")
            moveToCheckpointSlow(cp)
            task.wait(0.9 / math.max(0.25, speedFactor))
            avoidPlayers()
        end
        if autoLoop and not stopFlag then
            safeNotify("🔄 Respawn ulang (loop)")
            pcall(function() player:LoadCharacter() end)
            task.wait(4 / math.max(0.25, speedFactor))
        end
    end
    dbg("runInfinite ended")
end

-- ===========================
-- GUI (verbose, readable)
-- ===========================
-- Remove old GUI if exists
if CoreGui:FindFirstChild("ArunikaCPv24") then
    CoreGui.ArunikaCPv24:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ArunikaCPv24"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 360, 0, 680)
mainFrame.Position = UDim2.new(0, 12, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(1,0,0,36)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Text = "🌸 Arunika CP Tool v24 (Super Long)"

local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = mainFrame
statusLabel.Size = UDim2.new(1,-20,0,76)
statusLabel.Position = UDim2.new(0,10,0,44)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 13
statusLabel.TextWrapped = true
statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
statusLabel.Text = "Status: Idle\nHRP: -\nLoop: 0\nSpeed: x1.00"

-- layout start Y
local curY = 132

-- create per-CP buttons
for i, cp in ipairs(checkpoints) do
    local btn = Instance.new("TextButton")
    btn.Parent = mainFrame
    btn.Size = UDim2.new(1,-20,0,36)
    btn.Position = UDim2.new(0,10,0,curY)
    btn.BackgroundColor3 = Color3.fromRGB(46,46,46)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = cp.name .. "  " .. string.format("(%d, %d, %d)", cp.pos.X, cp.pos.Y, cp.pos.Z)
    btn.AutoButtonColor = true

    btn.MouseButton1Click:Connect(function()
        stopFlag = false
        autoLoop = false
        statusLabel.Text = "Status: Going to "..cp.name.."\nHRP: "..(hrp and tostring(hrp.Position) or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
        task.spawn(function()
            moveToCheckpointSlow(cp)
            statusLabel.Text = "Status: Idle\nHRP: "..(hrp and "["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]" or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
        end)
    end)

    curY = curY + 44
end

-- Auto Once button
local onceBtn = Instance.new("TextButton")
onceBtn.Parent = mainFrame
onceBtn.Size = UDim2.new(1,-20,0,40)
onceBtn.Position = UDim2.new(0,10,0,curY)
onceBtn.BackgroundColor3 = Color3.fromRGB(70,110,70)
onceBtn.Font = Enum.Font.GothamBold
onceBtn.TextSize = 14
onceBtn.TextColor3 = Color3.fromRGB(255,255,255)
onceBtn.Text = "▶️ Auto CP 1→6 (Once)"
onceBtn.MouseButton1Click:Connect(function()
    stopFlag = false
    autoLoop = false
    statusLabel.Text = "Status: Auto Once running..."
    task.spawn(function()
        runAllOnce()
        statusLabel.Text = "Status: Idle\nHRP: "..(hrp and "["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]" or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    end)
end)
curY = curY + 48

-- Auto Loop button
local loopBtn = Instance.new("TextButton")
loopBtn.Parent = mainFrame
loopBtn.Size = UDim2.new(1,-20,0,40)
loopBtn.Position = UDim2.new(0,10,0,curY)
loopBtn.BackgroundColor3 = Color3.fromRGB(110,90,40)
loopBtn.Font = Enum.Font.GothamBold
loopBtn.TextSize = 14
loopBtn.TextColor3 = Color3.fromRGB(255,255,255)
loopBtn.Text = "♻️ Auto CP Infinite"
loopBtn.MouseButton1Click:Connect(function()
    stopFlag = false
    autoLoop = true
    statusLabel.Text = "Status: Auto Loop running..."
    task.spawn(function()
        runInfinite()
    end)
end)
curY = curY + 48

-- Speed controls
local speedLabel = Instance.new("TextLabel")
speedLabel.Parent = mainFrame
speedLabel.Size = UDim2.new(1,-20,0,28)
speedLabel.Position = UDim2.new(0,10,0,curY)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.TextColor3 = Color3.fromRGB(230,230,230)
speedLabel.Text = "Speed: x"..string.format("%.2f", speedFactor)
curY = curY + 34

local speedUp = Instance.new("TextButton")
speedUp.Parent = mainFrame
speedUp.Size = UDim2.new(0.48,-12,0,36)
speedUp.Position = UDim2.new(0,10,0,curY)
speedUp.BackgroundColor3 = Color3.fromRGB(40,120,40)
speedUp.Font = Enum.Font.Gotham
speedUp.TextSize = 13
speedUp.TextColor3 = Color3.fromRGB(255,255,255)
speedUp.Text = "Speed +"

local speedDown = Instance.new("TextButton")
speedDown.Parent = mainFrame
speedDown.Size = UDim2.new(0.48,-12,0,36)
speedDown.Position = UDim2.new(0.52,10,0,curY)
speedDown.BackgroundColor3 = Color3.fromRGB(120,40,40)
speedDown.Font = Enum.Font.Gotham
speedDown.TextSize = 13
speedDown.TextColor3 = Color3.fromRGB(255,255,255)
speedDown.Text = "Speed -"

speedUp.MouseButton1Click:Connect(function()
    speedFactor = math.clamp(speedFactor + 0.25, 0.25, 5)
    speedLabel.Text = "Speed: x"..string.format("%.2f", speedFactor)
    statusLabel.Text = "Status: Idle\nHRP: "..(hrp and "["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]" or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    safeNotify("Speed set to x"..string.format("%.2f", speedFactor))
end)

speedDown.MouseButton1Click:Connect(function()
    speedFactor = math.clamp(speedFactor - 0.25, 0.25, 5)
    speedLabel.Text = "Speed: x"..string.format("%.2f", speedFactor)
    statusLabel.Text = "Status: Idle\nHRP: "..(hrp and "["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]" or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    safeNotify("Speed set to x"..string.format("%.2f", speedFactor))
end)
curY = curY + 48

-- Stop button
local stopButton = Instance.new("TextButton")
stopButton.Parent = mainFrame
stopButton.Size = UDim2.new(1,-20,0,40)
stopButton.Position = UDim2.new(0,10,0,curY)
stopButton.BackgroundColor3 = Color3.fromRGB(140,40,40)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 14
stopButton.TextColor3 = Color3.fromRGB(255,255,255)
stopButton.Text = "⏹️ STOP"
stopButton.MouseButton1Click:Connect(function()
    stopFlag = true
    autoLoop = false
    statusLabel.Text = "Status: Stopped by user\nHRP: "..(hrp and "["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]" or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    safeNotify("Stopped")
end)
curY = curY + 52

-- Rejoin button
local rejoinButton = Instance.new("TextButton")
rejoinButton.Parent = mainFrame
rejoinButton.Size = UDim2.new(1,-20,0,36)
rejoinButton.Position = UDim2.new(0,10,0,curY)
rejoinButton.BackgroundColor3 = Color3.fromRGB(40,80,120)
rejoinButton.Font = Enum.Font.Gotham
rejoinButton.TextSize = 14
rejoinButton.TextColor3 = Color3.fromRGB(255,255,255)
rejoinButton.Text = "🔄 Rejoin"
rejoinButton.MouseButton1Click:Connect(function()
    safeNotify("Rejoining...")
    safeRejoin()
end)
curY = curY + 44

-- status updater thread
task.spawn(function()
    while true do
        if statusLabel and statusLabel.Parent then
            statusLabel.Text = "Status: "..(autoLoop and "AutoLoop" or "Idle").."\nHRP: "..(hrp and "["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]" or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
        end
        task.wait(0.85)
    end
end)

-- finalize
safeNotify("Arunika CP Tool v24 siap — GUI muncul. Pilih mode.")
dbg("v24 loaded")

-- End of file
