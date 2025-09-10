--// Fancy Login GUI by Fattan
local PASSWORD = "FATTANGANTENG"
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Buat GUI utama
local gui = Instance.new("ScreenGui")
gui.Name = "LoginGui"
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Tambah efek blur background
local blur = Instance.new("BlurEffect", game.Lighting)
blur.Size = 15

-- Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 160)
frame.Position = UDim2.new(0.35, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Parent = gui
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Fattan Hub Login"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 60, 60)
title.TextScaled = true

-- TextBox untuk input password
local textbox = Instance.new("TextBox", frame)
textbox.Size = UDim2.new(1, -20, 0, 30)
textbox.Position = UDim2.new(0, 10, 0.4, 0)
textbox.PlaceholderText = "Enter Password"
textbox.Text = ""
textbox.TextScaled = true
textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textbox.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Tombol login
local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(1, -20, 0, 30)
button.Position = UDim2.new(0, 10, 0.7, 0)
button.Text = "Login"
button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
button.TextScaled = true
button.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Label notifikasi
local notif = Instance.new("TextLabel", frame)
notif.Size = UDim2.new(1, 0, 0, 20)
notif.Position = UDim2.new(0, 0, 1, 0)
notif.BackgroundTransparency = 1
notif.Text = ""
notif.TextColor3 = Color3.fromRGB(0, 255, 0)
notif.TextScaled = true

-- Suara klik
local clickSound = Instance.new("Sound", SoundService)
clickSound.SoundId = "rbxassetid://12222124" -- suara klik sederhana
clickSound.Volume = 1

-- Animasi keluar
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenOut = TweenService:Create(frame, tweenInfo, {Position = UDim2.new(0.5, 0, -1, 0)})

-- Event login
button.MouseButton1Click:Connect(function()
    clickSound:Play()

    if textbox.Text == PASSWORD then
        notif.Text = "✅ Login berhasil!"
        notif.TextColor3 = Color3.fromRGB(0, 255, 0)

        tweenOut:Play() -- animasi keluar
        tweenOut.Completed:Connect(function()
            gui:Destroy()
            blur:Destroy()
        end)
    else
        notif.Text = "❌ Password salah!"
        notif.TextColor3 = Color3.fromRGB(255, 0, 0)

        -- Efek goyang kalau salah
        local tweenWrong1 = TweenService:Create(frame, TweenInfo.new(0.05), {Position = UDim2.new(0.52,0,0.5,0)})
        local tweenWrong2 = TweenService:Create(frame, TweenInfo.new(0.05), {Position = UDim2.new(0.48,0,0.5,0)})
        tweenWrong1:Play()
        tweenWrong1.Completed:Connect(function()
            tweenWrong2:Play()
        end)
    end
end)
