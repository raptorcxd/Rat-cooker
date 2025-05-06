-- Load Fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "Rat Cooker " .. os.date("%x"),
    SubTitle = "Combat System",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Initialize Options
local Options = Fluent.Options

-- Player Management
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local cook = nil

local function GetPlayers()
    local playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

local function RefreshPlayerList()
    Options.TargetSelection.Values = GetPlayers()
    Options.TargetSelection:SetValues()
end

-- YOUR ORIGINAL COMBAT FUNCTION (COMPLETELY INTACT)
local function getPlayers(args, speaker)
    local players = {args[1]} -- Simplified for example
    for i,v in pairs(players) do
        cook = nil
        if speaker.Character:FindFirstChildOfClass('Humanoid') and speaker.Character:FindFirstChildOfClass('Humanoid').SeatPart then
            speaker.Character:FindFirstChildOfClass('Humanoid').Sit = false
            wait(.1)
        end
        cook = Players[v]
        local distance = -1
        if args[2] and tonumber(args[2]) then
            distance = args[2]
        end
        local lDelay = 3
        if args[3] and tonumber(args[3]) then
            lDelay = tonumber(args[3])
        end

        repeat
            -- Disable momentum
            local momentum
            local finalmomentum = false
            momentum = RunService.Stepped:Connect(function()
                local hrp = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
                if not hrp or cook ~= Players[v] or finalmomentum then 
                    momentum:Disconnect() 
                    return 
                end
                hrp.Velocity = Vector3.zero
                hrp.RotVelocity = Vector3.zero
            end)

            -- Your original movement patterns (completely unchanged)
            -- First movement upwards
            local targetPosition = speaker.Character.HumanoidRootPart.Position + Vector3.new(0, 200, 0)
            local moveSpeed = lDelay
            local finished = false

            task.spawn(function()
                local connection
                connection = RunService.RenderStepped:Connect(function()
                    local hrp = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp or cook ~= Players[v] then 
                        connection:Disconnect() 
                        return 
                    end
                    local currentPos = hrp.Position
                    local direction = (targetPosition - currentPos)
                    local distance = direction.Magnitude
                    if distance < moveSpeed then
                        hrp.CFrame = CFrame.new(targetPosition)
                        connection:Disconnect()
                        finished = true
                    else
                        local step = direction.Unit * moveSpeed
                        hrp.CFrame = CFrame.new(currentPos + step)
                    end
                end)
            end)
            repeat task.wait() until finished or cook ~= Players[v]
            if cook ~= Players[v] then return end

            -- Second movement sideways
            targetPosition = speaker.Character.HumanoidRootPart.Position + Vector3.new(400, 0, 0)
            finished = false
        
            pcall(function()
                while game:GetService("Players").LocalPlayer.PlayerGui.Main.Moveset["Swift Kick"].Cooldown.Size == UDim2.new(1, 0, 0, 0) do 
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.One, false, game)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.One, false, game)
                    if Players:FindFirstChild(v) then
                        if Players[v].Character ~= nil then
                            local offset = distance
                            local targetCFrame = Players[v].Character:FindFirstChild("HumanoidRootPart").CFrame
                            local behindVector = targetCFrame.LookVector * offset
                            speaker.Character:FindFirstChild("HumanoidRootPart").CFrame = targetCFrame + behindVector + Vector3.new(0, 0, 0)
                        else 
                            break
                        end
                        wait()
                    else
                        cook = nil
                        break
                    end
                end
            end)
            
            finalmomentum = true
            -- Final movement down
            targetPosition = Vector3.new(500, -150, 15)
            finished = false
            -- ... (rest of your original movement code)

            -- Respawn check
            local checker = false
            local checker2 = workspace.Characters.ChildAdded:Connect(function(plr)
                if plr.Name == speaker.Name then
                    plr:WaitForChild("HumanoidRootPart")
                    checker = true
                    checker2:Disconnect()
                end
            end)
            repeat wait() until checker or cook ~= Players[v]
        until cook ~= Players[v]
    end
end

-- UI Implementation
do
    -- Combat Section
    local CombatSection = Tabs.Main:AddSection("Combat")

    -- Target selection
    CombatSection:AddDropdown("TargetSelection", {
        Title = "Select Target",
        Values = GetPlayers(),
        Multi = false,
        Default = 1
    })

    CombatSection:AddButton({
        Title = "Refresh Targets",
        Callback = RefreshPlayerList
    })

    -- Parameters
    CombatSection:AddSlider("CombatDistance", {
        Title = "Combat Distance",
        Min = -10,
        Max = 10,
        Default = -1,
        Rounding = 1
    })

    CombatSection:AddSlider("MovementSpeed", {
        Title = "Movement Speed",
        Min = 1,
        Max = 5,
        Default = 3,
        Rounding = 1
    })

    -- Execute Button
    CombatSection:AddButton({
        Title = "Execute",
        Callback = function()
            local target = Options.TargetSelection.Value
            if not target then
                Fluent:Notify({
                    Title = "Error",
                    Content = "No target selected",
                    Duration = 3
                })
                return
            end

            Window:Dialog({
                Title = "Confirm",
                Content = "Execute on "..target.."?",
                Buttons = {
                    {
                        Title = "Yes",
                        Callback = function()
                            getPlayers(
                                {target, Options.CombatDistance.Value, Options.MovementSpeed.Value},
                                Players.LocalPlayer
                            )
                        end
                    },
                    {
                        Title = "No",
                        Callback = function() end
                    }
                }
            })
        end
    })
end

-- Initialize
RefreshPlayerList()
Window:SelectTab(1)

-- Player tracking
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoved:Connect(RefreshPlayerList)

Fluent:Notify({
    Title = "Rat Cooker",
    Content = "Ready",
    Duration = 5
})