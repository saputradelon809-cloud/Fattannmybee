-- ===== FATTANHUB Recorder Full =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== Loading Screen =====
local loadingGui = Instance.new("ScreenGui",playerGui)
loadingGui.Name = "FATTANHUB_Loading"

local loadingFrame = Instance.new("Frame",loadingGui)
loadingFrame.Size=UDim2.new(1,0,1,0)
loadingFrame.BackgroundColor3=Color3.fromRGB(15,15,15)

local loadingLabel = Instance.new("TextLabel",loadingFrame)
loadingLabel.Size=UDim2.new(0.8,0,0,80)
loadingLabel.Position=UDim2.new(0.1,0,0.4,0)
loadingLabel.BackgroundTransparency=1
loadingLabel.Text="FATTANHUB👑"
loadingLabel.TextColor3=Color3.fromRGB(255,215,0)
loadingLabel.Font=Enum.Font.GothamBlack
loadingLabel.TextScaled=true
loadingLabel.TextStrokeTransparency=0
loadingLabel.TextXAlignment=Enum.TextXAlignment.Center
loadingLabel.TextYAlignment=Enum.TextYAlignment.Center

local barBack=Instance.new("Frame",loadingFrame)
barBack.Size=UDim2.new(0.6,0,0,20)
barBack.Position=UDim2.new(0.2,0,0.6,0)
barBack.BackgroundColor3=Color3.fromRGB(50,50,50)
Instance.new("UICorner",barBack).CornerRadius=UDim.new(0,10)

local barFront=Instance.new("Frame",barBack)
barFront.Size=UDim2.new(0,0,1,0)
barFront.BackgroundColor3=Color3.fromRGB(255,215,0)
Instance.new("UICorner",barFront).CornerRadius=UDim.new(0,10)

-- ===== Main GUI =====
local guiName = "FATTANHUB_Recorder"
local oldGui = playerGui:FindFirstChild(guiName)
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
screenGui.Enabled = true

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,360,0,500)
mainFrame.Position = UDim2.new(0.5,-180,0.1,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35,35,40)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false -- tampil setelah loading selesai
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
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

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

-- Helper: tombol
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

-- Tombol utama
local recordBtn = createButton(contentFrame,"⏺ Record",UDim2.new(0,10,0,10),Color3.fromRGB(70,130,180))
local pauseBtn = createButton(contentFrame,"⏸ Pause",UDim2.new(0,200,0,10),Color3.fromRGB(255,215,0))
local saveBtn = createButton(contentFrame,"💾 Save",UDim2.new(0,10,0,55),Color3.fromRGB(34,139,34))
local loadBtn = createButton(contentFrame,"📂 Load",UDim2.new(0,200,0,55),Color3.fromRGB(100,149,237))
local mergeBtn = createButton(contentFrame,"🔗 Merge & Play",UDim2.new(0,10,0,100),Color3.fromRGB(255,140,0))

-- Speed
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

-- Replay logic
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

local function startRecording() recordData={} isRecording=true end
local function stopRecording() isRecording=false end

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

-- Play replay
local function playReplay(data)
    local token = {}
    currentReplayToken = token
    local index = 1
    while index <= #data do
        if currentReplayToken ~= token then break end
        while isPaused and currentReplayToken == token do
            RunService.Heartbeat:Wait()
        end
        if hrp and hrp.Parent and currentReplayToken == token then
            local f = data[math.floor(index)]
            hrp.CFrame = CFrame.lookAt(
                Vector3.new(f.Position[1],f.Position[2],f.Position[3]),
                Vector3.new(f.Position[1]+f.LookVector[1], f.Position[2]+f.LookVector[2], f.Position[3]+f.LookVector[3]),
                Vector3.new(f.UpVector[1], f.UpVector[2], f.UpVector[3])
            )
        end
        local speed = tonumber(speedBox.Text) or 1
        if speed <= 0 then speed = 1 end
        index = index + speed
        RunService.Heartbeat:Wait()
    end
    if currentReplayToken == token then currentReplayToken=nil end
end

-- Refresh list
local function refreshReplayList()
    for _,c in ipairs(replayList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i,r in ipairs(savedReplays) do
        local item = Instance.new("Frame", replayList)
        item.Size = UDim2.new(1,0,0,40)
        item.BackgroundColor3 = Color3.fromRGB(65,65,75)
        local nameBox = Instance.new("TextBox", item)
        nameBox.Size = UDim2.new(0.5,-10,1,0)
        nameBox.Position = UDim2.new(0,5,0,0)
        nameBox.Text = r.Name
        nameBox.TextColor3 = Color3.new(1,1,1)
        nameBox.ClearTextOnFocus=false
        Instance.new("UICorner",nameBox).CornerRadius=UDim.new(0,4)
        r.Selected = r.Selected or false
        local selectBtn = createButton(item,"☐",UDim2.new(0.55,0,0.15,0),Color3.fromRGB(100,100,100))
        selectBtn.Size=UDim2.new(0,30,0,25)
        selectBtn.MouseButton1Click:Connect(function()
            r.Selected = not r.Selected
            selectBtn.Text = r.Selected and "☑" or "☐"
        end)
        local playBtn = createButton(item,"▶",UDim2.new(0.65,0,0.15,0),Color3.fromRGB(70,130,180))
        playBtn.Size=UDim2.new(0,30,0,25)
        playBtn.MouseButton1Click:Connect(function() task.spawn(function() playReplay(r.Frames) end) end)
        local delBtn = createButton(item,"🗑",UDim2.new(0.75,0,0.15,0),Color3.fromRGB(220,20,60))
        delBtn.Size=UDim2.new(0,30,0,25)
        delBtn.MouseButton1Click:Connect(function() table.remove(savedReplays,i) refreshReplayList() end)
    end
    replayList.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y+10)
end

-- Tombol utama
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
    pauseBtn.Text = isPaused and "▶ Resume" or "⏸ Pause"
end)
saveBtn.MouseButton1Click:Connect(function()
    if #recordData>0 then
        table.insert(savedReplays,{Frames=recordData,Name="Replay "..(#savedReplays+1)})
        refreshReplayList()
    end
end)
loadBtn.MouseButton1Click:Connect(function() refreshReplayList() end)
mergeBtn.MouseButton1Click:Connect(function()
    local merged = {}
    for _,r in ipairs(savedReplays) do
        if r.Selected then
            for _,f in ipairs(r.Frames) do table.insert(merged,f) end
        end
    end
    if #merged>0 then task.spawn(function() playReplay(merged) end) end
end)

local minimized=false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentFrame.Visible = not minimized
    mainFrame.Size = minimized and UDim2.new(0,200,0,50) or UDim2.new(0,360,0,500)
end)

-- ===== Loading Animation =====
task.spawn(function()
    local startTime = tick()
    local duration = 5
    while tick()-startTime < duration do
        local progress = (tick()-startTime)/duration
        barFront.Size = UDim2.new(progress,0,1,0)
        RunService.Heartbeat:Wait()
    end
    barFront.Size = UDim2.new(1,0,1,0)
    wait(0.2)
    loadingGui:Destroy()
    mainFrame.Visible = true
end)
