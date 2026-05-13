--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- AreaReducer
local ChestsReducer = Rodux.createReducer({
    Chests = {},
    Verified = false,
}, {
    setChests = function(state, action)
        local newState = table.clone(state)
        newState.Chests = action.value
        return newState
    end,
    
    setVerified = function(state, action)
		local newState = table.clone(state)
		newState.Verified = action.value
		return newState
	end,
})

return ChestsReducer