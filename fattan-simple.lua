-- FATTAN HUB DELUXE (Blue Theme) - All-in-one Local GUI
-- Loading screen -> Elegant blue box UI -> features: Fly, ESP, Teleport, WalkFling, Freeze (visual),
-- Delete / Restore (visual), Admin Logo (local), Contact info.
-- All features are LOCAL (client-side visual / player-only effects).

-- -------------- Services & Player --------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- -------------- Config / Password --------------
local PASSWORD = "FATTANGANTENG"
-- If you want the script to prompt for password via the GUI, set this to nil and follow GUI prompt.
-- For quick testing, set inputPassword equal to PASSWORD below.
local inputPassword = PASSWORD

-- -------------- Helper: Notifications (custom small toast) --------------
local function toast(parent, title, text, duration)
	local dur = duration or 3
	local gui = Instance.new("ScreenGui", parent)
	gui.Name = "FattanToast"
	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(0, 300, 0, 50)
	frame.Position = UDim2.new(1, -320, 0, 20)
	frame.BackgroundColor3 = Color3.fromRGB(10, 30, 60)
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0,0)

	local t = Instance.new("TextLabel", frame)
	t.Size = UDim2.new(1, -12, 1, -12)
	t.Position = UDim2.new(0, 6, 0, 6)
	t.BackgroundTransparency = 1
	t.Text = ("[%s] %s"):format(title, text)
	t.TextWrapped = true
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextColor3 = Color3.fromRGB(220, 240, 255)
	t.Font = Enum.Font.Gotham
	t.TextSize = 14

	spawn(function()
		wait(dur)
		gui:Destroy()
	end)
end

local function notify(title, text)
	-- use SetCore as well for platform toast if available
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title = title; Text = text; Duration = 3})
	end)
	toast(playerGui, title, text, 3)
end

-- -------------- Loading Screen --------------
do
	local loadingGui = Instance.new("ScreenGui", playerGui)
	loadingGui.Name = "FattanLoading"

	local bg = Instance.new("Frame", loadingGui)
	bg.Size = UDim2.new(1,0,1,0)
	bg.BackgroundColor3 = Color3.fromRGB(12, 20, 40)

	local title = Instance.new("TextLabel", bg)
	title.Size = UDim2.new(1,0,0,120)
	title.Position = UDim2.new(0,0,0.38,0)
	title.BackgroundTransparency = 1
	title.Text = "FATTANHUBSCRIPT"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 44
	title.TextColor3 = Color3.fromRGB(170, 220, 255)
	title.TextStrokeTransparency = 0.7

	local barBG = Instance.new("Frame", bg)
	barBG.Size = UDim2.new(0.5,0,0,18)
	barBG.Position = UDim2.new(0.25,0,0.6,0)
	barBG.BackgroundColor3 = Color3.fromRGB(20,40,70)
	barBG.BorderSizePixel = 0

	local bar = Instance.new("Frame", barBG)
	bar.Size = UDim2.new(0,0,1,0)
	bar.BackgroundColor3 = Color3.fromRGB(120,200,255)
	bar.BorderSizePixel = 0

	-- animate
	for i = 1, 100 do
		bar.Size = UDim2.new(i/100,0,1,0)
		wait(0.015)
	end
	wait(0.25)
	loadingGui:Destroy()
end

-- -------------- Main GUI: box style (blue light/dark) --------------
local GUI = Instance.new("ScreenGui", playerGui)
GUI.Name = "FattanHubDeluxe_Blue"

local main = Instance.new("Frame", GUI)
main.Name = "MainFrame"
main.Size = UDim2.new(0, 360, 0, 480)
main.Position = UDim2.new(0.05,0,0.12,0)
main.BackgroundColor3 = Color3.fromRGB(6, 30, 60) -- dark blue
main.BorderSizePixel = 0
main.Active = true
main.ZIndex = 2

-- draggable behaviour (mouse)
local dragging, dragInput, dragStart, startPos
main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
main.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- header
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1,0,0,56)
header.BackgroundColor3 = Color3.fromRGB(20, 110, 170) -- bluish
header.BorderSizePixel = 0

local headerText = Instance.new("TextLabel", header)
headerText.Size = UDim2.new(1,0,1,0)
headerText.BackgroundTransparency = 1
headerText.Text = "🌊 FATTAN HUB DELUXE"
headerText.Font = Enum.Font.GothamBold
headerText.TextSize = 20
headerText.TextColor3 = Color3.fromRGB(230, 250, 255)

-- content area
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,-12,1,-120)
content.Position = UDim2.new(0,6,0,66)
content.BackgroundTransparency = 1
content.ClipsDescendants = true

local UIList = Instance.new("UIListLayout", content)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0,8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- small helper to make labeled button row
local function makeRow(titleText)
	local row = Instance.new("Frame", content)
	row.Size = UDim2.new(1,-10,0,42)
	row.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", row)
	label.Size = UDim2.new(0.55,0,1,0)
	label.Position = UDim2.new(0,4,0,0)
	label.BackgroundTransparency = 1
	label.Text = titleText
	label.Font = Enum.Font.Gotham
	label.TextSize = 16
	label.TextColor3 = Color3.fromRGB(200, 230, 255)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local holder = Instance.new("Frame", row)
	holder.Size = UDim2.new(0.43, -8, 1, 0)
	holder.Position = UDim2.new(0.57,0,0,0)
	holder.BackgroundTransparency = 1

	return row, label, holder
end

-- small helper to create toggle button style
local function createToggle(parent, initial)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(1,0,1,0)
	btn.BackgroundColor3 = initial and Color3.fromRGB(120,200,255) or Color3.fromRGB(60,90,120)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(12,20,30)
	btn.Text = initial and "ON" or "OFF"
	return btn
end

-- -------------- Feature variables --------------
-- Fly
local flying = false
local flySpeed = 1 -- default 1
local flyMax = 100
local flyGyro = Instance.new("BodyGyro")
local flyVel = Instance.new("BodyVelocity")

-- ESP
local espEnabled = false

-- WalkFling
local flingEnabled = false
local flingObj = nil

-- Delete / Restore
local deleteMode = false
local deletedParts = {}

-- Admin Logo
local adminLogo = false

-- -------------- Rows / Controls --------------

-- Movement header label
local r0, _, _ = makeRow("MOVEMENT")
local sep = Instance.new("Frame", r0)
sep.Size = UDim2.new(1,0,0,2)
sep.Position = UDim2.new(0,0,1, -2)
sep.BackgroundColor3 = Color3.fromRGB(10,70,120)
sep.BorderSizePixel = 0

-- Fly row (toggle + - + display)
local r1, lab1, holder1 = makeRow("Fly (toggle)")
local flyToggle = createToggle(holder1, false)
flyToggle.MouseButton1Click:Connect(function()
	if flying then
		-- stop
		flyGyro.Parent = nil; flyVel.Parent = nil; flying = false
		flyToggle.BackgroundColor3 = Color3.fromRGB(60,90,120); flyToggle.Text = "OFF"
		notify("Fly","OFF")
	else
		-- start
		flyGyro.Parent = character:FindFirstChild("HumanoidRootPart") or hrp
		flyVel.Parent = character:FindFirstChild("HumanoidRootPart") or hrp
		flyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
		flyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
		flying = true
		flyToggle.BackgroundColor3 = Color3.fromRGB(120,200,255); flyToggle.Text = "ON"
		notify("Fly","ON (Speed: "..flySpeed..")")
	end
end)

-- Fly speed controls row
local r1s, _, holder1s = makeRow("Fly Speed")
local minusBtn = Instance.new("TextButton", holder1s)
minusBtn.Size = UDim2.new(0.24,0,1,0)
minusBtn.Position = UDim2.new(0,0,0,0)
minusBtn.Text = " - "
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 18
minusBtn.BackgroundColor3 = Color3.fromRGB(40,70,100)
minusBtn.TextColor3 = Color3.fromRGB(220,240,255)
minusBtn.BorderSizePixel = 0

local speedLabel = Instance.new("TextLabel", holder1s)
speedLabel.Size = UDim2.new(0.5,0,1,0)
speedLabel.Position = UDim2.new(0.26,0,0,0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = tostring(flySpeed)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 16
speedLabel.TextColor3 = Color3.fromRGB(220,240,255)

local plusBtn = Instance.new("TextButton", holder1s)
plusBtn.Size = UDim2.new(0.24,0,1,0)
plusBtn.Position = UDim2.new(0.76,0,0,0)
plusBtn.Text = " + "
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 18
plusBtn.BackgroundColor3 = Color3.fromRGB(40,70,100)
plusBtn.TextColor3 = Color3.fromRGB(220,240,255)
plusBtn.BorderSizePixel = 0

minusBtn.MouseButton1Click:Connect(function()
	if flySpeed > 1 then
		flySpeed = flySpeed - 1
		speedLabel.Text = tostring(flySpeed)
		notify("Fly Speed", flySpeed)
	end
end)
plusBtn.MouseButton1Click:Connect(function()
	if flySpeed < flyMax then
		flySpeed = flySpeed + 1
		speedLabel.Text = tostring(flySpeed)
		notify("Fly Speed", flySpeed)
	end
end)

-- Movement controls: Teleport
local r2, lab2, holder2 = makeRow("Teleport to Player")
local tpBox = Instance.new("TextBox", holder2)
tpBox.Size = UDim2.new(1,0,1,0)
tpBox.ClearTextOnFocus = true
tpBox.Text = "TargetName"
tpBox.Font = Enum.Font.Gotham
tpBox.TextSize = 14
tpBox.TextColor3 = Color3.fromRGB(220,240,255)
tpBox.BackgroundColor3 = Color3.fromRGB(20,50,80)
tpBox.BorderSizePixel = 0
tpBox.FocusLost:Connect(function(enter)
	if enter and tpBox.Text ~= "" and tpBox.Text ~= "TargetName" then
		local t = Players:FindFirstChild(tpBox.Text)
		if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
			local targetHRP = t.Character.HumanoidRootPart
			hrp.CFrame = targetHRP.CFrame + Vector3.new(0,5,0)
			notify("Teleport","Teleported to "..t.Name)
		else
			notify("Teleport","Player not found or not spawned")
		end
		tpBox.Text = "TargetName"
	end
end)

-- WalkFling toggle
local r3, lab3, holder3 = makeRow("WalkFling (toggle)")
local flingBtn = createToggle(holder3, false)
flingBtn.MouseButton1Click:Connect(function()
	if flingEnabled then
		if flingObj then flingObj:Destroy(); flingObj = nil end
		flingEnabled = false
		flingBtn.BackgroundColor3 = Color3.fromRGB(60,90,120); flingBtn.Text = "OFF"
		notify("WalkFling","OFF")
	else
		local hrpLocal = character:FindFirstChild("HumanoidRootPart") or hrp
		flingObj = Instance.new("BodyAngularVelocity")
		flingObj.AngularVelocity = Vector3.new(9e9,9e9,9e9)
		flingObj.MaxTorque = Vector3.new(9e9,9e9,9e9)
		flingObj.P = 10000
		flingObj.Parent = hrpLocal
		flingEnabled = true
		flingBtn.BackgroundColor3 = Color3.fromRGB(120,200,255); flingBtn.Text = "ON"
		notify("WalkFling","ON")
	end
end)

-- Separator label for Visual
local rsep, _, _ = makeRow("VISUAL")

-- ESP toggle
local r4, lab4, holder4 = makeRow("ESP (toggle)")
local espBtn = createToggle(holder4, false)
espBtn.MouseButton1Click:Connect(function()
	if espEnabled then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("FattanESP") then
				p.Character:FindFirstChild("FattanESP"):Destroy()
			end
		end
		espEnabled = false
		espBtn.BackgroundColor3 = Color3.fromRGB(60,90,120); espBtn.Text = "OFF"
		notify("ESP","OFF")
	else
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character and not p.Character:FindFirstChild("FattanESP") then
				local hl = Instance.new("Highlight")
				hl.Name = "FattanESP"
				hl.FillColor = Color3.fromRGB(120,200,255)
				hl.OutlineColor = Color3.fromRGB(220,240,255)
				hl.Adornee = p.Character
				hl.Parent = p.Character
			end
		end
		Players.PlayerAdded:Connect(function(p)
			p.CharacterAdded:Connect(function(c)
				if espEnabled and c and not c:FindFirstChild("FattanESP") then
					local hl = Instance.new("Highlight")
					hl.Name = "FattanESP"
					hl.FillColor = Color3.fromRGB(120,200,255)
					hl.OutlineColor = Color3.fromRGB(220,240,255)
					hl.Adornee = c
					hl.Parent = c
				end
			end)
		end)
		espEnabled = true
		espBtn.BackgroundColor3 = Color3.fromRGB(120,200,255); espBtn.Text = "ON"
		notify("ESP","ON")
	end
end)

-- Admin Logo toggle
local r5, lab5, holder5 = makeRow("Admin Logo (toggle)")
local adminBtn = createToggle(holder5, false)
local function applyAdminTo(pl)
	if pl and pl.Character and pl.Character:FindFirstChild("Head") and not pl.Character.Head:FindFirstChild("FattanAdminLogo") then
		local head = pl.Character.Head
		local bb = Instance.new("BillboardGui", head)
		bb.Name = "FattanAdminLogo"
		bb.Size = UDim2.new(0,140,0,40)
		bb.StudsOffset = Vector3.new(0, 2.6, 0)
		bb.AlwaysOnTop = true
		local t = Instance.new("TextLabel", bb)
		t.Size = UDim2.new(1,0,1,0)
		t.BackgroundTransparency = 1
		t.Text = "👑 ADMIN"
		t.Font = Enum.Font.GothamBold
		t.TextSize = 16
		t.TextColor3 = Color3.fromRGB(255, 230, 160)
	end
end
local function removeAdminFrom(pl)
	if pl and pl.Character and pl.Character:FindFirstChild("Head") and pl.Character.Head:FindFirstChild("FattanAdminLogo") then
		pl.Character.Head.FattanAdminLogo:Destroy()
	end
end
adminBtn.MouseButton1Click:Connect(function()
	if adminLogo then
		removeAdminFrom(player)
		adminLogo = false
		adminBtn.BackgroundColor3 = Color3.fromRGB(60,90,120); adminBtn.Text = "OFF"
		notify("Admin Logo","OFF")
	else
		applyAdminTo(player)
		adminLogo = true
		adminBtn.BackgroundColor3 = Color3.fromRGB(120,200,255); adminBtn.Text = "ON"
		notify("Admin Logo","ON")
	end
end)

-- Separator label for Player tools
local rsep2, _, _ = makeRow("PLAYER")

-- Freeze / Unfreeze rows
local r6, lab6, holder6 = makeRow("Freeze Player (visual)")
local freezeBox = Instance.new("TextBox", holder6)
freezeBox.Size = UDim2.new(0.72,0,1,0)
freezeBox.Position = UDim2.new(0,0,0,0)
freezeBox.Text = "TargetName"
freezeBox.ClearTextOnFocus = true
freezeBox.BackgroundColor3 = Color3.fromRGB(20,50,80)
freezeBox.TextColor3 = Color3.fromRGB(220,240,255)
freezeBox.Font = Enum.Font.Gotham

local freezeBtn = Instance.new("TextButton", holder6)
freezeBtn.Size = UDim2.new(0.28,0,1,0)
freezeBtn.Position = UDim2.new(0.72,4,0,0)
freezeBtn.Text = "Freeze"
freezeBtn.Font = Enum.Font.GothamBold
freezeBtn.BackgroundColor3 = Color3.fromRGB(40,80,120)
freezeBtn.TextColor3 = Color3.fromRGB(220,240,255)
freezeBtn.MouseButton1Click:Connect(function()
	local name = freezeBox.Text
	if name and name ~= "" and name ~= "TargetName" then
		local t = Players:FindFirstChild(name)
		if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
			local hrpTarget = t.Character.HumanoidRootPart
			if hrpTarget:FindFirstChild("IceBox") then hrpTarget.IceBox:Destroy() end
			local ice = Instance.new("Part", hrpTarget)
			ice.Name = "IceBox"
			ice.Size = Vector3.new(6,8,6)
			ice.Anchored = false
			ice.CanCollide = false
			ice.Transparency = 0.5
			ice.Color = Color3.fromRGB(140,230,255)
			ice.Material = Enum.Material.Ice
			local weld = Instance.new("WeldConstraint", hrpTarget)
			weld.Part0 = hrpTarget
			weld.Part1 = ice
			if t.Character:FindFirstChild("Humanoid") then
				pcall(function() t.Character.Humanoid.WalkSpeed = 0 end)
			end
			notify("Freeze", "Frozen "..t.Name.." (visual)")
		else notify("Freeze","Player not found") end
	end
end)

local r7, lab7, holder7 = makeRow("Unfreeze Player (visual)")
local unfreezeBox = Instance.new("TextBox", holder7)
unfreezeBox.Size = UDim2.new(0.72,0,1,0)
unfreezeBox.Position = UDim2.new(0,0,0,0)
unfreezeBox.Text = "TargetName"
unfreezeBox.ClearTextOnFocus = true
unfreezeBox.BackgroundColor3 = Color3.fromRGB(20,50,80)
unfreezeBox.TextColor3 = Color3.fromRGB(220,240,255)
unfreezeBox.Font = Enum.Font.Gotham

local unfreezeBtn = Instance.new("TextButton", holder7)
unfreezeBtn.Size = UDim2.new(0.28,0,1,0)
unfreezeBtn.Position = UDim2.new(0.72,4,0,0)
unfreezeBtn.Text = "Unfreeze"
unfreezeBtn.Font = Enum.Font.GothamBold
unfreezeBtn.BackgroundColor3 = Color3.fromRGB(40,80,120)
unfreezeBtn.TextColor3 = Color3.fromRGB(220,240,255)
unfreezeBtn.MouseButton1Click:Connect(function()
	local name = unfreezeBox.Text
	if name and name ~= "" and name ~= "TargetName" then
		local t = Players:FindFirstChild(name)
		if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
			local hrpTarget = t.Character.HumanoidRootPart
			if hrpTarget:FindFirstChild("IceBox") then hrpTarget.IceBox:Destroy() end
			if t.Character:FindFirstChild("Humanoid") then
				pcall(function() t.Character.Humanoid.WalkSpeed = 16 end)
			end
			notify("Unfreeze", "Unfrozen "..t.Name.." (visual)")
		else notify("Unfreeze","Player not found") end
	end
end)

-- Separator label for World
local rsep3, _, _ = makeRow("WORLD")

-- Delete Part toggle + Restore button
local r8, lab8, holder8 = makeRow("Delete Part (click to hide visual)")
local delToggle = createToggle(holder8, false)
delToggle.MouseButton1Click:Connect(function()
	if deleteMode then
		deleteMode = false
		delToggle.BackgroundColor3 = Color3.fromRGB(60,90,120); delToggle.Text = "OFF"
		notify("Delete Mode","OFF")
	else
		deleteMode = true
		delToggle.BackgroundColor3 = Color3.fromRGB(120,200,255); delToggle.Text = "ON"
		notify("Delete Mode","ON - click parts to hide (visual)")
	end
end)

local r9, lab9, holder9 = makeRow("Restore Deleted Parts")
local restoreBtn = Instance.new("TextButton", holder9)
restoreBtn.Size = UDim2.new(1,0,1,0)
restoreBtn.Text = "Restore"
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.BackgroundColor3 = Color3.fromRGB(40,80,120)
restoreBtn.TextColor3 = Color3.fromRGB(220,240,255)
restoreBtn.MouseButton1Click:Connect(function()
	for i, part in ipairs(deletedParts) do
		if part and not part.Parent then
			pcall(function() part.Parent = workspace end)
		end
	end
	deletedParts = {}
	notify("Restore", "All visual-deleted parts restored")
end)

-- Click handler for delete mode
local mouse = player:GetMouse()
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if deleteMode and input.UserInputType == Enum.UserInputType.MouseButton1 then
		if mouse.Target then
			table.insert(deletedParts, mouse.Target)
			mouse.Target.Parent = nil -- hide (visual)
			notify("Delete", "Part hidden (visual)")
		end
	end
end)

-- Contact footer
local contact = Instance.new("TextLabel", main)
contact.Size = UDim2.new(1,0,0,28)
contact.Position = UDim2.new(0,0,1,-28)
contact.BackgroundColor3 = Color3.fromRGB(10, 30, 50)
contact.Text = "Contact: 085708378509"
contact.TextColor3 = Color3.fromRGB(190,220,255)
contact.Font = Enum.Font.Gotham
contact.TextSize = 14
contact.TextTransparency = 0
contact.BorderSizePixel = 0

-- -------------- Runtime: Fly update --------------
RunService.RenderStepped:Connect(function()
	-- set velocity when flying
	if flying and flyVel.Parent then
		local cam = workspace.CurrentCamera
		local dir = Vector3.new()
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
		flyGyro.CFrame = workspace.CurrentCamera.CFrame
		flyVel.Velocity = dir.Unit * flySpeed
		-- when no input, keep small upward to avoid falling
		if dir.Magnitude == 0 then
			flyVel.Velocity = Vector3.new(0, 0, 0)
		end
	end
end)

-- Keep admin logo on respawn if active
Players.LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart", 5)
	hrp = char:WaitForChild("HumanoidRootPart")
	if adminLogo then
		applyAdminTo(player) -- function declared above in closure
	end
end)

-- Final notify
notify("Fattan Hub", "Fattan Hub Deluxe Ready — UI: Blue Theme")
