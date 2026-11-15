repeat task.wait() until game:IsLoaded()

local function getGlobalTable()
    return typeof(getgenv) == "function" and typeof(getgenv()) == "table" and getgenv() or _G
end

local t = getGlobalTable()

-- Always fetch the current library. Reusing _FIRELIB here keeps stale MakeWindow code
-- alive after ParentLibrary.lua has been updated.
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zayac333/Pressure/main/ParentLibrary.lua?v=4"))()
if not lib then
    error("Fatal error while loading UI library: Loadstring did not return anything!")
end

local fhop = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zayac333/Pressure/main/OnlyPage.lua"))()
local makeWindow = lib.MakeWindow
lib.MakeWindow = function(self, options, fireHubWindow)
    local window = makeWindow(self, options)
    if fireHubWindow then
        coroutine.wrap(fhop)(window)
    end
    return window
end

t.EAGLE = true
t._FIRELIB = lib

return lib
