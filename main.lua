-- Load Fluent with error handling
local Fluent, SaveManager, InterfaceManager

local function LoadLibrary(url)
    local success, lib = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    return success and lib or nil
end

Fluent = LoadLibrary("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
if not Fluent then 
    warn("Failed to load Fluent UI")
    return 
end

-- Load addons (optional)
SaveManager = LoadLibrary("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua")
InterfaceManager = LoadLibrary("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")

-- Create RatCooker Window
local Window = Fluent:CreateWindow({
    Title = "🐀 RatCooker v2.0",
    SubTitle = "Powered by Fluent UI",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 500),
    Acrylic = false, -- Disabled for better performance
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Create Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "skull" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Main Tab Content
do
    -- Welcome Section
    Tabs.Main:AddParagraph({
        Title = "Welcome to RatCooker",
        Content = "Premium scripting hub with Fluent UI"
    })

    -- Combat Features
    local CombatSection = Tabs.Main:AddSection("Combat")

    CombatSection:AddToggle("AimbotToggle", {
        Title = "Aimbot",
        Default = false,
        Callback = function(Value)
            -- Your aimbot logic here
            Fluent:Notify({
                Title = "Aimbot " .. (Value and "enabled" or "disabled"),
                Content = "Feature status changed",
                Duration = 3
            })
        end
    })

    CombatSection:AddSlider("AimbotFOV", {
        Title = "Aimbot FOV",
        Min = 1,
        Max = 360,
        Default = 90,
        Rounding = 0,
        Callback = function(Value)
            -- Update aimbot FOV
        end
    })

    -- Visuals Section
    local VisualsSection = Tabs.Main:AddSection("Visuals")

    VisualsSection:AddToggle("ESPEnabled", {
        Title = "Player ESP",
        Default = false,
        Callback = function(Value)
            -- Toggle ESP
        end
    })

    VisualsSection:AddColorpicker("ESPColor", {
        Title = "ESP Color",
        Default = Color3.fromRGB(255, 0, 0)
    })
end

-- Player Tab Content
do
    local PlayerSection = Tabs.Player:AddSection("Modification")

    PlayerSection:AddSlider("WalkSpeed", {
        Title = "Walk Speed",
        Min = 16,
        Max = 200,
        Default = 16,
        Rounding = 0,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    })

    PlayerSection:AddButton("ResetCharacter", {
        Title = "Reset Character",
        Callback = function()
            game.Players.LocalPlayer.Character:BreakJoints()
        end
    })
end

-- Settings Tab (Addons)
if SaveManager and InterfaceManager then
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({"WalkSpeed"}) -- Don't save walkspeed
    
    -- Custom config folder for RatCooker
    InterfaceManager:SetFolder("RatCooker")
    SaveManager:SetFolder("RatCooker/configs")
    
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)
end

-- Initialization
Window:SelectTab(1)

Fluent:Notify({
    Title = "RatCooker",
    Content = "Successfully loaded!",
    Duration = 5
})

-- Load any saved config
if SaveManager then
    SaveManager:LoadAutoloadConfig()
end