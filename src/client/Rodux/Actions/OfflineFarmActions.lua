--[=[
 	Owner: CategoryTheory
 	Version: 0.0.1
 	Contact owner if any question, concern or feedback
 ]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.rodux)

local OfflineFarmActions = {
	setPowerEarned = Rodux.makeActionCreator("setPowerEarned", function(value)
        return {
            value = value,
        }
    end),
}

return OfflineFarmActions
