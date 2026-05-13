--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local FightActions = {
	setFighting = Rodux.makeActionCreator("setFighting", function(value)
		return { value = value }
	end),

	setAverage = Rodux.makeActionCreator("setAverage", function(value)
		return { value = value }
	end),

	setBarSize = Rodux.makeActionCreator("setBarSize", function(value)
		return { value = value }
	end),

	setBossName = Rodux.makeActionCreator("setBossName", function(value)
		return { value = value }
	end),

	setBossPower = Rodux.makeActionCreator("setBossPower", function(value)
		return { value = value }
	end),

	setClientPower = Rodux.makeActionCreator("setClientPower", function(value)
		return { value = value }
	end),
}

return FightActions
