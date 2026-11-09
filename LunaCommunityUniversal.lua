-- LUNA COMMUNITY | NEON GLASS FPS (VISUAL UPGRADE)
-- LocalScript | StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "LunaCommunityFPS"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local enabled = false
local dashEnabled = false
local antiAfkEnabled = false
local autoCandyEnabled = false
local autoCandyThread = nil
local speedEnabled = false
local speedHeld = false
local speedMultiplier = 1.8
local minSpeedMultiplier = 1.1
local maxSpeedMultiplier = 5.0
local speedStep = 0.1
local locomotionTracks = {}
local currentHumanoid
local speedOriginal
local speedConnection

local saved = {}
local descendantConnection
local fpsConnection
local rgbConnection

local hue = 0
local selectedTheme = "original"
local neonStyle = "rgb"
local shineStyle = "white"
local themeAccent = Color3.fromRGB(0, 220, 255)
local shineColor = Color3.new(1, 1, 1)

local function new(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(obj, radius)
    new("UICorner", {CornerRadius = UDim.new(0, radius)}, obj)
end

local function outline(obj, color, thickness)
    return new("UIStroke", {
        Color = color,
        Thickness = thickness,
        Transparency = 0.12
    }, obj)
end

local function rgbText(label)
    local gradient = new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(190, 70, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 220, 255))
        })
    }, label)
    return gradient
end

-- MAIN
local main = new("Frame", {
    Name = "LunaWindow",
    Size = UDim2.fromOffset(390, 510),
    Position = UDim2.new(0.5, -195, 0.5, -255),
    BackgroundColor3 = Color3.fromRGB(9, 12, 25),
    BorderSizePixel = 0,
    ClipsDescendants = true
}, gui)
corner(main, 15)

local border = outline(main, Color3.fromRGB(100, 100, 255), 2)
local borderGradient = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 65, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 220, 255))
    })
}, border)

-- WHITE LIGHT
local light = new("Frame", {
    Name = "WhiteLight",
    Size = UDim2.new(0, 75, 1.5, 0),
    Position = UDim2.new(0, -100, -0.25, 0),
    Rotation = 18,
    BackgroundColor3 = shineColor,
    BackgroundTransparency = 0.68,
    BorderSizePixel = 0,
    ZIndex = 1
}, main)

new("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.15),
        NumberSequenceKeypoint.new(1, 1)
    })
}, light)

local function shineLoop()
    if not light.Parent then return end
    light.Position = UDim2.new(0, -100, -0.25, 0)
    local tween = TweenService:Create(
        light,
        TweenInfo.new(2.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {Position = UDim2.new(1, 100, -0.25, 0)}
    )
    tween:Play()
    tween.Completed:Connect(shineLoop)
end
shineLoop()

-- HEADER
local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 53),
    BackgroundColor3 = Color3.fromRGB(15, 20, 39),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ZIndex = 2
}, main)
corner(header, 15)

local title = new("TextLabel", {
    Size = UDim2.new(1, -90, 1, 0),
    Position = UDim2.fromOffset(16, 0),
    BackgroundTransparency = 1,
    Text = "🌙  LUNA COMMUNITY",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, header)

local titleGradient = rgbText(title)

local close = new("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -42, 0, 11),
    BackgroundColor3 = Color3.fromRGB(65, 29, 48),
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 125, 155),
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    BorderSizePixel = 0,
    ZIndex = 5
}, header)
corner(close, 8)

local themeBadge = new("TextLabel", {
    Size = UDim2.fromOffset(34, 30),
    Position = UDim2.new(1, -82, 0, 11),
    BackgroundTransparency = 1,
    Text = "",
    TextSize = 19,
    Font = Enum.Font.GothamBold,
    ZIndex = 5
}, header)

-- CONTENT
local section = new("TextLabel", {
    Size = UDim2.new(1, -30, 0, 25),
    Position = UDim2.fromOffset(17, 66),
    BackgroundTransparency = 1,
    Text = "PERFORMANCE",
    TextColor3 = Color3.fromRGB(125, 190, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3
}, main)
rgbText(section)
section.Visible = false

-- NAVIGATION TABS
local perfTab = new("TextButton", {
    Size = UDim2.fromOffset(112, 25),
    Position = UDim2.fromOffset(17, 64),
    BackgroundColor3 = Color3.fromRGB(31, 48, 82),
    Text = "PERFORMANCE",
    TextColor3 = Color3.fromRGB(120, 220, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    BorderSizePixel = 0,
    ZIndex = 4
}, main)
corner(perfTab, 7)
local perfTabStroke = outline(perfTab, Color3.fromRGB(70, 160, 255), 1)

local miscTab = new("TextButton", {
    Size = UDim2.fromOffset(112, 25),
    Position = UDim2.fromOffset(139, 64),
    BackgroundColor3 = Color3.fromRGB(19, 26, 47),
    Text = "MISC",
    TextColor3 = Color3.fromRGB(145, 155, 185),
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    BorderSizePixel = 0,
    ZIndex = 4
}, main)
corner(miscTab, 7)
local miscTabStroke = outline(miscTab, Color3.fromRGB(75, 110, 200), 1)

local customTab = new("TextButton", {
    Size = UDim2.fromOffset(112, 25),
    Position = UDim2.fromOffset(261, 64),
    BackgroundColor3 = Color3.fromRGB(19, 26, 47),
    Text = "CUSTOM UI",
    TextColor3 = Color3.fromRGB(145, 155, 185),
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    BorderSizePixel = 0,
    ZIndex = 4
}, main)
corner(customTab, 7)
local customTabStroke = outline(customTab, Color3.fromRGB(75, 110, 200), 1)

local miscCard = new("Frame", {
    Size = UDim2.new(1, -34, 0, 174),
    Position = UDim2.fromOffset(17, 98),
    BackgroundColor3 = Color3.fromRGB(19, 26, 47),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 3
}, main)
corner(miscCard, 11)
local miscStroke = outline(miscCard, Color3.fromRGB(75, 110, 200), 1)

local miscTitle = new("TextLabel", {
    Size = UDim2.new(1, -24, 0, 28),
    Position = UDim2.fromOffset(13, 12),
    BackgroundTransparency = 1,
    Text = "⚡  SPEED BY HEARTBEAT",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, miscCard)
local miscTitleGradient = rgbText(miscTitle)

new("TextLabel", {
    Size = UDim2.new(1, -24, 0, 38),
    Position = UDim2.fromOffset(13, 43),
    BackgroundTransparency = 1,
    Text = "Enable the toggle and hold F to move faster.\nLeg animations stay at 1x speed.",
    TextColor3 = Color3.fromRGB(140, 155, 185),
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ZIndex = 4
}, miscCard)

local speedToggle = new("TextButton", {
    Size = UDim2.fromOffset(78, 32),
    Position = UDim2.new(1, -91, 0, 94),
    BackgroundColor3 = Color3.fromRGB(65, 32, 48),
    Text = "OFF",
    TextColor3 = Color3.fromRGB(255, 120, 140),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0,
    ZIndex = 5
}, miscCard)
corner(speedToggle, 9)

local speedMinus = new("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.fromOffset(13, 95),
    BackgroundColor3 = Color3.fromRGB(31, 48, 82),
    Text = "−",
    TextColor3 = Color3.fromRGB(120, 220, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    BorderSizePixel = 0,
    ZIndex = 5
}, miscCard)
corner(speedMinus, 8)
local speedMinusStroke = outline(speedMinus, Color3.fromRGB(70, 160, 255), 1)

local speedValue = new("TextLabel", {
    Size = UDim2.fromOffset(58, 30),
    Position = UDim2.fromOffset(49, 95),
    BackgroundTransparency = 1,
    Text = string.format("%.1fx", speedMultiplier),
    TextColor3 = Color3.fromRGB(235, 240, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    ZIndex = 5
}, miscCard)

local speedPlus = new("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.fromOffset(111, 95),
    BackgroundColor3 = Color3.fromRGB(31, 48, 82),
    Text = "+",
    TextColor3 = Color3.fromRGB(120, 220, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    BorderSizePixel = 0,
    ZIndex = 5
}, miscCard)
corner(speedPlus, 8)
local speedPlusStroke = outline(speedPlus, Color3.fromRGB(70, 160, 255), 1)

local speedDot = new("Frame", {
    Size = UDim2.fromOffset(9, 9),
    Position = UDim2.fromOffset(9, 11),
    BackgroundColor3 = Color3.fromRGB(255, 65, 75),
    BorderSizePixel = 0,
    ZIndex = 6
}, speedToggle)
corner(speedDot, 20)

local speedStatus = new("TextLabel", {
    Size = UDim2.new(1, -24, 0, 22),
    Position = UDim2.fromOffset(13, 137),
    BackgroundTransparency = 1,
    Text = "STATUS: OFF  •  HOLD F TO RUN",
    TextColor3 = Color3.fromRGB(130, 150, 185),
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, miscCard)

-- CUSTOM UI PAGE
local customCard = new("Frame", {
    Size = UDim2.new(1, -34, 0, 286),
    Position = UDim2.fromOffset(17, 98),
    BackgroundColor3 = Color3.fromRGB(19, 26, 47),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 3
}, main)
corner(customCard, 11)
local customStroke = outline(customCard, Color3.fromRGB(75, 110, 200), 1)

local customHeading = new("TextLabel", {
    Size = UDim2.new(1, -24, 0, 25),
    Position = UDim2.fromOffset(13, 9),
    BackgroundTransparency = 1,
    Text = "✦  CUSTOMIZE YOUR INTERFACE",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, customCard)
local customHeadingGradient = rgbText(customHeading)

local themeLabel = new("TextLabel", {
    Size = UDim2.new(1, -24, 0, 20), Position = UDim2.fromOffset(13, 39),
    BackgroundTransparency = 1, Text = "THEMES", TextColor3 = Color3.fromRGB(145, 170, 210),
    Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4
}, customCard)

local function makeThemeButton(text, x, y, width)
    local button = new("TextButton", {
        Size = UDim2.fromOffset(width, 34), Position = UDim2.fromOffset(x, y),
        BackgroundColor3 = Color3.fromRGB(31, 42, 67), Text = text,
        TextColor3 = Color3.fromRGB(225, 235, 255), Font = Enum.Font.GothamBold,
        TextSize = 10, BorderSizePixel = 0, ZIndex = 5
    }, customCard)
    corner(button, 8)
    local stroke = outline(button, Color3.fromRGB(75, 110, 200), 1)
    return button, stroke
end

local originalThemeButton, originalThemeStroke = makeThemeButton("🌙 ORIGINAL", 13, 63, 108)
local halloweenThemeButton, halloweenThemeStroke = makeThemeButton("🎃 HALLOWEEN", 131, 63, 108)
local waterThemeButton, waterThemeStroke = makeThemeButton("💧 WATER", 249, 63, 108)

local neonLabel = new("TextLabel", {
    Size = UDim2.new(1, -24, 0, 20), Position = UDim2.fromOffset(13, 111),
    BackgroundTransparency = 1, Text = "NEON STYLE", TextColor3 = Color3.fromRGB(145, 170, 210),
    Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4
}, customCard)
local rgbNeonButton, rgbNeonStroke = makeThemeButton("RGB CYCLE", 13, 135, 108)
local cyanNeonButton, cyanNeonStroke = makeThemeButton("CYAN", 131, 135, 108)
local purpleNeonButton, purpleNeonStroke = makeThemeButton("PURPLE", 249, 135, 108)

local shineLabel = new("TextLabel", {
    Size = UDim2.new(1, -24, 0, 20), Position = UDim2.fromOffset(13, 183),
    BackgroundTransparency = 1, Text = "MOVING LIGHT COLOR", TextColor3 = Color3.fromRGB(145, 170, 210),
    Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4
}, customCard)
local whiteLightButton, whiteLightStroke = makeThemeButton("WHITE", 13, 207, 108)
local blueLightButton, blueLightStroke = makeThemeButton("ICE BLUE", 131, 207, 108)
local pinkLightButton, pinkLightStroke = makeThemeButton("PINK", 249, 207, 108)

local themeStatus = new("TextLabel", {
    Size = UDim2.new(1, -24, 0, 24), Position = UDim2.fromOffset(13, 252),
    BackgroundTransparency = 1, Text = "ACTIVE THEME: ORIGINAL",
    TextColor3 = Color3.fromRGB(130, 150, 185), Font = Enum.Font.GothamBold,
    TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4
}, customCard)

local card, dashCard, antiAfkCard, autoCandyCard

local function setPage(page)
    local showPerformance = page == "performance"
    local showMisc = page == "misc"
    card.Visible = showPerformance
    dashCard.Visible = showPerformance
    antiAfkCard.Visible = showPerformance
    autoCandyCard.Visible = showPerformance
    miscCard.Visible = showMisc
    customCard.Visible = page == "custom"
    perfTab.BackgroundColor3 = showPerformance and Color3.fromRGB(31, 48, 82) or Color3.fromRGB(19, 26, 47)
    perfTab.TextColor3 = showPerformance and Color3.fromRGB(120, 220, 255) or Color3.fromRGB(145, 155, 185)
    miscTab.BackgroundColor3 = showMisc and Color3.fromRGB(31, 48, 82) or Color3.fromRGB(19, 26, 47)
    miscTab.TextColor3 = showMisc and Color3.fromRGB(120, 220, 255) or Color3.fromRGB(145, 155, 185)
    customTab.BackgroundColor3 = page == "custom" and Color3.fromRGB(31, 48, 82) or Color3.fromRGB(19, 26, 47)
    customTab.TextColor3 = page == "custom" and Color3.fromRGB(120, 220, 255) or Color3.fromRGB(145, 155, 185)
end

perfTab.MouseButton1Click:Connect(function() setPage("performance") end)
miscTab.MouseButton1Click:Connect(function() setPage("misc") end)
customTab.MouseButton1Click:Connect(function() setPage("custom") end)

-- FPS BOOST CARD
card = new("Frame", {
    Size = UDim2.new(1, -34, 0, 82),
    Position = UDim2.fromOffset(17, 98),
    BackgroundColor3 = Color3.fromRGB(19, 26, 47),
    BorderSizePixel = 0,
    ZIndex = 3
}, main)
corner(card, 11)
local cardStroke = outline(card, Color3.fromRGB(75, 110, 200), 1)

local boostTitle = new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 26),
    Position = UDim2.fromOffset(13, 10),
    BackgroundTransparency = 1,
    Text = "⚡  FPS BOOST",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, card)
rgbText(boostTitle)

new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 25),
    Position = UDim2.fromOffset(13, 38),
    BackgroundTransparency = 1,
    Text = "Reduces textures, effects, and visual details.",
    TextColor3 = Color3.fromRGB(140, 155, 185),
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, card)

local toggle = new("TextButton", {
    Size = UDim2.fromOffset(86, 32),
    Position = UDim2.new(1, -98, 0.5, -16),
    BackgroundColor3 = Color3.fromRGB(65, 32, 48),
    Text = "OFF",
    TextColor3 = Color3.fromRGB(255, 120, 140),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0,
    ZIndex = 5
}, card)
corner(toggle, 9)

local dot = new("Frame", {
    Size = UDim2.fromOffset(9, 9),
    Position = UDim2.fromOffset(9, 11),
    BackgroundColor3 = Color3.fromRGB(255, 65, 75),
    BorderSizePixel = 0,
    ZIndex = 6
}, toggle)
corner(dot, 20)

-- NO DASH COOLDOWN CARD
dashCard = new("Frame", {
    Size = UDim2.new(1, -34, 0, 82),
    Position = UDim2.fromOffset(17, 190),
    BackgroundColor3 = Color3.fromRGB(19, 26, 47),
    BorderSizePixel = 0,
    ZIndex = 3
}, main)
corner(dashCard, 11)
local dashStroke = outline(dashCard, Color3.fromRGB(75, 110, 200), 1)

local dashTitle = new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 26),
    Position = UDim2.fromOffset(13, 10),
    BackgroundTransparency = 1,
    Text = "⚡  NO DASH COOLDOWN",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, dashCard)
rgbText(dashTitle)

new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 25),
    Position = UDim2.fromOffset(13, 38),
    BackgroundTransparency = 1,
    Text = "Local cooldown setting.",
    TextColor3 = Color3.fromRGB(140, 155, 185),
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, dashCard)

local dashToggle = new("TextButton", {
    Size = UDim2.fromOffset(86, 32),
    Position = UDim2.new(1, -98, 0.5, -16),
    BackgroundColor3 = Color3.fromRGB(65, 32, 48),
    Text = "OFF",
    TextColor3 = Color3.fromRGB(255, 120, 140),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0,
    ZIndex = 5
}, dashCard)
corner(dashToggle, 9)

local dashDot = new("Frame", {
    Size = UDim2.fromOffset(9, 9),
    Position = UDim2.fromOffset(9, 11),
    BackgroundColor3 = Color3.fromRGB(255, 65, 75),
    BorderSizePixel = 0,
    ZIndex = 6
}, dashToggle)
corner(dashDot, 20)

-- ANTI-AFK CARD
antiAfkCard = new("Frame", {
    Size = UDim2.new(1, -34, 0, 82),
    Position = UDim2.fromOffset(17, 282),
    BackgroundColor3 = Color3.fromRGB(19, 26, 47),
    BorderSizePixel = 0,
    ZIndex = 3
}, main)
corner(antiAfkCard, 11)
local antiAfkStroke = outline(antiAfkCard, Color3.fromRGB(75, 110, 200), 1)
local antiAfkTitle = new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 26),
    Position = UDim2.fromOffset(13, 10),
    BackgroundTransparency = 1,
    Text = "🛡  ANTI-AFK",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, antiAfkCard)
rgbText(antiAfkTitle)
new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 25),
    Position = UDim2.fromOffset(13, 38),
    BackgroundTransparency = 1,
    Text = "Keeps your game's AFK flag disabled.",
    TextColor3 = Color3.fromRGB(140, 155, 185),
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, antiAfkCard)
local antiAfkToggle = new("TextButton", {
    Size = UDim2.fromOffset(86, 32),
    Position = UDim2.new(1, -98, 0.5, -16),
    BackgroundColor3 = Color3.fromRGB(65, 32, 48),
    Text = "OFF",
    TextColor3 = Color3.fromRGB(255, 120, 140),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0,
    ZIndex = 5
}, antiAfkCard)
corner(antiAfkToggle, 9)
local antiAfkDot = new("Frame", {
    Size = UDim2.fromOffset(9, 9),
    Position = UDim2.fromOffset(9, 11),
    BackgroundColor3 = Color3.fromRGB(255, 65, 75),
    BorderSizePixel = 0,
    ZIndex = 6
}, antiAfkToggle)
corner(antiAfkDot, 20)

-- AUTO CANDY CARD
autoCandyCard = new("Frame", {
    Size = UDim2.new(1, -34, 0, 82),
    Position = UDim2.fromOffset(17, 374),
    BackgroundColor3 = Color3.fromRGB(19, 26, 47),
    BorderSizePixel = 0,
    ZIndex = 3
}, main)
corner(autoCandyCard, 11)
local autoCandyStroke = outline(autoCandyCard, Color3.fromRGB(75, 110, 200), 1)
local autoCandyTitle = new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 26),
    Position = UDim2.fromOffset(13, 8),
    BackgroundTransparency = 1,
    Text = "🍬  AUTO CANDY",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, autoCandyCard)
rgbText(autoCandyTitle)
local autoCandyStatus = new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 28),
    Position = UDim2.fromOffset(13, 37),
    BackgroundTransparency = 1,
    Text = "STATUS: OFF",
    TextColor3 = Color3.fromRGB(140, 155, 185),
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, autoCandyCard)
local autoCandyToggle = new("TextButton", {
    Size = UDim2.fromOffset(86, 32),
    Position = UDim2.new(1, -98, 0.5, -16),
    BackgroundColor3 = Color3.fromRGB(65, 32, 48),
    Text = "OFF",
    TextColor3 = Color3.fromRGB(255, 120, 140),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    BorderSizePixel = 0,
    ZIndex = 5
}, autoCandyCard)
corner(autoCandyToggle, 9)
local autoCandyDot = new("Frame", {
    Size = UDim2.fromOffset(9, 9),
    Position = UDim2.fromOffset(9, 11),
    BackgroundColor3 = Color3.fromRGB(255, 65, 75),
    BorderSizePixel = 0,
    ZIndex = 6
}, autoCandyToggle)
corner(autoCandyDot, 20)

-- Optional executor Drawing status overlay (not available in standard Studio).
local candyDrawingStatus
local candyDrawingConnection
pcall(function()
    candyDrawingStatus = Drawing.new("Text")
    candyDrawingStatus.Text = "LUNA COMMUNITY | AUTO CANDY: OFF"
    candyDrawingStatus.Size = 18
    candyDrawingStatus.Center = true
    candyDrawingStatus.Outline = true
    candyDrawingStatus.Color = Color3.fromRGB(255, 255, 255)
    candyDrawingStatus.Visible = true
end)

candyDrawingConnection = RunService.RenderStepped:Connect(function()
    if not candyDrawingStatus then return end
    local camera = workspace.CurrentCamera
    if camera then
        candyDrawingStatus.Position = Vector2.new(camera.ViewportSize.X / 2, 35)
    end
    candyDrawingStatus.Text = "LUNA COMMUNITY | " .. autoCandyStatus.Text
end)

-- FOOTER
local footer = new("TextLabel", {
    Size = UDim2.new(1, -34, 0, 20),
    Position = UDim2.fromOffset(17, 470),
    BackgroundTransparency = 1,
    Text = "LUNA PERFORMANCE SYSTEM  •  CLIENT SIDE",
    TextColor3 = Color3.fromRGB(100, 120, 165),
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    ZIndex = 3
}, main)
rgbText(footer)

-- FLOATING FPS / PING DISPLAY
local hud = new("Frame", {
    Size = UDim2.fromOffset(160, 64),
    Position = UDim2.new(1, -180, 0, 25),
    BackgroundColor3 = Color3.fromRGB(9, 13, 27),
    BackgroundTransparency = 0.04,
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true
}, gui)
corner(hud, 11)
local hudStroke = outline(hud, Color3.fromRGB(90, 120, 255), 1.5)

local hudLight = new("Frame", {
    Size = UDim2.new(0, 40, 1.5, 0),
    Position = UDim2.new(0, -60, -0.25, 0),
    Rotation = 18,
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.72,
    BorderSizePixel = 0,
    ZIndex = 1
}, hud)

new("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
}, hudLight)

local function hudShine()
    if not hudLight.Parent then return end
    hudLight.Position = UDim2.new(0, -60, -0.25, 0)
    local tween = TweenService:Create(
        hudLight,
        TweenInfo.new(2, Enum.EasingStyle.Sine),
        {Position = UDim2.new(1, 60, -0.25, 0)}
    )
    tween:Play()
    tween.Completed:Connect(hudShine)
end
hudShine()

local fpsText = new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 25),
    Position = UDim2.fromOffset(9, 5),
    BackgroundTransparency = 1,
    Text = "FPS: 0",
    TextColor3 = Color3.fromRGB(90, 220, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3
}, hud)

local pingText = new("TextLabel", {
    Size = UDim2.new(1, -16, 0, 23),
    Position = UDim2.fromOffset(9, 33),
    BackgroundTransparency = 1,
    Text = "PING: -- ms",
    TextColor3 = Color3.fromRGB(185, 145, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3
}, hud)

-- DRAG
local function draggable(frame, handle)
    local active = false
    local origin
    local position

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            active = true
            origin = input.Position
            position = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if active and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - origin
            frame.Position = UDim2.new(
                position.X.Scale, position.X.Offset + delta.X,
                position.Y.Scale, position.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            active = false
        end
    end)
end

draggable(main, header)
draggable(hud, hud)

-- TREE IDENTIFICATION
local function isTree(instance)
    local current = instance
    while current and current ~= workspace do
        local name = string.lower(current.Name)
        if name:find("tree", 1, true)
        or name:find("arvore", 1, true)
        or name:find("árvore", 1, true)
        or name:find("foliage", 1, true) then
            return true
        end
        current = current.Parent
    end
    return false
end

local function save(instance, property)
    saved[instance] = saved[instance] or {}
    if saved[instance][property] == nil then
        local ok, value = pcall(function()
            return instance[property]
        end)
        if ok then
            saved[instance][property] = value
        end
    end
end

local function optimize(instance)
    if not enabled then return end
    if instance:IsA("BasePart") then
        if isTree(instance) then
            save(instance, "LocalTransparencyModifier")
            instance.LocalTransparencyModifier = 1
        else
            save(instance, "Material")
            save(instance, "Reflectance")
            instance.Material = Enum.Material.SmoothPlastic
            instance.Reflectance = 0
        end
    elseif instance:IsA("Decal") or instance:IsA("Texture") then
        save(instance, "Transparency")
        instance.Transparency = 1
    elseif instance:IsA("ParticleEmitter")
    or instance:IsA("Trail")
    or instance:IsA("Beam")
    or instance:IsA("Smoke")
    or instance:IsA("Fire")
    or instance:IsA("Sparkles") then
        save(instance, "Enabled")
        instance.Enabled = false
    end
end

local function restore()
    for instance, properties in pairs(saved) do
        if instance and instance.Parent then
            for property, value in pairs(properties) do
                pcall(function()
                    instance[property] = value
                end)
            end
        end
    end
    table.clear(saved)
end

local function setBoost(state)
    enabled = state
    if enabled then
        for _, instance in ipairs(workspace:GetDescendants()) do
            optimize(instance)
        end
        descendantConnection = workspace.DescendantAdded:Connect(function(instance)
            task.defer(function()
                if enabled and instance.Parent then
                    optimize(instance)
                end
            end)
        end)
        toggle.Text = "ON"
        toggle.TextColor3 = Color3.fromRGB(90, 255, 160)
        toggle.BackgroundColor3 = Color3.fromRGB(25, 70, 52)
        dot.BackgroundColor3 = Color3.fromRGB(60, 255, 120)
        hud.Visible = true
    else
        if descendantConnection then
            descendantConnection:Disconnect()
            descendantConnection = nil
        end
        restore()
        toggle.Text = "OFF"
        toggle.TextColor3 = Color3.fromRGB(255, 120, 140)
        toggle.BackgroundColor3 = Color3.fromRGB(65, 32, 48)
        dot.BackgroundColor3 = Color3.fromRGB(255, 65, 75)
        hud.Visible = false
    end
end

toggle.MouseButton1Click:Connect(function()
    setBoost(not enabled)
end)

-- NO DASH COOLDOWN LOCAL MARKER
dashToggle.MouseButton1Click:Connect(function()
    dashEnabled = not dashEnabled
    if dashEnabled then
        workspace:SetAttribute("VIPServer", tostring(player.UserId))
        workspace:SetAttribute("VIPServerOwner", player.Name)
        workspace:SetAttribute("NoDashCooldown", true)
        dashToggle.Text = "ON"
        dashToggle.TextColor3 = Color3.fromRGB(90, 255, 160)
        dashToggle.BackgroundColor3 = Color3.fromRGB(25, 70, 52)
        dashDot.BackgroundColor3 = Color3.fromRGB(60, 255, 120)
    else
        workspace:SetAttribute("NoDashCooldown", false)
        dashToggle.Text = "OFF"
        dashToggle.TextColor3 = Color3.fromRGB(255, 120, 140)
        dashToggle.BackgroundColor3 = Color3.fromRGB(65, 32, 48)
        dashDot.BackgroundColor3 = Color3.fromRGB(255, 65, 75)
    end
end)

-- ANTI-AFK + AUTO CANDY (ROBLOX STUDIO / YOUR OWN EXPERIENCE)
local function setToggleVisual(button, dot, state)
    button.Text = state and "ON" or "OFF"
    button.TextColor3 = state and Color3.fromRGB(90, 255, 160) or Color3.fromRGB(255, 120, 140)
    button.BackgroundColor3 = state and Color3.fromRGB(25, 70, 52) or Color3.fromRGB(65, 32, 48)
    dot.BackgroundColor3 = state and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 65, 75)
end

antiAfkToggle.MouseButton1Click:Connect(function()
    antiAfkEnabled = not antiAfkEnabled
    -- This flag is intended for AFK systems inside your own experience.
    -- Roblox's platform idle kick cannot be disabled through supported LocalScript APIs.
    player:SetAttribute("LunaAntiAFKEnabled", antiAfkEnabled)
    setToggleVisual(antiAfkToggle, antiAfkDot, antiAfkEnabled)
end)

local function getCandyPosition(candy)
    local restAttribute = candy:GetAttribute("Rest")
    if typeof(restAttribute) == "Vector3" then
        return restAttribute
    elseif typeof(restAttribute) == "CFrame" then
        return restAttribute.Position
    end

    local restObject = candy:FindFirstChild("Rest")
    if restObject then
        if restObject:IsA("ObjectValue") and restObject.Value and restObject.Value:IsA("BasePart") then
            return restObject.Value.Position
        elseif restObject:IsA("BasePart") then
            return restObject.Position
        elseif restObject:IsA("Vector3Value") then
            return restObject.Value
        end
    end
    return nil
end

local function findClosestCandy(root, folder)
    local closestPosition, closestDistance
    for _, candy in ipairs(folder:GetChildren()) do
        local position = getCandyPosition(candy)
        if position then
            local distance = (root.Position - position).Magnitude
            if not closestDistance or distance < closestDistance then
                closestDistance = distance
                closestPosition = position
            end
        end
    end
    return closestPosition
end

local function findClosestCandyDoor(root, trees)
    local bestPrompt, bestPart, bestDistance
    for _, tree in ipairs(trees:GetChildren()) do
        local door = tree:FindFirstChild("DOOR 1 NEW")
        local frame = door and door:FindFirstChild("Frame")
        local prompt = frame and frame:FindFirstChild("TrickOrTreat")
        local part = prompt and prompt.Parent
        if prompt and prompt:IsA("ProximityPrompt") and part and part:IsA("BasePart") then
            local distance = (root.Position - part.Position).Magnitude
            if not bestDistance or distance < bestDistance then
                bestPrompt, bestPart, bestDistance = prompt, part, distance
            end
        end
    end
    return bestPrompt, bestPart
end

local function activateCandyDoor(prompt, part, root)
    if not prompt or not part or not root then
        return false
    end

    -- Wait briefly for the door prompt to become available.
    local waitStarted = os.clock()
    while autoCandyEnabled and prompt.Parent and not prompt.Enabled and os.clock() - waitStarted < 3 do
        task.wait(0.1)
    end

    if not autoCandyEnabled or not prompt.Parent or not part.Parent or not prompt.Enabled then
        return false
    end

    -- Stand inside the prompt's activation range, facing the door.
    local approachDistance = math.clamp(prompt.MaxActivationDistance - 1, 2, 5)
    local approachPosition = part.Position + part.CFrame.LookVector * approachDistance + Vector3.new(0, 0.5, 0)
    root.CFrame = CFrame.lookAt(approachPosition, part.Position)
    task.wait(0.25)

    if not autoCandyEnabled or not prompt.Parent or not prompt.Enabled then
        return false
    end

    local distance = (root.Position - part.Position).Magnitude
    if distance > prompt.MaxActivationDistance then
        return false
    end

    -- Prefer the requested executor helper when it exists. In ordinary Studio,
    -- fall back to Roblox's ProximityPrompt input methods for local testing.
    if type(fireproximityprompt) == "function" then
        local ok = pcall(function()
            fireproximityprompt(prompt)
        end)
        return ok
    end

    local ok = pcall(function()
        prompt:InputHoldBegin()
        task.wait(math.max(prompt.HoldDuration, 0.1) + 0.15)
        prompt:InputHoldEnd()
    end)
    return ok
end

local function runAutoCandy()
    local candyFolder = workspace:WaitForChild("HalloweenCandy", 10)
    local doorTrees = workspace:WaitForChild("HalloweenDoorTrees", 10)
    if not candyFolder or not doorTrees then
        autoCandyStatus.Text = "STATUS: REQUIRED FOLDERS NOT FOUND"
        autoCandyEnabled = false
        setToggleVisual(autoCandyToggle, autoCandyDot, false)
        return
    end

    while autoCandyEnabled and gui.Parent do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if not humanoid or not root or humanoid.Health <= 0 then
            autoCandyStatus.Text = "STATUS: WAITING FOR CHARACTER"
            task.wait(0.5)
            continue
        end

        if character:FindFirstChild("RootAnchor") or character:FindFirstChild("NoRotate") then
            autoCandyStatus.Text = "STATUS: WAITING FOR DOOR"
            task.wait(0.25)
            continue
        end

        local candyPosition = findClosestCandy(root, candyFolder)
        if candyPosition then
            autoCandyStatus.Text = "STATUS: COLLECTING CANDY"
            root.CFrame = CFrame.new(candyPosition + Vector3.new(0, 4, 0))
            humanoid.Jump = true
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        else
            local prompt, part = findClosestCandyDoor(root, doorTrees)
            if prompt and part then
                autoCandyStatus.Text = "STATUS: OPENING NEAREST DOOR"
                local opened = activateCandyDoor(prompt, part, root)
                if opened then
                    autoCandyStatus.Text = "STATUS: DOOR INTERACTION COMPLETE"
                else
                    autoCandyStatus.Text = "STATUS: DOOR NOT READY - RETRYING"
                end
                task.wait(0.5)
            else
                autoCandyStatus.Text = "STATUS: NO CANDY OR DOORS FOUND"
                task.wait(0.5)
            end
        end
        task.wait(0.15)
    end
    if autoCandyStatus.Parent then
        autoCandyStatus.Text = "STATUS: OFF"
    end
end

autoCandyToggle.MouseButton1Click:Connect(function()
    autoCandyEnabled = not autoCandyEnabled
    setToggleVisual(autoCandyToggle, autoCandyDot, autoCandyEnabled)
    if autoCandyEnabled then
        autoCandyStatus.Text = "STATUS: STARTING..."
        autoCandyThread = task.spawn(runAutoCandy)
    else
        autoCandyStatus.Text = "STATUS: OFF"
    end
end)

-- SPEED BY HEARTBEAT
local function getHumanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function updateSpeedValue()
    speedValue.Text = string.format("%.1fx", speedMultiplier)
end

local function restoreSpeed()
    local humanoid = currentHumanoid or getHumanoid()
    if humanoid and humanoid.Parent and speedOriginal then
        humanoid.WalkSpeed = speedOriginal
    end
    speedOriginal = nil
end

local function setSpeedEnabled(state)
    speedEnabled = state
    if not speedEnabled then
        speedHeld = false
        restoreSpeed()
        speedToggle.Text = "OFF"
        speedToggle.TextColor3 = Color3.fromRGB(255, 120, 140)
        speedToggle.BackgroundColor3 = Color3.fromRGB(65, 32, 48)
        speedDot.BackgroundColor3 = Color3.fromRGB(255, 65, 75)
        speedStatus.Text = "STATUS: OFF  •  HOLD F TO RUN"
    else
        speedToggle.Text = "ON"
        speedToggle.TextColor3 = Color3.fromRGB(90, 255, 160)
        speedToggle.BackgroundColor3 = Color3.fromRGB(25, 70, 52)
        speedDot.BackgroundColor3 = Color3.fromRGB(60, 255, 120)
        speedStatus.Text = "STATUS: ON  •  HOLD F TO RUN"
    end
end

speedMinus.MouseButton1Click:Connect(function()
    speedMultiplier = math.max(minSpeedMultiplier, math.floor((speedMultiplier - speedStep) * 10 + 0.5) / 10)
    updateSpeedValue()
end)

speedPlus.MouseButton1Click:Connect(function()
    speedMultiplier = math.min(maxSpeedMultiplier, math.floor((speedMultiplier + speedStep) * 10 + 0.5) / 10)
    updateSpeedValue()
end)

speedToggle.MouseButton1Click:Connect(function()
    setSpeedEnabled(not speedEnabled)
end)

local function keepLocomotionAtNormalSpeed(track)
    local trackName = string.lower(track.Name or "")
    if trackName:find("walk", 1, true) or trackName:find("run", 1, true) then
        locomotionTracks[track] = true
        track:AdjustSpeed(1)
    end
end

local function bindCharacter(character)
    currentHumanoid = character:WaitForChild("Humanoid")
    speedOriginal = nil
    speedHeld = false
    table.clear(locomotionTracks)

    local animator = currentHumanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            keepLocomotionAtNormalSpeed(track)
        end
        animator.AnimationPlayed:Connect(keepLocomotionAtNormalSpeed)
    end
end

if player.Character then
    bindCharacter(player.Character)
end
player.CharacterAdded:Connect(bindCharacter)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.F and speedEnabled then
        speedHeld = true
        speedStatus.Text = "STATUS: RUNNING  •  RELEASE F TO STOP"
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        speedHeld = false
        restoreSpeed()
        if speedEnabled then
            speedStatus.Text = "STATUS: ON  •  HOLD F TO RUN"
        end
    end
end)

speedConnection = RunService.Heartbeat:Connect(function()
    local humanoid = getHumanoid()
    if not humanoid or humanoid.Health <= 0 then
        return
    end

    currentHumanoid = humanoid

    if speedEnabled and speedHeld then
        if not speedOriginal then
            speedOriginal = humanoid.WalkSpeed
        end
        humanoid.WalkSpeed = speedOriginal * speedMultiplier
    elseif speedOriginal then
        restoreSpeed()
    end

    -- Keep walk/run animation playback at 1x while movement speed changes.
    for track in pairs(locomotionTracks) do
        if track.IsPlaying then
            track:AdjustSpeed(1)
        else
            locomotionTracks[track] = nil
        end
    end
end)

-- CUSTOM UI THEME CONTROLS
local function updateThemeDecorations()
    if selectedTheme == "halloween" then
        title.Text = "🎃  LUNA COMMUNITY"
        themeBadge.Text = "🎃"
        themeStatus.Text = "ACTIVE THEME: HALLOWEEN  •  PUMPKIN DECOR"
        customCard.BackgroundColor3 = Color3.fromRGB(43, 25, 29)
        miscCard.BackgroundColor3 = Color3.fromRGB(43, 25, 29)
        card.BackgroundColor3 = Color3.fromRGB(43, 25, 29)
        dashCard.BackgroundColor3 = Color3.fromRGB(43, 25, 29)
        antiAfkCard.BackgroundColor3 = Color3.fromRGB(43, 25, 29)
        autoCandyCard.BackgroundColor3 = Color3.fromRGB(43, 25, 29)
        main.BackgroundColor3 = Color3.fromRGB(24, 11, 18)
        header.BackgroundColor3 = Color3.fromRGB(48, 22, 28)
        themeAccent = Color3.fromRGB(255, 125, 35)
        neonStyle = "orange"
    elseif selectedTheme == "water" then
        title.Text = "💧  LUNA COMMUNITY  🌊"
        themeBadge.Text = "💧"
        themeStatus.Text = "ACTIVE THEME: WATER  •  AQUA COLORS"
        customCard.BackgroundColor3 = Color3.fromRGB(14, 39, 54)
        miscCard.BackgroundColor3 = Color3.fromRGB(14, 39, 54)
        card.BackgroundColor3 = Color3.fromRGB(14, 39, 54)
        dashCard.BackgroundColor3 = Color3.fromRGB(14, 39, 54)
        antiAfkCard.BackgroundColor3 = Color3.fromRGB(14, 39, 54)
        autoCandyCard.BackgroundColor3 = Color3.fromRGB(14, 39, 54)
        main.BackgroundColor3 = Color3.fromRGB(5, 19, 31)
        header.BackgroundColor3 = Color3.fromRGB(10, 48, 65)
        themeAccent = Color3.fromRGB(45, 210, 235)
        neonStyle = "cyan"
    else
        title.Text = "🌙  LUNA COMMUNITY"
        themeBadge.Text = ""
        themeStatus.Text = "ACTIVE THEME: ORIGINAL"
        customCard.BackgroundColor3 = Color3.fromRGB(19, 26, 47)
        miscCard.BackgroundColor3 = Color3.fromRGB(19, 26, 47)
        card.BackgroundColor3 = Color3.fromRGB(19, 26, 47)
        dashCard.BackgroundColor3 = Color3.fromRGB(19, 26, 47)
        antiAfkCard.BackgroundColor3 = Color3.fromRGB(19, 26, 47)
        autoCandyCard.BackgroundColor3 = Color3.fromRGB(19, 26, 47)
        main.BackgroundColor3 = Color3.fromRGB(9, 12, 25)
        header.BackgroundColor3 = Color3.fromRGB(15, 20, 39)
        themeAccent = Color3.fromRGB(0, 220, 255)
        neonStyle = "rgb"
    end
    light.BackgroundColor3 = shineColor
end

local function setTheme(theme)
    selectedTheme = theme
    updateThemeDecorations()
end

originalThemeButton.MouseButton1Click:Connect(function() setTheme("original") end)
halloweenThemeButton.MouseButton1Click:Connect(function() setTheme("halloween") end)
waterThemeButton.MouseButton1Click:Connect(function() setTheme("water") end)

local function setNeon(style)
    neonStyle = style
    local gradientColors
    if style == "cyan" then
        themeAccent = Color3.fromRGB(0, 220, 255)
        gradientColors = ColorSequence.new(themeAccent, Color3.fromRGB(90, 245, 255))
    elseif style == "purple" then
        themeAccent = Color3.fromRGB(190, 80, 255)
        gradientColors = ColorSequence.new(themeAccent, Color3.fromRGB(110, 75, 255))
    elseif style == "orange" then
        themeAccent = Color3.fromRGB(255, 125, 35)
        gradientColors = ColorSequence.new(themeAccent, Color3.fromRGB(255, 205, 75))
    else
        themeAccent = Color3.fromRGB(0, 220, 255)
        gradientColors = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(190, 70, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 220, 255))
        })
    end
    titleGradient.Color = gradientColors
    miscTitleGradient.Color = gradientColors
    customHeadingGradient.Color = gradientColors
    borderGradient.Color = gradientColors
end
rgbNeonButton.MouseButton1Click:Connect(function() setNeon("rgb") end)
cyanNeonButton.MouseButton1Click:Connect(function() setNeon("cyan") end)
purpleNeonButton.MouseButton1Click:Connect(function() setNeon("purple") end)

local function setShine(style)
    shineStyle = style
    if style == "ice" then
        shineColor = Color3.fromRGB(105, 220, 255)
    elseif style == "pink" then
        shineColor = Color3.fromRGB(255, 145, 220)
    else
        shineColor = Color3.new(1, 1, 1)
    end
    light.BackgroundColor3 = shineColor
end
whiteLightButton.MouseButton1Click:Connect(function() setShine("white") end)
blueLightButton.MouseButton1Click:Connect(function() setShine("ice") end)
pinkLightButton.MouseButton1Click:Connect(function() setShine("pink") end)

-- FPS AND PING
local frames = 0
local elapsed = 0

fpsConnection = RunService.RenderStepped:Connect(function(dt)
    frames += 1
    elapsed += dt
    if elapsed >= 0.1 then
        local fps = math.floor(frames / elapsed + 0.5)
        local ping = "--"
        pcall(function()
            ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
        end)
        fpsText.Text = "FPS: " .. fps
        pingText.Text = "PING: " .. tostring(ping)
        frames = 0
        elapsed = 0
    end
end)

-- RGB ANIMATION
rgbConnection = RunService.Heartbeat:Connect(function(dt)
    hue = (hue + dt * 0.13) % 1

    local color
    if neonStyle == "rgb" then
        color = Color3.fromHSV(hue, 0.8, 1)
    else
        color = themeAccent
    end

    border.Color = color
    hudStroke.Color = color
    cardStroke.Color = color
    dashStroke.Color = color
    antiAfkStroke.Color = color
    autoCandyStroke.Color = color
    miscStroke.Color = color
    speedMinusStroke.Color = color
    speedPlusStroke.Color = color
    perfTabStroke.Color = color
    miscTabStroke.Color = color
    customTabStroke.Color = color
    customStroke.Color = color
    originalThemeStroke.Color = color
    halloweenThemeStroke.Color = color
    waterThemeStroke.Color = color
    rgbNeonStroke.Color = color
    cyanNeonStroke.Color = color
    purpleNeonStroke.Color = color
    whiteLightStroke.Color = color
    blueLightStroke.Color = color
    pinkLightStroke.Color = color

    borderGradient.Offset = Vector2.new(math.sin(hue * math.pi * 2) * 0.5, 0)
    titleGradient.Offset = Vector2.new(hue, 0)
    miscTitleGradient.Offset = Vector2.new(hue, 0)
    customHeadingGradient.Offset = Vector2.new(hue, 0)
end)

-- CLOSE CONFIRMATION + ANIME-STYLE DISSOLVE
local closePromptOpen = false

local function createCloseConfirmation()
    if closePromptOpen or not gui.Parent then return end
    closePromptOpen = true

    local shade = new("Frame", {
        Name = "CloseConfirmationShade",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(3, 5, 15),
        BackgroundTransparency = 0.28,
        BorderSizePixel = 0,
        ZIndex = 50
    }, gui)

    local dialog = new("Frame", {
        Name = "CloseConfirmation",
        Size = UDim2.fromOffset(285, 142),
        Position = UDim2.new(0.5, -142, 0.5, -71),
        BackgroundColor3 = Color3.fromRGB(13, 18, 37),
        BorderSizePixel = 0,
        ZIndex = 51
    }, shade)
    corner(dialog, 14)
    local dialogStroke = outline(dialog, Color3.fromRGB(120, 90, 255), 1.8)

    local promptTitle = new("TextLabel", {
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.fromOffset(12, 13),
        BackgroundTransparency = 1,
        Text = "CLOSE LUNA COMMUNITY?",
        TextColor3 = Color3.fromRGB(245, 245, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        ZIndex = 52
    }, dialog)
    rgbText(promptTitle)

    new("TextLabel", {
        Size = UDim2.new(1, -24, 0, 28),
        Position = UDim2.fromOffset(12, 45),
        BackgroundTransparency = 1,
        Text = "Are you sure you want to close the GUI?",
        TextColor3 = Color3.fromRGB(165, 177, 205),
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextWrapped = true,
        ZIndex = 52
    }, dialog)

    local yesButton = new("TextButton", {
        Size = UDim2.fromOffset(112, 34),
        Position = UDim2.new(0, 19, 1, -48),
        BackgroundColor3 = Color3.fromRGB(27, 76, 58),
        Text = "YES",
        TextColor3 = Color3.fromRGB(105, 255, 170),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        BorderSizePixel = 0,
        ZIndex = 53
    }, dialog)
    corner(yesButton, 9)
    outline(yesButton, Color3.fromRGB(65, 220, 145), 1)

    local noButton = new("TextButton", {
        Size = UDim2.fromOffset(112, 34),
        Position = UDim2.new(1, -131, 1, -48),
        BackgroundColor3 = Color3.fromRGB(66, 35, 52),
        Text = "NO",
        TextColor3 = Color3.fromRGB(255, 145, 165),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        BorderSizePixel = 0,
        ZIndex = 53
    }, dialog)
    corner(noButton, 9)
    outline(noButton, Color3.fromRGB(220, 90, 125), 1)

    noButton.MouseButton1Click:Connect(function()
        local fade = TweenService:Create(shade, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        })
        fade:Play()
        fade.Completed:Connect(function()
            if shade.Parent then shade:Destroy() end
            closePromptOpen = false
        end)
    end)

    yesButton.MouseButton1Click:Connect(function()
        if not gui.Parent then return end
        yesButton.Active = false
        noButton.Active = false

        -- Soft violet/cyan embers create a harmless anime-inspired dissolve.
        local origin = main.AbsolutePosition
        local mainSize = main.AbsoluteSize
        for i = 1, 22 do
            local ember = Instance.new("Frame")
            ember.Name = "DissolveEmber"
            ember.AnchorPoint = Vector2.new(0.5, 0.5)
            ember.Size = UDim2.fromOffset(math.random(3, 7), math.random(8, 17))
            ember.Position = UDim2.fromOffset(
                origin.X + math.random(0, math.max(1, mainSize.X)),
                origin.Y + math.random(0, math.max(1, mainSize.Y))
            )
            ember.Rotation = math.random(-45, 45)
            ember.BackgroundColor3 = (i % 2 == 0)
                and Color3.fromRGB(115, 95, 255)
                or Color3.fromRGB(90, 225, 255)
            ember.BackgroundTransparency = 0.12
            ember.BorderSizePixel = 0
            ember.ZIndex = 100
            ember.Parent = gui
            corner(ember, 8)

            local drift = UDim2.fromOffset(
                ember.Position.X.Offset + math.random(-85, 85),
                ember.Position.Y.Offset - math.random(55, 145)
            )
            TweenService:Create(ember, TweenInfo.new(0.72, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = drift,
                BackgroundTransparency = 1,
                Rotation = ember.Rotation + math.random(-100, 100),
                Size = UDim2.fromOffset(1, 2)
            }):Play()
        end

        local fadeInfo = TweenInfo.new(0.68, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        for _, object in ipairs(gui:GetDescendants()) do
            if object:IsA("GuiObject") and object.Name ~= "DissolveEmber" then
                local goals = {}
                if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
                    goals.TextTransparency = 1
                    goals.TextStrokeTransparency = 1
                end
                if object:IsA("ImageLabel") or object:IsA("ImageButton") then
                    goals.ImageTransparency = 1
                end
                if object.BackgroundTransparency < 1 then
                    goals.BackgroundTransparency = 1
                end
                if object == main then
                    goals.Size = UDim2.new(main.Size.X.Scale, main.Size.X.Offset * 0.88, main.Size.Y.Scale, main.Size.Y.Offset * 0.88)
                    goals.Rotation = 7
                elseif object == hud then
                    goals.Size = UDim2.fromOffset(0, 0)
                end
                if next(goals) then
                    TweenService:Create(object, fadeInfo, goals):Play()
                end
            elseif object:IsA("UIStroke") then
                TweenService:Create(object, fadeInfo, {Transparency = 1}):Play()
            end
        end

        TweenService:Create(shade, fadeInfo, {BackgroundTransparency = 1}):Play()
        task.wait(0.78)
        if gui.Parent then gui:Destroy() end
    end)
end

close.MouseButton1Click:Connect(createCloseConfirmation)

-- ===================== LUNA VISUAL UPGRADE =====================
do
    local TOGGLE_KEY = Enum.KeyCode.RightShift -- tecla para abrir/fechar (pode trocar)

    local rnd = Random.new()
    local function ko(t, c) return ColorSequenceKeypoint.new(t, c) end

    -- Pop animado da janela
    local scale = Instance.new("UIScale")
    scale.Parent = main

    -- Brilho neon atrás da janela
    local glow = new("ImageLabel", {
        Name = "LunaGlow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        ImageTransparency = 0.45,
        ZIndex = 0,
    }, gui)

    -- Degradê sutil nos cards (efeito vidro)
    for _, f in ipairs({card, dashCard, antiAfkCard, autoCandyCard, miscCard, customCard}) do
        new("UIGradient", {
            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(165, 165, 185)),
            Rotation = 90,
        }, f)
    end

    -- Hover suave nos botões
    for _, b in ipairs({
        toggle, dashToggle, antiAfkToggle, autoCandyToggle, speedToggle, speedMinus, speedPlus,
        originalThemeButton, halloweenThemeButton, waterThemeButton,
        rgbNeonButton, cyanNeonButton, purpleNeonButton,
        whiteLightButton, blueLightButton, pinkLightButton,
        perfTab, miscTab, customTab,
    }) do
        local s = Instance.new("UIScale")
        s.Parent = b
        b.MouseEnter:Connect(function()
            TweenService:Create(s, TweenInfo.new(0.12), {Scale = 1.06}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(s, TweenInfo.new(0.12), {Scale = 1}):Play()
        end)
    end

    -- Botão de esconder (–) ao lado do ×
    title.Size = UDim2.new(1, -140, 1, 0)
    local hideBtn = new("TextButton", {
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.new(1, -118, 0, 11),
        BackgroundColor3 = Color3.fromRGB(31, 48, 82),
        Text = "–",
        TextColor3 = Color3.fromRGB(120, 220, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, header)
    corner(hideBtn, 8)
    local hideStroke = outline(hideBtn, Color3.fromRGB(70, 160, 255), 1)

    -- Botão flutuante para reabrir (útil no celular)
    local openBtn = new("TextButton", {
        Size = UDim2.fromOffset(46, 46),
        Position = UDim2.new(0, 14, 0.5, -23),
        BackgroundColor3 = Color3.fromRGB(9, 12, 25),
        Text = "🌙",
        TextSize = 22,
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 60,
    }, gui)
    corner(openBtn, 23)
    local openStroke = outline(openBtn, Color3.fromRGB(100, 100, 255), 2)

    footer.Text = "LUNA SYSTEM  •  CLIENT SIDE  •  [RIGHT SHIFT] SHOW / HIDE"

    -- Abrir / fechar
    local shown = true
    local function setShown(state)
        if state == shown then return end
        shown = state
        if state then
            main.Visible = true
            glow.Visible = true
            openBtn.Visible = false
            scale.Scale = 0.85
            TweenService:Create(scale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        else
            TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Scale = 0.85}):Play()
            task.delay(0.18, function()
                if not shown then
                    main.Visible = false
                    glow.Visible = false
                    openBtn.Visible = true
                end
            end)
        end
    end

    hideBtn.MouseButton1Click:Connect(function() setShown(false) end)
    openBtn.MouseButton1Click:Connect(function() setShown(true) end)
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or UserInputService:GetFocusedTextBox() then return end
        if input.KeyCode == TOGGLE_KEY then setShown(not shown) end
    end)

    -- Decoração animada por tema
    local decor = new("Frame", {
        Name = "Decor",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 2,
    }, main)
    local parts = {}

    local function buildDecor(theme)
        decor:ClearAllChildren()
        table.clear(parts)

        if theme == "halloween" then
            local set = {"🦇", "🦇", "🎃", "👻", "🍬", "🦇"}
            for i = 1, 14 do
                local e = set[(i - 1) % #set + 1]
                local bat = e == "🦇"
                local l = new("TextLabel", {
                    BackgroundTransparency = 1, Text = e,
                    TextSize = rnd:NextInteger(14, 26),
                    Size = UDim2.fromOffset(30, 30),
                    TextTransparency = 0.35, ZIndex = 2,
                }, decor)
                parts[#parts + 1] = {
                    o = l, kind = bat and "bat" or "float",
                    x = rnd:NextNumber(0, 360), y = rnd:NextNumber(0, 480),
                    vx = bat and rnd:NextNumber(18, 42) * (i % 2 == 0 and 1 or -1) or rnd:NextNumber(-6, 6),
                    vy = bat and 0 or -rnd:NextNumber(8, 20),
                    ph = rnd:NextNumber(0, 6.28),
                }
            end
            for _, spot in ipairs({{4, 452, "🎃"}, {336, 452, "🎃"}}) do
                new("TextLabel", {
                    BackgroundTransparency = 1, Text = spot[3], TextSize = 44,
                    Size = UDim2.fromOffset(50, 50),
                    Position = UDim2.fromOffset(spot[1], spot[2]),
                    TextTransparency = 0.6, ZIndex = 2,
                }, decor)
            end
        elseif theme == "water" then
            for i = 1, 16 do
                local sz = rnd:NextInteger(6, 18)
                local b = new("Frame", {
                    Size = UDim2.fromOffset(sz, sz),
                    BackgroundColor3 = Color3.fromRGB(120, 230, 255),
                    BackgroundTransparency = 0.85, BorderSizePixel = 0, ZIndex = 2,
                }, decor)
                corner(b, 99)
                new("UIStroke", {Color = Color3.fromRGB(170, 240, 255), Thickness = 1, Transparency = 0.45}, b)
                parts[#parts + 1] = {
                    o = b, kind = "bubble",
                    x = rnd:NextNumber(0, 370), y = rnd:NextNumber(0, 500),
                    vx = 0, vy = -rnd:NextNumber(12, 32), ph = rnd:NextNumber(0, 6.28),
                }
            end
        else
            for i = 1, 16 do
                local l = new("TextLabel", {
                    BackgroundTransparency = 1, Text = "✦",
                    TextSize = rnd:NextInteger(8, 15),
                    TextColor3 = (i % 2 == 0) and Color3.fromRGB(90, 225, 255) or Color3.fromRGB(185, 120, 255),
                    Size = UDim2.fromOffset(20, 20), ZIndex = 2,
                }, decor)
                parts[#parts + 1] = {
                    o = l, kind = "star",
                    x = rnd:NextNumber(0, 370), y = rnd:NextNumber(0, 490),
                    vx = rnd:NextNumber(-3, 3), vy = -rnd:NextNumber(3, 9), ph = rnd:NextNumber(0, 6.28),
                }
            end
        end
    end

    local function dressTheme(theme)
        local seq, shine
        if theme == "halloween" then
            seq = ColorSequence.new({ko(0, Color3.fromRGB(255, 125, 25)), ko(0.5, Color3.fromRGB(255, 210, 90)), ko(1, Color3.fromRGB(255, 125, 25))})
            shine = Color3.fromRGB(255, 225, 185)
        elseif theme == "water" then
            seq = ColorSequence.new({ko(0, Color3.fromRGB(40, 210, 235)), ko(0.5, Color3.fromRGB(90, 150, 255)), ko(1, Color3.fromRGB(40, 210, 235))})
            shine = Color3.fromRGB(200, 245, 255)
        else
            seq = ColorSequence.new({ko(0, Color3.fromRGB(0, 220, 255)), ko(0.5, Color3.fromRGB(190, 70, 255)), ko(1, Color3.fromRGB(0, 220, 255))})
            shine = shineColor
        end
        borderGradient.Color = seq
        titleGradient.Color = seq
        miscTitleGradient.Color = seq
        customHeadingGradient.Color = seq
        light.BackgroundColor3 = shine
        buildDecor(theme)
    end

    -- roda depois do handler original de cada botão de tema
    originalThemeButton.MouseButton1Click:Connect(function() task.defer(dressTheme, "original") end)
    halloweenThemeButton.MouseButton1Click:Connect(function() task.defer(dressTheme, "halloween") end)
    waterThemeButton.MouseButton1Click:Connect(function() task.defer(dressTheme, "water") end)

    -- Loop visual (brilho + partículas)
    local t0 = os.clock()
    local fxConn = RunService.Heartbeat:Connect(function(dt)
        local t = os.clock() - t0
        hideStroke.Color = border.Color
        openStroke.Color = border.Color

        if not main.Visible then return end

        local p = main.AbsolutePosition - gui.AbsolutePosition
        local s = main.AbsoluteSize
        glow.Position = UDim2.fromOffset(p.X - 34, p.Y - 34)
        glow.Size = UDim2.fromOffset(s.X + 68, s.Y + 68)
        glow.ImageColor3 = border.Color
        glow.ImageTransparency = 0.42 + 0.1 * math.sin(t * 2.2)

        for _, q in ipairs(parts) do
            q.x += q.vx * dt
            q.y += q.vy * dt
            if q.x > 400 then q.x = -30 elseif q.x < -30 then q.x = 400 end
            if q.y < -30 then q.y = 520 end
            local wob = 0
            if q.kind == "bat" then
                wob = math.sin(t * 3 + q.ph) * 14
            elseif q.kind == "bubble" or q.kind == "float" then
                q.o.Position = UDim2.fromOffset(q.x + math.sin(t + q.ph) * 6, q.y)
            elseif q.kind == "star" then
                q.o.TextTransparency = 0.45 + 0.4 * math.sin(t * 2 + q.ph)
            end
            if q.kind == "bat" or q.kind == "star" then
                q.o.Position = UDim2.fromOffset(q.x, q.y + wob)
            end
        end
    end)

    gui.Destroying:Connect(function()
        if fxConn then fxConn:Disconnect() end
    end)

    dressTheme("original")
end
-- ===============================================================

gui.Destroying:Connect(function()
    if candyDrawingConnection then
        candyDrawingConnection:Disconnect()
        candyDrawingConnection = nil
    end
    if candyDrawingStatus then
        pcall(function() candyDrawingStatus:Remove() end)
        candyDrawingStatus = nil
    end
    autoCandyEnabled = false

    if enabled then
        setBoost(false)
    end

    if fpsConnection then
        fpsConnection:Disconnect()
    end

    if rgbConnection then
        rgbConnection:Disconnect()
    end

    if speedConnection then
        speedConnection:Disconnect()
    end

    autoCandyEnabled = false
    antiAfkEnabled = false
    player:SetAttribute("LunaAntiAFKEnabled", false)
end)
