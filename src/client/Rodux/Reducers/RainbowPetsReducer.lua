--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- GoldPetsReducer
local RainbowPetsReducer = Rodux.createReducer({
	SelectedRainbowPets = {},
}, {
	setSelectedRainbowPets = function(state, action)
		local newState = table.clone(state)
		newState.SelectedRainbowPets = action.value
		return newState
	end,
})

return RainbowPetsReducer
