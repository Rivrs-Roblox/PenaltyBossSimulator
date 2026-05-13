--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- BoostsReducer
local BoostsReducer = Rodux.createReducer({
    Boosts = {},
    ActiveBoosts = {}
}, {
    setBoosts = function(state, action)
        local newState = table.clone(state)
        newState.Boosts = action.value
        return newState
    end,

    setActiveBoosts = function(state, action)
        local newState = table.clone(state)
        newState.ActiveBoosts = action.value
        return newState
    end
})

return BoostsReducer