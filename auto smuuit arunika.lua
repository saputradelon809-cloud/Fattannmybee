-- ============================================================================
-- Arunika CP Tool v24 Extended (Single-file, GitHub-ready)
-- Filename suggestion: arunika_cp_tool_v24_extended.lua
-- Upload to GitHub raw and load with:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/<username>/<repo>/main/arunika_cp_tool_v24_extended.lua"))()
--
-- This file is intentionally verbose, heavily commented, and formatted so it's
-- easy to read and modify.  It implements:
--   • Fixed CP coordinates (from user)
--   • Manual TP per CP
--   • Auto once (CP1 -> CP6)
--   • Auto infinite loop (respawn after CP6)
--   • Up-first -> translate -> SLOW descent (parachute-like)
--   • Delay + circle around CP + small slow jumps to ensure CP triggers
--   • Auto respawn after CP6
--   • Auto rejoin on teleport fail / GUI error prompts / disconnect-like text
--   • Anti-AFK (VirtualUser)
--   • Anti-seat (prevent sitting)
--   • Avoid other players (small upward dodge)
--   • Speed control (GUI) to control how slow/fast the movements feel
--   • Status GUI with lots of comments and clearly separated sections
--
-- NOTE: Running automation in online games may violate the game's rules.
-- Use only in accounts/servers where you have permission to use such scripts.
-- ============================================================================

-- ===========================
-- Section 1 — Services Setup
-- ===========================
local Players         = game:GetService("Players")
local CoreGui         = game:GetService("CoreGui")
local StarterGui      = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local RunService      = game:GetService("RunService")
local VirtualUser     = pcall(function() return game:GetService("VirtualUser") end) and game:GetService("VirtualUser") or nil

-- Local player reference — required for local scripts / injectors
local player = Players.LocalPlayer
if not player then
    warn("[ArunikaCP v24 Extended] LocalPlayer not found. Run this as a Local script / in executor.")
    return
end

-- ===========================
-- Section 2 — Global State
-- ===========================
-- These variables hold runtime state that controls behavior.
local humanoid             = nil      -- player's Humanoid object
local hrp                  = nil      -- HumanoidRootPart
local stopFlag             = false    -- when true, movement loops should stop quickly
local autoLoop             = false    -- whether infinite auto-loop mode is active
local loopCount            = 0        -- how many loops completed in infinite mode
local speedFactor          = 1.0      -- multiply/scale timing; lower -> slower, higher -> faster
local preferSlowDescent    = true     -- keep parachute/slomo falling behavior by default
local circleRadiusDefault  = 3        -- default radius for circling CPs
local circleStepsDefault   = 12       -- default steps for circling
local descentStepsDefault  = 60       -- default interpolation steps for slow descent
local minimalHRPWait       = 6        -- seconds to wait for HRP before aborting move

-- ===========================
-- Section 3 — Checkpoints Data
-- ===========================
-- These are the coordinates you provided. Change them here if map updates.
local checkpoints = {
    { name = "CP1", pos = Vector3.new(135, 144, -175) },
    { name = "CP2", pos = Vector3.new(326, 92, -434)  },
    { name = "CP3", pos = Vector3.new(476, 172, -940) },
    { name = "CP4", pos = Vector3.new(930, 136, -627) },
    { name = "CP5", pos = Vector3.new(923, 104, 280)  },
    { name = "CP6", pos = Vector3.new(257, 328, 699)  },
}

-- ===========================
-- Section 4 — Utility Functions
-- ===========================
-- Small helpers wrapped in pcall to be robust across different executors.

local function safeNotify(text)
    -- show a Roblox notification; may fail in some executors, so pcall
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Arunika CP Tool",
            Text = tostring(text),
            Duration = 3
        })
    end)
end

local function safeRejoin()
    -- attempt to rejoin current place (simple way to "reconnect")
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

local function dbg(...)
    -- debug print wrapper that won't error
    pcall(function() print("[ArunikaCP v24 Ext]", ...) end)
end

-- wait until hrp available up to timeout seconds
local function waitForHRP(timeout)
    timeout = timeout or minimalHRPWait
    local t = 0
    while not hrp and t < timeout do
        task.wait(0.2)
        t = t + 0.2
    end
    return hrp ~= nil
end

-- ensure humanoid/hrp are current; called on character spawn
local function setupCharacter(character)
    if not character then return end

    -- Acquire humanoid & HRP safely with fallback waits
    humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 6)
    hrp      = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 6)

    -- if we successfully got humanoid, wire up useful events
    if humanoid then
        -- prevent auto-sit by other game mechanics (seat part)
        humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
            if humanoid and humanoid.Sit then
                pcall(function() humanoid.Sit = false end)
            end
        end)

        -- on death: stop loops, respawn automatically
        humanoid.Died:Connect(function()
            -- stop running; autoLoop will be turned off
            stopFlag = true
            autoLoop = false

            safeNotify("Mati — respawn otomatis.")
            dbg("Humanoid died; reloading character")
            task.wait(2)
            -- attempt to respawn character
            pcall(function() player:LoadCharacter() end)
        end)
    else
        dbg("setupCharacter: humanoid not found")
    end
end

-- initial setup if character already exists at injection time
if player.Character then
    setupCharacter(player.Character)
end

-- re-setup each time character spawns (respawn)
player.CharacterAdded:Connect(function(char)
    task.delay(0.05, function() setupCharacter(char) end)
end)

-- ===========================
-- Section 5 — Auto-rejoin / error detection
-- ===========================
-- Attempt to rejoin automatically if teleport fails or if certain error prompts show.

player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        safeNotify("Teleport gagal — mencoba rejoin...")
        dbg("OnTeleport: TeleportState.Failed -> rejoin")
        safeRejoin()
    end
end)

-- watch CoreGui for text prompts that look like "Disconnected" or "Kicked" or "Error"
CoreGui.DescendantAdded:Connect(function(obj)
    pcall(function()
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local txt = tostring(obj.Text):lower()
            if txt:find("disconnected") or txt:find("kicked") or txt:find("teleport failed") or txt:find("error") then
                safeNotify("Prompt terdeteksi — mencoba rejoin...")
                dbg("Detected prompt text: ", obj.Text)
                safeRejoin()
            end
        elseif obj.Name == "ErrorPrompt" then
            safeNotify("ErrorPrompt muncul — mencoba rejoin...")
            dbg("Detected ErrorPrompt object")
            safeRejoin()
        end
    end)
end)

-- ===========================
-- Section 6 — Anti-AFK
-- ===========================
-- Use VirtualUser if available to prevent AFK kicks. Wrapped in pcall for safety.
pcall(function()
    if VirtualUser then
        player.Idled:Connect(function()
            -- simulate a right click (or other safe action)
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
    end
end)

-- ===========================
-- Section 7 — Avoid players
-- ===========================
-- If another player's HRP is near, we perform a small upward nudge to reduce collision.
local function avoidPlayers()
    if not hrp then return false end
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= player and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            local other = pl.Character.HumanoidRootPart
            local d = (other.Position - hrp.Position).Magnitude
            if d < 8 then
                -- small upward avoidance to prevent getting stuck/blocked
                pcall(function() hrp.CFrame = hrp.CFrame + Vector3.new(0, 8, 0) end)
                task.wait(0.15)
                dbg("avoidPlayers: nudged up to avoid", pl.Name)
                return true
            end
        end
    end
    return false
end

-- ===========================
-- Section 8 — Movement primitives
-- ===========================
-- We'll implement a detailed movement routine split into phases:
--  Phase A: vertical rise to a safe altitude above obstacles
--  Phase B: horizontal translation while at altitude
--  Phase C: SLOW descent (parachute-like) to just above CP
--  Phase D: small delay -> circle around CP -> small slow jumps
--
-- All waits are scaled by speedFactor. Lower speedFactor -> slower -> more human-like.

-- Helper: linear interpolation between vectors with many small steps
local function lerpVec(a, b, t)
    return a:Lerp(b, t)
end

-- slowDescentSteps: perform many small steps between start and target
local function slowDescentSteps(descStart, descTarget, steps)
    steps = steps or descentStepsDefault
    for i = 1, steps do
        if stopFlag then return end
        local t = i / steps
        local pos = descStart:Lerp(descTarget, t)
        pcall(function() hrp.CFrame = CFrame.new(pos) end)
        -- longer wait to be very slow; scale by speedFactor
        task.wait(0.035 / math.max(0.25, speedFactor))
    end
end

-- performCircleAndJumps: circle around cpPos with small slow jumps
local function performCircleAndJumps(cpPos, radius, steps)
    radius = radius or circleRadiusDefault
    steps = steps or circleStepsDefault

    -- brief settle delay
    task.wait(0.6 / math.max(0.25, speedFactor))

    -- circle around CP
    for s = 1, steps do
        if stopFlag then return end
        local ang = (s / steps) * math.pi * 2
        local offset = Vector3.new(math.cos(ang) * radius, 0, math.sin(ang) * radius)
        local target = cpPos + offset + Vector3.new(0, 2, 0)
        pcall(function() hrp.CFrame = CFrame.new(target) end)
        task.wait(0.28 / math.max(0.25, speedFactor))
    end

    -- small slow jumps to trigger CP logic reliably
    for j = 1, 3 do
        if stopFlag then return end
        if humanoid then
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
        else
            pcall(function() hrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0) end)
        end
        task.wait(0.45 / math.max(0.25, speedFactor))
    end
end

-- moveToCheckpointSlow: the full sequence to approach a checkpoint safely
local function moveToCheckpointSlow(cpEntry)
    if not cpEntry then return end
    if not waitForHRP(minimalHRPWait) then
        safeNotify("HRP belum siap — coba lagi sebentar")
        dbg("moveToCheckpointSlow aborted: HRP missing")
        return
    end

    -- Phase A: Vertical rise
    local startPos = hrp.Position
    local upHeight = math.max(100, (cpEntry.pos.Y - startPos.Y) + 80)  -- ensure high altitude
    local topPos = startPos + Vector3.new(0, upHeight, 0)

    local riseSteps = math.clamp(math.floor(upHeight / 3), 30, 140)
    for i = 1, riseSteps do
        if stopFlag then return end
        local t = i / riseSteps
        local pos = startPos:Lerp(topPos, t)
        pcall(function() hrp.CFrame = CFrame.new(pos) end)
        task.wait(0.02 / math.max(0.25, speedFactor))
    end

    task.wait(0.06)

    -- Phase B: horizontal translation (while at safe altitude)
    local aboveTarget = Vector3.new(cpEntry.pos.X, topPos.Y, cpEntry.pos.Z)
    local fromPos = hrp.Position
    local horizDist = (fromPos - aboveTarget).Magnitude
    local horizSteps = math.clamp(math.floor(horizDist / 2) + 30, 30, 180)
    for i = 1, horizSteps do
        if stopFlag then return end
        local t = i / horizSteps
        local pos = fromPos:Lerp(aboveTarget, t)
        pcall(function() hrp.CFrame = CFrame.new(pos) end)
        task.wait(0.02 / math.max(0.25, speedFactor))
    end

    task.wait(0.05)

    -- Phase C: slow descent — parachute-like
    local descStart = hrp.Position
    local descTarget = cpEntry.pos + Vector3.new(0, 4, 0)  -- stop slightly above the exact coordinate
    -- we intentionally use many steps for very slow descent
    slowDescentSteps(descStart, descTarget, descentStepsDefault)

    -- final micro-adjust to be exactly above CP and small delay
    pcall(function() hrp.CFrame = CFrame.new(cpEntry.pos + Vector3.new(0, 2, 0)) end)
    task.wait(0.08 / math.max(0.25, speedFactor))

    -- Phase D: delay, circle, and small jumps to ensure game registers the checkpoint
    task.wait(0.9 / math.max(0.25, speedFactor))
    performCircleAndJumps(cpEntry.pos, circleRadiusDefault, circleStepsDefault)
    task.wait(0.5 / math.max(0.25, speedFactor))

    -- Notify completion for this CP
    safeNotify("✅ " .. tostring(cpEntry.name) .. " terambil")
    dbg("Arrived at CP:", cpEntry.name)
end

-- ===========================
-- Section 9 — Runners (single & loop)
-- ===========================
-- runOnce: iterate CP1..CP6 once, then respawn
local function runOnce()
    stopFlag = false
    dbg("runOnce: starting")
    for i, cp in ipairs(checkpoints) do
        if stopFlag then
            dbg("runOnce: stopped early by user")
            break
        end
        safeNotify("➡️ Menuju " .. cp.name)
        moveToCheckpointSlow(cp)
        task.wait(0.9 / math.max(0.25, speedFactor))
        avoidPlayers()
    end

    if not stopFlag then
        -- auto respawn after finishing CP6
        safeNotify("🎉 Semua CP selesai — respawn otomatis")
        dbg("runOnce: finished; respawning")
        task.wait(0.9)
        pcall(function() player:LoadCharacter() end)
    end
end

-- runInfinite: repeat runs with respawn between loops
local function runInfinite()
    stopFlag = false
    autoLoop = true
    loopCount = 0
    dbg("runInfinite: starting")
    while autoLoop do
        loopCount = loopCount + 1
        safeNotify("🔁 Memulai loop ke-" .. tostring(loopCount))
        for i, cp in ipairs(checkpoints) do
            if stopFlag or (not autoLoop) then
                dbg("runInfinite: stopped mid-loop")
                break
            end
            safeNotify("➡️ " .. cp.name .. " (Loop " .. tostring(loopCount) .. ")")
            moveToCheckpointSlow(cp)
            task.wait(0.9 / math.max(0.25, speedFactor))
            avoidPlayers()
        end

        if autoLoop and not stopFlag then
            safeNotify("🔄 Respawn ulang (loop)")
            dbg("runInfinite: loop complete; respawning")
            pcall(function() player:LoadCharacter() end)
            task.wait(3.5 / math.max(0.25, speedFactor))
        end
    end
    dbg("runInfinite: ended")
end

-- ===========================
-- Section 10 — GUI (very verbose & user-friendly)
-- ===========================
-- Build a visually clear GUI containing:
--  - per-CP manual buttons
--  - Auto Once button
--  - Auto Loop button
--  - Speed control (plus/minus)
--  - Stop & Rejoin buttons
--  - Status label

-- remove old GUI (avoid duplicates on re-inject)
if CoreGui:FindFirstChild("ArunikaCPv24Extended") then
    pcall(function() CoreGui.ArunikaCPv24Extended:Destroy() end)
end

-- create root ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ArunikaCPv24Extended"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- main draggable frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 820)
mainFrame.Position = UDim2.new(0, 12, 0, 30)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- title label
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.Size = UDim2.new(1, 0, 0, 36)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Text = "🌸 Arunika CP Tool v24 Extended (Super Long)"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- status label area (multiline)
local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = mainFrame
statusLabel.Size = UDim2.new(1, -22, 0, 80)
statusLabel.Position = UDim2.new(0, 11, 0, 46)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 13
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextWrapped = true
statusLabel.Text = "Status: Idle\nHRP: -\nLoop: 0\nSpeed: x1.00"

-- vertical stacking start Y
local startY = 140

-- create per-CP buttons in a column; each button triggers manual move
for i, cp in ipairs(checkpoints) do
    local btn = Instance.new("TextButton")
    btn.Parent = mainFrame
    btn.Size = UDim2.new(1, -22, 0, 40)
    btn.Position = UDim2.new(0, 11, 0, startY)
    btn.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = cp.name .. "  " .. string.format("(%d, %d, %d)", cp.pos.X, cp.pos.Y, cp.pos.Z)
    btn.AutoButtonColor = true

    btn.MouseButton1Click:Connect(function()
        -- when clicked: stop any running loops and go to this CP manually
        stopFlag = false
        autoLoop = false
        statusLabel.Text = "Status: Going to " .. cp.name .. "\nHRP: " .. (hrp and tostring(hrp.Position) or "-") .. "\nLoop: " .. tostring(loopCount) .. "\nSpeed: x" .. string.format("%.2f", speedFactor)
        task.spawn(function()
            moveToCheckpointSlow(cp)
            statusLabel.Text = "Status: Idle\nHRP: " .. (hrp and ("[" .. math.floor(hrp.Position.X) .. "," .. math.floor(hrp.Position.Y) .. "," .. math.floor(hrp.Position.Z) .. "]") or "-") .. "\nLoop: " .. tostring(loopCount) .. "\nSpeed: x" .. string.format("%.2f", speedFactor)
        end)
    end)

    startY = startY + 46
end

-- Auto Once button (run CP1..CP6 once)
local autoOnceBtn = Instance.new("TextButton")
autoOnceBtn.Parent = mainFrame
autoOnceBtn.Size = UDim2.new(1, -22, 0, 44)
autoOnceBtn.Position = UDim2.new(0, 11, 0, startY)
autoOnceBtn.BackgroundColor3 = Color3.fromRGB(70, 115, 70)
autoOnceBtn.Font = Enum.Font.GothamBold
autoOnceBtn.TextSize = 14
autoOnceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoOnceBtn.Text = "▶️ Auto CP 1→6 (Once)"
autoOnceBtn.AutoButtonColor = true

autoOnceBtn.MouseButton1Click:Connect(function()
    stopFlag = false
    autoLoop = false
    statusLabel.Text = "Status: Auto Once running..."
    task.spawn(function()
        runOnce()
        statusLabel.Text = "Status: Idle\nHRP: " .. (hrp and ("[" .. math.floor(hrp.Position.X) .. "," .. math.floor(hrp.Position.Y) .. "," .. math.floor(hrp.Position.Z) .. "]") or "-") .. "\nLoop: " .. tostring(loopCount) .. "\nSpeed: x" .. string.format("%.2f", speedFactor)
    end)
end)
startY = startY + 54

-- Auto Loop button (infinite repeat)
local autoLoopBtn = Instance.new("TextButton")
autoLoopBtn.Parent = mainFrame
autoLoopBtn.Size = UDim2.new(1, -22, 0, 44)
autoLoopBtn.Position = UDim2.new(0, 11, 0, startY)
autoLoopBtn.BackgroundColor3 = Color3.fromRGB(115, 95, 50)
autoLoopBtn.Font = Enum.Font.GothamBold
autoLoopBtn.TextSize = 14
autoLoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoLoopBtn.Text = "♻️ Auto CP Infinite (Loop)"
autoLoopBtn.AutoButtonColor = true

autoLoopBtn.MouseButton1Click:Connect(function()
    stopFlag = false
    autoLoop = true
    statusLabel.Text = "Status: Auto Loop running..."
    task.spawn(function()
        runInfinite()
    end)
end)
startY = startY + 58

-- Speed label and plus/minus controls
local speedLabel = Instance.new("TextLabel")
speedLabel.Parent = mainFrame
speedLabel.Size = UDim2.new(1, -22, 0, 30)
speedLabel.Position = UDim2.new(0, 11, 0, startY)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 13
speedLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
speedLabel.Text = "Speed: x" .. string.format("%.2f", speedFactor)
startY = startY + 36

local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Parent = mainFrame
speedUpBtn.Size = UDim2.new(0.48, -12, 0, 40)
speedUpBtn.Position = UDim2.new(0, 11, 0, startY)
speedUpBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
speedUpBtn.Font = Enum.Font.Gotham
speedUpBtn.TextSize = 13
speedUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpBtn.Text = "Speed +"

local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Parent = mainFrame
speedDownBtn.Size = UDim2.new(0.48, -12, 0, 40)
speedDownBtn.Position = UDim2.new(0.52, 11, 0, startY)
speedDownBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
speedDownBtn.Font = Enum.Font.Gotham
speedDownBtn.TextSize = 13
speedDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownBtn.Text = "Speed -"

speedUpBtn.MouseButton1Click:Connect(function()
    -- increase speed factor (less slow)
    speedFactor = math.clamp(speedFactor + 0.25, 0.25, 5)
    speedLabel.Text = "Speed: x" .. string.format("%.2f", speedFactor)
    statusLabel.Text = "Status: Idle\nHRP: " .. (hrp and ("[" .. math.floor(hrp.Position.X) .. "," .. math.floor(hrp.Position.Y) .. "," .. math.floor(hrp.Position.Z) .. "]") or "-") .. "\nLoop: " .. tostring(loopCount) .. "\nSpeed: x" .. string.format("%.2f", speedFactor)
    safeNotify("Speed set to x" .. string.format("%.2f", speedFactor))
end)

speedDownBtn.MouseButton1Click:Connect(function()
    -- decrease speed factor (more slow)
    speedFactor = math.clamp(speedFactor - 0.25, 0.25, 5)
    speedLabel.Text = "Speed: x" .. string.format("%.2f", speedFactor)
    statusLabel.Text = "Status: Idle\nHRP: " .. (hrp and ("[" .. math.floor(hrp.Position.X) .. "," .. math.floor(hrp.Position.Y) .. "," .. math.floor(hrp.Position.Z) .. "]") or "-") .. "\nLoop: " .. tostring(loopCount) .. "\nSpeed: x" .. string.format("%.2f", speedFactor)
    safeNotify("Speed set to x" .. string.format("%.2f", speedFactor))
end)
startY = startY + 56

-- STOP button (immediately halts)
local stopBtn = Instance.new("TextButton")
stopBtn.Parent = mainFrame
stopBtn.Size = UDim2.new(1, -22, 0, 46)
stopBtn.Position = UDim2.new(0, 11, 0, startY)
stopBtn.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 16
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.Text = "⏹️ STOP"
stopBtn.AutoButtonColor = true

stopBtn.MouseButton1Click:Connect(function()
    stopFlag = true
    autoLoop = false
    statusLabel.Text = "Status: Stopped by user\nHRP: " .. (hrp and ("[" .. math.floor(hrp.Position.X) .. "," .. math.floor(hrp.Position.Y) .. "," .. math.floor(hrp.Position.Z) .. "]") or "-") .. "\nLoop: " .. tostring(loopCount) .. "\nSpeed: x" .. string.format("%.2f", speedFactor)
    safeNotify("Stopped")
end)
startY = startY + 64

-- Rejoin button
local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Parent = mainFrame
rejoinBtn.Size = UDim2.new(1, -22, 0, 44)
rejoinBtn.Position = UDim2.new(0, 11, 0, startY)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 120)
rejoinBtn.Font = Enum.Font.Gotham
rejoinBtn.TextSize = 14
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.Text = "🔄 Rejoin"
rejoinBtn.AutoButtonColor = true

rejoinBtn.MouseButton1Click:Connect(function()
    safeNotify("Rejoining...")
    safeRejoin()
end)

-- status updater loop to refresh HRP / Loop / Speed periodically
task.spawn(function()
    while true do
        if statusLabel and statusLabel.Parent then
            local hrpStr = hrp and ("[" .. math.floor(hrp.Position.X) .. "," .. math.floor(hrp.Position.Y) .. "," .. math.floor(hrp.Position.Z) .. "]") or "-"
            statusLabel.Text = "Status: " .. (autoLoop and "AutoLoop" or "Idle") .. "\nHRP: " .. hrpStr .. "\nLoop: " .. tostring(loopCount) .. "\nSpeed: x" .. string.format("%.2f", speedFactor)
        end
        task.wait(0.8)
    end
end)

-- ===========================
-- Section 11 — Final ready notify
-- ===========================
safeNotify("Arunika CP Tool v24 Extended siap — GUI muncul. Pilih mode.")
dbg("Arunika CP Tool v24 Extended loaded successfully")

-- End of file
-- ============================================================================
