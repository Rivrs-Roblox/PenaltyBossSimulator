--[=[
 	Owner: rompionyoann
 	Version: 0.0.1
 	Contact owner if any question, concern or feedback
 ]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- Reducer
local OfflineFarmReducer = Rodux.createReducer({
	powerEarned = 0,
}, {
	setPowerEarned = function(state, action)
        local newState = table.clone(state)
        newState.powerEarned = action.value
        return newState
    end,
})

return OfflineFarmReducer