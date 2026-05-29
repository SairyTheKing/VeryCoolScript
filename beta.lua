-- Improved Gradient UI Library v2
-- Dark theme, modern design, FingerPaint font, mobile-friendly
-- Credits to original authors for the foundation
-- Version: 2.0.0
-- GitHub: https://raw.githubusercontent.com/SairyTheKing/VeryCoolScript/refs/heads/main/beta.lua

--[[
    LOADSTRING USAGE:
    local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/SairyTheKing/VeryCoolScript/refs/heads/main/beta.lua"))()

    OR for auto-updates, use this wrapper in your main script:

    local function getLibrary()
        local success, result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/SairyTheKing/VeryCoolScript/refs/heads/main/beta.lua"))()
        end)
        if success then
            return result
        else
            warn("Failed to load library from GitHub, using local fallback")
            -- fallback to require(path) here
        end
    end
    local lib = getLibrary()
]]

local libraryVersion = "2.0.0"

if game:GetService("CoreGui"):FindFirstChild("ImprovedGradientLib") then
    game:GetService("CoreGui").ImprovedGradientLib:Destroy()
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local library = {
    windows = 0,
    flags = {},
    theme = {
        background = Color3.fromRGB(14, 14, 18),
        foreground = Color3.fromRGB(22, 22, 28),
        surface = Color3.fromRGB(30, 30, 38),
        accent = Color3.fromRGB(138, 99, 255),
        accentHover = Color3.fromRGB(160, 125, 255),
        accentDark = Color3.fromRGB(100, 70, 200),
        textPrimary = Color3.fromRGB(245, 245, 250),
        textSecondary = Color3.fromRGB(170, 170, 180),
        textDark = Color3.fromRGB(110, 110, 120),
        border = Color3.fromRGB(45, 45, 55),
        success = Color3.fromRGB(90, 230, 150),
        error = Color3.fromRGB(240, 90, 90),
        warning = Color3.fromRGB(255, 190, 70),
        fontTitle = Enum.Font.FingerPaint,
        fontBody = Enum.Font.Gotham,
        fontMono = Enum.Font.Gotham,
        cornerRadius = UDim.new(0, 10),
        elementHeight = isMobile and 48 or 36,
        spacing = isMobile and 10 or 6,
        animationSpeed = 0.25,
        touchPadding = isMobile and 12 or 6
    }
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ImprovedGradientLib"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Utility functions
local function tween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or library.theme.animationSpeed
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out
    local tw = TweenService:Create(instance, TweenInfo.new(duration, easingStyle, easingDirection), properties)
    tw:Play()
    return tw
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or library.theme.cornerRadius
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or library.theme.border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function createShadow(parent, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 50, 50)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    return shadow
end

local function createRipple(parent, position, touchSize)
    local ripple = Instance.new("Frame")
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.85
    ripple.BorderSizePixel = 0
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, position.X, 0, position.Y)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.ZIndex = parent.ZIndex + 5
    createCorner(ripple, UDim.new(1, 0))
    ripple.Parent = parent

    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * (touchSize or 2.5)
    tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}, 0.6)
    task.delay(0.6, function()
        if ripple then ripple:Destroy() end
    end)
end

local function vibrate()
    if isMobile then
        pcall(function()
            GuiService:BroadcastNotification("", Enum.NotificationType.BehaviorHealth)
        end)
    end
end


-- Auto-update checker (optional, call if you want version checking)
function library:CheckForUpdates(url)
    url = url or "https://raw.githubusercontent.com/SairyTheKing/VeryCoolScript/refs/heads/main/beta.lua"
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local remoteVersion = result:match('local libraryVersion = "(.-)"')
        if remoteVersion and remoteVersion ~= libraryVersion then
            warn("[GradientLib] Update available: v" .. remoteVersion .. " (current: v" .. libraryVersion .. ")")
            return true, remoteVersion
        else
            print("[GradientLib] Up to date (v" .. libraryVersion .. ")")
            return false, libraryVersion
        end
    else
        warn("[GradientLib] Failed to check for updates")
        return nil, libraryVersion
    end
end

function library:Window(name, options)
    options = options or {}
    local window = {
        toggled = false,
        flags = {},
        elements = {},
        tabs = {},
        currentTab = nil,
        minimized = false
    }

    library.windows = library.windows + 1
    local windowIndex = library.windows
    local windowWidth = isMobile and 300 or 240

    -- Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = name or "Window"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = library.theme.background
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0, (20 + ((windowWidth + 20) * windowIndex - (windowWidth + 20))), 0, 20)
    MainFrame.Size = UDim2.new(0, windowWidth, 0, 44)
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = not isMobile
    MainFrame.ZIndex = 10
    createCorner(MainFrame, UDim.new(0, 12))
    createStroke(MainFrame, library.theme.border, 1.5)
    createShadow(MainFrame, 0.7)

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = library.theme.surface
    TopBar.BackgroundTransparency = 0.4
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, isMobile and 52 or 44)
    TopBar.ZIndex = 11
    createCorner(TopBar, UDim.new(0, 12))

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Font = library.theme.fontTitle
    Title.Text = name or "Window"
    Title.TextColor3 = library.theme.textPrimary
    Title.TextSize = isMobile and 26 or 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextYAlignment = Enum.TextYAlignment.Center
    Title.ZIndex = 12

    -- Minimize Button
    local MinimizeBtn = Instance.new("ImageButton")
    MinimizeBtn.Name = "Minimize"
    MinimizeBtn.Parent = TopBar
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Position = UDim2.new(1, -40, 0.5, -12)
    MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    MinimizeBtn.Image = "rbxassetid://7072706745"
    MinimizeBtn.ImageColor3 = library.theme.textSecondary
    MinimizeBtn.ZIndex = 12

    -- Content Container
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = MainFrame
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 0, 0, isMobile and 56 or 48)
    Container.Size = UDim2.new(1, 0, 1, -(isMobile and 56 or 48))
    Container.ZIndex = 10

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Container
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, library.theme.spacing)

    local UIPadding = Instance.new("UIPadding")
    UIPadding.Parent = Container
    UIPadding.PaddingLeft = UDim.new(0, isMobile and 14 or 10)
    UIPadding.PaddingRight = UDim.new(0, isMobile and 14 or 10)
    UIPadding.PaddingTop = UDim.new(0, isMobile and 8 or 5)
    UIPadding.PaddingBottom = UDim.new(0, isMobile and 14 or 10)

    -- Resize function
    local function reSize()
        local y = (isMobile and 56 or 48) + 10
        for _, v in pairs(Container:GetChildren()) do
            if v:IsA("Frame") or v:IsA("TextButton") or v:IsA("TextLabel") or v:IsA("TextBox") then
                y = y + v.AbsoluteSize.Y + library.theme.spacing
            end
        end
        y = y - library.theme.spacing + 5
        window.fullSize = UDim2.new(0, windowWidth, 0, math.min(y, isMobile and 600 or 500))
        if not window.minimized then
            tween(MainFrame, {Size = window.fullSize}, 0.3)
        end
    end

    -- Minimize functionality
    local fullSize = UDim2.new(0, windowWidth, 0, isMobile and 52 or 44)

    MinimizeBtn.MouseButton1Click:Connect(function()
        window.minimized = not window.minimized
        tween(MinimizeBtn, {Rotation = window.minimized and 180 or 0}, 0.3)

        if window.minimized then
            window.fullSize = MainFrame.Size
            tween(MainFrame, {Size = fullSize}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            Container.Visible = false
        else
            Container.Visible = true
            tween(MainFrame, {Size = window.fullSize or UDim2.new(0, windowWidth, 0, 300)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)

    MinimizeBtn.MouseEnter:Connect(function()
        tween(MinimizeBtn, {ImageColor3 = library.theme.accent}, 0.2)
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        tween(MinimizeBtn, {ImageColor3 = library.theme.textSecondary}, 0.2)
    end)

    -- Mobile drag support
    if isMobile then
        local dragging = false
        local dragStart = nil
        local startPos = nil

        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- Section
    function window:Section(text)
        local Section = Instance.new("Frame")
        Section.Name = "Section"
        Section.Parent = Container
        Section.BackgroundTransparency = 1
        Section.Size = UDim2.new(1, 0, 0, isMobile and 32 or 26)
        Section.LayoutOrder = #Container:GetChildren()

        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Parent = Section
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.Font = library.theme.fontTitle
        Label.Text = text
        Label.TextColor3 = library.theme.accent
        Label.TextSize = isMobile and 18 or 16
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center

        local Line = Instance.new("Frame")
        Line.Name = "Line"
        Line.Parent = Section
        Line.BackgroundColor3 = library.theme.border
        Line.BorderSizePixel = 0
        Line.Position = UDim2.new(0, 0, 1, -2)
        Line.Size = UDim2.new(1, 0, 0, 1)

        reSize()
        return Section
    end

    -- Label
    function window:Label(text, color)
        local LabelFrame = Instance.new("Frame")
        LabelFrame.Name = "Label"
        LabelFrame.Parent = Container
        LabelFrame.BackgroundTransparency = 1
        LabelFrame.Size = UDim2.new(1, 0, 0, isMobile and 28 or 24)
        LabelFrame.LayoutOrder = #Container:GetChildren()

        local Label = Instance.new("TextLabel")
        Label.Parent = LabelFrame
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.Font = library.theme.fontBody
        Label.Text = text
        Label.TextColor3 = color or library.theme.textSecondary
        Label.TextSize = isMobile and 16 or 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Center
        Label.TextWrapped = true

        reSize()
        return LabelFrame
    end

    -- Paragraph (multi-line text)
    function window:Paragraph(text, color)
        local ParagraphFrame = Instance.new("Frame")
        ParagraphFrame.Name = "Paragraph"
        ParagraphFrame.Parent = Container
        ParagraphFrame.BackgroundColor3 = library.theme.foreground
        ParagraphFrame.BackgroundTransparency = 0.5
        ParagraphFrame.BorderSizePixel = 0
        ParagraphFrame.Size = UDim2.new(1, 0, 0, isMobile and 80 or 60)
        ParagraphFrame.LayoutOrder = #Container:GetChildren()
        createCorner(ParagraphFrame)

        local Label = Instance.new("TextLabel")
        Label.Parent = ParagraphFrame
        Label.BackgroundTransparency = 1
        Label.Position = UDim2.new(0, library.theme.touchPadding, 0, 0)
        Label.Size = UDim2.new(1, -library.theme.touchPadding * 2, 1, 0)
        Label.Font = library.theme.fontBody
        Label.Text = text
        Label.TextColor3 = color or library.theme.textSecondary
        Label.TextSize = isMobile and 15 or 13
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextYAlignment = Enum.TextYAlignment.Top
        Label.TextWrapped = true

        ParagraphFrame.MouseEnter:Connect(function()
            tween(ParagraphFrame, {BackgroundTransparency = 0.2}, 0.2)
        end)
        ParagraphFrame.MouseLeave:Connect(function()
            tween(ParagraphFrame, {BackgroundTransparency = 0.5}, 0.2)
        end)

        reSize()
        return ParagraphFrame
    end

    -- Spacer
    function window:Spacer(height)
        local Spacer = Instance.new("Frame")
        Spacer.Name = "Spacer"
        Spacer.Parent = Container
        Spacer.BackgroundTransparency = 1
        Spacer.Size = UDim2.new(1, 0, 0, height or library.theme.spacing)
        Spacer.LayoutOrder = #Container:GetChildren()
        reSize()
        return Spacer
    end

    -- Separator
    function window:Separator()
        local Sep = Instance.new("Frame")
        Sep.Name = "Separator"
        Sep.Parent = Container
        Sep.BackgroundColor3 = library.theme.border
        Sep.BorderSizePixel = 0
        Sep.Size = UDim2.new(1, 0, 0, 1)
        Sep.LayoutOrder = #Container:GetChildren()
        reSize()
        return Sep
    end

    -- Toggle
    function window:Toggle(name, callback, default)
        local toggled = default or false
        local typeCallback = (typeof(callback) == "string" and "flag") or (typeof(callback) == "function" and "func")

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = "Toggle"
        ToggleFrame.Parent = Container
        ToggleFrame.BackgroundColor3 = library.theme.foreground
        ToggleFrame.BackgroundTransparency = 0.5
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Size = UDim2.new(1, 0, 0, library.theme.elementHeight)
        ToggleFrame.LayoutOrder = #Container:GetChildren()
        createCorner(ToggleFrame)

        local Title = Instance.new("TextLabel")
        Title.Parent = ToggleFrame
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, library.theme.touchPadding, 0, 0)
        Title.Size = UDim2.new(1, -70, 1, 0)
        Title.Font = library.theme.fontBody
        Title.Text = name
        Title.TextColor3 = library.theme.textPrimary
        Title.TextSize = isMobile and 16 or 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextYAlignment = Enum.TextYAlignment.Center

        local SwitchBg = Instance.new("Frame")
        SwitchBg.Parent = ToggleFrame
        SwitchBg.BackgroundColor3 = library.theme.border
        SwitchBg.BorderSizePixel = 0
        SwitchBg.Position = UDim2.new(1, -52, 0.5, -12)
        SwitchBg.Size = UDim2.new(0, 44, 0, 24)
        createCorner(SwitchBg, UDim.new(1, 0))

        local SwitchFill = Instance.new("Frame")
        SwitchFill.Parent = SwitchBg
        SwitchFill.BackgroundColor3 = toggled and library.theme.accent or library.theme.border
        SwitchFill.BorderSizePixel = 0
        SwitchFill.Size = UDim2.new(1, 0, 1, 0)
        createCorner(SwitchFill, UDim.new(1, 0))

        local Circle = Instance.new("Frame")
        Circle.Parent = SwitchBg
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BorderSizePixel = 0
        Circle.Size = UDim2.new(0, 20, 0, 20)
        Circle.Position = toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        createCorner(Circle, UDim.new(1, 0))

        local ClickArea = Instance.new("TextButton")
        ClickArea.Parent = ToggleFrame
        ClickArea.BackgroundTransparency = 1
        ClickArea.Size = UDim2.new(1, 0, 1, 0)
        ClickArea.Text = ""
        ClickArea.ZIndex = 5

        local function updateToggle()
            toggled = not toggled

            if typeCallback == "flag" then
                window.flags[callback] = toggled
            elseif typeCallback == "func" then
                callback(toggled)
            end

            tween(SwitchFill, {BackgroundColor3 = toggled and library.theme.accent or library.theme.border}, 0.2)
            tween(Circle, {Position = toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end

        ClickArea.MouseButton1Click:Connect(function()
            vibrate()
            createRipple(ToggleFrame, Vector2.new(ClickArea.AbsolutePosition.X + ClickArea.AbsoluteSize.X - 40, ClickArea.AbsolutePosition.Y + ClickArea.AbsoluteSize.Y / 2))
            updateToggle()
        end)

        ClickArea.TouchTap:Connect(function()
            vibrate()
            updateToggle()
        end)

        ToggleFrame.MouseEnter:Connect(function()
            tween(ToggleFrame, {BackgroundTransparency = 0.2}, 0.2)
        end)
        ToggleFrame.MouseLeave:Connect(function()
            tween(ToggleFrame, {BackgroundTransparency = 0.5}, 0.2)
        end)

        if toggled then
            updateToggle()
            updateToggle()
        end

        reSize()
        return ToggleFrame
    end

    -- Button
    function window:Button(name, callback, icon)
        local ButtonFrame = Instance.new("TextButton")
        ButtonFrame.Name = "Button"
        ButtonFrame.Parent = Container
        ButtonFrame.BackgroundColor3 = library.theme.accent
        ButtonFrame.BackgroundTransparency = 0.1
        ButtonFrame.BorderSizePixel = 0
        ButtonFrame.Size = UDim2.new(1, 0, 0, library.theme.elementHeight)
        ButtonFrame.LayoutOrder = #Container:GetChildren()
        ButtonFrame.Font = library.theme.fontBody
        ButtonFrame.Text = name
        ButtonFrame.TextColor3 = library.theme.textPrimary
        ButtonFrame.TextSize = isMobile and 16 or 14
        ButtonFrame.AutoButtonColor = false
        createCorner(ButtonFrame)

        if icon then
            local IconImg = Instance.new("ImageLabel")
            IconImg.Parent = ButtonFrame
            IconImg.BackgroundTransparency = 1
            IconImg.Position = UDim2.new(0, library.theme.touchPadding, 0.5, -10)
            IconImg.Size = UDim2.new(0, 20, 0, 20)
            IconImg.Image = icon
            IconImg.ImageColor3 = library.theme.textPrimary

            ButtonFrame.Text = "    " .. name
        end

        ButtonFrame.MouseButton1Click:Connect(function()
            vibrate()
            createRipple(ButtonFrame, Vector2.new(ButtonFrame.AbsolutePosition.X + ButtonFrame.AbsoluteSize.X / 2, ButtonFrame.AbsolutePosition.Y + ButtonFrame.AbsoluteSize.Y / 2))
            if callback then callback() end
        end)

        ButtonFrame.TouchTap:Connect(function()
            vibrate()
            if callback then callback() end
        end)

        ButtonFrame.MouseEnter:Connect(function()
            tween(ButtonFrame, {BackgroundColor3 = library.theme.accentHover, BackgroundTransparency = 0}, 0.2)
        end)
        ButtonFrame.MouseLeave:Connect(function()
            tween(ButtonFrame, {BackgroundColor3 = library.theme.accent, BackgroundTransparency = 0.1}, 0.2)
        end)

        ButtonFrame.MouseButton1Down:Connect(function()
            tween(ButtonFrame, {Size = UDim2.new(0.97, 0, 0, library.theme.elementHeight - 2)}, 0.1)
        end)
        ButtonFrame.MouseButton1Up:Connect(function()
            tween(ButtonFrame, {Size = UDim2.new(1, 0, 0, library.theme.elementHeight)}, 0.1)
        end)

        reSize()
        return ButtonFrame
    end

    -- Image Button
    function window:ImageButton(name, image, callback)
        local ImgFrame = Instance.new("Frame")
        ImgFrame.Name = "ImageButton"
        ImgFrame.Parent = Container
        ImgFrame.BackgroundColor3 = library.theme.foreground
        ImgFrame.BackgroundTransparency = 0.5
        ImgFrame.BorderSizePixel = 0
        ImgFrame.Size = UDim2.new(1, 0, 0, isMobile and 80 or 64)
        ImgFrame.LayoutOrder = #Container:GetChildren()
        createCorner(ImgFrame)

        local Img = Instance.new("ImageLabel")
        Img.Parent = ImgFrame
        Img.BackgroundTransparency = 1
        Img.Position = UDim2.new(0, library.theme.touchPadding, 0.5, -20)
        Img.Size = UDim2.new(0, 40, 0, 40)
        Img.Image = image
        Img.ImageColor3 = library.theme.accent

        local Title = Instance.new("TextLabel")
        Title.Parent = ImgFrame
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 60, 0, 0)
        Title.Size = UDim2.new(1, -70, 0.6, 0)
        Title.Font = library.theme.fontBody
        Title.Text = name
        Title.TextColor3 = library.theme.textPrimary
        Title.TextSize = isMobile and 16 or 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextYAlignment = Enum.TextYAlignment.Bottom

        local Subtitle = Instance.new("TextLabel")
        Subtitle.Parent = ImgFrame
        Subtitle.BackgroundTransparency = 1
        Subtitle.Position = UDim2.new(0, 60, 0.55, 0)
        Subtitle.Size = UDim2.new(1, -70, 0.4, 0)
        Subtitle.Font = library.theme.fontBody
        Subtitle.Text = "Tap to activate"
        Subtitle.TextColor3 = library.theme.textDark
        Subtitle.TextSize = isMobile and 14 or 12
        Subtitle.TextXAlignment = Enum.TextXAlignment.Left
        Subtitle.TextYAlignment = Enum.TextYAlignment.Top

        local ClickArea = Instance.new("TextButton")
        ClickArea.Parent = ImgFrame
        ClickArea.BackgroundTransparency = 1
        ClickArea.Size = UDim2.new(1, 0, 1, 0)
        ClickArea.Text = ""
        ClickArea.ZIndex = 5

        ClickArea.MouseButton1Click:Connect(function()
            vibrate()
            createRipple(ImgFrame, Vector2.new(ImgFrame.AbsolutePosition.X + ImgFrame.AbsoluteSize.X / 2, ImgFrame.AbsolutePosition.Y + ImgFrame.AbsoluteSize.Y / 2))
            if callback then callback() end
        end)

        ClickArea.TouchTap:Connect(function()
            vibrate()
            if callback then callback() end
        end)

        ImgFrame.MouseEnter:Connect(function()
            tween(ImgFrame, {BackgroundTransparency = 0.2}, 0.2)
        end)
        ImgFrame.MouseLeave:Connect(function()
            tween(ImgFrame, {BackgroundTransparency = 0.5}, 0.2)
        end)

        reSize()
        return ImgFrame
    end

    -- Slider
    function window:Slider(name, min, max, default, callback, suffix)
        local current = default or min
        local dragging = false
        suffix = suffix or ""

        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = "Slider"
        SliderFrame.Parent = Container
        SliderFrame.BackgroundColor3 = library.theme.foreground
        SliderFrame.BackgroundTransparency = 0.5
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Size = UDim2.new(1, 0, 0, isMobile and 64 or 52)
        SliderFrame.LayoutOrder = #Container:GetChildren()
        createCorner(SliderFrame)

        local Title = Instance.new("TextLabel")
        Title.Parent = SliderFrame
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, library.theme.touchPadding, 0, 4)
        Title.Size = UDim2.new(1, -20, 0, 20)
        Title.Font = library.theme.fontBody
        Title.Text = name
        Title.TextColor3 = library.theme.textPrimary
        Title.TextSize = isMobile and 16 or 14
        Title.TextXAlignment = Enum.TextXAlignment.Left

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = SliderFrame
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Position = UDim2.new(1, -70, 0, 4)
        ValueLabel.Size = UDim2.new(0, 60, 0, 20)
        ValueLabel.Font = library.theme.fontMono
        ValueLabel.Text = tostring(math.floor(current)) .. suffix
        ValueLabel.TextColor3 = library.theme.accent
        ValueLabel.TextSize = isMobile and 15 or 13
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

        local TrackBg = Instance.new("Frame")
        TrackBg.Parent = SliderFrame
        TrackBg.BackgroundColor3 = library.theme.border
        TrackBg.BorderSizePixel = 0
        TrackBg.Position = UDim2.new(0, library.theme.touchPadding, 0, isMobile and 36 or 28)
        TrackBg.Size = UDim2.new(1, -library.theme.touchPadding * 2, 0, isMobile and 8 or 6)
        createCorner(TrackBg, UDim.new(1, 0))

        local TrackFill = Instance.new("Frame")
        TrackFill.Parent = TrackBg
        TrackFill.BackgroundColor3 = library.theme.accent
        TrackFill.BorderSizePixel = 0
        TrackFill.Size = UDim2.new((current - min) / (max - min), 0, 1, 0)
        createCorner(TrackFill, UDim.new(1, 0))

        local Knob = Instance.new("Frame")
        Knob.Parent = TrackBg
        Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Knob.BorderSizePixel = 0
        Knob.Position = UDim2.new((current - min) / (max - min), isMobile and -10 or -7, 0.5, isMobile and -10 or -7)
        Knob.Size = UDim2.new(0, isMobile and 20 or 14, 0, isMobile and 20 or 14)
        createCorner(Knob, UDim.new(1, 0))

        local KnobGlow = Instance.new("Frame")
        KnobGlow.Parent = Knob
        KnobGlow.BackgroundColor3 = library.theme.accent
        KnobGlow.BackgroundTransparency = 0.8
        KnobGlow.BorderSizePixel = 0
        KnobGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
        KnobGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        KnobGlow.Size = UDim2.new(1, isMobile and 10 or 6, 1, isMobile and 10 or 6)
        createCorner(KnobGlow, UDim.new(1, 0))

        local function updateSlider(input)
            local sliderPos = TrackBg.AbsolutePosition.X
            local sliderSize = TrackBg.AbsoluteSize.X
            local mousePos = input.Position.X
            local percentage = math.max(0, math.min(1, (mousePos - sliderPos) / sliderSize))
            current = min + (max - min) * percentage

            tween(TrackFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.05)
            tween(Knob, {Position = UDim2.new(percentage, isMobile and -10 or -7, 0.5, isMobile and -10 or -7)}, 0.05)
            ValueLabel.Text = tostring(math.floor(current)) .. suffix

            if callback then callback(math.floor(current)) end
        end

        local function startDrag(input)
            dragging = true
            tween(Knob, {Size = UDim2.new(0, isMobile and 26 or 18, 0, isMobile and 26 or 18)}, 0.1)
            tween(KnobGlow, {Size = UDim2.new(1, isMobile and 14 or 10, 1, isMobile and 14 or 10), BackgroundTransparency = 0.5}, 0.1)
            updateSlider(input)
        end

        local function endDrag()
            if dragging then
                dragging = false
                tween(Knob, {Size = UDim2.new(0, isMobile and 20 or 14, 0, isMobile and 20 or 14)}, 0.1)
                tween(KnobGlow, {Size = UDim2.new(1, isMobile and 10 or 6, 1, isMobile and 10 or 6), BackgroundTransparency = 0.8}, 0.1)
            end
        end

        Knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                startDrag(input)
            end
        end)

        TrackBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                startDrag(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                endDrag()
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateSlider(input)
            end
        end)

        SliderFrame.MouseEnter:Connect(function()
            tween(SliderFrame, {BackgroundTransparency = 0.2}, 0.2)
        end)
        SliderFrame.MouseLeave:Connect(function()
            tween(SliderFrame, {BackgroundTransparency = 0.5}, 0.2)
        end)

        reSize()
        return SliderFrame
    end

    -- Dropdown
    function window:Dropdown(name, objects, callback)
        local toggled = false
        local selectedOption = nil

        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = "Dropdown"
        DropdownFrame.Parent = Container
        DropdownFrame.BackgroundColor3 = library.theme.foreground
        DropdownFrame.BackgroundTransparency = 0.5
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.Size = UDim2.new(1, 0, 0, library.theme.elementHeight)
        DropdownFrame.LayoutOrder = #Container:GetChildren()
        DropdownFrame.ClipsDescendants = false
        createCorner(DropdownFrame)

        local Title = Instance.new("TextLabel")
        Title.Parent = DropdownFrame
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, library.theme.touchPadding, 0, 0)
        Title.Size = UDim2.new(1, -50, 1, 0)
        Title.Font = library.theme.fontBody
        Title.Text = name
        Title.TextColor3 = library.theme.textPrimary
        Title.TextSize = isMobile and 16 or 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextYAlignment = Enum.TextYAlignment.Center

        local Arrow = Instance.new("ImageLabel")
        Arrow.Parent = DropdownFrame
        Arrow.BackgroundTransparency = 1
        Arrow.Position = UDim2.new(1, -32, 0.5, -10)
        Arrow.Size = UDim2.new(0, 20, 0, 20)
        Arrow.Image = "rbxassetid://7072706663"
        Arrow.ImageColor3 = library.theme.textSecondary
        Arrow.Rotation = 0

        local SelectedText = Instance.new("TextLabel")
        SelectedText.Parent = DropdownFrame
        SelectedText.BackgroundTransparency = 1
        SelectedText.Position = UDim2.new(1, -110, 0, 0)
        SelectedText.Size = UDim2.new(0, 80, 1, 0)
        SelectedText.Font = library.theme.fontBody
        SelectedText.Text = "Select..."
        SelectedText.TextColor3 = library.theme.textSecondary
        SelectedText.TextSize = isMobile and 14 or 12
        SelectedText.TextXAlignment = Enum.TextXAlignment.Right
        SelectedText.TextYAlignment = Enum.TextYAlignment.Center

        -- Mobile overlay dropdown
        local OptionsFrame
        if isMobile then
            OptionsFrame = Instance.new("Frame")
            OptionsFrame.Parent = ScreenGui
            OptionsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            OptionsFrame.BackgroundTransparency = 0.5
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.Position = UDim2.new(0, 0, 0, 0)
            OptionsFrame.Size = UDim2.new(1, 0, 1, 0)
            OptionsFrame.ZIndex = 50
            OptionsFrame.Visible = false

            local OptionsPanel = Instance.new("Frame")
            OptionsPanel.Parent = OptionsFrame
            OptionsPanel.BackgroundColor3 = library.theme.foreground
            OptionsPanel.BorderSizePixel = 0
            OptionsPanel.Position = UDim2.new(0.5, -140, 0.5, -150)
            OptionsPanel.Size = UDim2.new(0, 280, 0, 300)
            OptionsPanel.ZIndex = 51
            createCorner(OptionsPanel, UDim.new(0, 14))
            createStroke(OptionsPanel, library.theme.border, 2)
            createShadow(OptionsPanel, 0.5)

            local OptionsTitle = Instance.new("TextLabel")
            OptionsTitle.Parent = OptionsPanel
            OptionsTitle.BackgroundTransparency = 1
            OptionsTitle.Position = UDim2.new(0, 16, 0, 12)
            OptionsTitle.Size = UDim2.new(1, -32, 0, 30)
            OptionsTitle.Font = library.theme.fontTitle
            OptionsTitle.Text = "Select " .. name
            OptionsTitle.TextColor3 = library.theme.textPrimary
            OptionsTitle.TextSize = 20
            OptionsTitle.TextXAlignment = Enum.TextXAlignment.Left
            OptionsTitle.ZIndex = 52

            local CloseBtn = Instance.new("TextButton")
            CloseBtn.Parent = OptionsPanel
            CloseBtn.BackgroundColor3 = library.theme.error
            CloseBtn.BorderSizePixel = 0
            CloseBtn.Position = UDim2.new(1, -50, 0, 12)
            CloseBtn.Size = UDim2.new(0, 36, 0, 28)
            CloseBtn.Font = library.theme.fontBody
            CloseBtn.Text = "X"
            CloseBtn.TextColor3 = library.theme.textPrimary
            CloseBtn.TextSize = 16
            CloseBtn.ZIndex = 52
            createCorner(CloseBtn, UDim.new(0, 8))

            CloseBtn.MouseButton1Click:Connect(function()
                toggled = false
                tween(OptionsFrame, {BackgroundTransparency = 1}, 0.3)
                tween(OptionsPanel, {Position = UDim2.new(0.5, -140, 1, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                task.delay(0.3, function()
                    OptionsFrame.Visible = false
                end)
            end)

            local ScrollFrame = Instance.new("ScrollingFrame")
            ScrollFrame.Parent = OptionsPanel
            ScrollFrame.BackgroundTransparency = 1
            ScrollFrame.Position = UDim2.new(0, 8, 0, 50)
            ScrollFrame.Size = UDim2.new(1, -16, 1, -58)
            ScrollFrame.ScrollBarThickness = 4
            ScrollFrame.ScrollBarImageColor3 = library.theme.accent
            ScrollFrame.ZIndex = 52

            local ScrollLayout = Instance.new("UIListLayout")
            ScrollLayout.Parent = ScrollFrame
            ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ScrollLayout.Padding = UDim.new(0, 6)

            for i, v in pairs(objects) do
                local OptionBtn = Instance.new("TextButton")
                OptionBtn.Parent = ScrollFrame
                OptionBtn.BackgroundColor3 = library.theme.background
                OptionBtn.BorderSizePixel = 0
                OptionBtn.Size = UDim2.new(1, 0, 0, 44)
                OptionBtn.ZIndex = 53
                OptionBtn.Font = library.theme.fontBody
                OptionBtn.Text = "  " .. tostring(v)
                OptionBtn.TextColor3 = library.theme.textSecondary
                OptionBtn.TextSize = 15
                OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptionBtn.AutoButtonColor = false
                createCorner(OptionBtn, UDim.new(0, 8))

                OptionBtn.MouseEnter:Connect(function()
                    tween(OptionBtn, {BackgroundColor3 = library.theme.surface, TextColor3 = library.theme.textPrimary}, 0.15)
                end)
                OptionBtn.MouseLeave:Connect(function()
                    tween(OptionBtn, {BackgroundColor3 = library.theme.background, TextColor3 = library.theme.textSecondary}, 0.15)
                end)

                OptionBtn.MouseButton1Click:Connect(function()
                    vibrate()
                    selectedOption = tostring(v)
                    SelectedText.Text = selectedOption
                    SelectedText.TextColor3 = library.theme.accent
                    if callback then callback(selectedOption) end

                    toggled = false
                    tween(Arrow, {Rotation = 0}, 0.3)
                    tween(OptionsFrame, {BackgroundTransparency = 1}, 0.3)
                    tween(OptionsPanel, {Position = UDim2.new(0.5, -140, 1, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    task.delay(0.3, function()
                        OptionsFrame.Visible = false
                    end)
                end)

                OptionBtn.TouchTap:Connect(function()
                    vibrate()
                    selectedOption = tostring(v)
                    SelectedText.Text = selectedOption
                    SelectedText.TextColor3 = library.theme.accent
                    if callback then callback(selectedOption) end

                    toggled = false
                    tween(Arrow, {Rotation = 0}, 0.3)
                    tween(OptionsFrame, {BackgroundTransparency = 1}, 0.3)
                    tween(OptionsPanel, {Position = UDim2.new(0.5, -140, 1, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    task.delay(0.3, function()
                        OptionsFrame.Visible = false
                    end)
                end)
            end

            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollLayout.AbsoluteContentSize.Y + 10)
        else
            OptionsFrame = Instance.new("Frame")
            OptionsFrame.Parent = DropdownFrame
            OptionsFrame.BackgroundColor3 = library.theme.foreground
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.Position = UDim2.new(0, 0, 0, library.theme.elementHeight + 4)
            OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
            OptionsFrame.ZIndex = 20
            OptionsFrame.ClipsDescendants = true
            createCorner(OptionsFrame)
            createStroke(OptionsFrame, library.theme.border, 1)

            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.Parent = OptionsFrame
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsLayout.Padding = UDim.new(0, 2)

            local OptionsPadding = Instance.new("UIPadding")
            OptionsPadding.Parent = OptionsFrame
            OptionsPadding.PaddingTop = UDim.new(0, 4)
            OptionsPadding.PaddingBottom = UDim.new(0, 4)
            OptionsPadding.PaddingLeft = UDim.new(0, 4)
            OptionsPadding.PaddingRight = UDim.new(0, 4)

            local totalHeight = 8
            for i, v in pairs(objects) do
                totalHeight = totalHeight + 28

                local OptionBtn = Instance.new("TextButton")
                OptionBtn.Parent = OptionsFrame
                OptionBtn.BackgroundColor3 = library.theme.background
                OptionBtn.BackgroundTransparency = 1
                OptionBtn.BorderSizePixel = 0
                OptionBtn.Size = UDim2.new(1, 0, 0, 28)
                OptionBtn.ZIndex = 21
                OptionBtn.Font = library.theme.fontBody
                OptionBtn.Text = "  " .. tostring(v)
                OptionBtn.TextColor3 = library.theme.textSecondary
                OptionBtn.TextSize = 13
                OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptionBtn.AutoButtonColor = false
                createCorner(OptionBtn, UDim.new(0, 4))

                OptionBtn.MouseEnter:Connect(function()
                    tween(OptionBtn, {BackgroundTransparency = 0.5, TextColor3 = library.theme.textPrimary}, 0.15)
                end)
                OptionBtn.MouseLeave:Connect(function()
                    tween(OptionBtn, {BackgroundTransparency = 1, TextColor3 = library.theme.textSecondary}, 0.15)
                end)

                OptionBtn.MouseButton1Click:Connect(function()
                    selectedOption = tostring(v)
                    SelectedText.Text = selectedOption
                    SelectedText.TextColor3 = library.theme.accent
                    tween(SelectedText, {TextColor3 = library.theme.accent}, 0.2)
                    if callback then callback(selectedOption) end

                    toggled = false
                    tween(Arrow, {Rotation = 0}, 0.3)
                    tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                end)
            end
        end

        local ClickArea = Instance.new("TextButton")
        ClickArea.Parent = DropdownFrame
        ClickArea.BackgroundTransparency = 1
        ClickArea.Size = UDim2.new(1, 0, 1, 0)
        ClickArea.Text = ""
        ClickArea.ZIndex = 5

        ClickArea.MouseButton1Click:Connect(function()
            toggled = not toggled
            tween(Arrow, {Rotation = toggled and 180 or 0}, 0.3)

            if isMobile then
                if toggled then
                    OptionsFrame.Visible = true
                    OptionsFrame.BackgroundTransparency = 1
                    tween(OptionsFrame, {BackgroundTransparency = 0.5}, 0.3)
                    tween(OptionsFrame.OptionsPanel, {Position = UDim2.new(0.5, -140, 0.5, -150)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                else
                    tween(OptionsFrame, {BackgroundTransparency = 1}, 0.3)
                    tween(OptionsFrame.OptionsPanel, {Position = UDim2.new(0.5, -140, 1, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    task.delay(0.3, function()
                        OptionsFrame.Visible = false
                    end)
                end
            else
                tween(OptionsFrame, {Size = toggled and UDim2.new(1, 0, 0, math.min(totalHeight, 200)) or UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart, toggled and Enum.EasingDirection.Out or Enum.EasingDirection.In)
            end
        end)

        ClickArea.TouchTap:Connect(function()
            toggled = not toggled
            tween(Arrow, {Rotation = toggled and 180 or 0}, 0.3)

            if isMobile then
                if toggled then
                    OptionsFrame.Visible = true
                    OptionsFrame.BackgroundTransparency = 1
                    tween(OptionsFrame, {BackgroundTransparency = 0.5}, 0.3)
                    tween(OptionsFrame.OptionsPanel, {Position = UDim2.new(0.5, -140, 0.5, -150)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                else
                    tween(OptionsFrame, {BackgroundTransparency = 1}, 0.3)
                    tween(OptionsFrame.OptionsPanel, {Position = UDim2.new(0.5, -140, 1, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    task.delay(0.3, function()
                        OptionsFrame.Visible = false
                    end)
                end
            end
        end)

        DropdownFrame.MouseEnter:Connect(function()
            tween(DropdownFrame, {BackgroundTransparency = 0.2}, 0.2)
        end)
        DropdownFrame.MouseLeave:Connect(function()
            if not toggled then
                tween(DropdownFrame, {BackgroundTransparency = 0.5}, 0.2)
            end
        end)

        reSize()
        return DropdownFrame
    end

    -- TextBox
    function window:Box(name, default, callback)
        local BoxFrame = Instance.new("Frame")
        BoxFrame.Name = "Box"
        BoxFrame.Parent = Container
        BoxFrame.BackgroundColor3 = library.theme.foreground
        BoxFrame.BackgroundTransparency = 0.5
        BoxFrame.BorderSizePixel = 0
        BoxFrame.Size = UDim2.new(1, 0, 0, library.theme.elementHeight)
        BoxFrame.LayoutOrder = #Container:GetChildren()
        createCorner(BoxFrame)

        local Title = Instance.new("TextLabel")
        Title.Parent = BoxFrame
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, library.theme.touchPadding, 0, 0)
        Title.Size = UDim2.new(0.5, -library.theme.touchPadding, 1, 0)
        Title.Font = library.theme.fontBody
        Title.Text = name
        Title.TextColor3 = library.theme.textPrimary
        Title.TextSize = isMobile and 16 or 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextYAlignment = Enum.TextYAlignment.Center

        local InputBg = Instance.new("Frame")
        InputBg.Parent = BoxFrame
        InputBg.BackgroundColor3 = library.theme.background
        InputBg.BorderSizePixel = 0
        InputBg.Position = UDim2.new(0.5, 0, 0.5, -14)
        InputBg.Size = UDim2.new(0.48, 0, 0, 28)
        createCorner(InputBg, UDim.new(0, 8))
        createStroke(InputBg, library.theme.border, 1)

        local TextBox = Instance.new("TextBox")
        TextBox.Parent = InputBg
        TextBox.BackgroundTransparency = 1
        TextBox.Position = UDim2.new(0, 10, 0, 0)
        TextBox.Size = UDim2.new(1, -20, 1, 0)
        TextBox.Font = library.theme.fontMono
        TextBox.PlaceholderText = default or "value"
        TextBox.PlaceholderColor3 = library.theme.textDark
        TextBox.Text = ""
        TextBox.TextColor3 = library.theme.textPrimary
        TextBox.TextSize = isMobile and 15 or 13
        TextBox.TextXAlignment = Enum.TextXAlignment.Left
        TextBox.ClearTextOnFocus = false

        local focused = false

        TextBox.Focused:Connect(function()
            focused = true
            tween(InputBg, {BackgroundColor3 = library.theme.surface}, 0.2)
            tween(InputBg.UIStroke, {Color = library.theme.accent}, 0.2)
        end)

        TextBox.FocusLost:Connect(function()
            focused = false
            tween(InputBg, {BackgroundColor3 = library.theme.background}, 0.2)
            tween(InputBg.UIStroke, {Color = library.theme.border}, 0.2)
            if callback and TextBox.Text ~= "" then
                callback(TextBox.Text)
                TextBox.PlaceholderText = TextBox.Text
                TextBox.Text = ""
            end
        end)

        BoxFrame.MouseEnter:Connect(function()
            tween(BoxFrame, {BackgroundTransparency = 0.2}, 0.2)
        end)
        BoxFrame.MouseLeave:Connect(function()
            tween(BoxFrame, {BackgroundTransparency = 0.5}, 0.2)
        end)

        reSize()
        return BoxFrame
    end

    -- Search Box
    function window:SearchBox(name, objects, callback)
        local SearchFrame = Instance.new("Frame")
        SearchFrame.Name = "SearchBox"
        SearchFrame.Parent = Container
        SearchFrame.BackgroundColor3 = library.theme.foreground
        SearchFrame.BackgroundTransparency = 0.5
        SearchFrame.BorderSizePixel = 0
        SearchFrame.Size = UDim2.new(1, 0, 0, library.theme.elementHeight)
        SearchFrame.LayoutOrder = #Container:GetChildren()
        createCorner(SearchFrame)

        local Icon = Instance.new("ImageLabel")
        Icon.Parent = SearchFrame
        Icon.BackgroundTransparency = 1
        Icon.Position = UDim2.new(0, library.theme.touchPadding, 0.5, -10)
        Icon.Size = UDim2.new(0, 20, 0, 20)
        Icon.Image = "rbxassetid://7072725362"
        Icon.ImageColor3 = library.theme.textDark

        local TextBox = Instance.new("TextBox")
        TextBox.Parent = SearchFrame
        TextBox.BackgroundTransparency = 1
        TextBox.Position = UDim2.new(0, 40, 0, 0)
        TextBox.Size = UDim2.new(1, -50, 1, 0)
        TextBox.Font = library.theme.fontBody
        TextBox.PlaceholderText = name or "Search..."
        TextBox.PlaceholderColor3 = library.theme.textDark
        TextBox.Text = ""
        TextBox.TextColor3 = library.theme.textPrimary
        TextBox.TextSize = isMobile and 16 or 14
        TextBox.TextXAlignment = Enum.TextXAlignment.Left

        local ResultsFrame = Instance.new("Frame")
        ResultsFrame.Parent = SearchFrame
        ResultsFrame.BackgroundColor3 = library.theme.foreground
        ResultsFrame.BorderSizePixel = 0
        ResultsFrame.Position = UDim2.new(0, 0, 0, library.theme.elementHeight + 4)
        ResultsFrame.Size = UDim2.new(1, 0, 0, 0)
        ResultsFrame.ZIndex = 20
        ResultsFrame.ClipsDescendants = true
        createCorner(ResultsFrame)
        createStroke(ResultsFrame, library.theme.border, 1)

        local ResultsLayout = Instance.new("UIListLayout")
        ResultsLayout.Parent = ResultsFrame
        ResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ResultsLayout.Padding = UDim.new(0, 2)

        local ResultsPadding = Instance.new("UIPadding")
        ResultsPadding.Parent = ResultsFrame
        ResultsPadding.PaddingTop = UDim.new(0, 4)
        ResultsPadding.PaddingBottom = UDim.new(0, 4)
        ResultsPadding.PaddingLeft = UDim.new(0, 4)
        ResultsPadding.PaddingRight = UDim.new(0, 4)

        local function updateResults(query)
            for _, child in pairs(ResultsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end

            if query == "" then
                tween(ResultsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                return
            end

            local matches = {}
            for _, v in pairs(objects) do
                if string.find(string.lower(tostring(v)), string.lower(query)) then
                    table.insert(matches, v)
                end
            end

            local totalHeight = 8
            for _, v in pairs(matches) do
                totalHeight = totalHeight + 28

                local ResultBtn = Instance.new("TextButton")
                ResultBtn.Parent = ResultsFrame
                ResultBtn.BackgroundColor3 = library.theme.background
                ResultBtn.BackgroundTransparency = 1
                ResultBtn.BorderSizePixel = 0
                ResultBtn.Size = UDim2.new(1, 0, 0, 28)
                ResultBtn.ZIndex = 21
                ResultBtn.Font = library.theme.fontBody
                ResultBtn.Text = "  " .. tostring(v)
                ResultBtn.TextColor3 = library.theme.textSecondary
                ResultBtn.TextSize = 13
                ResultBtn.TextXAlignment = Enum.TextXAlignment.Left
                ResultBtn.AutoButtonColor = false
                createCorner(ResultBtn, UDim.new(0, 4))

                ResultBtn.MouseEnter:Connect(function()
                    tween(ResultBtn, {BackgroundTransparency = 0.5, TextColor3 = library.theme.textPrimary}, 0.15)
                end)
                ResultBtn.MouseLeave:Connect(function()
                    tween(ResultBtn, {BackgroundTransparency = 1, TextColor3 = library.theme.textSecondary}, 0.15)
                end)

                ResultBtn.MouseButton1Click:Connect(function()
                    if callback then callback(tostring(v)) end
                    TextBox.Text = tostring(v)
                    tween(ResultsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                end)

                ResultBtn.TouchTap:Connect(function()
                    if callback then callback(tostring(v)) end
                    TextBox.Text = tostring(v)
                    tween(ResultsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                end)
            end

            tween(ResultsFrame, {Size = UDim2.new(1, 0, 0, math.min(totalHeight, 200))}, 0.2)
        end

        TextBox.Changed:Connect(function(prop)
            if prop == "Text" then
                updateResults(TextBox.Text)
            end
        end)

        TextBox.FocusLost:Connect(function()
            task.delay(0.5, function()
                tween(ResultsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            end)
        end)

        SearchFrame.MouseEnter:Connect(function()
            tween(SearchFrame, {BackgroundTransparency = 0.2}, 0.2)
        end)
        SearchFrame.MouseLeave:Connect(function()
            tween(SearchFrame, {BackgroundTransparency = 0.5}, 0.2)
        end)

        reSize()
        return SearchFrame
    end

    -- Keybind
    function window:Keybind(name, defaultKey, callback)
        local currentKey = defaultKey or "None"
        local listening = false

        local KeybindFrame = Instance.new("Frame")
        KeybindFrame.Name = "Keybind"
        KeybindFrame.Parent = Container
        KeybindFrame.BackgroundColor3 = library.theme.foreground
        KeybindFrame.BackgroundTransparency = 0.5
        KeybindFrame.BorderSizePixel = 0
        KeybindFrame.Size = UDim2.new(1, 0, 0, library.theme.elementHeight)
        KeybindFrame.LayoutOrder = #Container:GetChildren()
        createCorner(KeybindFrame)

        local Title = Instance.new("TextLabel")
        Title.Parent = KeybindFrame
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, library.theme.touchPadding, 0, 0)
        Title.Size = UDim2.new(1, -90, 1, 0)
        Title.Font = library.theme.fontBody
        Title.Text = name
        Title.TextColor3 = library.theme.textPrimary
        Title.TextSize = isMobile and 16 or 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextYAlignment = Enum.TextYAlignment.Center

        local KeyBg = Instance.new("TextButton")
        KeyBg.Parent = KeybindFrame
        KeyBg.BackgroundColor3 = library.theme.background
        KeyBg.BorderSizePixel = 0
        KeyBg.Position = UDim2.new(1, -80, 0.5, -14)
        KeyBg.Size = UDim2.new(0, 70, 0, 28)
        KeyBg.Font = library.theme.fontMono
        KeyBg.Text = currentKey
        KeyBg.TextColor3 = library.theme.textSecondary
        KeyBg.TextSize = isMobile and 14 or 12
        KeyBg.AutoButtonColor = false
        createCorner(KeyBg, UDim.new(0, 8))
        createStroke(KeyBg, library.theme.border, 1)

        KeyBg.MouseButton1Click:Connect(function()
            listening = not listening
            if listening then
                KeyBg.Text = "..."
                tween(KeyBg, {BackgroundColor3 = library.theme.accent, TextColor3 = library.theme.textPrimary}, 0.2)
                tween(KeyBg.UIStroke, {Color = library.theme.accentHover}, 0.2)
            end
        end)

        KeyBg.TouchTap:Connect(function()
            listening = not listening
            if listening then
                KeyBg.Text = "Tap key"
                tween(KeyBg, {BackgroundColor3 = library.theme.accent, TextColor3 = library.theme.textPrimary}, 0.2)
                tween(KeyBg.UIStroke, {Color = library.theme.accentHover}, 0.2)
            end
        end)

        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if listening and not gameProcessed then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode.Name
                    KeyBg.Text = currentKey
                    listening = false
                    tween(KeyBg, {BackgroundColor3 = library.theme.background, TextColor3 = library.theme.textSecondary}, 0.2)
                    tween(KeyBg.UIStroke, {Color = library.theme.border}, 0.2)
                    if callback then callback(input.KeyCode) end
                end
            elseif not gameProcessed and input.KeyCode.Name == currentKey and callback then
                callback(input.KeyCode)
            end
        end)

        KeybindFrame.MouseEnter:Connect(function()
            tween(KeybindFrame, {BackgroundTransparency = 0.2}, 0.2)
        end)
        KeybindFrame.MouseLeave:Connect(function()
            tween(KeybindFrame, {BackgroundTransparency = 0.5}, 0.2)
        end)

        reSize()
        return KeybindFrame
    end

    -- Color Picker
    function window:ColorPicker(name, defaultColor, callback)
        local color = defaultColor or Color3.fromRGB(255, 255, 255)
        local toggled = false

        local PickerFrame = Instance.new("Frame")
        PickerFrame.Name = "ColorPicker"
        PickerFrame.Parent = Container
        PickerFrame.BackgroundColor3 = library.theme.foreground
        PickerFrame.BackgroundTransparency = 0.5
        PickerFrame.BorderSizePixel = 0
        PickerFrame.Size = UDim2.new(1, 0, 0, library.theme.elementHeight)
        PickerFrame.LayoutOrder = #Container:GetChildren()
        createCorner(PickerFrame)

        local Title = Instance.new("TextLabel")
        Title.Parent = PickerFrame
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, library.theme.touchPadding, 0, 0)
        Title.Size = UDim2.new(1, -50, 1, 0)
        Title.Font = library.theme.fontBody
        Title.Text = name
        Title.TextColor3 = library.theme.textPrimary
        Title.TextSize = isMobile and 16 or 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextYAlignment = Enum.TextYAlignment.Center

        local ColorPreview = Instance.new("TextButton")
        ColorPreview.Parent = PickerFrame
        ColorPreview.BackgroundColor3 = color
        ColorPreview.BorderSizePixel = 0
        ColorPreview.Position = UDim2.new(1, -40, 0.5, -12)
        ColorPreview.Size = UDim2.new(0, 28, 0, 24)
        ColorPreview.Text = ""
        ColorPreview.AutoButtonColor = false
        createCorner(ColorPreview, UDim.new(0, 8))
        createStroke(ColorPreview, library.theme.border, 1)

        local PickerPanel = Instance.new("Frame")
        PickerPanel.Parent = PickerFrame
        PickerPanel.BackgroundColor3 = library.theme.foreground
        PickerPanel.BorderSizePixel = 0
        PickerPanel.Position = UDim2.new(0, 0, 0, library.theme.elementHeight + 4)
        PickerPanel.Size = UDim2.new(1, 0, 0, 0)
        PickerPanel.ZIndex = 20
        PickerPanel.ClipsDescendants = true
        createCorner(PickerPanel)
        createStroke(PickerPanel, library.theme.border, 1)

        local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)

        local function updateColor()
            color = Color3.fromRGB(r, g, b)
            ColorPreview.BackgroundColor3 = color
            if callback then callback(color) end
        end

        local sliders = {
            {name = "R", color = Color3.fromRGB(255, 80, 80), value = r},
            {name = "G", color = Color3.fromRGB(80, 255, 80), value = g},
            {name = "B", color = Color3.fromRGB(80, 80, 255), value = b}
        }

        for i, sliderData in ipairs(sliders) do
            local SliderRow = Instance.new("Frame")
            SliderRow.Parent = PickerPanel
            SliderRow.BackgroundTransparency = 1
            SliderRow.Size = UDim2.new(1, -8, 0, isMobile and 32 or 28)
            SliderRow.Position = UDim2.new(0, 4, 0, 4 + (i - 1) * (isMobile and 34 or 30))

            local Label = Instance.new("TextLabel")
            Label.Parent = SliderRow
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(0, 24, 1, 0)
            Label.Font = library.theme.fontMono
            Label.Text = sliderData.name
            Label.TextColor3 = sliderData.color
            Label.TextSize = isMobile and 14 or 12

            local Track = Instance.new("Frame")
            Track.Parent = SliderRow
            Track.BackgroundColor3 = library.theme.border
            Track.BorderSizePixel = 0
            Track.Position = UDim2.new(0, 28, 0.5, -3)
            Track.Size = UDim2.new(1, -68, 0, 6)
            createCorner(Track, UDim.new(1, 0))

            local Fill = Instance.new("Frame")
            Fill.Parent = Track
            Fill.BackgroundColor3 = sliderData.color
            Fill.BorderSizePixel = 0
            Fill.Size = UDim2.new(sliderData.value / 255, 0, 1, 0)
            createCorner(Fill, UDim.new(1, 0))

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Parent = SliderRow
            ValLabel.BackgroundTransparency = 1
            ValLabel.Position = UDim2.new(1, -36, 0, 0)
            ValLabel.Size = UDim2.new(0, 30, 1, 0)
            ValLabel.Font = library.theme.fontMono
            ValLabel.Text = tostring(sliderData.value)
            ValLabel.TextColor3 = library.theme.textSecondary
            ValLabel.TextSize = isMobile and 13 or 11

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local pos = math.max(0, math.min(1, (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X))
                    local val = math.floor(pos * 255)
                    sliderData.value = val
                    ValLabel.Text = tostring(val)
                    tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)

                    if sliderData.name == "R" then r = val
                    elseif sliderData.name == "G" then g = val
                    else b = val end
                    updateColor()
                end
            end)
        end

        ColorPreview.MouseButton1Click:Connect(function()
            toggled = not toggled
            tween(PickerPanel, {Size = toggled and UDim2.new(1, 0, 0, isMobile and 120 or 100) or UDim2.new(1, 0, 0, 0)}, 0.3)
        end)

        ColorPreview.TouchTap:Connect(function()
            toggled = not toggled
            tween(PickerPanel, {Size = toggled and UDim2.new(1, 0, 0, isMobile and 120 or 100) or UDim2.new(1, 0, 0, 0)}, 0.3)
        end)

        PickerFrame.MouseEnter:Connect(function()
            tween(PickerFrame, {BackgroundTransparency = 0.2}, 0.2)
        end)
        PickerFrame.MouseLeave:Connect(function()
            tween(PickerFrame, {BackgroundTransparency = 0.5}, 0.2)
        end)

        reSize()
        return PickerFrame
    end

    -- Progress Bar
    function window:ProgressBar(name, max, color)
        local ProgressFrame = Instance.new("Frame")
        ProgressFrame.Name = "ProgressBar"
        ProgressFrame.Parent = Container
        ProgressFrame.BackgroundColor3 = library.theme.foreground
        ProgressFrame.BackgroundTransparency = 0.5
        ProgressFrame.BorderSizePixel = 0
        ProgressFrame.Size = UDim2.new(1, 0, 0, isMobile and 48 or 40)
        ProgressFrame.LayoutOrder = #Container:GetChildren()
        createCorner(ProgressFrame)

        local Title = Instance.new("TextLabel")
        Title.Parent = ProgressFrame
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, library.theme.touchPadding, 0, 4)
        Title.Size = UDim2.new(1, -20, 0, 18)
        Title.Font = library.theme.fontBody
        Title.Text = name
        Title.TextColor3 = library.theme.textPrimary
        Title.TextSize = isMobile and 15 or 13
        Title.TextXAlignment = Enum.TextXAlignment.Left

        local PercentLabel = Instance.new("TextLabel")
        PercentLabel.Parent = ProgressFrame
        PercentLabel.BackgroundTransparency = 1
        PercentLabel.Position = UDim2.new(1, -50, 0, 4)
        PercentLabel.Size = UDim2.new(0, 40, 0, 18)
        PercentLabel.Font = library.theme.fontMono
        PercentLabel.Text = "0%"
        PercentLabel.TextColor3 = color or library.theme.accent
        PercentLabel.TextSize = isMobile and 14 or 12
        PercentLabel.TextXAlignment = Enum.TextXAlignment.Right

        local TrackBg = Instance.new("Frame")
        TrackBg.Parent = ProgressFrame
        TrackBg.BackgroundColor3 = library.theme.border
        TrackBg.BorderSizePixel = 0
        TrackBg.Position = UDim2.new(0, library.theme.touchPadding, 0, isMobile and 28 or 22)
        TrackBg.Size = UDim2.new(1, -library.theme.touchPadding * 2, 0, isMobile and 10 or 8)
        createCorner(TrackBg, UDim.new(1, 0))

        local TrackFill = Instance.new("Frame")
        TrackFill.Parent = TrackBg
        TrackFill.BackgroundColor3 = color or library.theme.accent
        TrackFill.BorderSizePixel = 0
        TrackFill.Size = UDim2.new(0, 0, 1, 0)
        createCorner(TrackFill, UDim.new(1, 0))

        local function setProgress(value)
            local percentage = math.max(0, math.min(1, value / max))
            tween(TrackFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.3)
            PercentLabel.Text = tostring(math.floor(percentage * 100)) .. "%"
        end

        ProgressFrame.MouseEnter:Connect(function()
            tween(ProgressFrame, {BackgroundTransparency = 0.2}, 0.2)
        end)
        ProgressFrame.MouseLeave:Connect(function()
            tween(ProgressFrame, {BackgroundTransparency = 0.5}, 0.2)
        end)

        reSize()
        return ProgressFrame, setProgress
    end

    -- Multi-Select (Checkbox List)
    function window:MultiSelect(name, objects, callback)
        local selected = {}
        local toggled = false

        local MultiFrame = Instance.new("Frame")
        MultiFrame.Name = "MultiSelect"
        MultiFrame.Parent = Container
        MultiFrame.BackgroundColor3 = library.theme.foreground
        MultiFrame.BackgroundTransparency = 0.5
        MultiFrame.BorderSizePixel = 0
        MultiFrame.Size = UDim2.new(1, 0, 0, library.theme.elementHeight)
        MultiFrame.LayoutOrder = #Container:GetChildren()
        MultiFrame.ClipsDescendants = false
        createCorner(MultiFrame)

        local Title = Instance.new("TextLabel")
        Title.Parent = MultiFrame
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, library.theme.touchPadding, 0, 0)
        Title.Size = UDim2.new(1, -50, 1, 0)
        Title.Font = library.theme.fontBody
        Title.Text = name
        Title.TextColor3 = library.theme.textPrimary
        Title.TextSize = isMobile and 16 or 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextYAlignment = Enum.TextYAlignment.Center

        local Arrow = Instance.new("ImageLabel")
        Arrow.Parent = MultiFrame
        Arrow.BackgroundTransparency = 1
        Arrow.Position = UDim2.new(1, -32, 0.5, -10)
        Arrow.Size = UDim2.new(0, 20, 0, 20)
        Arrow.Image = "rbxassetid://7072706663"
        Arrow.ImageColor3 = library.theme.textSecondary
        Arrow.Rotation = 0

        local CountLabel = Instance.new("TextLabel")
        CountLabel.Parent = MultiFrame
        CountLabel.BackgroundTransparency = 1
        CountLabel.Position = UDim2.new(1, -80, 0, 0)
        CountLabel.Size = UDim2.new(0, 50, 1, 0)
        CountLabel.Font = library.theme.fontMono
        CountLabel.Text = "0 selected"
        CountLabel.TextColor3 = library.theme.textSecondary
        CountLabel.TextSize = isMobile and 13 or 11
        CountLabel.TextXAlignment = Enum.TextXAlignment.Right
        CountLabel.TextYAlignment = Enum.TextYAlignment.Center

        local OptionsFrame = Instance.new("Frame")
        OptionsFrame.Parent = MultiFrame
        OptionsFrame.BackgroundColor3 = library.theme.foreground
        OptionsFrame.BorderSizePixel = 0
        OptionsFrame.Position = UDim2.new(0, 0, 0, library.theme.elementHeight + 4)
        OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
        OptionsFrame.ZIndex = 20
        OptionsFrame.ClipsDescendants = true
        createCorner(OptionsFrame)
        createStroke(OptionsFrame, library.theme.border, 1)

        local OptionsLayout = Instance.new("UIListLayout")
        OptionsLayout.Parent = OptionsFrame
        OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        OptionsLayout.Padding = UDim.new(0, 2)

        local OptionsPadding = Instance.new("UIPadding")
        OptionsPadding.Parent = OptionsFrame
        OptionsPadding.PaddingTop = UDim.new(0, 4)
        OptionsPadding.PaddingBottom = UDim.new(0, 4)
        OptionsPadding.PaddingLeft = UDim.new(0, 4)
        OptionsPadding.PaddingRight = UDim.new(0, 4)

        local totalHeight = 8
        for i, v in pairs(objects) do
            totalHeight = totalHeight + (isMobile and 36 or 30)

            local OptionRow = Instance.new("Frame")
            OptionRow.Parent = OptionsFrame
            OptionRow.BackgroundColor3 = library.theme.background
            OptionRow.BackgroundTransparency = 1
            OptionRow.BorderSizePixel = 0
            OptionRow.Size = UDim2.new(1, 0, 0, isMobile and 36 or 30)
            OptionRow.ZIndex = 21
            createCorner(OptionRow, UDim.new(0, 4))

            local CheckBox = Instance.new("Frame")
            CheckBox.Parent = OptionRow
            CheckBox.BackgroundColor3 = library.theme.border
            CheckBox.BorderSizePixel = 0
            CheckBox.Position = UDim2.new(0, 8, 0.5, -8)
            CheckBox.Size = UDim2.new(0, 16, 0, 16)
            createCorner(CheckBox, UDim.new(0, 4))

            local CheckFill = Instance.new("Frame")
            CheckFill.Parent = CheckBox
            CheckFill.BackgroundColor3 = library.theme.accent
            CheckFill.BorderSizePixel = 0
            CheckFill.Size = UDim2.new(0, 0, 0, 0)
            CheckFill.Position = UDim2.new(0.5, 0, 0.5, 0)
            CheckFill.AnchorPoint = Vector2.new(0.5, 0.5)
            createCorner(CheckFill, UDim.new(0, 3))

            local OptionText = Instance.new("TextLabel")
            OptionText.Parent = OptionRow
            OptionText.BackgroundTransparency = 1
            OptionText.Position = UDim2.new(0, 32, 0, 0)
            OptionText.Size = UDim2.new(1, -40, 1, 0)
            OptionText.Font = library.theme.fontBody
            OptionText.Text = tostring(v)
            OptionText.TextColor3 = library.theme.textSecondary
            OptionText.TextSize = isMobile and 14 or 13
            OptionText.TextXAlignment = Enum.TextXAlignment.Left
            OptionText.TextYAlignment = Enum.TextYAlignment.Center

            local ClickArea = Instance.new("TextButton")
            ClickArea.Parent = OptionRow
            ClickArea.BackgroundTransparency = 1
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.Text = ""
            ClickArea.ZIndex = 22

            local isSelected = false
            ClickArea.MouseButton1Click:Connect(function()
                isSelected = not isSelected
                if isSelected then
                    selected[v] = true
                    tween(CheckFill, {Size = UDim2.new(1, -4, 1, -4)}, 0.15)
                else
                    selected[v] = nil
                    tween(CheckFill, {Size = UDim2.new(0, 0, 0, 0)}, 0.15)
                end

                local count = 0
                for _ in pairs(selected) do count = count + 1 end
                CountLabel.Text = count .. " selected"

                if callback then callback(selected) end
            end)

            ClickArea.TouchTap:Connect(function()
                isSelected = not isSelected
                if isSelected then
                    selected[v] = true
                    tween(CheckFill, {Size = UDim2.new(1, -4, 1, -4)}, 0.15)
                else
                    selected[v] = nil
                    tween(CheckFill, {Size = UDim2.new(0, 0, 0, 0)}, 0.15)
                end

                local count = 0
                for _ in pairs(selected) do count = count + 1 end
                CountLabel.Text = count .. " selected"

                if callback then callback(selected) end
            end)

            OptionRow.MouseEnter:Connect(function()
                tween(OptionRow, {BackgroundTransparency = 0.5}, 0.15)
            end)
            OptionRow.MouseLeave:Connect(function()
                tween(OptionRow, {BackgroundTransparency = 1}, 0.15)
            end)
        end

        local MainClick = Instance.new("TextButton")
        MainClick.Parent = MultiFrame
        MainClick.BackgroundTransparency = 1
        MainClick.Size = UDim2.new(1, 0, 1, 0)
        MainClick.Text = ""
        MainClick.ZIndex = 5

        MainClick.MouseButton1Click:Connect(function()
            toggled = not toggled
            tween(Arrow, {Rotation = toggled and 180 or 0}, 0.3)
            tween(OptionsFrame, {Size = toggled and UDim2.new(1, 0, 0, math.min(totalHeight, 250)) or UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart, toggled and Enum.EasingDirection.Out or Enum.EasingDirection.In)
        end)

        MainClick.TouchTap:Connect(function()
            toggled = not toggled
            tween(Arrow, {Rotation = toggled and 180 or 0}, 0.3)
            tween(OptionsFrame, {Size = toggled and UDim2.new(1, 0, 0, math.min(totalHeight, 250)) or UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quart, toggled and Enum.EasingDirection.Out or Enum.EasingDirection.In)
        end)

        MultiFrame.MouseEnter:Connect(function()
            tween(MultiFrame, {BackgroundTransparency = 0.2}, 0.2)
        end)
        MultiFrame.MouseLeave:Connect(function()
            if not toggled then
                tween(MultiFrame, {BackgroundTransparency = 0.5}, 0.2)
            end
        end)

        reSize()
        return MultiFrame
    end

    -- Number Spinner
    function window:Spinner(name, min, max, default, callback, suffix)
        local current = default or min
        suffix = suffix or ""

        local SpinnerFrame = Instance.new("Frame")
        SpinnerFrame.Name = "Spinner"
        SpinnerFrame.Parent = Container
        SpinnerFrame.BackgroundColor3 = library.theme.foreground
        SpinnerFrame.BackgroundTransparency = 0.5
        SpinnerFrame.BorderSizePixel = 0
        SpinnerFrame.Size = UDim2.new(1, 0, 0, library.theme.elementHeight)
        SpinnerFrame.LayoutOrder = #Container:GetChildren()
        createCorner(SpinnerFrame)

        local Title = Instance.new("TextLabel")
        Title.Parent = SpinnerFrame
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, library.theme.touchPadding, 0, 0)
        Title.Size = UDim2.new(0.5, -library.theme.touchPadding, 1, 0)
        Title.Font = library.theme.fontBody
        Title.Text = name
        Title.TextColor3 = library.theme.textPrimary
        Title.TextSize = isMobile and 16 or 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextYAlignment = Enum.TextYAlignment.Center

        local Controls = Instance.new("Frame")
        Controls.Parent = SpinnerFrame
        Controls.BackgroundTransparency = 1
        Controls.Position = UDim2.new(0.5, 0, 0.5, -14)
        Controls.Size = UDim2.new(0.48, 0, 0, 28)

        local MinusBtn = Instance.new("TextButton")
        MinusBtn.Parent = Controls
        MinusBtn.BackgroundColor3 = library.theme.border
        MinusBtn.BorderSizePixel = 0
        MinusBtn.Size = UDim2.new(0, 28, 1, 0)
        MinusBtn.Font = library.theme.fontMono
        MinusBtn.Text = "-"
        MinusBtn.TextColor3 = library.theme.textPrimary
        MinusBtn.TextSize = 18
        MinusBtn.AutoButtonColor = false
        createCorner(MinusBtn, UDim.new(0, 6))

        local ValueBg = Instance.new("Frame")
        ValueBg.Parent = Controls
        ValueBg.BackgroundColor3 = library.theme.background
        ValueBg.BorderSizePixel = 0
        ValueBg.Position = UDim2.new(0, 32, 0, 0)
        ValueBg.Size = UDim2.new(1, -64, 1, 0)
        createCorner(ValueBg, UDim.new(0, 6))
        createStroke(ValueBg, library.theme.border, 1)

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = ValueBg
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Size = UDim2.new(1, 0, 1, 0)
        ValueLabel.Font = library.theme.fontMono
        ValueLabel.Text = tostring(current) .. suffix
        ValueLabel.TextColor3 = library.theme.accent
        ValueLabel.TextSize = isMobile and 15 or 13

        local PlusBtn = Instance.new("TextButton")
        PlusBtn.Parent = Controls
        PlusBtn.BackgroundColor3 = library.theme.accent
        PlusBtn.BorderSizePixel = 0
        PlusBtn.Position = UDim2.new(1, -28, 0, 0)
        PlusBtn.Size = UDim2.new(0, 28, 1, 0)
        PlusBtn.Font = library.theme.fontMono
        PlusBtn.Text = "+"
        PlusBtn.TextColor3 = library.theme.textPrimary
        PlusBtn.TextSize = 18
        PlusBtn.AutoButtonColor = false
        createCorner(PlusBtn, UDim.new(0, 6))

        local function updateValue(change)
            current = math.max(min, math.min(max, current + change))
            ValueLabel.Text = tostring(current) .. suffix
            if callback then callback(current) end
        end

        MinusBtn.MouseButton1Click:Connect(function()
            vibrate()
            tween(MinusBtn, {BackgroundColor3 = library.theme.surface}, 0.1)
            task.delay(0.1, function()
                tween(MinusBtn, {BackgroundColor3 = library.theme.border}, 0.1)
            end)
            updateValue(-1)
        end)

        MinusBtn.TouchTap:Connect(function()
            vibrate()
            updateValue(-1)
        end)

        PlusBtn.MouseButton1Click:Connect(function()
            vibrate()
            tween(PlusBtn, {BackgroundColor3 = library.theme.accentHover}, 0.1)
            task.delay(0.1, function()
                tween(PlusBtn, {BackgroundColor3 = library.theme.accent}, 0.1)
            end)
            updateValue(1)
        end)

        PlusBtn.TouchTap:Connect(function()
            vibrate()
            updateValue(1)
        end)

        SpinnerFrame.MouseEnter:Connect(function()
            tween(SpinnerFrame, {BackgroundTransparency = 0.2}, 0.2)
        end)
        SpinnerFrame.MouseLeave:Connect(function()
            tween(SpinnerFrame, {BackgroundTransparency = 0.5}, 0.2)
        end)

        reSize()
        return SpinnerFrame
    end

    -- Tooltip system
    function window:Tooltip(parent, text)
        local Tip = Instance.new("Frame")
        Tip.Name = "Tooltip"
        Tip.Parent = ScreenGui
        Tip.BackgroundColor3 = library.theme.surface
        Tip.BorderSizePixel = 0
        Tip.Size = UDim2.new(0, 0, 0, 0)
        Tip.ZIndex = 100
        Tip.Visible = false
        createCorner(Tip, UDim.new(0, 6))
        createStroke(Tip, library.theme.border, 1)
        createShadow(Tip, 0.5)

        local TipText = Instance.new("TextLabel")
        TipText.Parent = Tip
        TipText.BackgroundTransparency = 1
        TipText.Position = UDim2.new(0, 8, 0, 0)
        TipText.Size = UDim2.new(1, -16, 1, 0)
        TipText.Font = library.theme.fontBody
        TipText.Text = text
        TipText.TextColor3 = library.theme.textPrimary
        TipText.TextSize = 12
        TipText.TextWrapped = true
        TipText.TextYAlignment = Enum.TextYAlignment.Center

        parent.MouseEnter:Connect(function()
            Tip.Visible = true
            Tip.Size = UDim2.new(0, 0, 0, 0)
            Tip.Position = UDim2.new(0, parent.AbsolutePosition.X + parent.AbsoluteSize.X / 2, 0, parent.AbsolutePosition.Y - 30)

            local textSize = TipText.TextBounds
            tween(Tip, {Size = UDim2.new(0, math.min(textSize.X + 16, 200), 0, math.max(textSize.Y + 8, 24))}, 0.2)
        end)

        parent.MouseLeave:Connect(function()
            tween(Tip, {Size = UDim2.new(0, 0, 0, 0)}, 0.15)
            task.delay(0.15, function()
                Tip.Visible = false
            end)
        end)
    end

    -- Tab System
    function window:Tab(name)
        local tab = {
            elements = {},
            frame = nil
        }

        if not window.currentTab then
            -- Create tab bar on first tab
            local TabBar = Instance.new("Frame")
            TabBar.Name = "TabBar"
            TabBar.Parent = Container
            TabBar.BackgroundColor3 = library.theme.surface
            TabBar.BackgroundTransparency = 0.3
            TabBar.BorderSizePixel = 0
            TabBar.Size = UDim2.new(1, 0, 0, isMobile and 44 or 36)
            TabBar.LayoutOrder = 0
            createCorner(TabBar, UDim.new(0, 8))

            local TabLayout = Instance.new("UIListLayout")
            TabLayout.Parent = TabBar
            TabLayout.FillDirection = Enum.FillDirection.Horizontal
            TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
            TabLayout.Padding = UDim.new(0, 4)

            local TabPadding = Instance.new("UIPadding")
            TabPadding.Parent = TabBar
            TabPadding.PaddingLeft = UDim.new(0, 4)
            TabPadding.PaddingRight = UDim.new(0, 4)
            TabPadding.PaddingTop = UDim.new(0, 4)
            TabPadding.PaddingBottom = UDim.new(0, 4)

            window.tabBar = TabBar
            window.tabLayout = TabLayout
            window.tabs = {}
        end

        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = window.tabBar
        TabBtn.BackgroundColor3 = library.theme.background
        TabBtn.BackgroundTransparency = 0.5
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(0, 0, 1, 0)
        TabBtn.Font = library.theme.fontBody
        TabBtn.Text = name
        TabBtn.TextColor3 = library.theme.textSecondary
        TabBtn.TextSize = isMobile and 15 or 13
        TabBtn.AutoButtonColor = false
        createCorner(TabBtn, UDim.new(0, 6))

        local TabContent = Instance.new("Frame")
        TabContent.Parent = Container
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 0, 0)
        TabContent.LayoutOrder = 999
        TabContent.Visible = false

        local TabList = Instance.new("UIListLayout")
        TabList.Parent = TabContent
        TabList.SortOrder = Enum.SortOrder.LayoutOrder
        TabList.Padding = UDim.new(0, library.theme.spacing)

        local TabPad = Instance.new("UIPadding")
        TabPad.Parent = TabContent
        TabPad.PaddingLeft = UDim.new(0, 0)
        TabPad.PaddingRight = UDim.new(0, 0)
        TabPad.PaddingTop = UDim.new(0, 5)
        TabPad.PaddingBottom = UDim.new(0, 5)

        tab.frame = TabContent
        tab.button = TabBtn
        tab.content = TabContent

        table.insert(window.tabs, tab)

        local function switchTab()
            for _, t in pairs(window.tabs) do
                tween(t.button, {BackgroundTransparency = 0.5, TextColor3 = library.theme.textSecondary}, 0.2)
                t.content.Visible = false
            end
            tween(TabBtn, {BackgroundTransparency = 0, TextColor3 = library.theme.textPrimary}, 0.2)
            TabContent.Visible = true
            window.currentTab = tab
            reSize()
        end

        TabBtn.MouseButton1Click:Connect(function()
            switchTab()
        end)

        TabBtn.TouchTap:Connect(function()
            switchTab()
        end)

        TabBtn.MouseEnter:Connect(function()
            if window.currentTab ~= tab then
                tween(TabBtn, {BackgroundTransparency = 0.3}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if window.currentTab ~= tab then
                tween(TabBtn, {BackgroundTransparency = 0.5}, 0.2)
            end
        end)

        -- Auto-size tab buttons
        task.delay(0.1, function()
            local tabCount = #window.tabs
            for _, t in pairs(window.tabs) do
                t.button.Size = UDim2.new(0, (window.tabBar.AbsoluteSize.X - 8 - (tabCount - 1) * 4) / tabCount, 1, 0)
            end
        end)

        if #window.tabs == 1 then
            switchTab()
        end

        -- Override add functions for tab content
        local oldSection = window.Section
        local oldLabel = window.Label
        local oldToggle = window.Toggle
        local oldButton = window.Button
        local oldSlider = window.Slider
        local oldDropdown = window.Dropdown
        local oldBox = window.Box

        function tab:Section(text)
            local el = oldSection(text)
            el.Parent = TabContent
            return el
        end

        function tab:Label(text, color)
            local el = oldLabel(text, color)
            el.Parent = TabContent
            return el
        end

        function tab:Toggle(name, callback, default)
            local el = oldToggle(name, callback, default)
            el.Parent = TabContent
            return el
        end

        function tab:Button(name, callback, icon)
            local el = oldButton(name, callback, icon)
            el.Parent = TabContent
            return el
        end

        function tab:Slider(name, min, max, default, callback, suffix)
            local el = oldSlider(name, min, max, default, callback, suffix)
            el.Parent = TabContent
            return el
        end

        function tab:Dropdown(name, objects, callback)
            local el = oldDropdown(name, objects, callback)
            el.Parent = TabContent
            return el
        end

        function tab:Box(name, default, callback)
            local el = oldBox(name, default, callback)
            el.Parent = TabContent
            return el
        end

        reSize()
        return tab
    end

    -- Notification system
    function window:Notify(text, type, duration)
        type = type or "info"
        duration = duration or 3

        local notifColors = {
            info = library.theme.accent,
            success = library.theme.success,
            error = library.theme.error,
            warning = library.theme.warning
        }

        local NotifFrame = Instance.new("Frame")
        NotifFrame.Parent = ScreenGui
        NotifFrame.BackgroundColor3 = library.theme.background
        NotifFrame.BorderSizePixel = 0
        NotifFrame.Position = UDim2.new(1, -260, 1, -100)
        NotifFrame.Size = UDim2.new(0, 240, 0, isMobile and 70 or 60)
        NotifFrame.ZIndex = 100
        createCorner(NotifFrame, UDim.new(0, 12))
        createStroke(NotifFrame, notifColors[type] or library.theme.accent, 2)
        createShadow(NotifFrame, 0.6)

        local Icon = Instance.new("ImageLabel")
        Icon.Parent = NotifFrame
        Icon.BackgroundTransparency = 1
        Icon.Position = UDim2.new(0, 14, 0.5, -14)
        Icon.Size = UDim2.new(0, 28, 0, 28)
        Icon.Image = type == "success" and "rbxassetid://7072701038" or type == "error" and "rbxassetid://7072725362" or type == "warning" and "rbxassetid://7072720236" or "rbxassetid://7072719338"
        Icon.ImageColor3 = notifColors[type] or library.theme.accent

        local Message = Instance.new("TextLabel")
        Message.Parent = NotifFrame
        Message.BackgroundTransparency = 1
        Message.Position = UDim2.new(0, 52, 0, 10)
        Message.Size = UDim2.new(1, -64, 1, -20)
        Message.Font = library.theme.fontBody
        Message.Text = text
        Message.TextColor3 = library.theme.textPrimary
        Message.TextSize = isMobile and 15 or 13
        Message.TextWrapped = true
        Message.TextYAlignment = Enum.TextYAlignment.Center

        -- Animate in
        NotifFrame.Position = UDim2.new(1, 20, 1, -100)
        tween(NotifFrame, {Position = UDim2.new(1, -260, 1, -100)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        task.delay(duration, function()
            tween(NotifFrame, {Position = UDim2.new(1, 20, 1, -100)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.wait(0.5)
            NotifFrame:Destroy()
        end)
    end

    reSize()
    return window
end

return library
