-- FattanHub Revised GUI
-- Semua fitur lama dimasukkan ke GUI baru dengan Sidebar Tab
-- Dibuat ulang by ChatGPT

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Buat ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FattanHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "FattanHub Revised"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 50, 1, 0)
CloseButton.Position = UDim2.new(1, -50, 0, 0)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -30)
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Content frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -120, 1, -30)
ContentFrame.Position = UDim2.new(0, 120, 0, 30)
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- Buat fungsi tab system
local Tabs = {}
local function createTab(name)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = name
    button.Font = Enum.Font.SourceSans
    button.TextSize = 16
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = Sidebar

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = ContentFrame

    button.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Frame.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        end
        frame.Visible = true
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)

    local tabData = {Button = button, Frame = frame}
    table.insert(Tabs, tabData)
    if #Tabs == 1 then
        frame.Visible = true
        button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
    return frame
end

-- Tab Movement
local MovementTab = createTab("Movement")

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Text = "WalkSpeed:"
SpeedLabel.Size = UDim2.new(0, 200, 0, 30)
SpeedLabel.Position = UDim2.new(0, 10, 0, 10)
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Parent = MovementTab

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0, 100, 0, 30)
SpeedBox.Position = UDim2.new(0, 10, 0, 40)
SpeedBox.Text = tostring(Humanoid.WalkSpeed)
SpeedBox.Parent = MovementTab

SpeedBox.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(SpeedBox.Text)
        if val then
            Humanoid.WalkSpeed = val
        end
    end
end)

local JumpLabel = SpeedLabel:Clone()
JumpLabel.Text = "JumpPower:"
JumpLabel.Position = UDim2.new(0, 10, 0, 80)
JumpLabel.Parent = MovementTab

local JumpBox = SpeedBox:Clone()
JumpBox.Position = UDim2.new(0, 10, 0, 110)
JumpBox.Text = tostring(Humanoid.JumpPower)
JumpBox.Parent = MovementTab

JumpBox.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(JumpBox.Text)
        if val then
            Humanoid.JumpPower = val
        end
    end
end)

-- TODO: Add Fly toggle, ESP tab, Teleport tab, Tools tab (scan, delete, freeze, rope, fling)

