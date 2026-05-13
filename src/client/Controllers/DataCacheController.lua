--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- DataCacheController
local DataCacheController = Knit.CreateController({
    Name = "DataCacheController",
    Cache = {}
})

--|| Functions ||--
function DataCacheController:CacheDataFile(filename: string)
    local _, err = pcall(function()
        local file = require(ReplicatedStorage.Shared.Data[filename])
        self.Cache[filename] = file
    end)

    if err then
        print("[CACHE CONTROLLER] File not found: " .. filename)
        return false
    else
        print("[CACHE CONTROLLER] File content added to cache: " .. filename)
        return true
    end
end

function DataCacheController:CacheDataFiles()
    for _, filename in pairs(ReplicatedStorage.Shared.Data:GetChildren()) do
        self:CacheDataFile(tostring(filename))
    end

    print("[CACHE CONTROLLER] All data files added to cache.")
end

function DataCacheController:GetFile(filename: string)
    if not self.Cache[filename] then
        self:CacheDataFile(filename)
    end

    return self.Cache[filename]
end

--|| Knit Lifecycle ||--
function DataCacheController:KnitInit()
    self:CacheDataFiles()
    print("[CACHE CONTROLLER] Controller loaded successfully.")
end

return DataCacheController