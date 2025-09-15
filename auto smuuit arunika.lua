-- AutoSummitDelta_Mobile.lua
-- Gunakan hanya di game Roblox milikmu sendiri.
-- Server + Client + GUI Mobile

-- ======= SERVER SIDE =======
if game:GetService("RunService"):IsServer() then
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")

    -- RemoteEvent
    local folder = ReplicatedStorage:FindFirstChild("AutoSummit") 
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "AutoSummit"
        folder.Parent = ReplicatedStorage
    end
    local requestEvent = folder:FindFirstChild("Request") or Instance.new("RemoteEvent", folder)
    requestEvent.Name = "Request"

    -- KOORDINAT DELTA
    local checkpoints = {
        Vector3.new(528, 153, -181), -- safezone 1
        Vector3.new(719, 113, 233),  -- pos 1
        Vector3.new(736, 121, 585),  -- pos 2
        Vector3.new(768, 299, 731),  -- pos 3
        Vector3.new(892, 329, 1072), -- pos 4
        Vector3.new(1523, 345, 1085),-- safezone 2
        Vector3.new(1473, 421, 500), -- pos 5
        Vector3.new(1509, 421, 56),  -- pos 6
        Vector3.new(2149, 621, 187)  -- summit
    }

    local tweenTimePerSegment = 0.8
    local waitAtCheckpoint = 2
    local distanceThreshold = 6

    local function getHRP(player)
        local char = player.Character or player.CharacterAdded:Wait()
        return char:FindFirstChild("HumanoidRootPart")
    end

    local function tweenTo(hrp, pos)
        local targetCFrame = CFrame.new(pos) * CFrame.new(0, 3, 0)
        local info = TweenInfo.new(tweenTimePerSegment, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(hrp, info, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end

    requestEvent.OnServerEvent:Connect(function(player, action)
        if action ~= "start" then return end
        local hrp = getHRP(player)
        if not hrp then return end

        for i, pos in ipairs(checkpoints) do
            tweenTo(hrp, pos)
            local tries = 0
            while hrp and (hrp.Position - pos).Magnitude > distanceThreshold and tries < 6 do
                task.wait(0.25)
                tries += 1
            end
            task.wait(waitAtCheckpoint)
            if i == #checkpoints then
                player:LoadCharacter() -- respawn saat summit
            end
        end
    end)

    print("[AutoSummitDelta] Server ready")
end

-- ======= CLIENT SIDE + GUI MOBILE =======
if game:GetService("RunService"):IsClient() then
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local folder = ReplicatedStorage:WaitForChild("AutoSummit")
    local requestEvent = folder:WaitForChild("Request")

    -- Buat GUI Mobile
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoSummitGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 160, 0, 50) -- lebih besar untuk mobile
    button.Position = UDim2.new(0.75, 0, 0.85, 0) -- kanan bawah
    button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.Text = "🚀 Auto Summit"
    button.Parent = screenGui
    button.Visible = true
    button.AutoButtonColor = true
    button.BorderSizePixel = 2

    -- efek klik
    button.MouseButton1Click:Connect(function()
        button.Text = "⏳ Running..."
        requestEvent:FireServer("start")
        task.wait(2)
        button.Text = "🚀 Auto Summit"
    end)

    print("[AutoSummitDelta] Client ready - Mobile GUI dibuat")
end
