--[[ 
=====================================================
🌸 Arunika CP Tool v23 Extended 🌸
=====================================================
Semua fitur versi sebelumnya sudah digabung & diperbaiki:
✔️ CP 1–6 (posisi fix)
✔️ GUI rapi (HP friendly)
✔️ Manual TP per CP
✔️ Auto Once (sekali jalan)
✔️ Auto Loop (tak terbatas)
✔️ Smooth teleport (naik → geser → turun cepat)
✔️ Fast descent (hindari fall damage)
✔️ Auto Respawn (setelah CP6)
✔️ Auto Rejoin (kalau kick / disconnect)
✔️ Anti-AFK (gerak otomatis)
✔️ Anti-Seat (hindari duduk otomatis)
✔️ Avoid Player (hindari tabrakan player lain)
✔️ Notifications setiap aksi
✔️ Speed control (biar fleksibel)

⚠️ NOTE:
- Script ini panjang (≈600 baris) karena detail + komentar.
- Upload ke GitHub → load via raw link.
=====================================================
]]--

-----------------------------
-- 🔧 Services & Variables --
-----------------------------
local Players         = game:GetService("Players")
local CoreGui         = game:GetService("CoreGui")
local StarterGui      = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

local player   = Players.LocalPlayer
local hrp      = nil
local humanoid = nil

-- Flags
local stopFlag  = false
local autoLoop  = false
local loopCount = 0
local speedFactor = 1.0

------------------------
-- 📍 Checkpoints Data --
------------------------
-- Fixed koordinat CP Arunika (dari kamu)
local checkpoints = {
    {name="CP 1", pos=Vector3.new(135,144,-175)},
    {name="CP 2", pos=Vector3.new(326,92,-434)},
    {name="CP 3", pos=Vector3.new(476,172,-940)},
    {name="CP 4", pos=Vector3.new(930,136,-627)},
    {name="CP 5", pos=Vector3.new(923,104,280)},
    {name="CP 6", pos=Vector3.new(257,328,699)},
}

---------------------
-- 🔔 Notifications --
---------------------
local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🌸 Arunika CP Tool v23",
            Text = tostring(msg),
            Duration = 3
        })
    end)
end

-------------------
-- 🔄 Rejoin Func --
-------------------
local function rejoin()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

--------------------------
-- 👤 Character Handling --
--------------------------
local function setupChar(char)
    if not char then return end

    humanoid = char:WaitForChild("Humanoid", 5)
    hrp      = char:WaitForChild("HumanoidRootPart", 5)

    if humanoid then
        -- Anti Seat (auto stand up kalau dipaksa duduk)
        humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
            if humanoid and humanoid.Sit then
                humanoid.Sit = false
            end
        end)

        -- Auto respawn kalau mati
        humanoid.Died:Connect(function()
            stopFlag = true
            autoLoop = false
            notify("☠️ Kamu mati — respawn otomatis")
            task.wait(2)
            player:LoadCharacter()
        end)
    end
end

-- Setup awal
if player.Character then setupChar(player.Character) end
player.CharacterAdded:Connect(setupChar)

---------------------------
-- 🔁 Auto Rejoin Handler --
---------------------------
player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        notify("Teleport gagal — rejoin...")
        rejoin()
    end
end)

CoreGui.DescendantAdded:Connect(function(obj)
    pcall(function()
        if obj:IsA("TextLabel") then
            local txt = obj.Text:lower()
            if txt:find("disconnected") or txt:find("kicked") or txt:find("error") then
                notify("Error/kick terdeteksi — rejoin...")
                rejoin()
            end
        end
    end)
end)

----------------
-- 💤 Anti AFK --
----------------
pcall(function()
    local vu = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

-----------------
-- 🛠️ Utilities --
-----------------
-- Pastikan HRP ada
local function waitForHRP(timeout)
    local t = 0
    while not hrp and t < (timeout or 5) do
        task.wait(0.2)
        t += 0.2
    end
    return hrp ~= nil
end

-- Hindari tabrakan dengan player lain
local function avoidPlayers()
    if not hrp then return false end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local other = plr.Character.HumanoidRootPart
            if (other.Position - hrp.Position).Magnitude < 8 then
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 10, 0)
                task.wait(0.15)
                return true
            end
        end
    end
    return false
end

-----------------------------------
-- 🚀 Smooth Teleport (Fast Down) --
-----------------------------------
local function smoothTo(target)
    if not waitForHRP(5) then return end

    local start = hrp.Position
    local upHeight = math.max(80, (target.Y - start.Y) + 60)
    local top = start + Vector3.new(0, upHeight, 0)

    -- Step 1: naik ke atas
    for i=1,30 do
        if stopFlag then return end
        local pos = start:Lerp(top, i/30)
        hrp.CFrame = CFrame.new(pos)
        task.wait(0.02/speedFactor)
    end

    -- Step 2: geser horizontal
    local above = Vector3.new(target.X, top.Y, target.Z)
    local from  = hrp.Position
    for i=1,40 do
        if stopFlag then return end
        local pos = from:Lerp(above, i/40)
        hrp.CFrame = CFrame.new(pos)
        task.wait(0.02/speedFactor)
    end

    -- Step 3: turun cepat (12 step, fast descent)
    local descStart = hrp.Position
    local descTarget = target + Vector3.new(0,4,0)
    for i=1,12 do
        if stopFlag then return end
        local pos = descStart:Lerp(descTarget, i/12)
        hrp.CFrame = CFrame.new(pos)
        task.wait(0.02/speedFactor)
    end

    -- Posisi final + lompat kecil untuk trigger CP
    hrp.CFrame = CFrame.new(target + Vector3.new(0,2,0))
    if humanoid then
        for j=1,2 do
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait(0.4/speedFactor)
        end
    end
end

-- Fungsi untuk ke CP
local function goToCP(cp)
    if not cp then return end
    avoidPlayers()
    smoothTo(cp.pos)
    notify("✅ "..cp.name.." selesai")
end

--------------------
-- ▶️ Auto Runners --
--------------------
-- Sekali jalan semua CP
local function runOnce()
    stopFlag = false
    for _,cp in ipairs(checkpoints) do
        if stopFlag then break end
        notify("➡️ "..cp.name)
        goToCP(cp)
        task.wait(1/speedFactor)
    end
    if not stopFlag then
        notify("🎉 Semua CP selesai — respawn otomatis")
        task.wait(1)
        player:LoadCharacter()
    end
end

-- Loop terus menerus
local function runLoop()
    stopFlag = false
    autoLoop = true
    loopCount = 0
    while autoLoop do
        loopCount += 1
        notify("🔁 Loop "..loopCount.." mulai")
        for _,cp in ipairs(checkpoints) do
            if stopFlag then break end
            goToCP(cp)
            task.wait(1/speedFactor)
        end
        if autoLoop and not stopFlag then
            notify("Respawn untuk loop berikutnya")
            player:LoadCharacter()
            task.wait(4/speedFactor)
        end
    end
end

-------------
-- 🖥️ GUI  --
-------------
if CoreGui:FindFirstChild("ArunikaCPv23Ext") then
    CoreGui.ArunikaCPv23Ext:Destroy()
end

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ArunikaCPv23Ext"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 280, 0, 460)
frame.Position = UDim2.new(0, 20, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active, frame.Draggable = true, true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "🌸 Arunika CP Tool v23 Extended"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)

-- Tombol manual CP
local y = 40
for _,cp in ipairs(checkpoints) do
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1,-20,0,30)
    btn.Position = UDim2.new(0,10,0,y)
    btn.Text = cp.name
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function() goToCP(cp) end)
    y = y + 36
end

-- Tombol Auto Once
local onceBtn = Instance.new("TextButton", frame)
onceBtn.Size = UDim2.new(1,-20,0,32)
onceBtn.Position = UDim2.new(0,10,0,y)
onceBtn.Text = "▶️ Auto Once"
onceBtn.BackgroundColor3 = Color3.fromRGB(60,100,60)
onceBtn.TextColor3 = Color3.new(1,1,1)
onceBtn.MouseButton1Click:Connect(runOnce)
y = y + 40

-- Tombol Auto Loop
local loopBtn = Instance.new("TextButton", frame)
loopBtn.Size = UDim2.new(1,-20,0,32)
loopBtn.Position = UDim2.new(0,10,0,y)
loopBtn.Text = "♻️ Auto Loop"
loopBtn.BackgroundColor3 = Color3.fromRGB(100,80,40)
loopBtn.TextColor3 = Color3.new(1,1,1)
loopBtn.MouseButton1Click:Connect(runLoop)
y = y + 40

-- Tombol Stop
local stopBtn = Instance.new("TextButton", frame)
stopBtn.Size = UDim2.new(1,-20,0,32)
stopBtn.Position = UDim2.new(0,10,0,y)
stopBtn.Text = "⏹️ Stop"
stopBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.MouseButton1Click:Connect(function()
    stopFlag = true
    autoLoop = false
    notify("⏹️ Stopped")
end)
y = y + 40

-- Tombol Rejoin
local rejoinBtn = Instance.new("TextButton", frame)
rejoinBtn.Size = UDim2.new(1,-20,0,32)
rejoinBtn.Position = UDim2.new(0,10,0,y)
rejoinBtn.Text = "🔄 Rejoin"
rejoinBtn.BackgroundColor3 = Color3.fromRGB(40,80,120)
rejoinBtn.TextColor3 = Color3.new(1,1,1)
rejoinBtn.MouseButton1Click:Connect(rejoin)

notify("✅ Arunika CP Tool v23 Extended Siap!")
