--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local TrailsActions = {
	setTrails = Rodux.makeActionCreator("setTrails", function(value)
		return { value = value }
	end),

	setTrail = Rodux.makeActionCreator("setTrail", function(value)
		return { value = value }
	end),
}

return TrailsActions
