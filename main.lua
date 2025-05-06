-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Libraries
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Configuration
local CONFIG = {
    targetName = "Dummy",
    containerPath = workspace:WaitForChild("Characters"),
    textColor = Color3.new(1, 0, 0),
    textSize = UDim2.new(0, 50, 0, 40),
    textOffset = Vector3.new(0, 3, 0),
    refreshRate = 1
}

-- State Management
local ESP = {
    Enabled = false,
    Cache = {},
    Loop = nil,
    Connections = {}
}

-- ESP Functions
local function createESP(targetModel)
    if not ESP.Enabled or not targetModel or not targetModel:FindFirstChild("HumanoidRootPart") then return end
    if ESP.Cache[targetModel] then return end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = targetModel.HumanoidRootPart
    billboardGui.Size = CONFIG.textSize
    billboardGui.StudsOffset = CONFIG.textOffset
    billboardGui.AlwaysOnTop = true
    billboardGui.Name = "ESP_"..targetModel.Name
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = targetModel.Name
    label.TextColor3 = CONFIG.textColor
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboardGui
    
    billboardGui.Parent = CoreGui
    ESP.Cache[targetModel] = billboardGui
    
    ESP.Connections[targetModel] = targetModel.AncestryChanged:Connect(function(_, newParent)
        if not newParent then
            if ESP.Cache[targetModel] then
                ESP.Cache[targetModel]:Destroy()
                ESP.Cache[targetModel] = nil
            end
        end
    end)
end

local function clearESP()
    for model, gui in pairs(ESP.Cache) do
        gui:Destroy()
        if ESP.Connections[model] then
            ESP.Connections[model]:Disconnect()
        end
    end
    ESP.Cache = {}
    ESP.Connections = {}
end

local function updateESPs()
    if not ESP.Enabled then return end
    
    for model, gui in pairs(ESP.Cache) do
        if not model.Parent then
            gui:Destroy()
            ESP.Cache[model] = nil
            if ESP.Connections[model] then
                ESP.Connections[model]:Disconnect()
            end
        end
    end
    
    for _, model in ipairs(CONFIG.containerPath:GetChildren()) do
        if model.Name == CONFIG.targetName then
            createESP(model)
        end
    end
end

local function toggleESP(state)
    ESP.Enabled = state
    
    if state then
        updateESPs()
        ESP.Loop = task.spawn(function()
            while ESP.Enabled do
                task.wait(CONFIG.refreshRate)
                updateESPs()
            end
        end)
    else
        clearESP()
        if ESP.Loop then
            task.cancel(ESP.Loop)
            ESP.Loop = nil
        end
    end
end

-- UI Setup
local Window = Fluent:CreateWindow({
    Title = "Rat Cooker",
    SubTitle = "Anti rat police",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Players = Window:AddTab({ Title = "Players", Icon = "users" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- UI Elements
Tabs.Players:AddToggle("DummyESP", {
    Title = "Dummy ESP",
    Default = false,
    Callback = toggleESP
})

-- Event Connections
table.insert(ESP.Connections, CONFIG.containerPath.ChildAdded:Connect(function(child)
    if child.Name == CONFIG.targetName then
        task.wait(0.1)
        if ESP.Enabled then
            createESP(child)
        end
    end
end))

-- Initialization
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("RatCooker")
SaveManager:SetFolder("RatCooker/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "Script Loaded",
    Duration = 5
})
Fluent:SetTheme("Dark")
SaveManager:LoadAutoloadConfig()
Fluent:Init()