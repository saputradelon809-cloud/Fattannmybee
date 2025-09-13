-- GUI Simpan Koordinat Multi-Posisi + Draggable + Label CP
local player = game.Players.LocalPlayer
local hrp = player.Character:WaitForChild("HumanoidRootPart")

local savedPositions = {}
local cpNames = {}

-- Buat ScreenGui
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

-- Frame utama (draggable)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true -- Bisa digeser
frame.Parent = gui

-- Tombol Save Posisi
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, -20, 0, 40)
saveBtn.Position = UDim2.new(0, 10, 0, 10)
saveBtn.Text = "Save Posisi"
saveBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Parent = frame

-- Tombol Cetak Kode
local printBtn = Instance.new("TextButton")
printBtn.Size = UDim2.new(1, -20, 0, 40)
printBtn.Position = UDim2.new(0, 10, 0, 60)
printBtn.Text = "Cetak Kode"
printBtn.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
printBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
printBtn.Parent = frame

-- ScrollFrame untuk menampilkan koordinat
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 0, 230)
scrollFrame.Position = UDim2.new(0, 10, 0, 110)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
scrollFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 5)

-- Fungsi update GUI
local function updateScrollFrame()
    scrollFrame:ClearAllChildren()
    for i, pos in ipairs(savedPositions) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 25)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 0)
        local cpName = cpNames[i] or ("CP"..i)
        label.Text = cpName .. ": Vector3.new(" .. pos.X .. ", " .. pos.Y .. ", " .. pos.Z .. ")"
        label.TextScaled = true
        label.Parent = scrollFrame
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #savedPositions * 30)
end

-- Fungsi Save Posisi
saveBtn.MouseButton1Click:Connect(function()
    local pos = hrp.Position
    table.insert(savedPositions, pos)
    -- Buat nama CP otomatis
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
