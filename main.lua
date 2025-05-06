-- Basic Fluent UI implementation
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local ui = Instance.new("ScreenGui")
ui.Name = "RatCookerUI"
ui.ResetOnSpawn = false
ui.Parent = gui

-- Main Window
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Dark theme
frame.Parent = ui

print("🐀 RatCooker UI loaded successfully!")
return true