-- ====================================================================
--  PART 1: CONFIG & CLEANUP (POCO X6 PRO OPTIMIZED)
-- ====================================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("SimpleNeonSense") then
    CoreGui.SimpleNeonSense:Destroy()
end

local function cleanChar(char)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        for _, child in pairs(root:GetChildren()) do
            if child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child.Name == "FlyVelocity" or child.Name == "FlingForce" then
                child:Destroy()
            end
        end
    end
    for _, child in pairs(char:GetDescendants()) do
        if (child:IsA("Highlight") and (child.Name == "NeonESP" or child.Name == "GunESP")) or child.Name == "GunLabel" or child.Name == "3D_GunLabel" then
            child:Destroy()
        end
    end
end

cleanChar(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(cleanChar)

_G.Config = {
    Speedhack = false, SpeedValue = 16,
    Noclip = false,
    SelectedPlayer = "", Target = false,
    GodModeToggle = false, GodModeType = "Loop",
    SpinBot = false, SpinSpeed = 30,
    FlyMode = false, FlySpeedValue = 40,
    XNeoFlyActive = false,
    OnePunchFling = false,
    ESPToggle = false,  
    ESPColor = "WHITE",
    MM2Mod = false,     
    MM2Roles = false,   
    MM2Gun = false,     
    MM2Shot = false     
}

local FILE_NAME = "SimpleNeon_Config.json"
function _G.saveSettings()
    if writefile then
        local success, encoded = pcall(function() return HttpService:JSONEncode(_G.Config) end)
        if success then writefile(FILE_NAME, encoded) end
    end
end

if readfile and isfile and isfile(FILE_NAME) then
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end)
    if success then 
        for k, v in pairs(decoded) do _G.Config[k] = v end
    end
end
-- ====================================================================
--  PART 2: MOBILE UI & SCALED MM2 WINDOW
-- ====================================================================
_G.ScreenGui = Instance.new("ScreenGui")
_G.ScreenGui.Name = "SimpleNeonSense"
_G.ScreenGui.Parent = CoreGui
_G.ScreenGui.ResetOnSpawn = false
_G.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    gui.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 15, 0, 140)
OpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenButton.Text = "⚙️"
OpenButton.TextSize = 24
OpenButton.TextColor3 = Color3.fromRGB(186, 85, 211)
OpenButton.ZIndex = 11
OpenButton.Parent = _G.ScreenGui
makeDraggable(OpenButton)
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)
local BStroke = Instance.new("UIStroke", OpenButton)
BStroke.Color = Color3.fromRGB(186, 85, 211); BStroke.Thickness = 1.5

_G.ShotButton = Instance.new("TextButton")
_G.ShotButton.Size = UDim2.new(0, 60, 0, 60)
_G.ShotButton.Position = UDim2.new(0, 15, 0, 210) 
_G.ShotButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
_G.ShotButton.Text = "SHOT"
_G.ShotButton.TextSize = 13
_G.ShotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
_G.ShotButton.Font = Enum.Font.SourceSans
_G.ShotButton.ZIndex = 11
_G.ShotButton.Visible = false
_G.ShotButton.Parent = _G.ScreenGui
makeDraggable(_G.ShotButton)
Instance.new("UICorner", _G.ShotButton).CornerRadius = UDim.new(0, 12)
local SStroke = Instance.new("UIStroke", _G.ShotButton)
SStroke.Color = Color3.fromRGB(50, 255, 50); SStroke.Thickness = 1.2

_G.MainFrame = Instance.new("Frame")
_G.MainFrame.Size = UDim2.new(0, 360, 0, 240)
_G.MainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
_G.MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
_G.MainFrame.Visible = false
_G.MainFrame.ZIndex = 10
_G.MainFrame.Parent = _G.ScreenGui
makeDraggable(_G.MainFrame)
Instance.new("UICorner", _G.MainFrame).CornerRadius = UDim.new(0, 8)
local MStroke = Instance.new("UIStroke", _G.MainFrame)
MStroke.Color = Color3.fromRGB(186, 85, 211)

_G.TopBar = Instance.new("Frame", _G.MainFrame)
_G.TopBar.Size = UDim2.new(1, 0, 0, 35)
_G.TopBar.BackgroundTransparency = 1
_G.TopBar.ZIndex = 11
local TopLayout = Instance.new("UIListLayout", _G.TopBar)
TopLayout.FillDirection = Enum.FillDirection.Horizontal; TopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; TopLayout.VerticalAlignment = Enum.VerticalAlignment.Center; TopLayout.Padding = UDim.new(0, 10)

_G.Container = Instance.new("Frame", _G.MainFrame)
_G.Container.Size = UDim2.new(1, -20, 1, -50)
_G.Container.Position = UDim2.new(0, 10, 0, 40)
_G.Container.BackgroundTransparency = 1
_G.Container.ZIndex = 11

-- УВЕЛИЧЕННОЕ ОКНО МЕНЮ ММ2 (+30% К РАЗМЕРУ ПОД СЕНСОР POCO)
_G.MM2Window = Instance.new("Frame")
_G.MM2Window.Size = UDim2.new(0, 210, 0, 170) 
_G.MM2Window.Position = UDim2.new(0.5, 190, 0.5, -85)
_G.MM2Window.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
_G.MM2Window.Visible = false
_G.MM2Window.ZIndex = 20
_G.MM2Window.Parent = _G.ScreenGui
makeDraggable(_G.MM2Window)
Instance.new("UICorner", _G.MM2Window).CornerRadius = UDim.new(0, 6)
local MM2Stroke = Instance.new("UIStroke", _G.MM2Window)
MM2Stroke.Color = Color3.fromRGB(255, 65, 65)

local MM2Title = Instance.new("TextLabel", _G.MM2Window)
MM2Title.Size = UDim2.new(1, 0, 0, 30)
MM2Title.BackgroundTransparency = 1
MM2Title.Text = "MM2 DASHBOARD"
MM2Title.TextColor3 = Color3.fromRGB(255, 65, 65)
MM2Title.Font = Enum.Font.SourceSansBold
MM2Title.TextSize = 14

_G.MM2Content = Instance.new("Frame", _G.MM2Window)
_G.MM2Content.Size = UDim2.new(1, -10, 1, -40)
_G.MM2Content.Position = UDim2.new(0, 5, 0, 35)
_G.MM2Content.BackgroundTransparency = 1
local MM2Layout = Instance.new("UIListLayout", _G.MM2Content)
MM2Layout.Padding = UDim.new(0, 6)

OpenButton.MouseButton1Click:Connect(function()
    local state = not _G.MainFrame.Visible
    _G.MainFrame.Visible = state
    _G.MM2Window.Visible = (_G.Config.MM2Mod and state) or false
end)
-- ====================================================================
--  PART 3: TABS & SYSTEM TEMPLATES
-- ====================================================================
local pages = {}
function _G.createTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 65, 0, 25)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(110, 110, 110)
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.ZIndex = 12
    TabBtn.Parent = _G.TopBar

    local Page = Instance.new("ScrollingFrame", _G.Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ScrollBarThickness = 0
    Page.ZIndex = 12

    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do
            p.Page.Visible = false
            p.Btn.TextColor3 = Color3.fromRGB(110, 110, 110)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(186, 85, 211)
    end)
    pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

_G.pPlayer = _G.createTab("Player")
_G.pVisual = _G.createTab("Visuals")
_G.pGame = _G.createTab("Game")
_G.pOther = _G.createTab("Other")
_G.pSettings = _G.createTab("Settings")

pages["Player"].Page.Visible = true
pages["Player"].Btn.TextColor3 = Color3.fromRGB(186, 85, 211)

function _G.createCheckbox(parent, configKey, text)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)

    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0, 20, 0, 20)
    ToggleBtn.Position = UDim2.new(0, 5, 0, 5)
    ToggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(30, 30, 30)
    ToggleBtn.Text = ""
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -35, 1, 0)
    Label.Position = UDim2.new(0, 35, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 13

    local stateCallback = nil
    ToggleBtn.MouseButton1Click:Connect(function()
        _G.Config[configKey] = not _G.Config[configKey]
        ToggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(30, 30, 30)
        _G.saveSettings()
        if stateCallback then stateCallback(_G.Config[configKey]) end
    end)
    return { OnToggle = function(callback) stateCallback = callback end }
end
-- ====================================================================
--  PART 4: SLIDERS & MOVEMENT PHYSICS LOOP
-- ====================================================================
function _G.createFeatureWithLeftSlider(parent, configKey, speedKey, text, min, max)
    local BigWrapper = Instance.new("Frame", parent)
    BigWrapper.Size = UDim2.new(1, 0, 0, 30)
    BigWrapper.BackgroundTransparency = 1
    BigWrapper.ZIndex = 13

    local MainLine = Instance.new("Frame", BigWrapper)
    MainLine.Size = UDim2.new(1, 0, 0, 30)
    MainLine.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainLine.ZIndex = 14
    Instance.new("UICorner", MainLine).CornerRadius = UDim.new(0, 5)

    local ToggleBtn = Instance.new("TextButton", MainLine)
    ToggleBtn.Size = UDim2.new(0, 20, 0, 20)
    ToggleBtn.Position = UDim2.new(0, 5, 0, 5)
    ToggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(30, 30, 30)
    ToggleBtn.Text = ""; ToggleBtn.ZIndex = 15
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)

    local Label = Instance.new("TextLabel", MainLine)
    Label.Size = UDim2.new(1, -70, 1, 0); Label.Position = UDim2.new(0, 35, 0, 0); Label.BackgroundTransparency = 1; Label.Text = text; Label.TextColor3 = Color3.fromRGB(200, 200, 200); Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Font = Enum.Font.SourceSans; Label.TextSize = 13; Label.ZIndex = 15

    local GearBtn = Instance.new("TextButton", MainLine)
    GearBtn.Size = UDim2.new(0, 25, 0, 25); GearBtn.Position = UDim2.new(1, -30, 0, 2); GearBtn.BackgroundTransparency = 1; GearBtn.Text = "⚙️"; GearBtn.TextSize = 13; GearBtn.ZIndex = 15

    local SliderPanel = Instance.new("Frame", BigWrapper)
    SliderPanel.Size = UDim2.new(1, 0, 0, 0); SliderPanel.Position = UDim2.new(0, 0, 0, 30); SliderPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20); SliderPanel.ClipsDescendants = true; SliderPanel.ZIndex = 13
    Instance.new("UICorner", SliderPanel).CornerRadius = UDim.new(0, 5)

    local SliderBar = Instance.new("Frame", SliderPanel)
    SliderBar.Size = UDim2.new(1, -40, 0, 6); SliderBar.Position = UDim2.new(0, 10, 0, 12); SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40); SliderBar.ZIndex = 14

    local SliderFill = Instance.new("Frame", SliderBar)
    SliderFill.Size = UDim2.new((_G.Config[speedKey] - min) / (max - min), 0, 1, 0); SliderFill.BackgroundColor3 = Color3.fromRGB(186, 85, 211); SliderFill.ZIndex = 15

    local ValueLabel = Instance.new("TextLabel", SliderPanel)
    ValueLabel.Size = UDim2.new(0, 30, 0, 20); ValueLabel.Position = UDim2.new(1, -35, 0, 5); ValueLabel.BackgroundTransparency = 1; ValueLabel.Text = tostring(_G.Config[speedKey]); ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255); ValueLabel.Font = Enum.Font.SourceSansBold; ValueLabel.TextSize = 12; ValueLabel.ZIndex = 15

    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (percentage * (max - min)))
        _G.Config[speedKey] = value
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        ValueLabel.Text = tostring(value)
        _G.saveSettings()
    end

    local sliding = false
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true; updateSlider(input) end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)

    local panelOpen = false
    GearBtn.MouseButton1Click:Connect(function()
        panelOpen = not panelOpen
        SliderPanel:TweenSize(UDim2.new(1, 0, 0, panelOpen and 30 or 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        BigWrapper:TweenSize(UDim2.new(1, 0, 0, panelOpen and 60 or 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    end)

    local stateCallback = nil
    ToggleBtn.MouseButton1Click:Connect(function()
        _G.Config[configKey] = not _G.Config[configKey]
        ToggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(30, 30, 30)
        _G.saveSettings()
        if stateCallback then stateCallback(_G.Config[configKey]) end
    end)
    return { OnToggle = function(callback) stateCallback = callback end }
end

local speedCheat = _G.createFeatureWithLeftSlider(_G.pPlayer, "Speedhack", "SpeedValue", " WalkSpeed Hack", 16, 250)
speedCheat.OnToggle(function(state)
    if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end
end)

local flyCheat = _G.createFeatureWithLeftSlider(_G.pPlayer, "FlyMode", "FlySpeedValue", " Fly Mode (Camera)", 10, 200)
flyCheat.OnToggle(function(state)
    if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
    end
end)

local spinCheat = _G.createFeatureWithLeftSlider(_G.pPlayer, "SpinBot", "SpinSpeed", " Spin Bot", 10, 150)
local noclipCheat = _G.createCheckbox(_G.pPlayer, "Noclip", "Noclip (Walk Through Walls)")

RunService.Stepped:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    if _G.Config.Noclip then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
    if hum and _G.Config.Speedhack and not _G.Config.FlyMode then hum.WalkSpeed = _G.Config.SpeedValue end
    if _G.Config.SpinBot then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(_G.Config.SpinSpeed), 0) end

    if _G.Config.FlyMode then
        if not root:FindFirstChild("FlyVelocity") then
            local flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.Name = "FlyVelocity"; flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5); flyVelocity.Velocity = Vector3.new(0, 0, 0); flyVelocity.Parent = root
        end
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        if hum and hum.MoveDirection.Magnitude > 0 then
            moveDirection = hum.MoveDirection
            local look = camera.CFrame.LookVector
            moveDirection = Vector3.new(moveDirection.X, look.Y, moveDirection.Z)
        end
        if moveDirection.Magnitude > 0 then root.FlyVelocity.Velocity = moveDirection.Unit * _G.Config.FlySpeedValue
        else root.FlyVelocity.Velocity = Vector3.new(0, 0.05, 0) end
    else
        if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
    end
end)
-- ====================================================================
--  PART 5.1: MM2 BUTTONS SETUP & FIXED FLING PHYSICS
-- ====================================================================
local DEFAULT_SHOT_POS = UDim2.new(0, 15, 0, 210)
local DEFAULT_TP_POS = UDim2.new(0, 15, 0, 280)

local baseEspCheat = _G.createCheckbox(_G.pVisual, "ESPToggle", "Player ESP (Neon Chams)")
local mm2SubTabBtn = Instance.new("TextButton", _G.pGame)
mm2SubTabBtn.Size = UDim2.new(1, 0, 0, 30); mm2SubTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); mm2SubTabBtn.Text = "👉 Open Murder Mystery 2 Menu"; mm2SubTabBtn.TextColor3 = Color3.fromRGB(186, 85, 211); mm2SubTabBtn.Font = Enum.Font.SourceSans; mm2SubTabBtn.TextSize = 13
Instance.new("UICorner", mm2SubTabBtn).CornerRadius = UDim.new(0, 5)
local SubStroke = Instance.new("UIStroke", mm2SubTabBtn); SubStroke.Color = Color3.fromRGB(186, 85, 211)

mm2SubTabBtn.MouseButton1Click:Connect(function()
    _G.Config.MM2Mod = not _G.Config.MM2Mod
    _G.MM2Window.Visible = _G.Config.MM2Mod
    _G.saveSettings()
end)

_G.TpGunButton = Instance.new("TextButton")
_G.TpGunButton.Size = UDim2.new(0, 60, 0, 60); _G.TpGunButton.Position = DEFAULT_TP_POS; _G.TpGunButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15); _G.TpGunButton.Text = "TP GUN"; _G.TpGunButton.TextSize = 12; _G.TpGunButton.TextColor3 = Color3.fromRGB(255, 255, 255); _G.TpGunButton.Font = Enum.Font.SourceSans; _G.TpGunButton.ZIndex = 11; _G.TpGunButton.Visible = false; _G.TpGunButton.Parent = _G.ScreenGui

local function makeElementDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    gui.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeElementDraggable(_G.TpGunButton)
Instance.new("UICorner", _G.TpGunButton).CornerRadius = UDim.new(0, 12)
local TpGStroke = Instance.new("UIStroke", _G.TpGunButton); TpGStroke.Color = Color3.fromRGB(186, 85, 211); TpGStroke.Thickness = 1.2

_G.ShotButton.Font = Enum.Font.SourceSans; _G.ShotButton.TextColor3 = Color3.fromRGB(255, 255, 255); _G.ShotButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15); _G.ShotButton.Position = DEFAULT_SHOT_POS
if _G.ShotButton:FindFirstChildOfClass("UIStroke") then
    _G.ShotButton:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(50, 255, 50); _G.ShotButton:FindFirstChildOfClass("UIStroke").Thickness = 1.2
end

local rolesCheat = _G.createCheckbox(_G.MM2Content, "MM2Roles", "Roles Chams (🔴/🔵/⚪)")
local gunEspCheat = _G.createCheckbox(_G.MM2Content, "MM2Gun", "Gun Chams + 3D Text")
local shotCheat = _G.createCheckbox(_G.MM2Content, "MM2Shot", "Shot Murder Button")
local tpGunToggle = _G.createCheckbox(_G.MM2Content, "Target", "TP to Gun Button")
local flingCheat = _G.createCheckbox(_G.pOther, "OnePunchFling", "OnePunchFling (Touch Fling)")

shotCheat.OnToggle(function(state) 
    if state then _G.ShotButton.Position = DEFAULT_SHOT_POS end
    _G.ShotButton.Visible = state 
end)
tpGunToggle.OnToggle(function(state) 
    if state then _G.TpGunButton.Position = DEFAULT_TP_POS end
    _G.TpGunButton.Visible = state 
end)

_G.Config.MM2Shot = false; _G.Config.Target = false; _G.ShotButton.Visible = false; _G.TpGunButton.Visible = false

-- ПОЧИНЕННЫЙ FLING ДЛЯ КИЛЛА ПРИ КАСАНИИ БЕЗ КРАШЕЙ
RunService.Heartbeat:Connect(function()
    if not _G.Config.OnePunchFling or not LocalPlayer.Character then return end
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local vel = myRoot:FindFirstChild("FlingForce") or Instance.new("BodyAngularVelocity")
    vel.Name = "FlingForce"
    vel.AngularVelocity = Vector3.new(0, 99999, 0)
    vel.MaxTorque = Vector3.new(0, 99999, 0)
    vel.Parent = myRoot
end)
