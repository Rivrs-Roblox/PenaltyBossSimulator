--[=[
	Owner: JustStop__
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Rodux = require(ReplicatedStorage.Packages.rodux)

-- RejoinReducer
local RejoinReducer = Rodux.createReducer({
	FirstConnection = os.time(),
	ClaimedRejoinReward = false,
}, {
	setFirstConnection = function(state, action)
		local newState = table.clone(state)
		newState.FirstConnection = action.value
		return newState
	end,
	setClaimedRejoinReward = function(state, action)
		local newState = table.clone(state)
		newState.ClaimedRejoinReward = action.value
		return newState
	end,
})

return RejoinReducer
