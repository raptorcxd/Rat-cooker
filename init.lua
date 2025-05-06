-- init.lua
local function safeLoad(url)
    local success, result = pcall(function()
        return game:HttpGet(url, true) -- true = disable caching
    end)
    if not success then
        warn("[RatCooker] Failed to load:", url, "\nError:", result)
        return nil
    end
    return result
end

-- Load main UI code
local mainCode = safeLoad("https://raw.githubusercontent.com/raptorcxd/RatCooker/main/main.lua")
if mainCode then
    local success, err = pcall(loadstring(mainCode))
    if not success then
        warn("[RatCooker] Execution error:", err)
    end
else
    warn("[RatCooker] UI failed to initialize")
end