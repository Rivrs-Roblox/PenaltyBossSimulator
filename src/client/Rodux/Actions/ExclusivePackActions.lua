--[=[
 	Owner: CategoryTheory
 	Version: 0.0.1
 	Contact owner if any question, concern or feedback
 ]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.rodux)

local ExclusivePackActions = {
	setExclusivePackData = Rodux.makeActionCreator("setExclusivePackData", function(exclusivePack)
        return {
            exclusivePack = exclusivePack,
        }
    end),
    setExclusivePackCurrentIndex = Rodux.makeActionCreator("setExclusivePackCurrentIndex", function(currentIndex)
        return {
            currentIndex = currentIndex,
        }
    end),
}   

return ExclusivePackActions
