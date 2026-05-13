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
local GoldPetsReducer = Rodux.createReducer({
    SelectedPets = {}
}, {
    setSelectedPets = function(state, action)
        local newState = table.clone(state)
        newState.SelectedPets = action.value
        return newState
    end,
})

return GoldPetsReducer