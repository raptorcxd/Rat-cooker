-- Safe loader with error handling
local function loadScript()
    local url = "https://raw.githubusercontent.com/raptorcxd/Rat-cooker/main/main.lua"
    local success, response = pcall(function()
        return game:HttpGet(url, true) -- true = disable caching
    end)
    
    if success then
        local loadedFn, err = loadstring(response)
        if loadedFn then
            return loadedFn()
        else
            warn("Compile error:", err)
        end
    else
        warn("HTTP request failed:", response)
    end
end

return loadScript()