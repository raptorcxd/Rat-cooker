-- File: Controllers/Cook.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Cook = {
    Active = false,
    Target = nil
}

function Cook:Start(targetPlayer)
    self.Target = targetPlayer
    self.Active = true
    
    while self.Active do
        -- Your cooking logic here
        RunService.Heartbeat:Wait()
    end
end

return Cook