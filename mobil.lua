-- // FATTAN HUB SCRIPT (Final Version)
-- Sudah termasuk Fly Fix + Freeze Player Beku

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Loading Screen
local LoadingGui = Instance.new("ScreenGui", CoreGui)
LoadingGui.Name = "FattanLoading"

local LoadingFrame = Instance.new("Frame", LoadingGui)
LoadingFrame.Size = UDim2.new(1,0,1,0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0,40,100)

local LoadingText = Instance.new("TextLabel", LoadingFrame)
LoadingText.Size = UDim2.new(1,0,1,0)
LoadingText.Text = "FATTAN HUB LOADING..."
LoadingText.TextColor3 = Color3.fromRGB(255,255,255)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 36
LoadingText.BackgroundTransparency = 1

task.wait(2)
TweenService:Create(LoadingFrame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
TweenService:Create(LoadingText, TweenInfo.new(1), {TextTransparency = 1}):Play()
task.wait(1)
LoadingGui:Destroy()

-- Main GUI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "FattanHub"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 430)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0,40,100)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1,0,0,35)
Title.BackgroundColor3 = Color3.fromRGB(0,120,200)
Title.Text = "FATTAN HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.Padding = UDim.new(0,4)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function createButton(text, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(0,80,160)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Fly Fix + Speed Control (HP Support)
local flying = false
local flySpeed = 60
local bv, bg
local upHeld, downHeld = false, false

local function startFly()
    local plr = Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    hum.PlatformStand = true

    local function setupBodyMovers()
        if not bv or not bv.Parent then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(9e9,9e9,9e9)
            bv.Velocity = Vector3.zero
        end
        if not bg or not bg.Parent then
            bg = Instance.new("BodyGyro", hrp)
            bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
            bg.P = 10000
            bg.CFrame = hrp.CFrame
        end
    end

    spawn(function()
        while flying and char and hrp.Parent do
            setupBodyMovers()
            local cam = workspace.CurrentCamera
            bg.CFrame = cam.CFrame
            local move = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move += Vector3.new(0,-1,0) end
            if upHeld then move += Vector3.new(0,1,0) end
            if downHeld then move += Vector3.new(0,-1,0) end

            bv.Velocity = move * flySpeed
            RunService.Heartbeat:Wait()
        end
    end)
end

local function stopFly()
    flying = false
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    local hum = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

createButton("Fly (Toggle)", function()
    flying = not flying
    if flying then
        startFly()
    else
        stopFly()
    end
end)

-- ESP Players + Nama lebih kecil
local espEnabled = false
createButton("ESP Player (Toggle)", function()
    espEnabled = not espEnabled
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if espEnabled then
                local highlight = Instance.new("Highlight", p.Character)
                highlight.Name = "FattanESP"
                highlight.FillColor = Color3.fromRGB(0,255,255)
                highlight.OutlineColor = Color3.fromRGB(0,0,0)

                if not p.Character:FindFirstChild("NameTagESP") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "NameTagESP"
                    billboard.Size = UDim2.new(0,120,0,30)
                    billboard.StudsOffset = Vector3.new(0,3,0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")

                    local label = Instance.new("TextLabel", billboard)
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.Text = p.Name
                    label.TextColor3 = Color3.new(1,1,1)
                    label.Font = Enum.Font.GothamBold
                    label.TextScaled = true
                    label.TextStrokeTransparency = 0
                    label.TextStrokeColor3 = Color3.new(0,0,0)
                end
            else
                if p.Character:FindFirstChild("FattanESP") then p.Character.FattanESP:Destroy() end
                if p.Character:FindFirstChild("NameTagESP") then p.Character.NameTagESP:Destroy() end
            end
        end
    end
end)

-- Player Selector + Freeze Fix
local selectedPlayer = nil

createButton("Teleport ke Player", function()
    if selectedPlayer then
        local plr = Players.LocalPlayer
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character:WaitForChild("HumanoidRootPart").CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
        end
    end
end)

createButton("Freeze Player (Selected)", function()
    if not selectedPlayer then return end
    local target = Players:FindFirstChild(selectedPlayer)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local hum = target.Character:FindFirstChildOfClass("Humanoid")

        local ice = Instance.new("Part", workspace)
        ice.Size = Vector3.new(6,8,6)
        ice.Anchored = true
        ice.CanCollide = false
        ice.Color = Color3.fromRGB(150,220,255)
        ice.Material = Enum.Material.Ice
        ice.CFrame = hrp.CFrame
        ice.Transparency = 0.2

        local weld = Instance.new("WeldConstraint", ice)
        weld.Part0 = ice
        weld.Part1 = hrp

        if hum then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            hum.PlatformStand = true
        end

        task.delay(10, function()
            if ice and ice.Parent then ice:Destroy() end
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                hum.PlatformStand = false
            end
        end)
    end
end)

createButton("Tarik Player (Selected)", function()
    if selectedPlayer then
        local plr = Players.LocalPlayer
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local attachment1 = Instance.new("Attachment", plr.Character.HumanoidRootPart)
            local attachment2 = Instance.new("Attachment", target.Character.HumanoidRootPart)
            local rope = Instance.new("RopeConstraint", plr.Character.HumanoidRootPart)
            rope.Attachment0 = attachment1
            rope.Attachment1 = attachment2
            rope.Length = 10
        end
    end
end)

-- WalkFling
createButton("WalkFling (Toggle)", function()
    local plr = Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local fling = Instance.new("BodyVelocity", hrp)
    fling.MaxForce = Vector3.new(9e9,9e9,9e9)
    fling.Velocity = Vector3.new(100,0,100)
    task.delay(3, function() fling:Destroy() end)
end)

-- Speed & Jump Adjustable
local hum = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
createButton("Run Speed 100", function()
    if hum then hum.WalkSpeed = 100 end
end)

createButton("Jump Power 100", function()
    if hum then hum.JumpPower = 100 end
end)

-- Admin Logo
local OwnerGui = Instance.new("BillboardGui")
OwnerGui.Size = UDim2.new(0,100,0,30)
OwnerGui.StudsOffset = Vector3.new(0,3,0)
OwnerGui.AlwaysOnTop = true
OwnerGui.Parent = Players.LocalPlayer.Character:WaitForChild("Head")

local crown = Instance.new("ImageLabel", OwnerGui)
crown.Size = UDim2.new(0,30,0,30)
crown.Position = UDim2.new(0,0,0,0)
crown.BackgroundTransparency = 1
crown.Image = "rbxassetid://6031068426" -- ikon mahkota

local text = Instance.new("TextLabel", OwnerGui)
text.Size = UDim2.new(1,0,1,0)
text.BackgroundTransparency = 1
text.Text = "OWNER"
text.TextColor3 = Color3.fromRGB(255,215,0)
text.Font = Enum.Font.GothamBlack
text.TextScaled = true
text.TextStrokeTransparency = 0
text.TextStrokeColor3 = Color3.new(0,0,0)

-- Contact Info
local Contact = Instance.new("TextLabel", MainFrame)
Contact.Size = UDim2.new(1,-10,0,25)
Contact.Text = "FattanHub v2.0"
Contact.TextColor3 = Color3.new(1,1,1)
Contact.BackgroundTransparency = 1
Contact.Font = Enum.Font.SourceSansBold
Contact.TextSize = 14
