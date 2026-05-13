--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- PetsReducer
local PetsReducer = Rodux.createReducer({
	EquippedPets = {},
	Pets = {},
	ScaledPetsPower = {},
}, {
	setEquippedPets = function(state, action)
		local newState = table.clone(state)
		newState.EquippedPets = action.value
		return newState
	end,

	setPets = function(state, action)
		local newState = table.clone(state)
		newState.Pets = action.value
		return newState
	end,

	setScaledPetsPower = function(state, action)
		local newState = table.clone(state)
		newState.ScaledPetsPower = action.value
		return newState
	end,
})

return PetsReducer
