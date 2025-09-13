loadstring([[
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeletePartGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 250) -- lebih besar
Frame.Position = UDim2.new(0.5, -150, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
Frame.Parent = ScreenGui
Frame.Active = true
Frame.Draggable = true

local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1,0,0.15,0)
TextLabel.Position = UDim2.new(0,0,0,0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "Delete Part GUI"
TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
TextLabel.TextScaled = true
TextLabel.Parent = Frame

local ScanButton = Instance.new("TextButton")
ScanButton.Size = UDim2.new(0.9,0,0.15,0)
ScanButton.Position = UDim2.new(0.05,0,0.2,0)
ScanButton.BackgroundColor3 = Color3.fromRGB(0,0,200)
ScanButton.Text = "Scan Parts"
ScanButton.TextScaled = true
ScanButton.Parent = Frame

local YesButton = Instance.new("TextButton")
YesButton.Size = UDim2.new(0.4,0,0.15,0)
YesButton.Position = UDim2.new(0.05,0,0.5,0)
YesButton.BackgroundColor3 = Color3.fromRGB(0,200,0)
YesButton.Text = "Yes"
YesButton.TextScaled = true
YesButton.Parent = Frame

local NoButton = Instance.new("TextButton")
NoButton.Size = UDim2.new(0.4,0,0.15,0)
NoButton.Position = UDim2.new(0.55,0,0.5,0)
NoButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
NoButton.Text = "No"
NoButton.TextScaled = true
NoButton.Parent = Frame

-- Highlight table
local highlights = {}
local selectedParts = {}

local function createHighlight(part, color)
    local h = Instance.new("Highlight")
    h.Adornee = part
    h.FillColor = color
    h.FillTransparency = 0.2 -- lebih jelas
    h.OutlineTransparency = 0.2
    h.Parent = workspace
    h.Enabled = true
    return h
end

local function showNotification(text, duration)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0.3,0,0.05,0)
    notif.Position = UDim2.new(0.35,0,0.05,0)
    notif.BackgroundColor3 = Color3.fromRGB(50,50,50)
    notif.BackgroundTransparency = 0.2
    notif.TextColor3 = Color3.fromRGB(255,255,255)
    notif.TextScaled = true
    notif.Text = text
    notif.Parent = ScreenGui
    game:GetService("Debris"):AddItem(notif, duration or 2)
end

-- Scan Parts
ScanButton.MouseButton1Click:Connect(function()
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") then
            if not highlights[part] then
                highlights[part] = createHighlight(part, Color3.fromRGB(255,0,0))
            else
                highlights[part].FillColor = Color3.fromRGB(255,0,0)
            end
        end
    end
    selectedParts = {}
    showNotification("Scan complete!", 2)
end)

-- Pilih part dengan tap
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        local ray = camera:ScreenPointToRay(input.Position.X, input.Position.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {player.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
        if result and result.Instance:IsA("BasePart") then
            local part = result.Instance
            if not selectedParts[part] then
                selectedParts[part] = true
                if highlights[part] then
                    highlights[part].FillColor = Color3.fromRGB(0,255,0)
                else
                    highlights[part] = createHighlight(part, Color3.fromRGB(0,255,0))
                end
            else
                selectedParts[part] = nil
                if highlights[part] then
                    highlights[part].FillColor = Color3.fromRGB(255,0,0)
                end
            end
        end
    end
end)

-- Tombol Yes
YesButton.MouseButton1Click:Connect(function()
    local count = 0
    for part,_ in pairs(selectedParts) do
        if part then
            part:Destroy()
            if highlights[part] then
                highlights[part]:Destroy()
                highlights[part] = nil
            end
            count = count + 1
        end
    end
    selectedParts = {}
    showNotification(count.." parts deleted!", 2)
end)

-- Tombol No
NoButton.MouseButton1Click:Connect(function()
    for part,_ in pairs(selectedParts) do
        if part and highlights[part] then
            highlights[part].FillColor = Color3.fromRGB(255,0,0)
        end
    end
    selectedParts = {}
    showNotification("Cancelled!", 2)
end)
]])()
