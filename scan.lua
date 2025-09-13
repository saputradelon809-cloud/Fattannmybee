loadstring([[
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- GUI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "DeletePartGUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 360, 0, 250)
Frame.Position = UDim2.new(0.5, -180, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0.15,0)
Title.BackgroundTransparency = 1
Title.Text = "Delete Part GUI"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextScaled = true

local ScanButton = Instance.new("TextButton", Frame)
ScanButton.Size = UDim2.new(0.9,0,0.15,0)
ScanButton.Position = UDim2.new(0.05,0,0.2,0)
ScanButton.BackgroundColor3 = Color3.fromRGB(0,0,200)
ScanButton.Text = "Scan Parts"
ScanButton.TextScaled = true

local YesButton = Instance.new("TextButton", Frame)
YesButton.Size = UDim2.new(0.4,0,0.15,0)
YesButton.Position = UDim2.new(0.05,0,0.5,0)
YesButton.BackgroundColor3 = Color3.fromRGB(0,200,0)
YesButton.Text = "Yes"
YesButton.TextScaled = true

local NoButton = Instance.new("TextButton", Frame)
NoButton.Size = UDim2.new(0.4,0,0.15,0)
NoButton.Position = UDim2.new(0.55,0,0.5,0)
NoButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
NoButton.Text = "No"
NoButton.TextScaled = true

-- Adornments
local container = Instance.new("Folder", workspace)
container.Name = "ScanAdornments"

local adornments = {}
local selectedParts = {}

local function showNotification(text, duration)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0.4,0,0.06,0)
    notif.Position = UDim2.new(0.3,0,0.05,0)
    notif.BackgroundColor3 = Color3.fromRGB(50,50,50)
    notif.BackgroundTransparency = 0.2
    notif.TextColor3 = Color3.fromRGB(255,255,255)
    notif.TextScaled = true
    notif.Text = text
    notif.Parent = ScreenGui
    game:GetService("Debris"):AddItem(notif, duration or 2)
end

local function createAdornment(part, color)
    local adorn = Instance.new("BoxHandleAdornment")
    adorn.Adornee = part
    adorn.Size = part.Size + Vector3.new(0.2,0.2,0.2)
    adorn.Color3 = color
    adorn.Transparency = 0.3
    adorn.AlwaysOnTop = true
    adorn.Parent = container
    return adorn
end

-- SCAN LOGIC
ScanButton.MouseButton1Click:Connect(function()
    container:ClearAllChildren()
    adornments = {}
    selectedParts = {}
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent ~= player.Character then
            adornments[part] = createAdornment(part, Color3.fromRGB(255,0,0))
        end
    end
    showNotification("Scan complete!", 2)
end)

-- MULTI-SELECT LOGIC
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        local ray = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
        local result = workspace:Raycast(ray.Origin, ray.Direction*1000, RaycastParams.new())
        if result and result.Instance:IsA("BasePart") and result.Instance.Parent ~= player.Character then
            local part = result.Instance
            if not selectedParts[part] then
                selectedParts[part] = true
                if adornments[part] then adornments[part].Color3 = Color3.fromRGB(0,255,0) end
            else
                selectedParts[part] = nil
                if adornments[part] then adornments[part].Color3 = Color3.fromRGB(255,0,0) end
            end
        end
    end
end)

-- DELETE LOGIC
YesButton.MouseButton1Click:Connect(function()
    local count = 0
    for part,_ in pairs(selectedParts) do
        if part then
            part:Destroy()
            count = count + 1
        end
    end
    container:ClearAllChildren()
    selectedParts = {}
    adornments = {}
    showNotification(count.." parts deleted!", 2)
end)

-- CANCEL LOGIC
NoButton.MouseButton1Click:Connect(function()
    for part,_ in pairs(selectedParts) do
        if adornments[part] then adornments[part].Color3 = Color3.fromRGB(255,0,0) end
    end
    selectedParts = {}
    showNotification("Cancelled!", 2)
end)
]])()
