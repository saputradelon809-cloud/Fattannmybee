--// CHECKPOINT SAVER with File Save
-- by ChatGPT

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local savedPoints = {}
local saveFile = "checkpoint_data.json" -- nama file penyimpanan

-- Cek apakah sudah ada file lama
if isfile and isfile(saveFile) then
    local data = readfile(saveFile)
    local success, decoded = pcall(function()
        return game:GetService("HttpService"):JSONDecode(data)
    end)
    if success and typeof(decoded) == "table" then
        savedPoints = decoded
    end
end

-- Fungsi simpan ke file
local function saveToFile()
    if writefile then
        local data = game:GetService("HttpService"):JSONEncode(savedPoints)
        writefile(saveFile, data)
    end
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "CPGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0, 20, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.BorderSizePixel = 2

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50,50,50)
Title.Text = "Checkpoint Saver"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local BtnHolder = Instance.new("Frame", Frame)
BtnHolder.Size = UDim2.new(1, -20, 0, 90)
BtnHolder.Position = UDim2.new(0, 10, 0, 40)
BtnHolder.BackgroundTransparency = 1

local function makeButton(name, posY)
    local btn = Instance.new("TextButton", BtnHolder)
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = name
    return btn
end

local SaveBtn = makeButton("Save Position", 0)
local TpLastBtn = makeButton("Teleport Last", 30)
local AutoBtn = makeButton("Auto Teleport All", 60)

-- List
local List = Instance.new("ScrollingFrame", Frame)
List.Size = UDim2.new(1, -20, 0, 140)
List.Position = UDim2.new(0, 10, 0, 140)
List.CanvasSize = UDim2.new(0,0,0,0)
List.BackgroundColor3 = Color3.fromRGB(35,35,35)
List.BorderSizePixel = 1
List.ScrollBarThickness = 6

-- Refresh List
local function refreshList()
    List:ClearAllChildren()
    for i, pos in ipairs(savedPoints) do
        local Item = Instance.new("Frame", List)
        Item.Size = UDim2.new(1, -10, 0, 30)
        Item.Position = UDim2.new(0, 5, 0, (i-1)*35)
        Item.BackgroundColor3 = Color3.fromRGB(45,45,45)
        
        local Label = Instance.new("TextLabel", Item)
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = "CP "..i.." ("..math.floor(pos.X)..","..math.floor(pos.Y)..","..math.floor(pos.Z)..")"
        Label.TextColor3 = Color3.fromRGB(255,255,255)
        Label.Font = Enum.Font.SourceSans
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        
        local TpBtn = Instance.new("TextButton", Item)
        TpBtn.Size = UDim2.new(0.2, -5, 1, -5)
        TpBtn.Position = UDim2.new(0.7, 0, 0, 2)
        TpBtn.Text = "TP"
        TpBtn.BackgroundColor3 = Color3.fromRGB(70,120,70)
        TpBtn.TextColor3 = Color3.fromRGB(255,255,255)
        
        local DelBtn = Instance.new("TextButton", Item)
        DelBtn.Size = UDim2.new(0.1, -5, 1, -5)
        DelBtn.Position = UDim2.new(0.9, 0, 0, 2)
        DelBtn.Text = "✖"
        DelBtn.BackgroundColor3 = Color3.fromRGB(120,70,70)
        DelBtn.TextColor3 = Color3.fromRGB(255,255,255)

        -- Aksi tombol
        TpBtn.MouseButton1Click:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
            end
        end)
        
        DelBtn.MouseButton1Click:Connect(function()
            table.remove(savedPoints, i)
            saveToFile()
            refreshList()
        end)
    end
    List.CanvasSize = UDim2.new(0,0,0,#savedPoints*35)
end

-- Tombol utama
SaveBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = player.Character.HumanoidRootPart.Position
        table.insert(savedPoints, pos)
        saveToFile()
        refreshList()
    end
end)

TpLastBtn.MouseButton1Click:Connect(function()
    if #savedPoints > 0 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(savedPoints[#savedPoints] + Vector3.new(0,3,0))
    end
end)

AutoBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        for i, pos in ipairs(savedPoints) do
            player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
            task.wait(1)
        end
    end
end)

-- Awal: refresh list dari file
refreshList()
