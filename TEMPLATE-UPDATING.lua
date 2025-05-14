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

-- Helper functions
local function getRoot(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
end

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
    if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    
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

-- Dummy ESP logic
local dummyESPEnabled = false
local dummyESPCache = {}
local dummyTargetName = "Dummy"
local dummyContainer = workspace:WaitForChild("Characters", 10) or workspace
local dummyTextColor = Color3.new(1, 0, 0)
local dummyTextSize = UDim2.new(0, 50, 0, 40)
local dummyTextOffset = Vector3.new(0, 3, 0)
local dummyRefreshRate = 1

local function createDummyESP(model)
    if not model or not model:FindFirstChild("HumanoidRootPart") or dummyESPCache[model] then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = model.HumanoidRootPart
    billboard.Size = dummyTextSize
    billboard.StudsOffset = dummyTextOffset
    billboard.AlwaysOnTop = true
    billboard.Name = "ESP"

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = model.Name
    label.TextColor3 = dummyTextColor
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard

    billboard.Parent = game:GetService("CoreGui")
    dummyESPCache[model] = billboard

    model.AncestryChanged:Connect(function(_, newParent)
        if not newParent and dummyESPCache[model] then
            dummyESPCache[model]:Destroy()
            dummyESPCache[model] = nil
        end
    end)
end

local function clearDummyESP()
    for model, gui in pairs(dummyESPCache) do
        gui:Destroy()
        dummyESPCache[model] = nil
    end
end

local function updateDummyESP()
    if not dummyESPEnabled then clearDummyESP() return end
    for _, model in ipairs(dummyContainer:GetChildren()) do
        if model.Name == dummyTargetName then
            createDummyESP(model)
        elseif dummyESPCache[model] then
            dummyESPCache[model]:Destroy()
            dummyESPCache[model] = nil
        end
    end
end

if dummyContainer then
    dummyContainer.ChildAdded:Connect(function(child)
        if child.Name == dummyTargetName and dummyESPEnabled then
            task.wait(0.1)
            createDummyESP(child)
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(dummyRefreshRate)
        updateDummyESP()
    end
end)

-- Main Bring function
local function bringPlayer(targetPlayer)
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local speaker = Players.LocalPlayer
    local char = speaker.Character
    if not char or not targetPlayer or not targetPlayer.Character then return end

    -- Stand up if sitting
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.SeatPart then
        humanoid.Sit = false
        task.wait(0.1)
    end

    -- Anchor all parts
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored then
            part.Anchored = true
        end
    end

    -- Try to bring the player using Swift Kick
    pcall(function()
        local moveset = speaker.PlayerGui:FindFirstChild("Main")
            and speaker.PlayerGui.Main:FindFirstChild("Moveset")
            and speaker.PlayerGui.Main.Moveset:FindFirstChild("Swift Kick")
        if not moveset then return end

        while moveset.Cooldown.Size == UDim2.new(1, 0, 0, 0) do
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
            if targetPlayer and targetPlayer.Character then
                local offset = -3 -- Distance behind
                local targetRoot = getRoot(targetPlayer.Character)
                local myRoot = getRoot(char)
                if targetRoot and myRoot then
                    local behindVector = targetRoot.CFrame.LookVector * offset
                    myRoot.CFrame = targetRoot.CFrame + behindVector
                end
            else
                break
            end
            task.wait()
        end
    end)

    -- Unanchor all parts
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Anchored then
            part.Anchored = false
        end
    end
end

--// ========== ADD UI ELEMENTS TO TABS ==========

Tabs.Main:AddParagraph({
    Title = "Bring rat",
    Content = "use todo"
})

-- Get player list for dropdown
local function getPlayerList()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

-- Refresh player list function
local function refreshPlayerList()
    playerDropdown:SetValues(getPlayerList())
end

-- Auto-refresh player list when players join/leave
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

-- Create dropdown for player selection
local playerDropdown = Tabs.Main:AddDropdown("PlayerSelect", {
    Title = "Select Player",
    Values = getPlayerList(),
    Multi = false,
    Default = nil,
})

-- Add refresh button
Tabs.Main:AddButton({
    Title = "Refresh Player List",
    Callback = refreshPlayerList
})

-- Add bring button with dropdown selection
Tabs.Main:AddButton({
    Title = "Bring Selected Player",
    Callback = function()
        local selectedPlayerName = Options.PlayerSelect.Value
        if selectedPlayerName then
            local targetPlayer = Players:FindFirstChild(selectedPlayerName)
            if targetPlayer then
                bringPlayer(targetPlayer)
            else
                Fluent:Notify({
                    Title = "Error",
                    Content = "Player not found!",
                    Duration = 3
                })
            end
        else
            Fluent:Notify({
                Title = "Error",
                Content = "No player selected!",
                Duration = 3
            })
        end
    end
})

Tabs.Features:AddToggle("DummyESP", {
    Title = "Dummy ESP",
    Default = false,
    Callback = function(state)
        dummyESPEnabled = state
        if state then
            updateDummyESP()
        else
            clearDummyESP()
        end
    end
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

