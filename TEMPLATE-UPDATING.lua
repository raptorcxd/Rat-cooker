--// LOAD FLUENT LIBRARY AND ADDONS
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// CREATE YOUR MAIN WINDOW
local Window = Fluent:CreateWindow({
    Title = "Rat Cooker V1",
    SubTitle = "Anti rat police",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

--// CREATE TABS
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Features = Window:AddTab({ Title = "Player", Icon = "accessibility" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

--// ========== FUNCTION LOGIC ==========

-- Fly logic
local flyConn, flyBV
local function flyToggle(state)
    local char = Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if state then
        flyBV = Instance.new("BodyVelocity", hrp)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.MaxForce = Vector3.new(1, 1, 1) * math.huge
        flyConn = RunService.RenderStepped:Connect(function()
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + hrp.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - hrp.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - hrp.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + hrp.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
            if move.Magnitude > 0 then
                flyBV.Velocity = move.Unit * 50
            else
                flyBV.Velocity = Vector3.zero
            end
        end)
    else
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyConn then flyConn:Disconnect() flyConn = nil end
    end
end

-- TP Walk logic
local tpwalking = false
local tpwalkConn = nil
local tpwalkSpeed = 1

local function startTpwalk(speed)
    tpwalking = true
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    tpwalkConn = RunService.Heartbeat:Connect(function(delta)
        if not tpwalking or not char or not hum or not hum.Parent then
            tpwalking = false
            if tpwalkConn then tpwalkConn:Disconnect() tpwalkConn = nil end
            return
        end
        if hum.MoveDirection.Magnitude > 0 then
            char:TranslateBy(hum.MoveDirection * (speed or 1) * delta * 10)
        end
    end)
end

local function stopTpwalk()
    tpwalking = false
    if tpwalkConn then tpwalkConn:Disconnect() tpwalkConn = nil end
end

local function tpwalkToggle(state, speed)
    if state then
        startTpwalk(speed)
    else
        stopTpwalk()
    end
end

--// ========== ADD UI ELEMENTS TO TABS ==========

Tabs.Main:AddParagraph({
    Title = "Cooking tab",
    Content = ""
})

Tabs.Features:AddToggle("Fly", {
    Title = "Fly",
    Default = false,
    Callback = flyToggle
})

Tabs.Features:AddInput("SpeedInput", {
    Title = "TP Walk Speed",
    Default = tostring(tpwalkSpeed),
    Placeholder = "Enter speed (number)",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            tpwalkSpeed = num
            if tpwalking then
                stopTpwalk()
                startTpwalk(tpwalkSpeed)
            end
        else
            Fluent:Notify({
                Title = "Invalid Input",
                Content = "Please enter a valid positive number.",
                Duration = 3
            })
        end
    end
})

Tabs.Features:AddToggle("TPWalk", {
    Title = "TP Walk",
    Default = false,
    Callback = function(state)
        tpwalkToggle(state, tpwalkSpeed)
    end
})

--// ========== ADDONS AND CONFIGURATION ==========

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ratcookerv1")
SaveManager:SetFolder("ratcookerv1/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "Loaded",
    Content = "",
    Duration = 5
})
Fluent:SetTheme("Dark")
SaveManager:LoadAutoloadConfig()
