-- [Fluent UI Loader]
local Players = game:GetService("Players")
local gui = Instance.new("ScreenGui")
gui.Name = "RatCookerUI"
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main Window (Fluent Design)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui

-- Fluent Styling
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 120, 212)
stroke.Thickness = 2
stroke.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Text = " RatCooker"
title.Font = Enum.Font.GothamSemibold
title.TextColor3 = Color3.new(1, 1, 1)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Parent = frame

print("UI loaded successfully!")
