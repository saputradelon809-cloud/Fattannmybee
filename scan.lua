loadstring([[
-- LocalScript all-in-one Delete Part (scan + select + delete)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local workspace = game:GetService("Workspace")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeletePartGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 100)
Frame.Position = UDim2.new(0.5, -125, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
Frame.Parent = ScreenGui
Frame.Active = true
Frame.Draggable = true

local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1,0,0.5,0)
TextLabel.Position = UDim2.new(0,0,0,0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "Delete this part?"
TextLabel.TextColor3 = Color3.fromRGB(255,255,255)
TextLabel.TextScaled = true
TextLabel.Parent = Frame

local YesButton = Instance.new("TextButton")
YesButton.Size = UDim2.new(0.45,0,0.4,0)
YesButton.Position = UDim2.new(0.05,0,0.55,0)
YesButton.BackgroundColor3 = Color3.fromRGB(0,200,0)
YesButton.Text = "Yes"
YesButton.TextScaled = true
YesButton.Parent = Frame
YesButton.Active = true
YesButton.Draggable = true

local NoButton = Instance.new("TextButton")
NoButton.Size = UDim2.new(0.45,0,0.4,0)
NoButton.Position = UDim2.new(0.5,0,0.55,0)
NoButton.BackgroundColor3 = Color3.fromRGB(200,0,0)
NoButton.Text = "No"
NoButton.TextScaled = true
NoButton.Parent = Frame
NoButton.Active = true
NoButton.Draggable = true

Frame.Visible = false

-- Table untuk highlight semua part
local highlights = {}

-- Fungsi bikin highlight
local function createHighlight(part, color)
    local h = Instance.new("Highlight")
    h.Adornee = part
    h.FillColor = color
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0.8
    h.Parent = workspace
    h.Enabled = true
    return h
end

-- Scan semua part di workspace → merah
for _, part in pairs(workspace:GetDescendants()) do
    if part:IsA("BasePart") then
        highlights[part] = createHighlight(part, Color3.fromRGB(255,0,0))
    end
end

-- Part selection
local selectedPart = nil

local function getPartFromTouch(touchPos)
    local ray = camera:ScreenPointToRay(touchPos.X, touchPos.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
    if result and result.Instance:IsA("BasePart") then
        return result.Instance
    end
    return nil
end

-- Input detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        local part = getPartFromTouch(input.Position)
        if part then
            -- Kembalikan warna part sebelumnya menjadi merah
            if selectedPart and highlights[selectedPart] then
                highlights[selectedPart].FillColor = Color3.fromRGB(255,0,0)
            end
            selectedPart = part
            -- Buat highlight hijau jika dipilih
            if highlights[part] then
                highlights[part].FillColor = Color3.fromRGB(0,255,0)
            else
                highlights[part] = createHighlight(part, Color3.fromRGB(0,255,0))
            end
            Frame.Visible = true
        end
    end
end)

-- Tombol Yes
YesButton.MouseButton1Click:Connect(function()
    if selectedPart then
        selectedPart:Destroy() -- client-side only
        if highlights[selectedPart] then
            highlights[selectedPart]:Destroy()
            highlights[selectedPart] = nil
        end
        selectedPart = nil
        Frame.Visible = false
    end
end)

-- Tombol No
NoButton.MouseButton1Click:Connect(function()
    if selectedPart and highlights[selectedPart] then
        highlights[selectedPart].FillColor = Color3.fromRGB(255,0,0) -- kembali merah
    end
    selectedPart = nil
    Frame.Visible = false
end)
]])()
