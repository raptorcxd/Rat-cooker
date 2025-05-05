-- Main loader
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function loadModule(name)
    return require(ReplicatedStorage:WaitForChild("RatcookerHub"):WaitForChild(name))
end

return {
    Cook = loadModule("Controllers/Cook"),
    UI = loadModule("Views/UI")
}
