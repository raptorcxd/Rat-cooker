-- main.lua
local Players = game:GetService("Players")
local ui = Instance.new("ScreenGui")
ui.Name = "RatCookerUI"
ui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main Window
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Dark theme

-- Fluent Design
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 120, 212) -- Accent blue
stroke.Thickness = 2
stroke.Parent = frame

frame.Parent = ui
print("🐀 RatCooker Fluent UI Loaded!")