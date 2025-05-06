local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create main window
local Window = Fluent:CreateWindow({
    Title = "Rat Cooker",
    SubTitle = "Anti rat police",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Create tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Players = Window:AddTab({ Title = "Players", Icon = "users" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Dummy ESP Variables
local espConnection = nil
local dummyESPEnabled = false

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Helper functions
local function findDummy()
    for _, child in ipairs(workspace:GetDescendants()) do
        if child.Name == "Dummy" and child:IsA("Model") then
            return child
        end
    end
    return nil
end

local function createESP(dummy)
    if dummy:FindFirstChild("DummyESP") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "DummyESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = dummy

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DummyNameTag"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 1
    billboard.Parent = dummy

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = "DUMMY"
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextScaled = true
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard

    local localPlayer = Players.LocalPlayer
    local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart then
        espConnection = RunService.Heartbeat:Connect(function()
            if dummy:FindFirstChild("HumanoidRootPart") and humanoidRootPart then
                local distance = (humanoidRootPart.Position - dummy.HumanoidRootPart.Position).Magnitude
                textLabel.Text = string.format("DUMMY\n%d studs", math.floor(distance))
            end
        end)
    end
end

local function removeESP(dummy)
    if dummy:FindFirstChild("DummyESP") then dummy.DummyESP:Destroy() end
    if dummy:FindFirstChild("DummyNameTag") then dummy.DummyNameTag:Destroy() end
    if espConnection then espConnection:Disconnect() espConnection = nil end
end

local function toggleDummyESP(enabled)
    dummyESPEnabled = enabled
    local dummy = findDummy()

    if enabled and dummy then
        createESP(dummy)
    elseif not enabled and dummy then
        removeESP(dummy)
    end
end

-- ✅ Add toggle to Players tab (Fluent-style)
local Toggle = Tabs.Players:AddToggle("DummyESP", {
    Title = "Dummy ESP",
    Default = false
})

Toggle:OnChanged(function()
    toggleDummyESP(Options.DummyESP.Value)
end)

Options.DummyESP:SetValue(false)

-- Save/config setup
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("RatCooker")
SaveManager:SetFolder("RatCooker/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Final steps
Fluent:Notify({
    Title = "Script Loaded",
    Duration = 5
})

Window:SelectTab(1)
Fluent:SetTheme("Dark")
SaveManager:LoadAutoloadConfig()

-- ✅ REQUIRED to render UI
Fluent:Init()
