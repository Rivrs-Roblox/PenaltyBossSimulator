--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local UIActions = {
    setCurrentUI = Rodux.makeActionCreator("setCurrentUI", function(value)
        return { value = value }
    end),

    setStoreTargetSection = Rodux.makeActionCreator("setStoreTargetSection", function(value)
        return { value = value }
    end),

    resetStoreTargetSection = Rodux.makeActionCreator("resetStoreTargetSection", function()
        return {}
    end),

    resetCurrentUI = Rodux.makeActionCreator("resetCurrentUI", function(value)
        return { value = value }
    end),

    setCurrentSeasonPassUI = Rodux.makeActionCreator("setCurrentSeasonPassUI", function(value)
        return { value = value }
    end),

    resetCurrentSeasonPassUI = Rodux.makeActionCreator("resetCurrentSeasonPassUI", function(value)
        return { value = value }
    end),

    setCurrentChristmasUI = Rodux.makeActionCreator("setCurrentChristmasUI", function(value)
		return { value = value }
	end),

	resetCurrentChristmasUI = Rodux.makeActionCreator("resetCurrentChristmasUI", function(value)
		return { value = value }
	end),
}

return UIActions
