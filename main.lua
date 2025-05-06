local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Constants
local CONFIG = {
    TARGET_NAME = "Dummy",
    CONTAINER_PATH = workspace:WaitForChild("Characters"),
    TEXT_COLOR = Color3.new(1, 0, 0),
    TEXT_SIZE = UDim2.new(0, 50, 0, 40),
    TEXT_OFFSET = Vector3.new(0, 3, 0),
    REFRESH_RATE = 1,
    FONT = Enum.Font.SourceSansBold
}

-- State management
local ESP = {
    Enabled = false,
    Cache = {},
    Connections = {},
    Loop = nil
}

-- Core functions
local function createESP(targetModel)
    if not targetModel or not targetModel:FindFirstChild("HumanoidRootPart") then return end
    if ESP.Cache[targetModel] then return end

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = targetModel.HumanoidRootPart
    billboardGui.Size = CONFIG.TEXT_SIZE
    billboardGui.StudsOffset = CONFIG.TEXT_OFFSET
    billboardGui.AlwaysOnTop = true
    billboardGui.Name = "ESP_"..targetModel.Name
    billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = targetModel.Name
    label.TextColor3 = CONFIG.TEXT_COLOR
    label.TextScaled = true
    label.Font = CONFIG.FONT
    label.Parent = billboardGui

    billboardGui.Parent = game:GetService("CoreGui")
    ESP.Cache[targetModel] = billboardGui

    -- Cleanup connection
    ESP.Connections[targetModel] = targetModel.AncestryChanged:Connect(function(_, newParent)
        if not newParent then
            if ESP.Cache[targetModel] then
                ESP.Cache[targetModel]:Destroy()
                ESP.Cache[targetModel] = nil
            end
            if ESP.Connections[targetModel] then
                ESP.Connections[targetModel]:Disconnect()
                ESP.Connections[targetModel] = nil
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
    
    -- Update existing ESPs
    for model, gui in pairs(ESP.Cache) do
        if not model.Parent then
            gui:Destroy()
            ESP.Cache[model] = nil
            if ESP.Connections[model] then
                ESP.Connections[model]:Disconnect()
                ESP.Connections[model] = nil
            end
        end
    end
    
    -- Add new ESPs
    for _, model in ipairs(CONFIG.CONTAINER_PATH:GetChildren()) do
        if model.Name == CONFIG.TARGET_NAME then
            createESP(model)
        end
    end
end

local function toggleESP(state)
    ESP.Enabled = state
    
    if state then
        -- Initial scan
        updateESPs()
        
        -- Start update loop
        ESP.Loop = task.spawn(function()
            while ESP.Enabled do
                updateESPs()
                task.wait(CONFIG.REFRESH_RATE)
            end
        end)
    else
        -- Cleanup
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

-- Add ESP Toggle
Tabs.Players:AddToggle("DummyESP", {
    Title = "Dummy ESP",
    Default = false,
    Callback = toggleESP
})

-- Set up container monitoring
table.insert(ESP.Connections, CONFIG.CONTAINER_PATH.ChildAdded:Connect(function(child)
    if child.Name == CONFIG.TARGET_NAME then
        task.wait(0.1) -- Allow model to fully load
        if ESP.Enabled then
            createESP(child)
        end
    end
end))

-- Initialize Fluent UI
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
    Content = "Dummy ESP system initialized",
    Duration = 3
})
Fluent:SetTheme("Dark")
SaveManager:LoadAutoloadConfig()
Fluent:Init()

-- Cleanup on script termination
game:GetService("UserInputService").WindowFocused:Connect(function()
    if not ESP.Enabled then return end
    updateESPs()
end)

table.insert(ESP.Connections, game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if ESP.Enabled then
        task.wait(1) -- Wait for character to load
        updateESPs()
    end
end))