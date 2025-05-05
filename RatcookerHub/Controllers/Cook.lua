-- Cook Controller
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Cook = {
    Active = false,
    Target = nil
}

function Cook:Cook(targetPlayer)
    self.Active = true
    self.Target = targetPlayer
    print("Cooking:", targetPlayer.Name)
end

return Cook
