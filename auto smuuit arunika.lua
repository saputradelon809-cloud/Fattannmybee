local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Pastikan HumanoidRootPart siap
local hrp
local function getHRP()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        hrp = player.Character.HumanoidRootPart
    else
        player.CharacterAdded:Wait()
        hrp = player.Character:WaitForChild("HumanoidRootPart")
    end
end
getHRP()

local savedPositions = {}
local cpNames = {}

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "CoordinateSaverGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 600)
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

-- Input nama CP
local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(1,-20,0,30)
nameBox.Position = UDim2.new(0,10,0,50)
nameBox.PlaceholderText = "Masukkan nama CP"
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

-- Tombol Auto Loop Teleport
local loopBtn = Instance.new("TextButton")
loopBtn.Size = UDim2.new(1,-20,0,40)
loopBtn.Position = UDim2.new(0,10,0,240)
loopBtn.Text = "Auto Loop Teleport"
loopBtn.BackgroundColor3 = Color3.fromRGB(80,80,200)
loopBtn.TextColor3 = Color3.fromRGB(255,255,255)
loopBtn.Parent = frame

-- Tombol Clear All
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(1,-20,0,40)
clearBtn.Position = UDim2.new(0,10,0,290)
clearBtn.Text = "Clear All"
clearBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
clearBtn.TextColor3 = Color3.fromRGB(255,255,255)
clearBtn.Parent = frame

-- Delay teleport
local delayBox = Instance.new("TextBox")
delayBox.Size = UDim2.new(1,-20,0,30)
delayBox.Position = UDim2.new(0,10,0,340)
delayBox.PlaceholderText = "Delay teleport (detik)"
delayBox.Text = "0.5"
delayBox.TextColor3 = Color3.fromRGB(255,255,255)
delayBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
delayBox.Parent = frame

-- ScrollFrame koordinat
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,-20,0,220)
scrollFrame.Position = UDim2.new(0,10,0,380)
scrollFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
scrollFrame.ScrollBarThickness = 6
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0,5)
uiListLayout.Parent = scrollFrame

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
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = cpName .. ": Vector3.new("..pos.X..","..pos.Y..","..pos.Z..")"
        label.Parent = container

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.3,0,1,0)
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
    end
end

-- Notifikasi sederhana
local function notify(msg)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(1,0,0,30)
    notif.Position = UDim2.new(0,0,0,0)
    notif.BackgroundColor3 = Color3.fromRGB(50,50,50)
    notif.TextColor3 = Color3.fromRGB(255,255,0)
    notif.Text = msg
    notif.TextScaled = true
    notif.Parent = frame
    game.Debris:AddItem(notif,1.5)
end

-- Tombol Save Posisi
saveBtn.MouseButton1Click:Connect(function()
    getHRP()
    if not hrp then return end
    local pos = hrp.Position
    table.insert(savedPositions,pos)
    local inputName = nameBox.Text
    if inputName == "" then inputName = "CP"..#savedPositions end
    table.insert(cpNames,inputName)
    nameBox.Text = ""
    updateScrollFrame()
    notify("Koordinat "..inputName.." tersimpan!")
end)

-- Tombol Cetak Kode
printBtn.MouseButton1Click:Connect(function()
    print("Kode koordinat siap pakai:")
    for i,pos in ipairs(savedPositions) do
        local cpName = cpNames[i] or ("CP"..i)
        print(cpName.." = Vector3.new("..pos.X..","..pos.Y..","..pos.Z..")")
    end
    notify("Kode koordinat dicetak di output")
end)

-- Tombol Auto Teleport
tpBtn.MouseButton1Click:Connect(function()
    getHRP()
    if not hrp then return end
    local delayTime = tonumber(delayBox.Text) or 0.5
    for i,pos in ipairs(savedPositions) do
        hrp.CFrame = CFrame.new(pos)
        wait(delayTime)
    end
    notify("Selesai Auto Teleport")
end)

-- Tombol Auto Loop Teleport
loopBtn.MouseButton1Click:Connect(function()
    getHRP()
    if not hrp then return end
    local delayTime = tonumber(delayBox.Text) or 0.5
    spawn(function()
        while #savedPositions>0 do
            for i,pos in ipairs(savedPositions) do
                hrp.CFrame = CFrame.new(pos)
                wait(delayTime)
            end
        end
    end)
    notify("Auto Loop Teleport dimulai")
end)

-- Tombol Clear All
clearBtn.MouseButton1Click:Connect(function()
    savedPositions = {}
    cpNames = {}
    updateScrollFrame()
    notify("Semua koordinat dihapus")
end)

-- Drag GUI mobile
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
