local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Pastikan HumanoidRootPart siap
local hrp
if player.Character then
    hrp = player.Character:WaitForChild("HumanoidRootPart")
else
    player.CharacterAdded:Wait()
    hrp = player.Character:WaitForChild("HumanoidRootPart")
end

local savedPositions = {}
local cpNames = {}

-- ScreenGui di PlayerGui (mobile-ready)
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 500)
frame.Position = UDim2.new(0, 20, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = gui

-- Header drag
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

-- Input nama CP manual
local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(1,-20,0,30)
nameBox.Position = UDim2.new(0,10,0,50)
nameBox.PlaceholderText = "Masukkan nama CP"
nameBox.Text = ""
nameBox.TextColor3 = Color3.fromRGB(255,255,255)
nameBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
nameBox.Parent = frame

-- Tombol Save Posisi
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1,-20,0,40)
saveBtn.Position = UDim2.new(0,10,0,90)
saveBtn.Text = "Save Posisi"
saveBtn.BackgroundColor3 = Color3.fromRGB(60,150,60)
saveBtn.TextColor3 = Color3.fromRGB(255,255,255)
saveBtn.Parent = frame

-- Tombol Cetak Kode
local printBtn = Instance.new("TextButton")
printBtn.Size = UDim2.new(1,-20,0,40)
printBtn.Position = UDim2.new(0,10,0,140)
printBtn.Text = "Cetak Kode"
printBtn.BackgroundColor3 = Color3.fromRGB(150,60,60)
printBtn.TextColor3 = Color3.fromRGB(255,255,255)
printBtn.Parent = frame

-- Tombol Auto Teleport
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(1,-20,0,40)
tpBtn.Position = UDim2.new(0,10,0,190)
tpBtn.Text = "Auto Teleport"
tpBtn.BackgroundColor3 = Color3.fromRGB(60,60,150)
tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
tpBtn.Parent = frame

-- Delay teleport
local delayBox = Instance.new("TextBox")
delayBox.Size = UDim2.new(1,-20,0,30)
delayBox.Position = UDim2.new(0,10,0,240)
delayBox.PlaceholderText = "Delay teleport (detik)"
delayBox.Text = "0.5"
delayBox.TextColor3 = Color3.fromRGB(255,255,255)
delayBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
delayBox.Parent = frame

-- ScrollFrame koordinat
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,-20,0,200)
scrollFrame.Position = UDim2.new(0,10,0,280)
scrollFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
scrollFrame.ScrollBarThickness = 6
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = scrollFrame
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0,5)

-- Fungsi update ScrollFrame
local function updateScrollFrame()
    scrollFrame:ClearAllChildren()
    uiListLayout.Parent = scrollFrame
    for i,pos in ipairs(savedPositions) do
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

        -- Tombol Edit
        local editBtn = Instance.new("TextButton")
        editBtn.Size = UDim2.new(0.15,0,1,0)
        editBtn.Position = UDim2.new(0.85,0,0,0)
        editBtn.Text = "Edit"
        editBtn.TextScaled = true
        editBtn.BackgroundColor3 = Color3.fromRGB(50,150,50)
        editBtn.TextColor3 = Color3.fromRGB(255,255,255)
        editBtn.Parent = container

        editBtn.MouseButton1Click:Connect(function()
            local newName = cpName.."_edited"
            cpNames[i] = newName
            updateScrollFrame()
        end)
    end
end

-- Tombol Save Posisi
saveBtn.MouseButton1Click:Connect(function()
    if not hrp then return end
    local pos = hrp.Position
    table.insert(savedPositions,pos)

    local inputName = nameBox.Text
    if inputName == "" then
        if #savedPositions==1 then inputName="CP1"
        elseif #savedPositions==2 then inputName="CP2"
        elseif #savedPositions==3 then inputName="CP3"
        else inputName="Summit" end
    end
    table.insert(cpNames,inputName)
    nameBox.Text = ""
    updateScrollFrame()
end)

-- Tombol Cetak Kode
printBtn.MouseButton1Click:Connect(function()
    print("Kode koordinat siap pakai:")
    for i,pos in ipairs(savedPositions) do
        local cpName = cpNames[i] or ("CP"..i)
        print(cpName.." = Vector3.new("..pos.X..","..pos.Y..","..pos.Z..")")
    end
end)

-- Tombol Auto Teleport
tpBtn.MouseButton1Click:Connect(function()
    local delayTime = tonumber(delayBox.Text) or 0.5
    for i,pos in ipairs(savedPositions) do
        hrp.CFrame = CFrame.new(pos)
        wait(delayTime)
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
