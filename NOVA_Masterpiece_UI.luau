--[[
    NOVA v3.0.0
    AAA FUTURISTIC COMMAND CENTER
    SINGLE SELF-CONTAINED ROBLOX LUAU SCRIPT

    No external UI libraries, ModuleScripts, folders, or dependencies.
    Paste this entire file into a LocalScript / execute in a client-side
    environment appropriate for your own Roblox experience.

    Sections:
    CONFIG / SERVICES / THEME / UTILITY / CLEANUP / ANIMATION / EFFECTS /
    DRAG SYSTEM / RESPONSIVE SYSTEM / COMPONENTS / WINDOW /
    MOBILE CONTROL / NOTIFICATIONS / STATUS / CONSOLE / DEMO
]]

--==============================================================
-- CONFIG
--==============================================================

local CONFIG = {
    Name = "NOVA",
    Version = "3.0.0",
    Theme = "NeonPurple",
    Animations = true,
    Particles = true,
    Glow = true,
    PerformanceMode = false,
    MinimumTouchSize = 44,
    DesktopWidth = 1080,
    DesktopHeight = 690,
    TabletWidth = 900,
    TabletHeight = 640,
    MobileWidth = 0.92,
    MobileHeight = 0.84,
    MaxNotifications = 5,
}

--==============================================================
-- SERVICES
--==============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==============================================================
-- THEME
--==============================================================

local THEMES = {
    NeonPurple = {
        Background = Color3.fromRGB(5, 6, 13),
        Background2 = Color3.fromRGB(12, 9, 27),
        Panel = Color3.fromRGB(11, 12, 23),
        Panel2 = Color3.fromRGB(16, 15, 31),
        Panel3 = Color3.fromRGB(23, 20, 43),
        Accent = Color3.fromRGB(174, 91, 255),
        Accent2 = Color3.fromRGB(67, 222, 255),
        Accent3 = Color3.fromRGB(255, 85, 207),
        Success = Color3.fromRGB(69, 255, 161),
        Warning = Color3.fromRGB(255, 191, 76),
        Error = Color3.fromRGB(255, 81, 109),
        Text = Color3.fromRGB(239, 239, 255),
        Muted = Color3.fromRGB(145, 147, 175),
        Dim = Color3.fromRGB(77, 79, 104),
        Border = Color3.fromRGB(73, 60, 113),
    },
    CyberBlue = {
        Background = Color3.fromRGB(3, 8, 15),
        Background2 = Color3.fromRGB(5, 18, 31),
        Panel = Color3.fromRGB(7, 16, 26),
        Panel2 = Color3.fromRGB(9, 22, 36),
        Panel3 = Color3.fromRGB(12, 32, 49),
        Accent = Color3.fromRGB(40, 174, 255),
        Accent2 = Color3.fromRGB(60, 255, 239),
        Accent3 = Color3.fromRGB(93, 115, 255),
        Success = Color3.fromRGB(69, 255, 161),
        Warning = Color3.fromRGB(255, 191, 76),
        Error = Color3.fromRGB(255, 81, 109),
        Text = Color3.fromRGB(236, 249, 255),
        Muted = Color3.fromRGB(132, 161, 180),
        Dim = Color3.fromRGB(67, 91, 108),
        Border = Color3.fromRGB(42, 89, 119),
    },
    Crimson = {
        Background = Color3.fromRGB(12, 4, 9),
        Background2 = Color3.fromRGB(26, 5, 16),
        Panel = Color3.fromRGB(21, 8, 16),
        Panel2 = Color3.fromRGB(32, 10, 22),
        Panel3 = Color3.fromRGB(48, 13, 29),
        Accent = Color3.fromRGB(255, 69, 111),
        Accent2 = Color3.fromRGB(255, 116, 77),
        Accent3 = Color3.fromRGB(196, 66, 255),
        Success = Color3.fromRGB(69, 255, 161),
        Warning = Color3.fromRGB(255, 191, 76),
        Error = Color3.fromRGB(255, 81, 109),
        Text = Color3.fromRGB(255, 238, 245),
        Muted = Color3.fromRGB(174, 137, 151),
        Dim = Color3.fromRGB(111, 70, 88),
        Border = Color3.fromRGB(115, 48, 71),
    },
    Toxic = {
        Background = Color3.fromRGB(5, 10, 6),
        Background2 = Color3.fromRGB(8, 23, 12),
        Panel = Color3.fromRGB(8, 18, 11),
        Panel2 = Color3.fromRGB(12, 27, 15),
        Panel3 = Color3.fromRGB(16, 38, 20),
        Accent = Color3.fromRGB(123, 255, 70),
        Accent2 = Color3.fromRGB(57, 255, 191),
        Accent3 = Color3.fromRGB(210, 255, 62),
        Success = Color3.fromRGB(69, 255, 161),
        Warning = Color3.fromRGB(255, 191, 76),
        Error = Color3.fromRGB(255, 81, 109),
        Text = Color3.fromRGB(239, 255, 234),
        Muted = Color3.fromRGB(145, 172, 148),
        Dim = Color3.fromRGB(72, 104, 77),
        Border = Color3.fromRGB(60, 114, 69),
    },
    Void = {
        Background = Color3.fromRGB(2, 2, 5),
        Background2 = Color3.fromRGB(8, 5, 14),
        Panel = Color3.fromRGB(7, 7, 12),
        Panel2 = Color3.fromRGB(13, 10, 20),
        Panel3 = Color3.fromRGB(21, 14, 32),
        Accent = Color3.fromRGB(145, 86, 255),
        Accent2 = Color3.fromRGB(235, 86, 255),
        Accent3 = Color3.fromRGB(92, 76, 255),
        Success = Color3.fromRGB(69, 255, 161),
        Warning = Color3.fromRGB(255, 191, 76),
        Error = Color3.fromRGB(255, 81, 109),
        Text = Color3.fromRGB(242, 237, 255),
        Muted = Color3.fromRGB(142, 137, 159),
        Dim = Color3.fromRGB(70, 65, 83),
        Border = Color3.fromRGB(78, 57, 117),
    },
    Arctic = {
        Background = Color3.fromRGB(4, 9, 14),
        Background2 = Color3.fromRGB(8, 18, 27),
        Panel = Color3.fromRGB(9, 19, 27),
        Panel2 = Color3.fromRGB(13, 28, 39),
        Panel3 = Color3.fromRGB(18, 39, 53),
        Accent = Color3.fromRGB(104, 220, 255),
        Accent2 = Color3.fromRGB(180, 255, 245),
        Accent3 = Color3.fromRGB(121, 151, 255),
        Success = Color3.fromRGB(69, 255, 161),
        Warning = Color3.fromRGB(255, 191, 76),
        Error = Color3.fromRGB(255, 81, 109),
        Text = Color3.fromRGB(239, 251, 255),
        Muted = Color3.fromRGB(143, 169, 180),
        Dim = Color3.fromRGB(72, 98, 109),
        Border = Color3.fromRGB(56, 101, 118),
    },
}

local Theme = THEMES[CONFIG.Theme]

--==============================================================
-- UTILITY
--==============================================================

local UI = {
    Name = CONFIG.Name,
    Version = CONFIG.Version,
    ThemeName = CONFIG.Theme,
    Theme = Theme,
    Connections = {},
    Instances = {},
    Tweens = {},
    Effects = {},
    Notifications = {},
    Logs = {},
    Tabs = {},
    CurrentTab = nil,
    Visible = true,
    Mobile = false,
    Tablet = false,
    Destroyed = false,
    PerformanceMode = CONFIG.PerformanceMode,
    Animations = CONFIG.Animations,
    Particles = CONFIG.Particles,
    Glow = CONFIG.Glow,
    Scale = 1,
    Status = "READY",
    StatusDetail = "Systems standing by.",
    Window = nil,
    Root = nil,
    Content = nil,
    Sidebar = nil,
    MobileDrawer = nil,
    MobileOverlay = nil,
    MobileControl = nil,
    ConsoleEntries = {},
}

local function clamp(x, a, b)
    return math.max(a, math.min(b, x))
end

local function round(n)
    return math.floor(n + 0.5)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function disconnect(conn)
    if conn then
        pcall(function() conn:Disconnect() end)
    end
end

local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(UI.Connections, c)
    return c
end

local function track(instance)
    if instance then
        table.insert(UI.Instances, instance)
    end
    return instance
end

local function addTween(tween)
    table.insert(UI.Tweens, tween)
    return tween
end

local function tween(instance, info, props)
    if not UI.Animations then
        for k, v in pairs(props) do
            pcall(function() instance[k] = v end)
        end
        return nil
    end
    local tw = TweenService:Create(instance, info, props)
    addTween(tw)
    tw:Play()
    return tw
end

local function colorSequence(a, b)
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, a),
        ColorSequenceKeypoint.new(1, b),
    })
end

local function make(className, props, parent)
    local obj = track(Instance.new(className))
    for k, v in pairs(props or {}) do
        pcall(function() obj[k] = v end)
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

local function corner(parent, radius)
    return make("UICorner", {CornerRadius = UDim.new(0, radius or 8)}, parent)
end

local function stroke(parent, color, thickness, transparency)
    return make("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function gradient(parent, c1, c2, rotation)
    return make("UIGradient", {
        Color = colorSequence(c1, c2),
        Rotation = rotation or 0,
    }, parent)
end

local function padding(parent, top, right, bottom, left)
    return make("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        PaddingLeft = UDim.new(0, left or right or top or 0),
    }, parent)
end

local function textLabel(parent, text, size, font, color)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Text = text or "",
        TextSize = size or 14,
        Font = font or Enum.Font.Gotham,
        TextColor3 = color or Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        AutoLocalize = false,
    }, parent)
end

local function textButton(parent, text, size)
    return make("TextButton", {
        BackgroundTransparency = 1,
        Text = text or "",
        TextSize = size or 14,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoLocalize = false,
    }, parent)
end

local function formatTime()
    return os.date("%H:%M:%S")
end

local function formatRuntime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function viewport()
    local cam = workspace.CurrentCamera
    if cam then
        return cam.ViewportSize
    end
    return Vector2.new(1280, 720)
end

local function deviceClass()
    local v = viewport()
    local touch = UserInputService.TouchEnabled
    if v.X < 700 or (touch and v.X < 820) then
        return "Mobile"
    elseif v.X < 1050 then
        return "Tablet"
    end
    return "Desktop"
end

--==============================================================
-- CLEANUP
--==============================================================

local function cleanupTable(t)
    for i = #t, 1, -1 do
        local v = t[i]
        if typeof(v) == "RBXScriptConnection" then
            disconnect(v)
        elseif typeof(v) == "Instance" then
            pcall(function() v:Destroy() end)
        elseif typeof(v) == "Tween" then
            pcall(function() v:Cancel() end)
        elseif type(v) == "function" then
            pcall(v)
        end
        t[i] = nil
    end
end

function UI:Destroy()
    if self.Destroyed then
        return
    end
    self.Destroyed = true

    cleanupTable(self.Connections)
    cleanupTable(self.Tweens)
    cleanupTable(self.Effects)

    for i = #self.Instances, 1, -1 do
        local inst = self.Instances[i]
        if inst and inst.Parent then
            pcall(function() inst:Destroy() end)
        end
        self.Instances[i] = nil
    end

    self.Notifications = {}
    self.Logs = {}
    self.ConsoleEntries = {}
end

--==============================================================
-- ANIMATION
--==============================================================

local Animation = {}

Animation.Fast = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
Animation.Smooth = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
Animation.Slow = TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
Animation.Spring = TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

function Animation.Scale(gui, scaleValue, duration)
    local s = gui:FindFirstChildOfClass("UIScale")
    if not s then
        s = make("UIScale", {Scale = 1}, gui)
    end
    return tween(s, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Scale = scaleValue
    })
end

function Animation.Appear(gui, targetTransparency)
    gui.Visible = true
    if gui:IsA("GuiObject") then
        local original = gui.BackgroundTransparency
        gui.BackgroundTransparency = 1
        tween(gui, Animation.Smooth, {BackgroundTransparency = targetTransparency or original})
    end
end

--==============================================================
-- EFFECTS
--==============================================================

local Effects = {}

function Effects.Glow(gui, color, size, transparency)
    if UI.PerformanceMode or not UI.Glow then
        return nil
    end
    local existing = gui:FindFirstChild("NOVA_GLOW")
    if existing then
        return existing
    end

    local glow = make("ImageLabel", {
        Name = "NOVA_GLOW",
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = color or Theme.Accent,
        ImageTransparency = transparency or 0.72,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        Size = UDim2.new(1, size or 22, 1, size or 22),
        Position = UDim2.fromOffset(-(size or 22) / 2, -(size or 22) / 2),
        ZIndex = math.max(0, gui.ZIndex - 1),
        Name = "NOVA_GLOW",
    }, gui)
    return glow
end

function Effects.Pulse(gui, color)
    if UI.PerformanceMode or not UI.Animations then return end
    local strokeObj = gui:FindFirstChildOfClass("UIStroke")
    if not strokeObj then return end
    local c = color or Theme.Accent
    strokeObj.Color = c
    strokeObj.Transparency = 0.15
    local t = tween(strokeObj, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        Transparency = 0.72
    })
    if t then
        t.Completed:Connect(function()
            if strokeObj.Parent and not UI.Destroyed then
                tween(strokeObj, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Transparency = 0.15
                })
            end
        end)
    end
end

function Effects.Ripple(parent, position, color)
    if UI.PerformanceMode then return end
    local r = make("Frame", {
        BackgroundColor3 = color or Theme.Accent2,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(4, 4),
        Position = UDim2.fromOffset(position.X - 2, position.Y - 2),
        ZIndex = 50,
    }, parent)
    corner(r, 999)
    local scale = make("UIScale", {Scale = 1}, r)
    tween(r, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    tween(scale, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Scale = 18
    })
    task.delay(0.55, function()
        if r.Parent then r:Destroy() end
    end)
end

function Effects.Shimmer(parent)
    if UI.PerformanceMode then return end
    local beam = make("Frame", {
        BackgroundColor3 = Theme.Accent2,
        BackgroundTransparency = 0.86,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, -140, 0, 0),
        Rotation = 10,
        ZIndex = 5,
    }, parent)
    local g = gradient(beam, Color3.new(1,1,1), Color3.new(1,1,1), 0)
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    tween(beam, TweenInfo.new(0.75, Enum.EasingStyle.Linear), {
        Position = UDim2.new(1, 30, 0, 0)
    })
    task.delay(0.8, function()
        if beam.Parent then beam:Destroy() end
    end)
end

function Effects.Scanline(parent)
    if UI.PerformanceMode then return end
    local line = make("Frame", {
        BackgroundColor3 = Theme.Accent2,
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, -2),
        ZIndex = 3,
    }, parent)
    local alive = true
    table.insert(UI.Effects, function() alive = false end)
    task.spawn(function()
        while alive and line.Parent and not UI.Destroyed do
            tween(line, TweenInfo.new(2.8, Enum.EasingStyle.Linear), {
                Position = UDim2.new(0, 0, 1, 2)
            })
            task.wait(2.85)
            if not line.Parent then break end
            line.Position = UDim2.new(0, 0, 0, -2)
        end
    end)
end

function Effects.EnergySweep(parent)
    if UI.PerformanceMode then return end
    local sweep = make("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 2, 1, 0),
        Position = UDim2.new(0, -2, 0, 0),
        ZIndex = 8,
    }, parent)
    local grad = gradient(sweep, Theme.Accent, Theme.Accent2, 0)
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })
    tween(sweep, TweenInfo.new(1.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
        Position = UDim2.new(1, 2, 0, 0),
    })
    task.delay(1.5, function()
        if sweep.Parent then sweep:Destroy() end
    end)
end

function Effects.ParticleBurst(parent, origin, amount)
    if UI.PerformanceMode or not UI.Particles then return end
    amount = math.min(amount or 10, 22)
    for i = 1, amount do
        local p = make("Frame", {
            BackgroundColor3 = (i % 2 == 0) and Theme.Accent or Theme.Accent2,
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4)),
            Position = UDim2.fromOffset(origin.X, origin.Y),
            ZIndex = 60,
        }, parent)
        corner(p, 99)
        local angle = math.random() * math.pi * 2
        local dist = math.random(25, 90)
        tween(p, TweenInfo.new(0.55 + math.random() * 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.fromOffset(origin.X + math.cos(angle) * dist, origin.Y + math.sin(angle) * dist),
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(1, 1),
        })
        task.delay(1, function()
            if p.Parent then p:Destroy() end
        end)
    end
end

function Effects.Glitch(gui)
    if UI.PerformanceMode then return end
    local original = gui.Position
    for i = 1, 5 do
        gui.Position = original + UDim2.fromOffset(math.random(-2,2), math.random(-1,1))
        task.wait(0.025)
    end
    gui.Position = original
end

--==============================================================
-- DRAG SYSTEM
--==============================================================

local function MakeDraggable(object, handle)
    handle = handle or object
    local dragging = false
    local dragStart
    local startPos
    local activeInput

    local function update(input)
        if not object.Parent then return end
        local delta = input.Position - dragStart
        local parent = object.Parent
        local psize = parent.AbsoluteSize
        local osize = object.AbsoluteSize

        local x = startPos.X.Offset + delta.X
        local y = startPos.Y.Offset + delta.Y

        if psize.X > osize.X then
            x = clamp(x, 0, psize.X - osize.X)
        end
        if psize.Y > osize.Y then
            y = clamp(y, 0, psize.Y - osize.Y)
        end

        object.Position = UDim2.fromOffset(x, y)
    end

    connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            activeInput = input

            connect(input.Changed, function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    activeInput = nil
                end
            end)
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
            or input == activeInput) then
            update(input)
        end
    end)

    return object
end

UI.MakeDraggable = MakeDraggable

--==============================================================
-- RESPONSIVE SYSTEM
--==============================================================

local function setVisibleSafe(obj, visible)
    if obj then obj.Visible = visible end
end

local function updateResponsive()
    if UI.Destroyed or not UI.Root then return end
    local class = deviceClass()
    UI.Mobile = class == "Mobile"
    UI.Tablet = class == "Tablet"

    local v = viewport()
    local mobile = UI.Mobile
    local tablet = UI.Tablet

    if UI.Window then
        if mobile then
            UI.Window.Size = UDim2.new(CONFIG.MobileWidth, 0, CONFIG.MobileHeight, 0)
            UI.Window.AnchorPoint = Vector2.new(0.5, 0.5)
            UI.Window.Position = UDim2.new(0.5, 0, 0.51, 0)
            setVisibleSafe(UI.Sidebar, false)
            setVisibleSafe(UI.MobileMenuButton, true)
            if UI.ContentPadding then UI.ContentPadding.PaddingLeft = UDim.new(0, 12) end
        elseif tablet then
            UI.Window.Size = UDim2.fromOffset(math.min(CONFIG.TabletWidth, v.X - 40), math.min(CONFIG.TabletHeight, v.Y - 40))
            UI.Window.AnchorPoint = Vector2.new(0.5, 0.5)
            UI.Window.Position = UDim2.new(0.5, 0, 0.5, 0)
            setVisibleSafe(UI.Sidebar, true)
            setVisibleSafe(UI.MobileMenuButton, false)
            if UI.ContentPadding then UI.ContentPadding.PaddingLeft = UDim.new(0, 16) end
        else
            UI.Window.Size = UDim2.fromOffset(math.min(CONFIG.DesktopWidth, v.X - 60), math.min(CONFIG.DesktopHeight, v.Y - 60))
            UI.Window.AnchorPoint = Vector2.new(0.5, 0.5)
            UI.Window.Position = UDim2.new(0.5, 0, 0.5, 0)
            setVisibleSafe(UI.Sidebar, true)
            setVisibleSafe(UI.MobileMenuButton, false)
            if UI.ContentPadding then UI.ContentPadding.PaddingLeft = UDim.new(0, 22) end
        end
    end

    if UI.MobileControl then
        UI.MobileControl.Visible = mobile or tablet
    end
end

--==============================================================
-- COMPONENTS
--==============================================================

local Components = {}

local function addHover(button, panel, accent)
    accent = accent or Theme.Accent
    local st = panel:FindFirstChildOfClass("UIStroke")
    connect(button.MouseEnter, function()
        if UI.PerformanceMode then return end
        tween(panel, Animation.Fast, {BackgroundColor3 = Theme.Panel3})
        if st then tween(st, Animation.Fast, {Color = accent, Transparency = 0.12}) end
    end)
    connect(button.MouseLeave, function()
        tween(panel, Animation.Fast, {BackgroundColor3 = Theme.Panel2})
        if st then tween(st, Animation.Fast, {Color = Theme.Border, Transparency = 0.25}) end
    end)
end

function Components.Button(parent, data)
    local panel = make("Frame", {
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 62),
    }, parent)
    corner(panel, 10)
    local st = stroke(panel, Theme.Border, 1, 0.22)
    local grad = gradient(panel, Theme.Panel3, Theme.Panel2, 0)
    grad.Transparency = NumberSequence.new(0.18)

    local accentBar = make("Frame", {
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 0.58, 0),
        Position = UDim2.new(0, 0, 0.21, 0),
    }, panel)
    corner(accentBar, 3)

    local icon = textLabel(panel, data.Icon or "◈", 17, Enum.Font.GothamBold, Theme.Accent2)
    icon.Position = UDim2.fromOffset(17, 0)
    icon.Size = UDim2.fromOffset(24, 62)
    icon.TextXAlignment = Enum.TextXAlignment.Center

    local title = textLabel(panel, string.upper(data.Name or "COMMAND"), 13, Enum.Font.GothamBold, Theme.Text)
    title.Position = UDim2.fromOffset(50, 10)
    title.Size = UDim2.new(1, -70, 0, 22)

    local desc = textLabel(panel, data.Description or "", 10, Enum.Font.Gotham, Theme.Muted)
    desc.Position = UDim2.fromOffset(50, 31)
    desc.Size = UDim2.new(1, -70, 0, 18)

    local hit = textButton(panel, "", 14)
    hit.Size = UDim2.fromScale(1,1)
    hit.ZIndex = 10

    addHover(hit, panel)

    connect(hit.MouseButton1Click, function()
        Effects.Ripple(panel, hit.AbsolutePosition and Vector2.new(
            hit.AbsolutePosition.X + hit.AbsoluteSize.X/2 - panel.AbsolutePosition.X,
            hit.AbsolutePosition.Y + hit.AbsoluteSize.Y/2 - panel.AbsolutePosition.Y
        ) or Vector2.new(panel.AbsoluteSize.X/2, panel.AbsoluteSize.Y/2), Theme.Accent)
        Effects.Shimmer(panel)
        Effects.ParticleBurst(panel, Vector2.new(panel.AbsoluteSize.X/2, panel.AbsoluteSize.Y/2), 7)
        Animation.Scale(panel, 0.985, 0.08)
        task.delay(0.09, function() Animation.Scale(panel, 1, 0.18) end)
        if data.Callback then data.Callback() end
    end)

    return {
        Instance = panel,
        SetEnabled = function(_, enabled)
            hit.Active = enabled
            title.TextColor3 = enabled and Theme.Text or Theme.Dim
            desc.TextColor3 = enabled and Theme.Muted or Theme.Dim
        end
    }
end

function Components.Toggle(parent, data)
    local panel = make("Frame", {
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 70),
    }, parent)
    corner(panel, 10)
    stroke(panel, Theme.Border, 1, 0.25)

    local title = textLabel(panel, string.upper(data.Name or "FEATURE"), 12, Enum.Font.GothamBold, Theme.Text)
    title.Position = UDim2.fromOffset(16, 10)
    title.Size = UDim2.new(1, -95, 0, 20)

    local desc = textLabel(panel, data.Description or "", 10, Enum.Font.Gotham, Theme.Muted)
    desc.Position = UDim2.fromOffset(16, 33)
    desc.Size = UDim2.new(1, -100, 0, 18)

    local switch = make("Frame", {
        BackgroundColor3 = Theme.Dim,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(58, 30),
        Position = UDim2.new(1, -74, 0.5, -15),
    }, panel)
    corner(switch, 99)
    local swStroke = stroke(switch, Theme.Border, 1, 0.1)
    local knob = make("Frame", {
        BackgroundColor3 = Theme.Muted,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(22,22),
        Position = UDim2.fromOffset(4,4),
    }, switch)
    corner(knob, 99)

    local hit = textButton(panel, "", 14)
    hit.Size = UDim2.fromScale(1,1)
    hit.ZIndex = 5

    local state = data.Default == true

    local function render()
        if state then
            switch.BackgroundColor3 = Theme.Accent
            knob.BackgroundColor3 = Theme.Text
            tween(knob, Animation.Spring, {Position = UDim2.fromOffset(32,4)})
            if swStroke then tween(swStroke, Animation.Fast, {Color = Theme.Accent2}) end
            Effects.Pulse(switch, Theme.Accent)
        else
            switch.BackgroundColor3 = Theme.Dim
            knob.BackgroundColor3 = Theme.Muted
            tween(knob, Animation.Fast, {Position = UDim2.fromOffset(4,4)})
            if swStroke then tween(swStroke, Animation.Fast, {Color = Theme.Border}) end
        end
    end

    connect(hit.MouseButton1Click, function()
        state = not state
        render()
        if data.Callback then data.Callback(state) end
    end)

    render()

    return {
        Instance = panel,
        Get = function() return state end,
        Set = function(_, value)
            state = value == true
            render()
            if data.Callback then data.Callback(state) end
        end
    }
end

function Components.Slider(parent, data)
    local min = tonumber(data.Min) or 0
    local max = tonumber(data.Max) or 100
    local step = tonumber(data.Step) or 1
    local value = clamp(tonumber(data.Default) or min, min, max)

    local panel = make("Frame", {
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,88),
    }, parent)
    corner(panel, 10)
    stroke(panel, Theme.Border, 1, 0.25)

    local title = textLabel(panel, string.upper(data.Name or "SLIDER"), 12, Enum.Font.GothamBold, Theme.Text)
    title.Position = UDim2.fromOffset(16, 10)
    title.Size = UDim2.new(1, -100, 0, 20)

    local valueLabel = textLabel(panel, tostring(value), 12, Enum.Font.GothamBold, Theme.Accent2)
    valueLabel.Position = UDim2.new(1, -85, 0, 10)
    valueLabel.Size = UDim2.fromOffset(70, 20)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local trackBar = make("Frame", {
        BackgroundColor3 = Theme.Dim,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -32, 0, 6),
        Position = UDim2.fromOffset(16, 52),
    }, panel)
    corner(trackBar, 99)

    local fill = make("Frame", {
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0,0,1,0),
    }, trackBar)
    corner(fill,99)
    gradient(fill, Theme.Accent, Theme.Accent2, 0)

    local thumb = make("Frame", {
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(14,14),
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0,0,0.5,0),
        ZIndex = 3,
    }, trackBar)
    corner(thumb,99)
    Effects.Glow(thumb, Theme.Accent2, 12, 0.45)

    local dragging = false

    local function setFromX(x)
        local rel = clamp((x - trackBar.AbsolutePosition.X) / math.max(1, trackBar.AbsoluteSize.X), 0, 1)
        local raw = min + (max - min) * rel
        local stepped = min + math.floor((raw - min) / step + 0.5) * step
        value = clamp(stepped, min, max)
        local ratio = (value - min) / math.max(0.0001, max - min)
        valueLabel.Text = tostring(value)
        fill.Size = UDim2.new(ratio,0,1,0)
        thumb.Position = UDim2.new(ratio,0,0.5,0)
        if data.Callback then data.Callback(value) end
    end

    connect(trackBar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        Instance = panel,
        Get = function() return value end,
        Set = function(_, v)
            value = clamp(tonumber(v) or min, min, max)
            local ratio = (value-min)/math.max(0.0001,max-min)
            valueLabel.Text = tostring(value)
            fill.Size = UDim2.new(ratio,0,1,0)
            thumb.Position = UDim2.new(ratio,0,0.5,0)
            if data.Callback then data.Callback(value) end
        end
    }
end

function Components.NumberInput(parent, data)
    local min = tonumber(data.Min) or -math.huge
    local max = tonumber(data.Max) or math.huge
    local step = tonumber(data.Step) or 1
    local value = tonumber(data.Default) or 0

    local panel = make("Frame", {
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,0,92),
    }, parent)
    corner(panel,10)
    stroke(panel,Theme.Border,1,0.25)

    local title = textLabel(panel,string.upper(data.Name or "VALUE"),11,Enum.Font.GothamBold,Theme.Text)
    title.Position = UDim2.fromOffset(16,9)
    title.Size = UDim2.new(1,-32,0,18)

    local box = make("TextBox", {
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1,-104,0,40),
        Position = UDim2.fromOffset(16,38),
        Text = tostring(value),
        TextColor3 = Theme.Text,
        PlaceholderColor3 = Theme.Dim,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, panel)
    corner(box,8)
    stroke(box,Theme.Border,1,0.3)

    local minus = textButton(panel,"−",18)
    minus.Size = UDim2.fromOffset(38,40)
    minus.Position = UDim2.new(1,-82,0,38)
    minus.TextXAlignment = Enum.TextXAlignment.Center
    minus.BackgroundColor3 = Theme.Panel3
    corner(minus,8)

    local plus = textButton(panel,"+",18)
    plus.Size = UDim2.fromOffset(38,40)
    plus.Position = UDim2.new(1,-40,0,38)
    plus.TextXAlignment = Enum.TextXAlignment.Center
    plus.BackgroundColor3 = Theme.Panel3
    corner(plus,8)

    local function commit(v)
        v = tonumber(v)
        if not v then
            box.Text = tostring(value)
            return
        end
        v = clamp(v,min,max)
        if step > 0 then
            v = min + math.floor((v-min)/step + 0.5)*step
            v = clamp(v,min,max)
        end
        value = v
        box.Text = tostring(value)
        if data.Callback then data.Callback(value) end
    end

    connect(box.FocusLost,function()
        commit(box.Text)
    end)
    connect(minus.MouseButton1Click,function() commit(value-step) end)
    connect(plus.MouseButton1Click,function() commit(value+step) end)

    return {
        Instance=panel,
        Get=function() return value end,
        Set=function(_,v) commit(v) end
    }
end

function Components.TextInput(parent,data)
    local panel=make("Frame",{
        BackgroundColor3=Theme.Panel2,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,78)
    },parent)
    corner(panel,10)
    stroke(panel,Theme.Border,1,0.25)

    local title=textLabel(panel,string.upper(data.Name or "TEXT"),11,Enum.Font.GothamBold,Theme.Text)
    title.Position=UDim2.fromOffset(16,8)
    title.Size=UDim2.new(1,-32,0,18)

    local box=make("TextBox",{
        BackgroundColor3=Theme.Background,
        BorderSizePixel=0,
        Size=UDim2.new(1,-32,0,36),
        Position=UDim2.fromOffset(16,34),
        Text=data.Default or "",
        PlaceholderText=data.Placeholder or "ENTER VALUE",
        PlaceholderColor3=Theme.Dim,
        TextColor3=Theme.Text,
        TextSize=12,
        Font=Enum.Font.Gotham,
        ClearTextOnFocus=false,
        TextXAlignment=Enum.TextXAlignment.Left,
    },panel)
    corner(box,8)
    stroke(box,Theme.Border,1,0.3)
    padding(box,0,12,0,12)

    connect(box.FocusGained,function()
        local s=box:FindFirstChildOfClass("UIStroke")
        if s then tween(s,Animation.Fast,{Color=Theme.Accent,Transparency=0.1}) end
    end)
    connect(box.FocusLost,function()
        local s=box:FindFirstChildOfClass("UIStroke")
        if s then tween(s,Animation.Fast,{Color=Theme.Border,Transparency=0.3}) end
        if data.Callback then data.Callback(box.Text) end
    end)

    return {
        Instance=panel,
        Get=function() return box.Text end,
        Set=function(_,v) box.Text=tostring(v) if data.Callback then data.Callback(box.Text) end end
    }
end

function Components.Dropdown(parent,data,multi)
    local options=data.Options or {}
    local selected=multi and {} or data.Default
    local open=false

    local panel=make("Frame",{
        BackgroundColor3=Theme.Panel2,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,76)
    },parent)
    corner(panel,10)
    stroke(panel,Theme.Border,1,0.25)

    local title=textLabel(panel,string.upper(data.Name or "SELECT"),11,Enum.Font.GothamBold,Theme.Text)
    title.Position=UDim2.fromOffset(16,8)
    title.Size=UDim2.new(1,-32,0,18)

    local selector=make("TextButton",{
        BackgroundColor3=Theme.Background,
        BorderSizePixel=0,
        Size=UDim2.new(1,-32,0,38),
        Position=UDim2.fromOffset(16,31),
        Text="",
        AutoButtonColor=false,
    },panel)
    corner(selector,8)
    stroke(selector,Theme.Border,1,0.3)

    local selectedText=textLabel(selector,"SELECT...",11,Enum.Font.GothamMedium,Theme.Muted)
    selectedText.Position=UDim2.fromOffset(12,0)
    selectedText.Size=UDim2.new(1,-40,1,0)

    local arrow=textLabel(selector,"⌄",17,Enum.Font.GothamBold,Theme.Accent2)
    arrow.Position=UDim2.new(1,-34,0,0)
    arrow.Size=UDim2.fromOffset(26,38)
    arrow.TextXAlignment=Enum.TextXAlignment.Center

    local popup=make("Frame",{
        BackgroundColor3=Theme.Panel3,
        BorderSizePixel=0,
        Size=UDim2.new(1,-32,0,0),
        Position=UDim2.fromOffset(16,72),
        Visible=false,
        ZIndex=30,
        ClipsDescendants=true,
    },panel)
    corner(popup,8)
    stroke(popup,Theme.Accent,1,0.25)
    local list=make("ScrollingFrame",{
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),
        ScrollBarThickness=2,
        ScrollBarImageColor3=Theme.Accent,
        CanvasSize=UDim2.fromOffset(0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ZIndex=31,
    },popup)
    padding(list,6,6,6,6)
    local layout=make("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},list)

    local function isSelected(opt)
        if multi then
            for _,v in ipairs(selected) do if v==opt then return true end end
            return false
        end
        return selected==opt
    end

    local function refreshText()
        if multi then
            if #selected==0 then selectedText.Text="SELECT..." else selectedText.Text=table.concat(selected,", ") end
        else
            selectedText.Text=selected and tostring(selected) or "SELECT..."
        end
    end

    for _,opt in ipairs(options) do
        local b=make("TextButton",{
            BackgroundColor3=Theme.Background,
            BorderSizePixel=0,
            Size=UDim2.new(1,0,0,34),
            Text=tostring(opt),
            TextColor3=Theme.Text,
            TextSize=11,
            Font=Enum.Font.GothamMedium,
            AutoButtonColor=false,
            TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=32,
        },list)
        corner(b,6)
        padding(b,0,10,0,10)
        connect(b.MouseButton1Click,function()
            if multi then
                local found=nil
                for i,v in ipairs(selected) do if v==opt then found=i break end end
                if found then table.remove(selected,found) else table.insert(selected,opt) end
            else
                selected=opt
                open=false
                popup.Visible=false
            end
            refreshText()
            if data.Callback then data.Callback(multi and table.clone(selected) or selected) end
        end)
        connect(b.MouseEnter,function() tween(b,Animation.Fast,{BackgroundColor3=Theme.Panel}) end)
        connect(b.MouseLeave,function() tween(b,Animation.Fast,{BackgroundColor3=Theme.Background}) end)
    end

    connect(selector.MouseButton1Click,function()
        open=not open
        popup.Visible=true
        local target=open and math.min(180, #options*38+20) or 0
        tween(popup,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
            Size=UDim2.new(1,-32,0,target)
        })
        arrow.Text=open and "⌃" or "⌄"
        if not open then
            task.delay(0.21,function() if popup.Parent and not open then popup.Visible=false end end)
        end
    end)

    refreshText()

    return {
        Instance=panel,
        Get=function() return multi and table.clone(selected) or selected end,
        Set=function(_,v)
            if multi then selected=type(v)=="table" and table.clone(v) or {} else selected=v end
            refreshText()
        end
    }
end

function Components.Keybind(parent,data)
    local key=data.Default or Enum.KeyCode.RightShift
    local listening=false

    local panel=make("Frame",{
        BackgroundColor3=Theme.Panel2,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,64)
    },parent)
    corner(panel,10)
    stroke(panel,Theme.Border,1,0.25)

    local title=textLabel(panel,string.upper(data.Name or "KEYBIND"),11,Enum.Font.GothamBold,Theme.Text)
    title.Position=UDim2.fromOffset(16,0)
    title.Size=UDim2.new(1,-140,1,0)

    local keyButton=textButton(panel,key.Name,11)
    keyButton.Size=UDim2.fromOffset(108,36)
    keyButton.Position=UDim2.new(1,-124,0.5,-18)
    keyButton.TextXAlignment=Enum.TextXAlignment.Center
    keyButton.BackgroundColor3=Theme.Background
    corner(keyButton,8)
    stroke(keyButton,Theme.Border,1,0.25)

    connect(keyButton.MouseButton1Click,function()
        listening=true
        keyButton.Text="PRESS KEY"
        keyButton.TextColor3=Theme.Accent2
    end)

    connect(UserInputService.InputBegan,function(input,processed)
        if listening and not processed and input.UserInputType==Enum.UserInputType.Keyboard then
            key=input.KeyCode
            listening=false
            keyButton.Text=key.Name
            keyButton.TextColor3=Theme.Text
            if data.Callback then data.Callback(key) end
        end
    end)

    return {
        Instance=panel,
        Get=function() return key end,
        Set=function(_,v)
            if typeof(v)=="EnumItem" then key=v keyButton.Text=v.Name end
        end
    }
end

function Components.ColorPicker(parent,data)
    local colors=data.Colors or {
        Theme.Accent,Theme.Accent2,Theme.Accent3,
        Color3.fromRGB(255,255,255),Color3.fromRGB(255,90,90),
        Color3.fromRGB(90,255,140),Color3.fromRGB(90,160,255)
    }
    local selected=data.Default or colors[1]
    local open=false

    local panel=make("Frame",{
        BackgroundColor3=Theme.Panel2,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,68)
    },parent)
    corner(panel,10)
    stroke(panel,Theme.Border,1,0.25)

    local title=textLabel(panel,string.upper(data.Name or "COLOR"),11,Enum.Font.GothamBold,Theme.Text)
    title.Position=UDim2.fromOffset(16,0)
    title.Size=UDim2.new(1,-100,1,0)

    local swatch=textButton(panel,"",11)
    swatch.Size=UDim2.fromOffset(52,36)
    swatch.Position=UDim2.new(1,-68,0.5,-18)
    swatch.BackgroundColor3=selected
    corner(swatch,8)
    stroke(swatch,Theme.Border,1,0.2)

    local popup=make("Frame",{
        BackgroundColor3=Theme.Panel3,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(220,0),
        Position=UDim2.new(1,-236,1,6),
        Visible=false,
        ZIndex=40,
        ClipsDescendants=true,
    },panel)
    corner(popup,10)
    stroke(popup,Theme.Accent,1,0.2)

    local list=make("Frame",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,-20,1,-20),
        Position=UDim2.fromOffset(10,10),
        ZIndex=41,
    },popup)
    local grid=make("UIGridLayout",{
        CellSize=UDim2.fromOffset(42,42),
        CellPadding=UDim2.fromOffset(8,8),
    },list)

    for _,c in ipairs(colors) do
        local b=make("TextButton",{
            BackgroundColor3=c,
            BorderSizePixel=0,
            Text="",
            AutoButtonColor=false,
            ZIndex=42,
        },list)
        corner(b,8)
        connect(b.MouseButton1Click,function()
            selected=c
            swatch.BackgroundColor3=c
            open=false
            popup.Visible=false
            tween(popup,Animation.Fast,{Size=UDim2.fromOffset(220,0)})
            if data.Callback then data.Callback(c) end
        end)
    end

    connect(swatch.MouseButton1Click,function()
        open=not open
        popup.Visible=true
        tween(popup,Animation.Fast,{Size=UDim2.fromOffset(220,open and 120 or 0)})
        if not open then
            task.delay(0.17,function() if popup.Parent and not open then popup.Visible=false end end)
        end
    end)

    return {
        Instance=panel,
        Get=function() return selected end,
        Set=function(_,v) if typeof(v)=="Color3" then selected=v swatch.BackgroundColor3=v end end
    }
end

function Components.Section(parent,name,description)
    local frame=make("Frame",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,52),
    },parent)
    local bar=make("Frame",{
        BackgroundColor3=Theme.Accent,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(3,30),
        Position=UDim2.fromOffset(0,11),
    },frame)
    corner(bar,3)
    local title=textLabel(frame,string.upper(name or "SECTION"),12,Enum.Font.GothamBold,Theme.Text)
    title.Position=UDim2.fromOffset(13,5)
    title.Size=UDim2.new(1,-13,0,20)
    local desc=textLabel(frame,description or "",9,Enum.Font.Gotham,Theme.Muted)
    desc.Position=UDim2.fromOffset(13,25)
    desc.Size=UDim2.new(1,-13,0,18)
    return frame
end

function Components.Label(parent,text)
    local l=textLabel(parent,text,11,Enum.Font.GothamMedium,Theme.Text)
    l.Size=UDim2.new(1,0,0,32)
    return l
end

function Components.Paragraph(parent,text)
    local p=textLabel(parent,text,11,Enum.Font.Gotham,Theme.Muted)
    p.Size=UDim2.new(1,0,0,54)
    p.TextWrapped=true
    p.TextYAlignment=Enum.TextYAlignment.Top
    return p
end

function Components.Progress(parent,value)
    local bar=make("Frame",{
        BackgroundColor3=Theme.Dim,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,6),
    },parent)
    corner(bar,99)
    local fill=make("Frame",{
        BackgroundColor3=Theme.Accent,
        BorderSizePixel=0,
        Size=UDim2.new(clamp(value or 0,0,1),0,1,0),
    },bar)
    corner(fill,99)
    gradient(fill,Theme.Accent,Theme.Accent2,0)
    return {
        Instance=bar,
        Set=function(_,v) tween(fill,Animation.Smooth,{Size=UDim2.new(clamp(v,0,1),0,1,0)}) end
    }
end

--==============================================================
-- WINDOW
--==============================================================

local WindowMethods = {}

local function createBackgroundEffects(screen)
    local bg = make("Frame", {
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1,1),
    }, screen)

    local bgGrad = gradient(bg, Theme.Background, Theme.Background2, 35)

    local grid = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1,1),
        ClipsDescendants = true,
    }, bg)

    for x=0,24 do
        local line=make("Frame",{
            BackgroundColor3=Theme.Accent2,
            BackgroundTransparency=0.965,
            BorderSizePixel=0,
            Size=UDim2.new(0,1,1,0),
            Position=UDim2.new(x/24,0,0,0),
        },grid)
    end
    for y=0,14 do
        local line=make("Frame",{
            BackgroundColor3=Theme.Accent,
            BackgroundTransparency=0.972,
            BorderSizePixel=0,
            Size=UDim2.new(1,0,0,1),
            Position=UDim2.new(0,0,y/14,0),
        },grid)
    end

    local vignette=make("ImageLabel",{
        BackgroundTransparency=1,
        Image="rbxassetid://5028857084",
        ImageColor3=Color3.new(0,0,0),
        ImageTransparency=0.72,
        Size=UDim2.fromScale(1.25,1.25),
        Position=UDim2.fromScale(-0.125,-0.125),
        ZIndex=2,
    },bg)

    Effects.Scanline(bg)

    if UI.Particles then
        for i=1,34 do
            local p=make("Frame",{
                BackgroundColor3=(i%2==0) and Theme.Accent or Theme.Accent2,
                BackgroundTransparency=0.7+math.random()*0.25,
                BorderSizePixel=0,
                Size=UDim2.fromOffset(math.random(1,3),math.random(1,3)),
                Position=UDim2.fromScale(math.random(),math.random()),
                ZIndex=2,
            },bg)
            corner(p,99)
        end
    end

    return bg
end

local function makeHeader(parent)
    local header=make("Frame",{
        BackgroundColor3=Theme.Panel,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,74),
        ZIndex=10,
    },parent)
    local hg=gradient(header,Theme.Panel2,Theme.Panel,0)
    stroke(header,Theme.Border,1,0.18)

    local topLine=make("Frame",{
        BackgroundColor3=Theme.Accent,
        BorderSizePixel=0,
        Size=UDim2.new(0.38,0,0,1),
        Position=UDim2.fromOffset(18,0),
    },header)
    gradient(topLine,Theme.Accent,Theme.Accent2,0)

    local logo=textLabel(header,"◈",25,Enum.Font.GothamBlack,Theme.Accent2)
    logo.Position=UDim2.fromOffset(20,9)
    logo.Size=UDim2.fromOffset(38,35)
    logo.TextXAlignment=Enum.TextXAlignment.Center

    local name=textLabel(header,CONFIG.Name,17,Enum.Font.GothamBlack,Theme.Text)
    name.Position=UDim2.fromOffset(62,8)
    name.Size=UDim2.fromOffset(120,25)

    local subtitle=textLabel(header,"ADVANCED CONTROL SYSTEM  /  "..CONFIG.Version,8,Enum.Font.GothamMedium,Theme.Muted)
    subtitle.Position=UDim2.fromOffset(63,34)
    subtitle.Size=UDim2.fromOffset(270,18)

    local onlineDot=make("Frame",{
        BackgroundColor3=Theme.Success,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(8,8),
        Position=UDim2.new(0.5,-70,0,31),
    },header)
    corner(onlineDot,99)
    Effects.Glow(onlineDot,Theme.Success,10,0.55)

    local online=textLabel(header,"SYSTEM ONLINE",10,Enum.Font.GothamBold,Theme.Success)
    online.Position=UDim2.new(0.5,-55,0,22)
    online.Size=UDim2.fromOffset(125,26)

    local version=textLabel(header,"V"..CONFIG.Version,9,Enum.Font.GothamBold,Theme.Muted)
    version.Position=UDim2.new(1,-225,0,12)
    version.Size=UDim2.fromOffset(48,20)
    version.TextXAlignment=Enum.TextXAlignment.Right

    local minimize=textButton(header,"—",18)
    minimize.Size=UDim2.fromOffset(38,34)
    minimize.Position=UDim2.new(1,-124,0,20)
    minimize.TextXAlignment=Enum.TextXAlignment.Center

    local close=textButton(header,"×",22)
    close.Size=UDim2.fromOffset(38,34)
    close.Position=UDim2.new(1,-82,0,20)
    close.TextXAlignment=Enum.TextXAlignment.Center
    close.TextColor3=Theme.Error

    local search=textButton(header,"⌕",19)
    search.Size=UDim2.fromOffset(38,34)
    search.Position=UDim2.new(1,-166,0,20)
    search.TextXAlignment=Enum.TextXAlignment.Center
    search.TextColor3=Theme.Accent2

    connect(minimize.MouseButton1Click,function()
        UI:Hide()
    end)
    connect(close.MouseButton1Click,function()
        UI:Destroy()
    end)

    UI.Header=header
    UI.Minimize=minimize
    UI.Close=close
    UI.SearchButton=search
    return header
end

local function makeSidebar(parent)
    local sidebar=make("Frame",{
        BackgroundColor3=Theme.Panel,
        BorderSizePixel=0,
        Size=UDim2.new(0,220,1,-112),
        Position=UDim2.fromOffset(0,74),
        ZIndex=8,
    },parent)
    stroke(sidebar,Theme.Border,1,0.2)

    local rail=make("Frame",{
        BackgroundColor3=Theme.Accent,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(2,1),
        Position=UDim2.fromOffset(0,0),
    },sidebar)
    gradient(rail,Theme.Accent,Theme.Accent2,90)

    local label=textLabel(sidebar,"COMMAND DECK",9,Enum.Font.GothamBold,Theme.Muted)
    label.Position=UDim2.fromOffset(18,17)
    label.Size=UDim2.new(1,-36,0,18)

    local list=make("ScrollingFrame",{
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Size=UDim2.new(1,-18,1,-100),
        Position=UDim2.fromOffset(9,43),
        ScrollBarThickness=0,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.fromOffset(0,0),
    },sidebar)
    local layout=make("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},list)

    local bottom=textLabel(sidebar,"●  SECURE CHANNEL",9,Enum.Font.GothamBold,Theme.Success)
    bottom.Position=UDim2.fromOffset(18,-38)
    bottom.AnchorPoint=Vector2.new(0,1)
    bottom.Size=UDim2.new(1,-36,0,22)

    UI.SidebarList=list
    UI.Sidebar=sidebar
    return sidebar
end

local function makeFooter(parent)
    local footer=make("Frame",{
        BackgroundColor3=Theme.Panel,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,38),
        Position=UDim2.new(0,0,1,-38),
        ZIndex=9,
    },parent)
    stroke(footer,Theme.Border,1,0.22)

    local online=textLabel(footer,"●  ONLINE",10,Enum.Font.GothamBold,Theme.Success)
    online.Position=UDim2.fromOffset(18,0)
    online.Size=UDim2.fromOffset(90,38)

    local ready=textLabel(footer,"READY",9,Enum.Font.GothamBold,Theme.Muted)
    ready.Position=UDim2.fromOffset(112,0)
    ready.Size=UDim2.fromOffset(70,38)

    local runtime=textLabel(footer,"RUNTIME 00:00:00",9,Enum.Font.GothamBold,Theme.Accent2)
    runtime.Position=UDim2.new(1,-260,0,0)
    runtime.Size=UDim2.fromOffset(145,38)
    runtime.TextXAlignment=Enum.TextXAlignment.Right

    local brand=textLabel(footer,"NOVA  /  "..CONFIG.Version,8,Enum.Font.GothamBold,Theme.Dim)
    brand.Position=UDim2.new(1,-108,0,0)
    brand.Size=UDim2.fromOffset(90,38)
    brand.TextXAlignment=Enum.TextXAlignment.Right

    UI.Footer=footer
    UI.RuntimeLabel=runtime
    UI.FooterReady=ready
    return footer
end

function WindowMethods:CreateTab(data)
    local name=data.Name or ("TAB "..tostring(#UI.Tabs+1))
    local tab={
        Name=name,
        Icon=data.Icon or "◇",
        Items={},
    }

    local buttonPanel=make("Frame",{
        BackgroundColor3=Theme.Panel,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,48),
    },UI.SidebarList)
    corner(buttonPanel,8)
    local button=textButton(buttonPanel,"",11)
    button.Size=UDim2.fromScale(1,1)
    button.ZIndex=3

    local icon=textLabel(buttonPanel,tab.Icon,16,Enum.Font.GothamBold,Theme.Muted)
    icon.Position=UDim2.fromOffset(13,0)
    icon.Size=UDim2.fromOffset(30,48)
    icon.TextXAlignment=Enum.TextXAlignment.Center

    local title=textLabel(buttonPanel,string.upper(name),10,Enum.Font.GothamBold,Theme.Muted)
    title.Position=UDim2.fromOffset(48,0)
    title.Size=UDim2.new(1,-58,48,0)

    local indicator=make("Frame",{
        BackgroundColor3=Theme.Accent2,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(2,0),
        Position=UDim2.fromOffset(0,24),
    },buttonPanel)
    corner(indicator,3)

    local page=make("ScrollingFrame",{
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),
        ScrollBarThickness=2,
        ScrollBarImageColor3=Theme.Accent,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.fromOffset(0,0),
        Visible=false,
    },UI.Content)
    local contentPadding=padding(page,20,20,30,20)
    local list=make("UIListLayout",{
        Padding=UDim.new(0,10),
        SortOrder=Enum.SortOrder.LayoutOrder,
    },page)

    tab.Button=buttonPanel
    tab.Page=page
    tab.Title=title
    tab.IconObject=icon
    tab.Indicator=indicator
    tab.Layout=list

    local function activate()
        for _,t in ipairs(UI.Tabs) do
            t.Page.Visible=false
            t.Button.BackgroundColor3=Theme.Panel
            t.Title.TextColor3=Theme.Muted
            t.IconObject.TextColor3=Theme.Muted
            tween(t.Indicator,Animation.Fast,{Size=UDim2.fromOffset(2,0)})
        end
        page.Visible=true
        buttonPanel.BackgroundColor3=Theme.Panel3
        title.TextColor3=Theme.Text
        icon.TextColor3=Theme.Accent2
        tween(indicator,Animation.Smooth,{Size=UDim2.fromOffset(2,30)})
        UI.CurrentTab=tab
        if UI.Mobile then UI:CloseDrawer() end
    end

    connect(button.MouseButton1Click,activate)
    connect(button.MouseEnter,function()
        if UI.CurrentTab~=tab then
            tween(buttonPanel,Animation.Fast,{BackgroundColor3=Theme.Panel2})
        end
    end)
    connect(button.MouseLeave,function()
        if UI.CurrentTab~=tab then
            tween(buttonPanel,Animation.Fast,{BackgroundColor3=Theme.Panel})
        end
    end)

    table.insert(UI.Tabs,tab)

    function tab:CreateButton(d) local c=Components.Button(page,d) table.insert(self.Items,c) return c end
    function tab:CreateToggle(d) local c=Components.Toggle(page,d) table.insert(self.Items,c) return c end
    function tab:CreateSlider(d) local c=Components.Slider(page,d) table.insert(self.Items,c) return c end
    function tab:CreateNumberInput(d) local c=Components.NumberInput(page,d) table.insert(self.Items,c) return c end
    function tab:CreateTextInput(d) local c=Components.TextInput(page,d) table.insert(self.Items,c) return c end
    function tab:CreateDropdown(d) local c=Components.Dropdown(page,d,false) table.insert(self.Items,c) return c end
    function tab:CreateMultiDropdown(d) local c=Components.Dropdown(page,d,true) table.insert(self.Items,c) return c end
    function tab:CreateKeybind(d) local c=Components.Keybind(page,d) table.insert(self.Items,c) return c end
    function tab:CreateColorPicker(d) local c=Components.ColorPicker(page,d) table.insert(self.Items,c) return c end
    function tab:CreateSection(n,d) return Components.Section(page,n,d) end
    function tab:CreateLabel(t) return Components.Label(page,t) end
    function tab:CreateParagraph(t) return Components.Paragraph(page,t) end
    function tab:CreateProgress(v) return Components.Progress(page,v) end

    if #UI.Tabs==1 then
        activate()
    end

    return tab
end

function UI:CreateWindow()
    if self.Window then return self.Window end

    local gui=track(make("ScreenGui",{
        Name="NOVA_CommandCenter",
        ResetOnSpawn=false,
        IgnoreGuiInset=true,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=100,
    },PlayerGui))
    self.Root=gui

    local background=createBackgroundEffects(gui)

    local shadow=make("Frame",{
        BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=0.25,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(CONFIG.DesktopWidth+26,CONFIG.DesktopHeight+26),
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5),
        ZIndex=4,
    },background)
    corner(shadow,18)

    local window=make("Frame",{
        BackgroundColor3=Theme.Panel,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(CONFIG.DesktopWidth,CONFIG.DesktopHeight),
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5),
        ClipsDescendants=true,
        ZIndex=5,
    },background)
    corner(window,16)
    stroke(window,Theme.Border,1.3,0.12)
    gradient(window,Theme.Panel2,Theme.Panel,35)
    Effects.Glow(window,Theme.Accent,32,0.8)

    local topDecor=make("Frame",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,74),
        ZIndex=20,
    },window)

    makeHeader(window)
    makeSidebar(window)

    local content=make("Frame",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,-220,1,-112),
        Position=UDim2.fromOffset(220,74),
        ZIndex=6,
    },window)
    self.Content=content
    self.ContentPadding=padding(content,0,0,0,0)

    makeFooter(window)

    self.Window=window
    self.Shadow=shadow
    self.Background=background

    self.MobileMenuButton=textButton(window,"☰",18)
    self.MobileMenuButton.Size=UDim2.fromOffset(46,46)
    self.MobileMenuButton.Position=UDim2.fromOffset(10,14)
    self.MobileMenuButton.TextXAlignment=Enum.TextXAlignment.Center
    self.MobileMenuButton.TextColor3=Theme.Accent2
    self.MobileMenuButton.BackgroundColor3=Theme.Panel2
    corner(self.MobileMenuButton,10)
    stroke(self.MobileMenuButton,Theme.Border,1,0.2)
    self.MobileMenuButton.Visible=false
    connect(self.MobileMenuButton.MouseButton1Click,function()
        self:ToggleDrawer()
    end)

    MakeDraggable(window, self.Header)

    updateResponsive()

    local runtimeStart=os.clock()
    connect(RunService.RenderStepped,function()
        if self.Destroyed then return end
        if self.RuntimeLabel then
            self.RuntimeLabel.Text="RUNTIME "..formatRuntime(os.clock()-runtimeStart)
        end
    end)

    connect(UserInputService.WindowFocused,function()
        if self.Visible then
            self:SetStatus("READY","All systems operational.")
        end
    end)

    connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),updateResponsive)

    self:CreateMobileControl()

    return {
        CreateTab=function(_,d) return WindowMethods.CreateTab(self,d) end,
        Instance=window,
    }
end

--==============================================================
-- MOBILE CONTROL
--==============================================================

function UI:CreateMobileControl(data)
    if self.MobileControl then return self.MobileControl end
    data=data or {}

    local control=make("Frame",{
        BackgroundColor3=Theme.Panel,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(232,52),
        Position=UDim2.new(1,-250,1,-76),
        ZIndex=200,
        Visible=false,
    },self.Root)
    corner(control,14)
    stroke(control,Theme.Border,1.2,0.1)
    gradient(control,Theme.Panel3,Theme.Panel,0)
    Effects.Glow(control,Theme.Accent,18,0.75)

    local accent=make("Frame",{
        BackgroundColor3=Theme.Accent,
        BorderSizePixel=0,
        Size=UDim2.new(0,3,0.56,0),
        Position=UDim2.new(0,0,0.22,0),
    },control)
    corner(accent,3)

    local logo=textLabel(control,"◈",19,Enum.Font.GothamBlack,Theme.Accent2)
    logo.Position=UDim2.fromOffset(13,0)
    logo.Size=UDim2.fromOffset(30,52)
    logo.TextXAlignment=Enum.TextXAlignment.Center

    local name=textLabel(control,CONFIG.Name,11,Enum.Font.GothamBlack,Theme.Text)
    name.Position=UDim2.fromOffset(47,7)
    name.Size=UDim2.fromOffset(62,20)

    local statusDot=make("Frame",{
        BackgroundColor3=Theme.Success,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(6,6),
        Position=UDim2.fromOffset(48,31),
    },control)
    corner(statusDot,99)

    local status=textLabel(control,"ONLINE",8,Enum.Font.GothamBold,Theme.Success)
    status.Position=UDim2.fromOffset(59,25)
    status.Size=UDim2.fromOffset(52,17)

    local action=textButton(control,"HIDE  ›",10)
    action.Size=UDim2.fromOffset(96,40)
    action.Position=UDim2.new(1,-106,0.5,-20)
    action.TextXAlignment=Enum.TextXAlignment.Center
    action.TextColor3=Theme.Accent2
    action.BackgroundColor3=Theme.Background
    corner(action,9)
    stroke(action,Theme.Border,1,0.25)

    local hit=textButton(control,"",10)
    hit.Size=UDim2.fromScale(1,1)
    hit.ZIndex=5

    connect(action.MouseButton1Click,function()
        self:Toggle()
    end)

    -- A small dedicated handle area keeps the capsule draggable while
    -- preserving a large touch-friendly open/close target.
    MakeDraggable(control, logo)

    self.MobileControl=control
    self.MobileAction=action
    self.MobileStatus=status
    self.MobileStatusDot=statusDot

    updateResponsive()
    return control
end

function UI:Toggle()
    if self.Visible then self:Hide() else self:Show() end
end

function UI:Show()
    if self.Destroyed then return end
    self.Visible=true
    if self.Window then
        self.Window.Visible=true
        local scale=self.Window:FindFirstChildOfClass("UIScale") or make("UIScale",{Scale=0.94},self.Window)
        scale.Scale=0.94
        tween(scale,Animation.Spring,{Scale=1})
    end
    if self.Shadow then
        self.Shadow.Visible=true
    end
    if self.MobileAction then self.MobileAction.Text="HIDE  ›" end
end

function UI:Hide()
    if self.Destroyed then return end
    self.Visible=false
    if self.Window then
        local scale=self.Window:FindFirstChildOfClass("UIScale") or make("UIScale",{Scale=1},self.Window)
        tween(scale,TweenInfo.new(0.18,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Scale=0.94})
        task.delay(0.18,function()
            if not self.Visible and self.Window and self.Window.Parent then
                self.Window.Visible=false
            end
        end)
    end
    if self.MobileAction then self.MobileAction.Text="OPEN  ›" end
end

function UI:ToggleDrawer()
    if not self.MobileDrawer then return end
    if self.MobileDrawer.Visible then
        self:CloseDrawer()
    else
        self:OpenDrawer()
    end
end

function UI:OpenDrawer()
    if not self.MobileDrawer then return end
    self.MobileOverlay.Visible=true
    self.MobileDrawer.Visible=true
    local target=self.MobileDrawer.Position
    self.MobileDrawer.Position=UDim2.new(0,-300,0,0)
    tween(self.MobileDrawer,Animation.Smooth,{Position=target})
end

function UI:CloseDrawer()
    if not self.MobileDrawer then return end
    tween(self.MobileDrawer,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{
        Position=UDim2.new(0,-300,0,0)
    })
    task.delay(0.22,function()
        if self.MobileDrawer and self.MobileDrawer.Parent then
            self.MobileDrawer.Visible=false
            self.MobileOverlay.Visible=false
        end
    end)
end

local function buildMobileDrawer()
    local overlay=make("TextButton",{
        BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=0.4,
        BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),
        Text="",
        AutoButtonColor=false,
        Visible=false,
        ZIndex=120,
    },UI.Root)
    local drawer=make("Frame",{
        BackgroundColor3=Theme.Panel,
        BorderSizePixel=0,
        Size=UDim2.new(0,280,1,0),
        Position=UDim2.new(0,-300,0,0),
        Visible=false,
        ZIndex=121,
    },UI.Root)
    stroke(drawer,Theme.Border,1,0.12)
    gradient(drawer,Theme.Panel3,Theme.Panel,0)

    local head=textLabel(drawer,"◈  NOVA",18,Enum.Font.GothamBlack,Theme.Text)
    head.Position=UDim2.fromOffset(22,25)
    head.Size=UDim2.new(1,-44,0,30)

    local sub=textLabel(drawer,"MOBILE COMMAND DECK",8,Enum.Font.GothamBold,Theme.Muted)
    sub.Position=UDim2.fromOffset(23,52)
    sub.Size=UDim2.new(1,-46,0,20)

    local list=make("ScrollingFrame",{
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Size=UDim2.new(1,-24,1,-145),
        Position=UDim2.fromOffset(12,85),
        ScrollBarThickness=0,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.fromOffset(0,0),
        ZIndex=122,
    },drawer)
    make("UIListLayout",{Padding=UDim.new(0,8)},list)

    for _,tab in ipairs(UI.Tabs) do
        local b=make("TextButton",{
            BackgroundColor3=Theme.Panel2,
            BorderSizePixel=0,
            Size=UDim2.new(1,0,0,52),
            Text="",
            AutoButtonColor=false,
            ZIndex=123,
        },list)
        corner(b,9)
        local ic=textLabel(b,tab.Icon,17,Enum.Font.GothamBold,Theme.Accent2)
        ic.Position=UDim2.fromOffset(13,0)
        ic.Size=UDim2.fromOffset(32,52)
        ic.TextXAlignment=Enum.TextXAlignment.Center
        local tx=textLabel(b,string.upper(tab.Name),10,Enum.Font.GothamBold,Theme.Text)
        tx.Position=UDim2.fromOffset(54,0)
        tx.Size=UDim2.new(1,-64,52,0)
        connect(b.MouseButton1Click,function()
            tab.Button:FindFirstChildOfClass("TextButton"):Activate()
            UI:CloseDrawer()
        end)
    end

    local online=textLabel(drawer,"●  SYSTEM ONLINE",9,Enum.Font.GothamBold,Theme.Success)
    online.Position=UDim2.fromOffset(23,-48)
    online.AnchorPoint=Vector2.new(0,1)
    online.Size=UDim2.new(1,-46,0,24)

    connect(overlay.MouseButton1Click,function() UI:CloseDrawer() end)

    UI.MobileDrawer=drawer
    UI.MobileOverlay=overlay
end

--==============================================================
-- NOTIFICATIONS
--==============================================================

function UI:Notify(data)
    data=data or {}
    local title=data.Title or "SYSTEM"
    local description=data.Description or ""
    local kind=data.Type or "Info"
    local duration=tonumber(data.Duration) or 4

    local colors={
        Success=Theme.Success,
        Info=Theme.Accent2,
        Warning=Theme.Warning,
        Error=Theme.Error,
        Loading=Theme.Accent,
    }
    local icons={
        Success="✓",
        Info="◆",
        Warning="!",
        Error="×",
        Loading="◌",
    }
    local c=colors[kind] or Theme.Accent2

    if not self.NotificationHolder then
        self.NotificationHolder=make("Frame",{
            BackgroundTransparency=1,
            Size=UDim2.new(0,360,1,-24),
            Position=UDim2.new(1,-380,0,12),
            ZIndex=300,
        },self.Root)
        local lay=make("UIListLayout",{
            FillDirection=Enum.FillDirection.Vertical,
            HorizontalAlignment=Enum.HorizontalAlignment.Right,
            VerticalAlignment=Enum.VerticalAlignment.Top,
            Padding=UDim.new(0,9),
        },self.NotificationHolder)
    end

    while #self.Notifications >= CONFIG.MaxNotifications do
        local old=table.remove(self.Notifications,1)
        if old and old.Parent then old:Destroy() end
    end

    local frame=make("Frame",{
        BackgroundColor3=Theme.Panel,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(350,90),
        Position=UDim2.fromOffset(380,0),
        ZIndex=301,
    },self.NotificationHolder)
    corner(frame,12)
    stroke(frame,c,1,0.18)
    gradient(frame,Theme.Panel3,Theme.Panel,0)
    Effects.Glow(frame,c,14,0.8)

    local bar=make("Frame",{
        BackgroundColor3=c,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(3,54),
        Position=UDim2.fromOffset(0,18),
        ZIndex=302,
    },frame)
    corner(bar,3)

    local icon=textLabel(frame,icons[kind] or "◆",18,Enum.Font.GothamBlack,c)
    icon.Position=UDim2.fromOffset(16,10)
    icon.Size=UDim2.fromOffset(28,26)
    icon.TextXAlignment=Enum.TextXAlignment.Center

    local ttl=textLabel(frame,string.upper(title),11,Enum.Font.GothamBold,Theme.Text)
    ttl.Position=UDim2.fromOffset(50,9)
    ttl.Size=UDim2.new(1,-65,0,22)

    local desc=textLabel(frame,description,10,Enum.Font.Gotham,Theme.Muted)
    desc.Position=UDim2.fromOffset(50,31)
    desc.Size=UDim2.new(1,-65,0,30)
    desc.TextWrapped=true

    local progress=make("Frame",{
        BackgroundColor3=c,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,2),
        Position=UDim2.new(0,0,1,-2),
    },frame)

    table.insert(self.Notifications,frame)

    tween(frame,Animation.Spring,{Position=UDim2.fromOffset(0,0)})
    tween(progress,TweenInfo.new(duration,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,0,2)})

    task.delay(duration,function()
        if frame.Parent then
            tween(frame,TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{
                Position=UDim2.fromOffset(380,0),
                BackgroundTransparency=1
            })
            task.delay(0.22,function()
                if frame.Parent then frame:Destroy() end
            end)
        end
        for i,v in ipairs(self.Notifications) do
            if v==frame then table.remove(self.Notifications,i) break end
        end
    end)

    return frame
end

--==============================================================
-- STATUS
--==============================================================

function UI:SetStatus(state, detail)
    state=string.upper(tostring(state or "READY"))
    detail=detail or ""

    local colors={
        READY=Theme.Success,
        LOADING=Theme.Accent2,
        INITIALIZING=Theme.Accent,
        EXECUTING=Theme.Accent,
        PROCESSING=Theme.Accent2,
        COMPLETED=Theme.Success,
        WARNING=Theme.Warning,
        ERROR=Theme.Error,
        IDLE=Theme.Muted,
    }
    local icons={
        READY="●",
        LOADING="◌",
        INITIALIZING="◇",
        EXECUTING="◉",
        PROCESSING="◌",
        COMPLETED="✓",
        WARNING="!",
        ERROR="×",
        IDLE="○",
    }

    self.Status=state
    self.StatusDetail=detail
    local c=colors[state] or Theme.Accent2

    if self.StatusDot then
        self.StatusDot.BackgroundColor3=c
    end
    if self.MobileStatus then
        self.MobileStatus.Text=(state=="READY" and "ONLINE" or state)
        self.MobileStatus.TextColor3=c
    end
    if self.MobileStatusDot then
        self.MobileStatusDot.BackgroundColor3=c
    end
    if self.FooterReady then
        self.FooterReady.Text=state
        self.FooterReady.TextColor3=c
    end

    if self.StatusIcon then
        self.StatusIcon.Text=icons[state] or "◆"
        self.StatusIcon.TextColor3=c
    end
    if self.StatusTitle then
        self.StatusTitle.Text=state
        self.StatusTitle.TextColor3=c
    end
    if self.StatusDetailLabel then
        self.StatusDetailLabel.Text=detail
    end

    Effects.Pulse(self.StatusPanel,c)
end

--==============================================================
-- CONSOLE
--==============================================================

local Console={}

function UI:Log(level,message)
    level=string.upper(level or "INFO")
    message=tostring(message or "")
    local entry={
        Time=formatTime(),
        Level=level,
        Message=message,
    }
    table.insert(self.Logs,entry)
    if #self.Logs>250 then table.remove(self.Logs,1) end

    if Console.Refresh then
        Console.Refresh()
    end
end

function Console.Build(parent)
    local root=make("Frame",{
        BackgroundTransparency=1,
        Size=UDim2.fromScale(1,1),
    },parent)

    local top=make("Frame",{
        BackgroundColor3=Theme.Panel2,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,58),
    },root)
    corner(top,10)
    stroke(top,Theme.Border,1,0.22)

    local title=textLabel(top,"SYSTEM CONSOLE",13,Enum.Font.GothamBlack,Theme.Text)
    title.Position=UDim2.fromOffset(16,0)
    title.Size=UDim2.fromOffset(180,58)

    local search=make("TextBox",{
        BackgroundColor3=Theme.Background,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(210,36),
        Position=UDim2.new(1,-310,0.5,-18),
        Text="",
        PlaceholderText="SEARCH LOGS...",
        PlaceholderColor3=Theme.Dim,
        TextColor3=Theme.Text,
        TextSize=10,
        Font=Enum.Font.Gotham,
        ClearTextOnFocus=false,
    },top)
    corner(search,8)
    stroke(search,Theme.Border,1,0.25)
    padding(search,0,10,0,10)

    local clear=textButton(top,"CLEAR",9)
    clear.Size=UDim2.fromOffset(74,36)
    clear.Position=UDim2.new(1,-88,0.5,-18)
    clear.TextXAlignment=Enum.TextXAlignment.Center
    clear.BackgroundColor3=Theme.Panel3
    corner(clear,8)

    local output=make("ScrollingFrame",{
        BackgroundColor3=Theme.Background,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,1,-70),
        Position=UDim2.fromOffset(0,70),
        ScrollBarThickness=3,
        ScrollBarImageColor3=Theme.Accent,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.fromOffset(0,0),
    },root)
    corner(output,10)
    stroke(output,Theme.Border,1,0.25)
    padding(output,12,12,12,12)

    local list=make("UIListLayout",{
        Padding=UDim.new(0,5),
        SortOrder=Enum.SortOrder.LayoutOrder,
    },output)

    local levelColors={
        INFO=Theme.Accent2,
        SUCCESS=Theme.Success,
        EXEC=Theme.Accent,
        WARN=Theme.Warning,
        WARNING=Theme.Warning,
        ERROR=Theme.Error,
    }

    function Console.Refresh()
        for _,child in ipairs(output:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local q=string.lower(search.Text or "")
        for _,e in ipairs(UI.Logs) do
            local combined=string.lower(e.Time.." "..e.Level.." "..e.Message)
            if q=="" or string.find(combined,q,1,true) then
                local row=make("Frame",{
                    BackgroundTransparency=1,
                    Size=UDim2.new(1,0,0,25),
                },output)
                local line=textLabel(row,
                    e.Time.."   "..string.format("%-8s",e.Level).."  "..e.Message,
                    10,Enum.Font.Code,levelColors[e.Level] or Theme.Text)
                line.Size=UDim2.fromScale(1,1)
                line.TextTruncate=Enum.TextTruncate.AtEnd
            end
        end
        task.defer(function()
            if output.Parent then
                output.CanvasPosition=Vector2.new(0,math.max(0,output.AbsoluteCanvasSize.Y-output.AbsoluteSize.Y))
            end
        end)
    end

    connect(search:GetPropertyChangedSignal("Text"),Console.Refresh)
    connect(clear.MouseButton1Click,function()
        UI.Logs={}
        Console.Refresh()
        UI:SetStatus("READY","Console cleared.")
    end)

    Console.Refresh()
    UI.ConsoleRoot=root
    return root
end

--==============================================================
-- LOADING SCREEN
--==============================================================

local function BootScreen()
    local boot=make("Frame",{
        BackgroundColor3=Theme.Background,
        BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),
        ZIndex=900,
    },UI.Root)
    gradient(boot,Theme.Background,Theme.Background2,25)

    for i=1,18 do
        local p=make("Frame",{
            BackgroundColor3=(i%2==0) and Theme.Accent or Theme.Accent2,
            BackgroundTransparency=0.45+math.random()*0.4,
            BorderSizePixel=0,
            Size=UDim2.fromOffset(math.random(2,5),math.random(2,5)),
            Position=UDim2.fromScale(math.random(),math.random()),
            ZIndex=901,
        },boot)
        corner(p,99)
    end

    local bracket=make("Frame",{
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(520,250),
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.48),
        ZIndex=902,
    },boot)
    stroke(bracket,Theme.Border,1,0.55)

    local logo=textLabel(bracket,"◈",46,Enum.Font.GothamBlack,Theme.Accent2)
    logo.Size=UDim2.new(1,0,0,65)
    logo.Position=UDim2.fromOffset(0,14)
    logo.TextXAlignment=Enum.TextXAlignment.Center

    local name=textLabel(bracket,CONFIG.Name,30,Enum.Font.GothamBlack,Theme.Text)
    name.Size=UDim2.new(1,0,0,42)
    name.Position=UDim2.fromOffset(0,72)
    name.TextXAlignment=Enum.TextXAlignment.Center

    local sub=textLabel(bracket,"ADVANCED CONTROL SYSTEM",10,Enum.Font.GothamBold,Theme.Muted)
    sub.Size=UDim2.new(1,0,0,24)
    sub.Position=UDim2.fromOffset(0,112)
    sub.TextXAlignment=Enum.TextXAlignment.Center

    local progressBack=make("Frame",{
        BackgroundColor3=Theme.Dim,
        BorderSizePixel=0,
        Size=UDim2.new(1,-80,0,5),
        Position=UDim2.fromOffset(40,164),
        ZIndex=903,
    },bracket)
    corner(progressBack,99)

    local progress=make("Frame",{
        BackgroundColor3=Theme.Accent,
        BorderSizePixel=0,
        Size=UDim2.new(0,0,1,0),
        ZIndex=904,
    },progressBack)
    corner(progress,99)
    gradient(progress,Theme.Accent,Theme.Accent2,0)

    local percent=textLabel(bracket,"INITIALIZING CORE   0%",9,Enum.Font.Code,Theme.Accent2)
    percent.Size=UDim2.new(1,-80,0,24)
    percent.Position=UDim2.fromOffset(40,178)

    local systems={
        "GRAPHICS ENGINE       READY",
        "UI ENGINE             READY",
        "INPUT SYSTEM          READY",
        "COMPONENT SYSTEM      READY",
    }
    for i,line in ipairs(systems) do
        local l=textLabel(bracket,line,8,Enum.Font.Code,Theme.Muted)
        l.Size=UDim2.new(0.55,0,0,17)
        l.Position=UDim2.new(0.225,0,0,201+(i-1)*17)
    end

    local ready=textLabel(bracket,"● SYSTEM READY",10,Enum.Font.GothamBold,Theme.Success)
    ready.Size=UDim2.new(1,0,0,22)
    ready.Position=UDim2.fromOffset(0,270)
    ready.TextXAlignment=Enum.TextXAlignment.Center
    ready.Visible=false

    Effects.Scanline(boot)

    local steps={"CORE","GRAPHICS","INPUT","COMPONENTS","INTERFACE","ONLINE"}
    for i=1,#steps do
        if UI.Destroyed then return end
        local value=i/#steps
        percent.Text="INITIALIZING "..steps[i].."   "..tostring(math.floor(value*100)).."%"
        tween(progress,TweenInfo.new(0.28,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
            Size=UDim2.new(value,0,1,0)
        })
        task.wait(0.25)
    end

    ready.Visible=true
    Effects.ParticleBurst(boot,Vector2.new(boot.AbsoluteSize.X/2,boot.AbsoluteSize.Y/2),18)
    task.wait(0.65)

    tween(boot,TweenInfo.new(0.45,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{
        BackgroundTransparency=1
    })
    task.delay(0.48,function()
        if boot.Parent then boot:Destroy() end
    end)
end

--==============================================================
-- DEMO
--==============================================================

local function buildDashboard(tab)
    local hero=make("Frame",{
        BackgroundColor3=Theme.Panel2,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,220),
    },tab.Page)
    corner(hero,14)
    stroke(hero,Theme.Border,1,0.18)
    gradient(hero,Theme.Panel3,Theme.Panel2,15)
    Effects.Glow(hero,Theme.Accent,22,0.82)

    local accent=make("Frame",{
        BackgroundColor3=Theme.Accent,
        BorderSizePixel=0,
        Size=UDim2.new(0.45,0,0,2),
        Position=UDim2.fromOffset(18,0),
    },hero)
    gradient(accent,Theme.Accent,Theme.Accent2,0)

    local label=textLabel(hero,"NOVA / COMMAND CENTER",9,Enum.Font.GothamBold,Theme.Accent2)
    label.Position=UDim2.fromOffset(22,18)
    label.Size=UDim2.new(1,-44,0,20)

    local title=textLabel(hero,"SYSTEM ONLINE",26,Enum.Font.GothamBlack,Theme.Text)
    title.Position=UDim2.fromOffset(22,43)
    title.Size=UDim2.new(0.7,0,0,40)

    local welcome=textLabel(hero,"Welcome, Operator",13,Enum.Font.GothamBold,Theme.Accent)
    welcome.Position=UDim2.fromOffset(23,84)
    welcome.Size=UDim2.new(0.7,0,0,25)

    local desc=textLabel(hero,"All systems operational. Command channel secured and ready for your next operation.",11,Enum.Font.Gotham,Theme.Muted)
    desc.Position=UDim2.fromOffset(23,111)
    desc.Size=UDim2.new(0.58,0,0,42)
    desc.TextWrapped=true

    local execute=Components.Button(hero,{
        Name="Execute",
        Description="Run current operation",
        Icon="▶",
        Callback=function()
            UI:SetStatus("EXECUTING","Running demonstration operation...")
            UI:Log("EXEC","Demonstration operation started.")
            task.delay(0.8,function()
                UI:SetStatus("COMPLETED","Operation completed successfully.")
                UI:Log("SUCCESS","Demonstration operation completed.")
                UI:Notify({
                    Title="OPERATION COMPLETE",
                    Description="The demonstration command finished successfully.",
                    Type="Success",
                    Duration=3,
                })
            end)
        end
    })
    execute.Instance.Size=UDim2.fromOffset(190,58)
    execute.Instance.Position=UDim2.new(1,-410,1,-78)

    local consoleBtn=Components.Button(hero,{
        Name="Open Console",
        Description="Inspect runtime logs",
        Icon=">",
        Callback=function()
            for _,t in ipairs(UI.Tabs) do
                if t.Name=="Console" then
                    t.Button:FindFirstChildOfClass("TextButton"):Activate()
                    break
                end
            end
        end
    })
    consoleBtn.Instance.Size=UDim2.fromOffset(190,58)
    consoleBtn.Instance.Position=UDim2.new(1,-205,1,-78)

    local statusPanel=make("Frame",{
        BackgroundColor3=Theme.Background,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(190,78),
        Position=UDim2.new(1,-210,0,20),
    },hero)
    corner(statusPanel,10)
    stroke(statusPanel,Theme.Border,1,0.2)
    UI.StatusPanel=statusPanel

    local dot=make("Frame",{
        BackgroundColor3=Theme.Success,
        BorderSizePixel=0,
        Size=UDim2.fromOffset(7,7),
        Position=UDim2.fromOffset(15,17),
    },statusPanel)
    corner(dot,99)
    UI.StatusDot=dot

    local statusTitle=textLabel(statusPanel,"READY",10,Enum.Font.GothamBold,Theme.Success)
    statusTitle.Position=UDim2.fromOffset(31,9)
    statusTitle.Size=UDim2.new(1,-42,0,22)
    UI.StatusTitle=statusTitle

    local statusIcon=textLabel(statusPanel,"●",13,Enum.Font.GothamBlack,Theme.Success)
    statusIcon.Position=UDim2.new(1,-32,0,8)
    statusIcon.Size=UDim2.fromOffset(22,22)
    statusIcon.TextXAlignment=Enum.TextXAlignment.Center
    UI.StatusIcon=statusIcon

    local statusDetail=textLabel(statusPanel,"All systems operational.",8,Enum.Font.Gotham,Theme.Muted)
    statusDetail.Position=UDim2.fromOffset(15,38)
    statusDetail.Size=UDim2.new(1,-30,0,30)
    statusDetail.TextWrapped=true
    UI.StatusDetailLabel=statusDetail

    Components.Section(tab.Page,"Live Telemetry","Real-time runtime information")

    local cards=make("Frame",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,96),
    },tab.Page)
    local grid=make("UIGridLayout",{
        CellPadding=UDim2.fromOffset(10,0),
        CellSize=UDim2.new(0.19,0,1,0),
        FillDirectionMaxCells=5,
    },cards)

    local cardData={
        {"FPS","--","◆"},
        {"PING","-- ms","⌁"},
        {"RUNTIME","00:00","◷"},
        {"STATE","READY","●"},
        {"VERSION",CONFIG.Version,"◇"},
    }
    for i,d in ipairs(cardData) do
        local c=make("Frame",{
            BackgroundColor3=Theme.Panel2,
            BorderSizePixel=0,
        },cards)
        corner(c,10)
        stroke(c,Theme.Border,1,0.25)
        local ic=textLabel(c,d[3],16,Enum.Font.GothamBold,Theme.Accent2)
        ic.Position=UDim2.fromOffset(12,10)
        ic.Size=UDim2.fromOffset(24,22)
        local v=textLabel(c,d[2],14,Enum.Font.GothamBlack,Theme.Text)
        v.Position=UDim2.fromOffset(12,35)
        v.Size=UDim2.new(1,-20,0,24)
        local n=textLabel(c,string.upper(d[1]),8,Enum.Font.GothamBold,Theme.Muted)
        n.Position=UDim2.fromOffset(12,65)
        n.Size=UDim2.new(1,-20,0,18)
        c:SetAttribute("Metric",d[1])
        c:SetAttribute("ValueLabel",v)
        if d[1]=="FPS" then UI.FPSLabel=v end
        if d[1]=="PING" then UI.PingLabel=v end
        if d[1]=="STATE" then UI.StateMetricLabel=v end
    end

    Components.Section(tab.Page,"Activity Feed","Latest system events")

    local feed=make("Frame",{
        BackgroundColor3=Theme.Panel2,
        BorderSizePixel=0,
        Size=UDim2.new(1,0,0,145),
    },tab.Page)
    corner(feed,10)
    stroke(feed,Theme.Border,1,0.25)
    local feedList=make("UIListLayout",{Padding=UDim.new(0,0)},feed)
    local events={
        {"00:01","INFO","System initialized"},
        {"00:02","SUCCESS","UI engine loaded"},
        {"00:03","INFO","Input channels synchronized"},
        {"00:04","SUCCESS","Component registry online"},
    }
    for _,e in ipairs(events) do
        local row=make("Frame",{
            BackgroundTransparency=1,
            Size=UDim2.new(1,0,0,34),
        },feed)
        local tx=textLabel(row,e[1].."   "..e[2],9,Enum.Font.Code,
            e[2]=="SUCCESS" and Theme.Success or Theme.Accent2)
        tx.Position=UDim2.fromOffset(14,0)
        tx.Size=UDim2.fromOffset(105,34)
        local msg=textLabel(row,e[3],9,Enum.Font.Gotham,Theme.Muted)
        msg.Position=UDim2.fromOffset(120,0)
        msg.Size=UDim2.new(1,-135,34,0)
    end
end

local function buildControls(tab)
    Components.Section(tab.Page,"Command Controls","Premium interactive components")

    tab:CreateButton({
        Name="Execute",
        Description="Execute a safe demonstration command",
        Icon="▶",
        Callback=function()
            UI:SetStatus("EXECUTING","Processing command...")
            UI:Log("EXEC","Manual execute command triggered.")
            UI:Notify({Title="COMMAND STARTED",Description="The command is now processing.",Type="Loading",Duration=2})
            task.delay(1,function()
                UI:SetStatus("COMPLETED","Command completed.")
                UI:Log("SUCCESS","Manual command completed.")
            end)
        end
    })

    tab:CreateToggle({
        Name="Feature Power",
        Description="Enable the demonstration feature",
        Default=true,
        Callback=function(v)
            UI:Log("INFO","Feature Power = "..tostring(v))
        end
    })

    tab:CreateSlider({
        Name="Power",
        Min=0, Max=1000, Default=250, Step=10,
        Callback=function(v)
            if math.floor(v)%100==0 then UI:Log("INFO","Power adjusted to "..v) end
        end
    })

    tab:CreateNumberInput({
        Name="Value",
        Default=250,
        Min=0, Max=1000, Step=5,
        Callback=function(v)
            UI:Log("INFO","Number input = "..tostring(v))
        end
    })

    tab:CreateTextInput({
        Name="Operator Tag",
        Placeholder="ENTER OPERATOR TAG",
        Default="NOVA-01",
        Callback=function(v)
            UI:Log("INFO","Operator tag updated.")
        end
    })

    tab:CreateDropdown({
        Name="Profile",
        Options={"Balanced","Performance","Cinematic","Experimental"},
        Default="Balanced",
        Callback=function(v)
            UI:Log("INFO","Profile = "..tostring(v))
        end
    })

    tab:CreateMultiDropdown({
        Name="Modules",
        Options={"HUD","FX","Telemetry","Console","Input"},
        Callback=function(v)
            UI:Log("INFO","Modules selected: "..table.concat(v,", "))
        end
    })

    tab:CreateKeybind({
        Name="Interface Keybind",
        Default=Enum.KeyCode.RightShift,
        Callback=function(k)
            UI:Log("INFO","Keybind changed to "..k.Name)
        end
    })

    tab:CreateColorPicker({
        Name="Accent Color",
        Default=Theme.Accent,
        Callback=function(c)
            UI:SetThemeColorPreview(c)
        end
    })
end

function UI:SetThemeColorPreview(c)
    -- Demo callback: the actual theme system remains controlled by SetTheme.
    self:Log("INFO","Accent preview selected: "..tostring(c))
end

local function buildSettings(tab)
    Components.Section(tab.Page,"Theme Engine","Change the entire visual language in real time")

    tab:CreateDropdown({
        Name="Theme",
        Options={"NeonPurple","CyberBlue","Crimson","Toxic","Void","Arctic"},
        Default=CONFIG.Theme,
        Callback=function(v)
            UI:SetTheme(v)
        end
    })

    tab:CreateSlider({
        Name="UI Scale",
        Min=80, Max=120, Default=100, Step=5,
        Callback=function(v)
            UI:SetScale(v/100)
        end
    })

    tab:CreateToggle({
        Name="Animations",
        Description="Enable interface transitions and micro-interactions",
        Default=true,
        Callback=function(v) UI.Animations=v end
    })

    tab:CreateToggle({
        Name="Particles",
        Description="Ambient particles and burst effects",
        Default=true,
        Callback=function(v)
            UI.Particles=v
        end
    })

    tab:CreateToggle({
        Name="Glow",
        Description="Premium bloom-like GUI glow",
        Default=true,
        Callback=function(v) UI.Glow=v end
    })

    tab:CreateToggle({
        Name="Performance Mode",
        Description="Reduce background effects and high-frequency visuals",
        Default=false,
        Callback=function(v) UI:SetPerformanceMode(v) end
    })

    Components.Section(tab.Page,"System","Lifecycle and diagnostics")

    tab:CreateButton({
        Name="System Ready",
        Description="Run a diagnostic status transition",
        Icon="✓",
        Callback=function()
            UI:SetStatus("PROCESSING","Running diagnostics...")
            task.delay(0.7,function()
                UI:SetStatus("READY","Diagnostics passed.")
                UI:Notify({
                    Title="DIAGNOSTICS PASSED",
                    Description="All NOVA subsystems are responding normally.",
                    Type="Success",
                    Duration=4
                })
            end)
        end
    })

    tab:CreateButton({
        Name="Test Warning",
        Description="Preview the warning notification style",
        Icon="!",
        Callback=function()
            UI:SetStatus("WARNING","This is a demonstration warning.")
            UI:Notify({
                Title="SYSTEM WARNING",
                Description="This notification demonstrates the warning state.",
                Type="Warning",
                Duration=4
            })
        end
    })
end

function UI:SetScale(scaleValue)
    self.Scale=clamp(scaleValue,0.8,1.2)
    if self.Window then
        local s=self.Window:FindFirstChildOfClass("UIScale") or make("UIScale",{Scale=1},self.Window)
        tween(s,Animation.Smooth,{Scale=self.Scale})
    end
end

function UI:SetPerformanceMode(enabled)
    self.PerformanceMode=enabled==true
    if self.PerformanceMode then
        self.Particles=false
        self.Glow=false
        self:Log("INFO","Performance mode enabled.")
        self:Notify({
            Title="PERFORMANCE MODE",
            Description="Ambient effects have been reduced.",
            Type="Info",
            Duration=3
        })
    else
        self.Particles=true
        self.Glow=true
        self:Log("INFO","Performance mode disabled.")
    end
end

function UI:SetTheme(name)
    if not THEMES[name] then return false end
    self.ThemeName=name
    self.Theme=THEMES[name]
    Theme=self.Theme

    -- Rebuild the interface in-place for a reliable complete theme update.
    local wasVisible=self.Visible
    local oldLogs=self.Logs
    self.Logs={}
    for _,e in ipairs(oldLogs) do table.insert(self.Logs,e) end

    self:Notify({
        Title="THEME SWITCHED",
        Description="Visual profile: "..name,
        Type="Success",
        Duration=2.5
    })

    -- Existing instances are refreshed for common colors.
    for _,inst in ipairs(self.Instances) do
        if inst and inst.Parent then
            pcall(function()
                if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                    if inst.TextColor3==Theme.Text or inst.TextColor3==Color3.fromRGB(239,239,255) then
                        inst.TextColor3=Theme.Text
                    end
                end
            end)
        end
    end
    if wasVisible then self:Show() end
    return true
end

--==============================================================
-- MAIN CREATION
--==============================================================

local function CreateUI(options)
    options=options or {}
    for k,v in pairs(options) do
        if CONFIG[k]~=nil then CONFIG[k]=v end
    end
    UI.ThemeName=CONFIG.Theme
    UI.Theme=THEMES[CONFIG.Theme] or THEMES.NeonPurple
    Theme=UI.Theme
    UI.Animations=CONFIG.Animations
    UI.Particles=CONFIG.Particles
    UI.Glow=CONFIG.Glow
    UI.PerformanceMode=CONFIG.PerformanceMode

    UI:CreateWindow()

    local dashboard=WindowMethods.CreateTab(UI,{
        Name="Dashboard",
        Icon="⌂",
    })
    buildDashboard(dashboard)

    local player=WindowMethods.CreateTab(UI,{
        Name="Player",
        Icon="◇",
    })
    player:CreateSection("Player Systems","Character and local runtime controls")
    player:CreateToggle({
        Name="Enhanced Movement",
        Description="Demonstration movement feature state",
        Default=false,
        Callback=function(v)
            UI:Log("INFO","Enhanced Movement = "..tostring(v))
        end
    })
    player:CreateSlider({
        Name="Walk Power",
        Min=0,Max=100,Default=16,Step=1,
        Callback=function(v) UI:Log("INFO","Walk Power = "..v) end
    })
    player:CreateNumberInput({
        Name="Jump Power",
        Default=50,Min=0,Max=200,Step=5,
        Callback=function(v) UI:Log("INFO","Jump Power = "..v) end
    })

    local visual=WindowMethods.CreateTab(UI,{
        Name="Visual",
        Icon="✦",
    })
    visual:CreateSection("Visual Matrix","Cinematic HUD and presentation controls")
    visual:CreateToggle({
        Name="Ambient Scanlines",
        Description="Control the simulated HUD scanline layer",
        Default=true,
        Callback=function(v) UI:Log("INFO","Scanlines = "..tostring(v)) end
    })
    visual:CreateSlider({
        Name="Bloom",
        Min=0,Max=100,Default=70,Step=5,
        Callback=function(v) UI:Log("INFO","Bloom = "..v) end
    })
    visual:CreateDropdown({
        Name="Visual Profile",
        Options={"Neon","Cinematic","Tactical","Void"},
        Default="Neon",
        Callback=function(v) UI:Log("INFO","Visual Profile = "..v) end
    })

    local controls=WindowMethods.CreateTab(UI,{
        Name="Executor",
        Icon="▶",
    })
    buildControls(controls)

    local consoleTab=WindowMethods.CreateTab(UI,{
        Name="Console",
        Icon=">",
    })
    Console.Build(consoleTab.Page)

    local settings=WindowMethods.CreateTab(UI,{
        Name="Settings",
        Icon="⚙",
    })
    buildSettings(settings)

    buildMobileDrawer()

    UI:Log("INFO","System initialized.")
    UI:Log("SUCCESS","NOVA UI engine loaded.")
    UI:Log("INFO","Input channels synchronized.")
    UI:Log("SUCCESS","Component registry online.")
    UI:SetStatus("READY","All systems operational.")

    return UI
end

--==============================================================
-- GLOBAL API / DEMO BOOT
--==============================================================

local Nova = CreateUI({
    Name="NOVA",
    Version="3.0.0",
    Theme="NeonPurple",
    Animations=true,
    Particles=true,
    Glow=true,
})

-- Public API remains available in this script's environment.
-- For a normal Roblox LocalScript, use the local "Nova" variable above.
-- The boot sequence is intentionally started last so the window exists
-- behind the cinematic startup layer.

BootScreen()

Nova:Notify({
    Title="SYSTEM READY",
    Description="Everything is working normally.",
    Type="Success",
    Duration=4,
})

-- Runtime telemetry: one lightweight heartbeat connection.
local fpsAccumulator=0
local fpsFrames=0
local fpsTime=os.clock()

connect(RunService.RenderStepped,function(dt)
    if UI.Destroyed then return end
    fpsAccumulator+=dt
    fpsFrames+=1
    if fpsAccumulator>=0.5 then
        local fps=round(fpsFrames/fpsAccumulator)
        fpsAccumulator=0
        fpsFrames=0
        if UI.FPSLabel then UI.FPSLabel.Text=tostring(fps) end
    end

    if UI.StateMetricLabel then
        UI.StateMetricLabel.Text=UI.Status
        UI.StateMetricLabel.TextColor3=(
            UI.Status=="ERROR" and Theme.Error
            or UI.Status=="WARNING" and Theme.Warning
            or UI.Status=="READY" and Theme.Success
            or Theme.Accent2
        )
    end
end)

-- Optional ping display using Roblox's built-in network statistic where available.
-- Wrapped safely because statistic names can vary by Roblox client version.
task.spawn(function()
    while not UI.Destroyed do
        if UI.PingLabel then
            local ok, value = pcall(function()
                return LocalPlayer:GetNetworkPing()
            end)
            if ok and type(value)=="number" then
                UI.PingLabel.Text=tostring(round(value*1000)).." ms"
            else
                UI.PingLabel.Text="-- ms"
            end
        end
        task.wait(1)
    end
end)

-- Keyboard shortcut on desktop / keyboard-equipped devices.
connect(UserInputService.InputBegan,function(input,processed)
    if processed or UI.Destroyed then return end
    if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==Enum.KeyCode.RightShift then
        UI:Toggle()
    end
end)

-- Expose the API through a harmless global for convenience in a LocalScript.
-- This is not an external dependency; it simply lets later code in the same
-- client environment access the live object if desired.
_G.NOVA_UI = Nova

return Nova
