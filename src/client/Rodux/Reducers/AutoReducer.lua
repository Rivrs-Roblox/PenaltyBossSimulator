--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- AutoReducer
local AutoReducer = Rodux.createReducer({
    AutoTraining = false,
    AutoWinning = false,
    AutoTrainingCurrent = {}
}, {
    setAutoTraining = function(state, action)
        local newState = table.clone(state)
        newState.AutoTraining = action.value
        return newState
    end,

    setAutoWinning = function(state, action)
        local newState = table.clone(state)
        newState.AutoWinning = action.value
        return newState
    end,

    setAutoTrainingCurrent = function(state, action)
        local newState = table.clone(state)
        newState.AutoTrainingCurrent = action.value
        return newState
    end,
})

return AutoReducer