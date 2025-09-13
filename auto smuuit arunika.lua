local player = game.Players.LocalPlayer
local hrp = player.Character:WaitForChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")

local savedPositions = {}
local cpNames = {}

-- ScreenGui di PlayerGui (penting agar tombol bekerja di mobile)
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 400)
frame.Position = UDim2.new(0, 20, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui

-- Header untuk drag
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,40)
header.BackgroundColor3 = Color3.fromRGB(80,80,80)
header.Parent = frame

local headerLabel = Instance.new("TextLabel")
headerLabel.Size = UDim2.new(1,0,1,0)
headerLabel.BackgroundTransparency = 1
headerLabel.Text = "Coordinate Saver"
headerLabel.TextColor3 = Color3.fromRGB(255,255,255)
headerLabel.TextScaled = true
headerLabel.Parent = header

-- Tombol Save Posisi
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, -20, 0, 40)
saveBtn.Position = UDim2.new(0,10,0,50)
saveBtn.Text = "Save Posisi"
saveBtn.BackgroundColor3 = Color3.fromRGB(60,150,60)
saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
saveBtn.Parent = frame

-- Tombol Cetak Kode
local printBtn = Instance.new("TextButton")
printBtn.Size = UDim2.new(1, -20, 0, 40)
printBtn.Position = UDim2.new(0,10,0,100)
printBtn.Text = "Cetak Kode"
printBtn.BackgroundColor3 = Color3.fromRGB(150,60,60)
printBtn.TextColor3 = Color3.fromRGB(255,255,255)
printBtn.Parent = frame

-- Tombol Auto Teleport
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(1, -20, 0, 40)
tpBtn.Position = UDim2.new(0,10,0,150)
tpBtn.Text = "Auto Teleport"
tpBtn.BackgroundColor3 = Color3.fromRGB(60,60,150)
tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
tpBtn.Parent = frame

-- ScrollFrame koordinat
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,-20,0,180)
scrollFrame.Position = UDim2.new(0,10,0,200)
scrollFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
scrollFrame.ScrollBarThickness = 6
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0,5)

-- Update ScrollFrame
local function updateScrollFrame()
    scrollFrame:ClearAllChildren()
    uiListLayout.Parent = scrollFrame
    for i, pos in ipairs(savedPositions) do
        local cpName = cpNames[i] or ("CP"..i)

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1,0,0,30)
        container.BackgroundTransparency = 1
        container.Parent = scrollFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7,0,1,0)
        label.Position = UDim2.new(0,0,0,0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255,255,0)
        label.TextScaled = true
        label.Text = cpName .. ": Vector3.new("..pos.X..","..pos.Y..","..pos.Z..")"
        label.Parent = container

        -- Tombol Delete
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.15,0,1,0)
        delBtn.Position = UDim2.new(0.7,0,0,0)
        delBtn.Text = "Del"
        delBtn.TextScaled = true
        delBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
        delBtn.TextColor3 = Color3.fromRGB(255,255,255)
        delBtn.Parent = container

        delBtn.MouseButton1Click:Connect(function()
            table.remove(savedPositions,i)
            table.remove(cpNames,i)
            updateScrollFrame()
        end)

        -- Tombol Edit (ganti nama CP)
        local editBtn = Instance.new("TextButton")
        editBtn.Size = UDim2.new(0.15,0,1,0)
        editBtn.Position = UDim2.new(0.85,0,0,0)
        editBtn.Text = "Edit"
        editBtn.TextScaled = true
        editBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
        editBtn.TextColor3 = Color3.fromRGB(255,255,255)
        editBtn.Parent = container

        editBtn.MouseButton1Click:Connect(function()
            local newName = cpName .. "_edited" -- untuk contoh, bisa diganti input GUI
            cpNames[i] = newName
            updateScrollFrame()
        end)
    end
end

-- Save Posisi
saveBtn.MouseButton1Click:Connect(function()
    local pos = hrp.Position
    table.insert(savedPositions,pos)
    local cpName = ""
    if #savedPositions == 1 then cpName="CP1"
    elseif #savedPositions == 2 then cpName="CP2"
    elseif #savedPositions == 3 then cpName="CP3"
    else cpName="Summit"
    end
    table.insert(cpNames,cpName)
    updateScrollFrame()
end)

-- Cetak Kode
printBtn.MouseButton1Click:Connect(function()
    print("Kode koordinat siap pakai:")
    for i,pos in ipairs(savedPositions) do
        local cpName = cpNames[i] or ("CP"..i)
        print(cpName.." = Vector3.new("..pos.X..","..pos.Y..","..pos.Z..")")
    end
end)

-- Auto Teleport
tpBtn.MouseButton1Click:Connect(function()
    for i,pos in ipairs(savedPositions) do
        hrp.CFrame = CFrame.new(pos)
        wait(0.5) -- delay antar teleport
    end
end)

-- Drag header mobile
local dragging=false
local dragStart
local frameStart
header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch then
        dragging=true
        dragStart=input.Position
        frameStart=frame.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then dragging=false end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.Touch then
        UserInputService.InputChanged:Connect(function(move)
            if dragging and move.UserInputType==Enum.UserInputType.Touch then
                local delta=move.Position-dragStart
                frame.Position=UDim2.new(frameStart.X.Scale,frameStart.X.Offset+delta.X,
                                         frameStart.Y.Scale,frameStart.Y.Offset+delta.Y)
            end
        end)
    end
end)
