--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- TrailReducer
local CoachReducer = Rodux.createReducer({
    Coaches = {},
    CurrentCoach = 0
}, {
    setCoaches = function(state, action)
        local newState = table.clone(state)
        newState.Coaches = action.value
        return newState
    end,

    setCoach = function(state, action)
        local newState = table.clone(state)
        newState.CurrentCoach = action.value
        return newState
    end
})

return CoachReducer