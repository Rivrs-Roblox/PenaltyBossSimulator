--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- UpdateReducer
local UpdateReducer = Rodux.createReducer({
    Timer = 10,
    Updating = false
}, {
    setTimer = function(state, action)
        local newState = table.clone(state)
        newState.Timer = action.value
        return newState
    end,

    setUpdating = function(state, action)
        local newState = table.clone(state)
        newState.Updating = action.value
        return newState
    end
})

return UpdateReducer