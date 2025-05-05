-- RatcookerHub Main
local Modules = require(script.Parent.init)

local function init()
    Modules.UI:CreateHub(" RatcookerHub", Vector2.new(400, 500))
    Modules.Cook:Cook(game.Players.LocalPlayer)
end

return {
    Init = init
}
