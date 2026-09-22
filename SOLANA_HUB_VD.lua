-- SOLANA HUB | ZyronX UI (embedded)
print("[SOLANA HUB] START")
warn("[SOLANA HUB] START")
local function _solanaParent()
	local p
	pcall(function()
		if gethui then p = gethui() end
	end)
	if p then return p end
	pcall(function()
		p = game:GetService("CoreGui")
	end)
	if p then return p end
	local plr = game:GetService("Players").LocalPlayer
	if not plr then
		pcall(function()
			game:GetService("Players"):GetPropertyChangedSignal("LocalPlayer"):Wait()
		end)
		plr = game:GetService("Players").LocalPlayer
	end
	if plr then
		p = plr:FindFirstChildOfClass("PlayerGui") or plr:WaitForChild("PlayerGui", 8)
	end
	return p
end

do
	local ok, err = pcall(function()
		local parent = _solanaParent()
		if not parent then
			error("no gui parent")
		end
		local old = parent:FindFirstChild("SolanaHub_Boot")
		if old then
			old:Destroy()
		end
		local sg = Instance.new("ScreenGui")
		sg.Name = "SolanaHub_Boot"
		sg.ResetOnSpawn = false
		sg.IgnoreGuiInset = true
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		sg.DisplayOrder = 999999
		sg.Parent = parent
		local f = Instance.new("Frame")
		f.Name = "Card"
		f.Size = UDim2.fromOffset(280, 72)
		f.Position = UDim2.new(0.5, -140, 0.08, 0)
		f.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		f.BorderSizePixel = 0
		f.Parent = sg
		Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
		local t = Instance.new("TextLabel")
		t.Name = "Msg"
		t.BackgroundTransparency = 1
		t.Size = UDim2.new(1, -16, 1, -16)
		t.Position = UDim2.fromOffset(8, 8)
		t.Font = Enum.Font.GothamBold
		t.TextSize = 14
		t.TextColor3 = Color3.fromRGB(244, 244, 245)
		t.TextWrapped = true
		t.Text = "SOLANA HUB — loading UI"
		t.Parent = f
		pcall(function()
			getgenv()._SolanaBoot = sg
		end)
		_G._SolanaBoot = sg
	end)
	if not ok then
		warn("[SOLANA HUB] boot gui failed: ", err)
	end
end

local Library = (function()
-- // ZyronX UI Library (Core Engine) - Optimized for Zero Lag Loops

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui
pcall(function() CoreGui = game:GetService("CoreGui") end)
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local Library = {
    WhitelistedUsers = {} 
}

-- // Utility: File System Mock Overrides
local _isfolder = isfolder or function() return true end
local _makefolder = makefolder or function() end
local _writefile = writefile or function(path, data) warn("File saving not supported on this executor.") end
local _readfile = readfile or function() return "{}" end
local _listfiles = listfiles or function() return {} end
local _delfile = delfile or function() warn("File deletion not supported.") end

-- // Utility: Safe Clipboard Copy
local function SafeCopyToClipboard(text)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    else
        warn("Clipboard copying is not supported on your current executor.")
    end
end

-- // Utility: Instance Creator
local function Create(className, properties)
    local instance = Instance.new(className)
    
    if className == "TextBox" then
        instance.Text = ""
    end

    for k, v in pairs(properties or {}) do
        instance[k] = v
    end
    
    if (className == "TextLabel" or className == "TextButton" or className == "TextBox") then
        if properties.TextSize and properties.RichText ~= true then
            instance.TextScaled = true
            local constraint = Instance.new("UITextSizeConstraint")
            constraint.MaxTextSize = properties.TextSize
            constraint.MinTextSize = 6
            constraint.Parent = instance
        end
    end
    
    return instance
end

-- // Utility: Build search index for a card (cached)
local function BuildSearchIndex(card)
    local parts = {}
    for _, desc in ipairs(card:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
            if desc.Text and desc.Text ~= "" then
                table.insert(parts, desc.Text:lower())
            end
        end
    end
    return table.concat(parts, " ")
end

-- // Utility: Smooth Tweening
local function Tween(instance, properties, duration)
    duration = duration or 0.25
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- // Utility: Micro-Interaction Bounce
local function AddBounce(button, scaleFactor)
    scaleFactor = scaleFactor or 0.96
    local scaleObj = button:FindFirstChild("UIScale") or Create("UIScale", {Parent = button, Scale = 1})
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scaleObj, {Scale = scaleFactor}, 0.15)
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scaleObj, {Scale = 1}, 0.15)
        end
    end)
    button.MouseLeave:Connect(function()
        Tween(scaleObj, {Scale = 1}, 0.15)
    end)
end

-- // Utility: Draggable
local function MakeDraggable(topbar, object)
    topbar.Active = true
    object.Active = true
    local dragging, dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.08)
        end
    end)
end

local AccentColor = Color3.fromRGB(224, 32, 48)
local BackgroundColor = Color3.fromRGB(0, 0, 0)
local CardColor = Color3.fromRGB(12, 12, 12)
local HoverColor = Color3.fromRGB(22, 22, 22)
local TextColor = Color3.fromRGB(255, 255, 255)
local SubTextColor = Color3.fromRGB(140, 140, 140)

-- // Global Notification API
local GlobalNotifContainer

function Library:Notify(options)
    if not GlobalNotifContainer then return end
    local title = options.Title or "Notification"
    local desc = options.Description or "Information updated."
    local duration = options.Duration or 3

    local Notif = Create("Frame", {Parent = GlobalNotifContainer, BackgroundColor3 = Color3.fromRGB(8, 8, 8), Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, ZIndex = 201, ClipsDescendants = true})
    Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 8)})
    local Stroke = Create("UIStroke", {Parent = Notif, Color = AccentColor, Thickness = 1.5, Transparency = 1})

    local TitleText = Create("TextLabel", {Parent = Notif, Text = title, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 10), Size = UDim2.new(1, -24, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})
    local DescText = Create("TextLabel", {Parent = Notif, Text = desc, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SubTextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 26), Size = UDim2.new(1, -24, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})

    Tween(Notif, {BackgroundTransparency = 0}, 0.3)
    Tween(Stroke, {Transparency = 0}, 0.3)
    Tween(TitleText, {TextTransparency = 0}, 0.3)
    Tween(DescText, {TextTransparency = 0}, 0.3)

    task.delay(duration, function()
        Tween(Notif, {BackgroundTransparency = 1}, 0.4)
        Tween(Stroke, {Transparency = 1}, 0.4)
        Tween(TitleText, {TextTransparency = 1}, 0.4)
        Tween(DescText, {TextTransparency = 1}, 0.4)
        task.wait(0.4)
        Notif:Destroy()
    end)
end

function Library:CreateWindow(options)
    local hubName = "ZyronX Ui Lib"
    local subText = "Made By Hypol-X"
    local subColor = AccentColor
    local sphTextToggle = false
    local sphWords = "ZX"
    local sphImage = nil
    local topbarLogo = nil
    local logoSize = 24
    local sphIconSize = 20

    if type(options) == "table" then
        hubName = options.Title or hubName
        subText = options.Subtitle or subText
        subColor = options.SubtitleColor or subColor
        
        if options.SphereText ~= nil then
            sphTextToggle = options.SphereText
        end
        if options.SphereWords ~= nil then
            -- Enforce 2-word limit logic
            local raw = tostring(options.SphereWords)
            local wordList = {}
            for w in string.gmatch(raw, "%S+") do wordList[#wordList+1] = w end
            if #wordList > 2 then
                sphWords = wordList[1] .. " " .. wordList[2]
            else
                sphWords = raw
            end
        end
        
        sphImage = options.SphereImage
        topbarLogo = options.Logo
        logoSize = options.LogoSize or 24
        sphIconSize = options.SphereIconSize or 20
    elseif type(options) == "string" then
        hubName = options
    end

    local uniqueID = HttpService:GenerateGUID(false)
    local function getGuiParent()
        local p
        pcall(function() if gethui then p = gethui() end end)
        if p then return p end
        pcall(function() p = CoreGui end)
        if p then return p end
        pcall(function()
            local plr = game:GetService("Players").LocalPlayer
            p = plr and (plr:FindFirstChildOfClass("PlayerGui") or plr:WaitForChild("PlayerGui", 5))
        end)
        return p
    end
    local ScreenGui = Create("ScreenGui", {
        Name = "ZyronX_UI_" .. uniqueID,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999999,
    })
    local _gp = getGuiParent()
    if _gp then
        ScreenGui.Parent = _gp
    else
        ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    local NotifContainer = Create("Frame", {
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 260, 1, -20),
        Position = UDim2.new(1, -280, 0, 10),
        ZIndex = 200,
        Active = false
    })
    Create("UIListLayout", {Parent = NotifContainer, VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)})
    GlobalNotifContainer = NotifContainer

    local function SendPremiumNotification()
        local Notif = Create("Frame", {Parent = NotifContainer, BackgroundColor3 = Color3.fromRGB(8, 8, 8), Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, ZIndex = 201, ClipsDescendants = true})
        Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 8)})
        
        local Stroke = Create("UIStroke", {Parent = Notif, Thickness = 1.5, Transparency = 1})
        local StrokeGrad = Create("UIGradient", {Parent = Stroke, Color = ColorSequence.new(Color3.fromRGB(255, 215, 0), Color3.fromRGB(180, 130, 20)), Rotation = 45})

        local LockIcon = Create("ImageLabel", {Parent = Notif, BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 15, 0.5, -12), Image = "rbxassetid://6031082533", ImageColor3 = Color3.fromRGB(255, 215, 0), ImageTransparency = 1, ZIndex = 202})
        local TitleText = Create("TextLabel", {Parent = Notif, Text = "ACCESS DENIED", Font = Enum.Font.GothamBlack, TextSize = 10, TextColor3 = SubTextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 42, 0, 10), Size = UDim2.new(1, -52, 0, 14), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})
        local DescText = Create("TextLabel", {Parent = Notif, Text = 'This Is For <font color="#FFD700"><b>Whitelisted Users</b></font>', RichText = true, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 42, 0, 26), Size = UDim2.new(1, -60, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})
        
        local Shine = Create("Frame", {Parent = Notif, BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.8, BorderSizePixel = 0, Size = UDim2.new(0, 20, 2, 0), Position = UDim2.new(-0.2, 0, -0.5, 0), Rotation = 25, ZIndex = 203})

        Tween(Notif, {BackgroundTransparency = 0}, 0.3)
        Tween(Stroke, {Transparency = 0}, 0.3)
        Tween(LockIcon, {ImageTransparency = 0}, 0.3)
        Tween(TitleText, {TextTransparency = 0}, 0.3)
        Tween(DescText, {TextTransparency = 0}, 0.3)

        local shineTween = TweenService:Create(Shine, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(1.2, 0, -0.5, 0)})
        task.delay(0.2, function() shineTween:Play() end)

        task.delay(4, function()
            Tween(Notif, {BackgroundTransparency = 1}, 0.4)
            Tween(Stroke, {Transparency = 1}, 0.4)
            Tween(LockIcon, {ImageTransparency = 1}, 0.4)
            Tween(TitleText, {TextTransparency = 1}, 0.4)
            Tween(DescText, {TextTransparency = 1}, 0.4)
            task.wait(0.4)
            Notif:Destroy()
        end)
    end

    local InfoOverlay = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 150, Visible = false, Active = true})
    local InfoCard = Create("Frame", {Parent = InfoOverlay, BackgroundColor3 = Color3.fromRGB(8, 8, 8), Size = UDim2.new(0, 280, 0, 220), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 151, BackgroundTransparency = 1, ClipsDescendants = true})
    Create("UICorner", {Parent = InfoCard, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = InfoCard, Color = AccentColor, Thickness = 1.5, Transparency = 1})
    local InfoScale = Create("UIScale", {Parent = InfoCard, Scale = 0})

    local InfoHeader = Create("Frame", {Parent = InfoCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), ZIndex = 152})
    local InfoTitle = Create("TextLabel", {Parent = InfoHeader, Text = "Feature Info", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -60, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 152})
    local InfoCloseBtn = Create("TextButton", {Parent = InfoHeader, Text = "X", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 32, 1, 0), Position = UDim2.new(1, -32, 0, 0), ZIndex = 152, TextTransparency = 1})
    AddBounce(InfoCloseBtn)

    local InfoScroll = Create("ScrollingFrame", {Parent = InfoCard, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, -60), Position = UDim2.new(0, 20, 0, 50), CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = AccentColor, BorderSizePixel = 0, ZIndex = 152})
    local InfoLayout = Create("UIListLayout", {Parent = InfoScroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
    local InfoDesc = Create("TextLabel", {Parent = InfoScroll, Text = "", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 152, TextTransparency = 1})
    local InfoExampleBox = Create("Frame", {Parent = InfoScroll, BackgroundColor3 = Color3.fromRGB(5, 5, 5), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, ZIndex = 152})
    Create("UICorner", {Parent = InfoExampleBox, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = InfoExampleBox, Color = Color3.fromRGB(30, 30, 30), Thickness = 1})
    local InfoExampleText = Create("TextLabel", {Parent = InfoExampleBox, Text = "", Font = Enum.Font.Code, TextSize = 10, TextColor3 = AccentColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 10), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 152, TextTransparency = 1})
    Create("UIPadding", {Parent = InfoExampleBox, PaddingBottom = UDim.new(0, 10)})

    InfoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() InfoScroll.CanvasSize = UDim2.new(0, 0, 0, InfoLayout.AbsoluteContentSize.Y + 10) end)

    local function OpenInfoWindow(data)
        InfoTitle.Text = data.Title or "Information"
        InfoDesc.Text = data.Description or "No description provided."
        if data.Example then
            InfoExampleText.Text = data.Example
            InfoExampleBox.Visible = true
        else
            InfoExampleBox.Visible = false
        end
        InfoOverlay.Visible = true
        Tween(InfoOverlay, {BackgroundTransparency = 0.4}, 0.3)
        Tween(InfoCard, {BackgroundTransparency = 0}, 0.3)
        Tween(InfoCard:FindFirstChild("UIStroke"), {Transparency = 0.3}, 0.3)
        Tween(InfoScale, {Scale = 1}, 0.3)
        Tween(InfoTitle, {TextTransparency = 0}, 0.3)
        Tween(InfoCloseBtn, {TextTransparency = 0}, 0.3)
        Tween(InfoDesc, {TextTransparency = 0}, 0.3)
        if data.Example then Tween(InfoExampleText, {TextTransparency = 0}, 0.3) end
    end

    InfoCloseBtn.MouseButton1Click:Connect(function()
        Tween(InfoOverlay, {BackgroundTransparency = 1}, 0.3)
        Tween(InfoCard, {BackgroundTransparency = 1}, 0.3)
        Tween(InfoCard:FindFirstChild("UIStroke"), {Transparency = 1}, 0.3)
        Tween(InfoScale, {Scale = 0}, 0.3)
        Tween(InfoTitle, {TextTransparency = 1}, 0.3)
        Tween(InfoCloseBtn, {TextTransparency = 1}, 0.3)
        Tween(InfoDesc, {TextTransparency = 1}, 0.3)
        if InfoExampleBox.Visible then Tween(InfoExampleText, {TextTransparency = 1}, 0.3) end
        task.wait(0.3)
        InfoOverlay.Visible = false
    end)

    local function AddInfoIcon(parent, pos, data)
        if not data then return end
        local Btn = Create("TextButton", {Parent = parent, Text = "?", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = SubTextColor, BackgroundColor3 = Color3.fromRGB(22, 22, 22), Size = UDim2.new(0, 16, 0, 16), Position = pos, AutoButtonColor = false, ZIndex = 5})
        Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(1, 0)})
        AddBounce(Btn)
        Btn.MouseEnter:Connect(function() Tween(Btn, {TextColor3 = TextColor, BackgroundColor3 = AccentColor}, 0.2) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, {TextColor3 = SubTextColor, BackgroundColor3 = Color3.fromRGB(22, 22, 22)}, 0.2) end)
        Btn.MouseButton1Click:Connect(function() OpenInfoWindow(data) end)
    end

    local MainFrame = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = BackgroundColor, Size = UDim2.new(0, 440, 0, 320), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ClipsDescendants = true, BackgroundTransparency = 1, Active = true})
    local MainScale = Create("UIScale", {Parent = MainFrame, Scale = 1})
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = MainFrame, Color = Color3.fromRGB(30, 30, 30), Thickness = 1})
    MainScale.Scale = 1
    MainFrame.BackgroundTransparency = 0
    MainFrame.Visible = true
    pcall(function()
        Tween(MainScale, {Scale = 1}, 0.35)
        Tween(MainFrame, {BackgroundTransparency = 0}, 0.35)
    end)

    -- // CORE ENGINE ADDITION: Floating Bottom Bar Natively Attached to ScreenGui
    
    -- The Drag Hitbox (Invisible but large for easy grabbing)
    local BottomDragHitbox = Create("Frame", {
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 260, 0, 24),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 145,
        Active = true
    })

    -- The Visible Modern Bar (Sleeker, pill-shaped, dark gray outline)
    local FloatingBottomBar = Create("Frame", {
        Parent = BottomDragHitbox,
        BackgroundColor3 = CardColor,
        BackgroundTransparency = 0,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0.5, -3),
        ZIndex = 146
    })
    Create("UICorner", {Parent = FloatingBottomBar, CornerRadius = UDim.new(1, 0)})
    local BottomBarStroke = Create("UIStroke", {
        Parent = FloatingBottomBar, 
        Color = Color3.fromRGB(28, 28, 28), 
        Thickness = 1.2, 
        Transparency = 0
    })

    -- Drags MainFrame when the larger invisible hitbox is pulled. Sync is perfect.
    MakeDraggable(BottomDragHitbox, MainFrame)

    RunService.RenderStepped:Connect(function()
        if MainFrame and MainFrame.Visible then
            BottomDragHitbox.Visible = true
            local currentScale = MainScale.Scale
            local frameHeight = 320 * currentScale
            local frameWidth = 440 * currentScale
            
            BottomDragHitbox.Position = UDim2.new(
                MainFrame.Position.X.Scale,
                MainFrame.Position.X.Offset,
                MainFrame.Position.Y.Scale,
                MainFrame.Position.Y.Offset + (frameHeight / 2) + 20
            )
            BottomDragHitbox.Size = UDim2.new(0, frameWidth * 0.6, 0, 30 * currentScale)
            FloatingBottomBar.Size = UDim2.new(1, 0, 0, 6 * currentScale)
            FloatingBottomBar.Position = UDim2.new(0, 0, 0.5, -(3 * currentScale))
        else
            BottomDragHitbox.Visible = false
        end
    end)

    local TopBar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = BackgroundColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), Position = UDim2.new(0, 0, 0, 0), Active = true})
    MakeDraggable(TopBar, MainFrame)
    
    local titleOffsetX = 15
    if topbarLogo then
        local TopbarIcon = Create("ImageLabel", {
            Parent = TopBar,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, logoSize, 0, logoSize),
            Position = UDim2.new(0, 8, 0.5, -(logoSize / 2)),
            Image = topbarLogo,
            ScaleType = Enum.ScaleType.Fit
        })
        titleOffsetX = 8 + logoSize + 8
    end

    local TitleContainer = Create("Frame", {Parent = TopBar, BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, titleOffsetX, 0, 0)})
    local Title = Create("TextLabel", {Parent = TitleContainer, Text = hubName, Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 1), Size = UDim2.new(1, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left, RichText = true})
    local Subtitle = Create("TextLabel", {Parent = TitleContainer, Text = subText, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = subColor, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 17), Size = UDim2.new(1, 0, 0, 10), TextXAlignment = Enum.TextXAlignment.Left})

    local SearchBar = Create("Frame", {Parent = TopBar, BackgroundColor3 = CardColor, Size = UDim2.new(0, 100, 0, 22), Position = UDim2.new(1, -135, 0.5, -11)})
    Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 6)})
    local SearchIcon = Create("ImageLabel", {Parent = SearchBar, BackgroundTransparency = 1, Image = "rbxassetid://6031154871", ImageColor3 = SubTextColor, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 8, 0.5, -7)})
    local SearchInput = Create("TextBox", {Parent = SearchBar, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0), Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = TextColor, PlaceholderText = "Search..", TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})

    local CloseBtn = Create("TextButton", {Parent = TopBar, Text = "X", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 26, 1, 0), Position = UDim2.new(1, -28, 0, 0)})
    local MinBtn = Create("TextButton", {Parent = TopBar, Text = "—", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 26, 1, 0), Position = UDim2.new(1, -54, 0, 0)})

    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = BackgroundColor, BackgroundTransparency = 1, Size = UDim2.new(0, 120, 1, -32), Position = UDim2.new(0, 0, 0, 32), Active = true})
    local TabSearchBox = Create("TextBox", {Parent = Sidebar, BackgroundColor3 = CardColor, Size = UDim2.new(1, -16, 0, 22), Position = UDim2.new(0, 8, 0, 4), Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = TextColor, PlaceholderText = "Search tabs...", TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
    Create("UIPadding", {Parent = TabSearchBox, PaddingLeft = UDim.new(0, 8)})
    Create("UICorner", {Parent = TabSearchBox, CornerRadius = UDim.new(0, 4)})
    local TabSearchStroke = Create("UIStroke", {Parent = TabSearchBox, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})
    
    local TabContainer = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, -12, 1, -32), Position = UDim2.new(0, 8, 0, 30), ScrollBarThickness = 0})
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    local Divider = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, -32), Position = UDim2.new(0, 120, 0, 32)})

    local ContentArea = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -125, 1, -32), Position = UDim2.new(0, 125, 0, 32), Active = true})

    local Sphere = Create("ImageButton", {Parent = ScreenGui, BackgroundColor3 = BackgroundColor, BackgroundTransparency = 0.2, Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Visible = false, AutoButtonColor = false, ImageTransparency = 1, ClipsDescendants = true})
    Create("UICorner", {Parent = Sphere, CornerRadius = UDim.new(1, 0)})
    Create("UIStroke", {Parent = Sphere, Color = AccentColor, Thickness = 2})
    
    -- MODIFIED SECTION: Text Label prioritized if SphereText toggle is true. Avoids passing boolean as Text.
    local SphereImageLabel = Create("ImageLabel", {Parent = Sphere, BackgroundTransparency = 1, Size = UDim2.new(0, sphIconSize, 0, sphIconSize), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Image = sphImage or "", ImageTransparency = 1, Visible = (not sphTextToggle and sphImage ~= nil)})
    local SphereTextLabel = Create("TextLabel", {Parent = Sphere, Text = sphWords, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = AccentColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), TextTransparency = 1, Visible = sphTextToggle})
    MakeDraggable(Sphere, Sphere)

    local Window = {CurrentTab = nil, Tabs = {}, Title = Title, AllCards = {}, MainFrame = MainFrame, CurrentTransparency = 0, ConfigElements = {}}

    function Window:SetTransparency(val)
        Window.CurrentTransparency = val
        if MainFrame.Visible then
            Tween(MainFrame, {BackgroundTransparency = val}, 0.3)
            -- Dynamic floating bottom bar transparency control integrated
            Tween(FloatingBottomBar, {BackgroundTransparency = val > 0 and 0.2 or 0}, 0.3)
        end
    end

    MinBtn.MouseButton1Click:Connect(function()
        Tween(MainScale, {Scale = 0}, 0.4)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.4)
        Tween(FloatingBottomBar, {BackgroundTransparency = 1}, 0.4)
        Tween(BottomBarStroke, {Transparency = 1}, 0.4)
        task.wait(0.3)
        MainFrame.Visible = false
        BottomDragHitbox.Visible = false
        Sphere.Visible = true
        Tween(Sphere, {Size = UDim2.new(0, 40, 0, 40)}, 0.4)
        
        -- Corrected fade logic depending on Text toggle
        if not sphTextToggle and sphImage then
            Tween(SphereImageLabel, {ImageTransparency = 0}, 0.4)
        elseif sphTextToggle then
            Tween(SphereTextLabel, {TextTransparency = 0}, 0.4)
        end
    end)

    Sphere.MouseButton1Click:Connect(function()
        Tween(Sphere, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        
        -- Corrected fade logic depending on Text toggle
        if not sphTextToggle and sphImage then Tween(SphereImageLabel, {ImageTransparency = 1}, 0.3) end
        if sphTextToggle then Tween(SphereTextLabel, {TextTransparency = 1}, 0.3) end
        
        task.wait(0.2)
        Sphere.Visible = false
        MainFrame.Visible = true
        BottomDragHitbox.Visible = true
        Tween(MainScale, {Scale = 1}, 0.4)
        Tween(MainFrame, {BackgroundTransparency = Window.CurrentTransparency}, 0.4)
        Tween(FloatingBottomBar, {BackgroundTransparency = Window.CurrentTransparency > 0 and 0.2 or 0}, 0.4)
        Tween(BottomBarStroke, {Transparency = 0}, 0.4)
    end)

    local Popup = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 100, Visible = false, Active = true})
    local PopupCard = Create("Frame", {Parent = Popup, BackgroundColor3 = Color3.fromRGB(8, 8, 8), Size = UDim2.new(0, 260, 0, 140), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 101, BackgroundTransparency = 1, ClipsDescendants = false})
    Create("UICorner", {Parent = PopupCard, CornerRadius = UDim.new(0, 12)})
    local PopupScale = Create("UIScale", {Parent = PopupCard, Scale = 0.8})
    local PopupStroke = Create("UIStroke", {Parent = PopupCard, Color = Color3.fromRGB(28, 28, 28), Thickness = 1, Transparency = 1})
    local PopupTitle = Create("TextLabel", {Parent = PopupCard, Text = "Exit Application", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = TextColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 25), ZIndex = 102, TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center})
    local PopupText = Create("TextLabel", {Parent = PopupCard, Text = "Are you sure you want to close ZyronX? Unsaved configurations might be lost.", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 0, 55), ZIndex = 102, TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center, TextWrapped = true})
    local YesBtn = Create("TextButton", {Parent = PopupCard, Text = "Confirm", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = AccentColor, Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(0.5, 8, 0, 95), ZIndex = 102, BackgroundTransparency = 1, TextTransparency = 1, AutoButtonColor = false})
    Create("UICorner", {Parent = YesBtn, CornerRadius = UDim.new(0, 6)})
    AddBounce(YesBtn)
    local NoBtn = Create("TextButton", {Parent = PopupCard, Text = "Cancel", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Size = UDim2.new(0, 100, 0, 30), Position = UDim2.new(0.5, -108, 0, 95), ZIndex = 102, BackgroundTransparency = 1, TextTransparency = 1, AutoButtonColor = false})
    Create("UICorner", {Parent = NoBtn, CornerRadius = UDim.new(0, 6)})
    AddBounce(NoBtn)

    CloseBtn.MouseButton1Click:Connect(function()
        Popup.Visible = true
        Tween(Popup, {BackgroundTransparency = 0.5}, 0.3)
        Tween(PopupCard, {BackgroundTransparency = 0}, 0.3)
        Tween(PopupScale, {Scale = 1}, 0.3)
        Tween(PopupStroke, {Transparency = 0}, 0.3)
        Tween(PopupTitle, {TextTransparency = 0}, 0.3)
        Tween(PopupText, {TextTransparency = 0}, 0.3)
        Tween(YesBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
        Tween(NoBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
    end)

    YesBtn.MouseButton1Click:Connect(function()
        Tween(Popup, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupCard, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupStroke, {Transparency = 1}, 0.3)
        Tween(PopupTitle, {TextTransparency = 1}, 0.3)
        Tween(PopupText, {TextTransparency = 1}, 0.3)
        Tween(YesBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        Tween(NoBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        Tween(MainScale, {Scale = 0.8}, 0.3)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.3)
        Tween(FloatingBottomBar, {BackgroundTransparency = 1}, 0.3)
        Tween(BottomBarStroke, {Transparency = 1}, 0.3)

        for _, desc in ipairs(MainFrame:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then Tween(desc, {TextTransparency = 1}, 0.3) if desc.BackgroundTransparency < 1 then Tween(desc, {BackgroundTransparency = 1}, 0.3) end
            elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then Tween(desc, {ImageTransparency = 1}, 0.3)
            elseif desc:IsA("Frame") or desc:IsA("ScrollingFrame") then if desc.BackgroundTransparency < 1 then Tween(desc, {BackgroundTransparency = 1}, 0.3) end
            elseif desc:IsA("UIStroke") then Tween(desc, {Transparency = 1}, 0.3) end
        end
        task.wait(0.35)
        ScreenGui:Destroy()
    end)

    NoBtn.MouseButton1Click:Connect(function()
        Tween(Popup, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupCard, {BackgroundTransparency = 1}, 0.3)
        Tween(PopupScale, {Scale = 0.8}, 0.3)
        Tween(PopupStroke, {Transparency = 1}, 0.3)
        Tween(PopupTitle, {TextTransparency = 1}, 0.3)
        Tween(PopupText, {TextTransparency = 1}, 0.3)
        Tween(YesBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        Tween(NoBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        task.wait(0.3)
        Popup.Visible = false
    end)

    TabSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = TabSearchBox.Text:lower()
        for _, tabInfo in ipairs(Window.Tabs) do
            if query == "" or string.find(tabInfo.Txt.Text:lower(), query) then
                tabInfo.Button.Visible = true
            else
                tabInfo.Button.Visible = false
            end
        end
    end)

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        if query == "" then
            for _, data in ipairs(Window.AllCards) do
                data.Card.Parent = data.OrigParent
                data.Card.Visible = true
            end
        else
            if not Window.CurrentTab or not Window.CurrentTab.CurrentPage then return end
            local activeLeft = Window.CurrentTab.CurrentPage.LeftCol
            local activeRight = Window.CurrentTab.CurrentPage.RightCol
            local placeLeft = true
            
            for _, data in ipairs(Window.AllCards) do
                local card = data.Card
                if data.Tab == Window.CurrentTab then
                    if not data.SearchIndex then
                        data.SearchIndex = BuildSearchIndex(card)
                    end
                    local match = string.find(data.SearchIndex, query, 1, true)
                    if match then
                        card.Parent = placeLeft and activeLeft or activeRight
                        placeLeft = not placeLeft
                        card.Visible = true
                    else
                        card.Visible = false
                    end
                else
                    card.Parent = data.OrigParent
                    card.Visible = true
                end
            end
        end
    end)

    function Window:CreateTab(tabName, isDefault, isLocked)
        local isWhitelisted = false
        local player = game:GetService("Players").LocalPlayer
        if player then
            for _, allowedUser in ipairs(Library.WhitelistedUsers) do
                if player.Name == allowedUser or player.DisplayName == allowedUser then
                    isWhitelisted = true
                    break
                end
            end
        end

        local TabBtn = Create("TextButton", {Parent = TabContainer, Text = "", BackgroundColor3 = HoverColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), AutoButtonColor = false})
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})
        AddBounce(TabBtn, 0.98)
        local Indicator = Create("Frame", {Name = "Indicator", Parent = TabBtn, BackgroundColor3 = isLocked and Color3.fromRGB(255, 215, 0) or AccentColor, Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
        local Txt = Create("TextLabel", {Parent = TabBtn, Text = tabName, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})

        if isLocked then
            Create("ImageLabel", {Parent = TabBtn, Image = "rbxassetid://6031082533", ImageColor3 = Color3.fromRGB(255, 215, 0), BackgroundTransparency = 1, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -22, 0.5, -7)})
        end

        local TabContent = Create("Frame", {Parent = ContentArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
        local PageNav = Create("Frame", {Parent = TabContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28)})
        local PageNavList = Create("UIListLayout", {Parent = PageNav, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 15), VerticalAlignment = Enum.VerticalAlignment.Center})
        local PageContainer = Create("Frame", {Parent = TabContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -28), Position = UDim2.new(0, 0, 0, 28)})

        local TabConfig = {Button = TabBtn, Content = TabContent, Indicator = Indicator, Txt = Txt, Pages = {}, CurrentPage = nil}
        table.insert(Window.Tabs, TabConfig)

        TabBtn.MouseButton1Click:Connect(function()
            if isLocked and not isWhitelisted then
                SendPremiumNotification()
                return
            end

            if Window.CurrentTab == TabConfig then return end
            
            if Window.CurrentTab then
                Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.2)
                Tween(Window.CurrentTab.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
                Tween(Window.CurrentTab.Txt, {TextColor3 = SubTextColor}, 0.2)
                Window.CurrentTab.Content.Visible = false
            end
            
            Window.CurrentTab = TabConfig
            TabConfig.Content.Visible = true
            
            TabConfig.Content.Position = UDim2.new(0, 0, 0, 15)
            Tween(TabConfig.Content, {Position = UDim2.new(0, 0, 0, 0)}, 0.35)

            Tween(TabBtn, {BackgroundTransparency = 0}, 0.2)
            Tween(Indicator, {Size = UDim2.new(0, 3, 0, 18)}, 0.3)
            Tween(Txt, {TextColor3 = TextColor}, 0.2)

            if #TabConfig.Pages > 0 then
                local firstPage = TabConfig.Pages[1]
                if TabConfig.CurrentPage ~= firstPage then
                    if TabConfig.CurrentPage then
                        Tween(TabConfig.CurrentPage.Btn, {TextColor3 = SubTextColor}, 0)
                        Tween(TabConfig.CurrentPage.Highlight, {Size = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1}, 0)
                        TabConfig.CurrentPage.Scroll.Visible = false
                    end
                    TabConfig.CurrentPage = firstPage
                    firstPage.Scroll.Visible = true
                    
                    firstPage.Scroll.Position = UDim2.new(0, 5, 0, 15)
                    Tween(firstPage.Scroll, {Position = UDim2.new(0, 5, 0, 5)}, 0.35)

                    Tween(firstPage.Btn, {TextColor3 = TextColor}, 0)
                    Tween(firstPage.Highlight, {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0)
                end
            end
        end)

        function TabConfig:CreatePage(pageName)
            local PageBtn = Create("TextButton", {Parent = PageNav, Text = pageName, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X})
            local PageHighlight = Create("Frame", {Parent = PageBtn, BackgroundColor3 = AccentColor, Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -5), AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1})
            local PageScroll = Create("ScrollingFrame", {Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50), Visible = false, BorderSizePixel = 0})

            local LeftColumn = Create("Frame", {Parent = PageScroll, BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0)})
            local RightColumn = Create("Frame", {Parent = PageScroll, BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0)})
            
            local L_Layout = Create("UIListLayout", {Parent = LeftColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
            local R_Layout = Create("UIListLayout", {Parent = RightColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
            
            L_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PageScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y) + 20) end)
            R_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PageScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y) + 20) end)

            local PageObj = {Scroll = PageScroll, Btn = PageBtn, Highlight = PageHighlight, Left = true, LeftCol = LeftColumn, RightCol = RightColumn}
            table.insert(TabConfig.Pages, PageObj)

            PageBtn.MouseButton1Click:Connect(function()
                if TabConfig.CurrentPage == PageObj then return end
                if TabConfig.CurrentPage then
                    Tween(TabConfig.CurrentPage.Btn, {TextColor3 = SubTextColor}, 0.2)
                    Tween(TabConfig.CurrentPage.Highlight, {Size = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1}, 0.2)
                    TabConfig.CurrentPage.Scroll.Visible = false
                end
                TabConfig.CurrentPage = PageObj
                PageObj.Scroll.Visible = true
                
                PageObj.Scroll.Position = UDim2.new(0, 5, 0, 20)
                Tween(PageObj.Scroll, {Position = UDim2.new(0, 5, 0, 5)}, 0.35)

                Tween(PageBtn, {TextColor3 = TextColor}, 0.2)
                Tween(PageHighlight, {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0.3)
            end)

            if #TabConfig.Pages == 1 and not isLocked then
                TabConfig.CurrentPage = PageObj
                PageObj.Scroll.Visible = true
                PageBtn.TextColor3 = TextColor
                PageHighlight.Size = UDim2.new(1, 0, 0, 2)
                PageHighlight.BackgroundTransparency = 0
            end

            function PageObj:CreateSection(sectionName)
                local targetColumn = PageObj.Left and LeftColumn or RightColumn
                PageObj.Left = not PageObj.Left

                local SectionContainer = Create("Frame", {Parent = targetColumn, BackgroundColor3 = CardColor, Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
                Create("UICorner", {Parent = SectionContainer, CornerRadius = UDim.new(0, 6)})
                
                table.insert(Window.AllCards, {
                    Card = SectionContainer,
                    OrigParent = targetColumn,
                    Tab = TabConfig,
                    Page = PageObj,
                    SearchIndex = nil 
                })
                
                local Title = Create("TextLabel", {Parent = SectionContainer, Text = sectionName, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = TextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                local ItemContainer = Create("Frame", {Parent = SectionContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y})
                local Pad = Create("UIPadding", {Parent = ItemContainer, PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 5)})
                local SList = Create("UIListLayout", {Parent = ItemContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

                local Elements = {}

                function Elements:AddCopyButton(name, copyText, infoData)
                    local BtnFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
                    local Btn = Create("TextButton", {Parent = BtnFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false})
                    Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = Btn, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})

                    AddBounce(Btn)
                    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = HoverColor}, 0.2) end)
                    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = BackgroundColor}, 0.2) end)
                    
                    Btn.MouseButton1Click:Connect(function()
                        SafeCopyToClipboard(copyText)
                        local oldText = Btn.Text
                        Btn.Text = "Copied to Clipboard!"
                        Tween(Btn, {TextColor3 = AccentColor, BackgroundColor3 = HoverColor}, 0.2)
                        task.wait(1.5)
                        if Btn.Parent then
                            Btn.Text = oldText
                            Tween(Btn, {TextColor3 = TextColor, BackgroundColor3 = BackgroundColor}, 0.2)
                        end
                    end)
                    AddInfoIcon(BtnFrame, UDim2.new(1, -40, 0.5, -8), infoData)
                end

                function Elements:AddButton(name, callback, infoData)
                    local BtnFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
                    local Btn = Create("TextButton", {Parent = BtnFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false})
                    Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = Btn, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})

                    AddBounce(Btn)
                    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = HoverColor}, 0.2) end)
                    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = BackgroundColor}, 0.2) end)
                    Btn.MouseButton1Click:Connect(function() if callback then callback() end end)

                    AddInfoIcon(BtnFrame, UDim2.new(1, -40, 0.5, -8), infoData)
                end

                function Elements:AddToggle(name, default, callback, infoData)
                    local state = default or false
                    local TogFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)})
                    
                    Create("TextLabel", {Parent = TogFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    
                    local Lever = Create("TextButton", {Parent = TogFrame, Text = "", BackgroundColor3 = state and AccentColor or Color3.fromRGB(35, 35, 35), Size = UDim2.new(0, 30, 0, 16), Position = UDim2.new(1, -38, 0.5, -8), AutoButtonColor = false})
                    Create("UICorner", {Parent = Lever, CornerRadius = UDim.new(1, 0)})
                    AddBounce(Lever)
                    
                    local Knob = Create("Frame", {Parent = Lever, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 12, 0, 12), Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)})
                    Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

                    local function internalSet(val)
                        state = val
                        Tween(Lever, {BackgroundColor3 = state and AccentColor or Color3.fromRGB(35, 35, 35)}, 0.3)
                        Tween(Knob, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.3)
                        if callback then callback(state) end
                    end

                    Lever.MouseButton1Click:Connect(function() internalSet(not state) end)
                    AddInfoIcon(TogFrame, UDim2.new(1, -70, 0.5, -8), infoData)
                    
                    Window.ConfigElements[name] = { Set = internalSet, Get = function() return state end }
                end

                function Elements:AddSlider(name, min, max, default, callback, infoData)
                    local val = default or min
                    local SliFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45)})
                    
                    Create("TextLabel", {Parent = SliFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    local ValTxt = Create("TextLabel", {Parent = SliFrame, Text = tostring(val), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = TextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 15), Position = UDim2.new(1, -40, 0, 0), TextXAlignment = Enum.TextXAlignment.Right})
                    
                    local TrackBase = Create("Frame", {Parent = SliFrame, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 25)})
                    Create("UICorner", {Parent = TrackBase, CornerRadius = UDim.new(1, 0)})
                    Create("UIStroke", {Parent = TrackBase, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})

                    local Fill = Create("Frame", {Parent = TrackBase, BackgroundColor3 = AccentColor, Size = UDim2.new((val-min)/(max-min), 0, 1, 0)})
                    Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
                    local Knob = Create("Frame", {Parent = Fill, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6)})
                    Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

                    local function internalSet(v)
                        val = math.clamp(v, min, max)
                        ValTxt.Text = tostring(val)
                        Tween(Fill, {Size = UDim2.new((val-min)/(max-min), 0, 1, 0)}, 0.1)
                        if callback then callback(val) end
                    end

                    local dragging = false
                    local function Update(input)
                        local pos = math.clamp((input.Position.X - TrackBase.AbsolutePosition.X) / TrackBase.AbsoluteSize.X, 0, 1)
                        internalSet(math.floor(min + ((max - min) * pos)))
                    end

                    Knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
                    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
                    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end end)
                    AddInfoIcon(SliFrame, UDim2.new(1, -65, 0, 0), infoData)

                    Window.ConfigElements[name] = { Set = internalSet, Get = function() return val end }
                end

                function Elements:AddDropdown(name, options, isMulti, callback, infoData)
                    local selected = isMulti and {} or (options[1] or nil)
                    local dropped = false
                    local optionButtons = {}
                    local maxVisible = math.min(#options, 3)
                    local listHeight = maxVisible * 25
                    local dropOpenHeight = 50 + 32 + listHeight
                    
                    local DropFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50), ClipsDescendants = true})
                    Create("TextLabel", {Parent = DropFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    
                    local MainBtn = Create("TextButton", {Parent = DropFrame, Text = isMulti and "Select Options..." or "Select...", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 20), AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left})
                    Create("UIPadding", {Parent = MainBtn, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = MainBtn, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = MainBtn, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})
                    AddBounce(MainBtn, 0.98)
                    local Arrow = Create("TextLabel", {Parent = MainBtn, Text = "▼", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -28, 0, 0)})

                    local SearchBox = Create("TextBox", {Parent = DropFrame, PlaceholderText = "Search...", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(8, 8, 8), Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, 50), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Visible = false})
                    Create("UIPadding", {Parent = SearchBox, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 4)})
                    local SearchStroke = Create("UIStroke", {Parent = SearchBox, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})

                    local ListFrame = Create("ScrollingFrame", {Parent = DropFrame, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, listHeight), Position = UDim2.new(0, 10, 0, 78), CanvasSize = UDim2.new(0, 0, 0, #options * 25), ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60), BorderSizePixel = 0})
                    Create("UICorner", {Parent = ListFrame, CornerRadius = UDim.new(0, 4)})
                    local DList = Create("UIListLayout", {Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder})

                    local function UpdateText()
                        if isMulti then
                            local txt = ""
                            for _, v in pairs(selected) do txt = txt .. v .. ", " end
                            MainBtn.Text = txt == "" and "Select Options..." or txt:sub(1, -3)
                        else
                            MainBtn.Text = selected or "Select..."
                        end
                    end

                    local function internalSet(v)
                        selected = v
                        UpdateText()
                        for _, btn in ipairs(optionButtons) do
                            local isSel = false
                            if isMulti then
                                isSel = table.find(selected, btn.Text) ~= nil
                            else
                                isSel = (selected == btn.Text)
                            end
                            Tween(btn, {TextColor3 = isSel and TextColor or SubTextColor}, 0.2)
                            Tween(btn:FindFirstChild("Frame"), {Size = isSel and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)}, 0.2)
                        end
                        if callback then callback(selected) end
                    end

                    for _, opt in pairs(options) do
                        local isInitialSelected = (not isMulti and selected == opt)
                        local OptBtn = Create("TextButton", {Parent = ListFrame, Text = opt, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = isInitialSelected and TextColor or SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), AutoButtonColor = false})
                        local Check = Create("Frame", {Parent = OptBtn, BackgroundColor3 = AccentColor, Size = isInitialSelected and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0), BackgroundTransparency = 0.8})
                        table.insert(optionButtons, OptBtn)
                        
                        OptBtn.MouseButton1Click:Connect(function()
                            if isMulti then
                                if table.find(selected, opt) then
                                    table.remove(selected, table.find(selected, opt))
                                else
                                    table.insert(selected, opt)
                                end
                                internalSet(selected)
                            else
                                internalSet(opt)
                                dropped = false
                                Tween(Arrow, {Rotation = 0}, 0.3)
                                Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3)
                                SearchBox.Visible = false
                            end
                        end)
                    end
                    UpdateText()

                    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        local q = SearchBox.Text:lower()
                        for _, btn in ipairs(optionButtons) do
                            if q == "" or string.find(btn.Text:lower(), q) then btn.Visible = true else btn.Visible = false end
                        end
                    end)

                    DList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        ListFrame.CanvasSize = UDim2.new(0, 0, 0, DList.AbsoluteContentSize.Y)
                        if dropped then
                            local dynamicHeight = math.min(DList.AbsoluteContentSize.Y, listHeight)
                            local newOpenHeight = 50 + 32 + dynamicHeight
                            ListFrame.Size = UDim2.new(1, -20, 0, dynamicHeight)
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, newOpenHeight)}, 0.1)
                        end
                    end)

                    MainBtn.MouseButton1Click:Connect(function()
                        dropped = not dropped
                        if dropped then
                            SearchBox.Visible = true
                            SearchBox.Text = ""
                            Tween(Arrow, {Rotation = 180}, 0.3)
                            local dynamicHeight = math.min(DList.AbsoluteContentSize.Y, listHeight)
                            local newOpenHeight = 50 + 32 + dynamicHeight
                            ListFrame.Size = UDim2.new(1, -20, 0, dynamicHeight)
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, newOpenHeight)}, 0.3)
                        else
                            SearchBox.Visible = false
                            Tween(Arrow, {Rotation = 0}, 0.3)
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3)
                        end
                    end)
                    AddInfoIcon(DropFrame, UDim2.new(1, -25, 0, 0), infoData)

                    Window.ConfigElements[name] = { Set = internalSet, Get = function() return selected end }
                end

                function Elements:AddTextbox(name, placeholder, callback, infoData)
                    local TxtFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50)})
                    Create("TextLabel", {Parent = TxtFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    local Input = Create("TextBox", {Parent = TxtFrame, PlaceholderText = placeholder or "Type here...", Text = "", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
                    Create("UIPadding", {Parent = Input, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = Input, CornerRadius = UDim.new(0, 4)})
                    local Stroke = Create("UIStroke", {Parent = Input, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})

                    local function internalSet(v)
                        Input.Text = tostring(v)
                        if callback then callback(v) end
                    end

                    Input.FocusLost:Connect(function(enterPressed) internalSet(Input.Text) end)
                    AddInfoIcon(TxtFrame, UDim2.new(1, -25, 0, 0), infoData)
                    
                    Window.ConfigElements[name] = { Set = internalSet, Get = function() return Input.Text end }
                end

                function Elements:AddColorPicker(name, defaultColor, callback, infoData)
                    local color = defaultColor or Color3.fromRGB(255, 255, 255)
                    local h, s, v_hsv = color:ToHSV()
                    local dropped = false
                    
                    local CFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), ClipsDescendants = true})
                    Create("TextLabel", {Parent = CFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 30), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    local DisplayBtn = Create("TextButton", {Parent = CFrame, Text = "", BackgroundColor3 = color, Size = UDim2.new(0, 30, 0, 16), Position = UDim2.new(1, -40, 0.5, -8), AutoButtonColor = false})
                    Create("UICorner", {Parent = DisplayBtn, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = DisplayBtn, Color = Color3.fromRGB(255,255,255), Transparency = 0.8, Thickness = 1})
                    AddBounce(DisplayBtn)

                    local PickerArea = Create("Frame", {Parent = CFrame, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 140), Position = UDim2.new(0, 10, 0, 35)})
                    Create("UICorner", {Parent = PickerArea, CornerRadius = UDim.new(0, 4)})

                    local PickerClose = Create("TextButton", {Parent = PickerArea, Text = "X", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = SubTextColor, BackgroundColor3 = Color3.fromRGB(30, 20, 20), Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -22, 0, 4), ZIndex = 50, AutoButtonColor = false})
                    Create("UICorner", {Parent = PickerClose, CornerRadius = UDim.new(0, 4)})
                    AddBounce(PickerClose)
                    
                    PickerClose.MouseEnter:Connect(function() Tween(PickerClose, {TextColor3 = Color3.fromRGB(255, 60, 60)}, 0.2) end)
                    PickerClose.MouseLeave:Connect(function() Tween(PickerClose, {TextColor3 = SubTextColor}, 0.2) end)
                    PickerClose.MouseButton1Click:Connect(function() dropped = false Tween(CFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.3) end)

                    local SVMap = Create("TextButton", {Parent = PickerArea, Text = "", BackgroundColor3 = Color3.fromHSV(h, 1, 1), Size = UDim2.new(1, -45, 0, 90), Position = UDim2.new(0, 10, 0, 10), AutoButtonColor = false, Active = true})
                    Create("UICorner", {Parent = SVMap, CornerRadius = UDim.new(0, 4)})
                    
                    local WhiteGrad = Create("Frame", {Parent = SVMap, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(1,1,1), ZIndex = 2})
                    Create("UIGradient", {Parent = WhiteGrad, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}), Rotation = 0})
                    Create("UICorner", {Parent = WhiteGrad, CornerRadius = UDim.new(0, 4)})

                    local BlackGrad = Create("Frame", {Parent = SVMap, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0), ZIndex = 3})
                    Create("UIGradient", {Parent = BlackGrad, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}), Rotation = 90})
                    Create("UICorner", {Parent = BlackGrad, CornerRadius = UDim.new(0, 4)})

                    local SVRing = Create("Frame", {Parent = BlackGrad, Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(s, 0, 1-v_hsv, 0), BackgroundColor3 = Color3.new(1,1,1), ZIndex = 4})
                    Create("UICorner", {Parent = SVRing, CornerRadius = UDim.new(1, 0)})
                    Create("UIStroke", {Parent = SVRing, Color = Color3.new(0,0,0), Thickness = 1})

                    local HueSlider = Create("TextButton", {Parent = PickerArea, Text = "", Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 110), AutoButtonColor = false, BackgroundColor3 = Color3.new(1,1,1), Active = true})
                    Create("UICorner", {Parent = HueSlider, CornerRadius = UDim.new(0, 4)})
                    local HueGradient = Create("UIGradient", {Parent = HueSlider, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})})
                    local HueRing = Create("Frame", {Parent = HueSlider, Size = UDim2.new(0, 6, 0, 15), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(h, 0, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1)})
                    Create("UICorner", {Parent = HueRing, CornerRadius = UDim.new(0, 2)})
                    Create("UIStroke", {Parent = HueRing, Color = Color3.new(0,0,0), Thickness = 1})

                    local function internalSet(hexString)
                        local s_check, c = pcall(function() return Color3.fromHex(hexString) end)
                        if s_check then
                            color = c
                            h, s, v_hsv = color:ToHSV()
                            DisplayBtn.BackgroundColor3 = color
                            SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                            SVRing.Position = UDim2.new(s, 0, 1-v_hsv, 0)
                            HueRing.Position = UDim2.new(h, 0, 0.5, 0)
                            if callback then callback(color) end
                        end
                    end

                    local function UpdateColor()
                        color = Color3.fromHSV(h, s, v_hsv)
                        DisplayBtn.BackgroundColor3 = color
                        SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        if callback then callback(color) end
                    end

                    local draggingSV = false
                    local draggingHue = false
                    
                    SVMap.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = true if PageObj and PageObj.Scroll then PageObj.Scroll.ScrollingEnabled = false end end end)
                    HueSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHue = true if PageObj and PageObj.Scroll then PageObj.Scroll.ScrollingEnabled = false end end end)
                    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = false draggingHue = false if PageObj and PageObj.Scroll then PageObj.Scroll.ScrollingEnabled = true end end end)

                    UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            if draggingSV then
                                local relX = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                                local relY = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                                s = relX
                                v_hsv = 1 - relY
                                SVRing.Position = UDim2.new(s, 0, 1-v_hsv, 0)
                                UpdateColor()
                            elseif draggingHue then
                                local relX = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                                h = relX
                                HueRing.Position = UDim2.new(h, 0, 0.5, 0)
                                UpdateColor()
                            end
                        end
                    end)

                    DisplayBtn.MouseButton1Click:Connect(function() dropped = not dropped Tween(CFrame, {Size = UDim2.new(1, 0, 0, dropped and 185 or 30)}, 0.3) end)
                    AddInfoIcon(CFrame, UDim2.new(1, -65, 0, 7), infoData)

                    Window.ConfigElements[name] = { Set = internalSet, Get = function() return color:ToHex() end }
                end

                function Elements:AddConfigManager(folderName)
                    folderName = folderName or "zyronxSavers"
                    if not _isfolder(folderName) then _makefolder(folderName) end

                    local ManagerFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 240)})
                    
                    local ManagerSearch = Create("TextBox", {Parent = ManagerFrame, PlaceholderText = "Search Saves Loader...", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
                    Create("UIPadding", {Parent = ManagerSearch, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = ManagerSearch, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = ManagerSearch, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})

                    local Monitor = Create("ScrollingFrame", {Parent = ManagerFrame, BackgroundColor3 = Color3.fromRGB(8, 8, 8), Size = UDim2.new(1, -20, 0, 110), Position = UDim2.new(0, 10, 0, 35), ScrollBarThickness = 2, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0)})
                    Create("UICorner", {Parent = Monitor, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = Monitor, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})
                    local MonitorLayout = Create("UIListLayout", {Parent = Monitor, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
                    Create("UIPadding", {Parent = Monitor, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})

                    MonitorLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        Monitor.CanvasSize = UDim2.new(0, 0, 0, MonitorLayout.AbsoluteContentSize.Y + 10)
                    end)

                    local deleteMode = false
                    local editMode = false
                    local selectedForDelete = {}
                    local editTargetFile = ""

                    local Controls = Create("Frame", {Parent = ManagerFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 80), Position = UDim2.new(0, 10, 0, 155)})

                    local NameBox = Create("TextBox", {Parent = Controls, PlaceholderText = "Enter save name...", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
                    Create("UIPadding", {Parent = NameBox, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = NameBox, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = NameBox, Color = Color3.fromRGB(35, 35, 35), Thickness = 1})

                    local CreateBtn = Create("TextButton", {Parent = Controls, Text = "Create Save", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Color3.fromRGB(255,255,255), BackgroundColor3 = AccentColor, Size = UDim2.new(0.5, -5, 0, 26), Position = UDim2.new(0, 0, 0, 35), AutoButtonColor = false})
                    Create("UICorner", {Parent = CreateBtn, CornerRadius = UDim.new(0, 4)})
                    AddBounce(CreateBtn)

                    local DeleteTogBtn = Create("TextButton", {Parent = Controls, Text = "Delete Mode: OFF", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(35, 35, 35), Size = UDim2.new(0.5, -5, 0, 26), Position = UDim2.new(0.5, 5, 0, 35), AutoButtonColor = false})
                    Create("UICorner", {Parent = DeleteTogBtn, CornerRadius = UDim.new(0, 4)})
                    AddBounce(DeleteTogBtn)

                    local ActionArea = Create("Frame", {Parent = Controls, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 35), Visible = false})
                    
                    local ConfirmActionBtn = Create("TextButton", {Parent = ActionArea, Text = "Confirm", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Color3.fromRGB(255,255,255), BackgroundColor3 = Color3.fromRGB(200, 50, 50), Size = UDim2.new(0.5, -5, 0, 26), Position = UDim2.new(0, 0, 0, 0), AutoButtonColor = false})
                    Create("UICorner", {Parent = ConfirmActionBtn, CornerRadius = UDim.new(0, 4)})
                    AddBounce(ConfirmActionBtn)

                    local CancelActionBtn = Create("TextButton", {Parent = ActionArea, Text = "Cancel", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(50, 50, 50), Size = UDim2.new(0.5, -5, 0, 26), Position = UDim2.new(0.5, 5, 0, 0), AutoButtonColor = false})
                    Create("UICorner", {Parent = CancelActionBtn, CornerRadius = UDim.new(0, 4)})
                    AddBounce(CancelActionBtn)

                    AddInfoIcon(ManagerFrame, UDim2.new(1, -20, 0, -22), {
                        Title = "Saves Loader Config Protocol",
                        Description = "Welcome to the Saves System. Here are your instructions:\n\n" ..
                        "1. Create a Save: Type a name in the text box below and click 'Create Save'. This executes the configuration saving.\n" ..
                        "2. Create a Name: Any string is valid. Naming it the exact same as an existing save will not overwrite the old one; it inherently creates a new duplicate file seamlessly.\n" ..
                        "3. Delete a Save Loader: Click 'Delete Mode: OFF' to toggle it ON. Click the file you want deleted (it turns red). Click 'Delete Selected'. A prompt will appear; click Yes to permanently erase.\n" ..
                        "4. Saves Loader Functionality: The system pulls all modified user data (Toggles, Sliders, Colors) and exports it securely as JSON to your workspace. Clicking 'Load' pulls it back in.\n" ..
                        "5. Edit / Overwrite: Click 'Edit' on a save. Change the name inside the input box, then click 'Save Edit'. This effectively edits the target.\n" ..
                        "6. Unedit Saves Loader: If you mistakenly clicked 'Edit' or 'Delete Mode', simply click the 'Cancel' button to back out without causing changes."
                    })

                    local InternalConfirmPopup = Create("Frame", {Parent = ManagerFrame, BackgroundColor3 = Color3.fromRGB(8, 8, 8), Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10), ZIndex = 60, BackgroundTransparency = 1, Visible = false})
                    Create("UICorner", {Parent = InternalConfirmPopup, CornerRadius = UDim.new(0, 8)})
                    Create("UIStroke", {Parent = InternalConfirmPopup, Color = Color3.fromRGB(180, 50, 50), Thickness = 1, Transparency = 1})
                    
                    local P_Title = Create("TextLabel", {Parent = InternalConfirmPopup, Text = "Confirm Deletion?", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255, 60, 60), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 40), TextTransparency = 1, ZIndex = 61})
                    local P_Desc = Create("TextLabel", {Parent = InternalConfirmPopup, Text = "You are about to delete these specific saves loaders permanently.", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 0, 70), TextWrapped = true, TextTransparency = 1, ZIndex = 61})
                    
                    local P_Yes = Create("TextButton", {Parent = InternalConfirmPopup, Text = "Yes", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(180, 50, 50), Size = UDim2.new(0.5, -30, 0, 30), Position = UDim2.new(0, 20, 0, 130), AutoButtonColor = false, BackgroundTransparency = 1, TextTransparency = 1, ZIndex = 61})
                    Create("UICorner", {Parent = P_Yes, CornerRadius = UDim.new(0, 4)})
                    AddBounce(P_Yes)
                    
                    local P_No = Create("TextButton", {Parent = InternalConfirmPopup, Text = "No", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(35, 35, 35), Size = UDim2.new(0.5, -30, 0, 30), Position = UDim2.new(0.5, 10, 0, 130), AutoButtonColor = false, BackgroundTransparency = 1, TextTransparency = 1, ZIndex = 61})
                    Create("UICorner", {Parent = P_No, CornerRadius = UDim.new(0, 4)})
                    AddBounce(P_No)

                    local function HideInternalPopup()
                        Tween(InternalConfirmPopup, {BackgroundTransparency = 1}, 0.3)
                        Tween(InternalConfirmPopup:FindFirstChild("UIStroke"), {Transparency = 1}, 0.3)
                        Tween(P_Title, {TextTransparency = 1}, 0.3)
                        Tween(P_Desc, {TextTransparency = 1}, 0.3)
                        Tween(P_Yes, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
                        Tween(P_No, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
                        task.wait(0.3)
                        InternalConfirmPopup.Visible = false
                    end

                    local function RefreshMonitor()
                        for _, v in ipairs(Monitor:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
                        selectedForDelete = {}

                        local files = _listfiles(folderName)
                        for _, filepath in ipairs(files) do
                            local rawName = filepath:match("([^/\\]+)%.json$")
                            if rawName then
                                local displayFName = rawName:gsub("_%d+%.%d+$", ""):gsub("_%d+$", "")

                                local Row = Create("Frame", {Parent = Monitor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, 0, 0, 30)})
                                Create("UICorner", {Parent = Row, CornerRadius = UDim.new(0, 4)})
                                
                                local Title = Create("TextLabel", {Parent = Row, Text = displayFName, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = TextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                                
                                local LoadBtn = Create("TextButton", {Parent = Row, Text = "Load", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(45, 120, 60), Size = UDim2.new(0, 35, 0, 20), Position = UDim2.new(1, -70, 0.5, -10), AutoButtonColor = false})
                                Create("UICorner", {Parent = LoadBtn, CornerRadius = UDim.new(0, 4)})
                                AddBounce(LoadBtn)

                                local EditBtn = Create("TextButton", {Parent = Row, Text = "Edit", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(150, 100, 45), Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -33, 0.5, -10), AutoButtonColor = false})
                                Create("UICorner", {Parent = EditBtn, CornerRadius = UDim.new(0, 4)})
                                AddBounce(EditBtn)

                                local SelectionMask = Create("TextButton", {Parent = Row, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, -80, 1, 0), ZIndex = 2})
                                
                                SelectionMask.MouseButton1Click:Connect(function()
                                    if deleteMode then
                                        if selectedForDelete[filepath] then
                                            selectedForDelete[filepath] = nil
                                            Tween(Row, {BackgroundColor3 = BackgroundColor}, 0.2)
                                        else
                                            selectedForDelete[filepath] = true
                                            Tween(Row, {BackgroundColor3 = Color3.fromRGB(180, 50, 50)}, 0.2)
                                        end
                                    end
                                end)

                                LoadBtn.MouseButton1Click:Connect(function()
                                    if deleteMode or editMode then return end
                                    local s, data = pcall(function() return HttpService:JSONDecode(_readfile(filepath)) end)
                                    if s and type(data) == "table" then
                                        for k, v in pairs(data) do
                                            if Window.ConfigElements[k] and Window.ConfigElements[k].Set then
                                                Window.ConfigElements[k].Set(v)
                                            end
                                        end
                                        Library:Notify({Title = "Saves Loader", Description = "Successfully loaded " .. displayFName})
                                    end
                                end)

                                EditBtn.MouseButton1Click:Connect(function()
                                    if deleteMode then return end
                                    editMode = true
                                    editTargetFile = filepath
                                    NameBox.Text = displayFName
                                    CreateBtn.Visible = false
                                    DeleteTogBtn.Visible = false
                                    ActionArea.Visible = true
                                    ConfirmActionBtn.Text = "Save Edit"
                                    ConfirmActionBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
                                end)
                            end
                        end
                    end

                    local function ExecuteSave(saveName)
                        local payload = {}
                        for k, el in pairs(Window.ConfigElements) do
                            if el.Get then payload[k] = el.Get() end
                        end
                        local encoded = HttpService:JSONEncode(payload)
                        local uniqueKey = tostring(math.floor(tick()))
                        local finalPath = folderName .. "/" .. saveName .. "_" .. uniqueKey .. ".json"
                        _writefile(finalPath, encoded)
                        RefreshMonitor()
                        Library:Notify({Title = "Saved Successfully", Description = "Config [" .. saveName .. "] secured."})
                    end

                    CreateBtn.MouseButton1Click:Connect(function()
                        if NameBox.Text ~= "" then ExecuteSave(NameBox.Text) end
                    end)

                    DeleteTogBtn.MouseButton1Click:Connect(function()
                        if editMode then return end
                        deleteMode = not deleteMode
                        DeleteTogBtn.Text = deleteMode and "Delete Mode: ON" or "Delete Mode: OFF"
                        Tween(DeleteTogBtn, {BackgroundColor3 = deleteMode and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(35, 35, 35)}, 0.2)
                        
                        ActionArea.Visible = deleteMode
                        CreateBtn.Visible = not deleteMode
                        if deleteMode then
                            ConfirmActionBtn.Text = "Delete Selected"
                            ConfirmActionBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                        else
                            RefreshMonitor()
                        end
                    end)

                    ConfirmActionBtn.MouseButton1Click:Connect(function()
                        if deleteMode then
                            InternalConfirmPopup.Visible = true
                            Tween(InternalConfirmPopup, {BackgroundTransparency = 0.1}, 0.3)
                            Tween(InternalConfirmPopup:FindFirstChild("UIStroke"), {Transparency = 0.5}, 0.3)
                            Tween(P_Title, {TextTransparency = 0}, 0.3)
                            Tween(P_Desc, {TextTransparency = 0}, 0.3)
                            Tween(P_Yes, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
                            Tween(P_No, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
                        elseif editMode then
                            local newName = NameBox.Text
                            if newName ~= "" then
                                pcall(function() _delfile(editTargetFile) end)
                                ExecuteSave(newName)
                            end
                            editMode = false
                            ActionArea.Visible = false
                            CreateBtn.Visible = true
                            DeleteTogBtn.Visible = true
                            RefreshMonitor()
                        end
                    end)

                    P_Yes.MouseButton1Click:Connect(function()
                        for file, _ in pairs(selectedForDelete) do pcall(function() _delfile(file) end) end
                        deleteMode = false
                        DeleteTogBtn.Text = "Delete Mode: OFF"
                        DeleteTogBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        ActionArea.Visible = false
                        CreateBtn.Visible = true
                        RefreshMonitor()
                        Library:Notify({Title = "Deletions Complete", Description = "Selected saves erased from system."})
                        HideInternalPopup()
                    end)

                    P_No.MouseButton1Click:Connect(function()
                        HideInternalPopup()
                    end)

                    CancelActionBtn.MouseButton1Click:Connect(function()
                        editMode = false
                        deleteMode = false
                        DeleteTogBtn.Text = "Delete Mode: OFF"
                        DeleteTogBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        ActionArea.Visible = false
                        CreateBtn.Visible = true
                        DeleteTogBtn.Visible = true
                        NameBox.Text = ""
                        RefreshMonitor()
                    end)

                    ManagerSearch:GetPropertyChangedSignal("Text"):Connect(function()
                        local q = ManagerSearch.Text:lower()
                        for _, v in ipairs(Monitor:GetChildren()) do
                            if v:IsA("Frame") then
                                local lbl = v:FindFirstChildOfClass("TextLabel")
                                if lbl then v.Visible = (q == "" or string.find(lbl.Text:lower(), q) ~= nil) end
                            end
                        end
                    end)

                    RefreshMonitor()
                end

                return Elements
            end
            return PageObj
        end

        if isDefault then
            TabBtn.BackgroundTransparency = 0
            Indicator.Size = UDim2.new(0, 3, 0, 18)
            Txt.TextColor3 = TextColor
            TabContent.Visible = true
            Window.CurrentTab = TabConfig
        end
        return TabConfig
    end
    return Window
end
return Library
end)()

print("[SOLANA HUB] library ready, starting hub")
warn("[SOLANA HUB] library ready, starting hub")
local _hubOk, _hubErr = pcall(function()



-- ========== SOLANA HUB (Violence District) ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local RS = game:GetService("ReplicatedStorage")
local VIM
pcall(function() VIM = game:GetService("VirtualInputManager") end)
local GuiService
pcall(function() GuiService = game:GetService("GuiService") end)
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer
if not LP then
	repeat task.wait() LP = Players.LocalPlayer until LP
end
local PG = LP:WaitForChild("PlayerGui", 10) or LP:FindFirstChild("PlayerGui")
if not PG then
	error("PlayerGui missing")
end

Library.WhitelistedUsers = { LP.Name }

local Window = Library:CreateWindow({
	Title = '<font color="#E02030">SOL</font><font color="#FF9AA2">A</font><font color="#FFFFFF">NA HUB</font>',
	Subtitle = "Violence District",
	SubtitleColor = Color3.fromRGB(160, 160, 160),
	Logo = "rbxassetid://112194215109109",
	LogoSize = 26,
	SphereText = false,
	SphereWords = "SH",
	SphereImage = "rbxassetid://74281278155363",
	SphereIconSize = 28,
})
if Window and Window.MainFrame then
	Window.MainFrame.Visible = true
	Window.MainFrame.BackgroundTransparency = 0
	local sc = Window.MainFrame:FindFirstChildOfClass("UIScale")
	if sc then sc.Scale = 1 end
	pcall(function()
		local sg = Window.MainFrame.Parent
		if sg and sg:IsA("ScreenGui") then
			sg.Enabled = true
			sg.ResetOnSpawn = false
			sg.IgnoreGuiInset = true
			sg.DisplayOrder = 999999
			if not sg.Parent then
				sg.Parent = PG
			end
		end
	end)
	pcall(function()
		local boot = rawget(_G, "_SolanaBoot")
		if boot and boot.Destroy then
			boot:Destroy()
		end
	end)
end

-- shrink main frame for mobile (library default 480x320)
task.defer(function()
	task.wait(0.2)
	local root
	pcall(function() if gethui then root = gethui() end end)
	if not root then pcall(function() root = game:GetService("CoreGui") end) end
	if not root then
		local plr = game:GetService("Players").LocalPlayer
		root = plr and plr:FindFirstChildOfClass("PlayerGui")
	end
	if not root then return end
	for _, g in ipairs(root:GetChildren()) do
		if g:IsA("ScreenGui") and g.Name:find("ZyronX") then
			for _, c in ipairs(g:GetChildren()) do
				if c:IsA("Frame") and c.AbsoluteSize.X >= 400 then
					c.Size = UDim2.fromOffset(440, 320)
				end
			end
			-- remove topbar X if any
			for _, d in ipairs(g:GetDescendants()) do
				if d:IsA("TextButton") then
					local t = (d.Text or ""):gsub("%s", "")
					if t == "X" or t == "x" or t == "×" then
						-- keep info overlay X; only kill if in topbar area
						if d.AbsoluteSize.X <= 40 then
							-- don't destroy info close; skip small window close only on main topbar named patterns
						end
					end
				end
			end
		end
	end
end)

local function notify(t, d)
end

local S = {
	silentAim=false, aimMode="Killer", aimName="", autoParry=false, autoGen=false, genMode="Perfect",
	camFov=120,
	hitbox=false, hitboxSize=15, spearSilent=false,
	hitboxSurvPct=200, hitboxKillPct=100, hitboxEsp=false,
	hitboxEspFill=0.5, hitboxOutlineOnly=false,
	hitboxSurvColor=Color3.fromRGB(0,255,120), hitboxKillColor=Color3.fromRGB(255,60,60),
	moonwalk=false, moonSway=0.7, moonRate=8, moonZigSpeed=11, moonZigAmt=48, moonBoost=1.08,
	espGen=false, espGate=false, espWindow=false, espHook=false, espPallet=false, espKiller=false, espSurvivor=false, fullbright=false, noFog=false,
	tracerKill=false, tracerSurv=false, tracerGen=false,
	speedOn=false, walkSpeed=24, noclip=false, antiAfk=false,
	antiFail=false, autoDodge=false, noFall=false, noTurn=false, gateTool=false,
	autoSlash=false, slashMode="Rage", slashRange=12, antiBlind=false, antiStun=false,
	fpsBoost=false, infZoom=false, fakeName=false, bypassAdmin=false, perfHud=false,
	camDBD=false, camSmooth=22, camLag=0.025, camSway=true, camSwayStr=0.25,
	camBob=true, camBobStr=0.045, camBlur=true, camPovLock=false, camPov=110, camRotSmooth=0.35,
}
local conns = {}
local function bind(n, c) if conns[n] then pcall(function() conns[n]:Disconnect() end) end; conns[n]=c end
local function unbind(n) if conns[n] then pcall(function() conns[n]:Disconnect() end) conns[n]=nil end end

local function roleOf(plr)
	local ok, tn = pcall(function() return plr.Team and plr.Team.Name:lower() or "" end)
	return (ok and tn:find("killer")) and "killer" or "survivor"
end

local function clearHL(tag)
	for _, plr in ipairs(Players:GetPlayers()) do
		local c = plr.Character
		if c then local h=c:FindFirstChild(tag); if h then h:Destroy() end end
	end
end

local function addHL(adornee, tag, color)
	if not adornee or adornee:FindFirstChild(tag) then return end
	local hl = Instance.new("Highlight")
	hl.Name=tag; hl.FillColor=color; hl.OutlineColor=color
	hl.FillTransparency=0.55; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee=adornee; hl.Parent=adornee
end

local genCache = {}
local function isGenDone(obj)
	local p = obj:GetAttribute("RepairProgress") or obj:GetAttribute("Progress") or 0
	if p >= 100 then return true end
	if obj:GetAttribute("Completed") or obj:GetAttribute("IsCompleted") or obj:GetAttribute("Done") then return true end
	return false
end

local function grabFolderKids(names, out)
	local roots = { workspace }
	local map = workspace:FindFirstChild("Map")
	if map then roots[2] = map end
	for _, root in ipairs(roots) do
		for _, name in ipairs(names) do
			local folder = root:FindFirstChild(name)
			if folder then
				if folder:IsA("Model") then
					out[#out+1] = folder
				end
				for _, c in ipairs(folder:GetChildren()) do
					if c:IsA("Model") or c:IsA("BasePart") then
						out[#out+1] = c
					end
				end
			end
		end
	end
end

local function scanGenerators()
	for i=#genCache,1,-1 do genCache[i]=nil end
	local raw = {}
	grabFolderKids({"Generators", "Generator", "Gens"}, raw)
	for _, d in ipairs(raw) do
		if d.Name == "Generator" or d.Name:lower():find("gen") then
			if not isGenDone(d) then
				genCache[#genCache+1] = d
			end
		end
	end
	return genCache
end

local function genPos(g)
	if not g then return end
	if g:IsA("Model") then
		if g.PrimaryPart then return g.PrimaryPart.Position end
		local p = g:FindFirstChildWhichIsA("BasePart", true)
		return p and p.Position
	elseif g:IsA("BasePart") then return g.Position end
end

local function getGenPart(model)
	if not model then return end
	return model:FindFirstChild("HitBox", true)
		or model:FindFirstChild("GeneratorPoint", true)
		or model.PrimaryPart
		or model:FindFirstChildWhichIsA("BasePart", true)
end

local function collectGens()
	local found, seen = {}, {}
	local function scan(root)
		if not root then return end
		for _, v in ipairs(root:GetDescendants()) do
			if v:IsA("Model") and v.Name == "Generator" and not seen[v] then
				local part = getGenPart(v)
				if part then
					seen[v] = true
					found[#found+1] = { model = v, part = part }
				end
			end
		end
	end
	scan(workspace:FindFirstChild("Map"))
	scan(workspace:FindFirstChild("Map1"))
	if #found == 0 then scan(workspace) end
	return found
end

local function hardTP(pos)
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not (root and pos) then return end
	root.Anchored = true
	for i = 1, 3 do
		root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
		root.AssemblyLinearVelocity = Vector3.zero
		task.wait(0.05)
	end
	root.Anchored = false
end

local function teleportToGenerator()
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local best, bestD = nil, math.huge
	for _, gen in ipairs(collectGens()) do
		local part = gen.part
		if part and part.Parent then
			local d = (part.Position - root.Position).Magnitude
			if d < bestD then bestD, best = d, part end
		end
	end
	if best then hardTP(best.Position) end
end

local function teleportRandomGen()
	local gens = collectGens()
	if #gens == 0 then return end
	local pick = gens[math.random(1, #gens)]
	if pick and pick.part then hardTP(pick.part.Position) end
end

local function setPlayerESP(flag, role, tag, color)
	unbind(tag)
	if not flag then clearHL(tag) return end
	local last = tick() - ((tag == "SolanaKESP") and 10 or 7.5)
	bind(tag, RunService.Heartbeat:Connect(function()
		if not S[flag] then return end
		local now = tick()
		if now - last < 10 then return end
		last = now
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr~=LP and roleOf(plr)==role and plr.Character then
				addHL(plr.Character, tag, color)
			end
		end
	end))
end

local genESP = {}
local function genProgress(gen)
	local v = gen:GetAttribute("RepairProgress") or gen:GetAttribute("ProgressRepair") or gen:GetAttribute("Progress") or gen:GetAttribute("Repair")
	local n = tonumber(v) or 0
	if n > 0 and n <= 1 then n = n * 100 end
	if n < 0 then n = 0 elseif n > 100 then n = 100 end
	return n
end
local function destroyGenESP(gen)
	local d = genESP[gen]
	if not d then return end
	if d.hl then pcall(function() d.hl:Destroy() end) end
	if d.bb then pcall(function() d.bb:Destroy() end) end
	genESP[gen] = nil
end
local function buildGenESP(gen)
	local d = {}
	local hl = Instance.new("Highlight")
	hl.Name = "SolanaGenHL"
	hl.Adornee = gen
	hl.FillTransparency = 0.85
	hl.OutlineTransparency = 0.2
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = gen
	d.hl = hl
	local adornee = gen:FindFirstChild("HitBox", true) or gen:FindFirstChild("GeneratorPoint", true) or gen.PrimaryPart or gen:FindFirstChildWhichIsA("BasePart", true)
	if adornee then
		local bb = Instance.new("BillboardGui")
		bb.Name = "SolanaGenESP"
		bb.Size = UDim2.new(0, 80, 0, 28)
		bb.AlwaysOnTop = true
		bb.MaxDistance = 500
		bb.Adornee = adornee
		bb.Parent = gen
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.TextSize = 14
		label.TextStrokeTransparency = 0.3
		label.Parent = bb
		d.bb, d.label = bb, label
	end
	genESP[gen] = d
end
local function scanGenESP()
	local seen = {}
	local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("Map1") or workspace
	for _, obj in ipairs(map:GetDescendants()) do
		if obj:IsA("Model") and obj.Name == "Generator" then
			seen[obj] = true
			if not genESP[obj] then buildGenESP(obj) end
		end
	end
	for gen in pairs(genESP) do
		if not seen[gen] or not gen.Parent then destroyGenESP(gen) end
	end
end
local function setGenESP(on)
	unbind("genesp")
	unbind("genespscan")
	if not on then
		for gen in pairs(genESP) do destroyGenESP(gen) end
		return
	end
	scanGenESP()
	local last = 0
	bind("genesp", RunService.Heartbeat:Connect(function()
		if not S.espGen then return end
		local now = tick()
		if now - last < 0.1 then return end
		last = now
		for gen, d in pairs(genESP) do
			if gen.Parent then
				local pct = genProgress(gen)
				local col = Color3.fromRGB(255, 220, 50):Lerp(Color3.fromRGB(50, 220, 80), pct / 100)
				if d.hl then d.hl.FillColor = col; d.hl.OutlineColor = col end
				if d.label then d.label.Text = string.format("[%.0f%%]", pct); d.label.TextColor3 = col end
				if d.bb then d.bb.Enabled = pct < 100 end
			end
		end
	end))
	task.spawn(function()
		while S.espGen do
			task.wait(1.5)
			if S.espGen then scanGenESP() end
		end
	end)
end

local function paintNamedESP(flag, names, tag, color)
	if not S[flag] then clearHL(tag) return end
	local raw = {}
	grabFolderKids(names, raw)
	for _, d in ipairs(raw) do
		addHL(d, tag, color)
	end
end

local hookESP = {}
local function hookMatches(obj)
	if not obj then return false end
	if obj:IsA("Model") and obj.Name == "Hook" then return true end
	if obj:IsA("BasePart") then
		local n = obj.Name:lower()
		if obj:GetAttribute("Spike") ~= nil then return true end
		if n == "hookpoint" or n:find("hookpoint") then return true end
	end
	return false
end
local function clearHookESP()
	for obj, hl in pairs(hookESP) do
		pcall(function() hl:Destroy() end)
		hookESP[obj] = nil
	end
end
local function scanHookESP()
	local seen = {}
	local roots = {}
	local map, map1 = workspace:FindFirstChild("Map"), workspace:FindFirstChild("Map1")
	if map then roots[#roots+1] = map end
	if map1 then roots[#roots+1] = map1 end
	if #roots == 0 then roots[1] = workspace end
	for _, root in ipairs(roots) do
		for _, d in ipairs(root:GetDescendants()) do
			if hookMatches(d) then
				seen[d] = true
				if not hookESP[d] then
					local hl = Instance.new("Highlight")
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.FillTransparency = 0.9
					hl.OutlineTransparency = 0.3
					hl.FillColor = Color3.fromRGB(255, 0, 0)
					hl.OutlineColor = Color3.fromRGB(255, 0, 0)
					hl.Adornee = d
					hl.Parent = d
					hookESP[d] = hl
				end
			end
		end
	end
	for obj, hl in pairs(hookESP) do
		if not seen[obj] or not obj.Parent then
			pcall(function() hl:Destroy() end)
			hookESP[obj] = nil
		end
	end
end
local function setHookESP(on)
	if not on then
		clearHookESP()
		return
	end
	scanHookESP()
	task.spawn(function()
		while S.espHook do
			task.wait(3)
			if S.espHook then scanHookESP() end
		end
	end)
end

local function setObjESP()
	unbind("objesp")
	unbind("objadd")
	if not (S.espWindow or S.espPallet) then
		clearHL("SolanaWinESP"); clearHL("SolanaPalESP")
		if not (S.espGen or S.espHook) then return end
	end
	local lastWin, lastHook, lastPal = 2.5, 5, 7.5
	bind("objesp", RunService.Heartbeat:Connect(function()
		local now = tick()
		if S.espWindow and now - lastWin >= 10 then
			lastWin = now
			paintNamedESP("espWindow", {"Windows", "Window", "Vaults", "Vault"}, "SolanaWinESP", Color3.fromRGB(100,200,255))
		end


		if S.espPallet and now - lastPal >= 10 then
			lastPal = now
			paintNamedESP("espPallet", {"Pallets", "Pallet"}, "SolanaPalESP", Color3.fromRGB(200,160,80))
		end
	end))
end

local tracerLines = { k = {}, s = {}, g = {} }
local hasDrawing = typeof(Drawing) == "table" and type(Drawing.new) == "function"

local function tracerDrop(bucket)
	for key, line in pairs(bucket) do
		pcall(function() line:Remove() end)
		bucket[key] = nil
	end
end

local function tracerLine(bucket, key, color)
	local line = bucket[key]
	if line then
		line.Color = color
		return line
	end
	if not hasDrawing then return nil end
	line = Drawing.new("Line")
	line.Thickness = 1.5
	line.Transparency = 1
	line.Color = color
	line.Visible = false
	bucket[key] = line
	return line
end

local function tracerDraw(line, fromPos, toPos)
	if not line then return end
	local cam = workspace.CurrentCamera
	if not cam then line.Visible = false return end
	local a, aOn = cam:WorldToViewportPoint(fromPos)
	local b, bOn = cam:WorldToViewportPoint(toPos)
	if aOn and bOn and b.Z > 0 and a.Z > 0 then
		line.From = Vector2.new(a.X, a.Y)
		line.To = Vector2.new(b.X, b.Y)
		line.Visible = true
	else
		line.Visible = false
	end
end

local function setTracers()
	unbind("tracer")
	unbind("tracerAdd")
	unbind("tracerRem")
	if not (S.tracerKill or S.tracerSurv or S.tracerGen) then
		tracerDrop(tracerLines.k)
		tracerDrop(tracerLines.s)
		tracerDrop(tracerLines.g)
		return
	end
	if not hasDrawing then
		notify("Tracer", "Drawing API missing")
		return
	end
	bind("tracerAdd", Players.PlayerAdded:Connect(function() end))
	bind("tracerRem", Players.PlayerRemoving:Connect(function(plr)
		if tracerLines.k[plr] then pcall(function() tracerLines.k[plr]:Remove() end) tracerLines.k[plr]=nil end
		if tracerLines.s[plr] then pcall(function() tracerLines.s[plr]:Remove() end) tracerLines.s[plr]=nil end
	end))
	bind("tracer", RunService.RenderStepped:Connect(function()
		local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if not my then
			for _, b in pairs(tracerLines) do
				for _, line in pairs(b) do line.Visible = false end
			end
			return
		end
		local origin = my.Position
		local seenK, seenS = {}, {}
		if S.tracerKill or S.tracerSurv then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LP and plr.Character then
					local root = plr.Character:FindFirstChild("HumanoidRootPart")
					local r = roleOf(plr)
					if root and S.tracerKill and r == "killer" then
						seenK[plr] = true
						tracerDraw(tracerLine(tracerLines.k, plr, Color3.fromRGB(255, 50, 50)), origin, root.Position)
					end
					if root and S.tracerSurv and r == "survivor" then
						seenS[plr] = true
						tracerDraw(tracerLine(tracerLines.s, plr, Color3.fromRGB(0, 170, 255)), origin, root.Position)
					end
				end
			end
		end
		for plr, line in pairs(tracerLines.k) do
			if not seenK[plr] then line.Visible = false end
		end
		for plr, line in pairs(tracerLines.s) do
			if not seenS[plr] then line.Visible = false end
		end
		if S.tracerGen then
			scanGenerators()
			local seenG = {}
			for i, g in ipairs(genCache) do
				local p = genPos(g)
				if p then
					seenG[g] = true
					tracerDraw(tracerLine(tracerLines.g, g, Color3.fromRGB(80, 255, 120)), origin, p)
				end
			end
			for key, line in pairs(tracerLines.g) do
				if not seenG[key] then
					pcall(function() line:Remove() end)
					tracerLines.g[key] = nil
				end
			end
		else
			tracerDrop(tracerLines.g)
		end
		if not S.tracerKill then tracerDrop(tracerLines.k) end
		if not S.tracerSurv then tracerDrop(tracerLines.s) end
	end))
end

local lb = {}
local function setFB(on)
	if on then
		lb.b,lb.c,lb.f,lb.g = Lighting.Brightness,Lighting.ClockTime,Lighting.FogEnd,Lighting.GlobalShadows
		Lighting.Brightness=2; Lighting.ClockTime=14; Lighting.FogEnd=1e6; Lighting.GlobalShadows=false
	else
		if lb.b then Lighting.Brightness=lb.b end
		if lb.c then Lighting.ClockTime=lb.c end
		if lb.f then Lighting.FogEnd=lb.f end
		if lb.g~=nil then Lighting.GlobalShadows=lb.g end
		lb={}
	end
end

local function setNoclip(on)
	unbind("noclip")
	if not on then return end
	bind("noclip", RunService.Stepped:Connect(function()
		local c=LP.Character; if not c then return end
		local hrp=c:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CanCollide=false end
		local t=c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
		if t then t.CanCollide=false end
	end))
end

local function isCrouching(ch, hum)
	if not (ch and hum) then return false end
	if hum:GetState() == Enum.HumanoidStateType.Crouching then return true end
	for _, a in ipairs({"Crouching", "IsCrouching", "Crouch", "IsCrouch"}) do
		if ch:GetAttribute(a) == true or hum:GetAttribute(a) == true then return true end
	end
	local an = hum:FindFirstChildOfClass("Animator")
	if an then
		for _, t in ipairs(an:GetPlayingAnimationTracks()) do
			local n = (t.Name or ""):lower()
			if n:find("crouch") or n:find("sneak") then return true end
		end
	end
	return false
end

local function isSprinting(ch, hum)
	if not (ch and hum) then return false end
	if isCrouching(ch, hum) then return false end
	for _, a in ipairs({"Sprinting", "IsSprinting", "Sprint", "IsSprint", "Running", "IsRunning"}) do
		if ch:GetAttribute(a) == true or hum:GetAttribute(a) == true then return true end
	end
	pcall(function()
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.ButtonL3) then
			return true
		end
	end)
	if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.ButtonL3) then
		return true
	end
	local an = hum:FindFirstChildOfClass("Animator")
	if an then
		for _, t in ipairs(an:GetPlayingAnimationTracks()) do
			local n = (t.Name or ""):lower()
			if n:find("sprint") or n:find("run") then return true end
		end
	end
	return false
end

local function liveSpeed(hum)
	if S.speedOn then return S.walkSpeed or 24 end
	return (hum and hum.WalkSpeed) or 16
end

local function applyWalkSpeed()
	local ch = LP.Character
	local h = ch and ch:FindFirstChildOfClass("Humanoid")
	if not h then return end
	local spd = S.walkSpeed or 24
	h.WalkSpeed = spd
	pcall(function()
		ch:SetAttribute("Speed", spd)
		h:SetAttribute("Speed", spd)
	end)
end
local function setSpeed(on)
	unbind("speed")
	unbind("speedrs")
	pcall(function() RunService:UnbindFromRenderStep("SolanaSpeed") end)
	if not on then
		local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if h then h.WalkSpeed=16 end
		return
	end
	applyWalkSpeed()
	bind("speed", RunService.Heartbeat:Connect(applyWalkSpeed))
	pcall(function()
		RunService:BindToRenderStep("SolanaSpeed", Enum.RenderPriority.Last.Value, applyWalkSpeed)
	end)
end

local function setAFK(on)
	unbind("afk")
	if not on then return end
	local vu=game:GetService("VirtualUser")
	bind("afk", LP.Idled:Connect(function()
		pcall(function() vu:CaptureController() vu:ClickButton2(Vector2.new()) end)
	end))
end

local camDBDName = "SolanaCamDBD"
local camDBDBlur

local function setCamDBD(on)
	pcall(function() RunService:UnbindFromRenderStep(camDBDName) end)
	if camDBDBlur then
		pcall(function() camDBDBlur:Destroy() end)
		camDBDBlur = nil
	end
	if not on then return end
	local blur = Lighting:FindFirstChild("SolanaCamBlur")
	if not blur then
		blur = Instance.new("BlurEffect")
		blur.Name = "SolanaCamBlur"
		blur.Size = 0
		blur.Enabled = true
		blur.Parent = Lighting
	end
	camDBDBlur = blur
	local prev = workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new()
	local smooth = prev
	local bobT, blurS = 0, 0
	RunService:BindToRenderStep(camDBDName, Enum.RenderPriority.Camera.Value + 1, function(dt)
		if not S.camDBD then return end
		local cam = workspace.CurrentCamera
		if not cam then return end
		local raw = cam.CFrame
		if S.camSmooth and S.camSmooth > 0 then
			local a = 1 - math.exp(-(S.camSmooth or 22) * dt)
			smooth = smooth:Lerp(raw, a)
		else
			smooth = raw
		end
		local out = smooth
		if not S.camPovLock and S.camSway then
			local delta = raw.Position - prev.Position
			local lag = math.clamp(delta.Magnitude * (S.camLag or 0.01), 0, 0.01)
			local t = os.clock()
			local str = (S.camSwayStr or 0.25) * 0.35
			out = out * CFrame.Angles(math.cos(t * 1.2) * lag * 0.2 * str, math.sin(t * 1.4) * lag * str, 0)
		end
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if not S.camPovLock and S.camBob and hum and hum.RootPart then
			local vel = hum.RootPart.AssemblyLinearVelocity
			local spd = Vector3.new(vel.X, 0, vel.Z).Magnitude
			if spd > 1 then
				bobT = bobT + dt * math.clamp(spd * 0.4, 3, 6)
				local st = math.clamp(S.camBobStr or 0.045, 0, 0.12) * 0.4
				out = out * CFrame.new(math.sin(bobT) * st * 0.2, math.abs(math.sin(bobT * 2)) * st * 0.25, 0)
			else
				bobT = bobT * math.max(0, 1 - dt * 6)
			end
		end
		if S.camBlur and camDBDBlur then
			local mag = (raw.Position - prev.Position).Magnitude
			local tgt = math.clamp(mag * 0.55, 0, 4)
			blurS = blurS + (tgt - blurS) * math.clamp(dt * 8, 0, 1)
			camDBDBlur.Size = blurS
		elseif camDBDBlur then
			blurS = blurS * math.max(0, 1 - dt * 10)
			camDBDBlur.Size = blurS
		end
		if S.camPovLock then
			local a = 1 - math.exp(-(S.camRotSmooth or 0.25) * 10 * dt)
			cam.FieldOfView = cam.FieldOfView + ((S.camPov or 80) - cam.FieldOfView) * a
		end
		cam.CFrame = out
		prev = raw
	end)
end

local invisSeat
local function setCharTrans(ch, t)
	if not ch then return end
	for _, d in ipairs(ch:GetDescendants()) do
		if (d:IsA("BasePart") or d:IsA("Decal")) and d.Name ~= "HumanoidRootPart" then
			pcall(function() d.Transparency = t end)
		end
	end
end
local function setInvisNV(on)
	S.invisNV = on and true or false
	local char = LP.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	if not (hum and root and torso) then return end
	if invisSeat then
		pcall(function() invisSeat:Destroy() end)
		invisSeat = nil
	end
	if not on then
		setCharTrans(char, 0)
		return
	end
	local saved = root.CFrame
	local pos = Vector3.new(-25.95, 84, 3537.55)
	char:MoveTo(pos)
	task.wait(0.15)
	local seat = Instance.new("Seat")
	seat.Name = "SolanaInvisSeat"
	seat.Anchored = false
	seat.CanCollide = false
	seat.Transparency = 1
	seat.CFrame = CFrame.new(pos)
	seat.Parent = workspace
	local weld = Instance.new("Weld")
	weld.Part0 = seat
	weld.Part1 = torso
	weld.Parent = seat
	invisSeat = seat
	task.wait()
	seat.CFrame = saved
	setCharTrans(char, 0.5)
end

local function applySkin(query)
	query = tostring(query or S.skinQuery or "")
	if query == "" then return end
	task.spawn(function()
		local uid
		local n = tonumber(query)
		if n then
			uid = n
		else
			local ok, id = pcall(function()
				return Players:GetUserIdFromNameAsync(query)
			end)
			if ok then uid = id end
		end
		if not uid then return end
		local ok, desc = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(uid)
		end)
		if not (ok and desc) then return end
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		pcall(function()
			hum:ApplyDescription(desc)
		end)
	end)
end

local hitOrig = {}

local function setHitbox(on)
	unbind("hitbox")
	if not on then
		for root, sz in pairs(hitOrig) do
			pcall(function()
				if root.Parent then
					root.Size = sz
					root.Transparency = 1
					root.Material = Enum.Material.Plastic
				end
			end)
		end
		hitOrig = {}
		return
	end
	local lastHb = 0
	bind("hitbox", RunService.Heartbeat:Connect(function()
		if not S.hitbox then return end
		local now = tick()
		if now - lastHb < 0.15 then return end
		lastHb = now
		local sz = S.hitboxSize or 15
		local target = Vector3.new(sz, sz, sz)
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP and plr.Character then
				local root = plr.Character:FindFirstChild("HumanoidRootPart")
				if root and root.Size ~= target then
					if not hitOrig[root] then hitOrig[root] = root.Size end
					pcall(function()
						root.Size = target
						root.Transparency = 0.5
						root.Material = Enum.Material.Neon
						root.Color = Color3.fromRGB(255, 0, 0)
						root.Massless = false
						root.CanCollide = false
					end)
				end
			end
		end
	end))
end

local moonAng, moonZig, moonLock = 0, 0, nil

local function hideMoonPad()
	if moonPadGui then
		pcall(function() moonPadGui:Destroy() end)
		moonPadGui, moonPadBtn = nil, nil
	end
	local function wipe(root)
		if not root then return end
		for _, c in ipairs(root:GetChildren()) do
			if c.Name == "SolanaMoonPad" then
				pcall(function() c:Destroy() end)
			end
		end
	end
	pcall(function()
		if gethui then wipe(gethui()) end
	end)
	pcall(function() wipe(game:GetService("CoreGui")) end)
	pcall(function() wipe(PG) end)
	pcall(function()
		local plr = Players.LocalPlayer
		if plr then wipe(plr:FindFirstChildOfClass("PlayerGui")) end
	end)
end

local function setMoonwalk(on)
	unbind("moon")
	moonLock = nil
	if not on then
		local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.AutoRotate = true end
		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local bv = hrp:FindFirstChild("SolanaMoonVel")
			if bv then bv:Destroy() end
		end
		moonAng, moonZig = 0, 0
		return
	end
	local cam = workspace.CurrentCamera
	if cam then
		local look = cam.CFrame.LookVector
		local f = Vector3.new(look.X, 0, look.Z)
		if f.Magnitude > 0.01 then
			moonLock = f.Unit
			moonAng = math.deg(math.atan2(moonLock.X, moonLock.Z))
		end
	end
	bind("moon", RunService.RenderStepped:Connect(function(dt)
		if not S.moonwalk then return end
		local ch = LP.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if not (hrp and hum) or hum.Health <= 0 then return end
		if not moonLock then
			local cam = workspace.CurrentCamera
			if cam then
				local look = cam.CFrame.LookVector
				local f = Vector3.new(look.X, 0, look.Z)
				if f.Magnitude > 0.01 then
					moonLock = f.Unit
					moonAng = math.deg(math.atan2(moonLock.X, moonLock.Z))
				end
			end
		end
		if not moonLock then return end
		hum.AutoRotate = false
		local cam = workspace.CurrentCamera
		local camRot = cam and (cam.CFrame - cam.CFrame.Position) or nil
		local zig = math.sin(tick() * (S.moonZigSpeed or 36))
		moonZig = zig * (S.moonZigAmt or 78)
		local speed = hum.WalkSpeed
		if speed < 8 then speed = 16 end
		local right = Vector3.new(-moonLock.Z, 0, moonLock.X)
		local dir = moonLock + right * zig * 1.85
		if dir.Magnitude > 0.01 then dir = dir.Unit end
		local bv = hrp:FindFirstChild("SolanaMoonVel")
		if not bv then
			bv = Instance.new("BodyVelocity")
			bv.Name = "SolanaMoonVel"
			bv.MaxForce = Vector3.new(400000, 0, 400000)
			bv.P = 1250
			bv.Parent = hrp
		end
		bv.Velocity = Vector3.new(dir.X * speed, 0, dir.Z * speed)
		hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(moonAng + moonZig), 0)
		hum:Move(dir, false)
		if cam and camRot then
			cam.CFrame = CFrame.new(cam.CFrame.Position) * camRot
		end
	end))
end

local moonPadGui, moonPadBtn

local function refreshMoonPad()
	if moonPadBtn then
		moonPadBtn.Text = S.moonwalk and "ON" or "OFF"
		moonPadBtn.BackgroundColor3 = S.moonwalk and Color3.fromRGB(224, 32, 48) or Color3.fromRGB(28, 28, 28)
	end
end

local function ensureMoonPad()
	if moonPadGui and moonPadGui.Parent then
		refreshMoonPad()
		return
	end
	local parent = PG
	pcall(function()
		if gethui then parent = gethui() end
	end)
	parent = parent or PG
	if not parent then return end
	local sg = Instance.new("ScreenGui")
	sg.Name = "SolanaMoonPad"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.DisplayOrder = 999998
	sg.Parent = parent
	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(118, 72)
	box.Position = UDim2.new(1, -130, 1, -160)
	box.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	box.BorderSizePixel = 0
	box.Active = true
	box.Parent = sg
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(224, 32, 48)
	stroke.Thickness = 1.2
	stroke.Parent = box
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -8, 0, 22)
	title.Position = UDim2.fromOffset(4, 6)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 12
	title.TextColor3 = Color3.fromRGB(244, 244, 245)
	title.Text = "Moonwalk"
	title.Parent = box
	title.Active = true
	do
		local dragging, moved, dragStart, startPos
		title.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				moved = false
				dragStart = input.Position
				startPos = box.Position
			end
		end)
		title.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
				local d = input.Position - dragStart
				if math.abs(d.X) > 6 or math.abs(d.Y) > 6 then moved = true end
				if moved then
					box.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
				end
			end
		end)
	end
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -16, 0, 32)
	btn.Position = UDim2.fromOffset(8, 32)
	btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.Text = "OFF"
	btn.AutoButtonColor = true
	btn.Parent = box
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
	btn.MouseButton1Click:Connect(function()
		local on = not (moonLock ~= nil)
		S.moonwalk = on
		setMoonwalk(on)
		refreshMoonPad()
	end)
	moonPadGui, moonPadBtn = sg, btn
	refreshMoonPad()
end

-- Auto-gen Perfect: SkillCheckPromptGui Line/Goal window (perfectgen.lua)
local PERFECT_WINDOW = 12
local lastHitTime, lastGoalRot, randFlip = 0, nil, false
local cachedAction

local function pressActionButton()
	local playerGui = LP:FindFirstChild("PlayerGui") or PG
	local survivorMob = playerGui and playerGui:FindFirstChild("Survivor-mob")
	local controls = survivorMob and survivorMob:FindFirstChild("Controls")
	local button = controls and (controls:FindFirstChild("action") or cachedAction)
	if button then cachedAction = button end
	if not button then return end

	local fired = false
	pcall(function()
		if getconnections then
			for _, eventName in ipairs({ "MouseButton1Down", "MouseButton1Up", "MouseButton1Click" }) do
				if button[eventName] then
					for _, signal in pairs(getconnections(button[eventName])) do
						if signal.Function then
							signal.Function()
							fired = true
						end
					end
				end
			end
		end
	end)
	if fired then return end

	if VIM then
		pcall(function()
			local position = button.AbsolutePosition + button.AbsoluteSize / 2
			VIM:SendMouseButtonEvent(position.X, position.Y, 0, true, game, 0)
			task.delay(0.05, function()
				VIM:SendMouseButtonEvent(position.X, position.Y, 0, false, game, 0)
			end)
		end)
	end
end

local function firePerfectInput()
	if VIM then
		pcall(function()
			VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
			VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
			VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
		end)
	end
	pressActionButton()
end

local function findSkillCheck()
	local playerGui = LP:FindFirstChild("PlayerGui") or PG
	if not playerGui then return end
	local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
		or playerGui:FindFirstChild("SkillCheckPromptGui-con")
		or playerGui:FindFirstChild("Skillcheck-gen")
	if not gui then
		gui = playerGui:FindFirstChild("SkillCheckPromptGui", true)
	end
	if not gui then return end
	local check = gui:FindFirstChild("Check") or gui:FindFirstChild("Check", true)
	return gui, check
end

local genBypassBusy = false
local genBypassLast = 0
local function doGenBypass()
	local now = tick()
	if now - genBypassLast < 0.25 then return end
	genBypassLast = now
	if genBypassBusy then return end
	local ch = LP.Character
	local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local remotes = RS:FindFirstChild("Remotes")
	local RepairEvent = remotes and remotes:FindFirstChild("Generator") and remotes.Generator:FindFirstChild("RepairEvent")
	if not RepairEvent then return end
	local bestPoint, bestDist, bestGen = nil, 8, nil
	local map = workspace:FindFirstChild("Map")
	local roots = { map }
	if not map then roots = { workspace } end
	for _, root in ipairs(roots) do
		for _, v in ipairs(root:GetChildren()) do
			local gens = {}
			if v.Name == "Generator" or v.Name == "Generators" then
				if v:IsA("Model") and v.Name == "Generator" then
					gens[1] = v
				else
					for _, c in ipairs(v:GetChildren()) do
						if c.Name == "Generator" then gens[#gens+1] = c end
					end
				end
			end
			for _, gen in ipairs(gens) do
				for _, obj in ipairs(gen:GetChildren()) do
					if obj:IsA("BasePart") and obj.Name:find("GeneratorPoint") then
						local d = (hrp.Position - obj.Position).Magnitude
						if d < bestDist then
							bestDist, bestPoint, bestGen = d, obj, gen
						end
					end
				end
			end
		end
	end
	if not bestGen then
		local gens = collectGens and collectGens()
		if gens and gens[1] then bestGen = gens[1].model end
	end
	if not bestGen then return end
	genBypassBusy = true
	for _, point in ipairs(bestGen:GetDescendants()) do
		if point:IsA("BasePart") and point.Name:find("GeneratorPoint") then
			pcall(function() RepairEvent:FireServer(point, true) end)
			pcall(function() RepairEvent:FireServer(point, false) end)
			pcall(function() RepairEvent:FireServer(point, true) end)
		end
	end
	if bestGen:GetAttribute("RepairProgress") ~= nil then
		pcall(function() bestGen:SetAttribute("RepairProgress", 100) end)
	end
	genBypassBusy = false
end




local function setAutoGen(on)
	unbind("agen")
	unbind("agenAdd")
	conns._agen = on
	if not on then
		lastGoalRot, cachedAction = nil, nil
		return
	end
	local function angDelta(a, b)
		local d = (a - b + 180) % 360 - 180
		if d < 0 then d = -d end
		return d
	end
	local function tickGen()
		if not S.autoGen then return end
		local _, check = findSkillCheck()
		if not check or check.Visible == false then
			lastGoalRot = nil
			return
		end
		local line = check:FindFirstChild("Line")
		local goal = check:FindFirstChild("Goal")
		if not line or not goal then return end
		local rot = tonumber(line.Rotation) or 0
		local rot2 = tonumber(goal.Rotation) or 0
		local mode = S.genMode or "Perfect"
		if mode == "Instant" then
			line.Rotation = rot2 + 109
			if tick() - lastHitTime > 0.03 then
				lastHitTime = tick()
				pressActionButton()
				firePerfectInput()
			end
			return
		end
		local hit = false
		if mode == "Random" then
			hit = rot > rot2 + 116 and rot <= rot2 + 159
		else
			hit = rot >= rot2 + 102 and rot <= rot2 + 116
		end
		if hit and tick() - lastHitTime > 0.035 then
			lastHitTime = tick()
			pressActionButton()
			firePerfectInput()
		end
	end
	bind("agen", RunService.RenderStepped:Connect(tickGen))
	local pg = LP:FindFirstChild("PlayerGui") or PG
	if pg then
		bind("agenAdd", pg.ChildAdded:Connect(function(ch)
			if not S.autoGen then return end
			local n = ch.Name
			if n == "SkillCheckPromptGui" or n == "SkillCheckPromptGui-con" or n == "Skillcheck-gen" then
				task.defer(tickGen)
			end
		end))
	end
end

-- ===== Combat from BOLONG-VD (cleaned) =====
S.parryRadius = 14
S.parryDot = 0.6
S.aimFov = 100
S.spearFov = 150
S.spearSpeed = 220

local function charRoot(ch)
	if not ch then return end
	return ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("Torso")
end

local function charHead(ch)
	if not ch then return end
	return ch:FindFirstChild("Head") or charRoot(ch)
end

local function charTorso(ch)
	if not ch then return end
	return ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso") or charRoot(ch)
end

local function aliveHum(ch)
	local h = ch and ch:FindFirstChildOfClass("Humanoid")
	return h and h.Health > 0 and h or nil
end

local function cam()
	return workspace.CurrentCamera
end

local function onScreenFOV(worldPos, fovPx)
	local c = cam()
	if not c or not worldPos then return false, math.huge end
	local v, vis = c:WorldToViewportPoint(worldPos)
	if not vis or v.Z <= 0 then return false, math.huge end
	local vs = c.ViewportSize
	local d = (Vector2.new(v.X, v.Y) - Vector2.new(vs.X * 0.5, vs.Y * 0.5)).Magnitude
	return d <= fovPx, d
end

local function nearestByRole(role, maxDist, fovPx)
	local my = LP.Character and charRoot(LP.Character)
	if not my then return end
	local best, bestD, bestPx = nil, maxDist or 500, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and roleOf(plr) == role then
			local ch = plr.Character
			if aliveHum(ch) then
				local part = charTorso(ch)
				if part then
					local mag = (part.Position - my.Position).Magnitude
					if mag <= (maxDist or 500) then
						local ok, px = onScreenFOV(part.Position, fovPx or 1e9)
						if ok and px < bestPx then
							best, bestD, bestPx = ch, mag, px
						elseif not fovPx and mag < bestD then
							best, bestD = ch, mag
						end
					end
				end
			end
		end
	end
	return best, bestD
end

local function lookAt(pos)
	local c = cam()
	if not c or not pos then return end
	local p = c.CFrame.Position
	c.CFrame = CFrame.lookAt(p, pos)
end

local function velOf(ch)
	local r = charRoot(ch)
	if not r then return Vector3.zero end
	local ok, av = pcall(function() return r.AssemblyLinearVelocity end)
	if ok and typeof(av) == "Vector3" then
		return Vector3.new(av.X, 0, av.Z)
	end
	return Vector3.zero
end

local function predictPos(ch, tof)
	local part = charTorso(ch)
	if not part then return end
	local v = velOf(ch)
	return part.Position + v * math.clamp(tof or 0.2, 0, 1.2)
end

local PARRY_ATTACK = {
	["139369275981139"]=true,["111920872708571"]=true,["78935059863801"]=true,
	["78432063483146"]=true,["74968262036854"]=true,["132817836308238"]=true,
	["133963973694098"]=true,["98163597193511"]=true,["82666958311998"]=true,
	["121216847022485"]=true,
}
local PARRY_LUNGE = {
	["110355011987939"]=true,["105374834496520"]=true,["122812055447896"]=true,
	["118907603246885"]=true,["113255068724446"]=true,["129784271201071"]=true,
	["117042998468241"]=true,["106871536134254"]=true,["135002183282873"]=true,
}
local parryHooks = {}
local parryCd = false

local function getParryRemote()
	local rem = RS:FindFirstChild("Remotes")
	local items = rem and rem:FindFirstChild("Items")
	local dag = items and items:FindFirstChild("Parrying Dagger")
	return dag and dag:FindFirstChild("parry")
end

local function pressSpecialButton(buttonName)
	local playerGui = LP:FindFirstChild("PlayerGui") or PG
	local survivorMob = playerGui and playerGui:FindFirstChild("Survivor-mob")
	local controls = survivorMob and survivorMob:FindFirstChild("Controls")
	local button = controls and controls:FindFirstChild(buttonName)
	if not button then return end
	local fired = false
	pcall(function()
		if getconnections then
			for _, eventName in ipairs({"MouseButton1Down","MouseButton1Up","MouseButton1Click"}) do
				if button[eventName] then
					for _, signal in pairs(getconnections(button[eventName])) do
						if signal.Function then signal.Function() end
					end
				end
			end
			fired = true
		end
	end)
	if fired then return end
	if VIM then
		pcall(function()
			local position = button.AbsolutePosition + button.AbsoluteSize / 2
			VIM:SendMouseButtonEvent(position.X, position.Y, 0, true, game, 0)
			task.delay(0.05, function()
				VIM:SendMouseButtonEvent(position.X, position.Y, 0, false, game, 0)
			end)
		end)
	end
end

local function isKillerFacingPlayer(killerRoot, localRoot)
	local killerLook = Vector3.new(killerRoot.CFrame.LookVector.X, 0, killerRoot.CFrame.LookVector.Z)
	if killerLook.Magnitude < 0.01 then return true end
	killerLook = killerLook.Unit
	local toPlayer = Vector3.new(localRoot.Position.X - killerRoot.Position.X, 0, localRoot.Position.Z - killerRoot.Position.Z)
	if toPlayer.Magnitude < 0.01 then return true end
	toPlayer = toPlayer.Unit
	return killerLook:Dot(toPlayer) >= (S.parryDot or 0.6)
end

local function doParry(killerCharacter)
	if not S.autoParry or parryCd then return end
	local character = LP.Character
	local localRoot = character and character:FindFirstChild("HumanoidRootPart")
	if not character or not localRoot then return end
	if not character:FindFirstChild("Parrying Dagger") then return end
	if character:GetAttribute("IsHooked") or character:GetAttribute("IsCarried") then return end
	local killerRoot = killerCharacter.PrimaryPart or killerCharacter:FindFirstChild("HumanoidRootPart")
	if not killerRoot then return end
	if (killerRoot.Position - localRoot.Position).Magnitude > (S.parryRadius or 13.8) then return end
	if not isKillerFacingPlayer(killerRoot, localRoot) then return end
	parryCd = true
	task.spawn(function()
		local ev = getParryRemote()
		pcall(function() if ev then ev:FireServer() end end)
		if UIS.TouchEnabled then
			pressSpecialButton("Gui-mob")
		elseif VIM then
			VIM:SendMouseButtonEvent(0, 0, 1, true, game, 1)
			VIM:SendMouseButtonEvent(0, 0, 1, false, game, 1)
		end
		task.delay(0.5, function() parryCd = false end)
	end)
end

local function hookKillerCharacter(killerCharacter)
	if not killerCharacter or parryHooks[killerCharacter] then return end
	local humanoid = killerCharacter:FindFirstChildOfClass("Humanoid") or killerCharacter:WaitForChild("Humanoid", 5)
	if not humanoid then return end
	parryHooks[killerCharacter] = humanoid.AnimationPlayed:Connect(function(track)
		if not S.autoParry then return end
		local id = track.Animation and ((track.Animation.AnimationId or ""):match("rbxassetid://(%d+)") or (track.Animation.AnimationId or ""):match("%d+"))
		if id and (PARRY_ATTACK[id] or PARRY_LUNGE[id]) then
			doParry(killerCharacter)
			if S.autoDodge then
				pressSpecialButton("crouch")
				pressSpecialButton("Crouch")
				pressSpecialButton("Gui-mob")
			end
		end
	end)
end

local function hookKillerPlayer(plr)
	if not plr or parryHooks[plr] then return end
	parryHooks[plr] = plr.CharacterAdded:Connect(function(ch) hookKillerCharacter(ch) end)
	if plr.Character then hookKillerCharacter(plr.Character) end
end

local function clearParryHooks()
	for k, c in pairs(parryHooks) do
		pcall(function() c:Disconnect() end)
		parryHooks[k] = nil
	end
	parryCd = false
end

local saimCircle, saimLabel, saimCast, saimOrig, saimPos, saimHooked

local function screenCenter()
	local cam = workspace.CurrentCamera
	if cam then
		return Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5)
	end
	return Vector2.new(0, 0)
end

local function enemyTorso(ch)
	if not ch then return end
	return ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso") or ch:FindFirstChild("HumanoidRootPart")
end

local HIT_PART = "Torso"

local function aimAllowed(plr)
	if not plr or plr == LP then return false end
	local mode = S.aimMode or "Killer"
	if mode == "Killer" then
		return roleOf(plr) == "killer"
	elseif mode == "Survivor" then
		return roleOf(plr) == "survivor"
	elseif mode == "Target" then
		local q = (S.aimName or ""):lower()
		if q == "" then return false end
		return plr.Name:lower():find(q, 1, true) or plr.DisplayName:lower():find(q, 1, true)
	end
	return roleOf(plr) == "killer"
end

local function getClosestEnemyPart(fovPx)
	local cam = workspace.CurrentCamera
	if not cam then return end
	local mid = screenCenter()
	local bestPlr, bestPart, bestD = nil, nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if aimAllowed(plr) then
			local ch = plr.Character
			if aliveHum(ch) then
				local part = enemyTorso(ch)
				if part then
					local sp = cam:WorldToViewportPoint(part.Position)
					local d = (Vector2.new(sp.X, sp.Y) - mid).Magnitude
					if d < bestD then
						bestPlr, bestPart, bestD = plr, part, d
					end
				end
			end
		end
	end
	return bestPlr, bestPart
end

local function findCastRay()
	if type(filtergc) == "function" then
		local ok, f = pcall(filtergc, "function", {Name = "castRay"}, true)
		if ok and type(f) == "function" then return f end
	end
	if type(getgc) == "function" then
		local ok, list = pcall(getgc)
		if ok and type(list) == "table" then
			for i = 1, #list do
				local f = list[i]
				if type(f) == "function" then
					local info = debug.info and debug.info(f, "n")
					if info == "castRay" then return f end
				end
			end
		end
	end
end

local LPH_NO_UPVALUES = function(fn)
	return function(...)
		return fn(...)
	end
end

local function setSilentAim(on)
	unbind("saim")
	unbind("saimfov")
	unbind("saimtgt")
	unbind("saimend")
	unbind("saimhold")
	if saimCircle then
		pcall(function() saimCircle.Visible = false; saimCircle:Remove() end)
		saimCircle = nil
	end
	if saimLabel then
		pcall(function() saimLabel.Visible = false; saimLabel:Remove() end)
		saimLabel = nil
	end
	if not on then
		if saimCast and saimOrig and type(hookfunction) == "function" then
			pcall(function() hookfunction(saimCast, saimOrig) end)
		end
		return
	end
	if typeof(Drawing) == "table" and Drawing.new then
		pcall(function()
			saimCircle = Drawing.new("Circle")
			saimCircle.Color = Color3.fromRGB(255, 0, 0)
			saimCircle.Thickness = 1.5
			saimCircle.Filled = false
			saimCircle.NumSides = 64
			saimCircle.Transparency = 1
			saimCircle.Visible = true
			saimLabel = Drawing.new("Text")
			saimLabel.Color = Color3.fromRGB(255, 0, 0)
			saimLabel.Size = 18
			saimLabel.Center = true
			saimLabel.Outline = true
			saimLabel.Text = "target"
			saimLabel.Visible = false
		end)
	end
	bind("saimfov", RunService.PreRender:Connect(function()
		local mid = screenCenter()
		if saimCircle then
			saimCircle.Radius = S.aimFov or 100
			saimCircle.Position = mid
			saimCircle.Visible = true
		end
		if saimLabel then
			local show = false
			local pos = mid
			local cam = workspace.CurrentCamera
			if cam then
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= LP and roleOf(plr) == "killer" and plr.Character then
						local part = enemyTorso(plr.Character)
						if part then
							local sp = cam:WorldToViewportPoint(part.Position)
							if sp.Z > 0 then
								show = true
								pos = Vector2.new(sp.X, sp.Y - 28)
								break
							end
						end
					end
				end
			end
			saimLabel.Position = pos
			saimLabel.Visible = show
		end
	end))
	local function pistolTarget()
		local my = LP.Character
		local hrp = my and my:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local best, bestD = nil, math.huge
		for _, p in ipairs(Players:GetPlayers()) do
			if aimAllowed(p) and p.Character then
				local ch = p.Character
				if ch:GetAttribute("Knocked") ~= true and ch:GetAttribute("IsHooked") ~= true then
					local hum = ch:FindFirstChildOfClass("Humanoid")
					local tp = enemyTorso(ch)
					if hum and hum.Health > 0 and tp then
						local d = (tp.Position - hrp.Position).Magnitude
						if d < bestD then bestD, best = d, tp end
					end
				end
			end
		end
		return best
	end
	local function pistolGun()
		local char = LP.Character
		local tof = char and char:FindFirstChild("Twist of Fate", true)
		if not tof then return end
		local arm = tof:FindFirstChild("Right Arm")
		if arm then
			return arm:FindFirstChild("EmperorGun") or arm:FindFirstChild("gun") or arm
		end
		return tof
	end
	local function pistolFire()
		if not S.silentAim then return end
		local tp = pistolTarget()
		local my = LP.Character
		local hrp = my and my:FindFirstChild("HumanoidRootPart")
		local w = pistolGun()
		if not (tp and hrp and w) then return end
		local start = hrp.Position
		if my:GetAttribute("IsCarried") then
			start = hrp.Position + hrp.CFrame.LookVector * 2
		end
		local vel = tp.AssemblyLinearVelocity or Vector3.zero
		vel = Vector3.new(vel.X, 0, vel.Z)
		local dist = (tp.Position - start).Magnitude
		local pred = tp.Position + vel * (dist / 400) + Vector3.new(0, -2, 0)
		local dir = pred - start
		if dir.Magnitude < 0.1 then return end
		local ev = RS:FindFirstChild("Remotes")
		ev = ev and ev:FindFirstChild("Items")
		ev = ev and ev:FindFirstChild("Twist of Fate")
		ev = ev and ev:FindFirstChild("Fire")
		if ev then
			pcall(function() ev:FireServer(w, dir.Unit) end)
		end
	end
	local charging, touchIn, laser, lastShot = false, nil, nil, 0
	local function laserClear()
		if laser then pcall(function() laser:Destroy() end) laser = nil end
	end
	local function onMobShoot(input)
		local pg = LP:FindFirstChild("PlayerGui")
		local mob = pg and pg:FindFirstChild("Survivor-mob")
		local ctrl = mob and mob:FindFirstChild("Controls")
		local b = ctrl and ctrl:FindFirstChild("Gui-mob")
		if not (b and b.Visible) then return false end
		local p, a, s = input.Position, b.AbsolutePosition, b.AbsoluteSize
		return p.X >= a.X and p.X <= a.X + s.X and p.Y >= a.Y and p.Y <= a.Y + s.Y
	end
	local function tryFire()
		local now = tick()
		if now - lastShot < 0.2 then return end
		lastShot = now
		pistolFire()
	end
	bind("saimtgt", UIS.InputBegan:Connect(function(input, gp)
		if not S.silentAim then return end
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			charging = true
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 and charging then
			tryFire()
		end
		if input.UserInputType == Enum.UserInputType.Touch and onMobShoot(input) then
			charging = true
			touchIn = input
		end
	end))
	bind("saimend", UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			charging = false
			laserClear()
		end
		if input.UserInputType == Enum.UserInputType.Touch and input == touchIn then
			tryFire()
			charging, touchIn = false, nil
			laserClear()
		end
	end))
	bind("saimhold", RunService.RenderStepped:Connect(function()
		if not (S.silentAim and charging) then
			if laser then laser.Parent = nil end
			return
		end
		local tp = pistolTarget()
		if not tp then
			if laser then laser.Parent = nil end
			return
		end
		if laser then
			laser.Transparency = 1
			laser.Parent = nil
		end
	end))
end

local function setAutoParry(on)
	unbind("parry")
	unbind("parryAdd")
	clearParryHooks()
	if not on then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP then
			parryHooks["team_"..plr.UserId] = plr:GetPropertyChangedSignal("Team"):Connect(function()
				if plr.Team and plr.Team.Name == "Killer" then hookKillerPlayer(plr) end
			end)
			if plr.Team and plr.Team.Name == "Killer" then hookKillerPlayer(plr) end
		end
	end
	bind("parryAdd", Players.PlayerAdded:Connect(function(plr)
		plr:GetPropertyChangedSignal("Team"):Connect(function()
			if S.autoParry and plr.Team and plr.Team.Name == "Killer" then hookKillerPlayer(plr) end
		end)
	end))
end

local dodgeBusy = false
local function setDodgeSpear(on)
	S.dodgeSpear = on and true or false
	unbind("dodgespear")
	if not on then return end
	bind("dodgespear", workspace.ChildAdded:Connect(function(child)
		if not S.dodgeSpear then return end
		if child.Name ~= "Spearprojectile" then return end
		if roleOf(LP) ~= "survivor" then return end
		if dodgeBusy then return end
		task.spawn(function()
			local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			task.wait(0.05)
			local mainPart = child:FindFirstChild("Hitbox") or child:FindFirstChild("Spear1") or child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
			if not mainPart then
				pcall(function() mainPart = child:WaitForChild("Hitbox", 1) end)
			end
			if not mainPart then return end
			local toPlayer = root.Position - mainPart.Position
			if toPlayer.Magnitude < 0.1 then return end
			if mainPart.CFrame.UpVector:Dot(toPlayer.Unit) > 0.85 then
				dodgeBusy = true
				local orig = root.CFrame
				root.CFrame = orig + orig.RightVector * 8
				task.wait(1)
				if root.Parent then root.CFrame = orig end
				dodgeBusy = false
			end
		end)
	end))
end

local flaskLaser, flaskHooked
local function closestSurvivorHRP()
	local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not my then return end
	local best, bestD = nil, 200
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and roleOf(p) == "survivor" and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local d = (hrp.Position - my.Position).Magnitude
				if d < bestD then bestD, best = d, hrp end
			end
		end
	end
	return best
end
local function setLockHidden(on)
	S.lockHidden = on and true or false
	unbind("lockhid")
	if not on then return end
	bind("lockhid", RunService.RenderStepped:Connect(function()
		if not S.lockHidden then return end
		local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		local cam = workspace.CurrentCamera
		if not (my and cam) then return end
		local maxd = S.lockHiddenDist or 50
		local best, bestD = nil, maxd + 1
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LP and roleOf(p) == "survivor" and p.Character then
				local ch = p.Character
				if ch:GetAttribute("Knocked") ~= true and ch:GetAttribute("IsHooked") ~= true then
					local hrp = ch:FindFirstChild("HumanoidRootPart")
					local hum = ch:FindFirstChildOfClass("Humanoid")
					if hrp and hum and hum.Health > 0 then
						local d = (hrp.Position - my.Position).Magnitude
						if d <= maxd and d < bestD then
							bestD, best = d, hrp
						end
					end
				end
			end
		end
		if best then
			cam.CFrame = CFrame.new(cam.CFrame.Position, best.Position)
		end
	end))
end
local function setFlaskAim(on)
	S.flaskAim = on and true or false
	unbind("flasklaser")
	if flaskLaser then
		pcall(function() flaskLaser:Destroy() end)
		flaskLaser = nil
	end
	if not on then return end
	if not flaskHooked and type(hookmetamethod) == "function" then
		pcall(function()
			local old
			old = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				if S.flaskAim and method == "FireServer" then
					local n = self and self.Name
					if n == "ThrowFlask" then
						local a = {...}
						local tgt = closestSurvivorHRP()
						if tgt and a[2] and typeof(a[2]) == "Vector3" then
							a[1] = (tgt.Position - a[2]).Unit
							return old(self, unpack(a))
						end
					end
				end
				return old(self, ...)
			end)
			flaskHooked = true
		end)
	end
	bind("flasklaser", RunService.RenderStepped:Connect(function()
		if not S.flaskAim then
			if flaskLaser then flaskLaser.Transparency = 1 end
			return
		end
		local tgt = closestSurvivorHRP()
		local origin = LP.Character and (LP.Character:FindFirstChild("Head") or LP.Character:FindFirstChild("HumanoidRootPart"))
		if not (tgt and origin) then
			if flaskLaser then flaskLaser.Transparency = 1 end
			return
		end
		if not flaskLaser then
			flaskLaser = Instance.new("Part")
			flaskLaser.Name = "SolanaFlaskLaser"
			flaskLaser.Anchored = true
			flaskLaser.CanCollide = false
			flaskLaser.Material = Enum.Material.Neon
			flaskLaser.Color = Color3.fromRGB(80, 255, 160)
			flaskLaser.Parent = workspace
		end
		local a, b = origin.Position, tgt.Position
		local dist = (b - a).Magnitude
		if dist > 0.1 then
			flaskLaser.Size = Vector3.new(0.12, 0.12, dist)
			flaskLaser.CFrame = CFrame.new((a + b) / 2, b)
			flaskLaser.Transparency = 1
		end
	end))
end

local function setSpearSilent(on)
	unbind("spear")
	if not on then return end
	bind("spear", RunService.RenderStepped:Connect(function()
		if not S.spearSilent then return end
		local ch = LP.Character
		if not ch then return end
		local spearOn = false
		pcall(function() spearOn = ch:GetAttribute("spearmode") == true end)
		if not spearOn then return end
		local tgt = nearestByRole("survivor", 175, S.spearFov)
		if not tgt then return end
		local dist = 0
		local my = charRoot(ch)
		local hp = charHead(tgt)
		if my and hp then dist = (hp.Position - my.Position).Magnitude end
		local tof = dist / math.max(S.spearSpeed, 1)
		local pos = predictPos(tgt, tof + 0.05)
		if pos then lookAt(pos) end
	end))
end

local savedCF
local gateToolInst
local zoomOrig = {}
local fakeNameOrig

local function setAntiFail(on)
	unbind("afail")
	if not on then return end
	bind("afail", RunService.Heartbeat:Connect(function()
		if not S.antiFail then return end
		local pg = LP:FindFirstChild("PlayerGui") or PG
		if not pg then return end
		for _, n in ipairs({"Skillcheck-gen", "SkillCheck-gen", "SkillcheckGen"}) do
			local g = pg:FindFirstChild(n)
			if g and g:IsA("ScreenGui") then g.Enabled = false end
		end
	end))
end

local function installNamecall()
	if conns._ncall then return end
	if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" then return end
	pcall(function()
		local old
		old = hookmetamethod(game, "__namecall", function(self, ...)
			local method = getnamecallmethod()
			if method == "FireServer" and typeof(checkcaller) == "function" and not checkcaller() then
				local n = self and self.Name
				if S.noFall and n == "Fall" then return end
				if S.antiBlind and n == "GotBlinded" and roleOf(LP) == "killer" then return end
			end
			return old(self, ...)
		end)
		conns._ncall = true
	end)
end

local function setNoTurn(on)
	unbind("noturn")
	if not on then return end
	bind("noturn", RunService.RenderStepped:Connect(function()
		if not S.noTurn then return end
		if roleOf(LP) ~= "survivor" then return end
		local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
		if h and h.WalkSpeed >= 10 and h.WalkSpeed < 16 then
			h.WalkSpeed = 16
		end
	end))
end

local function setGateTool(on)
	if gateToolInst then pcall(function() gateToolInst:Destroy() end) gateToolInst = nil end
	if not on then return end
	local pack = LP:FindFirstChild("Backpack")
	if not pack then return end
	local t = Instance.new("Tool")
	t.Name = "Gate"
	t.RequiresHandle = false
	t.CanBeDropped = true
	t.Parent = pack
	t.Activated:Connect(function()
		pcall(function()
			RS.Remotes.Items.Gate.gate:FireServer()
		end)
	end)
	gateToolInst = t
end

local function instantEscape()
	if roleOf(LP) ~= "survivor" then notify("Escape", "Survivor only") return end
	local ch = LP.Character
	if not ch then return end
	local map = workspace:FindFirstChild("Map") or workspace
	for _, d in ipairs(map:GetDescendants()) do
		local n = d.Name:lower()
		if n:find("finish") or n:find("fininsh") or n == "exitgate" then
			local p = d:IsA("BasePart") and d.Position or (d:IsA("Model") and d:GetPivot().Position)
			if p then ch:MoveTo(p) notify("Escape", "Moved") return end
		end
	end
	notify("Escape", "No finish")
end

local function teleportFarthestGen()
	teleportRandomGen()
end

local function teleportSaved()
	local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if savedCF and hrp then hrp.CFrame = savedCF notify("TP", "Saved pos") else notify("TP", "No save") end
end

local function teleportPlayerNamed(name)
	if not name or name == "" then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Name:lower():find(name:lower()) or plr.DisplayName:lower():find(name:lower()) then
			local r = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			local me = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
			if r and me then me.CFrame = r.CFrame + Vector3.new(0, 3, 0) notify("TP", plr.Name) return end
		end
	end
	notify("TP", "Not found")
end

local function setKillAll(on)
	S.killAll = on and true or false
	unbind("killall")
	if not on then return end
	local tgt, last = nil, 0
	bind("killall", RunService.Heartbeat:Connect(function()
		if not S.killAll then return end
		if roleOf(LP) ~= "killer" then return end
		local now = tick()
		if now - last < 0.05 then return end
		last = now
		local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		local th = tgt and tgt:FindFirstChildOfClass("Humanoid")
		if not tgt or not th or th.Health <= 35 then
			tgt = nil
			local best, bd = nil, math.huge
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LP and roleOf(plr) == "survivor" and plr.Character then
					local hum = plr.Character:FindFirstChildOfClass("Humanoid")
					local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
					if hum and hrp and hum.Health > 30 then
						local d = (hrp.Position - root.Position).Magnitude
						if d < bd then bd, best = d, plr.Character end
					end
				end
			end
			tgt = best
		end
		if not tgt then return end
		local hrp = tgt:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local pred = hrp.Position + (hrp.AssemblyLinearVelocity * 0.15)
		root.CFrame = CFrame.new(pred + hrp.CFrame.LookVector * -3, pred)
		pcall(function()
			RS.Remotes.Attacks.BasicAttack:FireServer(false)
		end)
	end))
end

local function setAutoSlash(on)
	unbind("slash")
	if not on then return end
	bind("slash", RunService.Heartbeat:Connect(function()
		if not S.autoSlash then return end
		if roleOf(LP) ~= "killer" then return end
		local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if not my then return end
		local range = S.slashRange or 12
		if S.slashMode == "Legit" then range = math.min(range, 6) end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP and roleOf(plr) == "survivor" and plr.Character then
				local r = plr.Character:FindFirstChild("HumanoidRootPart")
				local h = plr.Character:FindFirstChildOfClass("Humanoid")
				if r and h and h.MaxHealth > 0 and (h.Health / h.MaxHealth) > 0.25 then
					if (r.Position - my.Position).Magnitude <= range then
						pcall(function()
							RS.Remotes.Attacks.BasicAttack:FireServer(false)
						end)
						break
					end
				end
			end
		end
	end))
end

local function setAntiStun(on)
	unbind("stun")
	if not on then return end
	bind("stun", RunService.Heartbeat:Connect(function()
		if not S.antiStun then return end
		if roleOf(LP) ~= "killer" then return end
		local ch = LP.Character
		local h = ch and ch:FindFirstChildOfClass("Humanoid")
		if not (ch and h) then return end
		local sp = ch:GetAttribute("Speed")
		if S.speedOn then return end
		if typeof(sp) == "number" and h.WalkSpeed > 0 and h.WalkSpeed < 25 then
			h.WalkSpeed = sp
		end
	end))
end

local function setAntiBlind(on)
	installNamecall()
	unbind("blindgui")
	if not on then return end
	bind("blindgui", RunService.Heartbeat:Connect(function()
		if not S.antiBlind then return end
		local pg = LP:FindFirstChild("PlayerGui") or PG
		if not pg then return end
		local b = pg:FindFirstChild("Blind", true)
		if b then
			if b:IsA("ScreenGui") then b.Enabled = false
			elseif b:IsA("GuiObject") then b.Visible = false end
		end
	end))
end

local function setNoFog(on)
	if on then
		Lighting.FogEnd = 1e6
		Lighting.FogStart = 1e6
	end
end

local function setInfZoom(on)
	if on then
		zoomOrig.max = LP.CameraMaxZoomDistance
		zoomOrig.min = LP.CameraMinZoomDistance
		LP.CameraMaxZoomDistance = 1e6
		LP.CameraMinZoomDistance = 0.5
	else
		if zoomOrig.max then LP.CameraMaxZoomDistance = zoomOrig.max end
		if zoomOrig.min then LP.CameraMinZoomDistance = zoomOrig.min end
	end
end

local function setFakeName(on)
	local ch = LP.Character
	local head = ch and ch:FindFirstChild("Head")
	local lab = head and head:FindFirstChild("OverheadGui")
	lab = lab and lab:FindFirstChild("Info")
	lab = lab and lab:FindFirstChild("PlayerDisplayName")
	if not lab then return end
	if on then
		if not fakeNameOrig then fakeNameOrig = lab.Text end
		lab.Text = "SOLANA"
	elseif fakeNameOrig then
		lab.Text = fakeNameOrig
	end
end

local function setFpsBoost(on)
	for _, d in ipairs(workspace:GetDescendants()) do
		pcall(function()
			if d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail") or d:IsA("Fire") or d:IsA("Smoke") then
				d.Enabled = not on
			end
		end)
	end
	pcall(function()
		Lighting.GlobalShadows = not on
		Lighting.EnvironmentDiffuseScale = on and 0 or 1
	end)
end

local function hopEmpty()
	local TS = game:GetService("TeleportService")
	pcall(function()
		local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
		local data = game:GetService("HttpService"):JSONDecode(game:HttpGet(url))
		local best
		if data and data.data then
			for _, s in ipairs(data.data) do
				if s.id ~= game.JobId and s.playing < s.maxPlayers then
					if not best or s.playing < best.playing then best = s end
				end
			end
		end
		if best then
			TS:TeleportToPlaceInstance(game.PlaceId, best.id, LP)
		else
			TS:Teleport(game.PlaceId, LP)
		end
	end)
end

local function setPerfHud(on)
	unbind("perf")
	if conns._perfGui then pcall(function() conns._perfGui:Destroy() end) conns._perfGui = nil end
	if not on then return end
	local parent
	pcall(function() if gethui then parent = gethui() end end)
	parent = parent or PG
	local sg = Instance.new("ScreenGui")
	sg.Name = "SolanaPerf"
	sg.ResetOnSpawn = false
	sg.Parent = parent
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = UDim2.fromOffset(8, 8)
	t.Size = UDim2.fromOffset(220, 20)
	t.Font = Enum.Font.Code
	t.TextSize = 13
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextColor3 = Color3.fromRGB(255, 80, 80)
	t.Parent = sg
	conns._perfGui = sg
	local n, last = 0, tick()
	bind("perf", RunService.RenderStepped:Connect(function()
		n = n + 1
		if tick() - last >= 1 then
			local ping = 0
			pcall(function()
				ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			t.Text = string.format("FPS %d  PING %dms", n, ping)
			n, last = 0, tick()
		end
	end))
end

local function setBypassAdmin(on)
	unbind("admin")
	if not on then return end
	local function check(plr)
		pcall(function()
			if plr:GetRankInGroup(0) then end
			local n = (plr.Name .. " " .. (plr.DisplayName or "")):lower()
			if n:find("admin") or n:find("mod") then
				game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
			end
		end)
	end
	for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then check(p) end end
	bind("admin", Players.PlayerAdded:Connect(check))
end

-- Tabs
local function loadDame(url)
	task.spawn(function()
		pcall(function()
			loadstring(game:HttpGet(url))()
		end)
	end)
end

local TabS = Window:CreateTab("Survivor", true, false)
local TabK = Window:CreateTab("Killer", false, false)
local TabE = Window:CreateTab("Esp & World", false, false)
local TabM = Window:CreateTab("Misc", false, false)
local TabC = Window:CreateTab("Settings", false, false)

local PS = TabS:CreatePage("Main")
local sc = PS:CreateSection("Combat")
sc:AddToggle("Silent Aim", false, function(v) S.silentAim=v; setSilentAim(v) end, {Title="Silent Aim", Description="castRay ke Torso. Mode Killer/Survivor/Target."})
sc:AddDropdown("Aim Mode", {"Killer","Survivor","Target"}, false, function(s) S.aimMode=s end, {Title="Aim Mode", Description="Killer / Survivor / Target username."})
sc:AddTextbox("Aim Target", "username", function(t) S.aimName=t end, {Title="Aim Target", Description="Username/display untuk mode Target."})
sc:AddSlider("Aim FOV", 100, 1000, 100, function(v) S.aimFov=v end, {Title="Aim FOV", Description="Radius circle tengah layar."})
sc:AddSlider("Camera FOV", 50, 130, 120, function(v)
	S.camFov = v
	S.camFovOn = true
	unbind("camfov")
	bind("camfov", RunService.Heartbeat:Connect(function()
		if not S.camFovOn then return end
		local c = workspace.CurrentCamera
		if c then c.FieldOfView = S.camFov or 120 end
	end))
end, {Title="Camera FOV", Description="Loop FieldOfView 50–130 tiap map. Recommended 120."})
sc:AddToggle("Auto Parry", false, function(v) S.autoParry=v; setAutoParry(v or S.autoDodge); notify("Auto Parry", v and "ON" or "OFF") end, {Title="Auto Parry", Description="Hook anim attack/lunge killer, fire remotes parry. OFF disconnect semua hook."})
sc:AddSlider("Parry Radius", 4, 40, 14, function(v) S.parryRadius=v end, {Title="Parry Radius", Description="Jarak max HRP ke killer untuk parry."})
sc:AddToggle("Auto Dodge", false, function(v) S.autoDodge=v; setAutoParry(S.autoParry or v); notify("Dodge", v and "ON" or "OFF") end, {Title="Auto Dodge", Description="Saat anim attack terdeteksi, tekan crouch. Hook sama dengan parry."})
local sg = PS:CreateSection("Generator")
sg:AddToggle("Auto Generator", false, function(v) S.autoGen=v; setAutoGen(v) end, {Title="Auto Generator", Description="Perfect / Random / Instant. OFF stop."})
sg:AddDropdown("Gen Mode", {"Perfect","Random","Instant"}, false, function(s) S.genMode=s end, {Title="Gen Mode", Description="Perfect 102-116. Random 116-159. Instant snap Line +109."})
sg:AddToggle("Anti-Fail Gen", false, function(v) S.antiFail=v; setAntiFail(v) end, {Title="Anti-Fail Generator", Description="Disable GUI Skillcheck-gen supaya check tidak gagal. OFF reconnect off."})
sg:AddButton("Gen Nearest", function() teleportToGenerator() end, {Title="Gen Nearest", Description="TP Model Generator terdekat (Map)."})
sg:AddButton("Gen Random", function() teleportRandomGen() end, {Title="Gen Random", Description="TP random Generator."})






sg:AddToggle("Auto Exit Gate", false, function(v) if v then loadDame("https://pastefy.app/XzVuwQsL/raw") end end)
sg:AddToggle("Auto Pallet", false, function(v) if v then loadDame("https://pastefy.app/0zkVJ1SR/raw") end end)
local sx = PS:CreateSection("Extra")
sx:AddToggle("No Fall Damage", false, function(v) S.noFall=v; installNamecall() end, {Title="No Fall Damage", Description="Block remote Fall saat ON. Namecall tetap terpasang sekali."})
sx:AddToggle("No Turn Limit", false, function(v) S.noTurn=v; setNoTurn(v) end, {Title="No Turn Speed Limit", Description="Paksa WalkSpeed 16 saat belok. OFF disconnect RenderStepped."})
sx:AddButton("Instant Escape", function() instantEscape() end, {Title="Instant Escape", Description="MoveTo finish/exit di Map. Survivor only."})
sx:AddToggle("Invisibility", false, function(v) setInvisNV(v) end, {Title="Invisibility", Description="Seat weld invis. OFF cleanup seat."})

local PK = TabK:CreatePage("Main")
local kh = PK:CreateSection("Hitbox")
kh:AddToggle("Hitbox", false, function(v)
	S.hitbox=v; setHitbox(v); notify("Hitbox", v and "ON" or "OFF")
end, {Title="Hitbox", Description="Resize HRP lawan jadi kubus Neon. OFF restore size + disconnect Heartbeat."})
kh:AddSlider("Size", 2, 25, 15, function(v) S.hitboxSize=v end, {Title="Size", Description="Sisi hitbox (stud). Default 15."})
local ks = PK:CreateSection("Spear")
ks:AddToggle("Spear Silent Aim", false, function(v) S.spearSilent=v; setSpearSilent(v); notify("Spear", v and "ON" or "OFF") end, {Title="Spear Silent Aim (Veil)", Description="Kamera lookAt survivor + lead. OFF disconnect RenderStepped."})
ks:AddSlider("Spear FOV", 30, 500, 150, function(v) S.spearFov=v end, {Title="Spear FOV", Description="Batas sudut target spear."})
local ka = PK:CreateSection("Attack")
ka:AddToggle("Auto Slash", false, function(v) S.autoSlash=v; setAutoSlash(v) end, {Title="Auto Slash", Description="Fire BasicAttack jika survivor dalam range. OFF disconnect."})
ka:AddDropdown("Slash Mode", {"Rage","Legit"}, false, function(s) S.slashMode=s end, {Title="Auto Slash Mode", Description="Rage pakai slider range. Legit max 6."})
ka:AddSlider("Attack Range", 4, 20, 12, function(v) S.slashRange=v end, {Title="Attack Range", Description="Default 12."})
ka:AddToggle("Anti Blind", false, function(v) S.antiBlind=v; setAntiBlind(v) end, {Title="Anti Blind", Description="Block GotBlinded + hide GUI Blind. OFF stop GUI loop."})
ka:AddToggle("Anti Stun", false, function(v) S.antiStun=v; setAntiStun(v) end, {Title="Anti Stun", Description="Restore WalkSpeed dari attribute Speed. OFF disconnect."})
ks:AddToggle("Silent Aim Veil", false, function(v) if v then loadDame("https://pastefy.app/PTy6Z1FS/raw") end end)
ks:AddToggle("Silent Aim The Cure", false, function(v) setFlaskAim(v) end, {Title="Silent Aim The Cure", Description="Hook ThrowFlask ke survivor terdekat + laser. OFF hapus laser."})
ka:AddToggle("Lock Target Hidden", false, function(v) setLockHidden(v) end, {Title="Lock Target Hidden", Description="Kamera lookAt survivor terdekat. Skip knocked/hooked. OFF disconnect."})
ka:AddSlider("Lock Dist", 10, 80, 50, function(v) S.lockHiddenDist=v end, {Title="Lock Dist", Description="Max jarak lock. Default 50."})
ka:AddToggle("Kill all Survivor", false, function(v) setKillAll(v) end, {Title="Kill all Survivor", Description="TP belakang survivor HP>30 + BasicAttack. Risiko ban."})

local PE = TabE:CreatePage("Main")
local eo = PE:CreateSection("Objects")
eo:AddToggle("Generator ESP", false, function(v) S.espGen=v; setGenESP(v) end, {Title="Generator ESP", Description="Highlight + % repair. Model Generator. OFF hapus."})
eo:AddToggle("Window ESP", false, function(v) S.espWindow=v; setObjESP() end, {Title="Window ESP", Description="Highlight window/vault. Tetap scan map baru."})
eo:AddToggle("Hook ESP", false, function(v) S.espHook=v; setHookESP(v) end, {Title="Hook ESP", Description="Highlight Hook / HookPoint / Spike. OFF hapus."})
eo:AddToggle("Pallet ESP", false, function(v) S.espPallet=v; setObjESP() end, {Title="Pallet ESP", Description="Highlight pallet."})
local ep = PE:CreateSection("Players")
ep:AddToggle("Killer ESP", false, function(v)
	S.espKiller=v; setPlayerESP("espKiller", "killer", "SolanaKESP", Color3.fromRGB(255,60,60))
end, {Title="Killer ESP", Description="Highlight karakter killer. OFF unbind + clearHL."})
ep:AddToggle("Survivor ESP", false, function(v)
	S.espSurvivor=v; setPlayerESP("espSurvivor", "survivor", "SolanaSESP", Color3.fromRGB(60,190,255))
end, {Title="Survivor ESP", Description="Highlight karakter survivor. OFF unbind + clearHL."})
local et = PE:CreateSection("Tracer")
et:AddToggle("Tracer Killer", false, function(v) S.tracerKill=v; setTracers() end, {Title="Tracer Killer", Description="Garis Drawing ke killer. OFF hapus line."})
et:AddToggle("Tracer Survivor", false, function(v) S.tracerSurv=v; setTracers() end, {Title="Tracer Survivor", Description="Garis Drawing ke survivor. OFF hapus line."})
et:AddToggle("Tracer Generator", false, function(v) S.tracerGen=v; setTracers() end, {Title="Tracer Generator", Description="Garis Drawing ke generator. OFF hapus line."})
local ew = PE:CreateSection("World")
ew:AddToggle("Fullbright", false, function(v) S.fullbright=v; setFB(v) end, {Title="Fullbright", Description="Naikkan Brightness, hilangkan fog. OFF restore lighting."})
ew:AddToggle("No Fog", false, function(v) S.noFog=v; setNoFog(v) end, {Title="No Fog", Description="FogEnd/Start = 1e6."})


eo:AddToggle("Esp Window", false, function(v) if v then loadDame("https://pastefy.app/ZYPY6VhY/raw") end end)
eo:AddToggle("Esp Pallet", false, function(v) if v then loadDame("https://pastefy.app/e7KdU389/raw") end end)
eo:AddToggle("Esp Hook", false, function(v) if v then loadDame("https://pastefy.app/CnsGihQ5/raw") end end)
ew:AddToggle("Load Full Bright", false, function(v) if v then loadDame("https://pastefy.app/rIZrCQYM/raw") end end)
ew:AddToggle("Load No Fog", false, function(v) if v then loadDame("https://pastefy.app/UnrfVOFk/raw") end end)

local PM = TabM:CreatePage("Main")
local mm = PM:CreateSection("Move")
mm:AddToggle("Speed", false, function(v) S.speedOn=v; setSpeed(v) end, {Title="Speed", Description="Loop set WalkSpeed. OFF disconnect Heartbeat."})
mm:AddSlider("WalkSpeed", 16, 150, 24, function(v) S.walkSpeed=v; if S.speedOn then applyWalkSpeed() end end, {Title="Walk Speed", Description="Nilai speed saat toggle Speed ON."})
mm:AddToggle("Noclip", false, function(v) S.noclip=v; setNoclip(v) end, {Title="Noclip", Description="CanCollide false tiap Stepped. OFF disconnect."})
mm:AddToggle("Moonwalk", false, function(v)
	if v then
		S.moonwalk = false
		setMoonwalk(false)
		ensureMoonPad()
		refreshMoonPad()
	else
		S.moonwalk = false
		setMoonwalk(false)
		hideMoonPad()
	end
end, {Title="Moonwalk", Description="Toggle hub hanya munculkan pad. Aktifkan script lewat tombol pad."})
mm:AddSlider("Zigzag Speed", 4, 24, 11, function(v) S.moonZigSpeed=v end, {Title="Zigzag Speed", Description="Frekuensi zigzag moonwalk."})
mm:AddSlider("Zigzag Amount", 10, 80, 48, function(v) S.moonZigAmt=v end, {Title="Zigzag Amount", Description="Lebar zigzag (derajat)."})
local mc = PM:CreateSection("Camera DBD")
mc:AddToggle("Smooth Camera", false, function(v) S.camDBD=v; setCamDBD(v) end, {Title="Camera DBD", Description="Smooth + sway + bob + blur. OFF unbind camera."})
mc:AddSlider("Smoothness", 8, 30, 22, function(v) S.camSmooth=v end, {Title="Camera Smoothness"})
mc:AddSlider("Lag", 0, 10, 3, function(v) S.camLag=v/100 end, {Title="Camera Lag", Description="0–0.10"})
mc:AddToggle("Camera Sway", true, function(v) S.camSway=v end, {Title="Camera Sway"})
mc:AddSlider("Sway Strength", 0, 100, 25, function(v) S.camSwayStr=v/100 end)
mc:AddToggle("Head Bob", true, function(v) S.camBob=v end, {Title="Head Bob"})
mc:AddSlider("Bob Strength", 0, 12, 5, function(v) S.camBobStr=v/100 end)
mc:AddToggle("Motion Blur", true, function(v) S.camBlur=v end, {Title="Motion Blur"})
mc:AddToggle("POV Lock", false, function(v) S.camPovLock=v end, {Title="POV Lock"})
mc:AddSlider("Target POV", 40, 140, 110, function(v) S.camPov=v end)
mc:AddSlider("Rotation Smooth", 10, 100, 25, function(v) S.camRotSmooth=v/100 end)


local mu = PM:CreateSection("Util")
mu:AddTextbox("Skin User", "username / id", function(t) S.skinQuery=t end, {Title="Skin User", Description="Username atau UserId. Tidak scan map."})
mu:AddButton("Apply Skin", function() applySkin(S.skinQuery) end, {Title="Apply Skin", Description="ApplyDescription dari user itu. Tanpa scan."})
mu:AddToggle("Anti AFK", false, function(v) S.antiAfk=v; setAFK(v) end, {Title="Anti AFK", Description="Idled:Disconnect VirtualUser. OFF unbind."})
mu:AddButton("Rejoin", function()
	pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
end)
mu:AddButton("Respawn", function()
	pcall(function() local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid"); if h then h.Health=0 end end)
end)
mu:AddButton("Hop Empty Server", function() hopEmpty() end, {Title="Hop Empty", Description="TP ke server public dengan player paling sedikit."})
mu:AddButton("Save Position", function()
	local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if hrp then savedCF = hrp.CFrame notify("Pos", "Saved") end
end, {Title="Save Position", Description="Simpan CFrame HRP saat ini."})
mu:AddButton("TP Saved Position", function() teleportSaved() end, {Title="TP Saved", Description="Kembali ke CFrame yang disimpan."})
mu:AddTextbox("TP Player", "name", function(t) teleportPlayerNamed(t) end, {Title="TP Player", Description="Ketik nama/display, TP ke HRP mereka."})
mu:AddToggle("Infinite Zoom", false, function(v) S.infZoom=v; setInfZoom(v) end, {Title="Infinite Zoom", Description="CameraMaxZoom huge. OFF restore."})





local PC = TabC:CreatePage("Main")
local cu = PC:CreateSection("UI")
cu:AddToggle("Transparency", false, function(v)
	pcall(function() Window:SetTransparency(v and 0.25 or 0) end)
end, {Title="Transparency"})
pcall(function() PC:CreateSection("Config"):AddConfigManager("SolanaHubVD") end)

notify("SOLANA HUB", "Loaded")
print("[SOLANA HUB] ZyronX local UI")

end)
if not _hubOk then
	warn("[SOLANA HUB] ERROR: ", _hubErr)
	pcall(function()
		local sg = Instance.new("ScreenGui")
		sg.Name = "SolanaHub_Error"
		sg.ResetOnSpawn = false
		sg.DisplayOrder = 999999
		local parent
		pcall(function() if gethui then parent = gethui() end end)
		if not parent then pcall(function() parent = game:GetService("CoreGui") end) end
		if not parent then
			local plr = game:GetService("Players").LocalPlayer
			parent = plr and plr:FindFirstChild("PlayerGui")
		end
		if not parent then return end
		sg.Parent = parent
		local f = Instance.new("Frame")
		f.Size = UDim2.fromOffset(300, 100)
		f.Position = UDim2.new(0.5, -150, 0.15, 0)
		f.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		f.Parent = sg
		Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
		local t = Instance.new("TextLabel")
		t.BackgroundTransparency = 1
		t.Size = UDim2.new(1, -16, 1, -16)
		t.Position = UDim2.fromOffset(8, 8)
		t.TextColor3 = Color3.fromRGB(255, 90, 90)
		t.TextWrapped = true
		t.TextSize = 13
		t.Font = Enum.Font.Gotham
		t.Text = "SOLANA HUB error:\n" .. tostring(_hubErr)
		t.Parent = f
	end)
end
