--[=[
	Owner: JustStop__
	Version: v0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)

-- DataCacheService
local DataCacheService = Knit.CreateService({
    Name = "DataCacheService",
    Cache = {}
})

--|| Functions ||--
function DataCacheService:CacheDataFile(filename: string)
    local _, err = pcall(function()
        local file = require(ReplicatedStorage.Shared.Data[filename])
        self.Cache[filename] = file
    end)

    if err then
        print("[CACHE SERVICE] File not found: " .. filename)
        return false
    else
        print("[CACHE SERVICE] File content added to cache: " .. filename)
        return true
    end
end

function DataCacheService:CacheDataFiles()
    for _, filename in pairs(ReplicatedStorage.Shared.Data:GetChildren()) do
        self:CacheDataFile(tostring(filename))
    end

    print("[CACHE SERVICE] All data files added to cache.")
end

function DataCacheService:GetFile(filename: string)
    if not self.Cache[filename] then
        self:CacheDataFile(filename)
    end

    return self.Cache[filename]
end

--|| Knit Lifecycle ||--
function DataCacheService:KnitInit()
    self:CacheDataFiles()
    print("[CACHE SERVICE] Controller loaded successfully.")
end

return DataCacheService