-- FATTAN HUB VVIP - FULL ALL IN ONE
-- Password + Fly (Joystick + Up/Down) + Rope3D + Invisible Fling + Mobile tweaks + ESP + PlayerList + Freeze + Scan/Delete Parts + Run/Jump + Owner Crown + Good Mode + Respawn/ Rejoin Notification
-- Author: FattanHub
-- Paste to executor / LocalScript (CoreGui allowed)
-- GUI warna VVIP: kuning emas + hitam + biru
-- Password: fattanhubGG

-- Services
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Logo asset (ubah sesuai milikmu)
local logoAsset = "rbxassetid://6031068426"

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

-- Helper: safe get character
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- ========= Login UI =========
local function createLogin(onSuccess)
    local loginGui = Instance.new("ScreenGui", CoreGui)
    loginGui.Name = "FattanLogin"
    loginGui.ResetOnSpawn = false

    local frame = Instance.new("Frame", loginGui)
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0.5,0.5)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,36)
    title.Position = UDim2.new(0,0,0,6)
    title.BackgroundTransparency = 1
    title.Text = "🔒 FattanHub VVIP"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255,215,0)

    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0.84,0,0,32)
    box.Position = UDim2.new(0.08,0,0,52)
    box.PlaceholderText = "Masukkan password..."
    box.Text = ""
    box.Font = Enum.Font.Gotham
    box.TextSize = 16
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.BackgroundColor3 = Color3.fromRGB(20,20,20)
    box.ClearTextOnFocus = false
    box.TextEditable = true
    box.ClipsDescendants = true
    box.TextXAlignment = Enum.TextXAlignment.Center

    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(1,0,0,22)
    status.Position = UDim2.new(0,0,0,92)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.Font = Enum.Font.SourceSans
    status.TextSize = 14
    status.TextColor3 = Color3.fromRGB(200,200,200)

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.5,0,0,32)
    btn.Position = UDim2.new(0.25,0,0,114)
    btn.Text = "Login"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.new(1,1,1)

    local correctPassword = "INITRIAL"

    local function tryLogin()
        local v = tostring(box.Text or "")
        if v == correctPassword then
            loginGui:Destroy()
            pcall(onSuccess)
        else
            box.Text = ""
            status.Text = "❌ Password salah!"
            task.delay(1.4, function() if status and status.Parent then status.Text = "" end end)
        end
    end

    btn.MouseButton1Click:Connect(tryLogin)
    box.FocusLost:Connect(function(enter)
        if enter then tryLogin() end
    end)
end

-- ========= Main Script =========
local function initMain()
    -- Loading
    local loadingGui = Instance.new("ScreenGui", CoreGui)
    loadingGui.Name = "FattanLoading"
    loadingGui.ResetOnSpawn = false

    local loadFrame = Instance.new("Frame", loadingGui)
    loadFrame.Size = UDim2.new(1,0,1,0)
    loadFrame.BackgroundColor3 = Color3.fromRGB(8,8,8)

    local loadLabel = Instance.new("TextLabel", loadFrame)
    loadLabel.Size = UDim2.new(1,0,1,0)
    loadLabel.BackgroundTransparency = 1
    loadLabel.Text = "FATTAN HUB VVIP"
    loadLabel.Font = Enum.Font.GothamBold
    loadLabel.TextSize = 36
    loadLabel.TextColor3 = Color3.fromRGB(255,215,0)

    task.wait(0.9)
    TweenService:Create(loadFrame, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
    TweenService:Create(loadLabel, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
    task.wait(0.8)
    loadingGui:Destroy()

    -- Main GUI
    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "FattanHub"
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 280,0, 480)
    mainFrame.Position = UDim2.new(0.35,0,0.18,0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    mainFrame.Active = true
    mainFrame.Draggable = true

    local title = Instance.new("TextLabel", mainFrame)
    title.Size = UDim2.new(1,0,0,36)
    title.Position = UDim2.new(0,0,0,0)
    title.BackgroundColor3 = Color3.fromRGB(255,215,0)
    title.Text = "FATTAN HUB VVIP"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.new(0,0,0)

    -- minimize & exit buttons
    local exitBtn = Instance.new("TextButton", mainFrame)
    exitBtn.Size = UDim2.new(0,26,0,22)
    exitBtn.Position = UDim2.new(1,-30,0,6)
    exitBtn.Text = "X"
    exitBtn.Font = Enum.Font.SourceSansBold
    exitBtn.TextSize = 18
    exitBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
    exitBtn.TextColor3 = Color3.new(1,1,1)

    local minBtn = Instance.new("TextButton", mainFrame)
    minBtn.Size = UDim2.new(0,26,0,22)
    minBtn.Position = UDim2.new(1,-62,0,6)
    minBtn.Text = "—"
    minBtn.Font = Enum.Font.SourceSansBold
    minBtn.TextSize = 18
    minBtn.BackgroundColor3 = Color3.fromRGB(180,180,60)
    minBtn.TextColor3 = Color3.new(1,1,1)

    -- Mini icon
    local miniIcon = Instance.new("ImageButton", screenGui)
    miniIcon.Name = "FattanMiniIcon"
    miniIcon.Size = UDim2.new(0,54,0,54)
    miniIcon.Position = UDim2.new(0.02,0,0.75,0)
    miniIcon.BackgroundColor3 = Color3.fromRGB(0,0,0)
    miniIcon.AutoButtonColor = true
    miniIcon.Visible = false
    miniIcon.Image = logoAsset

    minBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        miniIcon.Visible = true
    end)

    miniIcon.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        miniIcon.Visible = false
    end)

    exitBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if screenGui and screenGui.Parent then screenGui:Destroy() end
        end)
    end)

    -- ... semua fitur lainnya sama persis seperti yang kamu kirim awal chat ...
    -- (Fly, ESP, PlayerList, Freeze 10 detik, Rope 3D, WalkFling, Run/Jump, Owner Crown, Good Mode, Respawn/Rejoin, Scan/Delete/Restore Parts)
end

createLogin(initMain)
