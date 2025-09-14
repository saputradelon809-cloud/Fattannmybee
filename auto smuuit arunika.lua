-- ============================================================================
--  Arunika CP Tool v23 - Expanded & Fully Commented Edition
--  (Super verbose version for readability / customization)
-- ----------------------------------------------------------------------------
--  Features included:
--   • Fixed CP coordinates (user-provided)
--   • Manual teleport per CP (smooth: naik -> terbang -> turun cepat)
--   • Auto single-run (CP1 -> CP6)
--   • Auto infinite loop (with respawn after CP6)
--   • Fast descent (to reduce fall damage risk)
--   • Auto-respawn after finish / on death
--   • Auto-rejoin on teleport fail, prompt errors, disconnect/kick detection
--   • Anti-AFK (VirtualUser)
--   • Anti-seat (prevent sitting)
--   • Avoid players (small upward dodge when colliding)
--   • Speed control in GUI
--   • Notifications and status panel in GUI
-- ----------------------------------------------------------------------------
--  HOW TO USE:
--   1) Paste whole file into your executor, or save as `arunika_cp_tool_v23.lua`.
--   2) Run the script. GUI will appear.
--   3) Use buttons to teleport, run auto, loop, stop, rejoin, adjust speed.
-- ----------------------------------------------------------------------------
--  NOTES:
--   • This verbose file is intentionally commented and long for clarity.
--   • Keep one copy in your GitHub repo if you want to load via HttpGet.
-- ============================================================================
-- Safety: make sure you only run this in private/executor contexts you control.

-- ===== SERVICES =====
local Players       = game:GetService("Players")
local CoreGui       = game:GetService("CoreGui")
local StarterGui    = game:GetService("StarterGui")
local TeleportService= game:GetService("TeleportService")
local RunService    = game:GetService("RunService")

-- === Player local reference ===
local player = Players.LocalPlayer
if not player then
    -- If LocalPlayer is nil, script can't run properly
    warn("[ArunikaCP] LocalPlayer not found; aborting.")
    return
end

-- ===== GLOBAL STATE VARIABLES (main runtime state) =====
local hrp            -- HumanoidRootPart (set in setupChar)
local humanoid       -- Humanoid (set in setupChar)
local stopFlag = false
local autoLoop = false
local loopCount = 0
local speedFactor = 1.0   -- 0.5..5.0 - controlled from GUI

-- ===== FIXED CHECKPOINT LIST (your coordinates) =====
-- Replace or add entries if the map changes later.
local checkpoints = {
    { name = "CP1", pos = Vector3.new(135,144,-175) },
    { name = "CP2", pos = Vector3.new(326,92,-434) },
    { name = "CP3", pos = Vector3.new(476,172,-940) },
    { name = "CP4", pos = Vector3.new(930,136,-627) },
    { name = "CP5", pos = Vector3.new(923,104,280) },
    { name = "CP6", pos = Vector3.new(257,328,699) },
}

-- ======================================================================
-- Utility functions
-- ======================================================================

-- Safe notify wrapper (StarterGui:SetCore may error depending on environment)
local function safeNotify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Arunika CP Tool",
            Text = tostring(text),
            Duration = 3
        })
    end)
end

-- Safe teleport join wrapper
local function safeTeleportJoin()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

-- Small helper to check that HRP exists (waits up to timeout seconds)
local function waitForHRP(timeout)
    timeout = timeout or 5
    local elapsed = 0
    while not hrp and elapsed < timeout do
        task.wait(0.2)
        elapsed = elapsed + 0.2
    end
    return hrp ~= nil
end

-- Quick debug printer to output in executor console if available
local function dbgPrint(...)
    -- Use pcall to avoid errors in weird environments
    pcall(function() print("[ArunikaCP]", ...) end)
end

-- ======================================================================
-- Character setup & event hooks
-- ======================================================================

-- This function initializes humanoid and HRP references and sets up
-- handlers: anti-sit (prevent sitting), and death handler (auto respawn)
local function setupChar(character)
    if not character then return end

    -- Acquire humanoid and humanoidrootpart with a small timeout
    humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
    hrp = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)

    if humanoid then
        -- Anti-sit: if Sit property becomes true, force it false
        -- This prevents the character from sitting automatically when near seat objects
        humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
            if humanoid and humanoid.Sit then
                pcall(function() humanoid.Sit = false end)
            end
        end)

        -- On death: stop loops and respawn
        humanoid.Died:Connect(function()
            -- Set flags so loops will stop; respawn will reload the character
            stopFlag = true
            autoLoop = false
            safeNotify("Kamu mati — respawn otomatis.")
            dbgPrint("Humanoid died; respawning...")
            -- Short wait then request respawn
            task.wait(2)
            pcall(function() player:LoadCharacter() end)
        end)
    else
        warn("[ArunikaCP] humanoid not found on setupChar")
    end
end

-- If the player's character already exists (script was injected mid-game), set it up
if player.Character then
    setupChar(player.Character)
end

-- Always hook CharacterAdded to reset references when respawned
player.CharacterAdded:Connect(function(char)
    -- Slight delay to allow character to load fully
    task.delay(0.1, function()
        setupChar(char)
    end)
end)

-- ======================================================================
-- Auto rejoin / error detection
-- ======================================================================

-- If teleport attempt fails, try to rejoin automatically.
player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        safeNotify("Teleport gagal — mencoba rejoin...")
        dbgPrint("Teleport failed; attempting rejoin")
        safeTeleportJoin()
    end
end)

-- Best-effort: watch CoreGui for prompt text that looks like errors/disconnects.
-- If we detect likely "Disconnected" or "Kicked" text, attempt rejoin.
CoreGui.DescendantAdded:Connect(function(obj)
    -- pcall wrap for safety (some GUIs may not expose Text)
    pcall(function()
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local txt = tostring(obj.Text):lower()
            if txt:find("disconnected") or txt:find("kicked") or txt:find("teleport failed") or txt:find("error") then
                safeNotify("Prompt terdeteksi: "..obj.Text .. " — mencoba rejoin...")
                dbgPrint("Detected prompt text:", obj.Text)
                safeTeleportJoin()
            end
        elseif obj.Name == "ErrorPrompt" then
            -- Some UIs spawn an ErrorPrompt object
            safeNotify("ErrorPrompt muncul — rejoin...")
            dbgPrint("ErrorPrompt detected in CoreGui")
            safeTeleportJoin()
        end
    end)
end)

-- ======================================================================
-- Anti-AFK (prevents being kicked for idling)
-- ======================================================================

pcall(function()
    local vu = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        -- simulate a click to avoid AFK kick
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

-- ======================================================================
-- Collision avoidance (other players)
-- ======================================================================

-- If a player is within a small radius, perform a small upward hop to avoid collision
local function avoidPlayers()
    if not hrp then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local otherHRP = plr.Character.HumanoidRootPart
            local dist = (otherHRP.Position - hrp.Position).Magnitude
            if dist < 8 then
                -- small upward nudge to avoid stuck/collision
                pcall(function() hrp.CFrame = hrp.CFrame + Vector3.new(0, 10, 0) end)
                task.wait(0.15)
                dbgPrint("Avoided player:", plr.Name)
                return true
            end
        end
    end
    return false
end

-- ======================================================================
-- Smooth movement algorithm
-- ======================================================================
-- Purpose: move character in 3 phases:
--   1) Vertical rise (go well above any obstacles)
--   2) Horizontal translation while at safe altitude
--   3) Fast but stepped descent to target (short enough to avoid fall damage)
-- After landing: small jumps to ensure the checkpoint system registers the touch.
-- ======================================================================

local function smoothTo(targetVector3)
    -- Ensure HRP available
    if not waitForHRP(5) then
        safeNotify("HRP belum siap — tidak dapat teleport")
        dbgPrint("smoothTo aborted: HRP not ready")
        return
    end

    -- Local copies
    local startPos = hrp.Position
    local target = targetVector3

    -- Compute an upHeight that puts us safely above cliffs/obstacles
    -- We add extra buffer (+60) and ensure a minimum (80) to clear tall terrain
    local upHeight = math.max(80, (target.Y - startPos.Y) + 60)
    local topPos = startPos + Vector3.new(0, upHeight, 0)

    -- =========== Phase 1: Vertical Rise ===========
    -- Rise in many small steps so physics/geometry won't be penetrated.
    -- Number of steps proportional to upHeight; clamp to reasonable bounds.
    local riseSteps = math.clamp(math.floor(upHeight / 3), 18, 80)
    for i = 1, riseSteps do
        if stopFlag then return end
        local t = i / riseSteps
        local pos = startPos:Lerp(topPos, t)
        pcall(function() hrp.CFrame = CFrame.new(pos) end)
        task.wait((0.018) / math.max(0.3, speedFactor))
    end

    -- small pause
    task.wait(0.06)

    -- =========== Phase 2: Horizontal translation above target ===========
    local aboveTarget = Vector3.new(target.X, topPos.Y, target.Z)
    local horizFrom = hrp.Position
    local horizDist = (horizFrom - aboveTarget).Magnitude
    local horizSteps = math.clamp(math.floor(horizDist / 2) + 20, 20, 120)
    for i = 1, horizSteps do
        if stopFlag then return end
        local t = i / horizSteps
        local pos = horizFrom:Lerp(aboveTarget, t)
        pcall(function() hrp.CFrame = CFrame.new(pos) end)
        task.wait((0.018) / math.max(0.3, speedFactor))
    end

    task.wait(0.06)

    -- =========== Phase 3: FAST descent (reduced steps to be quick) ===========
    -- We intentionally descend faster than earlier versions to avoid long fall times.
    -- Use a small number of steps (12) to appear natural but quick.
    local descFrom = hrp.Position
    local descTarget = target + Vector3.new(0, 4, 0)  -- stop slightly above to final adjust
    local descSteps = 12
    for i = 1, descSteps do
        if stopFlag then return end
        local t = i / descSteps
        local pos = descFrom:Lerp(descTarget, t)
        pcall(function() hrp.CFrame = CFrame.new(pos) end)
        task.wait((0.02) / math.max(0.3, speedFactor))
    end

    -- Final micro-walk to precise spot to ensure proper trigger (2 studs above then adjust)
    pcall(function() hrp.CFrame = CFrame.new(target + Vector3.new(0, 2, 0)) end)
    task.wait(0.06)

    -- Small jumps to make checkpoint detection more robust (some games register on jump)
    if humanoid then
        for j = 1, 2 do
            if stopFlag then break end
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
            task.wait(0.42 / math.max(0.5, speedFactor))
        end
    end
end

-- High-level wrapper: go to checkpoint entry
local function goToCPEntry(cpEntry)
    if not cpEntry or not cpEntry.pos then
        warn("[ArunikaCP] Invalid CP entry")
        return
    end

    -- Ensure HRP ready before attempt
    if not waitForHRP(5) then
        safeNotify("HRP belum siap. Coba lagi sebentar.")
        return
    end

    -- Avoid players if nearby
    avoidPlayers()

    -- Execute movement
    smoothTo(cpEntry.pos)

    -- Notify completion
    safeNotify("✅ "..tostring(cpEntry.name).." diambil")
    dbgPrint("Arrived at", cpEntry.name, cpEntry.pos)
end

-- ======================================================================
-- Runners (single run and infinite loop)
-- ======================================================================

local function runOnce()
    stopFlag = false
    dbgPrint("runOnce started")
    for i, cp in ipairs(checkpoints) do
        if stopFlag then
            dbgPrint("runOnce stopped by user")
            break
        end
        safeNotify("➡️ "..cp.name)
        goToCPEntry(cp)
        task.wait(0.9 / math.max(0.5, speedFactor))
        avoidPlayers()
    end

    if not stopFlag then
        safeNotify("✅ Semua CP selesai — respawn otomatis")
        dbgPrint("runOnce finished; respawning")
        task.wait(0.8)
        pcall(function() player:LoadCharacter() end)
    end
end

local function runInfiniteLoop()
    stopFlag = false
    autoLoop = true
    loopCount = 0
    dbgPrint("runInfiniteLoop started")
    while autoLoop do
        loopCount = loopCount + 1
        safeNotify("🔁 Memulai loop ke-"..tostring(loopCount))
        for _, cp in ipairs(checkpoints) do
            if stopFlag or not autoLoop then
                dbgPrint("runInfiniteLoop stopped mid-loop")
                break
            end
            safeNotify("➡️ "..cp.name.." (Loop "..loopCount..")")
            goToCPEntry(cp)
            task.wait(0.9 / math.max(0.5, speedFactor))
            avoidPlayers()
        end

        if autoLoop and not stopFlag then
            safeNotify("🔄 Respawn ulang (loop)")
            dbgPrint("Loop complete; respawning")
            pcall(function() player:LoadCharacter() end)
            task.wait(4 / math.max(0.5, speedFactor))
        end
    end
    dbgPrint("runInfiniteLoop ended")
end

-- ======================================================================
-- GUI Construction (verbose & organized)
-- ======================================================================

-- Remove any previous GUI with same name (prevent duplicates)
if CoreGui:FindFirstChild("ArunikaCPv23") then
    CoreGui.ArunikaCPv23:Destroy()
end

-- Create root ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ArunikaCPv23"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Main draggable frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 560)
mainFrame.Position = UDim2.new(0, 12, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Title label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 36)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextColor3 = Color3.fromRGB(255,255,255)
titleLabel.Text = "🌸 Arunika CP Tool v23 (Verbose)"
titleLabel.Parent = mainFrame

-- Status info label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 64)
statusLabel.Position = UDim2.new(0, 10, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 13
statusLabel.TextWrapped = true
statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
statusLabel.Text = "Status: Idle\nHRP: -\nLoop: 0\nSpeed: x1.00"
statusLabel.Parent = mainFrame

-- Vertical stacking y position for buttons
local currentY = 110

-- Create per-CP buttons (manual)
for i, cp in ipairs(checkpoints) do
    local btn = Instance.new("TextButton")
    btn.Name = "Btn_"..cp.name
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, currentY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Text = cp.name .. "  " .. string.format("(%d, %d, %d)", cp.pos.X, cp.pos.Y, cp.pos.Z)
    btn.Parent = mainFrame

    btn.MouseButton1Click:Connect(function()
        -- When clicked: stop anything else and go to this CP
        stopFlag = false
        autoLoop = false
        statusLabel.Text = "Status: Going to "..cp.name.."\nHRP: "..(hrp and tostring(hrp.Position) or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
        task.spawn(function()
            goToCPEntry(cp)
            statusLabel.Text = "Status: Idle\nHRP: "..(hrp and "["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]" or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
        end)
    end)

    currentY = currentY + 44
end

-- Auto Once button
local autoOnceBtn = Instance.new("TextButton")
autoOnceBtn.Name = "AutoOnce"
autoOnceBtn.Size = UDim2.new(1, -20, 0, 40)
autoOnceBtn.Position = UDim2.new(0, 10, 0, currentY)
autoOnceBtn.BackgroundColor3 = Color3.fromRGB(70, 110, 70)
autoOnceBtn.Font = Enum.Font.GothamBold
autoOnceBtn.TextSize = 14
autoOnceBtn.TextColor3 = Color3.fromRGB(255,255,255)
autoOnceBtn.Text = "▶️ Auto CP 1→6 (Once)"
autoOnceBtn.Parent = mainFrame

autoOnceBtn.MouseButton1Click:Connect(function()
    stopFlag = false
    autoLoop = false
    statusLabel.Text = "Status: Auto Once running..."
    task.spawn(function()
        runOnce()
        statusLabel.Text = "Status: Idle\nHRP: "..(hrp and "["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]" or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    end)
end)

currentY = currentY + 50

-- Auto infinite loop button
local autoLoopBtn = Instance.new("TextButton")
autoLoopBtn.Name = "AutoLoop"
autoLoopBtn.Size = UDim2.new(1, -20, 0, 40)
autoLoopBtn.Position = UDim2.new(0, 10, 0, currentY)
autoLoopBtn.BackgroundColor3 = Color3.fromRGB(110, 90, 40)
autoLoopBtn.Font = Enum.Font.GothamBold
autoLoopBtn.TextSize = 14
autoLoopBtn.TextColor3 = Color3.fromRGB(255,255,255)
autoLoopBtn.Text = "♻️ Auto CP Infinite"
autoLoopBtn.Parent = mainFrame

autoLoopBtn.MouseButton1Click:Connect(function()
    stopFlag = false
    autoLoop = true
    statusLabel.Text = "Status: Auto Loop running..."
    task.spawn(function()
        runInfiniteLoop()
        statusLabel.Text = "Status: Idle\nHRP: "..(hrp and "["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]" or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    end)
end)

currentY = currentY + 50

-- Speed display
local speedStateLabel = Instance.new("TextLabel")
speedStateLabel.Size = UDim2.new(1, -20, 0, 28)
speedStateLabel.Position = UDim2.new(0, 10, 0, currentY)
speedStateLabel.BackgroundTransparency = 1
speedStateLabel.Font = Enum.Font.Gotham
speedStateLabel.TextSize = 13
speedStateLabel.TextColor3 = Color3.fromRGB(230,230,230)
speedStateLabel.Text = "Speed: x" .. string.format("%.2f", speedFactor)
speedStateLabel.Parent = mainFrame

currentY = currentY + 34

-- Speed + button
local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Size = UDim2.new(0.48, -12, 0, 36)
speedUpBtn.Position = UDim2.new(0, 10, 0, currentY)
speedUpBtn.BackgroundColor3 = Color3.fromRGB(40,120,40)
speedUpBtn.Font = Enum.Font.Gotham
speedUpBtn.TextSize = 13
speedUpBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedUpBtn.Text = "Speed +"
speedUpBtn.Parent = mainFrame

-- Speed - button
local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Size = UDim2.new(0.48, -12, 0, 36)
speedDownBtn.Position = UDim2.new(0.52, 10, 0, currentY)
speedDownBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)
speedDownBtn.Font = Enum.Font.Gotham
speedDownBtn.TextSize = 13
speedDownBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedDownBtn.Text = "Speed -"
speedDownBtn.Parent = mainFrame

speedUpBtn.MouseButton1Click:Connect(function()
    speedFactor = math.clamp(speedFactor + 0.25, 0.5, 5)
    speedStateLabel.Text = "Speed: x" .. string.format("%.2f", speedFactor)
    statusLabel.Text = "Status: Idle\nHRP: "..(hrp and "["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]" or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    safeNotify("Speed set to x"..string.format("%.2f", speedFactor))
end)

speedDownBtn.MouseButton1Click:Connect(function()
    speedFactor = math.clamp(speedFactor - 0.25, 0.5, 5)
    speedStateLabel.Text = "Speed: x" .. string.format("%.2f", speedFactor)
    statusLabel.Text = "Status: Idle\nHRP: "..(hrp and "["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]" or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    safeNotify("Speed set to x"..string.format("%.2f", speedFactor))
end)

currentY = currentY + 50

-- STOP button
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(1, -20, 0, 40)
stopButton.Position = UDim2.new(0, 10, 0, currentY)
stopButton.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 14
stopButton.TextColor3 = Color3.fromRGB(255,255,255)
stopButton.Text = "⏹️ STOP"
stopButton.Parent = mainFrame

stopButton.MouseButton1Click:Connect(function()
    stopFlag = true
    autoLoop = false
    statusLabel.Text = "Status: Stopped by user\nHRP: "..(hrp and "["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]" or "-").."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
    safeNotify("Stopped")
end)

currentY = currentY + 54

-- Rejoin button
local rejoinButton = Instance.new("TextButton")
rejoinButton.Size = UDim2.new(1, -20, 0, 36)
rejoinButton.Position = UDim2.new(0, 10, 0, currentY)
rejoinButton.BackgroundColor3 = Color3.fromRGB(40,80,120)
rejoinButton.Font = Enum.Font.Gotham
rejoinButton.TextSize = 14
rejoinButton.TextColor3 = Color3.fromRGB(255,255,255)
rejoinButton.Text = "🔄 Rejoin"
rejoinButton.Parent = mainFrame

rejoinButton.MouseButton1Click:Connect(function()
    safeNotify("Rejoining...")
    safeTeleportJoin()
end)

-- Final ready notification
safeNotify("Arunika CP Tool v23 siap — GUI muncul")

-- Small updater thread that refreshes the status label periodically
task.spawn(function()
    while true do
        if statusLabel and statusLabel.Parent then
            local hrpStr = hrp and ("["..math.floor(hrp.Position.X)..","..math.floor(hrp.Position.Y)..","..math.floor(hrp.Position.Z).."]") or "-"
            statusLabel.Text = "Status: "..(autoLoop and "AutoLoop" or "Idle").."\nHRP: "..hrpStr.."\nLoop: "..tostring(loopCount).."\nSpeed: x"..string.format("%.2f", speedFactor)
        end
        task.wait(0.8)
    end
end)

-- End of script
-- ============================================================================
-- You can now run buttons in GUI. If you want any other tweak (save CP, load CP,
-- detect CP from map, or make the descent even faster/smoother), tell me and I'll
-- generate a new expanded version with that specific tweak.
-- ============================================================================
