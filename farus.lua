-- // FATTAN HUB SCRIPT
-- Loading Screen
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "FattanLoading"
LoadingGui.Parent = CoreGui

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1,0,1,0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0,40,100)
LoadingFrame.Parent = LoadingGui

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1,0,1,0)
LoadingText.Text = "FATTANHUBSCRIPT"
LoadingText.TextColor3 = Color3.fromRGB(255,255,255)
LoadingText.Font = Enum.Font.SourceSansBold
LoadingText.TextSize = 40
LoadingText.BackgroundTransparency = 1
LoadingText.Parent = LoadingFrame

task.wait(2)

TweenService:Create(LoadingFrame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
TweenService:Create(LoadingText, TweenInfo.new(1), {TextTransparency = 1}):Play()
task.wait(1)
LoadingGui:Destroy()

-- // MAIN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FattanHub"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0,40,100) -- biru tua
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(0,120,200) -- biru muda
Title.Text = "FATTAN HUB SCRIPT"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- fungsi buat tombol
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(0,80,160)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Parent = MainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- // FITUR FITUR
-- Fly
local flying = false
local flySpeed = 50
createButton("Fly (Toggle)", function()
    local plr = Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    flying = not flying
    if flying then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp

        RunService.RenderStepped:Connect(function()
            if flying and bv.Parent then
                local camCF = workspace.CurrentCamera.CFrame
                local dir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    dir = dir + camCF.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    dir = dir - camCF.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    dir = dir - camCF.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    dir = dir + camCF.RightVector
                end
                bv.Velocity = dir * flySpeed
            end
        end)
    else
        if hrp:FindFirstChild("BodyVelocity") then
            hrp.BodyVelocity:Destroy()
        end
    end
end)

-- ESP
local espEnabled = false
createButton("ESP Player (Toggle)", function()
    espEnabled = not espEnabled
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if espEnabled then
                local highlight = Instance.new("Highlight")
                highlight.Name = "FattanESP"
                highlight.FillColor = Color3.fromRGB(0,255,255)
                highlight.OutlineColor = Color3.fromRGB(0,0,0)
                highlight.Parent = p.Character
            else
                if p.Character:FindFirstChild("FattanESP") then
                    p.Character.FattanESP:Destroy()
                end
            end
        end
    end
end)

-- Teleport
createButton("Teleport ke Player", function()
    local plr = Players.LocalPlayer
    local targetName = "Player1" -- ganti manual nama target
    local target = Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        plr.Character:WaitForChild("HumanoidRootPart").CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
    end
end)

-- WalkSpeed
createButton("WalkSpeed 50", function()
    local hum = Players.LocalPlayer.Character:WaitForChild("Humanoid")
    hum.WalkSpeed = 50
end)

-- Freeze Visual
createButton("Freeze Player Visual", function()
    local targetName = "Player1" -- ganti manual
    local target = Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local ice = Instance.new("Part")
        ice.Size = Vector3.new(6,8,6)
        ice.Anchored = true
        ice.CanCollide = false
        ice.Color = Color3.fromRGB(150,220,255)
        ice.Material = Enum.Material.Ice
        ice.CFrame = target.Character.HumanoidRootPart.CFrame
        ice.Parent = workspace
    end
end)

-- Delete Part
createButton("Delete Parts", function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v:Destroy()
        end
    end
end)

-- Admin Logo
createButton("Admin Logo", function()
    local char = Players.LocalPlayer.Character
    if char and not char:FindFirstChild("AdminBillboard") then
        local billboard = Instance.new("BillboardGui", char.Head)
        billboard.Name = "AdminBillboard"
        billboard.Size = UDim2.new(0,100,0,50)
        billboard.StudsOffset = Vector3.new(0,3,0)
        billboard.AlwaysOnTop = true

        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1,0,1,0)
        label.Text = "👑 ADMIN 👑"
        label.TextColor3 = Color3.fromRGB(255,215,0)
        label.BackgroundTransparency = 1
        label.TextScaled = true
    end
end)

-- Rope / Tali Tarik Player
createButton("Tarik Player", function()
    local plr = Players.LocalPlayer
    local targetName = "Player1" -- ganti manual
    local target = Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local attachment1 = Instance.new("Attachment", plr.Character.HumanoidRootPart)
        local attachment2 = Instance.new("Attachment", target.Character.HumanoidRootPart)
        local rope = Instance.new("RopeConstraint", plr.Character.HumanoidRootPart)
        rope.Attachment0 = attachment1
        rope.Attachment1 = attachment2
        rope.Length = 10
    end
end)

-- Contact info
local Contact = Instance.new("TextLabel")
Contact.Parent = MainFrame
Contact.Size = UDim2.new(1,0,0,30)
Contact.BackgroundTransparency = 1
Contact.Text = "Contact: 085708378509"
Contact.TextColor3 = Color3.fromRGB(200,200,200)
Contact.Font = Enum.Font.SourceSans
Contact.TextSize = 14
