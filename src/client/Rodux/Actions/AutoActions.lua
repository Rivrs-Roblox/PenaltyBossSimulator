--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local AutoActions = {
	setAutoTraining = Rodux.makeActionCreator("setAutoTraining", function(value)
		return { value = value }
	end),

	setAutoWinning = Rodux.makeActionCreator("setAutoWinning", function(value)
		return { value = value }
	end),
}

return AutoActions
