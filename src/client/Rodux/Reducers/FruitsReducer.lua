--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- FruitsReducer
local FruitsReducer = Rodux.createReducer({
    Fruits = {},
    ActiveFruits = {}
}, {
    setFruits = function(state, action)
        local newState = table.clone(state)
        newState.Fruits = action.value
        return newState
    end,

    setActiveFruits = function(state, action)
        local newState = table.clone(state)
        newState.ActiveFruits = action.value
        return newState
    end
})

return FruitsReducer