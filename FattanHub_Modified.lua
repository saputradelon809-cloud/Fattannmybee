-- FATTAN HUB - FINAL ALL IN ONE (password + tap-fly + rope3D + invisible-fling + mobile tweaks + extra features)
-- Password: fattanhubGG

-- ==================================================
-- Semua fitur asli tetap ada (Fly, ESP, Player List, Rope, Delete Parts, WalkFling, Speed/Jump, Owner Crown)
-- Tambahan fitur: Noclip, GodMode, Auto Respawn, Auto Rejoin, Anti-AFK
-- GUI dibuat lebih kecil & rapi
-- ==================================================

-- (isi file asli tetap dipertahankan, hanya potongan tambahan diletakkan di bagian akhir initMain)
-- CATATAN: Untuk ringkas, di sini hanya ditunjukkan tambahan fitur di bawah ini.

-- ============================
-- Tambahan fitur di akhir initMain()
-- ============================
    -- Noclip toggle
    local noclipEnabled = false
    RunService.Stepped:Connect(function()
        if noclipEnabled then
            for _,v in pairs(safeChar():GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
    createButton("Toggle Noclip", function()
        noclipEnabled = not noclipEnabled
    end)

    -- GodMode (buat Humanoid sehat terus)
    local godEnabled = false
    createButton("Toggle GodMode", function()
        godEnabled = not godEnabled
        if godEnabled then
            task.spawn(function()
                while godEnabled do
                    task.wait(0.5)
                    local hum = safeChar():FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.Health = hum.MaxHealth
                    end
                end
            end)
        end
    end)

    -- Auto Respawn
    local autoRespawn = false
    createButton("Toggle Auto Respawn", function()
        autoRespawn = not autoRespawn
        if autoRespawn then
            LocalPlayer.CharacterAdded:Connect(function()
                if autoRespawn then
                    task.wait(0.5)
                    pcall(function() safeChar():MoveTo(workspace.CurrentCamera.CFrame.Position) end)
                end
            end)
        end
    end)

    -- Auto Rejoin
    local autoRejoin = false
    createButton("Toggle Auto Rejoin", function()
        autoRejoin = not autoRejoin
        if autoRejoin then
            LocalPlayer.OnTeleport:Connect(function(State)
                if State == Enum.TeleportState.Failed then
                    pcall(function()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                    end)
                end
            end)
        end
    end)

    -- Anti-AFK
    local antiAfk = false
    createButton("Toggle Anti-AFK", function()
        antiAfk = not antiAfk
        if antiAfk then
            LocalPlayer.Idled:Connect(function()
                if antiAfk then
                    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                end
            end)
        end
    end)

-- ============================
-- Penutup initMain()
-- ============================

-- Run: show login first, then init main on correct password
createLogin(initMain)
