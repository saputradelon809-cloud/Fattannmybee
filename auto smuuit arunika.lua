-- GUI Simpan Koordinat Mobile-Friendly Final
local player = game.Players.LocalPlayer
local hrp = player.Character:WaitForChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")

local savedPositions = {}
local cpNames = {}

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

-- Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0, 20, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui

-- Header untuk drag
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
header.Parent = frame

local headerLabel = Instance.new("TextLabel")
headerLabel.Size = UDim2.new(1, 0, 1, 0)
headerLabel.BackgroundTransparency = 1
headerLabel.Text = "Coordinate Saver"
headerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
headerLabel.TextScaled = true
headerLabel.Parent = header

-- Tombol Save Posisi
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, -20, 0, 40)
saveBtn.Position = UDim2.new(0, 10, 0, 50)
saveBtn.Text = "Save Posisi"
saveBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Parent = frame

-- Tombol Cetak Kode
local printBtn = Instance.new("TextButton")
printBtn.Size = UDim2.new(1, -20, 0, 40)
printBtn.Position = UDim2.new(0, 10, 0, 100)
printBtn.Text = "Cetak Kode"
printBtn.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
printBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
printBtn.Parent = frame

-- ScrollFrame untuk koordinat
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 0, 200)
scrollFrame.Position = UDim2.new(0, 10, 0, 150)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
scrollFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 5)

-- Fungsi update scrollFrame fix
local function updateScrollFrame()
    scrollFrame:ClearAllChildren()
    local labelHeight = 25
    local padding = 5
    for i, pos in ipairs(savedPositions) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, labelHeight)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 0)
        local cpName = cpNames[i] or ("CP"..i)
        label.Text = cpName .. ": Vector3.new(" .. pos.X .. ", " .. pos.Y .. ", " .. pos.Z .. ")"
        label.TextScaled = true
        label.Parent = scrollFrame
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #savedPositions * (25 + 5))
end

-- Fungsi Save Posisi
saveBtn.MouseButton1Click:Connect(function()
    local pos = hrp.Position
    table.insert(savedPositions, pos)
    -- Nama CP otomatis
    local cpName = ""
    if #savedPositions == 1 then
        cpName = "CP1"
    elseif #savedPositions == 2 then
        cpName = "CP2"
    elseif #savedPositions == 3 then
        cpName = "CP3"
    else
        cpName = "Summit"
    end
    table.insert(cpNames, cpName)
    updateScrollFrame()
end)

-- Fungsi Cetak Kode
printBtn.MouseButton1Click:Connect(function()
    print("Kode koordinat siap pakai:")
    for i, pos in ipairs(savedPositions) do
        local cpName = cpNames[i] or ("CP"..i)
        print(cpName .. " = Vector3.new(" .. pos.X .. ", " .. pos.Y .. ", " .. pos.Z .. ")")
    end
end)

-- Drag header mobile-friendly
local dragging = false
local dragStartPos
local frameStartPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStartPos = input.Position
        frameStartPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        UserInputService.InputChanged:Connect(function(move)
            if dragging and move.UserInputType == Enum.UserInputType.Touch then
                local delta = move.Position - dragStartPos
                frame.Position = UDim2.new(frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X, frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y)
            end
        end)
    end
end)

