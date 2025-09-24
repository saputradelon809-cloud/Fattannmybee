--// CIEN HUB by cien.txt
--// All-in-one Hub: SCRIPT, TXT, SUMMIT, TrolX

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "CIEN HUB || By cien.txt",
    LoadingTitle = "CIEN HUB",
    LoadingSubtitle = "by cien.txt",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "CienHub",
        FileName = "CienHubSettings"
    },
    KeySystem = false
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

---------------------------------
-- Notifications
---------------------------------
local function notify(title, text)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = 6,
        Image = 4483362458,
    })
end

---------------------------------
-- SCRIPT TAB
---------------------------------
local ScriptTab = Window:CreateTab("SCRIPT", 4483362458)

-- Fly
local flying = false
local flySpeed = 60
local flyUp, flyDown = false, false
local BodyVel, BodyGyro

local function stopFly()
    flying = false
    if BodyVel then BodyVel:Destroy() BodyVel=nil end
    if BodyGyro then BodyGyro:Destroy() BodyGyro=nil end
end

local function startFly()
    if flying then return end
    flying = true
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    BodyVel = Instance.new("BodyVelocity")
    BodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
    BodyVel.Velocity = Vector3.zero
    BodyVel.Parent = hrp

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    BodyGyro.P = 1e5
    BodyGyro.CFrame = hrp.CFrame
    BodyGyro.Parent = hrp

    RunService.RenderStepped:Connect(function()
        if flying and hrp then
            local camCF = Workspace.CurrentCamera.CFrame
            local moveDir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end
            if flyUp then moveDir += Vector3.new(0,1,0) end
            if flyDown then moveDir -= Vector3.new(0,1,0) end
            BodyVel.Velocity = moveDir * flySpeed
            BodyGyro.CFrame = camCF
        end
    end)
end

ScriptTab:CreateToggle({
    Name = "✈️ Fly",
    CurrentValue = false,
    Callback = function(state)
        if state then startFly() else stopFly() end
    end
})

-- ESP
local ESPs, ESPEnabled = {}, false
local function createESP(player)
    if not player.Character or ESPs[player] then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0,150,0,50)
    billboard.Adornee = hrp
    billboard.AlwaysOnTop = true
    local text = Instance.new("TextLabel", billboard)
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1,1,1)
    text.Text = player.Name
    billboard.Parent = game:GetService("CoreGui")
    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillColor = Color3.fromRGB(0,170,255)
    highlight.Parent = player.Character
    ESPs[player] = {billboard=billboard, highlight=highlight}
end
local function removeESP(player)
    if ESPs[player] then
        if ESPs[player].billboard then ESPs[player].billboard:Destroy() end
        if ESPs[player].highlight then ESPs[player].highlight:Destroy() end
        ESPs[player]=nil
    end
end
ScriptTab:CreateToggle({
    Name = "ESP Player",
    CurrentValue = false,
    Callback = function(state)
        ESPEnabled = state
        if not state then
            for plr,_ in pairs(ESPs) do removeESP(plr) end
        end
    end
})
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _,plr in pairs(Players:GetPlayers()) do
            if plr~=LocalPlayer then createESP(plr) end
        end
    end
end)
Players.PlayerRemoving:Connect(removeESP)

-- God Mode
ScriptTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Callback = function(state)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if state then
                hum.MaxHealth = math.huge
                hum.Health = hum.MaxHealth
                hum:GetPropertyChangedSignal("Health"):Connect(function()
                    if hum.Health<hum.MaxHealth then hum.Health=hum.MaxHealth end
                end)
            else
                hum.MaxHealth = 100
                if hum.Health>100 then hum.Health=100 end
            end
        end
    end
})

-- WalkSpeed & JumpPower
ScriptTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16,300},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(val)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end
})
ScriptTab:CreateSlider({
    Name = "Jump Power",
    Range = {50,500},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(val)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = val end
    end
})

-- Infinite Jump
ScriptTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(state)
        _G.infJump = state
    end
})
UIS.JumpRequest:Connect(function()
    if _G.infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Admin Title
ScriptTab:CreateToggle({
    Name = "👑 ADMIN 👑",
    CurrentValue = false,
    Callback = function(state)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local existing = game:GetService("CoreGui"):FindFirstChild("AdminBillboard")
            if state and not existing then
                local billboard = Instance.new("BillboardGui")
                billboard.Name="AdminBillboard"
                billboard.Size=UDim2.new(0,120,0,25)
                billboard.Adornee=char.HumanoidRootPart
                billboard.AlwaysOnTop=true
                local label=Instance.new("TextLabel", billboard)
                label.Size=UDim2.new(1,0,1,0)
                label.BackgroundTransparency=1
                label.TextColor3=Color3.fromRGB(255,215,0)
                label.Text="👑ADMIN👑"
                billboard.Parent=game:GetService("CoreGui")
            else
                if existing then existing:Destroy() end
            end
        end
    end
})

---------------------------------
-- TXT TAB
---------------------------------
local TxtTab = Window:CreateTab("TXT", 4483362458)

-- Teleport Player (pilih nama)
local function tpToPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,2,0)
        end
    end
end

TxtTab:CreateDropdown({
    Name = "Teleport to Player",
    Options = {},
    CurrentOption = "",
    Callback = function(targetName)
        tpToPlayer(targetName)
    end
})

-- Update dropdown otomatis
local function updatePlayerList()
    local names = {}
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    TxtTab.UpdateDropdown("Teleport to Player", names)
end
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- NoClip
local noclip=false
TxtTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback=function(state) noclip=state end
})
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
    end
end)

-- Hide Name
TxtTab:CreateToggle({
    Name="Hide Name",
    CurrentValue=false,
    Callback=function(state)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
            local head=LocalPlayer.Character.Head
            if state then
                for _,v in pairs(head:GetChildren()) do
                    if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then v.Enabled=false end
                end
            else
                for _,v in pairs(head:GetChildren()) do
                    if v:IsA("BillboardGui") or v:IsA("SurfaceGui") then v.Enabled=true end
                end
            end
        end
    end
})

-- Invisible
TxtTab:CreateToggle({
    Name="Invisible",
    CurrentValue=false,
    Callback=function(state)
        if LocalPlayer.Character then
            for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then
                    v.Transparency = state and 1 or 0
                end
            end
        end
    end
})

-- Load Infinite Yield
TxtTab:CreateButton({
    Name="Load Infinite Yield",
    Callback=function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

-- CCTV Player (kamera lihat player lain)
TxtTab:CreateDropdown({
    Name = "CCTV Player",
    Options = {},
    CurrentOption = "",
    Callback = function(targetName)
        local target = Players:FindFirstChild(targetName)
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Workspace.CurrentCamera.CameraSubject = target.Character.Head
            notify("CCTV","Kamera mengikuti "..targetName)
        end
    end
})
local function updateCCTVList()
    local names={}
    for _,plr in pairs(Players:GetPlayers()) do
        if plr~=LocalPlayer then table.insert(names,plr.Name) end
    end
    TxtTab.UpdateDropdown("CCTV Player",names)
end
Players.PlayerAdded:Connect(updateCCTVList)
Players.PlayerRemoving:Connect(updateCCTVList)
updateCCTVList()

---------------------------------
-- SUMMIT TAB
---------------------------------
local SummitTab = Window:CreateTab("SUMMIT", 4483362458)

local function autoSummit(points)
    task.spawn(function()
        while true do
            for _,pos in ipairs(points) do
                local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame=CFrame.new(pos)
                end
                task.wait(3)
            end
        end
    end)
end

SummitTab:CreateButton({
    Name="Mount Bayi",
    Callback=function()
        autoSummit({
            Vector3.new(-366,63,48),
            Vector3.new(-728,114,94),
            Vector3.new(-852,108,-35),
            Vector3.new(-1407,250,1502),
            Vector3.new(-1408,400,1617)
        })
    end
})

SummitTab:CreateButton({
    Name="Mount Pasrah",
    Callback=function()
        autoSummit({
            Vector3.new(-472,121,-363),
            Vector3.new(-16,115,-350),
            Vector3.new(42,133,-594),
            Vector3.new(-73,421,-939),
            Vector3.new(-168,478,-566),
            Vector3.new(-548,613,-13),
            Vector3.new(-1111,750,29),
            Vector3.new(-1069,854,-670),
            Vector3.new(-1010,910,-1113),
            Vector3.new(-739,986,-1638),
            Vector3.new(-187,1481,-2108),
            Vector3.new(65,1700,-1724)
        })
    end
})

SummitTab:CreateButton({
    Name="Mount Cikcok",
    Callback=function()
        autoSummit({
            Vector3.new(-365,182,-495),
            Vector3.new(-595,344,-863),
            Vector3.new(-1028,528,-747),
            Vector3.new(-1368,508,-866),
            Vector3.new(-1356,504,-1120),
            Vector3.new(-1325,512,-1869),
            Vector3.new(-1118,519,-2312),
            Vector3.new(-1093,516,-1816),
            Vector3.new(-1042,817,-1559),
            Vector3.new(-900,1100,-1507),
            Vector3.new(-622,1112,-1566),
            Vector3.new(-389,1132,-1293),
            Vector3.new(-283,1256,-1787),
            Vector3.new(-482,1288,-2171),
            Vector3.new(-374,1368,-2202),
            Vector3.new(-141,1596,-2143)
        })
    end
})

SummitTab:CreateButton({
    Name="Mount Pamali",
    Callback=function()
        autoSummit({
            Vector3.new(-91,449,651),
            Vector3.new(532,470,730),
            Vector3.new(767,360,389),
            Vector3.new(873,464,31),
            Vector3.new(-279,358,-98),
            Vector3.new(-335,460,-173),
            Vector3.new(-293,478,-337),
            Vector3.new(-295,619,-407),
            Vector3.new(-299,603,-555),
            Vector3.new(-546,744,-413),
            Vector3.new(-1416,627,-303),
            Vector3.new(-1925,570,-126),
            Vector3.new(-2208,674,-193),
            Vector3.new(-2527,775,-360),
            Vector3.new(-2691,784,-382),
            Vector3.new(-2892,776,-84),
            Vector3.new(-2948,800,257),
            Vector3.new(-3004,806,491),
            Vector3.new(-2717,786,474),
            Vector3.new(-2785,778,682)
        })
    end
})

---------------------------------
-- TROLX TAB (Visual Tools)
---------------------------------
local TrolxTab = Window:CreateTab("TrolX", 4483362458)

-- Jail Player
TrolxTab:CreateDropdown({
    Name="Jail Player",
    Options={},
    CurrentOption="",
    Callback=function(targetName)
        local target=Players:FindFirstChild(targetName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp=target.Character.HumanoidRootPart
            local jail=Instance.new("Part")
            jail.Size=Vector3.new(10,20,10)
            jail.Anchored=true
            jail.Transparency=0.5
            jail.Color=Color3.fromRGB(0,0,0)
            jail.CFrame=hrp.CFrame
            jail.Parent=workspace
        end
    end
})

-- Teleport Player to Me
TrolxTab:CreateDropdown({
    Name="TP Player To Me",
    Options={},
    CurrentOption="",
    Callback=function(targetName)
        local target=Players:FindFirstChild(targetName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrpTarget=target.Character.HumanoidRootPart
            local hrpMe=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrpMe then hrpTarget.CFrame=hrpMe.CFrame*CFrame.new(3,0,0) end
        end
    end
})

-- Update list player di TrolX
local function updateTrolxList()
    local names={}
    for _,plr in pairs(Players:GetPlayers()) do
        if plr~=LocalPlayer then table.insert(names,plr.Name) end
    end
    TrolxTab.UpdateDropdown("Jail Player",names)
    TrolxTab.UpdateDropdown("TP Player To Me",names)
end
Players.PlayerAdded:Connect(updateTrolxList)
Players.PlayerRemoving:Connect(updateTrolxList)
updateTrolxList()

-- Part Tools (Resize + Delete)
local Mouse=LocalPlayer:GetMouse()
local selectedPart=nil
local selectionBox=nil

-- Resize pakai Handles
local function addHandles(part)
    local handles = Instance.new("Handles")
    handles.Adornee = part
    handles.Style = Enum.HandlesStyle.Resize
    handles.Parent = part

    handles.MouseDrag:Connect(function(face, dist)
        local size = part.Size
        if face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then
            size = size + Vector3.new(0, dist, 0)
        elseif face == Enum.NormalId.Front or face == Enum.NormalId.Back then
            size = size + Vector3.new(0, 0, dist)
        elseif face == Enum.NormalId.Right or face == Enum.NormalId.Left then
            size = size + Vector3.new(dist, 0, 0)
        end
        part.Size = size
    end)
end

Mouse.Button1Down:Connect(function()
    if Mouse.Target and Mouse.Target:IsA("BasePart") then
        selectedPart=Mouse.Target
        if not selectionBox then
            selectionBox=Instance.new("SelectionBox")
            selectionBox.Color3=Color3.fromRGB(0,255,0)
            selectionBox.Parent=LocalPlayer:WaitForChild("PlayerGui")
        end
        selectionBox.Adornee=selectedPart
        addHandles(selectedPart)

        -- Delete pakai tombol Delete
        UIS.InputBegan:Connect(function(input)
            if input.KeyCode==Enum.KeyCode.Delete and selectedPart then
                selectedPart:Destroy()
                selectedPart=nil
                selectionBox.Adornee=nil
            end
        end)
    end
end)

---------------------------------
-- END
---------------------------------
notify("CIEN HUB","SC BY !TXT ✔ SUKSES\nSEMANGAT!! DI SETIAP PERTEMUAN PASTI ADA PERPISAHAN")
