--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

local PetsActions = {
	setEquippedPets = Rodux.makeActionCreator("setEquippedPets", function(value)
		return { value = value }
	end),

	setPets = Rodux.makeActionCreator("setPets", function(value)
		return { value = value }
	end),

	setScaledPetsPower = Rodux.makeActionCreator("setScaledPetsPower", function(value)
		return { value = value }
	end),
}

return PetsActions
