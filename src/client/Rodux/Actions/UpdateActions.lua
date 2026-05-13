--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local UpdateActions = {
    setTimer = Rodux.makeActionCreator("setTimer", function(value)
        return { value = value }
    end),

    setUpdating = Rodux.makeActionCreator("setUpdating", function(value)
        return { value = value }
    end)
}

return UpdateActions