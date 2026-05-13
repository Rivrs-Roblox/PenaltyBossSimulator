--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local AreaActions = {
    setAreas = Rodux.makeActionCreator("setAreas", function(value)
        return { value = value }
    end),

    setArea = Rodux.makeActionCreator("setArea", function(value)
        return { value = value }
    end)
}

return AreaActions