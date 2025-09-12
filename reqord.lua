-- Roblox Studio friendly version
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ====== GUI Setup ======
local guiName = "FATTANHUB_Recorder"
local oldGui = playerGui:FindFirstChild(guiName)
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Fullscreen main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(1,0,1,0)
mainFrame.Position = UDim2.new(0,0,0,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35,35,40)
mainFrame.Active = true
mainFrame.Draggable = false -- fullscreen
mainFrame.Parent = screenGui

-- Header
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1,0,0,50)
header.BackgroundColor3 = Color3.fromRGB(45,45,55)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-20,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "FATTANHUB 🏔 PS SCRIPT AUTO WALK"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0,40,0,40)
closeBtn.Position = UDim2.new(1,-50,0,5)
closeBtn.Text = "✖"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,70,70)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ====== Content ======
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1,-20,1,-60)
contentFrame.Position = UDim2.new(0,10,0,50)
contentFrame.BackgroundColor3 = Color3.fromRGB(45,45,55)

-- Tombol
local function createButton(parent, text, pos, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,150,0,35)
    btn.Position = pos
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0,8)
    return btn
end

local recordBtn = createButton(contentFrame,"⏺ Record",UDim2.new(0,10,0,10),Color3.fromRGB(70,130,180))
local pauseBtn = createButton(contentFrame,"⏸ Pause",UDim2.new(0,170,0,10),Color3.fromRGB(255,215,0))
local saveBtn = createButton(contentFrame,"💾 Save Replay",UDim2.new(0,330,0,10),Color3.fromRGB(34,139,34))
local loadBtn = createButton(contentFrame,"📂 Load Replay",UDim2.new(0,10,0,55),Color3.fromRGB(100,149,237))
local mergeBtn = createButton(contentFrame,"🔗 Merge & Play",UDim2.new(0,170,0,55),Color3.fromRGB(255,140,0))

-- Speed
local speedLabel = Instance.new("TextLabel", contentFrame)
speedLabel.Size = UDim2.new(0,60,0,30)
speedLabel.Position = UDim2.new(0,10,0,100)
speedLabel.Text = "Speed:"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedBox = Instance.new("TextBox", contentFrame)
speedBox.Size = UDim2.new(0,50,0,30)
speedBox.Position = UDim2.new(0,75,0,100)
speedBox.Text = "1"
speedBox.ClearTextOnFocus = false
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.BackgroundColor3 = Color3.fromRGB(80,80,90)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0,6)

-- Replay List
local replayList = Instance.new("ScrollingFrame", contentFrame)
replayList.Size = UDim2.new(1,-20,1,-150)
replayList.Position = UDim2.new(0,10,0,140)
replayList.CanvasSize = UDim2.new(0,0,0,0)
replayList.ScrollBarThickness = 6
replayList.BackgroundColor3 = Color3.fromRGB(55,55,65)

local listLayout = Instance.new("UIListLayout", replayList)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0,5)

-- ====== Replay Logic ======
local character, hrp
local isRecording, isPausedRecord, isPaused = false,false,false
local recordData = {}
local savedReplays = {}
local currentReplayToken = nil

local function onCharacterAdded(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart",10)
end
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

local function startRecording()
    recordData = {}
    isRecording = true
end
local function stopRecording()
    isRecording = false
end

RunService.Heartbeat:Connect(function()
    if isRecording and hrp then
        local cf = hrp.CFrame
        table.insert(recordData,{
            Position={cf.Position.X,cf.Position.Y,cf.Position.Z},
            LookVector={cf.LookVector.X,cf.LookVector.Y,cf.LookVector.Z},
            UpVector={cf.UpVector.X,cf.UpVector.Y,cf.UpVector.Z}
        })
    end
end)

local function playReplay(data)
    local token = {}
    currentReplayToken = token
    local speed = tonumber(speedBox.Text) or 1
    speed = speed>0 and speed or 1
    local index = 1
    local total = #data
    while index <= total do
        if currentReplayToken ~= token then break end
        while isPaused and currentReplayToken == token do
            RunService.Heartbeat:Wait()
        end
        if hrp and hrp.Parent and currentReplayToken == token then
            local f = data[math.floor(index)]
            hrp.CFrame = CFrame.lookAt(
                Vector3.new(f.Position[1],f.Position[2],f.Position[3]),
                Vector3.new(f.Position[1]+f.LookVector[1],f.Position[2]+f.LookVector[2],f.Position[3]+f.LookVector[3]),
                Vector3.new(f.UpVector[1],f.UpVector[2],f.UpVector[3])
            )
        end
        index = index + speed
        RunService.Heartbeat:Wait()
    end
    if currentReplayToken == token then currentReplayToken=nil end
end

-- Button functions
recordBtn.MouseButton1Click:Connect(function()
    if not isRecording then
        recordBtn.Text="⏹ Stop"
        startRecording()
    else
        recordBtn.Text="⏺ Record"
        stopRecording()
    end
end)

pauseBtn.MouseButton1Click:Connect(function()
    isPaused = not isPaused
end)

saveBtn.MouseButton1Click:Connect(function()
    if #recordData>0 then
        table.insert(savedReplays,{Frames=recordData,Name="Replay "..(#savedReplays+1)})
    end
end)

mergeBtn.MouseButton1Click:Connect(function()
    local merged = {}
    for _,r in ipairs(savedReplays) do
        if r.Selected then
            for _,f in ipairs(r.Frames) do table.insert(merged,f) end
        end
    end
    if #merged>0 then task.spawn(function() playReplay(merged) end) end
end)
