--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local SpinsActions = {
	setSpins = Rodux.makeActionCreator("setSpins", function(valueType, value)
		return { valueType = valueType, value = value }
	end),

	setLastFreeSpin = Rodux.makeActionCreator("setLastFreeSpin", function(value)
		return { value = value }
	end),
}

return SpinsActions
