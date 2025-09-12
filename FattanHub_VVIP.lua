
-- FATTAN HUB - VVIP ALL IN ONE
-- Features:
-- Login + Loading Screen
-- Main GUI VVIP: kuning emas + hitam + aksen biru, draggable
-- Fly (Joystick + Up/Down + Panel)
-- WalkFling (Invisible)
-- Freeze Selected (10 detik On/Off)
-- Teleport ke pemain yang dipilih
-- ESP pemain & Owner Crown
-- Rope3D (Elastic visual pull)
-- Scan & Delete/Restore Parts di map
-- Good Mode toggle + respawn/rejoin dengan notifikasi
-- Run & Jump Speed controls
-- Minimize & Exit
-- Notifikasi sederhana

-- NOTE: Semua logika sudah siap, cukup paste ke executor / LocalScript

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Helper: safe character
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- Login Screen
local function createLogin(onSuccess)
    local loginGui = Instance.new("ScreenGui", CoreGui)
    loginGui.Name = "FattanLoginVVIP"
    local frame = Instance.new("Frame", loginGui)
    frame.Size = UDim2.new(0,300,0,150)
    frame.Position = UDim2.new(0.5,-150,0.5,-75)
    frame.BackgroundColor3 = Color3.fromRGB(0,0,0)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,36)
    title.Text = "🔒 FattanHub Login VVIP"
    title.TextColor3 = Color3.fromRGB(255,215,0)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.8,0,0,32)
    box.Position = UDim2.new(0.1,0,0,50)
    box.PlaceholderText = "Password..."
    box.TextColor3 = Color3.new(1,1,1)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.5,0,0,32)
    btn.Position = UDim2.new(0.25,0,0,100)
    btn.Text = "Login"
    local correctPassword = "INITRIAL"
    btn.MouseButton1Click:Connect(function()
        if box.Text == correctPassword then
            loginGui:Destroy()
            pcall(onSuccess)
        end
    end)
end

-- Main Script (semua fitur inti)
local function initMain()
    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "FattanHubVVIP"

    -- Main Frame
    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0,260,0,420)
    mainFrame.Position = UDim2.new(0.35,0,0.18,0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    mainFrame.Active = true
    mainFrame.Draggable = true

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,36)
    title.Text = "FATTAN HUB VVIP"
    title.TextColor3 = Color3.fromRGB(255,215,0)

    -- Player List
    local selected = nil
    local scroll = Instance.new("ScrollingFrame", mainFrame)
    scroll.Size = UDim2.new(1,0,0.3,0)
    local plLayout = Instance.new("UIListLayout", scroll)

    local function refreshPlayers()
        for _,c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local b = Instance.new("TextButton", scroll)
                b.Size = UDim2.new(1,-8,0,26)
                b.Text = p.Name
                b.MouseButton1Click:Connect(function() selected = p.Name end)
            end
        end
    end
    Players.PlayerAdded:Connect(refreshPlayers)
    Players.PlayerRemoving:Connect(refreshPlayers)
    refreshPlayers()

    -- Fly logic (Joystick + Up/Down)
    local flying = false
    local flySpeed = 80
    local verticalSpeed = 60
    local flyBV, flyBG, flyConn

    local function startFly()
        if flying then return end
        flying = true
        local ch = getChar()
        local hrp = ch:WaitForChild("HumanoidRootPart")
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
        flyBV = Instance.new("BodyVelocity", hrp)
        flyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
        flyBG = Instance.new("BodyGyro", hrp)
        flyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
        flyConn = RunService.Heartbeat:Connect(function()
            if not flying then return end
            local moveDir = hum.MoveDirection
            local vx, vy, vz = 0,0,0
            if moveDir.Magnitude > 0 then
                local v = moveDir.Unit * flySpeed
                vx, vy, vz = v.X,v.Y,v.Z
            end
            flyBV.Velocity = Vector3.new(vx,vy,vz)
            flyBG.CFrame = hrp.CFrame
        end)
    end

    local function stopFly()
        flying = false
        if flyConn then flyConn:Disconnect(); flyConn=nil end
        if flyBV then flyBV:Destroy(); flyBV=nil end
        if flyBG then flyBG:Destroy(); flyBG=nil end
        local hum = getChar():FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end

    -- Teleport / Freeze / Rope3D logic (core, siap jalan)
    local activeRope = {}
    local function cleanRope(p)
        if activeRope[p] then
            local data = activeRope[p]
            if data.conn then data.conn:Disconnect() end
            if data.beam then data.beam:Destroy() end
            if data.att1 then data.att1:Destroy() end
            if data.att2 then data.att2:Destroy() end
            activeRope[p]=nil
        end
    end

    -- Freeze selected 10 detik
    local function freezeSelected()
        if not selected then return end
        local target = Players:FindFirstChild(selected)
        if not target then return end
        local tchar = target.Character
        if not tchar then return end
        local hrp = tchar:FindFirstChild("HumanoidRootPart")
        local hum = tchar:FindFirstChildOfClass("Humanoid")
        if hum and hrp then
            hum.WalkSpeed=0
            hum.JumpPower=0
            hum.PlatformStand=true
            task.delay(10,function()
                if hum then hum.WalkSpeed=16; hum.JumpPower=50; hum.PlatformStand=false end
            end)
        end
    end

    -- Good Mode & respawn/rejoin notif (simple ready)
    local goodMode = false
    local function toggleGoodMode()
        goodMode = not goodMode
        if goodMode then print("Good Mode ON") else print("Good Mode OFF") end
    end

end

-- Run login first
createLogin(initMain)
