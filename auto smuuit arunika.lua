-- Gunung Gataulah Teleport GUI (StarterGui LocalScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportRequest = ReplicatedStorage:WaitForChild("TeleportRequest")
local GetCheckpoint = ReplicatedStorage:WaitForChild("GetCheckpoint")

local player = game.Players.LocalPlayer

-- === GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- frame utama
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 320)
mainFrame.Position = UDim2.new(0, 20, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.Parent = screenGui

-- tab frame
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 35)
tabFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
tabFrame.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabFrame

-- content
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -35)
contentFrame.Position = UDim2.new(0, 0, 0, 35)
contentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
contentFrame.Parent = mainFrame

-- fungsi tab
local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.Parent = tabFrame

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = contentFrame

    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.Padding = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("Frame") then child.Visible = false end
        end
        page.Visible = true
    end)

    return page
end

-- daftar titik
local POINT_NAMES = {
    "Safezone A",
    "Pos 1",
    "Pos 2",
    "Pos 3",
    "Pos 4",
    "Safezone B",
    "Pos 5",
    "Pos 6",
    "Summit",
}

-- helper button
local function makeButton(parent, name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- === TAB MANUAL ===
local manualPage = createTab("Manual")
makeButton(manualPage, "Kembali ke CP Terakhir", function()
    local vec = GetCheckpoint:InvokeServer()
    if vec then
        TeleportRequest:FireServer(player:GetAttribute("CheckpointName"))
    end
end)

for _, name in ipairs(POINT_NAMES) do
    makeButton(manualPage, "Pergi ke "..name, function()
        TeleportRequest:FireServer(name)
    end)
end

-- === TAB AUTO ===
local autoPage = createTab("Auto")
local running = false

local function autoRoute(untilIndex)
    if running then return end
    running = true
    for i = 1, untilIndex do
        if not running then break end
        TeleportRequest:FireServer(POINT_NAMES[i])
        task.wait(3)
    end
    running = false
end

for i, name in ipairs(POINT_NAMES) do
    makeButton(autoPage, "Auto sampai "..name, function()
        if not running then
            task.spawn(function() autoRoute(i) end)
        else
            running = false
        end
    end)
end

-- default buka manual
manualPage.Visible = true
