-- main.lua
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Create Fluent UI
local ui = Instance.new("ScreenGui")
ui.Name = "RatCookerUI"
ui.ResetOnSpawn = false
ui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main Window (Fluent Design)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
frame.Parent = ui

-- Fluent Styling
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 120, 212)
stroke.Thickness = 2
stroke.Parent = frame

-- Title Bar
local title = Instance.new("TextLabel")
title.Text = "🐀 RatCooker v1.0"
title.Font = Enum.Font.GothamSemibold
title.TextSize = 18
title.TextColor3 = Color3.new(1, 1, 1)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Parent = frame

-- Fluent Button Example
local button = Instance.new("TextButton")
button.Text = "Execute"
button.Size = UDim2.new(0.9, 0, 0, 40)
button.Position = UDim2.new(0.05, 0, 0.2, 0)
button.BackgroundColor3 = Color3.fromRGB(0, 120, 212)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.Gotham
button.Parent = frame

-- Button Hover Effects (Fluent Animation)
button.MouseEnter:Connect(function()
    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 90, 158)}):Play()
end)

button.MouseLeave:Connect(function()
    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 212)}):Play()
end)

print("[RatCooker] Fluent UI loaded successfully!")
return true