-- ====================================================================
--  PART 1: CONFIG & CLEANUP
-- ====================================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
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
--  PART 2: MOBILE UI CREATION (SCALED FOR POCO)
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
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
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
BStroke.Color = Color3.fromRGB(186, 85, 211)
BStroke.Thickness = 1.5

_G.ShotButton = Instance.new("TextButton")
_G.ShotButton.Size = UDim2.new(0, 60, 0, 60)
_G.ShotButton.Position = UDim2.new(0, 15, 0, 210) 
_G.ShotButton.BackgroundColor3 = Color3.fromRGB(20, 10, 10)
_G.ShotButton.Text = "SHOT"
_G.ShotButton.TextSize = 14
_G.ShotButton.TextColor3 = Color3.fromRGB(255, 50, 50)
_G.ShotButton.Font = Enum.Font.SourceSansBold
_G.ShotButton.ZIndex = 11
_G.ShotButton.Visible = _G.Config.MM2Shot
_G.ShotButton.Parent = _G.ScreenGui
makeDraggable(_G.ShotButton)
Instance.new("UICorner", _G.ShotButton).CornerRadius = UDim.new(0, 12)
local SStroke = Instance.new("UIStroke", _G.ShotButton)
SStroke.Color = Color3.fromRGB(255, 50, 50)
SStroke.Thickness = 2

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
TopLayout.FillDirection = Enum.FillDirection.Horizontal
TopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TopLayout.Padding = UDim.new(0, 10)

_G.Container = Instance.new("Frame", _G.MainFrame)
_G.Container.Size = UDim2.new(1, -20, 1, -50)
_G.Container.Position = UDim2.new(0, 10, 0, 40)
_G.Container.BackgroundTransparency = 1
_G.Container.ZIndex = 11

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
--  PART 3: FUNCTIONS, FIXES & SHOT LOGIC
-- ====================================================================
local pages = {}
function _G.createTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 75, 0, 25)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(110, 110, 110)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 13
    TabBtn.Parent = _G.TopBar

    local Page = Instance.new("ScrollingFrame", _G.Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 5)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        Page.Visible = true
    end)
    table.insert(pages, Page)
    return Page
end

function _G.createToggle(parent, text, configKey, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(40, 20, 40) or Color3.fromRGB(20, 20, 20)
    Btn.Text = text .. ": " .. (_G.Config[configKey] and "ON" or "OFF")
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    Btn.MouseButton1Click:Connect(function()
        _G.Config[configKey] = not _G.Config[configKey]
        Btn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(40, 20, 40) or Color3.fromRGB(20, 20, 20)
        Btn.Text = text .. ": " .. (_G.Config[configKey] and "ON" or "OFF")
        _G.saveSettings()
        if callback then callback(_G.Config[configKey]) end
    end)
    return Btn
end

RunService.Heartbeat:Connect(function()
    if _G.Config.OnePunchFling and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local vel = root:FindFirstChild("FlingForce") or Instance.new("BodyAngularVelocity")
        vel.Name = "FlingForce"
        vel.AngularVelocity = Vector3.new(0, 99999, 0)
        vel.MaxTorque = Vector3.new(0, 99999, 0)
        vel.Parent = root
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local force = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlingForce")
            if force then force:Destroy() end
        end
    end
end)

local function findMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if p.Character:FindFirstChild("Knife") or p.Backpack:FindFirstChild("Knife") then return p end
            if p:FindFirstChild("Role") and p.Role.Value == "Murderer" then return p end
        end
    end
    return nil
end

_G.ShotButton.MouseButton1Click:Connect(function()
    local murderer = findMurderer()
    local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("Gun")
    if not gun then return end
    if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
        if gun.Parent == LocalPlayer.Backpack then gun.Parent = LocalPlayer.Character end
        local mRoot = murderer.Character.HumanoidRootPart
        LocalPlayer.Character.HumanoidRootPart.CFrame = mRoot.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0)
        task.wait(0.1)
        gun:Activate()
    end
end)

local mainTab = _G.createTab("Main")
local mm2Tab = _G.createTab("Game")

_G.createToggle(mm2Tab, "Enable MM2 Menu", "MM2Mod", function(val) _G.MM2Window.Visible = val and _G.MainFrame.Visible end)
_G.createToggle(mm2Tab, "Show SHOT Button", "MM2Shot", function(val) _G.ShotButton.Visible = val end)
_G.createToggle(_G.MM2Content, "Wallhack Roles", "MM2Roles")
_G.createToggle(_G.MM2Content, "Track Gun Drop", "MM2Gun")
_G.createToggle(mainTab, "One Punch Fling", "OnePunchFling")
_G.createToggle(mainTab, "Noclip", "Noclip")

if #pages > 0 then pages[1].Visible = true end
