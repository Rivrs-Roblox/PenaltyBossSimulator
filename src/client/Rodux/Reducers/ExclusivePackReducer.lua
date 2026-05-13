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
local ExclusivePackReducer = Rodux.createReducer({
	exclusivePack = {},
    exclusivePackCurrentIndex = 1,
}, {
	setExclusivePackData = function(state, action)
        local newState = table.clone(state)
        newState.exclusivePack = action.exclusivePack
        return newState
    end,
    setExclusivePackCurrentIndex = function(state, action)
        local newState = table.clone(state)
        newState.exclusivePackCurrentIndex = action.currentIndex
        return newState
    end,
})

return ExclusivePackReducer