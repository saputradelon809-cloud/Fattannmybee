-- Arunika CP Tool v15.3 (Debug Mode)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local hrp, humanoid

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "ArunikaDebug"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local info = Instance.new("TextLabel", frame)
info.Size = UDim2.new(1, 0, 0, 50)
info.Position = UDim2.new(0,0,0,0)
info.Text = "🔎 Debug Info"
info.TextColor3 = Color3.new(1,1,1)
info.BackgroundTransparency = 1

local btnCheck = Instance.new("TextButton", frame)
btnCheck.Size = UDim2.new(1, -20, 0, 40)
btnCheck.Position = UDim2.new(0, 10, 0, 60)
btnCheck.Text = "🔍 Cek Checkpoints"
btnCheck.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnCheck.TextColor3 = Color3.new(1,1,1)

local btnTP = Instance.new("TextButton", frame)
btnTP.Size = UDim2.new(1, -20, 0, 40)
btnTP.Position = UDim2.new(0, 10, 0, 110)
btnTP.Text = "⚡ TP ke CP1"
btnTP.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnTP.TextColor3 = Color3.new(1,1,1)

-- fungsi cek CP
local function getCheckpoints()
    local cps = {}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("cp") then
            table.insert(cps, obj)
        end
    end
    return cps
end

-- setup character
local function setupChar(char)
    hrp = char:WaitForChild("HumanoidRootPart", 5)
    humanoid = char:WaitForChild("Humanoid", 5)
end
if player.Character then setupChar(player.Character) end
player.CharacterAdded:Connect(setupChar)

-- button cek
btnCheck.MouseButton1Click:Connect(function()
    local cps = getCheckpoints()
    if #cps == 0 then
        info.Text = "❌ Tidak ada CP ditemukan!"
    else
        local txt = "✅ CP Ditemukan: "..#cps.."\n"
        for i,cp in ipairs(cps) do
            txt = txt..i..": "..cp.Name.." ("..tostring(cp.Position)..")\n"
            if i >= 5 then -- batasi biar nggak kepanjangan
                txt = txt.."..."
                break
            end
        end
        info.Text = txt
    end
end)

-- button TP
btnTP.MouseButton1Click:Connect(function()
    local cps = getCheckpoints()
    if #cps > 0 and hrp then
        hrp.CFrame = cps[1].CFrame + Vector3.new(0,5,0)
        info.Text = "⚡ Teleport ke "..cps[1].Name
    else
        info.Text = "❌ Gagal TP (CP/HRP hilang)"
    end
end)
