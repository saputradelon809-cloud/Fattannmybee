-- Fattan Hub Simple + Login
local PASSWORD = "FATTANGANTENG"
local TweenService = game:GetService("TweenService")

-- Login GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,250,0,120)
frame.Position = UDim2.new(0.4,0,0.35,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "Fattan Hub Login"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,60,60)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold

local pass = Instance.new("TextBox", frame)
pass.Size = UDim2.new(0.8,0,0,30)
pass.Position = UDim2.new(0.1,0,0.4,0)
pass.PlaceholderText = "Password..."
pass.BackgroundColor3 = Color3.fromRGB(40,40,40)
pass.TextColor3 = Color3.fromRGB(255,255,255)
pass.TextScaled = true

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.6,0,0,30)
btn.Position = UDim2.new(0.2,0,0.75,0)
btn.Text = "LOGIN"
btn.BackgroundColor3 = Color3.fromRGB(80,0,0)
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.TextScaled = true

-- Notif
local function notif(msg,parent)
    local n = Instance.new("TextLabel",parent)
    n.Size = UDim2.new(0,200,0,25)
    n.Position = UDim2.new(1,-210,1,-35)
    n.BackgroundColor3 = Color3.fromRGB(30,30,30)
    n.BorderColor3 = Color3.fromRGB(200,0,0)
    n.Text = msg
    n.TextColor3 = Color3.fromRGB(255,60,60)
    n.TextScaled = true
    n.BackgroundTransparency = 1
    TweenService:Create(n,TweenInfo.new(0.3),{BackgroundTransparency=0}):Play()
    task.delay(2,function()
        TweenService:Create(n,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        task.wait(0.3)n:Destroy()
    end)
end

-- Load Hub
local function loadHub()
    frame:Destroy()
    local hub = Instance.new("ScreenGui", game.CoreGui)
    local main = Instance.new("Frame", hub)
    main.Size = UDim2.new(0,260,0,150)
    main.Position = UDim2.new(0.37,0,0.35,0)
    main.BackgroundColor3 = Color3.fromRGB(25,25,25)

    local t = Instance.new("TextLabel", main)
    t.Size = UDim2.new(1,-30,0,30)
    t.Text = "Fattan Hub"
    t.BackgroundTransparency = 1
    t.TextColor3 = Color3.fromRGB(255,60,60)
    t.TextScaled = true
    t.Font = Enum.Font.SourceSansBold

    local close = Instance.new("TextButton", main)
    close.Size = UDim2.new(0,30,0,30)
    close.Position = UDim2.new(1,-30,0,0)
    close.Text = "X"
    close.MouseButton1Click:Connect(function()hub:Destroy()end)

    local function makeBtn(txt,y,cb)
        local b = Instance.new("TextButton",main)
        b.Size = UDim2.new(0.8,0,0,30)
        b.Position = UDim2.new(0.1,0,y,0)
        b.Text = txt
        b.BackgroundColor3 = Color3.fromRGB(40,40,40)
        b.TextColor3 = Color3.fromRGB(255,60,60)
        b.TextScaled = true
        b.MouseButton1Click:Connect(function()cb()notif("✅ "..txt.." Aktif!",hub)end)
    end

    makeBtn("Fattan Auto Farm",0.3,function()print("Auto Farm aktif")end)
    makeBtn("Fattan ESP",0.55,function()print("ESP aktif")end)
    makeBtn("Fattan Teleport",0.8,function()print("Teleport aktif")end)
end

btn.MouseButton1Click:Connect(function()
    if pass.Text == PASSWORD then
        loadHub()
    else
        btn.Text = "❌ SALAH!"
        TweenService:Create(btn,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(200,0,0)}):Play()
        task.delay(1.5,function()
            btn.Text = "LOGIN"
            btn.BackgroundColor3 = Color3.fromRGB(80,0,0)
        end)
    end
end)
