-- Roblox Studio Friendly Version FATTANHUB
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ====== Loading Screen ======
local loadingScreen = Instance.new("ScreenGui")
loadingScreen.Name = "FATTANHUB_Loading"
loadingScreen.ResetOnSpawn = false
loadingScreen.Parent = playerGui

local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1,0,1,0)
loadingFrame.Position = UDim2.new(0,0,0,0)
loadingFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
loadingFrame.Parent = loadingScreen

local loadingLabel = Instance.new("TextLabel")
loadingLabel.Size = UDim2.new(1,0,0,100)
loadingLabel.Position = UDim2.new(0,0,0.4,0)
loadingLabel.BackgroundTransparency = 1
loadingLabel.Text = "FATTANHUB👑"
loadingLabel.TextColor3 = Color3.fromRGB(255,215,0)
loadingLabel.Font = Enum.Font.GothamBlack
loadingLabel.TextScaled = true
loadingLabel.TextStrokeTransparency = 0
loadingLabel.Parent = loadingFrame

local barBack = Instance.new("Frame", loadingFrame)
barBack.Size = UDim2.new(0.6,0,0,20)
barBack.Position = UDim2.new(0.2,0,0.6,0)
barBack.BackgroundColor3 = Color3.fromRGB(50,50,50)
barBack.BorderSizePixel = 0

local barFront = Instance.new("Frame", barBack)
barFront.Size = UDim2.new(0,0,1,0)
barFront.BackgroundColor3 = Color3.fromRGB(255,215,0)
barFront.BorderSizePixel = 0

-- Loading animation 5 detik
task.spawn(function()
    local duration = 5
    local startTime = tick()
    while tick() - startTime < duration do
        local progress = (tick() - startTime)/duration
        barFront.Size = UDim2.new(progress,0,1,0)
        loadingLabel.TextTransparency = math.abs(math.sin(tick()*3))
        RunService.RenderStepped:Wait()
    end
    loadingScreen:Destroy()
end)

-- ====== GUI Setup ======
local guiName = "FATTANHUB_Recorder"
local oldGui = playerGui:FindFirstChild(guiName)
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,350,0,400)
mainFrame.Position = UDim2.new(0.5,-175,0.1,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35,35,40)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Header
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1,0,0,50)
header.BackgroundColor3 = Color3.fromRGB(45,45,55)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-90,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "FATTANHUB 🏔 PS SCRIPT AUTO WALK"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0,35,0,35)
closeBtn.Position = UDim2.new(1,-45,0,7)
closeBtn.Text = "✖"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,70,70)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0,35,0,35)
minimizeBtn.Position = UDim2.new(1,-90,0,7)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16

-- Content Frame
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1,-20,1,-60)
contentFrame.Position = UDim2.new(0,10,0,50)
contentFrame.BackgroundColor3 = Color3.fromRGB(45,45,55)

-- Button helper
local function createButton(parent,text,pos,color)
    local btn = Instance.new("TextButton",parent)
    btn.Size = UDim2.new(0,150,0,35)
    btn.Position = pos
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
    return btn
end

-- Buttons
local recordBtn = createButton(contentFrame,"⏺ Record",UDim2.new(0,10,0,10),Color3.fromRGB(70,130,180))
local pauseBtn = createButton(contentFrame,"⏸ Pause",UDim2.new(0,170,0,10),Color3.fromRGB(255,215,0))
local saveBtn = createButton(contentFrame,"💾 Save Replay",UDim2.new(0,10,0,55),Color3.fromRGB(34,139,34))
local loadBtn = createButton(contentFrame,"📂 Load Replay",UDim2.new(0,170,0,55),Color3.fromRGB(100,149,237))
local mergeBtn = createButton(contentFrame,"🔗 Merge & Play",UDim2.new(0,10,0,100),Color3.fromRGB(255,140,0))

-- Speed control
local speedLabel = Instance.new("TextLabel", contentFrame)
speedLabel.Size = UDim2.new(0,60,0,30)
speedLabel.Position = UDim2.new(0,10,0,145)
speedLabel.Text = "Speed:"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedBox = Instance.new("TextBox", contentFrame)
speedBox.Size = UDim2.new(0,50,0,30)
speedBox.Position = UDim2.new(0,75,0,145)
speedBox.Text = "1"
speedBox.ClearTextOnFocus = false
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.BackgroundColor3 = Color3.fromRGB(80,80,90)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0,6)

-- Replay List
local replayList = Instance.new("ScrollingFrame", contentFrame)
replayList.Size = UDim2.new(1,-20,1,-190)
replayList.Position = UDim2.new(0,10,0,185)
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

-- Minimize button toggle
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        contentFrame.Visible = false
        mainFrame.Size = UDim2.new(0,200,0,50)
    else
        contentFrame.Visible = true
        mainFrame.Size = UDim2.new(0,350,0,400)
    end
end)
