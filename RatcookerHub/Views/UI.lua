local FluentUI = {}

function FluentUI:CreateWindow(options)
    -- Create ScreenGui
    local ui = Instance.new("ScreenGui")
    ui.Name = "RatCookerUI"
    ui.ResetOnSpawn = false
    ui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    -- Main Container (Fluent-style panel)
    local frame = Instance.new("Frame")
    frame.Size = options.Size or UDim2.new(0, 400, 0, 500)
    frame.Position = UDim2.new(0.5, -frame.Size.X.Offset/2, 0.5, -frame.Size.Y.Offset/2)
    frame.BackgroundColor3 = Color3.fromRGB(32, 32, 32) -- Dark theme
    frame.Parent = ui

    -- Add Fluent UI elements
    local title = Instance.new("TextLabel")
    title.Text = options.Title or "🐀 RatCooker"
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 18
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Parent = frame

    -- Fluent Design Elements
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = frame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(0, 120, 212) -- Fluent blue accent
    uiStroke.Thickness = 2
    uiStroke.Parent = frame

    return ui
end

return FluentUI