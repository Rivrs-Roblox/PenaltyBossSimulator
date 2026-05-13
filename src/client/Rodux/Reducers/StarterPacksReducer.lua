--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- StarterPacksReducer
local StarterPacksReducer = Rodux.createReducer({
    BoughtStarterPacks = 0,
}, {
    setBoughtStarterPacks = function(state, action)
        local newState = table.clone(state)
        newState.BoughtStarterPacks = action.value
        return newState
    end,
})

return StarterPacksReducer