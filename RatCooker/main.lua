-- main.lua (Fluent UI Core)
local Players = game:GetService("Players")
local gui = Instance.new("ScreenGui")
gui.Name = "RatCookerUI"
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Fluent-style Window
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Dark theme
frame.Parent = gui

-- Fluent Design Elements
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(0, 120, 212) -- Accent blue

-- Title
local title = Instance.new("TextLabel")
title.Text = " RatCooker"
title.Font = Enum.Font.GothamSemibold
title.TextColor3 = Color3.new(1, 1, 1)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Parent = frame
